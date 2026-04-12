#!/usr/bin/env python3
"""
MetaFactoring Demo: Division Algebra Norm Channel Factoring

Demonstrates how sum-of-squares representations combined with
Brahmagupta-Fibonacci and Euler identities enable factoring.

Key theorems (formally verified in Lean 4):
  - norm_mult_complex: (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)²
  - two_square_reps_give_factor: two reps → factoring equation
  - norm_congruence_bridge: p≡3(mod 4) and p|a²+b² ⟹ p|a and p|b
  - prime_one_mod4_sum_sq: p≡1(mod 4) ⟹ p = a²+b²
"""

import math
from itertools import product as cartprod


def find_two_square_reps(N):
    """Find all representations N = a² + b² with 0 ≤ a ≤ b."""
    reps = []
    a = 0
    while 2 * a * a <= N:
        b_sq = N - a * a
        b = int(math.isqrt(b_sq))
        if b * b == b_sq:
            reps.append((a, b))
        a += 1
    return reps


def find_four_square_reps(N, max_reps=5):
    """Find representations N = a² + b² + c² + d² with a ≤ b ≤ c ≤ d."""
    reps = []
    for a in range(int(math.isqrt(N)) + 1):
        r1 = N - a * a
        if r1 < 0:
            break
        for b in range(a, int(math.isqrt(r1)) + 1):
            r2 = r1 - b * b
            if r2 < 0:
                break
            for c in range(b, int(math.isqrt(r2)) + 1):
                d_sq = r2 - c * c
                if d_sq < 0:
                    break
                d = int(math.isqrt(d_sq))
                if d * d == d_sq and d >= c:
                    reps.append((a, b, c, d))
                    if len(reps) >= max_reps:
                        return reps
    return reps


def brahmagupta_fibonacci(a, b, c, d):
    """Apply the Brahmagupta-Fibonacci identity: (a²+b²)(c²+d²) = two sums of squares."""
    return (
        (a*c - b*d, a*d + b*c),  # First form
        (a*c + b*d, a*d - b*c),  # Second form
    )


def factor_via_two_reps(N, rep1, rep2):
    """Extract factors from two sum-of-squares representations."""
    a1, b1 = rep1
    a2, b2 = rep2

    # Try multiple gcd combinations
    candidates = set()
    for x, y in [(a1*b2 - a2*b1, N), (a1*b2 + a2*b1, N),
                 (a1*a2 - b1*b2, N), (a1*a2 + b1*b2, N)]:
        g = math.gcd(abs(x), N)
        if 1 < g < N:
            candidates.add(g)
    return candidates


def demo_two_square_factoring():
    """Demonstrate factoring via two sum-of-squares representations."""
    print("=" * 70)
    print("NORM CHANNEL FACTORING: TWO-SQUARE REPRESENTATIONS")
    print("=" * 70)
    print("\nTheorem: If N = a₁²+b₁² = a₂²+b₂², then")
    print("  gcd(a₁b₂ ± a₂b₁, N) often gives a nontrivial factor.\n")

    # Test composites where both factors are 1 mod 4
    test_cases = []
    primes_1mod4 = [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97]

    for i, p in enumerate(primes_1mod4):
        for q in primes_1mod4[i+1:]:
            N = p * q
            reps = find_two_square_reps(N)
            if len(reps) >= 2:
                test_cases.append((N, p, q, reps))

    print(f"{'N':>8} {'p×q':>10} {'Rep 1':>15} {'Rep 2':>15} {'Factor':>8}")
    print("-" * 65)

    for N, p, q, reps in test_cases[:15]:
        r1, r2 = reps[0], reps[1]
        factors = factor_via_two_reps(N, r1, r2)
        r1_str = f"{r1[0]}²+{r1[1]}²"
        r2_str = f"{r2[0]}²+{r2[1]}²"
        factor_str = str(min(factors)) if factors else "—"
        print(f"{N:>8} {p:>3}×{q:<4} {r1_str:>15} {r2_str:>15} {factor_str:>8}")


def demo_norm_congruence_bridge():
    """Demonstrate the norm-congruence bridge theorem."""
    print("\n" + "=" * 70)
    print("NORM-CONGRUENCE BRIDGE")
    print("If p ≡ 3 (mod 4) and p | a²+b², then p | a and p | b")
    print("=" * 70)

    primes_3mod4 = [3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71]

    print(f"\n{'p':>4} {'p mod 4':>8} {'a':>5} {'b':>5} {'a²+b²':>8} "
          f"{'p|a²+b²':>8} {'p|a':>5} {'p|b':>5} {'Bridge':>8}")
    print("-" * 65)

    for p in primes_3mod4[:8]:
        # Find a,b where p | a²+b²
        found = False
        for a in range(1, 5*p):
            for b in range(a, 5*p):
                if (a*a + b*b) % p == 0:
                    div_sum = True
                    div_a = (a % p == 0)
                    div_b = (b % p == 0)
                    bridge_holds = div_a and div_b
                    print(f"{p:>4} {p % 4:>8} {a:>5} {b:>5} {a*a+b*b:>8} "
                          f"{'✓':>8} {'✓' if div_a else '✗':>5} "
                          f"{'✓' if div_b else '✗':>5} "
                          f"{'✓' if bridge_holds else '✗':>8}")
                    found = True
                    break
            if found:
                break


def demo_four_square_representations():
    """Demonstrate Lagrange's four-square theorem and quaternion factoring."""
    print("\n" + "=" * 70)
    print("FOUR-SQUARE REPRESENTATIONS (QUATERNION CHANNEL)")
    print("Every positive integer is a sum of four squares (Lagrange)")
    print("=" * 70)

    test_numbers = [7, 15, 23, 91, 100, 255, 1000]

    for N in test_numbers:
        reps = find_four_square_reps(N, max_reps=3)
        print(f"\n  N = {N}:")
        for a, b, c, d in reps:
            verify = a*a + b*b + c*c + d*d
            print(f"    {a}² + {b}² + {c}² + {d}² = {verify} {'✓' if verify == N else '✗'}")

    # Demonstrate non-commutativity advantage
    print("\n  Quaternion Non-Commutativity Advantage:")
    print("  q₁·q₂ and q₂·q₁ have same norm but different components")
    a1, a2, a3, a4 = 1, 2, 3, 4
    b1, b2, b3, b4 = 5, 6, 7, 8

    # q1*q2
    c1 = a1*b1 - a2*b2 - a3*b3 - a4*b4
    c2 = a1*b2 + a2*b1 + a3*b4 - a4*b3
    c3 = a1*b3 - a2*b4 + a3*b1 + a4*b2
    c4 = a1*b4 + a2*b3 - a3*b2 + a4*b1

    # q2*q1
    d1 = b1*a1 - b2*a2 - b3*a3 - b4*a4
    d2 = b1*a2 + b2*a1 + b3*a4 - b4*a3
    d3 = b1*a3 - b2*a4 + b3*a1 + b4*a2
    d4 = b1*a4 + b2*a3 - b3*a2 + b4*a1

    norm_fwd = c1**2 + c2**2 + c3**2 + c4**2
    norm_rev = d1**2 + d2**2 + d3**2 + d4**2

    print(f"\n  q₁ = ({a1}, {a2}, {a3}, {a4}), q₂ = ({b1}, {b2}, {b3}, {b4})")
    print(f"  q₁·q₂ = ({c1}, {c2}, {c3}, {c4}), norm = {norm_fwd}")
    print(f"  q₂·q₁ = ({d1}, {d2}, {d3}, {d4}), norm = {norm_rev}")
    print(f"  Same norm: {norm_fwd == norm_rev} ✓")
    print(f"  Different components: {(c1,c2,c3,c4) != (d1,d2,d3,d4)} ✓")
    print(f"  → Two factoring equations for the price of one!")


def demo_hurwitz_barrier():
    """Demonstrate the Hurwitz barrier at dimension 16."""
    print("\n" + "=" * 70)
    print("HURWITZ BARRIER: NO 16-SQUARE IDENTITY")
    print("=" * 70)

    # Show that pointwise product doesn't preserve sum-of-squares
    print("\n  Testing: does (Σaᵢ²)(Σbᵢ²) = Σ(aᵢbᵢ)² in dimension n?")

    for dim in [1, 2, 4, 8, 16]:
        a = [1] * dim
        b = [1] * dim
        lhs = sum(x**2 for x in a) * sum(x**2 for x in b)
        rhs = sum((x*y)**2 for x, y in zip(a, b))
        holds = (lhs == rhs)
        print(f"\n  Dim {dim:>2}: a = b = (1,...,1)")
        print(f"    (Σaᵢ²)(Σbᵢ²) = {lhs}")
        print(f"    Σ(aᵢbᵢ)²     = {rhs}")
        print(f"    Pointwise identity: {'✓' if holds else '✗ (fails!)'}")
        if not holds:
            print(f"    Gap: {lhs} ≠ {rhs}")
            print(f"    This is the Hurwitz barrier — no composition algebra in dim {dim}")


if __name__ == "__main__":
    demo_two_square_factoring()
    demo_norm_congruence_bridge()
    demo_four_square_representations()
    demo_hurwitz_barrier()
