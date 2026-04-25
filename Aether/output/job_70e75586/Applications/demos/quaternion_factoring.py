#!/usr/bin/env python3
"""
Quaternion Norm Factoring — Algorithm 15 from the SPB Framework

Demonstrates factoring via multiple four-square representations
and the Euler/Hamilton identity for quaternion norms.

Based on formally verified mathematics in:
  - Speculative/QuaternionFactoring.lean
  - Speculative/BrahmaguptaFibonacciFactoring.lean
  - quat_norm_mul, four_square_multiple_reps, bf_N_divides_cross_product
"""

import math
import random
from typing import Optional, Tuple, List


def find_four_square_rep(N: int) -> Optional[Tuple[int, int, int, int]]:
    """
    Find a representation N = a² + b² + c² + d².
    By Lagrange's four-square theorem (verified in the framework),
    every positive integer has such a representation.
    """
    for a in range(int(math.isqrt(N)) + 1):
        rem1 = N - a * a
        if rem1 < 0:
            break
        for b in range(int(math.isqrt(rem1)) + 1):
            rem2 = rem1 - b * b
            if rem2 < 0:
                break
            for c in range(int(math.isqrt(rem2)) + 1):
                rem3 = rem2 - c * c
                d_sq = rem3
                d = int(math.isqrt(d_sq))
                if d * d == d_sq:
                    return (a, b, c, d)
    return None


def find_multiple_four_square_reps(N: int, max_reps: int = 10) -> List[Tuple[int, int, int, int]]:
    """
    Find multiple distinct four-square representations of N.
    Verified: four_square_multiple_reps shows N ≥ 5 always has ≥ 2 reps.
    """
    reps = set()
    for a in range(int(math.isqrt(N)) + 1):
        rem1 = N - a * a
        if rem1 < 0:
            break
        for b in range(a, int(math.isqrt(rem1)) + 1):
            rem2 = rem1 - b * b
            if rem2 < 0:
                break
            for c in range(b, int(math.isqrt(rem2)) + 1):
                d_sq = rem2 - c * c
                if d_sq < 0:
                    break
                d = int(math.isqrt(d_sq))
                if d * d == d_sq and d >= c:
                    rep = (a, b, c, d)
                    reps.add(rep)
                    if len(reps) >= max_reps:
                        return list(reps)
    return list(reps)


def quaternion_factor(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Quaternion Norm Factoring Algorithm.
    
    Given N with two representations N = Σaᵢ² = Σbᵢ²,
    the quaternion norm multiplicativity (quat_norm_mul) gives:
    
    N² = |q₁|² · |q₂|² where q₁, q₂ are quaternions.
    
    The cross-terms aᵢbⱼ - aⱼbᵢ yield factor candidates via GCD.
    """
    reps = find_multiple_four_square_reps(N, max_reps=5)
    
    if verbose:
        print(f"Four-square representations of {N}:")
        for rep in reps:
            a, b, c, d = rep
            print(f"  {a}² + {b}² + {c}² + {d}² = {a*a + b*b + c*c + d*d}")
    
    if len(reps) < 2:
        if verbose:
            print("  Only one representation found — need at least two")
        return None
    
    # Try all pairs of representations
    for i, rep1 in enumerate(reps):
        for j, rep2 in enumerate(reps):
            if i >= j:
                continue
            a1, a2, a3, a4 = rep1
            b1, b2, b3, b4 = rep2
            
            # Cross-terms from the Euler identity
            # (verified as euler_four_square_identity_alt)
            cross_terms = [
                a1*b2 - a2*b1,
                a1*b3 - a3*b1,
                a1*b4 - a4*b1,
                a2*b3 - a3*b2,
                a2*b4 - a4*b2,
                a3*b4 - a4*b3,
                # Hamilton product terms
                a1*b1 + a2*b2 + a3*b3 + a4*b4,
                a1*b2 - a2*b1 + a3*b4 - a4*b3,
                a1*b3 - a3*b1 - a2*b4 + a4*b2,
                a1*b4 - a4*b1 + a2*b3 - a3*b2,
            ]
            
            for term in cross_terms:
                if term == 0:
                    continue
                g = math.gcd(abs(term), N)
                if 1 < g < N:
                    if verbose:
                        print(f"  Found factor via cross-term: gcd({term}, {N}) = {g}")
                    return (g, N // g)
    
    return None


def brahmagupta_fibonacci_factor(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Brahmagupta-Fibonacci two-square factoring (Algorithm 18).
    
    If N = a² + b² = c² + d², then N | (ad - bc)(ad + bc).
    (Verified as bf_N_divides_cross_product.)
    
    So gcd(ad ± bc, N) may give a nontrivial factor.
    """
    reps = []
    for a in range(int(math.isqrt(N)) + 1):
        b_sq = N - a * a
        if b_sq < 0:
            break
        b = int(math.isqrt(b_sq))
        if b * b == b_sq and b >= a:
            reps.append((a, b))
            if verbose:
                print(f"  {a}² + {b}² = {N}")
    
    if len(reps) < 2:
        return None
    
    for i, (a, b) in enumerate(reps):
        for j, (c, d) in enumerate(reps):
            if i >= j:
                continue
            # bf_N_divides_cross_product: N | (ad - bc)(ad + bc)
            cross1 = a * d - b * c
            cross2 = a * d + b * c
            
            for term in [cross1, cross2]:
                g = math.gcd(abs(term), N)
                if 1 < g < N:
                    if verbose:
                        print(f"  gcd({term}, {N}) = {g}")
                    return (g, N // g)
    
    return None


def demo():
    """Run demonstrations of quaternion factoring methods."""
    print("=" * 60)
    print("Quaternion & Brahmagupta-Fibonacci Factoring")
    print("=" * 60)
    
    # 1. Four-square representations
    print("\n--- Four-Square Representations ---")
    for N in [5, 10, 15, 25, 30, 50, 100, 1001]:
        reps = find_multiple_four_square_reps(N, max_reps=5)
        print(f"  N = {N}: {len(reps)} representation(s)")
        for rep in reps[:3]:
            a, b, c, d = rep
            print(f"    {a}² + {b}² + {c}² + {d}² = {a*a+b*b+c*c+d*d}")
    
    # 2. Quaternion factoring
    print("\n--- Quaternion Norm Factoring ---")
    test_cases = [15, 21, 35, 65, 85, 145, 221, 1001, 2465, 5525]
    for N in test_cases:
        result = quaternion_factor(N)
        if result:
            p, q = result
            print(f"  N = {N:>6} → {p} × {q} ✓")
        else:
            print(f"  N = {N:>6} → not factored via quaternions ✗")
    
    # 3. Brahmagupta-Fibonacci factoring
    print("\n--- Brahmagupta-Fibonacci (Two-Square) Factoring ---")
    # Numbers representable as sum of two squares in multiple ways
    two_sq_composites = []
    for a in range(1, 30):
        for b in range(a, 30):
            N = a*a + b*b
            if N > 1 and not all(N % p != 0 for p in range(2, int(N**0.5)+1)):
                two_sq_composites.append(N)
    
    two_sq_composites = sorted(set(two_sq_composites))[:15]
    
    for N in two_sq_composites:
        result = brahmagupta_fibonacci_factor(N)
        if result:
            p, q = result
            print(f"  N = {N:>6} → {p} × {q} ✓")
        else:
            print(f"  N = {N:>6} → single representation only")
    
    # 4. Detailed trace
    print("\n--- Detailed Trace: N = 1105 = 5 × 13 × 17 ---")
    brahmagupta_fibonacci_factor(1105, verbose=True)
    print()
    quaternion_factor(1105, verbose=True)


if __name__ == "__main__":
    demo()
