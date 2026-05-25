#!/usr/bin/env python3
"""
Real-World Applications of Pythagorean Witness Synthesis

This module demonstrates practical applications of the synthesis algorithms:
1. Structured test case generation for software testing
2. Integer factoring via Pythagorean triple construction
3. Optimal rectangle fitting (manufacturing/design)
4. Lattice point enumeration on circles
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Optional, Set
from collections import defaultdict

Triple = Tuple[int, int, int]

# ============================================================
# Application 1: Structured Test Case Generation
# ============================================================

def generate_test_suite(max_hypotenuse: int, coverage: str = "all") -> List[Triple]:
    """Generate a structured test suite of Pythagorean triples.
    
    Unlike random generation, this systematically covers different
    "regions" of the Pythagorean triple space, ensuring diverse
    test cases for any system that processes integer triples.
    
    Coverage modes:
    - "all": All primitive triples up to max_hypotenuse
    - "balanced": Triples where a ≈ b (near-isosceles)
    - "extreme": Triples where a << b (highly skewed)
    - "power_of_two": Triples where hypotenuse is near a power of 2
    
    Args:
        max_hypotenuse: Upper bound on hypotenuse
        coverage: Coverage strategy
    
    Returns:
        List of Pythagorean triples suitable as test cases
    """
    # Generate all primitive triples
    all_triples = []
    m = 2
    while m * m + 1 <= max_hypotenuse:
        for n in range(1, m):
            c = m * m + n * n
            if c > max_hypotenuse:
                break
            if gcd(m, n) == 1 and (m - n) % 2 == 1:
                a = m * m - n * n
                b = 2 * m * n
                if a > b:
                    a, b = b, a
                all_triples.append((a, b, c))
        m += 1
    
    all_triples.sort(key=lambda t: t[2])
    
    if coverage == "all":
        return all_triples
    elif coverage == "balanced":
        return [t for t in all_triples if t[1] <= 2 * t[0]]
    elif coverage == "extreme":
        return [t for t in all_triples if t[1] >= 5 * t[0]]
    elif coverage == "power_of_two":
        powers = {2**k for k in range(1, 30)}
        return [t for t in all_triples 
                if any(abs(t[2] - p) <= p * 0.1 for p in powers)]
    else:
        return all_triples


# ============================================================
# Application 2: Integer Factoring via Sum-of-Squares
# ============================================================

def sum_of_two_squares(n: int) -> Optional[Tuple[int, int]]:
    """Find a, b such that a² + b² = n, if they exist.
    
    Uses trial division approach. A number is expressible as a sum of
    two squares iff all prime factors of the form 4k+3 appear to an
    even power.
    
    Args:
        n: Target integer
    
    Returns:
        (a, b) with a² + b² = n, or None if impossible
    """
    for a in range(isqrt(n) + 1):
        remainder = n - a * a
        if remainder < 0:
            break
        b = isqrt(remainder)
        if b * b == remainder:
            return (a, b)
    return None


def factor_via_pythagorean(n: int) -> Optional[Tuple[int, int]]:
    """Attempt to factor n using Pythagorean triple structure.
    
    If n can be written as a² + b² in two different ways:
        n = a₁² + b₁² = a₂² + b₂²
    then gcd(a₁² - a₂², n) often gives a non-trivial factor.
    
    This is the Pythagorean factoring method, a simplified version
    of Fermat's sum-of-squares factoring.
    
    Args:
        n: Integer to factor
    
    Returns:
        (p, q) with p * q = n and 1 < p, q < n, or None
    """
    representations = []
    for a in range(1, isqrt(n) + 1):
        b_sq = n - a * a
        if b_sq < 0:
            break
        b = isqrt(b_sq)
        if b * b == b_sq and a <= b:
            representations.append((a, b))
    
    if len(representations) < 2:
        return None
    
    a1, b1 = representations[0]
    a2, b2 = representations[1]
    
    # Use Gaussian integer factoring
    # (a1 + b1i)(a1 - b1i) = (a2 + b2i)(a2 - b2i) = n
    # Cross multiply: factor = gcd(n, (a1*a2 + b1*b2)) or similar
    
    for candidate in [
        gcd(n, a1 * a2 + b1 * b2),
        gcd(n, a1 * a2 - b1 * b2),
        gcd(n, a1 * b2 + b1 * a2),
        gcd(n, a1 * b2 - b1 * a2),
    ]:
        if 1 < candidate < n:
            return (candidate, n // candidate)
    
    return None


# ============================================================
# Application 3: Optimal Rectangle Fitting
# ============================================================

def find_integer_rectangles(diagonal: int) -> List[Tuple[int, int]]:
    """Find all integer rectangles with the given diagonal length.
    
    A rectangle with sides a × b has diagonal √(a² + b²).
    We find all (a, b) with a² + b² = diagonal².
    
    This has applications in manufacturing (cutting stock problems),
    display design (pixel-perfect rectangles), and construction.
    
    Args:
        diagonal: Target diagonal length
    
    Returns:
        List of (width, height) pairs with width ≤ height
    """
    target = diagonal * diagonal
    rectangles = []
    for a in range(1, diagonal):
        b_sq = target - a * a
        if b_sq <= 0:
            break
        b = isqrt(b_sq)
        if b * b == b_sq and a <= b:
            rectangles.append((a, b))
    return rectangles


# ============================================================
# Application 4: Lattice Points on Circles
# ============================================================

def lattice_points_on_circle(radius_squared: int) -> List[Tuple[int, int]]:
    """Find all lattice points (x, y) on the circle x² + y² = r².
    
    This is equivalent to finding all representations of r² as a
    sum of two squares, including negative values and zero.
    
    The count of lattice points on x² + y² = n is related to
    the divisor function and has deep connections to number theory
    (Gauss circle problem).
    
    Args:
        radius_squared: The value of r² (must be a perfect square times n
                        for the circle to have integer radius)
    
    Returns:
        List of (x, y) lattice points on the circle
    """
    n = radius_squared
    points = []
    for x in range(isqrt(n) + 1):
        y_sq = n - x * x
        if y_sq < 0:
            break
        y = isqrt(y_sq)
        if y * y == y_sq:
            # Add all sign combinations
            if x == 0 and y == 0:
                points.append((0, 0))
            elif x == 0:
                points.extend([(0, y), (0, -y)])
            elif y == 0:
                points.extend([(x, 0), (-x, 0)])
            else:
                points.extend([(x, y), (x, -y), (-x, y), (-x, -y)])
    return sorted(points)


# ============================================================
# Demo
# ============================================================

def main():
    print("=" * 70)
    print("APPLICATIONS OF PYTHAGOREAN WITNESS SYNTHESIS")
    print("=" * 70)
    
    # --- Test Generation ---
    print("\n§1. STRUCTURED TEST CASE GENERATION")
    print("-" * 50)
    for coverage in ["balanced", "extreme"]:
        suite = generate_test_suite(100, coverage)
        print(f"\n  Coverage '{coverage}': {len(suite)} triples")
        for t in suite[:5]:
            ratio = t[1] / t[0] if t[0] > 0 else float('inf')
            print(f"    {t}  (ratio b/a = {ratio:.2f})")
    
    # --- Factoring ---
    print("\n§2. PYTHAGOREAN FACTORING")
    print("-" * 50)
    test_numbers = [5 * 13, 5 * 17, 13 * 17, 5 * 29, 5 * 13 * 17]
    for n in test_numbers:
        result = factor_via_pythagorean(n)
        reps = []
        for a in range(1, isqrt(n) + 1):
            b_sq = n - a*a
            b = isqrt(b_sq)
            if b*b == b_sq and a <= b:
                reps.append((a, b))
        print(f"  n = {n}: representations = {reps}, factors = {result}")
    
    # --- Rectangle Fitting ---
    print("\n§3. OPTIMAL RECTANGLE FITTING")
    print("-" * 50)
    for diag in [5, 10, 13, 25, 50, 65]:
        rects = find_integer_rectangles(diag)
        print(f"  Diagonal {diag}: {len(rects)} integer rectangle(s)")
        for w, h in rects:
            print(f"    {w} × {h} (area = {w*h}, perimeter = {2*(w+h)})")
    
    # --- Lattice Points ---
    print("\n§4. LATTICE POINTS ON CIRCLES")
    print("-" * 50)
    for r in [5, 10, 13, 25, 50]:
        points = lattice_points_on_circle(r * r)
        print(f"  Circle x²+y²={r}²={r*r}: {len(points)} lattice points")
        if len(points) <= 16:
            print(f"    Points: {points}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Compositional Witness Synthesis for Pythagorean Triples — Interactive Demo

This script demonstrates the three main synthesis methods:
1. Parametric witness: (m² - n², 2mn, m² + n²)
2. Berggren tree: compositional generation via matrix multiplication
3. Gaussian composition: Brahmagupta-Fibonacci identity

Run: python demo.py
"""

import numpy as np
from typing import Tuple, List

# ============================================================
# §1. Parametric Witness Synthesis
# ============================================================

def parametric_witness(m: int, n: int) -> Tuple[int, int, int]:
    """Synthesize a Pythagorean triple from parameters (m, n).
    
    Returns (m² - n², 2mn, m² + n²), which always satisfies a² + b² = c².
    
    >>> parametric_witness(2, 1)
    (3, 4, 5)
    >>> parametric_witness(3, 2)
    (5, 12, 13)
    """
    a = m**2 - n**2
    b = 2 * m * n
    c = m**2 + n**2
    return (a, b, c)

def verify_pythagorean(a: int, b: int, c: int) -> bool:
    """Verify that a² + b² = c²."""
    return a**2 + b**2 == c**2

# ============================================================
# §2. Berggren Tree Synthesis
# ============================================================

# The three Berggren matrices
BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
BERGGREN_MATRICES = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
BERGGREN_NAMES = ['A', 'B', 'C']
ROOT = np.array([3, 4, 5])

def berggren_apply(matrix_idx: int, triple: np.ndarray) -> np.ndarray:
    """Apply Berggren matrix to a triple."""
    return BERGGREN_MATRICES[matrix_idx] @ triple

def berggren_path(path: List[int]) -> np.ndarray:
    """Follow a Berggren path from root (3, 4, 5).
    
    Path is a list of indices 0=A, 1=B, 2=C, applied right-to-left.
    
    >>> berggren_path([])
    array([3, 4, 5])
    >>> berggren_path([0])
    array([ 5, 12, 13])
    """
    result = ROOT.copy()
    for idx in reversed(path):
        result = berggren_apply(idx, result)
    return result

def lorentz_form(triple: np.ndarray) -> int:
    """Compute the Lorentz form Q(a,b,c) = a² + b² - c²."""
    return int(triple[0]**2 + triple[1]**2 - triple[2]**2)

def enumerate_berggren_tree(max_depth: int) -> List[Tuple[List[int], np.ndarray]]:
    """Enumerate all triples in the Berggren tree up to given depth.
    
    Returns list of (path, triple) pairs.
    """
    results = [([], ROOT.copy())]
    frontier = [([], ROOT.copy())]
    
    for depth in range(max_depth):
        new_frontier = []
        for path, triple in frontier:
            for i in range(3):
                new_path = [i] + path
                new_triple = berggren_apply(i, triple)
                results.append((new_path, new_triple))
                new_frontier.append((new_path, new_triple))
        frontier = new_frontier
    
    return results

# ============================================================
# §3. Gaussian Composition
# ============================================================

def gaussian_compose(t1: Tuple[int, int, int], t2: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Compose two Pythagorean triples via Brahmagupta-Fibonacci identity.
    
    If a₁² + b₁² = c₁² and a₂² + b₂² = c₂², then
    (a₁a₂ - b₁b₂)² + (a₁b₂ + b₁a₂)² = (c₁c₂)²
    
    >>> gaussian_compose((3, 4, 5), (5, 12, 13))
    (-33, 56, 65)
    """
    a1, b1, c1 = t1
    a2, b2, c2 = t2
    return (a1*a2 - b1*b2, a1*b2 + b1*a2, c1*c2)

# ============================================================
# §4. Demo
# ============================================================

def main():
    print("=" * 70)
    print("COMPOSITIONAL WITNESS SYNTHESIS FOR PYTHAGOREAN TRIPLES")
    print("=" * 70)
    
    # --- Parametric Witnesses ---
    print("\n§1. PARAMETRIC WITNESS SYNTHESIS")
    print("-" * 40)
    print(f"{'m':>3} {'n':>3} | {'a':>6} {'b':>6} {'c':>6} | {'a²+b²=c²':>10}")
    print("-" * 50)
    for m in range(2, 8):
        for n in range(1, m):
            if (m - n) % 2 == 1 and np.gcd(m, n) == 1:
                a, b, c = parametric_witness(m, n)
                valid = verify_pythagorean(a, b, c)
                print(f"{m:3d} {n:3d} | {a:6d} {b:6d} {c:6d} | {'✓' if valid else '✗':>10}")
    
    # --- Berggren Tree ---
    print("\n§2. BERGGREN TREE SYNTHESIS")
    print("-" * 40)
    print("Root: (3, 4, 5)")
    print(f"Lorentz form Q(3,4,5) = {lorentz_form(ROOT)}")
    print()
    
    tree = enumerate_berggren_tree(3)
    print(f"Depth | Path{'':8s} | Triple{'':12s} | Q(a,b,c) | a²+b²=c²")
    print("-" * 70)
    for path, triple in tree[:40]:  # Show first 40
        depth = len(path)
        path_str = ''.join(BERGGREN_NAMES[i] for i in path) if path else 'root'
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        q = lorentz_form(triple)
        valid = verify_pythagorean(a, b, c)
        print(f"{depth:5d} | {path_str:12s} | ({a:5d},{b:5d},{c:5d}) | {q:8d} | {'✓' if valid else '✗'}")
    
    print(f"\nTotal triples generated (depth ≤ 3): {len(tree)}")
    print(f"All Pythagorean: {all(verify_pythagorean(*[int(x) for x in t]) for _, t in tree)}")
    print(f"All Lorentz form = 0: {all(lorentz_form(t) == 0 for _, t in tree)}")
    
    # --- Gaussian Composition ---
    print("\n§3. GAUSSIAN COMPOSITION")
    print("-" * 40)
    t1 = (3, 4, 5)
    t2 = (5, 12, 13)
    composed = gaussian_compose(t1, t2)
    print(f"Composing {t1} ⊗ {t2}")
    print(f"Result: {composed}")
    print(f"Verification: {composed[0]}² + {composed[1]}² = {composed[0]**2 + composed[1]**2}")
    print(f"             {composed[2]}² = {composed[2]**2}")
    print(f"Valid: {verify_pythagorean(*composed)}")
    
    # Self-composition
    t_self = gaussian_compose((3, 4, 5), (3, 4, 5))
    print(f"\nSelf-composition (3,4,5) ⊗ (3,4,5) = {t_self}")
    print(f"Valid: {verify_pythagorean(*t_self)}")
    print(f"|{t_self[0]}|² + {t_self[1]}² = {abs(t_self[0])**2 + t_self[1]**2} = {t_self[2]}² = {t_self[2]**2}")
    
    # --- Growth Analysis ---
    print("\n§4. BERGGREN HYPOTENUSE GROWTH")
    print("-" * 40)
    deep_tree = enumerate_berggren_tree(8)
    by_depth = {}
    for path, triple in deep_tree:
        d = len(path)
        if d not in by_depth:
            by_depth[d] = []
        by_depth[d].append(int(triple[2]))
    
    print(f"{'Depth':>5} | {'Count':>7} | {'Min Hyp':>10} | {'Max Hyp':>10} | {'Mean Hyp':>10}")
    print("-" * 55)
    for d in sorted(by_depth.keys()):
        hyps = by_depth[d]
        print(f"{d:5d} | {len(hyps):7d} | {min(hyps):10d} | {max(hyps):10d} | {np.mean(hyps):10.1f}")
    
    # --- No Isosceles Triple ---
    print("\n§5. NO ISOSCELES PYTHAGOREAN TRIPLE")
    print("-" * 40)
    print("Checking: does a² + a² = c² have any solution with a, c ∈ ℤ, a > 0?")
    found = False
    for a in range(1, 100000):
        c_sq = 2 * a * a
        c = int(c_sq ** 0.5)
        if c * c == c_sq:
            found = True
            print(f"Found: a={a}, c={c}")
            break
    if not found:
        print("No solution found for a ∈ [1, 100000]. (Theorem: none exists, √2 is irrational)")
    
    print("\n" + "=" * 70)
    print("All synthesis methods verified. Compositional structure confirmed.")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Berggren Tree of Primitive Pythagorean Triples

Visualizes the first 4 levels of the Berggren ternary tree, showing how
each primitive Pythagorean triple generates three children via the
Berggren matrices A, B, C. Node size reflects hypotenuse magnitude.

This demonstrates the compositional witness synthesis: every primitive
triple is uniquely reached by a path from the root (3, 4, 5).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Berggren matrices
BERGGREN = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
]
NAMES = ['A', 'B', 'C']
COLORS = ['#e74c3c', '#3498db', '#2ecc71']

def build_tree(depth):
    """Build tree structure for visualization."""
    nodes = []
    edges = []
    
    def add_node(triple, path, d, parent_idx=None):
        idx = len(nodes)
        nodes.append({
            'triple': tuple(int(x) for x in triple),
            'path': path,
            'depth': d,
            'idx': idx
        })
        if parent_idx is not None:
            edges.append((parent_idx, idx, path[-1] if path else -1))
        
        if d < depth:
            for i in range(3):
                child = BERGGREN[i] @ triple
                add_node(child, path + [i], d + 1, idx)
    
    add_node(np.array([3, 4, 5]), [], 0)
    return nodes, edges

def layout_tree(nodes, edges):
    """Compute x, y positions for tree nodes."""
    max_depth = max(n['depth'] for n in nodes)
    
    # Count nodes at each depth for spacing
    depth_counts = {}
    depth_indices = {}
    for n in nodes:
        d = n['depth']
        if d not in depth_counts:
            depth_counts[d] = 0
            depth_indices[d] = 0
        depth_counts[d] += 1
    
    # Assign positions
    positions = {}
    counters = {d: 0 for d in depth_counts}
    
    for n in nodes:
        d = n['depth']
        count = depth_counts[d]
        idx = counters[d]
        counters[d] += 1
        
        x = (idx - (count - 1) / 2) * (12 / max(count, 1))
        y = -d * 2.5
        positions[n['idx']] = (x, y)
    
    return positions

# Build and layout
nodes, edges = build_tree(3)
positions = layout_tree(nodes, edges)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(18, 12))
fig.patch.set_facecolor('white')
ax.set_facecolor('#fafafa')

# Draw edges
for parent_idx, child_idx, matrix_idx in edges:
    px, py = positions[parent_idx]
    cx, cy = positions[child_idx]
    color = COLORS[matrix_idx] if matrix_idx >= 0 else 'gray'
    ax.plot([px, cx], [py, cy], '-', color=color, linewidth=1.5, alpha=0.5, zorder=1)

# Draw nodes
max_hyp = max(n['triple'][2] for n in nodes)
for n in nodes:
    x, y = positions[n['idx']]
    a, b, c = n['triple']
    
    # Size proportional to log(hypotenuse)
    size = 800 + 400 * np.log(c)
    
    # Color by depth
    depth_colors = ['#f39c12', '#e74c3c', '#9b59b6', '#3498db']
    color = depth_colors[min(n['depth'], len(depth_colors) - 1)]
    
    ax.scatter([x], [y], s=size, c=color, alpha=0.8, edgecolors='white', 
               linewidths=2, zorder=2)
    
    label = f"({a},{b},{c})"
    fontsize = 7 if n['depth'] >= 2 else (9 if n['depth'] == 1 else 11)
    ax.annotate(label, (x, y), ha='center', va='center', fontsize=fontsize,
                fontweight='bold', color='white', zorder=3)

# Legend
for i, (name, color) in enumerate(zip(NAMES, COLORS)):
    ax.plot([], [], '-', color=color, linewidth=3, label=f'Matrix {name}')
ax.legend(loc='upper right', fontsize=12, framealpha=0.9)

# Annotations
ax.set_title('The Berggren Tree: Compositional Synthesis of Primitive Pythagorean Triples',
             fontsize=16, fontweight='bold', pad=20)
ax.set_xlabel('Branching Position', fontsize=12)
ax.text(0.02, 0.02, 
        'Root (3,4,5) → 3 children per node via Berggren matrices A, B, C\n'
        'Every primitive Pythagorean triple appears exactly once\n'
        'Node size ∝ log(hypotenuse) | Lorentz form Q = a² + b² - c² = 0 at every node',
        transform=ax.transAxes, fontsize=10, verticalalignment='bottom',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

ax.set_xlim(-8, 8)
ax.set_ylim(-9, 1.5)
ax.set_yticks([])
ax.grid(False)

plt.tight_layout()
plt.savefig('viz_berggren_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_berggren_tree.png")


#!/usr/bin/env python3
"""
Visualization: Lorentz Form Invariance and the Berggren Light Cone

Shows how the Berggren matrices preserve the Lorentz form Q(a,b,c) = a² + b² - c².
Pythagorean triples lie on the "light cone" Q = 0. The Berggren matrices
act as isometries of this quadratic form, mapping the cone to itself.

This visualizes the deep geometric reason why compositional synthesis works:
the Berggren matrices belong to the integer Lorentz group O(2,1;ℤ).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Lorentz Form Invariance: Why Berggren Synthesis Works',
             fontsize=16, fontweight='bold')

# --- Panel 1: The Light Cone ---
ax = axes[0]

# Draw the cone a² + b² = c² in the (a, c) plane (fixing b)
a_range = np.linspace(0, 50, 200)
for b_val, color, alpha in [(0, '#e74c3c', 0.8), (10, '#3498db', 0.6), 
                              (20, '#2ecc71', 0.4), (30, '#f39c12', 0.3)]:
    c_vals = np.sqrt(a_range**2 + b_val**2)
    ax.plot(a_range, c_vals, '-', color=color, alpha=alpha, linewidth=2,
            label=f'b = {b_val}')

# Plot primitive Pythagorean triples
for m in range(2, 12):
    for n in range(1, m):
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            if c <= 60:
                ax.scatter([a], [c], c='black', s=40, zorder=5, alpha=0.8)
                if c <= 30:
                    ax.annotate(f'({a},{b},{c})', (a, c), fontsize=7,
                               xytext=(3, 3), textcoords='offset points')

ax.set_xlabel('First leg a', fontsize=12)
ax.set_ylabel('Hypotenuse c', fontsize=12)
ax.set_title('The Pythagorean Light Cone\na² + b² = c²', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 50)
ax.set_ylim(0, 60)

# --- Panel 2: Lorentz form values along Berggren paths ---
ax = axes[1]

BERGGREN = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
]
NAMES = ['A', 'B', 'C']
COLORS = ['#e74c3c', '#3498db', '#2ecc71']

root = np.array([3, 4, 5])

# Generate paths and compute Q values
max_depth = 6
all_q_values = []
all_depths = []
all_colors = []

def explore(v, depth, first_step):
    q = int(v[0]**2 + v[1]**2 - v[2]**2)
    all_q_values.append(q)
    all_depths.append(depth + np.random.uniform(-0.1, 0.1))
    all_colors.append(COLORS[first_step] if first_step >= 0 else '#f39c12')
    
    if depth < max_depth:
        for i in range(3):
            child = BERGGREN[i] @ v
            explore(child, depth + 1, i if first_step < 0 else first_step)

explore(root, 0, -1)

ax.scatter(all_depths, all_q_values, c=all_colors, s=15, alpha=0.7)
ax.axhline(y=0, color='red', linewidth=2, linestyle='--', alpha=0.8,
           label='Q = 0 (Pythagorean)')

# Add legend for branches
for i in range(3):
    ax.scatter([], [], c=COLORS[i], s=50, label=f'Branch {NAMES[i]}')
ax.scatter([], [], c='#f39c12', s=50, label='Root')

ax.set_xlabel('Depth in Berggren Tree', fontsize=12)
ax.set_ylabel('Lorentz Form Q = a² + b² - c²', fontsize=12)
ax.set_title('Lorentz Form is Invariant\nQ = 0 at Every Node', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 2)

# --- Panel 3: Hypotenuse growth along paths ---
ax = axes[2]

# Follow specific long paths and track hypotenuse
paths_to_follow = {
    'AAA...': 0,
    'BBB...': 1,
    'CCC...': 2,
    'ABC...': None  # alternating
}

max_path_depth = 10
for label, fixed_idx in paths_to_follow.items():
    v = root.copy().astype(np.float64)
    hyps = [float(v[2])]
    for d in range(max_path_depth):
        if fixed_idx is not None:
            idx = fixed_idx
        else:
            idx = d % 3
        v = BERGGREN[idx] @ v
        hyps.append(float(v[2]))
    
    color = COLORS[fixed_idx] if fixed_idx is not None else '#f39c12'
    ax.semilogy(range(len(hyps)), hyps, 'o-', color=color, label=label,
                markersize=5, linewidth=2)

# Reference line: spectral radius growth
spectral = [5 * (3 + 2*np.sqrt(2))**d for d in range(max_path_depth + 1)]
ax.semilogy(range(len(spectral)), spectral, 'k--', alpha=0.3,
            label=f'(3+2√2)^d ≈ 5.83^d')

ax.set_xlabel('Depth d', fontsize=12)
ax.set_ylabel('Hypotenuse (log scale)', fontsize=12)
ax.set_title('Hypotenuse Growth Along Paths\nExponential in Tree Depth', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_lorentz_invariance.png', dpi=150, bbox_inches='tight')
print("Saved viz_lorentz_invariance.png")


#!/usr/bin/env python3
"""
Visualization: Witness Size Bounds for Parametric Pythagorean Triples

Shows the tight bounds on hypotenuse size: m² ≤ c = m² + n² ≤ 2m²,
and the relationship between parameters (m, n) and the generated triple.

This visualizes the key size theorems from the formal verification:
witness_hypotenuse_bound and witness_hypotenuse_lower.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Witness Size Bounds: Parametric Pythagorean Triple Synthesis',
             fontsize=16, fontweight='bold')

# --- Panel 1: Hypotenuse vs parameters ---
ax = axes[0, 0]
ms = np.arange(2, 30)
for n_ratio_label, n_func, color in [
    ('n = 1', lambda m: 1, '#e74c3c'),
    ('n = m//2', lambda m: max(1, m//2), '#3498db'),
    ('n = m-1', lambda m: m-1, '#2ecc71'),
]:
    hyps = []
    m_vals = []
    for m in ms:
        n = n_func(m)
        if n < m and n >= 1:
            c = m**2 + n**2
            hyps.append(c)
            m_vals.append(m)
    ax.plot(m_vals, hyps, 'o-', label=n_ratio_label, color=color, markersize=4)

# Bounds
m_cont = np.linspace(2, 29, 100)
ax.fill_between(m_cont, m_cont**2, 2*m_cont**2, alpha=0.15, color='gray',
                label='Bound: m² ≤ c ≤ 2m²')
ax.plot(m_cont, m_cont**2, '--', color='gray', alpha=0.5)
ax.plot(m_cont, 2*m_cont**2, '--', color='gray', alpha=0.5)

ax.set_xlabel('Parameter m', fontsize=12)
ax.set_ylabel('Hypotenuse c = m² + n²', fontsize=12)
ax.set_title('Hypotenuse Growth with Parameter m', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# --- Panel 2: All primitive triples up to hypotenuse 500 ---
ax = axes[0, 1]
triples = []
for m in range(2, 50):
    for n in range(1, m):
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            if c <= 500:
                triples.append((min(a,b), max(a,b), c))

a_vals = [t[0] for t in triples]
b_vals = [t[1] for t in triples]
c_vals = [t[2] for t in triples]

scatter = ax.scatter(a_vals, b_vals, c=c_vals, cmap='viridis', 
                     s=30, alpha=0.8, edgecolors='white', linewidths=0.5)
plt.colorbar(scatter, ax=ax, label='Hypotenuse c')

# Draw the line a = b (no isosceles triple exists here)
max_val = max(max(a_vals), max(b_vals))
ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='a = b (forbidden)')

ax.set_xlabel('Shorter leg a', fontsize=12)
ax.set_ylabel('Longer leg b', fontsize=12)
ax.set_title('Primitive Triples (c ≤ 500)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 3: Leg ratio distribution ---
ax = axes[1, 0]
ratios = [t[1]/t[0] for t in triples if t[0] > 0]
ax.hist(ratios, bins=30, color='#9b59b6', alpha=0.7, edgecolor='white')
ax.axvline(x=1, color='red', linestyle='--', linewidth=2, label='b/a = 1 (impossible)')
ax.set_xlabel('Leg ratio b/a', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Distribution of Leg Ratios', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 4: Quadratic bound visualization ---
ax = axes[1, 1]
m_range = range(2, 25)
for m in m_range:
    n_vals = range(1, m)
    for n in n_vals:
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            c = m**2 + n**2
            bound = (m + n)**2
            ratio = c / bound
            ax.scatter(m, ratio, c='#3498db', s=20, alpha=0.6)

ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, 
           label='c/(m+n)² = 0.5 (when n=0)')
ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.5,
           label='c/(m+n)² = 1 (upper bound)')

ax.set_xlabel('Parameter m', fontsize=12)
ax.set_ylabel('c / (m+n)²', fontsize=12)
ax.set_title('Quadratic Bound Tightness: c ≤ (m+n)²', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.4, 1.05)

plt.tight_layout()
plt.savefig('viz_witness_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_bounds.png")
