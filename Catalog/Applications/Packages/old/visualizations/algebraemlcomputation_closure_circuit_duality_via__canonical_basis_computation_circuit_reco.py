#!/usr/bin/env python3
"""
Closure-Circuit Duality: Core Algorithms

Implements the key algorithms from the research paper:
1. Closure computation from implication presentations
2. Canonical basis computation
3. Circuit reconstruction
4. Circuit minimization via basis comparison
"""

from itertools import combinations
from typing import FrozenSet, Dict, List, Tuple, Callable, Set, Optional
from dataclasses import dataclass, field


# =============================================================================
# Data Structures
# =============================================================================

@dataclass(frozen=True)
class ImplicationRule:
    """An implication rule: premises → conclusion."""
    premises: FrozenSet[str]
    conclusion: str

    def __repr__(self):
        p = set(self.premises) if self.premises else "∅"
        return f"{p} → {self.conclusion}"


@dataclass
class ClosurePresentation:
    """A finite presentation of a closure system by implications."""
    universe: FrozenSet[str]
    rules: List[ImplicationRule]

    def __repr__(self):
        return f"Presentation({len(self.rules)} rules on {len(self.universe)} elements)"


@dataclass(frozen=True)
class ResidualGenerator:
    """A residual generator: (target, support)."""
    target: str
    support: FrozenSet[str]

    def __repr__(self):
        s = set(self.support) if self.support else "∅"
        return f"{s} → {self.target}"


@dataclass
class CanonicalBasis:
    """The canonical residual basis of a closure operator."""
    generators: List[ResidualGenerator]

    @property
    def cardinality(self) -> int:
        return len(self.generators)

    def generators_for(self, target: str) -> List[FrozenSet[str]]:
        """Get all minimal supports for a given target."""
        return [g.support for g in self.generators if g.target == target]

    def __repr__(self):
        return f"CanonicalBasis({self.cardinality} generators)"


# =============================================================================
# Algorithm 1: Closure Computation
# =============================================================================

def compute_closure(
    presentation: ClosurePresentation,
    seed: FrozenSet[str]
) -> FrozenSet[str]:
    """Compute the closure of a seed set under a presentation.

    Algorithm: Forward chaining until fixpoint.
    Time complexity: O(|rules| × |universe|) per iteration,
                     O(|universe|) iterations worst case.

    Args:
        presentation: The closure presentation.
        seed: The initial set to close.

    Returns:
        The closure cl_P(seed).
    """
    result = set(seed)
    changed = True
    while changed:
        changed = False
        for rule in presentation.rules:
            if rule.premises <= result and rule.conclusion not in result:
                result.add(rule.conclusion)
                changed = True
    return frozenset(result)


def make_closure_operator(
    presentation: ClosurePresentation
) -> Callable[[FrozenSet[str]], FrozenSet[str]]:
    """Create a closure operator function from a presentation.

    Args:
        presentation: The closure presentation.

    Returns:
        A function cl : FrozenSet[str] → FrozenSet[str].
    """
    return lambda s: compute_closure(presentation, s)


# =============================================================================
# Algorithm 2: Canonical Basis Computation
# =============================================================================

def is_minimal_support(
    cl: Callable[[FrozenSet[str]], FrozenSet[str]],
    target: str,
    support: FrozenSet[str]
) -> bool:
    """Check if `support` is a minimal support for `target` under `cl`.

    Args:
        cl: Closure operator.
        target: Target element.
        support: Candidate support set.

    Returns:
        True if support is minimal (target ∈ cl(support) and no proper
        subset has this property).
    """
    if target not in cl(support):
        return False
    for elem in support:
        reduced = support - {elem}
        if target in cl(reduced):
            return False
    return True


def compute_canonical_basis(
    universe: FrozenSet[str],
    cl: Callable[[FrozenSet[str]], FrozenSet[str]]
) -> CanonicalBasis:
    """Compute the canonical residual basis of a closure operator.

    Algorithm:
        For each target x ∈ universe, enumerate subsets in order of
        increasing size. For each subset A with x ∈ cl(A), check
        minimality. Collect all minimal supports.

    Time complexity: O(|universe| × 2^|universe| × T_cl)
    Space complexity: O(|basis|)

    Args:
        universe: The ground set.
        cl: Closure operator.

    Returns:
        The canonical residual basis.
    """
    generators = []
    elements = sorted(universe)

    for target in elements:
        minimal_supports: List[FrozenSet[str]] = []

        for size in range(len(elements) + 1):
            for combo in combinations(elements, size):
                A = frozenset(combo)

                # Skip if a known minimal support is already a subset
                if any(ms <= A for ms in minimal_supports):
                    continue

                if target in cl(A):
                    if is_minimal_support(cl, target, A):
                        minimal_supports.append(A)

        for support in minimal_supports:
            generators.append(ResidualGenerator(target=target, support=support))

    return CanonicalBasis(generators=generators)


# =============================================================================
# Algorithm 3: Circuit Reconstruction
# =============================================================================

class Circuit:
    """Abstract base for monotone circuits."""
    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        raise NotImplementedError

    def gate_count(self) -> int:
        raise NotImplementedError


class InputCircuit(Circuit):
    def __init__(self, var: str):
        self.var = var

    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        return self.var in inputs

    def gate_count(self) -> int:
        return 1

    def __repr__(self):
        return self.var


class TrueCircuit(Circuit):
    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        return True

    def gate_count(self) -> int:
        return 1

    def __repr__(self):
        return "⊤"


class FalseCircuit(Circuit):
    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        return False

    def gate_count(self) -> int:
        return 1

    def __repr__(self):
        return "⊥"


class AndCircuit(Circuit):
    def __init__(self, children: List[Circuit]):
        self.children = children

    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        return all(c.evaluate(inputs) for c in self.children)

    def gate_count(self) -> int:
        return 1 + sum(c.gate_count() for c in self.children)

    def __repr__(self):
        return f"({' ∧ '.join(repr(c) for c in self.children)})"


class OrCircuit(Circuit):
    def __init__(self, children: List[Circuit]):
        self.children = children

    def evaluate(self, inputs: FrozenSet[str]) -> bool:
        return any(c.evaluate(inputs) for c in self.children)

    def gate_count(self) -> int:
        return 1 + sum(c.gate_count() for c in self.children)

    def __repr__(self):
        return f"({' ∨ '.join(repr(c) for c in self.children)})"


@dataclass
class ClosureCircuit:
    """A closure circuit: one monotone circuit per output element."""
    outputs: Dict[str, Circuit]

    def evaluate(self, target: str, inputs: FrozenSet[str]) -> bool:
        """Evaluate whether target ∈ cl(inputs)."""
        return self.outputs[target].evaluate(inputs)

    def total_gate_count(self) -> int:
        """Total number of gates across all output circuits."""
        return sum(c.gate_count() for c in self.outputs.values())


def reconstruct_circuit(basis: CanonicalBasis, universe: FrozenSet[str]) -> ClosureCircuit:
    """Reconstruct a closure circuit from the canonical basis.

    For each target x, builds the DNF circuit:
        C(x) = OR( AND(input(a) for a in A) for A in minSupp(x) )

    Args:
        basis: The canonical residual basis.
        universe: The ground set.

    Returns:
        A closure circuit correctly computing the closure.
    """
    outputs: Dict[str, Circuit] = {}

    for target in sorted(universe):
        supports = basis.generators_for(target)

        if not supports:
            outputs[target] = FalseCircuit()
        else:
            conjuncts = []
            for support in supports:
                if not support:
                    conjuncts.append(TrueCircuit())
                else:
                    conjuncts.append(
                        AndCircuit([InputCircuit(a) for a in sorted(support)])
                    )
            if len(conjuncts) == 1:
                outputs[target] = conjuncts[0]
            else:
                outputs[target] = OrCircuit(conjuncts)

    return ClosureCircuit(outputs=outputs)


# =============================================================================
# Algorithm 4: Verification
# =============================================================================

def verify_circuit_correctness(
    circuit: ClosureCircuit,
    cl: Callable[[FrozenSet[str]], FrozenSet[str]],
    universe: FrozenSet[str]
) -> Tuple[bool, Optional[Tuple[str, FrozenSet[str]]]]:
    """Verify that a circuit correctly computes a closure operator.

    Tests all 2^|universe| subsets.

    Args:
        circuit: The closure circuit.
        cl: The closure operator.
        universe: The ground set.

    Returns:
        (True, None) if correct, (False, (target, counterexample_set)) otherwise.
    """
    elements = sorted(universe)
    n = len(elements)

    for mask in range(2 ** n):
        S = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        closure_S = cl(S)

        for target in elements:
            circuit_result = circuit.evaluate(target, S)
            closure_result = target in closure_S

            if circuit_result != closure_result:
                return False, (target, S)

    return True, None


def verify_basis_uniqueness(
    basis: CanonicalBasis,
    cl: Callable[[FrozenSet[str]], FrozenSet[str]],
    universe: FrozenSet[str]
) -> bool:
    """Verify that the basis is irredundant: removing any generator
    breaks the characterization property.

    Args:
        basis: The canonical basis.
        cl: The closure operator.
        universe: The ground set.

    Returns:
        True if every generator is essential.
    """
    elements = sorted(universe)
    n = len(elements)

    for i, gen in enumerate(basis.generators):
        # Create modified basis without generator i
        modified = [g for j, g in enumerate(basis.generators) if j != i]
        modified_dict: Dict[str, List[FrozenSet[str]]] = {}
        for g in modified:
            modified_dict.setdefault(g.target, []).append(g.support)

        # Check if characterization still holds
        for mask in range(2 ** n):
            S = frozenset(elements[j] for j in range(n) if mask & (1 << j))
            closure_S = cl(S)

            for target in elements:
                in_closure = target in closure_S
                has_support = any(
                    A <= S for A in modified_dict.get(target, [])
                )
                if in_closure != has_support:
                    # Found a counterexample: this generator is essential
                    break
            else:
                continue
            break
        else:
            # No counterexample found: generator was redundant
            return False

    return True


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Example: database functional dependencies
    universe = frozenset({'A', 'B', 'C', 'D', 'E'})
    presentation = ClosurePresentation(
        universe=universe,
        rules=[
            ImplicationRule(frozenset({'A', 'B'}), 'C'),
            ImplicationRule(frozenset({'C'}), 'D'),
            ImplicationRule(frozenset({'D'}), 'E'),
            ImplicationRule(frozenset({'B'}), 'E'),
        ]
    )

    cl = make_closure_operator(presentation)
    print(f"Presentation: {presentation}")
    print(f"cl({{A,B}}) = {set(cl(frozenset({'A', 'B'})))}")
    print(f"cl({{B}}) = {set(cl(frozenset({'B'})))}")
    print()

    # Compute canonical basis
    basis = compute_canonical_basis(universe, cl)
    print(f"Canonical basis ({basis.cardinality} generators):")
    for gen in basis.generators:
        print(f"  {gen}")
    print()

    # Reconstruct circuit
    circuit = reconstruct_circuit(basis, universe)
    print(f"Total circuit gate count: {circuit.total_gate_count()}")
    for target in sorted(universe):
        print(f"  C({target}) = {circuit.outputs[target]}")
    print()

    # Verify correctness
    correct, counterexample = verify_circuit_correctness(circuit, cl, universe)
    print(f"Circuit correctness: {correct}")

    # Verify irredundancy
    irredundant = verify_basis_uniqueness(basis, cl, universe)
    print(f"Basis irredundancy: {irredundant}")
