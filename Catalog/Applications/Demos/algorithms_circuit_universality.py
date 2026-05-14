#!/usr/bin/env python3
"""
Circuit Universality: Algorithms

Implements the core algorithms from the research paper:
1. DNF synthesis for arbitrary boolean functions
2. Circuit translation (NAND → NOR, NOT+AND, NOT+OR)
3. Affine function detection
4. Gate set universality checking (Post's criterion)
"""

from itertools import product
from typing import Callable, List, Optional, Set, Tuple, Dict
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Circuit Types
# ============================================================

class GateType(Enum):
    INPUT = "input"
    CONST = "const"
    NAND = "nand"
    NOR = "nor"
    NOT = "not"
    AND = "and"
    OR = "or"


@dataclass
class CircuitNode:
    """A node in a boolean circuit."""
    gate: GateType
    value: Optional[bool] = None  # for CONST
    index: Optional[int] = None   # for INPUT
    children: Optional[List['CircuitNode']] = None

    def evaluate(self, inputs: Tuple[bool, ...]) -> bool:
        """Evaluate this circuit node on given inputs."""
        if self.gate == GateType.INPUT:
            return inputs[self.index]
        elif self.gate == GateType.CONST:
            return self.value
        elif self.gate == GateType.NAND:
            a, b = self.children
            return not (a.evaluate(inputs) and b.evaluate(inputs))
        elif self.gate == GateType.NOR:
            a, b = self.children
            return not (a.evaluate(inputs) or b.evaluate(inputs))
        elif self.gate == GateType.NOT:
            return not self.children[0].evaluate(inputs)
        elif self.gate == GateType.AND:
            a, b = self.children
            return a.evaluate(inputs) and b.evaluate(inputs)
        elif self.gate == GateType.OR:
            a, b = self.children
            return a.evaluate(inputs) or b.evaluate(inputs)
        raise ValueError(f"Unknown gate type: {self.gate}")

    @property
    def size(self) -> int:
        if self.children is None:
            return 1
        return 1 + sum(c.size for c in self.children)

    @property
    def depth(self) -> int:
        if self.children is None:
            return 0
        return 1 + max(c.depth for c in self.children)


# ============================================================
# Algorithm 1: DNF Synthesis
# ============================================================

def dnf_synthesize(f: Callable, n: int, gate_type: GateType = GateType.NAND) -> CircuitNode:
    """
    Synthesize a circuit computing f via Disjunctive Normal Form.

    Args:
        f: Boolean function (tuple of bools → bool)
        n: Number of input bits
        gate_type: Base gate type (NAND or NOR)

    Returns:
        CircuitNode computing f using only the specified gate type

    Complexity:
        Time: O(n · 2^n)
        Circuit size: O(n · 2^n)
    """
    # Helper: build NOT from base gate
    def make_not(c: CircuitNode) -> CircuitNode:
        if gate_type == GateType.NAND:
            return CircuitNode(GateType.NAND, children=[c, c])
        else:  # NOR
            return CircuitNode(GateType.NOR, children=[c, c])

    # Helper: build AND from base gate
    def make_and(a: CircuitNode, b: CircuitNode) -> CircuitNode:
        if gate_type == GateType.NAND:
            nand_ab = CircuitNode(GateType.NAND, children=[a, b])
            return make_not(nand_ab)
        else:  # NOR
            return CircuitNode(GateType.NOR, children=[make_not(a), make_not(b)])

    # Helper: build OR from base gate
    def make_or(a: CircuitNode, b: CircuitNode) -> CircuitNode:
        if gate_type == GateType.NAND:
            return CircuitNode(GateType.NAND, children=[make_not(a), make_not(b)])
        else:  # NOR
            nor_ab = CircuitNode(GateType.NOR, children=[a, b])
            return make_not(nor_ab)

    # Find satisfying assignments
    sat = [a for a in product([False, True], repeat=n) if f(a)]

    if not sat:
        return CircuitNode(GateType.CONST, value=False)

    # Build minterms
    minterms = []
    for assignment in sat:
        if n == 0:
            minterms.append(CircuitNode(GateType.CONST, value=True))
            continue
        literals = []
        for i in range(n):
            inp = CircuitNode(GateType.INPUT, index=i)
            lit = inp if assignment[i] else make_not(inp)
            literals.append(lit)
        term = literals[0]
        for lit in literals[1:]:
            term = make_and(term, lit)
        minterms.append(term)

    # OR all minterms
    result = minterms[0]
    for m in minterms[1:]:
        result = make_or(result, m)

    return result


# ============================================================
# Algorithm 2: Circuit Translation
# ============================================================

def translate_nand_to_nor(circuit: CircuitNode) -> CircuitNode:
    """
    Translate a NAND circuit to use only NOR gates.

    NAND(a,b) = NOT(AND(a,b)) = NOT(NOR(NOT(a), NOT(b)))

    Complexity: Size increases by at most 5×.
    """
    if circuit.gate == GateType.INPUT:
        return CircuitNode(GateType.INPUT, index=circuit.index)
    elif circuit.gate == GateType.CONST:
        return CircuitNode(GateType.CONST, value=circuit.value)
    elif circuit.gate == GateType.NAND:
        a = translate_nand_to_nor(circuit.children[0])
        b = translate_nand_to_nor(circuit.children[1])
        # NOT(x) = NOR(x, x)
        not_a = CircuitNode(GateType.NOR, children=[a, a])
        not_b = CircuitNode(GateType.NOR, children=[b, b])
        # AND(a,b) = NOR(NOT(a), NOT(b))
        and_ab = CircuitNode(GateType.NOR, children=[not_a, not_b])
        # NAND(a,b) = NOT(AND(a,b))
        return CircuitNode(GateType.NOR, children=[and_ab, and_ab])
    raise ValueError(f"Unexpected gate: {circuit.gate}")


def translate_nand_to_not_and(circuit: CircuitNode) -> CircuitNode:
    """
    Translate a NAND circuit to use only NOT and AND gates.

    NAND(a,b) = NOT(AND(a,b))

    Complexity: Size increases by at most 2×.
    """
    if circuit.gate == GateType.INPUT:
        return CircuitNode(GateType.INPUT, index=circuit.index)
    elif circuit.gate == GateType.CONST:
        return CircuitNode(GateType.CONST, value=circuit.value)
    elif circuit.gate == GateType.NAND:
        a = translate_nand_to_not_and(circuit.children[0])
        b = translate_nand_to_not_and(circuit.children[1])
        and_ab = CircuitNode(GateType.AND, children=[a, b])
        return CircuitNode(GateType.NOT, children=[and_ab])
    raise ValueError(f"Unexpected gate: {circuit.gate}")


def translate_nand_to_not_or(circuit: CircuitNode) -> CircuitNode:
    """
    Translate a NAND circuit to use only NOT and OR gates.

    NAND(a,b) = NOT(a) OR NOT(b)  (De Morgan)

    Complexity: Size increases by at most 3×.
    """
    if circuit.gate == GateType.INPUT:
        return CircuitNode(GateType.INPUT, index=circuit.index)
    elif circuit.gate == GateType.CONST:
        return CircuitNode(GateType.CONST, value=circuit.value)
    elif circuit.gate == GateType.NAND:
        a = translate_nand_to_not_or(circuit.children[0])
        b = translate_nand_to_not_or(circuit.children[1])
        not_a = CircuitNode(GateType.NOT, children=[a])
        not_b = CircuitNode(GateType.NOT, children=[b])
        return CircuitNode(GateType.OR, children=[not_a, not_b])
    raise ValueError(f"Unexpected gate: {circuit.gate}")


# ============================================================
# Algorithm 3: Affine Function Detection
# ============================================================

def is_affine(f: Callable, n: int) -> Tuple[bool, Optional[Tuple[bool, Tuple[bool, ...]]]]:
    """
    Check if a boolean function is affine over GF(2).

    A function f is affine if f(x) = c ⊕ a₁x₁ ⊕ a₂x₂ ⊕ ... ⊕ aₙxₙ
    for some constant c and coefficients aᵢ.

    Returns:
        (is_affine, (c, coeffs)) where coeffs is the coefficient tuple if affine,
        or (False, None) if not affine.

    Complexity: O(n · 2^n)
    """
    # Determine c from f(0,...,0)
    zero = tuple([False] * n)
    c = f(zero)

    # Determine each coefficient: aᵢ = f(eᵢ) ⊕ c
    coeffs = []
    for i in range(n):
        ei = tuple(j == i for j in range(n))
        coeffs.append(f(ei) ^ c)

    coeffs_tuple = tuple(coeffs)

    # Verify on all inputs
    for assignment in product([False, True], repeat=n):
        expected = c
        for i in range(n):
            if assignment[i] and coeffs[i]:
                expected = not expected
        if f(assignment) != expected:
            return False, None

    return True, (c, coeffs_tuple)


# ============================================================
# Algorithm 4: Post Clone Membership
# ============================================================

def is_zero_preserving(f: Callable, n: int) -> bool:
    """Check if f(0,...,0) = 0."""
    return not f(tuple([False] * n))


def is_one_preserving(f: Callable, n: int) -> bool:
    """Check if f(1,...,1) = 1."""
    return f(tuple([True] * n))


def is_monotone(f: Callable, n: int) -> bool:
    """Check if f is monotone: x ≤ y implies f(x) ≤ f(y)."""
    inputs = list(product([False, True], repeat=n))
    for x in inputs:
        for y in inputs:
            if all(xi <= yi for xi, yi in zip(x, y)):
                if f(x) and not f(y):
                    return False
    return True


def is_self_dual(f: Callable, n: int) -> bool:
    """Check if f(¬x) = ¬f(x) for all x."""
    for assignment in product([False, True], repeat=n):
        neg = tuple(not v for v in assignment)
        if f(neg) != (not f(assignment)):
            return False
    return True


def check_universality(gates: List[Tuple[int, Callable]], max_compose: int = 2) -> Dict[str, bool]:
    """
    Check Post's criterion for universality of a gate set.

    A gate set is universal iff it is NOT contained in any of the five
    maximal clones: zero-preserving, one-preserving, monotone, affine, self-dual.

    Args:
        gates: List of (arity, function) pairs
        max_compose: Not used in direct check (we check the gates directly)

    Returns:
        Dictionary with clone membership and universality status
    """
    results = {
        'all_zero_preserving': True,
        'all_one_preserving': True,
        'all_monotone': True,
        'all_affine': True,
        'all_self_dual': True,
    }

    for arity, f in gates:
        if not is_zero_preserving(f, arity):
            results['all_zero_preserving'] = False
        if not is_one_preserving(f, arity):
            results['all_one_preserving'] = False
        if not is_monotone(f, arity):
            results['all_monotone'] = False
        aff, _ = is_affine(f, arity)
        if not aff:
            results['all_affine'] = False
        if not is_self_dual(f, arity):
            results['all_self_dual'] = False

    # Universal iff escapes all five clones
    results['is_universal'] = not any([
        results['all_zero_preserving'],
        results['all_one_preserving'],
        results['all_monotone'],
        results['all_affine'],
        results['all_self_dual'],
    ])

    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS DEMO")
    print("=" * 60)

    # Test DNF synthesis
    def xor3(inputs):
        return inputs[0] ^ inputs[1] ^ inputs[2]

    circuit = dnf_synthesize(xor3, 3)
    print(f"\nXOR-3 circuit size: {circuit.size}")
    print(f"XOR-3 circuit depth: {circuit.depth}")

    # Verify
    correct = all(
        circuit.evaluate(a) == xor3(a)
        for a in product([False, True], repeat=3)
    )
    print(f"Verified correct: {correct}")

    # Test affine detection
    print("\n--- Affine Detection ---")
    test_functions = [
        ("XOR", 2, lambda x: x[0] ^ x[1]),
        ("AND", 2, lambda x: x[0] and x[1]),
        ("OR", 2, lambda x: x[0] or x[1]),
        ("NAND", 2, lambda x: not (x[0] and x[1])),
        ("CONST-1", 2, lambda x: True),
        ("x0", 2, lambda x: x[0]),
    ]

    for name, n, f in test_functions:
        aff, params = is_affine(f, n)
        status = f"AFFINE (c={int(params[0])}, coeffs={tuple(int(c) for c in params[1])})" if aff else "NOT AFFINE"
        print(f"  {name}: {status}")

    # Test universality checking
    print("\n--- Gate Set Universality ---")
    gate_sets = {
        "{NAND}": [(2, lambda x: not (x[0] and x[1]))],
        "{NOR}": [(2, lambda x: not (x[0] or x[1]))],
        "{AND}": [(2, lambda x: x[0] and x[1])],
        "{OR}": [(2, lambda x: x[0] or x[1])],
        "{XOR}": [(2, lambda x: x[0] ^ x[1])],
        "{NOT, AND}": [(1, lambda x: not x[0]), (2, lambda x: x[0] and x[1])],
        "{NOT, OR}": [(1, lambda x: not x[0]), (2, lambda x: x[0] or x[1])],
        "{AND, OR}": [(2, lambda x: x[0] and x[1]), (2, lambda x: x[0] or x[1])],
    }

    for name, gates in gate_sets.items():
        result = check_universality(gates)
        status = "UNIVERSAL" if result['is_universal'] else "NOT UNIVERSAL"
        reasons = []
        if result['all_zero_preserving']:
            reasons.append("0-preserving")
        if result['all_one_preserving']:
            reasons.append("1-preserving")
        if result['all_monotone']:
            reasons.append("monotone")
        if result['all_affine']:
            reasons.append("affine")
        if result['all_self_dual']:
            reasons.append("self-dual")
        reason_str = f" (trapped in: {', '.join(reasons)})" if reasons else ""
        print(f"  {name}: {status}{reason_str}")
