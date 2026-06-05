#!/usr/bin/env python3
"""
Quantum Phase-EML Neuron — Demonstration Script

Demonstrates the key theorems proved in the Lean 4 formalization:
1. Classical-quantum bridge (θ=0 recovery)
2. Phase-amplitude decoupling
3. Surjectivity onto ℂ
4. Quantum diagonal gap
5. Unitarity characterization
6. Quantum interference
"""

import numpy as np
from typing import Tuple


def eml(x: float, y: float) -> float:
    """Classical EML function: eml(x, y) = exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)


def eml_diag(z: float) -> float:
    """Diagonal EML: eml(z, z) = exp(z) - ln(z)"""
    return np.exp(z) - np.log(z)


def quantum_phase_eml(theta: float, x: float, y: float) -> complex:
    """Quantum phase-EML: q(θ, x, y) = exp(iθ) · eml(x, y)"""
    return np.exp(1j * theta) * eml(x, y)


def complex_eml(z: complex, w: complex) -> complex:
    """Full complex EML: cEML(z, w) = exp(z) - Log(w)"""
    return np.exp(z) - np.log(w)


def inverse_quantum_eml(w: complex) -> Tuple[float, float, float]:
    """Find θ, x, y such that quantum_phase_eml(θ, x, y) = w.
    Uses the constructive proof from the surjectivity theorem."""
    if w == 0:
        return 0.0, 0.0, np.e
    r = abs(w)
    theta = np.angle(w)
    # Set x = 0, y = exp(1 - r), so eml(0, exp(1-r)) = 1 - (1-r) = r
    x = 0.0
    y = np.exp(1 - r)
    return theta, x, y


def main():
    print("=" * 60)
    print("QUANTUM PHASE-EML NEURON — DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Classical-Quantum Bridge
    print("\n--- Demo 1: Classical-Quantum Bridge (Theorem 1) ---")
    print("At θ=0, quantum EML reduces to classical EML:")
    for x, y in [(0, 1), (1, 1), (0, np.e), (1, np.e)]:
        q = quantum_phase_eml(0, x, y)
        c = eml(x, y)
        print(f"  q(0, {x:.1f}, {y:.3f}) = {q:.6f}  |  eml({x:.1f}, {y:.3f}) = {c:.6f}  |  match: {np.isclose(q, c)}")

    # Demo 2: Phase-Amplitude Decoupling
    print("\n--- Demo 2: Phase-Amplitude Decoupling (Theorem 2) ---")
    print("|q(θ, x, y)|² = eml(x, y)² regardless of θ:")
    x, y = 1.0, 2.0
    c_sq = eml(x, y) ** 2
    for theta in [0, np.pi/4, np.pi/2, np.pi, 3*np.pi/2]:
        norm_sq = abs(quantum_phase_eml(theta, x, y)) ** 2
        print(f"  θ = {theta:.4f}:  |q|² = {norm_sq:.6f}  |  eml² = {c_sq:.6f}  |  match: {np.isclose(norm_sq, c_sq)}")

    # Demo 3: Surjectivity
    print("\n--- Demo 3: Surjectivity (Theorem 3) ---")
    print("Synthesizing parameters for target complex numbers:")
    targets = [3 + 4j, -2 + 0j, 0 + 1j, 0 + 0j, -1 - 1j]
    for w in targets:
        theta, x, y = inverse_quantum_eml(w)
        result = quantum_phase_eml(theta, x, y)
        print(f"  target = {w:>10}  →  q({theta:.3f}, {x:.3f}, {y:.6f}) = {result.real:.3f}{result.imag:+.3f}i  |  match: {np.isclose(result, w)}")

    # Demo 4: Quantum Diagonal Gap
    print("\n--- Demo 4: Quantum Diagonal Gap (Theorem 4) ---")
    print("For z > 0: |q(θ, z, z)|² ≥ 4")
    for z in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        for theta in [0, np.pi/3]:
            norm_sq = abs(quantum_phase_eml(theta, z, z)) ** 2
            print(f"  z = {z:6.2f}, θ = {theta:.3f}:  |q|² = {norm_sq:10.4f}  ≥ 4: {norm_sq >= 4 - 1e-10}")

    # Demo 5: Unitarity Characterization
    print("\n--- Demo 5: Unitarity Characterization (Theorem 5) ---")
    print("q is unitary iff eml = ±1")
    # eml(x, y) = 1: exp(x) - log(y) = 1 → x=0, y=1 gives eml=1
    print("  eml(0, 1) =", eml(0, 1), "→ |q|² =", abs(quantum_phase_eml(np.pi/4, 0, 1))**2)
    # eml(x, y) = -1: exp(x) - log(y) = -1 → x=0, y=exp(2) gives eml=1-2=-1
    print("  eml(0, e²) =", eml(0, np.e**2), "→ |q|² =", abs(quantum_phase_eml(np.pi/4, 0, np.e**2))**2)
    # Non-unitary example
    print("  eml(1, 1) =", eml(1, 1), "→ |q|² =", abs(quantum_phase_eml(np.pi/4, 1, 1))**2, "(not unitary)")

    # Demo 6: Quantum Interference
    print("\n--- Demo 6: Quantum Interference (Theorem 7) ---")
    x, y = 1.0, 1.0
    e = eml(x, y)
    print(f"  eml({x}, {y}) = {e:.4f}")
    for delta_theta in [0, np.pi/4, np.pi/2, np.pi]:
        theta1, theta2 = 0, delta_theta
        q1 = quantum_phase_eml(theta1, x, y)
        q2 = quantum_phase_eml(theta2, x, y)
        actual = abs(q1 + q2) ** 2
        predicted = 2 * e**2 * (1 + np.cos(theta1 - theta2))
        print(f"  Δθ = {delta_theta:.4f}:  |q₁+q₂|² = {actual:.6f}  |  formula = {predicted:.6f}  |  match: {np.isclose(actual, predicted)}")

    # Demo 7: Phase Derivative (Schrödinger structure)
    print("\n--- Demo 7: Phase Derivative (Theorem 9) ---")
    theta, x, y = 1.0, 0.5, 2.0
    h = 1e-7
    numerical_deriv = (quantum_phase_eml(theta + h, x, y) - quantum_phase_eml(theta - h, x, y)) / (2 * h)
    analytical_deriv = 1j * quantum_phase_eml(theta, x, y)
    print(f"  Numerical  ∂q/∂θ = {numerical_deriv:.6f}")
    print(f"  Analytical i·q   = {analytical_deriv:.6f}")
    print(f"  Match: {np.isclose(numerical_deriv, analytical_deriv, atol=1e-5)}")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum EML Interference Pattern

Shows how the interference intensity varies with phase difference,
demonstrating constructive and destructive interference.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml(x: float, y: float) -> float:
    return float(np.exp(x) - np.log(y))


def quantum_interference_intensity(delta_theta: float, x: float, y: float) -> float:
    e = eml(x, y)
    return 2 * e**2 * (1 + np.cos(delta_theta))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Interference vs phase difference
    delta = np.linspace(0, 4 * np.pi, 500)
    for x, y, label in [(0, 1, 'eml=1'), (1, 1, f'eml=e≈{np.e:.2f}'), (0, 0.1, f'eml≈{eml(0,0.1):.2f}')]:
        intensity = [quantum_interference_intensity(d, x, y) for d in delta]
        axes[0].plot(delta / np.pi, intensity, label=label, linewidth=2)
    axes[0].set_xlabel('Phase difference Δθ/π')
    axes[0].set_ylabel('Interference intensity |q₁+q₂|²')
    axes[0].set_title('Quantum EML Interference Pattern')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    axes[0].axhline(y=0, color='k', linewidth=0.5)

    # Panel 2: Two quantum EML outputs in the complex plane
    theta_vals = np.linspace(0, 2*np.pi, 100)
    x, y = 0.5, 1.0
    e = eml(x, y)
    for theta_fixed in [0, np.pi/3, 2*np.pi/3, np.pi]:
        q_vals = [np.exp(1j*t) * e + np.exp(1j*theta_fixed) * e for t in theta_vals]
        axes[1].plot([q.real for q in q_vals], [q.imag for q in q_vals],
                     label=f'θ₂={theta_fixed/np.pi:.1f}π', linewidth=1.5)
    
    # Show unit circle for reference
    circle = np.exp(1j * theta_vals)
    axes[1].plot(circle.real, circle.imag, 'k--', alpha=0.3, label='Unit circle')
    axes[1].set_xlabel('Re')
    axes[1].set_ylabel('Im')
    axes[1].set_title('Superposition loci in ℂ')
    axes[1].legend(fontsize=8)
    axes[1].set_aspect('equal')
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Diagonal gap visualization
    z_vals = np.linspace(0.01, 5, 500)
    diag_vals = [np.exp(z) - np.log(z) for z in z_vals]
    diag_sq = [d**2 for d in diag_vals]
    axes[2].plot(z_vals, diag_sq, 'b-', linewidth=2, label='|q(θ,z,z)|² = (eᶻ−ln z)²')
    axes[2].axhline(y=4, color='r', linestyle='--', linewidth=1.5, label='Gap bound = 4')
    axes[2].fill_between(z_vals, 0, 4, alpha=0.15, color='red', label='Forbidden zone')
    axes[2].set_xlabel('z')
    axes[2].set_ylabel('|q(θ, z, z)|²')
    axes[2].set_title('Quantum Diagonal Gap (Theorem 4)')
    axes[2].legend()
    axes[2].set_ylim(0, 50)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_eml_interference.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_eml_interference.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum EML Phase Evolution

Shows the circular trajectory in ℂ as the phase parameter θ evolves,
and the Schrödinger structure ∂q/∂θ = i·q.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml(x: float, y: float) -> float:
    return float(np.exp(x) - np.log(y))


def quantum_phase_eml(theta: float, x: float, y: float) -> complex:
    return np.exp(1j * theta) * eml(x, y)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Phase evolution circles for different EML amplitudes
    theta = np.linspace(0, 2*np.pi, 200)
    params = [(0, 1, 'eml=1'), (1, 1, f'eml=e≈{np.e:.1f}'), (0, 0.5, f'eml≈{eml(0,0.5):.1f}'),
              (0, np.e**2, f'eml={eml(0, np.e**2):.1f}')]
    
    for x, y, label in params:
        q = [quantum_phase_eml(t, x, y) for t in theta]
        axes[0].plot([z.real for z in q], [z.imag for z in q], linewidth=2, label=label)
        # Mark θ=0 point
        q0 = quantum_phase_eml(0, x, y)
        axes[0].plot(q0.real, q0.imag, 'o', markersize=6)
    
    axes[0].set_xlabel('Re(q)')
    axes[0].set_ylabel('Im(q)')
    axes[0].set_title('Phase Evolution: q(θ,x,y) traces circles')
    axes[0].legend(fontsize=9)
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)
    axes[0].axhline(y=0, color='k', linewidth=0.5)
    axes[0].axvline(x=0, color='k', linewidth=0.5)

    # Panel 2: Schrödinger derivative verification
    x, y = 0.5, 1.5
    theta_vals = np.linspace(0, 2*np.pi, 200)
    q_vals = np.array([quantum_phase_eml(t, x, y) for t in theta_vals])
    
    # Numerical derivative
    dt = theta_vals[1] - theta_vals[0]
    dq_dt = np.gradient(q_vals, dt)
    iq_vals = 1j * q_vals
    
    axes[1].plot(theta_vals/np.pi, np.real(dq_dt), 'b-', linewidth=2, label='Re(∂q/∂θ) numerical')
    axes[1].plot(theta_vals/np.pi, np.real(iq_vals), 'b--', linewidth=1.5, label='Re(i·q) analytical')
    axes[1].plot(theta_vals/np.pi, np.imag(dq_dt), 'r-', linewidth=2, label='Im(∂q/∂θ) numerical')
    axes[1].plot(theta_vals/np.pi, np.imag(iq_vals), 'r--', linewidth=1.5, label='Im(i·q) analytical')
    axes[1].set_xlabel('θ/π')
    axes[1].set_ylabel('Value')
    axes[1].set_title('Schrödinger Structure: ∂q/∂θ = i·q')
    axes[1].legend(fontsize=8)
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Unitarity defect as function of EML parameters
    x_vals = np.linspace(-2, 3, 200)
    y_vals_list = [0.5, 1.0, 2.0, np.e]
    
    for y_val in y_vals_list:
        defects = [(np.exp(x) - np.log(y_val))**2 - 1 for x in x_vals]
        axes[2].plot(x_vals, defects, linewidth=2, label=f'y={y_val:.1f}')
    
    axes[2].axhline(y=0, color='k', linewidth=1.5, linestyle='--', label='Unitary (δ=0)')
    axes[2].set_xlabel('x')
    axes[2].set_ylabel('Unitarity defect δ = |q|² - 1')
    axes[2].set_title('Unitarity Defect: δ=0 iff eml=±1')
    axes[2].legend(fontsize=9)
    axes[2].set_ylim(-2, 20)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_eml_phase_evolution.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_eml_phase_evolution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum EML Surjectivity

Shows how the quantum phase-EML covers the entire complex plane
by varying (θ, x, y) parameters.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml(x: float, y: float) -> float:
    return float(np.exp(x) - np.log(y))


def quantum_phase_eml(theta: float, x: float, y: float) -> complex:
    return np.exp(1j * theta) * eml(x, y)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Coverage of ℂ by sampling random parameters
    np.random.seed(42)
    n = 5000
    thetas = np.random.uniform(0, 2*np.pi, n)
    xs = np.random.uniform(-2, 3, n)
    ys = np.exp(np.random.uniform(-3, 3, n))  # y > 0
    
    q_vals = [quantum_phase_eml(t, x, y) for t, x, y in zip(thetas, xs, ys)]
    axes[0].scatter([z.real for z in q_vals], [z.imag for z in q_vals],
                    s=1, alpha=0.3, c='blue')
    axes[0].set_xlabel('Re')
    axes[0].set_ylabel('Im')
    axes[0].set_title('Surjectivity: q covers ℂ (5000 samples)')
    axes[0].set_xlim(-15, 15)
    axes[0].set_ylim(-15, 15)
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)

    # Panel 2: EML range (classical surjectivity)
    x_vals = np.linspace(-3, 3, 200)
    y_vals = np.exp(np.linspace(-3, 3, 200))
    
    eml_vals = []
    for x in x_vals:
        for y in y_vals:
            eml_vals.append(eml(x, y))
    
    axes[1].hist(eml_vals, bins=100, density=True, alpha=0.7, color='steelblue')
    axes[1].set_xlabel('eml(x, y)')
    axes[1].set_ylabel('Density')
    axes[1].set_title('Classical EML range: all of ℝ')
    axes[1].axvline(x=0, color='r', linestyle='--', label='eml=0')
    axes[1].axvline(x=1, color='g', linestyle='--', label='eml=1 (unitary)')
    axes[1].axvline(x=-1, color='g', linestyle=':', label='eml=-1 (unitary)')
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Constructive inverse — given targets, show they are reached
    targets = []
    for r in np.linspace(0.5, 5, 8):
        for phi in np.linspace(0, 2*np.pi, 12, endpoint=False):
            targets.append(r * np.exp(1j * phi))
    targets.append(0 + 0j)
    
    hits = []
    for w in targets:
        if abs(w) < 1e-10:
            t, x, y = 0, 0, np.e
        else:
            r = abs(w)
            t = np.angle(w)
            x, y = 0, np.exp(1 - r)
        hits.append(quantum_phase_eml(t, x, y))
    
    axes[2].scatter([w.real for w in targets], [w.imag for w in targets],
                    s=50, c='red', marker='x', label='Targets', zorder=5)
    axes[2].scatter([h.real for h in hits], [h.imag for h in hits],
                    s=30, c='blue', marker='o', alpha=0.5, label='q(θ,x,y)', zorder=4)
    
    for t, h in zip(targets, hits):
        axes[2].plot([t.real, h.real], [t.imag, h.imag], 'g-', alpha=0.2)
    
    axes[2].set_xlabel('Re')
    axes[2].set_ylabel('Im')
    axes[2].set_title('Inverse synthesis: targets → parameters → outputs')
    axes[2].legend()
    axes[2].set_aspect('equal')
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_eml_surjectivity.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_eml_surjectivity.png")


if __name__ == "__main__":
    main()
