#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Algorithms

Type-hinted implementations of the core quantum EML operations.
"""

from typing import List, Tuple
import numpy as np
from scipy.linalg import expm, logm


# ─── Core Data Types ─────────────────────────────────────────────────

class QuantumEMLGate:
    """A quantum EML gate parametrized by two matrices (exp and log params)."""

    def __init__(self, exp_param: np.ndarray, log_param: np.ndarray):
        assert exp_param.shape == log_param.shape
        self.exp_param = exp_param.astype(complex)
        self.log_param = log_param.astype(complex)
        self.dim = exp_param.shape[0]

    def eval(self) -> np.ndarray:
        """Gate value: exp(h1) * exp(h2)."""
        return expm(self.exp_param) @ expm(self.log_param)

    def inverse(self) -> "QuantumEMLGate":
        """Inverse gate: (-h2, -h1)."""
        return QuantumEMLGate(-self.log_param, -self.exp_param)

    def param_norm(self) -> float:
        """Total parameter norm."""
        return float(np.linalg.norm(self.exp_param) + np.linalg.norm(self.log_param))


class QuantumEMLNeuron:
    """Full quantum EML neuron with rotation + bias."""

    def __init__(self, rotation: np.ndarray, bias: float):
        self.rotation = rotation.astype(complex)
        self.bias = bias
        self.dim = rotation.shape[0]

    def forward(self, rho: np.ndarray) -> np.ndarray:
        """Apply neuron: exp(h)*rho*exp(-h) + t*I."""
        E = expm(self.rotation)
        Em = expm(-self.rotation)
        return E @ rho @ Em + self.bias * np.eye(self.dim, dtype=complex)


class QuantumEMLCircuit:
    """A circuit of quantum EML gates."""

    def __init__(self, gates: List[QuantumEMLGate]):
        self.gates = gates

    @property
    def depth(self) -> int:
        return len(self.gates)

    def total_param_norm(self) -> float:
        return sum(g.param_norm() for g in self.gates)

    def eval(self) -> np.ndarray:
        """Evaluate circuit as product of gate values."""
        n = self.gates[0].dim if self.gates else 2
        result = np.eye(n, dtype=complex)
        for gate in self.gates:
            result = result @ gate.eval()
        return result


# ─── BCH Defect Computation ──────────────────────────────────────────

def bch_defect(h1: np.ndarray, h2: np.ndarray) -> np.ndarray:
    """BCH defect: exp(h1)*exp(h2) - exp(h1+h2).

    This is zero when [h1, h2] = 0 and measures the
    noncommutative correction to the classical (commutative) case.
    """
    return expm(h1) @ expm(h2) - expm(h1 + h2)


def bch_defect_norm(h1: np.ndarray, h2: np.ndarray) -> float:
    """Frobenius norm of BCH defect."""
    return float(np.linalg.norm(bch_defect(h1, h2)))


def commutator_norm(h1: np.ndarray, h2: np.ndarray) -> float:
    """Norm of matrix commutator [h1, h2]."""
    return float(np.linalg.norm(h1 @ h2 - h2 @ h1))


# ─── Quantum EML Channel ─────────────────────────────────────────────

def qeml_channel(h: np.ndarray, rho: np.ndarray) -> np.ndarray:
    """Quantum EML channel: rho -> exp(h) * rho * exp(-h)."""
    E = expm(h)
    Em = expm(-h)
    return E @ rho @ Em


def qeml_channel_batch(h: np.ndarray, rhos: List[np.ndarray]) -> List[np.ndarray]:
    """Apply quantum EML channel to a batch of states."""
    E = expm(h)
    Em = expm(-h)
    return [E @ rho @ Em for rho in rhos]


# ─── Diagonal Spectral Bridge ────────────────────────────────────────

def diagonal_spectral_bridge(
    eigenvalues_1: List[complex],
    eigenvalues_2: List[complex],
) -> List[complex]:
    """Apply quantum EML to diagonal matrices via scalar operations.

    For diagonal matrices D1=diag(λ), D2=diag(μ):
      exp(D1)*exp(D2) = diag(exp(λ_i)*exp(μ_i))

    This is the bridge between quantum (matrix) and classical (scalar) EML.
    """
    assert len(eigenvalues_1) == len(eigenvalues_2)
    return [np.exp(a) * np.exp(b) for a, b in zip(eigenvalues_1, eigenvalues_2)]


# ─── Gate Distance and Metric ────────────────────────────────────────

def qeml_distance(g1: QuantumEMLGate, g2: QuantumEMLGate) -> float:
    """Distance between two QEML gates (Frobenius norm of difference)."""
    return float(np.linalg.norm(g1.eval() - g2.eval()))


# ─── Optimization: Find QEML gate closest to target unitary ─────────

def find_qeml_gate(
    target: np.ndarray,
    n_iter: int = 1000,
    lr: float = 0.01,
    dim: int = 2,
) -> Tuple[QuantumEMLGate, float]:
    """Find QEML gate parameters that approximate a target matrix.

    Uses gradient-free random search (since matrix exponential
    gradient is complex).

    Returns (best_gate, best_distance).
    """
    best_gate = QuantumEMLGate(np.zeros((dim, dim)), np.zeros((dim, dim)))
    best_dist = np.linalg.norm(best_gate.eval() - target)

    for _ in range(n_iter):
        # Random perturbation
        h1 = np.random.randn(dim, dim) * lr + (best_gate.exp_param.real if best_dist < float('inf') else 0)
        h2 = np.random.randn(dim, dim) * lr + (best_gate.log_param.real if best_dist < float('inf') else 0)

        gate = QuantumEMLGate(h1, h2)
        dist = float(np.linalg.norm(gate.eval() - target))

        if dist < best_dist:
            best_gate = gate
            best_dist = dist

    return best_gate, best_dist


if __name__ == "__main__":
    # Quick test
    sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
    sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

    g = QuantumEMLGate(0.5 * sigma_x, 0.3 * sigma_z)
    print(f"Gate eval:\n{g.eval()}")
    print(f"Gate param norm: {g.param_norm():.4f}")
    print(f"BCH defect norm: {bch_defect_norm(0.5 * sigma_x, 0.3 * sigma_z):.6f}")

    # Test circuit
    circuit = QuantumEMLCircuit([
        QuantumEMLGate(0.3 * sigma_x, 0.2 * sigma_z),
        QuantumEMLGate(0.1 * sigma_x, -0.4 * sigma_z),
    ])
    print(f"\nCircuit depth: {circuit.depth}")
    print(f"Circuit total norm: {circuit.total_param_norm():.4f}")
    print(f"Circuit eval:\n{circuit.eval()}")

    # Test spectral bridge
    bridge = diagonal_spectral_bridge([1.0, 2.0], [0.5, -0.3])
    print(f"\nSpectral bridge: {bridge}")
