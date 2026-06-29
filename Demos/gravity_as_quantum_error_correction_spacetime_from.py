#!/usr/bin/env python3
"""
Holographic Code Complex — Numerical Demonstrations

Demonstrates the key results from the formal proofs:
1. RT-Singleton equivalence for specific codes
2. Rate-distance tradeoff visualization
3. Singleton gap computation
4. Entropy cone dimensions
5. Greedy wedge simulation
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class QuantumCode:
    """Quantum error-correcting code [[n, k, d]]."""
    n: int  # physical qubits
    k: int  # logical qubits
    d: int  # code distance
    name: str = ""

    @property
    def redundancy(self) -> int:
        return self.n - self.k

    @property
    def singleton_entropy(self) -> float:
        return (self.n - self.k) / 2.0

    @property
    def is_mds(self) -> bool:
        return 2 * self.d + self.k == self.n + 2

    @property
    def singleton_gap(self) -> int:
        return (self.n + 2) - (2 * self.d + self.k)

    @property
    def rate(self) -> float:
        return self.k / self.n

    @property
    def distance_ratio(self) -> float:
        return self.d / self.n

    def verify_singleton_bound(self) -> bool:
        return 2 * self.d + self.k <= self.n + 2


# Standard quantum codes
CODES = [
    QuantumCode(5, 1, 3, "[[5,1,3]] Perfect"),
    QuantumCode(7, 1, 3, "[[7,1,3]] Steane"),
    QuantumCode(9, 1, 3, "[[9,1,3]] Shor"),
    QuantumCode(15, 5, 3, "[[15,5,3]] Pentagon"),
    QuantumCode(23, 1, 7, "[[23,1,7]] Golay"),
]


def demo_rt_singleton():
    """Demonstrate the RT-Singleton equivalence."""
    print("=" * 60)
    print("Demo 1: RT-Singleton Equivalence")
    print("=" * 60)
    print()
    print("Theorem: p.isMDS ↔ d = (n-k)/2 + 1")
    print()

    for code in CODES:
        s_ent = code.singleton_entropy
        target = s_ent + 1
        mds = code.is_mds
        print(f"  {code.name}:")
        print(f"    n={code.n}, k={code.k}, d={code.d}")
        print(f"    Singleton entropy = (n-k)/2 = {s_ent}")
        print(f"    d = {code.d}, S + 1 = {target}")
        print(f"    MDS: {mds} (d {'=' if mds else '≠'} S + 1)")
        print(f"    Gap: {code.singleton_gap}")
        print()


def demo_rate_distance():
    """Demonstrate the rate-distance tradeoff."""
    print("=" * 60)
    print("Demo 2: Rate-Distance Tradeoff")
    print("=" * 60)
    print()
    print("Theorem: k/n + 2d/n ≤ 1 + 2/n")
    print()

    for code in CODES:
        lhs = code.rate + 2 * code.distance_ratio
        rhs = 1 + 2 / code.n
        saturated = abs(lhs - rhs) < 1e-10
        print(f"  {code.name}:")
        print(f"    k/n + 2d/n = {lhs:.4f}")
        print(f"    1 + 2/n    = {rhs:.4f}")
        print(f"    {'SATURATED (MDS)' if saturated else f'Gap: {rhs - lhs:.4f}'}")
        print()


def demo_entropy_cone():
    """Demonstrate entropy cone dimensions."""
    print("=" * 60)
    print("Demo 3: Entropy Cone Dimensions")
    print("=" * 60)
    print()
    print("Theorem: C(N,2) ≤ 2^N - 1 and C(N,3) ≤ 2^N - 1")
    print()

    from math import comb
    for N in range(2, 8):
        dim = 2**N - 1
        geodesics = comb(N, 2)
        mmi = comb(N, 3) if N >= 3 else 0
        effective = dim - mmi if N >= 3 else dim
        print(f"  N = {N}:")
        print(f"    Entropy dim:   2^{N} - 1 = {dim}")
        print(f"    Geodesics:     C({N},2) = {geodesics}")
        print(f"    MMI constraints: C({N},3) = {mmi}")
        print(f"    Effective dim: {effective}")
        print(f"    Geodesic conjecture: {geodesics} ≤ {dim} → {'✓' if geodesics <= dim else '✗'}")
        print()


def demo_greedy_wedge():
    """Simulate the greedy entanglement wedge algorithm."""
    print("=" * 60)
    print("Demo 4: Greedy Entanglement Wedge")
    print("=" * 60)
    print()

    # Create a simple 6-vertex graph (triangle with 3 boundary vertices)
    V = 6
    weights = np.zeros((V, V))
    # Boundary-bulk edges (high weight = strong entanglement)
    for i in range(3):  # boundary vertices 0,1,2
        for j in range(3, 6):  # bulk vertices 3,4,5
            if (i + 3) == j:  # each boundary connects to "its" bulk vertex
                weights[i][j] = weights[j][i] = 2.0
            else:
                weights[i][j] = weights[j][i] = 0.5

    # Bulk-bulk edges
    weights[3][4] = weights[4][3] = 1.0
    weights[4][5] = weights[5][4] = 1.0
    weights[3][5] = weights[5][3] = 1.0

    def cut_weight(S: set) -> float:
        total = 0.0
        for i in S:
            for j in range(V):
                if j not in S:
                    total += weights[i][j]
        return total

    # Start with boundary region {0, 1}
    A = {0, 1}
    S = set(A)

    print(f"  Graph: 6 vertices (0,1,2 = boundary; 3,4,5 = bulk)")
    print(f"  Initial region A = {A}")
    print(f"  Initial cut weight = {cut_weight(S):.2f}")
    print()

    step = 0
    while True:
        found = False
        for v in range(V):
            if v not in S:
                new_S = S | {v}
                if cut_weight(new_S) <= cut_weight(S):
                    step += 1
                    old_cut = cut_weight(S)
                    S = new_S
                    new_cut = cut_weight(S)
                    print(f"  Step {step}: Add vertex {v}")
                    print(f"    Cut weight: {old_cut:.2f} → {new_cut:.2f}")
                    found = True
                    break
        if not found:
            break

    print(f"\n  Final wedge: {sorted(S)}")
    print(f"  Final cut weight: {cut_weight(S):.2f}")
    print(f"  Terminated after {step} steps (max allowed: {V})")
    print()


def demo_phase_transition():
    """Demonstrate phase transitions in code families."""
    print("=" * 60)
    print("Demo 5: Phase Transitions")
    print("=" * 60)
    print()

    print("  Code family: [[n, 1, d]] with increasing n")
    print("  MDS condition: 2d + 1 = n + 2, i.e., n = 2d - 1")
    print()

    d = 3  # fixed distance
    for n in range(5, 20):
        if n < d:
            continue
        if 2 * d + 1 > n + 2:
            continue
        code = QuantumCode(n, 1, d, f"[[{n},1,{d}]]")
        gap = code.singleton_gap
        mds = "MDS" if code.is_mds else f"gap={gap}"
        s_ent = code.singleton_entropy
        print(f"  n={n:2d}: {mds:10s}  S_singleton = {s_ent:.1f}  rate = {code.rate:.3f}")

    print()
    print("  → Phase transition at n = 5 → 6: MDS → non-MDS")
    print("    (gap jumps from 0 to 2)")


if __name__ == "__main__":
    demo_rt_singleton()
    demo_rate_distance()
    demo_entropy_cone()
    demo_greedy_wedge()
    demo_phase_transition()


#!/usr/bin/env python3
"""
Visualization: Entropy Cone Dimensions

Plots the entropy cone dimension, geodesic count, and MMI constraint count
as functions of the number of parties N.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb


def plot_entropy_cone():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    N_range = range(2, 12)
    dims = [2**N - 1 for N in N_range]
    geodesics = [comb(N, 2) for N in N_range]
    mmi = [comb(N, 3) if N >= 3 else 0 for N in N_range]

    # Left: all three on log scale
    ax1.semilogy(list(N_range), dims, 'ko-', linewidth=2, markersize=8, label=r'$2^N - 1$ (entropy dim)')
    ax1.semilogy(list(N_range), geodesics, 'rs-', linewidth=2, markersize=8, label=r'$\binom{N}{2}$ (geodesics)')
    ax1.semilogy(list(N_range), mmi, 'b^-', linewidth=2, markersize=8, label=r'$\binom{N}{3}$ (MMI)')

    ax1.set_xlabel('Number of parties N', fontsize=14)
    ax1.set_ylabel('Count (log scale)', fontsize=14)
    ax1.set_title('Entropy Cone Dimensions vs. Constraints', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: ratios
    ratio_geo = [g / d for g, d in zip(geodesics, dims)]
    ratio_mmi = [m / d for m, d in zip(mmi, dims)]
    effective = [(d - m) / d for d, m in zip(dims, mmi)]

    ax2.plot(list(N_range), ratio_geo, 'rs-', linewidth=2, markersize=8,
             label=r'$\binom{N}{2} / (2^N-1)$')
    ax2.plot(list(N_range), ratio_mmi, 'b^-', linewidth=2, markersize=8,
             label=r'$\binom{N}{3} / (2^N-1)$')
    ax2.plot(list(N_range), effective, 'gD-', linewidth=2, markersize=8,
             label='Effective dim fraction')

    ax2.set_xlabel('Number of parties N', fontsize=14)
    ax2.set_ylabel('Ratio', fontsize=14)
    ax2.set_title('Geodesics & MMI as Fraction of Entropy Dim', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('entropy_cone.png', dpi=150)
    print("Saved entropy_cone.png")


if __name__ == "__main__":
    plot_entropy_cone()


#!/usr/bin/env python3
"""
Visualization: Rate-Distance Tradeoff

Plots the Singleton rate-distance tradeoff curve and shows where
specific quantum codes fall relative to the MDS boundary.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_rate_distance_tradeoff():
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # MDS boundary for various n
    for n in [5, 7, 9, 15, 23]:
        rates = []
        dists = []
        for d in range(1, n // 2 + 2):
            k = n + 2 - 2 * d
            if k < 0 or k > n:
                continue
            rates.append(k / n)
            dists.append(d / n)
        ax.plot(rates, dists, '--', alpha=0.3, color='gray')
        if rates:
            ax.annotate(f'n={n}', (rates[0], dists[0]), fontsize=8, color='gray')

    # Specific codes
    codes = [
        (5, 1, 3, "[[5,1,3]]", "red", "*", 200),
        (7, 1, 3, "[[7,1,3]]", "blue", "s", 100),
        (9, 1, 3, "[[9,1,3]]", "green", "^", 100),
        (15, 5, 3, "[[15,5,3]]", "purple", "D", 100),
        (23, 1, 7, "[[23,1,7]]", "orange", "p", 120),
    ]

    for n, k, d, label, color, marker, size in codes:
        rate = k / n
        dist = d / n
        is_mds = 2 * d + k == n + 2
        ax.scatter(rate, dist, c=color, marker=marker, s=size, zorder=5,
                   edgecolors='black', linewidths=0.5)
        offset = (0.01, 0.01) if not is_mds else (0.01, -0.03)
        ax.annotate(label + (" (MDS)" if is_mds else ""),
                    (rate + offset[0], dist + offset[1]),
                    fontsize=9, color=color, fontweight='bold')

    # Universal MDS boundary (continuous)
    r = np.linspace(0, 1, 100)
    d_max = (1 - r) / 2 + 0.01  # Approximate for large n
    ax.plot(r, d_max, 'k-', linewidth=2, label='MDS boundary (n→∞)')
    ax.fill_between(r, d_max, 0.6, alpha=0.1, color='red', label='Forbidden region')

    ax.set_xlabel('Rate k/n', fontsize=14)
    ax.set_ylabel('Distance ratio d/n', fontsize=14)
    ax.set_title('Quantum Singleton Rate-Distance Tradeoff\n'
                 r'$k/n + 2d/n \leq 1 + 2/n$', fontsize=16)
    ax.legend(fontsize=10)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.02, 0.6)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tradeoff.png', dpi=150)
    print("Saved tradeoff.png")


if __name__ == "__main__":
    plot_rate_distance_tradeoff()
