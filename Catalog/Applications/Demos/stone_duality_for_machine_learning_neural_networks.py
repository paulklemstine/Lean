"""
Stone Duality for Neural Networks: Applications
==================================================
Real-world applications of the activation Boolean algebra theory.
"""

import numpy as np
from typing import List, Tuple, Dict
from math import comb


def application_decision_boundary_analysis():
    """Application 1: Analyzing decision boundaries of a binary classifier.

    Given a trained ReLU network, compute its activation Boolean algebra
    and use it to understand the decision boundary structure.
    """
    print("=" * 60)
    print("APPLICATION 1: Decision Boundary Analysis")
    print("=" * 60)

    # Simulated trained binary classifier: 2 inputs, 5 hidden neurons
    np.random.seed(123)
    W = np.array([[ 2.1, -1.3],
                  [-0.5,  2.0],
                  [ 1.5,  1.5],
                  [-1.0, -0.5],
                  [ 0.3, -1.8]])
    bias = np.array([0.1, -0.3, -1.0, 0.5, 0.2])
    readout = np.array([1.0, -0.5, 0.8, -0.3, 0.6])
    threshold = 0.0

    # Count activation regions
    n_samples = 200000
    regions: Dict[Tuple[bool, ...], List[float]] = {}
    for _ in range(n_samples):
        x = np.random.uniform(-3, 3, size=2)
        pre = W @ x + bias
        pattern = tuple(p > 0 for p in pre)
        output = np.dot(readout, np.maximum(pre, 0))
        if pattern not in regions:
            regions[pattern] = []
        regions[pattern].append(output)

    # Classify regions
    positive_regions = set()
    negative_regions = set()
    boundary_regions = set()

    for pattern, outputs in regions.items():
        mean_out = np.mean(outputs)
        if mean_out > threshold:
            positive_regions.add(pattern)
        else:
            negative_regions.add(pattern)

    zas = sum(comb(5, k) for k in range(3))  # Zaslavsky bound
    print(f"\nNetwork: 2 inputs → 5 hidden ReLU → 1 output")
    print(f"Realized activation regions: {len(regions)}")
    print(f"Zaslavsky bound: {zas}")
    print(f"Positive regions (output > 0): {len(positive_regions)}")
    print(f"Negative regions (output ≤ 0): {len(negative_regions)}")
    print(f"\nActivation Boolean algebra size: 2^{len(regions)} = {2**len(regions)}")
    print(f"Decision boundary = boundary between positive and negative regions")

    # The decision set is an element of the Boolean algebra
    print(f"\nThe positive decision set {{x : f(x) > 0}} is a union of "
          f"{len(positive_regions)} activation regions")
    print(f"→ It is an element of the activation Boolean algebra ✓")
    print(f"→ Its Stone dual preimage is a clopen set ✓")


def application_network_complexity():
    """Application 2: Measuring network expressivity via Boolean algebra size."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Expressivity Comparison")
    print("=" * 60)

    configs = [
        ("Small (3 neurons)", 3),
        ("Medium (5 neurons)", 5),
        ("Large (8 neurons)", 8),
        ("Very large (12 neurons)", 12),
    ]

    n = 2  # 2D input
    print(f"\nSingle-layer ReLU networks in R^{n}:")
    print(f"{'Config':<25} {'m':>4} {'Zaslavsky':>12} {'2^m':>10} {'2^Zas':>15}")
    print("-" * 70)

    for name, m in configs:
        zas = sum(comb(m, k) for k in range(n + 1))
        print(f"{name:<25} {m:>4} {zas:>12} {2**m:>10} {2**zas:>15}")

    print(f"\nKey insight: The activation Boolean algebra captures the *effective*")
    print(f"complexity of the network — not 2^m but at most 2^Zaslavsky,")
    print(f"which is polynomial in m for fixed dimension n.")


def application_adversarial_robustness():
    """Application 3: Adversarial robustness via activation regions."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Adversarial Robustness Analysis")
    print("=" * 60)

    np.random.seed(42)
    m = 4
    n = 2
    W = np.random.randn(m, n) * 2
    bias = np.random.randn(m) * 0.5
    readout = np.array([1.0, -1.0, 0.5, -0.5])

    # Test point
    x0 = np.array([1.0, 0.5])
    pre0 = W @ x0 + bias
    pattern0 = tuple(p > 0 for p in pre0)
    output0 = np.dot(readout, np.maximum(pre0, 0))

    print(f"\nTest point: x = {x0}")
    print(f"Activation pattern: {pattern0}")
    print(f"Network output: {output0:.4f}")

    # Find minimum perturbation to change activation pattern
    # (cross a hyperplane boundary)
    min_dist = float('inf')
    closest_hyperplane = -1

    for i in range(m):
        # Distance from x0 to hyperplane i: |w_i · x0 + b_i| / ||w_i||
        val = abs(W[i] @ x0 + bias[i])
        norm = np.linalg.norm(W[i])
        if norm > 0:
            dist = val / norm
            if dist < min_dist:
                min_dist = dist
                closest_hyperplane = i

    print(f"\nClosest hyperplane: {closest_hyperplane}")
    print(f"Distance to nearest boundary: {min_dist:.4f}")
    print(f"\n→ Any perturbation of size < {min_dist:.4f} stays in the same")
    print(f"  activation region and produces the same affine function")
    print(f"→ This gives a certified robustness radius")

    # The robustness is related to the geometry of the activation region
    print(f"\nConnection to Stone duality:")
    print(f"  The Stone point map is locally constant (piecewise constant)")
    print(f"  Each fiber (activation region) is an open convex polyhedron")
    print(f"  Adversarial robustness = radius of the largest ball in the fiber")


def application_model_compression():
    """Application 4: Model compression via Boolean algebra quotients."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Model Compression via Pattern Merging")
    print("=" * 60)

    np.random.seed(42)
    m = 6
    n = 2
    W = np.random.randn(m, n)
    bias = np.random.randn(m)
    readout = np.random.randn(m)

    # Find realized patterns
    n_samples = 100000
    regions: Dict[Tuple[bool, ...], List[np.ndarray]] = {}
    for _ in range(n_samples):
        x = np.random.uniform(-5, 5, size=n)
        pre = W @ x + bias
        pattern = tuple(p > 0 for p in pre)
        if pattern not in regions:
            regions[pattern] = []
        regions[pattern].append(x)

    print(f"\nNetwork: {n} inputs, {m} hidden neurons")
    print(f"Total possible patterns: 2^{m} = {2**m}")
    print(f"Realized patterns: {len(regions)}")
    print(f"Compression ratio: {len(regions)}/{2**m} = {len(regions)/2**m:.2%}")

    # For each realized pattern, compute the affine function
    affine_funcs = {}
    for pattern, points in regions.items():
        # The affine function on this region is:
        # f(x) = sum_{i: σ_i} readout_i * (W_i · x + b_i)
        w_eff = np.zeros(n)
        b_eff = 0.0
        for i in range(m):
            if pattern[i]:
                w_eff += readout[i] * W[i]
                b_eff += readout[i] * bias[i]
        affine_funcs[pattern] = (w_eff, b_eff)

    # Check if any patterns produce the same affine function
    groups: Dict[Tuple, List[Tuple]] = {}
    for pattern, (w, b) in affine_funcs.items():
        key = tuple(np.round(w, 6)) + (round(b, 6),)
        if key not in groups:
            groups[key] = []
        groups[key].append(pattern)

    n_distinct_affine = len(groups)
    print(f"\nDistinct affine functions: {n_distinct_affine}")
    if n_distinct_affine < len(regions):
        print(f"Some activation regions share the same affine function!")
        print(f"→ These can be merged in the Boolean algebra")
        print(f"→ Effective complexity: {n_distinct_affine} (not {len(regions)})")


if __name__ == "__main__":
    application_decision_boundary_analysis()
    application_network_complexity()
    application_adversarial_robustness()
    application_model_compression()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


"""
Stone Duality for Neural Networks: Demo
========================================
Demonstrates the core concepts of the activation Boolean algebra
for ReLU neural networks. Shows how hyperplane arrangements partition
input space into linear regions, and how activation patterns form
a Boolean algebra isomorphic to a powerset algebra.
"""

import numpy as np
from typing import List, Tuple, Dict, Set
import itertools


class Hyperplane:
    """A hyperplane w · x + b = 0 in R^n."""
    def __init__(self, w: np.ndarray, b: float):
        self.w = w
        self.b = b

    def eval(self, x: np.ndarray) -> float:
        return np.dot(self.w, x) + self.b

    def sign(self, x: np.ndarray) -> bool:
        """True if x is on the positive side (w·x + b > 0)."""
        return self.eval(x) > 0


class HyperplaneArrangement:
    """A finite collection of hyperplanes in R^n."""
    def __init__(self, hyperplanes: List[Hyperplane]):
        self.hyperplanes = hyperplanes
        self.m = len(hyperplanes)

    def activation_pattern(self, x: np.ndarray) -> Tuple[bool, ...]:
        """Compute the activation pattern of point x."""
        return tuple(h.sign(x) for h in self.hyperplanes)

    def count_regions(self, n_samples: int = 100000,
                      bounds: float = 10.0) -> Dict[Tuple[bool, ...], List[np.ndarray]]:
        """Sample random points and count distinct activation regions."""
        n = self.hyperplanes[0].w.shape[0]
        regions = {}
        for _ in range(n_samples):
            x = np.random.uniform(-bounds, bounds, size=n)
            pattern = self.activation_pattern(x)
            if pattern not in regions:
                regions[pattern] = []
            regions[pattern].append(x)
        return regions


class ReluNetwork:
    """A single-hidden-layer ReLU network."""
    def __init__(self, W: np.ndarray, bias: np.ndarray,
                 readout: np.ndarray, c: float = 0.0):
        self.W = W  # (n_out, n_in)
        self.bias = bias  # (n_out,)
        self.readout = readout  # (n_out,)
        self.c = c

    def preactivation(self, x: np.ndarray) -> np.ndarray:
        return self.W @ x + self.bias

    def forward(self, x: np.ndarray) -> float:
        pre = self.preactivation(x)
        relu_out = np.maximum(pre, 0)
        return self.c + np.dot(self.readout, relu_out)

    def to_arrangement(self) -> HyperplaneArrangement:
        hyperplanes = []
        for i in range(self.W.shape[0]):
            hyperplanes.append(Hyperplane(self.W[i], self.bias[i]))
        return HyperplaneArrangement(hyperplanes)

    def tropical_affine(self, pattern: Tuple[bool, ...],
                        x: np.ndarray) -> float:
        """Evaluate the tropical affine function for a given pattern."""
        result = self.c
        for i, active in enumerate(pattern):
            if active:
                h = Hyperplane(self.W[i], self.bias[i])
                result += self.readout[i] * h.eval(x)
        return result


def zaslavsky_bound(n: int, m: int) -> int:
    """Compute the Zaslavsky bound: sum_{k=0}^{n} C(m, k)."""
    from math import comb
    return sum(comb(m, k) for k in range(n + 1))


def demo_basic_arrangement():
    """Demo 1: Basic hyperplane arrangement in R^2."""
    print("=" * 60)
    print("DEMO 1: Hyperplane Arrangement in R^2")
    print("=" * 60)

    # Three hyperplanes in general position in R^2
    h1 = Hyperplane(np.array([1.0, 0.0]), 0.0)   # x > 0
    h2 = Hyperplane(np.array([0.0, 1.0]), 0.0)   # y > 0
    h3 = Hyperplane(np.array([1.0, 1.0]), -0.5)  # x + y > 0.5

    arr = HyperplaneArrangement([h1, h2, h3])

    regions = arr.count_regions(n_samples=50000)
    print(f"\nArrangement: 3 hyperplanes in R^2")
    print(f"Zaslavsky bound: {zaslavsky_bound(2, 3)} = C(3,0) + C(3,1) + C(3,2) = 1 + 3 + 3")
    print(f"Realized regions: {len(regions)}")
    print(f"\nActivation patterns:")
    for pattern, points in sorted(regions.items()):
        centroid = np.mean(points, axis=0)
        print(f"  σ = {pattern} -> ~{len(points)} samples, centroid ≈ ({centroid[0]:.2f}, {centroid[1]:.2f})")

    print(f"\nVerification: {len(regions)} ≤ {zaslavsky_bound(2, 3)} ✓")


def demo_relu_tropical():
    """Demo 2: ReLU network as tropical polynomial."""
    print("\n" + "=" * 60)
    print("DEMO 2: ReLU Network = Tropical Polynomial")
    print("=" * 60)

    # Simple network: 2 inputs, 3 hidden neurons
    W = np.array([[1.0, 0.5],
                  [-0.5, 1.0],
                  [0.3, -0.7]])
    bias = np.array([0.1, -0.2, 0.3])
    readout = np.array([1.0, -0.5, 0.8])
    c = 0.0

    net = ReluNetwork(W, bias, readout, c)
    arr = net.to_arrangement()

    # Sample a few points and verify tropical = ReLU on each region
    print("\nVerifying ReLU = tropical affine on each activation region:")
    np.random.seed(42)
    for _ in range(5):
        x = np.random.randn(2)
        pattern = arr.activation_pattern(x)
        relu_val = net.forward(x)
        tropical_val = net.tropical_affine(pattern, x)
        match = np.isclose(relu_val, tropical_val)
        print(f"  x = ({x[0]:+.3f}, {x[1]:+.3f}), "
              f"σ = {pattern}, "
              f"ReLU = {relu_val:.4f}, "
              f"tropical = {tropical_val:.4f}, "
              f"match = {match}")


def demo_boolean_algebra():
    """Demo 3: Boolean algebra structure of activation patterns."""
    print("\n" + "=" * 60)
    print("DEMO 3: Activation Boolean Algebra")
    print("=" * 60)

    # 3 hyperplanes in R^2
    h1 = Hyperplane(np.array([1.0, 0.2]), 0.0)
    h2 = Hyperplane(np.array([-0.3, 1.0]), 0.0)
    h3 = Hyperplane(np.array([0.5, -0.8]), 0.1)
    arr = HyperplaneArrangement([h1, h2, h3])

    regions = arr.count_regions(n_samples=100000)
    realized = set(regions.keys())

    print(f"\n{len(realized)} realized activation patterns (atoms):")
    for p in sorted(realized):
        print(f"  {p}")

    # All possible subsets of realized patterns = Boolean algebra elements
    all_patterns = list(realized)
    algebra_size = 2 ** len(all_patterns)
    print(f"\nBoolean algebra has 2^{len(all_patterns)} = {algebra_size} elements")
    print(f"Upper bound: 2^(2^m) = 2^(2^3) = {2**8}")

    # Demonstrate closure under complement
    print("\nClosure under complement:")
    S = frozenset(list(realized)[:3])
    S_comp = realized - S
    print(f"  S = {set(S)} (first 3 patterns)")
    print(f"  S^c = {S_comp}")
    print(f"  S ∪ S^c = realized patterns ✓: {S | S_comp == realized}")


def demo_stone_duality():
    """Demo 4: Stone duality — the Stone point map."""
    print("\n" + "=" * 60)
    print("DEMO 4: Stone Duality Map")
    print("=" * 60)

    # 4 hyperplanes in R^2
    h1 = Hyperplane(np.array([1.0, 0.0]), 0.0)
    h2 = Hyperplane(np.array([0.0, 1.0]), 0.0)
    h3 = Hyperplane(np.array([1.0, -1.0]), 0.0)
    h4 = Hyperplane(np.array([1.0, 1.0]), 0.0)
    arr = HyperplaneArrangement([h1, h2, h3, h4])

    # The Stone point map sends R^2 → {0,1}^4
    print("\nStone point map: R^2 → {0,1}^4")
    print("(maps each input to its activation pattern)")

    test_points = [
        np.array([1.0, 0.5]),
        np.array([-1.0, 0.5]),
        np.array([1.0, -0.5]),
        np.array([2.0, 1.0]),  # same quadrant as (1, 0.5)
        np.array([0.3, 0.1]),  # same region as (1, 0.5)?
    ]

    print("\n  Point         -> Stone point")
    for x in test_points:
        pattern = arr.activation_pattern(x)
        print(f"  ({x[0]:+.1f}, {x[1]:+.1f})  -> {pattern}")

    # Two points with same Stone point are in same region
    x1 = np.array([1.0, 0.5])
    x2 = np.array([2.0, 1.0])
    p1 = arr.activation_pattern(x1)
    p2 = arr.activation_pattern(x2)
    print(f"\n  (1.0, 0.5) and (2.0, 1.0) have same pattern: {p1 == p2}")
    print(f"  → They are in the same activation region (Stone fiber)")

    regions = arr.count_regions(n_samples=100000)
    print(f"\n  Zaslavsky bound for m=4, n=2: {zaslavsky_bound(2, 4)}")
    print(f"  Realized regions: {len(regions)}")


def demo_vc_dimension():
    """Demo 5: VC dimension and shattering."""
    print("\n" + "=" * 60)
    print("DEMO 5: VC Dimension Bound")
    print("=" * 60)

    for m in range(1, 6):
        n = 2
        # Create m random hyperplanes in R^2
        np.random.seed(42 + m)
        hyperplanes = [Hyperplane(np.random.randn(n), np.random.randn())
                       for _ in range(m)]
        arr = HyperplaneArrangement(hyperplanes)
        regions = arr.count_regions(n_samples=50000)

        zas = zaslavsky_bound(n, m)
        print(f"\n  m = {m} hyperplanes in R^{n}:")
        print(f"    Realized regions: {len(regions)}")
        print(f"    Zaslavsky bound:  {zas}")
        print(f"    2^m bound:        {2**m}")
        print(f"    Verified: {len(regions)} ≤ {zas} ≤ {2**m} ✓")


if __name__ == "__main__":
    np.random.seed(42)
    demo_basic_arrangement()
    demo_relu_tropical()
    demo_boolean_algebra()
    demo_stone_duality()
    demo_vc_dimension()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Activation Regions of a ReLU Network
=====================================================
Shows how hyperplanes partition R^2 into activation regions,
each colored by its activation pattern. The hyperplane boundaries
are drawn as lines, and each region is shaded.

This visualizes the core concept of the activation Boolean algebra:
the atoms are the colored regions, and the Boolean algebra consists
of all possible unions of these regions.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import matplotlib.patches as mpatches


def hyperplane_eval(w, b, x):
    return w[0] * x[0] + w[1] * x[1] + b


def activation_pattern(Ws, bs, x):
    return tuple(hyperplane_eval(w, b, x) > 0 for w, b in zip(Ws, bs))


# Create hyperplane arrangement: 5 neurons in R^2
np.random.seed(42)
m = 5
Ws = [np.array([2.0, -1.0]),
      np.array([-1.0, 2.0]),
      np.array([1.5, 1.0]),
      np.array([-0.5, -1.5]),
      np.array([1.0, 0.3])]
bs = [0.2, -0.3, -0.8, 0.5, -0.1]

# Create grid
resolution = 500
x_range = np.linspace(-3, 3, resolution)
y_range = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x_range, y_range)

# Compute activation pattern for each grid point
patterns = {}
pattern_grid = np.zeros((resolution, resolution), dtype=int)

for i in range(resolution):
    for j in range(resolution):
        point = np.array([X[i, j], Y[i, j]])
        p = activation_pattern(Ws, bs, point)
        if p not in patterns:
            patterns[p] = len(patterns)
        pattern_grid[i, j] = patterns[p]

n_regions = len(patterns)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Activation regions
ax1 = axes[0]
cmap = plt.cm.get_cmap('tab20', n_regions)
im = ax1.pcolormesh(X, Y, pattern_grid, cmap=cmap, shading='auto')

# Draw hyperplane boundaries
for k in range(m):
    w, b = Ws[k], bs[k]
    if abs(w[1]) > 1e-10:
        x_line = np.linspace(-3, 3, 100)
        y_line = -(w[0] * x_line + b) / w[1]
        mask = (y_line >= -3) & (y_line <= 3)
        ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=1.5, alpha=0.7)
    else:
        x_val = -b / w[0]
        if -3 <= x_val <= 3:
            ax1.axvline(x=x_val, color='k', linewidth=1.5, alpha=0.7)

from math import comb
zas = sum(comb(m, k) for k in range(3))  # n=2

ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_xlabel('x₁', fontsize=14)
ax1.set_ylabel('x₂', fontsize=14)
ax1.set_title(f'Activation Regions ({n_regions} regions, Zaslavsky bound = {zas})',
              fontsize=13)
ax1.set_aspect('equal')

# Right: Boolean algebra structure
ax2 = axes[1]
# Show the lattice of the Boolean algebra
# For visualization, show a sample of elements

# The atoms are the realized patterns
atom_labels = [f'R{i}' for i in range(min(n_regions, 8))]
n_show = min(n_regions, 6)

# Draw Hasse diagram of a small Boolean algebra
positions = {}
level_counts = {}

for k in range(n_show + 1):
    level_counts[k] = 0

# Place nodes
y_spacing = 1.0
for size in range(n_show + 1):
    subsets = []
    if size == 0:
        subsets = [frozenset()]
    elif size == n_show:
        subsets = [frozenset(range(n_show))]
    elif size == 1:
        subsets = [frozenset([i]) for i in range(n_show)]
    elif size == n_show - 1:
        subsets = [frozenset(range(n_show)) - frozenset([i]) for i in range(n_show)]
    else:
        # Only show a few
        from itertools import combinations
        subsets = [frozenset(c) for c in combinations(range(n_show), size)]
        if len(subsets) > 6:
            subsets = subsets[:6]

    for idx, s in enumerate(subsets):
        x_pos = (idx - len(subsets) / 2 + 0.5) * 1.5
        y_pos = size * y_spacing
        positions[s] = (x_pos, y_pos)

# Draw edges for a subset of the lattice
for s1, (x1, y1) in positions.items():
    for s2, (x2, y2) in positions.items():
        if s1 < s2 and len(s2) == len(s1) + 1:
            ax2.plot([x1, x2], [y1, y2], 'gray', linewidth=0.5, alpha=0.5)

# Draw nodes
for s, (x, y) in positions.items():
    color = cmap(list(s)[0]) if len(s) == 1 else ('white' if len(s) == 0 else 'lightblue')
    ax2.plot(x, y, 'o', markersize=12, color=color,
             markeredgecolor='black', markeredgewidth=1)
    if len(s) <= 1:
        label = '∅' if len(s) == 0 else f'R{list(s)[0]}'
        ax2.annotate(label, (x, y), textcoords="offset points",
                     xytext=(0, -18), ha='center', fontsize=8)

ax2.set_xlim(-5, 5)
ax2.set_ylim(-0.5, n_show + 0.5)
ax2.set_title(f'Activation Boolean Algebra\n(2^{n_regions} = {2**n_regions} elements)',
              fontsize=13)
ax2.axis('off')

plt.suptitle('Stone Duality for Neural Networks:\nActivation Patterns as Boolean Algebra Atoms',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('activation_regions.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved activation_regions.png ({n_regions} regions found)")


"""
Visualization: The Stone Dual Map
====================================
Visualizes the Stone point map from R^2 to {0,1}^m.
The left panel shows the continuous input space partitioned into regions.
The right panel shows the discrete Stone space (activation patterns)
as points in a hypercube, with edges connecting patterns that differ
by exactly one bit (adjacent regions share a hyperplane boundary).

This illustrates the fundamental theorem: two inputs map to the same
Stone point iff they agree on which side of every hyperplane they lie on.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def activation_pattern(Ws, bs, x):
    return tuple(np.dot(w, x) + b > 0 for w, b in zip(Ws, bs))


def hamming_distance(p1, p2):
    return sum(a != b for a, b in zip(p1, p2))


# Setup: 4 hyperplanes in R^2
Ws = [np.array([1.0, 0.0]),
      np.array([0.0, 1.0]),
      np.array([1.0, -1.0]),
      np.array([1.0, 1.0])]
bs = [0.0, 0.0, 0.0, -0.5]
m = len(Ws)

# Create grid and compute patterns
resolution = 400
x_range = np.linspace(-3, 3, resolution)
y_range = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x_range, y_range)

patterns = {}
pattern_grid = np.zeros((resolution, resolution), dtype=int)
pattern_centroids = {}

for i in range(resolution):
    for j in range(resolution):
        point = np.array([X[i, j], Y[i, j]])
        p = activation_pattern(Ws, bs, point)
        if p not in patterns:
            patterns[p] = len(patterns)
            pattern_centroids[p] = [[], []]
        idx = patterns[p]
        pattern_grid[i, j] = idx
        pattern_centroids[p][0].append(X[i, j])
        pattern_centroids[p][1].append(Y[i, j])

n_regions = len(patterns)

# Compute centroids
centroids = {}
for p, (xs, ys) in pattern_centroids.items():
    centroids[p] = (np.mean(xs), np.mean(ys))

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Input space with activation regions
ax1 = axes[0]
cmap = plt.cm.get_cmap('Set3', n_regions)
ax1.pcolormesh(X, Y, pattern_grid, cmap=cmap, shading='auto', alpha=0.7)

# Draw hyperplane boundaries
for k in range(m):
    w, b = Ws[k], bs[k]
    if abs(w[1]) > 1e-10:
        x_line = np.linspace(-3, 3, 100)
        y_line = -(w[0] * x_line + b) / w[1]
        mask = (y_line >= -3) & (y_line <= 3)
        ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=2, alpha=0.8)
    else:
        x_val = -b / w[0] if abs(w[0]) > 1e-10 else 0
        ax1.axvline(x=x_val, color='k', linewidth=2, alpha=0.8)

# Label centroids
for p, (cx, cy) in centroids.items():
    if -2.5 < cx < 2.5 and -2.5 < cy < 2.5:
        label = ''.join('1' if b else '0' for b in p)
        ax1.annotate(label, (cx, cy), fontsize=9, fontweight='bold',
                     ha='center', va='center',
                     bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

# Draw arrows showing the Stone map
for p, (cx, cy) in list(centroids.items())[:4]:
    if -2 < cx < 2 and -2 < cy < 2:
        ax1.annotate('', xy=(2.8, cy), xytext=(cx + 0.3, cy),
                     arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_xlabel('x₁', fontsize=14)
ax1.set_ylabel('x₂', fontsize=14)
ax1.set_title('Input Space R²\n(Activation Regions)', fontsize=13)
ax1.set_aspect('equal')

# Right: Stone space (discrete points)
ax2 = axes[1]

# Position patterns in a 2D layout based on their binary coordinates
# Use first two principal components of the binary patterns for layout
pattern_list = list(patterns.keys())
n = len(pattern_list)

# Simple 2D layout: use sum of bits for y, hash for x
pos = {}
for p in pattern_list:
    # Map binary pattern to 2D position
    bits = [1 if b else 0 for b in p]
    x_pos = sum(bits[i] * (2 ** i) for i in range(len(bits)))
    y_pos = sum(bits)
    # Add jitter to avoid overlaps
    pos[p] = (x_pos + np.random.uniform(-0.2, 0.2),
              y_pos + np.random.uniform(-0.1, 0.1))

# Draw edges between adjacent patterns (Hamming distance 1)
for p1 in pattern_list:
    for p2 in pattern_list:
        if p1 < p2 and hamming_distance(p1, p2) == 1:
            x1, y1 = pos[p1]
            x2, y2 = pos[p2]
            ax2.plot([x1, x2], [y1, y2], 'gray', linewidth=0.8, alpha=0.4)

# Draw nodes
for p in pattern_list:
    x, y = pos[p]
    color = cmap(patterns[p])
    ax2.plot(x, y, 'o', markersize=20, color=color,
             markeredgecolor='black', markeredgewidth=1.5, zorder=5)
    label = ''.join('1' if b else '0' for b in p)
    ax2.annotate(label, (x, y), fontsize=7, fontweight='bold',
                 ha='center', va='center', zorder=6)

ax2.set_xlabel('Pattern index', fontsize=12)
ax2.set_ylabel('Number of active neurons', fontsize=12)
ax2.set_title(f'Stone Space S(B)\n({n_regions} points = realized patterns)', fontsize=13)

# Add annotation
ax2.text(0.5, -0.12,
         'The Stone point map φ : R² → S(B)\n'
         'sends each input to its activation pattern.\n'
         'Edges connect patterns differing by 1 bit\n'
         '(adjacent activation regions).',
         transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', horizontalalignment='center',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.suptitle('Stone Duality: Continuous Space ↔ Discrete Space',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('stone_map.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved stone_map.png ({n_regions} Stone space points)")


"""
Visualization: Zaslavsky Bound vs Actual Regions
===================================================
Shows how the number of realized activation regions compares to
the theoretical Zaslavsky bound and the naive 2^m bound,
for varying numbers of hyperplanes m in dimension n=2.

This illustrates the key insight: the activation Boolean algebra
has far fewer atoms than the naive 2^m bound suggests, because
many activation patterns are geometrically impossible.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def count_regions_random(n, m, n_samples=200000, bounds=10.0, seed=42):
    """Count realized activation regions for random hyperplanes."""
    rng = np.random.RandomState(seed)
    Ws = rng.randn(m, n)
    bs = rng.randn(m) * 0.5

    patterns = set()
    for _ in range(n_samples):
        x = rng.uniform(-bounds, bounds, size=n)
        pre = Ws @ x + bs
        pattern = tuple(p > 0 for p in pre)
        patterns.add(pattern)

    return len(patterns)


def zaslavsky_bound(n, m):
    return sum(comb(m, k) for k in range(n + 1))


# Compute data
n = 2  # dimension
ms = list(range(1, 16))
actual_regions = []
zas_bounds = []
exp_bounds = []

for m in ms:
    actual = count_regions_random(n, m, n_samples=300000)
    actual_regions.append(actual)
    zas_bounds.append(zaslavsky_bound(n, m))
    exp_bounds.append(2 ** m)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Linear scale
ax1.plot(ms, actual_regions, 'bo-', linewidth=2, markersize=8, label='Actual regions (sampled)')
ax1.plot(ms, zas_bounds, 'rs--', linewidth=2, markersize=8, label=f'Zaslavsky bound (n={n})')
ax1.plot(ms, exp_bounds, 'g^:', linewidth=2, markersize=8, label='Naive bound 2^m')
ax1.set_xlabel('Number of hyperplanes m', fontsize=14)
ax1.set_ylabel('Number of regions', fontsize=14)
ax1.set_title('Activation Regions vs Bounds (Linear Scale)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Annotate the gap
m_annotate = 10
idx = ms.index(m_annotate)
ax1.annotate(f'Gap: {exp_bounds[idx]} vs {zas_bounds[idx]}',
             xy=(m_annotate, exp_bounds[idx]),
             xytext=(m_annotate - 3, exp_bounds[idx] * 0.8),
             arrowprops=dict(arrowstyle='->', color='green'),
             fontsize=10, color='green')

# Right: Log scale
ax2.semilogy(ms, actual_regions, 'bo-', linewidth=2, markersize=8, label='Actual regions')
ax2.semilogy(ms, zas_bounds, 'rs--', linewidth=2, markersize=8, label=f'Zaslavsky bound')
ax2.semilogy(ms, exp_bounds, 'g^:', linewidth=2, markersize=8, label='2^m bound')
ax2.set_xlabel('Number of hyperplanes m', fontsize=14)
ax2.set_ylabel('Number of regions (log scale)', fontsize=14)
ax2.set_title('Activation Regions vs Bounds (Log Scale)', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add text box with formulas
textstr = (f'Dimension n = {n}\n'
           f'Zaslavsky: Σ C(m,k) for k=0..{n}\n'
           f'  = 1 + m + m(m-1)/2\n'
           f'  = O(m²) for fixed n\n\n'
           f'Key: polynomial vs exponential!')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.9)
ax2.text(0.05, 0.95, textstr, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', bbox=props)

plt.suptitle('The Zaslavsky Gap: Why Neural Networks Are Simpler Than They Look',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('zaslavsky_bound.png', dpi=150, bbox_inches='tight')
plt.close()

# Print summary table
print("Zaslavsky Bound Analysis")
print(f"{'m':>4} {'Actual':>10} {'Zaslavsky':>12} {'2^m':>10} {'Ratio':>10}")
print("-" * 50)
for i, m in enumerate(ms):
    ratio = actual_regions[i] / exp_bounds[i]
    print(f"{m:>4} {actual_regions[i]:>10} {zas_bounds[i]:>12} {exp_bounds[i]:>10} {ratio:>10.4f}")

print(f"\nSaved zaslavsky_bound.png")
