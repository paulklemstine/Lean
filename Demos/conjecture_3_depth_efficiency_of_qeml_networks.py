#!/usr/bin/env python3
"""
Spectral Depth-Efficiency of qEML Networks: Applications

Real-world applications of the spectral depth-efficiency theory:

1. Spherical harmonic regression on S² (climate/geophysics)
2. Quantum spin observable approximation on SU(2)
3. Equivariant neural network capacity planning

Each application demonstrates how the theoretical bounds translate
into practical design guidelines.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Spherical Harmonic Regression
# ═══════════════════════════════════════════════════════════════════════

def spherical_harmonic_regression():
    """Demonstrate spectral truncation for zonal spherical harmonics on S².

    Zonal spherical harmonics Y_n^0(θ) = P_n(cos θ) form an orthogonal
    basis for axially symmetric functions on the sphere. The depth-efficiency
    theorem gives the error rate for truncation at degree d.

    Via the covering map SU(2) → SO(3) → S², this is equivalent to
    approximation of class functions on SU(2) using characters χ_n.
    """
    print("=" * 70)
    print("APPLICATION 1: Spherical Harmonic Regression on S²")
    print("=" * 70)

    theta = np.linspace(0.01, np.pi - 0.01, 500)
    cos_theta = np.cos(theta)

    # Legendre polynomials (zonal spherical harmonics Y_n^0)
    def legendre_p(n: int, x: np.ndarray) -> np.ndarray:
        """Compute P_n(x) via recurrence."""
        if n == 0:
            return np.ones_like(x)
        if n == 1:
            return x.copy()
        p_prev = np.ones_like(x)
        p_curr = x.copy()
        for k in range(2, n + 1):
            p_next = ((2*k - 1) * x * p_curr - (k - 1) * p_prev) / k
            p_prev = p_curr
            p_curr = p_next
        return p_curr

    # Target: Gravitational potential model (smooth, decaying coefficients)
    # f(θ) = ∑_{n=1}^{50} (R/r)^n · J_n · P_n(cos θ)
    # where J_n ∝ n^{-2} models geopotential coefficients
    N_max = 50
    coeffs = {n: 1.0 / n**2 for n in range(1, N_max + 1)}

    def target_f(theta):
        return sum(c * legendre_p(n, np.cos(theta))
                   for n, c in coeffs.items())

    f_vals = target_f(theta)

    # Compute truncation errors at various depths
    depths = list(range(1, N_max + 1))
    errors_sq = []
    for d in depths:
        truncated = sum(coeffs.get(n, 0) * legendre_p(n, cos_theta)
                        for n in range(1, d + 1))
        # L² error with sin(θ) measure (sphere)
        err_sq = np.trapezoid((f_vals - truncated)**2 * np.sin(theta), theta)
        errors_sq.append(err_sq)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Function and truncations
    ax1.plot(theta * 180/np.pi, f_vals, 'b-', linewidth=2, label='Target')
    for d in [5, 15, 50]:
        truncated = sum(coeffs.get(n, 0) * legendre_p(n, cos_theta)
                        for n in range(1, d + 1))
        ax1.plot(theta * 180/np.pi, truncated, '--', linewidth=1.5,
                 label=f'd = {d}')
    ax1.set_xlabel('Colatitude θ (degrees)')
    ax1.set_ylabel('f(θ)')
    ax1.set_title('Geopotential Model: Spherical Harmonic Truncation')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Error decay
    ax2.loglog(depths, errors_sq, 'b-', linewidth=2, label='L² error²')
    # Predicted: d^{-3} for k=2 (2k-1=3)
    pred = [errors_sq[4] * (5/d)**3 for d in depths]
    ax2.loglog(depths, pred, 'r--', linewidth=1.5, label='Predicted: d⁻³')
    ax2.set_xlabel('Truncation degree d')
    ax2.set_ylabel('Squared L² error')
    ax2.set_title('Error Decay vs Depth')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_spherical_harmonics.png', dpi=150)
    plt.close()

    # Print depth requirements
    print("\n  Depth requirements for various accuracies:")
    print(f"  {'Target ε²':>12s} | {'Min depth':>10s} | {'Predicted':>10s}")
    print("  " + "-" * 40)
    for target in [0.01, 0.001, 0.0001]:
        d_actual = next((d for d, e in zip(depths, errors_sq) if e < target),
                        N_max)
        d_pred = int(np.ceil((1.0 / target) ** (1/3)))
        print(f"  {target:>12.5f} | {d_actual:>10d} | {d_pred:>10d}")

    print("  → Saved: app_spherical_harmonics.png\n")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Quantum Spin Observable Approximation
# ═══════════════════════════════════════════════════════════════════════

def quantum_spin_approximation():
    """Demonstrate depth-efficiency for quantum spin observables on SU(2).

    For a spin-j quantum system, an observable O has expectation value
    ⟨ψ|U(g)†·O·U(g)|ψ⟩ as a function of g ∈ SU(2), which decomposes
    into characters χ_n with n ≤ 2j.

    The depth-efficiency theorem bounds how many qEML layers are needed
    to approximate this observable function.
    """
    print("=" * 70)
    print("APPLICATION 2: Quantum Spin Observable Approximation")
    print("=" * 70)

    # SU(2) parameterized by angle θ ∈ [0, π] (class function on maximal torus)
    theta = np.linspace(0.01, np.pi - 0.01, 500)

    def chi_n(n: int, theta: np.ndarray) -> np.ndarray:
        """SU(2) character χ_n(θ) = sin((n+1)θ) / sin(θ)."""
        return np.sin((n + 1) * theta) / np.sin(theta)

    # Simulate quantum observable with thermal decay
    # Observable coefficients ∝ exp(-βn) for inverse temperature β
    betas = [0.1, 0.5, 1.0, 2.0]
    N_max = 100

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for idx, beta in enumerate(betas):
        ax = axes[idx // 2][idx % 2]

        coeffs = {n: np.exp(-beta * n) for n in range(1, N_max + 1)}
        f_vals = sum(c * chi_n(n, theta) for n, c in coeffs.items())

        # Estimate decay rate
        ns = np.arange(1, N_max + 1)
        log_coeffs = [-beta * n for n in ns]
        # For exponential decay, the effective k ≈ β·ln(d)/ln(d) depends on scale

        # Spectral truncation errors
        depths = list(range(1, 51))
        errors = []
        for d in depths:
            truncated = sum(coeffs.get(n, 0) * chi_n(n, theta)
                            for n in range(1, d + 1))
            err = np.sqrt(np.trapezoid((f_vals - truncated)**2 * np.sin(theta)**2,
                                    theta))
            errors.append(err)

        ax.semilogy(depths, errors, 'b-', linewidth=2)
        ax.set_xlabel('qEML depth d')
        ax.set_ylabel('L² error')
        ax.set_title(f'Inverse temperature β = {beta}')
        ax.grid(True, alpha=0.3)

        # Find depth for error < 0.01
        d_01 = next((d for d, e in zip(depths, errors) if e < 0.01),
                     len(depths))
        ax.axvline(x=d_01, color='r', linestyle='--', alpha=0.5,
                   label=f'd={d_01} for ε<0.01')
        ax.legend()

        print(f"  β={beta}: depth for L² error < 0.01: d = {d_01}")

    plt.suptitle('Quantum Spin Observable: qEML Depth Requirements',
                 fontsize=14)
    plt.tight_layout()
    plt.savefig('app_quantum_spin.png', dpi=150)
    plt.close()
    print("  → Saved: app_quantum_spin.png\n")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Equivariant Neural Network Capacity Planning
# ═══════════════════════════════════════════════════════════════════════

def equivariant_capacity_planning():
    """Design guide for equivariant neural networks using depth-efficiency bounds.

    Given a target function class (characterized by Sobolev regularity s)
    and accuracy requirement ε, compute the minimum network depth.
    """
    print("=" * 70)
    print("APPLICATION 3: Equivariant Network Capacity Planning")
    print("=" * 70)

    # Regularity classes and their interpretations
    regularity_classes = [
        (1.0, "C⁰-like (barely summable)", "Rough textures"),
        (1.5, "H¹-like (first derivative)", "Smooth signals"),
        (2.0, "H²-like (second derivative)", "Very smooth"),
        (2.5, "H⁵/₂-like (critical regime)", "Analytic-like"),
        (3.0, "H³-like (three derivatives)", "Near-analytic"),
    ]

    epsilons = np.logspace(-1, -4, 50)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    print("\n  Depth requirements (d for squared L² error ≤ ε):")
    print(f"  {'Regularity k':>14s} | {'ε=0.01':>10s} | {'ε=0.001':>10s} | {'ε=0.0001':>12s}")
    print("  " + "-" * 55)

    for k, label, application in regularity_classes:
        rate = 2 * k - 1
        depths = [(1.0 / (rate * eps)) ** (1/rate) for eps in epsilons]

        ax1.loglog(epsilons, depths, linewidth=2, label=f'k={k} ({label})')

        # Table entries
        d_001 = int(np.ceil((1.0 / (rate * 0.01)) ** (1/rate)))
        d_0001 = int(np.ceil((1.0 / (rate * 0.001)) ** (1/rate)))
        d_00001 = int(np.ceil((1.0 / (rate * 0.0001)) ** (1/rate)))
        print(f"  {label:>14s} | {d_001:>10d} | {d_0001:>10d} | {d_00001:>12d}")

    ax1.set_xlabel('Target squared L² error ε')
    ax1.set_ylabel('Required depth d')
    ax1.set_title('Depth vs Accuracy by Regularity Class')
    ax1.legend(loc='upper right', fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.invert_xaxis()

    # Depth budget allocation
    # Given total depth D, how to split between spectral bands?
    total_depths = range(5, 101)
    for k in [1.0, 2.0, 3.0]:
        rate = 2 * k - 1
        errors = [1.0 / (rate * d**rate) for d in total_depths]
        ax2.semilogy(total_depths, errors, linewidth=2, label=f'k={k}')

    ax2.set_xlabel('Total network depth D')
    ax2.set_ylabel('Guaranteed squared L² error')
    ax2.set_title('Error Guarantee vs Network Depth')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_capacity_planning.png', dpi=150)
    plt.close()
    print("  → Saved: app_capacity_planning.png\n")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Covering Map Transfer (SU(2) → SO(3) → S²)
# ═══════════════════════════════════════════════════════════════════════

def covering_map_transfer():
    """Demonstrate error transfer across the covering map SU(2) → SO(3).

    Integer-spin representations of SU(2) descend to representations of SO(3).
    The spectral tail monotonicity theorem (spectral_tail_monotone) ensures
    that approximation on SU(2) controls approximation on SO(3) — deeper
    networks on the covering group capture all the structure of the base.
    """
    print("=" * 70)
    print("APPLICATION 4: Covering Map Transfer SU(2) → SO(3)")
    print("=" * 70)

    theta = np.linspace(0.01, np.pi - 0.01, 500)

    def chi_n(n: int, theta: np.ndarray) -> np.ndarray:
        """SU(2) character χ_n(θ) = sin((n+1)θ) / sin(θ)."""
        return np.sin((n + 1) * theta) / np.sin(theta)

    # Class function with both integer and half-integer spin components
    N_max = 60
    coeffs_su2 = {n: 1.0 / (n + 1)**2 for n in range(N_max)}
    # SO(3) sees only even-spin (integer spin = even n in our indexing)
    coeffs_so3 = {n: c for n, c in coeffs_su2.items() if n % 2 == 0}

    f_su2 = sum(c * chi_n(n, theta) for n, c in coeffs_su2.items())
    f_so3 = sum(c * chi_n(n, theta) for n, c in coeffs_so3.items())

    depths = list(range(1, N_max + 1))
    errors_su2 = []
    errors_so3 = []

    for d in depths:
        trunc_su2 = sum(c * chi_n(n, theta) for n, c in coeffs_su2.items()
                        if n <= d)
        trunc_so3 = sum(c * chi_n(n, theta) for n, c in coeffs_so3.items()
                        if n <= d)

        err_su2 = np.trapezoid((f_su2 - trunc_su2)**2 * np.sin(theta)**2, theta)
        err_so3 = np.trapezoid((f_so3 - trunc_so3)**2 * np.sin(theta)**2, theta)
        errors_su2.append(err_su2)
        errors_so3.append(err_so3)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(theta * 180/np.pi, f_su2, 'b-', linewidth=2,
             label='SU(2) class function')
    ax1.plot(theta * 180/np.pi, f_so3, 'r--', linewidth=2,
             label='SO(3) component (integer spins)')
    ax1.set_xlabel('θ (degrees)')
    ax1.set_ylabel('f(θ)')
    ax1.set_title('Class Functions on SU(2) vs SO(3)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.loglog(depths, errors_su2, 'b-', linewidth=2, label='SU(2) error')
    ax2.loglog(depths, [max(e, 1e-20) for e in errors_so3], 'r--',
               linewidth=2, label='SO(3) error')
    ax2.set_xlabel('Truncation depth d')
    ax2.set_ylabel('Squared L² error')
    ax2.set_title('Error Transfer: SU(2) ≥ SO(3)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_covering_transfer.png', dpi=150)
    plt.close()

    print("  Key insight: SO(3) error ≤ SU(2) error at every depth")
    print("  (monotonicity from spectral_tail_monotone)")
    print(f"  SU(2) error at d=20: {errors_su2[19]:.8f}")
    print(f"  SO(3) error at d=20: {errors_so3[19]:.8f}")
    print(f"  Ratio: {errors_so3[19]/errors_su2[19]:.4f}")
    print("  → Saved: app_covering_transfer.png\n")


if __name__ == '__main__':
    print("\n" + "=" * 70)
    print("SPECTRAL DEPTH-EFFICIENCY: APPLICATIONS")
    print("=" * 70 + "\n")

    spherical_harmonic_regression()
    quantum_spin_approximation()
    equivariant_capacity_planning()
    covering_map_transfer()

    print("=" * 70)
    print("All applications demonstrated.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Spectral Depth-Efficiency of qEML Networks: Demonstration

This script demonstrates the key theorems from the spectral depth-efficiency
theory for qEML networks on compact groups:

1. Spectral tail sum decay under polynomial coefficient decay
2. Upper bound verification: ∑_{n>d} a(n)² ≤ C²/d
3. Lower bound tightness: ∑_{n=d+1}^{2d} (1/n)² ≥ 1/(4d)
4. Epsilon-depth tradeoff visualization
5. Log-log error plots for multiple decay rates

Usage:
    python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple


def spectral_tail_sum(a: Callable[[int], float], d: int, N: int) -> float:
    """Compute ∑_{n=d+1}^N a(n)² — the spectral tail sum.

    This equals ‖f - T_d f‖²_{L²} by Parseval's theorem when a(n)
    are coefficients in an orthonormal expansion.

    Args:
        a: Coefficient function a : ℕ → ℝ
        d: Truncation depth
        N: Upper summation limit

    Returns:
        Sum of a(n)² for n from d+1 to N
    """
    return sum(a(n) ** 2 for n in range(d + 1, N + 1))


def predicted_upper_bound(C: float, d: int) -> float:
    """The predicted upper bound C²/d from Theorem A."""
    if d == 0:
        return float('inf')
    return C ** 2 / d


def predicted_lower_bound(d: int) -> float:
    """The predicted lower bound 1/(4d) from Theorem C."""
    if d == 0:
        return float('inf')
    return 1.0 / (4.0 * d)


def demo_tail_decay():
    """Demo 1: Visualize spectral tail sum decay for various coefficient families."""
    print("=" * 70)
    print("DEMO 1: Spectral Tail Sum Decay")
    print("=" * 70)

    N = 2000  # Large enough to approximate infinite sum
    depths = np.arange(1, 101)

    # Three decay families
    families = [
        ("k=1: a(n) = 1/n", lambda n: 1.0 / n if n >= 1 else 0, 1),
        ("k=2: a(n) = 1/n²", lambda n: 1.0 / n**2 if n >= 1 else 0, 2),
        ("k=3: a(n) = 1/n³", lambda n: 1.0 / n**3 if n >= 1 else 0, 3),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, (label, a, k) in enumerate(families):
        tail_sums = [spectral_tail_sum(a, d, N) for d in depths]

        # Predicted rate: d^{-(2k-1)}
        predicted_rate = 2 * k - 1
        predicted = [depths[0] ** predicted_rate / d ** predicted_rate * tail_sums[0]
                     for d in depths]

        ax = axes[idx]
        ax.loglog(depths, tail_sums, 'b-', linewidth=2, label='Actual tail sum')
        ax.loglog(depths, predicted, 'r--', linewidth=1.5,
                  label=f'Predicted: d^{{-{predicted_rate}}}')
        ax.set_xlabel('Depth d')
        ax.set_ylabel('Spectral tail sum')
        ax.set_title(label)
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Compute log-log slope
        log_d = np.log(depths[10:])
        log_tail = np.log([max(t, 1e-300) for t in tail_sums[10:]])
        slope = np.polyfit(log_d, log_tail, 1)[0]
        print(f"  {label}: measured log-log slope = {slope:.4f}"
              f" (predicted: {-predicted_rate})")

    plt.tight_layout()
    plt.savefig('demo_tail_decay.png', dpi=150)
    plt.close()
    print("  → Saved: demo_tail_decay.png\n")


def demo_upper_lower_bounds():
    """Demo 2: Verify upper and lower bounds for a(n) = 1/n."""
    print("=" * 70)
    print("DEMO 2: Upper and Lower Bound Verification")
    print("=" * 70)

    N = 5000
    a = lambda n: 1.0 / n if n >= 1 else 0
    C = 1.0
    depths = np.arange(1, 201)

    tail_sums = [spectral_tail_sum(a, d, N) for d in depths]
    upper_bounds = [predicted_upper_bound(C, d) for d in depths]
    lower_bounds = [predicted_lower_bound(d) for d in depths]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Log-log plot
    ax1.loglog(depths, tail_sums, 'b-', linewidth=2, label='Actual tail sum')
    ax1.loglog(depths, upper_bounds, 'r--', linewidth=1.5, label='Upper bound: C²/d')
    ax1.loglog(depths, lower_bounds, 'g--', linewidth=1.5, label='Lower bound: 1/(4d)')
    ax1.set_xlabel('Depth d')
    ax1.set_ylabel('Spectral tail sum (squared L² error)')
    ax1.set_title('Spectral Tail Sum: Bounds Verification')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Ratio plot
    upper_ratios = [t / u for t, u in zip(tail_sums, upper_bounds)]
    lower_ratios = [t / l for t, l in zip(tail_sums, lower_bounds)]
    ax2.plot(depths, upper_ratios, 'r-', linewidth=1.5,
             label='Actual / Upper bound')
    ax2.plot(depths, lower_ratios, 'g-', linewidth=1.5,
             label='Actual / Lower bound')
    ax2.axhline(y=1.0, color='k', linestyle=':', alpha=0.5)
    ax2.set_xlabel('Depth d')
    ax2.set_ylabel('Ratio')
    ax2.set_title('Bound Tightness Ratios')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo_bounds.png', dpi=150)
    plt.close()

    print(f"  Upper bound ratio (d=100): {upper_ratios[99]:.4f} (should be ≤ 1)")
    print(f"  Lower bound ratio (d=100): {lower_ratios[99]:.4f} (should be ≥ 1)")
    print(f"  Upper bound holds: {all(r <= 1.001 for r in upper_ratios)}")
    print(f"  Lower bound holds: {all(r >= 0.999 for r in lower_ratios)}")
    print("  → Saved: demo_bounds.png\n")


def demo_epsilon_depth():
    """Demo 3: Epsilon-depth tradeoff — given ε, compute required depth."""
    print("=" * 70)
    print("DEMO 3: Epsilon-Depth Tradeoff")
    print("=" * 70)

    N = 10000
    C = 1.0
    a = lambda n: 1.0 / n if n >= 1 else 0

    epsilons = [0.1, 0.05, 0.01, 0.005, 0.001]

    print(f"  {'ε':>10s} | {'Predicted d':>12s} | {'Actual min d':>12s} | {'Ratio':>8s}")
    print("  " + "-" * 50)

    predicted_depths = []
    actual_depths = []

    for eps in epsilons:
        # Predicted depth: d = ⌈C²/ε⌉
        d_pred = int(np.ceil(C ** 2 / eps))
        predicted_depths.append(d_pred)

        # Find actual minimum depth
        d_actual = 1
        while d_actual < N:
            if spectral_tail_sum(a, d_actual, N) <= eps:
                break
            d_actual += 1
        actual_depths.append(d_actual)

        ratio = d_actual / d_pred if d_pred > 0 else float('inf')
        print(f"  {eps:>10.5f} | {d_pred:>12d} | {d_actual:>12d} | {ratio:>8.3f}")

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.loglog(epsilons, predicted_depths, 'r--o', linewidth=2,
              markersize=8, label='Predicted: ⌈C²/ε⌉')
    ax.loglog(epsilons, actual_depths, 'b-s', linewidth=2,
              markersize=8, label='Actual minimum depth')
    ax.set_xlabel('Target accuracy ε')
    ax.set_ylabel('Required depth d')
    ax.set_title('Epsilon-Depth Tradeoff')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.invert_xaxis()

    plt.tight_layout()
    plt.savefig('demo_epsilon_depth.png', dpi=150)
    plt.close()
    print("  → Saved: demo_epsilon_depth.png\n")


def demo_su2_characters():
    """Demo 4: SU(2) character functions and spectral truncation.

    On SU(2), the irreducible characters are χ_n(θ) = sin((n+1)θ) / sin(θ)
    for a class function parameterized by angle θ ∈ [0, π].
    """
    print("=" * 70)
    print("DEMO 4: SU(2) Character Expansion and Spectral Truncation")
    print("=" * 70)

    theta = np.linspace(0.01, np.pi - 0.01, 500)

    def chi_n(n: int, theta: np.ndarray) -> np.ndarray:
        """SU(2) character χ_n(θ) = sin((n+1)θ) / sin(θ)."""
        return np.sin((n + 1) * theta) / np.sin(theta)

    # Target: f(θ) = ∑_{n=1}^{100} n^{-2} χ_n(θ)
    N_max = 100
    coeffs = {n: 1.0 / n**2 for n in range(1, N_max + 1)}

    def target_f(theta: np.ndarray) -> np.ndarray:
        return sum(coeffs[n] * chi_n(n, theta) for n in range(1, N_max + 1))

    f_vals = target_f(theta)

    # Spectral truncations at various depths
    depths_to_plot = [3, 10, 30, 100]
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for idx, d in enumerate(depths_to_plot):
        ax = axes[idx // 2][idx % 2]

        truncated = sum(coeffs.get(n, 0) * chi_n(n, theta)
                        for n in range(1, d + 1))

        ax.plot(theta, f_vals, 'b-', linewidth=2, label='Target f(θ)', alpha=0.7)
        ax.plot(theta, truncated, 'r--', linewidth=1.5,
                label=f'Truncation T_{d}f')
        ax.fill_between(theta, f_vals, truncated, alpha=0.2, color='orange',
                        label='Error')
        ax.set_xlabel('θ')
        ax.set_ylabel('f(θ)')
        ax.set_title(f'Depth d = {d}')
        ax.legend(loc='upper right')
        ax.grid(True, alpha=0.3)

        # Compute L² error (with Haar measure weight sin²(θ))
        error = np.sqrt(np.trapezoid((f_vals - truncated)**2 * np.sin(theta)**2,
                                  theta))
        predicted = sum(coeffs.get(n, 0)**2 for n in range(d + 1, N_max + 1))
        print(f"  Depth {d:3d}: L² error ≈ {error:.6f}, "
              f"predicted tail sum = {predicted:.6f}")

    plt.suptitle('SU(2) Character Expansion: Spectral Truncation', fontsize=14)
    plt.tight_layout()
    plt.savefig('demo_su2_characters.png', dpi=150)
    plt.close()
    print("  → Saved: demo_su2_characters.png\n")


def demo_log_log_slopes():
    """Demo 5: Log-log error vs depth for multiple decay rates.

    This is the key computational test of the depth-efficiency conjecture:
    the slope should equal -(2k-1) for decay rate k.
    """
    print("=" * 70)
    print("DEMO 5: Log-Log Slopes (Depth-Efficiency Verification)")
    print("=" * 70)

    N = 2000
    depths = np.arange(5, 101)

    decay_rates = [1, 1.5, 2, 2.5, 3]
    colors = ['blue', 'green', 'orange', 'red', 'purple']

    fig, ax = plt.subplots(figsize=(10, 7))

    print(f"  {'Decay k':>8s} | {'Predicted slope':>15s} | {'Measured slope':>15s} | {'Match':>6s}")
    print("  " + "-" * 55)

    for k, color in zip(decay_rates, colors):
        a = lambda n, k=k: 1.0 / n**k if n >= 1 else 0
        tails = [spectral_tail_sum(a, d, N) for d in depths]

        # Filter out zeros for log
        valid = [(d, t) for d, t in zip(depths, tails) if t > 1e-300]
        if len(valid) < 10:
            continue
        vd, vt = zip(*valid)

        ax.loglog(vd, vt, color=color, linewidth=2, label=f'k = {k}')

        # Fit slope
        log_d = np.log(np.array(vd[5:]))
        log_t = np.log(np.array(vt[5:]))
        slope = np.polyfit(log_d, log_t, 1)[0]
        predicted = -(2 * k - 1)
        match = abs(slope - predicted) < 0.1
        print(f"  {k:>8.1f} | {predicted:>15.2f} | {slope:>15.4f} | {'✓' if match else '✗':>6s}")

    ax.set_xlabel('Depth d', fontsize=12)
    ax.set_ylabel('Spectral tail sum (squared L² error)', fontsize=12)
    ax.set_title('Depth-Efficiency: Error vs Depth (Log-Log)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo_log_log_slopes.png', dpi=150)
    plt.close()
    print("  → Saved: demo_log_log_slopes.png\n")


if __name__ == '__main__':
    print("\n" + "=" * 70)
    print("SPECTRAL DEPTH-EFFICIENCY OF qEML NETWORKS")
    print("Computational Verification Suite")
    print("=" * 70 + "\n")

    demo_tail_decay()
    demo_upper_lower_bounds()
    demo_epsilon_depth()
    demo_su2_characters()
    demo_log_log_slopes()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
