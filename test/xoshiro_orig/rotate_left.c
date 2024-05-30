#include <stdint.h>
#include <stdio.h>

static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

int main() {
    printf("%llx\n", rotl(123456789, 3));
}