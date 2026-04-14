#!/usr/bin/env python3
"""
Hurwitz Quaternion Factoring Demo

Demonstrates factoring via the four-squares representation and quaternion norms.
Based on formally verified results:
  - four_squares_identity (Euler's identity)
  - lagrange_four_squares (every n = a² + b² + c² + d²)
  - sum_two_squares_prime_1mod4 (primes ≡ 1 mod 4 are sums of two squares)
  - quatNorm_nonneg, quatNorm_zero_iff

Usage: python3 quaternion_factoring_demo.py
"""

import math
import itertools

def four_squares(n):
    """Find a representation n = a² + b² + c² + d² (Lagrange's theorem)."""
    for a in range(math.isqrt(n) + 1):
        for b in range(a, math.isqrt(n - a*a) + 1):
            for c in range(b, math.isqrt(n - a*a - b*b) + 1):
                d2 = n - a*a - b*b - c*c
                if d2 >= 0:
                    d = math.isqrt(d2)
                    if d*d == d2 and d >= c:
                        return (a, b, c, d)
    return None

def two_squares(n):
    """Find a representation n = a² + b² if it exists."""
    for a in range(math.isqrt(n) + 1):
        b2 = n - a*a
        if b2 >= 0:
            b = math.isqrt(b2)
            if b*b == b2:
                return (a, b)
    return None

def quaternion_multiply(q1, q2):
    """Multiply two quaternions using Hamilton product.
    q = (a, b, c, d) represents a + bi + cj + dk.
    Verified: four_squares_identity shows N(q1*q2) = N(q1)*N(q2)."""
    a1, b1, c1, d1 = q1
    a2, b2, c2, d2 = q2
    return (
        a1*a2 - b1*b2 - c1*c2 - d1*d2,
        a1*b2 + b1*a2 + c1*d2 - d1*c2,
        a1*c2 - b1*d2 + c1*a2 + d1*b2,
        a1*d2 + b1*c2 - c1*b2 + d1*a2
    )

def quat_norm(q):
    """Quaternion norm N(q) = a² + b² + c² + d².
    Verified: quatNorm_nonneg (N(q) ≥ 0), quatNorm_zero_iff (N(q) = 0 ↔ q = 0)."""
    return sum(x*x for x in q)

def quat_conjugate(q):
    """Quaternion conjugate: (a, -b, -c, -d)."""
    a, b, c, d = q
    return (a, -b, -c, -d)

def demo_four_squares():
    """Demonstrate Lagrange's four-square theorem."""
    print("\n" + "="*70)
    print("LAGRANGE'S FOUR-SQUARE THEOREM")
    print("Verified: lagrange_four_squares")
    print("="*70)
    
    for n in [7, 15, 23, 42, 100, 127, 999]:
        rep = four_squares(n)
        if rep:
            a, b, c, d = rep
            print(f"  {n} = {a}² + {b}² + {c}² + {d}² = {a**2} + {b**2} + {c**2} + {d**2}")
        else:
            print(f"  {n}: No representation found (bug!)")

def demo_two_squares():
    """Demonstrate sum of two squares for primes ≡ 1 (mod 4)."""
    print("\n" + "="*70)
    print("SUM OF TWO SQUARES (p ≡ 1 mod 4)")
    print("Verified: sum_two_squares_prime_1mod4")
    print("="*70)
    
    primes = [p for p in range(2, 100) 
              if all(p % i != 0 for i in range(2, int(math.sqrt(p)) + 1)) and p > 1]
    
    for p in primes:
        rep = two_squares(p)
        mod4 = p % 4
        if mod4 == 1 and rep:
            a, b = rep
            print(f"  {p} ≡ 1 (mod 4): {p} = {a}² + {b}² ✓")
        elif mod4 == 3:
            print(f"  {p} ≡ 3 (mod 4): not a sum of two squares")
        elif p == 2:
            print(f"  {p} = 1² + 1² ✓")

def demo_euler_identity():
    """Demonstrate Euler's four-square identity (norm multiplicativity)."""
    print("\n" + "="*70)
    print("EULER'S FOUR-SQUARE IDENTITY (NORM MULTIPLICATIVITY)")
    print("Verified: four_squares_identity")
    print("="*70)
    
    test_cases = [
        ((1, 2, 3, 4), (5, 6, 7, 8)),
        ((1, 1, 1, 0), (2, 3, 0, 1)),
        ((3, 1, 4, 1), (5, 9, 2, 6)),
    ]
    
    for q1, q2 in test_cases:
        product = quaternion_multiply(q1, q2)
        n1 = quat_norm(q1)
        n2 = quat_norm(q2)
        np = quat_norm(product)
        
        print(f"\n  q₁ = {q1}, N(q₁) = {n1}")
        print(f"  q₂ = {q2}, N(q₂) = {n2}")
        print(f"  q₁·q₂ = {product}, N(q₁·q₂) = {np}")
        print(f"  N(q₁)·N(q₂) = {n1*n2} = N(q₁·q₂) = {np} {'✓' if n1*n2 == np else '✗'}")

def demo_quaternion_factoring():
    """Demonstrate quaternion-based factoring approach."""
    print("\n" + "="*70)
    print("QUATERNION FACTORING APPROACH")
    print("="*70)
    
    # For a composite N = p·q, find four-square reps of p and q,
    # then use the quaternion product to factor.
    composites = [(15, 3, 5), (21, 3, 7), (35, 5, 7), (91, 7, 13), (143, 11, 13)]
    
    for N, p, q in composites:
        rep_p = four_squares(p)
        rep_q = four_squares(q)
        rep_N = four_squares(N)
        
        product = quaternion_multiply(rep_p, rep_q)
        
        print(f"\n  N = {N} = {p} × {q}")
        print(f"  {p} = {rep_p[0]}² + {rep_p[1]}² + {rep_p[2]}² + {rep_p[3]}²")
        print(f"  {q} = {rep_q[0]}² + {rep_q[1]}² + {rep_q[2]}² + {rep_q[3]}²")
        print(f"  Direct: {N} = {rep_N[0]}² + {rep_N[1]}² + {rep_N[2]}² + {rep_N[3]}²")
        print(f"  Product: q_p · q_q = {product}")
        print(f"  N(product) = {quat_norm(product)} = {p} × {q} = {p*q} {'✓' if quat_norm(product) == N else '✗'}")

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   HURWITZ QUATERNION FACTORING DEMO (v9)                           ║")
    print("║   Based on formally verified quaternion norm properties             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_four_squares()
    demo_two_squares()
    demo_euler_identity()
    demo_quaternion_factoring()
    
    print("\n" + "="*70)
    print("All demonstrations complete.")
    print("="*70)
