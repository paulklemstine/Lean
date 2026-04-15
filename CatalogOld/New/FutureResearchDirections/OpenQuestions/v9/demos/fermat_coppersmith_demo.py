#!/usr/bin/env python3
"""
Fermat Factoring and Coppersmith Method Demo

Demonstrates:
1. Fermat's difference-of-squares factoring (fermat_factoring_odd)
2. Small modular root detection (small_mod_root_zero)
3. Hensel lifting for square roots (hensel_lift_square)
4. Energy landscape guided factoring

All mathematical foundations formally verified in Lean 4.
"""

import math
import time

def fermat_factor(N):
    """
    Fermat's factoring method: find a,b with N = a² - b².
    Formally verified: fermat_factoring_odd, diff_sq_factor
    """
    a = math.isqrt(N)
    if a * a == N:
        return a, 1  # Perfect square
    a += 1
    while True:
        b2 = a * a - N
        b = math.isqrt(b2)
        if b * b == b2:
            return a - b, a + b
        a += 1
        if a > (N + 1) // 2:
            return N, 1  # Failed (N is prime)

def coppersmith_small_root(f_coeffs, N, X_bound):
    """
    Find small root x₀ of f(x) ≡ 0 (mod N) with |x₀| < X_bound.
    Brute-force version (the formal Coppersmith bound ensures correctness).
    Verified: small_mod_root_zero, coppersmith_linear, coppersmith_quadratic_bound
    """
    for x in range(-X_bound, X_bound + 1):
        val = sum(c * x**i for i, c in enumerate(f_coeffs))
        if val % N == 0:
            return x
    return None

def hensel_lift(a, c, p, max_lifts=3):
    """
    Hensel lifting: given a² ≡ c (mod p), lift to a' with a'² ≡ c (mod p^k).
    Verified: hensel_lift_square, exists_mod_cancel
    """
    current_a = a
    current_mod = p
    lifts = [(current_a, current_mod)]
    
    for _ in range(max_lifts):
        # f(x) = x² - c, f'(x) = 2x
        if (2 * current_a) % p == 0:
            break  # Derivative is zero mod p, can't lift
        
        # Newton's method mod p²
        residue = (current_a ** 2 - c) % (current_mod * p)
        inv_deriv = pow(2 * current_a, -1, p) if math.gcd(2 * current_a, p) == 1 else None
        if inv_deriv is None:
            break
        
        t = (-residue * inv_deriv // current_mod) % p
        current_a = current_a + current_mod * t
        current_mod *= p
        lifts.append((current_a % current_mod, current_mod))
    
    return lifts

def energy_guided_factor(N, verbose=True):
    """
    Factor N using energy landscape insights.
    The energy function E(N,x) = N mod x has zeros exactly at divisors.
    Verified: energy_zero_at_divisor, energy_pos_at_nondivisor
    """
    sqrt_N = math.isqrt(N)
    
    # Strategy: check near √N first (Fermat insight)
    for delta in range(sqrt_N + 1):
        for x in [sqrt_N - delta, sqrt_N + delta]:
            if x > 0 and N % x == 0:
                if verbose:
                    print(f"  Found factor {x} at distance {delta} from √{N} ≈ {sqrt_N}")
                return x, N // x
    
    return N, 1

def demo_fermat():
    """Demo Fermat factoring."""
    print("\n" + "="*70)
    print("FERMAT'S DIFFERENCE OF SQUARES FACTORING")
    print("Verified: fermat_factoring_odd, fermat_identity")
    print("="*70)
    
    test_cases = [
        (15, "3 × 5"),
        (91, "7 × 13"),
        (1073, "29 × 37"),
        (10403, "101 × 103"),
        (1000009, "293 × 3413"),
    ]
    
    for N, expected in test_cases:
        start = time.time()
        p, q = fermat_factor(N)
        elapsed = time.time() - start
        print(f"\n  N = {N} ({expected})")
        print(f"  Factors: {min(p,q)} × {max(p,q)}")
        print(f"  Verification: {min(p,q)} × {max(p,q)} = {p*q} {'✓' if p*q == N else '✗'}")
        
        # Show difference of squares
        a = (p + q) // 2
        b = abs(q - p) // 2
        print(f"  a² - b² = {a}² - {b}² = {a**2} - {b**2} = {a**2 - b**2}")
        print(f"  Time: {elapsed*1000:.2f}ms")

def demo_coppersmith():
    """Demo Coppersmith small root finding."""
    print("\n" + "="*70)
    print("COPPERSMITH SMALL ROOT DETECTION")
    print("Verified: small_mod_root_zero, coppersmith_linear")
    print("="*70)
    
    # Linear: f(x) = 3x + 7 mod 21
    root = coppersmith_small_root([7, 3], 21, 10)
    print(f"\n  f(x) = 3x + 7, N = 21")
    print(f"  Small root: x₀ = {root}")
    print(f"  Verification: f({root}) = {3*root + 7} ≡ {(3*root + 7) % 21} (mod 21) {'✓' if (3*root + 7) % 21 == 0 else '✗'}")
    
    # Quadratic: f(x) = x² - 4 mod 21
    root = coppersmith_small_root([-4, 0, 1], 21, 10)
    print(f"\n  f(x) = x² - 4, N = 21")
    print(f"  Small root: x₀ = {root}")
    print(f"  Verification: f({root}) = {root**2 - 4} ≡ {(root**2 - 4) % 21} (mod 21) {'✓' if (root**2 - 4) % 21 == 0 else '✗'}")

def demo_hensel():
    """Demo Hensel lifting."""
    print("\n" + "="*70)
    print("HENSEL LIFTING FOR SQUARE ROOTS")
    print("Verified: hensel_lift_square, exists_mod_cancel")
    print("="*70)
    
    # Lift √2 mod 7: 3² = 9 ≡ 2 (mod 7)
    print(f"\n  Lifting √2 mod 7:")
    lifts = hensel_lift(3, 2, 7)
    for a, m in lifts:
        print(f"    a = {a}, a² = {a**2} ≡ {a**2 % m} (mod {m}) {'✓' if a**2 % m == 2 % m else '✗'}")
    
    # Lift √3 mod 11: 5² = 25 ≡ 3 (mod 11)
    print(f"\n  Lifting √3 mod 11:")
    lifts = hensel_lift(5, 3, 11)
    for a, m in lifts:
        print(f"    a = {a}, a² = {a**2} ≡ {a**2 % m} (mod {m}) {'✓' if a**2 % m == 3 % m else '✗'}")

def demo_energy_factor():
    """Demo energy landscape factoring."""
    print("\n" + "="*70)
    print("ENERGY LANDSCAPE GUIDED FACTORING")
    print("Verified: energy_global_min_at_divisor, sublevel_zero_card_eq_tau")
    print("="*70)
    
    test_cases = [143, 323, 1001, 10007, 100003]
    for N in test_cases:
        print(f"\n  N = {N}:")
        p, q = energy_guided_factor(N)
        print(f"  Result: {p} × {q} = {p*q} {'✓' if p*q == N else '✗'}")

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   COPPERSMITH-FERMAT-HENSEL FACTORING DEMO (v9)                    ║")
    print("║   All mathematical foundations verified in Lean 4                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_fermat()
    demo_coppersmith()
    demo_hensel()
    demo_energy_factor()
    
    print("\n" + "="*70)
    print("All demonstrations complete.")
    print("="*70)
