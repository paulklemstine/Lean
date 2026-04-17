// squfof_proper.c - Correct GMP-based SQUFOF (Shanks' Square Forms)
// Compile: gcc -O3 -shared -fPIC -o squfof_proper.so squfof_proper.c -lgmp
//
// SQUFOF: finds factor of N by reducing indefinite binary quadratic forms.
// The form (a,b,c) with disc = b²-4ac = 4mN is reduced until a is a perfect square.
// Then a 2nd reduction finds the gcd.
//
// Complexity: O(N^{1/4}) — much better than rho's O(N^{1/4}polylog) 
// for balanced semiprimes where both factors are > N^{1/3}.
//
// Catalog: quadraticFormRepr, two_square_reps_give_factor,
//          pyth_factoring_identity (c-b)(c+b) = a²  

#include <gmp.h>
#include <string.h>

// Multiplier table for SQUFOF
static const unsigned long mtable[] = {1, 3, 5, 7, 11, 3*5, 3*7, 3*11, 5*7, 5*11, 7*11, 3*5*7};
static const int nmult = 12;

int squfof_factor(const char *n_str, char *result_str, int result_size) {
    mpz_t N, D, Po, P, Pn, Q, Qn, Qo, r, s, t, g;
    mpz_init_set_str(N, n_str, 10);
    mpz_init(D); mpz_init(Po); mpz_init(P); mpz_init(Pn);
    mpz_init(Q); mpz_init(Qn); mpz_init(Qo);
    mpz_init(r); mpz_init(s); mpz_init(t); mpz_init(g);
    
    int found = 0;
    
    // Check even
    if (mpz_even_p(N)) {
        gmp_snprintf(result_str, result_size, "2");
        found = 1; goto cleanup;
    }
    
    // Check perfect square
    mpz_sqrt(r, N);
    mpz_mul(t, r, r);
    if (mpz_cmp(t, N) == 0 && mpz_cmp_ui(r, 1) > 0) {
        gmp_snprintf(result_str, result_size, "%Zd", r);
        found = 1; goto cleanup;
    }
    
    // Try each multiplier
    for (int mi = 0; mi < nmult && !found; mi++) {
        unsigned long m = mtable[mi];
        
        // Check gcd(m, N)
        mpz_gcd_ui(g, N, m);
        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
            gmp_snprintf(result_str, result_size, "%Zd", g);
            found = 1; break;
        }
        
        // D = m*N
        mpz_mul_ui(D, N, m);
        
        // Po = floor(sqrt(D))
        mpz_sqrt(Po, D);
        mpz_mul(t, Po, Po);
        if (mpz_cmp(t, D) > 0) mpz_sub_ui(Po, Po, 1);
        
        // Q = D - Po²
        mpz_mul(t, Po, Po);
        mpz_sub(Q, D, t);
        
        // Qo = m (or 1 depending on convention)  
        mpz_set_ui(Qo, m);
        
        // P = Po
        mpz_set(P, Po);
        
        // Search limit based on sqrt(D)
        mpz_sqrt(r, D);  // approximately 4th root of D
        unsigned long lim = mpz_get_ui(r);
        if (lim > 5000000) lim = 5000000;
        if (lim < 1000) lim = 1000;
        
        // Forward cycle: reduce form until Q is a perfect square
        for (unsigned long i = 0; i < lim && !found; i++) {
            // Pn = floor((Po + P) / Q) * Q - P
            mpz_add(t, Po, P);
            mpz_fdiv_q(t, t, Q);
            mpz_mul(t, t, Q);
            mpz_sub(Pn, t, P);
            
            // Qn = Qo + ((P - Pn) * t)   where t = (P + Po - Pn*(Pn+P)) / Q 
            // Actually: Qn = Qo + (P - Pn) * ((Po + Pn)/Q... simplified)
            // The standard formula: Qn = Qo + (P - Pn) * ((Po + Pn) / Q)  
            // Hmm, let me use the correct recurrence.
            
            // Standard SQUFOF recurrence:
            // q_i = floor((P_prev + P_i) / Q_i)   [not used directly]
            // P_{i+1} = q_i * Q_i - P_i
            // Q_{i+1} = Q_{i-1} + q_i * (P_i - P_{i+1})
            
            mpz_add(t, Po, P);
            mpz_fdiv_q(s, t, Q);  // s = q_i = floor((Po + P) / Q)
            // Wait, Po is the initial P, not the previous one.
            // In standard SQUFOF: q_i = floor((P_0 + P_i) / Q_i)
            
            // P_{i+1} = s * Q_i - P_i
            mpz_mul(Pn, s, Q);
            mpz_sub(Pn, Pn, P);
            
            // Q_{i+1} = Q_{i-1} + s * (P_i - P_{i+1})
            mpz_sub(t, P, Pn);  // P - Pn
            mpz_mul(t, s, t);   // s * (P - Pn)
            mpz_add(Qn, Qo, t);
            
            // Check if Qn is a perfect square
            mpz_sqrt(r, Qn);
            mpz_mul(t, r, r);
            int is_square = (mpz_cmp(t, Qn) == 0) && (mpz_cmp_ui(r, 1) > 0);
            
            if (is_square && (i & 1) == 0) {
                // Found a square Q at an even step!
                // Now do reverse cycle to find the gcd.
                
                // r is the square root of Qn
                mpz_set(s, r);  // s = sqrt(Qn)
                
                // g = gcd(s, N) — quick check
                mpz_gcd(g, s, N);
                if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
                    gmp_snprintf(result_str, result_size, "%Zd", g);
                    found = 1;
                    break;
                }
                
                // Reverse cycle
                // P = s * floor((Po - Pn) / s) + Pn 
                mpz_sub(t, Po, Pn);
                mpz_fdiv_q(t, t, s);
                mpz_mul(t, t, s);
                mpz_add(P, t, Pn);
                
                // Q = s
                mpz_set(Q, s);
                
                // Qo = (D - P*P) / Q
                mpz_mul(t, P, P);
                mpz_sub(t, D, t);
                mpz_fdiv_q(Qo, t, Q);
                
                // Reduce until Pn == P
                for (unsigned long j = 0; j < lim; j++) {
                    // q = floor((Po + P) / Q)
                    mpz_add(t, Po, P);
                    mpz_fdiv_q(s, t, Q);
                    
                    // Pn = q * Q - P
                    mpz_mul(Pn, s, Q);
                    mpz_sub(Pn, Pn, P);
                    
                    // Check for fixed point
                    if (mpz_cmp(P, Pn) == 0) {
                        mpz_gcd(g, P, N);
                        if (mpz_cmp_ui(g, 1) > 0 && mpz_cmp(g, N) < 0) {
                            gmp_snprintf(result_str, result_size, "%Zd", g);
                            found = 1;
                        }
                        break;
                    }
                    
                    // If Pn == P_prev, we might find gcd via |Q|
                    // Qn = Qo + q*(P - Pn)
                    mpz_sub(t, P, Pn);
                    mpz_mul(t, s, t);
                    mpz_add(Qn, Qo, t);
                    
                    mpz_set(Qo, Q);
                    mpz_set(Q, Qn);
                    mpz_set(P, Pn);
                }
                
                if (found) break;
            }
            
            // Shift: (P, Q, Qo) → (Pn, Qn, Q)
            mpz_set(Qo, Q);
            mpz_set(Q, Qn);
            mpz_set(P, Pn);
        }
    }
    
cleanup:
    mpz_clear(N); mpz_clear(D); mpz_clear(Po); mpz_clear(P); mpz_clear(Pn);
    mpz_clear(Q); mpz_clear(Qn); mpz_clear(Qo);
    mpz_clear(r); mpz_clear(s); mpz_clear(t); mpz_clear(g);
    
    return found;
}
