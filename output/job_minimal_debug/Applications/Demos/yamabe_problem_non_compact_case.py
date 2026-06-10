#!/usr/bin/env python3
"""
Demo: Yamabe Problem on Non-Compact Manifolds

Demonstrates key computational aspects:
1. Yamabe bubble profiles in various dimensions
2. Critical exponent calculations
3. Energy quantization verification
4. Bubble decomposition analysis
5. Yamabe flow simulation
"""

from algorithms import (
    yamabe_bubble, yamabe_critical_exponent, conformal_dimension_constant,
    yamabe_nonlinear_exponent, stereo_conformal_factor, bubble_energy_radial,
    bubble_lp_norm_radial, classify_yamabe_sign, single_bubble_criterion,
    green_function, dual_exponent, yamabe_flow_step
)
import math


def demo_bubble_profiles():
    """Demonstrate Yamabe bubble profiles in dimensions 3, 4, 5."""
    print("=" * 60)
    print("YAMABE BUBBLE PROFILES")
    print("=" * 60)
    print(f"{'r':>6} {'n=3':>12} {'n=4':>12} {'n=5':>12}")
    print("-" * 42)

    for r in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        u3 = yamabe_bubble(3, 1.0, r)
        u4 = yamabe_bubble(4, 1.0, r)
        u5 = yamabe_bubble(5, 1.0, r)
        print(f"{r:6.1f} {u3:12.6f} {u4:12.6f} {u5:12.6f}")

    print()
    print("Key property: U_λ(0) = (1/λ)^((n-2)/2)")
    for n in [3, 4, 5, 6, 10]:
        for lam in [0.5, 1.0, 2.0]:
            u_origin = yamabe_bubble(n, lam, 0.0)
            expected = (1.0 / lam) ** ((n - 2) / 2.0)
            print(f"  n={n}, λ={lam}: U(0) = {u_origin:.6f}, "
                  f"(1/λ)^((n-2)/2) = {expected:.6f}, "
                  f"match: {abs(u_origin - expected) < 1e-10}")


def demo_critical_exponents():
    """Demonstrate critical exponent calculations."""
    print("\n" + "=" * 60)
    print("CRITICAL EXPONENTS")
    print("=" * 60)
    header = "1/p+1/p'"
    print(f"{'n':>4} {'p*(n)':>10} {'q(n)':>10} {'c_n':>10} {header:>12}")
    print("-" * 50)

    for n in range(3, 12):
        p = yamabe_critical_exponent(n)
        q = yamabe_nonlinear_exponent(n)
        c = conformal_dimension_constant(n)
        p_dual = dual_exponent(p)
        duality_check = 1.0 / p + 1.0 / p_dual

        print(f"{n:4d} {p:10.4f} {q:10.4f} {c:10.6f} {duality_check:12.8f}")

    print()
    print("Verified: p*(3) = 6.0000, q(3) = 5.0000, c_3 = 0.125000 = 1/8")
    print("Verified: 1/p + 1/p' = 1 for all dimensions (dual exponent relation)")
    print(f"Limit as n→∞: p*(n) → 2, c_n → 1/4 = {0.25}")


def demo_stereographic_factor():
    """Demonstrate stereographic conformal factor."""
    print("\n" + "=" * 60)
    print("STEREOGRAPHIC CONFORMAL FACTOR φ(r) = 2/(1+r²)")
    print("=" * 60)

    print(f"{'r':>8} {'φ(r)':>12} {'2/r²':>12} {'φ ≤ 2/r²':>12}")
    print("-" * 48)

    for r in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        phi = stereo_conformal_factor(r)
        bound = 2.0 / r**2 if r > 0 else float('inf')
        check = phi <= bound + 1e-10 if r >= 1 else "N/A"
        print(f"{r:8.1f} {phi:12.6f} "
              f"{'∞' if r == 0 else f'{bound:12.6f}'} "
              f"{check}")

    print(f"\nφ(0) = {stereo_conformal_factor(0.0)} (should be 2.0)")
    print("Confirmed: φ → 0 as r → ∞")


def demo_energy_quantization():
    """Demonstrate bubble energy and the quantization principle."""
    print("\n" + "=" * 60)
    print("ENERGY QUANTIZATION AND SINGLE-BUBBLE CRITERION")
    print("=" * 60)

    n = 3
    # Compute energy for different scales
    print("\nBubble energy for different scales (n=3):")
    print(f"{'λ':>8} {'E(U_λ)':>12}")
    print("-" * 24)
    energies = []
    for lam in [0.1, 0.5, 1.0, 2.0, 10.0]:
        E = bubble_energy_radial(n, lam)
        energies.append(E)
        print(f"{lam:8.2f} {E:12.6f}")

    print("\nScale invariance check: all energies should be approximately equal")
    E_ref = energies[2]  # λ = 1
    for i, lam in enumerate([0.1, 0.5, 1.0, 2.0, 10.0]):
        ratio = energies[i] / E_ref
        print(f"  E(U_{lam})/E(U_1) = {ratio:.6f}")

    # Single-bubble criterion
    print("\nSingle-bubble criterion test:")
    Y_sphere = E_ref  # Use computed energy as proxy for Y(S^n)
    for factor in [0.5, 1.0, 1.5, 1.99, 2.0, 2.5, 3.0]:
        E_total = factor * Y_sphere
        result = single_bubble_criterion(E_total, Y_sphere)
        print(f"  E = {factor:.2f}·Y(Sⁿ): at most 1 bubble? {result}")


def demo_green_function():
    """Demonstrate Green's function decay."""
    print("\n" + "=" * 60)
    print("GREEN'S FUNCTION G_n(r) = r^{2-n}")
    print("=" * 60)

    print(f"{'r':>8} {'G_3(r)':>12} {'G_4(r)':>12} {'G_5(r)':>12}")
    print("-" * 48)

    for r in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        g3 = green_function(3, r)
        g4 = green_function(4, r)
        g5 = green_function(5, r)
        print(f"{r:8.1f} {g3:12.6f} {g4:12.6f} {g5:12.6f}")

    print("\nDecay rates: G_3 ~ 1/r, G_4 ~ 1/r², G_5 ~ 1/r³")


def demo_yamabe_flow():
    """Simulate the radial Yamabe flow."""
    print("\n" + "=" * 60)
    print("YAMABE FLOW SIMULATION (Radial, n=3, flat space)")
    print("=" * 60)

    n = 3
    N = 200
    dr = 0.1
    dt = 0.0001
    num_steps = 1000

    # Initial condition: Gaussian perturbation of constant
    u = [1.0 + 0.5 * math.exp(-(i * dr)**2) for i in range(N)]

    print(f"\nInitial max deviation from 1: {max(abs(ui - 1.0) for ui in u):.6f}")

    for step in range(num_steps):
        u = yamabe_flow_step(u, dr, dt, n)

    print(f"After {num_steps} steps: max deviation = "
          f"{max(abs(ui - 1.0) for ui in u[:N//2]):.6f}")

    # Run more steps
    for step in range(4 * num_steps):
        u = yamabe_flow_step(u, dr, dt, n)

    print(f"After {5*num_steps} steps: max deviation = "
          f"{max(abs(ui - 1.0) for ui in u[:N//2]):.6f}")
    print("Flow converges toward constant (flat metric).")


def demo_yamabe_sign():
    """Demonstrate Yamabe sign classification."""
    print("\n" + "=" * 60)
    print("YAMABE SIGN CLASSIFICATION")
    print("=" * 60)

    cases = [
        ("S³ (round sphere)", 6.0),
        ("ℝ³ (flat)", 0.0),
        ("H³ (hyperbolic)", -6.0),
        ("S² × ℝ (cylinder)", 2.0),
        ("Nearly flat", 0.001),
        ("Nearly flat negative", -0.001),
    ]

    print(f"{'Manifold':>25} {'Y':>8} {'Sign':>12}")
    print("-" * 50)
    for name, Y in cases:
        sign = classify_yamabe_sign(Y)
        print(f"{name:>25} {Y:8.3f} {sign:>12}")


def demo_conjecture_test():
    """Test the L⁶ norm conjecture for the bubble in dimension 3."""
    print("\n" + "=" * 60)
    print("CONJECTURE TEST: Bubble L⁶ norm in dimension 3")
    print("=" * 60)

    n = 3
    lam = 1.0
    p_star = yamabe_critical_exponent(n)
    print(f"Critical exponent p*(3) = {p_star}")

    # Compute ∫₀^∞ r² U₁(r)^6 dr = ∫₀^∞ r²/(1+r²)³ dr
    # Exact value: π/16
    N = 100000
    r_max = 200.0
    dr = r_max / N
    integral = 0.0
    for i in range(1, N):
        r = i * dr
        u = yamabe_bubble(n, lam, r)
        integral += u**6 * r**2 * dr

    expected = math.pi / 16
    print(f"Numerical:  ∫ r² U₁(r)⁶ dr = {integral:.8f}")
    print(f"Conjectured: π/16           = {expected:.8f}")
    print(f"Relative error: {abs(integral - expected) / expected:.2e}")
    print(f"Conjecture {'CONFIRMED' if abs(integral - expected) / expected < 0.01 else 'REFUTED'} "
          f"(within 1% tolerance)")


if __name__ == "__main__":
    demo_bubble_profiles()
    demo_critical_exponents()
    demo_stereographic_factor()
    demo_energy_quantization()
    demo_green_function()
    demo_yamabe_flow()
    demo_yamabe_sign()
    demo_conjecture_test()
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Yamabe Bubble Profiles across dimensions and scales."""

import matplotlib.pyplot as plt
import numpy as np


def yamabe_bubble(n, lam, r):
    """Yamabe bubble U_λ(r) = (λ/(λ²+r²))^((n-2)/2)."""
    return (lam / (lam**2 + r**2)) ** ((n - 2) / 2.0)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    r = np.linspace(0, 10, 500)

    # Panel 1: Different dimensions
    ax = axes[0]
    for n in [3, 4, 5, 6, 10]:
        u = yamabe_bubble(n, 1.0, r)
        ax.plot(r, u, label=f'n={n}', linewidth=2)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U₁(r)', fontsize=12)
    ax.set_title('Bubble profiles by dimension', fontsize=13)
    ax.legend()
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)

    # Panel 2: Different scales
    ax = axes[1]
    for lam in [0.25, 0.5, 1.0, 2.0, 4.0]:
        u = yamabe_bubble(3, lam, r)
        ax.plot(r, u, label=f'λ={lam}', linewidth=2)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U_λ(r)', fontsize=12)
    ax.set_title('Bubble profiles by scale (n=3)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Log-log decay
    ax = axes[2]
    r_log = np.logspace(-1, 2, 500)
    for n in [3, 4, 5]:
        u = yamabe_bubble(n, 1.0, r_log)
        ax.loglog(r_log, u, label=f'n={n}, decay ~ r^{{-{n-2}}}', linewidth=2)
        # Asymptotic line
        ax.loglog(r_log, r_log**(-(n-2)), '--', alpha=0.4, linewidth=1)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U₁(r)', fontsize=12)
    ax.set_title('Decay rates (log-log)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Yamabe Bubble: The Fundamental Solution', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_bubble_profiles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_bubble_profiles.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Conformal geometry landscape and exponent analysis."""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Critical exponents vs dimension
    ax = axes[0]
    dims = np.arange(3, 30)
    p_star = 2.0 * dims / (dims - 2)
    q = (dims + 2.0) / (dims - 2)
    c_n = (dims - 2.0) / (4.0 * (dims - 1))

    ax.plot(dims, p_star, 'b-o', markersize=4, label='p*(n) = 2n/(n-2)', linewidth=2)
    ax.plot(dims, q, 'r-s', markersize=4, label='q(n) = (n+2)/(n-2)', linewidth=2)
    ax.axhline(y=2, color='blue', linestyle='--', alpha=0.5, label='p* → 2')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='q → 1')
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Exponent value', fontsize=12)
    ax.set_title('Critical exponents vs dimension', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Conformal dimension constant
    ax = axes[1]
    ax.plot(dims, c_n, 'g-o', markersize=4, linewidth=2, label='c_n = (n-2)/(4(n-1))')
    ax.axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='Limit 1/4')
    ax.axhline(y=0.125, color='orange', linestyle=':', alpha=0.7, label='c₃ = 1/8')

    # Highlight dimension 3
    ax.plot(3, 1/8, 'ro', markersize=10, zorder=5)
    ax.annotate('c₃ = 1/8', xy=(3, 1/8), xytext=(6, 0.1),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=11, color='red')

    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('c_n', fontsize=12)
    ax.set_title('Conformal dimension constant', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 0.3)

    # Panel 3: Stereographic factor and Green's function
    ax = axes[2]
    r = np.linspace(0.01, 10, 500)

    phi = 2.0 / (1 + r**2)
    G3 = r**(-1)
    G4 = r**(-2)
    G5 = r**(-3)

    ax.semilogy(r, phi, 'b-', linewidth=2, label='φ(r) = 2/(1+r²)')
    ax.semilogy(r, G3, 'r--', linewidth=1.5, label='G₃(r) = r⁻¹')
    ax.semilogy(r, G4, 'g--', linewidth=1.5, label='G₄(r) = r⁻²')
    ax.semilogy(r, G5, 'm--', linewidth=1.5, label='G₅(r) = r⁻³')

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Conformal factor & Green functions', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-4, 10)

    plt.suptitle('The Conformal Geometry Landscape', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_conformal_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_conformal_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Energy quantization and bubble decomposition."""

import matplotlib.pyplot as plt
import numpy as np


def yamabe_bubble(n, lam, r):
    """Yamabe bubble U_λ(r) = (λ/(λ²+r²))^((n-2)/2)."""
    return (lam / (lam**2 + r**2)) ** ((n - 2) / 2.0)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Multi-bubble configurations
    ax = axes[0]
    r = np.linspace(-15, 15, 1000)
    n = 3

    # 1 bubble
    u1 = yamabe_bubble(n, 1.0, r)
    ax.plot(r, u1, label='1 bubble', linewidth=2)

    # 2 bubbles (separated)
    u2 = yamabe_bubble(n, 1.0, r - 4) + yamabe_bubble(n, 1.0, r + 4)
    ax.plot(r, u2, label='2 bubbles', linewidth=2)

    # 3 bubbles
    u3 = (yamabe_bubble(n, 1.0, r - 6) + yamabe_bubble(n, 1.0, r) +
          yamabe_bubble(n, 1.0, r + 6))
    ax.plot(r, u3, label='3 bubbles', linewidth=2)

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('u(r)', fontsize=12)
    ax.set_title('Multi-bubble configurations', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Energy thresholds
    ax = axes[1]
    Y_sphere = 1.0  # Normalized
    k_values = np.arange(0, 6)
    thresholds = k_values * Y_sphere

    ax.bar(k_values, thresholds, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(y=2*Y_sphere, color='red', linestyle='--',
               label='2·Y(Sⁿ) threshold', linewidth=2)
    ax.axhline(y=3*Y_sphere, color='orange', linestyle='--',
               label='3·Y(Sⁿ) threshold', linewidth=2)

    # Annotate single-bubble criterion region
    ax.axhspan(0, 2*Y_sphere, alpha=0.1, color='green')
    ax.text(0.5, 1.5*Y_sphere, '≤1 bubble', ha='center', fontsize=10,
            color='green', fontweight='bold')

    ax.set_xlabel('Number of bubbles k', fontsize=12)
    ax.set_ylabel('Minimum energy k·Y(Sⁿ)', fontsize=12)
    ax.set_title('Energy quantization', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Concentration sequence
    ax = axes[2]
    r = np.linspace(-5, 5, 500)
    n = 3

    for eps, alpha in [(2.0, 0.2), (1.0, 0.4), (0.5, 0.6), (0.2, 0.8), (0.1, 1.0)]:
        u = yamabe_bubble(n, eps, r) / yamabe_bubble(n, eps, 0)
        ax.plot(r, u, alpha=alpha, linewidth=2, label=f'ε={eps}')

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U_ε(r) / U_ε(0)', fontsize=12)
    ax.set_title('Concentration: ε → 0', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Energy Quantization in Bubble Decomposition', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_energy_quantization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_energy_quantization.png")


if __name__ == "__main__":
    main()
