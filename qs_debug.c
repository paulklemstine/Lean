#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

int main(int argc, char **argv) {
    if (argc < 2) { printf("Usage: %s N\n", argv[0]); return 1; }
    
    mpz_t N, sqrtN, Qx, tmp;
    mpz_init_set_str(N, argv[1], 10);
    mpz_init(sqrtN); mpz_init(Qx); mpz_init(tmp);
    
    int bits = mpz_sizeinbase(N, 2);
    printf("N has %d bits\n", bits);
    
    // Build factor base
    int fb_size = (bits <= 90) ? 200 : (bits <= 110) ? 400 : 800;
    int sieve_len = (bits <= 90) ? 200000 : (bits <= 110) ? 500000 : 1000000;
    
    int *fb_primes = malloc(fb_size * sizeof(int));
    int *fb_r1 = malloc(fb_size * sizeof(int));
    int *fb_r2 = malloc(fb_size * sizeof(int));
    int actual_fb = 0;
    
    mpz_sqrt(sqrtN, N);
    mpz_add_ui(sqrtN, sqrtN, 1);  // ceil(sqrt(N))
    
    for (int p = 3; actual_fb < fb_size && p < 50000; p += 2) {
        int is_prime = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { is_prime=0; break; }
        if (!is_prime) continue;
        
        // Check QR
        long long n_mod_p = mpz_fdiv_ui(N, p);
        if (n_mod_p == 0) {
            printf("N divisible by %d!\n", p);
            return 0;
        }
        
        // Euler criterion
        long long pw = 1, base = n_mod_p;
        int exp = (p-1)/2;
        while (exp > 0) {
            if (exp & 1) pw = (pw * base) % p;
            base = (base * base) % p;
            exp >>= 1;
        }
        if (pw != 1) continue;  // not a QR
        
        // Find sqrt(N) mod p via Tonelli-Shanks (simplified for p ≡ 3 mod 4)
        int r;
        if (p % 4 == 3) {
            long long rbase = n_mod_p, rexp = (p+1)/4;
            r = 1;
            while (rexp > 0) {
                if (rexp & 1) r = (int)(((long long)r * rbase) % p);
                rbase = (rbase * rbase) % p;
                rexp >>= 1;
            }
        } else {
            // p ≡ 1 mod 4: use Tonelli-Shanks
            // Simplified: just try all residues
            r = -1;
            for (int t = 1; t < p; t++) {
                if (((long long)t * t) % p == n_mod_p) { r = t; break; }
            }
            if (r < 0) continue;
        }
        
        fb_primes[actual_fb] = p;
        long long s_mod_p = mpz_fdiv_ui(sqrtN, p);
        fb_r1[actual_fb] = (int)((r - s_mod_p + p) % p);  // x such that Q(x) ≡ 0
        fb_r2[actual_fb] = (int)((p - r - s_mod_p + p) % p);  // second root
        actual_fb++;
    }
    
    fb_size = actual_fb;
    printf("Factor base: %d primes\n", fb_size);
    
    // Sieve
    double *sieve = malloc(sieve_len * sizeof(double));
    int nrels = 0;
    int max_rels = fb_size + 20;
    
    // Allocate relation storage
    mpz_t *rel_x = malloc(max_rels * sizeof(mpz_t));
    mpz_t *rel_Q = malloc(max_rels * sizeof(mpz_t));
    int **rel_factors = malloc(max_rels * sizeof(int*));
    int *rel_nfactors = malloc(max_rels * sizeof(int));
    int *rel_sign = malloc(max_rels * sizeof(int));
    for (int i = 0; i < max_rels; i++) {
        mpz_init(rel_x[i]); mpz_init(rel_Q[i]);
        rel_factors[i] = NULL;
    }
    
    double threshold = 0;
    for (int j = 0; j < fb_size; j++) threshold += log((double)fb_primes[j]);
    threshold *= 0.55;  // tuning parameter
    
    for (int block = 0; nrels < max_rels && block < 30; block++) {
        int x_off = block * sieve_len;
        
        for (int i = 0; i < sieve_len; i++) sieve[i] = 0.0;
        
        for (int j = 0; j < fb_size; j++) {
            int p = fb_primes[j];
            double lp = log((double)p);
            int r1 = (fb_r1[j] + x_off % p) % p;
            int r2 = (fb_r2[j] + x_off % p) % p;
            if (r1 < 0) r1 += p;
            if (r2 < 0) r2 += p;
            
            for (int x = r1; x < sieve_len; x += p) sieve[x] += lp;
            if (r1 != r2) {
                for (int x = r2; x < sieve_len; x += p) sieve[x] += lp;
            }
        }
        
        for (int x = 0; x < sieve_len && nrels < max_rels; x++) {
            if (sieve[x] < threshold) continue;
            
            long long xx = (long long)x + x_off;
            
            mpz_set_si(Qx, xx);
            mpz_add(Qx, Qx, sqrtN);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = (mpz_sgn(Qx) < 0) ? 1 : 0;
            mpz_abs(Qx, Qx);
            
            mpz_set(tmp, Qx);
            int facs[2000];
            int nfacs = 0;
            
            for (int j = 0; j < fb_size && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, fb_primes[j])) {
                    mpz_divexact_ui(tmp, tmp, fb_primes[j]);
                    facs[nfacs++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                mpz_set_si(rel_x[nrels], xx);
                mpz_add(rel_x[nrels], rel_x[nrels], sqrtN);
                mpz_set(rel_Q[nrels], Qx);
                rel_factors[nrels] = malloc(nfacs * sizeof(int));
                memcpy(rel_factors[nrels], facs, nfacs * sizeof(int));
                rel_nfactors[nrels] = nfacs;
                rel_sign[nrels] = sign;
                nrels++;
            }
        }
    }
    
    printf("Found %d relations (need %d)\n", nrels, fb_size);
    
    if (nrels >= fb_size) {
        printf("Enough relations! Would do LA now...\n");
    }
    
    // Cleanup
    for (int i = 0; i < max_rels; i++) {
        mpz_clear(rel_x[i]); mpz_clear(rel_Q[i]);
        free(rel_factors[i]);
    }
    free(rel_x); free(rel_Q); free(rel_factors); free(rel_nfactors); free(rel_sign);
    free(sieve); free(fb_primes); free(fb_r1); free(fb_r2);
    mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp);
    return 0;
}
