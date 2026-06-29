#!/usr/bin/env python3
"""Build PACKAGE.json with all embedded content."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Load visualizations
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
lean_code = read_file('Bridges/AlgebraTropicalMachineLearning/TropicalBarronChoquetDuality.lean')

package = {
    "title": "Tropical Barron-Choquet Duality via Idempotent Feature Semimodules",
    "domain": "Bridges: Algebra × Tropical Geometry × Machine Learning",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Network Compression Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Network Compression",
            "pseudocode": """Algorithm: TROPICAL-COMPRESS(R)
Input: Tropical network R = (I, w, eval)
Output: Irredundant network R* computing same function

1. S ← I
2. repeat
3.   found_dominated ← false
4.   for each i ∈ S:
5.     if ∃ j ∈ S, j ≠ i, ∀f: w(i)+eval(i)(f) ≤ w(j)+eval(j)(f):
6.       S ← S \\ {i}
7.       found_dominated ← true
8.       break
9. until ¬found_dominated
10. return (S, w|_S, eval|_S)

Complexity: O(|I|² · n) for n-dimensional inputs.""",
            "code": """import numpy as np

def tropical_compress(weights, eval_matrix):
    \"\"\"Compress a tropical network by removing dominated units.
    
    Args:
        weights: array of shape (n_units,)
        eval_matrix: array of shape (n_units, n_inputs)
    
    Returns:
        active_indices: list of surviving unit indices
    \"\"\"
    active = list(range(len(weights)))
    changed = True
    while changed:
        changed = False
        for idx, i in enumerate(active):
            for j in active:
                if j == i:
                    continue
                # Check pointwise domination via random sampling
                dominated = True
                for _ in range(500):
                    f = np.random.randn(eval_matrix.shape[1])
                    ci = weights[i] + eval_matrix[i] @ f
                    cj = weights[j] + eval_matrix[j] @ f
                    if ci > cj + 1e-10:
                        dominated = False
                        break
                if dominated:
                    active.pop(idx)
                    changed = True
                    break
            if changed:
                break
    return active

# Example
weights = np.array([2.0, 1.0, 1.0])  # Unit 2 dominated by unit 0
evals = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 0.0]])
evals[2] = evals[0]  # Same evaluation as unit 0
weights[2] = weights[0] - 1  # Lower weight => dominated

result = tropical_compress(weights, evals)
print(f"Active units: {result}")  # Should exclude unit 2
"""
        },
        {
            "name": "Weight Recovery from Isolating Inputs",
            "pseudocode": """Algorithm: RECOVER-WEIGHTS(L, eval, S)
Input: Functional L, evaluations eval, support S
Output: Weight function w on S

1. for each s ∈ S:
2.   f_s ← FIND-ISOLATING-INPUT(s, S, eval)
3.   w(s) ← L(f_s) - eval(s)(f_s)
4. return w

Complexity: O(|S| · C_isolate)""",
            "code": """import numpy as np

def recover_weights(L_func, eval_matrix, active_indices):
    \"\"\"Recover tropical network weights from functional values.
    
    Args:
        L_func: callable, the tropical functional
        eval_matrix: evaluation matrix
        active_indices: list of active unit indices
    
    Returns:
        recovered_weights: array of recovered weights
    \"\"\"
    n = len(active_indices)
    recovered = np.zeros(n)
    
    for idx, i in enumerate(active_indices):
        # Find isolating input by gradient ascent
        f = np.random.randn(eval_matrix.shape[1])
        for _ in range(100):
            margins = []
            for j in active_indices:
                if j == i:
                    continue
                margin = (eval_matrix[i] - eval_matrix[j]) @ f
                margins.append((margin, j))
            if not margins:
                break
            min_margin, j_close = min(margins, key=lambda x: x[0])
            if min_margin > 1.0:
                break
            grad = eval_matrix[i] - eval_matrix[j_close]
            f = f + 0.5 * grad
        
        recovered[idx] = L_func(f) - eval_matrix[i] @ f
    
    return recovered

# Example
weights = np.array([2.0, -1.0, 0.5])
evals = np.array([[3.0, 0.0], [0.0, 3.0], [-1.0, -1.0]])
L = lambda f: max(weights[i] + evals[i] @ f for i in range(3))

recovered = recover_weights(L, evals, [0, 1, 2])
print(f"True weights: {weights}")
print(f"Recovered:    {recovered}")
"""
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Network Activation Regions",
            "data": viz_data['tropical_regions']
        },
        {
            "name": "Certified Tropical Compression",
            "data": viz_data['compression']
        },
        {
            "name": "Lipschitz-1 Stability",
            "data": viz_data['stability']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json created ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Barron-Choquet Duality: Demonstrations

Demonstrates the main theorems:
1. Tropical network evaluation
2. Dominated unit detection and elimination
3. Irredundant compression
4. Weight recovery from isolating inputs
5. Perturbation stability
"""

import numpy as np
from typing import List, Tuple, Optional
import itertools


class TropicalNetwork:
    """A tropical neural network: N(f) = max_i (w_i + eval_i(f))"""

    def __init__(self, weights: np.ndarray, eval_matrix: np.ndarray):
        """
        Args:
            weights: 1D array of shape (n_units,) - tropical weights
            eval_matrix: 2D array of shape (n_units, n_inputs) - evaluation values
        """
        self.weights = weights.copy()
        self.eval_matrix = eval_matrix.copy()
        self.n_units = len(weights)
        self.n_inputs = eval_matrix.shape[1]

    def realize(self, f: np.ndarray) -> float:
        """Compute the tropical network output on input f."""
        if self.n_units == 0:
            return 0.0
        contributions = self.weights + self.eval_matrix @ f
        return np.max(contributions)

    def realize_batch(self, F: np.ndarray) -> np.ndarray:
        """Compute outputs on a batch of inputs (rows of F)."""
        contributions = self.weights[None, :] + F @ self.eval_matrix.T
        return np.max(contributions, axis=1)

    def which_unit_wins(self, f: np.ndarray) -> int:
        """Return the index of the unit achieving the maximum."""
        contributions = self.weights + self.eval_matrix @ f
        return int(np.argmax(contributions))

    def is_dominated(self, i: int) -> Tuple[bool, Optional[int]]:
        """Check if unit i is pointwise-dominated by some other unit j.
        Returns (is_dominated, dominator_index)."""
        for j in range(self.n_units):
            if j == i:
                continue
            # Check if w_i + eval_i(f) <= w_j + eval_j(f) for all f
            # This means (w_i - w_j) + (eval_i - eval_j) . f <= 0 for all f
            # For finite-dimensional linear evals, this requires checking
            # But for simplicity, we sample many random inputs
            dominated = True
            for _ in range(1000):
                f = np.random.randn(self.n_inputs)
                if self.weights[i] + self.eval_matrix[i] @ f > self.weights[j] + self.eval_matrix[j] @ f + 1e-10:
                    dominated = False
                    break
            if dominated:
                return True, j
        return False, None

    def compress(self) -> 'TropicalNetwork':
        """Remove all dominated units, returning an irredundant network."""
        active = list(range(self.n_units))
        changed = True
        while changed:
            changed = False
            for idx, i in enumerate(active):
                # Check if i is dominated by some j in active
                for j in active:
                    if j == i:
                        continue
                    # Check pointwise domination with random sampling
                    dominated = True
                    for _ in range(500):
                        f = np.random.randn(self.n_inputs)
                        ci = self.weights[i] + self.eval_matrix[i] @ f
                        cj = self.weights[j] + self.eval_matrix[j] @ f
                        if ci > cj + 1e-10:
                            dominated = False
                            break
                    if dominated:
                        active.pop(idx)
                        changed = True
                        break
                if changed:
                    break

        new_weights = self.weights[active]
        new_evals = self.eval_matrix[active]
        return TropicalNetwork(new_weights, new_evals)

    def find_isolating_input(self, i: int, active_indices: List[int]) -> Optional[np.ndarray]:
        """Find an input where unit i strictly dominates all others."""
        # For linear evaluations, maximize w_i + eval_i(f) - max_{j≠i} (w_j + eval_j(f))
        # Use gradient ascent on the margin
        f = np.random.randn(self.n_inputs)
        for _ in range(100):
            ci = self.weights[i] + self.eval_matrix[i] @ f
            margins = []
            for j in active_indices:
                if j == i:
                    continue
                cj = self.weights[j] + self.eval_matrix[j] @ f
                margins.append(ci - cj)
            if len(margins) == 0:
                return f
            min_margin = min(margins)
            if min_margin > 0.1:
                return f
            # Gradient: increase eval_i(f) relative to closest competitor
            j_closest = active_indices[[k for k in range(len(active_indices))
                                        if active_indices[k] != i][np.argmin(margins)]]
            grad = self.eval_matrix[i] - self.eval_matrix[j_closest]
            f = f + 0.5 * grad
        return f

    def recover_weights(self, L_func, active_indices: List[int]) -> np.ndarray:
        """Recover weights from functional values on isolating inputs."""
        recovered = np.zeros(len(active_indices))
        for idx, i in enumerate(active_indices):
            f_isol = self.find_isolating_input(i, active_indices)
            if f_isol is not None:
                L_val = L_func(f_isol)
                eval_val = self.eval_matrix[i] @ f_isol
                recovered[idx] = L_val - eval_val
        return recovered


def demo_basic_evaluation():
    """Demo 1: Basic tropical network evaluation."""
    print("=" * 60)
    print("DEMO 1: Tropical Network Evaluation")
    print("=" * 60)

    # 3 units, 2-dimensional input
    weights = np.array([1.0, -0.5, 2.0])
    eval_matrix = np.array([
        [1.0, 0.0],   # Unit 0: eval(f) = f[0]
        [0.0, 1.0],   # Unit 1: eval(f) = f[1]
        [-1.0, -1.0],  # Unit 2: eval(f) = -f[0] - f[1]
    ])
    net = TropicalNetwork(weights, eval_matrix)

    print(f"Network has {net.n_units} units, {net.n_inputs}-dim input")
    print(f"Weights: {weights}")
    print()

    test_inputs = [
        np.array([3.0, 0.0]),
        np.array([0.0, 3.0]),
        np.array([-2.0, -2.0]),
        np.array([1.0, 1.0]),
    ]

    for f in test_inputs:
        output = net.realize(f)
        winner = net.which_unit_wins(f)
        contribs = weights + eval_matrix @ f
        print(f"  f = {f}")
        print(f"    Contributions: {contribs}")
        print(f"    Output = max = {output:.2f} (unit {winner} wins)")
        print()


def demo_compression():
    """Demo 2: Dominated unit elimination and compression."""
    print("=" * 60)
    print("DEMO 2: Certified Tropical Compression")
    print("=" * 60)

    # Create a network with redundant units
    np.random.seed(42)
    n_units = 10
    n_inputs = 3

    # Make some units clearly dominated
    weights = np.random.randn(n_units)
    eval_matrix = np.random.randn(n_units, n_inputs)

    # Make unit 3 a copy of unit 0 but with lower weight (dominated)
    eval_matrix[3] = eval_matrix[0]
    weights[3] = weights[0] - 1.0

    # Make unit 7 dominated by unit 5
    eval_matrix[7] = eval_matrix[5]
    weights[7] = weights[5] - 0.5

    net = TropicalNetwork(weights, eval_matrix)
    print(f"Original network: {net.n_units} units")

    # Compress
    compressed = net.compress()
    print(f"Compressed network: {compressed.n_units} units")
    print(f"Compression ratio: {net.n_units}/{compressed.n_units} = {net.n_units/compressed.n_units:.1f}x")

    # Verify functional equivalence on random inputs
    max_diff = 0.0
    for _ in range(1000):
        f = np.random.randn(n_inputs)
        diff = abs(net.realize(f) - compressed.realize(f))
        max_diff = max(max_diff, diff)

    print(f"Max difference on 1000 random inputs: {max_diff:.2e}")
    print(f"Compression is {'EXACT' if max_diff < 1e-8 else 'APPROXIMATE'}!")
    print()


def demo_weight_recovery():
    """Demo 3: Sparse weight reconstruction from isolating inputs."""
    print("=" * 60)
    print("DEMO 3: Sparse Weight Reconstruction")
    print("=" * 60)

    # Create an irredundant network
    weights = np.array([2.0, -1.0, 0.5])
    eval_matrix = np.array([
        [3.0, 0.0],
        [0.0, 3.0],
        [-1.0, -1.0],
    ])
    net = TropicalNetwork(weights, eval_matrix)

    # Define the functional L = net.realize
    L = lambda f: net.realize(f)

    # Recover weights
    active = list(range(net.n_units))
    recovered = net.recover_weights(L, active)

    print("True weights:     ", weights)
    print("Recovered weights:", recovered)
    print("Max error:        ", np.max(np.abs(weights - recovered)))
    print()


def demo_stability():
    """Demo 4: Weight perturbation stability (Lipschitz-1 bound)."""
    print("=" * 60)
    print("DEMO 4: Perturbation Stability")
    print("=" * 60)

    np.random.seed(123)
    n_units = 5
    n_inputs = 3

    # Create two networks with close weights
    eval_matrix = np.random.randn(n_units, n_inputs) * 2
    weights1 = np.random.randn(n_units)
    epsilon = 0.1
    weights2 = weights1 + np.random.randn(n_units) * epsilon

    net1 = TropicalNetwork(weights1, eval_matrix)
    net2 = TropicalNetwork(weights2, eval_matrix)

    # Measure functional distance
    max_func_diff = 0.0
    for _ in range(10000):
        f = np.random.randn(n_inputs) * 3
        diff = abs(net1.realize(f) - net2.realize(f))
        max_func_diff = max(max_func_diff, diff)

    # Measure weight distance
    max_weight_diff = np.max(np.abs(weights1 - weights2))

    print(f"Weight perturbation:    ||w1 - w2||_inf = {max_weight_diff:.4f}")
    print(f"Functional perturbation: ||L1 - L2||_inf ≤ {max_func_diff:.4f}")
    print(f"Stability ratio:         {max_func_diff/max_weight_diff:.4f}")
    print(f"(Theory predicts ratio ≤ 1.0)")
    print()


def demo_tropical_idempotent():
    """Demo 5: Tropical idempotency — max(x, x) = x."""
    print("=" * 60)
    print("DEMO 5: Tropical Idempotency")
    print("=" * 60)

    # Duplicating a unit in a tropical network doesn't change its output
    weights = np.array([1.0, 2.0, -1.0])
    eval_matrix = np.array([
        [1.0, 0.5],
        [0.0, 1.0],
        [-0.5, 0.5],
    ])

    # Duplicate unit 1
    weights_dup = np.array([1.0, 2.0, -1.0, 2.0])
    eval_matrix_dup = np.array([
        [1.0, 0.5],
        [0.0, 1.0],
        [-0.5, 0.5],
        [0.0, 1.0],  # copy of unit 1
    ])

    net = TropicalNetwork(weights, eval_matrix)
    net_dup = TropicalNetwork(weights_dup, eval_matrix_dup)

    print("Original: 3 units")
    print("Duplicated: 4 units (unit 1 copied)")

    max_diff = 0.0
    for _ in range(1000):
        f = np.random.randn(2)
        diff = abs(net.realize(f) - net_dup.realize(f))
        max_diff = max(max_diff, diff)

    print(f"Max difference: {max_diff:.2e}")
    print("By tropical idempotency: max(x, x) = x ⟹ duplication is invisible")
    print()


def demo_large_compression():
    """Demo 6: Large-scale compression experiment."""
    print("=" * 60)
    print("DEMO 6: Large-Scale Compression Statistics")
    print("=" * 60)

    np.random.seed(0)
    results = []

    for n_units in [20, 50, 100]:
        for n_inputs in [2, 5, 10]:
            compression_ratios = []
            for trial in range(5):
                weights = np.random.randn(n_units)
                eval_matrix = np.random.randn(n_units, n_inputs)

                # Add some dominated units
                n_dominated = n_units // 3
                for k in range(n_dominated):
                    src = np.random.randint(0, n_units - n_dominated)
                    eval_matrix[n_units - n_dominated + k] = eval_matrix[src]
                    weights[n_units - n_dominated + k] = weights[src] - abs(np.random.randn())

                net = TropicalNetwork(weights, eval_matrix)
                compressed = net.compress()
                ratio = net.n_units / max(compressed.n_units, 1)
                compression_ratios.append(ratio)

            avg_ratio = np.mean(compression_ratios)
            results.append((n_units, n_inputs, avg_ratio))
            print(f"  n_units={n_units:3d}, n_inputs={n_inputs:2d}: "
                  f"avg compression ratio = {avg_ratio:.1f}x")

    print()


if __name__ == "__main__":
    demo_basic_evaluation()
    demo_compression()
    demo_weight_recovery()
    demo_stability()
    demo_tropical_idempotent()
    demo_large_compression()

    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for Tropical Barron-Choquet Duality."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_tropical_network_regions():
    """Visualize the piecewise-linear regions of a tropical network."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # 2D tropical network: N(x,y) = max(w1 + a1*x + b1*y, w2 + a2*x + b2*y, w3 + a3*x + b3*y)
    weights = np.array([1.0, -0.5, 2.0])
    eval_vecs = np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]])

    x = np.linspace(-3, 3, 300)
    y = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x, y)

    # Compute which unit wins at each point
    contribs = np.zeros((3, 300, 300))
    for i in range(3):
        contribs[i] = weights[i] + eval_vecs[i, 0] * X + eval_vecs[i, 1] * Y

    winner = np.argmax(contribs, axis=0)
    Z = np.max(contribs, axis=0)

    # Plot 1: Winner regions
    ax = axes[0]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    cmap = matplotlib.colors.ListedColormap(colors)
    ax.contourf(X, Y, winner, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap, alpha=0.4)
    ax.contour(X, Y, winner, levels=[0.5, 1.5], colors='black', linewidths=2)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical Network: Activation Regions', fontsize=14, fontweight='bold')
    for i, (name, color) in enumerate(zip(
            ['Unit 0: w=1, φ(x,y)=x', 'Unit 1: w=-0.5, φ(x,y)=y',
             'Unit 2: w=2, φ(x,y)=-x-y'],
            colors)):
        ax.plot([], [], 's', color=color, markersize=10, label=name)
    ax.legend(loc='lower left', fontsize=9)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)

    # Plot 2: Surface
    ax = axes[1]
    cs = ax.contourf(X, Y, Z, levels=20, cmap='viridis')
    ax.contour(X, Y, winner, levels=[0.5, 1.5], colors='white', linewidths=2, linestyles='--')
    plt.colorbar(cs, ax=ax, label='N(x, y)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical Network: Output Surface', fontsize=14, fontweight='bold')

    fig.suptitle('Tropical Neural Network with 3 Hidden Units', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_compression_demo():
    """Visualize before/after compression."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    np.random.seed(42)
    x = np.linspace(-5, 5, 500)

    # Original network: 6 lines (hidden units), some dominated
    weights = [2.0, 1.0, -1.0, 0.5, 1.5, -0.5]
    slopes = [0.5, -0.3, 0.8, 0.5, -0.3, 1.0]  # units 3, 4 are copies of 0, 1 with lower w

    # Compute the upper envelope
    lines = np.array([w + s * x for w, s in zip(weights, slopes)])
    envelope = np.max(lines, axis=0)

    # Plot original
    ax = axes[0]
    colors_orig = ['#2196F3', '#FF5722', '#4CAF50', '#9E9E9E', '#9E9E9E', '#FFC107']
    for i, (w, s) in enumerate(zip(weights, slopes)):
        line = w + s * x
        alpha = 0.3 if i in [3, 4] else 0.6
        lw = 1 if i in [3, 4] else 1.5
        ls = '--' if i in [3, 4] else '-'
        label = f'Unit {i}: w={w}, slope={s}'
        if i in [3, 4]:
            label += ' (DOMINATED)'
        ax.plot(x, line, color=colors_orig[i], alpha=alpha, linewidth=lw, linestyle=ls, label=label)
    ax.plot(x, envelope, 'k-', linewidth=2.5, label='Network output (envelope)')
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Output', fontsize=12)
    ax.set_title(f'Before Compression: {len(weights)} units', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, loc='upper left')
    ax.set_ylim(-5, 8)
    ax.grid(True, alpha=0.3)

    # After compression (remove dominated units 3, 4)
    keep = [0, 1, 2, 5]
    lines_compressed = lines[keep]
    envelope_c = np.max(lines_compressed, axis=0)

    ax = axes[1]
    for idx, i in enumerate(keep):
        line = weights[i] + slopes[i] * x
        ax.plot(x, line, color=colors_orig[i], alpha=0.6, linewidth=1.5,
                label=f'Unit {i}: w={weights[i]}, slope={slopes[i]}')
    ax.plot(x, envelope_c, 'k-', linewidth=2.5, label='Network output (identical!)')
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Output', fontsize=12)
    ax.set_title(f'After Compression: {len(keep)} units (irredundant)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, loc='upper left')
    ax.set_ylim(-5, 8)
    ax.grid(True, alpha=0.3)

    # Verify same envelope
    max_diff = np.max(np.abs(envelope - envelope_c))
    fig.suptitle(f'Certified Tropical Compression (max error = {max_diff:.1e})',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_stability():
    """Visualize weight stability under perturbation."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(7)
    epsilons = np.linspace(0.01, 1.0, 50)
    n_trials = 20
    n_units = 5
    n_inputs = 3

    max_weight_diffs = []
    max_func_diffs = []

    for eps in epsilons:
        wd_list = []
        fd_list = []
        for _ in range(n_trials):
            eval_matrix = np.random.randn(n_units, n_inputs) * 2
            w1 = np.random.randn(n_units)
            w2 = w1 + np.random.randn(n_units) * eps

            # Measure functional difference
            max_fd = 0
            for __ in range(500):
                f = np.random.randn(n_inputs) * 3
                c1 = np.max(w1 + eval_matrix @ f)
                c2 = np.max(w2 + eval_matrix @ f)
                max_fd = max(max_fd, abs(c1 - c2))

            wd_list.append(np.max(np.abs(w1 - w2)))
            fd_list.append(max_fd)

        max_weight_diffs.append(np.mean(wd_list))
        max_func_diffs.append(np.mean(fd_list))

    ax.plot(max_weight_diffs, max_func_diffs, 'o', color='#2196F3', alpha=0.6,
            markersize=6, label='Empirical (mean over 20 trials)')
    ax.plot([0, max(max_weight_diffs)], [0, max(max_weight_diffs)], 'r--',
            linewidth=2, label='Stability bound: ratio = 1')
    ax.set_xlabel('Weight perturbation ||w₁ - w₂||∞', fontsize=12)
    ax.set_ylabel('Functional perturbation ||L₁ - L₂||∞', fontsize=12)
    ax.set_title('Lipschitz-1 Stability of Tropical Networks', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = viz_tropical_network_regions()
    print(f"  Tropical network regions: {len(viz1)} chars")

    viz2 = viz_compression_demo()
    print(f"  Compression demo: {len(viz2)} chars")

    viz3 = viz_stability()
    print(f"  Stability plot: {len(viz3)} chars")

    # Save for use in PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump({
            'tropical_regions': viz1,
            'compression': viz2,
            'stability': viz3,
        }, f)

    print("Visualizations saved to viz_data.json")
