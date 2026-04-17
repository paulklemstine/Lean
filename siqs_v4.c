// siqs_v4.c — Clean SIQS derived from Catalog theorems
// QuadraticSieveFoundations.fermat_difference_of_squares: x²-y² = N → factors
// QuadraticSieveFoundations.congruence_of_squares_factor: gcd(x±y,N) gives factor
// QuadraticSieveFoundations.smooth_relation_congruence: x²≡s(mod N), s B-smooth → relation
// QuadraticSieveFoundations.IsFactorBase: select primes p with (N|p)=1
// QuadraticSieveFoundations.matching_exponents_square: XOR parity → null space
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 30000
#define MAX_REL 35000
#define MAX_SIEVE 6000000

static unsigned long long pow_mod_ul(unsigned long long b, unsigned long long e, unsigned long long m) {
    unsigned long long r = 1; b %= m;
    while (e) { if (e & 1) r = r * b % m; b = b * b % m; e >>= 1; }
    return r;
}

static unsigned long long sqrt_mod_ul(unsigned long long n, unsigned long long p) {
    if (p == 2) return n & 1;
    if (p % 4 == 3) return pow_mod_ul(n, (p+1)/4, p);
    unsigned long long Q = p-1; int S = 0;
    while (Q%2==0) { Q/=2; S++; }
    unsigned long long z = 2;
    while (pow_mod_ul(z,(p-1)/2,p) != p-1) z++;
    unsigned long long M=S, c=pow_mod_ul(z,Q,p), t=pow_mod_ul(n,Q,p), R=pow_mod_ul(n,(Q+1)/2,p);
    for(;;) {
        if (t==1) return R;
        if (t==0) return 0;
        unsigned long long i=0,tmp=t;
        while (tmp!=1 && i<M) { tmp=tmp*tmp%p; i++; }
        unsigned long long b=c;
        for (unsigned long long j=0; j<M-i-1; j++) b=b*b%p;
        R=R*b%p; t=t*b%p*b%p; c=b*b%p; M=i;
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
        int ip=1; for(int d=3;d*d<=(int)p;d+=2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        if (mpz_divisible_ui_p(N, p)) {
            gmp_snprintf(result_str, result_size, "%lu", p); retval=1; goto done;
        }
    }
    if (mpz_probab_prime_p(N, 25) > 0) goto done;
    
    // Parameters based on input size
    int fb_target, sieve_len;
    unsigned long long prime_limit;
    double lp_mult;
    // Catalog: IsFactorBase — choose B for u=log(Q)/log(B)≈2 (Dickman ρ(2)≈0.3)
    // Q(x) ≈ 2*√N*|x-√N|, so for |x-√N| ≈ sieve_len/2:
    // Q ≈ √N * sieve_len. For smoothness: B ≈ √Q ≈ N^{1/4} * sieve_len^{1/2}
    if (bits <= 64) { fb_target=500; sieve_len=100000; prime_limit=8000; lp_mult=2.5; }
    else if (bits <= 80) { fb_target=800; sieve_len=200000; prime_limit=12000; lp_mult=2.5; }
    else if (bits <= 100) { fb_target=1500; sieve_len=400000; prime_limit=30000; lp_mult=3.0; }
    else if (bits <= 120) { fb_target=2500; sieve_len=600000; prime_limit=50000; lp_mult=3.0; }
    else if (bits <= 140) { fb_target=4000; sieve_len=1000000; prime_limit=80000; lp_mult=3.0; }
    else if (bits <= 160) { fb_target=6000; sieve_len=1500000; prime_limit=120000; lp_mult=3.0; }
    else if (bits <= 180) { fb_target=8000; sieve_len=2000000; prime_limit=200000; lp_mult=3.0; }
    else { fb_target=10000; sieve_len=3000000; prime_limit=300000; lp_mult=3.5; }
    
    // Factor base (Catalog: IsFactorBase)
    int fb[MAX_FB]; double log_fb[MAX_FB]; int fb_sz = 0;
    unsigned long long *fb_r1 = malloc(MAX_FB * sizeof(unsigned long long));
    unsigned long long *fb_r2 = malloc(MAX_FB * sizeof(unsigned long long));
    
    mpz_sqrt(s, N);
    if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
    
    for (unsigned long p = 3; fb_sz < fb_target && p < prime_limit; p += 2) {
        int ip=1; for(unsigned long d=3;d*d<=p;d+=2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        unsigned long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) { gmp_snprintf(result_str, result_size, "%lu", p); retval=1; goto done_fb; }
        if (pow_mod_ul(nm,(p-1)/2,p) != 1) continue;
        unsigned long long sr = sqrt_mod_ul(nm, p);
        unsigned long long sm = mpz_fdiv_ui(s, p);
        fb[fb_sz] = (int)p;
        log_fb[fb_sz] = log((double)p);
        // Root 1: i ≡ sr - sm (mod p), Root 2: i ≡ -sr - sm (mod p)
        fb_r1[fb_sz] = (sr - sm + p) % p;
        fb_r2[fb_sz] = (p - sr - sm + 2*p) % p;
        if (fb_r2[fb_sz] >= p) fb_r2[fb_sz] -= p;
        fb_sz++;
    }
    
    if (fb_sz < 10) goto done_fb;
    
    // Sieve threshold
    double threshold = 0.5 * mpz_sizeinbase(N, 2) * 0.6931471805599453 - lp_mult * log_fb[fb_sz-1];
    
    int nrels = 0;
    int target = fb_sz + 20;
    if (target > MAX_REL) target = MAX_REL;
    
    long long rel_x[MAX_REL];
    int rel_sign[MAX_REL];
    int *rel_fids[MAX_REL];
    int rel_nf[MAX_REL];
    unsigned long long rel_lp1[MAX_REL]; // large prime 1 (0 if none)
    
    double *sv = malloc(sieve_len * sizeof(double));
    if (!sv) goto done_fb;
    
    for (int blk = 0; nrels < target && blk < 500; blk++) {
        long long blk_offset = (long long)blk * (long long)sieve_len;
        
        for (int i = 0; i < sieve_len; i++) sv[i] = 0.0;
        
        // Sieve BOTH roots (Catalog: smooth_relation_congruence — both ±sqrt(N) are solutions)
        for (int j = 0; j < fb_sz; j++) {
            int p = fb[j];
            double lp = log_fb[j];
            long long offset_mod = blk_offset % p;
            if (offset_mod < 0) offset_mod += p;
            long long r1 = ((long long)fb_r1[j] - offset_mod + p) % p;
            long long r2 = ((long long)fb_r2[j] - offset_mod + p) % p;
            int st1 = (int)r1;
            int st2 = (int)r2;
            for (int i = st1; i < sieve_len && i >= 0; i += p) sv[i] += lp;
            if (st1 != st2)
                for (int i = st2; i < sieve_len && i >= 0; i += p) sv[i] += lp;
        }
        
        // Scan
        for (int i = 0; i < sieve_len && nrels < target; i++) {
            if (sv[i] < threshold) continue;
            
            long long xx = blk_offset + i;
            if (xx == 0) continue;
            
            mpz_set_si(Qx, xx);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = 0;
            if (mpz_sgn(Qx) < 0) { mpz_neg(Qx, Qx); sign = 1; }
            
            mpz_set(tmp, Qx);
            int fids[MAX_FB*2], nf = 0;
            for (int j = 0; j < fb_sz && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, (unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp, tmp, (unsigned long)fb[j]);
                    fids[nf++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                // Fully smooth!
                rel_x[nrels] = xx;
                rel_sign[nrels] = sign;
                rel_nf[nrels] = nf;
                rel_fids[nrels] = malloc(nf * sizeof(int));
                memcpy(rel_fids[nrels], fids, nf * sizeof(int));
                nrels++;
            }
            // 1LP: if remainder is prime and < B^2, store as partial relation
            // Catalog: smooth_relation_congruence extended — one extra prime is OK
            else if (mpz_fits_ulong_p(tmp)) {
                unsigned long long rem = mpz_get_ui(tmp);
                unsigned long long lp_bound = (unsigned long long)fb[fb_sz-1] * (unsigned long long)fb[fb_sz-1] * 10;
                if (rem > 1 && rem < lp_bound) {
                    // Quick primality check
                    int is_prime = 1;
                    if (rem > 2) {
                        for (unsigned long long d = 2; d*d <= rem && d < 1000000; d++) {
                            if (rem % d == 0) { is_prime = 0; break; }
                        }
                    }
                    if (is_prime) {
                        rel_x[nrels] = xx;
                        rel_sign[nrels] = sign;
                        rel_nf[nrels] = nf;
                        rel_fids[nrels] = malloc(nf * sizeof(int));
                        memcpy(rel_fids[nrels], fids, nf * sizeof(int));
                        rel_lp1[nrels] = rem;  // Store large prime
                        nrels++;
                    }
                }
            }
        }
    }
    free(sv);
    
    if (nrels < fb_sz + 5) goto done_rels;
    
    // Gaussian elimination over GF(2)
    typedef unsigned long long u64;
    int ncols = fb_sz + 1;
    int nrows = nrels;
    int cwords = (ncols + 63) / 64;
    int iwords = (nrows + 63) / 64;
    int twords = cwords + iwords;
    
    u64 *M = calloc(nrows * twords, sizeof(u64));
    int *piv = malloc(ncols * sizeof(int));
    for (int j = 0; j < ncols; j++) piv[j] = -1;
    
    for (int i = 0; i < nrows; i++) {
        if (rel_sign[i]) M[i*twords] |= 1ULL;
        for (int f = 0; f < rel_nf[i]; f++) {
            int c = rel_fids[i][f] + 1;
            M[i*twords + c/64] ^= (1ULL << (c%64));
        }
        M[i*twords + cwords + i/64] |= (1ULL << (i%64));
    }
    
    for (int col = 0; col < ncols; col++) {
        for (int row = 0; row < nrows; row++) {
            if (!(M[row*twords + col/64] & (1ULL << (col%64)))) continue;
            int used = 0; for (int c=0; c<col; c++) if(piv[c]==row){used=1;break;}
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
    
    // Extract factor from null space
    for (int i = 0; i < nrows; i++) {
        int zero = 1;
        for (int w = 0; w < cwords; w++) if (M[i*twords+w]){zero=0;break;}
        if (!zero) continue;
        
        mpz_t X, Y; mpz_init_set_ui(X, 1); mpz_init_set_ui(Y, 1);
        
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                mpz_set_si(tmp, rel_x[j]);
                mpz_mul(X, X, tmp);
                mpz_mod(X, X, N);
            }
        }
        
        int total_exp[MAX_FB];
        for (int j = 0; j < fb_sz; j++) total_exp[j] = 0;
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                for (int f = 0; f < rel_nf[j]; f++)
                    total_exp[rel_fids[j][f]]++;
            }
        }
        
        int all_even = 1;
        for (int j = 0; j < fb_sz; j++) if(total_exp[j]%2!=0){all_even=0;break;}
        if (!all_even) { mpz_clear(X); mpz_clear(Y); continue; }
        
        for (int j = 0; j < fb_sz; j++) {
            if (total_exp[j] > 0) {
                mpz_set_ui(tmp, (unsigned long)fb[j]);
                mpz_pow_ui(tmp, tmp, (unsigned long)(total_exp[j]/2));
                mpz_mul(Y, Y, tmp);
                mpz_mod(Y, Y, N);
            }
        }
        
        mpz_sub(tmp, X, Y); mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1) > 0 && mpz_cmp(g,N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y); retval=1; break;
        }
        mpz_add(tmp, X, Y); mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1) > 0 && mpz_cmp(g,N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y); retval=1; break;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(M); free(piv);
    
done_rels:
    for (int r = 0; r < nrels; r++) free(rel_fids[r]);
done_fb:
    free(fb_r1); free(fb_r2);
done:
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return retval;
}
