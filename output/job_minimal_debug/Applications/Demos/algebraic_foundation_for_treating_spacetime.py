#!/usr/bin/env python3
"""
Demo: Holographic Quantum Error-Correcting Codes

Numerical examples demonstrating the Bekenstein-Singleton correspondence,
the quantum Singleton bound, Page curve dynamics, and holographic entropy
cone constraints.
"""

from algorithms import QCode, PageCurve, verify_bekenstein_singleton, entropy_density


def demo_singleton_bound():
    """Demonstrate the quantum Singleton bound for various codes."""
    print("=" * 60)
    print("QUANTUM SINGLETON BOUND: n - k >= 2(d - 1)")
    print("=" * 60)

    codes = [
        QCode(n=5, k=1, d=3),   # [[5,1,3]] perfect code
        QCode(n=7, k=1, d=3),   # Steane code
        QCode(n=9, k=1, d=3),   # Shor code (non-MDS)
        QCode(n=4, k=2, d=2),   # Small MDS code
        QCode(n=6, k=0, d=4),   # Pure error-detecting
    ]

    for c in codes:
        gap = c.redundancy - 2 * (c.d - 1)
        status = "MDS (saturated)" if c.is_mds else f"gap = {gap}"
        print(f"  [[{c.n},{c.k},{c.d}]]: n-k={c.redundancy}, "
              f"2(d-1)={2*(c.d-1)}, {status}")
    print()


def demo_bekenstein_singleton():
    """Demonstrate the Bekenstein-Singleton correspondence."""
    print("=" * 60)
    print("BEKENSTEIN-SINGLETON CORRESPONDENCE")
    print("For MDS codes: BH entropy = Singleton entropy")
    print("=" * 60)

    # Generate all MDS codes up to n=20
    mds_codes = []
    for n in range(2, 21):
        for d in range(1, n // 2 + 2):
            k = n - 2 * (d - 1)
            if 0 <= k <= n:
                try:
                    c = QCode(n=n, k=k, d=d)
                    if c.is_mds:
                        mds_codes.append(c)
                except:
                    pass

    print(f"\n  Found {len(mds_codes)} MDS codes with n <= 20:\n")
    print(f"  {'Code':>12}  {'Rate':>6}  {'S_BH':>6}  {'S_Sing':>7}  {'Match':>6}")
    print(f"  {'-'*12}  {'-'*6}  {'-'*6}  {'-'*7}  {'-'*6}")

    for c in mds_codes[:15]:  # Show first 15
        match = verify_bekenstein_singleton(c)
        code_str = f"[[{c.n},{c.k},{c.d}]]"
        pad = ' ' * max(0, 12 - len(code_str))
        mark = '✓' if match else '✗'
        print(f"  {code_str}{pad}  {c.rate:6.3f}  {c.bekenstein_hawking_entropy:6.2f}"
              f"  {c.singleton_entropy:7.2f}  {mark:>6}")
    print()


def demo_entropy_density():
    """Demonstrate the universal entropy density bound <= 1/2."""
    print("=" * 60)
    print("ENTROPY DENSITY BOUND: (n-k)/(2n) <= 1/2")
    print("=" * 60)

    max_density = 0.0
    max_code = None

    for n in range(2, 51):
        for d in range(1, n // 2 + 2):
            k = n - 2 * (d - 1)
            if 0 <= k <= n:
                try:
                    c = QCode(n=n, k=k, d=d)
                    ed = entropy_density(c)
                    if ed > max_density:
                        max_density = ed
                        max_code = c
                except:
                    pass

    print(f"\n  Maximum entropy density found: {max_density:.6f}")
    if max_code:
        print(f"  Achieved by: [[{max_code.n},{max_code.k},{max_code.d}]]")
    print(f"  Universal bound: 0.500000")
    print(f"  Bound satisfied: {max_density <= 0.5 + 1e-12}")
    print()


def demo_page_curve():
    """Demonstrate the Page curve for a dynamical code family."""
    print("=" * 60)
    print("PAGE CURVE: Radiation entropy vs. time")
    print("=" * 60)

    n = 20
    page_time = 10
    pc = PageCurve(n=n, page_time=page_time)

    print(f"\n  System size n = {n}, Page time = {page_time}\n")
    print(f"  {'Time':>6}  {'k(t)':>6}  {'d(t)':>6}  {'Rate':>6}  {'MDS':>5}")
    print(f"  {'-'*6}  {'-'*6}  {'-'*6}  {'-'*6}  {'-'*5}")

    for t in range(0, 21):
        code = pc.code_at(t)
        print(f"  {t:6d}  {code.k:6d}  {code.d:6d}  {code.rate:6.3f}  "
              f"{'✓' if code.is_mds else ' ':>5}")

    # Verify Page curve properties
    print(f"\n  Page curve properties:")
    print(f"  k(0) = {pc.k(0)} <= k(page_time) = {pc.k(page_time)}: "
          f"{pc.k(0) <= pc.k(page_time)}")

    all_mono_before = all(
        pc.k(t) <= pc.k(t + 1) for t in range(page_time)
    )
    all_mono_after = all(
        pc.k(t + 1) <= pc.k(t) for t in range(page_time, 20)
    )
    print(f"  Monotone increasing before Page time: {all_mono_before}")
    print(f"  Monotone decreasing after Page time: {all_mono_after}")
    print()


def demo_holographic_entropy_cone():
    """Demonstrate SSA and MMI constraints on 3-party entropy vectors."""
    print("=" * 60)
    print("HOLOGRAPHIC ENTROPY CONE: SSA + MMI constraints")
    print("=" * 60)

    # Example 1: GHZ state (holographic)
    # S(A) = S(B) = S(C) = 1, S(AB) = S(AC) = S(BC) = 1, S(ABC) = 0
    print("\n  GHZ state (3 qubits):")
    S_ghz = {1: 1, 1: 1, 1: 1}  # All single-party entropies = 1
    A, B, C = 1.0, 1.0, 1.0
    AB, AC, BC, ABC = 1.0, 1.0, 1.0, 0.0

    ssa_check = AB + BC >= ABC + B
    mmi_check = AB + AC + BC <= A + B + C + ABC

    print(f"  S(A)={A}, S(B)={B}, S(C)={C}")
    print(f"  S(AB)={AB}, S(AC)={AC}, S(BC)={BC}, S(ABC)={ABC}")
    print(f"  SSA: S(AB)+S(BC) >= S(ABC)+S(B): {AB+BC} >= {ABC+B}: {ssa_check}")
    print(f"  MMI: S(AB)+S(AC)+S(BC) <= S(A)+S(B)+S(C)+S(ABC): "
          f"{AB+AC+BC} <= {A+B+C+ABC}: {mmi_check}")

    # Example 2: W state (NOT holographic - violates MMI)
    print("\n  W state (3 qubits):")
    # Approximate entropies for |W> = (|001> + |010> + |100>)/sqrt(3)
    A, B, C = 0.918, 0.918, 0.918
    AB, AC, BC = 0.918, 0.918, 0.918
    ABC = 0.0

    ssa_check = AB + BC >= ABC + B
    mmi_check = AB + AC + BC <= A + B + C + ABC

    print(f"  S(A)≈{A}, S(B)≈{B}, S(C)≈{C}")
    print(f"  S(AB)≈{AB}, S(AC)≈{AC}, S(BC)≈{BC}, S(ABC)={ABC}")
    print(f"  SSA: {AB+BC:.3f} >= {ABC+B:.3f}: {ssa_check}")
    print(f"  MMI: {AB+AC+BC:.3f} <= {A+B+C+ABC:.3f}: {mmi_check}")

    # Example 3: Random holographic state
    print("\n  Holographic (RT) state (3 boundary regions):")
    # RT entropies from a graph model with edge weights
    w1, w2, w3 = 2.0, 3.0, 1.5  # Edge weights
    A = min(w1 + w3, w2)  # min-cut for A
    B = min(w1 + w2, w3)  # min-cut for B
    C = min(w2 + w3, w1)  # min-cut for C
    AB = min(w3, w1 + w2)
    AC = min(w2, w1 + w3)
    BC = min(w1, w2 + w3)
    ABC = 0.0  # pure state

    ssa_check = AB + BC >= ABC + B
    mmi_check = AB + AC + BC <= A + B + C + ABC

    print(f"  Edge weights: w1={w1}, w2={w2}, w3={w3}")
    print(f"  S(A)={A}, S(B)={B}, S(C)={C}")
    print(f"  S(AB)={AB}, S(AC)={AC}, S(BC)={BC}, S(ABC)={ABC}")
    print(f"  SSA: {AB+BC:.1f} >= {ABC+B:.1f}: {ssa_check}")
    print(f"  MMI: {AB+AC+BC:.1f} <= {A+B+C+ABC:.1f}: {mmi_check}")
    print()


if __name__ == "__main__":
    demo_singleton_bound()
    demo_bekenstein_singleton()
    demo_entropy_density()
    demo_page_curve()
    demo_holographic_entropy_cone()


#!/usr/bin/env python3
"""
Visualization: Holographic Entropy Cone (3-party)

Plots the 3-party holographic entropy cone defined by SSA and MMI constraints,
showing which entropy vectors are holographic vs. merely quantum.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


def check_ssa(sA, sB, sC, sAB, sAC, sBC, sABC):
    """Check all SSA instances for 3-party system."""
    # SSA: S(XY) + S(YZ) >= S(XYZ) + S(Y) for all orderings
    checks = [
        sAB + sBC >= sABC + sB,
        sAB + sAC >= sABC + sA,  # with relabeling
        sAC + sBC >= sABC + sC,
    ]
    return all(checks)


def check_mmi(sA, sB, sC, sAB, sAC, sBC, sABC):
    """Check MMI: S(AB) + S(AC) + S(BC) <= S(A) + S(B) + S(C) + S(ABC)."""
    return sAB + sAC + sBC <= sA + sB + sC + sABC + 1e-10


def main():
    fig = plt.figure(figsize=(14, 5))

    # Plot 1: 2D slice of entropy cone
    # Fix S(C) = 1, S(ABC) = 0 (pure state), scan S(A), S(B)
    ax1 = fig.add_subplot(131)

    sa_range = np.linspace(0, 2, 100)
    sb_range = np.linspace(0, 2, 100)
    SA, SB = np.meshgrid(sa_range, sb_range)

    # For pure state: S(ABC) = 0, so S(AB) = S(C) = 1, S(AC) = S(B), S(BC) = S(A)
    SC = 1.0
    SABC = 0.0
    SAB = SC  # purification
    SAC = SB  # purification
    SBC = SA  # purification

    ssa_mask = np.ones_like(SA, dtype=bool)
    mmi_mask = np.ones_like(SA, dtype=bool)

    for i in range(len(sa_range)):
        for j in range(len(sb_range)):
            sA, sB = SA[j, i], SB[j, i]
            sAB, sAC, sBC = SC, sB, sA

            ssa_ok = check_ssa(sA, sB, SC, sAB, sAC, sBC, SABC)
            mmi_ok = check_mmi(sA, sB, SC, sAB, sAC, sBC, SABC)

            ssa_mask[j, i] = ssa_ok
            mmi_mask[j, i] = mmi_ok

    # Quantum cone (SSA only)
    quantum = ssa_mask & ~mmi_mask
    holographic = ssa_mask & mmi_mask

    ax1.contourf(SA, SB, holographic.astype(float), levels=[0.5, 1.5],
                 colors=['#2196F3'], alpha=0.5)
    ax1.contourf(SA, SB, quantum.astype(float), levels=[0.5, 1.5],
                 colors=['#FF9800'], alpha=0.3)
    ax1.contour(SA, SB, ssa_mask.astype(float), levels=[0.5], colors=['orange'], linewidths=2)
    ax1.contour(SA, SB, (ssa_mask & mmi_mask).astype(float), levels=[0.5],
                colors=['blue'], linewidths=2)

    ax1.set_xlabel('S(A)', fontsize=12)
    ax1.set_ylabel('S(B)', fontsize=12)
    ax1.set_title('Entropy Cones\n(S(C)=1, pure state)', fontsize=13)

    from matplotlib.patches import Patch
    ax1.legend(handles=[
        Patch(facecolor='#2196F3', alpha=0.5, label='Holographic (SSA+MMI)'),
        Patch(facecolor='#FF9800', alpha=0.3, label='Quantum only (SSA)')
    ], fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Singleton bound region
    ax2 = fig.add_subplot(132)

    n_range = np.arange(2, 25)
    for d in [2, 3, 4, 5]:
        k_vals = n_range - 2 * (d - 1)
        k_vals = np.maximum(k_vals, 0)
        valid = k_vals <= n_range
        ax2.plot(n_range[valid], k_vals[valid], 'o-', markersize=4,
                 label=f'd={d}')

    # Shade the valid region
    ax2.fill_between(n_range, 0, n_range, alpha=0.05, color='gray')
    ax2.plot(n_range, n_range, 'k--', alpha=0.3, label='k=n')

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('k (logical qubits)', fontsize=12)
    ax2.set_title('MDS Codes:\nk = n - 2(d-1)', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(2, 24)
    ax2.set_ylim(0, 24)

    # Plot 3: Entropy defect vs rate
    ax3 = fig.add_subplot(133)

    rates = []
    defects = []
    colors = []

    for n in range(3, 30):
        for d in range(1, n // 2 + 2):
            for k in range(0, n + 1):
                if 2 * d <= n - k + 2 and k <= n:
                    rate = k / n
                    defect = (n - k) - 2 * (d - 1)
                    if defect >= 0:
                        rates.append(rate)
                        defects.append(defect)
                        colors.append('blue' if defect == 0 else 'orange')

    ax3.scatter(rates, defects, c=colors, alpha=0.3, s=10)
    ax3.axhline(y=0, color='blue', linewidth=2, label='MDS (Δ=0)')
    ax3.set_xlabel('Rate k/n', fontsize=12)
    ax3.set_ylabel('Entropy defect Δ', fontsize=12)
    ax3.set_title('Code Rate vs\nEntropy Defect', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_cone.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_cone.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Page Curve for Holographic Code Families

Plots the radiation entropy k(t) as a function of time, showing the
characteristic Page curve shape with a peak at the Page time.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def page_curve_k(t: np.ndarray, n: int, page_time: int) -> np.ndarray:
    """Compute k(t) for a Page curve."""
    result = np.zeros_like(t, dtype=float)
    for i, ti in enumerate(t):
        if ti <= page_time:
            result[i] = min(ti, n // 2)
        else:
            result[i] = max(n // 2 - (ti - page_time), 0)
    return result


def page_curve_smooth(t: np.ndarray, n: int, page_time: float) -> np.ndarray:
    """Smooth Page curve using thermodynamic approximation."""
    k_max = n / 2
    # Before page time: k ~ t (linear growth)
    # After page time: k ~ n - t (linear decrease)
    # Smooth version using tanh
    width = page_time / 5
    return k_max * (1 - np.tanh((t - page_time) / width)) / 2


def main():
    n = 40
    page_time = 20

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Discrete Page curve
    ax = axes[0]
    t_discrete = np.arange(0, 41)
    k_discrete = page_curve_k(t_discrete, n, page_time)
    d_discrete = (n - k_discrete) / 2 + 1

    ax.plot(t_discrete, k_discrete, 'b-o', markersize=4, label='k(t) = logical qubits')
    ax.axvline(x=page_time, color='red', linestyle='--', alpha=0.7, label=f'Page time = {page_time}')
    ax.fill_between(t_discrete, k_discrete, alpha=0.15, color='blue')
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Radiation entropy k(t)', fontsize=12)
    ax.set_title(f'Page Curve (n={n})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 41)

    # Right: Smooth thermodynamic Page curve
    ax = axes[1]
    t_smooth = np.linspace(0, 40, 200)
    k_smooth = page_curve_smooth(t_smooth, n, page_time)

    ax.plot(t_smooth, k_smooth, 'b-', linewidth=2, label='S_rad(t)')
    ax.axvline(x=page_time, color='red', linestyle='--', alpha=0.7, label='Page time')

    # Also plot the "naive" Hawking curve (always increasing)
    k_hawking = np.minimum(t_smooth, n / 2) * np.ones_like(t_smooth)
    k_hawking = np.where(t_smooth <= n, t_smooth * (n/2) / n, n/2)
    ax.plot(t_smooth, k_hawking, 'gray', linestyle=':', linewidth=1.5,
            label='Hawking (no unitarity)', alpha=0.6)

    ax.fill_between(t_smooth, k_smooth, alpha=0.15, color='blue')
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Radiation entropy', fontsize=12)
    ax.set_title('Thermodynamic Page Curve', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 41)

    plt.tight_layout()
    plt.savefig('page_curve.png', dpi=150, bbox_inches='tight')
    print("Saved page_curve.png")


if __name__ == "__main__":
    main()
