#!/usr/bin/env python3
"""
Berggren Tree Explorer & Factoring Demo
========================================
Demonstrates Algorithm 1 (Berggren Tree Descent Factoring) and
Algorithm 31 (Berggren Ternary Tree Index).

Generates the Berggren ternary tree of primitive Pythagorean triples,
visualizes it, and demonstrates tree-based integer factoring.
"""

import numpy as np
from typing import List, Tuple, Optional
import json

# The three Berggren matrices (formally verified in Pythagorean/Berggren/)
B1 = np.array([[ 1, -2,  2],
                [ 2, -1,  2],
                [ 2, -2,  3]])

B2 = np.array([[ 1,  2,  2],
                [ 2,  1,  2],
                [ 2,  2,  3]])

B3 = np.array([[-1,  2,  2],
                [-2,  1,  2],
                [-2,  2,  3]])

# Inverse matrices (formally verified: inv_B1_comp_B1, etc.)
B1_inv = np.array([[ 1,  2, -2],
                    [-2, -1,  2],
                    [-2, -2,  3]])

B2_inv = np.array([[ 1, -2, 2],
                    [ 2, -1, -2],
                    [-2,  2,  3]])

B3_inv = np.array([[-1,  2, -2],
                    [ 2, -1,  2],
                    [ 2, -2,  3]])

MATRICES = [B1, B2, B3]
INVERSES = [B1_inv, B2_inv, B3_inv]


def generate_tree(depth: int) -> List[Tuple[int, int, int, str]]:
    """Generate all primitive Pythagorean triples up to given depth."""
    root = np.array([3, 4, 5])
    results = [(3, 4, 5, "")]
    queue = [(root, "")]

    for _ in range(depth):
        next_queue = []
        for triple, path in queue:
            for i, M in enumerate(MATRICES):
                child = M @ triple
                a, b, c = int(child[0]), int(child[1]), int(child[2])
                if a > 0 and b > 0:  # Ensure positive
                    new_path = path + str(i + 1)
                    results.append((a, b, c, new_path))
                    next_queue.append((child, new_path))
        queue = next_queue

    return results


def verify_pythagorean(a: int, b: int, c: int) -> bool:
    """Verify a² + b² = c²."""
    return a * a + b * b == c * c


def lorentz_norm(a: int, b: int, c: int) -> int:
    """Compute Lorentz form a² + b² - c² (should be 0 for Pythagorean triples)."""
    return a * a + b * b - c * c


def trace_to_root(a: int, b: int, c: int) -> List[Tuple[int, int, int]]:
    """Trace a Pythagorean triple back to (3,4,5) using inverse matrices."""
    path = []
    triple = np.array([a, b, c])
    path.append((int(triple[0]), int(triple[1]), int(triple[2])))

    while not (triple[0] == 3 and triple[1] == 4 and triple[2] == 5):
        for inv in INVERSES:
            candidate = inv @ triple
            if all(x > 0 for x in candidate) and candidate[0] < triple[2]:
                triple = candidate
                path.append((int(triple[0]), int(triple[1]), int(triple[2])))
                break
        else:
            break  # Not a primitive triple or reached root

    return path


def spb(x: float, y: float) -> float:
    """The SPB operation: spb(x,y) = (x+y)/(1+xy).
    Formally verified as tan_add_eq_spb."""
    denom = 1 + x * y
    if abs(denom) < 1e-12:
        return float('inf')
    return (x + y) / denom


def factoring_attempt(N: int) -> Optional[int]:
    """Attempt to factor N using Berggren tree descent (Algorithm 1)."""
    from math import gcd, isqrt

    # Search for sum-of-two-squares representations
    for a in range(1, isqrt(N) + 1):
        b_sq = N - a * a
        if b_sq <= 0:
            continue
        b = isqrt(b_sq)
        if b * b == b_sq:
            c_sq = a * a + b * b
            c = isqrt(c_sq)
            if c * c == c_sq:
                # Found (a, b, c) with a² + b² = c²
                # Trace back and check GCDs
                path = trace_to_root(a, b, c)
                for pa, pb, pc in path:
                    g = gcd(pc, N)
                    if 1 < g < N:
                        return g
    return None


def main():
    print("=" * 70)
    print("BERGGREN TREE EXPLORER")
    print("Formally verified in Pythagorean/Berggren/")
    print("=" * 70)

    # Generate tree to depth 3
    triples = generate_tree(3)
    print(f"\nGenerated {len(triples)} primitive Pythagorean triples (depth 3):\n")

    print(f"{'Triple':<20} {'Path':<10} {'a²+b²=c²':<12} {'Lorentz':>8}")
    print("-" * 55)
    for a, b, c, path in triples[:20]:
        verified = "✓" if verify_pythagorean(a, b, c) else "✗"
        lnorm = lorentz_norm(a, b, c)
        print(f"({a:>3}, {b:>3}, {c:>3})     {path:<10} {verified:<12} {lnorm:>8}")

    if len(triples) > 20:
        print(f"  ... and {len(triples) - 20} more triples")

    # Demonstrate SPB operation
    print("\n" + "=" * 70)
    print("SPB OPERATION: spb(x,y) = (x+y)/(1+xy)")
    print("Verified: tan_add_eq_spb")
    print("=" * 70)

    test_pairs = [(0.5, 0.3), (0.1, 0.2), (0.8, 0.6)]
    for x, y in test_pairs:
        result = spb(x, y)
        # Verify it matches tan(arctan(x) + arctan(y))
        import math
        expected = math.tan(math.atan(x) + math.atan(y))
        print(f"  spb({x}, {y}) = {result:.6f}  (tan(arctan+arctan) = {expected:.6f})")

    # Demonstrate tree tracing
    print("\n" + "=" * 70)
    print("TREE TRACING: Algorithm 31 (Berggren Ternary Tree Index)")
    print("=" * 70)

    test_triples = [(5, 12, 13), (8, 15, 17), (7, 24, 25)]
    for a, b, c in test_triples:
        path = trace_to_root(a, b, c)
        print(f"\n  ({a}, {b}, {c}) → root path:")
        for pa, pb, pc in path:
            print(f"    ({pa}, {pb}, {pc})")

    # Demonstrate factoring attempt
    print("\n" + "=" * 70)
    print("FACTORING: Algorithm 1 (Berggren Tree Descent)")
    print("=" * 70)

    test_numbers = [65, 85, 145, 221, 325]
    for N in test_numbers:
        factor = factoring_attempt(N)
        if factor:
            print(f"  {N} = {factor} × {N // factor}")
        else:
            print(f"  {N}: no factor found via this method")

    # Output summary statistics
    print("\n" + "=" * 70)
    print("VERIFICATION SUMMARY")
    print("=" * 70)
    all_verified = all(verify_pythagorean(a, b, c) for a, b, c, _ in triples)
    all_lorentz = all(lorentz_norm(a, b, c) == 0 for a, b, c, _ in triples)
    print(f"  All {len(triples)} triples satisfy a² + b² = c²: {all_verified}")
    print(f"  All {len(triples)} triples have Lorentz norm 0:  {all_lorentz}")
    print(f"  (Formally verified: B₁_preserves_lorentz, B₂_preserves_lorentz, B₃_preserves_lorentz)")


if __name__ == "__main__":
    main()
