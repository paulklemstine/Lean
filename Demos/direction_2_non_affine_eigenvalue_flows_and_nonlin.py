#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Nonlinear Spectral Stability

Demonstrates applications in:
1. Trust-region optimization — Hessian eigenvalue tracking
2. Structural engineering — parametric stability of elastic systems
3. Control systems — gain margin computation
4. Polynomial homotopy continuation — certified path tracking
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────────────
# Application 1: Trust-Region Optimization
# ──────────────────────────────────────────────────────────────────────

def trust_region_application():
    """
    Trust-Region Hessian Eigenvalue Tracking

    In trust-region methods, we follow a path x(t) in parameter space and
    track the eigenvalues of the Hessian H(t). The optimization landscape
    remains locally convex (negative definite for maximization) as long as
    all eigenvalues stay negative.

    Model: H(t) = H₀ + t·P + t²·Q where P is a perturbation direction
    and Q captures second-order curvature effects.

    The eigenvalues evolve as quadratic functions of t. By our theorem,
    the trust region boundary is the first positive root of the most
    critical eigenvalue branch.
    """
    print("=" * 60)
    print("APPLICATION 1: Trust-Region Optimization")
    print("=" * 60)

    # Simulate a 4×4 Hessian with eigenvalue evolution
    np.random.seed(123)
    n_eigenvalues = 4
    t = np.linspace(0, 5, 1000)

    # Eigenvalue branches (quadratic in t)
    branches = [
        (-8.0, 2.0, 0.3),   # λ₁(t)
        (-5.0, 1.5, 0.2),   # λ₂(t)
        (-3.0, 0.8, 0.5),   # λ₃(t) — crosses first
        (-12.0, 1.0, 0.1),  # λ₄(t)
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot eigenvalue evolution
    roots = []
    for i, (a, b, c) in enumerate(branches):
        eig = a + b*t + c*t**2
        disc = b**2 - 4*a*c
        r = (-b + np.sqrt(disc)) / (2*c)
        roots.append(r)
        axes[0].plot(t, eig, linewidth=2, label=f'λ_{i+1}(t) (root={r:.2f})')
        axes[0].scatter([r], [0], s=60, zorder=5)

    rho = min(roots)
    axes[0].axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    axes[0].axvline(x=rho, color='purple', linewidth=2, linestyle='--',
                    label=f'Trust region boundary ρ={rho:.2f}')
    axes[0].fill_between(t, -15, 20, where=(t < rho), alpha=0.05, color='green')
    axes[0].set_xlabel('Step size t', fontsize=11)
    axes[0].set_ylabel('Hessian eigenvalue λ(t)', fontsize=11)
    axes[0].set_title('Hessian Eigenvalue Evolution', fontsize=13)
    axes[0].legend(fontsize=8)
    axes[0].set_ylim(-15, 20)
    axes[0].grid(True, alpha=0.3)

    # Determinant of Hessian (product of eigenvalues) — shows sign change
    det_vals = np.ones_like(t)
    for a, b, c in branches:
        det_vals *= (a + b*t + c*t**2)

    axes[1].plot(t, det_vals, 'k-', linewidth=2, label='det(H(t))')
    axes[1].axhline(y=0, color='r', linewidth=0.5, linestyle='--')
    axes[1].axvline(x=rho, color='purple', linewidth=2, linestyle='--',
                    label=f'Predicted boundary ρ={rho:.2f}')
    axes[1].set_xlabel('Step size t', fontsize=11)
    axes[1].set_ylabel('det(H(t))', fontsize=11)
    axes[1].set_title('Determinant Sign Change at Boundary', fontsize=13)
    axes[1].legend(fontsize=10)
    axes[1].set_ylim(-500, 2000)
    axes[1].grid(True, alpha=0.3)

    plt.suptitle('Trust-Region Method: Eigenvalue-Based Step Size Control', fontsize=14)
    plt.tight_layout()
    plt.savefig('app_trust_region.png', dpi=150)
    plt.close()
    print(f"Trust region boundary: ρ = {rho:.4f}")
    print(f"Critical eigenvalue branch: λ_{roots.index(rho)+1}")
    print("→ Saved: app_trust_region.png\n")


# ──────────────────────────────────────────────────────────────────────
# Application 2: Structural Stability
# ──────────────────────────────────────────────────────────────────────

def structural_stability_application():
    """
    Parametric Stability of Elastic Structures

    An elastic structure under parametric loading has stiffness matrix K(λ)
    where λ is the load parameter. The structure is stable when K(λ) is
    positive definite (all eigenvalues positive). As loading increases,
    eigenvalues decrease; the critical load is the first eigenvalue crossing.

    For columns under compression: K(λ) = K₀ - λ·Kg + λ²·Kn
    where K₀ is initial stiffness, Kg is geometric stiffness,
    and Kn captures nonlinear stiffening.

    We track σᵢ(λ) = eigenvalue_i(K(λ)) and find the critical load
    where the first eigenvalue reaches zero (buckling onset).
    """
    print("=" * 60)
    print("APPLICATION 2: Structural Stability (Buckling Analysis)")
    print("=" * 60)

    lam = np.linspace(0, 10, 1000)

    # Mode eigenvalues: σᵢ(λ) = σ₀ᵢ - aᵢλ + bᵢλ²
    # Here negative of eigenvalue branches to match stability convention
    modes = [
        (100.0, 12.0, 0.3),   # Mode 1 (fundamental)
        (250.0, 20.0, 0.5),   # Mode 2
        (400.0, 35.0, 0.8),   # Mode 3
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    colors = ['#e41a1c', '#377eb8', '#4daf4a']

    critical_loads = []
    for i, (s0, ai, bi) in enumerate(modes):
        sigma = s0 - ai*lam + bi*lam**2
        # Find first zero (if the branch dips below zero)
        # σ(λ) = bᵢλ² - aᵢλ + σ₀ᵢ = 0
        disc = ai**2 - 4*bi*s0
        if disc >= 0:
            r = (ai - np.sqrt(disc)) / (2*bi)
            if r > 0:
                critical_loads.append((r, i))
        ax.plot(lam, sigma, color=colors[i], linewidth=2,
                label=f'Mode {i+1}: σ₀={s0}, critical λ={r:.2f}' if disc >= 0 else f'Mode {i+1}: σ₀={s0} (no buckling)')

    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')

    if critical_loads:
        lam_cr = min(critical_loads, key=lambda x: x[0])
        ax.axvline(x=lam_cr[0], color='purple', linewidth=2, linestyle='--',
                   label=f'Critical load λ_cr = {lam_cr[0]:.2f}')
        print(f"Critical buckling load: λ_cr = {lam_cr[0]:.4f}")
        print(f"Critical mode: Mode {lam_cr[1]+1}")

    ax.set_xlabel('Load parameter λ', fontsize=12)
    ax.set_ylabel('Stiffness eigenvalue σ(λ)', fontsize=12)
    ax.set_title('Structural Buckling: First Eigenvalue Crossing = Critical Load', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 10)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('app_structural.png', dpi=150)
    plt.close()
    print("→ Saved: app_structural.png\n")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Control Systems Gain Margin
# ──────────────────────────────────────────────────────────────────────

def control_systems_application():
    """
    Gain Margin in Control Systems

    A feedback control system with gain parameter k has characteristic
    polynomial whose roots (eigenvalues) vary with k. The system is
    stable when all eigenvalues have negative real parts.

    As gain increases, eigenvalues migrate. The gain margin is the
    smallest gain at which an eigenvalue crosses the imaginary axis —
    exactly our stability radius theorem applied to Re(λᵢ(k)).
    """
    print("=" * 60)
    print("APPLICATION 3: Control Systems Gain Margin")
    print("=" * 60)

    k = np.linspace(0, 5, 1000)

    # Real parts of eigenvalues as functions of gain
    # Re(λᵢ(k)) modeled as quadratic branches
    eigenvalue_branches = [
        (-4.0, 1.5, 0.1),   # Dominant pole
        (-2.0, 0.5, 0.3),   # Second pole pair
        (-6.0, 0.8, 0.05),  # Third pole
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    gain_margins = []
    for i, (a, b, c) in enumerate(eigenvalue_branches):
        re_lambda = a + b*k + c*k**2
        disc = b**2 - 4*a*c
        r = (-b + np.sqrt(disc)) / (2*c)
        gain_margins.append(r)
        ax.plot(k, re_lambda, linewidth=2, label=f'Re(λ_{i+1}): root at k={r:.2f}')
        ax.scatter([r], [0], s=60, zorder=5)

    k_margin = min(gain_margins)
    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=k_margin, color='red', linewidth=2, linestyle='--',
               label=f'Gain margin k* = {k_margin:.2f}')
    ax.fill_between(k, -10, 10, where=(k < k_margin), alpha=0.05, color='green')
    ax.fill_between(k, -10, 10, where=(k > k_margin), alpha=0.05, color='red')

    ax.set_xlabel('Gain k', fontsize=12)
    ax.set_ylabel('Re(λ(k))', fontsize=12)
    ax.set_title('Control System: Gain Margin = First Eigenvalue Crossing', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 5)
    ax.set_ylim(-8, 10)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('app_control.png', dpi=150)
    plt.close()
    print(f"Gain margin: k* = {k_margin:.4f}")
    print("→ Saved: app_control.png\n")


# ──────────────────────────────────────────────────────────────────────
# Application 4: Polynomial Homotopy Continuation
# ──────────────────────────────────────────────────────────────────────

def homotopy_continuation_application():
    """
    Certified Path Tracking in Polynomial Homotopy Continuation

    In homotopy continuation, we deform a start system G into a target
    system F via H(t) = (1-t)G + tF. The Jacobian eigenvalues track
    the conditioning of the homotopy path.

    The stability radius predicts the first singular point along the path,
    where the Jacobian becomes singular and path tracking must adapt.
    """
    print("=" * 60)
    print("APPLICATION 4: Polynomial Homotopy Continuation")
    print("=" * 60)

    t = np.linspace(0, 1.2, 1000)

    # Jacobian eigenvalue branches along homotopy path
    branches = [
        lambda t: -2 + 3*t - 0.5*t**2,    # Branch 1
        lambda t: -1.5 + 2*t + 0.3*t**2,   # Branch 2
        lambda t: -3 + 4*t - t**2,          # Branch 3
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for i, branch_fn in enumerate(branches):
        vals = np.array([branch_fn(ti) for ti in t])
        ax.plot(t, vals, linewidth=2, label=f'σ_{i+1}(t)')
        # Find first zero
        for j in range(1, len(t)):
            if vals[j-1] < 0 and vals[j] >= 0:
                ax.scatter([t[j]], [0], s=60, zorder=5)
                break

    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=1.0, color='gray', linewidth=1, linestyle=':', alpha=0.5,
               label='Target t=1')

    ax.set_xlabel('Homotopy parameter t', fontsize=12)
    ax.set_ylabel('Jacobian singular value σ(t)', fontsize=12)
    ax.set_title('Homotopy Continuation: Eigenvalue Path Tracking', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 1.2)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('app_homotopy.png', dpi=150)
    plt.close()
    print("→ Saved: app_homotopy.png\n")


if __name__ == '__main__':
    print("\n" + "═" * 60)
    print("  APPLICATIONS OF NONLINEAR SPECTRAL STABILITY")
    print("═" * 60 + "\n")

    trust_region_application()
    structural_stability_application()
    control_systems_application()
    homotopy_continuation_application()

    print("═" * 60)
    print("  ALL APPLICATIONS COMPLETE")
    print("═" * 60)


#!/usr/bin/env python3
"""
demo.py — Nonlinear Spectral Stability: Interactive Demonstration

Demonstrates the core theorems:
1. First positive root existence for sign-crossing flows
2. Sign characterization before/after the first root
3. Stability radius as the minimum first positive root across branches
4. Quadratic branch specialization with explicit root formula

Generates random quadratic eigenvalue branches, computes predicted stability
radius from roots, validates by binary search, and visualizes results.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple, Optional

# ──────────────────────────────────────────────────────────────────────
# Core mathematical functions
# ──────────────────────────────────────────────────────────────────────

def quadratic_branch(a: float, b: float, c: float, t: np.ndarray) -> np.ndarray:
    """Evaluate θ(t) = a + b*t + c*t² for a quadratic eigenvalue branch."""
    return a + b * t + c * t**2

def quadratic_positive_root(a: float, b: float, c: float) -> Optional[float]:
    """
    Compute the first positive root of a + b*t + c*t² = 0.
    Returns None if no positive root exists.
    Requires a < 0 and c > 0 for the sign-crossing condition.
    """
    disc = b**2 - 4*a*c
    if disc < 0:
        return None
    sqrt_disc = np.sqrt(disc)
    r = (-b + sqrt_disc) / (2*c)
    if r > 0:
        return r
    return None

def stability_radius_from_branches(branches: List[Tuple[float, float, float]]) -> Optional[float]:
    """
    Compute the stability radius as the minimum first positive root
    across all quadratic branches.
    """
    roots = []
    for a, b, c in branches:
        r = quadratic_positive_root(a, b, c)
        if r is not None:
            roots.append(r)
    return min(roots) if roots else None

def stability_radius_by_search(branches: List[Tuple[float, float, float]],
                                 t_max: float = 20.0,
                                 n_points: int = 100000) -> Optional[float]:
    """
    Find the stability radius by binary search: the smallest t > 0
    where some branch becomes nonneg.
    """
    t_vals = np.linspace(0, t_max, n_points)
    for t in t_vals:
        for a, b, c in branches:
            val = a + b*t + c*t**2
            if val >= 0:
                return t
    return None

# ──────────────────────────────────────────────────────────────────────
# Demonstration 1: Single branch sign-crossing
# ──────────────────────────────────────────────────────────────────────

def demo_single_branch():
    """Demonstrate Theorem 1: first positive root existence."""
    print("=" * 70)
    print("DEMO 1: First Positive Root of a Nonlinear Branch")
    print("=" * 70)

    # Quadratic branch: θ(t) = -2 + 0.5t + 0.3t²
    a, b, c = -2.0, 0.5, 0.3
    t = np.linspace(0, 5, 1000)
    theta = quadratic_branch(a, b, c, t)

    r = quadratic_positive_root(a, b, c)
    print(f"\nBranch: θ(t) = {a} + {b}t + {c}t²")
    print(f"θ(0) = {a} < 0  ✓ (negative at origin)")
    print(f"First positive root: r = {r:.6f}")
    print(f"θ(r) = {a + b*r + c*r**2:.2e}  ≈ 0  ✓")
    print(f"θ(r/2) = {quadratic_branch(a, b, c, np.array([r/2]))[0]:.6f} < 0  ✓ (negative before root)")
    print(f"θ(2r) = {quadratic_branch(a, b, c, np.array([2*r]))[0]:.6f} > 0  ✓ (positive after root)")

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(t, theta, 'b-', linewidth=2, label=f'θ(t) = {a} + {b}t + {c}t²')
    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=r, color='r', linewidth=1.5, linestyle='--', label=f'First root r = {r:.4f}')
    ax.fill_between(t, theta, 0, where=(t < r), alpha=0.15, color='blue', label='Stable (θ < 0)')
    ax.fill_between(t, theta, 0, where=(t > r), alpha=0.15, color='red', label='Unstable (θ > 0)')
    ax.scatter([r], [0], color='red', s=100, zorder=5, label='Phase boundary')
    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('θ(t)', fontsize=12)
    ax.set_title('Theorem 1: First Positive Root as Phase Boundary', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 5)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demo_single_branch.png', dpi=150)
    plt.close()
    print("→ Saved: demo_single_branch.png\n")

# ──────────────────────────────────────────────────────────────────────
# Demonstration 2: Multi-branch stability radius
# ──────────────────────────────────────────────────────────────────────

def demo_multi_branch():
    """Demonstrate Theorem 3: stability radius = min first root."""
    print("=" * 70)
    print("DEMO 2: Stability Radius = Minimum First Positive Root")
    print("=" * 70)

    branches = [
        (-3.0, 1.0, 0.2),   # Branch 1
        (-1.0, 0.3, 0.5),   # Branch 2 (crosses first)
        (-5.0, 0.8, 0.1),   # Branch 3
        (-2.0, 2.0, 0.05),  # Branch 4
    ]

    t = np.linspace(0, 8, 1000)
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    roots = []
    for i, (a, b, c) in enumerate(branches):
        theta = quadratic_branch(a, b, c, t)
        r = quadratic_positive_root(a, b, c)
        roots.append((r, i))
        ax.plot(t, theta, color=colors[i], linewidth=2,
                label=f'θ_{i+1}(t) = {a}+{b}t+{c}t²  (root={r:.3f})')
        if r is not None:
            ax.scatter([r], [0], color=colors[i], s=80, zorder=5)

    rho = stability_radius_from_branches(branches)
    rho_search = stability_radius_by_search(branches)

    print(f"\nBranch roots: {[f'{r:.4f}' for r, _ in roots]}")
    print(f"Predicted stability radius (analytic): ρ = {rho:.6f}")
    print(f"Observed stability radius (search):    ρ ≈ {rho_search:.6f}")
    print(f"Agreement: |predicted - observed| = {abs(rho - rho_search):.6f}")

    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=rho, color='purple', linewidth=2, linestyle='--',
               label=f'Stability radius ρ = {rho:.4f}')
    ax.fill_between(t, -10, 10, where=(t < rho), alpha=0.05, color='green')
    ax.fill_between(t, -10, 10, where=(t > rho), alpha=0.05, color='red')

    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('Eigenvalue θ(t)', fontsize=12)
    ax.set_title('Theorem 3: Stability Radius = Earliest Branch Zero Crossing', fontsize=14)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(0, 8)
    ax.set_ylim(-6, 15)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demo_multi_branch.png', dpi=150)
    plt.close()
    print("→ Saved: demo_multi_branch.png\n")

# ──────────────────────────────────────────────────────────────────────
# Demonstration 3: Random trials
# ──────────────────────────────────────────────────────────────────────

def demo_random_trials(n_trials: int = 200, n_branches: int = 5):
    """Validate the stability radius formula with random quadratic families."""
    print("=" * 70)
    print(f"DEMO 3: Random Validation ({n_trials} trials, {n_branches} branches each)")
    print("=" * 70)

    np.random.seed(42)
    errors = []
    predicted_radii = []
    observed_radii = []

    for trial in range(n_trials):
        branches = []
        for _ in range(n_branches):
            a = -np.random.uniform(0.5, 5.0)
            b = np.random.uniform(0.0, 3.0)
            c = np.random.uniform(0.1, 2.0)
            branches.append((a, b, c))

        rho_pred = stability_radius_from_branches(branches)
        rho_obs = stability_radius_by_search(branches, t_max=20.0, n_points=50000)

        if rho_pred is not None and rho_obs is not None:
            err = abs(rho_pred - rho_obs)
            errors.append(err)
            predicted_radii.append(rho_pred)
            observed_radii.append(rho_obs)

    errors = np.array(errors)
    print(f"\nAll {len(errors)} trials completed.")
    print(f"Max absolute error: {errors.max():.6f}")
    print(f"Mean absolute error: {errors.mean():.6f}")
    print(f"Agreement within 0.001: {(errors < 0.001).sum()}/{len(errors)} trials")

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Scatter plot: predicted vs observed
    axes[0].scatter(predicted_radii, observed_radii, alpha=0.4, s=15, color='blue')
    lim = max(max(predicted_radii), max(observed_radii)) * 1.1
    axes[0].plot([0, lim], [0, lim], 'r--', linewidth=1, label='Perfect agreement')
    axes[0].set_xlabel('Predicted ρ (analytic formula)', fontsize=12)
    axes[0].set_ylabel('Observed ρ (numerical search)', fontsize=12)
    axes[0].set_title('Predicted vs Observed Stability Radius', fontsize=13)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)

    # Error histogram
    axes[1].hist(errors, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    axes[1].set_xlabel('Absolute Error |predicted - observed|', fontsize=12)
    axes[1].set_ylabel('Frequency', fontsize=12)
    axes[1].set_title('Error Distribution Across Random Trials', fontsize=13)
    axes[1].grid(True, alpha=0.3)

    plt.suptitle(f'Validation: {n_trials} Random Quadratic Families', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('demo_random_trials.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo_random_trials.png\n")

# ──────────────────────────────────────────────────────────────────────
# Demonstration 4: Affine vs quadratic comparison
# ──────────────────────────────────────────────────────────────────────

def demo_affine_vs_nonlinear():
    """Show how the nonlinear theory generalizes the affine case."""
    print("=" * 70)
    print("DEMO 4: Affine Theory as Special Case of Nonlinear Theory")
    print("=" * 70)

    t = np.linspace(0, 4, 1000)

    # Affine branch: θ(t) = -2 + t (root at t=2)
    a_aff, b_aff = -2.0, 1.0
    theta_affine = a_aff + b_aff * t
    r_affine = -a_aff / b_aff

    # Quadratic branch: θ(t) = -2 + 0.5t + 0.2t² (root earlier)
    a_q, b_q, c_q = -2.0, 0.5, 0.2
    theta_quad = quadratic_branch(a_q, b_q, c_q, t)
    r_quad = quadratic_positive_root(a_q, b_q, c_q)

    # Cubic-like branch via composition (still continuous + monotone)
    theta_cubic = -2.0 + 0.1 * t + 0.05 * t**2 + 0.15 * t**3
    # Find root numerically
    idx = np.argmin(np.abs(theta_cubic[1:]))
    r_cubic = t[1:][idx]

    print(f"Affine root:    r = {r_affine:.4f}  (exact: -a/b)")
    print(f"Quadratic root: r = {r_quad:.4f}  (quadratic formula)")
    print(f"Cubic root:     r ≈ {r_cubic:.4f}  (numerical)")

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(t, theta_affine, 'b-', linewidth=2, label=f'Affine: θ={a_aff}+{b_aff}t (r={r_affine:.2f})')
    ax.plot(t, theta_quad, 'r-', linewidth=2, label=f'Quadratic: θ={a_q}+{b_q}t+{c_q}t² (r={r_quad:.2f})')
    ax.plot(t, theta_cubic, 'g-', linewidth=2, label=f'Cubic: θ=-2+0.1t+0.05t²+0.15t³ (r≈{r_cubic:.2f})')
    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')

    for r, color in [(r_affine, 'blue'), (r_quad, 'red'), (r_cubic, 'green')]:
        ax.axvline(x=r, color=color, linewidth=1, linestyle=':', alpha=0.7)
        ax.scatter([r], [0], color=color, s=80, zorder=5)

    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('θ(t)', fontsize=12)
    ax.set_title('Nonlinear Theory Generalizes Affine: All Branches Follow the Same Principle', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 4)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demo_affine_vs_nonlinear.png', dpi=150)
    plt.close()
    print("→ Saved: demo_affine_vs_nonlinear.png\n")


if __name__ == '__main__':
    print("\n" + "═" * 70)
    print("  NONLINEAR SPECTRAL STABILITY — THEOREM DEMONSTRATION")
    print("═" * 70 + "\n")

    demo_single_branch()
    demo_multi_branch()
    demo_random_trials()
    demo_affine_vs_nonlinear()

    print("═" * 70)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("═" * 70)


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Flow Phase Diagram

Visualizes the core mathematical concept: multiple eigenvalue branches flowing
through parameter space, with the stability boundary at the first zero crossing.
Shows how the minimum first root across all branches determines the phase
transition from stability to instability.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ── Panel 1: Affine vs Nonlinear comparison ──
ax = axes[0]
t = np.linspace(0, 4, 500)

# Affine branch
theta_aff = -2 + 1.2 * t
r_aff = 2.0 / 1.2

# Quadratic branch
theta_quad = -2 + 0.3 * t + 0.4 * t**2
disc = 0.3**2 + 4*2*0.4
r_quad = (-0.3 + np.sqrt(disc)) / (2*0.4)

# Cubic-like
theta_cub = -1.5 + 0.1*t + 0.02*t**2 + 0.3*t**3
idx_cub = np.where(theta_cub >= 0)[0]
r_cub = t[idx_cub[0]] if len(idx_cub) > 0 else 4.0

ax.plot(t, theta_aff, 'b-', linewidth=2.5, label='Affine: θ = -2 + 1.2t')
ax.plot(t, theta_quad, 'r-', linewidth=2.5, label='Quadratic: θ = -2 + 0.3t + 0.4t²')
ax.plot(t, theta_cub, 'g-', linewidth=2.5, label='Cubic: θ = -1.5 + 0.1t + 0.02t² + 0.3t³')

for r, c in [(r_aff, 'blue'), (r_quad, 'red'), (r_cub, 'green')]:
    ax.plot(r, 0, 'o', color=c, markersize=10, zorder=5)
    ax.axvline(x=r, color=c, linewidth=0.8, linestyle=':', alpha=0.5)

ax.axhline(y=0, color='k', linewidth=0.8)
ax.fill_between(t, -5, 0, alpha=0.04, color='blue')
ax.fill_between(t, 0, 15, alpha=0.04, color='red')
ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('θ(t)', fontsize=11)
ax.set_title('From Affine to Nonlinear:\nSame Principle, Richer Geometry', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, 3.5)
ax.set_ylim(-3, 8)
ax.grid(True, alpha=0.2)

# ── Panel 2: Multi-branch stability radius ──
ax = axes[1]
t = np.linspace(0, 5, 500)

branches = [
    (-3.0, 1.0, 0.15, '#1f77b4'),
    (-1.5, 0.2, 0.6,  '#ff7f0e'),
    (-4.0, 0.5, 0.3,  '#2ca02c'),
    (-2.5, 1.5, 0.08, '#d62728'),
    (-1.8, 0.8, 0.25, '#9467bd'),
]

roots = []
for a, b, c, color in branches:
    theta = a + b*t + c*t**2
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    roots.append(r)
    ax.plot(t, theta, color=color, linewidth=2)
    ax.plot(r, 0, 'o', color=color, markersize=8, zorder=5)

rho = min(roots)
critical_idx = roots.index(rho)
ax.axhline(y=0, color='k', linewidth=0.8)
ax.axvline(x=rho, color='purple', linewidth=2.5, linestyle='--',
           label=f'ρ = min root = {rho:.2f}')

# Shade stable region
ax.fill_between(t, -6, 20, where=(t < rho), alpha=0.06, color='green')
ax.fill_between(t, -6, 20, where=(t >= rho), alpha=0.06, color='red')

ax.annotate('STABLE', xy=(rho/2, -5), fontsize=14, fontweight='bold',
            color='green', ha='center', alpha=0.5)
ax.annotate('UNSTABLE', xy=(rho + (5-rho)/2, -5), fontsize=14, fontweight='bold',
            color='red', ha='center', alpha=0.5)

ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('Eigenvalue θ(t)', fontsize=11)
ax.set_title('Stability Radius = Earliest\nBranch Zero Crossing', fontsize=12)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(0, 5)
ax.set_ylim(-6, 20)
ax.grid(True, alpha=0.2)

# ── Panel 3: Phase diagram in (branch, parameter) space ──
ax = axes[2]
n_branches = 8
np.random.seed(17)

branch_roots = []
for i in range(n_branches):
    a = -np.random.uniform(1, 5)
    b = np.random.uniform(0, 2)
    c = np.random.uniform(0.1, 1)
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    branch_roots.append(r)

rho = min(branch_roots)
critical = branch_roots.index(rho)

# Plot as horizontal bars
for i, r in enumerate(branch_roots):
    color = '#d62728' if i == critical else '#1f77b4'
    ax.barh(i, r, height=0.6, color=color, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.plot(r, i, 'ko', markersize=6, zorder=5)

ax.axvline(x=rho, color='red', linewidth=2.5, linestyle='--', label=f'ρ = {rho:.2f}')

# Legend
stable_patch = mpatches.Patch(color='#1f77b4', alpha=0.7, label='Other branches')
critical_patch = mpatches.Patch(color='#d62728', alpha=0.7, label='Critical branch')
ax.legend(handles=[stable_patch, critical_patch], fontsize=9, loc='upper right')

ax.set_xlabel('First positive root', fontsize=11)
ax.set_ylabel('Branch index j', fontsize=11)
ax.set_title('Phase Diagram: Branch Roots\nand Critical Branch', fontsize=12)
ax.set_yticks(range(n_branches))
ax.set_yticklabels([f'θ_{i+1}' for i in range(n_branches)])
ax.grid(True, alpha=0.2, axis='x')

plt.tight_layout()
plt.savefig('viz_eigenvalue_flows.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_eigenvalue_flows.png")


#!/usr/bin/env python3
"""
Visualization: Quadratic Root Formula and Validation

Visualizes the quadratic branch specialization theorem: for θ(t) = a + bt + ct²
with a < 0, b ≥ 0, c > 0, the first positive root r = (-b + √(b²-4ac))/(2c)
is the exact stability boundary.

Produces a heatmap of stability radii across (a, c) parameter space,
and a scatter plot validating analytic vs numerical roots.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ── Panel 1: Heatmap of stability radius in (a, c) space ──
ax = axes[0]
a_vals = np.linspace(-5, -0.1, 200)
c_vals = np.linspace(0.1, 3, 200)
A, C = np.meshgrid(a_vals, c_vals)
b_fixed = 0.5

# r = (-b + sqrt(b² - 4ac)) / (2c)
disc = b_fixed**2 - 4*A*C
R = (-b_fixed + np.sqrt(disc)) / (2*C)

im = ax.pcolormesh(a_vals, c_vals, R, cmap='viridis', shading='auto')
cbar = plt.colorbar(im, ax=ax, label='Stability radius ρ')
ax.set_xlabel('Constant term a (< 0)', fontsize=11)
ax.set_ylabel('Quadratic coefficient c (> 0)', fontsize=11)
ax.set_title(f'Stability Radius Map\n(b = {b_fixed} fixed)', fontsize=12)

# Add contour lines
contours = ax.contour(a_vals, c_vals, R, levels=[0.5, 1.0, 2.0, 3.0, 5.0],
                       colors='white', linewidths=0.8, linestyles='--')
ax.clabel(contours, fmt='ρ=%.1f', fontsize=8, colors='white')

# ── Panel 2: Analytic vs numerical validation ──
ax = axes[1]

n_trials = 500
analytic_roots = []
numerical_roots = []

for _ in range(n_trials):
    a = -np.random.uniform(0.5, 5)
    b = np.random.uniform(0, 3)
    c = np.random.uniform(0.1, 2)

    # Analytic
    disc = b**2 - 4*a*c
    r_analytic = (-b + np.sqrt(disc)) / (2*c)

    # Numerical (bisection)
    t_lo, t_hi = 0, 20
    for _ in range(100):
        t_mid = (t_lo + t_hi) / 2
        val = a + b*t_mid + c*t_mid**2
        if val < 0:
            t_lo = t_mid
        else:
            t_hi = t_mid
    r_numerical = (t_lo + t_hi) / 2

    analytic_roots.append(r_analytic)
    numerical_roots.append(r_numerical)

analytic_roots = np.array(analytic_roots)
numerical_roots = np.array(numerical_roots)
errors = np.abs(analytic_roots - numerical_roots)

ax.scatter(analytic_roots, numerical_roots, s=8, alpha=0.5, c=errors,
           cmap='RdYlGn_r', vmin=0, vmax=errors.max())
lim = max(analytic_roots.max(), numerical_roots.max()) * 1.05
ax.plot([0, lim], [0, lim], 'r--', linewidth=1, alpha=0.7, label='Perfect agreement')
ax.set_xlabel('Analytic root', fontsize=11)
ax.set_ylabel('Numerical root (bisection)', fontsize=11)
ax.set_title(f'Root Validation ({n_trials} trials)\nMax error: {errors.max():.2e}', fontsize=12)
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

# ── Panel 3: Discriminant and root structure ──
ax = axes[2]
t = np.linspace(0, 4, 500)

# Show several quadratic branches with same a, different (b,c)
a_fixed = -2.0
params = [
    (0.0, 0.5, '#1f77b4'),   # Purely quadratic
    (0.5, 0.5, '#ff7f0e'),   # Small linear term
    (1.0, 0.5, '#2ca02c'),   # Medium linear term
    (2.0, 0.5, '#d62728'),   # Large linear term
    (0.5, 1.5, '#9467bd'),   # Large quadratic term
]

for b, c, color in params:
    theta = a_fixed + b*t + c*t**2
    disc = b**2 - 4*a_fixed*c
    r = (-b + np.sqrt(disc)) / (2*c)
    ax.plot(t, theta, color=color, linewidth=2,
            label=f'b={b}, c={c} → r={r:.2f}')
    ax.plot(r, 0, 'o', color=color, markersize=8, zorder=5)

ax.axhline(y=0, color='k', linewidth=0.8)
ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('θ(t)', fontsize=11)
ax.set_title(f'Quadratic Branches (a={a_fixed} fixed)\nVarying b and c', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, 3.5)
ax.set_ylim(-3, 8)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_quadratic_roots.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_quadratic_roots.png")


#!/usr/bin/env python3
"""
Visualization: Stability Landscape and Phase Transition

Visualizes the stability landscape as a 2D surface where the height
represents the maximum eigenvalue across all branches. The zero-level
set is the stability boundary, and the stability radius is the distance
from the origin to this boundary along the parameter axis.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

np.random.seed(42)

fig = plt.figure(figsize=(16, 10))

# ── Panel 1: Stability landscape (top-left) ──
ax1 = fig.add_subplot(2, 2, 1)

# Parameter grid
t1 = np.linspace(0, 5, 300)
t2 = np.linspace(-3, 3, 300)
T1, T2 = np.meshgrid(t1, t2)

# Define eigenvalue branches as functions of (t1, t2)
# θ₁(t) = -2 + t₁ + 0.3t₂² (depends on both parameters)
# θ₂(t) = -3 + 0.5t₁ + t₂

theta1 = -2 + T1 + 0.3*T2**2
theta2 = -3 + 0.5*T1 + T2

# Maximum eigenvalue (stability = where max < 0)
max_theta = np.maximum(theta1, theta2)

# Plot stability region
stable = max_theta < 0
ax1.contourf(t1, t2, stable.astype(float), levels=[0.5, 1.5],
             colors=['#90EE90'], alpha=0.3)
ax1.contour(t1, t2, max_theta, levels=[0], colors=['red'], linewidths=2)
ax1.contour(t1, t2, theta1, levels=[0], colors=['blue'], linewidths=1, linestyles='--')
ax1.contour(t1, t2, theta2, levels=[0], colors=['orange'], linewidths=1, linestyles='--')

ax1.plot(0, 0, 'ko', markersize=8, label='Origin (stable)')
ax1.set_xlabel('Parameter t₁', fontsize=11)
ax1.set_ylabel('Parameter t₂', fontsize=11)
ax1.set_title('2D Stability Region\n(Green = Stable)', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.2)

# ── Panel 2: 1D slice showing branches (top-right) ──
ax2 = fig.add_subplot(2, 2, 2)

t = np.linspace(0, 6, 500)

# Family of 6 branches
branches = [
    (-2.0, 0.8, 0.1),
    (-1.5, 0.3, 0.4),
    (-4.0, 1.2, 0.15),
    (-3.0, 0.6, 0.2),
    (-1.0, 0.1, 0.5),
    (-5.0, 2.0, 0.05),
]

colors_br = plt.cm.tab10(np.linspace(0, 1, len(branches)))
roots = []

for i, (a, b, c) in enumerate(branches):
    theta = a + b*t + c*t**2
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    roots.append(r)
    ax2.plot(t, theta, color=colors_br[i], linewidth=1.5, alpha=0.8)
    ax2.plot(r, 0, 'o', color=colors_br[i], markersize=6, zorder=5)

rho = min(roots)
ax2.axhline(y=0, color='k', linewidth=0.8)
ax2.axvline(x=rho, color='red', linewidth=2.5, linestyle='--', label=f'ρ = {rho:.2f}')

# Shade
ax2.fill_between(t, -8, 0, where=(t < rho), alpha=0.03, color='green')
ax2.fill_between(t, 0, 25, where=(t > rho), alpha=0.03, color='red')

ax2.set_xlabel('Parameter t', fontsize=11)
ax2.set_ylabel('θ(t)', fontsize=11)
ax2.set_title('6-Branch Eigenvalue Flow\nρ = min(first roots)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 6)
ax2.set_ylim(-8, 25)
ax2.grid(True, alpha=0.2)

# ── Panel 3: Monte Carlo stability radius distribution (bottom-left) ──
ax3 = fig.add_subplot(2, 2, 3)

n_trials = 2000
n_branches_mc = 5
radii = []

for _ in range(n_trials):
    trial_roots = []
    for _ in range(n_branches_mc):
        a = -np.random.uniform(0.5, 5)
        b = np.random.uniform(0, 2)
        c = np.random.uniform(0.1, 1.5)
        disc = b**2 - 4*a*c
        r = (-b + np.sqrt(disc)) / (2*c)
        trial_roots.append(r)
    radii.append(min(trial_roots))

radii = np.array(radii)

ax3.hist(radii, bins=80, density=True, color='steelblue', edgecolor='black',
         linewidth=0.3, alpha=0.7)
ax3.axvline(x=np.mean(radii), color='red', linewidth=2, linestyle='--',
            label=f'Mean ρ = {np.mean(radii):.2f}')
ax3.axvline(x=np.median(radii), color='orange', linewidth=2, linestyle='--',
            label=f'Median ρ = {np.median(radii):.2f}')

ax3.set_xlabel('Stability radius ρ', fontsize=11)
ax3.set_ylabel('Density', fontsize=11)
ax3.set_title(f'Distribution of ρ\n({n_trials} random {n_branches_mc}-branch families)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.2)

# ── Panel 4: Sensitivity analysis (bottom-right) ──
ax4 = fig.add_subplot(2, 2, 4)

# How does ρ depend on number of branches?
branch_counts = range(1, 21)
mean_radii = []
std_radii = []

for n_br in branch_counts:
    trial_radii = []
    for _ in range(500):
        tr = []
        for _ in range(n_br):
            a = -np.random.uniform(0.5, 5)
            b = np.random.uniform(0, 2)
            c = np.random.uniform(0.1, 1.5)
            disc = b**2 - 4*a*c
            r = (-b + np.sqrt(disc)) / (2*c)
            tr.append(r)
        trial_radii.append(min(tr))
    mean_radii.append(np.mean(trial_radii))
    std_radii.append(np.std(trial_radii))

mean_radii = np.array(mean_radii)
std_radii = np.array(std_radii)

ax4.plot(list(branch_counts), mean_radii, 'b-o', linewidth=2, markersize=5,
         label='Mean ρ')
ax4.fill_between(list(branch_counts), mean_radii - std_radii, mean_radii + std_radii,
                 alpha=0.2, color='blue', label='±1 std')

ax4.set_xlabel('Number of branches n', fontsize=11)
ax4.set_ylabel('Stability radius ρ', fontsize=11)
ax4.set_title('ρ Decreases with More Branches\n(Order Statistics Effect)', fontsize=12)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.2)

plt.suptitle('Nonlinear Spectral Stability: Complete Phase Portrait',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_stability_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_stability_landscape.png")
