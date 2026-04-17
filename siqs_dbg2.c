#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "Usage: %s <N>\n", argv[0]); return 1; }
    
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, argv[1], 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    
    int bits = (int)mpz_sizeinbase(N, 2);
    fprintf(stderr, "N has %d bits\n", bits);
    
    mpz_sqrt(s, N);
    if (mpz_mul(tmp, s, s), mpz_cmp(tmp, N) < 0) mpz_add_ui(s, s, 1);
    
    // Factor base
    int fb_target = 60;
    int sieve_len = 100000;
    int fb[10000]; double log_fb[10000]; int fb_sz = 0;
    unsigned long long fb_r1[10000], fb_r2[10000];
    
    for (unsigned long p = 3; fb_sz < fb_target && p < 200000; p += 2) {
        int ip=1; for(unsigned long d=3;d*d<=p;d+=2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        unsigned long long nm = mpz_fdiv_ui(N, p);
        if (nm == 0) { fprintf(stderr, "Factor: %lu\n", p); return 0; }
        
        unsigned long long leg = 1;
        for (unsigned long long e=(p-1)/2, b=nm; e>0; e>>=1) {
            if (e & 1) leg = leg * b % p;
            b = b * b % p;
        }
        if (leg != 1) continue;
        
        // Compute sqrt
        unsigned long long sr = 0;
        if (p % 4 == 3) {
            sr = 1;
            for (unsigned long long e=(p+1)/4, b=nm; e>0; e>>=1) {
                if (e & 1) sr = sr * b % p;
                b = b * b % p;
            }
        } else {
            // Simple search
            for (unsigned long long t=1; t<p; t++) if (t*t%p==nm){sr=t;break;}
            if (sr==0) continue;
        }
        
        unsigned long long sm = mpz_fdiv_ui(s, p);
        fb[fb_sz] = (int)p;
        log_fb[fb_sz] = log((double)p);
        fb_r1[fb_sz] = (sr - sm + p) % p;
        fb_r2[fb_sz] = (p - sr - sm + 2*p) % p;
        if (fb_r2[fb_sz] >= p) fb_r2[fb_sz] -= p;
        
        // Verify roots
        unsigned long long x1 = (sm + fb_r1[fb_sz]) % p;
        unsigned long long x2 = (sm + fb_r2[fb_sz]) % p;
        if (x1*x1%p != nm) fprintf(stderr, "ROOT1 ERROR at p=%lu!\n", p);
        if (x2*x2%p != nm) fprintf(stderr, "ROOT2 ERROR at p=%lu!\n", p);
        
        fb_sz++;
    }
    
    fprintf(stderr, "Factor base: %d primes, first=%d, last=%d\n", fb_sz, fb[0], fb[fb_sz-1]);
    
    // Sieve
    double threshold = 0.5 * bits * 0.6931471805599453 - 2.0 * log_fb[fb_sz-1];
    fprintf(stderr, "Threshold: %.1f\n", threshold);
    
    double *sv = malloc(sieve_len * sizeof(double));
    int nrels = 0, target = fb_sz + 15;
    long long rel_x[10020]; int rel_sign[10020];
    int *rel_fids[10020]; int rel_nf[10020];
    
    int total_candidates = 0;
    
    for (int blk = 0; nrels < target && blk < 500; blk++) {
        long long blk_offset = (long long)blk * sieve_len;
        for (int i=0; i<sieve_len; i++) sv[i] = 0.0;
        
        for (int j=0; j<fb_sz; j++) {
            int p = fb[j];
            double lp = log_fb[j];
            long long om = blk_offset % p;
            if (om < 0) om += p;
            int st1 = (int)(((long long)fb_r1[j] - om + p) % p);
            int st2 = (int)(((long long)fb_r2[j] - om + p) % p);
            for (int i=st1; i<sieve_len && i>=0; i+=p) sv[i] += lp;
            if (st1 != st2)
                for (int i=st2; i<sieve_len && i>=0; i+=p) sv[i] += lp;
        }
        
        int blk_candidates = 0, blk_smooths = 0;
        for (int i=0; i<sieve_len && nrels<target; i++) {
            if (sv[i] < threshold) continue;
            blk_candidates++;
            
            long long xx = blk_offset + i;
            if (xx == 0) continue;
            
            mpz_set_si(Qx, xx);
            mpz_mul(Qx, Qx, Qx);
            mpz_sub(Qx, Qx, N);
            
            int sign = 0;
            if (mpz_sgn(Qx) < 0) { mpz_neg(Qx, Qx); sign = 1; }
            
            mpz_set(tmp, Qx);
            int fids[10000], nf = 0;
            for (int j=0; j<fb_sz && mpz_cmp_ui(tmp,1)>0; j++) {
                while (mpz_divisible_ui_p(tmp, (unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp, tmp, (unsigned long)fb[j]);
                    fids[nf++] = j;
                }
            }
            
            if (mpz_cmp_ui(tmp, 1) == 0) {
                blk_smooths++;
                rel_x[nrels] = xx;
                rel_sign[nrels] = sign;
                rel_nf[nrels] = nf;
                rel_fids[nrels] = malloc(nf * sizeof(int));
                memcpy(rel_fids[nrels], fids, nf * sizeof(int));
                nrels++;
            }
        }
        total_candidates += blk_candidates;
        
        if (blk < 3 || nrels >= target)
            fprintf(stderr, "Block %d: candidates=%d smooths=%d total=%d/%d\n",
                    blk, blk_candidates, blk_smooths, nrels, target);
    }
    free(sv);
    
    fprintf(stderr, "Total: candidates=%d smooths=%d target=%d\n", total_candidates, nrels, target);
    
    if (nrels < fb_sz + 5) { fprintf(stderr, "Not enough relations!\n"); return 1; }
    
    // Gaussian elimination
    typedef unsigned long long u64;
    int ncols = fb_sz + 1, nrows = nrels;
    int cwords = (ncols+63)/64, iwords = (nrows+63)/64, twords = cwords+iwords;
    u64 *M = calloc(nrows*twords, sizeof(u64));
    int *piv = malloc(ncols * sizeof(int));
    for (int j=0; j<ncols; j++) piv[j] = -1;
    
    for (int i=0; i<nrows; i++) {
        if (rel_sign[i]) M[i*twords] |= 1;
        for (int f=0; f<rel_nf[i]; f++) {
            int c = rel_fids[i][f]+1;
            M[i*twords+c/64] ^= (1ULL<<(c%64));
        }
        M[i*twords+cwords+i/64] |= (1ULL<<(i%64));
    }
    
    for (int col=0; col<ncols; col++) {
        for (int row=0; row<nrows; row++) {
            if (!(M[row*twords+col/64]&(1ULL<<(col%64)))) continue;
            int used=0; for(int c=0;c<col;c++) if(piv[c]==row){used=1;break;}
            if (used) continue;
            piv[col] = row;
            for (int r=0; r<nrows; r++) {
                if (r==row) continue;
                if (M[r*twords+col/64]&(1ULL<<(col%64)))
                    for (int w=0; w<twords; w++) M[r*twords+w] ^= M[row*twords+w];
            }
            break;
        }
    }
    
    int null_count = 0;
    for (int i=0; i<nrows; i++) {
        int zero=1;
        for (int w=0; w<cwords; w++) if(M[i*twords+w]){zero=0;break;}
        if (!zero) continue;
        
        null_count++;
        mpz_t X, Y; mpz_init_set_ui(X,1); mpz_init_set_ui(Y,1);
        for (int j=0; j<nrows; j++) {
            if (M[i*twords+cwords+j/64]&(1ULL<<(j%64))) {
                mpz_set_si(tmp, rel_x[j]);
                mpz_mul(X, X, tmp);
                mpz_mod(X, X, N);
            }
        }
        
        int total_exp[10000]; for(int j=0;j<fb_sz;j++) total_exp[j]=0;
        for (int j=0; j<nrows; j++) {
            if (M[i*twords+cwords+j/64]&(1ULL<<(j%64))) {
                for (int f=0; f<rel_nf[j]; f++) total_exp[rel_fids[j][f]]++;
            }
        }
        
        int all_even=1;
        for (int j=0; j<fb_sz; j++) if(total_exp[j]%2){all_even=0;break;}
        
        fprintf(stderr, "Null vector %d: all_even=%d\n", null_count, all_even);
        
        if (!all_even) { mpz_clear(X); mpz_clear(Y); continue; }
        
        for (int j=0; j<fb_sz; j++) {
            if (total_exp[j]>0) {
                mpz_set_ui(tmp, (unsigned long)fb[j]);
                mpz_pow_ui(tmp, tmp, (unsigned long)(total_exp[j]/2));
                mpz_mul(Y, Y, tmp);
                mpz_mod(Y, Y, N);
            }
        }
        
        mpz_sub(tmp, X, Y); mpz_gcd(g, tmp, N);
        fprintf(stderr, "  gcd(X-Y,N): "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            fprintf(stderr, "FOUND: "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
        }
        
        mpz_add(tmp, X, Y); mpz_gcd(g, tmp, N);
        fprintf(stderr, "  gcd(X+Y,N): "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            fprintf(stderr, "FOUND: "); mpz_out_str(stderr, 10, g); fprintf(stderr, "\n");
        }
        
        mpz_clear(X); mpz_clear(Y);
        if (null_count >= 5) break;
    }
    
    if (null_count == 0) fprintf(stderr, "No null vectors found!\n");
    
    return 0;
}
