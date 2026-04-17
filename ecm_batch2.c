#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <gmp.h>

extern int ecm_factor(mpz_t, mpz_t, double, void*);

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <number> <B1> [ncurves]\n", argv[0]);
        return 1;
    }
    
    mpz_t n, f;
    mpz_init(n); mpz_init(f);
    mpz_set_str(n, argv[1], 10);
    
    double B1 = atof(argv[2]);
    int ncurves = 1;
    if (argc > 3) ncurves = atoi(argv[3]);
    
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    
    for (int i = 0; i < ncurves; i++) {
        int result = ecm_factor(f, n, B1, NULL);
        // Debug: print what ecm_factor returned
        gmp_printf("Curve %d: result=%d, f=%Zd, n=%Zd, cmp(1,f)=%d, cmp(f,n)=%d\n", 
                   i+1, result, f, n, mpz_cmp_ui(f, 1), mpz_cmp(f, n));
        if (result > 0 && mpz_cmp_ui(f, 1) > 0 && mpz_cmp(f, n) < 0) {
            clock_gettime(CLOCK_MONOTONIC, &t1);
            double elapsed = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
            gmp_printf("FACTOR %Zd TIME %.6f CURVE %d\n", f, elapsed, i+1);
            mpz_clear(n); mpz_clear(f);
            return 0;
        }
    }
    
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double elapsed = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
    printf("NO_FACTOR TIME %.6f CURVES %d\n", elapsed, ncurves);
    
    mpz_clear(n); mpz_clear(f);
    return 1;
}
