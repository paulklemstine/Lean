#!/usr/bin/env python3
"""
Lorentz Group and Pythagorean Quadruples Demo

Explores the O(3,1;ℤ) symmetry group acting on Pythagorean quadruples,
the parametric generation of quadruples, and the connection to
special relativity's Lorentz transformations.
"""

import math
from itertools import permutations
from typing import List, Tuple, Set

# ============================================================
# SECTION 1: Pythagorean Quadruple Catalogue
# ============================================================

def find_primitive_quadruples(max_d: int = 50) -> List[Tuple[int, int, int, int]]:
    """Find all primitive Pythagorean quadruples with d ≤ max_d.
    
    A quadruple (a,b,c,d) is primitive if gcd(a,b,c,d)=1.
    """
    quads = []
    for d in range(1, max_d + 1):
        d_sq = d * d
        for a in range(0, d):
            a_sq = a * a
            if a_sq >= d_sq:
                break
            for b in range(a, d):
                b_sq = b * b
                if a_sq + b_sq >= d_sq:
                    break
                c_sq = d_sq - a_sq - b_sq
                c = int(math.isqrt(c_sq))
                if c * c == c_sq and c >= b:
                    g = math.gcd(math.gcd(a, b), math.gcd(c, d))
                    if g == 1:
                        quads.append((a, b, c, d))
    return quads

def count_quadruples_by_d(max_d: int = 100) -> dict:
    """Count primitive quadruples for each value of d."""
    counts = {}
    quads = find_primitive_quadruples(max_d)
    for q in quads:
        d = q[3]
        counts[d] = counts.get(d, 0) + 1
    return counts

# ============================================================
# SECTION 2: O(3,1;ℤ) Symmetries
# ============================================================

def apply_permutation(quad: Tuple[int, int, int, int], 
                       perm: Tuple[int, int, int]) -> Tuple[int, int, int, int]:
    """Apply a permutation of the spatial coordinates."""
    a, b, c, d = quad
    spatial = [a, b, c]
    new_spatial = [spatial[i] for i in perm]
    return (new_spatial[0], new_spatial[1], new_spatial[2], d)

def apply_sign_changes(quad: Tuple[int, int, int, int],
                        signs: Tuple[int, int, int]) -> Tuple[int, int, int, int]:
    """Apply sign changes to spatial coordinates."""
    a, b, c, d = quad
    return (signs[0]*a, signs[1]*b, signs[2]*c, d)

def orbit_size(quad: Tuple[int, int, int, int]) -> int:
    """Count the size of the O(3;ℤ) orbit of a quadruple.
    
    The spatial symmetry group is S₃ × (ℤ/2)³ = 48 elements,
    but the orbit may be smaller due to stabilizer.
    """
    orbit = set()
    a, b, c, d = quad
    
    for perm in permutations([0, 1, 2]):
        for s1 in [-1, 1]:
            for s2 in [-1, 1]:
                for s3 in [-1, 1]:
                    p = apply_permutation(quad, perm)
                    s = apply_sign_changes(p, (s1, s2, s3))
                    # Normalize to positive d
                    orbit.add(s)
    
    return len(orbit)

# ============================================================
# SECTION 3: Parametric Generation via SL(2,ℤ)
# ============================================================

def parametric_quad(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """Standard parametrization of Pythagorean quadruples."""
    a = m*m + n*n - p*p - q*q
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (a, b, c, d)

def sl2z_generators():
    """The generators of SL(2,ℤ): S and T."""
    S = [[0, -1], [1, 0]]   # S: z ↦ -1/z
    T = [[1, 1], [0, 1]]    # T: z ↦ z+1
    return S, T

def sl2z_act_on_params(M, m, n, p, q):
    """Apply an SL(2,ℤ) matrix to (m+ni, p+qi) via quaternion action.
    
    The matrix [[a,b],[c,d]] maps (z₁, z₂) = (m+ni, p+qi) to
    (az₁+bz₂, cz₁+dz₂) after normalization.
    
    For integer parameters, the action is:
    (m', n', p', q') = (am+bp, an+bq, cm+dp, cn+dq)
    """
    a, b = M[0]
    c, d = M[1]
    m2 = a*m + b*p
    n2 = a*n + b*q
    p2 = c*m + d*p
    q2 = c*n + d*q
    return m2, n2, p2, q2

# ============================================================
# SECTION 4: The Pell Equation Obstacle
# ============================================================

def check_pell_solutions(max_val: int = 1000) -> List[Tuple[int, int]]:
    """Find integer solutions to λ²-μ²=1."""
    solutions = []
    for lam in range(-max_val, max_val + 1):
        for mu in range(-max_val, max_val + 1):
            if lam*lam - mu*mu == 1:
                solutions.append((lam, mu))
                if len(solutions) > 100:
                    return solutions
    return solutions

# ============================================================
# SECTION 5: Factor Extraction Experiments
# ============================================================

def factor_via_quadruple(N: int, quad: Tuple[int, int, int, int]) -> int:
    """Try to extract a factor of N from a quadruple (a,b,c,d) with d²=kN."""
    a, b, c, d = quad
    candidates = [
        math.gcd(a*a + b*b, N),
        math.gcd(a*a + c*c, N),
        math.gcd(b*b + c*c, N),
        math.gcd(abs(a), N),
        math.gcd(abs(b), N),
        math.gcd(abs(c), N),
        math.gcd(abs(d), N),
    ]
    for g in candidates:
        if 1 < g < N:
            return g
    return 0

# ============================================================
# MAIN DEMONSTRATIONS
# ============================================================

def demo_quadruple_catalogue():
    """Display the catalogue of small primitive quadruples."""
    print("\n" + "="*70)
    print("PRIMITIVE PYTHAGOREAN QUADRUPLES (d ≤ 30)")
    print("="*70)
    
    quads = find_primitive_quadruples(30)
    print(f"\nFound {len(quads)} primitive quadruples")
    print(f"\n{'a':>3} {'b':>3} {'c':>3} {'d':>3} {'a²+b²+c²':>10} {'d²':>6} {'Orbit':>6}")
    print("-" * 40)
    for q in quads[:30]:
        a, b, c, d = q
        orb = orbit_size(q)
        print(f"{a:>3} {b:>3} {c:>3} {d:>3} {a**2+b**2+c**2:>10} {d**2:>6} {orb:>6}")

def demo_growth_rate():
    """Show how the number of quadruples grows with d."""
    print("\n" + "="*70)
    print("QUADRUPLE DENSITY: Growth Rate")
    print("="*70)
    
    counts = count_quadruples_by_d(50)
    print(f"\n{'d':>4} {'# Primitive':>12} {'d²':>8} {'Density':>10}")
    print("-" * 38)
    for d in sorted(counts.keys()):
        density = counts[d] / (d*d) if d > 0 else 0
        print(f"{d:>4} {counts[d]:>12} {d*d:>8} {density:>10.4f}")

def demo_pell_obstacle():
    """Show the Pell equation obstacle to single-plane boosts."""
    print("\n" + "="*70)
    print("THE PELL EQUATION OBSTACLE")
    print("="*70)
    
    solutions = check_pell_solutions(100)
    print(f"\nSolutions to λ²-μ²=1 with |λ|,|μ| ≤ 100:")
    for lam, mu in solutions:
        print(f"  (λ, μ) = ({lam}, {mu})")
    
    print(f"\nTotal: {len(solutions)} solutions")
    nontrivial = [(l, m) for l, m in solutions if m != 0]
    print(f"Nontrivial (μ≠0): {len(nontrivial)}")
    print("\nProof: (λ-μ)(λ+μ)=1 in ℤ ⟹ λ-μ=λ+μ=±1 ⟹ μ=0.")
    print("This is formalized in Lean 4 as theorem `no_nontrivial_boost`.")

def demo_sl2z_tree():
    """Generate quadruples via SL(2,ℤ) tree."""
    print("\n" + "="*70)
    print("QUADRUPLE TREE VIA SL(2,ℤ) ACTION")
    print("="*70)
    
    S, T = sl2z_generators()
    
    # Start from root parameters (1,1,1,0)
    root_params = (1, 1, 1, 0)
    root_quad = parametric_quad(*root_params)
    print(f"\nRoot: params {root_params} → quad {root_quad}")
    print(f"  Verify: {root_quad[0]}² + {root_quad[1]}² + {root_quad[2]}² = "
          f"{root_quad[0]**2 + root_quad[1]**2 + root_quad[2]**2} = "
          f"{root_quad[3]}² = {root_quad[3]**2}")
    
    print(f"\nApplying T (translation z ↦ z+1):")
    for i in range(1, 6):
        # T^i
        T_i = [[1, i], [0, 1]]
        params = sl2z_act_on_params(T_i, *root_params)
        quad = parametric_quad(*params)
        a, b, c, d = quad
        valid = a*a + b*b + c*c == d*d
        print(f"  T^{i}: params {params} → quad ({a},{b},{c},{d}) {'✓' if valid else '✗'}")
    
    print(f"\nApplying S (inversion z ↦ -1/z):")
    params = sl2z_act_on_params(S, *root_params)
    quad = parametric_quad(*params)
    a, b, c, d = quad
    valid = a*a + b*b + c*c == d*d
    print(f"  S: params {params} → quad ({a},{b},{c},{d}) {'✓' if valid else '✗'}")
    
    print(f"\nApplying ST, TS, STS, TST, etc.:")
    words = [
        ("ST", [[0, -1], [1, 1]]),
        ("TS", [[1, 0], [1, 1]]),  # Actually T·S but recomputed
    ]
    # Compute ST = S·T
    ST = [[S[0][0]*T[0][0]+S[0][1]*T[1][0], S[0][0]*T[0][1]+S[0][1]*T[1][1]],
          [S[1][0]*T[0][0]+S[1][1]*T[1][0], S[1][0]*T[0][1]+S[1][1]*T[1][1]]]
    TS = [[T[0][0]*S[0][0]+T[0][1]*S[1][0], T[0][0]*S[0][1]+T[0][1]*S[1][1]],
          [T[1][0]*S[0][0]+T[1][1]*S[1][0], T[1][0]*S[0][1]+T[1][1]*S[1][1]]]
    
    for name, M in [("ST", ST), ("TS", TS)]:
        params = sl2z_act_on_params(M, *root_params)
        quad = parametric_quad(*params)
        a, b, c, d = quad
        valid = a*a + b*b + c*c == d*d
        print(f"  {name}: params {params} → quad ({a},{b},{c},{d}) {'✓' if valid else '✗'}")

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  LORENTZ GROUP & PYTHAGOREAN QUADRUPLES — DEMO             ║")
    print("║  O(3,1;ℤ), SL(2,ℤ) Trees, and the Pell Obstacle          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    demo_quadruple_catalogue()
    demo_growth_rate()
    demo_pell_obstacle()
    demo_sl2z_tree()
    
    print("\n" + "="*70)
    print("DEMO COMPLETE")
    print("="*70)
