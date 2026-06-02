#!/usr/bin/env python3
"""
Quantum Zeta Spectrum: Numerical Demonstration

Computes the q-Casimir spectrum for the quantum deformation parameter
θ = π·γ₁ where γ₁ ≈ 14.134725 is the first non-trivial Riemann zero,
and analyzes its spectral statistics.
"""

import numpy as np

# ============================================================
# Core functions
# ============================================================

def q_integer(theta: float, n: int) -> float:
    """Compute the trigonometric q-integer [n]_q = sin(nθ)/sin(θ)."""
    s = np.sin(theta)
    if abs(s) < 1e-15:
        return float(n)  # classical limit
    return np.sin(n * theta) / s


def q_casimir(theta: float, n: int) -> float:
    """Compute the q-Casimir eigenvalue [n]_q · [n+1]_q."""
    return q_integer(theta, n) * q_integer(theta, n + 1)


def casimir_oscillation(theta: float, n: int) -> float:
    """The oscillatory part: cos((2n+1)θ)."""
    return np.cos((2 * n + 1) * theta)


# ============================================================
# Demonstrations
# ============================================================

def demo_chebyshev_recurrence():
    """Verify the Chebyshev recurrence numerically."""
    print("=" * 60)
    print("Demo 1: Chebyshev Recurrence Verification")
    print("  sin((n+2)θ) + sin(nθ) = 2cos(θ)sin((n+1)θ)")
    print("=" * 60)

    gamma1 = 14.134725
    theta = np.pi * gamma1

    for n in range(10):
        lhs = np.sin((n + 2) * theta) + np.sin(n * theta)
        rhs = 2 * np.cos(theta) * np.sin((n + 1) * theta)
        err = abs(lhs - rhs)
        print(f"  n={n:2d}: LHS={lhs:+.10f}  RHS={rhs:+.10f}  error={err:.2e}")


def demo_product_to_sum():
    """Verify the product-to-sum formula numerically."""
    print("\n" + "=" * 60)
    print("Demo 2: Product-to-Sum Formula Verification")
    print("  2sin(nθ)sin((n+1)θ) = cos(θ) - cos((2n+1)θ)")
    print("=" * 60)

    gamma1 = 14.134725
    theta = np.pi * gamma1

    for n in range(10):
        lhs = 2 * np.sin(n * theta) * np.sin((n + 1) * theta)
        rhs = np.cos(theta) - np.cos((2 * n + 1) * theta)
        err = abs(lhs - rhs)
        print(f"  n={n:2d}: LHS={lhs:+.10f}  RHS={rhs:+.10f}  error={err:.2e}")


def demo_casimir_spectrum():
    """Compute and display the q-Casimir spectrum."""
    print("\n" + "=" * 60)
    print("Demo 3: q-Casimir Spectrum for θ = π·γ₁")
    print("=" * 60)

    gamma1 = 14.134725
    theta = np.pi * gamma1
    sin_theta = np.sin(theta)

    print(f"  γ₁ = {gamma1}")
    print(f"  θ  = π·γ₁ = {theta:.6f}")
    print(f"  sin(θ) = {sin_theta:.10f}")
    print(f"  1/sin²(θ) = {1/sin_theta**2:.6f}")
    print()

    print(f"  {'n':>3s}  {'[n]_q':>12s}  {'[n+1]_q':>12s}  {'C_q(n)':>12s}  {'cos((2n+1)θ)':>14s}")
    print("  " + "-" * 58)

    for n in range(15):
        qn = q_integer(theta, n)
        qn1 = q_integer(theta, n + 1)
        cn = q_casimir(theta, n)
        osc = casimir_oscillation(theta, n)
        print(f"  {n:3d}  {qn:+12.6f}  {qn1:+12.6f}  {cn:+12.6f}  {osc:+14.6f}")


def demo_dirichlet_sum():
    """Verify the Dirichlet cosine sum identity."""
    print("\n" + "=" * 60)
    print("Demo 4: Dirichlet Cosine Sum Identity")
    print("  2sin(θ)·Σcos((k+1)θ) = sin((N+1)θ) + sin(Nθ) - sin(θ)")
    print("=" * 60)

    theta = 0.7  # generic angle

    for N in range(1, 15):
        lhs = 2 * np.sin(theta) * sum(
            np.cos((k + 1) * theta) for k in range(N)
        )
        rhs = np.sin((N + 1) * theta) + np.sin(N * theta) - np.sin(theta)
        err = abs(lhs - rhs)
        print(f"  N={N:2d}: LHS={lhs:+.10f}  RHS={rhs:+.10f}  error={err:.2e}")


def demo_spectral_statistics():
    """Compute spacing statistics of the q-Casimir spectrum."""
    print("\n" + "=" * 60)
    print("Demo 5: Spectral Statistics of q-Casimir Eigenvalues")
    print("=" * 60)

    gamma1 = 14.134725
    theta = np.pi * gamma1

    N = 100
    eigenvalues = [q_casimir(theta, n) for n in range(N)]

    # Compute nearest-neighbor spacings
    sorted_eigs = sorted(eigenvalues)
    spacings = [sorted_eigs[i+1] - sorted_eigs[i] for i in range(len(sorted_eigs) - 1)]
    spacings = [s for s in spacings if s > 1e-10]  # remove near-zero spacings

    if spacings:
        mean_spacing = np.mean(spacings)
        std_spacing = np.std(spacings)
        normalized = [s / mean_spacing for s in spacings]

        print(f"  Number of eigenvalues: {N}")
        print(f"  Mean spacing: {mean_spacing:.6f}")
        print(f"  Std deviation: {std_spacing:.6f}")
        print(f"  Spacing ratio (std/mean): {std_spacing/mean_spacing:.6f}")
        print(f"  (GUE prediction: ~0.42, Poisson: ~1.0)")
    else:
        print("  No non-trivial spacings found")


def demo_bound_verification():
    """Verify the |C_q(n)| ≤ 1/sin²(θ) bound."""
    print("\n" + "=" * 60)
    print("Demo 6: Casimir Bound Verification")
    print("  |C_q(n)| ≤ 1/sin²(θ)")
    print("=" * 60)

    gamma1 = 14.134725
    theta = np.pi * gamma1
    bound = 1 / np.sin(theta) ** 2

    print(f"  Bound = 1/sin²(θ) = {bound:.6f}")
    print()

    max_ratio = 0
    for n in range(200):
        cn = abs(q_casimir(theta, n))
        ratio = cn / bound
        max_ratio = max(max_ratio, ratio)

    print(f"  Max |C_q(n)|/bound over n=0..199: {max_ratio:.6f}")
    print(f"  Bound satisfied: {max_ratio <= 1.0 + 1e-10}")


if __name__ == "__main__":
    demo_chebyshev_recurrence()
    demo_product_to_sum()
    demo_casimir_spectrum()
    demo_dirichlet_sum()
    demo_spectral_statistics()
    demo_bound_verification()


#!/usr/bin/env python3
"""
Visualization: q-Casimir Spectrum for the Riemann Zero Deformation

Generates three plots:
1. The q-Casimir eigenvalues vs representation label
2. The oscillatory decomposition: constant part vs cos((2n+1)θ)
3. Nearest-neighbor spacing distribution compared to GUE/Poisson
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def q_integer(theta, n):
    s = np.sin(theta)
    if abs(s) < 1e-15:
        return float(n)
    return np.sin(n * theta) / s


def q_casimir(theta, n):
    return q_integer(theta, n) * q_integer(theta, n + 1)


def casimir_oscillation(theta, n):
    return np.cos((2 * n + 1) * theta)


def main():
    gamma1 = 14.134725
    theta = np.pi * gamma1
    N = 200

    ns = np.arange(N)
    eigenvalues = np.array([q_casimir(theta, n) for n in ns])
    oscillations = np.array([casimir_oscillation(theta, n) for n in ns])

    fig, axes = plt.subplots(3, 1, figsize=(12, 14))

    # Plot 1: q-Casimir spectrum
    ax1 = axes[0]
    ax1.plot(ns, eigenvalues, 'b-', linewidth=0.8, alpha=0.7)
    ax1.scatter(ns[:30], eigenvalues[:30], c='red', s=15, zorder=5)
    bound = 1 / np.sin(theta) ** 2
    ax1.axhline(y=bound, color='green', linestyle='--', alpha=0.5,
                label=f'Upper bound 1/sin²(θ) = {bound:.4f}')
    ax1.axhline(y=-bound, color='green', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Representation label n', fontsize=12)
    ax1.set_ylabel('q-Casimir eigenvalue C_q(n)', fontsize=12)
    ax1.set_title(f'q-Casimir Spectrum for θ = π·γ₁ (γ₁ ≈ {gamma1})',
                  fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Oscillatory decomposition
    ax2 = axes[1]
    sin2 = np.sin(theta) ** 2
    constant_part = np.full(N, np.cos(theta) / (2 * sin2))
    ax2.axhline(y=np.cos(theta) / (2 * sin2), color='blue', linestyle='-',
                linewidth=2, label='Constant: cos(θ)/(2sin²θ)')
    ax2.plot(ns, -oscillations / (2 * sin2), 'r-', linewidth=0.6, alpha=0.7,
             label='-cos((2n+1)θ)/(2sin²θ)')
    ax2.plot(ns, eigenvalues, 'k-', linewidth=0.5, alpha=0.4,
             label='C_q(n) = sum')
    ax2.set_xlabel('Representation label n', fontsize=12)
    ax2.set_ylabel('Eigenvalue components', fontsize=12)
    ax2.set_title('Casimir Eigenvalue = Constant + Oscillation (Explicit Formula Analog)',
                  fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 50)

    # Plot 3: Spacing distribution
    ax3 = axes[2]
    sorted_eigs = np.sort(eigenvalues)
    spacings = np.diff(sorted_eigs)
    spacings = spacings[spacings > 1e-10]
    if len(spacings) > 0:
        mean_s = np.mean(spacings)
        normalized_spacings = spacings / mean_s

        ax3.hist(normalized_spacings, bins=30, density=True, alpha=0.7,
                 color='steelblue', edgecolor='black', label='q-Casimir spacings')

        # Poisson prediction: P(s) = e^{-s}
        s_range = np.linspace(0, 4, 200)
        ax3.plot(s_range, np.exp(-s_range), 'r--', linewidth=2,
                 label='Poisson: e^{-s}')

        # GUE prediction: P(s) ≈ (32/π²)s² e^{-4s²/π}
        gue = (32 / np.pi ** 2) * s_range ** 2 * np.exp(-4 * s_range ** 2 / np.pi)
        ax3.plot(s_range, gue, 'g-', linewidth=2,
                 label='GUE: (32/π²)s²e^{-4s²/π}')

        ax3.set_xlabel('Normalized spacing s', fontsize=12)
        ax3.set_ylabel('Probability density', fontsize=12)
        ax3.set_title('Nearest-Neighbor Spacing Distribution', fontsize=14)
        ax3.legend(fontsize=10)
        ax3.set_xlim(0, 4)
        ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_zeta_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_zeta_spectrum.png")


if __name__ == "__main__":
    main()
