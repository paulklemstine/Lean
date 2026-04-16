// rho_inner.c - C implementation of Pollard rho inner loop
// Compile: gcc -O3 -shared -fPIC -o rho_inner.so rho_inner.c

#include <stdio.h>
#include <stdlib.h>

// Montgomery modular arithmetic for 64-bit numbers
// Only works for numbers < 2^63

typedef unsigned __int128 uint128_t;

// Advance y through the quadratic walk for 'steps' iterations
// y = (y*y + c) % n  or  y = (y*y + y + c) % n
// Also accumulate product q = q * (x - y) % n for GCD check
// Returns: 0 if no factor found, factor value if q accumulated a factor

static inline unsigned long long rho_step(
    unsigned long long y, unsigned long long c, unsigned long long n,
    unsigned long long *q_out, unsigned long long x,
    int steps, int use_add) {
    
    unsigned long long q = *q_out;
    
    if (use_add) {
        // f(y) = y*y + y + c
        for (int i = 0; i < steps; i++) {
            y = (((__uint128_t)y * y) % n + y + c) % n;
            // For negative: (x - y) % n when x > y gives x-y, when x < y gives n-(y-x)
            unsigned long long diff = (x >= y) ? (x - y) : (n - (y - x));
            q = ((__uint128_t)q * diff) % n;
        }
    } else {
        // f(y) = y*y + c
        for (int i = 0; i < steps; i++) {
            y = (((__uint128_t)y * y) % n + c) % n;
            unsigned long long diff = (x >= y) ? (x - y) : (n - (y - x));
            q = ((__uint128_t)q * diff) % n;
        }
    }
    
    *q_out = q;
    return y;
}

// Full Pollard rho with Brent detection
// Returns factor or 0 if not found
unsigned long long rho_c(
    unsigned long long n, int max_tries, unsigned long long seed, int use_dual) {
    
    unsigned long long max_r = 4000000;
    if (n > 256) {
        // Approximate N^{1/4} * 8
        unsigned long long s = 1;
        while (s * s * s * s < n && s < 100000000) s++;
        max_r = s * 8;
        if (max_r < 4000000) max_r = 4000000;
    }
    
    for (int c = 1; c <= max_tries && c <= 100; c++) {
        // Deterministic seed based on c
        unsigned long long y = seed;
        for (int j = 0; j < c * 31337; j++) {
            y = (y * 1103515245 + 12345) % n;
            if (y < 2) y = 2;
        }
        
        unsigned long long x = y;
        unsigned long long g = 1;
        unsigned long long r = 1;
        int use_add = use_dual && (c % 2 == 1);
        
        while (g == 1 && r <= max_r) {
            x = y;
            
            // Advance phase
            if (use_add) {
                for (unsigned long long i = 0; i < r; i++) {
                    y = (((__uint128_t)y * y) % n + y + c) % n;
                }
            } else {
                for (unsigned long long i = 0; i < r; i++) {
                    y = (((__uint128_t)y * y) % n + c) % n;
                }
            }
            
            // Detection phase with batch GCD
            unsigned long long k = 0;
            unsigned long long q = 1;
            while (k < r && g == 1) {
                unsigned long long batch = 1024;
                if (r - k < batch) batch = r - k;
                
                y = rho_step(y, c, n, &q, x, batch, use_add);
                k += batch;
                
                g = __builtin_ctzll(q) == 64 ? n : 1; // Quick check
                // Actually just do gcd
                // Use binary gcd for speed
                unsigned long long a = q, b = n;
                while (b != 0) {
                    a %= b;
                    unsigned long long t = a;
                    a = b;
                    b = t;
                }
                g = a;
            }
            
            r *= 2;
        }
        
        if (1 < g && g < n) return g;
    }
    
    return 0;
}