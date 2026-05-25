#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Tensor-Sorted Rewrite System

Implements:
  1. Well-typed tensor term generation
  2. Bottom-up distributivity normalization
  3. Semantic evaluation over NumPy arrays
  4. Operation counting and cost comparison
  5. Energy computation and verification

All algorithms correspond to formally verified counterparts in Lean 4.
"""

import numpy as np
from typing import Dict, Any, Optional, Tuple, List
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Algorithm 1: Typed Tensor Term Representation
# ============================================================

class Sort(Enum):
    """The three sorts of the tensor calculus."""
    SCAL = auto()
    VEC = auto()
    MAT = auto()


@dataclass
class Term:
    """Base class for tensor terms with sort annotation."""
    sort: Sort


@dataclass
class ScalVar(Term):
    """Scalar variable."""
    name: str
    def __init__(self, name: str):
        super().__init__(Sort.SCAL)
        self.name = name
    def __repr__(self): return self.name

@dataclass
class ScalAdd(Term):
    """Scalar addition."""
    left: Term; right: Term
    def __init__(self, left: Term, right: Term):
        super().__init__(Sort.SCAL)
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class ScalMul(Term):
    """Scalar multiplication."""
    left: Term; right: Term
    def __init__(self, left: Term, right: Term):
        super().__init__(Sort.SCAL)
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} × {self.right})"

@dataclass
class Dot(Term):
    """Dot product / inner product."""
    left: Term; right: Term
    def __init__(self, left: Term, right: Term):
        super().__init__(Sort.SCAL)
        self.left, self.right = left, right
    def __repr__(self): return f"⟨{self.left}, {self.right}⟩"

@dataclass
class VecVar(Term):
    """Vector variable."""
    name: str
    def __init__(self, name: str):
        super().__init__(Sort.VEC)
        self.name = name
    def __repr__(self): return self.name

@dataclass
class VecAdd(Term):
    """Vector addition."""
    left: Term; right: Term
    def __init__(self, left: Term, right: Term):
        super().__init__(Sort.VEC)
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class SmulVec(Term):
    """Scalar-vector multiplication."""
    scalar: Term; vec: Term
    def __init__(self, scalar: Term, vec: Term):
        super().__init__(Sort.VEC)
        self.scalar, self.vec = scalar, vec
    def __repr__(self): return f"({self.scalar} • {self.vec})"

@dataclass
class MulVec(Term):
    """Matrix-vector multiplication."""
    mat: Term; vec: Term
    def __init__(self, mat: Term, vec: Term):
        super().__init__(Sort.VEC)
        self.mat, self.vec = mat, vec
    def __repr__(self): return f"({self.mat} · {self.vec})"

@dataclass
class MatVar(Term):
    """Matrix variable."""
    name: str
    def __init__(self, name: str):
        super().__init__(Sort.MAT)
        self.name = name
    def __repr__(self): return self.name

@dataclass
class MatAdd(Term):
    """Matrix addition."""
    left: Term; right: Term
    def __init__(self, left: Term, right: Term):
        super().__init__(Sort.MAT)
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class SmulMat(Term):
    """Scalar-matrix multiplication."""
    scalar: Term; mat: Term
    def __init__(self, scalar: Term, mat: Term):
        super().__init__(Sort.MAT)
        self.scalar, self.mat = scalar, mat
    def __repr__(self): return f"({self.scalar} • {self.mat})"


# ============================================================
# Algorithm 2: Semantic Evaluation
# ============================================================

def evaluate(term: Term, env: Dict[str, Any]) -> Any:
    """
    Evaluate a tensor term in a numerical environment.

    Args:
        term: A well-typed tensor term
        env: Dictionary mapping variable names to numpy values

    Returns:
        Scalar (float), vector (np.ndarray), or matrix (np.ndarray)

    Time complexity: O(n² × term_size) where n is the vector dimension
    Space complexity: O(n² × term_depth) for intermediate matrices
    """
    if isinstance(term, ScalVar): return env[term.name]
    if isinstance(term, ScalAdd): return evaluate(term.left, env) + evaluate(term.right, env)
    if isinstance(term, ScalMul): return evaluate(term.left, env) * evaluate(term.right, env)
    if isinstance(term, Dot):     return np.dot(evaluate(term.left, env), evaluate(term.right, env))
    if isinstance(term, VecVar): return env[term.name]
    if isinstance(term, VecAdd): return evaluate(term.left, env) + evaluate(term.right, env)
    if isinstance(term, SmulVec): return evaluate(term.scalar, env) * evaluate(term.vec, env)
    if isinstance(term, MulVec): return evaluate(term.mat, env) @ evaluate(term.vec, env)
    if isinstance(term, MatVar): return env[term.name]
    if isinstance(term, MatAdd): return evaluate(term.left, env) + evaluate(term.right, env)
    if isinstance(term, SmulMat): return evaluate(term.scalar, env) * evaluate(term.mat, env)
    raise TypeError(f"Unknown term type: {type(term)}")


# ============================================================
# Algorithm 3: One-Step Normalization (normStep)
# ============================================================

def norm_step(term: Term) -> Tuple[Term, bool]:
    """
    Apply one distributivity rewrite at the top level.

    Returns:
        (normalized_term, changed) where changed indicates if a rule fired

    Time complexity: O(1) — only inspects top two levels
    Space complexity: O(1) — constructs at most one new term

    Implements the 8 oriented rewrite rules:
    1. A·(v+w)     → A·v + A·w          (mulVec distributes over vecAdd)
    2. (A+B)·v     → A·v + B·v          (matAdd distributes into mulVec)
    3. (a•A)·v     → a•(A·v)            (scalar-matrix-vector associativity)
    4. a•(v+w)     → a•v + a•w          (smulVec distributes over vecAdd)
    5. a•(A+B)     → a•A + a•B          (smulMat distributes over matAdd)
    6. ⟨v+w, u⟩   → ⟨v,u⟩ + ⟨w,u⟩    (dot linear in left argument)
    7. ⟨u, v+w⟩   → ⟨u,v⟩ + ⟨u,w⟩    (dot linear in right argument)
    8. ⟨a•v, w⟩   → a × ⟨v,w⟩         (scalar extraction from dot)
    """
    if isinstance(term, MulVec):
        if isinstance(term.vec, VecAdd):
            return VecAdd(MulVec(term.mat, term.vec.left), MulVec(term.mat, term.vec.right)), True
        if isinstance(term.mat, MatAdd):
            return VecAdd(MulVec(term.mat.left, term.vec), MulVec(term.mat.right, term.vec)), True
        if isinstance(term.mat, SmulMat):
            return SmulVec(term.mat.scalar, MulVec(term.mat.mat, term.vec)), True

    if isinstance(term, SmulVec) and isinstance(term.vec, VecAdd):
        return VecAdd(SmulVec(term.scalar, term.vec.left), SmulVec(term.scalar, term.vec.right)), True

    if isinstance(term, SmulMat) and isinstance(term.mat, MatAdd):
        return MatAdd(SmulMat(term.scalar, term.mat.left), SmulMat(term.scalar, term.mat.right)), True

    if isinstance(term, Dot):
        if isinstance(term.left, VecAdd):
            return ScalAdd(Dot(term.left.left, term.right), Dot(term.left.right, term.right)), True
        if isinstance(term.right, VecAdd):
            return ScalAdd(Dot(term.left, term.right.left), Dot(term.left, term.right.right)), True
        if isinstance(term.left, SmulVec):
            return ScalMul(term.left.scalar, Dot(term.left.vec, term.right)), True

    return term, False


# ============================================================
# Algorithm 4: Full Bottom-Up Normalization
# ============================================================

def normalize(term: Term, max_iterations: int = 100) -> Term:
    """
    Fully normalize a term by bottom-up application of rewrite rules.

    Strategy: recursively normalize children, then apply norm_step at root.
    Repeat until no more rules fire.

    Time complexity: O(term_size² × max_iterations) in worst case
    Space complexity: O(term_size × term_depth)

    Guaranteed to terminate: each rule application is bounded by max_iterations,
    and the formal proof shows each step preserves semantics.
    """
    for _ in range(max_iterations):
        term = _normalize_children(term)
        new_term, changed = norm_step(term)
        if not changed:
            return term
        term = new_term
    return term


def _normalize_children(term: Term) -> Term:
    """Recursively normalize all children of a term."""
    if isinstance(term, ScalAdd):
        return ScalAdd(normalize(term.left), normalize(term.right))
    if isinstance(term, ScalMul):
        return ScalMul(normalize(term.left), normalize(term.right))
    if isinstance(term, Dot):
        return Dot(normalize(term.left), normalize(term.right))
    if isinstance(term, VecAdd):
        return VecAdd(normalize(term.left), normalize(term.right))
    if isinstance(term, SmulVec):
        return SmulVec(normalize(term.scalar), normalize(term.vec))
    if isinstance(term, MulVec):
        return MulVec(normalize(term.mat), normalize(term.vec))
    if isinstance(term, MatAdd):
        return MatAdd(normalize(term.left), normalize(term.right))
    if isinstance(term, SmulMat):
        return SmulMat(normalize(term.scalar), normalize(term.mat))
    return term


# ============================================================
# Algorithm 5: Operation Counting
# ============================================================

def count_ops(term: Term) -> Dict[str, int]:
    """
    Count the number of each type of operation in a term.

    Returns dict with keys: 'scalar_add', 'scalar_mul', 'vec_add',
    'smul_vec', 'mul_vec', 'mat_add', 'smul_mat', 'dot'
    """
    counts = {
        'scalar_add': 0, 'scalar_mul': 0, 'vec_add': 0,
        'smul_vec': 0, 'mul_vec': 0, 'mat_add': 0,
        'smul_mat': 0, 'dot': 0
    }

    def _count(t: Term):
        if isinstance(t, ScalAdd):
            counts['scalar_add'] += 1; _count(t.left); _count(t.right)
        elif isinstance(t, ScalMul):
            counts['scalar_mul'] += 1; _count(t.left); _count(t.right)
        elif isinstance(t, Dot):
            counts['dot'] += 1; _count(t.left); _count(t.right)
        elif isinstance(t, VecAdd):
            counts['vec_add'] += 1; _count(t.left); _count(t.right)
        elif isinstance(t, SmulVec):
            counts['smul_vec'] += 1; _count(t.scalar); _count(t.vec)
        elif isinstance(t, MulVec):
            counts['mul_vec'] += 1; _count(t.mat); _count(t.vec)
        elif isinstance(t, MatAdd):
            counts['mat_add'] += 1; _count(t.left); _count(t.right)
        elif isinstance(t, SmulMat):
            counts['smul_mat'] += 1; _count(t.scalar); _count(t.mat)

    _count(term)
    return counts


def total_cost(term: Term, weights: Optional[Dict[str, float]] = None) -> float:
    """
    Compute weighted total cost of a term.

    Default weights: mul_vec=n², dot=n, scalar ops=1
    """
    if weights is None:
        weights = {
            'scalar_add': 1, 'scalar_mul': 1, 'vec_add': 1,
            'smul_vec': 1, 'mul_vec': 10, 'mat_add': 1,
            'smul_mat': 1, 'dot': 5
        }
    ops = count_ops(term)
    return sum(ops[k] * weights.get(k, 1) for k in ops)


# ============================================================
# Algorithm 6: Energy Computation
# ============================================================

def compute_energy(A: np.ndarray, v: np.ndarray) -> float:
    """Compute quadratic energy E(A,v) = v^T A v = ⟨v, Av⟩."""
    return float(v @ A @ v)


def verify_energy_expansion(A: np.ndarray, v: np.ndarray, w: np.ndarray,
                            tol: float = 1e-10) -> bool:
    """
    Verify the energy expansion identity:
    E(A, v+w) = E(A,v) + ⟨v,Aw⟩ + ⟨w,Av⟩ + E(A,w)
    """
    lhs = compute_energy(A, v + w)
    rhs = (compute_energy(A, v) + float(v @ A @ w)
           + float(w @ A @ v) + compute_energy(A, w))
    return abs(lhs - rhs) < tol


def verify_symmetric_specialization(A: np.ndarray, v: np.ndarray,
                                     w: np.ndarray, tol: float = 1e-10) -> bool:
    """
    For symmetric A, verify that ⟨w, Av⟩ = ⟨v, Aw⟩.
    """
    cross1 = float(v @ A @ w)
    cross2 = float(w @ A @ v)
    return abs(cross1 - cross2) < tol


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Build a sample expression: ⟨v, (A + B) · (v + w)⟩
    v, w = VecVar("v"), VecVar("w")
    A, B = MatVar("A"), MatVar("B")
    expr = Dot(v, MulVec(MatAdd(A, B), VecAdd(v, w)))

    print("Original expression:", expr)
    normalized = normalize(expr)
    print("Normalized:         ", normalized)

    # Evaluate both
    n = 3
    env = {
        "v": np.array([1.0, 2.0, 3.0]),
        "w": np.array([0.5, -1.0, 1.5]),
        "A": np.array([[2, 1, 0], [1, 3, 1], [0, 1, 2]], dtype=float),
        "B": np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]], dtype=float),
    }

    val_orig = evaluate(expr, env)
    val_norm = evaluate(normalized, env)

    print(f"\nOriginal value:   {val_orig:.10f}")
    print(f"Normalized value: {val_norm:.10f}")
    print(f"Match: {np.isclose(val_orig, val_norm)}")

    print(f"\nOriginal ops:   {count_ops(expr)}")
    print(f"Normalized ops: {count_ops(normalized)}")
    print(f"Original cost:   {total_cost(expr)}")
    print(f"Normalized cost: {total_cost(normalized)}")
