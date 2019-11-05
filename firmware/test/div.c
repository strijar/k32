int main() {
    unsigned int n = 0x12345678;
    unsigned int d = 0x777;

    unsigned int q = 0;
    unsigned int r = 0;

    int i;

    for (i = 0; i < 32; i++) {
        r = r << 1;
        r = r | (n >> 31);
        n = n << 1;

        if (r >= d) {
            r = r - d;
            q = q | 1;
        }

        q = q << 1;

        printf("%08X %08X\n", q, r);
    }

    q = q >> 1;
    printf("%08X %08X\n", q, r);

    return 0;
}
