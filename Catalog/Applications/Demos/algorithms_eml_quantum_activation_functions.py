#!/usr/bin/env python3
"""
Quantum Phase-EML Neuron — Algorithms

Type-hinted implementations of the quantum EML operations
and their inverse (target synthesis) algorithms.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class QuantumEMLOutput:
    """Result of a quantum EML neuron evaluation."""
    value: complex
    amplitude: float
    phase: float
    norm_sq: float
    is_unitary: bool
    unitarity_defect: float


def eml(x: float, y: float) -> float:
    """Classical EML activation function.
    
    eml(x, y) = exp(x) - ln(y)
    
    Args:
        x: First parameter (exponential input)
        y: Second parameter (logarithmic input), must be positive
        
    Returns:
        The EML value exp(x) - ln(y)
    """
    if y <= 0:
        raise ValueError(f"y must be positive, got {y}")
    return float(np.exp(x) - np.log(y))


def eml_diag(z: float) -> float:
    """Diagonal EML: eml(z, z) = exp(z) - ln(z).
    
    Satisfies the bound eml_diag(z) >= 2 for z > 0.
    
    Args:
        z: Parameter (must be positive)
    """
    if z <= 0:
        raise ValueError(f"z must be positive, got {z}")
    return float(np.exp(z) - np.log(z))


def quantum_phase_eml(theta: float, x: float, y: float) -> QuantumEMLOutput:
    """Quantum phase-EML neuron.
    
    q(θ, x, y) = exp(iθ) · (exp(x) - ln(y))
    
    Properties (proven in Lean 4):
    - Bridge: q(0, x, y) = eml(x, y)
    - Norm: |q|² = eml(x,y)²
    - Surjective onto ℂ
    - Periodic: q(θ+2π) = q(θ)
    - Phase derivative: ∂q/∂θ = i·q
    
    Args:
        theta: Phase parameter (radians)
        x: Amplitude parameter (exponential input)
        y: Amplitude parameter (logarithmic input), must be positive
    """
    if y <= 0:
        raise ValueError(f"y must be positive, got {y}")
    
    classical_value = eml(x, y)
    phase_factor = np.exp(1j * theta)
    value = complex(phase_factor * classical_value)
    norm_sq = classical_value ** 2
    
    return QuantumEMLOutput(
        value=value,
        amplitude=abs(classical_value),
        phase=theta % (2 * np.pi),
        norm_sq=norm_sq,
        is_unitary=np.isclose(norm_sq, 1.0),
        unitarity_defect=norm_sq - 1.0
    )


def inverse_quantum_eml(w: complex) -> Tuple[float, float, float]:
    """Inverse quantum EML: find parameters producing target output.
    
    Given w ∈ ℂ, find θ, x, y > 0 such that q(θ, x, y) = w.
    Uses the constructive proof from the surjectivity theorem.
    
    Args:
        w: Target complex number
        
    Returns:
        Tuple (θ, x, y) with y > 0 such that quantum_phase_eml(θ, x, y).value ≈ w
    """
    if w == 0:
        return 0.0, 0.0, np.e  # eml(0, e) = 1 - 1 = 0
    
    r = abs(w)
    theta = float(np.angle(w))
    # Set eml(x, y) = r by choosing x = 0, y = exp(1 - r)
    x = 0.0
    y = float(np.exp(1 - r))
    return theta, x, y


def quantum_interference(
    theta1: float, theta2: float, x: float, y: float
) -> float:
    """Compute the interference intensity of two quantum EML neurons.
    
    |q(θ₁, x, y) + q(θ₂, x, y)|² = 2·eml(x,y)²·(1 + cos(θ₁ - θ₂))
    
    Args:
        theta1, theta2: Phase parameters of the two neurons
        x, y: Shared amplitude parameters
        
    Returns:
        The interference intensity (non-negative)
    """
    e = eml(x, y)
    return float(2 * e**2 * (1 + np.cos(theta1 - theta2)))


def multi_neuron_interference(
    thetas: List[float], x: float, y: float
) -> float:
    """Compute the interference intensity of n quantum EML neurons.
    
    |Σ q(θ_k, x, y)|² = eml(x,y)² · |Σ exp(iθ_k)|²
    
    Args:
        thetas: List of phase parameters
        x, y: Shared amplitude parameters
        
    Returns:
        Total interference intensity
    """
    e = eml(x, y)
    phase_sum = sum(np.exp(1j * theta) for theta in thetas)
    return float(e**2 * abs(phase_sum)**2)


def unitarity_surface(
    x_range: Tuple[float, float] = (-2, 3),
    n_points: int = 1000
) -> List[Tuple[float, float]]:
    """Find (x, y) pairs where the quantum EML output is unitary.
    
    The quantum EML is unitary iff eml(x, y) = ±1,
    i.e., exp(x) - ln(y) = ±1, i.e., y = exp(exp(x) ∓ 1).
    
    Returns:
        List of (x, y) pairs on the unitarity surface
    """
    xs = np.linspace(x_range[0], x_range[1], n_points)
    points = []
    for x in xs:
        # eml(x, y) = 1 → y = exp(exp(x) - 1)
        y1 = np.exp(np.exp(x) - 1)
        points.append((float(x), float(y1)))
        # eml(x, y) = -1 → y = exp(exp(x) + 1)
        y2 = np.exp(np.exp(x) + 1)
        points.append((float(x), float(y2)))
    return points


def quantum_eml_phase_evolution(
    x: float, y: float,
    theta_start: float = 0,
    theta_end: float = 2 * np.pi,
    n_steps: int = 100
) -> List[complex]:
    """Trace the path of the quantum EML as θ evolves.
    
    Since ∂q/∂θ = i·q (Schrödinger dynamics), the evolution traces
    a circle of radius |eml(x,y)| in the complex plane.
    
    Args:
        x, y: Amplitude parameters
        theta_start, theta_end: Phase range
        n_steps: Number of evaluation points
        
    Returns:
        List of complex values along the evolution path
    """
    thetas = np.linspace(theta_start, theta_end, n_steps)
    return [complex(quantum_phase_eml(t, x, y).value) for t in thetas]


if __name__ == "__main__":
    # Quick self-test
    print("Testing inverse_quantum_eml...")
    for w in [1+2j, -3+0j, 0+0j, 5-5j]:
        t, x, y = inverse_quantum_eml(w)
        result = quantum_phase_eml(t, x, y)
        assert np.isclose(result.value, w, atol=1e-10), f"Failed for w={w}: got {result.value}"
    print("  All inverse tests passed!")
    
    print("Testing interference formula...")
    for t1, t2 in [(0, 0), (0, np.pi), (np.pi/4, np.pi/2)]:
        x, y = 1.0, 2.0
        q1 = quantum_phase_eml(t1, x, y).value
        q2 = quantum_phase_eml(t2, x, y).value
        actual = abs(q1 + q2)**2
        predicted = quantum_interference(t1, t2, x, y)
        assert np.isclose(actual, predicted), f"Interference mismatch at ({t1}, {t2})"
    print("  All interference tests passed!")
    
    print("Testing diagonal gap...")
    for z in [0.01, 0.1, 1.0, 10.0]:
        for theta in [0, 1.0, np.pi]:
            result = quantum_phase_eml(theta, z, z)
            assert result.norm_sq >= 4 - 1e-10, f"Diagonal gap violated at z={z}, θ={theta}"
    print("  All diagonal gap tests passed!")
    
    print("\nAll tests passed!")
