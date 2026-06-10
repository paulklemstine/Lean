#!/usr/bin/env python3
"""
Algorithms for EML Depth Separation Analysis

Provides:
- EML expression representation (syntax tree)
- Evaluation, depth, and size computation
- Tower expression construction
- Derivative product formula computation
- Lipschitz obstruction analysis
- Shallow approximant search (brute-force for small sizes)
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Tuple
import math
import numpy as np


# ═══════════════════════════════════════════════════════════════════════════════
# EML Expression AST
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class EMLVar:
    """Variable node: represents the input x."""
    pass

@dataclass
class EMLConst:
    """Constant node."""
    value: float

@dataclass
class EMLAdd:
    """Addition node."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass
class EMLMul:
    """Multiplication node."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass
class EMLExp:
    """Exponential node: exp(child)."""
    child: 'EMLExpr'

EMLExpr = Union[EMLVar, EMLConst, EMLAdd, EMLMul, EMLExp]


def eml_eval(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at input x.
    
    Args:
        expr: EML expression tree
        x: input value
    
    Returns:
        Evaluation result
    
    >>> eml_eval(EMLVar(), 2.0)
    2.0
    >>> eml_eval(EMLExp(EMLVar()), 0.0)
    1.0
    """
    if isinstance(expr, EMLVar):
        return x
    elif isinstance(expr, EMLConst):
        return expr.value
    elif isinstance(expr, EMLAdd):
        return eml_eval(expr.left, x) + eml_eval(expr.right, x)
    elif isinstance(expr, EMLMul):
        return eml_eval(expr.left, x) * eml_eval(expr.right, x)
    elif isinstance(expr, EMLExp):
        v = eml_eval(expr.child, x)
        return math.exp(min(v, 500))  # overflow protection
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


def eml_depth(expr: EMLExpr) -> int:
    """Compute the compositional depth (max nesting of exp nodes).
    
    Args:
        expr: EML expression tree
    
    Returns:
        Depth of the expression
    
    >>> eml_depth(EMLVar())
    0
    >>> eml_depth(EMLExp(EMLExp(EMLVar())))
    2
    """
    if isinstance(expr, EMLVar):
        return 0
    elif isinstance(expr, EMLConst):
        return 0
    elif isinstance(expr, (EMLAdd, EMLMul)):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, EMLExp):
        return 1 + eml_depth(expr.child)
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


def eml_size(expr: EMLExpr) -> int:
    """Compute the syntactic size (number of nodes).
    
    Args:
        expr: EML expression tree
    
    Returns:
        Number of nodes
    
    >>> eml_size(EMLVar())
    1
    >>> eml_size(EMLExp(EMLVar()))
    2
    """
    if isinstance(expr, (EMLVar, EMLConst)):
        return 1
    elif isinstance(expr, (EMLAdd, EMLMul)):
        return 1 + eml_size(expr.left) + eml_size(expr.right)
    elif isinstance(expr, EMLExp):
        return 1 + eml_size(expr.child)
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


def tower_expr(k: int) -> EMLExpr:
    """Construct the canonical tower expression of depth k.
    
    towerExpr(0) = x
    towerExpr(k+1) = exp(towerExpr(k))
    
    Args:
        k: tower depth
    
    Returns:
        EML expression representing iterExp(k)
    
    >>> eml_depth(tower_expr(5))
    5
    >>> eml_size(tower_expr(5))
    6
    """
    if k == 0:
        return EMLVar()
    return EMLExp(tower_expr(k - 1))


def eml_to_string(expr: EMLExpr) -> str:
    """Pretty-print an EML expression."""
    if isinstance(expr, EMLVar):
        return "x"
    elif isinstance(expr, EMLConst):
        return f"{expr.value:.4g}"
    elif isinstance(expr, EMLAdd):
        return f"({eml_to_string(expr.left)} + {eml_to_string(expr.right)})"
    elif isinstance(expr, EMLMul):
        return f"({eml_to_string(expr.left)} * {eml_to_string(expr.right)})"
    elif isinstance(expr, EMLExp):
        return f"exp({eml_to_string(expr.child)})"
    else:
        return "?"


# ═══════════════════════════════════════════════════════════════════════════════
# Iterated Exponential Computations
# ═══════════════════════════════════════════════════════════════════════════════

def iter_exp(k: int, x: float) -> float:
    """Compute iterExp(k, x) with overflow protection.
    
    Args:
        k: number of iterations
        x: input value
    
    Returns:
        k-fold iterated exponential of x
    """
    result = x
    for _ in range(k):
        result = math.exp(min(result, 500))
    return result


def iter_exp_deriv_product(k: int, x: float) -> float:
    """Compute the derivative of iterExp(k+1, x) using the product formula.
    
    d/dx iterExp(k+1, x) = ∏_{j=0}^{k} iterExp(j+1, x)
    
    Args:
        k: depth index (derivative of iterExp(k+1))
        x: evaluation point
    
    Returns:
        Derivative value via the product formula
    """
    product = 1.0
    for j in range(k + 1):
        product *= iter_exp(j + 1, x)
        if product > 1e300:
            return float('inf')
    return product


def endpoint_gap(k: int) -> float:
    """Compute iterExp(k, 1) - iterExp(k, 0).
    
    This gap is proven to be monotonically increasing in k
    and bounded below by e - 1 ≈ 1.718 for k ≥ 1.
    """
    return iter_exp(k, 1.0) - iter_exp(k, 0.0)


def lipschitz_obstruction_bound(k: int, L: float) -> float:
    """Compute the minimum uniform approximation error for a Lipschitz-L function
    approximating iterExp(k) on [0,1].
    
    By the Lipschitz obstruction theorem:
    If L + 2ε < gap(k), then ε-approximation is impossible.
    So min achievable ε ≥ (gap(k) - L) / 2.
    
    Args:
        k: tower depth
        L: Lipschitz constant of the approximant
    
    Returns:
        Lower bound on achievable ε (0 if L is large enough)
    """
    gap = endpoint_gap(k)
    return max(0.0, (gap - L) / 2.0)


# ═══════════════════════════════════════════════════════════════════════════════
# Shallow Approximant Analysis
# ═══════════════════════════════════════════════════════════════════════════════

def fit_shallow_sum_of_exp(
    k: int, N: int, num_points: int = 200, lr: float = 0.01, steps: int = 5000
) -> Tuple[float, np.ndarray, np.ndarray, np.ndarray]:
    """Attempt to fit iterExp(k, x) on [0,1] using a sum of N exponentials:
    g(x) = Σ_{i=1}^{N} a_i * exp(b_i * x + c_i)
    
    This is a depth-1 EML expression. The Lipschitz obstruction theorem
    predicts that N must be large when k is large.
    
    Args:
        k: tower depth to approximate
        N: number of exponential terms
        num_points: discretization of [0,1]
        lr: learning rate for gradient descent
        steps: optimization steps
    
    Returns:
        (best_error, a_params, b_params, c_params)
    """
    x = np.linspace(0, 1, num_points)
    target = np.array([iter_exp(k, xi) for xi in x])
    
    # Initialize parameters
    rng = np.random.RandomState(42)
    a = rng.randn(N) * 0.1
    b = rng.randn(N) * 2.0
    c = rng.randn(N) * 0.1
    
    best_error = float('inf')
    
    for step in range(steps):
        # Forward pass
        basis = np.exp(np.clip(np.outer(x, b) + c[None, :], -50, 50))
        pred = basis @ a
        residual = pred - target
        error = np.max(np.abs(residual))
        
        if error < best_error:
            best_error = error
            best_a, best_b, best_c = a.copy(), b.copy(), c.copy()
        
        # Gradient step (MSE gradient)
        grad_a = 2.0 * (basis.T @ residual) / num_points
        grad_b_basis = basis * np.outer(x, np.ones(N))
        grad_b = 2.0 * (grad_b_basis.T @ residual) * a / num_points
        grad_c_basis = basis
        grad_c = 2.0 * (grad_c_basis.T @ residual) * a / num_points
        
        a -= lr * np.clip(grad_a, -10, 10)
        b -= lr * np.clip(grad_b, -10, 10)
        c -= lr * np.clip(grad_c, -10, 10)
    
    return best_error, best_a, best_b, best_c


# ═══════════════════════════════════════════════════════════════════════════════
# Main: Algorithm demonstrations
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("EML Depth Separation — Algorithms")
    print("=" * 60)
    
    # 1. Tower expression construction
    print("\n── Tower Expression Construction ──")
    for k in range(6):
        expr = tower_expr(k)
        print(f"  towerExpr({k}) = {eml_to_string(expr)}")
        print(f"    depth = {eml_depth(expr)}, size = {eml_size(expr)}")
    
    # 2. Derivative product formula verification
    print("\n── Derivative Product Formula ──")
    x0 = 0.5
    for k in range(5):
        deriv_val = iter_exp_deriv_product(k, x0)
        # Numerical check
        dx = 1e-8
        num = (iter_exp(k + 1, x0 + dx) - iter_exp(k + 1, x0 - dx)) / (2 * dx)
        print(f"  k={k}: product = {deriv_val:.6f}, numerical = {num:.6f}, "
              f"match = {abs(deriv_val - num) / max(abs(num), 1e-15):.2e}")
    
    # 3. Lipschitz obstruction analysis
    print("\n── Lipschitz Obstruction Analysis ──")
    for k in range(1, 6):
        gap = endpoint_gap(k)
        min_eps_10 = lipschitz_obstruction_bound(k, 10)
        min_eps_100 = lipschitz_obstruction_bound(k, 100)
        print(f"  k={k}: gap = {gap:.4f}, "
              f"min ε (L=10) = {min_eps_10:.4f}, "
              f"min ε (L=100) = {min_eps_100:.4f}")
    
    # 4. Shallow approximation test
    print("\n── Shallow Sum-of-Exponentials Fitting ──")
    for k in [1, 2, 3]:
        for N in [2, 5, 10, 20]:
            err, _, _, _ = fit_shallow_sum_of_exp(k, N, steps=2000)
            print(f"  k={k}, N={N}: best L∞ error = {err:.4f}")
    
    print("\nDone!")
