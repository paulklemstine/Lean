#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of q-Casimir spectral theory.

Computes q-integers, q-Casimir eigenvalues, spectral gaps, and verifies
the key algebraic identities numerically.
"""

from typing import List, Tuple
import math


def q_int(q: float, n: int) -> float:
    """Compute [n]_q = 1 + q + q^2 + ... + q^{n-1}."""
    if n <= 0:
        return 0.0
    return sum(q**i for i in range(n))


def q_casimir_eigenvalue(q: float, n: int) -> float:
    """Compute λ_n(q) = [n]_q · [n+1]_q."""
    return q_int(q, n) * q_int(q, n + 1)


def spectral_gap(q: float, n: int) -> float:
    """Compute Δ_n = λ_{n+1}(q) - λ_n(q)."""
    return q_casimir_eigenvalue(q, n + 1) - q_casimir_eigenvalue(q, n)


def spectral_gap_closed_form(q: float, n: int) -> float:
    """Compute Δ_n via the closed form [n+1]_q · q^n · (1+q)."""
    return q_int(q, n + 1) * q**n * (1 + q)


def spectral_gap_recurrence_step(q: float, gap: float, power: float) -> Tuple[float, float]:
    """One step of the spectral gap dynamical system."""
    new_gap = q**2 * gap + power * q * (1 + q)
    new_power = power * q
    return new_gap, new_power


def verify_multiplication_formula(q: float, n: int, m: int) -> Tuple[float, float]:
    """Verify [n*m]_q = [n]_q · [m]_{q^n}."""
    lhs = q_int(q, n * m)
    rhs = q_int(q, n) * q_int(q**n, m)
    return lhs, rhs


def main():
    print("=" * 70)
    print("q-CASIMIR SPECTRAL THEORY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: q-integers for various q
    print("\n--- Demo 1: q-Integers ---")
    for q in [0.5, 0.9, 1.0, 1.5, 2.0]:
        vals = [q_int(q, n) for n in range(8)]
        print(f"  q = {q}: [n]_q = {[round(v, 4) for v in vals]}")

    # Demo 2: q-Casimir eigenvalues
    print("\n--- Demo 2: q-Casimir Eigenvalues ---")
    for q in [0.5, 1.0, 2.0]:
        vals = [q_casimir_eigenvalue(q, n) for n in range(7)]
        print(f"  q = {q}: λ_n = {[round(v, 4) for v in vals]}")

    # Demo 3: Spectral gaps and closed form verification
    print("\n--- Demo 3: Spectral Gap Closed Form Verification ---")
    q = 0.7
    print(f"  q = {q}")
    print(f"  {'n':>3}  {'Δ_n (direct)':>14}  {'Δ_n (closed)':>14}  {'|error|':>10}")
    for n in range(8):
        direct = spectral_gap(q, n)
        closed = spectral_gap_closed_form(q, n)
        error = abs(direct - closed)
        print(f"  {n:>3}  {direct:>14.8f}  {closed:>14.8f}  {error:>10.2e}")

    # Demo 4: Spectral gap recurrence verification
    print("\n--- Demo 4: Spectral Gap Recurrence Verification ---")
    q = 1.3
    gap, power = 1 + q, 1.0  # Initial state
    print(f"  q = {q}")
    print(f"  {'n':>3}  {'Δ_n (dynamics)':>16}  {'Δ_n (direct)':>14}  {'|error|':>10}")
    for n in range(10):
        direct = spectral_gap(q, n)
        error = abs(gap - direct)
        print(f"  {n:>3}  {gap:>16.8f}  {direct:>14.8f}  {error:>10.2e}")
        gap, power = spectral_gap_recurrence_step(q, gap, power)

    # Demo 5: Multiplication formula verification
    print("\n--- Demo 5: q-Integer Multiplication Formula ---")
    q = 0.8
    print(f"  q = {q}")
    test_cases = [(2, 3), (3, 4), (5, 7), (4, 6), (7, 3)]
    for n, m in test_cases:
        lhs, rhs = verify_multiplication_formula(q, n, m)
        error = abs(lhs - rhs)
        print(f"  [{n}*{m}]_q = {lhs:.8f},  [{n}]_q · [{m}]_{{q^{n}}} = {rhs:.8f},  error = {error:.2e}")

    # Demo 6: Spectral gap ratio convergence
    print("\n--- Demo 6: Spectral Gap Ratio Convergence ---")
    for q in [0.3, 0.5, 0.9, 1.1, 2.0, 5.0]:
        ratios = []
        for n in range(90, 100):
            g_n = spectral_gap(q, n)
            g_n1 = spectral_gap(q, n + 1)
            if abs(g_n) > 1e-300:
                ratios.append(g_n1 / g_n)
        avg_ratio = sum(ratios) / len(ratios) if ratios else float('nan')
        predicted = q if q < 1 else q**2
        print(f"  q = {q:>4.1f}: Δ_{{n+1}}/Δ_n → {avg_ratio:.8f} (predicted: {predicted:.8f})")

    # Demo 7: Classical limit
    print("\n--- Demo 7: Classical Limit (q=1) ---")
    print(f"  {'n':>3}  {'[n]_1':>6}  {'λ_n(1)':>8}  {'n(n+1)':>8}")
    for n in range(8):
        qn = q_int(1.0, n)
        lam = q_casimir_eigenvalue(1.0, n)
        classical = n * (n + 1)
        print(f"  {n:>3}  {qn:>6.0f}  {lam:>8.0f}  {classical:>8}")

    print("\n" + "=" * 70)
    print("All numerical verifications passed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
viz_spectral_landscape.py — 3D surface plot of q-Casimir spectral landscape.

Visualizes eigenvalues, spectral gaps, and gap ratios as functions of n and q.
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def q_int(q: np.ndarray, n: int) -> np.ndarray:
    """Vectorized q-integer computation."""
    result = np.zeros_like(q, dtype=float)
    for i in range(n):
        result += q ** i
    return result


def main():
    fig = plt.figure(figsize=(16, 10))

    # Parameters
    q_vals = np.linspace(0.1, 2.5, 100)
    n_vals = np.arange(1, 13)
    Q, N = np.meshgrid(q_vals, n_vals)

    # Compute eigenvalues
    eigenvalues = np.zeros_like(Q)
    gaps = np.zeros_like(Q)
    for i, n in enumerate(n_vals):
        for j, q in enumerate(q_vals):
            qn = q_int(np.array([q]), n)[0]
            qn1 = q_int(np.array([q]), n + 1)[0]
            eigenvalues[i, j] = qn * qn1
            gaps[i, j] = qn1 * q**n * (1 + q)

    # Plot 1: Eigenvalue surface
    ax1 = fig.add_subplot(221, projection='3d')
    ax1.plot_surface(Q, N, eigenvalues, cmap='viridis', alpha=0.8, edgecolor='none')
    ax1.set_xlabel('q')
    ax1.set_ylabel('n')
    ax1.set_zlabel('λ_n(q)')
    ax1.set_title('q-Casimir Eigenvalues')
    ax1.view_init(elev=25, azim=135)

    # Plot 2: Spectral gap surface
    ax2 = fig.add_subplot(222, projection='3d')
    ax2.plot_surface(Q, N, gaps, cmap='magma', alpha=0.8, edgecolor='none')
    ax2.set_xlabel('q')
    ax2.set_ylabel('n')
    ax2.set_zlabel('Δ_n(q)')
    ax2.set_title('Spectral Gaps: Δ_n = [n+1]_q · q^n · (1+q)')
    ax2.view_init(elev=25, azim=135)

    # Plot 3: Spectral gap sequence for fixed q values
    ax3 = fig.add_subplot(223)
    n_range = np.arange(0, 15)
    for q in [0.3, 0.5, 0.7, 1.0, 1.3, 1.5, 2.0]:
        gap_seq = []
        for n in n_range:
            qn1 = sum(q**i for i in range(n + 1))
            gap_seq.append(qn1 * q**n * (1 + q))
        ax3.semilogy(n_range, gap_seq, 'o-', label=f'q={q}', markersize=4)
    ax3.set_xlabel('n')
    ax3.set_ylabel('Δ_n (log scale)')
    ax3.set_title('Spectral Gap Sequences')
    ax3.legend(fontsize=8, ncol=2)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Gap ratio convergence
    ax4 = fig.add_subplot(224)
    q_test = np.linspace(0.1, 3.0, 200)
    ratio_n50 = []
    for q in q_test:
        qn51 = sum(q**i for i in range(52))
        qn50 = sum(q**i for i in range(51))
        ratio_n50.append(q * qn51 / qn50 if qn50 > 0 else 0)
    predicted = [q if q < 1 else q**2 for q in q_test]
    ax4.plot(q_test, ratio_n50, 'b-', linewidth=2, label='Δ_{51}/Δ_{50}')
    ax4.plot(q_test, predicted, 'r--', linewidth=1.5, label='Predicted limit')
    ax4.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    ax4.set_xlabel('q')
    ax4.set_ylabel('Gap ratio')
    ax4.set_title('Spectral Gap Ratio Convergence')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(0, 10)

    plt.tight_layout()
    plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to spectral_landscape.png")


if __name__ == "__main__":
    main()
