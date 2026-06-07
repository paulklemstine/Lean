#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Demonstration Script

Demonstrates the phase neuron, unitarity locus, strip theorem,
spectral EML, and quantum-classical bridge.
"""

import numpy as np

def phase_neuron(theta: float, phi: float) -> complex:
    """The phase neuron: exp(iθ) - iφ"""
    return np.exp(1j * theta) - 1j * phi

def phase_neuron_norm_sq(theta: float, phi: float) -> float:
    """Norm-squared: 1 - 2φ sin(θ) + φ²"""
    return 1 - 2 * phi * np.sin(theta) + phi**2

def defect(theta: float, phi: float) -> float:
    """Defect: φ² - 2φ sin(θ)"""
    return phi**2 - 2 * phi * np.sin(theta)

def spectral_eml(l1: float, l2: float) -> float:
    """Spectral EML: exp(l₁) - log(l₂)"""
    return np.exp(l1) - np.log(l2)

def synthesize_gate(z: complex) -> tuple[float, float]:
    """Given z with |Re(z)| ≤ 1, find (θ, φ) such that phaseNeuron(θ, φ) = z."""
    theta = np.arccos(np.clip(z.real, -1, 1))
    phi = np.sin(theta) - z.imag
    return theta, phi

# === Demo 1: Phase Neuron Basics ===
print("=" * 60)
print("DEMO 1: Phase Neuron Basics")
print("=" * 60)

test_cases = [(0, 0), (np.pi/4, 0), (np.pi/2, 1), (np.pi, 0.5)]
for theta, phi in test_cases:
    z = phase_neuron(theta, phi)
    ns = phase_neuron_norm_sq(theta, phi)
    ns_check = abs(z)**2
    print(f"  θ={theta:.4f}, φ={phi:.4f} → z={z:.4f}, |z|²={ns:.4f} (check: {ns_check:.4f})")

# === Demo 2: Unitarity Locus ===
print("\n" + "=" * 60)
print("DEMO 2: Unitarity Locus")
print("=" * 60)

print("  Trivial branch (φ=0):")
for theta in [0, np.pi/6, np.pi/4, np.pi/3, np.pi/2]:
    z = phase_neuron(theta, 0)
    print(f"    θ={theta:.4f} → |z|² = {abs(z)**2:.10f} (should be 1.0)")

print("  Sinusoidal branch (φ=2sin(θ)):")
for theta in [0, np.pi/6, np.pi/4, np.pi/3, np.pi/2]:
    phi = 2 * np.sin(theta)
    z = phase_neuron(theta, phi)
    z_expected = np.exp(-1j * theta)
    print(f"    θ={theta:.4f} → z={z:.4f}, exp(-iθ)={z_expected:.4f}, |z|²={abs(z)**2:.10f}")

# === Demo 3: Time Reversal ===
print("\n" + "=" * 60)
print("DEMO 3: Sinusoidal Branch = Time Reversal")
print("=" * 60)

for theta in np.linspace(0, 2*np.pi, 9):
    phi = 2 * np.sin(theta)
    z = phase_neuron(theta, phi)
    z_rev = np.exp(-1j * theta)
    err = abs(z - z_rev)
    print(f"  θ={theta:.4f}: phaseNeuron = {z:.4f}, exp(-iθ) = {z_rev:.4f}, error = {err:.2e}")

# === Demo 4: Strip Theorem ===
print("\n" + "=" * 60)
print("DEMO 4: Image = Strip {z : |Re(z)| ≤ 1}")
print("=" * 60)

targets = [0.5 + 2j, -0.7 - 3j, 0 + 0j, 1 + 100j, -1 - 50j]
for z_target in targets:
    theta, phi = synthesize_gate(z_target)
    z_actual = phase_neuron(theta, phi)
    err = abs(z_actual - z_target)
    print(f"  Target: {z_target}, Synthesized: {z_actual:.6f}, Error: {err:.2e}")

print("\n  Targets outside strip (|Re| > 1) cannot be reached:")
for z_target in [1.5 + 0j, -2 + 1j]:
    print(f"    {z_target}: Re = {z_target.real}, |Re| = {abs(z_target.real):.1f} > 1 ✗")

# === Demo 5: Reality Curve ===
print("\n" + "=" * 60)
print("DEMO 5: Reality Curve (φ = sin θ → real output)")
print("=" * 60)

for theta in np.linspace(0, np.pi, 7):
    phi = np.sin(theta)
    z = phase_neuron(theta, phi)
    print(f"  θ={theta:.4f}: output = {z:.6f}, Im = {z.imag:.2e} (should be ≈0)")

# === Demo 6: Spectral EML Gap Amplification ===
print("\n" + "=" * 60)
print("DEMO 6: Spectral EML Gap Amplification")
print("=" * 60)

print("  For l ≥ 1, f(l) = exp(l) - log(l) is strictly increasing:")
for l in [1.0, 1.5, 2.0, 3.0, 5.0, 10.0]:
    print(f"    f({l:.1f}) = {spectral_eml(l, l):.4f}")

print("\n  Below l=1, NON-monotone (f has minimum near l≈0.567):")
for l in [0.1, 0.3, 0.5, 0.567, 0.7, 1.0]:
    print(f"    f({l:.3f}) = {spectral_eml(l, l):.4f}")

# === Demo 7: Defect Landscape ===
print("\n" + "=" * 60)
print("DEMO 7: Defect Landscape")
print("=" * 60)

print("  Defect δ = φ² - 2φ sin(θ):")
for theta in [0, np.pi/6, np.pi/4, np.pi/2]:
    for phi in [0, 0.5, 1.0, 2*np.sin(theta)]:
        d = defect(theta, phi)
        print(f"    θ={theta:.4f}, φ={phi:.4f}: δ={d:.4f}", end="")
        if abs(d) < 1e-10:
            print(" ← UNITARY", end="")
        print()

# === Demo 8: Quantum-Classical Bridge ===
print("\n" + "=" * 60)
print("DEMO 8: Quantum-Classical Bridge (φ=0 → phase gates)")
print("=" * 60)

for theta in np.linspace(0, 2*np.pi, 9):
    z = phase_neuron(theta, 0)
    z_gate = np.exp(1j * theta)
    print(f"  θ={theta:.4f}: phaseNeuron = {z:.4f}, exp(iθ) = {z_gate:.4f}, match = {abs(z-z_gate) < 1e-14}")

print("\n✅ All demos complete.")


#!/usr/bin/env python3
"""
Visualization: Spectral EML Phase Transition

Shows the diagonal spectral EML f(l) = exp(l) - log(l) and its derivative,
highlighting the critical point l* ≈ 0.567 (Lambert W(1)) where the function
transitions from decreasing to increasing.
"""

import numpy as np
import matplotlib.pyplot as plt

def main():
    l = np.linspace(0.01, 3, 1000)
    f = np.exp(l) - np.log(l)
    f_prime = np.exp(l) - 1.0/l

    # Critical point: exp(l*) = 1/l* => l* * exp(l*) = 1 => l* = W(1)
    # Numerical approximation
    from scipy.optimize import brentq
    l_star = brentq(lambda x: np.exp(x) - 1.0/x, 0.01, 2.0)
    f_star = np.exp(l_star) - np.log(l_star)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 10))

    # Top: f(l) = exp(l) - log(l)
    ax1.plot(l, f, 'b-', linewidth=2)
    ax1.axvline(x=l_star, color='red', linestyle='--', alpha=0.7, label=f'Critical point l*≈{l_star:.4f}')
    ax1.axvline(x=1.0, color='green', linestyle='--', alpha=0.7, label='l=1 (monotone threshold)')
    ax1.plot(l_star, f_star, 'ro', markersize=10, zorder=5)
    ax1.annotate(f'Minimum: ({l_star:.3f}, {f_star:.3f})',
                 xy=(l_star, f_star), xytext=(l_star+0.5, f_star+1),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=12, color='red')
    ax1.set_xlabel('l (eigenvalue)', fontsize=14)
    ax1.set_ylabel('f(l) = exp(l) − log(l)', fontsize=14)
    ax1.set_title('Diagonal Spectral EML Transform', fontsize=16)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 15)
    ax1.grid(True, alpha=0.3)

    # Region annotations
    ax1.fill_betweenx([0, 15], 0, l_star, alpha=0.1, color='red', label='Decreasing')
    ax1.fill_betweenx([0, 15], l_star, 3, alpha=0.1, color='blue', label='Increasing')

    # Bottom: f'(l) = exp(l) - 1/l
    ax2.plot(l, f_prime, 'b-', linewidth=2)
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.axvline(x=l_star, color='red', linestyle='--', alpha=0.7)
    ax2.plot(l_star, 0, 'ro', markersize=10, zorder=5)
    ax2.fill_between(l, f_prime, 0, where=(f_prime < 0), alpha=0.2, color='red')
    ax2.fill_between(l, f_prime, 0, where=(f_prime > 0), alpha=0.2, color='blue')
    ax2.set_xlabel('l (eigenvalue)', fontsize=14)
    ax2.set_ylabel("f'(l) = exp(l) − 1/l", fontsize=14)
    ax2.set_title('Derivative of Spectral EML (sign determines monotonicity)', fontsize=16)
    ax2.set_ylim(-10, 15)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_eml_phase_transition.png', dpi=150)
    plt.show()

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Unitarity Locus of the Quantum EML Phase Neuron

Shows the two branches of the unitarity locus in (θ, φ) parameter space:
- Trivial branch: φ = 0 (pure quantum phase gates)
- Sinusoidal branch: φ = 2 sin(θ) (time-reversed gates)

The background colormap shows the defect δ(θ, φ) = φ² − 2φ sin(θ).
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm

def main():
    theta = np.linspace(0, 2 * np.pi, 500)
    phi = np.linspace(-3, 3, 500)
    Theta, Phi = np.meshgrid(theta, phi)
    Defect = Phi**2 - 2 * Phi * np.sin(Theta)

    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    norm = TwoSlopeNorm(vmin=-1, vcenter=0, vmax=5)
    im = ax.pcolormesh(Theta, Phi, Defect, cmap='RdBu_r', norm=norm, shading='auto')
    plt.colorbar(im, ax=ax, label='Defect δ(θ, φ) = φ² − 2φ sin(θ)')

    ax.plot(theta, np.zeros_like(theta), 'k-', linewidth=2.5, label='Trivial branch (φ=0)')
    ax.plot(theta, 2 * np.sin(theta), 'lime', linewidth=2.5, label='Sinusoidal branch (φ=2sinθ)')
    ax.plot(theta, np.sin(theta), 'yellow', linewidth=1.5, linestyle='--', label='Reality curve (φ=sinθ)')

    ax.set_xlabel('θ (phase angle)', fontsize=14)
    ax.set_ylabel('φ (imaginary displacement)', fontsize=14)
    ax.set_title('Unitarity Locus of the Quantum EML Phase Neuron', fontsize=16)
    ax.legend(loc='upper right', fontsize=11)
    ax.set_xlim(0, 2*np.pi)
    ax.set_ylim(-3, 3)

    ax.annotate('Sub-unitary\n(dissipative)', xy=(np.pi/2, 0.5), fontsize=10,
                ha='center', color='white', fontweight='bold')
    ax.annotate('Super-unitary\n(amplifying)', xy=(np.pi/2, 2.5), fontsize=10,
                ha='center', color='darkblue', fontweight='bold')

    plt.tight_layout()
    plt.savefig('unitarity_locus.png', dpi=150)
    plt.show()

if __name__ == "__main__":
    main()
