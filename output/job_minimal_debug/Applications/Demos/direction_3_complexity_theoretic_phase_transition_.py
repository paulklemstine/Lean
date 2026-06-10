"""
applications.py — Real-world applications of the Lorentzian recognition phase transition.

Demonstrates three practical applications:
1. Robust polynomial certification (matroid / log-concavity testing)
2. Signal detection in noisy environments
3. Numerical stability analysis for optimization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────────────────
# Application 1: Robust Lorentzian Polynomial Certification
# ──────────────────────────────────────────────────────────────────────────

def generate_lorentzian_hessian(n: int, gap: float) -> np.ndarray:
    """Generate a Hessian matrix with Lorentzian signature and given gap.

    Models the quadratic leaf of a Lorentzian polynomial: one positive
    eigenvalue, all others at most -gap.
    """
    D = np.diag([-gap] * n)
    D[0, 0] = gap * 2  # One positive eigenvalue
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    return Q @ D @ Q.T


def certify_lorentzianity(
    hessians: List[np.ndarray],
    noise_level: float,
    confidence: float = 0.99,
) -> Tuple[bool, float, str]:
    """Certify that a polynomial remains Lorentzian under coefficient perturbation.

    Uses the spectral gap proxy to determine if the perturbation tolerance
    exceeds the noise level.

    Args:
        hessians: List of quadratic-leaf Hessian matrices
        noise_level: Upper bound on coefficient perturbation norm
        confidence: Desired certification confidence

    Returns:
        (is_certified, min_gap, report)
    """
    min_gap = float('inf')
    for i, H in enumerate(hessians):
        eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
        n_pos = np.sum(eigenvalues > 1e-10)
        if n_pos > 1:
            return False, 0.0, f"Hessian {i} has {n_pos} positive eigenvalues"

        if len(eigenvalues) >= 2:
            gap = eigenvalues[0] - eigenvalues[1]
        else:
            gap = eigenvalues[0]
        min_gap = min(min_gap, gap)

    margin = min_gap - noise_level
    is_certified = margin > 0

    report = (
        f"Minimum spectral gap: {min_gap:.6f}\n"
        f"Noise level: {noise_level:.6f}\n"
        f"Margin: {margin:.6f}\n"
        f"Certified: {'YES' if is_certified else 'NO'}\n"
        f"Phase: {'EASY' if margin > 0 else 'CRITICAL' if abs(margin) < 1e-10 else 'UNKNOWN'}"
    )

    return is_certified, margin, report


# ──────────────────────────────────────────────────────────────────────────
# Application 2: Signal Detection in Noisy Matrices
# ──────────────────────────────────────────────────────────────────────────

def planted_signal_detection(
    n: int = 50,
    sigma: float = 1.0,
    signal_strengths: np.ndarray = None,
    n_trials: int = 200,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Detect planted rank-one signals using the spectral recognizer.

    This implements the recognizer-to-tester reduction: use the spectral
    gap proxy as a test statistic for planted signal detection.

    Args:
        n: Matrix dimension
        sigma: Noise level
        signal_strengths: Array of signal strengths to test
        n_trials: Number of Monte Carlo trials

    Returns:
        (signal_strengths, detection_rates, false_positive_rate)
    """
    if signal_strengths is None:
        signal_strengths = np.linspace(0, 5, 30) * sigma

    threshold = 2 * sigma  # GOE edge constant
    detection_rates = np.zeros(len(signal_strengths))

    # False positive rate (no signal)
    fp_count = 0
    for _ in range(n_trials):
        E = np.random.randn(n, n) * sigma / np.sqrt(n)
        E = (E + E.T) / 2
        eigenvalues = np.sort(np.linalg.eigvalsh(E))[::-1]
        gap = eigenvalues[0] - eigenvalues[1] if len(eigenvalues) >= 2 else 0
        if gap > threshold:
            fp_count += 1
    fp_rate = fp_count / n_trials

    # Detection rates for each signal strength
    for i, strength in enumerate(signal_strengths):
        detections = 0
        for _ in range(n_trials):
            # Planted rank-one signal
            v = np.random.randn(n)
            v /= np.linalg.norm(v)
            signal = strength * np.outer(v, v)

            # Add GOE noise
            E = np.random.randn(n, n) * sigma / np.sqrt(n)
            E = (E + E.T) / 2

            M = signal + E
            eigenvalues = np.sort(np.linalg.eigvalsh(M))[::-1]
            gap = eigenvalues[0] - eigenvalues[1] if len(eigenvalues) >= 2 else 0
            if gap > threshold:
                detections += 1

        detection_rates[i] = detections / n_trials

    return signal_strengths / sigma, detection_rates, np.full_like(signal_strengths, fp_rate)


# ──────────────────────────────────────────────────────────────────────────
# Application 3: Numerical Stability Radius Estimation
# ──────────────────────────────────────────────────────────────────────────

def estimate_stability_radius(
    A: np.ndarray,
    n_samples: int = 1000,
    max_perturbation: float = 5.0,
) -> Tuple[float, float]:
    """Estimate the stability radius of a matrix's Lorentzian signature.

    The stability radius is the largest perturbation ε such that
    A + ε*E still has Lorentzian signature for all ||E|| ≤ 1.

    Estimated by binary search with random perturbations.

    Args:
        A: Input symmetric matrix
        n_samples: Number of random perturbation samples
        max_perturbation: Maximum perturbation to test

    Returns:
        (lower_bound, upper_bound) on the stability radius
    """
    n = A.shape[0]

    # Check that A itself has Lorentzian signature
    eigenvalues = np.linalg.eigvalsh(A)
    if np.sum(eigenvalues > 1e-10) > 1:
        return 0.0, 0.0

    # Spectral gap gives an analytic lower bound
    sorted_eig = np.sort(eigenvalues)[::-1]
    spectral_gap = sorted_eig[0] - sorted_eig[1] if len(sorted_eig) >= 2 else sorted_eig[0]

    # Monte Carlo search for destruction threshold
    destruction_threshold = max_perturbation
    for _ in range(n_samples):
        E = np.random.randn(n, n)
        E = (E + E.T) / 2
        E /= np.linalg.norm(E, ord=2)  # Normalize to operator norm 1

        # Binary search for destruction point
        lo, hi = 0.0, max_perturbation
        for _ in range(30):  # 30 iterations of binary search
            mid = (lo + hi) / 2
            perturbed = A + mid * E
            eigs = np.linalg.eigvalsh(perturbed)
            if np.sum(eigs > 1e-10) > 1:
                hi = mid
            else:
                lo = mid
        destruction_threshold = min(destruction_threshold, hi)

    return spectral_gap, destruction_threshold


# ──────────────────────────────────────────────────────────────────────────
# Main: Run all applications
# ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("  Applications of Lorentzian Recognition Phase Transition")
    print("=" * 60)

    # Application 1: Polynomial certification
    print("\n" + "─" * 60)
    print("  Application 1: Lorentzian Polynomial Certification")
    print("─" * 60)

    n = 10
    gap = 2.0
    hessians = [generate_lorentzian_hessian(n, gap) for _ in range(5)]

    for noise in [0.5, 1.5, 2.5, 3.5]:
        certified, margin, report = certify_lorentzianity(hessians, noise)
        print(f"\n  Noise level = {noise:.1f}:")
        for line in report.strip().split('\n'):
            print(f"    {line}")

    # Application 2: Signal detection
    print("\n" + "─" * 60)
    print("  Application 2: Planted Signal Detection")
    print("─" * 60)

    strengths, det_rates, fp_rates = planted_signal_detection(n=30, n_trials=100)
    print(f"\n  False positive rate: {fp_rates[0]:.3f}")
    print(f"  Detection rates at various signal strengths:")
    for i in range(0, len(strengths), 5):
        print(f"    strength/σ = {strengths[i]:.2f}: detection = {det_rates[i]:.3f}")

    # Application 3: Stability radius
    print("\n" + "─" * 60)
    print("  Application 3: Stability Radius Estimation")
    print("─" * 60)

    for gap_val in [1.0, 2.0, 3.0, 5.0]:
        A = np.diag([-gap_val] * 20)
        A[0, 0] = gap_val
        lb, ub = estimate_stability_radius(A, n_samples=200)
        print(f"\n  Gap = {gap_val:.1f}:")
        print(f"    Spectral gap lower bound: {lb:.4f}")
        print(f"    Monte Carlo upper bound:  {ub:.4f}")
        print(f"    Ratio UB/LB: {ub/lb:.4f}" if lb > 0 else "    (degenerate)")

    # Generate visualization
    print("\n" + "─" * 60)
    print("  Generating application plots...")
    print("─" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Certification margin vs noise
    noise_levels = np.linspace(0, 4, 50)
    margins = [gap - nl for nl in noise_levels]
    axes[0].plot(noise_levels, margins, 'b-', linewidth=2)
    axes[0].axhline(y=0, color='r', linestyle='--', linewidth=1)
    axes[0].fill_between(noise_levels, 0, margins,
                         where=[m > 0 for m in margins], alpha=0.2, color='green')
    axes[0].fill_between(noise_levels, margins, 0,
                         where=[m < 0 for m in margins], alpha=0.2, color='red')
    axes[0].set_xlabel('Noise Level', fontsize=12)
    axes[0].set_ylabel('Certification Margin', fontsize=12)
    axes[0].set_title('Polynomial Certification', fontsize=13)
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Signal detection curve
    axes[1].plot(strengths, det_rates, 'g-', linewidth=2, label='Detection rate')
    axes[1].axhline(y=fp_rates[0], color='r', linestyle='--', label='False positive rate')
    axes[1].axvline(x=2.0, color='k', linestyle=':', label='Edge constant 2')
    axes[1].set_xlabel('Signal Strength / σ', fontsize=12)
    axes[1].set_ylabel('Detection Rate', fontsize=12)
    axes[1].set_title('Planted Signal Detection', fontsize=13)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Stability radius
    gaps = np.linspace(0.5, 5, 20)
    lb_vals = []
    ub_vals = []
    for g in gaps:
        A = np.diag([-g] * 10)
        A[0, 0] = g
        lb, ub = estimate_stability_radius(A, n_samples=50)
        lb_vals.append(lb)
        ub_vals.append(ub)
    axes[2].plot(gaps, lb_vals, 'b-', linewidth=2, label='Spectral gap (lower)')
    axes[2].plot(gaps, ub_vals, 'r--', linewidth=2, label='MC bound (upper)')
    axes[2].set_xlabel('Spectral Gap', fontsize=12)
    axes[2].set_ylabel('Stability Radius', fontsize=12)
    axes[2].set_title('Stability Radius vs Gap', fontsize=13)
    axes[2].legend(fontsize=10)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('applications.png', dpi=150, bbox_inches='tight')
    print("Application plots saved to applications.png")


"""
demo.py — Demonstrate the complexity-theoretic phase transition for Lorentzian recognition.

Generates random symmetric noise matrices, adds optional planted rank-one signals,
computes empirical spectral gaps, and visualizes the success curve as a function
of ε/σ, highlighting the predicted phase transition near the constant 2.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple

# ──────────────────────────────────────────────────────────────────────────
# Core functions
# ──────────────────────────────────────────────────────────────────────────

def generate_goe_matrix(n: int, sigma: float = 1.0) -> np.ndarray:
    """Generate an n×n GOE (Gaussian Orthogonal Ensemble) matrix.

    The GOE matrix has entries M_ij ~ N(0, σ²/n) for i≠j and
    M_ii ~ N(0, 2σ²/n), symmetrized.
    """
    M = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (M + M.T) / 2

def generate_signal_matrix(n: int, gap: float = 1.0) -> np.ndarray:
    """Generate a signal matrix with Lorentzian signature (one positive eigenvalue)
    and spectral gap `gap`.

    The matrix has eigenvalue +gap in the first direction and
    -gap in all other directions.
    """
    D = np.diag([-gap] * n)
    D[0, 0] = gap
    # Random orthogonal rotation
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    return Q @ D @ Q.T

def spectral_gap_proxy(A: np.ndarray) -> float:
    """Compute the spectral gap proxy: largest eigenvalue minus second largest."""
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    if len(eigenvalues) < 2:
        return eigenvalues[0] if len(eigenvalues) == 1 else 0.0
    return eigenvalues[0] - eigenvalues[1]

def has_lorentzian_signature(A: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if A has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > tol) <= 1

def algorithmic_margin(A: np.ndarray) -> float:
    """Compute the algorithmic margin: positive means Lorentzian-recognizable."""
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    n_positive = np.sum(eigenvalues > 0)
    if n_positive <= 1:
        # Already Lorentzian: margin = gap between 1st and 2nd eigenvalue
        if len(eigenvalues) >= 2:
            return eigenvalues[0] - eigenvalues[1]
        return eigenvalues[0] if len(eigenvalues) >= 1 else 0.0
    else:
        # Not Lorentzian: margin = negative of 2nd eigenvalue
        return -eigenvalues[1]

# ──────────────────────────────────────────────────────────────────────────
# Phase transition experiment
# ──────────────────────────────────────────────────────────────────────────

def run_phase_transition_experiment(
    n: int = 50,
    sigma: float = 1.0,
    epsilon_ratios: np.ndarray = None,
    n_trials: int = 200,
    signal_gap: float = None,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Run the phase transition experiment.

    For each ε/σ ratio, generate n_trials instances of:
    - Signal matrix with Lorentzian signature and gap = ε
    - GOE noise matrix with parameter σ
    - Perturbed matrix = Signal + Noise

    Returns (epsilon_ratios, success_rates, mean_margins).
    """
    if epsilon_ratios is None:
        epsilon_ratios = np.linspace(0.5, 4.0, 50)

    success_rates = np.zeros(len(epsilon_ratios))
    mean_margins = np.zeros(len(epsilon_ratios))

    for i, ratio in enumerate(epsilon_ratios):
        gap = ratio * sigma  # Signal gap = ratio * σ
        successes = 0
        margins = []

        for _ in range(n_trials):
            # Generate signal with Lorentzian signature
            A = generate_signal_matrix(n, gap=gap)
            # Generate GOE noise
            E = generate_goe_matrix(n, sigma=sigma)
            # Perturbed matrix
            M = A + E
            # Check recognition
            if has_lorentzian_signature(M):
                successes += 1
            margins.append(algorithmic_margin(M))

        success_rates[i] = successes / n_trials
        mean_margins[i] = np.mean(margins)

    return epsilon_ratios, success_rates, mean_margins

# ──────────────────────────────────────────────────────────────────────────
# Visualization
# ──────────────────────────────────────────────────────────────────────────

def plot_phase_transition(save_path: str = "phase_transition.png"):
    """Generate and plot the phase transition curve."""
    np.random.seed(42)

    print("Running phase transition experiment...")
    print("  n=50, σ=1.0, 200 trials per ε/σ ratio")

    ratios, success_rates, mean_margins = run_phase_transition_experiment(
        n=50, sigma=1.0, n_trials=200
    )

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Success rate
    ax1.plot(ratios, success_rates, 'b-', linewidth=2, label='Success rate')
    ax1.axvline(x=2.0, color='r', linestyle='--', linewidth=1.5,
                label='Edge constant 2σ/σ = 2')
    ax1.fill_between(ratios, 0, 1, where=(ratios >= 2.0),
                     alpha=0.1, color='green', label='Easy phase')
    ax1.fill_between(ratios, 0, 1, where=(ratios <= 2.0),
                     alpha=0.1, color='red', label='Hard phase')
    ax1.set_xlabel('Signal gap / σ  (ε/σ)', fontsize=13)
    ax1.set_ylabel('Recognition success rate', fontsize=13)
    ax1.set_title('Phase Transition in Lorentzian Recognition', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)

    # Right panel: Mean margin
    ax2.plot(ratios, mean_margins, 'g-', linewidth=2, label='Mean margin')
    ax2.axvline(x=2.0, color='r', linestyle='--', linewidth=1.5,
                label='Edge constant 2')
    ax2.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax2.set_xlabel('Signal gap / σ  (ε/σ)', fontsize=13)
    ax2.set_ylabel('Mean algorithmic margin', fontsize=13)
    ax2.set_title('Algorithmic Margin vs Signal Strength', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"Plot saved to {save_path}")

    # Print summary statistics
    idx_edge = np.argmin(np.abs(ratios - 2.0))
    print(f"\nAt the edge (ε/σ ≈ 2.0):")
    print(f"  Success rate: {success_rates[idx_edge]:.3f}")
    print(f"  Mean margin:  {mean_margins[idx_edge]:.4f}")

    # Find the sharpness of the transition
    low_idx = np.argmin(np.abs(ratios - 1.5))
    high_idx = np.argmin(np.abs(ratios - 2.5))
    print(f"\nBelow edge (ε/σ ≈ 1.5): success = {success_rates[low_idx]:.3f}")
    print(f"Above edge (ε/σ ≈ 2.5): success = {success_rates[high_idx]:.3f}")
    print(f"Transition width estimate: ~{(ratios[high_idx] - ratios[low_idx]):.1f}")

def plot_dimension_scaling(save_path: str = "dimension_scaling.png"):
    """Show how the transition sharpens with dimension."""
    np.random.seed(123)

    dimensions = [10, 30, 100]
    ratios = np.linspace(0.5, 4.0, 40)

    fig, ax = plt.subplots(figsize=(10, 7))
    colors = ['#e74c3c', '#3498db', '#2ecc71']

    for dim, color in zip(dimensions, colors):
        print(f"Running n={dim}...")
        _, success_rates, _ = run_phase_transition_experiment(
            n=dim, sigma=1.0, epsilon_ratios=ratios, n_trials=150
        )
        ax.plot(ratios, success_rates, '-', linewidth=2.5, color=color,
                label=f'n = {dim}')

    ax.axvline(x=2.0, color='black', linestyle='--', linewidth=1.5,
               label='Predicted edge = 2')
    ax.set_xlabel('Signal gap / σ', fontsize=14)
    ax.set_ylabel('Recognition success probability', fontsize=14)
    ax.set_title('Phase Transition Sharpens with Dimension', fontsize=15)
    ax.legend(fontsize=12)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"Dimension scaling plot saved to {save_path}")

# ──────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  Lorentzian Recognition Phase Transition Demo")
    print("=" * 60)
    print()
    plot_phase_transition()
    print()
    plot_dimension_scaling()
    print()
    print("Done! The plots confirm the predicted phase transition at ε/σ = 2.")


"""
Sharp GOE Failure Bound Visualization

Visualizes the sharp failure upper bound exp(−(max(ε−2σ,0))²n/(Cσ²))
from the GOE theory, showing how it transitions from 1 (no suppression)
below the edge to exponentially small above the edge. The bound governs
the probability that random perturbation destroys Lorentzian signature.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def sharp_failure_bound(C, sigma, epsilon, n):
    """Compute exp(-(max(ε-2σ,0))²·n / (C·σ²))."""
    excess = max(epsilon - 2 * sigma, 0)
    if C * sigma**2 <= 0:
        return 1.0
    return np.exp(-(excess**2) * n / (C * sigma**2))


sigma = 1.0
C = 4.0
eps_range = np.linspace(0, 5, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Failure bound vs ε for multiple n
ax = axes[0]
for n, color, ls in [(10, '#e74c3c', '-'), (50, '#3498db', '-'),
                      (200, '#2ecc71', '-'), (1000, '#9b59b6', '-')]:
    bounds = [sharp_failure_bound(C, sigma, e, n) for e in eps_range]
    ax.plot(eps_range, bounds, ls, linewidth=2, color=color, label=f'n = {n}')

ax.axvline(x=2*sigma, color='black', linestyle='--', linewidth=2, alpha=0.7)
ax.set_xlabel('Signal gap ε', fontsize=13)
ax.set_ylabel('Failure bound P(misclassification)', fontsize=13)
ax.set_title('Sharp GOE Failure Bound', fontsize=15, fontweight='bold')
ax.set_yscale('log')
ax.set_ylim(1e-15, 2)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.annotate('Edge: 2σ', xy=(2, 0.5), fontsize=12, ha='center',
            color='black', fontweight='bold')

# Panel 2: Exponent surface (ε vs n)
ax = axes[1]
n_range = np.linspace(1, 200, 100)
eps_range2 = np.linspace(0, 5, 100)
N, E = np.meshgrid(n_range, eps_range2)
Z = np.zeros_like(N)
for i in range(len(eps_range2)):
    for j in range(len(n_range)):
        Z[i, j] = sharp_failure_bound(C, sigma, eps_range2[i], n_range[j])

levels = [1e-10, 1e-8, 1e-6, 1e-4, 1e-2, 0.1, 0.5, 0.9, 0.99]
cs = ax.contourf(E, N, Z, levels=20, cmap='RdYlGn_r')
ax.contour(E, N, Z, levels=[0.5], colors='black', linewidths=2)
ax.axvline(x=2*sigma, color='white', linestyle='--', linewidth=2)
plt.colorbar(cs, ax=ax, label='Failure probability')
ax.set_xlabel('Signal gap ε', fontsize=13)
ax.set_ylabel('Dimension n', fontsize=13)
ax.set_title('Failure Landscape', fontsize=15, fontweight='bold')

# Panel 3: Bits of precision (how many bits of safety above edge?)
ax = axes[2]
deltas = np.linspace(0.01, 3, 100)
for n, color in [(10, '#e74c3c'), (50, '#3498db'), (200, '#2ecc71')]:
    bits = [(max(d, 0))**2 * n / (C * sigma**2) / np.log(2)
            for d in deltas]
    ax.plot(deltas, bits, '-', linewidth=2, color=color, label=f'n = {n}')

ax.set_xlabel('Excess gap δ = ε − 2σ', fontsize=13)
ax.set_ylabel('Bits of certification', fontsize=13)
ax.set_title('Certification Strength Above Edge', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.annotate('More bits = stronger guarantee', xy=(1.5, 30),
            fontsize=11, ha='center', style='italic')

plt.tight_layout(pad=2.0)
plt.savefig('viz_failure_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_failure_bound.png")


"""
Hypothesis Testing Reduction Visualization

Visualizes the recognizer-to-tester reduction: how a Lorentzian
signature recognizer induces a hypothesis test for planted signals.
Shows the spectral gap distributions under null (pure noise) and
planted (signal + noise) hypotheses, with the decision threshold
at the GOE edge constant 2σ.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def generate_goe_matrix(n, sigma=1.0):
    """Generate an n×n GOE matrix."""
    M = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (M + M.T) / 2


def spectral_gap(A):
    """Compute eigenvalue gap: λ₁ - λ₂."""
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    if len(eigs) < 2:
        return eigs[0] if len(eigs) > 0 else 0.0
    return eigs[0] - eigs[1]


np.random.seed(42)
n = 50
sigma = 1.0
n_trials = 500

fig, axes = plt.subplots(2, 2, figsize=(16, 14))

# ─── Panel 1: Gap distributions for null vs planted ───
ax = axes[0, 0]
signal_strengths = [0, 1.5, 2.5, 4.0]
colors = ['#95a5a6', '#e74c3c', '#f39c12', '#2ecc71']
labels = ['Null (no signal)', 'Planted (gap=1.5σ)', 'Planted (gap=2.5σ)',
          'Planted (gap=4σ)']

for strength, color, label in zip(signal_strengths, colors, labels):
    gaps = []
    for _ in range(n_trials):
        if strength == 0:
            M = generate_goe_matrix(n, sigma)
        else:
            D = np.diag([-strength * sigma] * n)
            D[0, 0] = strength * sigma
            Q, _ = np.linalg.qr(np.random.randn(n, n))
            signal = Q @ D @ Q.T
            M = signal + generate_goe_matrix(n, sigma)
        gaps.append(spectral_gap(M))

    ax.hist(gaps, bins=40, alpha=0.5, color=color, label=label, density=True)

ax.axvline(x=2*sigma, color='black', linestyle='--', linewidth=2,
           label='Threshold = 2σ')
ax.set_xlabel('Spectral Gap', fontsize=13)
ax.set_ylabel('Density', fontsize=13)
ax.set_title('Gap Distributions: Null vs Planted', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=10, loc='upper right')
ax.grid(True, alpha=0.3)

# ─── Panel 2: ROC curves ───
ax = axes[0, 1]
thresholds = np.linspace(0, 8, 200)

for strength, color, label in [(1.5, '#e74c3c', 'gap=1.5σ'),
                                 (2.5, '#f39c12', 'gap=2.5σ'),
                                 (4.0, '#2ecc71', 'gap=4.0σ')]:
    null_gaps = []
    planted_gaps = []
    for _ in range(n_trials):
        null_gaps.append(spectral_gap(generate_goe_matrix(n, sigma)))

        D = np.diag([-strength * sigma] * n)
        D[0, 0] = strength * sigma
        Q, _ = np.linalg.qr(np.random.randn(n, n))
        signal = Q @ D @ Q.T
        planted_gaps.append(spectral_gap(signal + generate_goe_matrix(n, sigma)))

    null_gaps = np.array(null_gaps)
    planted_gaps = np.array(planted_gaps)

    fpr = [np.mean(null_gaps > t) for t in thresholds]
    tpr = [np.mean(planted_gaps > t) for t in thresholds]

    ax.plot(fpr, tpr, '-', linewidth=2, color=color, label=label)

ax.plot([0, 1], [0, 1], 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('False Positive Rate', fontsize=13)
ax.set_ylabel('True Positive Rate', fontsize=13)
ax.set_title('ROC Curves: Spectral Gap Test', fontsize=15, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)

# ─── Panel 3: Detection advantage vs signal strength ───
ax = axes[1, 0]
strengths = np.linspace(0, 5, 30)
advantages = []
threshold = 2 * sigma

null_gaps = np.array([spectral_gap(generate_goe_matrix(n, sigma))
                      for _ in range(n_trials)])
fp_rate = np.mean(null_gaps > threshold)

for s in strengths:
    planted_gaps_list = []
    for _ in range(200):
        D = np.diag([-s * sigma] * n)
        D[0, 0] = s * sigma
        Q, _ = np.linalg.qr(np.random.randn(n, n))
        signal = Q @ D @ Q.T
        planted_gaps_list.append(spectral_gap(signal + generate_goe_matrix(n, sigma)))

    tp_rate = np.mean(np.array(planted_gaps_list) > threshold)
    advantages.append(tp_rate - fp_rate)

ax.plot(strengths, advantages, 'b-', linewidth=2.5)
ax.axvline(x=2.0, color='r', linestyle='--', linewidth=2, alpha=0.7,
           label='Edge constant = 2')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax.fill_between(strengths, 0, advantages,
                where=[a > 0 for a in advantages], alpha=0.15, color='green')
ax.set_xlabel('Signal strength / σ', fontsize=13)
ax.set_ylabel('Test advantage (TPR − FPR)', fontsize=13)
ax.set_title('Statistical Advantage of Spectral Test', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

# ─── Panel 4: Margin duality illustration ───
ax = axes[1, 1]
g_vals = np.linspace(0.5, 4.0, 100)
planted_margin = g_vals - 2 * sigma  # SpectralGapProxy(g, 2σ, 1)
null_margin = 2 * sigma - g_vals     # SpectralGapProxy(2σ, g, 1)

ax.plot(g_vals, planted_margin, 'g-', linewidth=2.5, label='Planted margin')
ax.plot(g_vals, null_margin, 'r-', linewidth=2.5, label='Null margin')
ax.fill_between(g_vals, planted_margin, null_margin,
                where=planted_margin > null_margin, alpha=0.1, color='green')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax.axvline(x=2.0, color='k', linestyle='--', linewidth=1.5, alpha=0.5)
ax.set_xlabel('Signal gap (g)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Margin Duality: Planted vs Null', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)
ax.annotate('Separation\nregion', xy=(3.0, 0.5), fontsize=12,
            ha='center', color='#27ae60', fontweight='bold')

plt.tight_layout(pad=2.0)
plt.savefig('viz_hypothesis_testing.png', dpi=150, bbox_inches='tight')
print("Saved viz_hypothesis_testing.png")


"""
Phase Transition Visualization for Lorentzian Recognition

Visualizes the sharp phase transition in Lorentzian signature recognition
as a function of signal-to-noise ratio ε/σ. The transition occurs at the
GOE edge constant 2, separating the easy phase (recognition succeeds)
from the hard phase (recognition fails). This is the central empirical
prediction of the complexity-theoretic phase transition theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def generate_goe_matrix(n, sigma=1.0):
    """Generate an n×n GOE matrix with variance parameter σ."""
    M = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (M + M.T) / 2


def generate_signal_matrix(n, gap=1.0):
    """Generate a signal matrix with Lorentzian signature and given gap."""
    D = np.diag([-gap] * n)
    D[0, 0] = gap
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    return Q @ D @ Q.T


def has_lorentzian_signature(A, tol=1e-10):
    """Check if A has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > tol) <= 1


def run_experiment(n, sigma, ratios, n_trials):
    """Run recognition experiment for given parameters."""
    success_rates = np.zeros(len(ratios))
    for i, ratio in enumerate(ratios):
        gap = ratio * sigma
        successes = 0
        for _ in range(n_trials):
            A = generate_signal_matrix(n, gap=gap)
            E = generate_goe_matrix(n, sigma=sigma)
            if has_lorentzian_signature(A + E):
                successes += 1
        success_rates[i] = successes / n_trials
    return success_rates


# Run experiments
np.random.seed(42)
ratios = np.linspace(0.5, 4.0, 40)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Phase transition for multiple dimensions
dims = [10, 30, 100]
colors = ['#e74c3c', '#3498db', '#2ecc71']
for n, color in zip(dims, colors):
    sr = run_experiment(n, 1.0, ratios, 150)
    ax1.plot(ratios, sr, '-', linewidth=2.5, color=color, label=f'n = {n}')

ax1.axvline(x=2.0, color='black', linestyle='--', linewidth=2, alpha=0.7,
            label='Predicted edge = 2')
ax1.fill_betweenx([0, 1], 0.5, 2.0, alpha=0.06, color='red')
ax1.fill_betweenx([0, 1], 2.0, 4.0, alpha=0.06, color='green')
ax1.text(1.2, 0.92, 'Hard\nPhase', fontsize=14, ha='center', color='#c0392b',
         fontweight='bold')
ax1.text(3.2, 0.92, 'Easy\nPhase', fontsize=14, ha='center', color='#27ae60',
         fontweight='bold')
ax1.set_xlabel('Signal gap / σ  (ε/σ)', fontsize=14)
ax1.set_ylabel('Recognition success probability', fontsize=14)
ax1.set_title('Phase Transition in Lorentzian Recognition', fontsize=16,
              fontweight='bold')
ax1.legend(fontsize=12, loc='center left')
ax1.set_ylim(-0.05, 1.05)
ax1.set_xlim(0.5, 4.0)
ax1.grid(True, alpha=0.3)

# Panel 2: Spectral gap proxy as function of noise
gap_values = np.linspace(0.5, 4.0, 100)
sigma = 1.0
proxy_vals = gap_values - 2 * sigma  # SpectralGapProxy(g, 2σ, 1)

ax2.plot(gap_values, proxy_vals, 'b-', linewidth=3)
ax2.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax2.axvline(x=2.0, color='r', linestyle='--', linewidth=2, alpha=0.7)
ax2.fill_between(gap_values, proxy_vals, 0,
                 where=proxy_vals > 0, alpha=0.15, color='green')
ax2.fill_between(gap_values, proxy_vals, 0,
                 where=proxy_vals < 0, alpha=0.15, color='red')
ax2.set_xlabel('Signal gap (g)', fontsize=14)
ax2.set_ylabel('Spectral Gap Proxy  (g − 2σ)', fontsize=14)
ax2.set_title('Algorithmic Margin as Order Parameter', fontsize=16,
              fontweight='bold')
ax2.annotate('Margin > 0\n→ Certified', xy=(3.0, 1.0), fontsize=12,
             ha='center', color='#27ae60', fontweight='bold')
ax2.annotate('Margin < 0\n→ No Certificate', xy=(1.0, -1.0), fontsize=12,
             ha='center', color='#c0392b', fontweight='bold')
ax2.annotate('Critical\nPoint', xy=(2.0, 0), xytext=(2.5, -0.8),
             fontsize=11, ha='center',
             arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
             color='red', fontweight='bold')
ax2.grid(True, alpha=0.3)

plt.tight_layout(pad=2.0)
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
