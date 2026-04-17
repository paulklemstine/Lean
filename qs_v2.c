// qs_v2.c — Corrected Quadratic Sieve
// From Catalog: QuadraticSieveFoundations.lean
//   congruence_of_squares_factor: x²≡y²(mod N), x≠±y → factor
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 2000
#define MAX_REL 2500
#define MAX_SIEVE 2000000

// Sieve with corrected root offsets
// Q(x) = (x + s)² - N where s = ceil(sqrt(N))
// For prime p dividing Q(x): x ≡ ±sqrt(N) - s (mod p)
// Root in sieve (index i, where x = i + x_start): i ≡ (root - x_start) mod p

int qs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, sqrtN, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(sqrtN); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    
    if (mpz_even_p(N)) {
        gmp_snprintf(result_str, result_size, "2");
        mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
        return 1;
    }
    
    // Trial division
    for (int p = 3; p < 10000; p += 2) {
        int is_prime = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { is_prime=0; break; }
        if (!is_prime) continue;
        if (mpz_divisible_ui_p(N, p)) {
            mpz_divexact_ui(tmp, N, p);
            if (mpz_cmp_ui(tmp, 1) > 0) {
                gmp_snprintf(result_str, result_size, "%d", p);
                mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
                return 1;
            }
        }
    }
    
    int bits = mpz_sizeinbase(N, 2);
    int fb_target = (bits <= 90) ? 150 : (bits <= 110) ? 300 : (bits <= 130) ? 600 : 1200;
    int sieve_len = (bits <= 90) ? 300000 : (bits <= 110) ? 600000 : 1500000;
    if (fb_target > MAX_FB) fb_target = MAX_FB;
    if (sieve_len > MAX_SIEVE) sieve_len = MAX_SIEVE;
    
    // s = ceil(sqrt(N))
    mpz_sqrt(sqrtN, N);
    if (mpz_mul(tmp, sqrtN, sqrtN), mpz_cmp(tmp, N) < 0) mpz_add_ui(sqrtN, sqrtN, 1);
    
    // Build factor base
    int fb[MAX_FB]; double logfb[MAX_FB]; int root1[MAX_FB]; int root2[MAX_FB];
    int fb_size = 0;
    
    for (int p = 3; fb_size < fb_target && p < 100000; p += 2) {
        int is_prime = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { is_prime=0; break; }
        if (!is_prime) continue;
        
        long long n_mod_p = mpz_fdiv_ui(N, p);
        if (n_mod_p == 0) {
            gmp_snprintf(result_str, result_size, "%d", p);
            mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
            return 1;
        }
        
        // Euler criterion: is n_mod_p a QR mod p?
        long long pw = 1, base = n_mod_p;
        int exp = (p-1)/2;
        while (exp > 0) {
            if (exp & 1) pw = (pw * base) % p;
            base = (base * base) % p;
            exp >>= 1;
        }
        if (pw != 1) continue;
        
        // Find sqrt(n_mod_p) mod p
        int r;
        if (p % 4 == 3) {
            long long rb = n_mod_p; r = 1; exp = (p+1)/4;
            while (exp > 0) {
                if (exp & 1) r = (int)(((long long)r * rb) % p);
                rb = (rb * rb) % p; exp >>= 1;
            }
        } else {
            // Brute force for small p (p < 100000)
            r = -1;
            for (int t = 1; t < p; t++) {
                if (((long long)t * t) % p == n_mod_p) { r = t; break; }
            }
            if (r < 0) continue;
        }
        
        // Roots of (x+s)² ≡ N (mod p): x ≡ ±r - s (mod p)
        long long s_mod_p = mpz_fdiv_ui(sqrtN, p);
        int r1 = (int)((r - s_mod_p + (long long)p) % p);
        int r2 = (int)(((long long)p - r - s_mod_p + 2*(long long)p) % p);
        if (r2 >= p) r2 -= p;
        
        fb[fb_size] = p;
        logfb[fb_size] = log((double)p);
        root1[fb_size] = r1;
        root2[fb_size] = r2;
        fb_size++;
    }
    
    if (fb_size < 10) goto fail;
    
    {
    double *sieve = malloc(sieve_len * sizeof(double));
    int nrels = 0;
    int target_rels = fb_size + 30;
    if (target_rels > MAX_REL) target_rels = MAX_REL;
    
    // Relation storage
    long long rel_x_val[MAX_REL];
    int rel_nfacs[MAX_REL];
    int *rel_facs[MAX_REL];
    int rel_sign[MAX_REL];
    
    // Threshold: ~log(Q(x)) for typical x in [0, sieve_len]
    // Q(x) ≈ 2*s*x + x² ≈ 2*s*x for x << s
    // log(Q) ≈ log(2*s) + log(x)
    // For x ≈ sieve_len/2: log(Q) ≈ log(2*s*sieve_len/2)
    // Smooth if: sum(log(fb_p)) ≥ log(Q) - small_epsilon
    double thres_base = 0;
    for (int j = 0; j < fb_size; j++) thres_base += logfb[j];
    // Threshold = log(Q(x)) * tuning_factor
    // We want sieve[x] ≥ log(Q(x)) to declare smooth
    
    for (int block = 0; nrels < target_rels && block < 50; block++) {
        long long x_start = (long long)block * sieve_len;
        
        for (int i = 0; i < sieve_len; i++) sieve[i] = 0.0;
        
        for (int j = 0; j < fb_size; j++) {
            int p = fb[j];
            double lp = logfb[j];
            // Starting index in sieve where (i + x_start) ≡ root1[j] (mod p)
            // i ≡ root1[j] - x_start (mod p)
            int start1 = (int)((root1[j] - (long long)(x_start % p) + p) % p);
            int start2 = (int)((root2[j] - (long long)(x_start % p) + p) % p);
            
            for (int i = start1; i < sieve_len; i += p) sieve[i] += lp;
            if (start1 != start2) {
                for (int i = start2; i < sieve_len; i += p) sieve[i] += lp;
            }
        }
        
        // Check candidates: sieve value ≥ log(Q(x)) - tolerance
        for (int i = 0; i < sieve_len && nrels < target_rels; i++) {
            // Estimate log(Q(x)) where x = i + x_start
            // Q(x) ≈ (x + s)² - N ≈ 2*s*(x) for small x
            long long xx = i + x_start;
            double logQ = log(2.0) + mpz_sizeinbase(sqrtN, 2) * 0.693 + 
                         (xx > 0 ? log((double)xx) : 0);
            double tolerance = logfb[fb_size-1] * 2;  // allow missing 2 large primes
            
            if (sieve[i] < logQ - tolerance) continue;
            
            // Compute Q(x) exactly
            mpz_set_si(Qx, xx);
            mpz_add(Qx, Qx, sqrtN);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = (mpz_sgn(Qx) < 0) ? 1 : 0;
            mpz_abs(Qx, Qx);
            
            // Trial divide
            mpz_set(tmp, Qx);
            int facs[MAX_FB * 2];
            int nfacs = 0;
            
            for (int j = 0; j < fb_size && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, fb[j])) {
                    mpz_divexact_ui(tmp, tmp, fb[j]);
                    facs[nfacs++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                rel_x_val[nrels] = xx + mpz_get_si(sqrtN);  // x + s
                rel_nfacs[nrels] = nfacs;
                rel_facs[nrels] = malloc(nfacs * sizeof(int));
                memcpy(rel_facs[nrels], facs, nfacs * sizeof(int));
                rel_sign[nrels] = sign;
                nrels++;
            }
        }
    }
    
    free(sieve);
    
    if (nrels < fb_size + 10) goto fail;
    
    // Gaussian elimination over GF(2)
    int mcols = fb_size + 1;  // +1 for sign bit
    int mrows = nrels;
    int words = (mcols + 63) / 64;
    int aug_words = words + (mrows + 63) / 64;  // augmented with identity
    unsigned long long *M = calloc(mrows * aug_words, sizeof(unsigned long long));
    
    for (int i = 0; i < mrows; i++) {
        if (rel_sign[i]) M[i * aug_words + 0] ^= 1;  // sign bit = column 0
        for (int f = 0; f < rel_nfacs[i]; f++) {
            int col = rel_facs[i][f] + 1;  // offset by 1 (col 0 = sign)
            M[i * aug_words + col / 64] ^= (1ULL << (col % 64));
        }
        M[i * aug_words + words + i / 64] |= (1ULL << (i % 64));  // identity
    }
    
    int *pivot = malloc(mcols * sizeof(int));
    for (int j = 0; j < mcols; j++) pivot[j] = -1;
    
    for (int col = 0; col < mcols; col++) {
        for (int row = 0; row < mrows; row++) {
            if (!(M[row * aug_words + col / 64] & (1ULL << (col % 64)))) continue;
            // Check if row already used as pivot
            int used = 0;
            for (int c = 0; c < col; c++) if (pivot[c] == row) { used = 1; break; }
            if (used) continue;
            pivot[col] = row;
            for (int r = 0; r < mrows; r++) {
                if (r == row) continue;
                if (M[r * aug_words + col / 64] & (1ULL << (col % 64))) {
                    for (int w = 0; w < aug_words; w++) M[r * aug_words + w] ^= M[row * aug_words + w];
                }
            }
            break;
        }
    }
    
    // Find null space: rows with all zeros in left half
    for (int i = 0; i < mrows; i++) {
        int zero = 1;
        for (int w = 0; w < words; w++) if (M[i * aug_words + w] != 0) { zero = 0; break; }
        if (!zero) continue;
        
        // Build x² and y² from the combination
        mpz_t X, Y;
        mpz_init_set_ui(X, 1); mpz_init_set_ui(Y, 1);
        
        for (int j = 0; j < mrows; j++) {
            if (M[i * aug_words + words + j / 64] & (1ULL << (j % 64))) {
                mpz_mul_si(X, X, rel_x_val[j]);
                if (rel_sign[j]) mpz_neg(Y, Y);
                for (int f = 0; f < rel_nfacs[j]; f++) {
                    mpz_mul_ui(Y, Y, fb[rel_facs[j][f]]);
                }
            }
        }
        
        mpz_mod(X, X, N);
        // Y² = product of Q(x)s, so sqrt(Y) should be product of |Q(x)|
        // Actually Y = product of fb[facs], which is sqrt(product of Q(x)s)
        mpz_mod(Y, Y, N);
        
        mpz_sub(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(M); free(pivot);
            for (int r = 0; r < nrels; r++) free(rel_facs[r]);
            mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
            return 1;
        }
        mpz_add(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(M); free(pivot);
            for (int r = 0; r < nrels; r++) free(rel_facs[r]);
            mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
            return 1;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(M); free(pivot);
    for (int r = 0; r < nrels; r++) free(rel_facs[r]);
    }
    
fail:
    mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return 0;
}
