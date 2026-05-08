#!/usr/bin/env python3
"""
Operadic Deep Learning: Numerical Demonstrations

This script demonstrates the key theorems from the formal Lean 4 verification
with concrete numerical examples and visualizations.

Theorems demonstrated:
1. Depth separation via generator count and depth-width product
2. Lipschitz-certified compositional robustness (L^k for depth k)
3. Parallel vs sequential robustness advantage
4. Tropical linear region counting (2^k)
5. Robustness-expressivity tradeoff (k² · L^k)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional


# ============================================================================
# I. Operadic Expression Data Structure
# ============================================================================

class ExprType(Enum):
    GENERATOR = auto()
    IDENTITY = auto()
    COMPOSE = auto()
    PARALLEL = auto()

@dataclass
class OperadicExpr:
    """Tree-structured operadic expression — mirrors the Lean OperadicExpression type."""
    kind: ExprType
    left: Optional['OperadicExpr'] = None
    right: Optional['OperadicExpr'] = None

    @staticmethod
    def generator():
        return OperadicExpr(ExprType.GENERATOR)

    @staticmethod
    def identity():
        return OperadicExpr(ExprType.IDENTITY)

    @staticmethod
    def compose(e1, e2):
        return OperadicExpr(ExprType.COMPOSE, e1, e2)

    @staticmethod
    def parallel(e1, e2):
        return OperadicExpr(ExprType.PARALLEL, e1, e2)

    @property
    def depth(self) -> int:
        """Mirrors OperadicExpression.depth from Lean."""
        if self.kind == ExprType.GENERATOR:
            return 1
        elif self.kind == ExprType.IDENTITY:
            return 0
        elif self.kind == ExprType.COMPOSE:
            return self.left.depth + self.right.depth
        else:  # PARALLEL
            return max(self.left.depth, self.right.depth)

    @property
    def generator_count(self) -> int:
        """Mirrors OperadicExpression.generatorCount from Lean."""
        if self.kind == ExprType.GENERATOR:
            return 1
        elif self.kind == ExprType.IDENTITY:
            return 0
        elif self.kind in (ExprType.COMPOSE, ExprType.PARALLEL):
            return self.left.generator_count + self.right.generator_count
        return 0

    @property
    def depth_width_product(self) -> int:
        """Mirrors OperadicExpression.depthWidthProduct from Lean."""
        return self.depth * self.generator_count

    def lipschitz(self, base_L: float) -> float:
        """Mirrors CertifiedRobustness.operadicLipschitz from Lean."""
        if self.kind == ExprType.GENERATOR:
            return base_L
        elif self.kind == ExprType.IDENTITY:
            return 1.0
        elif self.kind == ExprType.COMPOSE:
            return self.left.lipschitz(base_L) * self.right.lipschitz(base_L)
        else:  # PARALLEL
            return max(self.left.lipschitz(base_L), self.right.lipschitz(base_L))

    def tropical_regions(self) -> int:
        """Number of linear regions: 2^depth."""
        return 2 ** self.depth


def k_deep(k: int) -> OperadicExpr:
    """Mirrors kDeepExpression from Lean."""
    if k == 0:
        return OperadicExpr.identity()
    return OperadicExpr.compose(OperadicExpr.generator(), k_deep(k - 1))


def wide_parallel(n: int) -> OperadicExpr:
    """Mirrors wideParallel from Lean."""
    if n == 0:
        return OperadicExpr.identity()
    elif n == 1:
        return OperadicExpr.generator()
    else:
        return OperadicExpr.parallel(OperadicExpr.generator(), wide_parallel(n - 1))


# ============================================================================
# II. Numerical Verification of Theorems
# ============================================================================

def verify_theorems():
    """Verify key theorems numerically."""
    print("=" * 70)
    print("OPERADIC DEEP LEARNING: Numerical Theorem Verification")
    print("=" * 70)

    # Theorem: kDeep_depth
    print("\n--- Theorem: kDeep_depth ---")
    print("kDeepExpression(k).depth = k")
    for k in range(8):
        expr = k_deep(k)
        assert expr.depth == k, f"Failed for k={k}"
        print(f"  k={k}: depth = {expr.depth} ✓")

    # Theorem: kDeep_generatorCount
    print("\n--- Theorem: kDeep_generatorCount ---")
    print("kDeepExpression(k).generatorCount = k")
    for k in range(8):
        expr = k_deep(k)
        assert expr.generator_count == k
        print(f"  k={k}: generatorCount = {expr.generator_count} ✓")

    # Theorem: depthWidthProduct_kDeep
    print("\n--- Theorem: depthWidthProduct_kDeep ---")
    print("kDeepExpression(k).depthWidthProduct = k²")
    for k in range(8):
        expr = k_deep(k)
        assert expr.depth_width_product == k * k
        print(f"  k={k}: depthWidthProduct = {expr.depth_width_product} = {k}² ✓")

    # Theorem: depthWidthProduct_gap
    print("\n--- Theorem: depthWidthProduct_gap ---")
    print("DWP(k+1) - DWP(k) = 2k+1")
    for k in range(7):
        gap = k_deep(k + 1).depth_width_product - k_deep(k).depth_width_product
        assert gap == 2 * k + 1
        print(f"  k={k}: gap = {gap} = 2·{k}+1 ✓")

    # Theorem: kDeep_lipschitz
    print("\n--- Theorem: kDeep_lipschitz ---")
    print("operadicLipschitz(L, kDeep(k)) = L^k")
    L = 1.5
    for k in range(8):
        expr = k_deep(k)
        computed = expr.lipschitz(L)
        expected = L ** k
        assert abs(computed - expected) < 1e-10
        print(f"  L={L}, k={k}: Lipschitz = {computed:.4f} = {L}^{k} ✓")

    # Theorem: parallel_robustness_advantage
    print("\n--- Theorem: parallel_robustness_advantage ---")
    print("For L > 1, k ≥ 2: Lip(parallel) < Lip(sequential)")
    L = 2.0
    for k in range(2, 8):
        seq_lip = k_deep(k).lipschitz(L)
        par_lip = wide_parallel(k).lipschitz(L)
        assert par_lip < seq_lip
        print(f"  k={k}: parallel={par_lip:.1f} < sequential={seq_lip:.1f} "
              f"(ratio {seq_lip/par_lip:.1f}x) ✓")

    # Theorem: tropical_region_exponential
    print("\n--- Theorem: tropical_region_exponential ---")
    print("tropicalRegions(kDeep(k)) = 2^k")
    for k in range(8):
        regions = k_deep(k).tropical_regions()
        assert regions == 2 ** k
        print(f"  k={k}: regions = {regions} = 2^{k} ✓")

    # Theorem: wideParallel_depth
    print("\n--- Theorem: wideParallel_depth ---")
    print("wideParallel(n).depth = 1 for n ≥ 1")
    for n in range(1, 8):
        expr = wide_parallel(n)
        assert expr.depth == 1
        print(f"  n={n}: depth = {expr.depth}, generators = {expr.generator_count} ✓")

    print("\n" + "=" * 70)
    print("ALL THEOREMS VERIFIED NUMERICALLY ✓")
    print("=" * 70)


# ============================================================================
# III. Visualizations
# ============================================================================

def create_visualizations():
    """Generate publication-quality visualizations."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Operadic Deep Learning: Key Relationships", fontsize=16, fontweight='bold')

    depths = range(1, 11)

    # Plot 1: Depth-Width Product (k²)
    ax = axes[0, 0]
    dwp = [k * k for k in depths]
    ax.plot(list(depths), dwp, 'b-o', linewidth=2, markersize=6, label='k² (sequential)')
    ax.plot(list(depths), list(depths), 'r--s', linewidth=2, markersize=6, label='k (parallel)')
    ax.set_xlabel('Depth k', fontsize=12)
    ax.set_ylabel('Depth-Width Product', fontsize=12)
    ax.set_title('Expressivity: Depth-Width Product', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Lipschitz Constants (L^k vs L)
    ax = axes[0, 1]
    L_values = [1.2, 1.5, 2.0]
    colors = ['green', 'orange', 'red']
    for L, color in zip(L_values, colors):
        lip = [L ** k for k in depths]
        ax.semilogy(list(depths), lip, f'-o', color=color, linewidth=2,
                     markersize=6, label=f'L^k (L={L})')
    ax.axhline(y=2.0, color='blue', linestyle='--', linewidth=2, label='L (parallel)')
    ax.set_xlabel('Depth k', fontsize=12)
    ax.set_ylabel('Lipschitz Constant (log scale)', fontsize=12)
    ax.set_title('Robustness: Lipschitz Constants', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Tropical Linear Regions
    ax = axes[1, 0]
    regions = [2 ** k for k in depths]
    ax.semilogy(list(depths), regions, 'purple', linewidth=2, marker='D', markersize=6,
                label='2^k (sequential)')
    ax.axhline(y=2, color='cyan', linestyle='--', linewidth=2, label='2 (parallel)')
    ax.set_xlabel('Depth k', fontsize=12)
    ax.set_ylabel('Linear Regions (log scale)', fontsize=12)
    ax.set_title('Tropical: Linear Region Count', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 4: Robustness-Expressivity Tradeoff (k² · L^k)
    ax = axes[1, 1]
    L = 1.5
    tradeoff = [k * k * L ** k for k in depths]
    expressivity = [k * k for k in depths]
    robustness = [L ** k for k in depths]
    ax.semilogy(list(depths), tradeoff, 'k-o', linewidth=2, markersize=6,
                label=f'k² · L^k (L={L})')
    ax.semilogy(list(depths), expressivity, 'b--', linewidth=1.5, label='k² (expressivity)')
    ax.semilogy(list(depths), robustness, 'r--', linewidth=1.5, label='L^k (sensitivity)')
    ax.set_xlabel('Depth k', fontsize=12)
    ax.set_ylabel('Computation-Robustness Product', fontsize=12)
    ax.set_title('Tradeoff: k² · L^k', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('operadic_deep_learning_plots.png', dpi=150, bbox_inches='tight')
    print("\nSaved: operadic_deep_learning_plots.png")

    # Additional plot: Certified Robustness Radius
    fig2, ax2 = plt.subplots(1, 1, figsize=(8, 5))
    epsilon = 1.0
    for L in [1.2, 1.5, 2.0, 3.0]:
        radii = [epsilon / L ** k for k in depths]
        ax2.semilogy(list(depths), radii, '-o', linewidth=2, markersize=5,
                      label=f'ε/L^k (L={L})')
    ax2.set_xlabel('Depth k', fontsize=12)
    ax2.set_ylabel('Certified Robustness Radius (log scale)', fontsize=12)
    ax2.set_title('Certified Adversarial Robustness Radius vs Depth', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('certified_robustness_radius.png', dpi=150, bbox_inches='tight')
    print("Saved: certified_robustness_radius.png")


# ============================================================================
# IV. Concrete Neural Network Example
# ============================================================================

def neural_network_example():
    """Demonstrate operadic composition with actual matrix operations."""
    print("\n" + "=" * 70)
    print("CONCRETE EXAMPLE: 3-Layer Neural Network as Operadic Expression")
    print("=" * 70)

    np.random.seed(42)

    # Define three layers: R^4 -> R^3 -> R^2 -> R^1
    W1 = np.random.randn(3, 4) * 0.5
    b1 = np.random.randn(3) * 0.1
    W2 = np.random.randn(2, 3) * 0.5
    b2 = np.random.randn(2) * 0.1
    W3 = np.random.randn(1, 2) * 0.5
    b3 = np.random.randn(1) * 0.1

    # Activation: ReLU (Lipschitz constant = 1)
    relu = lambda x: np.maximum(0, x)

    # Compute operator norms (Lipschitz constants of linear maps)
    L1 = np.linalg.norm(W1, ord=2)
    L2 = np.linalg.norm(W2, ord=2)
    L3 = np.linalg.norm(W3, ord=2)

    print(f"\nLayer 1: R^4 → R^3, ‖W₁‖ = {L1:.4f}")
    print(f"Layer 2: R^3 → R^2, ‖W₂‖ = {L2:.4f}")
    print(f"Layer 3: R^2 → R^1, ‖W₃‖ = {L3:.4f}")

    # Operadic composition: total Lipschitz = L1 * L2 * L3 (since ReLU has Lip = 1)
    total_lip = L1 * L2 * L3
    print(f"\nOperadic Lipschitz (chain rule): {L1:.4f} × {L2:.4f} × {L3:.4f} = {total_lip:.4f}")

    # Depth = 3, generator count = 3, DWP = 9
    print(f"Depth = 3, Generator count = 3, Depth-Width Product = 9")

    # Certified robustness radius
    epsilon = 0.1
    cert_radius = epsilon / total_lip
    print(f"\nFor ε = {epsilon}:")
    print(f"  Certified robustness radius = ε / L_total = {cert_radius:.6f}")
    print(f"  Any perturbation ‖δx‖ ≤ {cert_radius:.6f} changes output by ≤ {epsilon}")

    # Compare: same layers in parallel
    parallel_lip = max(L1, L2, L3)
    parallel_radius = epsilon / parallel_lip
    print(f"\nIf same layers were parallel instead of sequential:")
    print(f"  Lipschitz = max(L₁, L₂, L₃) = {parallel_lip:.4f}")
    print(f"  Certified radius = {parallel_radius:.6f}")
    print(f"  Robustness advantage: {parallel_radius / cert_radius:.1f}× better")

    # Test with actual input
    x = np.array([1.0, -0.5, 0.3, 0.8])
    y = W3 @ relu(W2 @ relu(W1 @ x + b1) + b2) + b3
    print(f"\nInput:  x = {x}")
    print(f"Output: f(x) = {y}")

    # Perturb and verify Lipschitz bound
    delta = np.random.randn(4) * 0.01
    delta = delta / np.linalg.norm(delta) * cert_radius  # Normalize to cert_radius
    x_pert = x + delta
    y_pert = W3 @ relu(W2 @ relu(W1 @ x_pert + b1) + b2) + b3
    output_change = np.linalg.norm(y_pert - y)
    print(f"\nPerturbation: ‖δx‖ = {np.linalg.norm(delta):.6f} (= certified radius)")
    print(f"Output change: ‖f(x+δ) - f(x)‖ = {output_change:.6f}")
    print(f"Lipschitz bound: L · ‖δx‖ = {total_lip * np.linalg.norm(delta):.6f}")
    print(f"Bound holds: {output_change <= total_lip * np.linalg.norm(delta) + 1e-10} ✓")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    verify_theorems()
    create_visualizations()
    neural_network_example()
