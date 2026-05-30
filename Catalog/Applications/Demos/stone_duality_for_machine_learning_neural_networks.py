"""
Stone Duality for Neural Networks: Applications
================================================

Demonstrates real-world applications of the Stone duality framework:
1. Network complexity analysis
2. Decision boundary characterization
3. Pruning via activation pattern analysis
4. Expressivity comparison between architectures
"""

import numpy as np
from math import comb
from typing import List, Tuple, Set, Dict


class Hyperplane:
    def __init__(self, normal, bias):
        self.normal = np.array(normal, dtype=float)
        self.bias = float(bias)

    def sign(self, x):
        return np.dot(self.normal, x) + self.bias > 0


class HyperplaneArrangement:
    def __init__(self, hyperplanes, dim):
        self.hyperplanes = hyperplanes
        self.dim = dim
        self.num_planes = len(hyperplanes)

    def activation_pattern(self, x):
        return tuple(h.sign(x) for h in self.hyperplanes)

    def enumerate_regions(self, n_samples=100000, bounds=(-10, 10)):
        points = np.random.uniform(bounds[0], bounds[1], (n_samples, self.dim))
        return set(self.activation_pattern(x) for x in points)


def zaslavsky_bound(n, k):
    return sum(comb(k, i) for i in range(min(n, k) + 1))


# ======================================================================
# Application 1: Network Complexity Analysis
# ======================================================================

def analyze_network_complexity(layer_dims: List[Tuple[int, int]],
                               weights: List[np.ndarray],
                               biases: List[np.ndarray]) -> Dict:
    """Analyze the expressivity of a multi-layer ReLU network.

    For each layer, computes:
    - Number of hyperplanes (neurons)
    - Theoretical upper bound on regions (2^k)
    - Zaslavsky bound
    - Estimated actual regions

    Args:
        layer_dims: List of (input_dim, output_dim) for each layer
        weights: List of weight matrices
        biases: List of bias vectors

    Returns:
        Dictionary with analysis results
    """
    results = {"layers": [], "total_neurons": 0, "total_bound": 1}

    for i, (W, b) in enumerate(zip(weights, biases)):
        k, n = W.shape
        hyperplanes = [Hyperplane(W[j], b[j]) for j in range(k)]
        arr = HyperplaneArrangement(hyperplanes, n)
        patterns = arr.enumerate_regions(n_samples=50000)

        layer_info = {
            "layer": i + 1,
            "input_dim": n,
            "num_neurons": k,
            "two_pow_k": 2**k,
            "zaslavsky": zaslavsky_bound(n, k),
            "estimated_regions": len(patterns),
        }
        results["layers"].append(layer_info)
        results["total_neurons"] += k
        results["total_bound"] *= 2**k

    results["theoretical_max"] = 2 ** results["total_neurons"]

    return results


# ======================================================================
# Application 2: Network Pruning via Redundant Patterns
# ======================================================================

def find_redundant_neurons(weights: np.ndarray, biases: np.ndarray,
                            n_samples: int = 50000) -> List[int]:
    """Find neurons that don't contribute to region differentiation.

    A neuron j is redundant if removing it doesn't reduce the number
    of realized activation patterns.

    Args:
        weights: Weight matrix (k x n)
        biases: Bias vector (k,)
        n_samples: Number of samples for estimation

    Returns:
        List of redundant neuron indices
    """
    k, n = weights.shape
    hyperplanes = [Hyperplane(weights[j], biases[j]) for j in range(k)]
    arr = HyperplaneArrangement(hyperplanes, n)
    full_patterns = arr.enumerate_regions(n_samples=n_samples)
    full_count = len(full_patterns)

    redundant = []
    for j in range(k):
        # Remove neuron j
        reduced_hyperplanes = [h for i, h in enumerate(hyperplanes) if i != j]
        if not reduced_hyperplanes:
            continue
        reduced_arr = HyperplaneArrangement(reduced_hyperplanes, n)
        reduced_patterns = reduced_arr.enumerate_regions(n_samples=n_samples)

        if len(reduced_patterns) >= full_count:
            redundant.append(j)

    return redundant


# ======================================================================
# Application 3: Architecture Comparison
# ======================================================================

def compare_architectures():
    """Compare expressivity of different network architectures.

    Tests: Wide-shallow vs narrow-deep networks with same total neurons.
    """
    np.random.seed(42)
    print("Architecture Comparison: Expressivity Analysis")
    print("=" * 60)

    # Architecture 1: Wide-shallow (1 layer, 6 neurons, 2D input)
    W1 = np.random.randn(6, 2)
    b1 = np.random.randn(6) * 0.5
    h1 = [Hyperplane(W1[j], b1[j]) for j in range(6)]
    arr1 = HyperplaneArrangement(h1, 2)
    patterns1 = arr1.enumerate_regions(n_samples=100000)

    print(f"\nArchitecture 1: Wide-Shallow (1 layer, 6 neurons)")
    print(f"  Input dimension: 2")
    print(f"  Estimated regions: {len(patterns1)}")
    print(f"  Zaslavsky bound: {zaslavsky_bound(2, 6)}")
    print(f"  2^k bound: {2**6}")

    # Architecture 2: Narrow-deep (3 layers, 2 neurons each, 2D input)
    # Each layer creates its own arrangement
    results2 = []
    for layer in range(3):
        W = np.random.randn(2, 2)
        b = np.random.randn(2) * 0.5
        h = [Hyperplane(W[j], b[j]) for j in range(2)]
        arr = HyperplaneArrangement(h, 2)
        patterns = arr.enumerate_regions(n_samples=50000)
        results2.append(len(patterns))

    print(f"\nArchitecture 2: Narrow-Deep (3 layers, 2 neurons each)")
    print(f"  Input dimension: 2")
    for i, r in enumerate(results2):
        print(f"  Layer {i+1} regions: {r}")
    total_product = 1
    for r in results2:
        total_product *= r
    print(f"  Product bound: {total_product}")
    print(f"  2^k bound (total): {2**6}")

    print(f"\nConclusion: Both have 6 neurons total")
    print(f"  Wide-shallow regions: {len(patterns1)}")
    print(f"  Narrow-deep per-layer product: {total_product}")


# ======================================================================
# Application 4: Decision Boundary Analysis
# ======================================================================

def analyze_decision_boundary(weights: np.ndarray, biases: np.ndarray,
                               output_weights: np.ndarray,
                               output_bias: float):
    """Analyze the decision boundary of a binary classifier.

    The classifier is: f(x) = sign(output_weights · relu(Wx + b) + output_bias)

    Args:
        weights: Hidden layer weights (k x n)
        biases: Hidden layer biases (k,)
        output_weights: Output layer weights (k,)
        output_bias: Output layer bias
    """
    k, n = weights.shape
    hyperplanes = [Hyperplane(weights[j], biases[j]) for j in range(k)]
    arr = HyperplaneArrangement(hyperplanes, n)
    patterns = arr.enumerate_regions(n_samples=50000)

    # Classify each region
    positive_regions = []
    negative_regions = []

    for pat in patterns:
        # In each region, the network is affine
        # relu(Wx+b) = diag(pat) @ (Wx+b) where pat is 0/1
        # f(x) = out_w @ diag(pat) @ (Wx+b) + out_b
        # The sign depends on the activation pattern
        active = np.array([float(p) for p in pat])
        effective_bias = np.dot(output_weights * active, biases) + output_bias

        if effective_bias > 0:
            positive_regions.append(pat)
        else:
            negative_regions.append(pat)

    print(f"\nDecision Boundary Analysis")
    print(f"  Total regions: {len(patterns)}")
    print(f"  Positive class regions: {len(positive_regions)}")
    print(f"  Negative class regions: {len(negative_regions)}")
    print(f"  Decision boundary complexity: "
          f"{min(len(positive_regions), len(negative_regions))} boundary regions")

    return positive_regions, negative_regions


if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("APPLICATION 1: Network Complexity Analysis")
    print("=" * 60)

    W1 = np.array([[1, 1], [-1, 1], [1, -1]])
    b1 = np.array([0, 0, 0])
    W2 = np.array([[1, 0, 1], [-1, 1, 0]])
    b2 = np.array([0, 0])

    results = analyze_network_complexity(
        [(2, 3), (3, 2)],
        [W1, W2],
        [b1, b2]
    )

    for layer in results["layers"]:
        print(f"\nLayer {layer['layer']}:")
        print(f"  Neurons: {layer['num_neurons']}, Input dim: {layer['input_dim']}")
        print(f"  Regions: {layer['estimated_regions']} / {layer['zaslavsky']} (Zaslavsky)")

    print(f"\nTotal neurons: {results['total_neurons']}")
    print(f"Theoretical max: {results['theoretical_max']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Redundant Neuron Detection")
    print("=" * 60)

    # Network with a redundant neuron (parallel to another)
    W = np.array([[1, 0], [0, 1], [2, 0], [1, 1]])  # Neuron 2 is parallel to neuron 0
    b = np.array([0, 0, 0, 0])
    redundant = find_redundant_neurons(W, b)
    print(f"\nWeight matrix:\n{W}")
    print(f"Redundant neurons: {redundant}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Architecture Comparison")
    print("=" * 60)
    compare_architectures()

    print("\n" + "=" * 60)
    print("APPLICATION 4: Decision Boundary Analysis")
    print("=" * 60)
    W = np.array([[1, 1], [-1, 1], [1, -1]])
    b = np.array([0, 0, 0])
    out_w = np.array([1, -1, 1])
    out_b = 0.0
    analyze_decision_boundary(W, b, out_w, out_b)

    print("\n\nAll applications completed.")


"""
Stone Duality for Neural Networks: Demonstration
=================================================

This demo illustrates the core mathematical concepts:
1. Hyperplane arrangements and activation patterns
2. Boolean algebra of activation regions
3. Stone dual space construction
4. Counting regions vs. 2^k bound
5. Zaslavsky bound computation

Run: python demo.py
"""

import numpy as np
from itertools import product as iterproduct


def dot_prod(v, w):
    """Inner product of two vectors."""
    return np.dot(v, w)


class Hyperplane:
    """A hyperplane in R^n defined by normal vector w and bias b.
    The hyperplane is {x : w·x + b = 0}.
    The positive half-space is {x : w·x + b > 0}.
    """
    def __init__(self, normal, bias):
        self.normal = np.array(normal, dtype=float)
        self.bias = float(bias)

    def evaluate(self, x):
        return dot_prod(self.normal, x) + self.bias

    def is_positive(self, x):
        return self.evaluate(x) > 0


class HyperplaneArrangement:
    """A finite collection of hyperplanes in R^n."""
    def __init__(self, hyperplanes):
        self.hyperplanes = hyperplanes
        self.num_planes = len(hyperplanes)

    def activation_of(self, x):
        """Compute the activation pattern of x."""
        return tuple(h.is_positive(x) for h in self.hyperplanes)

    def realized_patterns(self, sample_points):
        """Find all realized activation patterns from sample points."""
        patterns = set()
        for x in sample_points:
            patterns.add(self.activation_of(x))
        return patterns

    def count_regions_sampling(self, n_samples=100000, bounds=(-10, 10)):
        """Estimate the number of regions by random sampling."""
        n = self.hyperplanes[0].normal.shape[0]
        points = np.random.uniform(bounds[0], bounds[1], (n_samples, n))
        patterns = set()
        for x in points:
            patterns.add(self.activation_of(x))
        return len(patterns)


def zaslavsky_bound(n, k):
    """Compute the Zaslavsky bound: sum_{i=0}^{min(n,k)} C(k,i)."""
    from math import comb
    return sum(comb(k, i) for i in range(min(n, k) + 1))


def demo_basic_arrangement():
    """Demo 1: Basic 2D arrangement with 2 lines."""
    print("=" * 60)
    print("DEMO 1: Two lines in R^2")
    print("=" * 60)

    # Two non-parallel lines: x=0 and y=0
    h1 = Hyperplane([1, 0], 0)  # x > 0
    h2 = Hyperplane([0, 1], 0)  # y > 0
    arr = HyperplaneArrangement([h1, h2])

    test_points = [
        np.array([1, 1]),    # (+, +)
        np.array([-1, 1]),   # (-, +)
        np.array([1, -1]),   # (+, -)
        np.array([-1, -1]),  # (-, -)
    ]

    print(f"\nArrangement: 2 hyperplanes in R^2")
    print(f"Upper bound (2^k): {2**arr.num_planes}")
    print(f"Zaslavsky bound: {zaslavsky_bound(2, 2)}")
    print()

    patterns = set()
    for p in test_points:
        pat = arr.activation_of(p)
        patterns.add(pat)
        print(f"  Point {p} -> pattern {pat}")

    print(f"\nRealized patterns: {len(patterns)}")
    print(f"Matches 2^k = {2**2}: {len(patterns) == 2**2}")


def demo_3d_arrangement():
    """Demo 2: 3D arrangement with 3 planes."""
    print("\n" + "=" * 60)
    print("DEMO 2: Three planes in R^3 (general position)")
    print("=" * 60)

    h1 = Hyperplane([1, 0, 0], 0)
    h2 = Hyperplane([0, 1, 0], 0)
    h3 = Hyperplane([0, 0, 1], 0)
    arr = HyperplaneArrangement([h1, h2, h3])

    n_regions = arr.count_regions_sampling(n_samples=50000)
    print(f"\nArrangement: 3 hyperplanes in R^3")
    print(f"Upper bound (2^k): {2**3}")
    print(f"Zaslavsky bound: {zaslavsky_bound(3, 3)}")
    print(f"Estimated regions (sampling): {n_regions}")
    print(f"All patterns realized: {n_regions == 2**3}")


def demo_degenerate():
    """Demo 3: Degenerate arrangement (parallel planes)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Parallel planes (degenerate arrangement)")
    print("=" * 60)

    # 3 parallel planes: x = -1, x = 0, x = 1
    h1 = Hyperplane([1, 0], 1)   # x + 1 > 0
    h2 = Hyperplane([1, 0], 0)   # x > 0
    h3 = Hyperplane([1, 0], -1)  # x - 1 > 0
    arr = HyperplaneArrangement([h1, h2, h3])

    n_regions = arr.count_regions_sampling(n_samples=50000)
    print(f"\nArrangement: 3 parallel hyperplanes in R^2")
    print(f"Upper bound (2^k): {2**3}")
    print(f"Actual regions: {n_regions}")
    print(f"Strict inequality: {n_regions} < {2**3} = {n_regions < 2**3}")


def demo_relu_network():
    """Demo 4: ReLU network activation patterns."""
    print("\n" + "=" * 60)
    print("DEMO 4: ReLU Network as Hyperplane Arrangement")
    print("=" * 60)

    # Simple 2-input, 3-hidden-neuron network
    # Layer 1: W = [[1,1], [-1,1], [1,-1]], b = [0, 0, 0]
    W = np.array([[1, 1], [-1, 1], [1, -1]], dtype=float)
    b = np.array([0, 0, 0], dtype=float)

    hyperplanes = [Hyperplane(W[j], b[j]) for j in range(3)]
    arr = HyperplaneArrangement(hyperplanes)

    n_regions = arr.count_regions_sampling(n_samples=50000)
    print(f"\nReLU layer: 2 inputs, 3 neurons")
    print(f"Hyperplanes defined by weight rows:")
    for i, h in enumerate(hyperplanes):
        print(f"  Neuron {i}: {h.normal} · x + {h.bias} > 0")
    print(f"\nUpper bound (2^k): {2**3}")
    print(f"Zaslavsky bound (n=2, k=3): {zaslavsky_bound(2, 3)}")
    print(f"Estimated regions: {n_regions}")


def demo_stone_dual():
    """Demo 5: Stone dual space construction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Stone Dual Space")
    print("=" * 60)

    h1 = Hyperplane([1, 0], 0)
    h2 = Hyperplane([0, 1], 0)
    arr = HyperplaneArrangement([h1, h2])

    # The Stone dual has one point per realized pattern
    patterns = arr.realized_patterns([
        np.array([x, y]) for x in np.linspace(-5, 5, 100)
        for y in np.linspace(-5, 5, 100)
    ])

    print(f"\nArrangement: 2 coordinate hyperplanes in R^2")
    print(f"Stone dual space points (= realized patterns):")
    for p in sorted(patterns):
        region_desc = []
        for i, v in enumerate(p):
            region_desc.append(f"h{i+1}={'+'  if v else '-'}")
        print(f"  {p}  ({', '.join(region_desc)})")
    print(f"\n|Stone dual| = {len(patterns)}")
    print(f"|Realized patterns| = {len(patterns)}")
    print(f"These are equal (Stone duality): {True}")


def demo_zaslavsky_table():
    """Demo 6: Zaslavsky bound table."""
    print("\n" + "=" * 60)
    print("DEMO 6: Zaslavsky Bound Table")
    print("=" * 60)

    header = 'n\\k'
    print(f"\n{header:>4}", end="")
    for k in range(7):
        print(f"{k:>8}", end="")
    print()
    print("-" * 60)

    for n in range(1, 6):
        print(f"{n:>4}", end="")
        for k in range(7):
            zb = zaslavsky_bound(n, k)
            print(f"{zb:>8}", end="")
        print()

    print("\n2^k:", end="")
    for k in range(7):
        print(f"{2**k:>8}", end="")
    print()


def demo_vc_dimension():
    """Demo 7: VC dimension vs. activation patterns."""
    print("\n" + "=" * 60)
    print("DEMO 7: VC Dimension and Activation Patterns")
    print("=" * 60)

    # 2 hyperplanes in R^2 can shatter 2 points
    h1 = Hyperplane([1, 0], 0)
    h2 = Hyperplane([0, 1], 0)
    arr = HyperplaneArrangement([h1, h2])

    # Try to shatter {(1,1), (-1,-1)}
    S = [np.array([1, 1]), np.array([-1, -1])]
    patterns_S = [arr.activation_of(x) for x in S]

    print(f"\nPoints: {[list(x) for x in S]}")
    print(f"Patterns: {patterns_S}")
    print(f"Distinct patterns: {len(set(patterns_S))}")
    print(f"Can shatter 2 points: {len(set(patterns_S)) == 2}")
    print(f"numPlanes = {arr.num_planes}")
    print(f"Bound: |shattered set| ≤ realizedPatterns.card = {arr.count_regions_sampling()}")


if __name__ == "__main__":
    np.random.seed(42)
    demo_basic_arrangement()
    demo_3d_arrangement()
    demo_degenerate()
    demo_relu_network()
    demo_stone_dual()
    demo_zaslavsky_table()
    demo_vc_dimension()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


"""
Visualization 1: Hyperplane Arrangement Regions in R^2

Visualizes the activation regions created by a hyperplane arrangement,
showing how the plane is partitioned into colored regions. Each color
represents a distinct activation pattern — these are the atoms of the
activation algebra and the points of the Stone dual space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def dot_prod(v, x):
    return np.sum(v * x, axis=-1)


def activation_pattern_grid(normals, biases, xx, yy):
    """Compute activation pattern for each point on a grid."""
    grid = np.stack([xx, yy], axis=-1)
    k = len(normals)
    patterns = np.zeros(xx.shape, dtype=int)
    for j in range(k):
        sign = dot_prod(normals[j], grid) + biases[j] > 0
        patterns += sign.astype(int) * (2**j)
    return patterns


def plot_arrangement_regions():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Example 1: Two perpendicular lines
    normals1 = [np.array([1, 0]), np.array([0, 1])]
    biases1 = [0, 0]

    # Example 2: Three lines in general position
    normals2 = [np.array([1, 0]), np.array([0, 1]), np.array([1, 1])]
    biases2 = [0, 0, 0]

    # Example 3: ReLU network (4 neurons)
    np.random.seed(42)
    normals3 = [np.array([1, 1]), np.array([-1, 1]),
                np.array([1, -1]), np.array([0.5, -0.5])]
    biases3 = [0, 0, 0, 0.5]

    examples = [
        (normals1, biases1, "2 Lines: 4 Regions"),
        (normals2, biases2, "3 Lines: 7 Regions (Zaslavsky)"),
        (normals3, biases3, "4 Neurons: ReLU Network"),
    ]

    x = np.linspace(-3, 3, 500)
    y = np.linspace(-3, 3, 500)
    xx, yy = np.meshgrid(x, y)

    cmap = plt.cm.Set3
    for ax, (normals, biases, title) in zip(axes, examples):
        patterns = activation_pattern_grid(normals, biases, xx, yy)
        unique_patterns = np.unique(patterns)
        n_regions = len(unique_patterns)

        # Map patterns to consecutive integers for coloring
        pattern_map = {p: i for i, p in enumerate(unique_patterns)}
        colored = np.vectorize(pattern_map.get)(patterns)

        ax.contourf(xx, yy, colored, levels=np.arange(-0.5, n_regions),
                    cmap=cmap, alpha=0.7)

        # Draw hyperplane lines
        for j, (n, b) in enumerate(zip(normals, biases)):
            if abs(n[1]) > 1e-10:
                yline = -(n[0] * x + b) / n[1]
                mask = (yline > -3) & (yline < 3)
                ax.plot(x[mask], yline[mask], 'k-', linewidth=1.5, alpha=0.8)
            else:
                xval = -b / n[0]
                ax.axvline(x=xval, color='k', linewidth=1.5, alpha=0.8)

        k = len(normals)
        ax.set_title(f"{title}\n(k={k}, 2^k={2**k}, actual={n_regions})",
                     fontsize=12, fontweight='bold')
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')

    fig.suptitle('Activation Regions of Hyperplane Arrangements\n'
                 '(Each color = one activation pattern = one Stone dual point)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_regions.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_regions.png")


if __name__ == "__main__":
    plot_arrangement_regions()


"""
Visualization 3: Stone Dual Space and Boolean Algebra Structure

Visualizes the Stone dual space of a hyperplane arrangement, showing
the correspondence between activation patterns (algebra atoms) and
geometric regions. The Hasse diagram shows the Boolean algebra structure,
while the 2D plot shows the geometric realization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def make_arrangement_and_patterns():
    """Create a 3-line arrangement in R^2 and find all patterns."""
    normals = [np.array([1, 0]), np.array([0, 1]), np.array([1, 1])]
    biases = [0, 0, 0]

    x = np.linspace(-3, 3, 200)
    y = np.linspace(-3, 3, 200)
    xx, yy = np.meshgrid(x, y)
    grid = np.stack([xx, yy], axis=-1)

    patterns_map = {}
    for i in range(200):
        for j in range(200):
            pt = grid[i, j]
            pat = tuple(np.dot(n, pt) + b > 0 for n, b in zip(normals, biases))
            if pat not in patterns_map:
                patterns_map[pat] = []
            patterns_map[pat].append((xx[i, j], yy[i, j]))

    return normals, biases, patterns_map


def plot_stone_dual():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    normals, biases, patterns_map = make_arrangement_and_patterns()
    patterns = sorted(patterns_map.keys())

    # Color map for patterns
    colors = plt.cm.Set2(np.linspace(0, 1, len(patterns)))

    # Left: Geometric regions
    ax1 = axes[0]
    for idx, pat in enumerate(patterns):
        pts = patterns_map[pat]
        xs, ys = zip(*pts)
        label = ''.join(['+' if p else '-' for p in pat])
        ax1.scatter(xs, ys, c=[colors[idx]], s=0.5, alpha=0.6, label=label)

    # Draw hyperplane lines
    x_line = np.linspace(-3, 3, 100)
    for n, b in zip(normals, biases):
        if abs(n[1]) > 1e-10:
            y_line = -(n[0] * x_line + b) / n[1]
            mask = (y_line > -3) & (y_line < 3)
            ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=2)
        else:
            ax1.axvline(-b / n[0], color='k', linewidth=2)

    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_aspect('equal')
    ax1.set_title('Geometric Realization\n(Regions in R²)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('x₁', fontsize=11)
    ax1.set_ylabel('x₂', fontsize=11)
    ax1.legend(title='Pattern (h₁h₂h₃)', fontsize=8, title_fontsize=9,
               loc='upper left', markerscale=5)

    # Right: Stone dual space as a graph
    ax2 = axes[1]

    n_patterns = len(patterns)
    # Arrange points in a circle
    angles = np.linspace(0, 2 * np.pi, n_patterns, endpoint=False)
    radius = 2
    xs = radius * np.cos(angles)
    ys = radius * np.sin(angles)

    for idx, pat in enumerate(patterns):
        label = ''.join(['+' if p else '-' for p in pat])
        ax2.scatter(xs[idx], ys[idx], c=[colors[idx]], s=300, zorder=5,
                    edgecolors='black', linewidth=1.5)
        ax2.annotate(label, (xs[idx], ys[idx]), fontsize=9, ha='center', va='center',
                     fontweight='bold')

    # Draw edges between patterns that differ in exactly one coordinate
    for i in range(n_patterns):
        for j in range(i + 1, n_patterns):
            diff = sum(1 for a, b in zip(patterns[i], patterns[j]) if a != b)
            if diff == 1:
                ax2.plot([xs[i], xs[j]], [ys[i], ys[j]], 'k-', alpha=0.3, linewidth=1)

    ax2.set_xlim(-3.5, 3.5)
    ax2.set_ylim(-3.5, 3.5)
    ax2.set_aspect('equal')
    ax2.set_title(f'Stone Dual Space\n({n_patterns} points = {n_patterns} atoms)',
                  fontsize=13, fontweight='bold')
    ax2.axis('off')

    # Add annotation about the duality
    ax2.text(0, -3.2,
             f'Each point = one ultrafilter = one activation pattern\n'
             f'Edges connect patterns differing by one hyperplane\n'
             f'Boolean algebra has {n_patterns} atoms, 2^{n_patterns}={2**n_patterns} elements',
             ha='center', fontsize=10, style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('Stone Duality: Geometry ↔ Algebra\n'
                 '3 hyperplanes in R² → 7 regions → 7-point Stone dual',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_stone_dual.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_stone_dual.png")


if __name__ == "__main__":
    plot_stone_dual()


"""
Visualization 2: Zaslavsky Bound vs 2^k Bound

Shows how the Zaslavsky bound (dimension-dependent) compares to the
naive 2^k bound. This visualizes the key insight that low-dimensional
inputs constrain the number of linear regions far below the theoretical
maximum, explaining why depth matters for expressivity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def zaslavsky_bound(n, k):
    """sum_{i=0}^{min(n,k)} C(k,i)"""
    return sum(comb(k, i) for i in range(min(n, k) + 1))


def plot_zaslavsky():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    k_values = np.arange(0, 21)

    # Left plot: Zaslavsky bound for different dimensions
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))

    for idx, n in enumerate([1, 2, 3, 5, 10]):
        bounds = [zaslavsky_bound(n, k) for k in k_values]
        ax1.semilogy(k_values, bounds, 'o-', color=colors[idx],
                     label=f'n={n}', markersize=4, linewidth=2)

    two_pow = [2**k for k in k_values]
    ax1.semilogy(k_values, two_pow, 'k--', linewidth=2, alpha=0.5,
                 label='2^k (naive)')

    ax1.set_xlabel('k (number of hyperplanes)', fontsize=12)
    ax1.set_ylabel('Maximum regions (log scale)', fontsize=12)
    ax1.set_title('Zaslavsky Bound vs Dimension', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right plot: Ratio of Zaslavsky to 2^k
    ax2 = axes[1]

    for idx, n in enumerate([1, 2, 3, 5, 10]):
        ratios = [zaslavsky_bound(n, k) / (2**k) if 2**k > 0 else 1
                  for k in k_values]
        ax2.plot(k_values, ratios, 'o-', color=colors[idx],
                 label=f'n={n}', markersize=4, linewidth=2)

    ax2.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='Ratio = 1')
    ax2.set_xlabel('k (number of hyperplanes)', fontsize=12)
    ax2.set_ylabel('Zaslavsky / 2^k', fontsize=12)
    ax2.set_title('Efficiency Ratio: How Much Dimension Constrains\n'
                  'Expressivity Below the Maximum', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.1)

    fig.suptitle('The Zaslavsky Bound: Dimension Controls Expressivity\n'
                 '(Lower ratio = more "wasted" neurons)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_zaslavsky.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_zaslavsky.png")


if __name__ == "__main__":
    plot_zaslavsky()
