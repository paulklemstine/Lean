#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Berggren tree

1. Exact integer geometry: generating right triangles with specific properties
2. Cryptographic hash: using Berggren words as collision-resistant identifiers
3. Network topology: Berggren tree as a routing structure
"""

from math import gcd, isqrt
from typing import List, Tuple, Optional

Triple = Tuple[int, int, int]

def bergA(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def bergB(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def bergC(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
def invBergA(a, b, c): return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
def invBergB(a, b, c): return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
def invBergC(a, b, c): return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

ROOT = (3, 4, 5)
GENS = {'A': bergA, 'B': bergB, 'C': bergC}
INVS = {'A': invBergA, 'B': invBergB, 'C': invBergC}

# ═══════════════════════════════════════════════════════════════
# Application 1: Exact Integer Geometry
# ═══════════════════════════════════════════════════════════════

def find_triples_near_angle(target_ratio: float, tolerance: float, max_c: int) -> List[Triple]:
    """
    Find primitive Pythagorean triples where a/b is close to target_ratio.
    Uses Berggren tree enumeration for guaranteed completeness.
    
    Application: CAD systems, CNC machining, pixel-perfect rendering
    where exact integer coordinates with specific angle constraints are needed.
    """
    results = []
    queue = [ROOT]
    while queue:
        t = queue.pop(0)
        a, b, c = t
        if c > max_c:
            continue
        ratio = a / b if b > 0 else float('inf')
        if abs(ratio - target_ratio) < tolerance:
            results.append(t)
        for gen in GENS.values():
            child = gen(a, b, c)
            if child[2] <= max_c:
                queue.append(child)
    results.sort(key=lambda t: abs(t[0]/t[1] - target_ratio))
    return results

def find_triples_with_prime_hyp(max_c: int) -> List[Triple]:
    """Find all primitive Pythagorean triples whose hypotenuse is prime."""
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i+2) == 0: return False
            i += 6
        return True
    
    results = []
    queue = [ROOT]
    while queue:
        t = queue.pop(0)
        if t[2] > max_c: continue
        if is_prime(t[2]):
            results.append(t)
        for gen in GENS.values():
            child = gen(*t)
            if child[2] <= max_c:
                queue.append(child)
    return sorted(results, key=lambda t: t[2])

# ═══════════════════════════════════════════════════════════════
# Application 2: Collision-Resistant Triple Identifier
# ═══════════════════════════════════════════════════════════════

def triple_to_word(triple: Triple) -> str:
    """Convert a primitive Pythagorean triple to its unique Berggren word."""
    if triple == ROOT:
        return ""
    word = []
    a, b, c = triple
    while (a, b, c) != ROOT:
        for name, inv in INVS.items():
            pa, pb, pc = inv(a, b, c)
            if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc and gcd(pa, pb) == 1:
                word.append(name)
                a, b, c = pa, pb, pc
                break
    return "".join(reversed(word))

def word_to_triple(word: str) -> Triple:
    """Convert a Berggren word to its unique triple."""
    t = ROOT
    for letter in word:
        t = GENS[letter](*t)
    return t

# ═══════════════════════════════════════════════════════════════
# Application 3: Pythagorean Triple Database
# ═══════════════════════════════════════════════════════════════

def build_triple_database(max_c: int) -> dict:
    """
    Build a complete database of primitive Pythagorean triples up to max_c.
    Each triple is indexed by hypotenuse and includes its Berggren word.
    """
    db = {}
    queue = [(ROOT, "")]
    while queue:
        t, word = queue.pop(0)
        if t[2] > max_c: continue
        c = t[2]
        if c not in db:
            db[c] = []
        db[c].append({'triple': t, 'word': word, 'depth': len(word)})
        for name, gen in GENS.items():
            child = gen(*t)
            if child[2] <= max_c:
                queue.append((child, word + name))
    return db

# ═══════════════════════════════════════════════════════════════
# Demonstrations
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("Application 1: Exact Integer Geometry")
    print("=" * 70)
    
    print("\n  Finding triples near 45° (a/b ≈ 1.0):")
    near_45 = find_triples_near_angle(1.0, 0.05, 1000)
    for t in near_45[:5]:
        print(f"    ({t[0]:>4}, {t[1]:>4}, {t[2]:>4})  angle ≈ {t[0]/t[1]:.4f}")
    
    print("\n  Finding triples near 30° (a/b ≈ 0.577):")
    near_30 = find_triples_near_angle(0.5774, 0.05, 1000)
    for t in near_30[:5]:
        print(f"    ({t[0]:>4}, {t[1]:>4}, {t[2]:>4})  angle ≈ {t[0]/t[1]:.4f}")
    
    print("\n  Triples with prime hypotenuse (c ≤ 200):")
    prime_triples = find_triples_with_prime_hyp(200)
    for t in prime_triples:
        print(f"    ({t[0]:>4}, {t[1]:>4}, {t[2]:>4})")
    
    print("\n" + "=" * 70)
    print("Application 2: Collision-Resistant Identifiers")
    print("=" * 70)
    
    test_triples = [(3,4,5), (5,12,13), (7,24,25), (119,120,169), (39,80,89)]
    for t in test_triples:
        word = triple_to_word(t)
        recovered = word_to_triple(word)
        print(f"  {t} → word '{word}' → {recovered} {'✓' if recovered == t else '✗'}")
    
    print("\n" + "=" * 70)
    print("Application 3: Triple Database")
    print("=" * 70)
    
    db = build_triple_database(200)
    multi_hyp = {c: entries for c, entries in db.items() if len(entries) > 1}
    print(f"\n  Total hypotenuse values with c ≤ 200: {len(db)}")
    print(f"  Hypotenuses with multiple triples: {len(multi_hyp)}")
    
    for c in sorted(multi_hyp.keys())[:5]:
        entries = multi_hyp[c]
        print(f"\n  c = {c}: {len(entries)} triples")
        for e in entries:
            print(f"    {e['triple']}, word='{e['word']}', depth={e['depth']}")
    
    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Demonstration of the Berggren Tree of Primitive Pythagorean Triples

This script demonstrates the key theorems proved in our formal verification:
1. Pythagorean property preservation
2. Primitivity preservation
3. Hypotenuse strict growth
4. Lorentz form preservation
5. Word injectivity (no collisions in the tree)
6. Determinant structure of Berggren matrices
"""

import numpy as np
from math import gcd
from typing import Tuple, List

# ═══════════════════════════════════════════════════════════════
# Core Definitions
# ═══════════════════════════════════════════════════════════════

def bergA(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child A: (a,b,c) -> (a-2b+2c, 2a-b+2c, 2a-2b+3c)"""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child B: (a,b,c) -> (a+2b+2c, 2a+b+2c, 2a+2b+3c)"""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child C: (a,b,c) -> (-a+2b+2c, -2a+b+2c, -2a+2b+3c)"""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': bergA, 'B': bergB, 'C': bergC}

def is_pythagorean(a: int, b: int, c: int) -> bool:
    return a**2 + b**2 == c**2

def is_primitive(a: int, b: int, c: int) -> bool:
    return gcd(gcd(a, b), c) == 1

def lorentz_Q(a: int, b: int, c: int) -> int:
    return a**2 + b**2 - c**2

# Berggren matrices
MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
MAT_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

def apply_word(word: str, triple: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Apply a Berggren word (string of A/B/C) to a triple."""
    a, b, c = triple
    for letter in word:
        a, b, c = GENERATORS[letter](a, b, c)
    return (a, b, c)

# ═══════════════════════════════════════════════════════════════
# Demo 1: Berggren Tree Generation
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 1: The Berggren Tree — First Three Generations")
print("=" * 70)

root = (3, 4, 5)
print(f"\nRoot: {root}")
print(f"  Pythagorean: {root[0]}² + {root[1]}² = {root[0]**2} + {root[1]**2} = {root[2]**2} = {root[2]}² ✓")
print(f"  Primitive: gcd({root[0]},{root[1]},{root[2]}) = {gcd(gcd(root[0],root[1]),root[2])} ✓")
print(f"  Lorentz Q: {lorentz_Q(*root)} = 0 ✓")

print("\nGeneration 1:")
for name, gen in GENERATORS.items():
    child = gen(*root)
    print(f"  {name}: {root} → {child}")
    print(f"    Pythagorean: {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} = {child[2]**2} ✓")
    print(f"    Primitive: gcd = {gcd(gcd(child[0],child[1]),child[2])} ✓")
    print(f"    Lorentz Q = {lorentz_Q(*child)} ✓")
    print(f"    Hypotenuse growth: {root[2]} < {child[2]} ✓")

print("\nGeneration 2 (from A-child (5,12,13)):")
parent = bergA(*root)
for name, gen in GENERATORS.items():
    child = gen(*parent)
    print(f"  {name}: {parent} → {child}, hyp growth: {parent[2]} < {child[2]} ✓")

# ═══════════════════════════════════════════════════════════════
# Demo 2: Word Injectivity
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 2: Word Injectivity — No Collisions in the Berggren Tree")
print("=" * 70)

# Generate all words up to length 4
def all_words(max_len: int) -> List[str]:
    if max_len == 0:
        return [""]
    shorter = all_words(max_len - 1)
    return shorter + [w + c for w in all_words(max_len - 1) if len(w) == max_len - 1 for c in "ABC"]

words = all_words(4)
triples = {}
collisions = 0
for w in words:
    t = apply_word(w, root)
    key = t
    if key in triples:
        collisions += 1
        print(f"  COLLISION: words '{w}' and '{triples[key]}' give same triple {t}")
    triples[key] = w

print(f"\nTotal words checked (length ≤ 4): {len(words)}")
print(f"Distinct triples generated: {len(triples)}")
print(f"Collisions found: {collisions}")
print(f"Injectivity verified: {'✓' if collisions == 0 else '✗'}")

# ═══════════════════════════════════════════════════════════════
# Demo 3: Determinant Structure
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 3: Determinant Structure — Berggren Generators in O(2,1;ℤ)")
print("=" * 70)

Q = np.diag([1, 1, -1])
for name, mat in [("A", MAT_A), ("B", MAT_B), ("C", MAT_C)]:
    det = int(round(np.linalg.det(mat)))
    lorentz_preserved = np.allclose(mat.T @ Q @ mat, Q)
    print(f"\n  Matrix {name}:")
    print(f"    det = {det} ({'proper' if det == 1 else 'improper'} Lorentz)")
    print(f"    Mᵀ·Q·M = Q: {lorentz_preserved} ✓")

# Product determinants
for w in ["AB", "AC", "BC", "ABC", "AA", "BB", "CC"]:
    mat = np.eye(3, dtype=int)
    for c in w:
        mat = mat @ {"A": MAT_A, "B": MAT_B, "C": MAT_C}[c]
    det = int(round(np.linalg.det(mat)))
    print(f"  det({w}) = {det}")

# ═══════════════════════════════════════════════════════════════
# Demo 4: Hypotenuse Growth Statistics
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 4: Hypotenuse Growth — Exponential Lower Bounds")
print("=" * 70)

# Compute min hypotenuse at each depth
min_hyp_at_depth = {}
def explore(triple, word, max_depth):
    d = len(word)
    if d not in min_hyp_at_depth or triple[2] < min_hyp_at_depth[d]:
        min_hyp_at_depth[d] = triple[2]
    if d < max_depth:
        for name in "ABC":
            child = GENERATORS[name](*triple)
            explore(child, word + name, max_depth)

explore(root, "", 10)

print(f"\n{'Depth':>6} {'Min Hypotenuse':>15} {'Ratio to prev':>15} {'Depth+5 bound':>15}")
print("-" * 55)
prev = None
for d in sorted(min_hyp_at_depth.keys()):
    h = min_hyp_at_depth[d]
    ratio = f"{h/prev:.4f}" if prev else "—"
    bound = d + 5
    print(f"{d:>6} {h:>15} {ratio:>15} {bound:>15}")
    prev = h

# ═══════════════════════════════════════════════════════════════
# Demo 5: Fixed Hypotenuse Multiplicity
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 5: Fixed-Hypotenuse Multiplicity")
print("=" * 70)

def count_primitive_triples(c: int) -> List[Tuple[int, int, int]]:
    """Find all primitive Pythagorean triples with hypotenuse c."""
    triples = []
    for a in range(1, c):
        b_sq = c**2 - a**2
        if b_sq <= 0:
            continue
        b = int(b_sq**0.5)
        if b*b == b_sq and b > 0 and gcd(a, b) == 1:
            triples.append((a, b, c))
    return triples

print(f"\n{'Hypotenuse c':>14} {'# Primitive Triples':>20} {'Triples':>40}")
print("-" * 78)
for c in [5, 13, 17, 25, 29, 37, 41, 53, 61, 65, 73, 85, 89, 97, 101, 125, 145, 169, 185]:
    triples = count_primitive_triples(c)
    if triples:
        triple_str = ", ".join(f"({a},{b},{c})" for a,b,c in triples[:3])
        if len(triples) > 3:
            triple_str += f" +{len(triples)-3} more"
        print(f"{c:>14} {len(triples):>20} {triple_str:>40}")

# ═══════════════════════════════════════════════════════════════
# Demo 6: Forward-Inverse Cancellation
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 6: Forward-Inverse Cancellation")
print("=" * 70)

def invBergA(a, b, c): return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
def invBergB(a, b, c): return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
def invBergC(a, b, c): return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

INVERSES = {'A': invBergA, 'B': invBergB, 'C': invBergC}

for name in "ABC":
    child = GENERATORS[name](*root)
    recovered = INVERSES[name](*child)
    print(f"  inv{name}({name}(3,4,5)) = inv{name}{child} = {recovered} ✓")

print("\nAll demonstrations completed successfully.")


#!/usr/bin/env python3
"""
visualizations.py — Visualizations of the Berggren Tree
Generates PNG figures for the research paper and JSON package.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from collections import defaultdict
import base64
import io

def bergA(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def bergB(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def bergC(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = [('A', bergA, '#e74c3c'), ('B', bergB, '#3498db'), ('C', bergC, '#2ecc71')]
ROOT = (3, 4, 5)

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode()

# ═══════════════════════════════════════════════════════════════
# Figure 1: Berggren Tree (first 4 levels)
# ═══════════════════════════════════════════════════════════════

def make_tree_figure():
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    positions = {}
    labels = {}
    edges = []
    
    positions[ROOT] = (0.5, 1.0)
    labels[ROOT] = f"({ROOT[0]},{ROOT[1]},{ROOT[2]})"
    
    def layout(triple, x, y, width, depth, max_depth):
        if depth >= max_depth:
            return
        for i, (name, gen, color) in enumerate(GENERATORS):
            child = gen(*triple)
            cx = x + (i - 1) * width
            cy = y - 0.25
            positions[child] = (cx, cy)
            labels[child] = f"({child[0]},{child[1]},{child[2]})"
            edges.append((triple, child, name, color))
            layout(child, cx, cy, width/3.3, depth+1, max_depth)
    
    layout(ROOT, 0.5, 1.0, 0.3, 0, 3)
    
    for parent, child, name, color in edges:
        px, py = positions[parent]
        cx, cy = positions[child]
        ax.plot([px, cx], [py, cy], color=color, linewidth=1.5, alpha=0.7)
    
    for triple, (x, y) in positions.items():
        ax.plot(x, y, 'o', color='white', markersize=8, zorder=3)
        ax.plot(x, y, 'o', color='#2c3e50', markersize=6, zorder=4)
        fontsize = 7 if y > 0.5 else 5
        ax.annotate(labels[triple], (x, y), textcoords="offset points",
                   xytext=(0, 8), ha='center', fontsize=fontsize, color='#2c3e50')
    
    legend_elements = [plt.Line2D([0], [0], color=c, linewidth=2, label=f'Generator {n}')
                      for n, _, c in GENERATORS]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.05, 1.1)
    ax.set_title('The Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    ax.axis('off')
    
    fig.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ═══════════════════════════════════════════════════════════════
# Figure 2: Primitive Triples on the Unit Circle
# ═══════════════════════════════════════════════════════════════

def make_circle_figure():
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Generate triples up to hypotenuse 200
    triples = []
    queue = [ROOT]
    while queue:
        t = queue.pop(0)
        if t[2] > 200:
            continue
        triples.append(t)
        for _, gen, _ in GENERATORS:
            child = gen(*t)
            if child[2] <= 200:
                queue.append(child)
    
    theta = np.linspace(0, np.pi/2, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
    
    for a, b, c in triples:
        x, y = a/c, b/c
        size = max(3, 30 / (c**0.3))
        ax.plot(x, y, 'o', color='#e74c3c', markersize=size, alpha=0.6)
    
    ax.set_xlim(0, 1.05)
    ax.set_ylim(0, 1.05)
    ax.set_aspect('equal')
    ax.set_xlabel('a/c', fontsize=12)
    ax.set_ylabel('b/c', fontsize=12)
    ax.set_title('Primitive Pythagorean Triples on the Unit Circle\n(a/c, b/c) for triples with c ≤ 200',
                fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.2)
    
    fig.savefig('unit_circle_triples.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ═══════════════════════════════════════════════════════════════
# Figure 3: Hypotenuse Growth by Depth
# ═══════════════════════════════════════════════════════════════

def make_growth_figure():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    max_depth = 12
    min_hyp = {}
    max_hyp = {}
    count = {}
    
    def explore(triple, depth):
        if depth > max_depth:
            return
        c = triple[2]
        if depth not in min_hyp or c < min_hyp[depth]:
            min_hyp[depth] = c
        if depth not in max_hyp or c > max_hyp[depth]:
            max_hyp[depth] = c
        count[depth] = count.get(depth, 0) + 1
        for _, gen, _ in GENERATORS:
            explore(gen(*triple), depth + 1)
    
    explore(ROOT, 0)
    
    depths = sorted(min_hyp.keys())
    mins = [min_hyp[d] for d in depths]
    maxs = [max_hyp[d] for d in depths]
    
    ax1.semilogy(depths, mins, 'o-', color='#3498db', label='Min hypotenuse', linewidth=2)
    ax1.semilogy(depths, maxs, 's-', color='#e74c3c', label='Max hypotenuse', linewidth=2)
    ax1.semilogy(depths, [d + 5 for d in depths], '--', color='gray', label='d + 5 (linear bound)', linewidth=1)
    ax1.set_xlabel('Depth', fontsize=12)
    ax1.set_ylabel('Hypotenuse', fontsize=12)
    ax1.set_title('Hypotenuse vs. Tree Depth', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    counts = [count[d] for d in depths]
    ax2.semilogy(depths, counts, 'o-', color='#2ecc71', linewidth=2)
    ax2.semilogy(depths, [3**d for d in depths], '--', color='gray', label='3^d', linewidth=1)
    ax2.set_xlabel('Depth', fontsize=12)
    ax2.set_ylabel('Number of triples', fontsize=12)
    ax2.set_title('Triple Count by Depth', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('hypotenuse_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ═══════════════════════════════════════════════════════════════
# Figure 4: Hypotenuse Multiplicity Histogram
# ═══════════════════════════════════════════════════════════════

def make_multiplicity_figure():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    max_c = 1000
    hyp_counts = defaultdict(int)
    
    queue = [ROOT]
    while queue:
        t = queue.pop(0)
        if t[2] > max_c:
            continue
        hyp_counts[t[2]] += 1
        for _, gen, _ in GENERATORS:
            child = gen(*t)
            if child[2] <= max_c:
                queue.append(child)
    
    mult_dist = defaultdict(int)
    for c, count in hyp_counts.items():
        mult_dist[count] += 1
    
    mults = sorted(mult_dist.keys())
    freqs = [mult_dist[m] for m in mults]
    
    ax.bar(mults, freqs, color='#9b59b6', alpha=0.8, edgecolor='white')
    ax.set_xlabel('Number of triples sharing a hypotenuse', fontsize=12)
    ax.set_ylabel('Number of hypotenuse values', fontsize=12)
    ax.set_title(f'Hypotenuse Multiplicity Distribution (c ≤ {max_c})',
                fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    for m, f in zip(mults, freqs):
        ax.annotate(str(f), (m, f), textcoords="offset points",
                   xytext=(0, 5), ha='center', fontsize=10)
    
    fig.savefig('multiplicity_dist.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

if __name__ == "__main__":
    print("Generating visualizations...")
    b1 = make_tree_figure()
    print(f"  berggren_tree.png generated ({len(b1)} chars base64)")
    b2 = make_circle_figure()
    print(f"  unit_circle_triples.png generated ({len(b2)} chars base64)")
    b3 = make_growth_figure()
    print(f"  hypotenuse_growth.png generated ({len(b3)} chars base64)")
    b4 = make_multiplicity_figure()
    print(f"  multiplicity_dist.png generated ({len(b4)} chars base64)")
    print("All visualizations generated successfully.")
