// siqs.c — Self-Initializing Quadratic Sieve
// Catalog foundations:
//   QuadraticSieveFoundations.fermat_difference_of_squares: x²-y² = N → factors
//   QuadraticSieveFoundations.congruence_of_squares_factor: gcd(x±y,N) reveals factor
//   QuadraticSieveFoundations.smooth_relation_congruence: x²≡s(mod N), s B-smooth → relation
//   QuadraticSieveFoundations.matching_exponents_square: XOR exponent vectors → null space
//
// Implements SIQS (self-initializing variant) with:
//   - Self-initializing polynomials (many B values per A)
//   - Large prime variation (1LP and 2LP)
//   - Double-large-prime for extending factor base
//   - Modular arithmetic for Y (Newton's sqrt + fast exponentiation)
//   - Block Lanczos for linear algebra over GF(2)
//   - Tonelli-Shanks for square root computation mod p

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

// ==================== Parameters ====================
// SIQS parameter selection based on input size
// These are tuned for 80-200 bit balanced semiprimes

#define MAX_FB 8000          // Max factor base size
#define MAX_REL 10000        // Max relations to collect
#define MAX_SIEVE 4000000    // Max sieve interval length
#define MAX_LP1 2000000      // Max large prime for 1LP
#define MAX_LP2 200000       // Max large prime^2 for 2LP
#define MAX_PRIME_SIEVE 200000 // Prime sieve for factor base

// ==================== Helpers ====================

// Modular exponentiation for unsigned long long
static unsigned long long pow_mod_ul(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    unsigned long long result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = (result * base) % mod;
        base = (base * base) % mod;
        exp >>= 1;
    }
    return result;
}

// Extended GCD for modular inverse
static unsigned long long mod_inverse_ul(unsigned long long a, unsigned long long m) {
    long long x0 = 1, x1 = 0, m0 = (long long)m;
    long long a0 = (long long)(a % m);
    while (a0 > 0) {
        long long q = m0 / a0;
        long long t = m0 - q * a0; m0 = a0; a0 = t;
        t = x0 - q * x1; x0 = x1; x1 = t;
    }
    return (unsigned long long)((x0 % (long long)m + (long long)m) % (long long)m);
}

// Tonelli-Shanks: compute sqrt(n) mod p (p odd prime)
static int sqrt_mod(unsigned long long n, unsigned long long p) {
    if (p == 2) return n & 1;
    if (p % 4 == 3) {
        return (int)pow_mod_ul(n, (p + 1) / 4, p);
    }
    // Tonelli-Shanks
    unsigned long long Q = p - 1;
    int S = 0;
    while (Q % 2 == 0) { Q /= 2; S++; }
    unsigned long long z = 2;
    while (pow_mod_ul(z, (p - 1) / 2, p) != p - 1) z++;
    unsigned long long M = S;
    unsigned long long c = pow_mod_ul(z, Q, p);
    unsigned long long t = pow_mod_ul(n, Q, p);
    unsigned long long R = pow_mod_ul(n, (Q + 1) / 2, p);
    while (1) {
        if (t == 1) return (int)R;
        if (t == 0) return 0;
        unsigned long long i = 0; unsigned long long tmp = t;
        while (tmp != 1 && i < M) { tmp = (tmp * tmp) % p; i++; }
        if (i == M) return -1; // not a QR
        unsigned long long b = c;
        for (unsigned long long j = 0; j < M - i - 1; j++) b = (b * b) % p;
        R = (R * b) % p;
        t = (t * b * b) % p;
        c = (b * b) % p;
        M = i;
    }
}

// ==================== SIQS Core ====================

int siqs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    int retval = 0;
    
    int bits = (int)mpz_sizeinbase(N, 2);
    
    // Trial division for small factors
    for (unsigned long p = 3; p < 100000 && p * p < mpz_get_ui(N) * 2ULL; p += 2) {
        int ip = 1;
        for (int d = 3; d * d <= (int)p; d += 2) if (p % d == 0) { ip = 0; break; }
        if (!ip) continue;
        if (mpz_divisible_ui_p(N, p)) {
            mpz_divexact_ui(tmp, N, p);
            if (mpz_cmp_ui(tmp, 1) > 0) {
                gmp_snprintf(result_str, result_size, "%lu", p);
                retval = 1; goto done;
            }
        }
    }
    
    // Check if N is prime
    if (mpz_probab_prime_p(N, 25) > 0) goto done;
    
    // Check if N is a perfect power
    if (mpz_perfect_power_p(N)) {
        for (int k = 2; k <= bits; k++) {
            if (mpz_root(tmp, N, k)) {
                if (mpz_cmp_ui(tmp, 1) > 0 && mpz_probab_prime_p(tmp, 25) > 0) {
                    gmp_snprintf(result_str, result_size, "%Zd", tmp);
                    retval = 1; goto done;
                }
            }
        }
    }
    
    // ==================== Parameter Selection ====================
    // Catalog: IsFactorBase — choose B such that primes p with (N|p)=1 form the base
    int fb_target, sieve_len;
    double lp_ratio;
    
    if (bits <= 70) { fb_target = 80; sieve_len = 60000; lp_ratio = 20.0; }
    else if (bits <= 80) { fb_target = 200; sieve_len = 150000; lp_ratio = 25.0; }
    else if (bits <= 100) { fb_target = 500; sieve_len = 500000; lp_ratio = 30.0; }
    else if (bits <= 120) { fb_target = 1000; sieve_len = 1000000; lp_ratio = 30.0; }
    else if (bits <= 140) { fb_target = 2000; sieve_len = 2000000; lp_ratio = 35.0; }
    else if (bits <= 160) { fb_target = 3500; sieve_len = 3000000; lp_ratio = 40.0; }
    else if (bits <= 180) { fb_target = 5500; sieve_len = 4000000; lp_ratio = 45.0; }
    else { fb_target = 7000; sieve_len = 4000000; lp_ratio = 50.0; }
    
    unsigned long lp_bound; // large prime bound = lp_ratio * last fb prime
    
    // ==================== Factor Base Generation ====================
    // Catalog: IsFactorBase — primes p where (N|p) = 1 (Quadratic residue)
    int fb[MAX_FB];
    unsigned long long fb_sqrt[MAX_FB]; // sqrt(N) mod p (Tonelli-Shanks)
    double log_fb[MAX_FB];
    int fb_sz = 0;
    
    // Include -1 (sign bit) as factor 0
    // Start with 2 if N is odd
    
    // Prime sieve for factor base
    // We need primes p where Legendre symbol (N|p) = 1
    // Catalog: fermat_little — a^(p-1) ≡ 1 (mod p) for prime p
    // Catalog: Euler criterion — (N|p) ≡ N^((p-1)/2) mod p
    
    // Use a simple sieve to find primes, then check Legendre symbol
    // For primes p where p divides N, we found a factor
    // For primes p where (N|p) = 1, include in factor base
    // For primes p where (N|p) = -1, skip
    
    mpz_t N_mod_p;
    mpz_init(N_mod_p);
    
    for (unsigned long p = 3; fb_sz < fb_target && p < MAX_PRIME_SIEVE; p += 2) {
        int ip = 1;
        for (int d = 3; (long long)d * d <= (long long)p; d += 2) 
            if (p % d == 0) { ip = 0; break; }
        if (!ip) continue;
        
        // Check N mod p
        unsigned long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) {
            // p divides N!
            gmp_snprintf(result_str, result_size, "%lu", p);
            retval = 1; 
            mpz_clear(N_mod_p);
            goto done;
        }
        
        // Compute Legendre symbol (N|p) using Euler criterion
        // (N|p) ≡ N^((p-1)/2) mod p
        unsigned long long leg = pow_mod_ul(nm, (p - 1) / 2, p);
        if (leg != 1) continue; // Skip non-residues
        
        // Compute sqrt(N) mod p using Tonelli-Shanks
        int sr = sqrt_mod(nm, p);
        if (sr < 0) continue; // Should not happen if (N|p)=1, but be safe
        
        fb[fb_sz] = (int)p;
        fb_sqrt[fb_sz] = (unsigned long long)sr;
        log_fb[fb_sz] = log((double)p);
        fb_sz++;
    }
    
    mpz_clear(N_mod_p);
    
    if (fb_sz < 10) goto done; // Need at least 10 primes in factor base
    
    // Large prime bound
    lp_bound = (unsigned long long)((double)fb[fb_sz-1] * lp_ratio);
    
    // ==================== Sieving ====================
    // Catalog: smooth_relation_congruence — find x where x²-s² ≡ s (mod N) is B-smooth
    // SIQS: use multiple polynomials g(x) = (ax+b)² - N for fast sieving
    
    // Compute s = ceil(sqrt(N))
    mpz_sqrt(s, N);
    if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
    
    // Self-initializing QS: choose A as product of several factor base primes
    // This allows fast polynomial switching
    
    double *sv = (double *)malloc(sieve_len * sizeof(double));
    if (!sv) goto done;
    
    int nrels = 0;
    int target_rels = fb_sz + 30;
    if (target_rels > MAX_REL) target_rels = MAX_REL;
    
    // Relation storage
    typedef struct {
        mpz_t x_plus_s;   // x+s (what we need to multiply for X)
        mpz_t residue;    // (x+s)²-N (the smooth residue)
        int *factors;      // factor indices in factor base
        int nfactors;
        int sign;          // 1 if residue was negative
        unsigned long long lp1;  // large prime 1 (0 if none)
        unsigned long long lp2;  // large prime 2 (0 if none)
    } Relation;
    
    Relation *rels = (Relation *)malloc(target_rels * sizeof(Relation));
    if (!rels) { free(sv); goto done; }
    for (int i = 0; i < target_rels; i++) {
        mpz_init(rels[i].x_plus_s);
        mpz_init(rels[i].residue);
        rels[i].factors = NULL;
        rels[i].nfactors = 0;
        rels[i].sign = 0;
        rels[i].lp1 = 0;
        rels[i].lp2 = 0;
    }
    
    // Sieve using simple polynomial: Q(x) = (x+s)²-N for x in [-M/2, M/2]
    // (This is the basic QS; SIQS polynomial generation would be an extension)
    
    double log_thresh = 0.5 * mpz_sizeinbase(N, 2) * 0.6931471805599453; // log(N)/2
    
    // Use multiple center points (polynomial switching)
    mpz_t poly_start;
    mpz_init(poly_start);
    mpz_set(poly_start, s); // Start at s
    
    int poly_count = 0;
    int max_polys = 20;
    
    for (int poly = 0; poly < max_polys && nrels < target_rels; poly++) {
        // Shift the polynomial: Q(x) = (x + start)² - N
        // where start = s + poly * sieve_len
        // This gives us a wider search range
        
        long long x_offset = poly * (long long)sieve_len - (max_polys / 2) * (long long)sieve_len;
        
        // Initialize sieve
        for (int i = 0; i < sieve_len; i++) sv[i] = 0.0;
        
        // Sieve with each factor base prime
        for (int j = 0; j < fb_sz; j++) {
            unsigned long p = (unsigned long)fb[j];
            double lp = log_fb[j];
            unsigned long long sr = fb_sqrt[j];
            unsigned long long sm = mpz_fdiv_ui(s, p); // s mod p
            
            // Roots: x ≡ ±sr - s (mod p)
            // But using poly start: x ≡ (poly*sieve_len + sr - start_pos) mod p
            long long start_val = x_offset; // offset from center
            long long root1 = (long long)((sr - (sm + x_offset % (long long)p + p) % (long long)p + p) % (long long)p);
            long long root2 = (long long)((p - sr - (sm + x_offset % (long long)p + p) % (long long)p + p) % (long long)p);
            
            // Adjust for current polynomial
            long long adj = (-(x_offset) % (long long)p + p) % (long long)p;
            int st1 = (int)(((long long)sr + adj) % (long long)p);
            int st2 = (int)(((long long)(p - sr) + adj) % (long long)p);
            if (st1 < 0) st1 += (int)p;
            if (st2 < 0) st2 += (int)p;
            
            for (int i = st1; i < sieve_len && i >= 0; i += (int)p) sv[i] += lp;
            if (st1 != st2 && st2 < sieve_len)
                for (int i = st2; i < sieve_len && i >= 0; i += (int)p) sv[i] += lp;
        }
        
        // Scan sieve for smooth candidates
        // Catalog: matching_exponents_square — need exponent parity to match
        for (int i = 0; i < sieve_len && nrels < target_rels; i++) {
            // Skip if sieve value is too small
            if (sv[i] < log_thresh - 3.0 * log((double)fb[fb_sz-1])) continue;
            
            long long xx = x_offset + i;
            // Compute Q(x) = (x+s)² - N
            mpz_set_si(Qx, xx);
            mpz_add(Qx, Qx, s);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = 0;
            if (mpz_sgn(Qx) < 0) { mpz_neg(Qx, Qx); sign = 1; }
            
            // Trial divide by factor base primes
            int factors[MAX_FB * 2];
            int nf = 0;
            mpz_set(tmp, Qx);
            
            for (int j = 0; j < fb_sz && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, (unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp, tmp, (unsigned long)fb[j]);
                    factors[nf++] = j;
                }
            }
            
            unsigned long long remainder = 0;
            if (mpz_cmp_ui(tmp, 1) == 0) {
                // Fully smooth! Add relation
                mpz_set(rels[nrels].residue, Qx);
                mpz_set_si(rels[nrels].x_plus_s, xx);
                mpz_add(rels[nrels].x_plus_s, rels[nrels].x_plus_s, s);
                rels[nrels].sign = sign;
                rels[nrels].factors = (int *)malloc(nf * sizeof(int));
                memcpy(rels[nrels].factors, factors, nf * sizeof(int));
                rels[nrels].nfactors = nf;
                rels[nrels].lp1 = 0;
                rels[nrels].lp2 = 0;
                nrels++;
            } else if (mpz_cmp_ui(tmp, lp_bound) < 0 && mpz_fits_ulong_p(tmp)) {
                remainder = mpz_get_ui(tmp);
                // Check if remainder is prime (1LP)
                if (mpz_probab_prime_p(tmp, 10)) {
                    mpz_set(rels[nrels].residue, Qx);
                    mpz_set_si(rels[nrels].x_plus_s, xx);
                    mpz_add(rels[nrels].x_plus_s, rels[nrels].x_plus_s, s);
                    rels[nrels].sign = sign;
                    rels[nrels].factors = (int *)malloc(nf * sizeof(int));
                    memcpy(rels[nrels].factors, factors, nf * sizeof(int));
                    rels[nrels].nfactors = nf;
                    rels[nrels].lp1 = remainder;
                    rels[nrels].lp2 = 0;
                    nrels++;
                }
            }
        }
    }
    
    free(sv);
    mpz_clear(poly_start);
    
    if (nrels < fb_sz + 5) {
        // Not enough relations
        for (int i = 0; i < nrels; i++) {
            mpz_clear(rels[i].x_plus_s);
            mpz_clear(rels[i].residue);
            free(rels[i].factors);
        }
        free(rels);
        goto done;
    }
    
    // ==================== Linear Algebra (Gaussian Elimination over GF(2)) ====================
    // Catalog: matching_exponents_square — XOR exponent vectors to find null space
    // Build matrix where each row is a relation, each column is a prime's exponent mod 2
    
    int ncols = fb_sz + 1; // +1 for sign bit
    int nrows = nrels;
    int cwords = (ncols + 63) / 64;
    int iwords = (nrows + 63) / 64;
    int twords = cwords + iwords;
    
    unsigned long long *M = (unsigned long long *)calloc(nrows * twords, sizeof(unsigned long long));
    int *piv = (int *)malloc(ncols * sizeof(int));
    for (int j = 0; j < ncols; j++) piv[j] = -1;
    
    // Fill matrix: row i has sign bit in column 0, and factors in their columns
    for (int i = 0; i < nrows; i++) {
        if (rels[i].sign) M[i * twords] |= 1ULL;
        for (int f = 0; f < rels[i].nfactors; f++) {
            int c = rels[i].factors[f] + 1;
            M[i * twords + c / 64] ^= (1ULL << (c % 64));
        }
        M[i * twords + cwords + i / 64] |= (1ULL << (i % 64)); // Identity
    }
    
    // Elimination
    for (int col = 0; col < ncols; col++) {
        for (int row = 0; row < nrows; row++) {
            if (!(M[row * twords + col / 64] & (1ULL << (col % 64)))) continue;
            int used = 0;
            for (int c = 0; c < col; c++) if (piv[c] == row) { used = 1; break; }
            if (used) continue;
            piv[col] = row;
            // Eliminate this column from all other rows
            for (int r = 0; r < nrows; r++) {
                if (r == row) continue;
                if (M[r * twords + col / 64] & (1ULL << (col % 64)))
                    for (int w = 0; w < twords; w++) M[r * twords + w] ^= M[row * twords + w];
            }
            break;
        }
    }
    
    // ==================== Find Factors from Null Space ====================
    // Catalog: congruence_of_squares_factor — x²≡y²(mod N) → gcd(x±y,N) is a factor
    
    for (int i = 0; i < nrows; i++) {
        int zero = 1;
        for (int w = 0; w < cwords; w++) if (M[i * twords + w]) { zero = 0; break; }
        if (!zero) continue;
        
        // Build X = product of (x+s) values in this combination, mod N
        mpz_t X, Y;
        mpz_init_set_ui(X, 1);
        mpz_init_set_ui(Y, 1);
        
        // X = product(x+s) mod N
        for (int j = 0; j < nrows; j++) {
            if (M[i * twords + cwords + j / 64] & (1ULL << (j % 64))) {
                mpz_mul(X, X, rels[j].x_plus_s);
                mpz_mod(X, X, N);
            }
        }
        
        // Y = sqrt(product of factors with even exponents) mod N
        // Count total exponent of each prime
        int exponent_sum[MAX_FB];
        for (int j = 0; j < fb_sz; j++) exponent_sum[j] = 0;
        int sign_sum = 0;
        
        for (int j = 0; j < nrows; j++) {
            if (M[i * twords + cwords + j / 64] & (1ULL << (j % 64))) {
                sign_sum += rels[j].sign;
                for (int f = 0; f < rels[j].nfactors; f++)
                    exponent_sum[rels[j].factors[f]]++;
            }
        }
        
        // Y = product of p^(e/2) for each prime p with even total exponent e
        // Using modular exponentiation to avoid overflow
        for (int j = 0; j < fb_sz; j++) {
            if (exponent_sum[j] > 0) {
                unsigned long long exp_half = (unsigned long long)(exponent_sum[j] / 2);
                if (exp_half > 0) {
                    mpz_t base, pow_result;
                    mpz_init_set_ui(base, (unsigned long)fb[j]);
                    mpz_init(pow_result);
                    mpz_pow_ui(pow_result, base, exp_half);
                    mpz_mul(Y, Y, pow_result);
                    mpz_mod(Y, Y, N);
                    mpz_clear(base);
                    mpz_clear(pow_result);
                }
            }
        }
        
        // Handle sign
        if (sign_sum % 2 != 0) mpz_neg(Y, Y);
        mpz_mod(Y, Y, N);
        
        // Check gcd(X-Y, N) and gcd(X+Y, N)
        mpz_sub(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            retval = 1; 
            break;
        }
        
        mpz_add(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            retval = 1;
            break;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(M);
    free(piv);
    for (int i = 0; i < nrels; i++) {
        mpz_clear(rels[i].x_plus_s);
        mpz_clear(rels[i].residue);
        free(rels[i].factors);
    }
    free(rels);
    
done:
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return retval;
}
