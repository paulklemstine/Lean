#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Algorithms

Type-hinted implementations of the core quantum EML algorithms.
"""

from typing import Tuple, List, Optional
import numpy as np


def eml(x: float, y: float) -> float:
    """Classical EML activation function.
    
    Args:
        x: First parameter (exponential input)
        y: Second parameter (logarithmic input, must be > 0)
    
    Returns:
        exp(x) - log(y)
    """
    return float(np.exp(x) - np.log(y))


def quantum_eml_phase(x: float, y: float) -> complex:
    """Quantum EML phase map.
    
    Maps classical parameters to a point on the unit circle S¹ ⊂ ℂ.
    
    Args:
        x: First EML parameter
        y: Second EML parameter (must be > 0)
    
    Returns:
        exp(i · eml(x, y)), a complex number with |z| = 1
    """
    return complex(np.exp(1j * eml(x, y)))


def quantum_eml_full(r: float, x: float, y: float) -> complex:
    """Full quantum EML with amplitude control.
    
    Args:
        r: Amplitude (should be > 0 for non-degenerate output)
        x: First EML parameter
        y: Second EML parameter (must be > 0)
    
    Returns:
        r · exp(i · eml(x, y))
    """
    return r * np.exp(1j * eml(x, y))


def compile_u1_gate(alpha: float) -> Tuple[float, float]:
    """Compile a U(1) rotation gate as quantum EML parameters.
    
    Given target angle α, returns (x, y) such that
    quantumEMLPhase(x, y) = exp(iα).
    
    The compilation formula is: x = 0, y = exp(1 - α).
    
    Args:
        alpha: Target rotation angle in radians
    
    Returns:
        Tuple (x, y) of quantum EML parameters
    """
    return (0.0, float(np.exp(1 - alpha)))


def compile_inverse_gate(x: float, y: float) -> Tuple[float, float]:
    """Find quantum EML parameters for the inverse gate.
    
    Given a gate with parameters (x, y), returns (x', y') such that
    quantumEMLPhase(x, y) · quantumEMLPhase(x', y') = 1.
    
    Args:
        x: First parameter of gate to invert
        y: Second parameter of gate to invert (must be > 0)
    
    Returns:
        Tuple (x', y') for the inverse gate
    """
    phase = eml(x, y)
    return compile_u1_gate(-phase)


def quantum_eml_gap(x: float, y: float) -> float:
    """Compute quantum EML gate error relative to identity.
    
    Returns |exp(i·eml(x,y)) - 1|², which satisfies
    the bound: gap ≤ eml(x,y)².
    
    Args:
        x: First EML parameter
        y: Second EML parameter
    
    Returns:
        Squared distance from identity gate
    """
    return float(2 - 2 * np.cos(eml(x, y)))


def quantum_eml_fidelity(x: float, y: float, alpha: float) -> float:
    """Compute quantum EML fidelity with target phase.
    
    Returns cos(eml(x,y) - α), the overlap between the quantum EML
    gate and the target rotation exp(iα).
    
    Args:
        x: First EML parameter
        y: Second EML parameter
        alpha: Target angle
    
    Returns:
        Fidelity value in [-1, 1], with 1 = perfect match
    """
    return float(np.cos(eml(x, y) - alpha))


def compose_quantum_eml_gates(
    gates: List[Tuple[float, float]]
) -> complex:
    """Compose a sequence of quantum EML gates.
    
    Uses the composition law: the product of phases equals
    exp(i · sum of EML values).
    
    Args:
        gates: List of (x, y) parameter pairs
    
    Returns:
        Product of all quantum EML phases
    """
    total_eml = sum(eml(x, y) for x, y in gates)
    return complex(np.exp(1j * total_eml))


def optimize_quantum_eml_circuit(
    target_alpha: float,
    current_gates: List[Tuple[float, float]]
) -> Tuple[float, float]:
    """Add a correction gate to achieve target phase.
    
    Given a current circuit (sequence of quantum EML gates) and a
    target phase, computes the parameters for one additional gate
    that achieves the target exactly.
    
    Args:
        target_alpha: Desired total rotation angle
        current_gates: Existing gate parameters
    
    Returns:
        Parameters (x, y) for the correction gate
    """
    current_phase = sum(eml(x, y) for x, y in current_gates)
    correction = target_alpha - current_phase
    return compile_u1_gate(correction)


def quantum_eml_error_bound(x: float, y: float) -> float:
    """Upper bound on quantum gate error from the gap bound theorem.
    
    Returns eml(x,y)², which is proven to be ≥ quantumEMLGap(x,y).
    
    Args:
        x: First EML parameter
        y: Second EML parameter
    
    Returns:
        Upper bound on gate error
    """
    return eml(x, y) ** 2


def quantum_eml_bloch_coordinates(
    x: float, y: float
) -> Tuple[float, float, float]:
    """Map quantum EML gate to Bloch sphere equator coordinates.
    
    Returns (cos(eml), sin(eml), 0), a point on the unit sphere
    equator corresponding to the quantum EML phase.
    
    Args:
        x: First EML parameter
        y: Second EML parameter
    
    Returns:
        Tuple (bx, by, bz) on the Bloch sphere equator
    """
    theta = eml(x, y)
    return (float(np.cos(theta)), float(np.sin(theta)), 0.0)


if __name__ == "__main__":
    # Quick self-test
    print("Quantum EML Algorithms — Self Test")
    
    # Test compilation
    for alpha in [0, np.pi/4, np.pi/2, np.pi]:
        x, y = compile_u1_gate(alpha)
        z = quantum_eml_phase(x, y)
        expected = np.exp(1j * alpha)
        assert abs(z - expected) < 1e-10, f"Compilation failed for α={alpha}"
    print("✓ Gate compilation correct")
    
    # Test composition
    gates = [(0, 1), (1, 2), (0.5, 0.5)]
    composed = compose_quantum_eml_gates(gates)
    manual = np.prod([quantum_eml_phase(x, y) for x, y in gates])
    assert abs(composed - manual) < 1e-10
    print("✓ Gate composition correct")
    
    # Test gap bound
    for x, y in [(0, 1), (1, 1), (0, 0.5), (2, 3)]:
        gap = quantum_eml_gap(x, y)
        bound = quantum_eml_error_bound(x, y)
        assert gap <= bound + 1e-10, f"Gap bound violated at ({x},{y})"
    print("✓ Gap bound verified")
    
    # Test inversion
    for x, y in [(0, 1), (1, 2), (0.5, 0.3)]:
        xi, yi = compile_inverse_gate(x, y)
        product = quantum_eml_phase(x, y) * quantum_eml_phase(xi, yi)
        assert abs(product - 1) < 1e-10
    print("✓ Gate inversion correct")
    
    print("\nAll tests passed!")
