#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Algorithm Implementations

Type-hinted implementations of the quantum EML neuron and related algorithms.
"""

import numpy as np
from typing import Tuple, Optional


def qeml(theta: float, r: float) -> complex:
    """
    Quantum EML activation function.
    
    Computes exp(iθ) · log(1 + ri), the scalar quantum analog of the
    classical EML activation eml(x,y) = exp(x) - log(y).
    
    Args:
        theta: Phase parameter (radians)
        r: Amplitude parameter
    
    Returns:
        Complex activation value
    """
    return np.exp(1j * theta) * np.log(1 + r * 1j)


def ceml(z1: complex, z2: complex) -> complex:
    """
    Complex EML function.
    
    Computes exp(z1) - log(z2), the complex extension of
    eml(x,y) = exp(x) - log(y).
    
    Args:
        z1: First complex input
        z2: Second complex input (must be nonzero for log)
    
    Returns:
        Complex EML value
    """
    return np.exp(z1) - np.log(z2)


def qeml_norm(r: float) -> float:
    """
    Quantum EML norm function.
    
    Computes ‖log(1 + ri)‖ = √((½log(1+r²))² + (arctan r)²).
    This is the radial component of the quantum EML, independent of phase.
    
    Args:
        r: Amplitude parameter
    
    Returns:
        Non-negative norm value
    """
    return float(abs(np.log(1 + r * 1j)))


def qeml_components(r: float) -> Tuple[float, float]:
    """
    Decompose log(1 + ri) into real and imaginary parts.
    
    Returns (log√(1+r²), arctan(r)), the amplitude and phase
    accumulation of the quantum EML at zero phase.
    
    Args:
        r: Amplitude parameter
    
    Returns:
        Tuple of (real_part, imaginary_part)
    """
    return (0.5 * np.log(1 + r**2), float(np.arctan(r)))


def qeml_inverse(
    w: complex,
    tol: float = 1e-12,
    max_iter: int = 100
) -> Tuple[float, float]:
    """
    Inverse quantum EML: find (θ, r) such that qeml(θ, r) = w.
    
    Uses binary search on the norm function (guaranteed to converge
    by the Intermediate Value Theorem, as proven in Lean) followed
    by phase matching.
    
    Args:
        w: Target complex number
        tol: Convergence tolerance
        max_iter: Maximum iterations for binary search
    
    Returns:
        Tuple (theta, r) such that qeml(theta, r) ≈ w
    """
    if abs(w) < tol:
        return (0.0, 0.0)
    
    target_norm = abs(w)
    
    # Binary search for r: find r such that qeml_norm(r) = target_norm
    lo, hi = 0.0, 1.0
    while qeml_norm(hi) < target_norm:
        hi *= 2
    
    for _ in range(max_iter):
        mid = (lo + hi) / 2
        if qeml_norm(mid) < target_norm:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    
    r = (lo + hi) / 2
    L = np.log(1 + r * 1j)
    theta = float(np.angle(w / L))
    
    return (theta, r)


def qeml_layer(
    x: np.ndarray,
    weights: np.ndarray,
    biases: np.ndarray,
    thetas: np.ndarray
) -> np.ndarray:
    """
    Forward pass of a quantum EML neural network layer.
    
    Computes Σ_j w_j · qeml(θ_j, r_j · x + b_j) for each input x.
    
    Args:
        x: Input array of shape (batch_size,)
        weights: Complex weights of shape (n_neurons,)
        biases: Real biases of shape (n_neurons,)
        thetas: Phase parameters of shape (n_neurons,)
    
    Returns:
        Complex output array of shape (batch_size,)
    """
    # Compute r_j * x + b_j for all neurons and inputs
    r_vals = np.outer(x, np.ones(len(biases))) + biases[np.newaxis, :]
    
    # Compute qeml for each neuron
    activations = np.exp(1j * thetas[np.newaxis, :]) * np.log(1 + r_vals * 1j)
    
    # Weighted sum
    return activations @ weights


def quantum_classical_bridge_check(
    x: float, y: float
) -> Tuple[float, float, float]:
    """
    Verify the classical bridge theorem numerically.
    
    Returns (ceml_real_part, classical_eml, absolute_error).
    
    Args:
        x: Real input for exp
        y: Positive real input for log
    
    Returns:
        Tuple of (complex_result, classical_result, error)
    """
    complex_result = ceml(complex(x), complex(y)).real
    classical_result = np.exp(x) - np.log(y)
    error = abs(complex_result - classical_result)
    return (complex_result, classical_result, error)


def norm_bound_verification(
    theta: float, r: float
) -> Tuple[float, float, bool]:
    """
    Verify the norm lower bound |arctan(r)| ≤ ‖qeml(θ,r)‖.
    
    Returns (arctan_bound, qeml_norm_value, bound_satisfied).
    
    Args:
        theta: Phase parameter
        r: Amplitude parameter
    
    Returns:
        Tuple of (lower_bound, actual_norm, is_satisfied)
    """
    bound = abs(np.arctan(r))
    norm = abs(qeml(theta, r))
    return (bound, norm, bound <= norm + 1e-15)
