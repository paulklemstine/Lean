#!/usr/bin/env python3
"""
Applications of the EML Inverse-Limit Approximation Theorem

This script demonstrates practical applications where the inverse-limit
approximation theorem enables neural network approximation in settings
that go beyond standard Euclidean codomains.

Applications covered:
1. Multi-scale signal processing (solenoid model)
2. Fractal image compression (Cantor set model)
3. Profinite group actions (p-adic integers model)
4. Dynamical systems on strange attractors
"""

import numpy as np
import matplotlib.pyplot as plt
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


# ============================================================
# Application 1: Multi-Scale Signal Processing
# ============================================================

def application_multiscale_signals():
    """
    Multi-scale signal processing via inverse-limit approximation.

    A signal at multiple resolutions forms a compatible family in an
    inverse system. The theorem guarantees that EML networks can
    approximate the full multi-scale representation.

    Practical use case: audio processing where different frequency
    bands are processed at different resolutions (like a wavelet
    decomposition viewed as an inverse limit).
    """
    np.random.seed(42)
    t = np.linspace(0, 1, 2048)

    # Original signal: sum of different frequency components
    signal = (np.sin(2 * np.pi * 3 * t) +
              0.5 * np.sin(2 * np.pi * 7 * t) +
              0.3 * np.sin(2 * np.pi * 15 * t) +
              0.15 * np.sin(2 * np.pi * 31 * t) +
              0.08 * np.sin(2 * np.pi * 63 * t))

    # Multi-scale decomposition (inverse system stages)
    def low_pass(sig, cutoff):
        """Low-pass filter: bonding map in the inverse system."""
        from numpy.fft import rfft, irfft
        Y = rfft(sig)
        Y[cutoff:] = 0
        return irfft(Y, n=len(sig))

    stages = [4, 8, 16, 32, 64]
    n_stages = len(stages)

    fig, axes = plt.subplots(n_stages + 1, 1, figsize=(14, 12), sharex=True)
    fig.suptitle(
        'Application 1: Multi-Scale Signal Processing via Inverse Limits',
        fontsize=14, fontweight='bold'
    )

    # Plot original signal
    axes[0].plot(t, signal, 'k-', linewidth=0.8)
    axes[0].set_title('Original signal (inverse limit)', fontsize=11)
    axes[0].set_ylabel('Amplitude')

    # Plot each stage
    for i, cutoff in enumerate(stages):
        filtered = low_pass(signal, cutoff)
        axes[i + 1].plot(t, filtered, color=plt.cm.viridis(i / n_stages),
                         linewidth=1)
        axes[i + 1].set_title(f'Stage {i}: Low-pass filter (cutoff={cutoff})',
                              fontsize=11)
        axes[i + 1].set_ylabel('Amplitude')

    axes[-1].set_xlabel('Time', fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'app_multiscale_signals.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 1: Multi-scale signal processing demo saved.")

    # Compute approximation errors at each stage
    print("  Approximation quality at each stage:")
    for i, cutoff in enumerate(stages):
        filtered = low_pass(signal, cutoff)
        error = np.max(np.abs(signal - filtered))
        print(f"    Stage {i} (cutoff={cutoff}): max error = {error:.4f}")


# ============================================================
# Application 2: Fractal Approximation
# ============================================================

def sierpinski_ifs(n_points=50000, n_iter=20):
    """Generate points of the Sierpinski triangle via IFS."""
    vertices = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3) / 2]])
    point = np.array([0.0, 0.0])
    points = []
    for _ in range(n_iter):
        point = point  # warmup
    for _ in range(n_points):
        vertex = vertices[np.random.randint(3)]
        point = (point + vertex) / 2
        points.append(point.copy())
    return np.array(points)


def application_fractal_approximation():
    """
    Fractal codomains via inverse limits.

    The Sierpinski triangle can be viewed as an inverse limit:
    at each stage, we subdivide into finer triangulations.
    The theorem guarantees that maps into the Sierpinski triangle
    (e.g., a parametric curve on the fractal) can be approximated.

    Practical use case: generative models that produce fractal patterns,
    texture synthesis for natural phenomena (coastlines, clouds, etc.).
    """
    # Generate Sierpinski triangle
    points = sierpinski_ifs()

    # Approximation at different scales
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    fig.suptitle(
        'Application 2: Fractal Codomain Approximation via Inverse Limits',
        fontsize=14, fontweight='bold'
    )

    n_stages = 6
    for i in range(n_stages):
        ax = axes[i // 3, i % 3]

        # At stage i, discretize to a grid of 2^i cells per side
        grid_size = 2 ** (i + 1)
        grid_x = np.floor(points[:, 0] * grid_size) / grid_size
        grid_y = np.floor(points[:, 1] * grid_size) / grid_size

        ax.scatter(grid_x, grid_y, s=0.1,
                   color=plt.cm.plasma(i / n_stages), alpha=0.3)
        ax.set_xlim(-0.1, 1.1)
        ax.set_ylim(-0.1, 1.0)
        ax.set_aspect('equal')
        ax.set_title(f'Stage {i}: {grid_size}×{grid_size} grid', fontsize=11)
        ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'app_fractal_approx.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 2: Fractal approximation demo saved.")


# ============================================================
# Application 3: p-adic Integer Approximation
# ============================================================

def application_padic():
    """
    Approximation on p-adic integers.

    The ring of p-adic integers Z_p is the inverse limit:
      ... → Z/p^3 → Z/p^2 → Z/p
    with the reduction bonding maps.

    A continuous function f: X → Z_p is determined by compatible
    functions f_n: X → Z/p^n. The theorem guarantees EML approximation.

    Practical use case: error-correcting codes, cryptographic protocols
    that operate on p-adic data structures.
    """
    p = 3  # Use 3-adic integers
    n_stages = 6

    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    fig.suptitle(
        f'Application 3: Approximation on {p}-adic Integers (Inverse Limit of Z/{p}^n)',
        fontsize=14, fontweight='bold'
    )

    x = np.linspace(0, 1, 500)

    for i in range(n_stages):
        ax = axes[i // 3, i % 3]
        mod = p ** (i + 1)

        # A "function into Z/mod" is a step function with mod levels
        # We show the projection of a continuous function
        y_continuous = np.sin(2 * np.pi * x) * (mod / 2) + mod / 2
        y_discrete = np.floor(y_continuous) % mod

        ax.step(x, y_discrete, where='mid',
                color=plt.cm.viridis(i / n_stages), linewidth=1.5)
        ax.plot(x, y_continuous, 'k--', alpha=0.3, linewidth=0.8)
        ax.set_title(f'Stage {i}: Z/{mod}Z', fontsize=11)
        ax.set_ylabel('Value', fontsize=10)
        ax.set_ylim(-0.5, mod + 0.5)

    for ax in axes.flat:
        ax.set_xlabel('x', fontsize=10)
        ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'app_padic.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Application 3: {p}-adic integer approximation demo saved.")


# ============================================================
# Application 4: Dynamical Systems
# ============================================================

def henon_map(x, y, a=1.4, b=0.3):
    """One iteration of the Hénon map."""
    return 1 - a * x**2 + y, b * x


def application_dynamical_systems():
    """
    Approximation on strange attractors viewed as inverse limits.

    Many strange attractors can be expressed as inverse limits of
    branched manifolds (the Williams conjecture / theorem for
    hyperbolic attractors). This means our inverse-limit approximation
    theorem applies to maps into strange attractors.

    Practical use case: data-driven modeling of chaotic systems,
    where the attractor is learned as an inverse limit and predictions
    are made via EML approximation at each stage.
    """
    # Generate Hénon attractor
    n_points = 50000
    x, y = 0.1, 0.1
    xs, ys = [], []
    for _ in range(1000):  # transient
        x, y = henon_map(x, y)
    for _ in range(n_points):
        x, y = henon_map(x, y)
        xs.append(x)
        ys.append(y)
    xs, ys = np.array(xs), np.array(ys)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle(
        'Application 4: Strange Attractors as Inverse Limits',
        fontsize=14, fontweight='bold'
    )

    # Full attractor
    axes[0].scatter(xs, ys, s=0.1, c='darkblue', alpha=0.1)
    axes[0].set_title('Hénon Attractor (Inverse Limit)', fontsize=12)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('y')
    axes[0].set_aspect('equal')

    # Stage approximation: discretize
    for idx, grid_res in enumerate([10, 50]):
        ax = axes[idx + 1]
        gx = np.round(xs * grid_res) / grid_res
        gy = np.round(ys * grid_res) / grid_res
        ax.scatter(gx, gy, s=0.5,
                   c=plt.cm.plasma(0.3 + 0.3 * idx), alpha=0.2)
        ax.set_title(f'Stage Approximation (res={grid_res})', fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_aspect('equal')

    for ax in axes:
        ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'app_dynamical.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Application 4: Dynamical systems demo saved.")


# ============================================================
# Summary: Convergence Across Applications
# ============================================================

def summary_convergence():
    """
    Summary visualization: how the inverse-limit approximation
    error decreases across different applications.
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    N_stages = np.arange(1, 15)

    # Model convergence rates for different applications
    apps = {
        'Multi-scale signals': lambda N: 0.5 * np.exp(-0.3 * N),
        'Fractal codomains': lambda N: 1.0 / (2 ** N),
        'p-adic integers': lambda N: 1.0 / (3 ** N),
        'Strange attractors': lambda N: 0.8 * np.exp(-0.15 * N),
    }

    colors = plt.cm.tab10(np.linspace(0, 0.4, len(apps)))
    for (name, fn), color in zip(apps.items(), colors):
        errors = [fn(N) for N in N_stages]
        ax.semilogy(N_stages, errors, 'o-', color=color, linewidth=2,
                     markersize=5, label=name)

    ax.set_xlabel('Number of inverse-limit stages N', fontsize=12)
    ax.set_ylabel('Approximation error', fontsize=12)
    ax.set_title(
        'Convergence of Inverse-Limit Approximation Across Applications',
        fontsize=13, fontweight='bold'
    )
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'summary_convergence.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Summary convergence visualization saved.")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("Applications of EML Inverse-Limit Approximation")
    print("=" * 60)
    print()

    application_multiscale_signals()
    print()
    application_fractal_approximation()
    print()
    application_padic()
    print()
    application_dynamical_systems()
    print()
    summary_convergence()

    print()
    print("=" * 60)
    print("All application demos completed.")
    print("=" * 60)
    print()
    print("Summary of applications:")
    print("1. MULTI-SCALE SIGNALS: Process audio/images at multiple")
    print("   resolutions simultaneously, with guaranteed approximation")
    print("   across all scales.")
    print()
    print("2. FRACTAL CODOMAINS: Generate or approximate patterns on")
    print("   fractal sets (coastlines, clouds, biological structures)")
    print("   using neural networks.")
    print()
    print("3. P-ADIC INTEGERS: Approximate functions valued in p-adic")
    print("   number systems, relevant for cryptography and coding theory.")
    print()
    print("4. STRANGE ATTRACTORS: Model chaotic dynamical systems whose")
    print("   attractors are inverse limits of branched manifolds.")


#!/usr/bin/env python3
"""
Demonstration: EML Approximation Through Inverse Limits

This script illustrates the core ideas of the EML Stone-Weierstrass theorem
for inverse-limit codomains through concrete numerical examples and
visualizations.

The key mathematical insight: a compact Hausdorff space Y realized as an
inverse limit of compact metrizable ANR stages (Y_n, p_n) can be approximated
by working at finite stages. Specifically:
1. Finitely many coordinate projections control the inverse-limit metric.
2. EML approximation at each finite stage can be assembled into a global
   approximation in the inverse limit.

We demonstrate this with:
- The Cantor set as an inverse limit of finite discrete spaces.
- Solenoids as inverse limits of circles.
- A general sequential approximation algorithm.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from typing import Callable, List, Tuple
import os

# ============================================================
# Example 1: Cantor Set as Inverse Limit
# ============================================================

def cantor_ternary(n_stages: int = 6) -> List[np.ndarray]:
    """
    Demonstrate the Cantor set as an inverse limit of finite sets {0,1}^n.

    The Cantor set C ⊂ [0,1] is the inverse limit of the system:
      Y_n = {0,1,...,2^n - 1}  with  p_n(k) = k // 2
    Each point in C is encoded by an infinite sequence of 0s and 2s
    in base 3 (equivalently, 0s and 1s indexing left/right in each stage).
    """
    stages = []
    for n in range(n_stages):
        # At stage n, we have 2^n intervals
        num_intervals = 2 ** n
        # Centers of the intervals at stage n of the Cantor construction
        if n == 0:
            centers = np.array([0.5])
        else:
            prev = stages[-1]
            width = 1.0 / (3 ** n)
            new_centers = []
            for c in prev:
                new_centers.append(c - width)
                new_centers.append(c + width)
            centers = np.array(sorted(new_centers))
        stages.append(centers)
    return stages


def plot_cantor_inverse_limit():
    """Visualize the Cantor set construction as an inverse limit."""
    n_stages = 7
    stages = cantor_ternary(n_stages)

    fig, axes = plt.subplots(n_stages, 1, figsize=(12, 8), sharex=True)
    fig.suptitle(
        'Cantor Set as Inverse Limit of Finite Stages',
        fontsize=14, fontweight='bold'
    )

    for n in range(n_stages):
        ax = axes[n]
        width = 1.0 / (3 ** n) * 0.8
        for c in stages[n]:
            ax.barh(0, width, left=c - width / 2, height=0.5,
                    color=plt.cm.viridis(n / n_stages), edgecolor='black',
                    linewidth=0.5)
        ax.set_xlim(-0.05, 1.05)
        ax.set_ylim(-0.3, 0.8)
        ax.set_ylabel(f'Stage {n}', fontsize=10)
        ax.set_yticks([])
        if n < n_stages - 1:
            ax.set_xticks([])

    axes[-1].set_xlabel('Position in [0, 1]', fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'cantor_inverse_limit.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Cantor set inverse limit visualization saved.")


# ============================================================
# Example 2: Finite-Coordinate Metric Control
# ============================================================

def demonstrate_metric_control():
    """
    Demonstrate the finite-coordinate metric control lemma.

    For the inverse limit L with projections π_n, we show that for any ε > 0,
    there exists N such that if all projections up to N are ε/2-close,
    then the points in L are ε-close.

    We use a product metric: d(x, y) = Σ_n 2^{-n} d_n(π_n(x), π_n(y))
    """
    np.random.seed(42)

    # Simulate an inverse limit as a weighted product
    max_stages = 20
    n_points = 100

    # Generate random "inverse limit" points
    # Each point is an infinite sequence, truncated at max_stages
    points = np.random.rand(n_points, max_stages)

    # Product metric: d(x,y) = Σ_n 2^{-n} |x_n - y_n|
    weights = np.array([2.0 ** (-n) for n in range(max_stages)])

    def full_dist(x, y):
        return np.sum(weights * np.abs(x - y))

    def truncated_dist(x, y, N):
        return np.sum(weights[:N + 1] * np.abs(x[:N + 1] - y[:N + 1]))

    # For various epsilon values, find the controlling N
    epsilons = [0.5, 0.2, 0.1, 0.05, 0.02]
    controlling_N = []

    for eps in epsilons:
        # Find smallest N such that tail sum < eps/2
        # Tail sum = Σ_{n>N} 2^{-n} ≤ 2^{-N}
        N = int(np.ceil(-np.log2(eps / 2)))
        controlling_N.append(N)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Controlling N vs epsilon
    ax1.semilogy(controlling_N, epsilons, 'bo-', markersize=8, linewidth=2)
    ax1.set_xlabel('Controlling stage N', fontsize=12)
    ax1.set_ylabel('Error tolerance ε', fontsize=12)
    ax1.set_title('Finite-Coordinate Metric Control', fontsize=13)
    ax1.grid(True, alpha=0.3)
    for i, (n, e) in enumerate(zip(controlling_N, epsilons)):
        ax1.annotate(f'N={n}, ε={e}', (n, e),
                     textcoords="offset points", xytext=(10, 5), fontsize=9)

    # Plot 2: Approximation error vs number of stages used
    pair_idx = (0, 1)
    x, y = points[pair_idx[0]], points[pair_idx[1]]
    true_dist = full_dist(x, y)

    Ns = range(max_stages)
    approx_dists = [truncated_dist(x, y, N) for N in Ns]
    errors = [true_dist - d for d in approx_dists]

    ax2.semilogy(list(Ns), [max(e, 1e-16) for e in errors], 'r-', linewidth=2,
                 label='|d(x,y) - d_N(x,y)|')
    ax2.axhline(y=true_dist, color='blue', linestyle='--', alpha=0.5,
                label=f'd(x,y) = {true_dist:.4f}')
    ax2.set_xlabel('Number of coordinate stages N', fontsize=12)
    ax2.set_ylabel('Approximation error', fontsize=12)
    ax2.set_title('Metric Convergence with Stages', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'metric_control.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Metric control demonstration saved.")


# ============================================================
# Example 3: EML Approximation at Each Stage
# ============================================================

def sigmoid(x: np.ndarray) -> np.ndarray:
    """Logistic sigmoid function."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -500, 500)))


def eml_single_neuron(x: np.ndarray, w: float, b: float) -> np.ndarray:
    """Single EML neuron: σ(wx + b)."""
    return sigmoid(w * x + b)


def eml_approximation(x: np.ndarray, target_fn: Callable,
                       n_neurons: int = 20) -> np.ndarray:
    """
    Approximate a target function using a sum of EML neurons.
    Uses random features as a simple demonstration.
    """
    np.random.seed(123)
    weights = np.random.randn(n_neurons) * 3
    biases = np.random.randn(n_neurons) * 2

    # Build feature matrix
    features = np.column_stack([
        eml_single_neuron(x, w, b) for w, b in zip(weights, biases)
    ])

    # Fit coefficients by least squares
    target = target_fn(x)
    coeffs, _, _, _ = np.linalg.lstsq(features, target, rcond=None)

    return features @ coeffs


def demonstrate_stagewise_approximation():
    """
    Demonstrate EML approximation at each stage of an inverse system.

    We use a simple inverse system where Y_n = ℝ and the bonding map
    p_n is a projection/averaging operation. The map f: [0,1] → L is
    approximated stage by stage.
    """
    x = np.linspace(0, 1, 500)

    # Define target functions at different stages
    # Stage 0: smooth low-frequency function
    # Stage 1: adds medium-frequency detail
    # Stage 2: adds high-frequency detail
    def stage0(t):
        return np.sin(2 * np.pi * t)

    def stage1(t):
        return np.sin(2 * np.pi * t) + 0.3 * np.sin(6 * np.pi * t)

    def stage2(t):
        return (np.sin(2 * np.pi * t) + 0.3 * np.sin(6 * np.pi * t)
                + 0.1 * np.sin(14 * np.pi * t))

    stages = [stage0, stage1, stage2]
    stage_names = ['Stage 0 (Low freq)', 'Stage 1 (+ Med freq)',
                   'Stage 2 (+ High freq)']
    n_neurons_per_stage = [5, 10, 20]

    fig, axes = plt.subplots(3, 1, figsize=(12, 10), sharex=True)
    fig.suptitle(
        'EML Approximation at Each Inverse System Stage',
        fontsize=14, fontweight='bold'
    )

    errors = []
    for i, (fn, name, n_neurons) in enumerate(
            zip(stages, stage_names, n_neurons_per_stage)):
        ax = axes[i]
        target = fn(x)
        approx = eml_approximation(x, fn, n_neurons=n_neurons)
        err = np.max(np.abs(target - approx))
        errors.append(err)

        ax.plot(x, target, 'b-', linewidth=2, label='Target', alpha=0.8)
        ax.plot(x, approx, 'r--', linewidth=2,
                label=f'EML ({n_neurons} neurons)', alpha=0.8)
        ax.fill_between(x, target - err, target + err,
                         alpha=0.1, color='gray', label=f'Error band (ε={err:.4f})')
        ax.set_ylabel('Value', fontsize=11)
        ax.set_title(f'{name} — Sup error: {err:.4f}', fontsize=12)
        ax.legend(loc='upper right', fontsize=9)
        ax.grid(True, alpha=0.3)

    axes[-1].set_xlabel('x ∈ [0, 1]', fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'stagewise_approximation.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Stagewise approximation demonstration saved.")
    print(f"  Stage errors: {[f'{e:.4f}' for e in errors]}")


# ============================================================
# Example 4: Compatible Assembly
# ============================================================

def demonstrate_compatible_assembly():
    """
    Demonstrate the assembly of compatible stage approximations
    into a global approximation in the inverse limit.

    Key insight: approximations must be COMPATIBLE across stages,
    meaning p_n(g_{n+1}(x)) = g_n(x) for all n.

    We show the effect of:
    (a) Independent approximation (not compatible — loses coherence)
    (b) Compatible approximation (respects bonding maps — good global approx)
    """
    x = np.linspace(0, 1, 500)

    # Bonding map: projection that averages out high-frequency components
    def bonding_map(y_fine, cutoff_freq):
        """Project by removing frequencies above cutoff."""
        from numpy.fft import rfft, irfft
        Y = rfft(y_fine)
        Y[cutoff_freq:] = 0
        return irfft(Y, n=len(y_fine))

    # Target: multi-scale function
    def target(t):
        return (np.sin(2 * np.pi * t) + 0.4 * np.cos(4 * np.pi * t)
                + 0.2 * np.sin(10 * np.pi * t) + 0.1 * np.cos(20 * np.pi * t))

    y_target = target(x)

    # Stage approximations with different fidelities
    n_stages = 4
    cutoffs = [3, 6, 12, 25]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(
        'Assembly of Compatible Stage Approximations',
        fontsize=14, fontweight='bold'
    )

    # Panel 1: Target function
    ax = axes[0, 0]
    ax.plot(x, y_target, 'k-', linewidth=2, label='Target f')
    ax.set_title('Target Function f : X → L', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Stage projections π_n ∘ f
    ax = axes[0, 1]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_stages))
    for i, (cutoff, color) in enumerate(zip(cutoffs, colors)):
        projection = bonding_map(y_target, cutoff)
        ax.plot(x, projection, color=color, linewidth=1.5,
                label=f'π_{i} ∘ f (cutoff={cutoff})')
    ax.set_title('Stage Projections π_n ∘ f', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Independent approximation (non-compatible)
    ax = axes[1, 0]
    independent_errors = []
    for i, (cutoff, color) in enumerate(zip(cutoffs, colors)):
        projection = bonding_map(y_target, cutoff)
        # Add random noise to simulate independent approximation
        noise = 0.05 * np.random.randn(len(x))
        approx = projection + noise
        err = np.max(np.abs(projection - approx))
        independent_errors.append(err)
        if i == n_stages - 1:
            ax.plot(x, approx, color=color, linewidth=1.5, alpha=0.7,
                    label=f'Independent approx (max stage)')
    ax.plot(x, y_target, 'k--', linewidth=1, alpha=0.5, label='Target')
    ax.set_title('Independent Approximation (Non-compatible)', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 4: Compatible assembly
    ax = axes[1, 1]
    # Compatible approximation: approximate at highest stage,
    # then derive lower stages via bonding maps
    highest_approx = eml_approximation(x, target, n_neurons=30)
    compatible_stages = [bonding_map(highest_approx, c) for c in cutoffs]

    for i, (stage_approx, color) in enumerate(zip(compatible_stages, colors)):
        if i == n_stages - 1:
            ax.plot(x, stage_approx, color=color, linewidth=1.5, alpha=0.7,
                    label=f'Compatible approx (stage {i})')
    ax.plot(x, y_target, 'k--', linewidth=1, alpha=0.5, label='Target')
    global_err = np.max(np.abs(y_target - highest_approx))
    ax.set_title(f'Compatible Assembly (sup error: {global_err:.4f})', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    for ax in axes.flat:
        ax.set_xlabel('x', fontsize=10)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'compatible_assembly.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Compatible assembly demonstration saved.")
    print(f"  Global approximation error: {global_err:.4f}")


# ============================================================
# Example 5: Convergence Rate Visualization
# ============================================================

def demonstrate_convergence():
    """
    Show how the approximation error decreases as we use more stages.

    For the inverse-limit approximation theorem, the key parameters are:
    - N: number of controlling stages (from metric control lemma)
    - δ: approximation error at each stage (from stage-level density)
    - ε: final error in the inverse limit (ε depends on N and δ)
    """
    # Simulate convergence for different numbers of stages
    N_values = range(1, 20)

    # Model: ε ≈ 2^{-N} + δ (tail sum + stage error)
    stage_errors = [0.1, 0.05, 0.01]

    fig, ax = plt.subplots(figsize=(10, 6))

    for delta in stage_errors:
        total_errors = [2.0 ** (-N) + delta for N in N_values]
        ax.semilogy(list(N_values), total_errors, 'o-', linewidth=2,
                     markersize=5, label=f'δ = {delta} (stage error)')

    # Show the metric control contribution alone
    tail_sums = [2.0 ** (-N) for N in N_values]
    ax.semilogy(list(N_values), tail_sums, 'k--', linewidth=2,
                 alpha=0.5, label='Tail sum 2^{-N} (metric control)')

    ax.set_xlabel('Number of controlling stages N', fontsize=12)
    ax.set_ylabel('Total approximation error ε', fontsize=12)
    ax.set_title(
        'Inverse-Limit Approximation: Error vs. Number of Stages',
        fontsize=13, fontweight='bold'
    )
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'convergence_rate.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Convergence rate visualization saved.")


# ============================================================
# Example 6: Solenoid Approximation
# ============================================================

def demonstrate_solenoid():
    """
    Demonstrate approximation in a solenoid.

    The 2-adic solenoid is the inverse limit of circles:
      ... → S¹ →[×2] S¹ →[×2] S¹
    where the bonding map is z ↦ z².

    A continuous function f : [0,1] → Solenoid is determined by a
    compatible sequence of maps f_n : [0,1] → S¹ with p_n(f_{n+1}) = f_n.
    """
    t = np.linspace(0, 1, 1000)

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    fig.suptitle(
        'Solenoid as Inverse Limit of Circles',
        fontsize=14, fontweight='bold'
    )

    n_stages = 6
    for i in range(n_stages):
        ax = axes[i // 3, i % 3]
        # At stage i, we have 2^i wrappings
        freq = 2 ** i
        theta = 2 * np.pi * freq * t
        x_circle = np.cos(theta)
        y_circle = np.sin(theta)

        # Plot the image on the circle
        ax.plot(x_circle, y_circle, linewidth=max(0.5, 2 - 0.3 * i),
                color=plt.cm.plasma(i / n_stages))
        ax.set_xlim(-1.3, 1.3)
        ax.set_ylim(-1.3, 1.3)
        ax.set_aspect('equal')
        ax.set_title(f'Stage {i}: {freq}× winding', fontsize=11)
        ax.grid(True, alpha=0.2)

        # Draw unit circle
        circle = Circle((0, 0), 1, fill=False, color='gray',
                         linestyle='--', linewidth=0.5)
        ax.add_patch(circle)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'solenoid_stages.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Solenoid demonstration saved.")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("EML Inverse-Limit Approximation Demonstrations")
    print("=" * 60)
    print()

    plot_cantor_inverse_limit()
    demonstrate_metric_control()
    demonstrate_stagewise_approximation()
    demonstrate_compatible_assembly()
    demonstrate_convergence()
    demonstrate_solenoid()

    print()
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
    print()
    print("Key takeaways:")
    print("1. Inverse limits of compact metrizable spaces are controlled")
    print("   by finitely many coordinate projections.")
    print("2. EML approximation at each stage can be assembled into")
    print("   a global approximation in the inverse limit.")
    print("3. Compatibility across stages is essential — independent")
    print("   approximation loses coherence.")
    print("4. The error in the inverse limit is controlled by both")
    print("   the number of stages N and the stage-level error δ.")
