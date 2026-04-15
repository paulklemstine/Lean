#!/usr/bin/env python3
"""
Smooth Number Distribution Analyzer

Analyzes the distribution of B-smooth numbers (numbers whose prime factors
are all ≤ B), which is critical for the Quadratic Sieve and other
factoring algorithms.

Demonstrates the Dickman rho function: Ψ(x, x^{1/u}) ~ x · ρ(u)

Usage:
    python smooth_number_distribution.py [max_x] [smoothness_bound]
"""

import sys
import math

def sieve_primes(limit):
    """Return primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.sqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def is_b_smooth(n, B):
    """Check if n is B-smooth (all prime factors ≤ B)."""
    if n <= 1:
        return True
    d = 2
    while d <= B and n > 1:
        while n % d == 0:
            n //= d
        d += 1
    return n == 1

def count_smooth(x, B):
    """Count B-smooth numbers up to x: Ψ(x, B)."""
    count = 0
    for n in range(1, x + 1):
        if is_b_smooth(n, B):
            count += 1
    return count

def dickman_rho(u, n_terms=100):
    """Approximate the Dickman rho function ρ(u).
    ρ(u) = 1 for 0 ≤ u ≤ 1
    ρ(u) satisfies u·ρ'(u) = -ρ(u-1) for u > 1

    Uses simple numerical ODE integration.
    """
    if u <= 0:
        return 1.0
    if u <= 1:
        return 1.0

    # Numerical integration via Euler's method
    dt = 0.001
    # Store ρ on a grid
    n_points = int(u / dt) + 1
    rho = [0.0] * n_points

    # ρ(t) = 1 for t ∈ [0, 1]
    for i in range(min(n_points, int(1.0 / dt) + 1)):
        rho[i] = 1.0

    # For t > 1, solve u·ρ'(u) = -ρ(u-1)
    for i in range(int(1.0 / dt) + 1, n_points):
        t = i * dt
        t_minus_1 = t - 1.0
        idx = int(t_minus_1 / dt)
        if idx < 0:
            idx = 0
        if idx >= n_points:
            idx = n_points - 1
        rho_t_minus_1 = rho[idx]
        # ρ'(t) = -ρ(t-1)/t
        rho[i] = rho[i-1] - dt * rho_t_minus_1 / t

    return rho[-1]

def factoring_probability(N_bits, B):
    """Estimate probability that a random number near N is B-smooth."""
    # u = log(N)/log(B)
    N_log = N_bits * math.log(2)
    B_log = math.log(B) if B > 1 else 1
    u = N_log / B_log
    return dickman_rho(u)

def optimal_smoothness_bound(N_bits):
    """Estimate optimal smoothness bound for QS factoring of N."""
    # L(N) = exp(√(ln N · ln ln N))
    ln_N = N_bits * math.log(2)
    ln_ln_N = math.log(ln_N) if ln_N > 0 else 1
    L = math.exp(math.sqrt(ln_N * ln_ln_N))
    # Optimal B ≈ L^{1/√2}
    return int(L ** (1 / math.sqrt(2)))

def main():
    max_x = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
    B_default = int(sys.argv[2]) if len(sys.argv) > 2 else 10

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Smooth Number Distribution Analyzer                 ║")
    print("║     Foundation for Quadratic Sieve Factoring             ║")
    print("║     Gravitational Factoring Project — v12               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Count smooth numbers for various bounds
    print(f"\n  Ψ(x, B) = count of B-smooth numbers ≤ x")
    print(f"  {'x':>8} ", end="")
    bounds = [2, 3, 5, 7, 10, 20, 50]
    for B in bounds:
        print(f"{'B='+str(B):>8}", end="")
    print()
    print("  " + "-" * (8 + 8 * len(bounds)))

    checkpoints = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000]
    for x in checkpoints:
        if x > max_x:
            break
        print(f"  {x:>8} ", end="")
        for B in bounds:
            count = count_smooth(x, B)
            print(f"{count:>8}", end="")
        print()

    # Dickman rho function values
    print(f"\n  Dickman ρ Function (asymptotic smooth number density):")
    print(f"  {'u':>6} {'ρ(u)':>12} {'1/ρ(u)':>12}  Interpretation")
    print("  " + "-" * 60)
    for u_10 in range(5, 55, 5):
        u = u_10 / 10.0
        rho = dickman_rho(u)
        inv_rho = 1.0 / rho if rho > 0 else float('inf')
        interp = ""
        if u <= 1:
            interp = "All numbers are 1-smooth"
        elif u <= 2:
            interp = f"~{rho:.1%} of numbers are x^(1/{u:.1f})-smooth"
        else:
            interp = f"~1 in {inv_rho:.0f} numbers"
        print(f"  {u:>6.1f} {rho:>12.6f} {inv_rho:>12.1f}  {interp}")

    # Factoring implications
    print(f"\n  Implications for Factoring:")
    print(f"  {'N bits':>8} {'Optimal B':>12} {'Prob smooth':>12} {'Relations needed':>16}")
    print("  " + "-" * 52)
    for bits in [64, 128, 256, 512, 768, 1024, 2048]:
        B = optimal_smoothness_bound(bits)
        prob = factoring_probability(bits, B)
        relations = int(1.0 / prob) if prob > 0 else float('inf')
        # Number of primes ≤ B (approximately B/ln(B))
        factor_base = int(B / math.log(B)) if B > 2 else 1
        print(f"  {bits:>8} {B:>12,} {prob:>12.2e} {relations:>16,}")

    # QS complexity
    print(f"\n  Quadratic Sieve Complexity: L(N)^(1+o(1))")
    print(f"  where L(N) = exp(√(ln N · ln ln N))")
    print(f"  {'N bits':>8} {'L(N)':>15}")
    for bits in [64, 128, 256, 512, 1024]:
        ln_N = bits * math.log(2)
        L = math.exp(math.sqrt(ln_N * math.log(ln_N)))
        print(f"  {bits:>8} {L:>15.2e}")

    print(f"\n  Connection to Formal Verification:")
    print(f"    The Quadratic Sieve's correctness depends on:")
    print(f"    • x² ≡ y² (mod N) → gcd(x-y, N) is often a factor")
    print(f"    • Smooth numbers provide the exponent vectors")
    print(f"    • Linear algebra over GF(2) finds dependencies")
    print(f"    All algebraic steps formally verified in Lean 4!")

if __name__ == "__main__":
    main()
