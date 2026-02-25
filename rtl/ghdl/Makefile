GHDL=ghdl-gcc
GHDLFLAGS= --std=93 --ieee=synopsys --workdir=work
GHDLRUNFLAGS=--wave=tb_k32.ghw

SRC = \
    ../core/k32_pkg.vhd\
    ../core/k32_fetch.vhd\
    ../core/k32_decode.vhd\
    ../core/k32_dstack.vhd\
    ../core/k32_ex.vhd\
    ../core/k32.vhd\
    ../soc/uart.vhd\
    txt_util.vhd\
    trace.vhd\
    tb_k32.vhd\
    ram_life_16x16.vhd

OBJS = \
    work/txt_util.o \
    work/k32_pkg.o \
    work/trace.o \
    work/k32_fetch.o \
    work/k32_decode.o \
    work/k32_dstack.o \
    work/k32_ex.o \
    work/k32.o \
    work/ram_life_16x16.o \
    work/uart.o \
    work/tb_k32.o

all: tb_k32

tb_k32: work/work-obj93.cf $(OBJS)
	$(GHDL) -e $(GHDLFLAGS) $@

work/work-obj93.cf:
	mkdir work
	$(GHDL) -i $(GHDLFLAGS) $(SRC)

run: tb_k32
	$(GHDL) -r tb_k32 $(GHDLRUNFLAGS)

clean:
	rm -rf work tb_k32 *.o *.ghw *.log

# Targets to analyze files

$(OBJS): $(SRC)

work/%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

work/%.o: ../core/%.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

work/%.o: ../soc/%.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

