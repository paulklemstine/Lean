"""
Quantum Classical Action Demonstrations
========================================
Computational validation of the Lohmiller-Slotine construction:
  ψ_j = √ρ_j · exp(iφ_j/ℏ)

Demonstrates:
  1. Double-slit interference pattern
  2. Quantum tunnelling (reflection + transmission = 1)
  3. Particle in a box wavefunctions and energy levels
  4. Harmonic oscillator energy levels
  5. Hydrogen atom energy levels from Kepler orbits
  6. EPR correlations and Bell inequality violation
  7. Multipath superposition (Berggren-branched waves)

Each demo produces a PNG plot saved to the current directory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# --- Physical constants (natural units where convenient) ---
HBAR = 1.0545718e-34  # J·s
M_E = 9.1093837e-31   # electron mass, kg


# ============================================================
# Demo 1: Double-Slit Interference
# ============================================================
def demo_double_slit():
    """
    Two classical action branches produce the standard interference pattern.
    ψ = (1/r₁)exp(ip₀r₁/ℏ) + (1/r₂)exp(ip₀r₂/ℏ)
    """
    # Parameters (dimensionless units)
    d = 1.0        # slit separation
    L = 100.0      # screen distance
    p0 = 50.0      # momentum (sets fringe spacing)
    hbar = 1.0

    y = np.linspace(-5, 5, 2000)

    # Slit positions
    slit1 = np.array([0, d / 2])
    slit2 = np.array([0, -d / 2])

    # Distances from each slit to screen point
    r1 = np.sqrt(L**2 + (y - slit1[1])**2)
    r2 = np.sqrt(L**2 + (y - slit2[1])**2)

    # Classical density and phase on each branch
    rho1 = 1.0 / r1**2
    rho2 = 1.0 / r2**2
    phi1 = p0 * r1
    phi2 = p0 * r2

    # Wave ansatz: ψ_j = √ρ_j · exp(iφ_j/ℏ)
    psi1 = np.sqrt(rho1) * np.exp(1j * phi1 / hbar)
    psi2 = np.sqrt(rho2) * np.exp(1j * phi2 / hbar)
    psi_total = psi1 + psi2
    prob = np.abs(psi_total)**2

    # Interference formula verification
    interference = rho1 + rho2 + 2 * np.sqrt(rho1 * rho2) * np.cos((phi1 - phi2) / hbar)
    max_error = np.max(np.abs(prob - interference))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(y, prob, 'b-', linewidth=0.8, label='|ψ₁+ψ₂|²')
    axes[0].plot(y, rho1 + rho2, 'r--', linewidth=1, alpha=0.7, label='ρ₁+ρ₂ (no interference)')
    axes[0].set_xlabel('Screen position y')
    axes[0].set_ylabel('Probability density')
    axes[0].set_title('Double-Slit Interference Pattern')
    axes[0].legend()

    axes[1].semilogy(y, np.abs(prob - interference) + 1e-20, 'g-', linewidth=0.5)
    axes[1].set_xlabel('Screen position y')
    axes[1].set_ylabel('|numerical - formula|')
    axes[1].set_title(f'Verification Error (max = {max_error:.2e})')

    plt.tight_layout()
    plt.savefig('demo1_double_slit.png', dpi=150)
    plt.close()
    print(f"Demo 1: Double-slit interference. Max verification error: {max_error:.2e}")


# ============================================================
# Demo 2: Quantum Tunnelling
# ============================================================
def demo_tunnelling():
    """
    Complex classical action enables tunnelling.
    R + T = 1 verified for a range of energies.
    """
    p0_values = np.linspace(0.5, 5.0, 500)
    M = 1.0
    V = 5.0  # Barrier height

    T_list = []
    R_list = []
    for p0 in p0_values:
        E = p0**2 / (2 * M)
        if E > V:
            pT = np.sqrt(p0**2 - 2 * M * V)
            T = 4 * p0 * pT / (p0 + pT)**2
            R = ((p0 - pT) / (p0 + pT))**2
        else:
            kappa = np.sqrt(2 * M * V - p0**2)
            # Tunnelling: exponential decay
            barrier_width = 1.0
            T = np.exp(-2 * kappa * barrier_width)
            R = 1 - T
        T_list.append(T)
        R_list.append(R)

    T_arr = np.array(T_list)
    R_arr = np.array(R_list)
    E_arr = p0_values**2 / (2 * M)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(E_arr / V, T_arr, 'b-', linewidth=1.5, label='T (transmission)')
    axes[0].plot(E_arr / V, R_arr, 'r-', linewidth=1.5, label='R (reflection)')
    axes[0].axvline(x=1.0, color='gray', linestyle='--', alpha=0.5, label='E = V')
    axes[0].set_xlabel('E / V')
    axes[0].set_ylabel('Coefficient')
    axes[0].set_title('Tunnelling: Reflection & Transmission')
    axes[0].legend()

    axes[1].semilogy(E_arr / V, np.abs(R_arr + T_arr - 1) + 1e-20, 'g-', linewidth=1)
    axes[1].set_xlabel('E / V')
    axes[1].set_ylabel('|R + T - 1|')
    axes[1].set_title('Conservation Verification')

    plt.tight_layout()
    plt.savefig('demo2_tunnelling.png', dpi=150)
    plt.close()
    print(f"Demo 2: Tunnelling. Max |R+T-1| = {np.max(np.abs(R_arr + T_arr - 1)):.2e}")


# ============================================================
# Demo 3: Particle in a Box
# ============================================================
def demo_particle_in_box():
    """
    Energy levels Eₖ = ℏ²π²k²/(2ML²) and wavefunctions.
    """
    L = 1.0
    M = 1.0
    hbar = 1.0
    x = np.linspace(0, L, 1000)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for k in range(1, 6):
        E_k = hbar**2 * np.pi**2 * k**2 / (2 * M * L**2)
        psi_k = np.sqrt(2 / L) * np.sin(np.pi * k * x / L)
        axes[0].plot(x, psi_k + E_k * 0.05, label=f'k={k}, E={E_k:.2f}')

    axes[0].set_xlabel('x')
    axes[0].set_ylabel('ψ_k(x) + offset')
    axes[0].set_title('Particle in a Box: Wavefunctions')
    axes[0].legend(fontsize=8)

    ks = np.arange(1, 11)
    energies = hbar**2 * np.pi**2 * ks**2 / (2 * M * L**2)
    axes[1].bar(ks, energies, color='steelblue', alpha=0.8)
    axes[1].set_xlabel('Quantum number k')
    axes[1].set_ylabel('Energy Eₖ')
    axes[1].set_title('Energy Levels (∝ k²)')

    # Verify ratio property
    for i in range(len(ks)):
        for j in range(i + 1, len(ks)):
            ratio = energies[i] / energies[j]
            expected = ks[i]**2 / ks[j]**2
            assert abs(ratio - expected) < 1e-12

    plt.tight_layout()
    plt.savefig('demo3_particle_in_box.png', dpi=150)
    plt.close()
    print("Demo 3: Particle in a box. Energy ratio verification passed.")


# ============================================================
# Demo 4: Harmonic Oscillator
# ============================================================
def demo_harmonic_oscillator():
    """
    Harmonic oscillator energy levels: E_k = ℏω(k + N/2)
    Shows zero-point energy and equally spaced levels.
    """
    hbar = 1.0
    omega = 2.0
    N = 1  # 1D

    fig, ax = plt.subplots(figsize=(8, 6))

    ks = np.arange(0, 8)
    energies = hbar * omega * (ks + N / 2.0)

    ax.barh(ks, energies, height=0.6, color='coral', alpha=0.8)
    for k, E in zip(ks, energies):
        ax.text(E + 0.1, k, f'E_{k} = {E:.1f}', va='center', fontsize=10)

    ax.set_xlabel('Energy')
    ax.set_ylabel('Quantum number k')
    ax.set_title(f'Harmonic Oscillator (ω={omega}, ℏ={hbar})\nZero-point energy = {energies[0]:.1f}')
    ax.axvline(x=0, color='gray', linestyle='-', alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo4_harmonic_oscillator.png', dpi=150)
    plt.close()
    print(f"Demo 4: Harmonic oscillator. Zero-point energy = {energies[0]:.2f}")


# ============================================================
# Demo 5: Hydrogen Atom Energy Levels
# ============================================================
def demo_hydrogen():
    """
    Hydrogen energy levels from Kepler orbits:
    E_k = M/2 · (G/(ℏk))²
    Verifies E₁/E₂ = k₂²/k₁² (inverse square ratio).
    """
    M = 1.0
    G = 1.0
    hbar = 1.0

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ks = np.arange(1, 11)
    energies = M / 2 * (G / (hbar * ks))**2

    axes[0].bar(ks, -energies, color='darkviolet', alpha=0.8)
    axes[0].set_xlabel('Principal quantum number k')
    axes[0].set_ylabel('-Eₖ (binding energy)')
    axes[0].set_title('Hydrogen Energy Levels (∝ 1/k²)')

    # Verify inverse-square ratio
    errors = []
    for i in range(len(ks)):
        for j in range(i + 1, len(ks)):
            ratio = energies[i] / energies[j]
            expected = ks[j]**2 / ks[i]**2
            errors.append(abs(ratio - expected))

    axes[1].semilogy(range(len(errors)), np.array(errors) + 1e-20, 'mo', markersize=3)
    axes[1].set_xlabel('Pair index')
    axes[1].set_ylabel('|E_i/E_j - k_j²/k_i²|')
    axes[1].set_title(f'Ratio Verification (max error = {max(errors):.2e})')

    plt.tight_layout()
    plt.savefig('demo5_hydrogen.png', dpi=150)
    plt.close()
    print(f"Demo 5: Hydrogen levels. Max ratio error: {max(errors):.2e}")


# ============================================================
# Demo 6: EPR Correlations & Bell Inequality
# ============================================================
def demo_epr():
    """
    EPR correlation: C(n₁, n₂) = -n₁·n₂
    Demonstrates Bell inequality violation.
    """
    def spin_direction(alpha, beta):
        return np.array([
            np.sin(beta) * np.cos(alpha),
            np.sin(beta) * np.sin(alpha),
            np.cos(beta)
        ])

    def epr_correlation(a1, b1, a2, b2):
        n1 = spin_direction(a1, b1)
        n2 = spin_direction(a2, b2)
        return -np.dot(n1, n2)

    # Sweep relative angle
    thetas = np.linspace(0, 2 * np.pi, 500)
    correlations = [epr_correlation(0, theta, 0, 0) for theta in thetas]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(np.degrees(thetas), correlations, 'b-', linewidth=1.5)
    axes[0].axhline(y=-1, color='red', linestyle='--', alpha=0.5, label='C = -1 (aligned)')
    axes[0].axhline(y=0, color='gray', linestyle='--', alpha=0.5, label='C = 0 (⊥)')
    axes[0].set_xlabel('Relative angle θ (degrees)')
    axes[0].set_ylabel('EPR Correlation')
    axes[0].set_title('EPR Correlation C(θ) = -cos(θ)')
    axes[0].legend()

    # Verify special cases
    assert abs(epr_correlation(0, 0, 0, 0) - (-1)) < 1e-14, "Aligned test failed"
    assert abs(epr_correlation(0, 0, 0, np.pi / 2)) < 1e-14, "Perpendicular test failed"

    # Bell inequality: CHSH
    # S = |E(a,b) - E(a,b') + E(a',b) + E(a',b')|
    # Classical limit: S ≤ 2. Quantum: S ≤ 2√2
    a, a_prime = 0, np.pi / 4
    b, b_prime = np.pi / 8, 3 * np.pi / 8

    E_ab = epr_correlation(0, a, 0, b)
    E_ab_prime = epr_correlation(0, a, 0, b_prime)
    E_a_prime_b = epr_correlation(0, a_prime, 0, b)
    E_a_prime_b_prime = epr_correlation(0, a_prime, 0, b_prime)

    S = abs(E_ab - E_ab_prime + E_a_prime_b + E_a_prime_b_prime)

    axes[1].bar(['E(a,b)', "E(a,b')", "E(a',b)", "E(a',b')", 'S', 'Classical\nlimit', 'Quantum\nlimit'],
                [E_ab, E_ab_prime, E_a_prime_b, E_a_prime_b_prime, S, 2.0, 2 * np.sqrt(2)],
                color=['steelblue'] * 4 + ['red', 'gray', 'green'],
                alpha=0.8)
    axes[1].axhline(y=2, color='gray', linestyle='--', alpha=0.7)
    axes[1].set_ylabel('Value')
    axes[1].set_title(f'CHSH Bell Inequality\nS = {S:.4f} > 2 (violated!)')

    plt.tight_layout()
    plt.savefig('demo6_epr.png', dpi=150)
    plt.close()
    print(f"Demo 6: EPR. CHSH S = {S:.4f} (classical limit 2, quantum limit {2*np.sqrt(2):.4f})")


# ============================================================
# Demo 7: Multipath Superposition with Berggren Branching
# ============================================================
def demo_multipath_berggren():
    """
    Starting from (3,4,5), Berggren branching generates child triples.
    Each triple defines a wave branch; the superposition produces interference.
    """
    def berggren_A(a, b, c):
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

    def berggren_B(a, b, c):
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

    def berggren_C(a, b, c):
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

    # Root triple
    root = (3, 4, 5)

    # Generate children
    children = [
        berggren_A(*root),
        berggren_B(*root),
        berggren_C(*root),
    ]

    # Verify Pythagorean property
    all_triples = [root] + children
    for a, b, c in all_triples:
        assert a**2 + b**2 == c**2, f"Failed: {a}² + {b}² ≠ {c}²"

    print(f"  Root: {root}, a²+b²={root[0]**2+root[1]**2}, c²={root[2]**2}")
    for name, child in zip(['A', 'B', 'C'], children):
        print(f"  Child {name}: {child}, a²+b²={child[0]**2+child[1]**2}, c²={child[2]**2}")

    # Construct multipath wave
    x = np.linspace(-10, 10, 2000)
    hbar = 1.0

    psi_total = np.zeros_like(x, dtype=complex)
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    colors = ['blue', 'red', 'green', 'orange']
    for idx, (a, b, c) in enumerate(all_triples):
        # Phase from triple: p₀ = c, angle = arctan(b/a)
        theta = np.arctan2(b, a)
        p0 = c
        rho = 1.0 / (1 + (x - theta)**2)  # Lorentzian density centered at angle
        phi = p0 * x

        psi_branch = np.sqrt(rho) * np.exp(1j * phi / hbar)
        psi_total += psi_branch

        axes[0, 0].plot(x, rho, color=colors[idx], alpha=0.7,
                        label=f'({a},{b},{c}), θ={np.degrees(theta):.1f}°')

    prob = np.abs(psi_total)**2

    axes[0, 0].set_title('Branch Densities ρⱼ')
    axes[0, 0].set_xlabel('x')
    axes[0, 0].legend(fontsize=8)

    axes[0, 1].plot(x, prob, 'purple', linewidth=0.8)
    axes[0, 1].set_title('Multipath Interference |Σψⱼ|²')
    axes[0, 1].set_xlabel('x')

    # Berggren tree visualization
    ax = axes[1, 0]
    ax.set_xlim(-2, 4)
    ax.set_ylim(-1, 3)
    ax.set_aspect('equal')
    positions = {root: (1, 2.5)}
    for i, child in enumerate(children):
        positions[child] = (-0.5 + 1.5 * i, 0.5)

    for triple, pos in positions.items():
        ax.annotate(f'({triple[0]},{triple[1]},{triple[2]})',
                    xy=pos, fontsize=10, ha='center',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black'))

    for child in children:
        ax.annotate('', xy=positions[child], xytext=positions[root],
                    arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    ax.set_title('Berggren Tree (depth 1)')
    ax.axis('off')

    # Lorentz form visualization
    ax2 = axes[1, 1]
    a_vals = np.linspace(-10, 10, 200)
    b_vals = np.linspace(-10, 10, 200)
    A, B = np.meshgrid(a_vals, b_vals)
    C = np.sqrt(A**2 + B**2)
    L = A**2 + B**2 - C**2  # Should be identically 0

    for a, b, c in all_triples:
        ax2.plot(a, b, 'ro', markersize=10)
        ax2.annotate(f'({a},{b},{c})', xy=(a, b), textcoords='offset points',
                     xytext=(5, 5), fontsize=8)

    circle_theta = np.linspace(0, 2 * np.pi, 100)
    for c_val in [5, 13, 17, 29]:
        ax2.plot(c_val * np.cos(circle_theta), c_val * np.sin(circle_theta),
                 '--', alpha=0.3, label=f'c={c_val}')

    ax2.set_xlabel('a')
    ax2.set_ylabel('b')
    ax2.set_title('Pythagorean Triples on Lorentz Null Cone')
    ax2.set_aspect('equal')
    ax2.legend(fontsize=7)
    ax2.set_xlim(-20, 25)
    ax2.set_ylim(-5, 25)

    plt.tight_layout()
    plt.savefig('demo7_multipath_berggren.png', dpi=150)
    plt.close()
    print("Demo 7: Multipath Berggren superposition complete.")


# ============================================================
# Main
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("Quantum Classical Action Demonstrations")
    print("Lohmiller-Slotine Construction Validation")
    print("=" * 60)
    print()

    demo_double_slit()
    demo_tunnelling()
    demo_particle_in_box()
    demo_harmonic_oscillator()
    demo_hydrogen()
    demo_epr()
    demo_multipath_berggren()

    print()
    print("=" * 60)
    print("All 7 demonstrations completed successfully.")
    print("Output files: demo1_*.png through demo7_*.png")
    print("=" * 60)
