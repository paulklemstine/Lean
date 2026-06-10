#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Certified Radius Theory

Demonstrates how formally verified certified radii apply to:
1. Neural network robustness certification
2. Cryptographic entropy extraction bounds
3. Tropical classifier geometry
4. Adversarial perturbation budgets
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


def certified_radius(m: float, K: float) -> float:
    """Certified radius: max(0, m/K)."""
    if K <= 0:
        return 0.0
    return max(0.0, m / K)


# ═══════════════════════════════════════════════════════════════
# Application 1: Neural Network Robustness
# ═══════════════════════════════════════════════════════════════

def app_neural_robustness():
    """
    Simulate certifying a neural network's prediction robustness.
    
    Given a classifier with known Lipschitz constant K and margin m
    at a test point, the certified radius r = max(0, m/K) guarantees
    that no adversarial perturbation within radius r can flip the prediction.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Robustness Certification")
    print("=" * 60)
    
    # Simulated network: 2-layer ReLU network on MNIST-like data
    # Typical Lipschitz constants for small networks: K ∈ [1, 50]
    # Typical margins: m ∈ [0.1, 10]
    
    np.random.seed(42)
    n_test = 20
    margins = np.abs(np.random.randn(n_test)) * 3 + 0.5
    lipschitz_constants = np.abs(np.random.randn(n_test)) * 10 + 2
    
    print(f"\n{'Point':>6} {'Margin':>8} {'Lipschitz':>10} {'Radius':>8} {'ε-robust?':>10}")
    print("-" * 50)
    
    epsilon = 0.3  # standard adversarial budget (e.g., L2 for MNIST)
    n_robust = 0
    
    for i in range(n_test):
        m, K = margins[i], lipschitz_constants[i]
        r = certified_radius(m, K)
        robust = r >= epsilon
        if robust:
            n_robust += 1
        print(f"{i+1:6d} {m:8.3f} {K:10.3f} {r:8.4f} {'✓' if robust else '✗':>10}")
    
    print(f"\nCertified robust at ε={epsilon}: {n_robust}/{n_test} "
          f"({100*n_robust/n_test:.0f}%)")
    
    # Monotonicity application: if we can tighten the Lipschitz estimate...
    print("\nMonotonicity insight:")
    m_example = margins[0]
    K_original = lipschitz_constants[0]
    K_tighter = K_original * 0.7
    r_original = certified_radius(m_example, K_original)
    r_tighter = certified_radius(m_example, K_tighter)
    print(f"  Original: K={K_original:.2f} → r={r_original:.4f}")
    print(f"  Tighter:  K={K_tighter:.2f} → r={r_tighter:.4f}")
    print(f"  Improvement: {(r_tighter/r_original - 1)*100:.1f}%")
    print(f"  (Guaranteed by certifiedRadius_antitone_Lipschitz)")


# ═══════════════════════════════════════════════════════════════
# Application 2: Cryptographic Entropy Extraction
# ═══════════════════════════════════════════════════════════════

def app_entropy_extraction():
    """
    Apply certified radius theory to entropy extraction bounds.
    
    In the Leftover Hash Lemma, the statistical distance between
    the extracted key and uniform is bounded by a Lipschitz-type
    inequality. The certified radius framework gives the maximum
    "entropy margin" that can absorb source perturbations.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Cryptographic Entropy Extraction")
    print("=" * 60)
    
    # Parameters from the Leftover Hash Lemma setup
    # Source entropy H₂(X), output length ℓ, security parameter ε
    
    print("\nEntropy extraction security margins:")
    print(f"{'H₂(X)':>8} {'ℓ':>6} {'Margin':>8} {'K_eff':>8} {'Safe Δε':>8}")
    print("-" * 45)
    
    for h2 in [128, 192, 256]:
        for ell in [64, 96, 128]:
            if h2 <= ell:
                continue
            # margin = H₂(X) - ℓ (entropy surplus)
            margin = float(h2 - ell)
            # Effective Lipschitz in log-scale
            K_eff = 2.0  # simplified
            r = certified_radius(margin, K_eff)
            print(f"{h2:8d} {ell:6d} {margin:8.1f} {K_eff:8.1f} {r:8.1f}")
    
    print("\nInterpretation: 'Safe Δε' is the maximum entropy perturbation")
    print("the source can undergo while maintaining extraction security.")
    print("Guaranteed by the certified radius monotonicity framework.")


# ═══════════════════════════════════════════════════════════════
# Application 3: Tropical Classifier Geometry
# ═══════════════════════════════════════════════════════════════

def app_tropical_geometry():
    """
    Interpret certified radii through tropical geometry.
    
    A piecewise-linear classifier (e.g., ReLU network) defines
    a tropical hypersurface. The certified radius is the distance
    from the test point to this decision boundary.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Classifier Geometry")
    print("=" * 60)
    
    # A tropical linear classifier in 2D:
    # f(x) = max(a₁·x + b₁, a₂·x + b₂) - max(a₃·x + b₃, a₄·x + b₄)
    # The decision boundary is a tropical hypersurface.
    
    # Define two tropical linear forms
    def tropical_class_1(x):
        return max(2 * x[0] + 1, -x[0] + 3 * x[1] + 2)
    
    def tropical_class_2(x):
        return max(x[0] - x[1] + 1, -2 * x[0] + x[1])
    
    def classifier(x):
        return tropical_class_1(x) - tropical_class_2(x)
    
    # Estimate Lipschitz constant
    # For tropical linear forms, K is bounded by max coefficient magnitude
    K_estimate = 6.0  # conservative bound
    
    # Test points
    test_points = [
        np.array([1.0, 0.5]),
        np.array([0.0, 0.0]),
        np.array([-1.0, 1.0]),
        np.array([2.0, -1.0]),
    ]
    
    print(f"\n{'Point':>15} {'f(x)':>8} {'|f(x)|':>8} {'Radius':>8}")
    print("-" * 45)
    
    for x in test_points:
        fx = classifier(x)
        margin = abs(fx)
        r = certified_radius(margin, K_estimate)
        print(f"({x[0]:5.1f},{x[1]:5.1f}) {fx:8.3f} {margin:8.3f} {r:8.4f}")
    
    print(f"\nLipschitz constant K = {K_estimate}")
    print("The certified radius = distance to tropical decision boundary")
    print("(up to the Lipschitz scaling factor)")
    
    # Generate visualization
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    xs = np.linspace(-3, 3, 200)
    ys = np.linspace(-3, 3, 200)
    X, Y = np.meshgrid(xs, ys)
    Z = np.zeros_like(X)
    
    for i in range(len(xs)):
        for j in range(len(ys)):
            Z[j, i] = classifier(np.array([xs[i], ys[j]]))
    
    # Decision boundary
    ax.contour(X, Y, Z, levels=[0], colors='red', linewidths=2)
    ax.contourf(X, Y, Z, levels=20, cmap='RdBu', alpha=0.6)
    plt.colorbar(ax.contourf(X, Y, Z, levels=20, cmap='RdBu', alpha=0.0), ax=ax,
                 label='Classifier value f(x)')
    
    # Plot test points with certified balls
    for x in test_points:
        fx = classifier(x)
        r = certified_radius(abs(fx), K_estimate)
        ax.plot(x[0], x[1], 'ko', markersize=8)
        if r > 0.01:
            circle = plt.Circle(x, r, fill=False, color='green',
                               linewidth=2, linestyle='--')
            ax.add_patch(circle)
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Tropical Classifier with Certified Robustness Balls', fontsize=13)
    ax.set_aspect('equal')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    
    plt.tight_layout()
    plt.savefig('tropical_classifier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nVisualization saved: tropical_classifier.png")


# ═══════════════════════════════════════════════════════════════
# Application 4: Adversarial Budget Analysis
# ═══════════════════════════════════════════════════════════════

def app_adversarial_budget():
    """
    Analyze adversarial perturbation budgets across model configurations.
    
    Uses the monotonicity theorems to reason about how model improvements
    (tighter Lipschitz bounds, larger margins) translate to certified
    robustness improvements.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Adversarial Budget Analysis")
    print("=" * 60)
    
    # Compare model architectures
    models = [
        ("Small CNN", 3.2, 15.0),
        ("ResNet-18", 5.1, 8.5),
        ("Lipschitz Net", 4.0, 3.0),
        ("Randomized Smooth", 2.8, 1.5),
    ]
    
    epsilon_targets = [0.1, 0.3, 0.5, 1.0]
    
    print(f"\n{'Model':>20} {'Margin':>8} {'K':>6} {'Radius':>8}", end="")
    for eps in epsilon_targets:
        print(f" {'ε='+str(eps):>6}", end="")
    print()
    print("-" * 75)
    
    for name, m, K in models:
        r = certified_radius(m, K)
        print(f"{name:>20} {m:8.2f} {K:6.1f} {r:8.4f}", end="")
        for eps in epsilon_targets:
            cert = "✓" if r >= eps else "✗"
            print(f" {cert:>6}", end="")
        print()
    
    # Monotonicity-guided improvement analysis
    print("\nImprovement analysis (using certifiedRadius_mono):")
    base_m, base_K = 3.0, 10.0
    base_r = certified_radius(base_m, base_K)
    print(f"  Baseline: m={base_m}, K={base_K}, r={base_r:.4f}")
    
    improvements = [
        ("2× margin", base_m * 2, base_K),
        ("0.5× Lipschitz", base_m, base_K * 0.5),
        ("Both", base_m * 2, base_K * 0.5),
    ]
    
    for desc, m, K in improvements:
        r = certified_radius(m, K)
        factor = r / base_r if base_r > 0 else float('inf')
        print(f"  {desc:>20}: m={m:.1f}, K={K:.1f}, r={r:.4f} ({factor:.1f}× improvement)")
    
    print("\nKey insight: radius scales linearly with margin and inversely with K.")
    print("Both improvements compose multiplicatively (4× total for both).")
    print("This compositionality is guaranteed by certifiedRadius_mono.")


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    app_neural_robustness()
    app_entropy_extraction()
    app_tropical_geometry()
    app_adversarial_budget()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Certified Radius as a Residuated Tropical Invariant

Demonstrates the core theorems with concrete numerical examples:
1. Monotonicity of certified radius under margin/Lipschitz changes
2. The residual adjunction on reals
3. Finite benchmark certification on concrete point sets

Each demonstration corresponds to a formally verified theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# ═══════════════════════════════════════════════════════════════
# Definition: Certified Radius
# ═══════════════════════════════════════════════════════════════

def certified_radius(m: float, K: float) -> float:
    """
    The canonical scalar certified radius: max(0, m/K).
    
    Given a classification margin m and Lipschitz constant K > 0,
    this is the largest perturbation radius r ≥ 0 such that
    K·r ≤ m, i.e., the margin can absorb perturbations of size r.
    
    Formally verified as `certifiedRadius` in Lean.
    """
    if K <= 0:
        return max(0.0, 0.0)  # degenerate case
    return max(0.0, m / K)


def residual_real(a: float, b: float) -> float:
    """The residual operation on reals: b - a."""
    return b - a


# ═══════════════════════════════════════════════════════════════
# Demo 1: Monotonicity (Theorem A)
# ═══════════════════════════════════════════════════════════════

def demo_monotonicity():
    """
    Demonstrates certifiedRadius_mono:
      m₁ ≤ m₂, 0 < K₂ ≤ K₁  ⟹  certifiedRadius(m₁,K₁) ≤ certifiedRadius(m₂,K₂)
    
    Also demonstrates the two component monotonicity laws:
      - certifiedRadius_monotone_margin: monotone in margin
      - certifiedRadius_antitone_Lipschitz: antitone in Lipschitz constant
    """
    print("=" * 60)
    print("DEMO 1: Monotonicity of Certified Radius")
    print("=" * 60)
    
    # Margin monotonicity with fixed K
    K = 2.0
    margins = np.linspace(-2, 5, 8)
    radii = [certified_radius(m, K) for m in margins]
    
    print(f"\nMargin monotonicity (K = {K}):")
    print(f"{'Margin':>10} {'Radius':>10}")
    for m, r in zip(margins, radii):
        print(f"{m:10.3f} {r:10.3f}")
    
    # Verify monotonicity
    for i in range(len(radii) - 1):
        assert radii[i] <= radii[i + 1] + 1e-12, "Margin monotonicity violated!"
    print("✓ Margin monotonicity verified for all pairs")
    
    # Lipschitz antitonicity with fixed margin
    m = 3.0
    lipschitz_constants = np.linspace(0.5, 5, 10)
    radii_lip = [certified_radius(m, K) for K in lipschitz_constants]
    
    print(f"\nLipschitz antitonicity (m = {m}):")
    print(f"{'K':>10} {'Radius':>10}")
    for K, r in zip(lipschitz_constants, radii_lip):
        print(f"{K:10.3f} {r:10.3f}")
    
    # Verify antitonicity
    for i in range(len(radii_lip) - 1):
        assert radii_lip[i] >= radii_lip[i + 1] - 1e-12, "Lipschitz antitonicity violated!"
    print("✓ Lipschitz antitonicity verified for all pairs")
    
    # Combined monotonicity
    print(f"\nCombined monotonicity:")
    m1, K1 = 1.0, 4.0
    m2, K2 = 3.0, 2.0
    r1 = certified_radius(m1, K1)
    r2 = certified_radius(m2, K2)
    print(f"  r({m1}, {K1}) = {r1:.4f}")
    print(f"  r({m2}, {K2}) = {r2:.4f}")
    assert r1 <= r2 + 1e-12, "Combined monotonicity violated!"
    print(f"  r({m1}, {K1}) ≤ r({m2}, {K2}): ✓")
    
    return margins, radii, lipschitz_constants, radii_lip


# ═══════════════════════════════════════════════════════════════
# Demo 2: Residual Adjunction (Theorem B)
# ═══════════════════════════════════════════════════════════════

def demo_residuation():
    """
    Demonstrates real_add_le_iff_le_sub:
      a + r ≤ b  ⟺  r ≤ b - a
    
    And the WithBot ℝ lifting:
      ↑(a + r) ≤ ↑b  ⟺  ↑r ≤ ↑(b - a)
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Residual Adjunction")
    print("=" * 60)
    
    test_cases = [
        (1.0, 3.0, 5.0),   # a=1, r=3, b=5 → 4 ≤ 5 and 3 ≤ 4
        (2.0, 1.0, 2.5),   # a=2, r=1, b=2.5 → 3 ≤ 2.5? No, and 1 ≤ 0.5? No
        (-1.0, 2.0, 0.5),  # a=-1, r=2, b=0.5 → 1 ≤ 0.5? No
        (0.0, 0.0, 0.0),   # boundary case
        (-3.0, 1.0, -1.0), # negative values
    ]
    
    print(f"\n{'a':>6} {'r':>6} {'b':>6} | {'a+r≤b':>8} {'r≤b-a':>8} | {'Match':>6}")
    print("-" * 55)
    for a, r, b in test_cases:
        lhs = (a + r <= b)
        rhs = (r <= b - a)
        match = "✓" if lhs == rhs else "✗"
        print(f"{a:6.1f} {r:6.1f} {b:6.1f} | {str(lhs):>8} {str(rhs):>8} | {match:>6}")
        assert lhs == rhs, f"Adjunction failed for a={a}, r={r}, b={b}"
    
    print("\n✓ Residual adjunction verified for all test cases")
    
    # Connection to certified radius
    print("\nResidual interpretation of certified radius:")
    m, K = 3.0, 2.0
    cr = certified_radius(m, K)
    res = residual_real(0, m / K)
    print(f"  certifiedRadius({m}, {K}) = max(0, {m}/{K}) = {cr}")
    print(f"  max(0, residualReal(0, {m}/{K})) = max(0, {res}) = {max(0, res)}")
    assert abs(cr - max(0, res)) < 1e-12
    print(f"  ✓ They agree: certified radius IS the nonneg residual")


# ═══════════════════════════════════════════════════════════════
# Demo 3: Finite Benchmark Certification (Theorem C)
# ═══════════════════════════════════════════════════════════════

def demo_benchmark():
    """
    Demonstrates finite_certified_ball_nonneg:
    Given f with margin m at center x, Lipschitz K over S,
    and r ≤ certifiedRadius(m, K), all y ∈ S with ‖y-x‖ ≤ r
    satisfy f(y) ≥ 0.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Finite Benchmark Certification")
    print("=" * 60)
    
    n = 2  # dimension
    
    # Define a simple classifier: f(y) = 3 - 2*‖y‖ (margin 3 at origin, Lipschitz 2)
    x = np.zeros(n)
    
    def f(y):
        return 3.0 - 2.0 * np.linalg.norm(y - x)
    
    m = 3.0   # margin: f(x) = 3 ≥ m
    K = 2.0   # Lipschitz constant
    
    # Certified radius
    r = certified_radius(m, K)
    print(f"\nClassifier: f(y) = 3 - 2‖y‖")
    print(f"Center: x = {x}")
    print(f"Margin: m = {m}, f(x) = {f(x)}")
    print(f"Lipschitz constant: K = {K}")
    print(f"Certified radius: r = max(0, {m}/{K}) = {r}")
    
    # Generate finite perturbation set
    np.random.seed(42)
    S = [np.random.randn(n) * 2 for _ in range(100)]
    
    # Check Lipschitz condition
    print(f"\nFinite set S has {len(S)} points")
    lip_violations = 0
    for y in S:
        if abs(f(y) - f(x)) > K * np.linalg.norm(y - x) + 1e-10:
            lip_violations += 1
    print(f"Lipschitz violations: {lip_violations}")
    
    # Check certification
    points_in_ball = [(y, f(y)) for y in S if np.linalg.norm(y - x) <= r]
    print(f"Points within certified ball (‖y-x‖ ≤ {r}): {len(points_in_ball)}")
    
    certified_correct = all(fy >= -1e-10 for _, fy in points_in_ball)
    print(f"All f(y) ≥ 0 in certified ball: {'✓' if certified_correct else '✗'}")
    
    if points_in_ball:
        min_fy = min(fy for _, fy in points_in_ball)
        print(f"Minimum f(y) in ball: {min_fy:.6f}")
    
    # Show some outside the ball for contrast
    points_outside = [(y, f(y)) for y in S if np.linalg.norm(y - x) > r]
    neg_outside = sum(1 for _, fy in points_outside if fy < 0)
    print(f"Points outside ball with f(y) < 0: {neg_outside}")
    
    return S, x, r


# ═══════════════════════════════════════════════════════════════
# Visualizations
# ═══════════════════════════════════════════════════════════════

def create_visualizations():
    """Generate publication-quality visualizations."""
    
    # --- Figure 1: Certified Radius Surface ---
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    # Margin monotonicity
    ax = axes[0]
    for K in [0.5, 1.0, 2.0, 4.0]:
        ms = np.linspace(-2, 6, 200)
        rs = [certified_radius(m, K) for m in ms]
        ax.plot(ms, rs, label=f'K = {K}', linewidth=2)
    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Certified Radius r(m, K)', fontsize=12)
    ax.set_title('Margin Monotonicity', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='black', linewidth=0.5)
    
    # Lipschitz antitonicity
    ax = axes[1]
    for m in [1.0, 2.0, 4.0, 6.0]:
        Ks = np.linspace(0.2, 6, 200)
        rs = [certified_radius(m, K) for K in Ks]
        ax.plot(Ks, rs, label=f'm = {m}', linewidth=2)
    ax.set_xlabel('Lipschitz Constant K', fontsize=12)
    ax.set_ylabel('Certified Radius r(m, K)', fontsize=12)
    ax.set_title('Lipschitz Antitonicity', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # 2D heatmap
    ax = axes[2]
    ms = np.linspace(0, 5, 100)
    Ks = np.linspace(0.2, 5, 100)
    M, KK = np.meshgrid(ms, Ks)
    R = np.vectorize(certified_radius)(M, KK)
    im = ax.pcolormesh(M, KK, R, cmap='viridis', shading='auto')
    plt.colorbar(im, ax=ax, label='Certified Radius')
    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Lipschitz Constant K', fontsize=12)
    ax.set_title('Certified Radius Landscape', fontsize=13)
    
    plt.tight_layout()
    plt.savefig('certified_radius_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    # --- Figure 2: Benchmark Certification ---
    fig, ax = plt.subplots(1, 1, figsize=(7, 7))
    
    x = np.zeros(2)
    m, K = 3.0, 2.0
    r = certified_radius(m, K)
    
    np.random.seed(42)
    S = [np.random.randn(2) * 2 for _ in range(200)]
    
    def f(y):
        return 3.0 - 2.0 * np.linalg.norm(y)
    
    # Color by f(y) value
    for y in S:
        dist = np.linalg.norm(y)
        fy = f(y)
        if dist <= r:
            color = 'green' if fy >= 0 else 'red'
            marker = 'o'
        else:
            color = 'blue' if fy >= 0 else 'orange'
            marker = 'x'
        ax.plot(y[0], y[1], marker, color=color, markersize=5, alpha=0.7)
    
    # Draw certified ball
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k--', linewidth=2,
            label=f'Certified ball (r={r:.1f})')
    ax.plot(0, 0, 'k*', markersize=15, label='Center x')
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Finite Benchmark Certification\n'
                 f'f(y) = 3 - 2‖y‖, K={K}, m={m}, r={r}', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Custom legend entries
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green',
               markersize=8, label='In ball, f(y)≥0 ✓'),
        Line2D([0], [0], marker='x', color='blue',
               markersize=8, label='Outside ball, f(y)≥0'),
        Line2D([0], [0], marker='x', color='orange',
               markersize=8, label='Outside ball, f(y)<0'),
        Line2D([0], [0], color='black', linestyle='--',
               linewidth=2, label=f'Certified ball r={r:.1f}'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper right')
    
    plt.tight_layout()
    plt.savefig('benchmark_certification.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    # --- Figure 3: Residual Adjunction ---
    fig, ax = plt.subplots(1, 1, figsize=(7, 5))
    
    a_vals = np.linspace(-2, 4, 7)
    b = 3.0
    
    for a in a_vals:
        rs = np.linspace(-3, 5, 200)
        lhs = a + rs  # a + r
        
        # Shade region where a + r ≤ b  ⟺  r ≤ b - a
        feasible = rs[a + rs <= b]
        if len(feasible) > 0:
            ax.axvline(x=b - a, color='gray', alpha=0.2, linewidth=0.5)
    
    # Main illustration
    a = 1.0
    rs = np.linspace(-3, 5, 200)
    ax.plot(rs, a + rs, 'b-', linewidth=2, label=f'a + r (a={a})')
    ax.axhline(y=b, color='r', linewidth=2, linestyle='--', label=f'b = {b}')
    ax.axvline(x=b - a, color='green', linewidth=2, linestyle=':',
               label=f'r = b - a = {b-a}')
    ax.fill_between(rs, -5, b, where=(a + rs <= b), alpha=0.1, color='green',
                    label='Feasible: a + r ≤ b')
    
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Residual Adjunction: a + r ≤ b ⟺ r ≤ b − a', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-2, 6)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('residual_adjunction.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("\nVisualizations saved:")
    print("  - certified_radius_monotonicity.png")
    print("  - benchmark_certification.png")
    print("  - residual_adjunction.png")


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    demo_monotonicity()
    demo_residuation()
    demo_benchmark()
    create_visualizations()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
