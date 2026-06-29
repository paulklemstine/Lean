"""
Quantum Tensor Rewriting: Core Algorithms

Implements the verified normalization algorithm for quantum circuit expressions
using distributive tensor rewriting. This module provides:

1. QuantumTensorExpr - AST for quantum circuit expressions
2. normalize() - Canonical normalization via distributive expansion
3. denote() - Denotational semantics via symbolic matrix evaluation
4. polyInterp() - Polynomial interpretation (termination measure)

All algorithms correspond to formally verified Lean 4 implementations.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable, Any
from enum import Enum
import numpy as np


class QGate(Enum):
    """Gate set for 2-qubit quantum circuits."""
    H = "H"        # Hadamard gate
    T = "T"        # T gate (π/8 phase)
    CNOT = "CNOT"  # Controlled-NOT


# --- AST for Quantum Tensor Expressions ---

class QuantumTensorExpr:
    """Base class for quantum tensor expressions."""
    pass


@dataclass(frozen=True)
class Gate(QuantumTensorExpr):
    """A primitive quantum gate."""
    gate: QGate
    def __repr__(self) -> str:
        return self.gate.value


@dataclass(frozen=True)
class Ident(QuantumTensorExpr):
    """The identity gate."""
    def __repr__(self) -> str:
        return "I"


@dataclass(frozen=True)
class Seq(QuantumTensorExpr):
    """Sequential composition (matrix product)."""
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self) -> str:
        return f"({self.left} ; {self.right})"


@dataclass(frozen=True)
class Par(QuantumTensorExpr):
    """Parallel composition (tensor product)."""
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self) -> str:
        return f"({self.left} ⊗ {self.right})"


@dataclass(frozen=True)
class Add(QuantumTensorExpr):
    """Formal sum (distributive expansion node)."""
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self) -> str:
        return f"({self.left} + {self.right})"


# --- Polynomial Interpretation (Termination Measure) ---

def poly_interp(e: QuantumTensorExpr) -> int:
    """
    Polynomial interpretation: the termination measure.
    
    - Atoms map to 2
    - seq/par map to multiplication  
    - add maps to a + b + 1 (penalized addition)
    
    Key property: distributing multiplication over penalized addition
    strictly decreases this measure, proving termination.
    
    Time complexity: O(n) where n is the number of AST nodes.
    Space complexity: O(d) where d is the depth of the expression tree.
    """
    if isinstance(e, (Gate, Ident)):
        return 2
    elif isinstance(e, Seq):
        return poly_interp(e.left) * poly_interp(e.right)
    elif isinstance(e, Par):
        return poly_interp(e.left) * poly_interp(e.right)
    elif isinstance(e, Add):
        return poly_interp(e.left) + poly_interp(e.right) + 1
    raise TypeError(f"Unknown expression type: {type(e)}")


# --- Normalization Algorithm ---

def norm_step(e: QuantumTensorExpr) -> QuantumTensorExpr:
    """
    One-step top-level normalization: apply the first applicable
    distributivity rule at the root.
    
    Rules:
    - par (add a b) c  →  add (par a c) (par b c)    [left-distributivity of ⊗]
    - par a (add b c)  →  add (par a b) (par a c)    [right-distributivity of ⊗]
    - seq a (add b c)  →  add (seq a b) (seq a c)    [right-distributivity of ;]
    
    Returns the input unchanged if no rule applies.
    
    Time complexity: O(1) per call.
    """
    if isinstance(e, Par) and isinstance(e.left, Add):
        a, b, c = e.left.left, e.left.right, e.right
        return Add(Par(a, c), Par(b, c))
    elif isinstance(e, Par) and isinstance(e.right, Add):
        a, b, c = e.left, e.right.left, e.right.right
        return Add(Par(a, b), Par(a, c))
    elif isinstance(e, Seq) and isinstance(e.right, Add):
        a, b, c = e.left, e.right.left, e.right.right
        return Add(Seq(a, b), Seq(a, c))
    return e


def norm_step_deep(e: QuantumTensorExpr) -> QuantumTensorExpr:
    """
    Deep normalization: recursively normalize children, then apply
    norm_step at the root. This is a single bottom-up pass.
    
    Time complexity: O(n) per call where n is the number of AST nodes.
    Space complexity: O(d) where d is the depth.
    """
    if isinstance(e, (Gate, Ident)):
        return e
    elif isinstance(e, Seq):
        return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    elif isinstance(e, Par):
        return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    elif isinstance(e, Add):
        return Add(norm_step_deep(e.left), norm_step_deep(e.right))
    raise TypeError(f"Unknown expression type: {type(e)}")


def normalize(e: QuantumTensorExpr, max_iters: int = None) -> QuantumTensorExpr:
    """
    Full normalization by iterating norm_step_deep until convergence.
    
    Guaranteed to terminate because each productive step strictly
    decreases the polynomial interpretation (formally verified).
    
    Args:
        e: Expression to normalize
        max_iters: Maximum iterations (default: poly_interp(e))
    
    Returns:
        The canonical normal form of e.
    
    Time complexity: O(n * k) where n = AST size, k = number of iterations.
        k is bounded by poly_interp(e), which is at most exponential in n.
        In practice, k is usually small (linear in the number of add nodes).
    """
    if max_iters is None:
        max_iters = poly_interp(e)
    
    for _ in range(max_iters):
        e_new = norm_step_deep(e)
        if e_new == e:
            return e
        e = e_new
    return e


# --- Size and Complexity ---

def expr_size(e: QuantumTensorExpr) -> int:
    """Number of nodes in the expression tree."""
    if isinstance(e, (Gate, Ident)):
        return 1
    elif isinstance(e, (Seq, Par, Add)):
        return 1 + expr_size(e.left) + expr_size(e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


def count_add_nodes(e: QuantumTensorExpr) -> int:
    """Count the number of Add nodes in the expression."""
    if isinstance(e, (Gate, Ident)):
        return 0
    elif isinstance(e, Add):
        return 1 + count_add_nodes(e.left) + count_add_nodes(e.right)
    elif isinstance(e, (Seq, Par)):
        return count_add_nodes(e.left) + count_add_nodes(e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


def is_normal_form(e: QuantumTensorExpr) -> bool:
    """
    Check if an expression is in normal form:
    no Add node appears as a direct child of Par or Seq.
    """
    if isinstance(e, (Gate, Ident)):
        return True
    elif isinstance(e, Seq):
        if isinstance(e.right, Add):
            return False
        return is_normal_form(e.left) and is_normal_form(e.right)
    elif isinstance(e, Par):
        if isinstance(e.left, Add) or isinstance(e.right, Add):
            return False
        return is_normal_form(e.left) and is_normal_form(e.right)
    elif isinstance(e, Add):
        return is_normal_form(e.left) and is_normal_form(e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


# --- Denotational Semantics ---

# Concrete 2x2 gate matrices
H_MATRIX = np.array([[1, 1], [1, -1]], dtype=complex) / np.sqrt(2)
T_MATRIX = np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]], dtype=complex)
I_MATRIX = np.eye(2, dtype=complex)
CNOT_MATRIX = np.array([
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 0, 1],
    [0, 0, 1, 0]
], dtype=complex)

GATE_MATRICES = {
    QGate.H: H_MATRIX,
    QGate.T: T_MATRIX,
    QGate.CNOT: CNOT_MATRIX,
}


def denote_matrix(e: QuantumTensorExpr) -> np.ndarray:
    """
    Denotational semantics: evaluate an expression as a complex matrix.
    
    - gate g  →  gate matrix
    - ident   →  identity matrix
    - seq a b →  matrix product (a @ b)
    - par a b →  Kronecker product (a ⊗ b)
    - add a b →  matrix sum (a + b)
    
    Returns a complex numpy matrix.
    """
    if isinstance(e, Gate):
        return GATE_MATRICES[e.gate].copy()
    elif isinstance(e, Ident):
        return I_MATRIX.copy()
    elif isinstance(e, Seq):
        return denote_matrix(e.left) @ denote_matrix(e.right)
    elif isinstance(e, Par):
        return np.kron(denote_matrix(e.left), denote_matrix(e.right))
    elif isinstance(e, Add):
        return denote_matrix(e.left) + denote_matrix(e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


def matrices_equal(m1: np.ndarray, m2: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if two matrices are approximately equal."""
    return np.allclose(m1, m2, atol=tol)


# --- Circuit Generation ---

def generate_circuits(depth: int, gates: list[QGate] = None) -> list[QuantumTensorExpr]:
    """
    Generate all circuit expressions up to a given depth over a gate set.
    
    Args:
        depth: Maximum depth of the expression tree
        gates: Gate set to use (default: {H, T, CNOT})
    
    Returns:
        List of all expressions up to the given depth.
    """
    if gates is None:
        gates = [QGate.H, QGate.T, QGate.CNOT]
    
    if depth <= 0:
        return []
    
    # Base expressions
    base = [Gate(g) for g in gates] + [Ident()]
    
    if depth == 1:
        return base
    
    # Recursive: build from smaller expressions
    smaller = generate_circuits(depth - 1, gates)
    result = list(base)  # depth-1 expressions are included
    
    for a in smaller:
        for b in smaller:
            result.append(Seq(a, b))
            result.append(Par(a, b))
            result.append(Add(a, b))
    
    return result


def collect_summands(e: QuantumTensorExpr) -> list[QuantumTensorExpr]:
    """Flatten an Add-tree into a list of summands."""
    if isinstance(e, Add):
        return collect_summands(e.left) + collect_summands(e.right)
    return [e]


def summands_match_as_multisets(e1: QuantumTensorExpr, e2: QuantumTensorExpr) -> bool:
    """Check if two expressions have the same summands as multisets."""
    s1 = sorted(str(x) for x in collect_summands(e1))
    s2 = sorted(str(x) for x in collect_summands(e2))
    return s1 == s2


if __name__ == "__main__":
    # Example usage
    H = Gate(QGate.H)
    T = Gate(QGate.T)
    CNOT = Gate(QGate.CNOT)
    I = Ident()
    
    # A circuit with superposition: H ⊗ (T + H)
    expr = Par(H, Add(T, H))
    print(f"Expression: {expr}")
    print(f"Poly interp: {poly_interp(expr)}")
    print(f"Is normal form: {is_normal_form(expr)}")
    
    nf = normalize(expr)
    print(f"Normal form: {nf}")
    print(f"Is normal form: {is_normal_form(nf)}")
    
    # Verify semantics preservation
    m_orig = denote_matrix(expr)
    m_norm = denote_matrix(nf)
    print(f"Semantics preserved: {matrices_equal(m_orig, m_norm)}")
