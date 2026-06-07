#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Core Algorithms

Type-hinted implementations of the mathematical constructions
formalized in Applications/QuantumEMLCore.lean.
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional


@dataclass
class QuantumEMLGate:
    """A quantum EML gate parameterized by (θ, φ) ∈ ℝ²."""
    theta: float  # Phase angle
    phi: float    # Imaginary displacement

    def output(self) -> complex:
        """Compute the phase neuron output: exp(iθ) − iφ."""
        return np.exp(1j * self.theta) - 1j * self.phi

    def norm_sq(self) -> float:
        """Norm-squared via closed-form: 1 − 2φ sin(θ) + φ²."""
        return 1.0 - 2.0 * self.phi * np.sin(self.theta) + self.phi**2

    def defect(self) -> float:
        """Unitarity defect: φ² − 2φ sin(θ). Zero iff unitary."""
        return self.phi**2 - 2.0 * self.phi * np.sin(self.theta)

    def is_unitary(self, tol: float = 1e-12) -> bool:
        """Check if gate is approximately unitary."""
        return abs(self.defect()) < tol

    def project_to_unitary(self) -> 'QuantumEMLGate':
        """Project to nearest unitary gate (in parameter space).

        Two branches: φ=0 (trivial) and φ=2sin(θ) (sinusoidal).
        Returns whichever is closer in |φ − target|.
        """
        phi_trivial = 0.0
        phi_sinusoidal = 2.0 * np.sin(self.theta)
        if abs(self.phi - phi_trivial) <= abs(self.phi - phi_sinusoidal):
            return QuantumEMLGate(self.theta, phi_trivial)
        else:
            return QuantumEMLGate(self.theta, phi_sinusoidal)

    def branch(self) -> str:
        """Classify which regime the gate is in."""
        phi_sin = np.sin(self.theta)
        phi_2sin = 2.0 * np.sin(self.theta)
        tol = 1e-10
        if abs(self.phi) < tol:
            return "quantum_phase"
        elif abs(self.phi - phi_sin) < tol:
            return "classical_real"
        elif abs(self.phi - phi_2sin) < tol:
            return "time_reversal"
        elif self.defect() < -tol:
            return "sub_unitary"
        elif self.defect() > tol:
            return "super_unitary"
        else:
            return "unitary_boundary"

    @staticmethod
    def identity() -> 'QuantumEMLGate':
        """The identity gate (θ=0, φ=0), output = 1."""
        return QuantumEMLGate(0.0, 0.0)

    @staticmethod
    def from_target(z: complex) -> Optional['QuantumEMLGate']:
        """Synthesize a gate whose output equals z.

        Only possible if |Re(z)| ≤ 1 (strip theorem).
        Returns None if target is outside the strip.
        """
        if abs(z.real) > 1.0 + 1e-12:
            return None
        theta = np.arccos(np.clip(z.real, -1.0, 1.0))
        phi = np.sin(theta) - z.imag
        return QuantumEMLGate(theta, phi)


def ceml(z: complex, w: complex) -> complex:
    """Complex EML: exp(z) − log(w)."""
    return np.exp(z) - np.log(w)


def spectral_eml(l1: float, l2: float) -> float:
    """Spectral EML transform: exp(l₁) − log(l₂)."""
    return np.exp(l1) - np.log(l2)


def spectral_eml_diagonal(l: float) -> float:
    """Diagonal spectral EML: exp(l) − log(l).
    Strictly increasing for l ≥ 1, minimum near l ≈ 0.567.
    """
    return np.exp(l) - np.log(l)


def unitarity_locus_sample(n_points: int = 1000) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Sample the unitarity locus.

    Returns (theta_trivial, phi_trivial, theta_sin, phi_sin)
    for the two branches.
    """
    theta = np.linspace(0, 2 * np.pi, n_points)
    phi_trivial = np.zeros_like(theta)
    phi_sinusoidal = 2.0 * np.sin(theta)
    return theta, phi_trivial, theta, phi_sinusoidal


def defect_landscape(theta_range: tuple[float, float] = (0, 2*np.pi),
                     phi_range: tuple[float, float] = (-3, 3),
                     resolution: int = 200) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the defect δ(θ, φ) = φ² − 2φ sin θ on a grid.

    Returns (Theta, Phi, Defect) meshgrid arrays.
    """
    theta = np.linspace(*theta_range, resolution)
    phi = np.linspace(*phi_range, resolution)
    Theta, Phi = np.meshgrid(theta, phi)
    Defect = Phi**2 - 2 * Phi * np.sin(Theta)
    return Theta, Phi, Defect


def compose_gates(gates: list[QuantumEMLGate]) -> complex:
    """Compose gates by multiplying their outputs."""
    result = 1.0 + 0j
    for g in gates:
        result *= g.output()
    return result


def approximate_target(z_target: complex, n_gates: int = 10,
                       lr: float = 0.01, iterations: int = 1000) -> list[QuantumEMLGate]:
    """Gradient descent to find gates whose product approximates z_target.

    Uses simple SGD on the parameters (θ₁, φ₁, ..., θₙ, φₙ).
    """
    # Random initialization
    thetas = np.random.uniform(0, 2*np.pi, n_gates)
    phis = np.random.uniform(-1, 1, n_gates)

    for _ in range(iterations):
        # Forward pass
        outputs = [np.exp(1j * t) - 1j * p for t, p in zip(thetas, phis)]
        product = np.prod(outputs)
        error = product - z_target

        # Numerical gradient
        for i in range(n_gates):
            # dL/dθᵢ
            dt = 1e-7
            thetas[i] += dt
            out_plus = np.prod([np.exp(1j*t) - 1j*p for t, p in zip(thetas, phis)])
            thetas[i] -= dt
            grad_theta = (abs(out_plus - z_target)**2 - abs(error)**2) / dt

            # dL/dφᵢ
            phis[i] += dt
            out_plus = np.prod([np.exp(1j*t) - 1j*p for t, p in zip(thetas, phis)])
            phis[i] -= dt
            grad_phi = (abs(out_plus - z_target)**2 - abs(error)**2) / dt

            thetas[i] -= lr * grad_theta
            phis[i] -= lr * grad_phi

    return [QuantumEMLGate(t, p) for t, p in zip(thetas, phis)]


if __name__ == "__main__":
    # Quick test
    g = QuantumEMLGate.identity()
    print(f"Identity gate: output={g.output()}, defect={g.defect()}")

    g2 = QuantumEMLGate(np.pi/4, 0)
    print(f"Phase gate π/4: output={g2.output():.4f}, unitary={g2.is_unitary()}")

    g3 = QuantumEMLGate(np.pi/4, 2*np.sin(np.pi/4))
    print(f"Sinusoidal branch π/4: output={g3.output():.4f}, unitary={g3.is_unitary()}")
    print(f"  Expected exp(-iπ/4) = {np.exp(-1j*np.pi/4):.4f}")

    z_target = 0.5 + 0.3j
    g_synth = QuantumEMLGate.from_target(z_target)
    if g_synth:
        print(f"Synthesized gate for {z_target}: θ={g_synth.theta:.4f}, φ={g_synth.phi:.4f}")
        print(f"  Output: {g_synth.output():.6f}")
