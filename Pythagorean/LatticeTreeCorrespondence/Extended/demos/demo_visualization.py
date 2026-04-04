#!/usr/bin/env python3
"""
Visualization Demo: Generate publication-quality data tables and summaries
for the Dimensional Escape research paper.

Runs all experiments and produces formatted output suitable for inclusion
in the research paper and Scientific American article.
"""

import math
import random
import numpy as np

def banner(title):
    print("\n" + "═"*70)
    print(f"  {title}")
    print("═"*70)

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i*i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def primes_up_to(n):
    return [i for i in range(2, n+1) if is_prime(i)]

# ============================================================
# Demo 1: The Pythagorean Quadruple Tree
# ============================================================

def demo_quadruple_tree():
    banner("THE PYTHAGOREAN QUADRUPLE TREE")
    
    print("""
    Starting from parameters (m,n,p,q) = (1,1,1,0):
    
    The formula:  a = m²+n²-p²-q²
                  b = 2(mq+np)
                  c = 2(nq-mp)
                  d = m²+n²+p²+q²
    """)
    
    seeds = [
        (1,1,1,0), (2,1,1,0), (1,1,0,1), (2,1,1,1),
        (3,1,1,0), (2,2,1,0), (1,2,1,1), (3,2,1,1),
    ]
    
    print(f"  {'Parameters':>20} → {'(a, b, c, d)':>20} │ {'a²+b²+c²':>10} = {'d²':>6} │ Check")
    print("  " + "─"*75)
    
    for (m,n,p,q) in seeds:
        a = m*m + n*n - p*p - q*q
        b = 2*(m*q + n*p)
        c = 2*(n*q - m*p)
        d = m*m + n*n + p*p + q*q
        lhs = a*a + b*b + c*c
        rhs = d*d
        check = "✓" if lhs == rhs else "✗"
        print(f"  ({m},{n},{p},{q}){'':<12} → ({a:>2},{b:>3},{c:>3},{d:>2}) │ {lhs:>10} = {rhs:>6} │  {check}")

# ============================================================
# Demo 2: The Pell Obstacle
# ============================================================

def demo_pell_obstacle():
    banner("THE PELL OBSTACLE: λ² - μ² = 1")
    
    print("""
    For O(3,1;ℤ) to have single-plane boosts, we need integer solutions
    to λ² - μ² = 1 with μ ≠ 0.
    
    Factoring: (λ-μ)(λ+μ) = 1
    In ℤ, the only factorizations of 1 are: 1×1 and (-1)×(-1)
    
    Case 1: λ-μ=1, λ+μ=1  →  μ=0  (trivial)
    Case 2: λ-μ=-1, λ+μ=-1 →  μ=0  (trivial)
    
    Exhaustive verification for |λ|,|μ| ≤ 100:
    """)
    
    solutions = []
    for lam in range(-100, 101):
        for mu in range(-100, 101):
            if lam*lam - mu*mu == 1:
                solutions.append((lam, mu))
    
    print(f"    Found {len(solutions)} solutions:")
    for (l, m) in solutions:
        print(f"      λ={l:>4}, μ={m:>4}  →  {l}²-{m}² = {l*l}-{m*m} = {l*l-m*m}")
    
    nontrivial = [(l,m) for (l,m) in solutions if m != 0]
    print(f"\n    Nontrivial solutions (μ≠0): {len(nontrivial)}")
    print(f"    ⟹ O(3,1;ℤ) has NO single-plane boosts. QED ■")

# ============================================================
# Demo 3: Factor Extraction Pipeline
# ============================================================

def demo_extraction():
    banner("FACTOR EXTRACTION FROM SHORT LATTICE VECTORS")
    
    test_cases = [(35, 5, 7), (77, 7, 11), (91, 7, 13), (143, 11, 13), 
                  (221, 13, 17), (323, 17, 19)]
    
    print(f"\n  {'N':>6} = {'p×q':>6} │ {'Vector (x,y,z)':>18} │ {'‖v‖':>6} │ {'gcd(x²+y²,N)':>14} │ {'Factor':>7}")
    print("  " + "─"*75)
    
    for N, p, q in test_cases:
        # Find a short vector in L₄(N)
        found = False
        for x in range(1, int(N**0.5)+5):
            for y in range(0, int(N**0.5)+5):
                for z in range(0, int(N**0.5)+5):
                    if (x*x + y*y + z*z) % N == 0 and (x*x + y*y + z*z) > 0:
                        norm = math.sqrt(x*x + y*y + z*z)
                        g1 = math.gcd(x*x + y*y, N)
                        g2 = math.gcd(x*x + z*z, N)
                        g3 = math.gcd(y*y + z*z, N)
                        
                        factor = None
                        for g in [g1, g2, g3]:
                            if 1 < g < N:
                                factor = g
                                break
                        
                        f_str = str(factor) if factor else "—"
                        print(f"  {N:>6} = {p}×{q:>2} │ ({x:>3},{y:>3},{z:>3}) │ {norm:>6.2f} │ {g1:>14} │ {f_str:>7}")
                        found = True
                        break
                if found: break
            if found: break

# ============================================================
# Demo 4: Dimensional Hierarchy Table
# ============================================================

def demo_dimensional_hierarchy():
    banner("DIMENSIONAL HIERARCHY: Minkowski Exponent 1/d")
    
    print("""
    Minkowski's theorem: shortest nonzero vector ‖v‖ ≤ √γ_d · Δ^{1/d}
    
    For lattice with determinant Δ ~ N:
    """)
    
    print(f"  {'Dim d':>6} │ {'1/d':>8} │ {'γ_d':>8} │ {'1024-bit N':>12} │ {'2048-bit N':>12} │ {'4096-bit N':>12}")
    print("  " + "─"*70)
    
    gamma = {2: 1.333, 3: 2.0, 4: 4.0, 5: 8.0, 6: 64/3}
    
    for d in range(2, 7):
        exp = 1/d
        g = gamma.get(d, 2**(d-1))
        bits_1024 = int(1024 / d)
        bits_2048 = int(2048 / d)
        bits_4096 = int(4096 / d)
        print(f"  {d:>6} │ {exp:>8.4f} │ {g:>8.3f} │ 2^{bits_1024:>9} │ 2^{bits_2048:>9} │ 2^{bits_4096:>9}")
    
    print(f"\n  Each step from d to d+1 reduces the exponent by 1/(d(d+1)).")
    print(f"  The biggest jump is d=2→3: exponent drops from 0.500 to 0.333.")

# ============================================================
# Demo 5: Euler Four-Square Identity
# ============================================================

def demo_euler_identity():
    banner("EULER'S FOUR-SQUARE IDENTITY (Quaternion Norm)")
    
    print("""
    (a₁²+b₁²+c₁²+d₁²)(a₂²+b₂²+c₂²+d₂²) = 
        (a₁a₂-b₁b₂-c₁c₂-d₁d₂)² + (a₁b₂+b₁a₂+c₁d₂-d₁c₂)² +
        (a₁c₂-b₁d₂+c₁a₂+d₁b₂)² + (a₁d₂+b₁c₂-c₁b₂+d₁a₂)²
    """)
    
    examples = [
        ((1,1,1,0), (1,0,1,1)),  # 3 × 3 = 9
        ((1,1,0,0), (1,0,0,1)),  # 2 × 2 = 4
        ((2,1,0,0), (1,1,1,0)),  # 5 × 3 = 15
    ]
    
    for (a1,b1,c1,d1), (a2,b2,c2,d2) in examples:
        n1 = a1**2 + b1**2 + c1**2 + d1**2
        n2 = a2**2 + b2**2 + c2**2 + d2**2
        
        e1 = a1*a2 - b1*b2 - c1*c2 - d1*d2
        e2 = a1*b2 + b1*a2 + c1*d2 - d1*c2
        e3 = a1*c2 - b1*d2 + c1*a2 + d1*b2
        e4 = a1*d2 + b1*c2 - c1*b2 + d1*a2
        
        product = e1**2 + e2**2 + e3**2 + e4**2
        
        print(f"  ({a1},{b1},{c1},{d1}) · ({a2},{b2},{c2},{d2})")
        print(f"  Norms: {n1} × {n2} = {n1*n2}")
        print(f"  Product quaternion: ({e1},{e2},{e3},{e4})")
        print(f"  Product norm: {e1}²+{e2}²+{e3}²+{e4}² = {product}")
        print(f"  Check: {n1*n2} = {product} {'✓' if n1*n2 == product else '✗'}")
        print()

# ============================================================
# Demo 6: Three-Square Representability
# ============================================================

def demo_three_squares():
    banner("LEGENDRE'S THREE-SQUARE THEOREM")
    
    print("  N = a² + b² + c²  iff  N ≠ 4^k(8m+7)\n")
    
    representable = 0
    not_representable = 0
    
    for N in range(1, 201):
        m = N
        while m % 4 == 0:
            m //= 4
        if m % 8 == 7:
            not_representable += 1
        else:
            representable += 1
    
    print(f"  Of integers 1..200:")
    print(f"    Representable:     {representable} ({100*representable/200:.1f}%)")
    print(f"    Not representable: {not_representable} ({100*not_representable/200:.1f}%)")
    print(f"    Theory predicts:   ~{100*5/6:.1f}%")
    
    print(f"\n  Non-representable numbers (form 4^k(8m+7)):")
    non_rep = []
    for N in range(1, 201):
        m = N
        while m % 4 == 0:
            m //= 4
        if m % 8 == 7:
            non_rep.append(N)
    
    # Print in rows of 10
    for i in range(0, len(non_rep), 15):
        print(f"    {', '.join(str(x) for x in non_rep[i:i+15])}")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_quadruple_tree()
    demo_pell_obstacle()
    demo_extraction()
    demo_dimensional_hierarchy()
    demo_euler_identity()
    demo_three_squares()
    
    banner("ALL VISUALIZATION DEMOS COMPLETE")
