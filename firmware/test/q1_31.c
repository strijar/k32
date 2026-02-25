#include <stdio.h>
#include <stdint.h>

int32_t from_float(float x) {
    return x * 2147483648.0f;
}

float to_float(int32_t x) {
    return x / 2147483648.0f;
}

int32_t q_mul(int32_t x, int32_t y) {
    int32_t res;

    if (x == 0x80000000 && y == 0x80000000) {
        res = 0x7FFFFFFF;
    } else {
        int64_t prod = (int64_t) x * (int64_t) y;

        res = (int32_t)(prod >> 31);
    }

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

    return res;
}

int main() {
    int32_t x = from_float(0.5f);
    int32_t y = from_float(0.25f);
    int32_t res = q_mul(x, y);

    printf("%08X %08X = %08X (%.7f)\n", x, y, res, to_float(res));

    return 0;
}
