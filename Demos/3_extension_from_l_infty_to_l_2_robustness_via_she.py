"""
Applications of L₂ Certified Robustness via Quadratic Forms

Demonstrates practical applications:
1. ReLU network certification on a synthetic classifier
2. Network architecture diagnostics via comparability analysis
3. Training-time metric smoothing objective
"""

import numpy as np
from typing import List, Tuple, Dict


def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation function."""
    return np.maximum(0, x)


class PiecewiseLinearClassifier:
    """A simple 2-layer ReLU network for demonstration.

    The network computes: f(x) = W2 @ relu(W1 @ x + b1) + b2
    On each activation region, this reduces to an affine map x ↦ A_i x + b_i
    where A_i = W2 @ D_i @ W1 for a diagonal matrix D_i encoding the
    active/inactive pattern of ReLU units.
    """

    def __init__(self, W1: np.ndarray, b1: np.ndarray,
                 W2: np.ndarray, b2: np.ndarray):
        self.W1 = W1
        self.b1 = b1
        self.W2 = W2
        self.b2 = b2
        self.input_dim = W1.shape[1]
        self.hidden_dim = W1.shape[0]
        self.output_dim = W2.shape[0]

    def forward(self, x: np.ndarray) -> np.ndarray:
        """Forward pass."""
        h = relu(self.W1 @ x + self.b1)
        return self.W2 @ h + self.b2

    def predict(self, x: np.ndarray) -> int:
        """Predict class (argmax of output)."""
        return int(np.argmax(self.forward(x)))

    def activation_pattern(self, x: np.ndarray) -> np.ndarray:
        """Get the binary activation pattern at x."""
        pre_activation = self.W1 @ x + self.b1
        return (pre_activation > 0).astype(float)

    def local_operator(self, x: np.ndarray) -> np.ndarray:
        """Get the local linear operator A_i at point x.

        A_i = W2 @ diag(activation_pattern) @ W1
        """
        pattern = self.activation_pattern(x)
        D = np.diag(pattern)
        return self.W2 @ D @ self.W1

    def local_bias(self, x: np.ndarray) -> np.ndarray:
        """Get the local bias b_i at point x."""
        pattern = self.activation_pattern(x)
        D = np.diag(pattern)
        return self.W2 @ D @ self.b1 + self.b2

    def score_gap(self, x: np.ndarray) -> float:
        """Compute the classification margin (gap between top two scores)."""
        scores = self.forward(x)
        sorted_scores = np.sort(scores)[::-1]
        if len(sorted_scores) < 2:
            return float('inf')
        return float(sorted_scores[0] - sorted_scores[1])

    def certified_radius(self, x: np.ndarray) -> float:
        """Compute the certified L₂ radius at point x.

        Uses the local operator norm and score gap margin.
        """
        margin = self.score_gap(x)
        if margin <= 0:
            return 0.0
        A = self.local_operator(x)
        norm_A = np.linalg.norm(A, ord=2)
        if norm_A < 1e-15:
            return float('inf')
        return margin / norm_A

    def verify_certificate(self, x: np.ndarray, n_samples: int = 10000) -> Dict:
        """Empirically verify the certified radius by random sampling.

        Returns statistics about the verification.
        """
        r = self.certified_radius(x)
        pred_x = self.predict(x)
        n_consistent = 0
        n_boundary = 0
        max_unsafe_norm = 0.0

        for _ in range(n_samples):
            # Sample uniformly from ball of radius 1.5*r
            v = np.random.randn(self.input_dim)
            v = v / np.linalg.norm(v) * np.random.uniform(0, 1.5 * min(r, 10.0))

            pred_xv = self.predict(x + v)
            if np.linalg.norm(v) < r:
                if pred_xv == pred_x:
                    n_consistent += 1
                else:
                    # This should never happen if the certificate is correct
                    max_unsafe_norm = max(max_unsafe_norm, np.linalg.norm(v))
            if pred_xv != pred_x:
                n_boundary += 1

        within_cert = sum(1 for _ in range(n_samples)
                        if np.random.uniform(0, 1.5 * min(r, 10.0)) < r)

        return {
            "certified_radius": r,
            "prediction": pred_x,
            "margin": self.score_gap(x),
            "operator_norm": np.linalg.norm(self.local_operator(x), ord=2),
            "n_boundary_violations": n_boundary,
            "certificate_valid": max_unsafe_norm == 0.0,
        }


def application_1_relu_certification():
    """Application 1: Certify a ReLU network on synthetic data."""
    print("=" * 60)
    print("Application 1: ReLU Network L₂ Certification")
    print("=" * 60)

    np.random.seed(42)
    input_dim = 4
    hidden_dim = 8
    output_dim = 3

    # Random network weights
    W1 = np.random.randn(hidden_dim, input_dim) * 0.5
    b1 = np.random.randn(hidden_dim) * 0.1
    W2 = np.random.randn(output_dim, hidden_dim) * 0.3
    b2 = np.random.randn(output_dim) * 0.1

    net = PiecewiseLinearClassifier(W1, b1, W2, b2)

    # Test points
    test_points = [np.random.randn(input_dim) for _ in range(5)]

    print(f"\nNetwork: {input_dim}→{hidden_dim}→{output_dim} ReLU")
    print("-" * 50)

    for idx, x in enumerate(test_points):
        r = net.certified_radius(x)
        margin = net.score_gap(x)
        A = net.local_operator(x)
        _, s, _ = np.linalg.svd(A)

        print(f"\nPoint {idx+1}: x = [{', '.join(f'{xi:.2f}' for xi in x)}]")
        print(f"  Prediction: class {net.predict(x)}")
        print(f"  Score gap (margin): {margin:.4f}")
        print(f"  Local operator norm: {np.linalg.norm(A, ord=2):.4f}")
        print(f"  Singular values: [{', '.join(f'{si:.3f}' for si in s)}]")
        print(f"  Condition number: {s[0]/max(s[-1], 1e-15):.2f}")
        print(f"  Certified L₂ radius: {r:.4f}")

        # Empirical verification
        result = net.verify_certificate(x, n_samples=5000)
        print(f"  Certificate valid (empirical): {result['certificate_valid']}")


def application_2_architecture_diagnostics():
    """Application 2: Diagnose network architecture via comparability."""
    print("\n" + "=" * 60)
    print("Application 2: Architecture Diagnostics via Comparability")
    print("=" * 60)

    np.random.seed(123)
    input_dim = 3
    hidden_dim = 6
    output_dim = 2

    W1 = np.random.randn(hidden_dim, input_dim) * 0.5
    b1 = np.random.randn(hidden_dim) * 0.1
    W2 = np.random.randn(output_dim, hidden_dim) * 0.3
    b2 = np.random.randn(output_dim) * 0.1

    net = PiecewiseLinearClassifier(W1, b1, W2, b2)

    # Sample many points and collect local operators
    n_points = 100
    points = [np.random.randn(input_dim) * 2 for _ in range(n_points)]

    # Group by activation pattern
    patterns = {}
    for x in points:
        pattern = tuple(net.activation_pattern(x))
        if pattern not in patterns:
            patterns[pattern] = {
                "operator": net.local_operator(x),
                "points": [],
                "radii": [],
            }
        patterns[pattern]["points"].append(x)
        patterns[pattern]["radii"].append(net.certified_radius(x))

    print(f"\nFound {len(patterns)} distinct activation regions from {n_points} samples")
    print("-" * 50)

    region_data = list(patterns.values())

    # Compute pairwise comparability
    max_c = 1.0
    n_regions = min(len(region_data), 10)  # limit for display

    print(f"\nComparability analysis (first {n_regions} regions):")
    for i in range(n_regions):
        Ai = region_data[i]["operator"]
        avg_radius = np.mean(region_data[i]["radii"])
        _, si, _ = np.linalg.svd(Ai)
        print(f"  Region {i}: ‖A‖={np.linalg.norm(Ai, ord=2):.3f}, "
              f"κ={si[0]/max(si[-1],1e-15):.1f}, "
              f"avg_radius={avg_radius:.4f}, "
              f"#points={len(region_data[i]['points'])}")

    print("\nPairwise comparability constants (sample):")
    for i in range(min(n_regions, 5)):
        for j in range(i+1, min(n_regions, 5)):
            Ai = region_data[i]["operator"]
            Aj = region_data[j]["operator"]
            AtA = Ai.T @ Ai
            BtB = Aj.T @ Aj + 1e-10 * np.eye(input_dim)
            try:
                evals = np.linalg.eigvalsh(
                    np.linalg.solve(BtB, AtA))
                c = max(1.0, float(np.max(evals)))
            except np.linalg.LinAlgError:
                c = float('inf')
            max_c = max(max_c, c)
            print(f"    c({i},{j}) = {c:.3f}")

    print(f"\n  Maximum comparability constant: {max_c:.3f}")
    print(f"  Geometric loss factor: √c = {np.sqrt(max_c):.3f}")


def application_3_metric_smoothing():
    """Application 3: Training objective for metric smoothing."""
    print("\n" + "=" * 60)
    print("Application 3: Metric Smoothing Training Objective")
    print("=" * 60)

    np.random.seed(456)
    input_dim = 3

    print("\nSimulating gradient descent to minimize comparability constant...")
    print("(Adjusting operator A2 to match A1's quadratic form)")

    # Fixed reference operator
    A1 = np.array([[2.0, 0.5, 0.1],
                    [0.3, 1.5, 0.2],
                    [0.1, 0.2, 1.0]])

    # Initial distorted operator
    A2 = np.array([[3.0, 1.0, 0.5],
                    [0.8, 0.5, 0.3],
                    [0.2, 0.4, 2.5]])

    lr = 0.01
    n_steps = 200
    history = []

    for step in range(n_steps):
        AtA1 = A1.T @ A1
        AtA2 = A2.T @ A2

        # Compute comparability constant
        try:
            reg = 1e-8 * np.eye(input_dim)
            evals = np.linalg.eigvalsh(
                np.linalg.solve(AtA2 + reg, AtA1))
            c12 = max(1.0, float(np.max(evals)))
            evals = np.linalg.eigvalsh(
                np.linalg.solve(AtA1 + reg, AtA2))
            c21 = max(1.0, float(np.max(evals)))
        except np.linalg.LinAlgError:
            c12 = c21 = float('inf')

        c_sym = max(c12, c21)
        history.append(c_sym)

        # Gradient: move A2's Gram matrix toward A1's
        grad = 2 * (AtA2 - AtA1) @ A2
        A2 = A2 - lr * grad

        if step % 50 == 0:
            print(f"  Step {step:3d}: c = {c_sym:.4f}, √c = {np.sqrt(c_sym):.4f}")

    print(f"  Step {n_steps}: c = {history[-1]:.4f}, √c = {np.sqrt(history[-1]):.4f}")

    print(f"\n  Initial comparability: c = {history[0]:.4f}")
    print(f"  Final comparability:   c = {history[-1]:.4f}")
    print(f"  Reduction factor:      {history[0]/history[-1]:.1f}x")


if __name__ == "__main__":
    print("L₂ Certified Robustness — Applications\n")

    application_1_relu_certification()
    application_2_architecture_diagnostics()
    application_3_metric_smoothing()

    print("\n" + "=" * 60)
    print("All applications completed.")
    print("=" * 60)


"""
Demo: L₂ Certified Robustness via Quadratic Forms

Demonstrates the main theorems with concrete numerical examples and
generates visualizations showing:
1. Local quadratic forms as ellipses on a 2D piecewise-linear classifier
2. Comparability constant sweep showing √c loss factor
3. Anisotropic vs. isotropic certification comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse, Circle
from matplotlib.collections import PatchCollection
import os

# ── Utility functions ──────────────────────────────────────────────────

def operator_norm(A: np.ndarray) -> float:
    return np.linalg.norm(A, ord=2)

def local_certified_radius(A: np.ndarray, margin: float) -> float:
    norm_A = operator_norm(A)
    if norm_A < 1e-15:
        return float('inf')
    return margin / norm_A

def find_comparability_constant(A: np.ndarray, B: np.ndarray) -> float:
    AtA = A.T @ A
    BtB = B.T @ B + 1e-10 * np.eye(B.shape[1])  # regularize
    try:
        eigenvalues = np.linalg.eigvalsh(np.linalg.solve(BtB, AtA))
        return max(1.0, float(np.max(eigenvalues)))
    except np.linalg.LinAlgError:
        return float('inf')

# ── Demo 1: 2D Piecewise-Linear Classifier ────────────────────────────

def demo_2d_classifier():
    """Visualize a 2D classifier with 4 activation regions.

    Each region has a different linear operator, defining different
    local quadratic forms (shown as ellipses) and different certified
    radii (shown as circles).
    """
    print("=" * 60)
    print("Demo 1: 2D Piecewise-Linear Classifier")
    print("=" * 60)

    # Define 4 regions as quadrants
    regions = [
        {"name": "Q1 (x>0, y>0)", "center": np.array([1.5, 1.5])},
        {"name": "Q2 (x<0, y>0)", "center": np.array([-1.5, 1.5])},
        {"name": "Q3 (x<0, y<0)", "center": np.array([-1.5, -1.5])},
        {"name": "Q4 (x>0, y<0)", "center": np.array([1.5, -1.5])},
    ]

    # Define operators (different sensitivity profiles)
    operators = [
        np.array([[3.0, 0.5], [0.2, 1.0]]),   # Stretches x more
        np.array([[1.0, 0.3], [0.1, 2.5]]),   # Stretches y more
        np.array([[2.0, 1.0], [0.5, 2.0]]),   # Mixed stretching
        np.array([[1.5, 0.0], [0.0, 1.5]]),   # Nearly isotropic
    ]

    margins = [2.0, 1.5, 1.8, 2.2]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: quadratic form ellipses
    ax1 = axes[0]
    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-4, 4)
    ax1.set_aspect('equal')
    ax1.axhline(0, color='gray', linewidth=0.5, linestyle='--')
    ax1.axvline(0, color='gray', linewidth=0.5, linestyle='--')
    ax1.set_title("Local Quadratic Forms (Ellipsoidal Certificates)", fontsize=12)
    ax1.set_xlabel("x₁")
    ax1.set_ylabel("x₂")

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    for idx, (region, A, m) in enumerate(zip(regions, operators, margins)):
        center = region["center"]

        # Compute ellipse from A^T A
        AtA = A.T @ A
        eigenvalues, eigenvectors = np.linalg.eigh(AtA)

        # Semi-axes of {v : ‖Av‖ < m} are m/sqrt(λ_i)
        semi_axes = m / np.sqrt(eigenvalues)
        angle = np.degrees(np.arctan2(eigenvectors[1, 0], eigenvectors[0, 0]))

        # Draw ellipsoidal certificate
        ellipse = Ellipse(
            center, 2*semi_axes[0], 2*semi_axes[1],
            angle=angle, fill=False, edgecolor=colors[idx],
            linewidth=2, linestyle='-', label=f"Region {idx+1}"
        )
        ax1.add_patch(ellipse)

        # Draw isotropic certificate (circle)
        r_iso = local_certified_radius(A, m)
        circle = Circle(
            center, r_iso, fill=False, edgecolor=colors[idx],
            linewidth=1.5, linestyle='--'
        )
        ax1.add_patch(circle)

        ax1.plot(*center, 'o', color=colors[idx], markersize=6)
        ax1.annotate(f"r={r_iso:.2f}", center + np.array([0.1, -0.3]),
                    fontsize=8, color=colors[idx])

    ax1.legend(loc='upper left', fontsize=9)

    # Right panel: certified radii comparison
    ax2 = axes[1]
    region_names = [f"R{i+1}" for i in range(4)]
    iso_radii = [local_certified_radius(A, m) for A, m in zip(operators, margins)]

    # Anisotropic "effective radii" (geometric mean of semi-axes)
    aniso_radii = []
    for A, m in zip(operators, margins):
        _, s, _ = np.linalg.svd(A)
        aniso_radii.append(np.prod(m / s) ** (1.0 / len(s)))

    x_pos = np.arange(len(region_names))
    width = 0.35
    bars1 = ax2.bar(x_pos - width/2, iso_radii, width, label='Isotropic (sphere)',
                    color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x_pos + width/2, aniso_radii, width, label='Anisotropic (ellipsoid)',
                    color='#e74c3c', alpha=0.8)

    ax2.set_xlabel("Region")
    ax2.set_ylabel("Effective Radius")
    ax2.set_title("Isotropic vs. Anisotropic Certified Radii", fontsize=12)
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(region_names)
    ax2.legend()

    global_iso = min(iso_radii)
    ax2.axhline(global_iso, color='navy', linewidth=1.5, linestyle=':',
                label=f'Global iso radius = {global_iso:.3f}')
    ax2.legend()

    plt.tight_layout()
    plt.savefig('visualization_1_quadratic_forms.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: visualization_1_quadratic_forms.png")

    # Print numerical results
    print("\nNumerical Results:")
    for i in range(4):
        _, s, _ = np.linalg.svd(operators[i])
        print(f"  Region {i+1}: ‖A‖={operator_norm(operators[i]):.3f}, "
              f"σ=[{s[0]:.2f}, {s[1]:.2f}], "
              f"margin={margins[i]:.1f}, "
              f"iso_radius={iso_radii[i]:.4f}")

    print(f"\n  Global isotropic radius: {global_iso:.4f}")

    # Comparability analysis
    print("\n  Comparability constants:")
    for i in range(4):
        for j in range(i+1, 4):
            c = find_comparability_constant(operators[i], operators[j])
            print(f"    c({i+1},{j+1}) = {c:.4f}")


# ── Demo 2: Comparability Constant Sweep ───────────────────────────────

def demo_comparability_sweep():
    """Show how the comparability constant c affects the global radius.

    Creates a family of operators parameterized by a "distortion" parameter
    and plots the global radius vs. the comparability constant.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Comparability Constant Sweep")
    print("=" * 60)

    np.random.seed(42)
    n = 5
    margin = 1.0

    # Base operator
    A_base = np.eye(n) * 2.0

    distortions = np.linspace(0, 3.0, 50)
    comparability_constants = []
    global_radii = []
    theoretical_loss = []

    for d in distortions:
        # Create distorted operator
        perturbation = np.random.randn(n, n) * 0.1
        A_distorted = A_base + d * perturbation

        c = find_comparability_constant(A_base, A_distorted)
        comparability_constants.append(c)

        # Global radius is margin / max(‖A_base‖, ‖A_distorted‖)
        r1 = local_certified_radius(A_base, margin)
        r2 = local_certified_radius(A_distorted, margin)
        global_radii.append(min(r1, r2))

        # Theoretical loss: r_base / sqrt(c)
        theoretical_loss.append(r1 / np.sqrt(c))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(distortions, comparability_constants, 'b-', linewidth=2, label='c(distortion)')
    ax1.set_xlabel("Distortion parameter δ", fontsize=12)
    ax1.set_ylabel("Comparability constant c", fontsize=12)
    ax1.set_title("Comparability Constant vs. Operator Distortion", fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.plot(comparability_constants, global_radii, 'ro-', markersize=3,
             linewidth=1.5, label='Actual global radius')
    ax2.plot(comparability_constants, theoretical_loss, 'b--', linewidth=1.5,
             label='r₀ / √c (theoretical bound)')
    ax2.set_xlabel("Comparability constant c", fontsize=12)
    ax2.set_ylabel("Certified radius", fontsize=12)
    ax2.set_title("Global Radius vs. Comparability Constant", fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('visualization_2_comparability_sweep.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: visualization_2_comparability_sweep.png")


# ── Demo 3: Volume Gain from Anisotropy ────────────────────────────────

def demo_volume_gain():
    """Compare volumes of anisotropic vs. isotropic perturbation sets.

    Shows that anisotropic certification can certify exponentially larger
    perturbation sets when the operator has high condition number.
    """
    print("\n" + "=" * 60)
    print("Demo 3: Anisotropic Volume Gain")
    print("=" * 60)

    dimensions = [2, 3, 5, 10, 20]
    condition_numbers = np.logspace(0, 2, 30)  # 1 to 100
    margin = 1.0

    fig, ax = plt.subplots(figsize=(10, 6))

    for n in dimensions:
        gains = []
        for kappa in condition_numbers:
            # Create operator with specified condition number
            sigmas = np.linspace(1, kappa, n)
            # Volume gain = product(σ_max / σ_i)
            gain = np.prod(sigmas[-1] / sigmas)
            gains.append(gain)
        ax.semilogy(condition_numbers, gains, linewidth=2, label=f'n={n}')

    ax.set_xlabel("Condition number κ(A)", fontsize=12)
    ax.set_ylabel("Volume gain (aniso/iso)", fontsize=12)
    ax.set_title("Volume Gain from Anisotropic Certification", fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    ax.set_xscale('log')

    plt.tight_layout()
    plt.savefig('visualization_3_volume_gain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: visualization_3_volume_gain.png")

    # Print numerical examples
    print("\nVolume gain examples (σ_max/σ_min = condition number):")
    for n in [2, 5, 10]:
        for kappa in [2, 10, 100]:
            sigmas = np.linspace(1, kappa, n)
            gain = np.prod(sigmas[-1] / sigmas)
            print(f"  n={n:2d}, κ={kappa:3d}: volume gain = {gain:.1f}x")


# ── Main ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("L₂ Certified Robustness via Quadratic Forms — Demonstrations\n")

    demo_2d_classifier()
    demo_comparability_sweep()
    demo_volume_gain()

    print("\n" + "=" * 60)
    print("All demos completed. Visualization files saved.")
    print("=" * 60)
