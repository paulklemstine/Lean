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
