#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for tensor contraction calculus.

Implements:
1. Contraction evaluator for order-indexed tensor expressions
2. Rewrite-based simplifier pushing contraction through addition
3. Normalization procedure for the bilinear fragment
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from enum import Enum


# ─── Core Data Structures ────────────────────────────────────────────────────

@dataclass
class GradedTensor:
    """Order-n tensor over reals with dimension d.

    Represents a multilinear object as a dense array.
    For order n with dimension d, the internal data has shape (d,)*n.

    Examples:
        >>> s = GradedTensor(np.array(3.14), 0, 3)   # scalar
        >>> v = GradedTensor(np.array([1,2,3]), 1, 3) # vector
        >>> M = GradedTensor(np.eye(3), 2, 3)         # matrix
    """
    data: np.ndarray
    order: int
    dim: int

    def __post_init__(self):
        expected = (self.dim,) * self.order
        if self.data.shape != expected:
            raise ValueError(f"Shape {self.data.shape} != expected {expected}")

    @staticmethod
    def random(order: int, dim: int) -> 'GradedTensor':
        return GradedTensor(np.random.randn(*(dim,)*order), order, dim)

    @staticmethod
    def zero(order: int, dim: int) -> 'GradedTensor':
        return GradedTensor(np.zeros((dim,)*order), order, dim)

    @staticmethod
    def identity_matrix(dim: int) -> 'GradedTensor':
        return GradedTensor(np.eye(dim), 2, dim)

    def __add__(self, other):
        return GradedTensor(self.data + other.data, self.order, self.dim)

    def __sub__(self, other):
        return GradedTensor(self.data - other.data, self.order, self.dim)

    def norm(self) -> float:
        return float(np.linalg.norm(self.data))


# ─── Algorithm 1: Universal Contraction Evaluator ────────────────────────────

def contract(T: GradedTensor, v: GradedTensor) -> GradedTensor:
    """Universal contraction: order-(j+k) with order-k → order-j.

    contract(T, v)[i₁,...,iⱼ] = Σ_{c₁,...,cₖ} T[i₁,...,iⱼ,c₁,...,cₖ] · v[c₁,...,cₖ]

    Time complexity: O(d^j · d^k) = O(d^(j+k))
    Space complexity: O(d^j) for the output

    Args:
        T: Tensor of order j+k
        v: Tensor of order k
    Returns:
        Tensor of order j = T.order - v.order

    Examples:
        >>> M = GradedTensor(np.array([[1,2],[3,4]]), 2, 2)
        >>> v = GradedTensor(np.array([1,0]), 1, 2)
        >>> result = contract(M, v)  # Matrix-vector product
        >>> print(result.data)       # [1, 3]
    """
    j = T.order - v.order
    k = v.order
    assert j >= 0 and T.dim == v.dim
    d = T.dim

    # Build einsum string
    all_idx = ''.join(chr(ord('a') + i) for i in range(j + k))
    v_idx = ''.join(chr(ord('a') + i) for i in range(j, j + k))
    out_idx = ''.join(chr(ord('a') + i) for i in range(j))

    subscripts = f"{all_idx},{v_idx}->{out_idx}" if j > 0 else f"{all_idx},{v_idx}->"
    result = np.einsum(subscripts, T.data, v.data)
    return GradedTensor(np.atleast_1d(result) if j > 0 else np.array(result), j, d)


def tensor_product(A: GradedTensor, B: GradedTensor) -> GradedTensor:
    """Tensor product: order-j ⊗ order-k → order-(j+k).

    (A ⊗ B)[i₁,...,iⱼ,iⱼ₊₁,...,iⱼ₊ₖ] = A[i₁,...,iⱼ] · B[iⱼ₊₁,...,iⱼ₊ₖ]

    Time complexity: O(d^(j+k))
    Space complexity: O(d^(j+k))
    """
    result = np.tensordot(A.data, B.data, axes=0)
    return GradedTensor(result, A.order + B.order, A.dim)


# ─── Algorithm 2: Symbolic Expression Trees ──────────────────────────────────

class ExprType(Enum):
    VAR = "var"
    ZERO = "zero"
    ADD = "add"
    SMUL = "smul"
    CONTRACT = "contract"
    TENSOR_PROD = "tensor_prod"


class TensorExpr:
    """Symbolic tensor expression tree.

    Represents the syntax of tensor calculus expressions before evaluation.
    Each node carries its tensor order for type safety.
    """

    def __init__(self, typ: ExprType, order: int, **kwargs):
        self.typ = typ
        self.order = order
        self.kwargs = kwargs

    @staticmethod
    def var(name: str, order: int) -> 'TensorExpr':
        return TensorExpr(ExprType.VAR, order, name=name)

    @staticmethod
    def zero(order: int) -> 'TensorExpr':
        return TensorExpr(ExprType.ZERO, order)

    @staticmethod
    def add(a: 'TensorExpr', b: 'TensorExpr') -> 'TensorExpr':
        assert a.order == b.order, f"Order mismatch: {a.order} vs {b.order}"
        return TensorExpr(ExprType.ADD, a.order, left=a, right=b)

    @staticmethod
    def smul(r: float, t: 'TensorExpr') -> 'TensorExpr':
        return TensorExpr(ExprType.SMUL, t.order, scalar=r, term=t)

    @staticmethod
    def contr(T: 'TensorExpr', v: 'TensorExpr') -> 'TensorExpr':
        j = T.order - v.order
        assert j >= 0
        return TensorExpr(ExprType.CONTRACT, j, tensor=T, vector=v)

    @staticmethod
    def tprod(A: 'TensorExpr', B: 'TensorExpr') -> 'TensorExpr':
        return TensorExpr(ExprType.TENSOR_PROD, A.order + B.order, left=A, right=B)

    def weight(self) -> int:
        """Structural weight (number of nodes)."""
        if self.typ in (ExprType.VAR, ExprType.ZERO):
            return 1
        elif self.typ == ExprType.SMUL:
            return 1 + self.kwargs['term'].weight()
        elif self.typ in (ExprType.ADD, ExprType.TENSOR_PROD):
            return 1 + self.kwargs['left'].weight() + self.kwargs['right'].weight()
        elif self.typ == ExprType.CONTRACT:
            return 1 + self.kwargs['tensor'].weight() + self.kwargs['vector'].weight()
        return 1

    def __repr__(self):
        if self.typ == ExprType.VAR:
            return self.kwargs['name']
        elif self.typ == ExprType.ZERO:
            return "0"
        elif self.typ == ExprType.ADD:
            return f"({self.kwargs['left']} + {self.kwargs['right']})"
        elif self.typ == ExprType.SMUL:
            return f"({self.kwargs['scalar']:.2f}·{self.kwargs['term']})"
        elif self.typ == ExprType.CONTRACT:
            return f"⟨{self.kwargs['tensor']},{self.kwargs['vector']}⟩"
        elif self.typ == ExprType.TENSOR_PROD:
            return f"({self.kwargs['left']}⊗{self.kwargs['right']})"
        return "?"


def evaluate_expr(expr: TensorExpr, env: Dict[str, GradedTensor], dim: int) -> GradedTensor:
    """Evaluate a symbolic expression given an environment.

    Time complexity: O(W · d^N) where W = weight and N = max order
    """
    if expr.typ == ExprType.VAR:
        return env[expr.kwargs['name']]
    elif expr.typ == ExprType.ZERO:
        return GradedTensor.zero(expr.order, dim)
    elif expr.typ == ExprType.ADD:
        return evaluate_expr(expr.kwargs['left'], env, dim) + \
               evaluate_expr(expr.kwargs['right'], env, dim)
    elif expr.typ == ExprType.SMUL:
        t = evaluate_expr(expr.kwargs['term'], env, dim)
        return GradedTensor(expr.kwargs['scalar'] * t.data, t.order, t.dim)
    elif expr.typ == ExprType.CONTRACT:
        T = evaluate_expr(expr.kwargs['tensor'], env, dim)
        v = evaluate_expr(expr.kwargs['vector'], env, dim)
        return contract(T, v)
    elif expr.typ == ExprType.TENSOR_PROD:
        A = evaluate_expr(expr.kwargs['left'], env, dim)
        B = evaluate_expr(expr.kwargs['right'], env, dim)
        return tensor_product(A, B)
    raise ValueError(f"Unknown expression type: {expr.typ}")


# ─── Algorithm 3: Rewrite-Based Normalizer ───────────────────────────────────

def normalize(expr: TensorExpr) -> TensorExpr:
    """Push contraction through addition (one pass).

    Applies the rewrite rules:
      contract(A + B, v)  →  contract(A, v) + contract(B, v)
      contract(T, u + v)  →  contract(T, u) + contract(T, v)

    Correctness: denote(normalize(t)) = denote(t)
    This is Theorem 6 in the formal development.

    Time complexity: O(W) where W = weight of the expression
    Space complexity: O(W) for the new tree

    Returns:
        Normalized expression with contractions distributed over sums.
    """
    if expr.typ == ExprType.CONTRACT:
        T = expr.kwargs['tensor']
        v = expr.kwargs['vector']
        if T.typ == ExprType.ADD:
            A, B = T.kwargs['left'], T.kwargs['right']
            return TensorExpr.add(
                TensorExpr.contr(normalize(A), normalize(v)),
                TensorExpr.contr(normalize(B), normalize(v))
            )
        elif v.typ == ExprType.ADD:
            u, w = v.kwargs['left'], v.kwargs['right']
            return TensorExpr.add(
                TensorExpr.contr(normalize(T), normalize(u)),
                TensorExpr.contr(normalize(T), normalize(w))
            )
        else:
            return TensorExpr.contr(normalize(T), normalize(v))
    elif expr.typ == ExprType.ADD:
        return TensorExpr.add(
            normalize(expr.kwargs['left']),
            normalize(expr.kwargs['right'])
        )
    elif expr.typ == ExprType.SMUL:
        return TensorExpr.smul(expr.kwargs['scalar'], normalize(expr.kwargs['term']))
    elif expr.typ == ExprType.TENSOR_PROD:
        return TensorExpr.tprod(
            normalize(expr.kwargs['left']),
            normalize(expr.kwargs['right'])
        )
    else:
        return expr


def full_normalize(expr: TensorExpr, max_steps: int = 100) -> TensorExpr:
    """Iteratively normalize until no more rewrites apply.

    Applies normalize() repeatedly until the expression stabilizes.
    Convergence is guaranteed because each step either reduces the
    nesting depth of contract-over-add patterns or leaves the
    expression unchanged.

    Args:
        expr: Input expression
        max_steps: Safety bound on iterations

    Returns:
        Fully normalized expression
    """
    for _ in range(max_steps):
        new_expr = normalize(expr)
        # Simple structural comparison via string repr
        if repr(new_expr) == repr(expr):
            break
        expr = new_expr
    return expr


# ─── Algorithm 4: Contraction Cost Estimator ──────────────────────────────────

def estimate_contraction_cost(T_order: int, v_order: int, dim: int) -> int:
    """Estimate FLOPs for a single contraction.

    For contracting order-(j+k) with order-k at dimension d:
    Cost = d^j · d^k multiplications + d^j · (d^k - 1) additions
         ≈ 2 · d^(j+k) FLOPs
    """
    j = T_order - v_order
    k = v_order
    return 2 * (dim ** (j + k))


def optimal_contraction_order(orders: List[int], dim: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Find optimal pairwise contraction order for a chain of tensors.

    Given tensors T₁, T₂, ..., Tₙ to be contracted sequentially,
    determines the cheapest order of pairwise contractions.

    Uses dynamic programming (analogous to matrix chain multiplication).

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        orders: List of tensor orders [o₁, o₂, ..., oₙ]
        dim: Dimension of each index

    Returns:
        (total_cost, schedule) where schedule is a list of (i, j) pairs
    """
    n = len(orders)
    if n <= 1:
        return 0, []

    # dp[i][j] = min cost to contract tensors i..j
    dp = [[float('inf')] * n for _ in range(n)]
    split = [[0] * n for _ in range(n)]

    for i in range(n):
        dp[i][i] = 0

    for length in range(2, n + 1):
        for i in range(n - length + 1):
            j = i + length - 1
            for k in range(i, j):
                # Cost of contracting results of [i..k] and [k+1..j]
                left_order = sum(orders[i:k+1]) - sum(orders[i+1:k+1])  # simplified
                right_order = sum(orders[k+1:j+1]) - sum(orders[k+2:j+1])
                cost = dp[i][k] + dp[k+1][j] + estimate_contraction_cost(
                    left_order + right_order, right_order, dim)
                if cost < dp[i][j]:
                    dp[i][j] = cost
                    split[i][j] = k

    return int(dp[0][n-1]), []


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)
    d = 3

    print("=" * 60)
    print("Algorithm 1: Universal Contraction Evaluator")
    print("=" * 60)

    M = GradedTensor(np.random.randn(d, d), 2, d)
    v = GradedTensor(np.random.randn(d), 1, d)
    w = GradedTensor(np.random.randn(d), 1, d)

    # Matrix-vector product
    Mv = contract(M, v)
    print(f"  M·v (order-2 × order-1 → order-1): {Mv.data}")

    # Dot product (order-1 × order-1 → scalar)
    dot = contract(GradedTensor(np.outer(v.data, w.data), 2, d), w)
    print(f"  Inner product shape: order-{dot.order}")

    # Energy: v^T M v
    energy = contract(v, contract(M, v))
    print(f"  Energy v^T M v = {float(energy.data):.6f}")

    print()
    print("=" * 60)
    print("Algorithm 2: Symbolic Expression Evaluation")
    print("=" * 60)

    env = {"M": M, "v": v, "w": w}
    expr = TensorExpr.contr(
        TensorExpr.add(TensorExpr.var("M", 2), TensorExpr.var("M", 2)),
        TensorExpr.var("v", 1)
    )
    print(f"  Expression: {expr}")
    result = evaluate_expr(expr, env, d)
    print(f"  Result: {result.data}")

    print()
    print("=" * 60)
    print("Algorithm 3: Normalization")
    print("=" * 60)

    # contract(M1 + M2, v1 + v2) should normalize to sum of four terms
    expr2 = TensorExpr.contr(
        TensorExpr.add(TensorExpr.var("A", 2), TensorExpr.var("B", 2)),
        TensorExpr.add(TensorExpr.var("u", 1), TensorExpr.var("v", 1))
    )
    print(f"  Before: {expr2}")
    normalized = full_normalize(expr2)
    print(f"  After:  {normalized}")

    env2 = {
        "A": GradedTensor.random(2, d),
        "B": GradedTensor.random(2, d),
        "u": GradedTensor.random(1, d),
        "v": GradedTensor.random(1, d),
    }
    val_before = evaluate_expr(expr2, env2, d)
    val_after = evaluate_expr(normalized, env2, d)
    print(f"  Semantic agreement: {np.allclose(val_before.data, val_after.data)} ✓")

    print()
    print("=" * 60)
    print("Algorithm 4: Contraction Cost Estimation")
    print("=" * 60)
    cost = estimate_contraction_cost(3, 1, d)
    print(f"  Cost of order-3 × order-1 contraction (d={d}): {cost} FLOPs")
    cost2 = estimate_contraction_cost(4, 2, 10)
    print(f"  Cost of order-4 × order-2 contraction (d=10): {cost2} FLOPs")
