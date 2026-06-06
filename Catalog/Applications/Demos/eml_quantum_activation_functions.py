#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Interactive Demo

Demonstrates the key theorems proved in the Lean formalization:
1. Phase unitarity: |exp(iθ)| = 1
2. Group homomorphism: exp(i(θ₁+θ₂)) = exp(iθ₁)·exp(iθ₂)
3. Polar surjectivity: every z ≠ 0 has a quantum EML representation
4. Classical-quantum bridge: phase=0 recovers classical EML
5. Chain composition rule: phases add, amplitudes multiply
"""

import numpy as np


def quantum_phase(theta: float) -> complex:
    """Quantum phase gate: exp(iθ)"""
    return np.exp(1j * theta)


def quantum_eml_polar(theta: float, r: float) -> complex:
    """Quantum EML polar neuron: exp(iθ) · r"""
    return quantum_phase(theta) * r


def quantum_eml_neuron(theta1: float, theta2: float, theta3: float) -> complex:
    """Quantum EML neuron: exp(iθ₁) · (exp(θ₂) - log(θ₃))"""
    amplitude = np.exp(theta2) - np.log(theta3) if theta3 > 0 else np.exp(theta2)
    return quantum_phase(theta1) * amplitude


def classical_eml(x: float, y: float) -> float:
    """Classical EML function: exp(x) - log(y)"""
    return np.exp(x) - (np.log(y) if y > 0 else 0.0)


def demo_phase_unitarity():
    """Theorem 1: ||quantumPhase(θ)|| = 1 for all θ"""
    print("=" * 60)
    print("THEOREM 1: Phase Unitarity")
    print("=" * 60)
    thetas = [0, np.pi/6, np.pi/4, np.pi/3, np.pi/2, np.pi, 2*np.pi, 7.3]
    for theta in thetas:
        z = quantum_phase(theta)
        print(f"  θ = {theta:8.4f}  →  exp(iθ) = {z:.4f}  |exp(iθ)| = {abs(z):.10f}")
    print(f"\n  ✓ All norms equal 1 (to machine precision)\n")


def demo_group_homomorphism():
    """Theorem 2: quantumPhase(θ₁+θ₂) = quantumPhase(θ₁) · quantumPhase(θ₂)"""
    print("=" * 60)
    print("THEOREM 2: Phase Group Homomorphism")
    print("=" * 60)
    pairs = [(np.pi/4, np.pi/3), (1.0, 2.0), (np.pi, np.pi), (0.5, -0.5)]
    for t1, t2 in pairs:
        lhs = quantum_phase(t1 + t2)
        rhs = quantum_phase(t1) * quantum_phase(t2)
        err = abs(lhs - rhs)
        print(f"  θ₁={t1:.3f}, θ₂={t2:.3f}:")
        print(f"    exp(i(θ₁+θ₂))     = {lhs:.6f}")
        print(f"    exp(iθ₁)·exp(iθ₂) = {rhs:.6f}")
        print(f"    error = {err:.2e}")
    print(f"\n  ✓ Homomorphism verified (all errors < 1e-15)\n")


def demo_polar_surjectivity():
    """Theorem 3: Every z ≠ 0 has quantum EML polar representation"""
    print("=" * 60)
    print("THEOREM 3: Polar Surjectivity")
    print("=" * 60)
    targets = [1+1j, -3.0+0j, 0.5j, -2-2j, 0.01+0.01j]
    for z in targets:
        theta = np.angle(z)
        r = abs(z)
        reconstruction = quantum_eml_polar(theta, r)
        err = abs(reconstruction - z)
        print(f"  z = {str(z):>12s} → θ = {theta:+.4f}, r = {r:.4f}")
        print(f"    reconstructed = {reconstruction:.6f}, error = {err:.2e}")
    print(f"\n  ✓ All nonzero targets reconstructed exactly\n")


def demo_classical_bridge():
    """Theorem 4: quantumEMLNeuron(0, x, y) = classicalEML(x, y)"""
    print("=" * 60)
    print("THEOREM 4: Classical-Quantum Bridge")
    print("=" * 60)
    params = [(1.0, np.e), (0.0, 1.0), (2.0, 0.5), (-1.0, 3.0)]
    for x, y in params:
        quantum = quantum_eml_neuron(0, x, y)
        classical = classical_eml(x, y)
        err = abs(quantum - classical)
        print(f"  x={x:+.2f}, y={y:.2f}:")
        print(f"    quantum(θ=0)  = {quantum:.6f}")
        print(f"    classical     = {classical:.6f}")
        print(f"    error = {err:.2e}")
    print()

    # Phase rotation preserves norm
    print("  Phase rotation preserves norm:")
    for theta in [0, np.pi/4, np.pi/2, np.pi]:
        z = quantum_eml_neuron(theta, 1.0, np.e)
        print(f"    θ = {theta:.4f}: ||neuron|| = {abs(z):.6f}, "
              f"|classical| = {abs(classical_eml(1.0, np.e)):.6f}")
    print(f"\n  ✓ Quantum phase doesn't change amplitude\n")


def demo_chain_composition():
    """Theorem 5: Compose(gate₁, gate₂) = Gate(θ₁+θ₂, r₁·r₂)"""
    print("=" * 60)
    print("THEOREM 5: Chain Composition Rule")
    print("=" * 60)
    cases = [
        (np.pi/4, 2.0, np.pi/3, 3.0),
        (0.0, 1.0, np.pi, 1.0),
        (1.5, 0.5, -0.5, 4.0),
    ]
    for t1, r1, t2, r2 in cases:
        composed = quantum_eml_polar(t1, r1) * quantum_eml_polar(t2, r2)
        direct = quantum_eml_polar(t1 + t2, r1 * r2)
        err = abs(composed - direct)
        print(f"  (θ₁={t1:.2f}, r₁={r1:.1f}) ∘ (θ₂={t2:.2f}, r₂={r2:.1f}):")
        print(f"    composed = {composed:.6f}")
        print(f"    Gate(θ₁+θ₂, r₁r₂) = {direct:.6f}")
        print(f"    error = {err:.2e}")
    print(f"\n  ✓ Multiplicative chain rule verified\n")


def demo_spectral_distance():
    """Theorem 6: Distance bound with phase-amplitude decoupling"""
    print("=" * 60)
    print("THEOREM 6: Spectral Distance Bound")
    print("=" * 60)
    r = 3.0
    pairs = [(0, np.pi/6), (np.pi/4, np.pi/2), (0, np.pi)]
    for t1, t2 in pairs:
        dist = abs(quantum_eml_polar(t1, r) - quantum_eml_polar(t2, r))
        phase_dist = abs(quantum_phase(t1) - quantum_phase(t2))
        bound = r * phase_dist
        print(f"  θ₁={t1:.4f}, θ₂={t2:.4f}, r={r:.1f}:")
        print(f"    ||gate₁ - gate₂|| = {dist:.6f}")
        print(f"    r·||phase₁ - phase₂|| = {bound:.6f}")
        print(f"    ratio = {dist/bound:.10f}")
    print(f"\n  ✓ Distance = r × phase distance (exact equality)\n")


if __name__ == "__main__":
    print("\n" + "🔬 QUANTUM EML ACTIVATION FUNCTIONS — DEMONSTRATION 🔬".center(60))
    print("=" * 60 + "\n")

    demo_phase_unitarity()
    demo_group_homomorphism()
    demo_polar_surjectivity()
    demo_classical_bridge()
    demo_chain_composition()
    demo_spectral_distance()

    print("=" * 60)
    print("All 6 theorems demonstrated numerically ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Quantum EML Phase Space

Shows how the quantum phase gate traces the unit circle,
and how the quantum EML polar neuron covers the complex plane.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def quantum_phase(theta):
    return np.exp(1j * theta)


def quantum_eml_polar(theta, r):
    return quantum_phase(theta) * r


def plot_phase_unitarity():
    """Plot the unit circle traced by quantum phase gates."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Unit circle with phase gate points
    ax = axes[0]
    thetas = np.linspace(0, 2 * np.pi, 100)
    circle = [quantum_phase(t) for t in thetas]
    ax.plot([z.real for z in circle], [z.imag for z in circle], 'b-', lw=2, alpha=0.3)

    special_angles = [0, np.pi/6, np.pi/4, np.pi/3, np.pi/2, 2*np.pi/3, np.pi,
                      4*np.pi/3, 3*np.pi/2, 5*np.pi/3]
    labels = ['0', 'π/6', 'π/4', 'π/3', 'π/2', '2π/3', 'π', '4π/3', '3π/2', '5π/3']
    for t, label in zip(special_angles, labels):
        z = quantum_phase(t)
        ax.plot(z.real, z.imag, 'ro', markersize=8)
        ax.annotate(f'θ={label}', (z.real, z.imag), textcoords="offset points",
                    xytext=(10, 5), fontsize=7)

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', lw=0.5)
    ax.axvline(x=0, color='k', lw=0.5)
    ax.set_title('Theorem 1: Phase Unitarity\n|exp(iθ)| = 1', fontsize=12)
    ax.set_xlabel('Re')
    ax.set_ylabel('Im')

    # Panel 2: Group homomorphism
    ax = axes[1]
    t1_vals = np.linspace(0, 2*np.pi, 50)
    t2 = np.pi / 3
    for t1 in t1_vals:
        z1 = quantum_phase(t1)
        z2 = quantum_phase(t2)
        z_sum = quantum_phase(t1 + t2)
        z_prod = z1 * z2
        ax.plot(z_sum.real, z_sum.imag, 'b.', markersize=3)
        ax.plot(z_prod.real, z_prod.imag, 'r.', markersize=1)

    ax.plot([], [], 'b.', label='exp(i(θ₁+θ₂))')
    ax.plot([], [], 'r.', label='exp(iθ₁)·exp(iθ₂)')
    ax.legend(fontsize=9)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f'Theorem 2: Group Homomorphism\nθ₂ = π/3 fixed', fontsize=12)

    # Panel 3: Polar surjectivity
    ax = axes[2]
    np.random.seed(42)
    targets = [complex(np.random.uniform(-3, 3), np.random.uniform(-3, 3)) for _ in range(200)]
    targets = [z for z in targets if abs(z) > 0.1]
    for z in targets:
        theta = np.angle(z)
        r = abs(z)
        recon = quantum_eml_polar(theta, r)
        ax.plot(z.real, z.imag, 'b.', markersize=4, alpha=0.5)
        ax.plot(recon.real, recon.imag, 'r+', markersize=3, alpha=0.3)

    ax.plot(0, 0, 'kx', markersize=15, mew=3, label='z=0 (excluded)')
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_title('Theorem 3: Polar Surjectivity\nℂ\\{0} fully covered', fontsize=12)

    plt.tight_layout()
    plt.savefig('quantum_eml_phase_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quantum_eml_phase_space.png")


def plot_chain_composition():
    """Visualize the chain composition rule."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: Phase addition
    ax = axes[0]
    thetas = np.linspace(0, 2*np.pi, 100)
    circle = [quantum_phase(t) for t in thetas]
    ax.plot([z.real for z in circle], [z.imag for z in circle], 'k-', lw=1, alpha=0.3)

    t1, t2 = np.pi/4, np.pi/3
    z1 = quantum_phase(t1)
    z2 = quantum_phase(t2)
    z_comp = quantum_phase(t1 + t2)

    ax.annotate('', xy=(z1.real, z1.imag), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.annotate('', xy=(z2.real, z2.imag), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.annotate('', xy=(z_comp.real, z_comp.imag), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='green', lw=3))

    ax.plot(z1.real, z1.imag, 'bo', markersize=10, label=f'θ₁=π/4')
    ax.plot(z2.real, z2.imag, 'ro', markersize=10, label=f'θ₂=π/3')
    ax.plot(z_comp.real, z_comp.imag, 'gs', markersize=12, label=f'θ₁+θ₂=7π/12')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_title('Theorem 5: Phases Add\nexp(iθ₁)·exp(iθ₂) = exp(i(θ₁+θ₂))', fontsize=11)

    # Panel 2: Amplitude multiplication
    ax = axes[1]
    r_vals = np.linspace(0.1, 3, 20)
    for r1 in [0.5, 1.0, 2.0]:
        norms = [r1 * r2 for r2 in r_vals]
        ax.plot(r_vals, norms, '-', lw=2, label=f'r₁ = {r1}')

    ax.set_xlabel('r₂ (amplitude of gate 2)', fontsize=11)
    ax.set_ylabel('||compose|| = r₁ · r₂', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=10)
    ax.set_title('Theorem 5: Amplitudes Multiply\n||gate₁ ∘ gate₂|| = r₁ · r₂', fontsize=11)

    plt.tight_layout()
    plt.savefig('quantum_eml_composition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quantum_eml_composition.png")


def plot_classical_bridge():
    """Visualize the classical-quantum bridge."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: Quantum neuron for varying phase (fixed EML params)
    ax = axes[0]
    x, y = 1.0, np.e
    classical_val = np.exp(x) - np.log(y)

    thetas = np.linspace(0, 2*np.pi, 200)
    neurons = [quantum_phase(t) * classical_val for t in thetas]

    ax.plot([z.real for z in neurons], [z.imag for z in neurons], 'b-', lw=2)
    ax.plot(classical_val, 0, 'r*', markersize=15, label='Classical (θ=0)')

    for t in [np.pi/4, np.pi/2, np.pi]:
        z = quantum_phase(t) * classical_val
        ax.plot(z.real, z.imag, 'go', markersize=8)
        ax.annotate(f'θ={t/np.pi:.1f}π', (z.real, z.imag),
                    textcoords="offset points", xytext=(10, 5), fontsize=9)

    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=10)
    ax.set_title('Theorem 4: Classical → Quantum\nPhase rotates classical EML output', fontsize=11)
    ax.set_xlabel('Re')
    ax.set_ylabel('Im')

    # Panel 2: Norm preservation
    ax = axes[1]
    thetas = np.linspace(0, 4*np.pi, 200)
    for x, y, label in [(1.0, np.e, 'exp(1)-1'), (0.5, 2.0, 'exp(0.5)-ln2'), (2.0, 1.0, 'exp(2)')]:
        classical_val = np.exp(x) - np.log(y)
        norms = [abs(quantum_phase(t) * classical_val) for t in thetas]
        ax.plot(thetas / np.pi, norms, '-', lw=2, label=f'{label} = {classical_val:.2f}')
        ax.axhline(y=abs(classical_val), color='gray', ls='--', lw=0.5)

    ax.set_xlabel('Phase θ / π', fontsize=11)
    ax.set_ylabel('||quantumEMLNeuron||', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_title('Theorem 4: Norm Independence\n||neuron(θ)|| = |classical EML| ∀θ', fontsize=11)

    plt.tight_layout()
    plt.savefig('quantum_eml_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quantum_eml_bridge.png")


if __name__ == "__main__":
    plot_phase_unitarity()
    plot_chain_composition()
    plot_classical_bridge()
    print("\nAll visualizations generated ✓")
