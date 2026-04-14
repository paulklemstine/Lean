#!/usr/bin/env python3
"""
EML–Pythagorean Quadruple & N-tuple Explorer

Explores Research Direction 3 (Quadruples) and Direction 4 (N-tuples):
- Enumerate Pythagorean quadruples
- Search for quadruple tree generators
- Verify EML encoding
- Explore N-tuple generalizations
"""

import math
import itertools
from typing import List, Tuple, Set

# =============================================================================
# Pythagorean Quadruples
# =============================================================================

def find_quadruples(max_d: int) -> List[Tuple[int, int, int, int]]:
    """Find all primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(3, max_d + 1):
        d2 = d * d
        for a in range(1, d):
            for b in range(a, d):
                rem = d2 - a*a - b*b
                if rem <= 0:
                    break
                c = int(math.isqrt(rem))
                if c*c == rem and c >= b:
                    if math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1:
                        quads.append((a, b, c, d))
    return quads

def verify_quadruple(a: int, b: int, c: int, d: int) -> bool:
    """Check a² + b² + c² = d²."""
    return a**2 + b**2 + c**2 == d**2

# =============================================================================
# Quadruple Parametrization
# =============================================================================

def euler_quadruple(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """Lebesgue's parametrization of Pythagorean quadruples:
    a = m²+n²-p²-q², b = 2(mq+np), c = 2(nq-mp), d = m²+n²+p²+q²."""
    a = m**2 + n**2 - p**2 - q**2
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m**2 + n**2 + p**2 + q**2
    return (a, b, c, d)

# =============================================================================
# Quadruple Tree Search (Research Direction 3)
# =============================================================================

def search_quadruple_matrices(quads: List[Tuple[int, int, int, int]],
                                max_coeff: int = 5) -> dict:
    """Search for integer matrices that map one quadruple to another.
    This explores whether a finite set of generators exists."""
    connections = {}
    quad_set = set(quads)

    for i, q1 in enumerate(quads[:20]):  # Check first 20
        for j, q2 in enumerate(quads[:20]):
            if i == j:
                continue
            # Check if q2 = M * q1 for a simple matrix pattern
            a1, b1, c1, d1 = q1
            a2, b2, c2, d2 = q2
            # Simple check: is q2 a linear combination?
            # We'd need 4x4 matrix, but check basic patterns
            key = (q1, q2)
            # Check ratio of d values
            if d1 > 0 and d2 > 0:
                ratio = d2 / d1
                connections[key] = {'d_ratio': ratio}

    return connections

# =============================================================================
# N-tuple Generalization (Research Direction 4)
# =============================================================================

def find_ntuples(n: int, max_val: int) -> List[Tuple]:
    """Find Pythagorean n-tuples: x₁² + ... + x_{n-1}² = x_n²."""
    results = []

    def search(current: list, remaining: int, min_val: int, target_sq: int = None):
        if len(current) == n - 1:
            # Check if sum of squares is a perfect square
            s = sum(x**2 for x in current)
            root = int(math.isqrt(s))
            if root*root == s and root > 0 and root <= max_val:
                results.append(tuple(current + [root]))
            return
        rem = max_val**2 - sum(x**2 for x in current)
        if rem < 0:
            return
        max_x = min(max_val, int(math.sqrt(rem)) + 1)
        for x in range(min_val, max_x + 1):
            search(current + [x], remaining - 1, x)

    search([], n - 1, 1)
    return results

# =============================================================================
# EML Encoding
# =============================================================================

def eml(x: float, y: float) -> float:
    """EML operator."""
    return math.exp(x) - math.log(y)

def eml_verify_quad(a: int, b: int, c: int, d: int) -> float:
    """Verify quadruple relation via EML in log-space."""
    if a <= 0 or b <= 0 or c <= 0 or d <= 0:
        return float('inf')
    lhs = math.exp(2*math.log(a)) + math.exp(2*math.log(b)) + math.exp(2*math.log(c))
    rhs = math.exp(2*math.log(d))
    return abs(lhs - rhs)

def lorentz4(a: int, b: int, c: int, d: int) -> int:
    """4D Lorentz form: a² + b² + c² - d²."""
    return a**2 + b**2 + c**2 - d**2

# =============================================================================
# Demo
# =============================================================================

def run_demo():
    print("=" * 70)
    print("  EML–PYTHAGOREAN QUADRUPLE & N-TUPLE EXPLORER")
    print("=" * 70)

    # Demo 1: Find Pythagorean Quadruples
    print("\n📐 Demo 1: Primitive Pythagorean Quadruples (d ≤ 30)")
    print("-" * 50)
    quads = find_quadruples(30)
    for q in quads[:15]:
        a, b, c, d = q
        ok = verify_quadruple(a, b, c, d)
        L = lorentz4(a, b, c, d)
        print(f"  ({a}, {b}, {c}, {d})  ✓={ok}  Q₄={L}")
    print(f"  ... total: {len(quads)} primitive quadruples with d ≤ 30")

    # Demo 2: EML Verification of Quadruples
    print("\n🔬 Demo 2: EML Log-Space Verification")
    print("-" * 50)
    for q in quads[:8]:
        a, b, c, d = q
        residual = eml_verify_quad(a, b, c, d)
        print(f"  ({a},{b},{c},{d}): log-space residual = {residual:.2e}")

    # Demo 3: Lebesgue Parametrization
    print("\n🔢 Demo 3: Lebesgue Parametrization")
    print("-" * 50)
    for m, n, p, q in itertools.product(range(1, 4), repeat=4):
        if m > n and n > p and p > q:
            quad = euler_quadruple(m, n, p, q)
            a, b, c, d = quad
            if a > 0 and b > 0 and c > 0 and d > 0:
                ok = verify_quadruple(abs(a), abs(b), abs(c), d)
                print(f"  (m,n,p,q)=({m},{n},{p},{q}) → ({a},{b},{c},{d})  ✓={ok}")

    # Demo 4: Triple-to-Quadruple Embedding
    print("\n📦 Demo 4: Triple → Quadruple Embedding")
    print("-" * 50)
    triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25)]
    for a, b, c in triples:
        ok_triple = a**2 + b**2 == c**2
        ok_quad = verify_quadruple(a, b, 0, c)
        print(f"  ({a},{b},{c}) → ({a},{b},0,{c})  triple✓={ok_triple}  quad✓={ok_quad}")

    # Demo 5: Pythagorean 5-tuples
    print("\n🔮 Demo 5: Pythagorean 5-tuples (x₁²+x₂²+x₃²+x₄² = x₅²)")
    print("-" * 50)
    fivetuples = find_ntuples(5, 20)
    for t in fivetuples[:12]:
        s = sum(x**2 for x in t[:-1])
        print(f"  {t}  sum={s}  {t[-1]}²={t[-1]**2}  ✓={s == t[-1]**2}")
    print(f"  ... total: {len(fivetuples)} found with max value ≤ 20")

    # Demo 6: Dimension Hierarchy
    print("\n📊 Demo 6: Pythagorean N-tuple Counts by Dimension")
    print("-" * 50)
    for n in range(3, 7):
        count = len(find_ntuples(n, 15))
        print(f"  {n}-tuples with max value ≤ 15: {count}")

    print("\n" + "=" * 70)
    print("  Quadruple & N-tuple exploration complete!")
    print("=" * 70)

if __name__ == '__main__':
    run_demo()
