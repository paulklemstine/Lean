"""
EML Stone-Weierstrass Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the EML
approximation theory. These correspond to the Lean 4 formalization
in Applications/EMLStoneWeierstrass.lean.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Callable, Optional, Tuple
import math


# ============================================================
# Algorithm 1: EML Expression AST and Evaluation
# ============================================================

@dataclass
class EMLExpr:
    """Abstract syntax tree for EML expressions.
    
    Corresponds to the Lean 4 inductive type EMLExpr.
    """
    pass


@dataclass
class Const(EMLExpr):
    """Constant expression."""
    value: float


@dataclass
class Var(EMLExpr):
    """Input variable."""
    pass


@dataclass
class Exp(EMLExpr):
    """Exponential: exp(inner)."""
    inner: EMLExpr


@dataclass
class Log(EMLExpr):
    """Logarithm: log(inner)."""
    inner: EMLExpr


@dataclass
class Add(EMLExpr):
    """Addition: left + right."""
    left: EMLExpr
    right: EMLExpr


@dataclass
class Mul(EMLExpr):
    """Multiplication: left * right."""
    left: EMLExpr
    right: EMLExpr


def eml_eval(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at input x.
    
    Corresponds to EMLExpr.eval in the Lean formalization.
    
    Args:
        expr: The EML expression to evaluate.
        x: The input value.
    
    Returns:
        The result of evaluating expr at x.
    """
    if isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Var):
        return x
    elif isinstance(expr, Exp):
        return math.exp(eml_eval(expr.inner, x))
    elif isinstance(expr, Log):
        val = eml_eval(expr.inner, x)
        return math.log(val) if val > 0 else 0.0
    elif isinstance(expr, Add):
        return eml_eval(expr.left, x) + eml_eval(expr.right, x)
    elif isinstance(expr, Mul):
        return eml_eval(expr.left, x) * eml_eval(expr.right, x)
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


def eml_depth(expr: EMLExpr) -> int:
    """Compute the depth of an EML expression.
    
    Corresponds to EMLExpr.depth in the Lean formalization.
    """
    if isinstance(expr, (Const, Var)):
        return 0
    elif isinstance(expr, (Exp, Log)):
        return eml_depth(expr.inner) + 1
    elif isinstance(expr, (Add, Mul)):
        return max(eml_depth(expr.left), eml_depth(expr.right)) + 1
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


def eml_size(expr: EMLExpr) -> int:
    """Compute the size (number of nodes) of an EML expression.
    
    Corresponds to EMLExpr.size in the Lean formalization.
    """
    if isinstance(expr, (Const, Var)):
        return 1
    elif isinstance(expr, (Exp, Log)):
        return eml_size(expr.inner) + 1
    elif isinstance(expr, (Add, Mul)):
        return eml_size(expr.left) + eml_size(expr.right) + 1
    else:
        raise TypeError(f"Unknown EML expression type: {type(expr)}")


# ============================================================
# Algorithm 2: EML Power Representation
# ============================================================

def eml_power(n: int) -> EMLExpr:
    """Construct the EML expression for x^n: exp(n * log(x)).
    
    This always has size 5, regardless of n.
    Corresponds to emlPower in the Lean formalization.
    
    Args:
        n: The exponent (non-negative integer).
    
    Returns:
        EML expression computing x^n on positive inputs.
    """
    return Exp(Mul(Const(float(n)), Log(Var())))


# ============================================================
# Algorithm 3: Polynomial to EML Compilation
# ============================================================

def polynomial_to_eml(coeffs: List[float]) -> EMLExpr:
    """Compile a polynomial to an EML expression.
    
    Given coefficients [a_0, a_1, ..., a_d], constructs an EML expression
    computing a_0 + a_1*x + a_2*x^2 + ... + a_d*x^d.
    
    The resulting expression has size O(d) where d = len(coeffs) - 1.
    Corresponds to the construction in polynomial_eml_linear_size.
    
    Args:
        coeffs: Polynomial coefficients, lowest degree first.
    
    Returns:
        EML expression computing the polynomial on positive inputs.
    """
    if not coeffs:
        return Const(0.0)
    
    # Start with the constant term
    result: EMLExpr = Const(coeffs[0])
    
    # Add each higher-degree term: a_i * x^i = a_i * exp(i * log(x))
    for i in range(1, len(coeffs)):
        if coeffs[i] != 0.0:
            term = Mul(Const(coeffs[i]), eml_power(i))
            result = Add(result, term)
    
    return result


# ============================================================
# Algorithm 4: EML Approximation Quality Assessment
# ============================================================

def eml_approx_error(
    expr: EMLExpr,
    target: Callable[[float], float],
    a: float,
    b: float,
    n_samples: int = 1000
) -> float:
    """Compute the maximum approximation error of an EML expression.
    
    Samples the interval [a, b] and computes the maximum absolute
    difference between the EML expression and the target function.
    
    Args:
        expr: The EML expression.
        target: The target function to approximate.
        a: Left endpoint (must be > 0 for log to be defined).
        b: Right endpoint.
        n_samples: Number of sample points.
    
    Returns:
        Approximate sup-norm error.
    """
    if a <= 0:
        raise ValueError("Left endpoint must be positive for EML evaluation")
    
    max_error = 0.0
    for i in range(n_samples + 1):
        x = a + (b - a) * i / n_samples
        eml_val = eml_eval(expr, x)
        target_val = target(x)
        error = abs(eml_val - target_val)
        max_error = max(max_error, error)
    
    return max_error


# ============================================================
# Algorithm 5: Lipschitz Transfer Bound Verification
# ============================================================

def verify_lipschitz_transfer(
    f: Callable[[float], float],
    g: Callable[[float], float],
    K: float,
    epsilon: float,
    a: float,
    b: float,
    n_pairs: int = 100
) -> Tuple[bool, float]:
    """Verify the Lipschitz transfer bound numerically.
    
    Checks that |g(x) - g(y)| ≤ K|x - y| + 2ε for sampled pairs.
    Corresponds to eml_lipschitz_transfer in the Lean formalization.
    
    Args:
        f: The original Lipschitz function.
        g: The EML approximation.
        K: Lipschitz constant of f.
        epsilon: Approximation error bound.
        a, b: Interval endpoints.
        n_pairs: Number of random pairs to test.
    
    Returns:
        (all_satisfied, max_violation): Whether all pairs satisfy the bound,
        and the maximum violation (negative means satisfied with margin).
    """
    import random
    random.seed(42)
    
    max_violation = float('-inf')
    all_satisfied = True
    
    for _ in range(n_pairs):
        x = random.uniform(a, b)
        y = random.uniform(a, b)
        
        lhs = abs(g(x) - g(y))
        rhs = K * abs(x - y) + 2 * epsilon
        violation = lhs - rhs
        
        if violation > 1e-10:
            all_satisfied = False
        max_violation = max(max_violation, violation)
    
    return all_satisfied, max_violation


# ============================================================
# Algorithm 6: EML Complexity Estimation
# ============================================================

def estimate_eml_complexity(
    target: Callable[[float], float],
    a: float,
    b: float,
    epsilon: float,
    max_degree: int = 100
) -> Tuple[int, EMLExpr]:
    """Estimate the EML complexity of a function at scale epsilon.
    
    Uses polynomial approximation (via Chebyshev interpolation)
    followed by EML compilation to find a small EML expression
    that epsilon-approximates the target.
    
    Args:
        target: The target function.
        a, b: Interval endpoints (a > 0).
        epsilon: Desired approximation accuracy.
        max_degree: Maximum polynomial degree to try.
    
    Returns:
        (size, expr): The size and EML expression achieving the approximation.
    """
    import numpy as np
    
    for degree in range(1, max_degree + 1):
        # Chebyshev nodes on [a, b]
        nodes = [
            0.5 * (a + b) + 0.5 * (b - a) * math.cos(math.pi * (2*k + 1) / (2 * (degree + 1)))
            for k in range(degree + 1)
        ]
        values = [target(x) for x in nodes]
        
        # Fit polynomial (using numpy for convenience)
        coeffs_np = np.polyfit(nodes, values, degree)
        coeffs = list(reversed(coeffs_np.tolist()))  # lowest degree first
        
        # Build EML expression
        expr = polynomial_to_eml(coeffs)
        
        # Check error
        error = eml_approx_error(expr, target, a, b)
        
        if error < epsilon:
            return eml_size(expr), expr
    
    # Fallback: return the highest degree tried
    return eml_size(expr), expr


if __name__ == "__main__":
    # Quick test
    print("Testing EML algorithms...")
    
    # Test identity
    identity = Exp(Log(Var()))
    assert abs(eml_eval(identity, 2.5) - 2.5) < 1e-14
    assert eml_size(identity) == 3
    assert eml_depth(identity) == 2
    print(f"✓ Identity: size={eml_size(identity)}, depth={eml_depth(identity)}")
    
    # Test power
    p5 = eml_power(5)
    assert abs(eml_eval(p5, 2.0) - 32.0) < 1e-10
    assert eml_size(p5) == 5
    print(f"✓ x^5: size={eml_size(p5)}, eval(2)={eml_eval(p5, 2.0)}")
    
    # Test polynomial
    poly = polynomial_to_eml([1.0, 2.0, 3.0])  # 1 + 2x + 3x^2
    val = eml_eval(poly, 2.0)
    expected = 1 + 4 + 12
    assert abs(val - expected) < 1e-10
    print(f"✓ 1+2x+3x^2 at x=2: {val} (expected {expected}), size={eml_size(poly)}")
    
    print("\nAll tests passed!")
