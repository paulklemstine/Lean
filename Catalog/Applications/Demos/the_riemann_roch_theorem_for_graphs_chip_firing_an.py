#!/usr/bin/env python3
"""
Chip-Firing on Complete Graphs: Demonstration
==============================================

Demonstrates the key theorems about chip-firing on K_n:
1. Fire-all triviality (Laplacian of constant = 0)
2. Complement firing duality
3. Canonical complement involution
4. Spectral gap (Laplacian kernel = constants)
5. Riemann-Roch predictions
"""

import numpy as np
from typing import List, Tuple


def laplacian_kn(n: int) -> np.ndarray:
    """Laplacian matrix of the complete graph K_n."""
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


def chip_fire(D: np.ndarray, v: int, n: int) -> np.ndarray:
    """Fire vertex v on K_n: sends 1 chip to each neighbor."""
    result = D.copy()
    result[v] -= (n - 1)
    for w in range(n):
        if w != v:
            result[w] += 1
    return result


def canonical_divisor(n: int) -> np.ndarray:
    """Canonical divisor K_{K_n}: each vertex gets n-3 chips."""
    return np.full(n, n - 3, dtype=int)


def genus(n: int) -> int:
    """Genus of K_n: (n-1)(n-2)/2."""
    return (n - 1) * (n - 2) // 2


def canonical_complement(D: np.ndarray, n: int) -> np.ndarray:
    """Canonical complement: K - D."""
    return canonical_divisor(n) - D


def laplacian_apply(f: np.ndarray, n: int) -> np.ndarray:
    """Apply Laplacian of K_n to function f."""
    L = laplacian_kn(n)
    return L @ f


def main():
    print("=" * 60)
    print("CHIP-FIRING ON COMPLETE GRAPHS: DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Fire-All Triviality
    print("\n--- Demo 1: Fire-All Triviality ---")
    for n in [3, 4, 5, 6]:
        f_const = np.ones(n, dtype=int)
        result = laplacian_apply(f_const, n)
        print(f"  K_{n}: Δ(1) = {result}  (should be all zeros)")

    # Demo 2: Complement Firing Duality
    print("\n--- Demo 2: Complement Firing Duality ---")
    for n in [3, 4, 5]:
        for v in range(min(2, n)):
            f = np.array([0 if i == v else 1 for i in range(n)], dtype=int)
            result = laplacian_apply(f, n)
            expected = np.array([-(n-1) if i == v else 1 for i in range(n)])
            match = np.array_equal(result, expected)
            print(f"  K_{n}, v={v}: Δ(χ_{{V\\{{{v}}}}}) = {result}  "
                  f"expected {expected}  {'✓' if match else '✗'}")

    # Demo 3: Canonical Complement Involution
    print("\n--- Demo 3: Canonical Complement Involution ---")
    for n in [3, 4, 5, 6]:
        D = np.array([i for i in range(n)], dtype=int)
        K = canonical_divisor(n)
        KmD = canonical_complement(D, n)
        KmKmD = canonical_complement(KmD, n)
        match = np.array_equal(D, KmKmD)
        print(f"  K_{n}: D={D}, K-D={KmD}, K-(K-D)={KmKmD}  {'✓' if match else '✗'}")

    # Demo 4: Degree Duality
    print("\n--- Demo 4: Degree Duality: deg(K-D) = 2g-2 - deg(D) ---")
    for n in [3, 4, 5, 6]:
        g = genus(n)
        D = np.array([i % 3 for i in range(n)], dtype=int)
        KmD = canonical_complement(D, n)
        deg_D = D.sum()
        deg_KmD = KmD.sum()
        expected = 2 * g - 2 - deg_D
        print(f"  K_{n}: g={g}, deg(D)={deg_D}, deg(K-D)={deg_KmD}, "
              f"2g-2-deg(D)={expected}  {'✓' if deg_KmD == expected else '✗'}")

    # Demo 5: Spectral Gap
    print("\n--- Demo 5: Laplacian Kernel = Constants ---")
    for n in [3, 4, 5, 6]:
        L = laplacian_kn(n)
        eigenvalues = sorted(np.linalg.eigvalsh(L))
        print(f"  K_{n}: eigenvalues = {[round(e, 1) for e in eigenvalues]}")
        print(f"         spectral gap = {round(eigenvalues[1], 1)}")

    # Demo 6: Riemann-Roch Prediction
    print("\n--- Demo 6: Riemann-Roch Canonical Prediction ---")
    for n in range(2, 8):
        g = genus(n)
        K = canonical_divisor(n)
        deg_K = K.sum()
        lhs = deg_K + 1 - g
        rhs = g - 1
        print(f"  K_{n}: g={g}, deg(K)={deg_K}, "
              f"deg(K)+1-g={lhs}, g-1={rhs}  {'✓' if lhs == rhs else '✗'}")

    # Demo 7: Chip-Firing Example
    print("\n--- Demo 7: Chip-Firing on K_4 ---")
    D = np.array([5, 0, 0, 0])
    print(f"  Initial: D = {D}, deg = {D.sum()}")
    D1 = chip_fire(D, 0, 4)
    print(f"  Fire v=0: D = {D1}, deg = {D1.sum()}")
    D2 = chip_fire(D1, 0, 4)
    print(f"  Fire v=0: D = {D2}, deg = {D2.sum()}")
    D3 = chip_fire(D2, 1, 4)
    print(f"  Fire v=1: D = {D3}, deg = {D3.sum()}")

    # Demo 8: S_n Action
    print("\n--- Demo 8: Symmetric Group Action on K_4 ---")
    D = np.array([3, 1, 2, 0])
    sigma = [1, 2, 3, 0]  # cyclic permutation
    D_sigma = np.array([D[sigma.index(i)] for i in range(4)])
    print(f"  D = {D}, σ = {sigma}")
    print(f"  σ·D = {D_sigma}")
    print(f"  deg(D) = {D.sum()}, deg(σ·D) = {D_sigma.sum()}  "
          f"{'✓' if D.sum() == D_sigma.sum() else '✗'}")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics on K_4
============================================
Shows chip redistribution under firing operations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def chip_fire(D: np.ndarray, v: int, n: int) -> np.ndarray:
    result = D.copy()
    result[v] -= (n - 1)
    for w in range(n):
        if w != v:
            result[w] += 1
    return result


def main():
    n = 4
    D = np.array([6, 0, 0, 0])

    # Record trajectory
    trajectory = [D.copy()]
    fired = []

    # Fire sequence to redistribute
    for v in [0, 0, 1, 2]:
        D = chip_fire(D, v, n)
        trajectory.append(D.copy())
        fired.append(v)

    fig, axes = plt.subplots(1, len(trajectory), figsize=(3 * len(trajectory), 4))

    for idx, (D_step, ax) in enumerate(zip(trajectory, axes)):
        # Draw K_4 as a square
        positions = np.array([[0, 1], [1, 1], [1, 0], [0, 0]], dtype=float)

        # Draw edges
        for i in range(n):
            for j in range(i + 1, n):
                ax.plot([positions[i, 0], positions[j, 0]],
                        [positions[i, 1], positions[j, 1]],
                        'gray', linewidth=0.5, alpha=0.5)

        # Draw vertices with chip counts
        colors = ['#ff6b6b' if D_step[i] < 0 else
                  '#4ecdc4' if D_step[i] == 0 else '#45b7d1'
                  for i in range(n)]
        sizes = [max(100, 50 + 50 * abs(D_step[i])) for i in range(n)]

        ax.scatter(positions[:, 0], positions[:, 1],
                   c=colors, s=sizes, zorder=5, edgecolors='black')

        for i in range(n):
            ax.annotate(str(D_step[i]),
                        (positions[i, 0], positions[i, 1]),
                        ha='center', va='center', fontweight='bold',
                        fontsize=14, zorder=6)

        if idx == 0:
            ax.set_title(f'Initial\ndeg={D_step.sum()}', fontsize=10)
        else:
            ax.set_title(f'Fire v={fired[idx-1]}\ndeg={D_step.sum()}',
                         fontsize=10)

        ax.set_xlim(-0.3, 1.3)
        ax.set_ylim(-0.3, 1.3)
        ax.set_aspect('equal')
        ax.axis('off')

    plt.suptitle('Chip-Firing on K₄: Degree Conservation', fontsize=14)
    plt.tight_layout()
    plt.savefig('chipfire_dynamics.png', dpi=150, bbox_inches='tight')
    print("Saved chipfire_dynamics.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Laplacian Spectrum of Complete Graphs
=====================================================
Shows how the spectral gap of K_n grows with n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def laplacian_kn(n: int) -> np.ndarray:
    """Laplacian matrix of K_n."""
    return n * np.eye(n) - np.ones((n, n))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Eigenvalue distribution for various K_n
    ax1 = axes[0]
    for n in [3, 4, 5, 6, 8, 10]:
        L = laplacian_kn(n)
        eigvals = sorted(np.linalg.eigvalsh(L))
        ax1.scatter([n] * len(eigvals), eigvals, s=30, alpha=0.7)
    ax1.set_xlabel('n (vertices in K_n)')
    ax1.set_ylabel('Eigenvalue')
    ax1.set_title('Laplacian Eigenvalues of K_n')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Spectral gap vs n
    ax2 = axes[1]
    ns = range(2, 20)
    gaps = [n for n in ns]  # spectral gap of K_n is n
    ax2.plot(list(ns), gaps, 'b-o', markersize=4)
    ax2.set_xlabel('n')
    ax2.set_ylabel('Spectral Gap (= n)')
    ax2.set_title('Spectral Gap of K_n')
    ax2.grid(True, alpha=0.3)

    # Plot 3: Genus and canonical degree
    ax3 = axes[2]
    ns = range(2, 15)
    genera = [(n - 1) * (n - 2) // 2 for n in ns]
    canon_degs = [n * (n - 3) for n in ns]
    ax3.plot(list(ns), genera, 'r-o', label='g(K_n)', markersize=4)
    ax3.plot(list(ns), canon_degs, 'b-s', label='deg(K_{K_n})', markersize=4)
    ax3.plot(list(ns), [2 * g - 2 for g in genera], 'g--',
             label='2g-2', alpha=0.7)
    ax3.set_xlabel('n')
    ax3.set_ylabel('Value')
    ax3.set_title('Genus and Canonical Degree')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_analysis.png")


if __name__ == "__main__":
    main()
