#!/usr/bin/env python3
"""
Hurwitz Quaternion Factoring Demo (A+7b, B1)

Demonstrates the quaternion-based factoring algorithm:
1. Find two 4-square representations of N
2. Compute the Hamilton product cross-terms
3. Extract factors via GCD
"""

import math
import random

def four_square_rep(n):
    """Find a representation n = a² + b² + c² + d²."""
    for a in range(int(math.isqrt(n)) + 1):
        for b in range(int(math.isqrt(n - a*a)) + 1):
            for c in range(int(math.isqrt(n - a*a - b*b)) + 1):
                d2 = n - a*a - b*b - c*c
                d = int(math.isqrt(d2))
                if d*d == d2:
                    return (a, b, c, d)
    return None

def all_four_square_reps(n, max_reps=20):
    """Find multiple 4-square representations of n."""
    reps = set()
    root = int(math.isqrt(n))
    for a in range(root + 1):
        for b in range(int(math.isqrt(n - a*a)) + 1):
            for c in range(int(math.isqrt(n - a*a - b*b)) + 1):
                d2 = n - a*a - b*b - c*c
                d = int(math.isqrt(d2))
                if d*d == d2:
                    reps.add(tuple(sorted([a, b, c, d], reverse=True)))
                    if len(reps) >= max_reps:
                        return list(reps)
    return list(reps)

def hamilton_product(a, b):
    """Compute the Hamilton product of two quaternions."""
    a1, a2, a3, a4 = a
    b1, b2, b3, b4 = b
    return (
        a1*b1 - a2*b2 - a3*b3 - a4*b4,
        a1*b2 + a2*b1 + a3*b4 - a4*b3,
        a1*b3 - a2*b4 + a3*b1 + a4*b2,
        a1*b4 + a2*b3 - a3*b2 + a4*b1
    )

def quaternion_norm(q):
    """Norm of a quaternion."""
    return sum(x*x for x in q)

def factor_via_quaternion(N):
    """Attempt to factor N using quaternion representations."""
    reps = all_four_square_reps(N)

    if len(reps) < 2:
        return None

    factors_found = set()

    for i in range(len(reps)):
        for j in range(i+1, len(reps)):
            # Try all sign combinations
            a = reps[i]
            for signs in [(1,1,1,1), (1,-1,1,1), (1,1,-1,1), (1,1,1,-1),
                         (-1,1,1,1), (1,-1,-1,1), (1,1,-1,-1), (1,-1,1,-1)]:
                b = tuple(s*x for s, x in zip(signs, reps[j]))

                # Compute Hamilton product
                hp = hamilton_product(a, b)

                # Try GCD of each component with N
                for component in hp:
                    g = math.gcd(abs(component), N)
                    if 1 < g < N:
                        factors_found.add(g)
                        factors_found.add(N // g)

    if factors_found:
        p = min(factors_found)
        q = N // p
        return (p, q)
    return None

def demo_quaternion_factoring():
    """Demonstrate quaternion factoring on various composites."""
    print("=" * 65)
    print("HURWITZ QUATERNION FACTORING")
    print("=" * 65)

    # Include composites NOT expressible as sum of two squares
    composites = [
        15, 21, 33, 35, 39, 51, 55, 65, 77, 85, 91, 95,
        105, 119, 143, 187, 221, 247, 299, 323, 391, 437
    ]

    successes = 0
    for N in composites:
        result = factor_via_quaternion(N)
        reps = all_four_square_reps(N)
        if result:
            p, q = result
            print(f"  N = {N:5d} = {p:3d} × {q:3d}  ({len(reps)} reps)  ✓")
            successes += 1
        else:
            print(f"  N = {N:5d}  (no factor found, {len(reps)} reps)")

    print(f"\n  Success rate: {successes}/{len(composites)} = {100*successes/len(composites):.0f}%")

def demo_euler_identity():
    """Verify the Euler four-square identity."""
    print("\n" + "=" * 65)
    print("EULER FOUR-SQUARE IDENTITY VERIFICATION")
    print("=" * 65)

    pairs = [
        ((1, 2, 3, 4), (5, 6, 7, 8)),
        ((1, 1, 1, 1), (2, 3, 0, 0)),
        ((3, 0, 0, 0), (0, 0, 2, 1)),
    ]

    for a, b in pairs:
        norm_a = quaternion_norm(a)
        norm_b = quaternion_norm(b)
        hp = hamilton_product(a, b)
        norm_hp = quaternion_norm(hp)

        print(f"\n  α = {a}, |α|² = {norm_a}")
        print(f"  β = {b}, |β|² = {norm_b}")
        print(f"  αβ = {hp}")
        print(f"  |αβ|² = {norm_hp} = {norm_a} × {norm_b} = {norm_a*norm_b} {'✓' if norm_hp == norm_a*norm_b else '✗'}")

def demo_representation_count():
    """Show how representation count r₄(n) relates to σ₁."""
    print("\n" + "=" * 65)
    print("FOUR-SQUARE REPRESENTATION COUNTS vs JACOBI FORMULA")
    print("=" * 65)

    from sympy import divisor_sigma

    print(f"\n  {'n':>4} {'r₄(n)':>8} {'8·σ₁(n)':>10} {'Match':>7} {'(odd)':>6}")
    print("  " + "-" * 40)

    for n in range(1, 21):
        reps = all_four_square_reps(n, max_reps=1000)
        # Count with signs and permutations
        r4 = 0
        root = int(math.isqrt(n))
        for a in range(-root, root+1):
            for b in range(-int(math.isqrt(n-a*a)), int(math.isqrt(n-a*a))+1):
                for c in range(-int(math.isqrt(n-a*a-b*b)), int(math.isqrt(n-a*a-b*b))+1):
                    d2 = n - a*a - b*b - c*c
                    if d2 >= 0:
                        d = int(math.isqrt(d2))
                        if d*d == d2:
                            r4 += 2 if d > 0 else 1

        s1 = int(divisor_sigma(n, 1))
        # Jacobi: r₄(n) = 8·Σ_{d|n, 4∤d} d
        s1_no4 = sum(d for d in range(1, n+1) if n % d == 0 and d % 4 != 0)
        jacobi = 8 * s1_no4
        is_odd = n % 2 == 1
        match = "✓" if r4 == jacobi else "✗"
        print(f"  {n:4d} {r4:8d} {jacobi:10d} {match:>7} {'odd' if is_odd else '':>6}")

if __name__ == "__main__":
    print("╔" + "═" * 63 + "╗")
    print("║  HURWITZ QUATERNION FACTORING — Gravitational Factoring v7  ║")
    print("╚" + "═" * 63 + "╝")

    demo_quaternion_factoring()
    demo_euler_identity()
    demo_representation_count()
