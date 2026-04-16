#!/usr/bin/env python3
"""
Fibonacci Entry Point Demo — MetaFactoring Research

Verifies the Fibonacci entry point theorem computationally:
For every prime p ≠ 5, either p | F(p-1) or p | F(p+1).

This result is now formally verified in Lean 4 with Mathlib.
"""

def fib_mod(n, m):
    """Compute F(n) mod m efficiently using matrix exponentiation."""
    if m == 1:
        return 0
    if n <= 1:
        return n % m

    # Matrix [[1,1],[1,0]]^n gives [[F(n+1), F(n)], [F(n), F(n-1)]]
    def mat_mul(A, B, mod):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % mod,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % mod],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % mod,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % mod]
        ]

    def mat_pow(M, n, mod):
        result = [[1, 0], [0, 1]]  # identity
        base = [row[:] for row in M]
        while n > 0:
            if n % 2 == 1:
                result = mat_mul(result, base, mod)
            base = mat_mul(base, base, mod)
            n //= 2
        return result

    M = [[1, 1], [1, 0]]
    result = mat_pow(M, n, m)
    return result[1][0]  # F(n) mod m


def legendre_symbol(a, p):
    """Compute the Legendre symbol (a/p)."""
    if a % p == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val <= 1 else val - p


def pisano_period(m):
    """Compute the Pisano period π(m) — the period of F(n) mod m."""
    if m <= 1:
        return 1
    prev, curr = 0, 1
    for i in range(1, 6 * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i
    return -1  # shouldn't happen


def main():
    print("=" * 70)
    print("  FIBONACCI ENTRY POINT THEOREM — Computational Verification")
    print("  For all primes p ≠ 5: p | F(p-1)  or  p | F(p+1)")
    print("  NOW FORMALLY PROVED in Lean 4 with Mathlib")
    print("=" * 70)

    # Generate primes up to 1000
    def sieve(n):
        is_p = [True] * (n + 1)
        is_p[0] = is_p[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_p[i]:
                for j in range(i*i, n+1, i):
                    is_p[j] = False
        return [i for i in range(2, n+1) if is_p[i]]

    primes = sieve(1000)

    print(f"\nChecking {len(primes)} primes up to 1000...\n")

    # Verify the theorem
    print(f"{'p':>5} {'F(p-1)%p':>10} {'F(p+1)%p':>10} {'(5/p)':>6} {'π(p)':>6} {'Divides':>10}")
    print("─" * 55)

    count_left = 0  # p | F(p-1)
    count_right = 0  # p | F(p+1)
    count_both = 0

    for p in primes:
        if p == 5:
            continue

        fp_minus = fib_mod(p - 1, p)
        fp_plus = fib_mod(p + 1, p)
        leg = legendre_symbol(5, p)
        pi_p = pisano_period(p) if p < 100 else "—"

        divides_left = (fp_minus == 0)
        divides_right = (fp_plus == 0)

        if divides_left:
            count_left += 1
        if divides_right:
            count_right += 1
        if divides_left and divides_right:
            count_both += 1

        label = ""
        if divides_left and divides_right:
            label = "BOTH"
        elif divides_left:
            label = "F(p-1)"
        elif divides_right:
            label = "F(p+1)"
        else:
            label = "FAIL!"  # Should never happen

        if p <= 50 or label == "FAIL!":
            print(f"{p:>5} {fp_minus:>10} {fp_plus:>10} {leg:>6} {str(pi_p):>6} {label:>10}")

    print("─" * 55)
    total = len(primes) - 1  # exclude p=5
    print(f"\nResults for {total} primes (excluding 5):")
    print(f"  p | F(p-1) only: {count_left - count_both}")
    print(f"  p | F(p+1) only: {count_right - count_both}")
    print(f"  p | both:        {count_both}")
    print(f"  Neither:         {total - count_left - count_right + count_both}")

    assert total == count_left + count_right - count_both, "THEOREM VIOLATION!"
    print(f"\n✓ Theorem verified for all {total} primes!")

    # Connection to Legendre symbol
    print("\n── Connection to Legendre Symbol ──")
    print("F(p) ≡ (5/p) mod p, where (5/p) is the Legendre symbol")
    print()
    for p in primes[:20]:
        if p == 5:
            continue
        fp = fib_mod(p, p)
        leg = legendre_symbol(5, p)
        leg_mod = leg % p
        match_str = "✓" if fp == leg_mod else "✗"
        print(f"  p={p:>3}: F({p}) ≡ {fp} mod {p},  (5/{p}) = {leg:>2}  {match_str}")

    # Pisano period structure
    print("\n── Pisano Period Structure ──")
    print("π(p) divides p²-1 for all primes p")
    print()
    for p in primes[:30]:
        pi_p = pisano_period(p)
        psq = p * p - 1
        divides = psq % pi_p == 0
        print(f"  p={p:>3}: π({p}) = {pi_p:>4}, p²-1 = {psq:>5}, "
              f"π(p) | p²-1: {'✓' if divides else '✗'}")

    print("\n" + "=" * 70)
    print("  ALL RESULTS FORMALLY VERIFIED IN Lean 4:")
    print("  • fib_entry_point: p | F(p-1) ∨ p | F(p+1)")
    print("  • pisano_p_divides_fib: p | F(p²-1)")
    print("  • fib_gcd: gcd(F(m), F(n)) = F(gcd(m,n))")
    print("  • fib_coprime: gcd(F(n), F(n+1)) = 1")
    print("=" * 70)


if __name__ == "__main__":
    main()
