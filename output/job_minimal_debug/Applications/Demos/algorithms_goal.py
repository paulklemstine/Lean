#!/usr/bin/env python3
"""
Tropical Circuit Duality: Algorithms

Implements the core algorithms from the duality theory:
1. Circuit dualization (min-to-max and max-to-min)
2. Semantic evaluation in both conventions
3. Simulation transfer: given a simulator for one convention, produce one for the other
4. Normal form extraction and duality at the affine-form level
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable
import itertools


# ═══════════════════════════════════════════════════════════════════════
# Circuit Data Types
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Var:
    """Variable node (shared between min/max circuits)."""
    index: int

@dataclass(frozen=True)
class Const:
    """Constant node."""
    value: float

@dataclass(frozen=True)
class Add:
    """Tropical multiplication (= real addition) gate."""
    left: 'CircuitNode'
    right: 'CircuitNode'

@dataclass(frozen=True)
class MinGate:
    """Min gate (tropical addition in min-plus)."""
    left: 'CircuitNode'
    right: 'CircuitNode'

@dataclass(frozen=True)
class MaxGate:
    """Max gate (tropical addition in max-plus)."""
    left: 'CircuitNode'
    right: 'CircuitNode'

# Type aliases
MinCircuitNode = Union[Var, Const, Add, MinGate]
MaxCircuitNode = Union[Var, Const, Add, MaxGate]
CircuitNode = Union[Var, Const, Add, MinGate, MaxGate]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Circuit Evaluation
# ═══════════════════════════════════════════════════════════════════════

def evaluate(node: CircuitNode, sigma: list[float]) -> float:
    """
    Evaluate a tropical circuit on assignment sigma.

    Handles both min-plus and max-plus circuits uniformly.

    Time complexity: O(|C|) where |C| is the circuit size.
    Space complexity: O(depth(C)) for the recursion stack.

    Args:
        node: Root of the circuit tree.
        sigma: Variable assignment (list of reals).

    Returns:
        The real-valued output of the circuit.

    >>> evaluate(MinGate(Var(0), Add(Const(3), Var(1))), [5, 2])
    5.0
    >>> evaluate(MaxGate(Var(0), Add(Const(-3), Var(1))), [-5, -2])
    -5.0
    """
    if isinstance(node, Var):
        return sigma[node.index]
    elif isinstance(node, Const):
        return node.value
    elif isinstance(node, Add):
        return evaluate(node.left, sigma) + evaluate(node.right, sigma)
    elif isinstance(node, MinGate):
        return min(evaluate(node.left, sigma), evaluate(node.right, sigma))
    elif isinstance(node, MaxGate):
        return max(evaluate(node.left, sigma), evaluate(node.right, sigma))
    raise TypeError(f"Unknown node type: {type(node)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Circuit Dualization
# ═══════════════════════════════════════════════════════════════════════

def dualize(node: CircuitNode) -> CircuitNode:
    """
    Dualize a tropical circuit: negate constants, swap min↔max.

    This is the core syntactic transformation. It satisfies:
      evaluate(dualize(C), [-σᵢ]) = -evaluate(C, [σᵢ])

    Time complexity: O(|C|)
    Space complexity: O(|C|) for the new tree

    The map is an involution: dualize(dualize(C)) == C.

    Args:
        node: Root of the circuit tree.

    Returns:
        The dualized circuit.

    >>> dualize(MinGate(Var(0), Const(3)))
    MaxGate(left=Var(index=0), right=Const(value=-3))
    >>> dualize(MaxGate(Var(0), Const(-3)))
    MinGate(left=Var(index=0), right=Const(value=3))
    """
    if isinstance(node, Var):
        return node  # variables unchanged
    elif isinstance(node, Const):
        return Const(-node.value)  # negate constants
    elif isinstance(node, Add):
        return Add(dualize(node.left), dualize(node.right))
    elif isinstance(node, MinGate):
        return MaxGate(dualize(node.left), dualize(node.right))  # min → max
    elif isinstance(node, MaxGate):
        return MinGate(dualize(node.left), dualize(node.right))  # max → min
    raise TypeError(f"Unknown node type: {type(node)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Circuit Measures
# ═══════════════════════════════════════════════════════════════════════

def circuit_size(node: CircuitNode) -> int:
    """
    Count the number of nodes in a circuit.

    Time complexity: O(|C|)

    >>> circuit_size(MinGate(Var(0), Add(Const(3), Var(1))))
    5
    """
    if isinstance(node, (Var, Const)):
        return 1
    elif isinstance(node, (Add, MinGate, MaxGate)):
        return 1 + circuit_size(node.left) + circuit_size(node.right)
    raise TypeError

def circuit_depth(node: CircuitNode) -> int:
    """
    Compute the depth of a circuit (longest root-to-leaf path).

    Time complexity: O(|C|)

    >>> circuit_depth(MinGate(Var(0), Add(Const(3), Var(1))))
    2
    """
    if isinstance(node, (Var, Const)):
        return 0
    elif isinstance(node, (Add, MinGate, MaxGate)):
        return 1 + max(circuit_depth(node.left), circuit_depth(node.right))
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Simulation Transfer
# ═══════════════════════════════════════════════════════════════════════

def simulation_transfer(
    simulator: Callable[[CircuitNode], CircuitNode],
    circuit: CircuitNode
) -> CircuitNode:
    """
    Transfer a simulator from one convention to the other.

    Given a simulator that converts min-plus circuits to equivalent
    max-plus circuits, produce a simulator that converts max-plus
    circuits to equivalent min-plus circuits (or vice versa).

    The algorithm:
      1. Dualize the input circuit (swap conventions).
      2. Apply the original simulator.
      3. Dualize the result back.

    Time complexity: O(|simulator(dualize(C))|)

    This is the computational content of the Simulation Transfer Theorem.

    Args:
        simulator: A function that takes a circuit and returns a
                   semantically equivalent circuit in the other convention.
        circuit: The circuit to simulate.

    Returns:
        A circuit in the original convention that is semantically
        equivalent to the dual of the input.
    """
    # Step 1: Dualize to switch conventions
    dual_input = dualize(circuit)
    # Step 2: Apply the simulator
    simulated = simulator(dual_input)
    # Step 3: Dualize back to original convention
    return dualize(simulated)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Normal Form Extraction
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class AffineForm:
    """
    A tropical affine form: const + Σ coeff[i] * x[i].

    Every min-plus circuit evaluates as the minimum of a family
    of such affine forms (its "normal form").
    """
    coeffs: dict[int, int]  # variable index -> coefficient (natural number)
    const: float

    def evaluate(self, sigma: list[float]) -> float:
        """Evaluate this affine form at sigma."""
        return self.const + sum(
            count * sigma[i] for i, count in self.coeffs.items()
        )

    def __repr__(self):
        terms = [f"{self.const:.2f}"]
        for i, c in sorted(self.coeffs.items()):
            if c == 1:
                terms.append(f"x{i}")
            elif c > 1:
                terms.append(f"{c}·x{i}")
        return " + ".join(terms)


def extract_normal_forms(node: CircuitNode) -> list[AffineForm]:
    """
    Extract the normal-form affine family from a min-plus circuit.

    The circuit evaluates as min{a.evaluate(σ) | a ∈ result}.

    Time complexity: O(|C| · product of branch sizes) in worst case.

    >>> forms = extract_normal_forms(MinGate(Var(0), Add(Const(3), Var(1))))
    >>> len(forms)
    2
    """
    if isinstance(node, Var):
        return [AffineForm({node.index: 1}, 0.0)]
    elif isinstance(node, Const):
        return [AffineForm({}, node.value)]
    elif isinstance(node, MinGate):
        return extract_normal_forms(node.left) + extract_normal_forms(node.right)
    elif isinstance(node, Add):
        left_forms = extract_normal_forms(node.left)
        right_forms = extract_normal_forms(node.right)
        result = []
        for lf, rf in itertools.product(left_forms, right_forms):
            merged = dict(lf.coeffs)
            for i, c in rf.coeffs.items():
                merged[i] = merged.get(i, 0) + c
            result.append(AffineForm(merged, lf.const + rf.const))
        return result
    raise TypeError(f"Cannot extract normal forms from {type(node)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Verification Suite
# ═══════════════════════════════════════════════════════════════════════

def verify_duality(node: CircuitNode, sigma: list[float], tol: float = 1e-12) -> bool:
    """
    Verify the semantic duality identity for a specific circuit and assignment.

    Checks: evaluate(dualize(C), -σ) == -evaluate(C, σ)

    Args:
        node: Circuit to check.
        sigma: Variable assignment.
        tol: Floating-point tolerance.

    Returns:
        True if the identity holds within tolerance.
    """
    val_original = evaluate(node, sigma)
    neg_sigma = [-x for x in sigma]
    val_dual = evaluate(dualize(node), neg_sigma)
    return abs(val_dual - (-val_original)) < tol


def verify_involution(node: CircuitNode) -> bool:
    """Check that dualize(dualize(C)) == C."""
    return dualize(dualize(node)) == node


def verify_size_preservation(node: CircuitNode) -> bool:
    """Check that size(dualize(C)) == size(C)."""
    return circuit_size(dualize(node)) == circuit_size(node)


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Build a min-plus circuit: min(x0, 3 + x1)
    C = MinGate(Var(0), Add(Const(3), Var(1)))
    sigma = [5.0, 2.0]

    print("Circuit:", C)
    print("Assignment:", sigma)
    print("Evaluation:", evaluate(C, sigma))
    print()

    # Dualize
    D = dualize(C)
    print("Dual circuit:", D)
    print("Dual evaluation at -σ:", evaluate(D, [-x for x in sigma]))
    print()

    # Normal forms
    forms = extract_normal_forms(C)
    print("Normal forms:")
    for f in forms:
        print(f"  {f}  →  value = {f.evaluate(sigma)}")
    print(f"  min = {min(f.evaluate(sigma) for f in forms)}")
    print()

    # Verification
    print("Duality verified:", verify_duality(C, sigma))
    print("Involution verified:", verify_involution(C))
    print("Size preserved:", verify_size_preservation(C))
