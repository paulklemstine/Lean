// rho_gmp.c - GMP-based Pollard rho for arbitrary precision
// Compile: gcc -O3 -shared -fPIC -o rho_gmp.so rho_gmp.c -lgmp

#include <gmp.h>
#include <stdlib.h>

// Full Pollard rho with Brent detection using GMP
// Returns factor via result parameter, 1 on success, 0 on failure
int rho_gmp(const char *n_str, int max_tries, unsigned long long c_seed,
             int use_dual, char *result_str, int result_size) {
    mpz_t n, y, x, c, q, g, diff, tmp;
    mpz_t P0;
    
    mpz_init_set_str(n, n_str, 10);
    mpz_init(y);
    mpz_init(x);
    mpz_init(c);
    mpz_init(q);
    mpz_init(g);
    mpz_init(diff);
    mpz_init(tmp);
    mpz_init(P0);
    
    int found = 0;
    
    // max_r = max(4000000, 8 * approx_N^1/4)
    unsigned long max_r = 4000000;
    // Approximate N^{1/4}
    mpz_sqrt(tmp, n);
    mpz_sqrt(tmp, tmp);  // tmp ≈ n^{1/4}
    unsigned long n_quarter = mpz_get_ui(tmp);
    if (n_quarter > 500000) n_quarter = 500000;
    unsigned long bound = n_quarter * 8;
    if (bound > max_r) max_r = bound;
    
    for (int ci = 1; ci <= max_tries && ci <= 100; ci++) {
        mpz_set_ui(c, ci);
        int use_add = use_dual && (ci % 2 == 1);
        
        // Deterministic seed
        unsigned long long y_seed = c_seed;
        for (int j = 0; j < ci * 31337; j++) {
            y_seed = (y_seed * 1103515245ULL + 12345ULL);
        }
        mpz_set_ui(y, y_seed);
        mpz_mod(y, y, n);
        if (mpz_cmp_ui(y, 2) < 0) mpz_set_ui(y, 2);
        
        mpz_set(x, y);
        mpz_set_ui(g, 1);
        unsigned long r = 1;
        
        while (mpz_cmp_ui(g, 1) == 0 && r <= max_r) {
            mpz_set(x, y);
            
            // Advance phase: move y forward by r steps
            if (use_add) {
                for (unsigned long i = 0; i < r; i++) {
                    mpz_mul(tmp, y, y);
                    mpz_add(tmp, tmp, y);
                    mpz_add_ui(tmp, tmp, ci);
                    mpz_mod(y, tmp, n);
                }
            } else {
                for (unsigned long i = 0; i < r; i++) {
                    mpz_mul(tmp, y, y);
                    mpz_add_ui(tmp, tmp, ci);
                    mpz_mod(y, tmp, n);
                }
            }
            
            // Detection phase with batch GCD
            unsigned long k = 0;
            mpz_set_ui(q, 1);
            
            while (k < r && mpz_cmp_ui(g, 1) == 0) {
                unsigned long batch = 1024;
                if (r - k < batch) batch = r - k;
                
                for (unsigned long i = 0; i < batch; i++) {
                    if (use_add) {
                        mpz_mul(tmp, y, y);
                        mpz_add(tmp, tmp, y);
                        mpz_add_ui(tmp, tmp, ci);
                        mpz_mod(y, tmp, n);
                    } else {
                        mpz_mul(tmp, y, y);
                        mpz_add_ui(tmp, tmp, ci);
                        mpz_mod(y, tmp, n);
                    }
                    mpz_sub(diff, x, y);
                    mpz_mod(diff, diff, n);
                    mpz_mul(q, q, diff);
                    mpz_mod(q, q, n);
                }
                k += batch;
                
                mpz_gcd(g, q, n);
            }
            
            r *= 2;
        }
        
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            mpz_get_str(result_str, 10, g);
            found = 1;
            break;
        }
        
        // If g == n, try backtracking (simplified)
        if (mpz_cmp(g, n) == 0) {
            mpz_set_ui(g, 1);
            // Just skip this c value
        }
    }
    
    mpz_clear(n); mpz_clear(y); mpz_clear(x); mpz_clear(c);
    mpz_clear(q); mpz_clear(g); mpz_clear(diff); mpz_clear(tmp); mpz_clear(P0);
    
    return found;
}