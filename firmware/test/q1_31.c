#include <stdio.h>
#include <stdint.h>

int32_t from_float(float x) {
    int32_t res = x * 2147483648.0f;

    printf("%.5f -> %08X\n", x, res);

    return res;
}

float to_float(int32_t x) {
    float res = x / 2147483648.0f;

    printf("%08X -> %.5f\n", x, res);

    return res;
}

int32_t q_mul(int32_t x, int32_t y) {
    int32_t res;

    if (x == 0x80000000 && y == 0x80000000) {
        res = 0x7FFFFFFF;
    } else {
        int64_t prod = (int64_t) x * (int64_t) y;

        res = (int32_t)(prod >> 31);
    }

    printf("%08X * %08X = %08X\n", x, y, res);

    return res;
}

int32_t q_add(int32_t x, int32_t y) {
    int64_t res = (int64_t) x + (int64_t) y;

    if (res > 2147483647) {
        res = 2147483647;
    }

    if (res < -2147483647) {
        res = -2147483647;
    }

    printf("%08X + %08X = %08X\n", x, y, res);

    return res;
}

int32_t q_sub(int32_t x, int32_t y) {
    int64_t res = (int64_t) x - (int64_t) y;

    if (res > 2147483647) {
        res = 2147483647;
    }

    if (res < -2147483647) {
        res = -2147483647;
    }

    printf("%08X - %08X = %08X\n", x, y, res);

    return res;
}

int main() {
    int32_t res;

    /*
    res = from_float(0.5f);
    res = q_add(res, q_mul(from_float(0.6f), from_float(0.5f)));
    res = q_add(res, q_mul(from_float(0.5f), from_float(0.4f)));
    */

    res = q_sub(from_float(0.7f), from_float(0.2f));
    res = q_sub(res, from_float(0.6f));
    res = q_sub(res, from_float(0.5f));
    res = q_sub(res, from_float(0.5f));

    to_float(res);

    return 0;
}
