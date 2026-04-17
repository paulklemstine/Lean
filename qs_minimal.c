// qs_minimal.c — Minimal Multiple Polynomial Quadratic Sieve (MPQS)
// From Catalog: QuadraticSieveFoundations.lean
//   smooth_relation_congruence: Q(x) = (x+s)²-N → B-smooth → relation
//   matching_exponents_square: even exponent sum → square product  
//   congruence_of_squares_factor: x²≡y²(mod N), x≠±y → factor
//
// Targets: 80-140 bit semiprimes in <3 seconds

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 2000     // Maximum factor base size
#define MAX_REL 2500    // Maximum relations (fb_size + extra)
#define MAX_SIEVE 2000000  // Sieve interval length

typedef struct {
    int p;           // prime
    double logp;     // log(p)
    int r1, r2;      // roots of Q(x) mod p (two solutions)
    int pinv;        // p^(-1) mod N (for trial division)
} FBPrime;

typedef struct {
    mpz_t x;        // x value
    mpz_t Q;        // |Q(x)| (signed value factored)
    int *factors;   // factorization: list of indices into fb (with repeats)
    int nfactors;   // number of factors
    int sign;        // sign of Q(x): 1 if positive, 0 if negative
} Relation;

// Tonelli-Shanks: solve x²≡n (mod p) for prime p
int tonelli_shanks(int n, int p) {
    if (p == 2) return n % 2;
    // Check n is QR mod p
    long long pw = 1;
    for (int i = 0; i < (p-1)/2; i++) pw = (pw * n) % p;
    if (pw != 1) return -1;  // not a QR
    
    // Write p-1 = Q * 2^S
    int Q = p - 1, S = 0;
    while (Q % 2 == 0) Q /= 2, S++;
    
    if (S == 1) {
        // p ≡ 3 (mod 4): x = n^((p+1)/4) mod p
        long long exp = (p + 1) / 4;
        long long result = 1, base = n;
        while (exp > 0) {
            if (exp & 1) result = (result * base) % p;
            base = (base * base) % p;
            exp >>= 1;
        }
        return (int)result;
    }
    
    // Find z: non-residue mod p
    int z = 2;
    while (1) {
        long long pw2 = 1;
        for (int i = 0; i < (p-1)/2; i++) pw2 = (pw2 * z) % p;
        if (pw2 == p - 1) break;
        z++;
    }
    
    long long M = Q, c = 1, t = 1, R = 1;
    // c = z^Q mod p
    long long zbase = z;
    int exp = Q;
    while (exp > 0) {
        if (exp & 1) c = (c * zbase) % p;
        zbase = (zbase * zbase) % p;
        exp >>= 1;
    }
    // t = n^Q mod p
    long long nbase = n % p;
    exp = Q;
    t = 1;
    while (exp > 0) {
        if (exp & 1) t = (t * nbase) % p;
        nbase = (nbase * nbase) % p;
        exp >>= 1;
    }
    // R = n^((Q+1)/2) mod p
    exp = (Q + 1) / 2;
    R = 1; nbase = n % p;
    while (exp > 0) {
        if (exp & 1) R = (R * nbase) % p;
        nbase = (nbase * nbase) % p;
        exp >>= 1;
    }
    
    int i = S;
    while (t != 1) {
        // Find least i2 < i such that t^(2^i2) ≡ 1 mod p
        long long t2 = t;
        int i2;
        for (i2 = 1; i2 < i; i2++) {
            t2 = (t2 * t2) % p;
            if (t2 == 1) break;
        }
        // b = c^(2^(i-i2-1)) mod p
        long long b = c;
        for (int j = 0; j < i - i2 - 1; j++) b = (b * b) % p;
        R = (R * b) % p;
        t = (t * b * b) % p;
        c = (b * b) % p;
        i = i2;
    }
    return (int)R;
}

// Jacobi symbol (a/p) for p odd prime
int jacobi_mod(long long a, int p) {
    a = a % p; if (a < 0) a += p;
    if (a == 0) return 0;
    if (a == 1) return 1;
    // Euler criterion: a^((p-1)/2) mod p
    long long result = 1, base = a;
    int exp = (p - 1) / 2;
    while (exp > 0) {
        if (exp & 1) result = (result * base) % p;
        base = (base * base) % p;
        exp >>= 1;
    }
    return (result == p - 1) ? -1 : (int)result;
}

int qs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, sqrtN, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(sqrtN); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    
    // Quick checks
    if (mpz_even_p(N)) {
        gmp_snprintf(result_str, result_size, "2");
        mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
        return 1;
    }
    
    // Trial division up to 1000
    for (int p = 3; p < 1000; p += 2) {
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
    
    // Determine factor base size from bit length
    int bits = mpz_sizeinbase(N, 2);
    int fb_size, sieve_len, target_rels;
    
    if (bits <= 90) {
        fb_size = 200; sieve_len = 200000; target_rels = 220;
    } else if (bits <= 110) {
        fb_size = 400; sieve_len = 500000; target_rels = 440;
    } else if (bits <= 130) {
        fb_size = 800; sieve_len = 1000000; target_rels = 880;
    } else {
        fb_size = 1500; sieve_len = 2000000; target_rels = 1650;
    }
    
    if (fb_size > MAX_FB) fb_size = MAX_FB;
    if (sieve_len > MAX_SIEVE) sieve_len = MAX_SIEVE;
    if (target_rels > MAX_REL) target_rels = MAX_REL;
    
    // Build factor base
    FBPrime fb[MAX_FB];
    int actual_fb = 0;
    
    // -1 as "prime" 0 (for sign)
    fb[0].p = -1; fb[0].logp = 0.693; fb[0].r1 = 0; fb[0].r2 = 0;
    actual_fb = 1;
    
    // s = ceil(sqrt(N))
    mpz_sqrt(sqrtN, N);
    if (mpz_cmp(sqrtN, sqrtN) <= 0) { mpz_add_ui(sqrtN, sqrtN, 1); }  // ceil
    
    // Residue N mod p for small primes
    for (int p = 3; actual_fb < fb_size && p < 50000; p += 2) {
        int is_prime = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { is_prime=0; break; }
        if (!is_prime) continue;
        
        // Check if N is divisible by p
        if (mpz_divisible_ui_p(N, p)) {
            mpz_divexact_ui(tmp, N, p);
            if (mpz_cmp_ui(tmp, 1) > 0) {
                gmp_snprintf(result_str, result_size, "%d", p);
                mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
                return 1;
            }
            continue;  // p divides N completely, but we already checked for this
        }
        
        // Check if N is a QR mod p (Jacobi symbol = 1)
        long long n_mod_p = mpz_fdiv_ui(N, p);
        if (jacobi_mod(n_mod_p, p) != 1) continue;
        
        // Find roots of Q(x) = (x+s)^2 - N ≡ 0 (mod p)
        // x = -s + sqrt(N) mod p (Tonelli-Shanks)
        int r = tonelli_shanks((int)n_mod_p, p);
        if (r < 0) continue;  // shouldn't happen since we checked QR
        
        fb[actual_fb].p = p;
        fb[actual_fb].logp = log((double)p);
        // s mod p
        long long s_mod_p = mpz_fdiv_ui(sqrtN, p);
        // Root 1: r - s mod p
        fb[actual_fb].r1 = (int)(((long long)r - s_mod_p) % p);
        if (fb[actual_fb].r1 < 0) fb[actual_fb].r1 += p;
        // Root 2: p - r - s mod p  
        fb[actual_fb].r2 = (int)(((long long)p - (long long)r - s_mod_p) % p);
        if (fb[actual_fb].r2 < 0) fb[actual_fb].r2 += p;
        actual_fb++;
    }
    
    fb_size = actual_fb;
    target_rels = fb_size + 20;
    if (target_rels > MAX_REL) target_rels = MAX_REL;
    
    // Sieve
    double sieve[sieve_len];
    Relation rels[MAX_REL];
    int nrels = 0;
    
    // Initialize relations
    for (int i = 0; i < MAX_REL; i++) {
        mpz_init(rels[i].x);
        mpz_init(rels[i].Q);
        rels[i].factors = NULL;
        rels[i].nfactors = 0;
        rels[i].sign = 0;
    }
    
    for (int block = 0; nrels < target_rels && block < 20; block++) {
        int x_start = block * sieve_len;
        
        // Clear sieve
        for (int i = 0; i < sieve_len; i++) sieve[i] = 0.0;
        
        // Sieve: add log(p) at each root position
        for (int j = 1; j < fb_size; j++) {
            int p = fb[j].p;
            double lp = fb[j].logp;
            int r1 = (fb[j].r1 + x_start) % p;
            int r2 = (fb[j].r2 + x_start) % p;
            
            for (int x = r1; x < sieve_len; x += p) sieve[x] += lp;
            if (r1 != r2) {
                for (int x = r2; x < sieve_len; x += p) sieve[x] += lp;
            }
        }
        
        // Threshold: half the factor base log sum
        double threshold = 0.0;
        for (int j = 1; j < fb_size; j++) threshold += fb[j].logp;
        threshold *= 0.5;  // adjust: smooth if sieve value ≥ 80% of total log
        
        // Check candidates above threshold
        for (int x = 0; x < sieve_len && nrels < target_rels; x++) {
            if (sieve[x] < threshold) continue;
            
            // Compute Q(x + x_start) = (x + x_start + s)^2 - N
            long long xx = (long long)x + x_start;
            mpz_set_si(Qx, xx);
            mpz_add(Qx, Qx, sqrtN);  // Qx = x + s
            mpz_mul(Qx, Qx, Qx);     // Qx = (x+s)^2
            mpz_sub(Qx, Qx, N);       // Qx = (x+s)^2 - N
            
            if (mpz_sgn(Qx) == 0) continue;
            
            int sign = (mpz_sgn(Qx) < 0) ? 1 : 0;
            mpz_abs(Qx, Qx);
            
            // Trial divide by factor base
            int facs[MAX_FB * 2];
            int nfacs = 0;
            if (sign) facs[nfacs++] = 0;  // -1 factor
            
            mpz_set(tmp, Qx);
            for (int j = 1; j < fb_size && mpz_cmp_ui(tmp, 1) > 0; j++) {
                int p = fb[j].p;
                while (mpz_divisible_ui_p(tmp, p)) {
                    mpz_divexact_ui(tmp, tmp, p);
                    facs[nfacs++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                // Fully smooth! Record relation
                mpz_set_ui(rels[nrels].x, xx);
                mpz_add(rels[nrels].x, rels[nrels].x, sqrtN);  // x + s
                mpz_set(rels[nrels].Q, Qx);
                rels[nrels].factors = malloc(nfacs * sizeof(int));
                memcpy(rels[nrels].factors, facs, nfacs * sizeof(int));
                rels[nrels].nfactors = nfacs;
                rels[nrels].sign = sign;
                nrels++;
            }
        }
    }
    
    if (nrels < fb_size) {
        // Not enough relations
        goto cleanup;
    }
    
    // Gaussian elimination mod 2
    // Matrix: rows = relations, cols = fb_size
    // Entry M[i][j] = (number of times fb[j] appears in rel[i]) mod 2
    
    // Use packed uint64 for matrix
    int mcols = fb_size;
    int mrows = nrels;
    int words_per_row = (mcols + 63) / 64;
    unsigned long long *matrix = calloc(mrows * words_per_row, sizeof(unsigned long long));
    int *pivot_row = calloc(mcols, sizeof(int));  // pivot_row[col] = row that has pivot for this col
    for (int j = 0; j < mcols; j++) pivot_row[j] = -1;
    
    // Fill matrix (augmented: include identity for tracking)
    int aug_words = (mrows + 63) / 64;
    int total_words = words_per_row + aug_words;
    unsigned long long *aug = calloc(mrows * total_words, sizeof(unsigned long long));
    
    // Set relation bits
    for (int i = 0; i < nrels; i++) {
        for (int f = 0; f < rels[i].nfactors; f++) {
            int col = rels[i].factors[f];
            aug[i * total_words + col / 64] ^= (1ULL << (col % 64));
        }
        // Identity part
        aug[i * total_words + words_per_row + i / 64] |= (1ULL << (i % 64));
    }
    
    // Gaussian elimination
    for (int col = 0; col < mcols; col++) {
        // Find pivot
        int prow = -1;
        for (int row = 0; row < mrows; row++) {
            if (pivot_row[col] != -1) break;  // already have pivot
            if (aug[row * total_words + col / 64] & (1ULL << (col % 64))) {
                // Check this row isn't already used as pivot for earlier column
                int used = 0;
                for (int c2 = 0; c2 < col; c2++) {
                    if (pivot_row[c2] == row) { used = 1; break; }
                }
                if (!used) { prow = row; break; }
            }
        }
        if (prow < 0) continue;
        pivot_row[col] = prow;
        
        // Eliminate
        for (int row = 0; row < mrows; row++) {
            if (row == prow) continue;
            if (aug[row * total_words + col / 64] & (1ULL << (col % 64))) {
                // XOR this row with prow
                for (int w = 0; w < total_words; w++) {
                    aug[row * total_words + w] ^= aug[prow * total_words + w];
                }
            }
        }
    }
    
    // Find null space vectors (rows that are all zero in the left half)
    for (int i = 0; i < mrows; i++) {
        int all_zero = 1;
        for (int w = 0; w < words_per_row; w++) {
            if (aug[i * total_words + w] != 0) { all_zero = 0; break; }
        }
        if (!all_zero) continue;
        
        // Extract the relation combination from identity part
        mpz_t X, Y;
        mpz_init_set_ui(X, 1);
        mpz_init_set_ui(Y, 1);
        
        for (int j = 0; j < mrows; j++) {
            if (aug[i * total_words + words_per_row + j / 64] & (1ULL << (j % 64))) {
                mpz_mul(X, X, rels[j].x);
                mpz_mul(Y, Y, rels[j].Q);
            }
        }
        
        mpz_mod(X, X, N);
        mpz_sqrt(Y, Y);
        mpz_mod(Y, Y, N);
        
        // x² ≡ y² (mod N). Check gcd(x-y, N) and gcd(x+y, N)
        mpz_sub(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(aug); free(matrix); free(pivot_row);
            goto cleanup;
        }
        mpz_add(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(aug); free(matrix); free(pivot_row);
            goto cleanup;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(aug); free(matrix); free(pivot_row);
    
cleanup:
    for (int i = 0; i < MAX_REL; i++) {
        mpz_clear(rels[i].x); mpz_clear(rels[i].Q);
        free(rels[i].factors);
    }
    mpz_clear(N); mpz_clear(sqrtN); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    
    return 0;  // TODO: return 1 on success
}
