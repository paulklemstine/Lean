#!/usr/bin/env python3
"""
Langlands for Toddlers: Shape-Color Dictionary Demo

Demonstrates the GL₁ Langlands correspondence by computing Jacobi symbols
(Kronecker symbols) for fundamental discriminants and showing how they
encode splitting behavior in quadratic number fields.
"""

from typing import Dict, List, Tuple


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for positive odd n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be positive and odd, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """Compute the Kronecker symbol (d/n), extending Jacobi to even n."""
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    if n == -1:
        return -1 if d < 0 else 1
    if n == 2:
        if d % 2 == 0:
            return 0
        if d % 8 in (1, 7):
            return 1
        return -1

    # Factor out powers of 2
    result = 1
    while n % 2 == 0:
        result *= kronecker_symbol(d, 2)
        n //= 2
    if n == 1:
        return result

    # Use Jacobi for odd part
    if n < 0:
        n = -n
        if d < 0:
            result = -result
    return result * jacobi_symbol(d, n)


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree."""
    n = abs(n)
    if n == 0:
        return False
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


def is_fundamental_discriminant(d: int) -> bool:
    """Check if d is a fundamental discriminant."""
    if d == 0:
        return False
    if d % 4 == 1:
        return is_squarefree(d)
    if d % 4 == 0:
        m = d // 4
        return is_squarefree(m) and m % 4 != 1 and m != 0
    return False


def fundamental_discriminant(d: int) -> int:
    """Compute the fundamental discriminant of Q(√d) for squarefree d."""
    if not is_squarefree(d) or d == 0:
        raise ValueError(f"d must be nonzero and squarefree, got {d}")
    if d % 4 == 1:
        return d
    return 4 * d


def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, limit + 1, i):
                sieve[j] = False
    return [i for i in range(2, limit + 1) if sieve[i]]


def shape_color_table(discriminants: List[int], prime_limit: int = 30) -> None:
    """Print the shape-color dictionary for given discriminants."""
    primes = sieve_primes(prime_limit)

    print("=" * 70)
    print("SHAPE-COLOR DICTIONARY: Jacobi Symbol J(D, p)")
    print("=" * 70)
    print(f"{'D':>6} | {'Field':>12} | " + " ".join(f"{p:>3}" for p in primes))
    print("-" * 70)

    for d in discriminants:
        # Determine the field
        if d % 4 == 0:
            m = d // 4
            field = f"Q(√{m})"
        else:
            field = f"Q(√{d})"

        values = [kronecker_symbol(d, p) for p in primes]
        val_str = " ".join(f"{v:>3}" for v in values)
        print(f"{d:>6} | {field:>12} | {val_str}")

    print("=" * 70)
    print("Legend: +1 = split, -1 = inert, 0 = ramified")
    print()


def verify_injectivity(discriminants: List[int], prime_limit: int = 100) -> None:
    """Verify that distinct discriminants produce distinct character patterns."""
    primes = sieve_primes(prime_limit)

    print("INJECTIVITY VERIFICATION")
    print("=" * 50)

    for i in range(len(discriminants)):
        for j in range(i + 1, len(discriminants)):
            d1, d2 = discriminants[i], discriminants[j]
            diff_primes = []
            for p in primes:
                if kronecker_symbol(d1, p) != kronecker_symbol(d2, p):
                    diff_primes.append(p)
            if diff_primes:
                print(f"D={d1:>4} vs D={d2:>4}: differ at primes {diff_primes[:5]}...")
            else:
                print(f"D={d1:>4} vs D={d2:>4}: IDENTICAL (BUG?)")

    print()


def gauss_sum_verification(prime_limit: int = 50) -> None:
    """Verify g(χ)² = χ(-1)·p for quadratic characters mod p."""
    import cmath

    primes = [p for p in sieve_primes(prime_limit) if p > 2]

    print("GAUSS SUM BRIDGE: g(χ)² vs χ(-1)·p")
    print("=" * 60)
    print(f"{'p':>5} | {'g(χ)²':>20} | {'χ(-1)·p':>10} | {'Match':>5}")
    print("-" * 60)

    for p in primes:
        # Compute Gauss sum g(χ) = Σ (a/p) · e^{2πia/p}
        gauss = sum(
            jacobi_symbol(a, p) * cmath.exp(2j * cmath.pi * a / p)
            for a in range(1, p)
        )
        g_sq = gauss ** 2
        chi_neg1 = jacobi_symbol(-1, p)
        expected = chi_neg1 * p

        match = abs(g_sq - expected) < 1e-8
        print(f"{p:>5} | {g_sq.real:>10.4f}+{g_sq.imag:>7.4f}i | {expected:>10} | {'✓' if match else '✗':>5}")

    print()


def character_orthogonality_test(prime_limit: int = 30) -> None:
    """Verify Σ χ(a) = 0 for quadratic characters mod p."""
    primes = [p for p in sieve_primes(prime_limit) if p > 2]

    print("CHARACTER ORTHOGONALITY: Σ_{a=0}^{p-1} (a/p)")
    print("=" * 40)

    for p in primes:
        total = sum(jacobi_symbol(a, p) for a in range(p))
        status = "✓" if total == 0 else "✗"
        print(f"  p = {p:>3}: Σ = {total:>3}  {status}")

    print()


def reciprocity_test(prime_limit: int = 30) -> None:
    """Verify quadratic reciprocity: (p/q)(q/p) = (-1)^((p-1)/2 · (q-1)/2)."""
    primes = [p for p in sieve_primes(prime_limit) if p > 2]

    print("QUADRATIC RECIPROCITY (SELF-DUALITY)")
    print("=" * 60)

    violations = 0
    checks = 0
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            lhs = jacobi_symbol(p, q) * jacobi_symbol(q, p)
            rhs = (-1) ** ((p - 1) // 2 * (q - 1) // 2)
            checks += 1
            if lhs != rhs:
                violations += 1
                print(f"  VIOLATION: p={p}, q={q}: LHS={lhs}, RHS={rhs}")

    print(f"  Checked {checks} pairs, {violations} violations")
    if violations == 0:
        print("  ✓ All pairs satisfy quadratic reciprocity!")
    print()


def fundamental_discriminant_census(limit: int = 100) -> None:
    """Census of fundamental discriminants up to |D| ≤ limit."""
    fund_discs = [d for d in range(-limit, limit + 1) if is_fundamental_discriminant(d)]
    positive = [d for d in fund_discs if d > 0]
    negative = [d for d in fund_discs if d < 0]

    print(f"FUNDAMENTAL DISCRIMINANT CENSUS (|D| ≤ {limit})")
    print("=" * 50)
    print(f"  Total: {len(fund_discs)}")
    print(f"  Positive: {len(positive)}  {positive[:15]}...")
    print(f"  Negative: {len(negative)}  {negative[:15]}...")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  LANGLANDS FOR TODDLERS: THE GL₁ SHAPE-COLOR DICTIONARY")
    print("=" * 70 + "\n")

    # Key discriminants
    discriminants = [-4, -3, 5, 8, -7, 12, -8, 13, 17, -11]

    # 1. Shape-Color Table
    shape_color_table(discriminants)

    # 2. Injectivity Verification
    verify_injectivity(discriminants)

    # 3. Gauss Sum Bridge
    gauss_sum_verification()

    # 4. Character Orthogonality
    character_orthogonality_test()

    # 5. Quadratic Reciprocity
    reciprocity_test()

    # 6. Census
    fundamental_discriminant_census()
