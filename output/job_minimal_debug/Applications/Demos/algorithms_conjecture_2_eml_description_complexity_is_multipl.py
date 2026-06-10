#!/usr/bin/env python3
"""
Algorithms for EML Description Complexity

Implements the core algorithms from the research paper:
1. Expression tree construction and evaluation
2. Product tree building (linear and balanced)
3. Error budget computation
4. Complexity estimation
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Union
import numpy as np


# ============================================================
# Expression Tree Data Structure
# ============================================================

@dataclass
class ExprTree:
    """
    Expression tree for compositional function approximation.

    Each node is either a leaf (holding a function), an addition node,
    or a multiplication node. The tree evaluates to a real-valued function.
    """
    pass


@dataclass
class Leaf(ExprTree):
    """Leaf node holding a base function."""
    func: Callable[[float], float]
    name: str = "f"

    def eval(self, x: float) -> float:
        return self.func(x)

    @property
    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return self.name


@dataclass
class Add(ExprTree):
    """Addition node: evaluates to left + right."""
    left: ExprTree
    right: ExprTree

    def eval(self, x: float) -> float:
        return self.left.eval(x) + self.right.eval(x)

    @property
    def size(self) -> int:
        return self.left.size + self.right.size + 1

    def __repr__(self) -> str:
        return f"({self.left} + {self.right})"


@dataclass
class Mul(ExprTree):
    """Multiplication node: evaluates to left * right."""
    left: ExprTree
    right: ExprTree

    def eval(self, x: float) -> float:
        return self.left.eval(x) * self.right.eval(x)

    @property
    def size(self) -> int:
        return self.left.size + self.right.size + 1

    def __repr__(self) -> str:
        return f"({self.left} * {self.right})"


# ============================================================
# Product Tree Construction
# ============================================================

def build_product_tree_linear(trees: List[ExprTree]) -> ExprTree:
    """
    Build a product tree by left-to-right chaining.

    Given trees [T₁, T₂, ..., T_k], returns:
        Mul(Mul(...Mul(T₁, T₂), T₃)..., T_k)

    Size: sum(T_i.size) + (k - 1)
    Depth: k - 1

    Args:
        trees: List of expression trees to multiply.

    Returns:
        Product tree (left-associated).

    Example:
        >>> t1 = Leaf(lambda x: x, "x")
        >>> t2 = Leaf(lambda x: x+1, "x+1")
        >>> t3 = Leaf(lambda x: x-1, "x-1")
        >>> prod = build_product_tree_linear([t1, t2, t3])
        >>> print(prod)
        ((x * x+1) * x-1)
        >>> prod.eval(3.0)
        24.0
    """
    if not trees:
        return Leaf(lambda x: 1.0, "1")
    result = trees[0]
    for i in range(1, len(trees)):
        result = Mul(result, trees[i])
    return result


def build_product_tree_balanced(trees: List[ExprTree]) -> ExprTree:
    """
    Build a product tree using balanced binary splitting.

    Given trees [T₁, ..., T_k], recursively splits into two halves
    and multiplies the subtrees.

    Size: sum(T_i.size) + (k - 1)  [same as linear]
    Depth: ceil(log₂(k))  [much better than linear]

    Args:
        trees: List of expression trees to multiply.

    Returns:
        Product tree (balanced).

    Example:
        >>> trees = [Leaf(lambda x, i=i: x**i, f"x^{i}") for i in range(4)]
        >>> prod = build_product_tree_balanced(trees)
        >>> prod.eval(2.0)  # 1 * 2 * 4 * 8 = 64
        64.0
    """
    if not trees:
        return Leaf(lambda x: 1.0, "1")
    if len(trees) == 1:
        return trees[0]
    mid = len(trees) // 2
    left = build_product_tree_balanced(trees[:mid])
    right = build_product_tree_balanced(trees[mid:])
    return Mul(left, right)


# ============================================================
# Error Budget Computation
# ============================================================

def compute_error_budget(k: int, B: float, epsilon: float) -> float:
    """
    Compute the per-factor error budget for k-fold product approximation.

    For k factors each bounded by B, to achieve total error ≤ ε,
    each factor should be approximated within:
        δ = ε / (2k(B+1)^(k-1))

    Args:
        k: Number of factors.
        B: Uniform bound on factor values.
        epsilon: Target total approximation error.

    Returns:
        Per-factor error budget δ.

    Example:
        >>> compute_error_budget(3, 2.0, 0.1)
        0.001851851851851852
    """
    if k == 0:
        return epsilon
    return epsilon / (2 * k * (B + 1) ** (k - 1))


def compute_product_error_bound(k: int, B: float, delta: float) -> float:
    """
    Compute the theoretical product perturbation bound.

    If each of k factors is B-bounded and perturbed by at most δ,
    the product perturbation is at most k * (B+1)^(k-1) * δ.

    Args:
        k: Number of factors.
        B: Uniform bound on factor values.
        delta: Per-factor perturbation.

    Returns:
        Upper bound on product perturbation.
    """
    if k == 0:
        return 0.0
    return k * (B + 1) ** (k - 1) * delta


# ============================================================
# Complexity Estimation
# ============================================================

def estimate_complexity(
    func: Callable[[np.ndarray], np.ndarray],
    a: float,
    b: float,
    epsilon: float,
    max_size: int = 100,
    n_points: int = 200,
) -> int:
    """
    Estimate the EML description complexity of a function on [a,b].

    Uses a greedy approach: tries polynomial approximations of increasing
    degree and returns the first degree achieving the target error.

    This is a heuristic lower bound on tree size, since polynomials of
    degree d can be represented as trees of size O(d).

    Args:
        func: Target function.
        a, b: Interval endpoints.
        epsilon: Target approximation error.
        max_size: Maximum tree size to try.
        n_points: Number of evaluation points.

    Returns:
        Estimated complexity (tree size).
    """
    x = np.linspace(a, b, n_points)
    y = func(x)

    for deg in range(1, max_size):
        coeffs = np.polyfit(x, y, deg)
        approx = np.polyval(coeffs, x)
        error = np.max(np.abs(y - approx))
        if error <= epsilon:
            # Horner form: degree d polynomial needs ~2d+1 tree nodes
            return 2 * deg + 1

    return max_size


# ============================================================
# Product Approximation Algorithm
# ============================================================

def approximate_product(
    funcs: List[Callable[[np.ndarray], np.ndarray]],
    approx_funcs: List[Callable[[np.ndarray], np.ndarray]],
    a: float,
    b: float,
    B: float,
    epsilon: float,
    n_points: int = 200,
) -> dict:
    """
    Construct a product approximation and verify the error bound.

    Given functions f_1,...,f_k and their approximations F_1,...,F_k,
    constructs the product approximation ∏F_i and verifies that
    |∏f_i - ∏F_i| ≤ ε on [a,b].

    Args:
        funcs: Original functions.
        approx_funcs: Approximating functions.
        a, b: Interval.
        B: Uniform bound.
        epsilon: Target error.
        n_points: Evaluation grid size.

    Returns:
        Dictionary with error analysis.
    """
    k = len(funcs)
    x = np.linspace(a, b, n_points)

    # Compute per-factor errors
    factor_errors = []
    for i in range(k):
        err = np.max(np.abs(funcs[i](x) - approx_funcs[i](x)))
        factor_errors.append(err)

    # Compute products
    prod_orig = np.ones_like(x)
    prod_approx = np.ones_like(x)
    for i in range(k):
        prod_orig *= funcs[i](x)
        prod_approx *= approx_funcs[i](x)

    product_error = np.max(np.abs(prod_orig - prod_approx))
    delta = max(factor_errors) if factor_errors else 0
    theoretical_bound = compute_product_error_bound(k, B, delta)

    return {
        'k': k,
        'B': B,
        'epsilon': epsilon,
        'factor_errors': factor_errors,
        'max_factor_error': delta,
        'product_error': product_error,
        'theoretical_bound': theoretical_bound,
        'bound_satisfied': product_error <= theoretical_bound + 1e-10,
        'target_satisfied': product_error <= epsilon + 1e-10,
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("EML Complexity Algorithms — Example Usage")
    print("=" * 50)

    # Example 1: Build product trees
    print("\n1. Product Tree Construction")
    leaves = [
        Leaf(lambda x: np.sin(x), "sin"),
        Leaf(lambda x: np.cos(x), "cos"),
        Leaf(lambda x: x, "id"),
    ]

    linear = build_product_tree_linear(leaves)
    balanced = build_product_tree_balanced(leaves)

    print(f"   Linear tree:   {linear}")
    print(f"   Linear size:   {linear.size}")
    print(f"   Balanced tree: {balanced}")
    print(f"   Balanced size: {balanced.size}")
    print(f"   Eval at π/4:   {linear.eval(np.pi/4):.6f}")

    # Example 2: Error budget
    print("\n2. Error Budget Computation")
    for k in [2, 5, 10]:
        budget = compute_error_budget(k, B=2.0, epsilon=0.01)
        print(f"   k={k}, B=2, ε=0.01 → δ = {budget:.2e}")

    # Example 3: Product approximation
    print("\n3. Product Approximation Verification")
    funcs = [
        lambda x: np.sin(x),
        lambda x: np.cos(x),
    ]
    # Approximate with truncated Taylor series
    approx_funcs = [
        lambda x: x - x**3/6 + x**5/120,          # sin approx
        lambda x: 1 - x**2/2 + x**4/24 - x**6/720, # cos approx
    ]

    result = approximate_product(funcs, approx_funcs, -1, 1, B=1.0, epsilon=0.01)
    print(f"   Product error: {result['product_error']:.6f}")
    print(f"   Theoretical bound: {result['theoretical_bound']:.6f}")
    print(f"   Bound satisfied: {result['bound_satisfied']}")

    # Example 4: Complexity estimation
    print("\n4. Complexity Estimation")
    for name, func in [
        ("sin(x)", lambda x: np.sin(x)),
        ("x^3 - x", lambda x: x**3 - x),
        ("exp(x)", lambda x: np.exp(x)),
    ]:
        c = estimate_complexity(func, -1, 1, 0.001)
        print(f"   {name:12s}: estimated complexity = {c}")
