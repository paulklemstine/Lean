#!/usr/bin/env python3
"""
Quantum EML Neurons: Core Algorithms

Type-hinted implementations of the quantum EML neuron operations,
QPA algebra, and approximation algorithms.
"""

import numpy as np
from typing import Tuple, List, Optional


# ============================================================
# Core Quantum EML Functions
# ============================================================

def qeml(theta: float, t: float) -> complex:
    """
    Quantum EML neuron activation.
    
    Computes exp(iθ) · log(1 + it) where θ is the phase parameter
    and t is the coupling parameter.
    
    Args:
        theta: Phase rotation parameter (radians)
        t: Coupling strength parameter
    
    Returns:
        Complex activation value
    """
    return np.exp(1j * theta) * np.log(1 + 1j * t)


def qeml_amplitude(t: float) -> float:
    """
    Amplitude component of quantum EML: |log(1 + it)|.
    
    This is independent of the phase parameter θ (phase invariance theorem).
    """
    return float(abs(np.log(1 + 1j * t)))


def qeml_intrinsic_phase(t: float) -> float:
    """Intrinsic phase angle of the logarithmic component."""
    return float(np.angle(np.log(1 + 1j * t)))


# ============================================================
# QPA (Quantum Phase-Amplitude) Algebra
# ============================================================

class QPA:
    """
    Quantum Phase-Amplitude element.
    
    Represents a complex number in polar form (amplitude, phase) with
    amplitude ≥ 0. Forms a monoid under polar multiplication.
    """
    
    def __init__(self, amplitude: float, phase: float):
        assert amplitude >= 0, "Amplitude must be non-negative"
        self.amplitude = amplitude
        self.phase = phase
    
    def mul(self, other: 'QPA') -> 'QPA':
        """Polar multiplication: multiply amplitudes, add phases."""
        return QPA(self.amplitude * other.amplitude,
                   self.phase + other.phase)
    
    @staticmethod
    def one() -> 'QPA':
        """Multiplicative identity: (1, 0)."""
        return QPA(1.0, 0.0)
    
    @staticmethod
    def zero() -> 'QPA':
        """Zero element: (0, 0)."""
        return QPA(0.0, 0.0)
    
    def to_complex(self) -> complex:
        """Convert to complex number."""
        return self.amplitude * np.exp(1j * self.phase)
    
    @staticmethod
    def from_qeml(theta: float, t: float) -> 'QPA':
        """Create QPA from quantum EML parameters."""
        return QPA(qeml_amplitude(t), theta + qeml_intrinsic_phase(t))
    
    def __repr__(self) -> str:
        return f"QPA(r={self.amplitude:.6f}, φ={self.phase:.6f})"


# ============================================================
# Quantum EML Layer
# ============================================================

class QuantumEMLLayer:
    """
    A layer of quantum EML neurons evaluated in parallel.
    
    Each neuron i computes: weights[i] * qeml(phases[i], couplings[i] * input)
    The layer output is the sum of all neuron outputs.
    """
    
    def __init__(self, phases: np.ndarray, couplings: np.ndarray,
                 weights: np.ndarray):
        assert len(phases) == len(couplings) == len(weights)
        self.phases = phases
        self.couplings = couplings
        self.weights = weights
        self.width = len(phases)
    
    def eval(self, input_val: float = 1.0) -> complex:
        """Evaluate the layer at a given input."""
        return sum(self.weights[i] * qeml(self.phases[i],
                                           self.couplings[i] * input_val)
                   for i in range(self.width))
    
    def norm_bound(self) -> float:
        """Upper bound on output norm (triangle inequality)."""
        return sum(abs(self.weights[i]) * qeml_amplitude(self.couplings[i])
                   for i in range(self.width))


# ============================================================
# Inverse Quantum EML (Finding Parameters)
# ============================================================

def inverse_qeml(z: complex, tol: float = 1e-12) -> Tuple[float, float]:
    """
    Find (θ, t) such that qeml(θ, t) ≈ z.
    
    Uses the surjectivity theorem constructively:
    1. Binary search for t such that qeml_amplitude(t) = |z|
    2. Compute θ from the phase relationship
    
    Args:
        z: Target complex number
        tol: Tolerance for amplitude matching
    
    Returns:
        Tuple (theta, t) such that qeml(theta, t) ≈ z
    """
    if abs(z) < tol:
        return (0.0, 0.0)
    
    target_amp = abs(z)
    
    # Binary search for t
    t_lo, t_hi = 0.0, 1.0
    while qeml_amplitude(t_hi) < target_amp:
        t_hi *= 2
    
    for _ in range(200):
        t_mid = (t_lo + t_hi) / 2
        if qeml_amplitude(t_mid) < target_amp:
            t_lo = t_mid
        else:
            t_hi = t_mid
        if t_hi - t_lo < tol:
            break
    
    t0 = (t_lo + t_hi) / 2
    w = np.log(1 + 1j * t0)
    theta = float(np.angle(z / w))
    
    return (theta, t0)


# ============================================================
# Quantum EML Approximation Algorithm
# ============================================================

def approximate_function(f, n_neurons: int = 10,
                         sample_points: int = 100) -> QuantumEMLLayer:
    """
    Approximate a complex function on the unit disk using quantum EML neurons.
    
    Uses a greedy residual-matching approach:
    1. Sample the target function at points on the unit disk
    2. Iteratively add neurons to minimize the maximum residual
    
    Args:
        f: Target function ℂ → ℂ (evaluated at real inputs for simplicity)
        n_neurons: Number of neurons to use
        sample_points: Number of sample points
    
    Returns:
        QuantumEMLLayer approximating f
    """
    xs = np.linspace(-2, 2, sample_points)
    targets = np.array([f(x) for x in xs])
    residuals = targets.copy()
    
    phases = np.zeros(n_neurons)
    couplings = np.zeros(n_neurons)
    weights = np.zeros(n_neurons, dtype=complex)
    
    for k in range(n_neurons):
        # Find the point with largest residual
        idx = np.argmax(np.abs(residuals))
        z_target = residuals[idx]
        
        if abs(z_target) < 1e-15:
            break
        
        # Find qeml parameters matching this residual
        theta, t = inverse_qeml(z_target)
        phases[k] = theta
        couplings[k] = t / max(abs(xs[idx]), 0.01)
        
        # Compute weight via least-squares projection
        neuron_vals = np.array([qeml(theta, couplings[k] * x) for x in xs])
        if np.dot(neuron_vals.conj(), neuron_vals).real > 1e-30:
            weights[k] = np.dot(neuron_vals.conj(), residuals) / \
                         np.dot(neuron_vals.conj(), neuron_vals)
        else:
            weights[k] = 1.0
        
        residuals -= weights[k] * neuron_vals
    
    return QuantumEMLLayer(phases, couplings, weights)


# ============================================================
# Interference Analysis
# ============================================================

def analyze_interference(t1: float, t2: float,
                         n_points: int = 360) -> dict:
    """
    Analyze constructive/destructive interference patterns.
    
    For two neurons with couplings t1 and t2, varies the relative phase
    and computes the resulting interference pattern.
    
    Returns dict with phase angles and corresponding norms.
    """
    theta_base = 0.0
    deltas = np.linspace(0, 2 * np.pi, n_points)
    norms = np.array([abs(qeml(theta_base, t1) + qeml(theta_base + d, t2))
                      for d in deltas])
    
    return {
        'phase_deltas': deltas,
        'norms': norms,
        'max_norm': float(np.max(norms)),
        'min_norm': float(np.min(norms)),
        'constructive_phase': float(deltas[np.argmax(norms)]),
        'destructive_phase': float(deltas[np.argmin(norms)]),
        'amplitude_sum': qeml_amplitude(t1) + qeml_amplitude(t2),
        'amplitude_diff': abs(qeml_amplitude(t1) - qeml_amplitude(t2)),
    }


if __name__ == "__main__":
    # Quick validation
    print("Quantum EML Algorithms - Validation")
    print("=" * 40)
    
    # Test inverse
    z = 2 + 3j
    theta, t = inverse_qeml(z)
    z_recovered = qeml(theta, t)
    print(f"Inverse test: target={z}, recovered={z_recovered:.6f}, "
          f"error={abs(z - z_recovered):.2e}")
    
    # Test interference
    result = analyze_interference(1.0, 1.0)
    print(f"\nInterference (t₁=1, t₂=1):")
    print(f"  Max norm: {result['max_norm']:.6f} "
          f"(bound: {result['amplitude_sum']:.6f})")
    print(f"  Min norm: {result['min_norm']:.6f} "
          f"(bound: {result['amplitude_diff']:.6f})")
    
    # Test approximation
    f = lambda x: complex(np.sin(x), np.cos(x))
    layer = approximate_function(f, n_neurons=5)
    xs_test = np.linspace(-1, 1, 20)
    max_err = max(abs(layer.eval(x) - f(x)) for x in xs_test)
    print(f"\nApproximation test (5 neurons): max error = {max_err:.6f}")
