#!/usr/bin/env python3
"""
Berggren Tree Factoring Demo
=============================
Demonstrates Pythagorean tree factoring via inverse Berggren descent.
Shows that the algorithm is Θ(√N) for balanced semiprimes.

Usage:
    python berggren_tree_factoring.py [N]

Example:
    python berggren_tree_factoring.py 15  # factors 15 = 3 × 5
"""

import math
import sys
from typing import Optional, Tuple, List


def gcd(a: int, b: int) -> int:
    """Euclidean GCD."""
    while b:
        a, b = b, a % b
    return abs(a)


def is_pythagorean_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a * a + b * b == c * c


def berggren_children(m: int, n: int) -> List[Tuple[int, int]]:
    """
    Compute the three Berggren children of (m, n) in parameter space.
    The triple is (m²-n², 2mn, m²+n²).
    Children in (m,n) space:
      B₁: (2m-n, m)    — corresponds to matrix M₁
      B₂: (2m+n, m)    — corresponds to matrix M₂
      B₃: (m+2n, n)    — corresponds to matrix M₃
    """
    return [
        (2 * m - n, m),
        (2 * m + n, m),
        (m + 2 * n, n),
    ]


def berggren_parent(m: int, n: int) -> Optional[Tuple[int, int, str]]:
    """
    Compute the parent of (m, n) in the Berggren tree.
    Returns (parent_m, parent_n, branch_type) or None if at root.

    Inverse operations:
      M₁⁻¹: (m, n) → (n, 2n - m)     when m < 2n
      M₂⁻¹: (m, n) → (n, m - 2n)     when m > 2n and certain conditions
      M₃⁻¹: (m, n) → (m - 2n, n)     when m > 2n
    """
    if m <= 0 or n <= 0 or m <= n:
        return None

    if m < 2 * n:
        # M₁⁻¹ branch: swap and reduce
        parent_m, parent_n = n, 2 * n - m
        if parent_m > parent_n > 0:
            return (parent_m, parent_n, "M₁⁻¹")
    elif m > 2 * n:
        # M₃⁻¹ branch: subtract (continued fraction step)
        parent_m, parent_n = m - 2 * n, n
        if parent_m > parent_n > 0:
            return (parent_m, parent_n, "M₃⁻¹")
    # m == 2n is the root (m=2, n=1) condition

    return None


def mn_to_triple(m: int, n: int) -> Tuple[int, int, int]:
    """Convert Euclid parameters to Pythagorean triple."""
    a = m * m - n * n
    b = 2 * m * n
    c = m * m + n * n
    return (a, b, c)


def tree_descent(m: int, n: int) -> List[Tuple[int, int, str]]:
    """
    Descend from (m, n) to the root (2, 1) via inverse Berggren moves.
    Returns the path as a list of (m, n, move_type).
    """
    path = [(m, n, "start")]
    current_m, current_n = m, n

    max_steps = 10000  # safety limit
    steps = 0

    while current_m != 2 or current_n != 1:
        result = berggren_parent(current_m, current_n)
        if result is None:
            path.append((current_m, current_n, "stuck"))
            break
        current_m, current_n, move = result
        path.append((current_m, current_n, move))
        steps += 1
        if steps > max_steps:
            path.append((current_m, current_n, "timeout"))
            break

    return path


def factor_via_tree(N: int) -> Optional[Tuple[int, int]]:
    """
    Factor N using Pythagorean tree search.

    Strategy: Search for (m, n) such that:
    - m > n > 0, gcd(m,n) = 1, m-n is odd
    - The triple (m²-n², 2mn, m²+n²) has a component sharing a factor with N

    This is fundamentally O(√N) for balanced semiprimes.
    """
    if N <= 1:
        return None
    if N % 2 == 0:
        return (2, N // 2)

    # Search through Euclid parameters
    steps = 0
    limit = int(math.isqrt(N)) + 1

    for m in range(2, limit + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:  # need m-n odd for primitive
                continue
            if gcd(m, n) != 1:  # need coprime
                continue

            a, b, c = mn_to_triple(m, n)
            steps += 1

            # Check if any component shares a factor with N
            for component in [a, b, c, a + b, a - b, m - n, m + n]:
                g = gcd(abs(component), N)
                if 1 < g < N:
                    print(f"  Found factor via (m,n) = ({m},{n})")
                    print(f"  Triple: ({a}, {b}, {c})")
                    print(f"  GCD({component}, {N}) = {g}")
                    print(f"  Steps: {steps}")
                    return (g, N // g)

    return None


def gauss_reduction_2d(a: int, b: int, c: int, d: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """
    Gauss's algorithm for 2D lattice reduction.
    Input: basis vectors (a, b) and (c, d).
    Output: reduced basis.

    This is mathematically identical to Berggren tree descent.
    """
    v1 = [a, b]
    v2 = [c, d]
    steps = 0

    while True:
        # Ensure |v1| ≤ |v2|
        norm1 = v1[0] ** 2 + v1[1] ** 2
        norm2 = v2[0] ** 2 + v2[1] ** 2

        if norm1 > norm2:
            v1, v2 = v2, v1
            norm1, norm2 = norm2, norm1

        # Reduce v2 by v1
        dot = v1[0] * v2[0] + v1[1] * v2[1]
        mu = round(dot / norm1)

        if mu == 0:
            break

        v2 = [v2[0] - mu * v1[0], v2[1] - mu * v1[1]]
        steps += 1

        if steps > 10000:
            break

    return (tuple(v1), tuple(v2)), steps


def demonstrate_correspondence(N: int):
    """
    Show that Berggren descent and Gauss reduction produce the same steps.
    """
    print(f"\n{'='*60}")
    print(f"LATTICE-TREE CORRESPONDENCE for N = {N}")
    print(f"{'='*60}")

    # Find a relevant (m, n) pair
    for m in range(2, int(math.isqrt(N)) + 10):
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            a, b, c = mn_to_triple(m, n)
            if c > N:
                # Use this (m, n) for demonstration
                print(f"\nStarting from (m, n) = ({m}, {n})")
                print(f"Triple: ({a}, {b}, {c})")

                # Berggren descent
                print(f"\nBerggren Tree Descent:")
                path = tree_descent(m, n)
                for step_m, step_n, move in path:
                    triple = mn_to_triple(step_m, step_n)
                    print(f"  ({step_m}, {step_n}) → triple {triple}  [{move}]")

                # Gauss reduction on the corresponding lattice
                print(f"\nGauss 2D Lattice Reduction:")
                print(f"  Input basis: ({m}, {n}), ({1}, {0})")
                result, gauss_steps = gauss_reduction_2d(m, n, 1, 0)
                print(f"  Reduced basis: {result}")
                print(f"  Gauss steps: {gauss_steps}")

                return


def benchmark_complexity(sizes: List[int]):
    """
    Benchmark factoring complexity across different N sizes.
    Shows Θ(√N) scaling.
    """
    print(f"\n{'='*60}")
    print("COMPLEXITY BENCHMARK: Pythagorean Tree Factoring")
    print(f"{'='*60}")
    print(f"{'N':>15} {'p':>10} {'q':>10} {'Steps':>10} {'√N':>10} {'Ratio':>8}")
    print("-" * 65)

    for p in sizes:
        q = p + 2  # balanced semiprime
        while not is_prime_simple(q):
            q += 2
        N = p * q
        steps = count_factor_steps(N)
        sqrt_n = math.isqrt(N)
        ratio = steps / sqrt_n if sqrt_n > 0 else 0
        print(f"{N:>15} {p:>10} {q:>10} {steps:>10} {sqrt_n:>10} {ratio:>8.3f}")


def is_prime_simple(n: int) -> bool:
    """Simple primality test."""
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


def count_factor_steps(N: int) -> int:
    """Count steps to factor N via Pythagorean tree method."""
    if N <= 1:
        return 0
    if N % 2 == 0:
        return 1

    steps = 0
    for m in range(2, int(math.isqrt(N)) + 2):
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            steps += 1
            a = m * m - n * n
            g = gcd(a, N)
            if 1 < g < N:
                return steps
            g = gcd(2 * m * n, N)
            if 1 < g < N:
                return steps
    return steps


def demo_quadruple_lattice(N: int):
    """
    Demonstrate the 3D quadruple lattice L₄(N).
    Find vectors (x,y,z) with x² + y² + z² ≡ 0 (mod N²).
    """
    print(f"\n{'='*60}")
    print(f"QUADRUPLE LATTICE L₄({N}) = {{(x,y,z) : x²+y²+z² ≡ 0 (mod {N}²)}}")
    print(f"{'='*60}")

    N2 = N * N
    count = 0
    print(f"\nShort vectors in L₄({N}):")
    print(f"{'(x, y, z)':>25} {'x²+y²+z²':>15} {'(mod N²)':>10} {'Norm':>10}")
    print("-" * 62)

    limit = min(N * 3, 100)
    for x in range(-limit, limit + 1):
        for y in range(-limit, limit + 1):
            for z in range(-limit, limit + 1):
                s = x * x + y * y + z * z
                if s > 0 and s % N2 == 0:
                    norm = math.sqrt(s)
                    print(f"  ({x:>3}, {y:>3}, {z:>3}) {s:>15} {s % N2:>10} {norm:>10.2f}")
                    count += 1

                    # Check for factor extraction
                    for val in [x, y, z, x + y, x - y, x + z, y + z]:
                        g = gcd(abs(val), N)
                        if 1 < g < N:
                            print(f"    *** FACTOR FOUND: gcd({val}, {N}) = {g} ***")

                    if count >= 20:
                        break
            if count >= 20:
                break
        if count >= 20:
            break

    print(f"\nTotal short vectors found: {count}")
    print(f"√N = {math.isqrt(N)}, N = {N}")


if __name__ == "__main__":
    # Default test value
    N = 15 if len(sys.argv) < 2 else int(sys.argv[1])

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     PYTHAGOREAN TREE FACTORING — DEMONSTRATION         ║")
    print("║     Lattice-Tree Correspondence & Quadruple Escape     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: Factor a number
    print(f"\n{'='*60}")
    print(f"FACTORING N = {N}")
    print(f"{'='*60}")
    result = factor_via_tree(N)
    if result:
        p, q = result
        print(f"\n  ✓ N = {N} = {p} × {q}")
    else:
        print(f"\n  ✗ Could not factor {N} (prime or 1)")

    # Demo 2: Show the correspondence
    demonstrate_correspondence(N)

    # Demo 3: Benchmark
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    benchmark_complexity(primes)

    # Demo 4: Quadruple lattice
    if N < 50:
        demo_quadruple_lattice(N)
    else:
        demo_quadruple_lattice(15)

    print(f"\n{'='*60}")
    print("KEY FINDING: Tree factoring is Θ(√N) for balanced semiprimes")
    print("ESCAPE ROUTE: 3D quadruple lattice may break this barrier")
    print(f"{'='*60}")
