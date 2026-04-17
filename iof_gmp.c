// iof_gmp.c — Inside-Out Factoring with Multi-Polynomial Sieve
// From Catalog: InsideOutResearch.lean
//   factor_condition: p|N → p|((N-2k)²-1) ⟺ p|(4k²-1)
//   four_k_sq_minus_one: 4k²-1 = (2k-1)(2k+1)  
//   factor_at_half_p: at k=(p-1)/2, p|(4k²-1) → IOF finds factor
//   multiPolySieve: 7 polynomial GCD channels per k value
// From Catalog: Core.lean
//   sqMap iteration: x^{2^k} mod n — power-of-2 smoothness check
//   orbit_collision_gives_factor: if x≡y (mod p) but x≢y (mod N) → gcd(x-y,N)>1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gmp.h>

// Multi-polynomial sieve from InsideOutResearch.lean
// Tests gcd(p(n,k), n) for 7+ polynomial forms p
int iof_multi_poly_factor(const char *n_str, char *result_str, int result_size, unsigned long max_k) {
    mpz_t n, v, g, tmp;
    mpz_init_set_str(n, n_str, 10);
    mpz_init(v); mpz_init(g); mpz_init(tmp);
    
    int found = 0;
    
    // Check even
    if (mpz_even_p(n)) {
        gmp_snprintf(result_str, result_size, "2");
        found = 1; goto cleanup;
    }
    
    // Quick trial division for small primes (from Catalog: smooth_below_base)
    for (unsigned long pr = 3; pr <= 257; pr += 2) {
        // Quick primality for trial division
        int is_prime = 1;
        for (unsigned long d = 3; d * d <= pr; d += 2) {
            if (pr % d == 0) { is_prime = 0; break; }
        }
        if (!is_prime) continue;
        
        mpz_mod_ui(tmp, n, pr);
        if (mpz_cmp_ui(tmp, 0) == 0) {
            // Check it's not N itself
            mpz_divexact_ui(tmp, n, pr);
            if (mpz_cmp_ui(tmp, 1) > 0) {
                gmp_snprintf(result_str, result_size, "%lu", pr);
                found = 1; goto cleanup;
            }
        }
    }
    
    // Multi-polynomial sieve from InsideOutResearch.lean
    // Polynomials: k²-1, 2k²-1, k²+k-1, 2k²+1, 3k²-1, k²+k+1, 3k²+1, k²-2
    for (unsigned long k = 1; k <= max_k && !found; k++) {
        unsigned long k2 = k * k;
        
        // Poly 1: k²-1 (from 4k²-1 factorization)
        if (k2 > 1) {
            mpz_set_ui(v, k2 - 1);
            mpz_gcd(g, v, n);
            if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
                gmp_snprintf(result_str, result_size, "%Zd", g);
                found = 1; break;
            }
        }
        
        // Poly 2: 2k²-1 (double square)
        mpz_set_ui(v, 2 * k2 - 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 3: k²+k-1 (off-diagonal)
        mpz_set_ui(v, k2 + k - 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 4: 2k²+1 (+1 variant)
        mpz_set_ui(v, 2 * k2 + 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 5: 3k²-1 (triple square)
        mpz_set_ui(v, 3 * k2 - 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 6: k²+k+1 (+k+1 variant)
        mpz_set_ui(v, k2 + k + 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 7: 3k²+1 (triple +1)
        mpz_set_ui(v, 3 * k2 + 1);
        mpz_gcd(g, v, n);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // Poly 8: k²-2 (near-square)
        if (k2 > 2) {
            mpz_set_ui(v, k2 - 2);
            mpz_gcd(g, v, n);
            if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
                gmp_snprintf(result_str, result_size, "%Zd", g);
                found = 1; break;
            }
        }
    }
    
cleanup:
    mpz_clear(n); mpz_clear(v); mpz_clear(g); mpz_clear(tmp);
    return found;
}

// Power-of-2 smoothness check from Core.lean: sqMap iteration
// x^{2^k} mod n — finds factor if ord_p(x) divides 2^k
// Combined with multiple bases: 2, 3, 5, 7, 11, 13
int power2_smooth_factor(const char *n_str, char *result_str, int result_size, unsigned long max_power) {
    mpz_t n, x, g, one;
    mpz_init_set_str(n, n_str, 10);
    mpz_init(x); mpz_init(g); mpz_init_set_ui(one, 1);
    
    int found = 0;
    unsigned long bases[] = {2, 3, 5, 7, 11, 13};
    int n_bases = 6;
    
    for (int b = 0; b < n_bases && !found; b++) {
        mpz_set_ui(x, bases[b]);
        
        // Compute x^{2^k} mod n by repeated squaring
        // From Catalog: sq_iter_eq_pow — (sqMap)^k(x) = x^{2^k}
        for (unsigned long k = 0; k < max_power && !found; k++) {
            mpz_powm_ui(x, x, 2, n);  // x = x² mod n = x^{2^{k+1}} mod n
            
            // Check if x ≡ 1 (mod p) for some p | n
            mpz_sub(g, x, one);  // x - 1
            mpz_gcd(g, g, n);
            if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, n) < 0) {
                gmp_snprintf(result_str, result_size, "%Zd", g);
                found = 1;
            }
        }
    }
    
    mpz_clear(n); mpz_clear(x); mpz_clear(g); mpz_clear(one);
    return found;
}

// Combined: IOF multi-poly sieve + power2 smoothness
// The two cover DIFFERENT smoothness classes:
// IOF: p-1 = smooth (captures 4k²-1 factorization)
// power2: ord(x) = 2^k smooth (captures Fermat-like structures)
// From Catalog: MetaOracle.crustallize — optimal frozen crystal = both channels
int combined_catalog_factor(const char *n_str, char *result_str, int result_size) {
    // First: quick multi-poly sieve (for small k, very fast)
    if (iof_multi_poly_factor(n_str, result_str, result_size, 1000000)) {
        return 1;
    }
    
    // Second: power-of-2 smoothness (up to 2^20 = M)
    if (power2_smooth_factor(n_str, result_str, result_size, 20)) {
        return 1;
    }
    
    return 0;
}
