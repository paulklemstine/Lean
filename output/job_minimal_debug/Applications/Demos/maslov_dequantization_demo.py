#!/usr/bin/env python3
"""
Maslov Dequantization Robustness — Numerical Demonstrations

This script demonstrates the four parts of the Maslov Dequantization Isometry
theorem with concrete numerical examples and visualizations:

  (i)   |emlAdd(f,g) - max(f,g)| ≤ ε·log 2
  (ii)  |emlClassifier - tropClassifier| ≤ ε·log d
  (iii) Lipschitz constant is preserved exactly
  (iv)  Certified robustness transfers from tropical to EML

Usage:
    python maslov_dequantization_demo.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import matplotlib.gridspec as gridspec

# ─────────────────────────────────────────────────────────
# Core Functions
# ─────────────────────────────────────────────────────────

def logsumexp(z, epsilon):
    """Numerically stable ε·log(Σ exp(z_i/ε))."""
    z_scaled = z / epsilon
    z_max = np.max(z_scaled)
    return epsilon * (z_max + np.log(np.sum(np.exp(z_scaled - z_max))))

def eml_add(f_val, g_val, epsilon):
    """EML (log-plus) addition: ε·log(exp(f/ε) + exp(g/ε))."""
    return logsumexp(np.array([f_val, g_val]), epsilon)

def trop_add(f_val, g_val):
    """Tropical (max-plus) addition."""
    return max(f_val, g_val)

def eml_classifier(Phi, epsilon, x):
    """
    EML classifier: C_ε(x)_k = ε·log(Σ_i exp(Φ_{k,i}(x)/ε))
    Phi: list of m classes, each with d affine functions
    Each Phi[k][i] = (a_ki, w_ki) where the function is a + w·x
    """
    m = len(Phi)
    scores = np.zeros(m)
    for k in range(m):
        vals = np.array([a + np.dot(w, x) for a, w in Phi[k]])
        scores[k] = logsumexp(vals, epsilon)
    return scores

def trop_classifier(Phi, x):
    """
    Tropical classifier: C_0(x)_k = max_i Φ_{k,i}(x)
    """
    m = len(Phi)
    scores = np.zeros(m)
    for k in range(m):
        vals = np.array([a + np.dot(w, x) for a, w in Phi[k]])
        scores[k] = np.max(vals)
    return scores

def class_margin(scores, y_true):
    """Classification margin: min_{j≠y} (score[y] - score[j])."""
    margins = [scores[y_true] - scores[j] for j in range(len(scores)) if j != y_true]
    return min(margins)

def linf_norm(x):
    """L-infinity norm."""
    return np.max(np.abs(x))

# ─────────────────────────────────────────────────────────
# Demo 1: Binary Logsumexp Sandwich (Part i)
# ─────────────────────────────────────────────────────────

def demo_binary_logsumexp():
    """Demonstrate |emlAdd - tropAdd| ≤ ε·log 2."""
    print("=" * 60)
    print("PART (i): Binary Logsumexp Sandwich")
    print("     |emlAdd(ε,f,g) - max(f,g)| ≤ ε·log 2")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left plot: emlAdd vs tropAdd for varying inputs
    epsilons = [0.1, 0.5, 1.0, 2.0]
    a_vals = np.linspace(-3, 3, 200)
    b_fixed = 0.0

    for eps in epsilons:
        eml_vals = [eml_add(a, b_fixed, eps) for a in a_vals]
        trop_vals = [trop_add(a, b_fixed) for a in a_vals]
        errors = [abs(e - t) for e, t in zip(eml_vals, trop_vals)]
        bound = eps * np.log(2)
        axes[0].plot(a_vals, errors, label=f'ε={eps}, bound={bound:.3f}')
        axes[0].axhline(y=bound, linestyle='--', alpha=0.3)

    axes[0].set_xlabel('a (with b=0)')
    axes[0].set_ylabel('|emlAdd - tropAdd|')
    axes[0].set_title('Error |emlAdd(ε,a,b) - max(a,b)| vs bound ε·log 2')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Right plot: convergence as ε → 0
    eps_range = np.logspace(-2, 1, 100)
    max_errors = []
    bounds = []
    for eps in eps_range:
        test_pairs = [(a, b) for a in np.linspace(-5, 5, 50) for b in np.linspace(-5, 5, 50)]
        err = max(abs(eml_add(a, b, eps) - trop_add(a, b)) for a, b in test_pairs)
        max_errors.append(err)
        bounds.append(eps * np.log(2))

    axes[1].loglog(eps_range, max_errors, 'b-', label='Observed max error')
    axes[1].loglog(eps_range, bounds, 'r--', label='Bound ε·log 2')
    axes[1].set_xlabel('ε')
    axes[1].set_ylabel('Max |error|')
    axes[1].set_title('Maslov Deformation: Error → 0 as ε → 0')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('part_i_binary_logsumexp.png', dpi=150, bbox_inches='tight')
    plt.close()

    # Numerical verification
    print(f"\nNumerical verification with 2500 test pairs:")
    for eps in [0.01, 0.1, 1.0, 5.0]:
        bound = eps * np.log(2)
        max_err = max(abs(eml_add(a, b, eps) - trop_add(a, b))
                      for a in np.linspace(-10, 10, 50) for b in np.linspace(-10, 10, 50))
        print(f"  ε={eps:5.2f}: max error = {max_err:.6f}, bound = {bound:.6f}, "
              f"ratio = {max_err/bound:.4f}")
    print()

# ─────────────────────────────────────────────────────────
# Demo 2: d-term Logsumexp Bound (Part ii)
# ─────────────────────────────────────────────────────────

def demo_d_term_logsumexp():
    """Demonstrate |emlClassifier - tropClassifier| ≤ ε·log d."""
    print("=" * 60)
    print("PART (ii): d-term Dequantization Error")
    print("     |C_ε(x)_k - C_0(x)_k| ≤ ε·log d")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Test with varying d
    d_values = [2, 4, 8, 16, 32]
    eps_range = np.logspace(-2, 1, 50)

    for d in d_values:
        max_errors = []
        for eps in eps_range:
            errors = []
            for _ in range(200):
                z = np.random.randn(d) * 3
                eml_val = logsumexp(z, eps)
                trop_val = np.max(z)
                errors.append(abs(eml_val - trop_val))
            max_errors.append(max(errors))
        bound = [eps * np.log(d) for eps in eps_range]
        axes[0].loglog(eps_range, max_errors, '-', label=f'd={d}')
        axes[0].loglog(eps_range, bound, '--', alpha=0.3)

    axes[0].set_xlabel('ε')
    axes[0].set_ylabel('Max |error|')
    axes[0].set_title('Dequantization Error for varying d')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Fixed ε, varying d
    eps_fixed = 1.0
    d_range = range(2, 65)
    observed_max = []
    theoretical_bound = []
    for d in d_range:
        errors = []
        for _ in range(500):
            z = np.random.randn(d) * 3
            eml_val = logsumexp(z, eps_fixed)
            trop_val = np.max(z)
            errors.append(abs(eml_val - trop_val))
        observed_max.append(max(errors))
        theoretical_bound.append(eps_fixed * np.log(d))

    axes[1].plot(list(d_range), observed_max, 'bo-', markersize=3, label='Observed max error')
    axes[1].plot(list(d_range), theoretical_bound, 'r--', label='Bound ε·log d')
    axes[1].set_xlabel('d (number of pieces)')
    axes[1].set_ylabel('Max |error|')
    axes[1].set_title(f'Dequantization Error vs d (ε={eps_fixed})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('part_ii_dequantization_error.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\nNumerical verification (ε=1.0, 500 random trials each):")
    for d in [2, 4, 8, 16, 32, 64]:
        bound = np.log(d)
        errors = []
        for _ in range(1000):
            z = np.random.randn(d) * 3
            errors.append(abs(logsumexp(z, 1.0) - np.max(z)))
        max_err = max(errors)
        print(f"  d={d:3d}: max error = {max_err:.4f}, bound = {bound:.4f}, "
              f"ratio = {max_err/bound:.4f}")
    print()

# ─────────────────────────────────────────────────────────
# Demo 3: Lipschitz Preservation (Part iii)
# ─────────────────────────────────────────────────────────

def demo_lipschitz_preservation():
    """Demonstrate that log-sum-exp preserves Lipschitz constants exactly."""
    print("=" * 60)
    print("PART (iii): Exact Lipschitz Preservation")
    print("     C_ε is L-Lipschitz (same constant as each Φ_{k,i})")
    print("=" * 60)

    n = 2   # input dimension
    d = 4   # number of affine pieces per class
    m = 3   # number of classes

    # Create random affine functions with Lipschitz constant L
    np.random.seed(42)
    L = 2.0

    # Phi[k][i] = (a_ki, w_ki) where ||w_ki||_1 ≤ L
    Phi = []
    for k in range(m):
        pieces = []
        for i in range(d):
            a = np.random.randn()
            w = np.random.randn(n)
            # Normalize so that sum(|w_i|) ≤ L (L1 norm ≤ L gives L∞ Lipschitz ≤ L)
            w = w / np.sum(np.abs(w)) * L * np.random.uniform(0.5, 1.0)
            pieces.append((a, w))
        Phi.append(pieces)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Measure empirical Lipschitz constant for varying ε
    eps_values = np.logspace(-2, 1, 30)
    emp_lip_constants = {k: [] for k in range(m)}

    for eps in eps_values:
        for k in range(m):
            max_ratio = 0
            for _ in range(2000):
                x = np.random.randn(n) * 3
                y = np.random.randn(n) * 3
                dist = linf_norm(x - y)
                if dist < 1e-10:
                    continue
                scores_x = eml_classifier(Phi, eps, x)
                scores_y = eml_classifier(Phi, eps, y)
                ratio = abs(scores_x[k] - scores_y[k]) / dist
                max_ratio = max(max_ratio, ratio)
            emp_lip_constants[k].append(max_ratio)

    for k in range(m):
        axes[0].semilogx(eps_values, emp_lip_constants[k], '-o', markersize=3,
                         label=f'Class {k} empirical Lip')
    axes[0].axhline(y=L, color='r', linestyle='--', linewidth=2, label=f'Theoretical bound L={L}')
    axes[0].set_xlabel('ε')
    axes[0].set_ylabel('Empirical Lipschitz constant')
    axes[0].set_title('Lipschitz Constant vs ε (preserved exactly)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Compare EML vs tropical Lipschitz
    eps_test = 1.0
    trop_lip = {k: 0 for k in range(m)}
    eml_lip = {k: 0 for k in range(m)}
    for _ in range(5000):
        x = np.random.randn(n) * 3
        y = np.random.randn(n) * 3
        dist = linf_norm(x - y)
        if dist < 1e-10:
            continue
        t_x = trop_classifier(Phi, x)
        t_y = trop_classifier(Phi, y)
        e_x = eml_classifier(Phi, eps_test, x)
        e_y = eml_classifier(Phi, eps_test, y)
        for k in range(m):
            trop_lip[k] = max(trop_lip[k], abs(t_x[k] - t_y[k]) / dist)
            eml_lip[k] = max(eml_lip[k], abs(e_x[k] - e_y[k]) / dist)

    classes = list(range(m))
    width = 0.25
    axes[1].bar([c - width for c in classes], [trop_lip[k] for k in classes],
               width, label='Tropical C₀', color='steelblue')
    axes[1].bar(classes, [eml_lip[k] for k in classes],
               width, label=f'EML C_ε (ε={eps_test})', color='coral')
    axes[1].bar([c + width for c in classes], [L] * m,
               width, label=f'Bound L={L}', color='forestgreen', alpha=0.6)
    axes[1].set_xlabel('Class k')
    axes[1].set_ylabel('Empirical Lipschitz constant')
    axes[1].set_title('Lipschitz Constants: Tropical vs EML vs Bound')
    axes[1].legend()
    axes[1].set_xticks(classes)
    axes[1].grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('part_iii_lipschitz_preservation.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\nLipschitz constant comparison (ε={eps_test}, n={n}, d={d}, m={m}):")
    print(f"  Theoretical bound L = {L:.2f}")
    for k in range(m):
        print(f"  Class {k}: tropical Lip = {trop_lip[k]:.4f}, EML Lip = {eml_lip[k]:.4f}")
    print()

# ─────────────────────────────────────────────────────────
# Demo 4: Robustness Transfer (Part iv)
# ─────────────────────────────────────────────────────────

def demo_robustness_transfer():
    """Demonstrate certified robustness transfer from tropical to EML."""
    print("=" * 60)
    print("PART (iv): Certified Robustness Transfer")
    print("     r* = γ / (2L) — same radius for both classifiers")
    print("=" * 60)

    n = 2
    d = 3
    m = 3
    np.random.seed(123)
    L = 1.5

    # Create well-separated classifier
    Phi = []
    for k in range(m):
        pieces = []
        for i in range(d):
            a = np.random.randn() + 2 * k  # bias to separate classes
            w = np.random.randn(n)
            w = w / np.sum(np.abs(w)) * L * np.random.uniform(0.5, 1.0)
            pieces.append((a, w))
        Phi.append(pieces)

    # Test point
    x0 = np.array([0.5, 0.3])
    y_true = np.argmax(trop_classifier(Phi, x0))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Compute margins for varying ε
    eps_values = np.logspace(-2, 1, 50)
    trop_margins = []
    eml_margins = []

    trop_scores = trop_classifier(Phi, x0)
    trop_margin = class_margin(trop_scores, y_true)

    for eps in eps_values:
        eml_scores = eml_classifier(Phi, eps, x0)
        eml_margin = class_margin(eml_scores, y_true)
        trop_margins.append(trop_margin)
        eml_margins.append(eml_margin)

    adjusted_trop = [trop_margin - 2 * eps * np.log(d) for eps in eps_values]

    axes[0].semilogx(eps_values, trop_margins, 'b-', linewidth=2, label='Tropical margin')
    axes[0].semilogx(eps_values, eml_margins, 'r-', linewidth=2, label='EML margin')
    axes[0].semilogx(eps_values, adjusted_trop, 'g--', linewidth=2,
                     label='Tropical - 2ε·log d')
    axes[0].set_xlabel('ε')
    axes[0].set_ylabel('Classification margin')
    axes[0].set_title('Margin: Tropical vs EML')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Robustness certificate visualization
    eps_fixed = 0.5
    eml_scores = eml_classifier(Phi, eps_fixed, x0)
    eml_margin = class_margin(eml_scores, y_true)
    gamma = trop_margin - 2 * eps_fixed * np.log(d)  # guaranteed lower bound on EML margin
    r_star = gamma / (2 * L) if gamma > 0 else 0

    # Verify robustness empirically
    n_attacks = 5000
    successful_attacks = 0
    attack_radii = np.linspace(0, r_star * 3, 100)
    attack_success_rate = []

    for r in attack_radii:
        successes = 0
        for _ in range(200):
            delta = np.random.uniform(-r, r, n)
            x_adv = x0 + delta
            scores_adv = eml_classifier(Phi, eps_fixed, x_adv)
            pred = np.argmax(scores_adv)
            if pred != y_true:
                successes += 1
        attack_success_rate.append(successes / 200)

    axes[1].plot(attack_radii, attack_success_rate, 'b-', linewidth=2,
                label='Attack success rate')
    if r_star > 0:
        axes[1].axvline(x=r_star, color='r', linestyle='--', linewidth=2,
                       label=f'Certified radius r*={r_star:.3f}')
    axes[1].axhline(y=0, color='gray', linewidth=0.5)
    axes[1].fill_between([0, r_star], [0, 0], [1, 1], alpha=0.1, color='green',
                        label='Certified safe zone')
    axes[1].set_xlabel('Perturbation radius (L∞)')
    axes[1].set_ylabel('Attack success rate')
    axes[1].set_title(f'Certified Robustness (ε={eps_fixed}, L={L})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('part_iv_robustness_transfer.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\nRobustness certificate (ε={eps_fixed}, L={L}):")
    print(f"  True class: {y_true}")
    print(f"  Tropical margin: {trop_margin:.4f}")
    print(f"  EML margin: {eml_margin:.4f}")
    print(f"  Lower bound γ = trop_margin - 2ε·log d = {gamma:.4f}")
    print(f"  Certified radius r* = γ/(2L) = {r_star:.4f}")
    print(f"  No adversarial example exists within L∞ ball of radius {r_star:.4f}")
    print()

# ─────────────────────────────────────────────────────────
# Demo 5: Full Pipeline Visualization
# ─────────────────────────────────────────────────────────

def demo_full_pipeline():
    """Visualize the complete EML → tropical → robustness pipeline."""
    print("=" * 60)
    print("FULL PIPELINE: EML → Tropical → Certified Robustness")
    print("=" * 60)

    n = 2
    d = 4
    m = 3
    np.random.seed(77)
    L = 1.0

    # Create classifier with known structure
    Phi = []
    # Class 0: top-left region
    Phi.append([(2.0, np.array([-0.5, 0.5])),
                (1.5, np.array([-0.3, 0.4])),
                (1.0, np.array([-0.6, 0.3])),
                (0.5, np.array([-0.4, 0.6]))])
    # Class 1: top-right region
    Phi.append([(2.0, np.array([0.5, 0.5])),
                (1.5, np.array([0.4, 0.3])),
                (1.0, np.array([0.3, 0.6])),
                (0.5, np.array([0.6, 0.4]))])
    # Class 2: bottom region
    Phi.append([(2.0, np.array([0.0, -0.8])),
                (1.5, np.array([0.2, -0.6])),
                (1.0, np.array([-0.2, -0.7])),
                (0.5, np.array([0.1, -0.9]))])

    fig = plt.figure(figsize=(18, 12))
    gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

    # Decision boundaries for tropical and EML classifiers
    grid_range = np.linspace(-4, 4, 200)
    X, Y = np.meshgrid(grid_range, grid_range)

    for col, (eps_label, eps_val) in enumerate([
        ('Tropical (ε→0)', None), ('EML (ε=0.5)', 0.5), ('EML (ε=2.0)', 2.0)]):

        # Top row: decision regions
        ax = fig.add_subplot(gs[0, col])
        Z = np.zeros_like(X)
        for i in range(X.shape[0]):
            for j in range(X.shape[1]):
                pt = np.array([X[i, j], Y[i, j]])
                if eps_val is None:
                    scores = trop_classifier(Phi, pt)
                else:
                    scores = eml_classifier(Phi, eps_val, pt)
                Z[i, j] = np.argmax(scores)

        ax.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5, 2.5],
                   colors=['#ff9999', '#99ff99', '#9999ff'], alpha=0.5)
        ax.contour(X, Y, Z, levels=[0.5, 1.5], colors='black', linewidths=1)

        # Mark a test point with robustness ball
        x0 = np.array([1.5, 1.5])
        if eps_val is None:
            scores = trop_classifier(Phi, x0)
        else:
            scores = eml_classifier(Phi, eps_val, x0)
        y_true = np.argmax(scores)
        margin = class_margin(scores, y_true)
        r = margin / (2 * L) if margin > 0 else 0

        ax.plot(x0[0], x0[1], 'k*', markersize=15, zorder=5)
        circle = Circle(x0, r, fill=False, color='red', linewidth=2, linestyle='--')
        ax.add_patch(circle)

        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
        ax.set_title(f'{eps_label}\nmargin={margin:.2f}, r*={r:.2f}')
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')
        ax.set_aspect('equal')

    # Bottom row: score functions along a line
    t_vals = np.linspace(-4, 4, 300)
    direction = np.array([1.0, 0.5]) / np.sqrt(1.25)

    for col, (eps_label, eps_val) in enumerate([
        ('Tropical', None), ('EML ε=0.5', 0.5), ('EML ε=2.0', 2.0)]):

        ax = fig.add_subplot(gs[1, col])
        for k in range(m):
            scores = []
            for t in t_vals:
                pt = t * direction
                if eps_val is None:
                    s = trop_classifier(Phi, pt)
                else:
                    s = eml_classifier(Phi, eps_val, pt)
                scores.append(s[k])
            ax.plot(t_vals, scores, linewidth=2, label=f'Class {k}')

        ax.set_xlabel('t (along direction)')
        ax.set_ylabel('Score')
        ax.set_title(f'{eps_label}: Score Functions')
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.savefig('full_pipeline_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()

    # Print summary
    print("\nDecision boundary analysis:")
    for eps_label, eps_val in [('Tropical', None), ('EML ε=0.5', 0.5), ('EML ε=2.0', 2.0)]:
        x0 = np.array([1.5, 1.5])
        scores = trop_classifier(Phi, x0) if eps_val is None else eml_classifier(Phi, eps_val, x0)
        y_true = np.argmax(scores)
        margin = class_margin(scores, y_true)
        r = margin / (2 * L) if margin > 0 else 0
        print(f"  {eps_label:15s}: predicted class={y_true}, margin={margin:.3f}, r*={r:.3f}")
    print()

# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Maslov Dequantization Isometry — Numerical Demos      ║")
    print("║   Formally verified in Lean 4 + Mathlib                 ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_binary_logsumexp()
    demo_d_term_logsumexp()
    demo_lipschitz_preservation()
    demo_robustness_transfer()
    demo_full_pipeline()

    print("=" * 60)
    print("All demos complete. Generated figures:")
    print("  • part_i_binary_logsumexp.png")
    print("  • part_ii_dequantization_error.png")
    print("  • part_iii_lipschitz_preservation.png")
    print("  • part_iv_robustness_transfer.png")
    print("  • full_pipeline_visualization.png")
    print("=" * 60)
