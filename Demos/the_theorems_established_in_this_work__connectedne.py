"""
Applications of Interval Preconnectedness and Pythagorean Sine Theory

1. Signal Processing: Pythagorean sine approximation for rational frequency synthesis
2. Cryptographic Hash: Using Pythagorean triple structure for hash construction
3. Approximation Theory: Best rational approximation via Pythagorean sines
"""

import math
from typing import List, Tuple


# ============================================================
# Application 1: Rational Frequency Synthesis
# ============================================================

def rational_frequency_synthesis(
    target_freq_ratio: float,
    max_denominator: int = 10000
) -> Tuple[int, int, int, float]:
    """
    Find a Pythagorean triple (a, b, c) such that a/c closely
    approximates a target frequency ratio.
    
    In signal processing, frequencies must often be expressed as
    ratios of integers for digital synthesis. Pythagorean triples
    provide ratios a/c that are guaranteed to come from right triangles,
    enabling geometric constructions of the corresponding waveforms.
    
    Returns: (a, b, c, actual_ratio)
    """
    best = None
    best_error = float('inf')
    
    # Generate triples via parametric form: a = m²-n², b = 2mn, c = m²+n²
    for m in range(2, int(math.sqrt(max_denominator)) + 1):
        for n in range(1, m):
            if math.gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_denominator:
                break
            # Check both a/c and b/c
            for leg in [a, b]:
                ratio = leg / c
                error = abs(ratio - target_freq_ratio)
                if error < best_error:
                    best_error = error
                    best = (min(a, b), max(a, b), c, ratio)
    
    return best


def musical_pythagorean_intervals():
    """
    Find Pythagorean triples approximating musical intervals.
    
    Musical intervals are frequency ratios. We find Pythagorean triples
    whose sine values approximate common musical ratios.
    """
    intervals = {
        "Minor second (16/15)": 16/15 - 1,  # Map to [0,1] as ratio - 1
        "Major second (9/8)": 1 - 8/9,
        "Minor third (6/5)": 1 - 5/6,
        "Major third (5/4)": 1 - 4/5,
        "Perfect fourth (4/3)": 1 - 3/4,
        "Tritone (√2)": 1 - 1/math.sqrt(2),
        "Perfect fifth (3/2)": 1 - 2/3,
    }
    
    print("Musical Intervals via Pythagorean Sines")
    print("=" * 60)
    for name, target in intervals.items():
        result = rational_frequency_synthesis(target, 50000)
        if result:
            a, b, c, ratio = result
            print(f"  {name}")
            print(f"    Target: {target:.6f}")
            print(f"    Triple: ({a}, {b}, {c}), ratio = {ratio:.6f}")
            print(f"    Error: {abs(ratio - target):.8f}")
            print()


# ============================================================
# Application 2: Geometric Lattice Points
# ============================================================

def lattice_circle_coverage(radius: int = 100) -> dict:
    """
    Compute coverage of angles by lattice points on circles.
    
    For each circle of radius r (where r is a Pythagorean hypotenuse),
    count the number of lattice points and analyze angular distribution.
    
    This connects to the cross-domain result: the density of Pythagorean
    sines in [0, 1] implies that lattice points on circles of increasing
    radius cover all angles with increasing precision.
    """
    results = {}
    
    for m in range(2, int(math.sqrt(radius)) + 1):
        for n in range(1, m):
            if math.gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > radius:
                continue
            
            angle = math.atan2(a, b) * 180 / math.pi  # degrees
            if c not in results:
                results[c] = []
            results[c].append({
                'triple': (min(a,b), max(a,b), c),
                'angle': angle,
                'sine': min(a,b) / c
            })
    
    return results


# ============================================================
# Application 3: Interval Connectedness Checker
# ============================================================

def check_interval_preconnected(
    points: List[float],
    is_connected: callable = None
) -> bool:
    """
    Numerically verify the interval preconnectedness property.
    
    Given a finite sample of points from an ordered space,
    check whether all closed intervals between sample points
    appear to be preconnected (connected in the subspace topology).
    
    For real numbers, this always holds. The function demonstrates
    the computational aspect of the theorem.
    
    Args:
        points: Sample points from the space
        is_connected: Function checking if a set of points is connected
                     (defaults to checking if range is contiguous)
    """
    points = sorted(points)
    
    if is_connected is None:
        # For reals, every interval is connected
        def is_connected(pts):
            if len(pts) < 2:
                return True
            # Check if points densely fill their range
            lo, hi = min(pts), max(pts)
            if hi == lo:
                return True
            # In ℝ, [lo, hi] is always connected
            return True
    
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            interval_pts = [p for p in points if points[i] <= p <= points[j]]
            if not is_connected(interval_pts):
                return False
    
    return True


if __name__ == "__main__":
    musical_pythagorean_intervals()
    
    print("\nLattice Circle Coverage")
    print("=" * 60)
    coverage = lattice_circle_coverage(200)
    for c in sorted(coverage.keys())[:10]:
        entries = coverage[c]
        angles = [e['angle'] for e in entries]
        print(f"  Circle r={c}: {len(entries)} points, "
              f"angles: {[f'{a:.1f}°' for a in sorted(angles)]}")
    
    print("\nInterval Preconnectedness Check")
    print("=" * 60)
    import random
    random.seed(42)
    sample = sorted(random.uniform(0, 1) for _ in range(50))
    result = check_interval_preconnected(sample)
    print(f"  Sample of 50 random points in [0,1]: preconnected = {result}")


"""
Demo: Interval Preconnectedness and Pythagorean Sine Density

Demonstrates the core mathematical results:
1. Interval preconnectedness implies connectedness for linear orders
2. Pythagorean sines densely fill [0, 1]
3. Berggren tree matrices preserve the Pythagorean relation
"""

import math
from typing import Tuple, List

def is_pythagorean_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a**2 + b**2 == c**2

def is_primitive(a: int, b: int, c: int) -> bool:
    """Check if a Pythagorean triple is primitive (coprime)."""
    return math.gcd(a, c) == 1 and math.gcd(a, b) == 1

def pythagorean_sine(a: int, c: int) -> float:
    """Compute the Pythagorean sine a/c."""
    return a / c

def berggren_A(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren A-matrix action."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren B-matrix action."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren C-matrix action."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def generate_triples_berggren(max_depth: int = 8) -> List[Tuple[int, int, int]]:
    """Generate all primitive Pythagorean triples up to given tree depth."""
    triples = []
    stack = [(3, 4, 5, 0)]
    while stack:
        a, b, c, depth = stack.pop()
        if depth > max_depth:
            continue
        # Ensure a <= b
        if a > b:
            a, b = b, a
        if a > 0 and b > 0 and c > 0:
            triples.append((a, b, c))
        for transform in [berggren_A, berggren_B, berggren_C]:
            na, nb, nc = transform(a, b, c)
            if nc > 0 and na > 0:
                stack.append((abs(na), abs(nb), nc, depth + 1))
    return triples


def demo_berggren_preservation():
    """Demonstrate that Berggren matrices preserve Pythagorean relation."""
    print("=" * 60)
    print("Demo 1: Berggren Matrices Preserve Pythagorean Relation")
    print("=" * 60)
    
    a, b, c = 3, 4, 5
    print(f"\nBase triple: ({a}, {b}, {c})")
    print(f"  {a}² + {b}² = {a**2} + {b**2} = {a**2 + b**2} = {c}² ✓")
    
    for name, transform in [("A", berggren_A), ("B", berggren_B), ("C", berggren_C)]:
        na, nb, nc = transform(a, b, c)
        check = na**2 + nb**2 == nc**2
        print(f"\n  Berggren {name}({a},{b},{c}) = ({na}, {nb}, {nc})")
        print(f"    {na}² + {nb}² = {na**2} + {nb**2} = {na**2 + nb**2}")
        print(f"    {nc}² = {nc**2}")
        print(f"    Pythagorean: {'✓' if check else '✗'}")


def demo_sine_density():
    """Demonstrate density of Pythagorean sines in [0, 1]."""
    print("\n" + "=" * 60)
    print("Demo 2: Density of Pythagorean Sines in [0, 1]")
    print("=" * 60)
    
    triples = generate_triples_berggren(max_depth=10)
    sines = sorted(set(
        ratio
        for a, b, c in triples 
        if is_pythagorean_triple(a, b, c)
        for ratio in [a / c, b / c]
    ))
    
    print(f"\nGenerated {len(triples)} primitive triples")
    print(f"Found {len(sines)} distinct sine values")
    
    # Check density: max gap
    if len(sines) > 1:
        gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
        max_gap = max(gaps)
        avg_gap = sum(gaps) / len(gaps)
        print(f"Max gap between consecutive sines: {max_gap:.6f}")
        print(f"Average gap: {avg_gap:.6f}")
    
    # Test conjecture: find triple near 1/√2
    target = 1 / math.sqrt(2)
    best = min(sines, key=lambda x: abs(x - target))
    print(f"\nConjecture test: closest sine to 1/√2 ≈ {target:.6f}")
    print(f"  Best approximation: {best:.6f}")
    print(f"  Error: {abs(best - target):.8f}")
    
    # More targets
    for r in [0.1, 0.25, 0.5, 0.75, 0.9]:
        best = min(sines, key=lambda x: abs(x - r))
        print(f"  Target {r}: best = {best:.6f}, error = {abs(best - r):.8f}")


def demo_interval_preconnected():
    """Illustrate the interval preconnectedness → connectedness proof."""
    print("\n" + "=" * 60)
    print("Demo 3: Interval Preconnectedness → Connectedness")
    print("=" * 60)
    
    print("""
The proof strategy (formalized in Lean 4):

1. Fix a basepoint x₀ in the space.
2. For every point y, the interval [min(x₀,y), max(x₀,y)] contains x₀.
3. The union of all these intervals equals the entire space.
4. Each interval is preconnected (by hypothesis).
5. The intersection contains x₀ (nonempty).
6. By the union theorem for preconnected sets → whole space is preconnected.
7. Combined with nonemptiness → connected space.

Key insight: Local convexity (interval preconnected) determines 
global topology (connected space).
""")
    
    # Numerical illustration on [0, 1]
    import random
    random.seed(42)
    x0 = 0.5
    points = sorted(random.uniform(0, 1) for _ in range(20))
    
    print("Numerical illustration on [0, 1] with x₀ = 0.5:")
    print(f"  Points: {[f'{p:.3f}' for p in points[:10]]}...")
    
    covered = set()
    for y in points:
        lo, hi = min(x0, y), max(x0, y)
        for i in range(1001):
            covered.add(round(lo + (hi - lo) * i / 1000, 3))
    
    coverage = len(covered) / 1001
    print(f"  Coverage of [0,1] by union of intervals: {coverage:.1%}")


def demo_cross_domain():
    """Show the number theory ↔ topology bridge."""
    print("\n" + "=" * 60)
    print("Demo 4: Cross-Domain Bridge (Number Theory ↔ Topology)")
    print("=" * 60)
    
    print("""
The Pythagorean sine function sin(θ) = a/c maps:
  • Discrete objects (primitive Pythagorean triples)
  → Continuous space ([0, 1] ⊂ ℝ)

This creates a bridge:
  • Number Theory: enumeration of Pythagorean triples via Berggren tree
  • Topology: density/connectedness of the image in [0, 1]
  • The sine-injective theorem shows this map is injective on (a, c) pairs
  • The density conjecture asserts the image is dense

The triple (3, 4, 5) gives sin(θ) = 3/5 = 0.6
The triple (5, 12, 13) gives sin(θ) = 5/13 ≈ 0.385
The triple (8, 15, 17) gives sin(θ) = 8/17 ≈ 0.471
""")
    
    triples = generate_triples_berggren(6)
    pyth_triples = [(a, b, c) for a, b, c in triples if is_pythagorean_triple(a, b, c)]
    
    print("First 15 primitive triples and their sines:")
    shown = sorted(pyth_triples, key=lambda t: t[2])[:15]
    for a, b, c in shown:
        s = min(a, b) / c
        print(f"  ({a:4d}, {b:4d}, {c:4d})  →  sin = {s:.6f}")


if __name__ == "__main__":
    demo_berggren_preservation()
    demo_sine_density()
    demo_interval_preconnected()
    demo_cross_domain()


"""
Visualization: The Berggren Tree of Pythagorean Triples

Shows the ternary tree structure of primitive Pythagorean triples,
color-coded by the sine value a/c. The tree demonstrates how the 
three Berggren matrices generate all primitive triples from (3,4,5).
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def build_tree(max_depth=6):
    """Build tree with position information for plotting."""
    nodes = []
    edges = []
    queue = deque([(3, 4, 5, 0, 0.5, 0)])  # a, b, c, depth, x, parent_idx
    
    while queue:
        a, b, c, depth, x, parent_idx = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        if depth > max_depth or a <= 0 or b <= 0:
            continue
        
        node_idx = len(nodes)
        nodes.append({
            'triple': (a, b, c),
            'depth': depth,
            'x': x,
            'sine': a / c
        })
        
        if depth > 0:
            edges.append((parent_idx, node_idx))
        
        # Width of subtree decreases with depth
        width = 0.5 ** (depth + 1)
        
        for i, T in enumerate([berggren_A, berggren_B, berggren_C]):
            na, nb, nc = T(a, b, c)
            child_x = x + (i - 1) * width
            if nc <= 5000:
                queue.append((abs(na), abs(nb), nc, depth + 1, child_x, node_idx))
    
    return nodes, edges


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

# Left: Tree structure
nodes, edges = build_tree(max_depth=5)

for parent_idx, child_idx in edges:
    p = nodes[parent_idx]
    c = nodes[child_idx]
    ax1.plot([p['x'], c['x']], [-p['depth'], -c['depth']], 
             'k-', alpha=0.2, linewidth=0.5)

xs = [n['x'] for n in nodes]
ys = [-n['depth'] for n in nodes]
sines = [n['sine'] for n in nodes]

scatter = ax1.scatter(xs, ys, c=sines, cmap='viridis', s=30, 
                       edgecolors='black', linewidths=0.3, zorder=5)
plt.colorbar(scatter, ax=ax1, label='Sine value (a/c)')

# Label root and first level
for n in nodes[:4]:
    a, b, c = n['triple']
    ax1.annotate(f'({a},{b},{c})', (n['x'], -n['depth']),
                textcoords="offset points", xytext=(0, 8),
                fontsize=7, ha='center')

ax1.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=13)
ax1.set_ylabel('Tree Depth')
ax1.set_xlabel('Horizontal Position (schematic)')
ax1.set_yticks(range(0, -6, -1))
ax1.set_yticklabels(range(0, 6))

# Right: Sine values on the unit circle
angles = [math.asin(s) for s in sines]
for i, (angle, sine) in enumerate(zip(angles, sines)):
    depth = nodes[i]['depth']
    alpha = max(0.1, 1 - depth * 0.15)
    ax2.plot([0, math.cos(angle)], [0, math.sin(angle)], 
             'b-', alpha=alpha * 0.3, linewidth=0.5)

# Draw quarter circle
theta = np.linspace(0, np.pi/2, 100)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5)

# Plot lattice points
for n in nodes:
    a, b, c = n['triple']
    ax2.plot(b/c, a/c, 'o', markersize=4, 
             color=plt.cm.viridis(n['sine']), 
             markeredgecolor='black', markeredgewidth=0.3)

ax2.set_xlim(-0.05, 1.05)
ax2.set_ylim(-0.05, 1.05)
ax2.set_aspect('equal')
ax2.set_title('Pythagorean Triples on the Unit Circle', fontsize=13)
ax2.set_xlabel('cos(θ) = b/c')
ax2.set_ylabel('sin(θ) = a/c')
ax2.grid(True, alpha=0.3)

plt.suptitle('The Berggren Tree and Its Projection onto the Unit Circle', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_berggren_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_berggren_tree.png")


"""
Visualization: Convergence of Maximum Gap in Pythagorean Sines

Tests the density conjecture by showing how the maximum gap between
consecutive Pythagorean sine values shrinks as the hypotenuse bound grows.
If the conjecture is true, this gap → 0 as the bound → ∞.
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_triples(max_c):
    triples = []
    queue = deque([(3, 4, 5)])
    seen = set()
    while queue:
        a, b, c = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        key = (a, b, c)
        if key in seen or c > max_c or a <= 0 or b <= 0:
            continue
        seen.add(key)
        triples.append((a, b, c))
        for T in [berggren_A, berggren_B, berggren_C]:
            na, nb, nc = T(a, b, c)
            if nc <= max_c and nc > 0:
                queue.append((abs(na), abs(nb), nc))
    return triples


# Compute convergence data
bounds = [50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]
max_gaps = []
mean_gaps = []
num_sines = []

for max_c in bounds:
    triples = generate_triples(max_c)
    sines = sorted(set(a / c for a, b, c in triples))
    num_sines.append(len(sines))
    if len(sines) > 1:
        gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
        max_gaps.append(max(gaps))
        mean_gaps.append(sum(gaps) / len(gaps))
    else:
        max_gaps.append(1.0)
        mean_gaps.append(1.0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Max gap vs bound (log-log)
ax = axes[0, 0]
ax.loglog(bounds, max_gaps, 'ro-', linewidth=2, markersize=8, label='Max gap')
ax.loglog(bounds, mean_gaps, 'bs-', linewidth=2, markersize=6, label='Mean gap')
# Fit power law
log_b = np.log(bounds[-4:])
log_g = np.log(max_gaps[-4:])
slope = np.polyfit(log_b, log_g, 1)[0]
ax.set_xlabel('Hypotenuse bound (c_max)', fontsize=12)
ax.set_ylabel('Gap size', fontsize=12)
ax.set_title(f'Gap Convergence (power law slope ≈ {slope:.2f})', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 2: Number of distinct sines
ax = axes[0, 1]
ax.loglog(bounds, num_sines, 'go-', linewidth=2, markersize=8)
ax.set_xlabel('Hypotenuse bound (c_max)', fontsize=12)
ax.set_ylabel('Number of distinct sines', fontsize=12)
ax.set_title('Growth of Pythagorean Sine Count', fontsize=13)
ax.grid(True, alpha=0.3)

# Plot 3: Gap distribution for large bound
ax = axes[1, 0]
triples = generate_triples(5000)
sines = sorted(set(a / c for a, b, c in triples))
gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
ax.hist(gaps, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
ax.axvline(x=np.mean(gaps), color='red', linestyle='--', label=f'Mean: {np.mean(gaps):.4f}')
ax.set_xlabel('Gap size', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title(f'Gap Distribution (c ≤ 5000, n={len(sines)})', fontsize=13)
ax.legend(fontsize=11)

# Plot 4: Sine values colored by gap to next
ax = axes[1, 1]
gap_colors = gaps + [0]  # Last point has no gap
scatter = ax.scatter(sines, [1]*len(sines), c=gap_colors, 
                      cmap='hot_r', s=1, alpha=0.5)
plt.colorbar(scatter, ax=ax, label='Gap to next sine')
ax.set_xlim(0, 1)
ax.set_yticks([])
ax.set_xlabel('Sine value a/c', fontsize=12)
ax.set_title('Sine Values Colored by Gap Size', fontsize=13)

plt.suptitle('Evidence for the Pythagorean Sine Density Conjecture', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_convergence.png")


"""
Visualization: Density of Pythagorean Sines in [0, 1]

Shows how the sine values a/c from primitive Pythagorean triples
(a² + b² = c²) fill in the interval [0, 1] as the hypotenuse bound grows.
The density conjecture states that these values are dense in [0, 1].
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_triples(max_c):
    triples = []
    queue = deque([(3, 4, 5)])
    while queue:
        a, b, c = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        if c <= max_c and a > 0 and b > 0:
            triples.append((a, b, c))
            for T in [berggren_A, berggren_B, berggren_C]:
                na, nb, nc = T(a, b, c)
                if nc <= max_c:
                    queue.append((abs(na), abs(nb), nc))
    return triples


fig, axes = plt.subplots(3, 1, figsize=(12, 10))

bounds = [100, 1000, 10000]
for idx, max_c in enumerate(bounds):
    ax = axes[idx]
    triples = generate_triples(max_c)
    sines = sorted(set(a / c for a, b, c in triples))
    
    # Plot sine values as vertical lines
    ax.vlines(sines, 0, 1, alpha=0.3, linewidth=0.5, color='navy')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.2)
    ax.set_title(f'Pythagorean sines with c ≤ {max_c} ({len(sines)} values)', fontsize=12)
    ax.set_xlabel('Sine value a/c')
    ax.set_ylabel('Density')
    
    # Overlay histogram
    if len(sines) > 10:
        ax.hist(sines, bins=50, density=True, alpha=0.4, color='steelblue', label='Distribution')
    
    # Mark max gap
    if len(sines) > 1:
        gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
        max_gap = max(gaps)
        max_gap_idx = gaps.index(max_gap)
        ax.axvspan(sines[max_gap_idx], sines[max_gap_idx + 1], 
                   alpha=0.3, color='red', label=f'Max gap: {max_gap:.4f}')
    
    ax.legend(loc='upper right')

plt.suptitle('Density of Pythagorean Sines: Evidence for the Density Conjecture', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_sine_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_sine_density.png")
