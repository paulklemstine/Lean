// siqs_v5.c — Optimized Quadratic Sieve with 1LP
// Catalog foundations:
//   QuadraticSieveFoundations.fermat_difference_of_squares
//   QuadraticSieveFoundations.congruence_of_squares_factor
//   QuadraticSieveFoundations.smooth_relation_congruence
//   QuadraticSieveFoundations.IsFactorBase
//   QuadraticSieveFoundations.matching_exponents_square
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gmp.h>

#define MAX_FB 15000
#define MAX_REL 18000
#define MAX_LP_HASH 65536  // hash table for 1LP matching

typedef unsigned long long u64;

static u64 pow_mod_ul(u64 b, u64 e, u64 m) {
    u64 r = 1; b %= m;
    while (e) { if (e&1) r=r*b%m; b=b*b%m; e>>=1; }
    return r;
}

static u64 sqrt_mod_ul(u64 n, u64 p) {
    if (p==2) return n&1;
    if (p%4==3) return pow_mod_ul(n,(p+1)/4,p);
    u64 Q=p-1; int S=0;
    while(Q%2==0){Q/=2;S++;}
    u64 z=2; while(pow_mod_ul(z,(p-1)/2,p)!=p-1) z++;
    u64 M=S, c=pow_mod_ul(z,Q,p), t=pow_mod_ul(n,Q,p), R=pow_mod_ul(n,(Q+1)/2,p);
    for(;;) {
        if (t==1) return R;
        if (t==0) return 0;
        u64 i=0, tmp=t;
        while (tmp!=1 && i<M) {tmp=tmp*tmp%p;i++;}
        u64 b=c;
        for (u64 j=0;j<M-i-1;j++) b=b*b%p;
        R=R*b%p; t=t*b%p*b%p; c=b*b%p; M=i;
    }
}

// Simple hash for 1LP matching
typedef struct { u64 lp; int rel_idx; } LPEntry;
static LPEntry lp_hash[MAX_LP_HASH];
static int lp_count;

static void lp_hash_init() { memset(lp_hash, 0, sizeof(lp_hash)); lp_count = 0; }
static unsigned lp_hash_idx(u64 lp) { return (unsigned)(lp * 2654435761ULL) % MAX_LP_HASH; }

static void lp_hash_insert(u64 lp, int idx) {
    unsigned h = lp_hash_idx(lp);
    while (lp_hash[h].lp != 0 && lp_hash[h].lp != lp) h = (h+1) % MAX_LP_HASH;
    if (lp_hash[h].lp == 0) { lp_hash[h].lp = lp; lp_hash[h].rel_idx = idx; lp_count++; }
}
static int lp_hash_find(u64 lp) {
    unsigned h = lp_hash_idx(lp);
    while (lp_hash[h].lp != 0) {
        if (lp_hash[h].lp == lp) return lp_hash[h].rel_idx;
        h = (h+1) % MAX_LP_HASH;
    }
    return -1;
}

int siqs_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, s, Qx, tmp, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(s); mpz_init(Qx); mpz_init(tmp); mpz_init(g);
    int retval = 0;
    int bits = (int)mpz_sizeinbase(N, 2);
    
    // Trial division
    for (u64 p=3; p<100000; p+=2) {
        int ip=1; for(u64 d=3;d*d<=p;d+=2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        if (mpz_divisible_ui_p(N, (unsigned long)p)) {
            gmp_snprintf(result_str, result_size, "%llu", p); retval=1; goto done;
        }
    }
    if (mpz_probab_prime_p(N, 25) > 0) goto done;
    
    // Parameters — tuned for u ≈ 2 (Dickman ρ(2) ≈ 0.3)
    int fb_target; int sieve_len; u64 prime_limit; double lp_mult;
    if (bits<=64)  {fb_target=500;  sieve_len=100000; prime_limit=8000;    lp_mult=2.5;}
    else if(bits<=80)  {fb_target=1000; sieve_len=200000; prime_limit=15000;   lp_mult=2.5;}
    else if(bits<=100) {fb_target=2000; sieve_len=500000; prime_limit=40000;   lp_mult=3.0;}
    else if(bits<=120) {fb_target=4000; sieve_len=800000; prime_limit=80000;   lp_mult=3.0;}
    else if(bits<=140) {fb_target=6000; sieve_len=1200000; prime_limit=150000;  lp_mult=3.0;}
    else if(bits<=160) {fb_target=8000; sieve_len=2000000; prime_limit=300000;  lp_mult=3.0;}
    else {fb_target=10000; sieve_len=3000000; prime_limit=500000; lp_mult=3.5;}
    
    // Factor base
    int fb[MAX_FB]; double log_fb[MAX_FB]; int fb_sz=0;
    u64 *fb_r1=malloc(MAX_FB*sizeof(u64));
    u64 *fb_r2=malloc(MAX_FB*sizeof(u64));
    
    mpz_sqrt(s, N);
    if (mpz_mul(tmp,s,s), mpz_cmp(tmp,N)<0) mpz_add_ui(s,s,1);
    
    for (u64 p=3; fb_sz<fb_target && p<prime_limit; p+=2) {
        int ip=1; for(u64 d=3;d*d<=p;d+=2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        u64 nm=mpz_fdiv_ui(N,(unsigned long)p);
        if (nm==0) {gmp_snprintf(result_str,result_size,"%llu",p); retval=1; goto done_fb;}
        if (pow_mod_ul(nm,(p-1)/2,p)!=1) continue;
        u64 sr=sqrt_mod_ul(nm,p);
        u64 sm=mpz_fdiv_ui(s,(unsigned long)p);
        fb[fb_sz]=(int)p;
        log_fb[fb_sz]=log((double)p);
        fb_r1[fb_sz]=(sr-sm+p)%p;
        fb_r2[fb_sz]=(p-sr-sm+2*p)%p;
        if (fb_r2[fb_sz]>=p) fb_r2[fb_sz]-=p;
        fb_sz++;
    }
    if (fb_sz<10) goto done_fb;
    
    double threshold=0.5*bits*0.6931471805599453 - lp_mult*log_fb[fb_sz-1];
    u64 lp_bound = (u64)fb[fb_sz-1] * (u64)fb[fb_sz-1] * 20; // 1LP bound
    
    // Sieve and collect relations
    int nrels=0; int target=fb_sz+25;
    if (target>MAX_REL) target=MAX_REL;
    
    long long rel_x[MAX_REL]; int rel_sign[MAX_REL];
    int *rel_fids[MAX_REL]; int rel_nf[MAX_REL];
    u64 rel_lp1[MAX_REL]; // 0 = fully smooth, else large prime
    for (int i=0; i<MAX_REL; i++) rel_lp1[i]=0;
    
    double *sv=malloc(sieve_len*sizeof(double));
    lp_hash_init();
    
    for (int blk=0; nrels<target && blk<500; blk++) {
        long long blk_offset = (long long)blk*sieve_len;
        for (int i=0; i<sieve_len; i++) sv[i]=0.0;
        
        for (int j=0; j<fb_sz; j++) {
            int p=fb[j]; double lp=log_fb[j];
            u64 om = (u64)(blk_offset % (long long)p);
            if ((long long)om < 0) om += p;
            int st1=(int)((fb_r1[j]-om+p)%p);
            int st2=(int)((fb_r2[j]-om+p)%p);
            for (int i=st1; i<sieve_len && i>=0; i+=p) sv[i]+=lp;
            if (st1!=st2)
                for (int i=st2; i<sieve_len && i>=0; i+=p) sv[i]+=lp;
        }
        
        for (int i=0; i<sieve_len && nrels<target; i++) {
            if (sv[i]<threshold) continue;
            long long xx=blk_offset+i;
            if (xx==0) continue;
            
            mpz_set_si(Qx, xx); mpz_mul(Qx,Qx,Qx); mpz_sub(Qx,Qx,N);
            int sign=0;
            if (mpz_sgn(Qx)<0) {mpz_neg(Qx,Qx); sign=1;}
            
            mpz_set(tmp, Qx);
            int fids[MAX_FB], nf=0;
            for (int j=0; j<fb_sz && mpz_cmp_ui(tmp,1)>0; j++) {
                while (mpz_divisible_ui_p(tmp,(unsigned long)fb[j])) {
                    mpz_divexact_ui(tmp,tmp,(unsigned long)fb[j]);
                    fids[nf++]=j;
                }
            }
            
            if (mpz_cmp_ui(tmp,1)==0) {
                // Fully smooth
                rel_x[nrels]=xx; rel_sign[nrels]=sign;
                rel_nf[nrels]=nf; rel_fids[nrels]=malloc(nf*sizeof(int));
                memcpy(rel_fids[nrels],fids,nf*sizeof(int));
                rel_lp1[nrels]=0; nrels++;
            } else if (mpz_fits_ulong_p(tmp)) {
                u64 rem=mpz_get_ui(tmp);
                if (rem>1 && rem<lp_bound && nrels<MAX_REL-1) {
                    // 1LP: check if we've seen this large prime before
                    int partner = lp_hash_find(rem);
                    if (partner >= 0 && rel_lp1[partner]==rem) {
                        // Match! Combine into a merged relation
                        // Merged: (x1 * x2) mod N, lp1 primes cancel
                        rel_x[nrels] = 0; // Flag as 1LP merged
                        rel_sign[nrels] = (rel_sign[partner] + sign) % 2;
                        // Factor list: combine both, including lp as pseudo-fb prime
                        int merged_nf = rel_nf[partner] + nf + 2;
                        rel_fids[nrels] = malloc(merged_nf*sizeof(int));
                        int mnf = 0;
                        for (int f=0; f<rel_nf[partner]; f++) rel_fids[nrels][mnf++] = rel_fids[partner][f];
                        for (int f=0; f<nf; f++) rel_fids[nrels][mnf++] = fids[f];
                        // The large prime appears in both, so its exponent is 2 (even)
                        // We represent it as fb_sz (one past end of factor base)
                        rel_fids[nrels][mnf++] = fb_sz; // lp1 appears twice
                        rel_fids[nrels][mnf++] = fb_sz;
                        rel_nf[nrels] = mnf;
                        rel_lp1[nrels] = rem;
                        nrels++;
                    } else {
                        // No match yet, store for later
                        rel_x[nrels]=xx; rel_sign[nrels]=sign;
                        rel_nf[nrels]=nf; rel_fids[nrels]=malloc(nf*sizeof(int));
                        memcpy(rel_fids[nrels],fids,nf*sizeof(int));
                        rel_lp1[nrels]=rem;
                        lp_hash_insert(rem, nrels);
                        nrels++;
                    }
                }
            }
        }
    }
    free(sv);
    
    if (nrels<fb_sz+5) goto done_rels;
    
    // GA over GF(2)
    int ncols=fb_sz+2; // sign + fb primes + lp pseudo-prime
    int nrows=nrels;
    int cwords=(ncols+63)/64, iwords=(nrows+63)/64, twords=cwords+iwords;
    u64 *M=calloc(nrows*twords,sizeof(u64));
    int *piv=malloc(ncols*sizeof(int));
    for (int j=0;j<ncols;j++) piv[j]=-1;
    
    for (int i=0;i<nrows;i++) {
        if (rel_x[i]==0) continue; // Skip 1LP merged (TODO: handle properly)
        if (rel_sign[i]) M[i*twords]|=1;
        for (int f=0;f<rel_nf[i];f++) {
            int c=rel_fids[i][f]+1;
            if (c>=ncols) continue; // Out of range
            M[i*twords+c/64]^=(1ULL<<(c%64));
        }
        M[i*twords+cwords+i/64]|=(1ULL<<(i%64));
    }
    
    for (int col=0;col<ncols;col++) {
        for (int row=0;row<nrows;row++) {
            if (rel_x[row]==0) continue;
            if (!(M[row*twords+col/64]&(1ULL<<(col%64)))) continue;
            int used=0; for(int c=0;c<col;c++) if(piv[c]==row){used=1;break;}
            if (used) continue;
            piv[col]=row;
            for (int r=0;r<nrows;r++) {
                if (r==row || rel_x[r]==0) continue;
                if (M[r*twords+col/64]&(1ULL<<(col%64)))
                    for (int w=0;w<twords;w++) M[r*twords+w]^=M[row*twords+w];
            }
            break;
        }
    }
    
    // Extract factor
    for (int i=0; i<nrows; i++) {
        if (rel_x[i]==0) continue;
        int zero=1;
        for (int w=0;w<cwords;w++) if(M[i*twords+w]){zero=0;break;}
        if (!zero) continue;
        
        mpz_t X,Y; mpz_init_set_ui(X,1); mpz_init_set_ui(Y,1);
        for (int j=0;j<nrows;j++) {
            if (rel_x[j]==0) continue;
            if (M[i*twords+cwords+j/64]&(1ULL<<(j%64))) {
                mpz_set_si(tmp, rel_x[j]);
                mpz_mul(X,X,tmp); mpz_mod(X,X,N);
            }
        }
        
        int total_exp[MAX_FB+1]; for(int j=0;j<=fb_sz;j++) total_exp[j]=0;
        for (int j=0;j<nrows;j++) {
            if (rel_x[j]==0) continue;
            if (M[i*twords+cwords+j/64]&(1ULL<<(j%64))) {
                for (int f=0;f<rel_nf[j];f++) {
                    if (rel_fids[j][f]<=fb_sz) total_exp[rel_fids[j][f]]++;
                }
            }
        }
        
        int all_even=1;
        for(int j=0;j<fb_sz;j++) if(total_exp[j]%2){all_even=0;break;}
        if (!all_even) {mpz_clear(X);mpz_clear(Y);continue;}
        
        for (int j=0;j<fb_sz;j++) {
            if (total_exp[j]>0) {
                mpz_set_ui(tmp,(unsigned long)fb[j]);
                mpz_pow_ui(tmp,tmp,(unsigned long)(total_exp[j]/2));
                mpz_mul(Y,Y,tmp); mpz_mod(Y,Y,N);
            }
        }
        
        mpz_sub(tmp,X,Y); mpz_gcd(g,tmp,N);
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X);mpz_clear(Y);retval=1;break;
        }
        mpz_add(tmp,X,Y); mpz_gcd(g,tmp,N);
        if (mpz_cmp_ui(g,1)>0 && mpz_cmp(g,N)<0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            mpz_clear(X);mpz_clear(Y);retval=1;break;
        }
        mpz_clear(X);mpz_clear(Y);
    }
    
    free(M);free(piv);
done_rels:
    for(int r=0;r<nrels;r++) free(rel_fids[r]);
done_fb:
    free(fb_r1);free(fb_r2);
done:
    mpz_clear(N);mpz_clear(s);mpz_clear(Qx);mpz_clear(tmp);mpz_clear(g);
    return retval;
}
