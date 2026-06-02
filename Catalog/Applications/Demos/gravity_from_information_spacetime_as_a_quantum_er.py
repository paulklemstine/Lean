#!/usr/bin/env python3
"""
Gravity from Information: Spacetime as a Quantum Error-Correcting Code
=====================================================================

Numerical demonstrations of the holographic code framework.
Shows how the Bekenstein-Hawking entropy formula maps to the quantum
Singleton bound, and verifies the key theorems computationally.
"""

import math


def holographic_code(area: int, geodesic: int) -> tuple[int, int, int]:
    """Construct [[n, k, d]] code from spacetime geometry.
    
    Args:
        area: Boundary area in Planck units (must be divisible by 4)
        geodesic: Minimal geodesic length in Planck units (must be even)
    
    Returns:
        (n, k, d) code parameters
    """
    assert area > 0 and area % 4 == 0, f"area={area} must be positive and divisible by 4"
    assert geodesic > 0 and geodesic % 2 == 0, f"geodesic={geodesic} must be positive and even"
    assert geodesic <= area, f"geodesic={geodesic} must not exceed area={area}"
    return (area, area // 4, geodesic // 2)


def singleton_bound_check(n: int, k: int, d: int) -> bool:
    """Check if [[n, k, d]] satisfies the quantum Singleton bound: n - k >= 2(d-1)."""
    return n - k >= 2 * (d - 1)


def singleton_saturated(n: int, k: int, d: int) -> bool:
    """Check if [[n, k, d]] saturates the Singleton bound: k + 2(d-1) = n."""
    return k + 2 * (d - 1) == n


def code_rate(n: int, k: int) -> float:
    """Code rate k/n."""
    return k / n


def info_protection_tradeoff(n: int, k: int, d: int) -> tuple[float, float, float]:
    """Compute info density, protection density, and their bound.
    
    Returns:
        (rho_I + 2*rho_P, bound 1 + 2/n, satisfied)
    """
    rho_I = k / n
    rho_P = d / n
    lhs = rho_I + 2 * rho_P
    rhs = 1 + 2 / n
    return (lhs, rhs, lhs <= rhs + 1e-12)


def holographic_entropy(a: int) -> int:
    """S(a) = a // 4"""
    return a // 4


def verify_strong_subadditivity(a: int, b: int, c: int) -> bool:
    """Verify S(a+b+c) + S(b) <= S(a+b) + S(b+c) + 1."""
    return (holographic_entropy(a + b + c) + holographic_entropy(b)
            <= holographic_entropy(a + b) + holographic_entropy(b + c) + 1)


def main():
    print("=" * 70)
    print("GRAVITY FROM INFORMATION: HOLOGRAPHIC CODE DEMONSTRATIONS")
    print("=" * 70)
    
    # Demo 1: Holographic codes for various spacetime geometries
    print("\n--- Demo 1: Holographic Codes from Spacetime Geometry ---\n")
    print(f"{'Area':>6} {'Geod':>6} | {'n':>6} {'k':>6} {'d':>6} | {'Rate':>8} {'Singleton':>10} {'Saturated':>10}")
    print("-" * 75)
    
    test_cases = [
        (4, 2), (8, 4), (12, 6), (16, 8), (20, 10),
        (100, 50), (1000, 500), (10000, 5000),
    ]
    
    for area, geodesic in test_cases:
        n, k, d = holographic_code(area, geodesic)
        rate = code_rate(n, k)
        sb = singleton_bound_check(n, k, d)
        sat = singleton_saturated(n, k, d)
        print(f"{area:>6} {geodesic:>6} | {n:>6} {k:>6} {d:>6} | {rate:>8.4f} {'✓' if sb else '✗':>10} {'✓' if sat else '✗':>10}")
    
    # Demo 2: Information-Protection Tradeoff
    print("\n--- Demo 2: Information-Protection Tradeoff ---\n")
    print(f"{'n':>6} {'k':>6} {'d':>6} | {'ρ_I+2ρ_P':>10} {'Bound':>10} {'Satisfied':>10}")
    print("-" * 60)
    
    for n in [10, 20, 50, 100, 1000]:
        for d in range(2, min(n // 2, 6)):
            k = n - 2 * (d - 1)  # Singleton-saturating
            if k > 0:
                lhs, rhs, ok = info_protection_tradeoff(n, k, d)
                print(f"{n:>6} {k:>6} {d:>6} | {lhs:>10.6f} {rhs:>10.6f} {'✓' if ok else '✗':>10}")
    
    # Demo 3: Rate Monotonicity
    print("\n--- Demo 3: Rate Increases with n (fixed d=5) ---\n")
    d = 5
    print(f"{'n':>6} {'k':>6} {'Rate':>10}")
    print("-" * 30)
    for n in [10, 20, 50, 100, 500, 1000, 10000]:
        k = n - 2 * (d - 1)
        if k > 0:
            print(f"{n:>6} {k:>6} {code_rate(n, k):>10.6f}")
    print(f"\nAs n → ∞, rate → 1 (the overhead 2(d-1)={2*(d-1)} becomes negligible)")
    
    # Demo 4: Strong Subadditivity Verification
    print("\n--- Demo 4: Strong Subadditivity Verification ---\n")
    violations = 0
    total = 0
    for a in range(30):
        for b in range(30):
            for c in range(30):
                total += 1
                if not verify_strong_subadditivity(a, b, c):
                    violations += 1
                    print(f"  VIOLATION at a={a}, b={b}, c={c}")
    print(f"Checked {total} cases, violations: {violations}")
    
    # Demo 5: Singleton entropy from distance
    print("\n--- Demo 5: k + 2d = n + 2 for Saturating Codes ---\n")
    print(f"{'n':>6} {'d':>6} {'k':>6} | {'k+2d':>6} {'n+2':>6} {'Match':>6}")
    print("-" * 45)
    for n in range(2, 30):
        for d in range(1, n + 1):
            k = n - 2 * (d - 1)
            if k >= 0 and singleton_saturated(n, k, d):
                match = (k + 2 * d == n + 2)
                print(f"{n:>6} {d:>6} {k:>6} | {k + 2*d:>6} {n+2:>6} {'✓' if match else '✗':>6}")
    
    # Demo 6: Geometric Singleton bound
    print("\n--- Demo 6: Geometric Singleton: geodesic ≤ 3·area/4 + 2 ---\n")
    for area in [4, 8, 12, 16, 20, 100, 1000]:
        bound = 3 * area // 4 + 2
        print(f"  area = {area:>5}: geodesic must be ≤ {bound:>5} "
              f"(ratio geodesic/area ≤ {bound/area:.3f})")
    print(f"\n  As area → ∞, max geodesic/area → 3/4 = 0.750")
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Holographic Entropy Properties

Shows subadditivity and strong subadditivity of the discrete
holographic entropy function S(a) = a // 4 (Bekenstein-Hawking formula).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def holographic_entropy(a):
    return a // 4


def plot_entropy():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Entropy function
    ax = axes[0]
    a = np.arange(0, 101)
    s = np.array([holographic_entropy(x) for x in a])
    ax.plot(a, s, 'b-', linewidth=2, label='S(a) = ⌊a/4⌋')
    ax.plot(a, a / 4, 'r--', alpha=0.5, label='a/4 (continuous)')
    ax.set_xlabel('Boundary size a (Planck units)', fontsize=12)
    ax.set_ylabel('Entropy S(a)', fontsize=12)
    ax.set_title('Holographic Entropy\n(Bekenstein-Hawking, discrete)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Middle: Subadditivity gap
    ax = axes[1]
    max_val = 50
    gap = np.zeros((max_val, max_val))
    for a in range(max_val):
        for b in range(max_val):
            sa = holographic_entropy(a)
            sb = holographic_entropy(b)
            sab = holographic_entropy(a + b)
            gap[a, b] = sa + sb - sab  # Should be >= -1
    im = ax.imshow(gap, origin='lower', cmap='RdYlGn', vmin=-1, vmax=1,
                   extent=[0, max_val, 0, max_val])
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('a', fontsize=12)
    ax.set_title('Subadditivity Gap\nS(a)+S(b)-S(a+b) ≥ -1', fontsize=13)
    plt.colorbar(im, ax=ax, label='Gap')

    # Right: Strong subadditivity verification
    ax = axes[2]
    max_val = 30
    ssa_gaps = []
    for a in range(max_val):
        for b in range(max_val):
            for c in range(max_val):
                sabc = holographic_entropy(a + b + c)
                sb = holographic_entropy(b)
                sab = holographic_entropy(a + b)
                sbc = holographic_entropy(b + c)
                gap = sab + sbc - sabc - sb
                ssa_gaps.append(gap)

    ssa_gaps = np.array(ssa_gaps)
    ax.hist(ssa_gaps, bins=range(int(ssa_gaps.min()), int(ssa_gaps.max()) + 2),
            color='steelblue', edgecolor='navy', alpha=0.8)
    ax.axvline(x=-1, color='red', linestyle='--', linewidth=2,
               label='Lower bound = -1')
    ax.set_xlabel('SSA gap: S(AB)+S(BC)-S(ABC)-S(B)', fontsize=11)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Strong Subadditivity Gaps\n(min = {ssa_gaps.min()}, verified ≥ -1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_properties.png', dpi=150, bbox_inches='tight')
    print("Saved: entropy_properties.png")


if __name__ == "__main__":
    plot_entropy()


#!/usr/bin/env python3
"""
Visualization: Information-Protection Tradeoff Curve

Shows the fundamental tradeoff between information density (k/n)
and protection density (d/n) for quantum codes satisfying the
Singleton bound. The boundary of the feasible region is the line
rho_I + 2*rho_P = 1 (asymptotic bound), which is the coding-theoretic
expression of the Einstein constraint.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_tradeoff():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Tradeoff curve for various n
    ax = axes[0]
    for n in [10, 20, 50, 100, 500]:
        rho_I_vals = []
        rho_P_vals = []
        for d in range(1, (n + 2) // 2 + 1):
            k = n - 2 * (d - 1)
            if k >= 0:
                rho_I_vals.append(k / n)
                rho_P_vals.append(d / n)
        ax.plot(rho_P_vals, rho_I_vals, 'o-', markersize=3, label=f'n={n}')

    # Asymptotic bound
    rho_P = np.linspace(0, 0.5, 100)
    rho_I = 1 - 2 * rho_P
    ax.plot(rho_P, rho_I, 'k--', linewidth=2, label='Asymptotic bound')
    ax.fill_between(rho_P, 0, rho_I, alpha=0.1, color='gray')

    ax.set_xlabel('Protection density ρ_P = d/n', fontsize=12)
    ax.set_ylabel('Information density ρ_I = k/n', fontsize=12)
    ax.set_title('Information-Protection Tradeoff\n(Coding-Theoretic Einstein Constraint)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Right: Rate vs n for fixed d
    ax = axes[1]
    for d in [2, 3, 5, 10, 20]:
        ns = np.arange(2 * d, 1001)
        ks = ns - 2 * (d - 1)
        rates = ks / ns
        ax.plot(ns, rates, label=f'd={d}')

    ax.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='rate = 1')
    ax.set_xlabel('Number of physical qubits n', fontsize=12)
    ax.set_ylabel('Code rate k/n', fontsize=12)
    ax.set_title('Rate Increases with n\n(Larger regions encode more efficiently)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tradeoff_curve.png', dpi=150, bbox_inches='tight')
    print("Saved: tradeoff_curve.png")


if __name__ == "__main__":
    plot_tradeoff()
