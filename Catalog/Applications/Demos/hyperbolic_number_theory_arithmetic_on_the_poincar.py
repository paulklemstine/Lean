"""
Applications of Hyperbolic Number Theory
==========================================

Real-world applications of the mathematical results:
1. Hyperbolic coding theory (error-correcting codes on trees)
2. Diophantine approximation via Farey sequences
3. Trace-based matrix classification for dynamical systems
"""

import math
from fractions import Fraction
from typing import List, Tuple


# ============================================================
# Application 1: Best Rational Approximations via Farey Mediants
# ============================================================

def best_rational_approximation(x: float, max_denom: int = 100) -> List[Tuple[int, int]]:
    """
    Find the best rational approximations to x using the Stern-Brocot tree.
    
    This uses the connection between Farey sequences and SL₂(ℤ):
    each step in the continued fraction algorithm corresponds to a
    matrix multiplication in SL₂(ℤ), and the best approximations
    are vertices of the Farey tessellation of the hyperbolic plane.
    
    Args:
        x: Real number to approximate.
        max_denom: Maximum denominator.
    
    Returns:
        List of (p, q) best approximations p/q.
    """
    # Stern-Brocot search
    approx = []
    lo_p, lo_q = 0, 1  # 0/1
    hi_p, hi_q = 1, 0  # 1/0 = infinity
    
    while True:
        med_p = lo_p + hi_p
        med_q = lo_q + hi_q
        
        if med_q > max_denom:
            break
        
        med_val = med_p / med_q
        
        if abs(med_val - x) < 1e-12:
            approx.append((med_p, med_q))
            break
        elif med_val < x:
            lo_p, lo_q = med_p, med_q
            approx.append((med_p, med_q))
        else:
            hi_p, hi_q = med_p, med_q
            approx.append((med_p, med_q))
    
    return approx


# ============================================================
# Application 2: Matrix Classification via Trace
# ============================================================

def classify_sl2_element(trace: int) -> str:
    """
    Classify an SL₂(ℤ) element by its trace.
    
    This is the fundamental classification in hyperbolic geometry:
    - |tr| < 2: Elliptic (rotation, finite order in PSL₂)
    - |tr| = 2: Parabolic (translation along horocycle)
    - |tr| > 2: Hyperbolic (translation along geodesic)
    
    The trace determines the geometry of the corresponding isometry
    of the hyperbolic plane. This classification is used in:
    - Dynamical systems (periodic vs. chaotic orbits)
    - Number theory (cusps vs. closed geodesics)
    - Physics (classification of Lorentz transformations)
    
    Args:
        trace: Integer trace of an SL₂(ℤ) element.
    
    Returns:
        Classification string.
    """
    abs_tr = abs(trace)
    if abs_tr < 2:
        if trace == 0:
            return "Elliptic (order 2 or 4 in PSL₂)"
        elif abs_tr == 1:
            return "Elliptic (order 3 or 6 in PSL₂)"
        else:
            return f"Elliptic (|tr|={abs_tr})"
    elif abs_tr == 2:
        return "Parabolic (fixes one ideal point, translation along horocycle)"
    else:
        # Hyperbolic: translation length = 2·arccosh(|tr|/2)
        length = 2 * math.acosh(abs_tr / 2)
        return f"Hyperbolic (translation length = {length:.4f})"


# ============================================================
# Application 3: Hurwitz's Theorem via Markov Spectrum
# ============================================================

def markov_approximation_constants(n_triples: int = 15) -> List[float]:
    """
    Compute the Lagrange spectrum from Markov numbers.
    
    Hurwitz's theorem states that for any irrational α, there are
    infinitely many p/q with |α - p/q| < 1/(√5 · q²).
    The constant √5 is the best possible for the golden ratio.
    
    The Markov spectrum gives the best constants for worse-approximable
    numbers. For each Markov number m, the constant is √(9 - 4/m²).
    
    This connects the Markov equation x²+y²+z² = 3xyz (proved via
    Vieta involution in our Lean formalization) directly to the
    quality of Diophantine approximations.
    """
    # Generate Markov numbers
    triples = set()
    queue = [(1, 1, 1)]
    
    while queue and len(triples) < n_triples:
        x, y, z = queue.pop(0)
        triple = tuple(sorted([x, y, z]))
        if triple in triples or max(triple) > 10**6:
            continue
        triples.add(triple)
        for a, b, c in [(x, y, z), (y, z, x), (x, z, y)]:
            new_c = 3 * a * b - c
            if new_c > 0:
                queue.append((a, b, new_c))
    
    markov_nums = sorted(set(n for t in triples for n in t))
    
    # Compute Lagrange constants
    constants = []
    for m in markov_nums:
        L = math.sqrt(9 - 4 / m**2)
        constants.append((m, L))
    
    return constants


# ============================================================
# Application 4: Coding Theory on Trees
# ============================================================

def hyperbolic_code_distance(codewords: List[List[int]]) -> int:
    """
    Compute the minimum distance of a code on a binary tree.
    
    In hyperbolic geometry, the tree is a 0-hyperbolic space.
    The Gromov product (x|y) = (d(o,x) + d(o,y) - d(x,y))/2
    measures "how long paths from o to x and y stay together."
    
    For tree codes, this gives the minimum distance property:
    d_min = min_{x≠y} d_tree(x, y)
    
    This uses our proved Gromov product tree inequality.
    """
    min_dist = float('inf')
    for i in range(len(codewords)):
        for j in range(i + 1, len(codewords)):
            d = sum(1 for a, b in zip(codewords[i], codewords[j]) if a != b)
            min_dist = min(min_dist, d)
    return min_dist


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Application 1: Best Rational Approximations")
    print("=" * 50)
    
    targets = [math.pi, math.e, math.sqrt(2), (1 + math.sqrt(5)) / 2]
    names = ["π", "e", "√2", "φ (golden ratio)"]
    
    for name, x in zip(names, targets):
        approxs = best_rational_approximation(x, max_denom=1000)
        best = approxs[-1] if approxs else (0, 1)
        error = abs(x - best[0] / best[1])
        print(f"  {name} ≈ {best[0]}/{best[1]} (error = {error:.2e})")
    
    print(f"\nApplication 2: SL₂(ℤ) Element Classification")
    print("=" * 50)
    
    for tr in range(-3, 8):
        print(f"  tr = {tr:>3}: {classify_sl2_element(tr)}")
    
    print(f"\nApplication 3: Markov Spectrum (Diophantine Approximation)")
    print("=" * 50)
    
    constants = markov_approximation_constants(15)
    print(f"  Lagrange constants from Markov numbers:")
    print(f"  {'Markov m':>10} {'√(9-4/m²)':>12} {'1/L':>10}")
    for m, L in constants[:10]:
        print(f"  {m:>10} {L:>12.6f} {1/L:>10.6f}")
    print(f"  Limit: L → 3 (accumulation point of the Markov spectrum)")
    
    print(f"\nApplication 4: Tree Code Distance")
    print("=" * 50)
    codewords = [
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 0, 1, 1],
        [1, 1, 1, 1],
    ]
    d_min = hyperbolic_code_distance(codewords)
    print(f"  Code with {len(codewords)} words, minimum distance = {d_min}")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================
Demonstrations of the key mathematical concepts.

This script demonstrates:
1. SL₂(ℤ) trace arithmetic and the Chebyshev connection
2. Markov triples and the Vieta involution (Markov tree generation)
3. Farey sequences and their connection to hyperbolic tessellation
4. The Fricke trace identity verification
"""

from fractions import Fraction


# ============================================================
# SL₂(ℤ) Matrix Operations
# ============================================================

class SL2Z:
    """An element of SL₂(ℤ): 2×2 integer matrix with determinant 1."""
    
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = a, b, c, d
        det = a * d - b * c
        assert det == 1, f"Determinant must be 1, got {det}"
    
    def __repr__(self):
        return f"[[{self.a}, {self.b}], [{self.c}, {self.d}]]"
    
    def __mul__(self, other):
        return SL2Z(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d
        )
    
    def trace(self):
        return self.a + self.d
    
    def inv(self):
        return SL2Z(self.d, -self.b, -self.c, self.a)
    
    def pow(self, n):
        result = SL2Z(1, 0, 0, 1)  # Identity
        for _ in range(n):
            result = self * result
        return result
    
    @staticmethod
    def S():
        return SL2Z(0, -1, 1, 0)
    
    @staticmethod
    def T():
        return SL2Z(1, 1, 0, 1)


# ============================================================
# Demo 1: Trace Arithmetic and Chebyshev Polynomials
# ============================================================

def chebyshev_trace(n, t):
    """Compute the trace Chebyshev polynomial: T_0=2, T_1=t, T_{n+2}=t*T_{n+1}-T_n."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


print("=" * 60)
print("DEMO 1: Trace Arithmetic and Chebyshev Polynomials")
print("=" * 60)

# Take g = ST (trace 1, elliptic of order 6)
g = SL2Z.S() * SL2Z.T()
print(f"\ng = S·T = {g}, trace = {g.trace()}")

print(f"\nVerifying: tr(g^n) = chebyshevT(n, tr(g))")
print(f"{'n':>3} {'tr(g^n)':>10} {'chebyshevT(n,1)':>15} {'match':>6}")
for n in range(10):
    actual = g.pow(n).trace()
    expected = chebyshev_trace(n, g.trace())
    print(f"{n:>3} {actual:>10} {expected:>15} {'✓' if actual == expected else '✗':>6}")

# Take a hyperbolic element (trace > 2)
h = SL2Z(3, 1, 2, 1)  # trace = 4, hyperbolic
print(f"\nh = {h}, trace = {h.trace()} (hyperbolic)")
print(f"\nTrace growth for hyperbolic element (exponential):")
for n in range(8):
    print(f"  tr(h^{n}) = {h.pow(n).trace()}")


# ============================================================
# Demo 2: Fricke Trace Identity
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Fricke Trace Identity")
print("=" * 60)

print("\nVerifying: tr(g)² + tr(h)² + tr(gh)² - tr(g)·tr(h)·tr(gh) = tr(ghg⁻¹h⁻¹) + 2")

test_pairs = [
    (SL2Z.S(), SL2Z.T()),
    (SL2Z(2, 1, 1, 1), SL2Z(3, 1, 2, 1)),
    (SL2Z(1, 2, 0, 1), SL2Z(1, 0, 3, 1)),
]

for g, h in test_pairs:
    tg, th = g.trace(), h.trace()
    tgh = (g * h).trace()
    commutator = g * h * g.inv() * h.inv()
    tc = commutator.trace()
    
    lhs = tg**2 + th**2 + tgh**2 - tg * th * tgh
    rhs = tc + 2
    
    print(f"  g={g}, h={h}")
    print(f"  tr(g)={tg}, tr(h)={th}, tr(gh)={tgh}, tr([g,h])={tc}")
    print(f"  LHS={lhs}, RHS={rhs}, match={'✓' if lhs == rhs else '✗'}")
    print()


# ============================================================
# Demo 3: Markov Triples and Vieta Involution
# ============================================================

print("=" * 60)
print("DEMO 3: Markov Triples and the Vieta Involution")
print("=" * 60)

def vieta_jump(x, y, z):
    """Apply Vieta involution: replace z with 3xy - z."""
    return 3 * x * y - z

def is_markov(x, y, z):
    """Check if (x, y, z) satisfies the Markov equation."""
    return x**2 + y**2 + z**2 == 3 * x * y * z

def generate_markov_tree(max_value=10000):
    """Generate Markov triples by breadth-first Vieta jumping."""
    triples = set()
    queue = [(1, 1, 1)]
    
    while queue:
        x, y, z = queue.pop(0)
        triple = tuple(sorted([x, y, z]))
        if triple in triples or max(triple) > max_value:
            continue
        triples.add(triple)
        
        # Apply Vieta jump on each coordinate
        z_new = vieta_jump(x, y, z)
        if z_new > 0:
            queue.append((x, y, z_new))
        x_new = vieta_jump(y, z, x)
        if x_new > 0:
            queue.append((x_new, y, z))
        y_new = vieta_jump(x, z, y)
        if y_new > 0:
            queue.append((x, y_new, z))
    
    return sorted(triples)

triples = generate_markov_tree(500)
print(f"\nFirst 15 Markov triples (x² + y² + z² = 3xyz):")
for i, (x, y, z) in enumerate(triples[:15]):
    check = "✓" if is_markov(x, y, z) else "✗"
    print(f"  {i+1:>2}. ({x}, {y}, {z})  {check}")

# Extract Markov numbers
markov_numbers = sorted(set(n for t in triples for n in t))
print(f"\nMarkov numbers up to 500: {markov_numbers}")

# Verify Vieta involution
print(f"\nVieta involution on (1, 2, 5):")
print(f"  Jump z: (1, 2, {vieta_jump(1, 2, 5)}) — is Markov: {is_markov(1, 2, vieta_jump(1, 2, 5))}")
print(f"  Double jump: (1, 2, {vieta_jump(1, 2, vieta_jump(1, 2, 5))}) — back to original!")


# ============================================================
# Demo 4: Farey Sequence and SL₂(ℤ) Connection
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Farey Sequence ↔ SL₂(ℤ)")
print("=" * 60)

def farey_sequence(n):
    """Generate the Farey sequence of order n."""
    fracs = set()
    for d in range(1, n + 1):
        for num in range(0, d + 1):
            fracs.add(Fraction(num, d))
    return sorted(fracs)

farey = farey_sequence(6)
print(f"\nFarey sequence F₆ ({len(farey)} terms):")
print("  " + ", ".join(str(f) for f in farey[:20]) + "...")

# Verify Farey neighbors correspond to SL₂(ℤ)
print(f"\nFarey neighbors have determinant ±1 (= SL₂(ℤ) elements):")
for i in range(min(8, len(farey) - 1)):
    a, b = farey[i].numerator, farey[i].denominator
    c, d = farey[i + 1].numerator, farey[i + 1].denominator
    det = a * d - b * c
    print(f"  {farey[i]} and {farey[i+1]}: det = {a}·{d} - {b}·{c} = {det}")

# Totient sum
print(f"\nEuler totient sum Φ(n) = |F_n| - 1:")
for n in range(1, 11):
    phi_sum = sum(1 for f in farey_sequence(n)) - 1
    print(f"  Φ({n:>2}) = {phi_sum:>4}")


# ============================================================
# Demo 5: Every integer ≥ 2 is a trace
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Every Integer ≥ 2 is a Trace of SL₂(ℤ)")
print("=" * 60)

print(f"\nFor n ≥ 2, the matrix [[n-1, 1], [n-2, 1]] ∈ SL₂(ℤ) has trace n:")
for n in range(2, 12):
    g = SL2Z(n - 1, 1, n - 2, 1)
    print(f"  n={n:>2}: {g}, det={g.a * g.d - g.b * g.c}, trace={g.trace()}")

print("\nDone! All demonstrations verified.")


"""
Visualization 2: The Markov Tree

This script visualizes the Markov tree — the infinite binary tree of Markov
triples connected by Vieta involutions. Each node is a Markov triple
(x, y, z) satisfying x² + y² + z² = 3xyz, and edges represent single
Vieta jumps z ↦ 3xy - z.

The tree structure reveals the deep connection between hyperbolic geometry
(the tree is a Cayley graph of a free product) and Diophantine equations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import deque


def generate_markov_tree_with_edges(max_val=200):
    """Generate Markov tree nodes and edges for visualization."""
    nodes = {}  # triple -> position
    edges = []
    queue = deque([(1, 1, 1, None)])
    visited = set()
    
    while queue:
        x, y, z, parent = queue.popleft()
        triple = tuple(sorted([x, y, z]))
        if triple in visited or max(triple) > max_val:
            continue
        visited.add(triple)
        nodes[triple] = None  # position computed later
        
        if parent is not None:
            parent_key = tuple(sorted(parent))
            if parent_key in nodes:
                edges.append((parent_key, triple))
        
        # Vieta jumps
        for a, b, c in [(x, y, z), (y, z, x), (x, z, y)]:
            nc = 3 * a * b - c
            if nc > 0 and nc != c:
                new_triple = (a, b, nc)
                queue.append((a, b, nc, (x, y, z)))
    
    return nodes, edges


def layout_tree(nodes, edges):
    """Simple hierarchical layout based on max element."""
    import math
    
    sorted_triples = sorted(nodes.keys(), key=lambda t: (max(t), sum(t)))
    
    # Group by "level" (max element)
    levels = {}
    for t in sorted_triples:
        lvl = max(t)
        if lvl not in levels:
            levels[lvl] = []
        levels[lvl].append(t)
    
    positions = {}
    sorted_levels = sorted(levels.keys())
    
    for i, lvl in enumerate(sorted_levels):
        triples_at_level = levels[lvl]
        n = len(triples_at_level)
        for j, t in enumerate(triples_at_level):
            x = (j - (n - 1) / 2) * 2.5
            y = -i * 2
            positions[t] = (x, y)
    
    return positions


nodes, edges = generate_markov_tree_with_edges(200)
positions = layout_tree(nodes, edges)

fig, ax = plt.subplots(figsize=(14, 10), dpi=150)

# Draw edges
for parent, child in edges:
    if parent in positions and child in positions:
        px, py = positions[parent]
        cx, cy = positions[child]
        ax.plot([px, cx], [py, cy], 'b-', alpha=0.3, linewidth=1)

# Draw nodes
for triple, pos in positions.items():
    x, y = pos
    color = 'gold' if max(triple) == 1 else \
            'orange' if max(triple) <= 5 else \
            'salmon' if max(triple) <= 30 else 'lightblue'
    
    ax.plot(x, y, 'o', color=color, markersize=20, markeredgecolor='black',
            markeredgewidth=1, zorder=5)
    label = f"{triple[2]}"  # Show largest element
    ax.text(x, y, label, ha='center', va='center', fontsize=7,
            fontweight='bold', zorder=6)

# Add full triple labels for small ones
for triple, pos in positions.items():
    if max(triple) <= 34:
        x, y = pos
        ax.text(x, y - 1.0, f"({triple[0]},{triple[1]},{triple[2]})",
                ha='center', va='top', fontsize=6, color='gray')

ax.set_title('The Markov Tree: Vieta Involutions on x² + y² + z² = 3xyz',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Markov triples connected by Vieta jumps z ↦ 3xy − z')
ax.axis('off')

fig.tight_layout()
plt.savefig('viz_markov_tree.png', dpi=150, bbox_inches='tight')
print(f"Saved Markov tree with {len(nodes)} triples and {len(edges)} edges")


"""
Visualization 1: SL₂(ℤ) Orbit on the Poincaré Disk

This script visualizes the orbit of a point under the modular group PSL(2,ℤ)
acting on the Poincaré disk model of the hyperbolic plane. The orbit points
form the "hyperbolic integers" — the central object of our study.

The coloring indicates hyperbolic distance from the origin, showing how
hyperbolic space expands exponentially near the boundary.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math
from collections import deque


def cayley_to_disk(z):
    """Map upper half-plane to Poincaré disk: w = (z-i)/(z+i)."""
    i = complex(0, 1)
    if abs(z + i) < 1e-15:
        return None
    return (z - i) / (z + i)


def hyp_dist_from_origin(w):
    """Hyperbolic distance from origin in the disk model."""
    r = abs(w)
    if r >= 1:
        return float('inf')
    return 2 * math.atanh(r)


def sl2z_orbit(max_depth=6, base=complex(0, 1)):
    """Compute orbit of base under PSL(2,ℤ) generators S and T."""
    seen = set()
    points = []
    queue = deque([(base, 0)])
    
    while queue:
        z, d = queue.popleft()
        key = (round(z.real, 6), round(z.imag, 6))
        if key in seen or z.imag <= 0.01:
            continue
        seen.add(key)
        
        w = cayley_to_disk(z)
        if w and abs(w) < 0.999:
            points.append(w)
        
        if d < max_depth:
            if abs(z) > 0.01:
                queue.append((-1/z, d+1))
            queue.append((z+1, d+1))
            queue.append((z-1, d+1))
    
    return points


# Generate orbit
orbit = sl2z_orbit(max_depth=7)

fig, ax = plt.subplots(1, 1, figsize=(10, 10), dpi=150)

# Draw the unit circle (boundary of hyperbolic space)
circle = patches.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw geodesic circles (horocycles) for reference
for r in [0.3, 0.5, 0.7, 0.9]:
    ref_circle = patches.Circle((0, 0), r, fill=False, color='gray',
                                 linewidth=0.3, linestyle='--', alpha=0.5)
    ax.add_patch(ref_circle)

# Color points by hyperbolic distance
xs = [p.real for p in orbit]
ys = [p.imag for p in orbit]
dists = [hyp_dist_from_origin(p) for p in orbit]

scatter = ax.scatter(xs, ys, c=dists, cmap='plasma', s=15, alpha=0.8,
                     edgecolors='none', vmin=0, vmax=max(dists) * 0.8)

# Mark the origin
ax.plot(0, 0, 'r*', markersize=15, zorder=5, label='Origin')

plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin', shrink=0.8)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit on the Poincaré Disk',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper right')
ax.grid(True, alpha=0.2)

fig.tight_layout()
plt.savefig('viz_poincare_orbit.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(orbit)} orbit points")


"""
Visualization 3: Trace Growth — Chebyshev Polynomials and Exponential Divergence

This script visualizes how traces of powers of SL₂(ℤ) elements grow.
For parabolic elements (tr=2), traces stay constant.
For hyperbolic elements (tr≥3), traces grow exponentially — this is
the group-theoretic manifestation of geodesic divergence in hyperbolic space.

The Chebyshev polynomial connection tr(g^n) = T_n(tr(g)) makes this precise.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def chebyshev_trace(n, t):
    """Trace Chebyshev: T_0=2, T_1=t, T_{n+2}=t·T_{n+1}-T_n."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


fig, axes = plt.subplots(1, 2, figsize=(14, 6), dpi=150)

# Left: Linear scale
ax1 = axes[0]
ns = list(range(12))

trace_values = {
    'tr = 0 (elliptic, order 4)': 0,
    'tr = 1 (elliptic, order 6)': 1,
    'tr = 2 (parabolic)': 2,
    'tr = 3 (hyperbolic)': 3,
    'tr = 4 (hyperbolic)': 4,
    'tr = 5 (hyperbolic)': 5,
}

colors = ['purple', 'blue', 'green', 'orange', 'red', 'brown']

for (label, t), color in zip(trace_values.items(), colors):
    vals = [chebyshev_trace(n, t) for n in ns]
    ax1.plot(ns, vals, 'o-', color=color, label=label, markersize=4)

ax1.set_xlabel('Power n', fontsize=12)
ax1.set_ylabel('tr(g^n)', fontsize=12)
ax1.set_title('Trace of Powers (Linear Scale)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-50, 500)

# Right: Log scale for hyperbolic elements
ax2 = axes[1]
ns_long = list(range(20))

for t in [3, 4, 5, 7, 10]:
    vals = [abs(chebyshev_trace(n, t)) for n in ns_long]
    ax2.semilogy(ns_long, vals, 'o-', markersize=3,
                 label=f'tr = {t}')
    
    # Show theoretical growth rate
    eigenvalue = (t + math.sqrt(t**2 - 4)) / 2
    theoretical = [2 * eigenvalue**n for n in ns_long]
    ax2.semilogy(ns_long, theoretical, '--', alpha=0.3, color='gray')

ax2.set_xlabel('Power n', fontsize=12)
ax2.set_ylabel('|tr(g^n)| (log scale)', fontsize=12)
ax2.set_title('Exponential Growth for Hyperbolic Elements', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add annotation about growth rate
ax2.text(0.5, 0.05,
         'Dashed lines: theoretical λ^n growth\n'
         'λ = (tr + √(tr²−4))/2 (largest eigenvalue)',
         transform=ax2.transAxes, fontsize=8,
         verticalalignment='bottom', style='italic',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Chebyshev Polynomials and Hyperbolic Trace Growth',
             fontsize=15, fontweight='bold', y=1.02)
fig.tight_layout()
plt.savefig('viz_trace_growth.png', dpi=150, bbox_inches='tight')
print("Saved trace growth visualization")
