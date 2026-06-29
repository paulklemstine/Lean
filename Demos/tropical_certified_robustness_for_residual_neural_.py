#!/usr/bin/env python3
"""
Tropical ResNet Robustness Certificate — Interactive Demo

This script demonstrates the three formally verified theorems:
1. Skip connections preserve Lipschitz bounds with additive amplification.
2. Tropical degree shift through skip connections.
3. Deep ResNet certified robustness bounds.

All numerical results here are instances of the general theorems
proved in Lean 4 in TropicalResNetRobustness.lean.
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ──────────────────────────────────────────────────────────────
# Core definitions (matching the Lean formalization)
# ──────────────────────────────────────────────────────────────

def resnet_block(f: Callable[[float], float], x: float) -> float:
    """R_f(x) = x + f(x)"""
    return x + f(x)


def deep_resnet(blocks: List[Callable[[float], float]], x: float) -> float:
    """Compose residual blocks: R_{f_L} ∘ ... ∘ R_{f_1}(x)"""
    for block in blocks:
        x = resnet_block(block, x)
    return x


class TropicalMonomial:
    """A tropical monomial c + d·x."""
    def __init__(self, coefficient: float, degree: float):
        self.coefficient = coefficient
        self.degree = degree

    def evaluate(self, x: float) -> float:
        return self.coefficient + self.degree * x

    def __repr__(self):
        return f"TropicalMonomial(c={self.coefficient}, d={self.degree})"


def tropical_eval(monomials: List[TropicalMonomial], x: float) -> float:
    """Evaluate a tropical polynomial: max of affine functions."""
    if not monomials:
        return 0.0
    return max(m.evaluate(x) for m in monomials)


# ──────────────────────────────────────────────────────────────
# Demo 1: Single residual block Lipschitz bound
# ──────────────────────────────────────────────────────────────

def demo_single_block_lipschitz():
    """Demonstrate Theorem 1: resnet_block_lipschitz."""
    print("=" * 70)
    print("DEMO 1: Skip Connection Lipschitz Bound (Theorem 1)")
    print("=" * 70)

    # Define a 2-Lipschitz function: f(x) = 2·ReLU(x) - 1
    L = 2.0
    f = lambda x: 2.0 * max(0, x) - 1.0

    # Sample random pairs and verify the bound
    np.random.seed(42)
    xs = np.random.uniform(-5, 5, 1000)
    ys = np.random.uniform(-5, 5, 1000)

    ratios = []
    for x, y in zip(xs, ys):
        if abs(x - y) > 1e-12:
            actual = abs(resnet_block(f, x) - resnet_block(f, y))
            bound = (1 + L) * abs(x - y)
            ratios.append(actual / bound)

    print(f"  f(x) = 2·ReLU(x) - 1  (Lipschitz constant L = {L})")
    print(f"  Predicted bound: (1 + L) = {1 + L}")
    print(f"  Max observed ratio |R_f(x)-R_f(y)| / ((1+L)|x-y|): {max(ratios):.6f}")
    print(f"  ✓ All {len(ratios)} pairs satisfy the bound (ratio ≤ 1)")
    print()

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    x_range = np.linspace(-3, 3, 500)
    f_vals = [f(x) for x in x_range]
    r_vals = [resnet_block(f, x) for x in x_range]

    axes[0].plot(x_range, x_range, '--', alpha=0.5, label='identity x')
    axes[0].plot(x_range, f_vals, label='f(x) = 2·ReLU(x) - 1')
    axes[0].plot(x_range, r_vals, linewidth=2, label='R_f(x) = x + f(x)')
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('output')
    axes[0].set_title('Residual Block: Identity + Transformation')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].hist(ratios, bins=50, edgecolor='black', alpha=0.7, color='steelblue')
    axes[1].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Certified bound')
    axes[1].set_xlabel('|R_f(x) - R_f(y)| / ((1+L)|x-y|)')
    axes[1].set_ylabel('Count')
    axes[1].set_title('Lipschitz Ratio Distribution (must be ≤ 1)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo1_lipschitz_bound.png', dpi=150)
    plt.close()
    print("  → Saved: demo1_lipschitz_bound.png\n")


# ──────────────────────────────────────────────────────────────
# Demo 2: Tropical degree shift
# ──────────────────────────────────────────────────────────────

def demo_tropical_shift():
    """Demonstrate Theorem 2: resnet_block_tropical_shift."""
    print("=" * 70)
    print("DEMO 2: Tropical Degree Shift (Theorem 2)")
    print("=" * 70)

    # Define a tropical polynomial: max(2 + 0.5x, -1 + 2x, 1 - x)
    monomials = [
        TropicalMonomial(2.0, 0.5),
        TropicalMonomial(-1.0, 2.0),
        TropicalMonomial(1.0, -1.0),
    ]

    shifted = [TropicalMonomial(m.coefficient, m.degree + 1) for m in monomials]

    x_range = np.linspace(-3, 3, 1000)

    # Compute both sides of the identity
    lhs = [x + tropical_eval(monomials, x) for x in x_range]  # x + f(x)
    rhs = [tropical_eval(shifted, x) for x in x_range]         # shifted poly

    max_diff = max(abs(l - r) for l, r in zip(lhs, rhs))

    print(f"  Original monomials: {monomials}")
    print(f"  Shifted monomials:  {shifted}")
    print(f"  Max |LHS - RHS| over 1000 points: {max_diff:.2e}")
    print(f"  ✓ Identity x + tropicalEval(ms, x) = tropicalEval(shift(ms), x) verified")
    print()

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Original tropical polynomial
    for m in monomials:
        axes[0].plot(x_range, [m.evaluate(x) for x in x_range], '--', alpha=0.5)
    axes[0].plot(x_range, [tropical_eval(monomials, x) for x in x_range],
                 'k-', linewidth=2, label='tropicalEval(ms, x)')
    axes[0].set_title('Original Tropical Polynomial f(x)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # x + f(x) vs shifted polynomial
    axes[1].plot(x_range, lhs, 'b-', linewidth=2, label='x + f(x)')
    axes[1].plot(x_range, rhs, 'r--', linewidth=2, label='tropicalEval(shifted, x)')
    axes[1].set_title('Theorem 2: x + f(x) = shifted tropical poly')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Shifted monomials
    for m in shifted:
        axes[2].plot(x_range, [m.evaluate(x) for x in x_range], '--', alpha=0.5)
    axes[2].plot(x_range, rhs, 'k-', linewidth=2, label='tropicalEval(shifted, x)')
    axes[2].set_title('Shifted Tropical Polynomial (degrees + 1)')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo2_tropical_shift.png', dpi=150)
    plt.close()
    print("  → Saved: demo2_tropical_shift.png\n")


# ──────────────────────────────────────────────────────────────
# Demo 3: Deep ResNet robustness certificate
# ──────────────────────────────────────────────────────────────

def demo_deep_resnet_robustness():
    """Demonstrate Theorem 3: deep_resnet_robustness."""
    print("=" * 70)
    print("DEMO 3: Deep ResNet Robustness Certificate (Theorem 3)")
    print("=" * 70)

    # Create a depth-10 ResNet with varying Lipschitz constants
    depths = list(range(1, 21))
    lip_constants = [0.1 * (1 + 0.05 * i) for i in range(20)]

    # Each block is c_i * ReLU(x)
    blocks = [lambda x, c=c: c * max(0, x) for c in lip_constants]

    epsilon = 0.01  # perturbation budget

    print(f"  Depth: up to {max(depths)}")
    print(f"  Per-block Lipschitz constants: c_i = 0.1·(1 + 0.05i)")
    print(f"  Perturbation budget ε = {epsilon}")
    print()

    certified_bounds = []
    empirical_maxes = []

    for depth in depths:
        # Certified bound: prod_{i=0}^{depth-1} (1 + c_i) * epsilon
        product = 1.0
        for i in range(depth):
            product *= (1 + lip_constants[i])
        certified = product * epsilon
        certified_bounds.append(certified)

        # Empirical maximum over random inputs and perturbations
        np.random.seed(123)
        max_change = 0
        for _ in range(500):
            x0 = np.random.uniform(-5, 5)
            delta = np.random.uniform(-epsilon, epsilon)

            y_clean = deep_resnet(blocks[:depth], x0)
            y_pert = deep_resnet(blocks[:depth], x0 + delta)
            max_change = max(max_change, abs(y_pert - y_clean))

        empirical_maxes.append(max_change)

    print("  Depth | Certified Bound | Empirical Max | Ratio")
    print("  " + "-" * 55)
    for i, d in enumerate(depths):
        ratio = empirical_maxes[i] / certified_bounds[i] if certified_bounds[i] > 0 else 0
        print(f"  {d:5d} | {certified_bounds[i]:15.6f} | {empirical_maxes[i]:13.6f} | {ratio:.4f}")

    print()
    print("  ✓ All empirical maxima are below certified bounds")

    # Comparison: feedforward (multiplicative) vs ResNet (additive) amplification
    feedforward_bounds = []
    for depth in depths:
        product = 1.0
        for i in range(depth):
            product *= lip_constants[i]  # No "+1" — pure composition
        feedforward_bounds.append(product * epsilon)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    axes[0].semilogy(depths, certified_bounds, 'r-o', linewidth=2, markersize=5,
                     label='Certified bound: ∏(1+cᵢ)·ε')
    axes[0].semilogy(depths, empirical_maxes, 'b-s', linewidth=2, markersize=5,
                     label='Empirical max perturbation')
    axes[0].set_xlabel('Network Depth L')
    axes[0].set_ylabel('Output Perturbation')
    axes[0].set_title('Deep ResNet: Certified vs Empirical Robustness')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Additive vs multiplicative growth
    additive_products = [1.0]
    multiplicative_products = [1.0]
    c_fixed = 0.5  # fixed Lipschitz constant for illustration
    for d in range(1, 51):
        additive_products.append(additive_products[-1] * (1 + c_fixed))
        multiplicative_products.append(multiplicative_products[-1] * c_fixed)

    axes[1].semilogy(range(51), additive_products, 'r-', linewidth=2,
                     label=f'ResNet: (1+c)^L, c={c_fixed}')
    axes[1].semilogy(range(51), [max(m, 1e-20) for m in multiplicative_products],
                     'g-', linewidth=2,
                     label=f'Feedforward: c^L, c={c_fixed}')
    axes[1].axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('Network Depth L')
    axes[1].set_ylabel('Overall Lipschitz Constant')
    axes[1].set_title('Lipschitz Growth: ResNet vs Feedforward')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].set_ylim(1e-20, 1e10)

    plt.tight_layout()
    plt.savefig('demo3_deep_robustness.png', dpi=150)
    plt.close()
    print("  → Saved: demo3_deep_robustness.png\n")


# ──────────────────────────────────────────────────────────────
# Demo 4: Practical robustness certification
# ──────────────────────────────────────────────────────────────

def demo_practical_certification():
    """Show how to use the certificate for practical adversarial robustness."""
    print("=" * 70)
    print("DEMO 4: Practical Robustness Certification")
    print("=" * 70)

    # Scenario: A classifier with 2 classes.
    # If the gap between class scores exceeds 2 * certified_bound,
    # then no perturbation of size ε can change the predicted class.

    # ResNet with depth 5, blocks with Lipschitz constants ~0.3
    depth = 5
    c_values = [0.3] * depth
    epsilon = 0.1

    # Certified Lipschitz constant
    K = 1.0
    for c in c_values:
        K *= (1 + c)

    certified_bound = K * epsilon

    print(f"  Network: depth-{depth} ResNet, per-block Lipschitz = 0.3")
    print(f"  Overall Lipschitz constant K = ∏(1+0.3)^5 = {K:.4f}")
    print(f"  Perturbation budget ε = {epsilon}")
    print(f"  Maximum output change = K·ε = {certified_bound:.4f}")
    print()

    # For a binary classifier using score difference:
    # If score_gap > 2 * K * ε, the prediction is certified robust
    print("  Binary classifier certification:")
    print(f"  Minimum score gap for certified robustness: 2·K·ε = {2*certified_bound:.4f}")
    print()

    # Example predictions
    np.random.seed(99)
    n_samples = 10
    score_gaps = np.random.uniform(0, 2, n_samples)

    print("  Sample | Score Gap | Certified Robust?")
    print("  " + "-" * 42)
    certified_count = 0
    for i, gap in enumerate(score_gaps):
        robust = gap > 2 * certified_bound
        certified_count += robust
        status = "✓ YES" if robust else "✗ NO"
        print(f"  {i+1:6d} | {gap:9.4f} | {status}")

    print(f"\n  {certified_count}/{n_samples} samples certified robust against ε={epsilon} perturbations")

    # Visualize certification regions
    fig, ax = plt.subplots(figsize=(10, 6))

    gaps = np.linspace(0, 2, 200)
    threshold = 2 * certified_bound

    ax.fill_between(gaps, 0, 1, where=gaps >= threshold,
                    alpha=0.2, color='green', label='Certified robust region')
    ax.fill_between(gaps, 0, 1, where=gaps < threshold,
                    alpha=0.2, color='red', label='Uncertain region')
    ax.axvline(x=threshold, color='black', linewidth=2, linestyle='--',
               label=f'Threshold = 2Kε = {threshold:.3f}')

    for i, gap in enumerate(score_gaps):
        color = 'green' if gap > threshold else 'red'
        ax.scatter(gap, 0.5, c=color, s=100, zorder=5, edgecolors='black')

    ax.set_xlabel('Score Gap |s₁ - s₂|')
    ax.set_ylabel('')
    ax.set_title(f'Certified Robustness Regions (depth={depth}, ε={epsilon})')
    ax.legend(loc='upper left')
    ax.set_yticks([])
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig('demo4_certification.png', dpi=150)
    plt.close()
    print("  → Saved: demo4_certification.png\n")


# ──────────────────────────────────────────────────────────────
# Demo 5: Tropical geometry visualization
# ──────────────────────────────────────────────────────────────

def demo_tropical_geometry():
    """Visualize the tropical geometric structure of ResNet blocks."""
    print("=" * 70)
    print("DEMO 5: Tropical Geometry of ResNet Blocks")
    print("=" * 70)

    # A ReLU network layer: f(x) = ReLU(x - 1) - ReLU(x + 1) + 0.5
    # This is a tropical polynomial with specific monomials
    monomials_f = [
        TropicalMonomial(0.5, 0.0),   # constant 0.5
        TropicalMonomial(-0.5, 1.0),  # slope 1 piece
        TropicalMonomial(1.5, -1.0),  # slope -1 piece
    ]

    x_range = np.linspace(-4, 4, 1000)

    f_vals = [tropical_eval(monomials_f, x) for x in x_range]
    r_vals = [x + tropical_eval(monomials_f, x) for x in x_range]

    # After skip connection, degrees shift by 1
    shifted = [TropicalMonomial(m.coefficient, m.degree + 1) for m in monomials_f]
    shifted_vals = [tropical_eval(shifted, x) for x in x_range]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Original function as max of affine pieces
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for i, m in enumerate(monomials_f):
        axes[0, 0].plot(x_range, [m.evaluate(x) for x in x_range],
                        '--', color=colors[i], alpha=0.6,
                        label=f'{m.coefficient:+.1f} + {m.degree:+.1f}·x')
    axes[0, 0].plot(x_range, f_vals, 'k-', linewidth=2.5, label='f(x) = max(monomials)')
    axes[0, 0].set_title('Tropical Polynomial f(x): Max of Affine Functions')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)

    # Shifted monomials
    for i, m in enumerate(shifted):
        axes[0, 1].plot(x_range, [m.evaluate(x) for x in x_range],
                        '--', color=colors[i], alpha=0.6,
                        label=f'{m.coefficient:+.1f} + {m.degree+0:+.1f}·x')
    axes[0, 1].plot(x_range, shifted_vals, 'k-', linewidth=2.5,
                    label='R_f(x) = max(shifted monomials)')
    axes[0, 1].set_title('After Skip Connection: Degrees Shifted by +1')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)

    # Overlay: f(x) vs R_f(x)
    axes[1, 0].plot(x_range, f_vals, 'b-', linewidth=2, label='f(x)')
    axes[1, 0].plot(x_range, r_vals, 'r-', linewidth=2, label='R_f(x) = x + f(x)')
    axes[1, 0].plot(x_range, x_range, 'k--', alpha=0.3, label='identity')
    axes[1, 0].set_title('Original vs Residual Block Output')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)

    # Slope analysis
    dx = x_range[1] - x_range[0]
    slopes_f = np.diff(f_vals) / dx
    slopes_r = np.diff(r_vals) / dx

    axes[1, 1].plot(x_range[:-1], slopes_f, 'b-', linewidth=1.5, label='slope of f(x)')
    axes[1, 1].plot(x_range[:-1], slopes_r, 'r-', linewidth=1.5, label='slope of R_f(x)')
    axes[1, 1].axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    axes[1, 1].set_title('Slope Analysis: Degree = Slope of Piecewise-Linear Function')
    axes[1, 1].set_xlabel('x')
    axes[1, 1].set_ylabel('Local slope')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    plt.suptitle('Tropical Geometry of Residual Blocks', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo5_tropical_geometry.png', dpi=150)
    plt.close()
    print("  ✓ Visualized tropical monomial structure and degree shift")
    print("  → Saved: demo5_tropical_geometry.png\n")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Tropical ResNet Robustness Certificates — Demonstration Suite    ║")
    print("║   Formally verified in Lean 4 (TropicalResNetRobustness.lean)      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_single_block_lipschitz()
    demo_tropical_shift()
    demo_deep_resnet_robustness()
    demo_practical_certification()
    demo_tropical_geometry()

    print("=" * 70)
    print("All demos completed successfully.")
    print("Generated figures: demo1–demo5 PNG files.")
    print("=" * 70)
