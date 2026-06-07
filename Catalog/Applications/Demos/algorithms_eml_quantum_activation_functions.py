#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Algorithms

Type-hinted implementations of the core Quantum EML algorithms
for neural network activation functions and quantum computing bridges.
"""

from typing import Tuple, List, Optional, Callable
import numpy as np


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Quantum EML Activation Evaluation
# ═══════════════════════════════════════════════════════════════

def qeml_activate(z: complex, w: complex) -> complex:
    """
    Evaluate the Quantum EML activation function.

    The QEML activation is the complexification of the classical EML:
        qeml(z, w) = exp(z) - log(w)

    This function is:
    - Holomorphic in z for fixed w
    - Surjective onto ℂ (Theorem qeml_surjective)
    - Reduces to classical EML on real inputs (Theorem qeml_classical_embedding)

    Parameters:
        z: Complex input (exponential channel)
        w: Complex input (logarithmic channel), must be nonzero

    Returns:
        Complex activation value
    """
    return np.exp(z) - np.log(w)


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Quantum EML Neuron (Phase-Amplitude Architecture)
# ═══════════════════════════════════════════════════════════════

class QuantumEMLNeuron:
    """
    A quantum EML neuron with phase-amplitude separation.

    The neuron computes: output = exp(i·α) · log(1 + i·β)

    Key properties (all formally verified):
    - The amplitude |output| depends only on β (Theorem qemlNeuron_norm_independent_of_phase)
    - The phase of output is controlled by α (Theorem qemlNeuron_phase_action)
    - Phase composition is additive (Theorem qemlPhase_add)
    """

    def __init__(self, alpha: float = 0.0, beta: float = 1.0):
        self.alpha = alpha  # Phase parameter (lives on S¹)
        self.beta = beta    # Amplitude parameter (lives on ℝ)

    def forward(self, x: complex) -> complex:
        """Evaluate the neuron: exp(i·α) · log(1 + i·β·x)"""
        phase = np.exp(1j * self.alpha)
        log_act = np.log(1 + 1j * self.beta * x)
        return phase * log_act

    def amplitude(self) -> float:
        """The amplitude of the neuron's output (independent of phase)."""
        return abs(np.log(1 + 1j * self.beta))

    def get_phase(self) -> complex:
        """The phase rotation applied by this neuron."""
        return np.exp(1j * self.alpha)

    def compose_phase(self, other: 'QuantumEMLNeuron') -> 'QuantumEMLNeuron':
        """Compose phase rotations: result has phase α₁ + α₂."""
        return QuantumEMLNeuron(self.alpha + other.alpha, self.beta)


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: QEML Surjectivity Witness Construction
# ═══════════════════════════════════════════════════════════════

def find_qeml_preimage(target: complex) -> Tuple[complex, complex]:
    """
    Constructive surjectivity: find (z, w) such that qeml(z, w) = target.

    This implements the constructive proof of Theorem qeml_surjective.

    Strategy:
    - For target ≠ -1: z = log(target + 1), w = e
      Then qeml(z, w) = exp(log(target+1)) - log(e) = (target+1) - 1 = target
    - For target = -1: z = iπ, w = 1
      Then qeml(z, w) = exp(iπ) - log(1) = -1 - 0 = -1

    Parameters:
        target: Any complex number

    Returns:
        (z, w) such that qeml(z, w) = target
    """
    if np.isclose(target, -1.0):
        return (1j * np.pi, complex(1.0))
    else:
        z = np.log(target + 1)
        w = complex(np.e)
        return (z, w)


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Quantum EML Chain Evaluation
# ═══════════════════════════════════════════════════════════════

class QEMLChainOp:
    """An operation in a quantum EML chain."""

    def __init__(self, op_type: str, params: Optional[Tuple] = None):
        """
        op_type: 'cexp', 'clog', 'affine', 'phase_rotate'
        params: For 'affine': (a, b) complex; for 'phase_rotate': (theta,) real
        """
        self.op_type = op_type
        self.params = params or ()

    def eval(self, z: complex) -> complex:
        if self.op_type == 'cexp':
            return np.exp(z)
        elif self.op_type == 'clog':
            return np.log(z) if z != 0 else complex(float('-inf'))
        elif self.op_type == 'affine':
            a, b = self.params
            return a * z + b
        elif self.op_type == 'phase_rotate':
            theta = self.params[0]
            return np.exp(1j * theta) * z
        else:
            raise ValueError(f"Unknown op: {self.op_type}")

    def depth_contribution(self) -> int:
        """Non-trivial operations (exp, log) contribute depth 1; affine/phase are free."""
        if self.op_type in ('cexp', 'clog'):
            return 1
        return 0


def eval_qchain(chain: List[QEMLChainOp], z: complex) -> complex:
    """
    Evaluate a quantum EML chain (left-to-right composition).

    Satisfies: eval_qchain(c1 ++ c2, z) = eval_qchain(c1, eval_qchain(c2, z))
    (Theorem qeml_chain_comp_eval)
    """
    result = z
    for op in reversed(chain):
        result = op.eval(result)
    return result


def qchain_depth(chain: List[QEMLChainOp]) -> int:
    """
    Compute the depth (number of exp/log operations) of a chain.

    Satisfies: depth(c1 ++ c2) ≤ depth(c1) + depth(c2)
    (Theorem qeml_chain_depth_subadditive)

    Phase rotations are free (Theorem qeml_phase_depth_free).
    """
    return sum(op.depth_contribution() for op in chain)


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Quantum EML Layer (Neural Network Integration)
# ═══════════════════════════════════════════════════════════════

class QuantumEMLLayer:
    """
    A layer of quantum EML neurons for quantum-classical neural networks.

    Each neuron has independent phase (α) and amplitude (β) parameters,
    enabling gradient-based optimization with clean separation of concerns.
    """

    def __init__(self, input_dim: int, output_dim: int, seed: int = 42):
        rng = np.random.RandomState(seed)
        self.alphas = rng.uniform(0, 2 * np.pi, (output_dim, input_dim))
        self.betas = rng.uniform(-1, 1, (output_dim, input_dim))
        self.weights = rng.randn(output_dim, input_dim) * 0.1

    def forward(self, x: np.ndarray) -> np.ndarray:
        """
        Forward pass through the quantum EML layer.

        For each output neuron j:
            output_j = Σ_i w_ji · exp(i·α_ji) · log(1 + i·β_ji · x_i)

        Parameters:
            x: Input array of shape (input_dim,), real or complex

        Returns:
            Output array of shape (output_dim,), complex
        """
        output = np.zeros(self.alphas.shape[0], dtype=complex)
        for j in range(len(output)):
            for i in range(len(x)):
                phase = np.exp(1j * self.alphas[j, i])
                log_act = np.log(1 + 1j * self.betas[j, i] * x[i])
                output[j] += self.weights[j, i] * phase * log_act
        return output


# ═══════════════════════════════════════════════════════════════
# Demonstration
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Quantum EML Algorithms — Demonstration\n")

    # Test surjectivity
    print("Surjectivity witness construction:")
    for target in [0, 1, -1, 1+1j, -3.14+2.72j]:
        z, w = find_qeml_preimage(complex(target))
        result = qeml_activate(z, w)
        print(f"  target = {target:>12}, preimage qeml({z:.4f}, {w:.4f}) = {result:.6f}")

    # Test chain evaluation
    print("\nChain evaluation:")
    chain = [
        QEMLChainOp('phase_rotate', (np.pi/4,)),
        QEMLChainOp('cexp'),
        QEMLChainOp('affine', (2+0j, 1+0j)),
    ]
    z = 1.0 + 0.5j
    result = eval_qchain(chain, z)
    depth = qchain_depth(chain)
    print(f"  Chain of {len(chain)} ops, depth {depth}, input {z} → output {result:.4f}")

    # Test layer
    print("\nQuantum EML Layer (3 → 2):")
    layer = QuantumEMLLayer(3, 2)
    x = np.array([1.0, 0.5, -0.3])
    output = layer.forward(x)
    print(f"  Input:  {x}")
    print(f"  Output: {output}")
    print(f"  |Output|: {np.abs(output)}")
