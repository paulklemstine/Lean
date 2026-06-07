#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Algorithms

Type-hinted implementations of the core algorithms from the
Quantum EML Spectral Pair theory.
"""

from dataclasses import dataclass
from typing import List, Tuple, Callable
import numpy as np


@dataclass
class EMLSpectralPair:
    """An EML Spectral Pair representing quantum-classical decomposition."""
    phase: float
    logScale: float
    
    def quantum_gate(self) -> complex:
        """Compute unitary component exp(i·phase)."""
        return np.exp(1j * self.phase)
    
    def classical_info(self) -> float:
        """Compute classical information content -logScale."""
        return -self.logScale
    
    def quantum_amplitude(self) -> float:
        """Compute quantum amplitude exp(phase)."""
        return np.exp(self.phase)
    
    def eml_value(self) -> float:
        """Compute full EML value: exp(phase) - logScale."""
        return np.exp(self.phase) - self.logScale
    
    def spectral_norm(self) -> float:
        """Compute spectral norm sqrt(phase² + logScale²)."""
        return np.sqrt(self.phase**2 + self.logScale**2)
    
    def compose(self, other: 'EMLSpectralPair') -> 'EMLSpectralPair':
        """Compose two spectral pairs: phases add, logScales add."""
        return EMLSpectralPair(
            phase=self.phase + other.phase,
            logScale=self.logScale + other.logScale
        )


def eml_spectral_distance(p: EMLSpectralPair, q: EMLSpectralPair) -> float:
    """
    Compute the EML spectral distance between two pairs.
    
    This is a genuine metric (proven: symmetry, triangle inequality, 
    separation) on the space of EML spectral pairs.
    
    Algorithm: Euclidean distance on (phase, logScale) coordinates.
    Complexity: O(1)
    """
    return np.sqrt((p.phase - q.phase)**2 + (p.logScale - q.logScale)**2)


@dataclass
class QuantumEMLNeuron:
    """
    A quantum EML neuron with dual channels.
    
    Given input x, produces:
    - Quantum output: exp(i·(w₁·x + b₁)) ∈ U(1)  (unit circle)
    - Classical output: exp(w₁·x + b₁) - (w₂·x + b₂)  (real number)
    """
    w1: float  # Weight for exponential (phase) channel
    b1: float  # Bias for exponential (phase) channel
    w2: float  # Weight for logarithmic (information) channel
    b2: float  # Bias for logarithmic (information) channel
    
    def eval(self, x: float) -> EMLSpectralPair:
        """Evaluate the neuron at input x."""
        return EMLSpectralPair(
            phase=self.w1 * x + self.b1,
            logScale=self.w2 * x + self.b2
        )
    
    def quantum_output(self, x: float) -> complex:
        """Compute quantum (unitary) output."""
        return self.eval(x).quantum_gate()
    
    def classical_output(self, x: float) -> float:
        """Compute classical (EML) output."""
        return self.eval(x).eml_value()
    
    def forward(self, x: float) -> Tuple[complex, float]:
        """Full forward pass returning both outputs."""
        sp = self.eval(x)
        return sp.quantum_gate(), sp.eml_value()


class QuantumEMLLayer:
    """
    A layer of quantum EML neurons.
    
    Each neuron independently produces a spectral pair.
    The layer output is the composed spectral pair (phases sum, logScales sum).
    
    Algorithm:
    1. Each neuron evaluates independently: O(n) total
    2. Compose all spectral pairs: O(n) additions
    3. Total: O(n) per forward pass
    """
    
    def __init__(self, neurons: List[QuantumEMLNeuron]):
        self.neurons = neurons
    
    def forward(self, x: float) -> EMLSpectralPair:
        """Forward pass: compose all neuron outputs."""
        result = EMLSpectralPair(0.0, 0.0)
        for neuron in self.neurons:
            result = result.compose(neuron.eval(x))
        return result
    
    def quantum_output(self, x: float) -> complex:
        """Combined quantum gate (product of individual gates)."""
        return self.forward(x).quantum_gate()


def eml_spectral_gap_verifier(x: float) -> Tuple[float, bool]:
    """
    Verify the EML Spectral Gap theorem for a given x > 0.
    
    Theorem: exp(x) - log(x) > 2 for all x > 0.
    
    Returns: (eml_diag_value, is_above_gap)
    """
    if x <= 0:
        raise ValueError(f"x must be positive, got {x}")
    val = np.exp(x) - np.log(x)
    return val, val > 2.0


def find_eml_diag_minimum(
    x_min: float = 0.01, 
    x_max: float = 5.0, 
    n_points: int = 10000
) -> Tuple[float, float]:
    """
    Find the approximate minimum of exp(x) - log(x) on (0, ∞).
    
    The true minimum is at x₀ = W(1) ≈ 0.5671 (Lambert W function)
    with minimum value ≈ 2.3327.
    
    Algorithm: Grid search with refinement
    Complexity: O(n_points)
    """
    xs = np.linspace(x_min, x_max, n_points)
    vals = np.exp(xs) - np.log(xs)
    min_idx = np.argmin(vals)
    return float(xs[min_idx]), float(vals[min_idx])


def quantum_eml_gradient(
    neuron: QuantumEMLNeuron, 
    x: float
) -> Tuple[float, float, float, float]:
    """
    Compute gradients of classical output w.r.t. neuron parameters.
    
    The classical output is f(x) = exp(w₁x + b₁) - (w₂x + b₂).
    
    Returns: (∂f/∂w₁, ∂f/∂b₁, ∂f/∂w₂, ∂f/∂b₂)
    
    Algorithm: Analytic differentiation
    Complexity: O(1)
    """
    phase = neuron.w1 * x + neuron.b1
    amp = np.exp(phase)
    
    df_dw1 = x * amp       # ∂f/∂w₁ = x · exp(w₁x + b₁)
    df_db1 = amp            # ∂f/∂b₁ = exp(w₁x + b₁)
    df_dw2 = -x             # ∂f/∂w₂ = -x
    df_db2 = -1.0           # ∂f/∂b₂ = -1
    
    return df_dw1, df_db1, df_dw2, df_db2


def train_quantum_eml_neuron(
    target_fn: Callable[[float], float],
    x_train: np.ndarray,
    learning_rate: float = 0.01,
    n_epochs: int = 1000
) -> QuantumEMLNeuron:
    """
    Train a quantum EML neuron to approximate a target function.
    
    Uses gradient descent on the classical channel.
    
    Algorithm:
    1. Initialize random parameters
    2. For each epoch:
       a. Compute predictions for all training points
       b. Compute MSE loss
       c. Update parameters via gradient descent
    
    Complexity: O(n_epochs × n_train)
    """
    # Initialize
    neuron = QuantumEMLNeuron(
        w1=np.random.randn() * 0.1,
        b1=np.random.randn() * 0.1,
        w2=np.random.randn() * 0.1,
        b2=np.random.randn() * 0.1
    )
    
    for epoch in range(n_epochs):
        total_grad = np.zeros(4)
        total_loss = 0.0
        
        for x in x_train:
            pred = neuron.classical_output(float(x))
            target = target_fn(float(x))
            error = pred - target
            total_loss += error**2
            
            grads = quantum_eml_gradient(neuron, float(x))
            total_grad += np.array(grads) * error
        
        # Update
        total_grad /= len(x_train)
        neuron.w1 -= learning_rate * total_grad[0]
        neuron.b1 -= learning_rate * total_grad[1]
        neuron.w2 -= learning_rate * total_grad[2]
        neuron.b2 -= learning_rate * total_grad[3]
        
        if epoch % 200 == 0:
            mse = total_loss / len(x_train)
            print(f"  Epoch {epoch:4d}: MSE = {mse:.6f}")
    
    return neuron


if __name__ == "__main__":
    print("=== EML Spectral Gap Minimum ===")
    x_min, val_min = find_eml_diag_minimum()
    print(f"Minimum at x ≈ {x_min:.4f}, value ≈ {val_min:.6f}")
    print(f"Gap above 2: {val_min - 2:.6f}")
    
    print("\n=== Training Quantum EML Neuron ===")
    print("Target: sin(x) on [-π, π]")
    x_train = np.linspace(-np.pi, np.pi, 50)
    neuron = train_quantum_eml_neuron(np.sin, x_train, learning_rate=0.001, n_epochs=1000)
    print(f"Trained neuron: w₁={neuron.w1:.4f}, b₁={neuron.b1:.4f}, "
          f"w₂={neuron.w2:.4f}, b₂={neuron.b2:.4f}")
