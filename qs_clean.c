// qs_clean.c — Clean Quadratic Sieve implementation
// From Catalog: QuadraticSieveFoundations.lean
//   congruence_of_squares_factor: x²≡y²(mod N), x≠±y → factor
//   smooth_relation_congruence: Q(x) = (x+⌈√N⌉)²-N → B-smooth → relation
//   matching_exponents_square: even exponents → square product

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 2000
#define MAX_REL 2500

typedef unsigned long long u64;

// Simple quadratic sieve
int qs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    
    // Quick trial division
    for (int p = 3; p < 10000; p += 2) {
        int ip = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { ip=0; break; }
        if (ip && mpz_divisible_ui_p(N, p)) {
            mpz_divexact_ui(tmp, N, p);
            if (mpz_cmp_ui(tmp,1) > 0) {
                gmp_snprintf(result_str, result_size, "%d", p);
                goto success;
            }
        }
    }
    
    int bits = mpz_sizeinbase(N, 2);
    int fb_target = (bits <= 80) ? 60 : (bits <= 100) ? 150 : (bits <= 120) ? 400 : 800;
    int sieve_len = (bits <= 80) ? 100000 : (bits <= 100) ? 300000 : 1000000;
    
    mpz_sqrt(s, N);
    if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
    
    // Factor base
    int fb[MAX_FB], r1[MAX_FB], r2[MAX_FB];
    double logfb[MAX_FB];
    int fb_sz = 0;
    
    for (int p = 3; fb_sz < fb_target && p < 100000; p += 2) {
        int ip = 1;
        for (int d = 3; d*d <= p; d += 2) if (p%d==0) { ip=0; break; }
        if (!ip) continue;
        long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) { gmp_snprintf(result_str, result_size, "%d", p); goto success; }
        
        // Euler criterion
        long long pw = 1, b = nm; int e = (p-1)/2;
        while (e) { if (e&1) pw=(pw*b)%p; b=(b*b)%p; e>>=1; }
        if (pw != 1) continue;
        
        // Tonelli-Shanks (p≡3 mod4 fast path + brute force for p≡1 mod4)
        int r;
        if (p%4 == 3) {
            long long rb=nm; r=1; e=(p+1)/4;
            while (e) { if (e&1) r=(int)(((long long)r*rb)%p); rb=(rb*rb)%p; e>>=1; }
        } else {
            r = -1;
            for (int t=1; t<p; t++) if (((long long)t*t)%p==nm) { r=t; break; }
            if (r<0) continue;
        }
        
        long long sm = mpz_fdiv_ui(s, p);
        fb[fb_sz] = p;
        logfb[fb_sz] = log((double)p);
        r1[fb_sz] = (int)((r - sm + p) % p);
        r2[fb_sz] = (int)((p - r - sm + 2*(long long)p) % p);
        if (r2[fb_sz] >= p) r2[fb_sz] -= p;
        fb_sz++;
    }
    
    // Sieve and collect relations
    double *sieve_arr = malloc(sieve_len * sizeof(double));
    int nrels = 0, target = fb_sz + 20;
    if (target > MAX_REL) target = MAX_REL;
    
    long long rel_xs[MAX_REL];
    int rel_nf[MAX_REL], rel_sg[MAX_REL];
    int *rel_fs[MAX_REL];
    
    for (int blk = 0; nrels < target && blk < 100; blk++) {
        long long x0 = (long long)blk * sieve_len;
        int x0_mod_fb[fb_sz];
        for (int j=0; j<fb_sz; j++) x0_mod_fb[j] = (int)(x0 % fb[j]);
        
        for (int i=0; i<sieve_len; i++) sieve_arr[i] = 0;
        
        for (int j=0; j<fb_sz; j++) {
            int p = fb[j]; double lp = logfb[j];
            int st1 = (r1[j] - x0_mod_fb[j] + p) % p;
            int st2 = (r2[j] - x0_mod_fb[j] + p) % p;
            for (int i=st1; i<sieve_len; i+=p) sieve_arr[i] += lp;
            if (st1 != st2)
                for (int i=st2; i<sieve_len; i+=p) sieve_arr[i] += lp;
        }
        
        double log_thresh = mpz_sizeinbase(N, 2) * 0.693 / 2.0;  // ≈ log(√N)
        
        for (int i=0; i<sieve_len && nrels<target; i++) {
            long long xx = i + x0;
            // log(Q(x)) ≈ log(2*√N*xx) for xx << √N
            double logQ = log_thresh + (xx > 0 ? log((double)xx) + 0.693 : 0);
            if (sieve_arr[i] < logQ - logfb[fb_sz-1]*3) continue;
            
            // Compute Q(x) = (x+s)²-N
            mpz_set_si(Qx, xx);
            mpz_add(Qx, Qx, s);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = mpz_sgn(Qx) < 0 ? 1 : 0;
            mpz_abs(Qx, Qx);
            mpz_set(tmp, Qx);
            
            int fs[MAX_FB*2]; int nf=0;
            for (int j=0; j<fb_sz && mpz_cmp_ui(tmp,1)>0; j++)
                while (mpz_divisible_ui_p(tmp, fb[j])) {
                    mpz_divexact_ui(tmp, tmp, fb[j]);
                    fs[nf++] = j;
                }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                rel_xs[nrels] = xx + mpz_get_si(s);  // x + s
                rel_nf[nrels] = nf;
                rel_sg[nrels] = sign;
                rel_fs[nrels] = malloc(nf * sizeof(int));
                memcpy(rel_fs[nrels], fs, nf * sizeof(int));
                nrels++;
            }
        }
    }
    
    free(sieve_arr);
    
    if (nrels < fb_sz + 5) goto fail;
    
    // Gaussian elimination over GF(2) with augmented matrix
    // Columns: 0=sign, 1..fb_sz = factor base primes
    // Augmented with identity to track combination
    int ncols = fb_sz + 1;
    int nrows = nrels;
    int cwords = (ncols+63)/64;
    int iwords = (nrows+63)/64;
    int twords = cwords + iwords;
    u64 *M = calloc(nrows * twords, sizeof(u64));
    
    for (int i=0; i<nrows; i++) {
        if (rel_sg[i]) M[i*twords+0] |= 1;
        for (int f=0; f<rel_nf[i]; f++)
            M[i*twords + (rel_fs[i][f]+1)/64] ^= (1ULL << ((rel_fs[i][f]+1)%64));
        M[i*twords + cwords + i/64] |= (1ULL << (i%64));
    }
    
    // GE
    int *_piv=malloc(ncols*sizeof(int)); int *piv=_piv; for (int j=0; j<ncols; j++) piv[j]=-1;
    
    for (int col=0; col<ncols; col++) {
        for (int row=0; row<nrows; row++) {
            if (!(M[row*twords + col/64] & (1ULL<<(col%64)))) continue;
            int used=0;
            for (int c=0; c<col; c++) if (piv[c]==row) {used=1; break;}
            if (used) continue;
            piv[col] = row;
            for (int r=0; r<nrows; r++) {
                if (r==row) continue;
                if (M[r*twords + col/64] & (1ULL<<(col%64)))
                    for (int w=0; w<twords; w++) M[r*twords+w] ^= M[row*twords+w];
            }
            break;
        }
    }
    
    // Find null space vectors
    for (int i=0; i<nrows; i++) {
        int zero=1;
        for (int w=0; w<cwords; w++) if (M[i*twords+w]) {zero=0; break;}
        if (!zero) continue;
        
        mpz_t X, Y;
        mpz_init_set_ui(X, 1);
        mpz_init_set_ui(Y, 1);
        
        for (int j=0; j<nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL<<(j%64))) {
                mpz_mul_si(X, X, rel_xs[j]);
                mpz_mod(X, X, N);
                if (rel_sg[j]) mpz_neg(Y, Y);
                for (int f=0; f<rel_nf[j]; f++)
                    mpz_mul_ui(Y, Y, fb[rel_fs[j][f]]);
                mpz_mod(Y, Y, N);
            }
        }
        
        // X² ≡ Y² (mod N) → check gcd
        mpz_sub(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(M);
            for (int r=0; r<nrels; r++) free(rel_fs[r]);
            goto success;
        }
        mpz_add(tmp, X, Y);
        mpz_gcd(g, tmp, N);
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X); mpz_clear(Y);
            free(M);
            for (int r=0; r<nrels; r++) free(rel_fs[r]);
            goto success;
        }
        mpz_clear(X); mpz_clear(Y);
    }
    
    free(M);
    for (int r=0; r<nrels; r++) free(rel_fs[r]);

fail:
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return 0;

success:
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return 1;
}
