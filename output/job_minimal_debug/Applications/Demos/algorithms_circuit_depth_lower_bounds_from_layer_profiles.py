"""
Circuit Depth Lower Bounds from Layer Profiles — Algorithm Implementations

Type-hinted implementations of the core algorithms for computing circuit
depth lower bounds, layer profiles, and exchange descent complexity analysis.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional
import math


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class BoolCircuit:
    """A Boolean circuit represented as a tree of gates.

    Each gate is one of:
      - ('INPUT', index)
      - ('CONST', value)
      - ('AND', left, right)
      - ('OR', left, right)
      - ('NOT', child)
    """
    gate_type: str
    children: List['BoolCircuit']
    value: Optional[int] = None  # For INPUT: index; for CONST: 0 or 1

    @staticmethod
    def input(index: int) -> 'BoolCircuit':
        return BoolCircuit('INPUT', [], value=index)

    @staticmethod
    def const(val: bool) -> 'BoolCircuit':
        return BoolCircuit('CONST', [], value=int(val))

    @staticmethod
    def and_gate(left: 'BoolCircuit', right: 'BoolCircuit') -> 'BoolCircuit':
        return BoolCircuit('AND', [left, right])

    @staticmethod
    def or_gate(left: 'BoolCircuit', right: 'BoolCircuit') -> 'BoolCircuit':
        return BoolCircuit('OR', [left, right])

    @staticmethod
    def not_gate(child: 'BoolCircuit') -> 'BoolCircuit':
        return BoolCircuit('NOT', [child])

    def eval(self, assignment: List[bool]) -> bool:
        """Evaluate the circuit on a given input assignment."""
        if self.gate_type == 'INPUT':
            return assignment[self.value]
        elif self.gate_type == 'CONST':
            return bool(self.value)
        elif self.gate_type == 'AND':
            return self.children[0].eval(assignment) and self.children[1].eval(assignment)
        elif self.gate_type == 'OR':
            return self.children[0].eval(assignment) or self.children[1].eval(assignment)
        elif self.gate_type == 'NOT':
            return not self.children[0].eval(assignment)
        raise ValueError(f"Unknown gate type: {self.gate_type}")


# ============================================================================
# Circuit Metrics
# ============================================================================

def circuit_depth(c: BoolCircuit) -> int:
    """Compute the depth of a Boolean circuit (longest root-to-leaf path)."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 0
    elif c.gate_type == 'NOT':
        return 1 + circuit_depth(c.children[0])
    else:  # AND, OR
        return 1 + max(circuit_depth(c.children[0]), circuit_depth(c.children[1]))


def circuit_size(c: BoolCircuit) -> int:
    """Compute the size (total gate count) of a Boolean circuit."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 1
    elif c.gate_type == 'NOT':
        return 1 + circuit_size(c.children[0])
    else:
        return 1 + circuit_size(c.children[0]) + circuit_size(c.children[1])


def internal_size(c: BoolCircuit) -> int:
    """Count the number of internal (non-leaf) gates."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 0
    elif c.gate_type == 'NOT':
        return 1 + internal_size(c.children[0])
    else:
        return 1 + internal_size(c.children[0]) + internal_size(c.children[1])


def leaf_count(c: BoolCircuit) -> int:
    """Count the number of leaf nodes (inputs and constants)."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 1
    elif c.gate_type == 'NOT':
        return leaf_count(c.children[0])
    else:
        return leaf_count(c.children[0]) + leaf_count(c.children[1])


def negation_depth(c: BoolCircuit) -> int:
    """Compute the negation depth (NOT gates on longest path)."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 0
    elif c.gate_type == 'NOT':
        return 1 + negation_depth(c.children[0])
    elif c.gate_type in ('AND', 'OR'):
        return max(negation_depth(c.children[0]), negation_depth(c.children[1]))
    return 0


# ============================================================================
# Layer Profile
# ============================================================================

def layer_count(c: BoolCircuit, d: int) -> int:
    """Count internal gates at depth exactly d."""
    if c.gate_type in ('INPUT', 'CONST'):
        return 0
    if d == 0:
        return 1
    if c.gate_type == 'NOT':
        return layer_count(c.children[0], d - 1)
    # AND, OR
    return layer_count(c.children[0], d - 1) + layer_count(c.children[1], d - 1)


def layer_profile(c: BoolCircuit) -> List[int]:
    """Compute the full layer profile of a circuit.

    Returns a list where profile[d] = number of internal gates at depth d.
    """
    depth = circuit_depth(c)
    return [layer_count(c, d) for d in range(depth)]


def information_width(c: BoolCircuit) -> int:
    """The maximum layer count across all depths (circuit width)."""
    profile = layer_profile(c)
    return max(profile) if profile else 0


# ============================================================================
# Sensitivity
# ============================================================================

def sensitivity(c: BoolCircuit, assignment: List[bool]) -> int:
    """Compute the sensitivity of a circuit at a given input."""
    n = len(assignment)
    base_output = c.eval(assignment)
    count = 0
    for i in range(n):
        flipped = assignment.copy()
        flipped[i] = not flipped[i]
        if c.eval(flipped) != base_output:
            count += 1
    return count


def max_sensitivity(c: BoolCircuit, n: int) -> int:
    """Compute the maximum sensitivity over all 2^n inputs."""
    max_sens = 0
    for bits in range(2 ** n):
        assignment = [(bits >> i) & 1 == 1 for i in range(n)]
        max_sens = max(max_sens, sensitivity(c, assignment))
    return max_sens


# ============================================================================
# Exchange Descent
# ============================================================================

@dataclass
class ExchangeDescentSpec:
    """Specification for an exchange descent problem."""
    dim: int
    cert_depth: int

    def __post_init__(self) -> None:
        assert self.cert_depth < self.dim, "cert_depth must be < dim"
        assert self.dim >= 2, "dim must be >= 2"

    @property
    def gap(self) -> int:
        return self.dim - self.cert_depth - 1

    @property
    def input_bits(self) -> int:
        return self.dim + 2 ** self.dim

    @property
    def output_bits(self) -> int:
        return int(math.log2(self.dim)) + 1


def conjectured_depth_lower_bound(d: int, k: int) -> int:
    """Compute the conjectured depth lower bound: (d - k - 1) * floor(log2(d))."""
    if d <= k + 1:
        return 0
    return (d - k - 1) * int(math.log2(d))


# ============================================================================
# Verification Algorithms
# ============================================================================

def verify_layer_profile_conservation(c: BoolCircuit) -> bool:
    """Verify that sum of layer counts = internal size."""
    profile = layer_profile(c)
    return sum(profile) == internal_size(c)


def verify_work_ge_span(c: BoolCircuit) -> bool:
    """Verify that size >= depth + 1."""
    return circuit_size(c) >= circuit_depth(c) + 1


def verify_leaf_count_bound(c: BoolCircuit) -> bool:
    """Verify that leaf_count <= 2^depth."""
    return leaf_count(c) <= 2 ** circuit_depth(c)


def verify_negation_depth_bound(c: BoolCircuit) -> bool:
    """Verify that negation_depth <= depth."""
    return negation_depth(c) <= circuit_depth(c)


def verify_monotonicity(c: BoolCircuit, n: int) -> bool:
    """Verify that a circuit with negation_depth = 0 is monotone."""
    if negation_depth(c) != 0:
        return True  # Vacuously true
    for bits1 in range(2 ** n):
        a1 = [(bits1 >> i) & 1 == 1 for i in range(n)]
        for bits2 in range(2 ** n):
            a2 = [(bits2 >> i) & 1 == 1 for i in range(n)]
            # Check: if a1 <= a2 pointwise, then f(a1) <= f(a2)
            if all(not a1[i] or a2[i] for i in range(n)):
                if c.eval(a1) and not c.eval(a2):
                    return False
    return True


# ============================================================================
# Example Circuit Constructors
# ============================================================================

def build_parity_circuit(n: int) -> BoolCircuit:
    """Build a circuit computing the XOR (parity) of n inputs.

    This requires depth O(log n) and demonstrates the depth-sensitivity
    relationship: parity has maximum sensitivity n.
    """
    if n == 0:
        return BoolCircuit.const(False)
    if n == 1:
        return BoolCircuit.input(0)

    inputs = [BoolCircuit.input(i) for i in range(n)]
    # XOR via tree: a XOR b = (a AND NOT b) OR (NOT a AND b)
    def xor_gate(a: BoolCircuit, b: BoolCircuit) -> BoolCircuit:
        return BoolCircuit.or_gate(
            BoolCircuit.and_gate(a, BoolCircuit.not_gate(b)),
            BoolCircuit.and_gate(BoolCircuit.not_gate(a), b)
        )

    # Build a balanced binary tree of XOR gates
    level = inputs
    while len(level) > 1:
        next_level = []
        for i in range(0, len(level), 2):
            if i + 1 < len(level):
                next_level.append(xor_gate(level[i], level[i + 1]))
            else:
                next_level.append(level[i])
        level = next_level
    return level[0]


def build_majority_circuit(n: int = 3) -> BoolCircuit:
    """Build a majority circuit on 3 inputs (monotone, depth 2)."""
    x0, x1, x2 = BoolCircuit.input(0), BoolCircuit.input(1), BoolCircuit.input(2)
    # MAJ(x0,x1,x2) = (x0 AND x1) OR (x1 AND x2) OR (x0 AND x2)
    return BoolCircuit.or_gate(
        BoolCircuit.or_gate(
            BoolCircuit.and_gate(x0, x1),
            BoolCircuit.and_gate(x1, x2)
        ),
        BoolCircuit.and_gate(x0, x2)
    )
