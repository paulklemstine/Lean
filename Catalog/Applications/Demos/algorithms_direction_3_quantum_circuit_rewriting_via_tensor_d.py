#!/usr/bin/env python3
"""
Quantum Circuit Rewriting — Core Algorithms

This module implements the core algorithms for distributive normalization
of quantum circuit expressions, following the formal theory developed in
the Lean 4 formalization.

Algorithms:
1. Distributive Expansion (expand): O(product of branch factors) time
2. Canonical Normal Form (normalize): expansion + sorting
3. Equivalence Checking (equiv_check): normalize and compare
4. Circuit Depth Analysis: compute circuit depth and monomial count
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass
from enum import Enum, auto
from collections import Counter


# ─── Core Data Types ───

class ExprType(Enum):
    GATE = auto()
    SEQ = auto()
    ADD = auto()
    ONE = auto()


@dataclass(frozen=True)
class QExpr:
    """Quantum tensor expression AST node."""
    type: ExprType
    gate_id: Optional[int] = None
    left: Optional['QExpr'] = None
    right: Optional['QExpr'] = None

    def __repr__(self) -> str:
        if self.type == ExprType.GATE:
            return f"g{self.gate_id}"
        elif self.type == ExprType.SEQ:
            return f"({self.left} ; {self.right})"
        elif self.type == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.type == ExprType.ONE:
            return "I"
        return "?"


def gate(n: int) -> QExpr:
    """Create a gate expression."""
    return QExpr(ExprType.GATE, gate_id=n)

def seq(a: QExpr, b: QExpr) -> QExpr:
    """Create a sequential composition."""
    return QExpr(ExprType.SEQ, left=a, right=b)

def add(a: QExpr, b: QExpr) -> QExpr:
    """Create an addition (superposition)."""
    return QExpr(ExprType.ADD, left=a, right=b)

def one() -> QExpr:
    """Create an identity expression."""
    return QExpr(ExprType.ONE)


# ─── Type Aliases ───

Monomial = Tuple[int, ...]  # Tuple of gate indices
NormalForm = Tuple[Monomial, ...]  # Sorted tuple of monomials


# ─── Algorithm 1: Distributive Expansion ───

def expand(expr: QExpr) -> List[List[int]]:
    """
    Distributive expansion of a quantum expression into sum-of-products form.

    Algorithm:
    - gate(n) → [[n]]
    - one → [[]]
    - add(a, b) → expand(a) ++ expand(b)
    - seq(a, b) → [p ++ q | p ∈ expand(a), q ∈ expand(b)]

    Time complexity: O(|expand(a)| × |expand(b)|) for seq nodes,
    where the product of all branch factors gives the total monomial count.

    Space complexity: O(total monomials × average monomial length)

    This is the core algorithm: it fully distributes sequential composition
    over addition, producing a flat list of monomials.

    >>> expand(gate(0))
    [[0]]
    >>> expand(add(gate(0), gate(1)))
    [[0], [1]]
    >>> expand(seq(add(gate(0), gate(1)), gate(2)))
    [[0, 2], [1, 2]]
    """
    if expr.type == ExprType.GATE:
        return [[expr.gate_id]]
    elif expr.type == ExprType.ONE:
        return [[]]
    elif expr.type == ExprType.ADD:
        return expand(expr.left) + expand(expr.right)
    elif expr.type == ExprType.SEQ:
        result = []
        for p in expand(expr.left):
            for q in expand(expr.right):
                result.append(p + q)
        return result
    else:
        raise ValueError(f"Unknown expression type: {expr.type}")


# ─── Algorithm 2: Canonical Normal Form ───

def normalize(expr: QExpr) -> NormalForm:
    """
    Compute the canonical normal form of a quantum expression.

    The normal form is a sorted tuple of monomials (each a tuple of gate indices).
    Two expressions have the same normal form if and only if they are equivalent
    modulo the distributive rewrite rules plus commutativity of addition.

    Algorithm:
    1. Expand to sum-of-products via distributive expansion.
    2. Convert each monomial to a tuple (immutable, hashable).
    3. Sort lexicographically to obtain a canonical representative.

    Time complexity: O(E log E) where E = number of monomials in expansion
    Space complexity: O(E × L) where L = average monomial length

    >>> normalize(seq(add(gate(1), gate(0)), gate(2)))
    ((0, 2), (1, 2))
    """
    monomials = expand(expr)
    sorted_monos = sorted(tuple(m) for m in monomials)
    return tuple(sorted_monos)


# ─── Algorithm 3: Equivalence Checking ───

def equiv_check(e1: QExpr, e2: QExpr) -> bool:
    """
    Check if two quantum expressions are equivalent under distributive rewriting.

    Two expressions are equivalent if they have the same canonical normal form.
    This is sound: if equiv_check returns True, the expressions have the same
    denotation in every semiring.

    For the converse (completeness relative to the free algebra), two expressions
    with different normal forms are distinguished by the free semiring interpretation.

    Time complexity: O(E1 log E1 + E2 log E2) where Ei = expansion size of ei
    Space complexity: O(max(E1, E2) × L)

    >>> equiv_check(seq(one(), gate(0)), gate(0))
    True
    >>> equiv_check(gate(0), gate(1))
    False
    """
    return normalize(e1) == normalize(e2)


# ─── Algorithm 4: Expression Analysis ───

def expr_depth(expr: QExpr) -> int:
    """
    Compute the depth of a quantum expression tree.

    >>> expr_depth(gate(0))
    0
    >>> expr_depth(seq(gate(0), gate(1)))
    1
    """
    if expr.type in (ExprType.GATE, ExprType.ONE):
        return 0
    return 1 + max(expr_depth(expr.left), expr_depth(expr.right))


def expr_size(expr: QExpr) -> int:
    """
    Compute the number of nodes in a quantum expression tree.

    >>> expr_size(gate(0))
    1
    >>> expr_size(seq(gate(0), gate(1)))
    3
    """
    if expr.type in (ExprType.GATE, ExprType.ONE):
        return 1
    return 1 + expr_size(expr.left) + expr_size(expr.right)


def monomial_count(expr: QExpr) -> int:
    """
    Compute the number of monomials in the expansion without materializing them.

    This is much more efficient than len(expand(expr)) for large expressions.

    Algorithm:
    - gate/one → 1
    - add(a, b) → mc(a) + mc(b)
    - seq(a, b) → mc(a) × mc(b)

    >>> monomial_count(seq(add(gate(0), gate(1)), add(gate(2), gate(3))))
    4
    """
    if expr.type in (ExprType.GATE, ExprType.ONE):
        return 1
    elif expr.type == ExprType.ADD:
        return monomial_count(expr.left) + monomial_count(expr.right)
    elif expr.type == ExprType.SEQ:
        return monomial_count(expr.left) * monomial_count(expr.right)
    return 0


# ─── Algorithm 5: Denotation (Numerical Evaluation) ───

# Standard 2-qubit gate matrices
I2 = np.eye(2, dtype=complex)
H_1q = (1/np.sqrt(2)) * np.array([[1, 1], [1, -1]], dtype=complex)
T_1q = np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]], dtype=complex)
CNOT_mat = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)

GATE_MATRICES = {
    0: np.kron(H_1q, I2),   # H ⊗ I
    1: np.kron(I2, H_1q),   # I ⊗ H
    2: np.kron(T_1q, I2),   # T ⊗ I
    3: np.kron(I2, T_1q),   # I ⊗ T
    4: CNOT_mat,             # CNOT
}


def denote(expr: QExpr, env: Dict[int, np.ndarray] = None) -> np.ndarray:
    """
    Evaluate a quantum expression into a 4×4 complex matrix.

    Uses the standard 2-qubit gate set {H⊗I, I⊗H, T⊗I, I⊗T, CNOT} by default.

    >>> denote(gate(0)).shape
    (4, 4)
    """
    if env is None:
        env = GATE_MATRICES

    if expr.type == ExprType.GATE:
        return env[expr.gate_id].copy()
    elif expr.type == ExprType.SEQ:
        return denote(expr.left, env) @ denote(expr.right, env)
    elif expr.type == ExprType.ADD:
        return denote(expr.left, env) + denote(expr.right, env)
    elif expr.type == ExprType.ONE:
        return np.eye(4, dtype=complex)
    raise ValueError(f"Unknown type: {expr.type}")


def denote_nf(nf: NormalForm, env: Dict[int, np.ndarray] = None) -> np.ndarray:
    """Evaluate a normal form (tuple of monomials) into a matrix."""
    if env is None:
        env = GATE_MATRICES
    result = np.zeros((4, 4), dtype=complex)
    for mono in nf:
        mat = np.eye(4, dtype=complex)
        for g in mono:
            mat = mat @ env[g]
        result += mat
    return result


def verify_soundness(expr: QExpr) -> float:
    """
    Verify expansion soundness for a given expression.
    Returns the maximum absolute difference between original and expanded denotation.

    >>> verify_soundness(seq(add(gate(0), gate(1)), gate(4))) < 1e-10
    True
    """
    mat_orig = denote(expr)
    nf = normalize(expr)
    mat_nf = denote_nf(nf)
    return float(np.max(np.abs(mat_orig - mat_nf)))


# ─── Algorithm 6: Batch Equivalence Classification ───

def classify_circuits(exprs: List[QExpr]) -> Dict[NormalForm, List[int]]:
    """
    Classify a list of circuits by their normal form.

    Returns a dictionary mapping each distinct normal form to the indices
    of expressions that normalize to it.

    Time complexity: O(n × E_max × log E_max) where n = len(exprs)

    >>> exprs = [gate(0), seq(one(), gate(0)), gate(1)]
    >>> classes = classify_circuits(exprs)
    >>> len(classes)
    2
    """
    classes: Dict[NormalForm, List[int]] = {}
    for i, expr in enumerate(exprs):
        nf = normalize(expr)
        if nf not in classes:
            classes[nf] = []
        classes[nf].append(i)
    return classes


# ─── Main: Example Usage ───

if __name__ == "__main__":
    print("Quantum Circuit Rewriting — Algorithm Demonstrations\n")

    # Example 1: Basic expansion
    e = seq(add(gate(0), gate(1)), add(gate(2), gate(3)))
    print(f"Expression: {e}")
    print(f"Monomial count: {monomial_count(e)}")
    print(f"Expansion: {expand(e)}")
    print(f"Normal form: {normalize(e)}")
    print(f"Soundness error: {verify_soundness(e):.2e}")

    # Example 2: Equivalence checking
    e1 = seq(one(), gate(0))
    e2 = gate(0)
    print(f"\nEquiv({e1}, {e2}): {equiv_check(e1, e2)}")

    e3 = seq(add(gate(0), gate(1)), gate(2))
    e4 = add(seq(gate(0), gate(2)), seq(gate(1), gate(2)))
    print(f"Equiv({e3}, {e4}): {equiv_check(e3, e4)}")

    # Example 3: Classification
    exprs = [
        gate(0), seq(one(), gate(0)),
        gate(1), seq(gate(0), one()),
        add(gate(0), gate(1)),
        add(gate(1), gate(0)),
    ]
    classes = classify_circuits(exprs)
    print(f"\nCircuit classification ({len(exprs)} circuits → {len(classes)} classes):")
    for nf, indices in classes.items():
        print(f"  NF {nf}: circuits {indices}")
