#!/usr/bin/env python3
"""
Applications of Pythagorean Lattice Reduction

Demonstrates practical applications connecting Pythagorean triple arithmetic
to cryptographic analysis and number theory.
"""

import math
from typing import List, Tuple, Optional, Dict
from algorithms import (
    find_nontrivial_sqrt_one_crt, 
    factor_via_sqrt_collision,
    congruence_lattice_basis,
    lattice_reduce_2d,
    generate_berggren_tree,
    scan_pythagorean_collisions,
    extended_gcd
)

# ============================================================
# Application 1: RSA-Style Key Analysis
# ============================================================

def analyze_rsa_structure(p: int, q: int) -> Dict:
    """
    Analyze the lattice structure of an RSA-style modulus n = p*q.
    
    Shows how the congruence lattice encodes the factorization
    and computes relevant lattice parameters.
    
    >>> result = analyze_rsa_structure(101, 103)
    >>> result['factors']
    (101, 103)
    """
    n = p * q
    
    # Find nontrivial square root
    r = find_nontrivial_sqrt_one_crt(p, q)
    
    if r is None:
        return {'n': n, 'factors': (p, q), 'error': 'No nontrivial sqrt (need both ≥ 3)'}
    
    # Build and reduce lattice
    basis = congruence_lattice_basis(n, r)
    b1_red, b2_red = lattice_reduce_2d(basis[0], basis[1])
    
    # Compute lattice parameters
    det = abs(basis[0][0] * basis[1][1] - basis[0][1] * basis[1][0])
    lambda1_sq = b1_red[0]**2 + b1_red[1]**2
    lambda2_sq = b2_red[0]**2 + b2_red[1]**2
    
    # Factor extraction
    d1 = math.gcd(abs(r - 1), n)
    d2 = math.gcd(abs(r + 1), n)
    
    return {
        'n': n,
        'factors': (p, q),
        'sqrt_one': r,
        'lattice_det': det,
        'original_basis': basis,
        'reduced_basis': [b1_red, b2_red],
        'lambda1_sq': lambda1_sq,
        'lambda2_sq': lambda2_sq,
        'hermite_ratio': lambda1_sq / det,  # λ₁² / det(L)
        'factor_via_gcd': (d1 if 1 < d1 < n else d2),
    }

print("=" * 70)
print("APPLICATION 1: RSA Modulus Lattice Analysis")
print("=" * 70)

rsa_examples = [
    (7, 11), (13, 17), (31, 37), (61, 67), (101, 103),
    (127, 131), (251, 257), (509, 521)
]

print(f"\n{'n':<12} {'p×q':<14} {'r':<8} {'det(L)':<8} {'λ₁²':<10} {'λ₁²/det':<10} {'Factor'}")
print("-" * 75)

for p, q in rsa_examples:
    result = analyze_rsa_structure(p, q)
    if 'error' not in result:
        print(f"{result['n']:<12} {p}×{q:<8} {result['sqrt_one']:<8} "
              f"{result['lattice_det']:<8} {result['lambda1_sq']:<10} "
              f"{result['hermite_ratio']:<10.4f} {result['factor_via_gcd']}")

# ============================================================
# Application 2: Pythagorean Collision Scanner
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 2: Pythagorean Collision Scanner for Factoring")
print("=" * 70)

def pythagorean_factor_attempt(n: int, max_param: int = 200) -> Optional[Dict]:
    """
    Attempt to factor n by scanning Pythagorean triples for modular collisions.
    
    This implements the informal factoring strategy: generate Pythagorean triples
    (a, b, c) and check whether n | (a² + b²) but n ∤ c, or whether
    a² ≡ b² (mod n) nontrivially. Either condition yields a factor.
    """
    for m in range(2, max_param):
        for k in range(1, m):
            if math.gcd(m, k) != 1 or (m - k) % 2 == 0:
                continue
            a = m**2 - k**2
            b = 2 * m * k
            c = m**2 + k**2
            
            # Check: n | c² but n ∤ c
            if c**2 % n == 0 and c % n != 0:
                d = math.gcd(c, n)
                if 1 < d < n:
                    return {
                        'method': 'hypotenuse_gcd',
                        'triple': (a, b, c),
                        'params': (m, k),
                        'factor': d,
                        'complement': n // d
                    }
            
            # Check: a² ≡ b² (mod n) nontrivially
            if (a**2 - b**2) % n == 0:
                if (a - b) % n != 0 and (a + b) % n != 0:
                    d = math.gcd(abs(a - b), n)
                    if 1 < d < n:
                        return {
                            'method': 'leg_collision',
                            'triple': (a, b, c),
                            'params': (m, k),
                            'factor': d,
                            'complement': n // d
                        }
    
    return None

print("\nAttempting to factor composites via Pythagorean collision scanning:")
test_numbers = [15, 21, 35, 77, 91, 143, 221, 323, 437, 667, 899, 1147]

for n in test_numbers:
    result = pythagorean_factor_attempt(n)
    if result:
        print(f"  {n} = {result['factor']} × {result['complement']} "
              f"via {result['method']}, triple = {result['triple']}")
    else:
        print(f"  {n}: no collision found in range")

# ============================================================
# Application 3: Berggren Tree Depth Analysis
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 3: Berggren Tree Structure Analysis")
print("=" * 70)

triples = generate_berggren_tree(1000)
print(f"\nPrimitive Pythagorean triples with hypotenuse ≤ 1000: {len(triples)}")

# Analyze distribution of legs
even_legs = [min(a, b) if min(a, b) % 2 == 0 else max(a, b) for a, b, c in triples]
odd_legs = [max(a, b) if min(a, b) % 2 == 0 else min(a, b) for a, b, c in triples]

print(f"Average even leg: {sum(even_legs) / len(even_legs):.1f}")
print(f"Average odd leg: {sum(odd_legs) / len(odd_legs):.1f}")
print(f"Average hypotenuse: {sum(c for _, _, c in triples) / len(triples):.1f}")

# Count triples with hypotenuse in various ranges
ranges = [(0, 100), (100, 200), (200, 500), (500, 1000)]
for lo, hi in ranges:
    count = sum(1 for _, _, c in triples if lo < c <= hi)
    print(f"  Triples with {lo} < c ≤ {hi}: {count}")

# ============================================================
# Application 4: Lattice Gap Analysis
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 4: Lattice Gap Ratio Analysis")
print("=" * 70)

print("\nHermite ratio λ₁²/det(L) for various RSA-style moduli:")
print("(Smaller ratio = better lattice reduction quality)")
print()

gaps = []
for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]:
    for q in [p + 2, p + 4, p + 6]:
        if all(q % i != 0 for i in range(2, int(q**0.5) + 1)) and q > p:
            n = p * q
            r = find_nontrivial_sqrt_one_crt(p, q)
            if r is not None:
                basis = congruence_lattice_basis(n, r)
                b1, b2 = lattice_reduce_2d(basis[0], basis[1])
                lam1_sq = b1[0]**2 + b1[1]**2
                ratio = lam1_sq / n
                gaps.append((n, p, q, ratio))

gaps.sort(key=lambda x: x[0])
print(f"{'n':<10} {'p':<6} {'q':<6} {'λ₁²/n ratio':<15}")
print("-" * 40)
for n, p, q, ratio in gaps[:20]:
    print(f"{n:<10} {p:<6} {q:<6} {ratio:<15.6f}")

avg_ratio = sum(r for _, _, _, r in gaps) / len(gaps) if gaps else 0
print(f"\nAverage Hermite ratio: {avg_ratio:.6f}")
print(f"Minkowski bound (2D): {2 / math.pi:.6f}")

print("\n" + "=" * 70)
print("All applications complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction for Integer Factoring — Demonstration

This script demonstrates the key mathematical constructions connecting
Pythagorean triples, congruence lattices, and integer factoring.
"""

import math
import numpy as np
from typing import List, Tuple, Optional

# ============================================================
# Section 1: Berggren Tree of Primitive Pythagorean Triples
# ============================================================

# The three Berggren matrices
U = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
A = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
D = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

BERGGREN_GENS = [U, A, D]
GEN_NAMES = ['U', 'A', 'D']

def generate_berggren_triples(depth: int) -> List[Tuple[np.ndarray, str]]:
    """Generate all primitive Pythagorean triples up to given depth in the Berggren tree."""
    root = np.array([3, 4, 5])
    results = [(root, "")]
    queue = [(root, "", 0)]
    
    while queue:
        triple, word, d = queue.pop(0)
        if d >= depth:
            continue
        for i, gen in enumerate(BERGGREN_GENS):
            new_triple = gen @ triple
            new_word = word + GEN_NAMES[i]
            results.append((new_triple, new_word))
            queue.append((new_triple, new_word, d + 1))
    
    return results

def verify_pythagorean(a, b, c) -> bool:
    """Verify a² + b² = c²."""
    return a**2 + b**2 == c**2

def verify_primitive(a, b, c) -> bool:
    """Verify gcd(a, b, c) = 1."""
    return math.gcd(math.gcd(abs(a), abs(b)), abs(c)) == 1

print("=" * 70)
print("DEMO 1: Berggren Tree of Primitive Pythagorean Triples")
print("=" * 70)
print()

triples = generate_berggren_triples(3)
print(f"Generated {len(triples)} triples (depth ≤ 3):")
print(f"{'Word':<8} {'Triple':<25} {'Pythagorean?':<14} {'Primitive?'}")
print("-" * 65)
for triple, word in triples[:20]:
    a, b, c = triple
    is_pyth = verify_pythagorean(a, b, c)
    is_prim = verify_primitive(a, b, c)
    word_display = word if word else "(root)"
    print(f"{word_display:<8} ({a:>4}, {b:>4}, {c:>4})      {str(is_pyth):<14} {is_prim}")

print(f"\n... and {len(triples) - 20} more triples")

# Verify all are Pythagorean
all_pyth = all(verify_pythagorean(*t) for t, _ in triples)
all_prim = all(verify_primitive(*t) for t, _ in triples)
print(f"\nAll {len(triples)} triples Pythagorean: {all_pyth}")
print(f"All {len(triples)} triples primitive: {all_prim}")

# Verify determinants
print("\nBerggren generator determinants:")
for name, gen in zip(GEN_NAMES, BERGGREN_GENS):
    det = int(round(np.linalg.det(gen)))
    print(f"  det({name}) = {det}")

# ============================================================
# Section 2: Square-Root Collision Factoring
# ============================================================

print("\n" + "=" * 70)
print("DEMO 2: Square-Root Collision Factoring")
print("=" * 70)

def find_nontrivial_sqrt_one(n: int) -> Optional[int]:
    """Find r with r² ≡ 1 (mod n), r ≢ ±1 (mod n)."""
    for r in range(2, n - 1):
        if (r * r) % n == 1:
            return r
    return None

def factor_via_collision(n: int, x: int, y: int) -> int:
    """Extract factor via gcd(x - y, n) when x² ≡ y² (mod n)."""
    d = math.gcd(abs(x - y), n)
    return d

print("\nFactoring composites via nontrivial square roots of 1:")
print(f"{'n':<8} {'p×q':<12} {'r (r²≡1)':<12} {'gcd(r-1,n)':<14} {'Factor?'}")
print("-" * 60)

test_composites = [
    (15, 3, 5), (21, 3, 7), (35, 5, 7), (77, 7, 11),
    (91, 7, 13), (143, 11, 13), (221, 13, 17), (323, 17, 19),
    (1001, 7, 143), (10403, 101, 103)
]

for n, p, q in test_composites:
    r = find_nontrivial_sqrt_one(n)
    if r is not None:
        d = factor_via_collision(n, r, 1)
        is_factor = 1 < d < n and n % d == 0
        print(f"{n:<8} {p}×{q:<8} {r:<12} {d:<14} {is_factor}")
    else:
        print(f"{n:<8} {p}×{q:<8} {'None':<12} {'—':<14} (no nontrivial sqrt)")

# Show why n=6 has no nontrivial sqrt
print("\nWhy n = 6 = 2×3 has no nontrivial square root of 1:")
print("  Square roots of 1 mod 6:", [r for r in range(6) if (r*r) % 6 == 1])
print("  Both 1 and 5 ≡ -1 are trivial (confirming our formal counterexample)")

# ============================================================  
# Section 3: Congruence Lattice Construction
# ============================================================

print("\n" + "=" * 70)
print("DEMO 3: Congruence Lattice L_{n,r}")
print("=" * 70)

def congruence_lattice_basis(n: int, r: int) -> np.ndarray:
    """Return a basis for L_{n,r} = {(x,y) : x ≡ ry (mod n)}."""
    return np.array([[n, 0], [r, 1]])

def verify_lattice_membership(v: np.ndarray, n: int, r: int) -> bool:
    """Check if v ∈ L_{n,r}, i.e., n | (v[0] - r*v[1])."""
    return (v[0] - r * v[1]) % n == 0

def verify_square_congruence(v: np.ndarray, n: int) -> bool:
    """Check if v[0]² ≡ v[1]² (mod n)."""
    return (v[0]**2 - v[1]**2) % n == 0

n, p, q = 91, 7, 13
r = find_nontrivial_sqrt_one(n)
print(f"\nExample: n = {n} = {p}×{q}, nontrivial sqrt r = {r}")
print(f"  Verification: {r}² = {r**2} ≡ {r**2 % n} (mod {n})")

basis = congruence_lattice_basis(n, r)
print(f"\nLattice L_{{n,r}} basis:")
print(f"  b₁ = ({basis[0,0]}, {basis[0,1]})")
print(f"  b₂ = ({basis[1,0]}, {basis[1,1]})")
print(f"  det = {abs(int(np.linalg.det(basis)))}")

# Generate some lattice vectors and verify properties
print(f"\nSample lattice vectors and their properties:")
print(f"{'(x, y)':<20} {'∈ L?':<8} {'x²≡y²?':<10} {'gcd(x-y,n)':<14} {'Factor?'}")
print("-" * 60)

for a in range(-3, 4):
    for b in range(-3, 4):
        if a == 0 and b == 0:
            continue
        v = a * basis[0] + b * basis[1]
        in_L = verify_lattice_membership(v, n, r)
        sq_cong = verify_square_congruence(v, n)
        d = math.gcd(abs(int(v[0] - v[1])), n)
        is_factor = 1 < d < n and n % d == 0
        if abs(a) + abs(b) <= 2:  # Only show small combinations
            print(f"({v[0]:>5}, {v[1]:>5})     {str(in_L):<8} {str(sq_cong):<10} {d:<14} {is_factor}")

# ============================================================
# Section 4: Euclid Parametrization
# ============================================================

print("\n" + "=" * 70)
print("DEMO 4: Euclid Parametrization (m² - k², 2mk, m² + k²)")
print("=" * 70)

print(f"\n{'m':<4} {'k':<4} {'a=m²-k²':<10} {'b=2mk':<10} {'c=m²+k²':<10} {'a²+b²=c²?'}")
print("-" * 52)
for m in range(2, 8):
    for k in range(1, m):
        if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
            a = m**2 - k**2
            b = 2 * m * k
            c = m**2 + k**2
            check = a**2 + b**2 == c**2
            print(f"{m:<4} {k:<4} {a:<10} {b:<10} {c:<10} {check}")

# ============================================================
# Section 5: Complete Factoring Example
# ============================================================

print("\n" + "=" * 70)
print("DEMO 5: Complete Factoring Pipeline")
print("=" * 70)

def full_factoring_pipeline(n: int):
    """Demonstrate the complete reduction: composite → lattice → factor."""
    print(f"\nFactoring n = {n}:")
    
    # Step 1: Find nontrivial square root
    r = find_nontrivial_sqrt_one(n)
    if r is None:
        print(f"  No nontrivial square root of 1 mod {n} found.")
        print(f"  (This happens when n has a factor of 2 — need odd composites)")
        return
    
    print(f"  Step 1: Found r = {r} with r² = {r*r} ≡ {(r*r)%n} (mod {n})")
    
    # Step 2: Build lattice
    basis = congruence_lattice_basis(n, r)
    print(f"  Step 2: Lattice basis = ({basis[0,0]},{basis[0,1]}), ({basis[1,0]},{basis[1,1]})")
    
    # Step 3: The vector (r, 1) is in the lattice
    v = np.array([r, 1])
    print(f"  Step 3: Vector v = ({v[0]}, {v[1]}) ∈ L_{{n,r}}")
    print(f"          x² - y² = {v[0]**2} - {v[1]**2} = {v[0]**2 - v[1]**2}")
    print(f"          (x² - y²) mod n = {(v[0]**2 - v[1]**2) % n}")
    
    # Step 4: Extract factor
    d1 = math.gcd(abs(r - 1), n)
    d2 = math.gcd(abs(r + 1), n)
    print(f"  Step 4: gcd(r-1, n) = gcd({r-1}, {n}) = {d1}")
    print(f"          gcd(r+1, n) = gcd({r+1}, {n}) = {d2}")
    
    factors = []
    if 1 < d1 < n:
        factors.append(d1)
    if 1 < d2 < n:
        factors.append(d2)
    
    if factors:
        d = factors[0]
        print(f"  Result: {n} = {d} × {n // d} ✓")
    else:
        print(f"  No nontrivial factor found from this r")

for n in [15, 35, 77, 91, 143, 221, 1001, 10403]:
    full_factoring_pipeline(n)

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""Generate the PACKAGE.json deliverable."""

import json
import base64

# Read all markdown files
with open('ARTICLE.md', 'r') as f:
    article = f.read()

with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()

with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Read code files
with open('demo.py', 'r') as f:
    demo_code = f.read()

with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()

with open('applications.py', 'r') as f:
    applications_code = f.read()

# Read Lean file
with open('Cryptography/PythagoreanLatticeReduction.lean', 'r') as f:
    lean_code = f.read()

# Read images as base64
visualizations = []
for name, fname in [
    ("Berggren Tree of Primitive Pythagorean Triples", "berggren_tree.png"),
    ("Congruence Lattice Before and After Reduction", "congruence_lattice.png"),
    ("Square Root Distribution for Composite Numbers", "sqrt_distribution.png"),
]:
    with open(fname, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
    visualizations.append({
        "name": name,
        "data": f"data:image/png;base64,{b64}"
    })

package = {
    "title": "Pythagorean Lattice Reduction for Integer Factoring",
    "domain": "Cryptography / Number Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Pythagorean Lattice Reduction Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code.replace(
                "from algorithms import (\n    find_nontrivial_sqrt_one_crt, \n    factor_via_sqrt_collision,\n    congruence_lattice_basis,\n    lattice_reduce_2d,\n    generate_berggren_tree,\n    scan_pythagorean_collisions,\n    extended_gcd\n)",
                "# Self-contained: core algorithms included inline\nimport math\nfrom typing import List, Tuple, Optional, Dict\n\n" + open('algorithms.py').read().split("if __name__")[0]
            )
        }
    ],
    "algorithms": [
        {
            "name": "Congruence Lattice Factoring",
            "pseudocode": """Algorithm: Factor via Congruence Lattice
Input: Composite n = p*q, p, q >= 3, coprime
Output: Nontrivial factor d of n

1. Compute Bezout coefficients: a*p + b*q = 1
2. Set r = 1 - 2*a*p (mod n)
   // r^2 ≡ 1 (mod n), r ≢ ±1 (mod n)
3. Construct lattice basis B = {(n,0), (r,1)}
4. Reduce basis using Gauss/LLL: B' = {b1, b2}
5. For each short vector v in B':
     d = gcd(v[0] - v[1], n)
     if 1 < d < n: return d
6. Return gcd(r - 1, n)""",
            "code": algorithms_code
        },
        {
            "name": "Berggren Tree Generation",
            "pseudocode": """Algorithm: Generate Berggren Tree
Input: Maximum hypotenuse C
Output: All primitive Pythagorean triples with c <= C

1. Initialize queue with root = (3, 4, 5)
2. While queue is not empty:
   a. Pop triple (a, b, c) from queue
   b. If c > C: skip
   c. Output (|a|, |b|, c)
   d. For each generator M in {U, A, D}:
      Push M * (a, b, c) to queue
3. Return sorted unique triples""",
            "code": algorithms_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Visualizations for Pythagorean Lattice Reduction

Generates publication-quality figures showing:
1. The Berggren tree of primitive Pythagorean triples
2. Congruence lattice structure
3. Square-root collision geometry
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import math
import base64
import io

def save_fig_base64(fig) -> str:
    """Save figure as base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"

# ============================================================
# Figure 1: Berggren Tree of Primitive Pythagorean Triples
# ============================================================

def plot_berggren_tree():
    """Plot primitive Pythagorean triples in (a, b) plane, colored by tree depth."""
    U = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    A = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
    D = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    gens = [U, A, D]
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    root = np.array([3, 4, 5])
    max_c = 500
    
    # BFS with depth tracking
    queue = [(root, 0)]
    triples_by_depth = {}
    
    while queue:
        triple, depth = queue.pop(0)
        a, b, c = triple
        if c > max_c:
            continue
        if depth not in triples_by_depth:
            triples_by_depth[depth] = []
        triples_by_depth[depth].append((abs(a), abs(b), c))
        for gen in gens:
            child = gen @ triple
            if child[2] <= max_c:
                queue.append((child, depth + 1))
    
    colors = plt.cm.viridis(np.linspace(0, 0.85, max(triples_by_depth.keys()) + 1))
    
    for depth in sorted(triples_by_depth.keys()):
        triples = triples_by_depth[depth]
        aa = [t[0] for t in triples]
        bb = [t[1] for t in triples]
        sizes = [max(8, 60 - depth * 8) for _ in triples]
        ax.scatter(aa, bb, c=[colors[depth]], s=sizes, 
                  label=f'Depth {depth}', alpha=0.8, edgecolors='white', linewidth=0.5)
    
    # Draw the unit circle quadrant (a² + b² = c²)
    theta = np.linspace(0, np.pi/2, 100)
    for c_val in [100, 200, 300, 400, 500]:
        ax.plot(c_val * np.cos(theta), c_val * np.sin(theta), 
                'k-', alpha=0.1, linewidth=0.5)
    
    ax.set_xlabel('a (odd leg)', fontsize=14)
    ax.set_ylabel('b (even leg)', fontsize=14)
    ax.set_title('Berggren Tree: Primitive Pythagorean Triples (a, b)\n'
                 'with a² + b² = c², c ≤ 500', fontsize=16)
    ax.legend(loc='upper left', fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    return fig

# ============================================================
# Figure 2: Congruence Lattice with Short Vectors
# ============================================================

def plot_congruence_lattice():
    """Plot the congruence lattice L_{n,r} and highlight short vectors."""
    n = 35
    r = 6  # 6² = 36 ≡ 1 (mod 35), nontrivial
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left: unreduced lattice
    ax = axes[0]
    b1 = np.array([n, 0])
    b2 = np.array([r, 1])
    
    # Generate lattice points
    points = []
    for i in range(-3, 4):
        for j in range(-20, 21):
            p = i * b1 + j * b2
            if abs(p[0]) <= 50 and abs(p[1]) <= 15:
                points.append(p)
    
    points = np.array(points)
    ax.scatter(points[:, 0], points[:, 1], c='steelblue', s=20, alpha=0.6, zorder=2)
    ax.arrow(0, 0, b1[0], b1[1], head_width=0.3, head_length=0.5, fc='red', ec='red', zorder=3)
    ax.arrow(0, 0, b2[0], b2[1], head_width=0.3, head_length=0.5, fc='green', ec='green', zorder=3)
    ax.scatter([0], [0], c='black', s=50, zorder=4)
    ax.text(b1[0]/2, b1[1]-1.2, f'b₁=({b1[0]},{b1[1]})', color='red', fontsize=11, ha='center')
    ax.text(b2[0]+1, b2[1]+0.5, f'b₂=({b2[0]},{b2[1]})', color='green', fontsize=11)
    ax.set_title(f'Unreduced Lattice L₃₅,₆\nBasis: ({b1[0]},{b1[1]}), ({b2[0]},{b2[1]})', fontsize=14)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-52, 52)
    ax.set_ylim(-17, 17)
    
    # Right: reduced lattice
    ax = axes[1]
    
    # 2D Gauss reduction
    def norm_sq(v): return v[0]**2 + v[1]**2
    def dot(u, v): return u[0]*v[0] + u[1]*v[1]
    
    rb1 = list(b2)
    rb2 = list(b1)
    if norm_sq(rb1) > norm_sq(rb2):
        rb1, rb2 = rb2, rb1
    while True:
        mu = round(dot(rb2, rb1) / norm_sq(rb1))
        rb2 = [rb2[0] - mu*rb1[0], rb2[1] - mu*rb1[1]]
        if norm_sq(rb1) <= norm_sq(rb2):
            break
        rb1, rb2 = rb2, rb1
    
    rb1 = np.array(rb1)
    rb2 = np.array(rb2)
    
    ax.scatter(points[:, 0], points[:, 1], c='steelblue', s=20, alpha=0.6, zorder=2)
    ax.arrow(0, 0, rb1[0], rb1[1], head_width=0.3, head_length=0.5, fc='red', ec='red', zorder=3)
    ax.arrow(0, 0, rb2[0], rb2[1], head_width=0.3, head_length=0.5, fc='green', ec='green', zorder=3)
    ax.scatter([0], [0], c='black', s=50, zorder=4)
    ax.text(rb1[0]+0.5, rb1[1]+0.5, f'b₁\'=({rb1[0]},{rb1[1]})', color='red', fontsize=11)
    ax.text(rb2[0]+0.5, rb2[1]+0.5, f'b₂\'=({rb2[0]},{rb2[1]})', color='green', fontsize=11)
    
    # Highlight short vector that gives factor
    # Check which lattice point gives nontrivial gcd
    for p in points:
        d = math.gcd(abs(int(p[0] - p[1])), n)
        if 1 < d < n and norm_sq(p) < 200:
            ax.scatter([p[0]], [p[1]], c='gold', s=100, zorder=5, 
                      edgecolors='black', linewidth=1.5)
    
    ax.set_title(f'Reduced Lattice L₃₅,₆\nBasis: ({rb1[0]},{rb1[1]}), ({rb2[0]},{rb2[1]})', fontsize=14)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-52, 52)
    ax.set_ylim(-17, 17)
    
    plt.suptitle('Congruence Lattice Before and After Reduction (n=35, r=6)\n'
                 'Gold points yield nontrivial factors', fontsize=15, y=1.02)
    plt.tight_layout()
    
    return fig

# ============================================================
# Figure 3: Square Root Distribution
# ============================================================

def plot_sqrt_distribution():
    """Plot distribution of square roots of 1 mod n for various composites."""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    composites = []
    sqrt_counts = []
    has_nontrivial = []
    
    for n in range(4, 200):
        # Check if composite
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue
        sqrts = [r for r in range(n) if (r*r) % n == 1]
        trivial = {1, n-1}
        nontrivial = [r for r in sqrts if r not in trivial]
        composites.append(n)
        sqrt_counts.append(len(sqrts))
        has_nontrivial.append(len(nontrivial) > 0)
    
    colors = ['#2ecc71' if nt else '#e74c3c' for nt in has_nontrivial]
    ax.bar(range(len(composites)), sqrt_counts, color=colors, alpha=0.7, width=1.0)
    ax.set_xticks(range(0, len(composites), 10))
    ax.set_xticklabels([str(composites[i]) for i in range(0, len(composites), 10)], 
                       rotation=45, fontsize=9)
    ax.set_xlabel('Composite number n', fontsize=13)
    ax.set_ylabel('Number of square roots of 1 mod n', fontsize=13)
    ax.set_title('Square Roots of Unity mod n for Composite Numbers\n'
                 'Green = has nontrivial roots (factorable), Red = only ±1', fontsize=14)
    
    # Add legend
    import matplotlib.lines as mlines
    green_patch = mlines.Line2D([], [], color='#2ecc71', marker='s', linestyle='None',
                                markersize=10, label='Has nontrivial √1')
    red_patch = mlines.Line2D([], [], color='#e74c3c', marker='s', linestyle='None',
                              markersize=10, label='Only ±1 (prime powers, 2p)')
    ax.legend(handles=[green_patch, red_patch], loc='upper left', fontsize=11)
    
    ax.grid(True, alpha=0.3, axis='y')
    plt.tight_layout()
    
    return fig

# ============================================================
# Generate all figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = plot_berggren_tree()
    fig1.savefig('berggren_tree.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ berggren_tree.png")
    
    fig2 = plot_congruence_lattice()
    fig2.savefig('congruence_lattice.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ congruence_lattice.png")
    
    fig3 = plot_sqrt_distribution()
    fig3.savefig('sqrt_distribution.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ sqrt_distribution.png")
    
    print("\nAll visualizations generated.")
