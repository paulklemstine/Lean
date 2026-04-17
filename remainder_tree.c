// remainder_tree.c — Batch modular arithmetic via product/remainder trees
// Catalog: IOFSpeedup.leg_product, factor_in_product, bleg_product
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gmp.h>

// Compute N mod p_i for ALL primes simultaneously using remainder tree
void remainder_tree_batch(mpz_t N, unsigned long long *primes, int nprimes,
                           unsigned long long *remainders) {
    // Build product tree (balanced binary)
    int nlevels = 0;
    { int s = nprimes; while (s > 1) { nlevels++; s = (s+1)/2; } }
    
    int *lsz = malloc((nlevels+1)*sizeof(int));
    lsz[0] = nprimes;
    for (int i=1; i<=nlevels; i++) lsz[i] = (lsz[i-1]+1)/2;
    
    // tree[level][index] = product
    mpz_t **tree = malloc((nlevels+1)*sizeof(mpz_t*));
    for (int i=0; i<=nlevels; i++) {
        tree[i] = malloc(lsz[i]*sizeof(mpz_t));
        for (int j=0; j<lsz[i]; j++) mpz_init(tree[i][j]);
    }
    
    // Leaves
    for (int j=0; j<nprimes; j++) mpz_set_ui(tree[0][j], (unsigned long)primes[j]);
    
    // Build product tree bottom-up
    for (int i=1; i<=nlevels; i++) {
        for (int j=0; j<lsz[i]; j++) {
            int left=2*j, right=2*j+1;
            if (right < lsz[i-1])
                mpz_mul(tree[i][j], tree[i-1][left], tree[i-1][right]);
            else
                mpz_set(tree[i][j], tree[i-1][left]);
        }
    }
    
    // Top-down remainder tree
    mpz_t **rtree = malloc((nlevels+1)*sizeof(mpz_t*));
    for (int i=0; i<=nlevels; i++) rtree[i] = NULL;
    
    rtree[nlevels] = malloc(lsz[nlevels]*sizeof(mpz_t));
    mpz_init(rtree[nlevels][0]);
    mpz_mod(rtree[nlevels][0], N, tree[nlevels][0]);
    
    for (int i=nlevels-1; i>=0; i--) {
        rtree[i] = malloc(lsz[i]*sizeof(mpz_t));
        for (int j=0; j<lsz[i]; j++) {
            mpz_init(rtree[i][j]);
            mpz_mod(rtree[i][j], rtree[i+1][j/2], tree[i][j]);
        }
    }
    
    // Extract remainders
    for (int j=0; j<nprimes; j++) remainders[j] = mpz_get_ui(rtree[0][j]);
    
    // Cleanup
    for (int i=0; i<=nlevels; i++) {
        for (int j=0; j<lsz[i]; j++) { mpz_clear(tree[i][j]); mpz_clear(rtree[i][j]); }
        free(tree[i]); free(rtree[i]);
    }
    free(tree); free(rtree); free(lsz);
}

// Exported function: batch factor detection
// Returns 1 if a factor found (in *factor), 0 otherwise
int batch_find_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N;
    mpz_init_set_str(N, n_str, 10);
    
    // Generate small primes up to 100000
    int max_p = 100000;
    unsigned long long *primes = malloc(10000*sizeof(unsigned long long));
    int nprimes = 0;
    
    for (unsigned long long p = 3; p < max_p && nprimes < 10000; p += 2) {
        int ip = 1;
        for (unsigned long d = 3; d*d <= p; d += 2) if(p%d==0){ip=0;break;}
        if (!ip) continue;
        primes[nprimes++] = p;
    }
    
    // Batch GCD: compute product of all primes mod N, then GCD
    mpz_t P, G;
    mpz_init_set_ui(P, 1);
    for (int i = 0; i < nprimes; i++) {
        mpz_mul_ui(P, P, (unsigned long)primes[i]);
        mpz_mod(P, P, N);  // Keep reduced
    }
    mpz_init(G);
    mpz_gcd(G, N, P);
    
    int found = 0;
    if (mpz_cmp_ui(G, 1) > 0) {
        // Found factor group! Use remainder tree to find which primes
        unsigned long long *rems = malloc(nprimes * sizeof(unsigned long long));
        remainder_tree_batch(N, primes, nprimes, rems);
        
        for (int i = 0; i < nprimes; i++) {
            if (rems[i] == 0) {
                gmp_snprintf(result_str, result_size, "%llu", primes[i]);
                found = 1;
                break;
            }
        }
        free(rems);
    }
    
    mpz_clear(N); mpz_clear(P); mpz_clear(G);
    free(primes);
    return found;
}
