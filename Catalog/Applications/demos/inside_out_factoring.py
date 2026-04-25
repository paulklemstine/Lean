#!/usr/bin/env python3
"""
Inside-Out Factoring (IOF) — Algorithm 1 from the SPB Framework

Demonstrates the Berggren tree descent method for integer factoring.
Given an odd composite N, constructs the trivial Pythagorean triple
(N, (N²-1)/2, (N²+1)/2) and descends the tree by applying inverse
Berggren matrices, checking GCDs at each step.

Based on formally verified mathematics in:
  - Computation/Factoring/InsideOutFactor.lean
  - Pythagorean/TreeFactoring/Core.lean
"""

import math
from typing import Optional, Tuple, List


def inverse_berggren_B1(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Apply inverse Berggren matrix B₁⁻¹."""
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)


def inverse_berggren_B2(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Apply inverse Berggren matrix B₂⁻¹."""
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def inverse_berggren_B3(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Apply inverse Berggren matrix B₃⁻¹."""
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def trivial_pythagorean_triple(N: int) -> Tuple[int, int, int]:
    """
    For any odd N, (N, (N²-1)/2, (N²+1)/2) is a Pythagorean triple.
    Verified as trivial_triple_is_pyth in TreeFactoring/Core.lean.
    """
    assert N % 2 == 1, "N must be odd"
    return (N, (N*N - 1) // 2, (N*N + 1) // 2)


def inside_out_factor(N: int, max_steps: int = 1000, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Inside-Out Factoring Algorithm.
    
    Given an odd composite N:
    1. Build trivial Pythagorean triple for N
    2. Descend the Berggren tree by applying inverse matrices
    3. At each node, check GCD(leg, N) for nontrivial factors
    
    Returns (p, q) if a factorization is found, None otherwise.
    """
    if N % 2 == 0:
        return (2, N // 2)
    if N < 9:
        return None
    
    a, b, c = trivial_pythagorean_triple(N)
    
    if verbose:
        print(f"Starting IOF for N = {N}")
        print(f"Trivial triple: ({a}, {b}, {c})")
        print(f"Verification: {a}² + {b}² = {a*a + b*b}, {c}² = {c*c}")
    
    path = []
    
    for step in range(max_steps):
        # Check GCDs at current node
        for leg in [a, b, c - 1, c + 1, a + b, abs(a - b)]:
            g = math.gcd(abs(leg), N)
            if 1 < g < N:
                if verbose:
                    print(f"  Step {step}: Found factor {g} via GCD({leg}, {N})")
                    print(f"  Path: {path}")
                return (g, N // g)
        
        # Reached the root
        if a == 3 and b == 4 and c == 5:
            break
        if a <= 0 or b <= 0:
            break
        
        # Try each inverse matrix and pick the one giving positive values
        candidates = [
            (1, inverse_berggren_B1(a, b, c)),
            (2, inverse_berggren_B2(a, b, c)),
            (3, inverse_berggren_B3(a, b, c)),
        ]
        
        found = False
        for label, (a2, b2, c2) in candidates:
            if a2 > 0 and b2 > 0 and c2 > 0:
                a, b, c = a2, b2, c2
                path.append(label)
                found = True
                if verbose:
                    print(f"  Step {step}: B{label}⁻¹ → ({a}, {b}, {c})")
                break
        
        if not found:
            break
    
    return None


def demo():
    """Run demonstrations of Inside-Out Factoring."""
    print("=" * 60)
    print("Inside-Out Factoring (IOF) — Berggren Tree Descent")
    print("=" * 60)
    
    # Small examples
    test_cases = [15, 21, 35, 77, 91, 143, 221, 323, 437, 667, 899,
                  1001, 1147, 2021, 3599, 5767, 10403, 25117]
    
    print("\n--- Factoring Results ---")
    successes = 0
    for N in test_cases:
        result = inside_out_factor(N)
        if result:
            p, q = result
            status = "✓"
            successes += 1
        else:
            p, q = "?", "?"
            status = "✗"
        print(f"  {status} N = {N:>8} → {p} × {q}")
    
    print(f"\nSuccess rate: {successes}/{len(test_cases)}")
    
    # Detailed trace for N = 77
    print("\n--- Detailed Trace: N = 77 ---")
    inside_out_factor(77, verbose=True)
    
    # Detailed trace for N = 143  
    print("\n--- Detailed Trace: N = 143 ---")
    inside_out_factor(143, verbose=True)


if __name__ == "__main__":
    demo()
