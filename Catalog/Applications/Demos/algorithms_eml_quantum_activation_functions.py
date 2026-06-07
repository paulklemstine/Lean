#!/usr/bin/env python3
"""
Quantum EML Activation Algebra — Core Algorithms

Type-hinted implementations of the Quantum Activation Algebra (QAA).
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class QActivation:
    """A quantum activation parameterized by phase θ and amplitude φ."""
    phase: float
    amplitude: float

    def eval(self) -> complex:
        """Evaluate to a complex number: exp(iθ) · (1 + iφ)."""
        return np.exp(1j * self.phase) * (1 + 1j * self.amplitude)

    def norm(self) -> float:
        """Output norm: √(1 + φ²)."""
        return np.sqrt(1 + self.amplitude**2)

    def spectral_gap(self) -> float:
        """Departure from unitarity: √(1+φ²) - 1."""
        return self.norm() - 1

    def info_content(self) -> float:
        """Information content in nats: log(1+φ²)."""
        return np.log(1 + self.amplitude**2)

    def unitarity_defect(self) -> float:
        """Unitarity defect: φ²."""
        return self.amplitude**2

    def is_unitary(self, tol: float = 1e-10) -> bool:
        """Check if activation is unitary (φ = 0)."""
        return abs(self.amplitude) < tol


def compose(q1: QActivation, q2: QActivation) -> QActivation:
    """Compose two quantum activations by multiplying their evaluations.

    Algorithm:
        1. Compute product z = q1.eval() * q2.eval()
        2. Extract amplitude from |z|: amplitude = √(|z|² - 1)
        3. Extract phase from arg(z/(1+iφ))

    The composed amplitude satisfies (1+amplitude)² = (1+a₁²)(1+a₂²).
    """
    z = q1.eval() * q2.eval()
    r = abs(z)
    new_amplitude = np.sqrt(max(0, r**2 - 1))
    w = z / (1 + 1j * new_amplitude)
    new_phase = np.angle(w)
    return QActivation(phase=new_phase, amplitude=new_amplitude)


def layer_eval(activations: List[QActivation]) -> complex:
    """Evaluate a multi-layer quantum activation (product).

    Algorithm:
        result ← 1
        for each activation q in layer:
            result ← result × q.eval()
        return result

    Norm factorizes: |layer| = ∏ |q_i| = ∏ √(1+φ_i²)
    """
    result = 1.0 + 0j
    for q in activations:
        result *= q.eval()
    return result


def layer_norm(activations: List[QActivation]) -> float:
    """Compute multi-layer norm without evaluating (avoids overflow).

    Algorithm: |layer| = ∏ √(1+φ_i²) = exp(½ · Σ log(1+φ_i²))
    """
    log_norm = sum(0.5 * np.log(1 + q.amplitude**2) for q in activations)
    return np.exp(log_norm)


def inverse_qact(z: complex) -> Optional[QActivation]:
    """Find QActivation q such that q.eval() = z.

    Algorithm:
        1. Compute r = |z|
        2. If r < 1, return None (not in image)
        3. Set φ = √(r² - 1)
        4. Set θ = arg(z/(1+iφ))

    Returns None if |z| < 1 (not in image of qact).
    """
    r = abs(z)
    if r < 1 - 1e-10:
        return None
    phi = np.sqrt(max(0, r**2 - 1))
    w = z / (1 + 1j * phi)
    theta = np.angle(w)
    return QActivation(phase=theta, amplitude=phi)


def spectral_gap_bounds(phi: float) -> Tuple[float, float]:
    """Compute tight bounds on the spectral gap.

    For |φ| ≤ 1: φ²/3 ≤ spectralGap(φ) ≤ φ²/2
    For all φ:   0 ≤ spectralGap(φ) ≤ |φ|

    Returns (lower_bound, upper_bound).
    """
    gap = np.sqrt(1 + phi**2) - 1
    if abs(phi) <= 1:
        return (phi**2 / 3, phi**2 / 2)
    else:
        return (0, abs(phi))


def quantum_classical_bridge(x: float) -> dict:
    """Bridge between classical EML and quantum activation.

    Classical EML: eml(x, y) = exp(x) - log(y)
    Quantum bridge: qact(0, exp(x)-1) has:
      - Re = 1
      - Im = exp(x) - 1
      - |qact|² = 1 + (exp(x)-1)²

    Returns dict with classical and quantum quantities.
    """
    q = QActivation(phase=0, amplitude=np.exp(x) - 1)
    z = q.eval()
    return {
        'classical_exp': np.exp(x),
        'quantum_re': z.real,
        'quantum_im': z.imag,
        'quantum_norm_sq': abs(z)**2,
        'info_content': q.info_content(),
        'spectral_gap': q.spectral_gap(),
    }


def depth_amplification_rate(phi: float, n: int) -> float:
    """Compute the amplification rate for n layers with constant φ.

    Rate = (√(1+φ²))^n

    This grows exponentially when φ ≠ 0, analogous to
    exploding gradients in classical neural networks.
    """
    return np.sqrt(1 + phi**2)**n


if __name__ == "__main__":
    # Quick test
    q1 = QActivation(phase=np.pi/4, amplitude=1.0)
    q2 = QActivation(phase=np.pi/3, amplitude=0.5)

    print(f"q1 = exp(i·{q1.phase:.3f}) · (1 + i·{q1.amplitude:.1f})")
    print(f"q1.eval() = {q1.eval():.4f}")
    print(f"q1.norm() = {q1.norm():.4f}")
    print(f"q1.spectral_gap() = {q1.spectral_gap():.4f}")
    print(f"q1.info_content() = {q1.info_content():.4f}")
    print(f"q1.is_unitary() = {q1.is_unitary()}")
    print()

    q3 = compose(q1, q2)
    print(f"compose(q1, q2).norm() = {q3.norm():.4f}")
    print(f"Expected: {q1.norm() * q2.norm():.4f}")
    print()

    z = 2 + 3j
    q_inv = inverse_qact(z)
    if q_inv:
        print(f"inverse_qact({z}) = (θ={q_inv.phase:.4f}, φ={q_inv.amplitude:.4f})")
        print(f"Verification: qact(θ,φ) = {q_inv.eval():.4f}")
