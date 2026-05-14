"""
Tropical Double Descent: Real-World Applications

Demonstrates how the tropical phase transition framework applies to:
1. Neural network width selection
2. Epoch-wise double descent
3. Quantized model selection on edge hardware
4. Multi-branch learning curves (e.g., ensemble methods)
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Neural Network Width Selection
# ============================================================

def nn_width_selection():
    """
    Simulate neural network test error as a function of width.

    In practice, the risk curve for neural networks as a function of width
    often exhibits double descent. We model this with two affine branches:
    - Classical (bias-dominated): error decreases then increases toward threshold
    - Modern (variance-dominated): error decreases in overparameterized regime

    The tropical model predicts the optimal width and the danger zone.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Width Selection")
    print("=" * 60)

    # Model: dataset has 1000 effective dimensions
    # Classical regime: more parameters reduce bias
    # Interpolation threshold: ~1000 parameters
    # Modern regime: more parameters enable smoother interpolation

    n_threshold = 1000  # interpolation threshold
    A = 2.0             # baseline error level
    B = 0.001           # slope per parameter

    print(f"\nScenario: Image classifier with variable hidden layer width")
    print(f"Interpolation threshold: {n_threshold} parameters")
    print(f"Slope: {B} error units per parameter")

    # Evaluate at key points
    widths = [100, 500, 900, 1000, 1100, 1500, 2000, 5000]
    print(f"\n{'Width':>8} | {'Classical':>10} | {'Modern':>10} | {'Tropical':>10} | {'Regime':>12}")
    print("-" * 60)

    for w in widths:
        c = A + B * w - 2 * B * n_threshold
        m = A - B * w
        t = min(c, m)
        regime = "classical" if c <= m else "modern"
        marker = " ← PEAK" if w == n_threshold else ""
        print(f"{w:>8} | {c:>10.4f} | {m:>10.4f} | {t:>10.4f} | {regime:>12}{marker}")

    print(f"\nRecommendation: AVOID width ≈ {n_threshold}.")
    print(f"Optimal strategy: use width >> {n_threshold} (modern regime)")
    print(f"Peak error at threshold: {A - B * n_threshold:.4f}")
    print(f"Error at 5000 params: {A - B * 5000:.4f} (much better)")


# ============================================================
# Application 2: Epoch-Wise Double Descent
# ============================================================

def epoch_wise_descent():
    """
    Model epoch-wise double descent using tropical risk.

    As training proceeds, the model first fits the data (error decreases),
    then starts memorizing noise (error increases toward interpolation epoch),
    then finds a smoother solution (error decreases again).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Epoch-Wise Double Descent")
    print("=" * 60)

    # Interpolation epoch: when training loss first hits zero
    epoch_threshold = 50
    A = 3.0
    B = 0.04

    print(f"\nScenario: Training a neural network, tracking test error vs epochs")
    print(f"Interpolation epoch: {epoch_threshold}")

    epochs = list(range(0, 101, 10))
    print(f"\n{'Epoch':>8} | {'Test Error':>10} | {'Phase':>15}")
    print("-" * 40)

    for e in epochs:
        c = A + B * e - 2 * B * epoch_threshold
        m = A - B * e
        t = min(c, m)
        if e < epoch_threshold:
            phase = "pre-interpolation"
        elif e == epoch_threshold:
            phase = "INTERPOLATION"
        else:
            phase = "post-interpolation"
        print(f"{e:>8} | {t:>10.3f} | {phase:>15}")

    print(f"\nKey insight: Continue training past epoch {epoch_threshold}!")
    print(f"Early stopping at epoch {epoch_threshold} gives WORST test error.")


# ============================================================
# Application 3: Quantized Model Selection
# ============================================================

def quantized_model_selection():
    """
    Demonstrate certified robustness of model selection under quantization.

    When risk estimates are computed in reduced precision (e.g., INT8),
    the tropical vertex stability theorem guarantees the phase structure
    is preserved if the branch gap exceeds 2ε.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantized Model Selection")
    print("=" * 60)

    A, B, n0 = 5.0, 0.3, 15

    # Simulate different quantization levels
    quant_configs = [
        ("FP32", 1e-7),
        ("FP16", 5e-4),
        ("BF16", 1e-3),
        ("INT8", 0.02),
        ("INT4", 0.1),
    ]

    print(f"\nModel: A={A}, B={B}, n₀={n0}")
    print(f"Branch gap at distance k from threshold: 2B·k = {2*B:.2f}·k")

    print(f"\n{'Format':>8} | {'ε':>10} | {'Min safe |n-n₀|':>16} | {'Safe range':>15}")
    print("-" * 60)

    for name, eps in quant_configs:
        # Stability requires 2B·k > 2ε, i.e., k > ε/B
        min_dist = eps / B
        safe_from = max(0, int(np.ceil(n0 - min_dist + 1e-12)))  # not meaningful here
        min_k = int(np.ceil(min_dist + 1e-12))
        print(f"{name:>8} | {eps:>10.1e} | {min_k:>16} | n∉[{n0-min_k+1}..{n0+min_k-1}]")

    print(f"\nConclusion: Even INT8 preserves the phase structure for |n-n₀| ≥ 1.")
    print(f"Only INT4 might confuse branches very close to the threshold.")

    # Demonstrate with actual noisy evaluations
    print(f"\n--- Numerical verification with INT8 noise ---")
    np.random.seed(123)
    eps = 0.02
    errors = 0
    trials = 1000
    for _ in range(trials):
        for n in range(30):
            c = A + B * n - 2 * B * n0
            m = A - B * n
            c_noisy = c + np.random.uniform(-eps, eps)
            m_noisy = m + np.random.uniform(-eps, eps)

            exact_winner = "classical" if c <= m else "modern"
            noisy_winner = "classical" if c_noisy <= m_noisy else "modern"

            if exact_winner != noisy_winner and n != n0:
                errors += 1

    print(f"  {trials} random trials, {errors} branch-selection errors "
          f"out of {trials * 30} evaluations (excluding n₀)")
    print(f"  Error rate: {100 * errors / (trials * 30):.4f}%")


# ============================================================
# Application 4: Multi-Branch Learning Curves
# ============================================================

def multi_branch_learning():
    """
    Demonstrate multi-branch tropical risk for ensemble/multi-architecture scenarios.

    When multiple model architectures compete, the risk landscape becomes a
    tropical arrangement with multiple vertices (phase transitions).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Multi-Architecture Competition")
    print("=" * 60)

    # Four competing architectures:
    # 1. Linear model: low bias reduction rate, always available
    # 2. Small neural net: moderate, threshold at n=20
    # 3. Large neural net: aggressive, threshold at n=50
    # 4. Ensemble: very powerful but needs lots of parameters
    architectures = [
        ("Linear", -2.0, 0.15),
        ("Small NN", 0.0, 0.08),
        ("Large NN", 4.0, -0.05),
        ("Ensemble", 8.0, -0.12),
    ]

    print("\nCompeting architectures:")
    for name, alpha, beta in architectures:
        direction = "↑" if beta > 0 else "↓"
        print(f"  {name}: f(n) = {alpha:+.1f} + {beta:+.3f}·n  {direction}")

    n_range = range(0, 81)
    print(f"\n{'n':>4} | {'Linear':>8} | {'SmallNN':>8} | {'LargeNN':>8} | {'Ensemble':>8} | {'Best':>8} | {'Winner':>10}")
    print("-" * 75)

    transitions = []
    prev_winner = None

    for n in list(range(0, 81, 5)):
        vals = [(alpha + beta * n, name) for name, alpha, beta in architectures]
        risks = [v[0] for v in vals]
        best_idx = np.argmin(risks)
        best_val = risks[best_idx]
        winner = vals[best_idx][1]

        if prev_winner is not None and winner != prev_winner:
            transitions.append((n, prev_winner, winner))
        prev_winner = winner

        print(f"{n:>4} | {risks[0]:>8.2f} | {risks[1]:>8.2f} | {risks[2]:>8.2f} | {risks[3]:>8.2f} | {best_val:>8.2f} | {winner:>10}")

    print(f"\nPhase transitions detected:")
    for n, before, after in transitions:
        print(f"  n ≈ {n}: {before} → {after}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    nn_width_selection()
    epoch_wise_descent()
    quantized_model_selection()
    multi_branch_learning()


"""
Tropical Double Descent: Demonstration and Numerical Verification

This module demonstrates the tropical phase transition theorem for double descent,
verifying all five certified properties with concrete numerical examples.
"""

import numpy as np

# ============================================================
# Core Definitions
# ============================================================

def classical_risk(A: float, B: float, n0: int, n: int) -> float:
    """Classical risk branch: A + B*n - 2*B*n0 (increasing with slope B)."""
    return A + B * n - 2 * B * n0

def modern_risk(A: float, B: float, n0: int, n: int) -> float:
    """Modern risk branch: A - B*n (decreasing with slope -B)."""
    return A - B * n

def tropical_risk(A: float, B: float, n0: int, n: int) -> float:
    """Tropical (min-plus) risk: min of classical and modern branches."""
    return min(classical_risk(A, B, n0, n), modern_risk(A, B, n0, n))

def affine_nat(alpha: float, beta: float, n: int) -> float:
    """General affine form: alpha + beta * n."""
    return alpha + beta * n

def tropical_affine_risk(a1: float, b1: float, a2: float, b2: float, n: int) -> float:
    """Tropical minimum of two general affine forms."""
    return min(affine_nat(a1, b1, n), affine_nat(a2, b2, n))

# ============================================================
# Verification of Theorem Properties
# ============================================================

def verify_concrete_model():
    """Verify all properties of the concrete tropical risk model."""
    print("=" * 70)
    print("VERIFICATION: Concrete Tropical Double Descent Model")
    print("=" * 70)

    A, B, n0 = 5.0, 0.3, 15
    print(f"\nParameters: A={A}, B={B}, n₀={n0}")
    print(f"Vertex value: A - B*n₀ = {A - B * n0}")
    print()

    # Property 1: Left facet dominance (n ≤ n₀)
    print("--- Property 1: Left facet dominance (n ≤ n₀) ---")
    all_ok = True
    for n in range(n0 + 1):
        tr = tropical_risk(A, B, n0, n)
        cr = classical_risk(A, B, n0, n)
        if abs(tr - cr) > 1e-12:
            print(f"  FAIL at n={n}: tropical={tr}, classical={cr}")
            all_ok = False
    print(f"  {'PASS' if all_ok else 'FAIL'}: tropicalRisk = classicalRisk for all n ≤ {n0}")

    # Property 2: Right facet dominance (n₀ ≤ n)
    print("\n--- Property 2: Right facet dominance (n₀ ≤ n) ---")
    all_ok = True
    for n in range(n0, 40):
        tr = tropical_risk(A, B, n0, n)
        mr = modern_risk(A, B, n0, n)
        if abs(tr - mr) > 1e-12:
            print(f"  FAIL at n={n}: tropical={tr}, modern={mr}")
            all_ok = False
    print(f"  {'PASS' if all_ok else 'FAIL'}: tropicalRisk = modernRisk for all n ≥ {n0}")

    # Property 3: Vertex value
    print(f"\n--- Property 3: Vertex value ---")
    vertex_val = tropical_risk(A, B, n0, n0)
    expected = A - B * n0
    print(f"  tropicalRisk(n₀) = {vertex_val}, expected = {expected}")
    print(f"  {'PASS' if abs(vertex_val - expected) < 1e-12 else 'FAIL'}")

    # Property 4: Strict increase to threshold
    print(f"\n--- Property 4: Strict increase for n < n₀ ---")
    all_ok = True
    for n in range(n0):
        if tropical_risk(A, B, n0, n) >= tropical_risk(A, B, n0, n + 1):
            print(f"  FAIL at n={n}: {tropical_risk(A, B, n0, n)} >= {tropical_risk(A, B, n0, n+1)}")
            all_ok = False
    print(f"  {'PASS' if all_ok else 'FAIL'}: strictly increasing on [0, {n0})")

    # Property 5: Strict decrease after threshold
    print(f"\n--- Property 5: Strict decrease for n ≥ n₀ ---")
    all_ok = True
    for n in range(n0, 35):
        if tropical_risk(A, B, n0, n + 1) >= tropical_risk(A, B, n0, n):
            print(f"  FAIL at n={n}: {tropical_risk(A, B, n0, n+1)} >= {tropical_risk(A, B, n0, n)}")
            all_ok = False
    print(f"  {'PASS' if all_ok else 'FAIL'}: strictly decreasing on [{n0}, 35)")

    # Global maximum
    print(f"\n--- Property 6: Unique global maximum at n₀ ---")
    vertex = tropical_risk(A, B, n0, n0)
    all_ok = True
    for n in range(40):
        if n != n0 and tropical_risk(A, B, n0, n) >= vertex:
            print(f"  FAIL at n={n}: {tropical_risk(A, B, n0, n)} >= {vertex}")
            all_ok = False
    print(f"  {'PASS' if all_ok else 'FAIL'}: n₀={n0} is strict global max")

    print()
    return A, B, n0


def verify_general_model():
    """Verify the general tropical affine phase transition theorem."""
    print("=" * 70)
    print("VERIFICATION: General Tropical Affine Phase Transition")
    print("=" * 70)

    # Two affine forms crossing at n₀ = 10
    # f₁(n) = -3 + 0.4n  (positive slope)
    # f₂(n) = 5 - 0.4n   (negative slope)
    # Crossing: -3 + 0.4n = 5 - 0.4n → 0.8n = 8 → n = 10
    a1, b1 = -3.0, 0.4
    a2, b2 = 5.0, -0.4
    n0 = 10
    print(f"\nf₁(n) = {a1} + {b1}·n, f₂(n) = {a2} + {b2}·n")
    print(f"Crossing at n₀ = {n0}")
    print(f"f₁(n₀) = {affine_nat(a1, b1, n0)}, f₂(n₀) = {affine_nat(a2, b2, n0)}")

    # All four properties
    print("\n--- Left facet ---")
    ok = all(
        abs(tropical_affine_risk(a1, b1, a2, b2, n) - affine_nat(a1, b1, n)) < 1e-12
        for n in range(n0 + 1)
    )
    print(f"  {'PASS' if ok else 'FAIL'}")

    print("--- Right facet ---")
    ok = all(
        abs(tropical_affine_risk(a1, b1, a2, b2, n) - affine_nat(a2, b2, n)) < 1e-12
        for n in range(n0, 30)
    )
    print(f"  {'PASS' if ok else 'FAIL'}")

    print("--- Strictly increasing before threshold ---")
    ok = all(
        tropical_affine_risk(a1, b1, a2, b2, n) < tropical_affine_risk(a1, b1, a2, b2, n + 1)
        for n in range(n0)
    )
    print(f"  {'PASS' if ok else 'FAIL'}")

    print("--- Strictly decreasing after threshold ---")
    ok = all(
        tropical_affine_risk(a1, b1, a2, b2, n + 1) < tropical_affine_risk(a1, b1, a2, b2, n)
        for n in range(n0, 25)
    )
    print(f"  {'PASS' if ok else 'FAIL'}")

    print()
    return a1, b1, a2, b2, n0


def verify_stability():
    """Verify the perturbation stability theorem."""
    print("=" * 70)
    print("VERIFICATION: Tropical Vertex Stability Under Perturbation")
    print("=" * 70)

    A, B, n0 = 5.0, 0.3, 15
    epsilon = 0.1

    np.random.seed(42)

    # Create perturbed risk functions
    N = 30
    f = [classical_risk(A, B, n0, n) for n in range(N)]
    g = [modern_risk(A, B, n0, n) for n in range(N)]

    # Add bounded noise
    f_perturbed = [f[n] + np.random.uniform(-epsilon, epsilon) for n in range(N)]
    g_perturbed = [g[n] + np.random.uniform(-epsilon, epsilon) for n in range(N)]

    print(f"\nParameters: A={A}, B={B}, n₀={n0}, ε={epsilon}")
    print(f"Branch gap at n₀±k: 2B·k = {2*B}·k")
    print(f"Stability requires gap > 2ε = {2*epsilon}")
    print(f"So stability holds for |n - n₀| > {2*epsilon/(2*B):.1f}, i.e., |n - n₀| ≥ 1")

    # Check that branch dominance is preserved
    print("\n--- Left of threshold (n < n₀) ---")
    ok = True
    for n in range(n0):
        gap = abs(f[n] - g[n])
        if gap > 2 * epsilon:
            exact_dom = min(f[n], g[n]) == f[n]
            perturbed_dom = min(f_perturbed[n], g_perturbed[n]) == f_perturbed[n]
            if exact_dom != perturbed_dom:
                print(f"  FAIL at n={n}")
                ok = False
    print(f"  {'PASS' if ok else 'FAIL'}: branch dominance preserved")

    print("--- Right of threshold (n > n₀) ---")
    ok = True
    for n in range(n0 + 1, N):
        gap = abs(f[n] - g[n])
        if gap > 2 * epsilon:
            exact_dom = min(f[n], g[n]) == g[n]
            perturbed_dom = min(f_perturbed[n], g_perturbed[n]) == g_perturbed[n]
            if exact_dom != perturbed_dom:
                print(f"  FAIL at n={n}")
                ok = False
    print(f"  {'PASS' if ok else 'FAIL'}: branch dominance preserved")

    print()


def print_risk_table():
    """Print a formatted table of risk values."""
    print("=" * 70)
    print("TABLE: Risk Values for A=5.0, B=0.3, n₀=15")
    print("=" * 70)
    A, B, n0 = 5.0, 0.3, 15
    print(f"{'n':>4} | {'Classical':>10} | {'Modern':>10} | {'Tropical':>10} | {'Active':>10}")
    print("-" * 55)
    for n in range(0, 31, 1):
        cr = classical_risk(A, B, n0, n)
        mr = modern_risk(A, B, n0, n)
        tr = tropical_risk(A, B, n0, n)
        active = "classical" if abs(tr - cr) < 1e-12 else "modern"
        marker = " ← VERTEX" if n == n0 else ""
        print(f"{n:>4} | {cr:>10.2f} | {mr:>10.2f} | {tr:>10.2f} | {active:>10}{marker}")
    print()


if __name__ == "__main__":
    print_risk_table()
    verify_concrete_model()
    verify_general_model()
    verify_stability()
    print("All verifications complete.")


"""
Tropical Double Descent: Visualizations

Generates publication-quality figures for the tropical phase transition framework.
All figures are saved as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def classical_risk(A, B, n0, n):
    return A + B * n - 2 * B * n0

def modern_risk(A, B, n0, n):
    return A - B * n

def tropical_risk(A, B, n0, n):
    return min(classical_risk(A, B, n0, n), modern_risk(A, B, n0, n))


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_double_descent_main():
    """Main double descent figure showing both branches and tropical envelope."""
    A, B, n0 = 5.0, 0.3, 15
    ns = np.arange(0, 31)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Compute values
    classical = [classical_risk(A, B, n0, n) for n in ns]
    modern = [modern_risk(A, B, n0, n) for n in ns]
    trop = [tropical_risk(A, B, n0, n) for n in ns]

    # Plot branches
    ax.plot(ns, classical, '--', color='#2196F3', linewidth=1.5, alpha=0.6, label='Classical branch')
    ax.plot(ns, modern, '--', color='#FF9800', linewidth=1.5, alpha=0.6, label='Modern branch')

    # Plot tropical risk (thick)
    ax.plot(ns, trop, '-', color='#E91E63', linewidth=3, label='Tropical risk (min)')

    # Mark vertex
    vertex_val = tropical_risk(A, B, n0, n0)
    ax.plot(n0, vertex_val, 'o', color='#E91E63', markersize=12, zorder=5)
    ax.annotate(f'Tropical vertex\n(n₀={n0}, R={vertex_val:.1f})',
                xy=(n0, vertex_val), xytext=(n0 + 3, vertex_val + 0.8),
                fontsize=11, ha='left',
                arrowprops=dict(arrowstyle='->', color='#333'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='#E91E63', alpha=0.9))

    # Shade regimes
    ax.axvspan(0, n0, alpha=0.05, color='#2196F3', label='Classical regime')
    ax.axvspan(n0, 30, alpha=0.05, color='#FF9800', label='Modern regime')
    ax.axvline(x=n0, color='gray', linestyle=':', linewidth=1, alpha=0.5)

    # Arrows for monotonicity
    ax.annotate('', xy=(12, tropical_risk(A, B, n0, 12)),
                xytext=(5, tropical_risk(A, B, n0, 5)),
                arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
    ax.annotate('', xy=(25, tropical_risk(A, B, n0, 25)),
                xytext=(18, tropical_risk(A, B, n0, 18)),
                arrowprops=dict(arrowstyle='->', color='#FF9800', lw=2))

    ax.set_xlabel('Model Complexity (n)', fontsize=13)
    ax.set_ylabel('Risk', fontsize=13)
    ax.set_title('Tropical Double Descent: Phase Transition at the Tropical Vertex', fontsize=14)
    ax.legend(loc='lower left', fontsize=10, framealpha=0.9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 30.5)

    fig.savefig('fig_double_descent.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_branch_gap():
    """Visualize the branch gap and its sign change at the vertex."""
    A, B, n0 = 5.0, 0.3, 15
    ns = np.arange(0, 31)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), height_ratios=[2, 1])

    # Top: both branches
    classical = [classical_risk(A, B, n0, n) for n in ns]
    modern = [modern_risk(A, B, n0, n) for n in ns]

    ax1.plot(ns, classical, '-o', color='#2196F3', linewidth=2, markersize=4, label='Classical')
    ax1.plot(ns, modern, '-s', color='#FF9800', linewidth=2, markersize=4, label='Modern')
    ax1.fill_between(ns, classical, modern, where=[c <= m for c, m in zip(classical, modern)],
                     alpha=0.15, color='#2196F3', label='Classical ≤ Modern')
    ax1.fill_between(ns, classical, modern, where=[c >= m for c, m in zip(classical, modern)],
                     alpha=0.15, color='#FF9800', label='Modern ≤ Classical')
    ax1.axvline(x=n0, color='#E91E63', linestyle='--', linewidth=1.5, label=f'n₀ = {n0}')
    ax1.set_ylabel('Risk', fontsize=12)
    ax1.set_title('Branch Comparison and Gap Analysis', fontsize=14)
    ax1.legend(fontsize=9, ncol=3)
    ax1.grid(True, alpha=0.3)

    # Bottom: gap
    gap = [2 * B * (n - n0) for n in ns]
    colors = ['#2196F3' if g <= 0 else '#FF9800' for g in gap]
    ax2.bar(ns, gap, color=colors, alpha=0.7, width=0.8)
    ax2.axhline(y=0, color='black', linewidth=1)
    ax2.axvline(x=n0, color='#E91E63', linestyle='--', linewidth=1.5)
    ax2.set_xlabel('Model Complexity (n)', fontsize=12)
    ax2.set_ylabel('Gap = Classical − Modern', fontsize=12)
    ax2.set_title('Branch Gap: Δ(n) = 2B(n − n₀)', fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('fig_branch_gap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_discrete_derivative():
    """Plot the discrete tropical derivative showing the sign change."""
    A, B, n0 = 5.0, 0.3, 15
    ns = np.arange(0, 30)

    fig, ax = plt.subplots(1, 1, figsize=(10, 5))

    derivs = []
    for n in ns:
        r_n = tropical_risk(A, B, n0, n)
        r_n1 = tropical_risk(A, B, n0, n + 1)
        derivs.append(r_n1 - r_n)

    colors = ['#4CAF50' if d > 0 else '#F44336' for d in derivs]
    ax.bar(ns, derivs, color=colors, alpha=0.8, width=0.8)
    ax.axhline(y=0, color='black', linewidth=1)
    ax.axvline(x=n0 - 0.5, color='#E91E63', linestyle='--', linewidth=2, label=f'n₀ = {n0}')

    ax.set_xlabel('Model Complexity (n)', fontsize=12)
    ax.set_ylabel('ΔR(n) = R(n+1) − R(n)', fontsize=12)
    ax.set_title('Discrete Tropical Derivative: Sign Changes at the Vertex', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Annotations
    ax.annotate('Δ = +B (increasing)', xy=(5, B), xytext=(3, B + 0.15),
                fontsize=10, color='#4CAF50', fontweight='bold')
    ax.annotate('Δ = −B (decreasing)', xy=(22, -B), xytext=(20, -B - 0.15),
                fontsize=10, color='#F44336', fontweight='bold')

    fig.savefig('fig_derivative.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_stability():
    """Visualize perturbation stability of the tropical vertex."""
    A, B, n0 = 5.0, 0.3, 15
    epsilon = 0.2
    ns = np.arange(0, 31)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    np.random.seed(42)

    # True tropical risk
    trop = [tropical_risk(A, B, n0, n) for n in ns]

    # Multiple perturbed versions
    for trial in range(20):
        perturbed = []
        for n in ns:
            c = classical_risk(A, B, n0, n) + np.random.uniform(-epsilon, epsilon)
            m = modern_risk(A, B, n0, n) + np.random.uniform(-epsilon, epsilon)
            perturbed.append(min(c, m))
        ax.plot(ns, perturbed, '-', color='#9E9E9E', linewidth=0.5, alpha=0.4)

    # True risk (thick)
    ax.plot(ns, trop, '-', color='#E91E63', linewidth=3, label='True tropical risk', zorder=10)

    # Epsilon band around vertex
    ax.axvspan(n0 - epsilon/B, n0 + epsilon/B, alpha=0.2, color='#FFC107',
               label=f'Uncertainty zone (±ε/B = ±{epsilon/B:.1f})')

    # Safe zones
    ax.annotate('Branch dominance\nPRESERVED', xy=(5, min(trop) + 0.5),
                fontsize=11, ha='center', color='#4CAF50', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.annotate('Branch dominance\nPRESERVED', xy=(25, min(trop) + 0.5),
                fontsize=11, ha='center', color='#4CAF50', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    ax.set_xlabel('Model Complexity (n)', fontsize=12)
    ax.set_ylabel('Risk', fontsize=12)
    ax.set_title(f'Tropical Vertex Stability: ε = {epsilon}, 20 Random Perturbations', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    fig.savefig('fig_stability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_general_affine():
    """Plot the general tropical affine phase transition for various parameter settings."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    configs = [
        ((-3, 0.4, 5, -0.4), "Symmetric: β₁ = 0.4, β₂ = −0.4"),
        ((-5, 0.8, 3, -0.2), "Asymmetric: β₁ = 0.8, β₂ = −0.2"),
        ((-1, 0.2, 7, -0.6), "Steep modern: β₁ = 0.2, β₂ = −0.6"),
        ((-4, 0.5, 6, -0.5), "Equal slopes: β₁ = 0.5, β₂ = −0.5"),
    ]

    for ax, ((a1, b1, a2, b2), title) in zip(axes.flat, configs):
        # Find crossing
        n0_real = (a2 - a1) / (b1 - b2)
        ns = np.arange(0, 31)

        f1 = [a1 + b1 * n for n in ns]
        f2 = [a2 + b2 * n for n in ns]
        trop = [min(v1, v2) for v1, v2 in zip(f1, f2)]

        ax.plot(ns, f1, '--', color='#2196F3', linewidth=1, alpha=0.5, label='f₁')
        ax.plot(ns, f2, '--', color='#FF9800', linewidth=1, alpha=0.5, label='f₂')
        ax.plot(ns, trop, '-', color='#E91E63', linewidth=2.5, label='min(f₁, f₂)')

        if 0 <= n0_real <= 30:
            v = a1 + b1 * n0_real
            ax.plot(n0_real, v, 'o', color='#E91E63', markersize=10, zorder=5)
            ax.axvline(x=n0_real, color='gray', linestyle=':', alpha=0.5)

        ax.set_title(title, fontsize=11)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('n')
        ax.set_ylabel('Risk')

    fig.suptitle('General Tropical Affine Phase Transitions', fontsize=14, y=1.01)
    fig.tight_layout()
    fig.savefig('fig_general_affine.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_phase_diagram_2d():
    """Plot a conceptual 2D phase diagram for two hyperparameters."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Create a 2D grid showing which of 3 "branches" dominates
    x = np.linspace(0, 10, 200)
    y = np.linspace(0, 10, 200)
    X, Y = np.meshgrid(x, y)

    # Three competing risk branches
    R1 = 5 - 0.3 * X - 0.4 * Y   # Branch 1: good at low X, low Y
    R2 = 2 + 0.2 * X - 0.3 * Y   # Branch 2: moderate
    R3 = -1 + 0.1 * X + 0.2 * Y  # Branch 3: good at high X, high Y

    # Which branch dominates
    R_stack = np.stack([R1, R2, R3])
    dominant = np.argmin(R_stack, axis=0)
    R_min = np.min(R_stack, axis=0)

    # Plot phase regions
    cmap = plt.cm.Set3
    ax.contourf(X, Y, dominant, levels=[-0.5, 0.5, 1.5, 2.5],
                colors=['#BBDEFB', '#FFE0B2', '#C8E6C9'], alpha=0.7)

    # Plot tropical curves (boundaries)
    ax.contour(X, Y, R1 - R2, levels=[0], colors=['#1565C0'], linewidths=2)
    ax.contour(X, Y, R2 - R3, levels=[0], colors=['#E65100'], linewidths=2)
    ax.contour(X, Y, R1 - R3, levels=[0], colors=['#2E7D32'], linewidths=2)

    # Labels
    ax.text(1, 2, 'Phase 1\n(Classical)', fontsize=12, ha='center',
            fontweight='bold', color='#1565C0')
    ax.text(5, 3, 'Phase 2\n(Transitional)', fontsize=12, ha='center',
            fontweight='bold', color='#E65100')
    ax.text(7, 8, 'Phase 3\n(Modern)', fontsize=12, ha='center',
            fontweight='bold', color='#2E7D32')

    ax.set_xlabel('Hyperparameter 1 (e.g., Width)', fontsize=12)
    ax.set_ylabel('Hyperparameter 2 (e.g., Depth)', fontsize=12)
    ax.set_title('2D Tropical Phase Diagram:\nCompeting Risk Regimes in Hyperparameter Space', fontsize=14)
    ax.grid(True, alpha=0.2)

    fig.savefig('fig_phase_diagram_2d.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_main = plot_double_descent_main()
    print("  ✓ fig_double_descent.png")
    b64_gap = plot_branch_gap()
    print("  ✓ fig_branch_gap.png")
    b64_deriv = plot_discrete_derivative()
    print("  ✓ fig_derivative.png")
    b64_stab = plot_stability()
    print("  ✓ fig_stability.png")
    b64_gen = plot_general_affine()
    print("  ✓ fig_general_affine.png")
    b64_2d = plot_phase_diagram_2d()
    print("  ✓ fig_phase_diagram_2d.png")
    print("All visualizations generated successfully.")
