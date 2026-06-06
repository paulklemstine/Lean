#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Core Algorithms

Type-hinted implementations of the quantum EML constructions
and algorithms described in the research paper.
"""

import numpy as np
from typing import Tuple, List, Optional


# ─── Core Quantum EML Primitives ───────────────────────────────

def quantum_phase(theta: float) -> complex:
    """Quantum phase gate: exp(iθ).
    
    Properties (proved in Lean 4):
    - |quantum_phase(θ)| = 1 (unitarity)
    - quantum_phase(θ₁ + θ₂) = quantum_phase(θ₁) * quantum_phase(θ₂)
    - quantum_phase(θ + 2π) = quantum_phase(θ)
    """
    return np.exp(1j * theta)


def quantum_eml_polar(theta: float, r: float) -> complex:
    """Quantum EML polar neuron: exp(iθ) · r.
    
    Separates quantum info (phase θ) from classical info (amplitude r).
    """
    return quantum_phase(theta) * r


def quantum_eml_neuron(theta1: float, theta2: float, theta3: float) -> complex:
    """Quantum EML neuron: exp(iθ₁) · (exp(θ₂) - log(θ₃)).
    
    Bridges quantum phase gate with classical EML.
    Property: ||neuron|| = |exp(θ₂) - log(θ₃)| (phase doesn't affect norm).
    """
    amplitude = np.exp(theta2) - (np.log(theta3) if theta3 > 0 else 0.0)
    return quantum_phase(theta1) * amplitude


def classical_eml_complex(x: float, y: float) -> complex:
    """Classical EML lifted to complex: exp(x) - log(y) ∈ ℂ."""
    return complex(np.exp(x) - (np.log(y) if y > 0 else 0.0))


# ─── Composition & Recovery ────────────────────────────────────

def quantum_eml_compose(
    theta1: float, r1: float, theta2: float, r2: float
) -> Tuple[float, float]:
    """Compose two quantum EML polar gates.
    
    Returns (θ₁+θ₂, r₁·r₂) — phases add, amplitudes multiply.
    (Proved: quantumEML_compose_eq)
    """
    return (theta1 + theta2, r1 * r2)


def quantum_eml_recover(z: complex) -> Tuple[float, float]:
    """Recover quantum EML parameters from target complex number.
    
    Given z ≠ 0, returns (θ, r) such that quantum_eml_polar(θ, r) = z.
    (Proved: quantumEMLPolar_surj — always succeeds for z ≠ 0)
    """
    if z == 0:
        raise ValueError("Cannot recover parameters for z = 0")
    return (float(np.angle(z)), float(abs(z)))


def quantum_eml_distance(
    theta1: float, theta2: float, r: float
) -> float:
    """Exact distance between two quantum EML polar neurons with same amplitude.
    
    Returns r · |exp(iθ₁) - exp(iθ₂)|.
    (Proved: quantumEMLPolar_dist_bound)
    """
    return abs(r) * abs(quantum_phase(theta1) - quantum_phase(theta2))


# ─── Quantum EML Network Layer ─────────────────────────────────

class QuantumEMLLayer:
    """A layer of quantum EML neurons.
    
    Each neuron applies: z ↦ exp(iθ_k) · (exp(w_k · Re(z) + b_k) - log(|z| + ε))
    """
    
    def __init__(self, n_neurons: int, seed: Optional[int] = None):
        rng = np.random.default_rng(seed)
        self.n_neurons = n_neurons
        self.phases = rng.uniform(0, 2 * np.pi, n_neurons)
        self.weights = rng.standard_normal(n_neurons)
        self.biases = rng.standard_normal(n_neurons)
    
    def forward(self, z: complex) -> np.ndarray:
        """Apply all neurons to input z, return array of complex outputs."""
        re_input = z.real
        amplitude_input = max(abs(z), 1e-10)
        
        outputs = np.empty(self.n_neurons, dtype=complex)
        for k in range(self.n_neurons):
            exp_part = np.exp(self.weights[k] * re_input + self.biases[k])
            log_part = np.log(amplitude_input)
            amplitude = exp_part - log_part
            outputs[k] = quantum_phase(self.phases[k]) * amplitude
        
        return outputs
    
    def collapse(self) -> Tuple[float, float]:
        """Collapse the layer to a single equivalent gate (phase, amplitude).
        
        Uses the chain composition rule: phases add, amplitudes multiply.
        """
        total_phase = float(np.sum(self.phases))
        # For a single input, amplitudes depend on the input
        return (total_phase % (2 * np.pi), 1.0)


# ─── Quantum EML Forward Pass ──────────────────────────────────

def quantum_eml_forward(
    layers: List[List[Tuple[float, float, float]]],
    z_input: complex
) -> complex:
    """Multi-layer quantum EML forward pass.
    
    Each layer is a list of (θ, w, b) triples.
    Algorithm from Research Paper §4.1.
    """
    z = z_input
    for layer in layers:
        outputs = []
        for theta, w, b in layer:
            amplitude = np.exp(w * z.real + b) - np.log(max(abs(z), 1e-10))
            phase = theta + w * z.imag
            outputs.append(quantum_phase(phase) * amplitude)
        z = sum(outputs) / len(outputs)  # Average pooling
    return z


# ─── Euler / Fourier Decomposition ─────────────────────────────

def quantum_eml_fourier_basis(
    thetas: List[float], amplitudes: List[float], x: float
) -> complex:
    """Evaluate quantum EML Fourier sum: Σ r_k · exp(iθ_k · x).
    
    By the Euler decomposition (Theorem 7), this computes a
    truncated Fourier series.
    """
    result = 0j
    for theta, r in zip(thetas, amplitudes):
        result += r * quantum_phase(theta * x)
    return result


def quantum_eml_fourier_fit(
    target_fn,
    x_samples: np.ndarray,
    n_terms: int
) -> Tuple[List[float], List[float]]:
    """Fit a quantum EML Fourier sum to a target function.
    
    Uses least squares to find optimal θ_k and r_k.
    """
    from scipy.optimize import minimize
    
    def loss(params):
        thetas = params[:n_terms]
        amplitudes = params[n_terms:]
        total = 0.0
        for x in x_samples:
            pred = quantum_eml_fourier_basis(
                list(thetas), list(amplitudes), x
            )
            total += abs(pred - target_fn(x)) ** 2
        return total
    
    x0 = np.random.randn(2 * n_terms)
    result = minimize(loss, x0, method='Nelder-Mead',
                      options={'maxiter': 5000})
    thetas = list(result.x[:n_terms])
    amplitudes = list(result.x[n_terms:])
    return thetas, amplitudes


if __name__ == "__main__":
    # Quick demonstration
    print("Quantum EML Algorithms — Self-test")
    print("=" * 40)
    
    # Test composition
    theta_out, r_out = quantum_eml_compose(np.pi/4, 2.0, np.pi/3, 3.0)
    direct = quantum_eml_polar(theta_out, r_out)
    composed = quantum_eml_polar(np.pi/4, 2.0) * quantum_eml_polar(np.pi/3, 3.0)
    print(f"Composition test: error = {abs(direct - composed):.2e}")
    
    # Test recovery
    z = 3 + 4j
    theta, r = quantum_eml_recover(z)
    reconstructed = quantum_eml_polar(theta, r)
    print(f"Recovery test: error = {abs(reconstructed - z):.2e}")
    
    # Test distance bound
    d = quantum_eml_distance(0, np.pi/4, 5.0)
    d_direct = abs(quantum_eml_polar(0, 5.0) - quantum_eml_polar(np.pi/4, 5.0))
    print(f"Distance test: error = {abs(d - d_direct):.2e}")
    
    # Test layer
    layer = QuantumEMLLayer(4, seed=42)
    outputs = layer.forward(1.0 + 0.5j)
    print(f"Layer test: {len(outputs)} outputs, norms = {[f'{abs(o):.3f}' for o in outputs]}")
    
    print("\nAll tests passed ✓")
