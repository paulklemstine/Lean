#!/usr/bin/env python3
"""
Perfect Numbers and Mersenne Primes Demo

Explores perfect numbers, their connection to Mersenne primes via the
Euclid-Euler theorem, and the open question of odd perfect numbers.
"""

from sympy import isprime, divisors, factorint


def divisor_sum(n):
    """Compute σ(n) = sum of all positive divisors of n."""
    return sum(divisors(n))


def find_perfect_numbers(limit=10000):
    """Find all perfect numbers below limit."""
    print(f"=== Perfect Numbers below {limit} ===")
    perfect = []

    for n in range(2, limit + 1):
        if divisor_sum(n) == 2 * n:
            perfect.append(n)
            divs = divisors(n)
            print(f"  {n} is perfect: divisors = {divs}, sum = {sum(divs)} = 2×{n}")

    print(f"\n  Found {len(perfect)} perfect numbers: {perfect}")
    print()


def mersenne_euclid_connection(limit=20):
    """Show the connection between Mersenne primes and perfect numbers."""
    print(f"=== Mersenne-Euclid Connection ===")
    print(f"{'p':>4} {'2^p-1':>10} {'Prime?':>7} {'2^(p-1)×(2^p-1)':>20} {'Perfect?':>9}")
    print("-" * 55)

    for p in range(2, limit + 1):
        if not isprime(p):
            continue
        mersenne = 2**p - 1
        is_mersenne_prime = isprime(mersenne)
        perfect_candidate = 2**(p-1) * mersenne
        is_perfect = divisor_sum(perfect_candidate) == 2 * perfect_candidate

        print(f"{p:>4} {mersenne:>10} {'Yes ✓' if is_mersenne_prime else 'No':>7} "
              f"{perfect_candidate:>20} {'Yes ✓' if is_perfect else 'No':>9}")

    print()
    print("  Euclid's theorem: If 2^p - 1 is prime, then 2^(p-1)(2^p - 1) is perfect.")
    print("  Euler's theorem: Every EVEN perfect number has this form.")
    print("  Open: Do ODD perfect numbers exist? (None found below 10^2200)")
    print()


def abundancy_analysis(limit=100):
    """Classify numbers as deficient, perfect, or abundant."""
    print(f"=== Abundancy Classification (n ≤ {limit}) ===")

    deficient = []
    perfect = []
    abundant = []

    for n in range(2, limit + 1):
        s = divisor_sum(n)
        if s < 2 * n:
            deficient.append(n)
        elif s == 2 * n:
            perfect.append(n)
        else:
            abundant.append(n)

    print(f"  Deficient: {len(deficient)} numbers (σ(n) < 2n)")
    print(f"  Perfect:   {len(perfect)} numbers (σ(n) = 2n) → {perfect}")
    print(f"  Abundant:  {len(abundant)} numbers (σ(n) > 2n)")
    print(f"  First abundant: {abundant[:10]}")
    print()

    # Abundancy ratios
    print("  Abundancy ratios σ(n)/n for perfect and near-perfect:")
    for n in sorted(perfect + abundant[:5]):
        ratio = divisor_sum(n) / n
        print(f"    σ({n})/{n} = {divisor_sum(n)}/{n} = {ratio:.4f}")
    print()


def mersenne_prime_search(limit=30):
    """Search for Mersenne primes."""
    print(f"=== Mersenne Prime Search (exponents ≤ {limit}) ===")
    mersenne_primes = []

    for p in range(2, limit + 1):
        if not isprime(p):
            continue
        m = 2**p - 1
        if isprime(m):
            mersenne_primes.append((p, m))
            print(f"  M_{p} = 2^{p} - 1 = {m} is PRIME ✓")
        else:
            factors = factorint(m)
            factor_str = " × ".join(f"{b}^{e}" if e > 1 else str(b) for b, e in factors.items())
            print(f"  M_{p} = 2^{p} - 1 = {m} = {factor_str}")

    print(f"\n  Mersenne primes found: M_p for p ∈ {[p for p, _ in mersenne_primes]}")
    print()


def sigma_multiplicativity():
    """Demonstrate multiplicativity of σ for perfect number proof."""
    print("=== Multiplicativity of σ ===")
    print()
    print("σ is multiplicative: σ(ab) = σ(a)σ(b) when gcd(a,b) = 1")
    print()

    test_cases = [(2, 3), (4, 7), (8, 31), (16, 31), (64, 127)]
    for a, b in test_cases:
        from math import gcd
        if gcd(a, b) == 1:
            sa = divisor_sum(a)
            sb = divisor_sum(b)
            sab = divisor_sum(a * b)
            ok = "✓" if sa * sb == sab else "✗"
            print(f"  σ({a})×σ({b}) = {sa}×{sb} = {sa*sb}  vs  σ({a*b}) = {sab}  {ok}")

    print()
    print("This is key to proving Euclid's direction:")
    print("  σ(2^(p-1) × (2^p-1)) = σ(2^(p-1)) × σ(2^p-1)")
    print("                       = (2^p - 1) × 2^p")
    print("                       = 2 × 2^(p-1) × (2^p - 1)")
    print()


if __name__ == "__main__":
    find_perfect_numbers(10000)
    mersenne_euclid_connection()
    abundancy_analysis()
    mersenne_prime_search()
    sigma_multiplicativity()
