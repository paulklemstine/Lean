#!/usr/bin/env python3
"""
Demo: Topological Quantum Computing — Braiding Universality

Demonstrates key results:
1. Fibonacci anyon braiding matrices and their properties
2. Approximation of SU(2) elements by braid words
3. Solovay-Kitaev convergence
4. Topological error protection
5. Jones polynomial evaluation
"""

import numpy as np
import cmath
from algorithms import (
    golden_ratio, fibonacci_braiding_matrix, fibonacci_f_matrix,
    random_su2, brute_force_approximation, solovay_kitaev_depth,
    kauffman_bracket_unknot, kauffman_loop_value,
    jones_polynomial_trefoil, jones_polynomial_figure_eight,
    topological_error_rate, required_system_size,
    check_density_criterion, commutator, check_lie_algebra_generation,
    operator_distance, BraidWord, BraidGenerator, evaluate_braid_word
)


def demo_golden_ratio():
    """Demonstrate golden ratio properties."""
    print("=" * 60)
    print("DEMO 1: Golden Ratio and Fibonacci Anyons")
    print("=" * 60)

    phi = golden_ratio()
    print(f"\nGolden ratio φ = {phi:.10f}")
    print(f"φ² = {phi**2:.10f}")
    print(f"φ + 1 = {phi + 1:.10f}")
    print(f"Verified: φ² = φ + 1: {np.isclose(phi**2, phi + 1)}")
    print(f"φ is irrational (approximation test): {not (phi * 1000000).is_integer()}")

    print(f"\nQuantum dimension: d = φ = {phi:.6f}")
    print(f"Total quantum dimension: D² = 2 + φ = {2 + phi:.6f}")
    print()


def demo_braiding_matrices():
    """Demonstrate Fibonacci anyon braiding matrices."""
    print("=" * 60)
    print("DEMO 2: Fibonacci Anyon Braiding Matrices")
    print("=" * 60)

    sigma = fibonacci_braiding_matrix()
    print(f"\nBraiding matrix σ:")
    print(sigma)
    print(f"\nσ is unitary: {np.allclose(sigma @ sigma.conj().T, np.eye(2))}")
    print(f"det(σ) = {np.linalg.det(sigma):.6f}")
    print(f"|det(σ)| = {abs(np.linalg.det(sigma)):.6f}")
    print(f"tr(σ) = {np.trace(sigma):.6f}")
    print(f"|tr(σ)|² = {abs(np.trace(sigma))**2:.6f}")
    print(f"Density criterion (|tr|² < 4): {check_density_criterion(sigma)}")

    # Check σ and σ² generate su(2)
    sigma2 = sigma @ sigma
    C = commutator(sigma, sigma2)
    print(f"\n[σ, σ²] = ")
    print(C)
    print(f"||[σ, σ²]|| = {np.linalg.norm(C):.6f}")
    print(f"σ, σ², [σ,σ²] span su(2): {check_lie_algebra_generation(sigma, sigma2)}")

    F = fibonacci_f_matrix()
    print(f"\nF-matrix (fusion):")
    print(F)
    print(f"F is unitary: {np.allclose(F @ F.T, np.eye(2))}")
    print()


def demo_approximation():
    """Demonstrate braid word approximation of SU(2) elements."""
    print("=" * 60)
    print("DEMO 3: Braid Word Approximation")
    print("=" * 60)

    sigma = fibonacci_braiding_matrix()
    np.random.seed(42)

    print("\nApproximating random SU(2) elements with braid words:")
    print(f"{'Target':>10} {'Best dist':>12} {'Word length':>12}")
    print("-" * 40)

    for trial in range(5):
        target = random_su2()
        dist, word = brute_force_approximation(target, sigma, max_length=6)
        print(f"  Trial {trial+1}    {dist:12.6f}    {len(word):12d}")

    print()


def demo_solovay_kitaev():
    """Demonstrate Solovay-Kitaev convergence."""
    print("=" * 60)
    print("DEMO 4: Solovay-Kitaev Convergence")
    print("=" * 60)

    print(f"\nSK approximation depth for various target errors:")
    print(f"{'ε₀':>8} {'ε_target':>12} {'SK depth':>10} {'Achieved error':>16}")
    print("-" * 50)

    for eps0 in [0.5, 0.3, 0.1]:
        for target in [1e-3, 1e-6, 1e-9, 1e-12]:
            depth = solovay_kitaev_depth(eps0, target)
            achieved = eps0 ** (1.5 ** depth)
            print(f"{eps0:8.2f} {target:12.1e} {depth:10d} {achieved:16.2e}")

    # Demonstrate exponential convergence
    print(f"\nExponential convergence demonstration (ε₀ = 0.5):")
    eps0 = 0.5
    for n in range(1, 15):
        power = 1.5 ** n
        error = eps0 ** power
        print(f"  n = {n:2d}: (3/2)^n = {power:10.2f}, ε₀^{{(3/2)^n}} = {error:.2e}")
        if error < 1e-30:
            break
    print()


def demo_topological_protection():
    """Demonstrate topological error protection."""
    print("=" * 60)
    print("DEMO 5: Topological Error Protection")
    print("=" * 60)

    print(f"\nError rate vs system size (energy gap Δ = 0.5):")
    gap = 0.5
    for L in [1, 2, 5, 10, 20, 50]:
        error = topological_error_rate(gap, L)
        print(f"  L = {L:3d}: error = {error:.6e}")

    print(f"\nRequired system size for target error:")
    for target in [1e-3, 1e-6, 1e-9, 1e-12]:
        L = required_system_size(gap, target)
        print(f"  ε = {target:.0e}: L ≥ {L:.1f}")

    print(f"\nError monotonicity verification:")
    errors = [topological_error_rate(gap, L) for L in range(1, 11)]
    is_monotone = all(errors[i] >= errors[i+1] for i in range(len(errors)-1))
    print(f"  Error strictly decreasing: {is_monotone}")
    print()


def demo_jones_polynomial():
    """Demonstrate Jones polynomial evaluation."""
    print("=" * 60)
    print("DEMO 6: Jones Polynomial")
    print("=" * 60)

    print("\nJones polynomial of the trefoil knot V_T(t):")
    for t_val in [1.0, -1.0, cmath.exp(2j*cmath.pi/5), cmath.exp(2j*cmath.pi/3)]:
        V = jones_polynomial_trefoil(t_val)
        print(f"  V_T({t_val:.4f}) = {V:.6f}")

    print(f"\nJones polynomial of the figure-eight knot V_8(t):")
    for t_val in [1.0, -1.0, cmath.exp(2j*cmath.pi/5)]:
        V = jones_polynomial_figure_eight(t_val)
        print(f"  V_8({t_val:.4f}) = {V:.6f}")

    print(f"\nKauffman bracket loop value d = -A² - A⁻²:")
    for A_val in [1j, cmath.exp(1j*cmath.pi/4), cmath.exp(1j*cmath.pi/5)]:
        d = kauffman_loop_value(A_val)
        print(f"  A = {A_val:.4f}: d = {d:.6f}")

    print(f"\nV_T(1) = {jones_polynomial_trefoil(1.0):.6f} (should be 1 for knots)")
    print(f"V_8(1) = {jones_polynomial_figure_eight(1.0):.6f} (should be 1 for knots)")
    print()


def demo_conjecture_test():
    """Test the Fibonacci approximation efficiency conjecture."""
    print("=" * 60)
    print("DEMO 7: Fibonacci Approximation Efficiency Conjecture")
    print("=" * 60)

    print("\nConjecture: Optimal braid word length grows as O(log²(1/ε))")
    print("Test: For ε = 10^{-n}, measure shortest word achieving ε-approximation")
    print()

    sigma = fibonacci_braiding_matrix()
    np.random.seed(123)
    target = random_su2()

    print(f"{'n':>4} {'ε = 10^-n':>12} {'Best dist':>12} {'Word len':>10} {'n²':>6} {'n^4':>8}")
    print("-" * 55)

    for n in range(1, 7):
        eps = 10 ** (-n)
        dist, word = brute_force_approximation(target, sigma, max_length=min(n+3, 8))
        wlen = len(word)
        print(f"{n:4d} {eps:12.1e} {dist:12.6f} {wlen:10d} {n**2:6d} {n**4:8d}")

    print("\nNote: Exhaustive search is limited; true optimal lengths require")
    print("more sophisticated algorithms (e.g., continued fraction expansion).")
    print()


if __name__ == "__main__":
    demo_golden_ratio()
    demo_braiding_matrices()
    demo_approximation()
    demo_solovay_kitaev()
    demo_topological_protection()
    demo_jones_polynomial()
    demo_conjecture_test()


#!/usr/bin/env python3
"""
Visualization: Fibonacci Anyon Braiding on the Bloch Sphere
Shows how successive braiding operations trace dense paths on SU(2).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import cmath

def golden_ratio():
    return (1 + np.sqrt(5)) / 2

def fibonacci_braiding_matrix():
    phi = golden_ratio()
    phi_inv = 1 / phi
    F = np.array([[phi_inv, np.sqrt(phi_inv)],
                  [np.sqrt(phi_inv), -phi_inv]])
    R = np.diag([cmath.exp(-4j * cmath.pi / 5),
                 cmath.exp(3j * cmath.pi / 5)])
    return F @ R @ np.linalg.inv(F)

def su2_to_bloch(U):
    """Map SU(2) element to point on S² via action on |0⟩."""
    state = U @ np.array([1, 0], dtype=complex)
    theta = 2 * np.arccos(min(abs(state[0]), 1.0))
    phi_angle = np.angle(state[1]) - np.angle(state[0]) if abs(state[0]) > 1e-10 else 0
    x = np.sin(theta) * np.cos(phi_angle)
    y = np.sin(theta) * np.sin(phi_angle)
    z = np.cos(theta)
    return x, y, z

def main():
    sigma = fibonacci_braiding_matrix()
    sigma_inv = np.linalg.inv(sigma)

    fig = plt.figure(figsize=(14, 6))

    # Left: Braid word orbits on Bloch sphere
    ax1 = fig.add_subplot(121, projection='3d')

    # Draw unit sphere
    u = np.linspace(0, 2 * np.pi, 40)
    v = np.linspace(0, np.pi, 20)
    xs = np.outer(np.cos(u), np.sin(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.ones_like(u), np.cos(v))
    ax1.plot_surface(xs, ys, zs, alpha=0.05, color='lightblue')

    # Generate random braid words and plot their Bloch vectors
    np.random.seed(42)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    for trial in range(5):
        points_x, points_y, points_z = [], [], []
        U = np.eye(2, dtype=complex)
        for step in range(200):
            if np.random.random() < 0.5:
                U = U @ sigma
            else:
                U = U @ sigma_inv
            # Normalize to ensure numerical stability
            U = U / np.sqrt(abs(np.linalg.det(U)))
            x, y, z = su2_to_bloch(U)
            points_x.append(x)
            points_y.append(y)
            points_z.append(z)
        ax1.scatter(points_x, points_y, points_z, s=1, alpha=0.5, c=colors[trial])

    ax1.set_title('Fibonacci Braid Orbits\non Bloch Sphere', fontsize=12)
    ax1.set_xlabel('X')
    ax1.set_ylabel('Y')
    ax1.set_zlabel('Z')

    # Right: Density of braid word matrices (trace distribution)
    ax2 = fig.add_subplot(122)

    traces = []
    U = np.eye(2, dtype=complex)
    for _ in range(10000):
        if np.random.random() < 0.5:
            U = U @ sigma
        else:
            U = U @ sigma_inv
        U = U / np.sqrt(abs(np.linalg.det(U)))
        traces.append(np.real(np.trace(U)))

    ax2.hist(traces, bins=100, density=True, alpha=0.7, color='#3498db',
             edgecolor='#2980b9')

    # Overlay the Weyl distribution for SU(2): ρ(t) = (1/π)√(1 - t²/4)
    t = np.linspace(-2, 2, 200)
    weyl = (1/np.pi) * np.sqrt(np.maximum(1 - t**2/4, 0))
    ax2.plot(t, weyl, 'r-', linewidth=2, label='Weyl measure (Haar)')
    ax2.set_xlabel('Re(tr(U))', fontsize=13)
    ax2.set_ylabel('Density', fontsize=13)
    ax2.set_title('Trace Distribution of Fibonacci\nBraid Words vs Haar Measure', fontsize=12)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('braiding_density.png', dpi=150, bbox_inches='tight')
    print("Saved braiding_density.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Solovay-Kitaev Convergence
Shows how approximation error decreases exponentially with SK depth.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def solovay_kitaev_error(eps0, n):
    """Error after n SK iterations: eps0^{(3/2)^n}."""
    return eps0 ** ((3/2) ** n)

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Error vs SK depth for different initial errors
    ax1 = axes[0]
    depths = np.arange(0, 13)
    for eps0, color, label in [(0.5, '#e74c3c', 'ε₀ = 0.5'),
                                (0.3, '#3498db', 'ε₀ = 0.3'),
                                (0.1, '#2ecc71', 'ε₀ = 0.1')]:
        errors = [solovay_kitaev_error(eps0, n) for n in depths]
        ax1.semilogy(depths, errors, 'o-', color=color, label=label, linewidth=2, markersize=6)

    ax1.set_xlabel('Solovay-Kitaev Depth n', fontsize=13)
    ax1.set_ylabel('Approximation Error', fontsize=13)
    ax1.set_title('Exponential Convergence of SK Approximation', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-40, 1)

    # Right: Topological error protection
    ax2 = axes[1]
    L_values = np.linspace(0.1, 50, 200)
    for gap, color, label in [(0.2, '#e74c3c', 'Δ = 0.2'),
                               (0.5, '#3498db', 'Δ = 0.5'),
                               (1.0, '#2ecc71', 'Δ = 1.0')]:
        errors = np.exp(-gap * L_values)
        ax2.semilogy(L_values, errors, color=color, label=label, linewidth=2)

    ax2.set_xlabel('System Size L', fontsize=13)
    ax2.set_ylabel('Error Probability', fontsize=13)
    ax2.set_title('Topological Error Protection', fontsize=14)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('sk_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved sk_convergence.png")

if __name__ == "__main__":
    main()
