#!/usr/bin/env python3
"""
Epistemic Valley Theory — Numerical Demonstrations

Demonstrates the uncanny valley phenomenon in mathematical proof evaluation:
the phase transition at α = 4, valley depth, valley width, and the universal
epistemic barrier.
"""

import math


def suspicion(r: float) -> float:
    """Suspicion function S(r) = r²(1-r)."""
    return r**2 * (1 - r)


def trust(alpha: float, r: float) -> float:
    """Trust function U(r) = r - α·S(r)."""
    return r - alpha * suspicion(r)


def valley_boundaries(alpha: float) -> tuple[float, float] | None:
    """
    Compute the valley boundaries for α > 4.
    Returns (a, b) where trust(α, a) = trust(α, b) = 0 and trust < 0 on (a, b).
    Returns None if α ≤ 4 (no valley).
    """
    disc = alpha**2 - 4 * alpha
    if disc <= 0:
        return None
    sqrt_disc = math.sqrt(disc)
    a = (alpha - sqrt_disc) / (2 * alpha)
    b = (alpha + sqrt_disc) / (2 * alpha)
    return (a, b)


def critical_sensitivity_general(S, r_values):
    """
    Compute the critical sensitivity for a general suspicion function.
    α* = inf { c / S(c) : c ∈ (0,1), S(c) > 0 }
    """
    alpha_star = float('inf')
    for r in r_values:
        s = S(r)
        if s > 0:
            alpha_star = min(alpha_star, r / s)
    return alpha_star


def main():
    print("=" * 60)
    print("EPISTEMIC VALLEY THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Phase transition at α = 4
    print("\n--- Demo 1: Phase Transition at α = 4 ---")
    print(f"{'α':>6}  {'trust(α, 1/2)':>14}  {'Valley?':>8}")
    print("-" * 32)
    for alpha in [1, 2, 3, 3.5, 3.9, 4.0, 4.1, 5, 6, 8, 10]:
        t = trust(alpha, 0.5)
        valley = "YES" if t < 0 else ("BOUNDARY" if abs(t) < 1e-10 else "NO")
        print(f"{alpha:6.1f}  {t:14.6f}  {valley:>8}")

    # Demo 2: Trust function values across rigor levels
    print("\n--- Demo 2: Trust at Various Rigor Levels (α = 6) ---")
    alpha = 6.0
    print(f"{'r':>6}  {'S(r)':>10}  {'trust(r)':>10}")
    print("-" * 30)
    for i in range(11):
        r = i / 10.0
        print(f"{r:6.2f}  {suspicion(r):10.4f}  {trust(alpha, r):10.4f}")

    # Demo 3: Valley boundaries
    print("\n--- Demo 3: Valley Boundaries ---")
    print(f"{'α':>6}  {'a (left)':>10}  {'b (right)':>10}  {'width':>8}")
    print("-" * 38)
    for alpha in [4.1, 5, 6, 8, 10, 20, 50]:
        bounds = valley_boundaries(alpha)
        if bounds:
            a, b = bounds
            print(f"{alpha:6.1f}  {a:10.4f}  {b:10.4f}  {b-a:8.4f}")

    # Demo 4: Suspicion peak
    print("\n--- Demo 4: Suspicion Peak ---")
    print(f"Suspicion at r=2/3: S(2/3) = {suspicion(2/3):.6f}")
    print(f"Expected: 4/27 = {4/27:.6f}")
    print(f"Verified: {abs(suspicion(2/3) - 4/27) < 1e-12}")

    # Demo 5: Epistemic Barrier (Universal)
    print("\n--- Demo 5: Epistemic Barrier for Custom Suspicion ---")
    # Try different admissible suspicion functions
    suspicion_fns = [
        ("r²(1-r)", lambda r: r**2 * (1-r)),
        ("r(1-r)", lambda r: r * (1-r)),
        ("r(1-r)²", lambda r: r * (1-r)**2),
        ("sin(πr)/π", lambda r: math.sin(math.pi * r) / math.pi if 0 < r < 1 else 0.0),
        ("r²(1-r)²", lambda r: r**2 * (1-r)**2),
    ]
    r_vals = [i / 1000 for i in range(1, 1000)]
    for name, S in suspicion_fns:
        alpha_star = critical_sensitivity_general(S, r_vals)
        print(f"  S(r) = {name:15s}  →  α* ≈ {alpha_star:.4f}")

    # Demo 6: Energy landscape interpretation
    print("\n--- Demo 6: Energy Barrier Height ---")
    print(f"{'α':>6}  {'max energy':>12}  {'at r':>8}")
    print("-" * 30)
    for alpha in [4, 4.5, 5, 6, 8, 10]:
        max_e = 0
        max_r = 0
        for i in range(1, 1000):
            r = i / 1000.0
            e = -trust(alpha, r)
            if e > max_e:
                max_e = e
                max_r = r
        print(f"{alpha:6.1f}  {max_e:12.6f}  {max_r:8.3f}")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Epistemic energy barrier and gradient flow trajectories."""

import numpy as np

def suspicion(r):
    return r**2 * (1 - r)

def trust(alpha, r):
    return r - alpha * suspicion(r)

def trust_deriv(alpha, r):
    return 1 - 2*alpha*r + 3*alpha*r**2

def main():
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot.")
        return

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    r = np.linspace(0, 1, 500)
    
    # Panel 1: Energy landscape comparison
    ax = axes[0]
    for alpha, color, label in [(3, 'green', 'α=3 (subcritical)'),
                                  (4, 'orange', 'α=4 (critical)'),
                                  (6, 'red', 'α=6 (supercritical)'),
                                  (10, 'darkred', 'α=10 (deep valley)')]:
        energy = -trust(alpha, r)
        ax.plot(r, energy, color=color, linewidth=2, label=label)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Rigor level r', fontsize=12)
    ax.set_ylabel('Epistemic energy E(r) = -U(r)', fontsize=12)
    ax.set_title('Energy Barrier Landscape', fontsize=14)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 1)
    ax.grid(True, alpha=0.3)

    # Panel 2: Gradient flow trajectories
    ax = axes[1]
    alpha = 6.0
    dt = 0.002
    n_steps = 2000
    initial_conditions = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95]
    
    for r0 in initial_conditions:
        traj = [r0]
        rv = r0
        for _ in range(n_steps):
            dr = trust_deriv(alpha, rv)
            rv = rv + dt * dr
            rv = max(0.0, min(1.0, rv))
            traj.append(rv)
        t = np.arange(len(traj)) * dt
        color = 'blue' if traj[-1] > 0.5 else 'red'
        ax.plot(t, traj, color=color, alpha=0.6, linewidth=1.2)
    
    ax.axhline(y=1.0, color='blue', linestyle='--', alpha=0.3, label='Full rigor (attractor)')
    fixed_pts = np.roots([3*alpha, -2*alpha, 1])
    for fp in fixed_pts:
        if 0 < fp.real < 1 and abs(fp.imag) < 1e-10:
            ax.axhline(y=fp.real, color='gray', linestyle=':', alpha=0.5)
    
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Rigor level r(t)', fontsize=12)
    ax.set_title(f'Gradient Flow Trajectories (α={alpha})', fontsize=14)
    ax.set_xlim(0, n_steps * dt)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('epistemic_energy_barrier.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: epistemic_energy_barrier.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Trust function landscape across suspicion sensitivities."""

import numpy as np

def suspicion(r):
    return r**2 * (1 - r)

def trust(alpha, r):
    return r - alpha * suspicion(r)

def main():
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot.")
        return

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    r = np.linspace(0, 1, 500)
    
    # Panel 1: Trust for various α
    ax = axes[0]
    alphas = [0, 2, 3, 4, 5, 6, 8]
    colors = plt.cm.RdYlBu_r(np.linspace(0.1, 0.9, len(alphas)))
    for alpha, color in zip(alphas, colors):
        t = trust(alpha, r)
        style = '--' if alpha == 4 else '-'
        lw = 2.5 if alpha == 4 else 1.5
        ax.plot(r, t, style, color=color, linewidth=lw, label=f'α={alpha}')
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.fill_between(r, trust(6, r), 0, where=trust(6, r) < 0, alpha=0.15, color='red')
    ax.set_xlabel('Rigor level r', fontsize=12)
    ax.set_ylabel('Trust U(r)', fontsize=12)
    ax.set_title('Trust Landscape', fontsize=14)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.5, 1.1)
    ax.grid(True, alpha=0.3)

    # Panel 2: Valley depth vs α
    ax = axes[1]
    alphas_range = np.linspace(0, 12, 500)
    depth = np.maximum(0, alphas_range / 8 - 0.5)
    ax.plot(alphas_range, depth, 'b-', linewidth=2)
    ax.axvline(x=4, color='red', linestyle='--', linewidth=1.5, label='α* = 4')
    ax.fill_between(alphas_range, depth, 0, where=depth > 0, alpha=0.15, color='blue')
    ax.set_xlabel('Suspicion sensitivity α', fontsize=12)
    ax.set_ylabel('Valley depth', fontsize=12)
    ax.set_title('Phase Transition at α = 4', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 12)
    ax.grid(True, alpha=0.3)

    # Panel 3: Valley boundaries
    ax = axes[2]
    alphas_sup = np.linspace(4.01, 20, 500)
    a_vals = (alphas_sup - np.sqrt(alphas_sup**2 - 4*alphas_sup)) / (2*alphas_sup)
    b_vals = (alphas_sup + np.sqrt(alphas_sup**2 - 4*alphas_sup)) / (2*alphas_sup)
    ax.fill_between(alphas_sup, a_vals, b_vals, alpha=0.3, color='red', label='Valley region')
    ax.plot(alphas_sup, a_vals, 'r-', linewidth=1.5)
    ax.plot(alphas_sup, b_vals, 'r-', linewidth=1.5)
    ax.plot([4], [0.5], 'ko', markersize=8, zorder=5, label='Critical point (4, 1/2)')
    ax.set_xlabel('Suspicion sensitivity α', fontsize=12)
    ax.set_ylabel('Rigor level r', fontsize=12)
    ax.set_title('Valley Boundaries', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(4, 20)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('epistemic_valley_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: epistemic_valley_landscape.png")


if __name__ == "__main__":
    main()
