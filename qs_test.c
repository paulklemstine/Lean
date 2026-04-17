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
    
    int bits = mpz_sizeinbase(N, 2);
    int fb_target = 150, sieve_len = 300000;
    
    mpz_sqrt(sqrtN, N);
    if (mpz_mul(tmp, sqrtN, sqrtN), mpz_cmp(tmp, N) < 0) mpz_add_ui(sqrtN, sqrtN, 1);
    gmp_printf("N=%Zd, bits=%d, s=%Zd\n", N, bits, sqrtN);
    
    // Build factor base
    int fb[150], root1[150], root2[150];
    int fb_size = 0;
    
    for (int p = 3; fb_size < fb_target && p < 100000; p += 2) {
        int is_prime = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { is_prime=0; break; }
        if (!is_prime) continue;
        
        long long n_mod_p = mpz_fdiv_ui(N, p);
        if (n_mod_p == 0) { printf("N divisible by %d\n", p); return 0; }
        
        long long pw = 1, base = n_mod_p; int exp = (p-1)/2;
        while (exp > 0) { if (exp & 1) pw = (pw*base)%p; base=(base*base)%p; exp>>=1; }
        if (pw != 1) continue;
        
        int r;
        if (p % 4 == 3) {
            long long rb = n_mod_p; r = 1; exp = (p+1)/4;
            while (exp > 0) { if (exp&1) r=(int)(((long long)r*rb)%p); rb=(rb*rb)%p; exp>>=1; }
        } else {
            r = -1;
            for (int t = 1; t < p; t++) if (((long long)t*t)%p==n_mod_p) { r=t; break; }
            if (r < 0) continue;
        }
        
        long long s_mod_p = mpz_fdiv_ui(sqrtN, p);
        fb[fb_size] = p;
        root1[fb_size] = (int)((r - s_mod_p + p) % p);
        root2[fb_size] = (int)((p - r - s_mod_p + 2*(long long)p) % p);
        if (root2[fb_size] >= p) root2[fb_size] -= p;
        fb_size++;
    }
    
    printf("Factor base: %d primes (first: %d, last: %d)\n", fb_size, fb[0], fb[fb_size-1]);
    
    // Sieve first block
    double *sieve = malloc(sieve_len * sizeof(double));
    for (int i = 0; i < sieve_len; i++) sieve[i] = 0.0;
    
    for (int j = 0; j < fb_size; j++) {
        int p = fb[j]; double lp = log((double)p);
        // For block 0, x_start = 0, so start1 = root1[j], start2 = root2[j]
        for (int i = root1[j]; i < sieve_len; i += p) sieve[i] += lp;
        if (root1[j] != root2[j])
            for (int i = root2[j]; i < sieve_len; i += p) sieve[i] += lp;
    }
    
    // Count smooth candidates
    double threshold = 0;
    for (int j = 0; j < fb_size; j++) threshold += log((double)fb[j]);
    printf("Sum of all log(fb): %.1f\n", threshold);
    
    int candidates = 0, smooth = 0;
    for (int i = 0; i < sieve_len; i++) {
        // Estimate log(Q(i))
        double logQ = log(2.0) + mpz_sizeinbase(sqrtN, 2)*0.693 + (i > 0 ? log((double)i) : 0);
        if (sieve[i] < logQ - log((double)fb[fb_size-1])*2) continue;
        candidates++;
        
        // Check exact smooth
        mpz_set_si(Qx, i);
        mpz_add(Qx, Qx, sqrtN);
        mpz_mul(Qx, Qx, Qx);
        mpz_sub(Qx, Qx, N);
        mpz_abs(Qx, Qx);
        mpz_set(tmp, Qx);
        
        for (int j = 0; j < fb_size && mpz_cmp_ui(tmp, 1) > 0; j++)
            while (mpz_divisible_ui_p(tmp, fb[j])) mpz_divexact_ui(tmp, tmp, fb[j]);
        
        if (mpz_cmp_ui(tmp, 1) == 0) smooth++;
    }
    
    printf("Candidates: %d, Smooth: %d\n", candidates, smooth);
    
    // Debug: check first few candidates manually
    int count = 0;
    for (int i = 0; i < sieve_len && count < 5; i++) {
        double logQ = log(2.0) + mpz_sizeinbase(sqrtN, 2)*0.693 + (i > 0 ? log((double)i) : 0);
        if (sieve[i] < logQ - log((double)fb[fb_size-1])*2) continue;
        
        mpz_set_si(Qx, i);
        mpz_add(Qx, Qx, sqrtN);
        mpz_mul(Qx, Qx, Qx);
        mpz_sub(Qx, Qx, N);
        printf("x=%d: Q=%Zd, sieve=%.1f, logQ=%.1f\n", i, Qx, sieve[i], logQ);
        count++;
    }
    
    free(sieve);
    mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp);
    return 0;
}
