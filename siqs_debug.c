#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "Usage: %s <number>\n", argv[0]); return 1; }
    
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, argv[1], 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    
    int bits = (int)mpz_sizeinbase(N, 2);
    fprintf(stderr, "N has %d bits\n", bits);
    
    // Factor base
    int fb_target = bits <= 64 ? 80 : bits <= 80 ? 200 : bits <= 100 ? 500 : bits <= 120 ? 800 : 1200;
    int sieve_len = bits <= 64 ? 100000 : bits <= 80 ? 200000 : bits <= 100 ? 500000 : 1000000;
    
    int fb[8000]; double log_fb[8000]; int fb_sz = 0;
    unsigned long long fb_r1[8000], fb_r2[8000];
    
    for (unsigned long p = 3; fb_sz < fb_target && p < 200000; p += 2) {
        int ip = 1; for (int d = 3; d*d <= (int)p; d += 2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        unsigned long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) { fprintf(stderr, "Found factor %lu\n", p); return 0; }
        
        // Euler criterion
        unsigned long long leg = 1;
        for (unsigned long long e = (p-1)/2, b = nm; e > 0; e >>= 1) {
            if (e & 1) leg = leg * b % p;
            b = b * b % p;
        }
        if (leg != 1) continue;
        
        // Tonelli-Shanks
        unsigned long long sr;
        if (p % 4 == 3) {
            sr = 1;
            for (unsigned long long e = (p+1)/4, b = nm; e > 0; e >>= 1) {
                if (e & 1) sr = sr * b % p;
                b = b * b % p;
            }
        } else {
            // Simple search for small p
            sr = 0;
            for (unsigned long long t = 1; t < p; t++) {
                if (t * t % p == nm) { sr = t; break; }
            }
            if (sr == 0) continue; // Shouldn't happen
        }
        
        fb[fb_sz] = (int)p;
        log_fb[fb_sz] = log((double)p);
        
        // s = ceil(sqrt(N))
        mpz_sqrt(s, N);
        if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
        
        unsigned long long sm = mpz_fdiv_ui(s, p);
        fb_r1[fb_sz] = (sr - sm + p) % p;  // root1: x ≡ sr (mod p) relative to s
        fb_r2[fb_sz] = (p - sr - sm + 2*p) % p;  // root2: x ≡ -sr (mod p)
        fb_sz++;
    }
    
    fprintf(stderr, "Factor base: %d primes, sieve_len=%d\n", fb_sz, sieve_len);
    
    // Sieve
    double *sv = malloc(sieve_len * sizeof(double));
    int nrels = 0;
    int target = fb_sz + 20;
    long long rel_xs[10020];
    int rel_signs[10020];
    int *rel_fids[10020];
    int rel_nf[10020];
    
    double log_thresh = 0.5 * bits * 0.6931471805599453 + log((double)fb[fb_sz-1]);
    
    for (int blk = 0; nrels < target && blk < 200; blk++) {
        long long offset = (long long)blk * sieve_len;
        
        for (int i = 0; i < sieve_len; i++) sv[i] = 0.0;
        
        for (int j = 0; j < fb_sz; j++) {
            int p = fb[j];
            double lp = log_fb[j];
            
            // For x = s + offset + i, Q(x) = x² - N
            // x ≡ ±sqrt(N) (mod p)
            // i ≡ ±sqrt(N) - s - offset (mod p)
            long long r1 = (fb_r1[j] - offset % p + p) % p;
            long long r2 = (fb_r2[j] - offset % p + p) % p;
            
            for (int i = (int)r1; i < sieve_len; i += p) sv[i] += lp;
            if (r1 != r2)
                for (int i = (int)r2; i < sieve_len; i += p) sv[i] += lp;
        }
        
        int candidates = 0, smooths = 0;
        double cutoff = log_thresh - 2.5 * log((double)fb[fb_sz-1]);
        
        for (int i = 0; i < sieve_len && nrels < target; i++) {
            if (sv[i] < cutoff) continue;
            candidates++;
            
            long long xx = offset + i;
            mpz_set_si(Qx, xx);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = 0;
            if (mpz_sgn(Qx) < 0) { mpz_neg(Qx, Qx); sign = 1; }
            
            mpz_set(tmp, Qx);
            int fids[8000], nf = 0;
            for (int j = 0; j < fb_sz && mpz_cmp_ui(tmp, 1) > 0; j++) {
                while (mpz_divisible_ui_p(tmp, (unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp, tmp, (unsigned long)fb[j]);
                    fids[nf++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                smooths++;
                rel_xs[nrels] = xx;
                rel_signs[nrels] = sign;
                rel_nf[nrels] = nf;
                rel_fids[nrels] = malloc(nf * sizeof(int));
                memcpy(rel_fids[nrels], fids, nf * sizeof(int));
                nrels++;
            }
        }
        
        if (blk < 5 || nrels >= target)
            fprintf(stderr, "Block %d: candidates=%d smooths=%d total_rels=%d/%d\n", 
                    blk, candidates, smooths, nrels, target);
    }
    free(sv);
    
    fprintf(stderr, "Total relations: %d (target: %d)\n", nrels, target);
    
    if (nrels < fb_sz + 5) {
        fprintf(stderr, "Not enough relations!\n");
        return 1;
    }
    
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
            int used = 0; for (int c = 0; c < col; c++) if(piv[c]==row){used=1;break;}
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
    
    // Find null vectors
    int found = 0;
    for (int i = 0; i < nrows; i++) {
        int zero = 1;
        for (int w = 0; w < cwords; w++) if(M[i*twords+w]){zero=0;break;}
        if (!zero) continue;
        
        mpz_t X, Y; mpz_init_set_ui(X, 1); mpz_init_set_ui(Y, 1);
        
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                mpz_set_si(tmp, rel_xs[j]);
                mpz_mul(X, X, tmp);
                mpz_mod(X, X, N);
            }
        }
        
        int total_exp[8000];
        for (int j = 0; j < fb_sz; j++) total_exp[j] = 0;
        
        for (int j = 0; j < nrows; j++) {
            if (M[i*twords + cwords + j/64] & (1ULL << (j%64))) {
                for (int f = 0; f < rel_nf[j]; f++)
                    total_exp[rel_fids[j][f]]++;
            }
        }
        
        int all_even = 1;
        for (int j = 0; j < fb_sz; j++) if (total_exp[j] % 2 != 0) { all_even = 0; break; }
        
        fprintf(stderr, "Null vector %d: all_even=%d\n", i, all_even);
        
        if (!all_even) { mpz_clear(X); mpz_clear(Y); continue; }
        
        for (int j = 0; j < fb_sz; j++) {
            if (total_exp[j] > 0) {
                mpz_t base; mpz_init_set_ui(base, (unsigned long)fb[j]);
                mpz_pow_ui(tmp, base, (unsigned long)(total_exp[j] / 2));
                mpz_mul(Y, Y, tmp);
                mpz_mod(Y, Y, N);
                mpz_clear(base);
            }
        }
        
        mpz_sub(tmp, X, Y); mpz_gcd(g, tmp, N);
        fprintf(stderr, "  gcd(X-Y,N) = "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
        
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(argv[1], 500, "%Zd", g); // Abuse argv as output buffer
            fprintf(stderr, "FOUND FACTOR: "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
            found = 1;
        }
        
        if (!found) {
            mpz_add(tmp, X, Y); mpz_gcd(g, tmp, N);
            fprintf(stderr, "  gcd(X+Y,N) = "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
            if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
                fprintf(stderr, "FOUND FACTOR: "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
                found = 1;
            }
        }
        mpz_clear(X); mpz_clear(Y);
        if (found) break;
    }
    
    if (!found) fprintf(stderr, "No factor found\n");
    
    free(M); free(piv);
    for (int r = 0; r < nrels; r++) free(rel_fids[r]);
    mpz_clear(N); mpz_clear(s); mpz_clear(Qx); mpz_clear(tmp); mpz_clear(g);
    return found ? 0 : 1;
}
