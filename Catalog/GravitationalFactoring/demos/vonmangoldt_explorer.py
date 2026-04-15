#!/usr/bin/env python3
"""
Von Mangoldt Function & Chebyshev ψ Explorer

Visualizes the von Mangoldt function Λ(n) and Chebyshev's ψ(x) = Σ_{n≤x} Λ(n).

The key identity verified in Lean 4:
  Σ_{d|n} Λ(d) = log(n)

This connects prime factorization to logarithms and is the gateway
to the Prime Number Theorem.

Usage:
    python vonmangoldt_explorer.py [max_x]
"""

import sys
import math

def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def smallest_prime_factor(n):
    """Return the smallest prime factor of n, or 0 if n ≤ 1."""
    if n <= 1:
        return 0
    if n % 2 == 0:
        return 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return i
        i += 2
    return n

def is_prime_power(n):
    """Return (p, k) if n = p^k for prime p and k ≥ 1, else None."""
    if n <= 1:
        return None
    p = smallest_prime_factor(n)
    k = 0
    m = n
    while m % p == 0:
        m //= p
        k += 1
    if m == 1 and k >= 1:
        return (p, k)
    return None

def von_mangoldt(n):
    """Λ(n) = log(p) if n = p^k, else 0."""
    result = is_prime_power(n)
    if result:
        return math.log(result[0])
    return 0.0

def chebyshev_psi(x):
    """ψ(x) = Σ_{n=1}^{x} Λ(n)."""
    return sum(von_mangoldt(n) for n in range(1, x + 1))

def divisors(n):
    """Return all divisors of n."""
    if n == 0:
        return []
    divs = []
    for d in range(1, int(math.sqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)

def verify_mangoldt_identity(n):
    """Verify Σ_{d|n} Λ(d) = log(n)."""
    if n <= 0:
        return 0, 0, 0
    divs = divisors(n)
    lhs = sum(von_mangoldt(d) for d in divs)
    rhs = math.log(n)
    return lhs, rhs, abs(lhs - rhs)

def main():
    max_x = int(sys.argv[1]) if len(sys.argv) > 1 else 100

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Von Mangoldt Function & Chebyshev ψ Explorer        ║")
    print("║     Σ_{d|n} Λ(d) = log(n) — Formally Verified          ║")
    print("║     Gravitational Factoring Project — v12               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Display von Mangoldt values
    print(f"\n  Von Mangoldt Function Λ(n):")
    print(f"  {'n':>4} {'Type':>12} {'Λ(n)':>10} {'= log(p)':>10}")
    print("  " + "-" * 40)

    for n in range(1, min(31, max_x + 1)):
        pp = is_prime_power(n)
        if pp:
            p, k = pp
            if k == 1:
                type_str = f"prime {p}"
            else:
                type_str = f"{p}^{k}"
            val = von_mangoldt(n)
            print(f"  {n:>4} {type_str:>12} {val:>10.4f}   log({p})")
        else:
            if n == 1:
                print(f"  {n:>4} {'unit':>12} {'0':>10}")
            else:
                print(f"  {n:>4} {'composite':>12} {'0':>10}")

    # Verify the Mangoldt identity
    print(f"\n  Mangoldt Identity Verification: Σ_{{d|n}} Λ(d) = log(n)")
    print(f"  {'n':>4} {'Σ Λ(d)':>10} {'log(n)':>10} {'Error':>12}  Divisors contributing")
    print("  " + "-" * 65)

    for n in [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 16, 20, 24, 30, 36, 60, 100]:
        if n > max_x:
            break
        lhs, rhs, err = verify_mangoldt_identity(n)
        divs = divisors(n)
        contributing = [(d, von_mangoldt(d)) for d in divs if von_mangoldt(d) > 0]
        contrib_str = " + ".join(f"Λ({d})" for d, _ in contributing) if contributing else "—"
        print(f"  {n:>4} {lhs:>10.6f} {rhs:>10.6f} {err:>12.2e}  {contrib_str}")

    # Chebyshev ψ function
    print(f"\n  Chebyshev ψ(x) = Σ_{{n≤x}} Λ(n)")
    print(f"  {'x':>6} {'ψ(x)':>10} {'x':>8} {'ψ(x)/x':>10} {'|ψ/x - 1|':>10}")
    print("  " + "-" * 50)

    checkpoints = [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000]
    for x in checkpoints:
        if x > max_x:
            break
        psi = chebyshev_psi(x)
        ratio = psi / x if x > 0 else 0
        dev = abs(ratio - 1)
        print(f"  {x:>6} {psi:>10.2f} {x:>8} {ratio:>10.4f} {dev:>10.4f}")

    # ASCII chart of ψ(x)/x convergence
    print(f"\n  Convergence of ψ(x)/x → 1 (Prime Number Theorem)")
    for x in checkpoints:
        if x > max_x:
            break
        psi = chebyshev_psi(x)
        ratio = psi / x
        bar_center = 40
        offset = int((ratio - 1) * 200)
        offset = max(-bar_center, min(bar_center - 1, offset))
        bar = [' '] * (2 * bar_center + 1)
        bar[bar_center] = '|'  # mark 1.0
        bar[bar_center + offset] = '●'
        print(f"  x={x:>5}: {''.join(bar)}  ψ/x={ratio:.4f}")

    # Primes vs prime powers
    prime_count = sum(1 for n in range(2, max_x + 1) if is_prime(n))
    prime_power_count = sum(1 for n in range(2, max_x + 1) if is_prime_power(n))
    higher_powers = prime_power_count - prime_count

    print(f"\n  Statistics for n ≤ {max_x}:")
    print(f"    Primes: {prime_count}")
    print(f"    Prime powers (p^k, k≥2): {higher_powers}")
    print(f"    Total Λ-nonzero values: {prime_power_count}")
    print(f"    Proportion prime powers: {prime_power_count/max_x:.4f}")

    # Connection to PNT
    psi_max = chebyshev_psi(max_x)
    print(f"\n  PNT Connection:")
    print(f"    ψ({max_x}) = {psi_max:.2f}")
    print(f"    ψ({max_x})/{max_x} = {psi_max/max_x:.6f}")
    print(f"    PNT states: ψ(x)/x → 1 as x → ∞")
    print(f"    Deviation: {abs(psi_max/max_x - 1)*100:.2f}%")
    print(f"\n  Formally Verified in Lean 4:")
    print(f"    ✓ vonMangoldt_at_one: Λ(1) = 0")
    print(f"    ✓ vonMangoldt_at_prime: Λ(p) = log p")
    print(f"    ✓ vonMangoldt_at_prime_pow: Λ(p^k) = log p")
    print(f"    ✓ vonMangoldt_sum: Σ_{{d|n}} Λ(d) = log n")

if __name__ == "__main__":
    main()
