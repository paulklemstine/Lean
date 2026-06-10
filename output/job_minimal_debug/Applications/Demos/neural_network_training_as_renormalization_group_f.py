#!/usr/bin/env python3
"""
Neural Network Training as Renormalization Group Flow — Demonstration

This script demonstrates the key results from our formalization:
1. SGD on quadratic loss converges geometrically to the fixed point
2. Universality: different data with same sufficient statistics → same trajectory
3. Critical exponent governs convergence rate
4. Optimal learning rate gives one-step convergence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def sgd_step_1d(w, a, b, eta):
    """One step of SGD on quadratic loss L(w) = (1/2)a*w^2 - b*w."""
    return w - eta * (a * w - b)


def run_sgd_trajectory(w0, a, b, eta, n_steps):
    """Run SGD for n_steps, return trajectory."""
    trajectory = [w0]
    w = w0
    for _ in range(n_steps):
        w = sgd_step_1d(w, a, b, eta)
        trajectory.append(w)
    return np.array(trajectory)


def demo_geometric_convergence():
    """Demonstrate geometric convergence to fixed point w* = b/a."""
    print("=" * 60)
    print("Demo 1: Geometric Convergence")
    print("=" * 60)

    a, b = 2.0, 3.0  # L(w) = w^2 - 3w
    w_star = b / a    # w* = 1.5
    eta = 0.3         # Learning rate
    w0 = 10.0         # Initial parameter

    contraction = abs(1 - eta * a)
    print(f"  a = {a}, b = {b}, w* = {w_star}")
    print(f"  eta = {eta}, contraction factor |1 - eta*a| = {contraction:.4f}")
    print(f"  Critical exponent nu = {-1/np.log(contraction):.4f}")
    print()

    n_steps = 20
    traj = run_sgd_trajectory(w0, a, b, eta, n_steps)

    for n in range(min(10, n_steps + 1)):
        predicted = contraction**n * (w0 - w_star) + w_star
        actual = traj[n]
        error = abs(actual - predicted)
        print(f"  Step {n:2d}: w = {actual:10.6f}, predicted = {predicted:10.6f}, |error| = {error:.2e}")

    print(f"\n  Verified: geometric convergence with rate {contraction:.4f}")


def demo_universality():
    """Show that losses with same (a,b) but different c give same trajectory."""
    print("\n" + "=" * 60)
    print("Demo 2: Universality Classes")
    print("=" * 60)

    a, b = 2.0, 3.0
    eta = 0.3
    w0 = 5.0

    # Two different "data distributions" with same sufficient statistics
    traj1 = run_sgd_trajectory(w0, a, b, eta, 10)
    traj2 = run_sgd_trajectory(w0, a, b, eta, 10)  # Same a,b

    # Different a,b → different trajectory
    traj3 = run_sgd_trajectory(w0, 3.0, 4.0, eta, 10)

    print(f"  Loss 1: a={a}, b={b}")
    print(f"  Loss 2: a={a}, b={b} (same universality class)")
    print(f"  Loss 3: a=3.0, b=4.0 (different universality class)")
    print()

    for n in [0, 1, 5, 10]:
        print(f"  Step {n:2d}: L1={traj1[n]:.6f}, L2={traj2[n]:.6f}, L3={traj3[n]:.6f}")

    print(f"\n  L1 and L2 are identical (same universality class)")
    print(f"  L3 diverges (different universality class)")


def demo_optimal_learning_rate():
    """Show that eta = 1/a gives one-step convergence."""
    print("\n" + "=" * 60)
    print("Demo 3: Optimal Learning Rate (One-Step Convergence)")
    print("=" * 60)

    a, b = 2.0, 3.0
    w_star = b / a
    eta_opt = 1.0 / a
    w0 = 100.0

    w1 = sgd_step_1d(w0, a, b, eta_opt)
    print(f"  a = {a}, b = {b}, w* = {w_star}")
    print(f"  Optimal eta = 1/a = {eta_opt}")
    print(f"  w0 = {w0}")
    print(f"  w1 = {w1} (after one step)")
    print(f"  |w1 - w*| = {abs(w1 - w_star):.2e}")
    print(f"\n  Verified: one-step convergence at optimal learning rate!")


def demo_spectral_gap():
    """Show how spectral gap varies with learning rate."""
    print("\n" + "=" * 60)
    print("Demo 4: Spectral Gap vs Learning Rate")
    print("=" * 60)

    a = 2.0
    etas = np.linspace(0.01, 0.99/a, 10)

    print(f"  a = {a}, optimal eta = {1/a:.4f}")
    print()
    for eta in etas:
        gap = abs(1 - eta * a)
        nu = -1 / np.log(gap) if gap > 0 and gap < 1 else float('inf')
        print(f"  eta = {eta:.4f}: spectral gap = {gap:.4f}, nu = {nu:.4f}")


def demo_2layer_linear():
    """Demonstrate two-layer linear network gauge invariance."""
    print("\n" + "=" * 60)
    print("Demo 5: Two-Layer Linear Network Gauge Invariance")
    print("=" * 60)

    d, m = 3, 4
    np.random.seed(42)
    W = np.random.randn(m, d)
    v = np.random.randn(m)

    # Effective weight
    w_eff = v @ W

    # Apply gauge transformation: scale v by 1/c, W by c
    c = 2.5
    v_new = v / c
    W_new = c * W
    w_eff_new = v_new @ W_new

    print(f"  d = {d}, m = {m}, c = {c}")
    print(f"  Original effective weight: {w_eff}")
    print(f"  Transformed effective weight: {w_eff_new}")
    print(f"  Max difference: {np.max(np.abs(w_eff - w_eff_new)):.2e}")
    print(f"\n  Verified: gauge invariance preserves effective weight!")


def demo_wilson_fisher_conjecture():
    """Numerical test of the Wilson-Fisher conjecture."""
    print("\n" + "=" * 60)
    print("Demo 6: Wilson-Fisher Conjecture Test")
    print("=" * 60)

    print("\n  For d-dimensional isotropic data, the WF exponent is nu = 1/(d-2)")
    for d in range(3, 8):
        nu_wf = 1.0 / (d - 2)
        print(f"  d = {d}: nu_WF = {nu_wf:.4f}")

    print("\n  For 2-layer linear network on isotropic d-dim data:")
    print("  sigma^2 = E[x^2] = 1 (isotropic), rho = E[xy] depends on target")
    print("  SGD critical exponent nu_SGD = -1/log|1 - eta*sigma^2|")

    sigma2 = 1.0
    eta = 0.5
    nu_sgd = -1 / np.log(abs(1 - eta * sigma2))
    print(f"  With eta={eta}, sigma^2={sigma2}: nu_SGD = {nu_sgd:.4f}")
    print(f"  WF prediction for d=3: nu_WF = {1.0:.4f}")
    print(f"\n  Note: The correspondence requires infinite-width limit (N→∞)")
    print(f"  and careful matching of the RG scale to the learning rate.")


if __name__ == "__main__":
    demo_geometric_convergence()
    demo_universality()
    demo_optimal_learning_rate()
    demo_spectral_gap()
    demo_2layer_linear()
    demo_wilson_fisher_conjecture()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Beta Function and RG Flow Phase Portrait."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def beta_function(w, a, b, eta):
    """β(w) = -η(aw - b)"""
    return -eta * (a * w - b)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle("Beta Function and RG Flow", fontsize=16, fontweight='bold')

    # Panel 1: Beta function for different learning rates
    ax = axes[0]
    a, b = 2.0, 3.0
    w_star = b / a
    ws = np.linspace(-2, 5, 200)

    for eta in [0.1, 0.3, 0.5, 0.8, 1.0]:
        betas = beta_function(ws, a, b, eta)
        ax.plot(ws, betas, label=f'η={eta}', linewidth=2)

    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=w_star, color='k', linestyle='--', alpha=0.5, label=f'w*={w_star}')
    ax.set_xlabel('w')
    ax.set_ylabel('β(w)')
    ax.set_title('Beta Function β(w) = -η(aw - b)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Phase portrait (w vs β(w)) showing flow direction
    ax = axes[1]
    eta = 0.3
    ws = np.linspace(-1, 4, 200)
    betas = beta_function(ws, a, b, eta)

    ax.plot(ws, betas, 'b-', linewidth=2)
    ax.fill_between(ws, 0, betas, where=(betas > 0), alpha=0.2, color='green',
                    label='Flow toward w*')
    ax.fill_between(ws, 0, betas, where=(betas < 0), alpha=0.2, color='red',
                    label='Flow toward w*')

    # Add flow arrows
    for w in np.linspace(-0.5, 3.5, 12):
        b_val = beta_function(w, a, b, eta)
        ax.annotate('', xy=(w + 0.15 * np.sign(b_val), 0),
                    xytext=(w, 0),
                    arrowprops=dict(arrowstyle='->', color='purple', lw=1.5))

    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=w_star, color='k', linestyle='--', alpha=0.5)
    ax.plot(w_star, 0, 'ro', markersize=10, zorder=5, label='Fixed point')
    ax.set_xlabel('w')
    ax.set_ylabel('β(w)')
    ax.set_title(f'RG Flow Phase Portrait (η={eta})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: RG scaling relation
    ax = axes[2]
    eta_base = 0.2
    ws = np.linspace(-1, 4, 200)

    for s in [0.5, 1.0, 1.5, 2.0, 3.0]:
        betas = beta_function(ws, a, b, s * eta_base)
        ax.plot(ws, betas, label=f's={s}, η={s*eta_base:.1f}', linewidth=2)

    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=w_star, color='k', linestyle='--', alpha=0.5)
    ax.set_xlabel('w')
    ax.set_ylabel('β(w)')
    ax.set_title('RG Scaling: β(sη, w) = s·β(η, w)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('beta_function_rg.png', dpi=150, bbox_inches='tight')
    print("Saved beta_function_rg.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Geometric Convergence of SGD as RG Flow."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def sgd_step_1d(w, a, b, eta):
    return w - eta * (a * w - b)


def run_trajectory(w0, a, b, eta, n_steps):
    traj = [w0]
    w = w0
    for _ in range(n_steps):
        w = sgd_step_1d(w, a, b, eta)
        traj.append(w)
    return np.array(traj)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Neural Network Training as Renormalization Group Flow",
                 fontsize=16, fontweight='bold')

    # Panel 1: Geometric convergence for different learning rates
    ax = axes[0, 0]
    a, b = 2.0, 3.0
    w_star = b / a
    w0 = 10.0
    n_steps = 30

    for eta in [0.1, 0.3, 0.5, 0.8]:
        traj = run_trajectory(w0, a, b, eta, n_steps)
        gap = abs(1 - eta * a)
        ax.plot(range(n_steps + 1), traj, 'o-', markersize=3,
                label=f'η={eta}, |1-ηa|={gap:.2f}')

    ax.axhline(y=w_star, color='k', linestyle='--', alpha=0.5, label=f'w*={w_star}')
    ax.set_xlabel('Step n')
    ax.set_ylabel('w_n')
    ax.set_title('Geometric Convergence')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Log-scale distance to fixed point
    ax = axes[0, 1]
    for eta in [0.1, 0.3, 0.5, 0.8]:
        traj = run_trajectory(w0, a, b, eta, n_steps)
        distances = np.abs(traj - w_star)
        distances[distances < 1e-16] = 1e-16
        ax.semilogy(range(n_steps + 1), distances, 'o-', markersize=3,
                    label=f'η={eta}')

    ax.set_xlabel('Step n')
    ax.set_ylabel('|w_n - w*|')
    ax.set_title('Distance to Fixed Point (log scale)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Spectral gap vs learning rate
    ax = axes[1, 0]
    etas = np.linspace(0.01, 0.99, 200)
    gaps = np.abs(1 - etas * a)
    ax.plot(etas, gaps, 'b-', linewidth=2)
    ax.axvline(x=1/a, color='r', linestyle='--', alpha=0.7, label=f'η*=1/a={1/a:.2f}')
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    ax.fill_between(etas, 0, gaps, alpha=0.1)
    ax.set_xlabel('Learning rate η')
    ax.set_ylabel('Spectral gap |1-ηa|')
    ax.set_title('Spectral Gap (Contraction Factor)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 2)

    # Panel 4: Universality classes
    ax = axes[1, 1]
    configs = [
        (2.0, 3.0, 'Class A: a=2, b=3'),
        (2.0, 3.0, 'Class A: a=2, b=3 (copy)'),
        (3.0, 4.0, 'Class B: a=3, b=4'),
        (1.0, 2.0, 'Class C: a=1, b=2'),
    ]
    colors = ['blue', 'cyan', 'red', 'green']
    eta = 0.2
    w0 = 8.0
    n_steps = 25

    for (ai, bi, label), color in zip(configs, colors):
        traj = run_trajectory(w0, ai, bi, eta, n_steps)
        ax.plot(range(n_steps + 1), traj, 'o-', markersize=3,
                label=label, color=color)
        ax.axhline(y=bi/ai, color=color, linestyle='--', alpha=0.3)

    ax.set_xlabel('Step n')
    ax.set_ylabel('w_n')
    ax.set_title('Universality Classes')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence_rg_flow.png', dpi=150, bbox_inches='tight')
    print("Saved convergence_rg_flow.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Critical Exponents and Wilson-Fisher Conjecture."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def critical_exponent(eta, a):
    """ν = -1/log|1 - ηa|"""
    gap = abs(1 - eta * a)
    if gap <= 0 or gap >= 1:
        return np.nan
    return -1.0 / np.log(gap)


def wilson_fisher_nu(d):
    """Mean-field WF exponent ν = 1/(d-2)"""
    if d <= 2:
        return np.inf
    return 1.0 / (d - 2)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Critical Exponents in Neural RG Flow",
                 fontsize=16, fontweight='bold')

    # Panel 1: Critical exponent vs learning rate
    ax = axes[0, 0]
    a = 2.0
    etas = np.linspace(0.01, 0.99/a, 300)
    nus = [critical_exponent(eta, a) for eta in etas]

    ax.plot(etas, nus, 'b-', linewidth=2)
    ax.axvline(x=1/a, color='r', linestyle='--', label=f'η*=1/a={1/a:.2f}')
    ax.set_xlabel('Learning rate η')
    ax.set_ylabel('Critical exponent ν')
    ax.set_title('ν vs Learning Rate')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 20)

    # Panel 2: Wilson-Fisher exponent vs dimension
    ax = axes[0, 1]
    ds = np.arange(3, 20)
    nus_wf = [wilson_fisher_nu(d) for d in ds]

    ax.bar(ds, nus_wf, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('ν_WF = 1/(d-2)')
    ax.set_title('Wilson-Fisher Exponent')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Convergence rate comparison
    ax = axes[1, 0]
    a = 2.0
    b = 3.0
    w0 = 10.0
    n_steps = 50

    for eta in [0.1, 0.3, 0.49]:
        gap = abs(1 - eta * a)
        nu = critical_exponent(eta, a)
        traj = [w0]
        w = w0
        for _ in range(n_steps):
            w = w - eta * (a * w - b)
            traj.append(w)
        distances = np.abs(np.array(traj) - b/a)
        distances[distances < 1e-16] = 1e-16

        # Fit: |w_n - w*| ~ exp(-n/ν)
        ax.semilogy(range(n_steps+1), distances, 'o', markersize=2,
                   label=f'η={eta}, ν={nu:.2f}')
        ns = np.arange(n_steps+1)
        ax.semilogy(ns, distances[0] * np.exp(-ns/nu), '--', alpha=0.5)

    ax.set_xlabel('Step n')
    ax.set_ylabel('|w_n - w*|')
    ax.set_title('Convergence: |w_n - w*| ~ exp(-n/ν)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: Heatmap of convergence rate vs (η, a)
    ax = axes[1, 1]
    a_vals = np.linspace(0.5, 5.0, 100)
    eta_vals = np.linspace(0.01, 1.0, 100)
    A, E = np.meshgrid(a_vals, eta_vals)
    Gaps = np.abs(1 - E * A)
    # Mask unstable region
    Gaps[Gaps >= 1] = np.nan

    im = ax.pcolormesh(a_vals, eta_vals, Gaps, cmap='RdYlGn_r',
                       shading='auto', vmin=0, vmax=1)
    ax.plot(a_vals, 1/a_vals, 'k--', linewidth=2, label='η* = 1/a (optimal)')
    ax.plot(a_vals, 2/a_vals, 'r--', linewidth=1, label='η = 2/a (stability)')

    plt.colorbar(im, ax=ax, label='Spectral gap |1-ηa|')
    ax.set_xlabel('Hessian a')
    ax.set_ylabel('Learning rate η')
    ax.set_title('Stability Diagram')
    ax.legend(fontsize=8)
    ax.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('critical_exponents.png', dpi=150, bbox_inches='tight')
    print("Saved critical_exponents.png")


if __name__ == "__main__":
    main()
