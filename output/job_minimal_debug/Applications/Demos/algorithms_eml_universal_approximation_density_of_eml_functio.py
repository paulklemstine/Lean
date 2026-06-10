#!/usr/bin/env python3
"""
EML Universal Approximation — Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from dataclasses import dataclass
from typing import List, Tuple, Callable, Optional
import numpy as np


# === EML Expression Tree ===

@dataclass
class EMLExpr:
    """Base class for EML expression trees."""
    pass

@dataclass
class Var(EMLExpr):
    """Variable node."""
    pass

@dataclass
class Const(EMLExpr):
    """Constant node."""
    value: float

@dataclass
class Add(EMLExpr):
    """Addition node."""
    left: EMLExpr
    right: EMLExpr

@dataclass
class Mul(EMLExpr):
    """Multiplication node."""
    left: EMLExpr
    right: EMLExpr

@dataclass
class Neg(EMLExpr):
    """Negation node."""
    child: EMLExpr

@dataclass
class Inv(EMLExpr):
    """Inversion node."""
    child: EMLExpr

@dataclass
class EML(EMLExpr):
    """EML operation: a * exp(b)."""
    left: EMLExpr  # a
    right: EMLExpr  # b


def eval_expr(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at point x."""
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return eval_expr(expr.left, x) + eval_expr(expr.right, x)
    elif isinstance(expr, Mul):
        return eval_expr(expr.left, x) * eval_expr(expr.right, x)
    elif isinstance(expr, Neg):
        return -eval_expr(expr.child, x)
    elif isinstance(expr, Inv):
        v = eval_expr(expr.child, x)
        return 1.0 / v if v != 0 else float('inf')
    elif isinstance(expr, EML):
        a = eval_expr(expr.left, x)
        b = eval_expr(expr.right, x)
        return a * np.exp(b)
    raise ValueError(f"Unknown expression type: {type(expr)}")


def eml_depth(expr: EMLExpr) -> int:
    """Compute the EML depth (max nesting of eml operations)."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, (Neg, Inv)):
        return eml_depth(expr.child)
    elif isinstance(expr, EML):
        return 1 + max(eml_depth(expr.left), eml_depth(expr.right))
    return 0


def exp_rank(expr: EMLExpr) -> int:
    """Compute the exponential rank (max depth of exp nesting)."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(exp_rank(expr.left), exp_rank(expr.right))
    elif isinstance(expr, (Neg, Inv)):
        return exp_rank(expr.child)
    elif isinstance(expr, EML):
        return max(exp_rank(expr.left), exp_rank(expr.right) + 1)
    return 0


def expr_size(expr: EMLExpr) -> int:
    """Compute the size (number of nodes) of an EML expression."""
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Mul, EML)):
        return 1 + expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, (Neg, Inv)):
        return 1 + expr_size(expr.child)
    return 1


# === Iterated Exponential Construction ===

def build_iter_exp(n: int) -> EMLExpr:
    """Build the canonical EML expression for iterExp(n).
    
    Algorithm: ITEREXP_EML(n)
    - If n = 0: return var
    - Else: return eml(const(1), ITEREXP_EML(n-1))
    
    Properties:
    - eval(result, x) = exp^n(x) for all x
    - eml_depth(result) = n
    - exp_rank(result) = n
    - size(result) = 2n + 1
    """
    if n == 0:
        return Var()
    return EML(Const(1.0), build_iter_exp(n - 1))


def iter_exp(n: int, x: float) -> float:
    """Compute the iterated exponential E_n(x) directly."""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result


# === EML Approximation ===

def eml_generator_1d(w: float, b: float, x: float) -> float:
    """Single EML generator: exp(w*x + b)."""
    return np.exp(w * x + b)


def eml_lipschitz_bound(w: float, b: float) -> float:
    """Lipschitz constant bound for exp(w*x + b) on [0,1].
    
    Theorem: |exp(w*x1 + b) - exp(w*x2 + b)| ≤ |w| * exp(|w| + |b|) * |x1 - x2|
    """
    return abs(w) * np.exp(abs(w) + abs(b))


def greedy_eml_fit(
    f: Callable[[float], float],
    n_generators: int,
    n_samples: int = 200,
    seed: int = 42
) -> Tuple[List[Tuple[float, float, float]], float]:
    """Greedy EML approximation of f on [0,1].
    
    Algorithm: EML_APPROXIMATE(f, n_generators)
    1. Sample the target function at n_samples points
    2. Generate random EML generators exp(w*x + b)
    3. Fit coefficients by least squares
    4. Return (generators, max_error)
    
    Returns:
        List of (w, b, coefficient) tuples and the max approximation error.
    """
    rng = np.random.default_rng(seed)
    xs = np.linspace(0, 1, n_samples)
    target = np.array([f(x) for x in xs])
    
    # Build design matrix
    A = np.ones((n_samples, n_generators + 1))  # +1 for constant term
    generator_params = []
    for i in range(n_generators):
        w = rng.uniform(-5, 5)
        b = rng.uniform(-3, 3)
        A[:, i + 1] = np.exp(w * xs + b)
        generator_params.append((w, b))
    
    # Least squares fit
    coeffs, _, _, _ = np.linalg.lstsq(A, target, rcond=None)
    
    approx = A @ coeffs
    max_error = float(np.max(np.abs(target - approx)))
    
    result = [(0.0, 0.0, coeffs[0])]  # constant term
    for i, (w, b) in enumerate(generator_params):
        result.append((w, b, coeffs[i + 1]))
    
    return result, max_error


# === Width-Depth Analysis ===

def width_depth_analysis(max_depth: int = 20) -> List[Tuple[int, int, int, float]]:
    """Analyze the width-for-depth tradeoff.
    
    Returns list of (depth, eml_leaves, relu_width, ratio) tuples.
    """
    results = []
    for d in range(1, max_depth + 1):
        eml_leaves = 2 * d + 1
        relu_width = 2 ** d
        ratio = relu_width / eml_leaves
        results.append((d, eml_leaves, relu_width, ratio))
    return results


# === Polynomial-to-EML Bridge ===

def polynomial_to_eml(coefficients: List[float]) -> EMLExpr:
    """Convert a polynomial (given by coefficients [a₀, a₁, ..., aₙ])
    to an EML expression using only field operations (depth 0).
    
    p(x) = a₀ + a₁x + a₂x² + ... + aₙxⁿ
    """
    if not coefficients:
        return Const(0.0)
    
    # Build x^k terms
    def power_expr(k: int) -> EMLExpr:
        if k == 0:
            return Const(1.0)
        elif k == 1:
            return Var()
        else:
            return Mul(Var(), power_expr(k - 1))
    
    terms = []
    for k, c in enumerate(coefficients):
        if c != 0:
            if k == 0:
                terms.append(Const(c))
            else:
                terms.append(Mul(Const(c), power_expr(k)))
    
    if not terms:
        return Const(0.0)
    
    result = terms[0]
    for t in terms[1:]:
        result = Add(result, t)
    return result


if __name__ == "__main__":
    # Verify iterated exponential construction
    for n in range(5):
        expr = build_iter_exp(n)
        x = 0.5
        assert abs(eval_expr(expr, x) - iter_exp(n, x)) < 1e-10
        assert eml_depth(expr) == n
        assert exp_rank(expr) == n
        assert expr_size(expr) == 2 * n + 1
    print("✓ Iterated exponential construction verified")

    # Verify polynomial bridge
    poly = polynomial_to_eml([1, 1, -2, 1])  # 1 + x - 2x² + x³
    for x in [0, 0.25, 0.5, 0.75, 1.0]:
        expected = 1 + x - 2*x**2 + x**3
        actual = eval_expr(poly, x)
        assert abs(expected - actual) < 1e-10, f"Failed at x={x}: {expected} vs {actual}"
    print("✓ Polynomial-to-EML bridge verified")

    # Verify EML approximation
    generators, error = greedy_eml_fit(lambda x: abs(x - 0.5), 20)
    print(f"✓ EML approximation of |x-0.5|: max error = {error:.6f}")

    # Width-depth analysis
    results = width_depth_analysis(15)
    print(f"✓ Width-depth analysis: ratio at depth 15 = {results[-1][3]:.1f}x")

    print("\nAll algorithm tests passed.")
