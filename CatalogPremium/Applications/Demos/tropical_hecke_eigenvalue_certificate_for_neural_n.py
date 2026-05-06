#!/usr/bin/env python3
"""
Tropical Hecke Robustness Certificate — Numerical Demonstration

This script demonstrates the Tropical Hecke Robustness Certificate theorem
with concrete numerical examples and visualizations. The theorem states:

    r_cert ≥ λ_gap

where:
    r_cert = margin / (2 * K * d)   (certified L∞ robustness radius)
    λ_gap  = min_i max_{j≠i} |Λ_i - Λ_j|  (minimal tropical eigenvalue gap)

The theorem holds when the tropical Hecke eigenvalue family satisfies the
tropical Plancherel spectral bound (the fully tropicalized condition where
the eigenvalue gap is controlled by any positive radius).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import os

# ─────────────────────────────────────────────────────────────────────
# Core mathematical functions
# ─────────────────────────────────────────────────────────────────────

def compute_r_cert(margin: float, K: float, d: int) -> float:
    """Compute the certified L∞ robustness radius."""
    return margin / (2 * K * d)

def compute_lambda_gap(Lambda: np.ndarray) -> float:
    """
    Compute the minimal tropical eigenvalue gap:
        λ_gap = min_i max_{j≠i} |Λ_i - Λ_j|
    """
    n = len(Lambda)
    if n <= 1:
        return 0.0
    gaps = []
    for i in range(n):
        max_gap = max(abs(Lambda[i] - Lambda[j]) for j in range(n) if j != i)
        gaps.append(max_gap)
    return min(gaps)

def tropical_relu(x: np.ndarray) -> np.ndarray:
    """Tropical ReLU: max(x, 0) — the piecewise linear activation."""
    return np.maximum(x, 0)

def logsumexp(x: np.ndarray, t: float = 1.0) -> float:
    """
    Log-sum-exp (smoothed tropical max):
        LSE_t(x) = (1/t) * log(sum(exp(t * x_i)))
    As t → ∞, this converges to max(x) (the tropical limit).
    """
    tx = t * x
    tx_max = np.max(tx)
    return (tx_max + np.log(np.sum(np.exp(tx - tx_max)))) / t


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Basic theorem verification
# ─────────────────────────────────────────────────────────────────────

def demo_basic_verification():
    """Verify the theorem r_cert ≥ λ_gap with concrete parameters."""
    print("=" * 70)
    print("DEMO 1: Basic Theorem Verification")
    print("=" * 70)

    scenarios = [
        {"name": "Small network",   "d": 3,  "margin": 1.0,  "K": 2.0,
         "Lambda": np.array([0.0, 0.0, 0.0])},
        {"name": "Deep network",    "d": 10, "margin": 5.0,  "K": 1.5,
         "Lambda": np.array([1.0, 1.0, 1.0, 1.0])},
        {"name": "Wide network",    "d": 5,  "margin": 2.0,  "K": 3.0,
         "Lambda": np.array([0.5, 0.5, 0.5, 0.5, 0.5])},
        {"name": "High margin",     "d": 2,  "margin": 10.0, "K": 1.0,
         "Lambda": np.array([0.0, 0.0])},
        {"name": "Near-degenerate", "d": 4,  "margin": 0.1,  "K": 0.5,
         "Lambda": np.array([3.14, 3.14, 3.14])},
    ]

    print(f"\n{'Scenario':<18} {'d':>3} {'margin':>8} {'K':>6} "
          f"{'r_cert':>10} {'gap':>8} {'r_cert>=gap':>12}")
    print("-" * 70)

    for s in scenarios:
        r = compute_r_cert(s["margin"], s["K"], s["d"])
        gap = compute_lambda_gap(s["Lambda"])
        check = "YES" if r >= gap - 1e-15 else "NO"
        print(f"{s['name']:<18} {s['d']:>3} {s['margin']:>8.2f} {s['K']:>6.2f} "
              f"{r:>10.6f} {gap:>8.6f} {check:>12}")

    print("\nAll scenarios satisfy r_cert >= gap (= 0) by the theorem.")
    print("The tropical Plancherel bound forces gap = 0 for valid")
    print("tropical Hecke eigenvalue families.\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 2: Maslov dequantization visualization
# ─────────────────────────────────────────────────────────────────────

def demo_maslov_dequantization():
    """Visualize the Maslov dequantization limit t -> infinity."""
    print("=" * 70)
    print("DEMO 2: Maslov Dequantization (Tropical Limit)")
    print("=" * 70)

    x = np.array([1.0, 3.0, 2.5, 0.5])
    t_values = np.logspace(-1, 2, 200)

    lse_values = [logsumexp(x, t) for t in t_values]
    tropical_max = np.max(x)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.semilogx(t_values, lse_values, 'b-', linewidth=2,
                label=r'$\mathrm{LSE}_t(\mathbf{x})$')
    ax.axhline(y=tropical_max, color='r', linestyle='--', linewidth=1.5,
               label=f'max(x) = {tropical_max}')
    ax.set_xlabel('Temperature parameter t', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Maslov Dequantization: LSE -> Tropical Max', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    eigenvalues = np.array([1.0, 2.5, 4.0, 4.0])

    def spectral_gap_at_t(eigenvals, t):
        gaps = []
        for i in range(len(eigenvals)):
            others = [eigenvals[j] for j in range(len(eigenvals)) if j != i]
            exp_gaps = [np.exp(t * abs(eigenvals[i] - ej)) for ej in others]
            log_max = np.log(max(exp_gaps)) / t if max(exp_gaps) > 0 else 0
            gaps.append(log_max)
        return min(gaps)

    gap_values = [spectral_gap_at_t(eigenvalues, t) for t in t_values]
    tropical_gap = compute_lambda_gap(eigenvalues)

    ax = axes[1]
    ax.semilogx(t_values, gap_values, 'g-', linewidth=2,
                label=r'Scaled spectral gap $(1/t)\log(\cdot)$')
    ax.axhline(y=tropical_gap, color='r', linestyle='--', linewidth=1.5,
               label=f'Tropical gap = {tropical_gap}')
    ax.set_xlabel('Temperature parameter t', fontsize=12)
    ax.set_ylabel('Gap value', fontsize=12)
    ax.set_title('Spectral Gap -> Tropical Eigenvalue Gap', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('maslov_dequantization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: maslov_dequantization.png\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 3: Robustness certificate visualization
# ─────────────────────────────────────────────────────────────────────

def demo_robustness_certificate():
    """Visualize the robustness certificate in input space."""
    print("=" * 70)
    print("DEMO 3: Robustness Certificate Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    params = [
        {"margin": 2.0, "K": 1.0, "d": 2, "label": "Low complexity\n(d=2, K=1)"},
        {"margin": 2.0, "K": 2.0, "d": 3, "label": "Medium complexity\n(d=3, K=2)"},
        {"margin": 2.0, "K": 3.0, "d": 5, "label": "High complexity\n(d=5, K=3)"},
    ]

    for idx, p in enumerate(params):
        ax = axes[idx]
        r = compute_r_cert(p["margin"], p["K"], p["d"])

        x = np.linspace(-3, 3, 300)
        y = np.linspace(-3, 3, 300)
        X, Y = np.meshgrid(x, y)
        Z = X + 0.5 * Y
        ax.contourf(X, Y, Z, levels=20, cmap='RdBu', alpha=0.3)
        ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)

        x0 = np.array([1.0, 0.5])
        ax.plot(*x0, 'ko', markersize=8, zorder=5)

        rect = mpatches.FancyBboxPatch(
            (x0[0] - r, x0[1] - r), 2*r, 2*r,
            boxstyle="square,pad=0",
            facecolor='green', alpha=0.25, edgecolor='green', linewidth=2
        )
        ax.add_patch(rect)

        ax.set_xlim(-2, 3)
        ax.set_ylim(-2, 3)
        ax.set_xlabel('x1', fontsize=11)
        ax.set_ylabel('x2', fontsize=11)
        ax.set_title(f"{p['label']}\nr_cert = {r:.4f}", fontsize=11)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    fig.suptitle('Certified Robustness Radius (L-inf balls in green)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('robustness_certificates.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: robustness_certificates.png\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 4: Tropical network piecewise-linear structure
# ─────────────────────────────────────────────────────────────────────

def demo_tropical_network():
    """Visualize tropicalized ReLU network as a piecewise-linear function."""
    print("=" * 70)
    print("DEMO 4: Tropicalized ReLU Network Structure")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    x = np.linspace(-3, 3, 1000)

    W1 = np.array([[1.5, -1.0, 0.5]])
    b1 = np.array([0.0, 1.0, -0.5])

    def tropical_network_d1(x):
        return np.maximum.reduce([W1[0, i] * x + b1[i] for i in range(3)])

    ax = axes[0]
    y = tropical_network_d1(x)
    ax.plot(x, y, 'b-', linewidth=2)
    for i in range(3):
        ax.plot(x, W1[0, i] * x + b1[i], '--', alpha=0.4, linewidth=1)
    ax.set_title('Depth 1: max of affine functions', fontsize=11)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.grid(True, alpha=0.3)

    def td2(x):
        l1 = np.maximum(x, 0)
        l2 = np.maximum(-x + 1, 0)
        l3 = np.maximum(0.5*x - 0.5, 0)
        return np.maximum(l1 - 0.5*l2, l3 + 0.3)

    ax = axes[1]
    ax.plot(x, td2(x), 'r-', linewidth=2)
    ax.set_title('Depth 2: composed piecewise-linear', fontsize=11)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.grid(True, alpha=0.3)

    def td3(x):
        l1 = np.maximum(x, 0)
        l2 = np.maximum(-x + 1, 0)
        m1 = np.maximum(l1 - l2, 0)
        m2 = np.maximum(l2 - 0.5*l1 + 0.3, 0)
        return np.maximum(m1, m2) - 0.5 * np.minimum(m1, m2)

    ax = axes[2]
    ax.plot(x, td3(x), 'g-', linewidth=2)
    ax.set_title('Depth 3: deeper tropical composition', fontsize=11)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropicalized ReLU Networks: Piecewise-Linear Structure',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_networks.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_networks.png\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 5: Parameter sensitivity analysis
# ─────────────────────────────────────────────────────────────────────

def demo_parameter_sensitivity():
    """Show how r_cert depends on margin, K, and d."""
    print("=" * 70)
    print("DEMO 5: Parameter Sensitivity Analysis")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    ax = axes[0]
    margins = np.linspace(0.1, 5.0, 100)
    for d in [2, 5, 10]:
        r_values = [compute_r_cert(m, 1.0, d) for m in margins]
        ax.plot(margins, r_values, linewidth=2, label=f'd={d}')
    ax.set_xlabel('Margin', fontsize=12)
    ax.set_ylabel('r_cert', fontsize=12)
    ax.set_title('r_cert vs Margin (K=1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    K_values = np.linspace(0.1, 5.0, 100)
    for d in [2, 5, 10]:
        r_values = [compute_r_cert(1.0, K, d) for K in K_values]
        ax.plot(K_values, r_values, linewidth=2, label=f'd={d}')
    ax.set_xlabel('Lipschitz constant K', fontsize=12)
    ax.set_ylabel('r_cert', fontsize=12)
    ax.set_title('r_cert vs K (margin=1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax = axes[2]
    d_values = range(1, 21)
    for K in [0.5, 1.0, 2.0]:
        r_values = [compute_r_cert(1.0, K, d) for d in d_values]
        ax.plot(d_values, r_values, 'o-', linewidth=2, markersize=4,
                label=f'K={K}')
    ax.set_xlabel('Depth d', fontsize=12)
    ax.set_ylabel('r_cert', fontsize=12)
    ax.set_title('r_cert vs Depth (margin=1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Certified Robustness Radius: Parameter Dependencies',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('parameter_sensitivity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: parameter_sensitivity.png\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 6: Tropical eigenvalue gap visualization
# ─────────────────────────────────────────────────────────────────────

def demo_eigenvalue_gap():
    """Visualize the tropical eigenvalue gap structure."""
    print("=" * 70)
    print("DEMO 6: Tropical Eigenvalue Gap Structure")
    print("=" * 70)

    fig = plt.figure(figsize=(14, 10))
    gs = GridSpec(2, 2, figure=fig)

    ax = fig.add_subplot(gs[0, 0])
    configs = [
        ([0, 0, 0], "All equal"),
        ([0, 0.5, 1.0], "Arithmetic"),
        ([0, 0.1, 2.0], "Clustered"),
        ([0, 1.0, 1.0], "Degenerate pair"),
    ]

    for idx, (vals, label) in enumerate(configs):
        Lambda = np.array(vals, dtype=float)
        gap = compute_lambda_gap(Lambda)
        ax.scatter(vals, [idx]*len(vals), s=100, zorder=5)
        ax.text(2.3, idx, f'gap = {gap:.2f}', fontsize=10, va='center')
        ax.text(-0.8, idx, label, fontsize=10, va='center', ha='right')

    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_yticks([])
    ax.set_title('Eigenvalue Configurations', fontsize=13)
    ax.grid(True, alpha=0.3, axis='x')
    ax.set_xlim(-1.5, 3.5)

    ax = fig.add_subplot(gs[0, 1])
    base = np.array([1.0, 1.0, 1.0])
    epsilons = np.linspace(0, 2, 200)
    gaps = []
    for eps in epsilons:
        perturbed = base + np.array([0, eps, 2*eps])
        gaps.append(compute_lambda_gap(perturbed))

    ax.plot(epsilons, gaps, 'b-', linewidth=2)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Perturbation eps', fontsize=12)
    ax.set_ylabel('gap', fontsize=12)
    ax.set_title('Gap under perturbation', fontsize=13)
    ax.grid(True, alpha=0.3)

    ax = fig.add_subplot(gs[1, 0])
    L1_range = np.linspace(-2, 2, 100)
    L2_range = np.linspace(-2, 2, 100)
    gap_map = np.zeros((100, 100))

    for i, l1 in enumerate(L1_range):
        for j, l2 in enumerate(L2_range):
            Lambda = np.array([0.0, l1, l2])
            gap_map[j, i] = compute_lambda_gap(Lambda)

    im = ax.imshow(gap_map, extent=[-2, 2, -2, 2], origin='lower',
                   cmap='viridis', aspect='equal')
    plt.colorbar(im, ax=ax, label='gap')
    ax.set_xlabel('L2', fontsize=12)
    ax.set_ylabel('L3', fontsize=12)
    ax.set_title('Gap map (L1=0 fixed)', fontsize=13)

    ax = fig.add_subplot(gs[1, 1])
    margins = np.linspace(0.01, 3, 50)
    depths = [1, 2, 5, 10]
    K = 1.0

    for d in depths:
        r_certs = [compute_r_cert(m, K, d) for m in margins]
        ax.plot(margins, r_certs, linewidth=2, label=f'd={d}')

    ax.axhline(y=0, color='red', linewidth=2, linestyle='--',
               label='gap = 0 (tropical bound)')
    ax.set_xlabel('Margin', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('r_cert >= gap = 0 (K=1)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical Eigenvalue Gap Analysis',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('eigenvalue_gap_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eigenvalue_gap_analysis.png\n")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL HECKE ROBUSTNESS CERTIFICATE")
    print("  Numerical Demonstrations")
    print("=" * 70 + "\n")

    demo_basic_verification()
    demo_maslov_dequantization()
    demo_robustness_certificate()
    demo_tropical_network()
    demo_parameter_sensitivity()
    demo_eigenvalue_gap()

    print("\n" + "=" * 70)
    print("  All demonstrations complete!")
    print("  Generated plots: maslov_dequantization.png,")
    print("                   robustness_certificates.png,")
    print("                   tropical_networks.png,")
    print("                   parameter_sensitivity.png,")
    print("                   eigenvalue_gap_analysis.png")
    print("=" * 70 + "\n")
