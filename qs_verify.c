#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

int main(int argc, char **argv) {
    if (argc < 2) return 1;
    mpz_t N, sqrtN, Qx, tmp;
    mpz_init_set_str(N, argv[1], 10);
    mpz_init(sqrtN); mpz_init(Qx); mpz_init(tmp);
    
    mpz_sqrt(sqrtN, N);
    if (mpz_mul(tmp, sqrtN, sqrtN), mpz_cmp(tmp, N) < 0) mpz_add_ui(sqrtN, sqrtN, 1);
    
    // Verify: for x=2, Q(2) should be 6808148
    mpz_set_si(Qx, 2);
    mpz_add(Qx, Qx, sqrtN);
    mpz_mul(Qx, Qx, Qx);
    mpz_sub(Qx, Qx, N);
    gmp_printf("Q(2) = %Zd\n", Qx);
    
    // Factor base: just check x=2 manually
    int Q2 = 6808148;
    // 6808148 = 2^2 * 1702037 = 2^2 * 293 * 5809... wait
    // Let me check: 6808148 / 4 = 1702037
    // 1702037 / 293 = 5814.?... not exact
    // Actually let me just compute in Python. But first, the sieve is working!
    // The issue is in the C QS's Gaussian elimination or null space extraction.
    
    mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp);
    return 0;
}
