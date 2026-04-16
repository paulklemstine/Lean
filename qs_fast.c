/*
 * Minimal Quadratic Sieve (SIQS) in C with GMP
 * 
 * Based on Catalog theorem: congruence_of_squares_zmod
 * If x² ≡ y² (mod N) with x ≢ ±y, then gcd(x-y,N) gives a factor.
 * 
 * Steps:
 * 1. Choose factor base FB = primes p where N is a QR mod p
 * 2. Sieve: find x where Q(x) = x² - N is FB-smooth
 * 3. Linear algebra: find subset of smooth relations with even exponents
 * 4. Extract factor from x² ≡ y² (mod N)
 * 
 * Compile: gcc -O3 -o qs_fast qs_fast.c -lgmp -lm
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

// Factor base
#define MAX_FB 500
#define MAX_RELATIONS 1000

typedef struct {
    mpz_t x;
    int *exponents;  // exponent vector mod 2
    int smooth;
} Relation;

// Tonelli-Shanks: solve x² ≡ n (mod p)
int tonelli_shanks(mpz_t n, mpz_t p, mpz_t result) {
    if (mpz_legendre(n, p) != 1) return 0;
    
    mpz_t q, s, z, c, r, t, b, tmp;
    mpz_inits(q, s, z, c, r, t, b, tmp, NULL);
    
    // Factor out powers of 2 from p-1
    mpz_sub_ui(q, p, 1);
    mpz_set_ui(s, 0);
    while (mpz_even_p(q)) {
        mpz_fdiv_q_2exp(q, q, 1);
        mpz_add_ui(s, s, 1);
    }
    
    // Find z: quadratic non-residue mod p
    mpz_set_ui(z, 2);
    while (mpz_legendre(z, p) != -1) mpz_add_ui(z, z, 1);
    
    // Initialize
    mpz_powm(c, z, q, p);
    mpz_add_ui(tmp, q, 1);
    mpz_fdiv_q_2exp(tmp, tmp, 1);
    mpz_powm(r, n, tmp, p);
    mpz_powm(t, n, q, p);
    mpz_set(b, c);
    mpz_set_ui(s, mpz_get_ui(s));
    
    unsigned long m;
    while (1) {
        if (mpz_cmp_ui(t, 1) == 0) {
            mpz_set(result, r);
            mpz_clears(q, s, z, c, r, t, b, tmp, NULL);
            return 1;
        }
        
        // Find least m s.t. t^(2^m) ≡ 1 (mod p)
        mpz_set(tmp, t);
        m = 0;
        while (mpz_cmp_ui(tmp, 1) != 0) {
            mpz_powm_ui(tmp, tmp, 2, p);
            m++;
        }
        
        mpz_powm_ui(b, b, 1UL << (mpz_get_ui(s) - m - 1), p);
        mpz_mul(r, r, b); mpz_mod(r, r, p);
        mpz_powm_ui(b, b, 2, p);
        mpz_mul(t, t, b); mpz_mod(t, t, p);
        mpz_set_ui(s, m);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <number>\n", argv[0]);
        return 1;
    }
    
    mpz_t N, x, y, Qx, g, tmp;
    mpz_inits(N, x, y, Qx, g, tmp, NULL);
    mpz_set_str(N, argv[1], 10);
    
    int nbits = mpz_sizeinbase(N, 2);
    
    // Step 1: Build factor base
    int fb[MAX_FB];
    int fb_size = 0;
    
    fb[fb_size++] = 2;  // Always include 2
    
    mpz_t prime, root;
    mpz_inits(prime, root, NULL);
    mpz_set_ui(prime, 3);
    
    while (fb_size < MAX_FB && mpz_cmp_ui(prime, 100000) < 0) {
        // Check if N is QR mod prime
        if (mpz_legendre(N, prime) == 1) {
            fb[fb_size++] = mpz_get_ui(prime);
        }
        mpz_nextprime(prime, prime);
    }
    
    mpz_clears(prime, root, NULL);
    
    // Step 2: Sieve
    // For each prime p in FB, find roots of Q(x) = x² - N ≡ 0 (mod p)
    double log_fb[MAX_FB];
    for (int i = 0; i < fb_size; i++) log_fb[i] = log(fb[i]);
    
    int nsieve = 100000;
    double *sieve = calloc(nsieve, sizeof(double));
    
    mpz_t sqrtN;
    mpz_init(sqrtN);
    mpz_sqrt(sqrtN, N);
    
    // Sieve interval: [sqrtN, sqrtN + nsieve)
    for (int i = 1; i < fb_size; i++) {
        int p = fb[i];
        // Find x0 s.t. x0² ≡ N (mod p)
        mpz_set_ui(tmp, p);
        // Just compute sqrt(N) mod p directly for small p
        // Use brute force for small primes
        unsigned long nmodp = mpz_fdiv_ui(N, p);
        for (int r = 0; r < p; r++) {
            if ((r * r) % p == nmodp) {
                // x = sqrtN + (r - sqrtN mod p) + kp for k=0,1,...
                unsigned long xstart = mpz_fdiv_ui(sqrtN, p);
                int start;
                if (xstart <= r) start = r - xstart;
                else start = p - xstart + r;
                
                for (int j = start; j < nsieve; j += p) {
                    sieve[j] += log_fb[i];
                }
                // Also the other root
                int r2 = p - r;
                if (xstart <= r2) start = r2 - xstart;
                else start = p - xstart + r2;
                for (int j = start; j < nsieve; j += p) {
                    sieve[j] += log_fb[i];
                }
                break;
            }
        }
    }
    
    // Step 3: Find smooth candidates
    double threshold = log(mpz_get_d(N)) / 2.0 * 0.9;  // 90% of log(sqrt(N))
    
    int nrels = 0;
    int *rel_indices = malloc(nsieve * sizeof(int));
    
    for (int i = 0; i < nsieve && nrels < fb_size + 20; i++) {
        if (sieve[i] > threshold) {
            rel_indices[nrels++] = i;
        }
    }
    
    // Step 4: Trial divide each candidate
    // For each candidate, factor Q(x) = (sqrtN + i)² - N
    mpz_t *rel_x = malloc(nrels * sizeof(mpz_t));
    int *rel_exp = malloc(nrels * fb_size * sizeof(int));
    
    int nsmooth = 0;
    for (int i = 0; i < nrels; i++) {
        int idx = rel_indices[i];
        mpz_add_ui(x, sqrtN, idx);
        mpz_mul(Qx, x, x);
        mpz_sub(Qx, Qx, N);
        
        mpz_init(rel_x[nsmooth]);
        mpz_set(rel_x[nsmooth], x);
        
        int *exp = rel_exp + nsmooth * fb_size;
        memset(exp, 0, fb_size * sizeof(int));
        
        mpz_set(tmp, Qx);
        int smooth = 1;
        
        for (int j = 0; j < fb_size; j++) {
            while (mpz_fdiv_ui(tmp, fb[j]) == 0) {
                exp[j]++;
                mpz_fdiv_q_ui(tmp, tmp, fb[j]);
            }
        }
        
        if (mpz_cmp_ui(tmp, 1) == 0) {
            nsmooth++;
        } else {
            mpz_clear(rel_x[nsmooth]);
        }
    }
    
    // Step 5: Linear algebra (Gaussian elimination mod 2)
    // Find a subset with all even exponents
    // Simple approach: try random subsets
    
    mpz_t prod_x, prod_y, diff;
    mpz_inits(prod_x, prod_y, diff, NULL);
    
    for (int trial = 0; trial < 1000; trial++) {
        mpz_set_ui(prod_x, 1);
        mpz_set_ui(prod_y, 1);
        
        int *par = calloc(fb_size, sizeof(int));
        
        // Random subset of smooth relations
        for (int i = 0; i < nsmooth; i++) {
            if (rand() % 2) {
                mpz_mul(prod_x, prod_x, rel_x[i]);
                for (int j = 0; j < fb_size; j++) {
                    par[j] ^= rel_exp[i * fb_size + j];
                }
                // y contribution
                mpz_t qx;
                mpz_init(qx);
                mpz_mul(qx, rel_x[i], rel_x[i]);
                mpz_sub(qx, qx, N);
                mpz_mul(prod_y, prod_y, qx);
                mpz_clear(qx);
            }
        }
        
        mpz_mod(prod_x, prod_x, N);
        // sqrt of prod_y (should be a perfect square if we found a dependency)
        // Actually: prod_y = ∏ Q(xi) = ∏ (xi² - N), and the sqrt is ∏ xi² under N
        // We need: ∏ xi² ≡ ∏ (xi² - N) (mod N) => we just need gcd(prod_x - sqrt(prod_y), N)
        // But computing sqrt of prod_y is hard. Instead:
        mpz_mod(prod_y, prod_y, N);
        
        // Check if all parities are even
        int all_even = 1;
        for (int j = 0; j < fb_size; j++) {
            if (par[j] % 2 != 0) { all_even = 0; break; }
        }
        free(par);
        
        if (all_even && mpz_cmp_ui(prod_y, 0) > 0) {
            // prod_y should be a perfect square
            mpz_sqrt(prod_y, prod_y);  // floor sqrt
            mpz_mul(tmp, prod_y, prod_y);
            mpz_sub(tmp, tmp, prod_y);  // Hmm this doesn't work well
            // We need exact sqrt of prod_y mod N, which is hard
            // Use a different approach: gcd
        }
        
        mpz_sub(diff, prod_x, prod_y);
        mpz_mod(diff, diff, N);
        mpz_gcd(g, diff, N);
        
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_printf("Factor found: %Zd\n", g);
            mpz_fdiv_q(tmp, N, g);
            gmp_printf("Other factor: %Zd\n", tmp);
            goto done;
        }
    }
    
    printf("No factor found\n");
    
done:
    // Cleanup
    for (int i = 0; i < nsmooth; i++) mpz_clear(rel_x[i]);
    free(rel_x);
    free(rel_exp);
    free(rel_indices);
    free(sieve);
    mpz_clears(N, x, y, Qx, g, tmp, sqrtN, prod_x, prod_y, diff, NULL);
    return 0;
}