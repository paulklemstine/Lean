// Direct ecm_factor() calls via C — eliminates subprocess overhead
// Catalog: MetaOracle.crystallize — optimal fixed point of query refinement
// Catalog: factoring_semiprime — ∃ x, 1 < gcd(x,pq) < pq
// Catalog: query_strategy_output_bound — k queries → at most 2^k outputs

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <gmp.h>

// ecm_factor signature: int ecm_factor(mpz_t f, mpz_t n, double B1, void *param)
extern int ecm_factor(mpz_t, mpz_t, double, void*);

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <number> <B1> [ncurves]\n", argv[0]);
        return 1;
    }
    
    mpz_t n, f;
    mpz_init(n);
    mpz_init(f);
    mpz_set_str(n, argv[1], 10);
    
    double B1 = atof(argv[2]);
    int ncurves = 1;
    if (argc > 3) ncurves = atoi(argv[3]);
    
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    
    for (int i = 0; i < ncurves; i++) {
        int result = ecm_factor(f, n, B1, NULL);
        if (result > 0 && mpz_cmp_ui(f, 1) > 0 && mpz_cmp(f, n) < 0) {
            clock_gettime(CLOCK_MONOTONIC, &t1);
            double elapsed = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
            gmp_printf("FACTOR %Zd TIME %.3f CURVE %d\n", f, elapsed, i+1);
            mpz_clear(n); mpz_clear(f);
            return 0;
        }
    }
    
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double elapsed = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
    printf("NO_FACTOR TIME %.3f CURVES %d\n", elapsed, ncurves);
    
    mpz_clear(n); mpz_clear(f);
    return 1;
}
