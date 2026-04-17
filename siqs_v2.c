// siqs_v2.c — Self-Initializing Quadratic Sieve (fixed root computation)
// Catalog: QuadraticSieveFoundations — congruence_of_squares_factor, smooth_relation_congruence
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 8000
#define MAX_REL 10000

// Modular exponentiation (unsigned long long)
static unsigned long long pow_mod_ul(unsigned long long b, unsigned long long e, unsigned long long m) {
    unsigned long long r = 1; b %= m;
    while (e > 0) { if (e & 1) r = r * b % m; b = b * b % m; e >>= 1; }
    return r;
}

// Tonelli-Shanks: sqrt(n) mod p
static unsigned long long sqrt_mod_ul(unsigned long long n, unsigned long long p) {
    if (p == 2) return n & 1;
    if (p % 4 == 3) return pow_mod_ul(n, (p + 1) / 4, p);
    // Full Tonelli-Shanks
    unsigned long long Q = p - 1; int S = 0;
    while (Q % 2 == 0) { Q /= 2; S++; }
    unsigned long long z = 2;
    while (pow_mod_ul(z, (p - 1) / 2, p) != p - 1) z++;
    unsigned long long M = S, c = pow_mod_ul(z, Q, p);
    unsigned long long t = pow_mod_ul(n, Q, p), R = pow_mod_ul(n, (Q + 1) / 2, p);
    while (1) {
        if (t == 1) return R;
        if (t == 0) return 0;
        unsigned long long i = 0, tmp = t;
        while (tmp != 1 && i < M) { tmp = tmp * tmp % p; i++; }
        unsigned long long b = c;
        for (unsigned long long j = 0; j < M - i - 1; j++) b = b * b % p;
        R = R * b % p; t = t * b % p * b % p; c = b * b % p; M = i;
    }
}

int siqs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    int retval = 0;
    
    int bits = (int)mpz_sizeinbase(N, 2);
    
    // Trial division
    for (unsigned long p = 3; p < 100000; p += 2) {
        int ip = 1; for (int d = 3; d*d <= (int)p; d += 2) if (p%d==0){ip=0;break;}
        if (!ip) continue;
        if (mpz_divisible_ui_p(N, p)) {
            gmp_snprintf(result_str, result_size, "%lu", p);
            retval = 1; goto done;
        }
    }
    
    // Parameters
    int fb_target, sieve_len;
    if (bits <= 64) { fb_target = 60; sieve_len = 50000; }
    else if (bits <= 80) { fb_target = 150; sieve_len = 150000; }
    else if (bits <= 100) { fb_target = 400; sieve_len = 400000; }
    else if (bits <= 120) { fb_target = 800; sieve_len = 800000; }
    else if (bits <= 140) { fb_target = 1500; sieve_len = 1500000; }
    else if (bits <= 160) { fb_target = 2500; sieve_len = 2000000; }
    else if (bits <= 180) { fb_target = 4000; sieve_len = 3000000; }
    else { fb_target = 6000; sieve_len = 4000000; }
    
    // Factor base: primes p where (N|p) = 1
    int fb[MAX_FB]; 
    double log_fb[MAX_FB];
    int fb_sz = 0;
    
    unsigned long long *fb_r1 = malloc(MAX_FB * sizeof(unsigned long long)); // root1: sqrt(N) mod p
    unsigned long long *fb_r2 = malloc(MAX_FB * sizeof(unsigned long long)); // root2: (p - sqrt(N)) mod p
    
    for (unsigned long p = 3; fb_sz < fb_target && p < 500000; p += 2) {
        int ip = 1; for (int d = 3; d*d <= (int)p; d += 2) if (p%d==0){ip=0;break;}
        if (!ip) continue;
        
        unsigned long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) { gmp_snprintf(result_str, result_size, "%lu", p); retval=1; goto done_fb; }
        
        unsigned long long leg = pow_mod_ul(nm, (p-1)/2, p);
        if (leg != 1) continue;
        
        unsigned long long sr = sqrt_mod_ul(nm, p);
        fb[fb_sz] = (int)p;
        log_fb[fb_sz] = log((double)p);
        fb_r1[fb_sz] = sr;        // This is sqrt(N mod p)
        fb_r2[fb_sz] = p - sr;   // Second root
        fb_sz++;
    }
    
    // Compute s = ceil(sqrt(N))
    mpz_sqrt(s, N);
    if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
    
    // Sieve around s: Q(x) = (x)² - N where x = s + i, i in [-M/2, M/2]
    // Roots of Q(x) ≡ 0 (mod p): x ≡ ±sqrt(N) (mod p)
    // For x = s + i: i ≡ ±sqrt(N) - s (mod p)
    // So the sieve starts for prime p are:
    //   i1 = (r1 - s) mod p  where r1 = sqrt(N) mod p
    //   i2 = (r2 - s) mod p  where r2 = p - sqrt(N) mod p
    
    unsigned long long *s_mod_p = malloc(fb_sz * sizeof(unsigned long long)); // s mod p for each fb prime
    for (int j = 0; j < fb_sz; j++) {
        s_mod_p[j] = mpz_fdiv_ui(s, (unsigned long)fb[j]);
        // Compute roots for the interval center
        fb_r1[j] = (fb_r1[j] - s_mod_p[j] + (unsigned long long)fb[j]) % (unsigned long long)fb[j];
        fb_r2[j] = (fb_r2[j] - s_mod_p[j] + (unsigned long long)fb[j]) % (unsigned long long)fb[j];
    }
    
    // Sieve
    int nrels = 0;
    int target = fb_sz + 25;
    if (target > MAX_REL) target = MAX_REL;
    
    double *sv = malloc(sieve_len * sizeof(double));
    
    // xs_values and their smooth residues
    long long rel_xs[MAX_REL];
    int rel_signs[MAX_REL];
    int *rel_fids[MAX_REL]; // factor base indices
    int rel_nf[MAX_REL];
    unsigned long long rel_lp[MAX_REL]; // large prime
    
    double log_thresh = 0.5 * mpz_sizeinbase(N, 2) * 0.6931471805599453;
    
    int half_sieve = sieve_len / 2;
    
    for (int blk = 0; nrels < target && blk < 50; blk++) {
        // Sieve interval: x = s + (blk * sieve_len - half_sieve) to s + ((blk+1)*sieve_len - half_sieve)
        // i.e., i goes from (blk * sieve_len - half_sieve) to ((blk+1)*sieve_len - half_sieve)
        // Offset for this block
        long long blk_offset = (long long)blk * sieve_len - half_sieve;
        
        // Initialize sieve
        for (int i = 0; i < sieve_len; i++) sv[i] = 0.0;
        
        // Add contributions from each factor base prime
        for (int j = 0; j < fb_sz; j++) {
            int p = fb[j];
            double lp = log_fb[j];
            
            // Starting points for this block
            // root positions in the block: (r1 - blk_offset) mod p
            long long r1 = ((long long)fb_r1[j] - blk_offset) % p;
            long long r2 = ((long long)fb_r2[j] - blk_offset) % p;
            if (r1 < 0) r1 += p;
            if (r2 < 0) r2 += p;
            int st1 = (int)r1;
            int st2 = (int)r2;
            
            // Sieve
            for (int i = st1; i < sieve_len; i += p) sv[i] += lp;
            if (st1 != st2)
                for (int i = st2; i < sieve_len; i += p) sv[i] += lp;
        }
        
        // Scan for smooth candidates
        double extra = 3.0 * log((double)(fb_sz > 0 ? fb[fb_sz-1] : 100));
        for (int i = 0; i < sieve_len && nrels < target; i++) {
            if (sv[i] < log_thresh - extra) continue;
            
            long long xx = blk_offset + i;
            
            // Compute Q(x) = x² - N directly
            mpz_set_si(Qx, xx);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = 0;
            if (mpz_sgn(Qx) < 0) { mpz_neg(Qx, Qx); sign = 1; }
            
            // Trial divide by factor base primes
            mpz_set(tmp, Qx);
            int fids[MAX_FB * 2], nf = 0;
            for (int j = 0; j < fb_sz && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, (unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp, tmp, (unsigned long)fb[j]);
                    fids[nf++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                // Fully smooth!
                rel_xs[nrels] = xx;
                rel_signs[nrels] = sign;
                rel_nf[nrels] = nf;
                rel_fids[nrels] = malloc(nf * sizeof(int));
                memcpy(rel_fids[nrels], fids, nf * sizeof(int));
                rel_lp[nrels] = 0;
                nrels++;
            } else if (mpz_cmp_ui(tmp, (unsigned long)fb[fb_sz-1] * 30) < 0 && mpz_fits_ulong_p(tmp)) {
                // 1LP: remainder is a single large prime
                unsigned long long r = mpz_get_ui(tmp);
                // Quick primality check
                if (r > 1) {
                    int rp = 1; for (unsigned long d = 2; d*d <= r; d++) if (r%d==0){rp=0;break;}
                    if (rp) {
                        // Store as 1LP relation (same as full relation but record large prime)
                        // For now, skip 1LP to keep it simple
                        // TODO: implement 1LP matching
                    }
                }
            }
        }
    }
    free(sv);
    
    if (nrels < fb_sz + 5) goto done_fb;
    
    // ==================== Gaussian Elimination over GF(2) ====================
    int ncols = fb_sz + 1; // sign + fb_sz primes
    int nrows = nrels;
    int cwords = (ncols + 63) / 64;
    int iwords = (nrows + 63) / 64;
    int twords = cwords + iwords;
    
    typedef unsigned long long u64;
    u64 *M = calloc(nrows * twords, sizeof(u64));
    int *piv = malloc(ncols * sizeof(int));
    for (int j = 0; j < ncols; j++) piv[j] = -1;
    
    for (int i = 0; i < nrows; i++) {
        if (rel_signs[i]) M[i*twords] |= 1;
        for (int f = 0; f < rel_nf[i]; f++) {
            int c = rel_fids[i][f] + 1;
            M[i*twords + c/64] ^= (1ULL << (c%64));
        }
        M[i*twords + cwords + i/64] |= (1ULL << (i%64));
    }
    
    for (int col = 0; col < ncols; col++) {
        for (int row = 0; row < nrows; row++) {
            if (!(M[row*twords + col/64] & (1ULL << (col%64)))) continue;
            int used = 0; for (int c = 0; c < col; c++) if (piv[c]==row){used=1;break;}
            if (used) continue;
            piv[col] = row;
            for (int r = 0; r < nrows; r++) {
                if (r == row) continue;
                if (M[r*twords + col/64] & (1ULL << (col%64)))
                    for (int w = 0; w < twords; w++) M[r*twords+w] ^= M[row*twords+w];
            }
            break;
        }
    }
    
    // ==================== Extract Factor from Null Space ====================
    for (int i = 0; i < nrows; i++) {
        int zero = 1;
        for (int w = 0; w < cwords; w++) if (M[i*twords+w]){zero=0;break;}
        if (!zero) continue;
        
        mpz_t X, Y;
        mpz_init_set_ui(X, 1);
        mpz_init_set_ui(Y, 1);
        
        // X = product(x_i) mod N
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                mpz_set_si(tmp, rel_xs[j]);
                mpz_mul(X, X, tmp);
                mpz_mod(X, X, N);
            }
        }
        
        // Y = sqrt(product of Q(x_i)) mod N
        // Count exponent of each fb prime
        int total_exp[MAX_FB];
        for (int j = 0; j < fb_sz; j++) total_exp[j] = 0;
        
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                for (int f = 0; f < rel_nf[j]; f++)
                    total_exp[rel_fids[j][f]]++;
            }
        }
        
        // Y = product of p^(e_p/2) mod N for each prime where e_p is even
        // Verify all exponents are even (otherwise this isn't a valid null vector)
        for (int j = 0; j < fb_sz; j++) {
            if (total_exp[j] % 2 != 0) {
                // This shouldn't happen for a proper null vector, skip
                mpz_set_ui(Y, 0);
                break;
            }
            if (total_exp[j] > 0) {
                mpz_t base; mpz_init_set_ui(base, (unsigned long)fb[j]);
                mpz_pow_ui(tmp, base, (unsigned long)(total_exp[j] / 2));
                mpz_mul(Y, Y, tmp);
                mpz_mod(Y, Y, N);
                mpz_clear(base);
            }
        }
        
        if (mpz_cmp_ui(Y, 0) == 0) { mpz_clear(X); mpz_clear(Y); continue; }
        
        // Try gcd(X - Y, N) and gcd(X + Y, N)
        mpz_sub(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1) > 0 && mpz_cmp(g,N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            retval = 1; break;
        }
        mpz_add(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1) > 0 && mpz_cmp(g,N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            retval = 1; break;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(M); free(piv);
    for (int r = 0; r < nrels; r++) free(rel_fids[r]);
    
    free(s_mod_p);
done_fb:
    free(fb_r1); free(fb_r2);
done:
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return retval;
}
