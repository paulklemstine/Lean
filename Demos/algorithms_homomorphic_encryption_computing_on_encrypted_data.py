"""
Algorithms for Noise-Bounded Fully Homomorphic Encryption

Implements the core FHE algorithms formalized in Lean 4:
- Noise-bounded HE scheme simulation
- Bootstrapped circuit evaluation (Gentry's construction)
- BGV leveled evaluation
- Noise growth analysis
"""

from typing import List, Tuple, Callable, Any, Optional
from dataclasses import dataclass
from enum import Enum
import math


class GateType(Enum):
    INPUT = "input"
    ADD = "add"
    MUL = "mul"


@dataclass
class ArithCircuit:
    """Arithmetic circuit: tree of additions and multiplications."""
    gate: GateType
    value: Optional[int] = None  # For input gates
    left: Optional['ArithCircuit'] = None
    right: Optional['ArithCircuit'] = None

    @staticmethod
    def input(val: int) -> 'ArithCircuit':
        return ArithCircuit(GateType.INPUT, value=val)

    @staticmethod
    def add(left: 'ArithCircuit', right: 'ArithCircuit') -> 'ArithCircuit':
        return ArithCircuit(GateType.ADD, left=left, right=right)

    @staticmethod
    def mul(left: 'ArithCircuit', right: 'ArithCircuit') -> 'ArithCircuit':
        return ArithCircuit(GateType.MUL, left=left, right=right)

    def depth(self) -> int:
        """Multiplicative depth of the circuit."""
        if self.gate == GateType.INPUT:
            return 0
        assert self.left is not None and self.right is not None
        if self.gate == GateType.ADD:
            return max(self.left.depth(), self.right.depth())
        return max(self.left.depth(), self.right.depth()) + 1

    def size(self) -> int:
        """Total number of nodes."""
        if self.gate == GateType.INPUT:
            return 1
        assert self.left is not None and self.right is not None
        return self.left.size() + self.right.size() + 1

    def evaluate(self) -> int:
        """Evaluate the circuit on plaintext values."""
        if self.gate == GateType.INPUT:
            assert self.value is not None
            return self.value
        assert self.left is not None and self.right is not None
        if self.gate == GateType.ADD:
            return self.left.evaluate() + self.right.evaluate()
        return self.left.evaluate() * self.right.evaluate()


@dataclass
class Ciphertext:
    """A ciphertext with tracked noise level."""
    value: int  # The actual encrypted value (simplified model)
    noise: int  # Current noise level
    key_id: int = 0  # Which key this is encrypted under


@dataclass
class NoiseBoundedHE:
    """
    Noise-bounded homomorphic encryption scheme.

    This is a simplified simulation that tracks noise growth
    through homomorphic operations, matching our formal model.
    """
    max_noise: int
    fresh_noise: int
    secret_key: int = 42  # Simplified

    def encrypt(self, plaintext: int) -> Ciphertext:
        """Encrypt a plaintext value."""
        # In a real scheme, this would involve lattice operations
        return Ciphertext(value=plaintext, noise=self.fresh_noise)

    def decrypt(self, ct: Ciphertext) -> Optional[int]:
        """Decrypt if noise is within bounds."""
        if ct.noise >= self.max_noise:
            return None  # Decryption failure
        return ct.value

    def h_add(self, c1: Ciphertext, c2: Ciphertext) -> Ciphertext:
        """Homomorphic addition."""
        return Ciphertext(
            value=c1.value + c2.value,
            noise=c1.noise + c2.noise
        )

    def h_mul(self, c1: Ciphertext, c2: Ciphertext) -> Ciphertext:
        """Homomorphic multiplication."""
        return Ciphertext(
            value=c1.value * c2.value,
            noise=c1.noise * c2.noise
        )

    def is_valid(self, ct: Ciphertext) -> bool:
        """Check if ciphertext noise is within bounds."""
        return ct.noise < self.max_noise


@dataclass
class BootstrappableHE(NoiseBoundedHE):
    """HE scheme with bootstrapping (noise refresh)."""
    bootstrap_noise: int = 3

    def refresh(self, ct: Ciphertext) -> Ciphertext:
        """Refresh a ciphertext, reducing noise to bootstrap level."""
        if ct.noise >= self.max_noise:
            raise ValueError("Cannot refresh invalid ciphertext")
        return Ciphertext(value=ct.value, noise=self.bootstrap_noise)

    def refreshed_eval(self, circuit: ArithCircuit,
                       inputs: dict[int, Ciphertext]) -> Ciphertext:
        """
        Evaluate circuit with refresh after every gate.
        This is Gentry's construction for unlimited computation.
        """
        if circuit.gate == GateType.INPUT:
            assert circuit.value is not None
            return inputs[circuit.value]

        assert circuit.left is not None and circuit.right is not None
        r1 = self.refresh(self.refreshed_eval(circuit.left, inputs))
        r2 = self.refresh(self.refreshed_eval(circuit.right, inputs))

        if circuit.gate == GateType.ADD:
            result = self.h_add(r1, r2)
        else:
            result = self.h_mul(r1, r2)

        return self.refresh(result)

    def can_bootstrap(self) -> bool:
        """Check the bootstrapping capacity condition."""
        return (self.bootstrap_noise * self.bootstrap_noise < self.max_noise and
                self.bootstrap_noise + self.bootstrap_noise < self.max_noise)


def noise_growth_without_bootstrap(initial_noise: int, depth: int) -> int:
    """
    Compute noise after `depth` levels of multiplication without bootstrapping.
    Noise grows as initial_noise^(2^depth).
    """
    return initial_noise ** (2 ** depth)


def max_depth_without_bootstrap(initial_noise: int, max_noise: int) -> int:
    """
    Maximum multiplicative depth achievable without bootstrapping.
    """
    if initial_noise <= 1:
        return float('inf')  # type: ignore
    depth = 0
    current = initial_noise
    while current < max_noise:
        current = current * current
        depth += 1
    return depth - 1  # Last valid depth


def bgv_leveled_eval(scheme: NoiseBoundedHE,
                     circuit: ArithCircuit,
                     inputs: dict[int, Ciphertext]) -> Ciphertext:
    """
    BGV-style leveled evaluation (no bootstrapping needed for known-depth circuits).
    """
    if circuit.gate == GateType.INPUT:
        assert circuit.value is not None
        return inputs[circuit.value]

    assert circuit.left is not None and circuit.right is not None
    c1 = bgv_leveled_eval(scheme, circuit.left, inputs)
    c2 = bgv_leveled_eval(scheme, circuit.right, inputs)

    if circuit.gate == GateType.ADD:
        return scheme.h_add(c1, c2)
    return scheme.h_mul(c1, c2)


def find_optimal_parameters(target_depth: int, security_bits: int = 128
                            ) -> dict[str, int]:
    """
    Find optimal FHE parameters for a given circuit depth.

    Returns approximate parameter suggestions for:
    - n: ring dimension
    - log_q: log of ciphertext modulus
    - fresh_noise: initial noise bound
    - max_noise: maximum tolerable noise
    """
    # Simplified parameter selection based on known heuristics
    n = max(1024, 2 ** math.ceil(math.log2(security_bits * target_depth)))
    log_q = target_depth * 30 + security_bits  # Rough estimate
    fresh_noise = 2 ** 10
    max_noise = 2 ** (log_q - 1)

    return {
        "ring_dimension": n,
        "log_modulus": log_q,
        "fresh_noise": fresh_noise,
        "max_noise": max_noise,
        "achievable_depth": max_depth_without_bootstrap(fresh_noise, max_noise)
    }
