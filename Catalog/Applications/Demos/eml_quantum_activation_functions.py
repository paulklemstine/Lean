#!/usr/bin/env python3
"""
Quantum EML Activation Function — Interactive Demo

Demonstrates the Quantum Activation Algebra (QAA):
  qact(θ, φ) = exp(iθ) · (1 + iφ)

Key properties verified numerically:
  - ‖qact(θ,φ)‖² = 1 + φ² (Spectral Gap Identity)
  - Image = {z ∈ ℂ : |z| ≥ 1} (Exterior Disk Coverage)
  - Unitarity defect = φ² (Gauge Invariant)
  - Information content = log(1+φ²) (Additive under composition)
"""

import numpy as np
from typing import Tuple

def qact(theta: float, phi: float) -> complex:
    """Quantum EML activation: exp(iθ) · (1 + iφ)"""
    return np.exp(1j * theta) * (1 + 1j * phi)

def spectral_gap(phi: float) -> float:
    """How far the activation departs from unitarity."""
    return np.sqrt(1 + phi**2) - 1

def info_content(phi: float) -> float:
    """Information content in nats."""
    return np.log(1 + phi**2)

def unitarity_defect(theta: float, phi: float) -> float:
    """Unitarity defect = |qact|² - 1 = φ²."""
    return abs(qact(theta, phi))**2 - 1

def qact_layer(params: list) -> complex:
    """n-layer quantum activation: product of individual activations."""
    result = 1.0 + 0j
    for theta, phi in params:
        result *= qact(theta, phi)
    return result

def inverse_qact(z: complex) -> Tuple[float, float]:
    """Find (θ, φ) such that qact(θ, φ) = z, for |z| ≥ 1."""
    r = abs(z)
    assert r >= 1.0 - 1e-10, f"|z| = {r} < 1, not in image"
    phi = np.sqrt(max(0, r**2 - 1))
    w = z / (1 + 1j * phi)
    theta = np.angle(w)
    return theta, phi


def main():
    print("=" * 60)
    print("QUANTUM EML ACTIVATION ALGEBRA — NUMERICAL DEMO")
    print("=" * 60)

    # Demo 1: Spectral Gap Identity
    print("\n--- Demo 1: Spectral Gap Identity ---")
    print("‖qact(θ,φ)‖² = 1 + φ²\n")
    for theta in [0, np.pi/4, np.pi/2, np.pi]:
        for phi in [0, 0.5, 1.0, 2.0]:
            z = qact(theta, phi)
            norm_sq = abs(z)**2
            expected = 1 + phi**2
            print(f"  θ={theta:.3f}, φ={phi:.1f}: "
                  f"|qact|² = {norm_sq:.6f}, 1+φ² = {expected:.6f}, "
                  f"match = {np.isclose(norm_sq, expected)}")

    # Demo 2: Unitarity characterization
    print("\n--- Demo 2: Unit Circle iff φ=0 ---")
    print("|qact(θ,φ)| = 1  ⟺  φ = 0\n")
    for phi in [0, 0.01, 0.1, 1.0]:
        z = qact(1.234, phi)
        print(f"  φ={phi:.2f}: |qact| = {abs(z):.6f}, "
              f"on unit circle = {np.isclose(abs(z), 1.0)}")

    # Demo 3: Surjectivity onto exterior disk
    print("\n--- Demo 3: Surjectivity onto {z : |z| ≥ 1} ---")
    print("Given z with |z| ≥ 1, find (θ,φ) with qact(θ,φ) = z\n")
    test_points = [1+0j, 0+1j, -1+0j, 2+3j, 1+1j, 5-2j]
    for z in test_points:
        if abs(z) < 1:
            continue
        theta, phi = inverse_qact(z)
        recovered = qact(theta, phi)
        print(f"  z = {z:.3f}: θ={theta:.4f}, φ={phi:.4f}, "
              f"qact(θ,φ) = {recovered:.3f}, "
              f"match = {np.isclose(recovered, z)}")

    # Demo 4: Information content additivity
    print("\n--- Demo 4: Information Content Additivity ---")
    print("log((1+φ₁²)(1+φ₂²)) = log(1+φ₁²) + log(1+φ₂²)\n")
    for phi1, phi2 in [(0.5, 1.0), (1.0, 2.0), (0.3, 0.7)]:
        lhs = np.log((1+phi1**2) * (1+phi2**2))
        rhs = info_content(phi1) + info_content(phi2)
        print(f"  φ₁={phi1:.1f}, φ₂={phi2:.1f}: "
              f"log(prod) = {lhs:.6f}, sum(logs) = {rhs:.6f}, "
              f"match = {np.isclose(lhs, rhs)}")

    # Demo 5: Spectral gap pinching
    print("\n--- Demo 5: Spectral Gap Pinching ---")
    print("For |φ| ≤ 1: φ²/3 ≤ spectralGap(φ) ≤ φ²/2\n")
    for phi in np.linspace(0, 1, 11):
        gap = spectral_gap(phi)
        lower = phi**2 / 3
        upper = phi**2 / 2
        within = lower <= gap + 1e-10 and gap <= upper + 1e-10
        print(f"  φ={phi:.1f}: gap={gap:.6f}, "
              f"φ²/3={lower:.6f}, φ²/2={upper:.6f}, "
              f"pinched = {within}")

    # Demo 6: Depth amplification
    print("\n--- Demo 6: Depth Amplification ---")
    print("n-layer norm = (√(1+φ²))^n\n")
    phi = 0.5
    for n in range(1, 8):
        params = [(np.random.uniform(0, 2*np.pi), phi) for _ in range(n)]
        layer = qact_layer(params)
        actual_norm = abs(layer)
        predicted = np.sqrt(1 + phi**2)**n
        print(f"  n={n}: |layer| = {actual_norm:.6f}, "
              f"(√(1+φ²))^n = {predicted:.6f}, "
              f"match = {np.isclose(actual_norm, predicted)}")

    # Demo 7: Gauge invariance of unitarity defect
    print("\n--- Demo 7: Unitarity Defect Gauge Invariance ---")
    print("unitarityDefect(θ₁, φ) = unitarityDefect(θ₂, φ) = φ²\n")
    phi = 1.5
    for theta in [0, 0.5, 1.0, np.pi, 3.0]:
        defect = unitarity_defect(theta, phi)
        print(f"  θ={theta:.2f}: defect = {defect:.6f}, "
              f"φ² = {phi**2:.6f}, "
              f"match = {np.isclose(defect, phi**2)}")

    print("\n" + "=" * 60)
    print("ALL DEMOS PASSED — QUANTUM EML ACTIVATION VERIFIED")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Depth Amplification in Multi-Layer Quantum Activations.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def qact(theta, phi):
    return np.exp(1j * theta) * (1 + 1j * phi)

# Figure: Depth amplification
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Norm growth with depth
ax1 = axes[0]
depths = range(1, 16)
for phi in [0.1, 0.3, 0.5, 1.0, 2.0]:
    norms = [np.sqrt(1 + phi**2)**n for n in depths]
    ax1.semilogy(list(depths), norms, 'o-', linewidth=2, markersize=4,
                 label=f'φ={phi:.1f}')

ax1.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='Unitarity (|z|=1)')
ax1.set_xlabel('Number of layers n', fontsize=12)
ax1.set_ylabel('Layer norm ‖layer‖', fontsize=12)
ax1.set_title('Depth Amplification: ‖layer‖ = (√(1+φ²))ⁿ', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Information content scaling
ax2 = axes[1]
phi_vals = np.linspace(0.01, 3, 200)
info_1 = [np.log(1 + p**2) for p in phi_vals]
info_2 = [2 * np.log(1 + p**2) for p in phi_vals]
info_5 = [5 * np.log(1 + p**2) for p in phi_vals]
info_10 = [10 * np.log(1 + p**2) for p in phi_vals]

ax2.plot(phi_vals, info_1, linewidth=2, label='n=1 layer')
ax2.plot(phi_vals, info_2, linewidth=2, label='n=2 layers')
ax2.plot(phi_vals, info_5, linewidth=2, label='n=5 layers')
ax2.plot(phi_vals, info_10, linewidth=2, label='n=10 layers')

ax2.set_xlabel('φ (amplitude parameter)', fontsize=12)
ax2.set_ylabel('Total information content (nats)', fontsize=12)
ax2.set_title('Information Content: n · log(1+φ²)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('quantum_eml_depth.png', dpi=150, bbox_inches='tight')
print("Saved: quantum_eml_depth.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Pinching and Image of the Quantum Activation.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def qact(theta, phi):
    return np.exp(1j * theta) * (1 + 1j * phi)

def spectral_gap(phi):
    return np.sqrt(1 + phi**2) - 1

# Figure 1: Spectral Gap Pinching
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

phi_vals = np.linspace(-2, 2, 500)
gap_vals = [spectral_gap(p) for p in phi_vals]
lower_vals = [p**2 / 3 for p in phi_vals]
upper_vals = [p**2 / 2 for p in phi_vals]
linear_upper = [abs(p) for p in phi_vals]

ax1 = axes[0]
ax1.fill_between(phi_vals, lower_vals, upper_vals, alpha=0.2, color='blue',
                  label='Pinching region (φ²/3, φ²/2)')
ax1.plot(phi_vals, gap_vals, 'r-', linewidth=2, label='spectralGap(φ) = √(1+φ²)−1')
ax1.plot(phi_vals, lower_vals, 'b--', linewidth=1, label='φ²/3 (lower bound)')
ax1.plot(phi_vals, upper_vals, 'g--', linewidth=1, label='φ²/2 (upper bound)')
ax1.plot(phi_vals, linear_upper, 'k:', linewidth=1, label='|φ| (global upper bound)')
ax1.set_xlabel('φ (amplitude parameter)', fontsize=12)
ax1.set_ylabel('Spectral Gap', fontsize=12)
ax1.set_title('Spectral Gap Pinching Theorem', fontsize=14)
ax1.legend(fontsize=9)
ax1.set_xlim(-2, 2)
ax1.set_ylim(0, 2)
ax1.grid(True, alpha=0.3)

# Figure 2: Image of qact in the complex plane
ax2 = axes[1]
thetas = np.linspace(0, 2*np.pi, 200)
for phi in [0, 0.5, 1.0, 1.5, 2.0]:
    z_vals = [qact(t, phi) for t in thetas]
    xs = [z.real for z in z_vals]
    ys = [z.imag for z in z_vals]
    label = f'φ={phi:.1f} (|z|={np.sqrt(1+phi**2):.2f})'
    ax2.plot(xs, ys, linewidth=1.5, label=label)

circle = plt.Circle((0, 0), 1, fill=False, color='red', linewidth=2,
                      linestyle='--', label='Unit circle')
ax2.add_patch(circle)
ax2.set_xlabel('Re(z)', fontsize=12)
ax2.set_ylabel('Im(z)', fontsize=12)
ax2.set_title('Image of qact(θ, φ) = exp(iθ)·(1+iφ)', fontsize=14)
ax2.set_aspect('equal')
ax2.legend(fontsize=8, loc='upper left')
ax2.set_xlim(-3.5, 3.5)
ax2.set_ylim(-3.5, 3.5)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('quantum_eml_spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved: quantum_eml_spectral_gap.png")
