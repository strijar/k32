#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdarg.h>

#include "io.h"

#define CPU_ID          0
#define RAM_SIZE        64000
#define DSTACK_SIZE     16
#define RSTACK_SIZE     16

typedef union {
    unsigned int all;

    struct {
        unsigned int x          : 5;
        unsigned int dstack     : 3;
        unsigned int rstack     : 3;
        unsigned int free       : 4;
        unsigned int bmem       : 1;
        unsigned int nt         : 1;
        unsigned int tr         : 1;
        unsigned int tn         : 1;
        unsigned int rpc        : 1;
        unsigned int op         : 4;
        unsigned int b_sel      : 2;
        unsigned int a_sel      : 3;
    };
} alu_bits;

typedef union {
    unsigned int all;

    struct {
        unsigned int data       : 29;
        unsigned int type       : 2;
        unsigned int lit        : 1;
    };

    struct {
        unsigned int lit_data   : 31;
    };
} inst_bits;

typedef struct {
    unsigned int        *data;
    unsigned int        t, n;
    int                 sp;
    int                 max;
} stack_type;

unsigned char   *ram_byte;
unsigned int    *ram_word;
unsigned int    pc;
unsigned long   clk = 0;

stack_type      ds;
stack_type      rs;

int             trace_file = -1;

/* * */

void trace(const char *format, ...) {
    if (trace_file < 0) return;

    char        buf[128];
    int         len;
    va_list     ap;

    va_start(ap, format);
    len = vsnprintf(buf, sizeof(buf), format, ap);
    va_end(ap);
    write(trace_file, buf, len);
}

/* Stack */

void stack_next(stack_type *stack, unsigned int data);

void stack_init(stack_type *stack, int max) {
    stack->data = calloc(max, sizeof(unsigned int));
    stack->max = max;
    stack->sp = 0;
    stack->t = 0;
    stack->n = 0;
}

void stack_pop(stack_type *stack) {
    stack->sp--;

    if (stack->sp < 0)
        stack->sp = stack->max - 1;

    stack->n = stack->data[stack->sp];
}

void stack_push(stack_type *stack) {
    stack->sp++;

    if (stack->sp == stack->max)
        stack->sp = 0;

    stack_next(stack, stack->t);
}

void stack_next(stack_type *stack, unsigned int data) {
    stack->n = data;
    stack->data[stack->sp] = data;
}

void stack_trace() {
    trace(" | %08X %08X %02i | %08X %08X %02i ", ds.t, ds.n, ds.sp, rs.t, rs.n, rs.sp);
}

/* Data bus  */

unsigned int read_word(unsigned int addr) {
    if (addr < RAM_SIZE) {
        return ram_word[addr >> 2];
    } else {
        return io_read(addr);
    }
}

unsigned int read_byte(unsigned int addr) {
    if (addr < RAM_SIZE) {
        return ram_byte[addr];
    } else {
        return io_read(addr);
    }
}

void write_word(unsigned int addr, unsigned int data) {
    if (addr < RAM_SIZE) {
        ram_word[addr >> 2] = data;
    } else {
        io_write(addr, data);
    }
}

void write_byte(unsigned int addr, unsigned char data) {
    if (addr < RAM_SIZE) {
        ram_byte[addr] = data & 0xFF;
    } else {
        io_write(addr, data);
    }
}

/* * */

void init() {
    ram_byte = calloc(RAM_SIZE, sizeof(char));
    ram_word = (unsigned int*) ram_byte;

    stack_init(&ds, DSTACK_SIZE);
    stack_init(&rs, RSTACK_SIZE);

    pc = 0;
}

void load(char *name, unsigned int addr) {
    int f = open(name, O_RDONLY);

    if (f > 0) {
        int res = read(f, ram_byte + addr, RAM_SIZE-addr);

        if (res < 0) {
            printf("Error: read file %s\n", name);
        } else {
            printf("Loaded file %s (%i bytes)\n", name, res);
        }

        close(f);
    } else {
        printf("Error: open file %s\n", name);
    }
}

void alu(unsigned int all) {
    alu_bits            bits = { .all = all };
    unsigned int        a, b, ds_top;

    switch (bits.a_sel) {
        case 0: a = ds.t;       break;
        case 1: a = ds.n;       break;
        case 2: a = rs.t;       break;
        case 3: a = rs.n;       break;
        case 4: a = CPU_ID;     break;
        case 5: a = bits.x;     break;
        case 6: a = ds.sp;      break;
        default: a = 0;
    }

    switch (bits.b_sel) {
        case 0: b = bits.x;     break;
        case 1: b = ds.t;       break;
        case 2: b = ds.n;       break;
        case 3: b = rs.t;       break;
        default: b = 0;
    }

    switch (bits.op) {
        case 0: ds_top = a + b;                                                 break;
        case 1: ds_top = a - b;                                                 break;
        case 2: ds_top = a & b;                                                 break;
        case 3: ds_top = a | b;                                                 break;
        case 4: ds_top = a ^ b;                                                 break;
        case 5: ds_top = ~a;                                                    break;
        case 6: ds_top = (a == b) ? -1 : 0;                                     break;
        case 7: ds_top = ((signed)a < (signed)b) ? -1 : 0;                      break;
        case 8: ds_top = (a < b) ? -1 : 0;                                      break;
        case 9: ds_top = a >> b;                                                break;
        case 10: ds_top = a << b;                                               break;
        case 11: ds_top = bits.bmem ? read_byte(ds.t) : read_word(ds.t);        break;

        default:
            trace("<-- Bye (%02X) clk:%li\n", bits.op, clk);
            exit(1);
    }

    if (bits.nt) {
        if (bits.bmem) {
            write_byte(ds.t, ds.n);
        } else {
            write_word(ds.t, ds.n);
        }
    }

    switch (bits.dstack) {
        case 1: stack_push(&ds);  break;
        case 2: stack_pop(&ds);   break;
    }

    if (bits.rpc) {
        pc = rs.t;
        trace("\n");
    } else {
        pc += 4;
    }

    switch (bits.rstack) {
        case 1:
            stack_push(&rs);
            break;

        case 2:
            rs.t = rs.n;
            stack_pop(&rs);
        break;
    }

    if (bits.tn) {
        stack_next(&ds, ds.t);
    }

    if (bits.tr) {
        rs.t = ds.t;
    }

    ds.t = ds_top;
}

void step() {
    unsigned int        inst = read_word(pc);
    inst_bits           bits;

    bits.all = inst;

    trace("%08X %08X ", pc, inst);

    if (bits.lit) {
        trace("Lit      : %08X ", inst);
        stack_trace();
        stack_push(&ds);
        ds.t = bits.lit_data;
        pc += 4;
    } else {
        switch (bits.type) {
            case 0:
                trace("Jump     : %08X ", bits.data);
                stack_trace();
                pc = bits.data;
                break;

            case 1:
                trace("CondJump : %08X ", bits.data);
                stack_trace();

                pc = ds.t ? (pc + 4) : bits.data;
                ds.t = ds.n;
                stack_pop(&ds);
                break;

            case 2:
                trace("Call     : %08X ", bits.data);
                stack_trace();
                trace("\n");

                stack_push(&rs);
                rs.t = pc + 4;
                pc = bits.data;
                break;

            case 3:
                trace("ALU      : %08X ", bits.data);
                stack_trace();

                alu(bits.data);
                break;
        }
    }

    trace("\n");
}

int main() {
    init();

    // trace_file = open("k32.log", O_WRONLY | O_CREAT, 0644);

    load("k32_vec.bin",  0x0000);
    load("k32_main.bin", 0x0020);
    load("k32_nuc.bin",  0x8000);

    while(1) {
        step();
        clk++;
    }

    return 0;
}
