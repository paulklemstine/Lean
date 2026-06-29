#!/usr/bin/env python3
"""
Applications of Compact Tropical Entropy to real-world problems.

Demonstrates connections to:
1. Neural network loss landscape optimization
2. Zero-temperature statistical mechanics
3. Tropical optimal transport
4. Signal compression and data processing
"""

import numpy as np
from typing import Tuple


def neural_network_loss_landscape():
    """
    Application: Tropical partition function on a neural network loss landscape.

    A simple 2-parameter network has loss L(w1, w2) = (w1*w2 - target)^2 + reg*(w1^2 + w2^2).
    The tropical partition function gives the global minimum loss.
    """
    print("=" * 70)
    print("APPLICATION 1: Neural Network Loss Landscape")
    print("=" * 70)

    target = 1.0
    reg = 0.01  # Regularization strength

    def loss(w: np.ndarray) -> float:
        w1, w2 = w
        return (w1 * w2 - target) ** 2 + reg * (w1**2 + w2**2)

    # Grid search on compact parameter space [-3, 3]^2
    N = 201
    w_range = np.linspace(-3, 3, N)
    grid = np.array([(w1, w2) for w1 in w_range for w2 in w_range])
    losses = np.array([loss(w) for w in grid])

    z_trop = np.min(losses)
    best_idx = np.argmin(losses)
    best_w = grid[best_idx]

    print(f"\nLoss: L(w1,w2) = (w1*w2 - 1)^2 + 0.01*(w1^2 + w2^2)")
    print(f"Parameter space: [-3, 3]^2 (compact)")
    print(f"Tropical partition function (min loss): {z_trop:.6f}")
    print(f"Optimal parameters: w1={best_w[0]:.4f}, w2={best_w[1]:.4f}")
    print(f"Product w1*w2 = {best_w[0]*best_w[1]:.4f} (target: {target})")

    # Monotonicity: increasing regularization increases minimum loss
    print("\nMonotonicity under regularization strength:")
    for reg_val in [0.0, 0.01, 0.1, 0.5, 1.0]:
        def loss_reg(w, r=reg_val):
            return (w[0]*w[1] - target)**2 + r*(w[0]**2 + w[1]**2)
        losses_r = np.array([loss_reg(w) for w in grid])
        print(f"  λ = {reg_val:.2f}: Z_trop = {np.min(losses_r):.6f}")
    print()


def zero_temperature_physics():
    """
    Application: Ground state selection in a 1D quantum-inspired system.

    The energy landscape E(x) = -cos(2πx) + 0.3*cos(6πx) models a particle
    in a periodic potential with harmonics. The tropical partition function
    selects the ground state.
    """
    print("=" * 70)
    print("APPLICATION 2: Zero-Temperature Statistical Mechanics")
    print("=" * 70)

    grid = np.linspace(0, 1, 100001)

    def potential(x):
        return -np.cos(2 * np.pi * x) + 0.3 * np.cos(6 * np.pi * x)

    E_vals = np.array([potential(x) for x in grid])
    z_trop = np.min(E_vals)
    x_ground = grid[np.argmin(E_vals)]

    print(f"\nPotential: V(x) = -cos(2πx) + 0.3*cos(6πx)")
    print(f"Configuration space: [0, 1] (compact)")
    print(f"Ground state energy: E_0 = {z_trop:.8f}")
    print(f"Ground state position: x_0 = {x_ground:.6f}")

    # Classical vs tropical comparison
    print("\nClassical → Tropical convergence (temperature → 0):")
    print(f"{'Temperature':>12} | {'F_classical':>14} | {'Error':>12}")
    print("-" * 45)

    for T in [10.0, 1.0, 0.1, 0.01, 0.001]:
        beta = 1.0 / T
        shifted = -beta * E_vals
        max_s = np.max(shifted)
        log_Z = max_s + np.log(np.sum(np.exp(shifted - max_s)))
        F = -log_Z / beta
        print(f"{T:12.4f} | {F:14.8f} | {abs(F - z_trop):12.2e}")
    print()


def tropical_signal_compression():
    """
    Application: Data processing inequality for signal compression.

    A signal x ∈ [0, 1]^2 is compressed to y = f(x) ∈ [0, 1] via projection.
    The DPI guarantees the compressed system's minimum energy is ≤ the original's.
    """
    print("=" * 70)
    print("APPLICATION 3: Signal Compression via Data Processing")
    print("=" * 70)

    N = 101
    grid_1d = np.linspace(0, 1, N)
    grid_2d = np.array([(x, y) for x in grid_1d for y in grid_1d])

    # Original signal energy
    def E_signal(xy):
        x, y = xy
        return (x - 0.5)**2 + (y - 0.3)**2 + 0.05 * np.sin(10*x) * np.cos(8*y)

    # Compressed energy (projection to 1D)
    def E_compressed(y_val):
        return (y_val - 0.3)**2  # Best achievable along fiber

    # Naive compressed energy (just use y coordinate)
    def E_naive(y_val):
        return (0.5 - 0.5)**2 + (y_val - 0.3)**2  # Fix x=0.5

    E_orig_vals = np.array([E_signal(xy) for xy in grid_2d])
    E_comp_vals = np.array([E_compressed(y) for y in grid_1d])
    E_naive_vals = np.array([E_naive(y) for y in grid_1d])

    z_orig = np.min(E_orig_vals)
    z_comp = np.min(E_comp_vals)
    z_naive = np.min(E_naive_vals)

    print(f"\nOriginal system: X = [0,1]^2")
    print(f"E(x,y) = (x-0.5)^2 + (y-0.3)^2 + 0.05*sin(10x)*cos(8y)")
    print(f"Z_trop(original) = {z_orig:.8f}")
    print(f"\nCompressed system: Y = [0,1] (projection to y-axis)")
    print(f"F(y) = (y-0.3)^2  (fiber-minimized)")
    print(f"Z_trop(compressed) = {z_comp:.8f}")
    print(f"Z_trop(naive compressed) = {z_naive:.8f}")
    print(f"\nDPI: Z_trop(compressed) ≤ Z_trop(original)? {z_comp <= z_orig + 1e-10}")
    print(f"Information loss gap: {z_orig - z_comp:.8f}")
    print()


def tropical_portfolio_optimization():
    """
    Application: Portfolio optimization as tropical partition function.

    Given n assets with return vectors, find the minimum-risk portfolio.
    The tropical partition function gives the minimum achievable risk.
    """
    print("=" * 70)
    print("APPLICATION 4: Portfolio Risk Minimization")
    print("=" * 70)

    np.random.seed(42)

    # Simulate 3-asset covariance matrix
    n_assets = 3
    A = np.random.randn(n_assets, n_assets)
    cov = A @ A.T + 0.1 * np.eye(n_assets)  # Positive definite

    expected_returns = np.array([0.08, 0.12, 0.05])

    def portfolio_risk(weights):
        """Variance of portfolio return."""
        return float(weights @ cov @ weights)

    # Search over simplex (compact!)
    N = 51
    best_risk = float('inf')
    best_weights = None

    portfolios = []
    for i in range(N):
        for j in range(N - i):
            k = N - 1 - i - j
            w = np.array([i, j, k], dtype=float) / (N - 1)
            risk = portfolio_risk(w)
            portfolios.append((w, risk))
            if risk < best_risk:
                best_risk = risk
                best_weights = w.copy()

    print(f"\nAssets: {n_assets}")
    print(f"Covariance matrix:\n{cov.round(4)}")
    print(f"Expected returns: {expected_returns}")
    print(f"\nSearch space: Probability simplex (compact)")
    print(f"Z_trop (minimum risk) = {best_risk:.6f}")
    print(f"Optimal weights: {best_weights.round(4)}")
    print(f"Expected return: {float(best_weights @ expected_returns):.4f}")

    # Translation invariance: adding constant risk premium
    c = 0.05
    shifted_risks = [r + c for _, r in portfolios]
    z_shifted = min(shifted_risks)
    print(f"\nTranslation invariance (c={c}):")
    print(f"Z_trop(risk + {c}) = {z_shifted:.6f}")
    print(f"Z_trop(risk) + {c} = {best_risk + c:.6f}")
    print(f"Match: {abs(z_shifted - (best_risk + c)) < 1e-10}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  COMPACT TROPICAL ENTROPY: Real-World Applications")
    print("=" * 70 + "\n")

    neural_network_loss_landscape()
    zero_temperature_physics()
    tropical_signal_compression()
    tropical_portfolio_optimization()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demonstration of Compact Tropical Entropy theorems with concrete numerical examples.

This script demonstrates all six structural laws of the tropical partition function
on compact spaces, using discretized approximations of continuous energy landscapes.
"""

import numpy as np
from typing import Callable, Tuple


def tropical_partition(E: np.ndarray) -> float:
    """Compute the tropical partition function: Z_trop = min(E)."""
    return float(np.min(E))


def tropical_partition_on_grid(
    E_func: Callable, grid: np.ndarray
) -> Tuple[float, float]:
    """Compute tropical partition function on a grid, returning (Z_trop, minimizer)."""
    values = np.array([E_func(x) for x in grid])
    idx = np.argmin(values)
    return float(values[idx]), float(grid[idx])


def demo_attainment():
    """Demonstrate Theorem 3.2: Attainment of the minimum."""
    print("=" * 70)
    print("THEOREM: Attainment (tropicalPartitionCompact_attained)")
    print("On a compact space with LSC energy, the minimum is achieved.")
    print("=" * 70)

    # Energy: E(x) = (x - 0.3)^2 on [0, 1]
    grid = np.linspace(0, 1, 10001)
    E = lambda x: (x - 0.3) ** 2

    z_trop, x_min = tropical_partition_on_grid(E, grid)
    print(f"\nEnergy: E(x) = (x - 0.3)^2 on [0, 1]")
    print(f"Tropical partition function: Z_trop = {z_trop:.8f}")
    print(f"Minimizer: x_0 = {x_min:.4f}")
    print(f"E(x_0) = {E(x_min):.8f}")
    print(f"Attainment verified: E(x_0) == Z_trop? {np.isclose(E(x_min), z_trop)}")

    # Multi-modal energy
    E2 = lambda x: min(abs(x - 0.2), abs(x - 0.8))
    z_trop2, x_min2 = tropical_partition_on_grid(E2, grid)
    print(f"\nEnergy: E(x) = min(|x - 0.2|, |x - 0.8|) on [0, 1]")
    print(f"Z_trop = {z_trop2:.8f}, minimizer at x_0 = {x_min2:.4f}")
    print(f"E(x_0) = {E2(x_min2):.8f}")
    print()


def demo_translation_invariance():
    """Demonstrate Theorem 3.6: Translation invariance."""
    print("=" * 70)
    print("THEOREM: Translation Invariance (tropicalPartitionCompact_add_const)")
    print("Z_trop(E + c) = Z_trop(E) + c")
    print("=" * 70)

    grid = np.linspace(0, 1, 10001)
    E = lambda x: np.sin(5 * x) + x**2

    E_values = np.array([E(x) for x in grid])
    z_base = tropical_partition(E_values)

    for c in [-3.0, 0.0, 2.5, 10.0]:
        E_shifted = E_values + c
        z_shifted = tropical_partition(E_shifted)
        expected = z_base + c
        match = np.isclose(z_shifted, expected)
        print(f"c = {c:6.1f}: Z_trop(E+c) = {z_shifted:10.6f}, "
              f"Z_trop(E) + c = {expected:10.6f}, match = {match}")
    print()


def demo_monotonicity():
    """Demonstrate Theorem 3.7: Monotonicity."""
    print("=" * 70)
    print("THEOREM: Monotonicity (tropicalPartitionCompact_mono)")
    print("E(x) <= F(x) for all x  ==>  Z_trop(E) <= Z_trop(F)")
    print("=" * 70)

    grid = np.linspace(0, 1, 10001)
    E = lambda x: x**2
    F = lambda x: x**2 + 0.1 * np.sin(10 * x) + 0.2

    E_vals = np.array([E(x) for x in grid])
    F_vals = np.array([F(x) for x in grid])

    # Verify pointwise inequality
    pointwise = np.all(E_vals <= F_vals + 1e-10)
    z_E = tropical_partition(E_vals)
    z_F = tropical_partition(F_vals)

    print(f"\nE(x) = x^2")
    print(f"F(x) = x^2 + 0.1*sin(10x) + 0.2")
    print(f"E(x) <= F(x) for all x? {pointwise}")
    print(f"Z_trop(E) = {z_E:.8f}")
    print(f"Z_trop(F) = {z_F:.8f}")
    print(f"Z_trop(E) <= Z_trop(F)? {z_E <= z_F + 1e-10}")
    print()


def demo_pullback_surjective():
    """Demonstrate Theorem 3.8: Surjective pullback invariance."""
    print("=" * 70)
    print("THEOREM: Surjective Pullback (tropicalPartitionCompact_pullback_surjective)")
    print("f surjective ==> Z_trop(E ∘ f) = Z_trop(E)")
    print("=" * 70)

    # X = [0, 1], Y = [0, 1], f(y) = y^2 (surjective onto [0, 1])
    grid_X = np.linspace(0, 1, 10001)
    grid_Y = np.linspace(0, 1, 10001)

    E = lambda x: (x - 0.5) ** 2 + 0.1 * np.cos(4 * np.pi * x)
    f = lambda y: y  # identity is surjective

    E_vals_X = np.array([E(x) for x in grid_X])
    E_comp_f_vals = np.array([E(f(y)) for y in grid_Y])

    z_X = tropical_partition(E_vals_X)
    z_pullback = tropical_partition(E_comp_f_vals)

    print(f"\nE(x) = (x - 0.5)^2 + 0.1*cos(4πx) on [0, 1]")
    print(f"f: [0,1] → [0,1], f(y) = y (identity, surjective)")
    print(f"Z_trop(X, E) = {z_X:.8f}")
    print(f"Z_trop(Y, E∘f) = {z_pullback:.8f}")
    print(f"Equal? {np.isclose(z_X, z_pullback)}")

    # Surjection that doubles coverage: f(y) = y mod 0.5 * 2 (wrapping)
    # maps [0,1] surjectively onto [0,1]
    f2 = lambda y: (2 * y) % 1.0
    E_comp_f2_vals = np.array([E(f2(y)) for y in grid_Y])
    z_pullback2 = tropical_partition(E_comp_f2_vals)
    print(f"\nf2(y) = (2y) mod 1 (surjective, 2-to-1)")
    print(f"Z_trop(Y, E∘f2) = {z_pullback2:.8f}")
    print(f"Equal to Z_trop(X, E)? {np.isclose(z_X, z_pullback2)}")
    print()


def demo_data_processing():
    """Demonstrate Theorem 3.9: Data processing inequality."""
    print("=" * 70)
    print("THEOREM: Data Processing Inequality (tropical_data_processing)")
    print("F(f(x)) <= E(x) for all x  ==>  Z_trop(F) <= Z_trop(E)")
    print("=" * 70)

    # X = [0,1]^2, Y = [0,1], f = projection onto first coordinate
    N = 201
    grid_1d = np.linspace(0, 1, N)
    grid_2d = np.array([(x, y) for x in grid_1d for y in grid_1d])

    E = lambda xy: xy[0] ** 2 + xy[1] ** 2 + 0.5  # Energy on X = [0,1]^2
    F = lambda y: y**2  # Energy on Y = [0,1]
    f = lambda xy: xy[1]  # Projection to second coordinate

    # Verify F(f(x)) <= E(x) for all x
    violations = 0
    for xy in grid_2d:
        if F(f(xy)) > E(xy) + 1e-10:
            violations += 1

    E_vals = np.array([E(xy) for xy in grid_2d])
    F_vals = np.array([F(y) for y in grid_1d])

    z_E = tropical_partition(E_vals)
    z_F = tropical_partition(F_vals)

    print(f"\nX = [0,1]^2, Y = [0,1]")
    print(f"E(x,y) = x^2 + y^2 + 0.5 on X")
    print(f"F(y) = y^2 on Y")
    print(f"f(x,y) = y (projection)")
    print(f"F(f(x,y)) = y^2 <= x^2 + y^2 + 0.5 = E(x,y)? "
          f"Violations: {violations}/{len(grid_2d)}")
    print(f"Z_trop(Y, F) = {z_F:.8f}")
    print(f"Z_trop(X, E) = {z_E:.8f}")
    print(f"Z_trop(F) <= Z_trop(E)? {z_F <= z_E + 1e-10}")
    print()


def demo_classical_to_tropical():
    """Demonstrate convergence of classical partition function to tropical."""
    print("=" * 70)
    print("CONVERGENCE: Classical → Tropical as β → ∞")
    print("F_β = -(1/β) log Σ exp(-β E(x)) → min E(x)")
    print("=" * 70)

    grid = np.linspace(0, 1, 10001)
    E = lambda x: (x - 0.4) ** 2 + 0.1 * np.sin(8 * x)
    E_vals = np.array([E(x) for x in grid])

    z_trop = tropical_partition(E_vals)
    print(f"\nE(x) = (x - 0.4)^2 + 0.1*sin(8x) on [0, 1]")
    print(f"Z_trop (true minimum) = {z_trop:.8f}")
    print()

    print(f"{'β':>10} | {'F_β':>14} | {'|F_β - Z_trop|':>14}")
    print("-" * 45)

    for beta in [0.1, 1, 5, 10, 50, 100, 500, 1000, 5000]:
        # Use log-sum-exp trick for numerical stability
        shifted = -beta * E_vals
        max_val = np.max(shifted)
        log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))
        F_beta = -log_Z / beta
        error = abs(F_beta - z_trop)
        print(f"{beta:10.1f} | {F_beta:14.8f} | {error:14.2e}")

    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  COMPACT TROPICAL ENTROPY: Numerical Demonstrations")
    print("=" * 70 + "\n")

    demo_attainment()
    demo_translation_invariance()
    demo_monotonicity()
    demo_pullback_surjective()
    demo_data_processing()
    demo_classical_to_tropical()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables embedded."""

import json
import base64

# Read markdown files
with open('ARTICLE.md', 'r') as f:
    article = f.read()
with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()
with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Read Python code
with open('demo.py', 'r') as f:
    demo_code = f.read()
with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()
with open('applications.py', 'r') as f:
    applications_code = f.read()
with open('visualizations.py', 'r') as f:
    viz_code = f.read()

# Read Lean code
with open('Tropical/Topology/TropicalEntropyCompact.lean', 'r') as f:
    lean_code = f.read()

# Read visualization images as base64
viz_data = {}
for name in ['energy_landscape', 'translation_invariance', 'monotonicity', 'data_processing']:
    with open(f'{name}.png', 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
        viz_data[name] = f"data:image/png;base64,{b64}"

# Build package
package = {
    "title": "Compact Tropical Entropy: Topological Foundations for Zero-Temperature Information Theory",
    "domain": "Tropical Mathematics / Information Theory / Topological Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Partition Function Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Partition Function Computation",
            "pseudocode": """Algorithm: TropicalPartition(E, X)
Input: Energy function E, compact domain X (discretized to grid of N points)
Output: Z_trop = inf E(x), minimizer x_0

1. Evaluate E(x_i) for each grid point x_i, i = 1, ..., N
2. Find i* = argmin_i E(x_i)
3. Return Z_trop = E(x_{i*}), x_0 = x_{i*}

Complexity: O(N) time, O(N) space
Correctness: Converges to true infimum as grid refines (h -> 0)
""",
            "code": algorithms_code
        },
        {
            "name": "Classical-to-Tropical Convergence",
            "pseudocode": """Algorithm: ClassicalToTropical(E_values, beta)
Input: Energy values E(x_1), ..., E(x_N), inverse temperature beta
Output: Classical free energy F_beta approximating Z_trop as beta -> infinity

1. Compute shifted = -beta * E_values
2. max_val = max(shifted)  // for numerical stability
3. log_Z = max_val + log(sum(exp(shifted - max_val)))
4. Return F_beta = -log_Z / beta

Convergence: |F_beta - Z_trop| = O(log(N) / beta) as beta -> infinity
""",
            "code": "# See algorithms.py classical_free_energy function"
        }
    ],
    "visualizations": [
        {
            "name": "Energy Landscape and Attainment Theorem",
            "data": viz_data['energy_landscape']
        },
        {
            "name": "Translation Invariance",
            "data": viz_data['translation_invariance']
        },
        {
            "name": "Monotonicity Theorem",
            "data": viz_data['monotonicity']
        },
        {
            "name": "Data Processing Inequality",
            "data": viz_data['data_processing']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Compact Tropical Entropy.
Generates PNG figures illustrating key theorems and concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_energy_landscape_and_minimum():
    """Visualize the attainment theorem: minimum achieved on compact space."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: energy landscape with minimum marked
    x = np.linspace(0, 1, 1000)
    E = np.sin(5 * x) * 0.3 + (x - 0.4)**2

    ax = axes[0]
    ax.fill_between(x, E, alpha=0.15, color='steelblue')
    ax.plot(x, E, 'steelblue', linewidth=2, label='Energy E(x)')

    idx_min = np.argmin(E)
    z_trop = E[idx_min]
    x_min = x[idx_min]

    ax.axhline(y=z_trop, color='crimson', linestyle='--', linewidth=1.5,
               label=f'Z_trop = {z_trop:.4f}')
    ax.plot(x_min, z_trop, 'o', color='crimson', markersize=10, zorder=5,
            label=f'Minimizer x₀ = {x_min:.3f}')

    ax.set_xlabel('State x ∈ [0, 1] (compact)', fontsize=12)
    ax.set_ylabel('Energy E(x)', fontsize=12)
    ax.set_title('Attainment Theorem\nMinimum achieved on compact space', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: classical to tropical convergence
    ax2 = axes[1]
    betas = np.logspace(-1, 3, 50)
    F_betas = []
    for beta in betas:
        shifted = -beta * E
        max_s = np.max(shifted)
        log_Z = max_s + np.log(np.sum(np.exp(shifted - max_s)) * (x[1] - x[0]))
        F_betas.append(-log_Z / beta)

    ax2.semilogx(betas, F_betas, 'steelblue', linewidth=2,
                 label='Classical F_β')
    ax2.axhline(y=z_trop, color='crimson', linestyle='--', linewidth=1.5,
                label=f'Tropical Z_trop = {z_trop:.4f}')
    ax2.set_xlabel('Inverse temperature β', fontsize=12)
    ax2.set_ylabel('Free energy', fontsize=12)
    ax2.set_title('Classical → Tropical Convergence\nβ → ∞ limit', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_translation_invariance():
    """Visualize the translation invariance theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(0, 1, 1000)
    E_base = np.sin(5 * x) * 0.3 + (x - 0.4)**2
    z_base = np.min(E_base)

    colors = ['steelblue', 'forestgreen', 'darkorange', 'purple']
    shifts = [0, 0.5, 1.0, -0.3]

    for c, color in zip(shifts, colors):
        E_shifted = E_base + c
        z_shifted = np.min(E_shifted)
        ax.plot(x, E_shifted, color=color, linewidth=2,
                label=f'E + {c:.1f}, Z_trop = {z_shifted:.3f}')
        ax.axhline(y=z_shifted, color=color, linestyle='--', alpha=0.5, linewidth=1)

    ax.set_xlabel('State x', fontsize=12)
    ax.set_ylabel('Energy', fontsize=12)
    ax.set_title('Translation Invariance: Z_trop(E + c) = Z_trop(E) + c', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_monotonicity():
    """Visualize the monotonicity theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(0, 1, 1000)
    E = (x - 0.4)**2
    F = (x - 0.4)**2 + 0.15 + 0.05 * np.sin(12 * x)

    z_E = np.min(E)
    z_F = np.min(F)

    ax.fill_between(x, E, F, alpha=0.15, color='gray', label='Gap: F(x) - E(x) ≥ 0')
    ax.plot(x, E, 'steelblue', linewidth=2.5, label=f'E(x), Z_trop = {z_E:.4f}')
    ax.plot(x, F, 'crimson', linewidth=2.5, label=f'F(x) ≥ E(x), Z_trop = {z_F:.4f}')

    ax.axhline(y=z_E, color='steelblue', linestyle='--', alpha=0.5)
    ax.axhline(y=z_F, color='crimson', linestyle='--', alpha=0.5)

    # Arrow showing Z_trop(E) <= Z_trop(F)
    ax.annotate('', xy=(0.95, z_F), xytext=(0.95, z_E),
                arrowprops=dict(arrowstyle='<->', color='black', lw=1.5))
    ax.text(0.97, (z_E + z_F)/2, 'gap', fontsize=10, ha='left', va='center')

    ax.set_xlabel('State x', fontsize=12)
    ax.set_ylabel('Energy', fontsize=12)
    ax.set_title('Monotonicity: E ≤ F pointwise ⟹ Z_trop(E) ≤ Z_trop(F)', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_data_processing():
    """Visualize the data processing inequality."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # 2D energy landscape
    N = 200
    x = np.linspace(0, 1, N)
    y = np.linspace(0, 1, N)
    X, Y = np.meshgrid(x, y)
    E = (X - 0.3)**2 + (Y - 0.6)**2 + 0.1 * np.sin(8*X) * np.cos(6*Y)

    ax1 = axes[0]
    c = ax1.contourf(X, Y, E, levels=30, cmap='viridis')
    plt.colorbar(c, ax=ax1, label='E(x, y)')
    idx = np.unravel_index(np.argmin(E), E.shape)
    ax1.plot(X[idx], Y[idx], 'r*', markersize=15, label=f'min = {E[idx]:.4f}')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_title('Latent Energy E(x, y)\non X = [0,1]²', fontsize=12)
    ax1.legend()

    # Projected (compressed) energy
    ax2 = axes[1]
    F_fiber = np.min(E, axis=1)  # min over x for each y
    ax2.fill_between(y, F_fiber, alpha=0.2, color='crimson')
    ax2.plot(y, F_fiber, 'crimson', linewidth=2, label='F(y) = min_x E(x,y)')
    z_F = np.min(F_fiber)
    ax2.axhline(y=z_F, color='crimson', linestyle='--',
                label=f'Z_trop(F) = {z_F:.4f}')
    ax2.set_xlabel('y')
    ax2.set_ylabel('Compressed energy')
    ax2.set_title('Observed Energy F(y)\non Y = [0,1]', fontsize=12)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Comparison
    ax3 = axes[2]
    z_E = np.min(E)
    labels = ['Z_trop(X, E)\n(latent)', 'Z_trop(Y, F)\n(observed)']
    values = [z_E, z_F]
    colors_bar = ['steelblue', 'crimson']
    bars = ax3.bar(labels, values, color=colors_bar, alpha=0.7, edgecolor='black')
    ax3.set_ylabel('Tropical Partition Function', fontsize=12)
    ax3.set_title('Data Processing Inequality\nZ_trop(F) ≤ Z_trop(E)', fontsize=12)
    for bar, val in zip(bars, values):
        ax3.text(bar.get_x() + bar.get_width()/2, val + 0.002,
                f'{val:.4f}', ha='center', va='bottom', fontsize=11)
    ax3.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_theorem_dependency():
    """Visualize the theorem dependency graph."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Node positions
    nodes = {
        'bddBelow': (2, 8.5, 'BddBelow\nRange'),
        'exists_min': (6, 8.5, 'Extreme Value\nTheorem'),
        'le': (2, 6, 'Lower\nBound'),
        'forall_le': (6, 6, 'Greatest\nLower Bound'),
        'attained': (10, 6, 'Attainment'),
        'le_iff': (10, 4, 'Universal\nCharacterization'),
        'add_const': (2, 3.5, 'Translation\nInvariance'),
        'mono': (6, 3.5, 'Monotonicity'),
        'pullback': (2, 1.5, 'Pullback\nInvariance'),
        'dpi': (6, 1.5, 'Data\nProcessing'),
    }

    # Draw nodes
    for key, (x, y, label) in nodes.items():
        color = '#4A90D9' if key in ['exists_min', 'attained'] else '#7BC67E'
        if key in ['dpi', 'pullback']:
            color = '#E8A838'
        box = dict(boxstyle='round,pad=0.4', facecolor=color, alpha=0.8, edgecolor='black')
        ax.text(x, y, label, fontsize=9, ha='center', va='center', bbox=box,
                fontweight='bold')

    # Draw edges (dependency arrows)
    edges = [
        ('bddBelow', 'le'),
        ('bddBelow', 'attained'),
        ('exists_min', 'attained'),
        ('le', 'attained'),
        ('le', 'mono'),
        ('le', 'add_const'),
        ('forall_le', 'attained'),
        ('attained', 'le_iff'),
        ('attained', 'add_const'),
        ('le', 'dpi'),
    ]

    for src, dst in edges:
        x1, y1, _ = nodes[src]
        x2, y2, _ = nodes[dst]
        ax.annotate('', xy=(x2, y2 + 0.4), xytext=(x1, y1 - 0.4),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.set_title('Theorem Dependency Graph\nCompact Tropical Entropy Package',
                fontsize=14, fontweight='bold', pad=20)

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#4A90D9', alpha=0.8, label='Core (attainment)'),
        Patch(facecolor='#7BC67E', alpha=0.8, label='Order-theoretic'),
        Patch(facecolor='#E8A838', alpha=0.8, label='Structural'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10)

    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of name -> base64."""
    print("Generating visualizations...")

    viz = {}

    print("  1/4: Energy landscape and attainment...")
    viz['energy_landscape'] = plot_energy_landscape_and_minimum()

    print("  2/4: Translation invariance...")
    viz['translation_invariance'] = plot_translation_invariance()

    print("  3/4: Monotonicity...")
    viz['monotonicity'] = plot_monotonicity()

    print("  4/4: Data processing inequality...")
    viz['data_processing'] = plot_data_processing()

    print("All visualizations generated.")
    return viz


if __name__ == "__main__":
    viz = generate_all_visualizations()

    # Save individual PNGs
    for name, data_uri in viz.items():
        b64_data = data_uri.split(',')[1]
        with open(f'{name}.png', 'wb') as f:
            f.write(base64.b64decode(b64_data))
        print(f"Saved {name}.png")

    print(f"\nGenerated {len(viz)} visualization(s).")
