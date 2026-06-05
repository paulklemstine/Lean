"""
Algorithms for EML Differential Equations

Type-hinted implementations of the key algorithms from the formalization:
1. Polynomial Solution Test — decides if y'' = q(x)y has polynomial solutions
2. EML Expression Differentiation — formal symbolic differentiation
3. Wronskian Computation — numerical Wronskian evaluation
4. Kovacic Case 1 Test — checks for exponential solutions
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable, Optional, Tuple
import numpy as np


# ============================================================
# Algorithm 1: EML Expression Tree and Differentiation
# ============================================================

@dataclass
class Const:
    """Constant EML expression."""
    value: float

@dataclass
class Var:
    """Variable x."""
    pass

@dataclass
class Add:
    """Sum of two EML expressions."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass
class Mul:
    """Product of two EML expressions."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass
class Exp:
    """Exponential of an EML expression."""
    arg: 'EMLExpr'

@dataclass
class Log:
    """Logarithm of an EML expression."""
    arg: 'EMLExpr'

EMLExpr = Union[Const, Var, Add, Mul, Exp, Log]


def eml_deriv(e: EMLExpr) -> EMLExpr:
    """
    Formal differentiation of EML expressions.

    Implements the chain rule, product rule, and standard derivative rules.
    The key property: the output is always an EMLExpr (closure theorem).

    Args:
        e: An EML expression

    Returns:
        The formal derivative, also an EML expression
    """
    if isinstance(e, Const):
        return Const(0.0)
    elif isinstance(e, Var):
        return Const(1.0)
    elif isinstance(e, Add):
        return Add(eml_deriv(e.left), eml_deriv(e.right))
    elif isinstance(e, Mul):
        # Product rule: (fg)' = f'g + fg'
        return Add(
            Mul(eml_deriv(e.left), e.right),
            Mul(e.left, eml_deriv(e.right))
        )
    elif isinstance(e, Exp):
        # Chain rule: (exp(f))' = f' * exp(f)
        return Mul(eml_deriv(e.arg), Exp(e.arg))
    elif isinstance(e, Log):
        # Chain rule: (log(f))' = f'/f = f' * exp(-log(f))
        return Mul(
            eml_deriv(e.arg),
            Exp(Mul(Const(-1.0), Log(e.arg)))
        )
    else:
        raise TypeError(f"Unknown EML expression type: {type(e)}")


def eml_eval(e: EMLExpr, x: float) -> float:
    """
    Evaluate an EML expression at a point.

    Args:
        e: An EML expression
        x: The point to evaluate at

    Returns:
        The value e(x)
    """
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return x
    elif isinstance(e, Add):
        return eml_eval(e.left, x) + eml_eval(e.right, x)
    elif isinstance(e, Mul):
        return eml_eval(e.left, x) * eml_eval(e.right, x)
    elif isinstance(e, Exp):
        return np.exp(eml_eval(e.arg, x))
    elif isinstance(e, Log):
        return np.log(eml_eval(e.arg, x))
    else:
        raise TypeError(f"Unknown EML expression type: {type(e)}")


def eml_depth(e: EMLExpr) -> int:
    """
    Compute the exp/log nesting depth of an EML expression.

    Args:
        e: An EML expression

    Returns:
        The nesting depth (0 for polynomials)
    """
    if isinstance(e, (Const, Var)):
        return 0
    elif isinstance(e, (Add, Mul)):
        return max(eml_depth(e.left), eml_depth(e.right))
    elif isinstance(e, (Exp, Log)):
        return eml_depth(e.arg) + 1
    else:
        raise TypeError(f"Unknown EML expression type: {type(e)}")


def eml_to_string(e: EMLExpr) -> str:
    """Pretty-print an EML expression."""
    if isinstance(e, Const):
        return f"{e.value:g}"
    elif isinstance(e, Var):
        return "x"
    elif isinstance(e, Add):
        return f"({eml_to_string(e.left)} + {eml_to_string(e.right)})"
    elif isinstance(e, Mul):
        return f"({eml_to_string(e.left)} · {eml_to_string(e.right)})"
    elif isinstance(e, Exp):
        return f"exp({eml_to_string(e.arg)})"
    elif isinstance(e, Log):
        return f"log({eml_to_string(e.arg)})"
    else:
        return "?"


# ============================================================
# Algorithm 2: Polynomial Solution Test
# ============================================================

def polynomial_solution_test(q_coeffs: list[float]) -> Tuple[bool, str]:
    """
    Decide if y'' = q(x)·y has a nonzero polynomial solution.

    Based on the degree gap obstruction theorem:
    - If deg(q) ≥ 1: NO polynomial solutions (degree gap)
    - If q = 0: YES (solutions are y = ax + b)
    - If q ≠ 0 constant: NO (solutions are exponential/trigonometric)

    Args:
        q_coeffs: Coefficients of q(x) = q[0] + q[1]x + q[2]x² + ...

    Returns:
        (has_solution, explanation) tuple
    """
    # Remove trailing zeros
    while q_coeffs and abs(q_coeffs[-1]) < 1e-15:
        q_coeffs = q_coeffs[:-1]

    if not q_coeffs or all(abs(c) < 1e-15 for c in q_coeffs):
        return True, "q = 0: solutions are y = ax + b (any linear function)"

    deg = len(q_coeffs) - 1

    if deg >= 1:
        return False, (
            f"DEGREE GAP OBSTRUCTION: deg(q) = {deg} ≥ 1.\n"
            f"  For polynomial p of degree n: deg(p'') = n-2, deg(q·p) = n+{deg}.\n"
            f"  These are irreconcilable for any n ≥ 0.\n"
            f"  (Formally proved: poly_ode_degree_obstruction)"
        )
    else:
        c = q_coeffs[0]
        return False, (
            f"CONSTANT COEFFICIENT: q = {c:.4g}.\n"
            f"  p'' = {c:.4g}·p has solutions exp(±√({c:.4g})·x), not polynomials.\n"
            f"  deg(p'') = n-2 ≠ n = deg(c·p) for n ≥ 2.\n"
            f"  For n ≤ 1: p'' = 0 but c·p ≠ 0.\n"
            f"  (Formally proved: no_poly_solution_const_coeff)"
        )


# ============================================================
# Algorithm 3: Wronskian Computation
# ============================================================

def wronskian(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x: float,
    h: float = 1e-7
) -> float:
    """
    Compute the Wronskian W(f, g)(x) = f(x)g'(x) - g(x)f'(x).

    Uses central difference for derivative approximation.

    Args:
        f: First function
        g: Second function
        x: Point of evaluation
        h: Step size for numerical differentiation

    Returns:
        W(f, g)(x)
    """
    f_val = f(x)
    g_val = g(x)
    f_prime = (f(x + h) - f(x - h)) / (2 * h)
    g_prime = (g(x + h) - g(x - h)) / (2 * h)
    return f_val * g_prime - g_val * f_prime


def verify_wronskian_constancy(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x_range: Tuple[float, float] = (-10.0, 5.0),
    n_points: int = 100
) -> Tuple[float, float, float]:
    """
    Verify that the Wronskian is constant over a range.

    Args:
        f, g: Two functions (should be solutions of the same ODE)
        x_range: Range to check
        n_points: Number of sample points

    Returns:
        (mean_wronskian, std_dev, max_deviation) tuple
    """
    xs = np.linspace(x_range[0], x_range[1], n_points)
    ws = [wronskian(f, g, x) for x in xs]
    mean_w = np.mean(ws)
    std_w = np.std(ws)
    max_dev = np.max(np.abs(np.array(ws) - mean_w))
    return mean_w, std_w, max_dev


# ============================================================
# Algorithm 4: Kovacic Case 1 Test (Simplified)
# ============================================================

def kovacic_case1_test(q_coeffs: list[float]) -> Tuple[bool, str]:
    """
    Simplified Kovacic Case 1 test for polynomial q.

    Tests whether y'' = q(x)y might have a solution of the form
    exp(∫r(x)dx) where r is a polynomial (simplest case).

    If such a solution exists, then r satisfies the Riccati equation:
    r' + r² = q. For polynomial r of degree d, the leading terms give:
    - r² has degree 2d
    - q has degree deg(q)
    So 2d = deg(q), meaning deg(q) must be even.

    For q = x (Airy): deg = 1 (odd), so NO polynomial Riccati solution.

    Args:
        q_coeffs: Coefficients of q(x)

    Returns:
        (possible, explanation) tuple
    """
    while q_coeffs and abs(q_coeffs[-1]) < 1e-15:
        q_coeffs = q_coeffs[:-1]

    if not q_coeffs:
        return True, "q = 0: trivial case, r = 0 works (exp(0) = 1 is polynomial)"

    deg_q = len(q_coeffs) - 1

    if deg_q % 2 == 1:
        return False, (
            f"PARITY OBSTRUCTION: deg(q) = {deg_q} is odd.\n"
            f"  A polynomial Riccati solution r would need deg(r²) = deg(q),\n"
            f"  i.e., 2·deg(r) = {deg_q}, giving deg(r) = {deg_q}/2 (not integer).\n"
            f"  Therefore NO exponential-of-polynomial solution exists."
        )
    else:
        d = deg_q // 2
        lead_q = q_coeffs[-1]
        # r² must match leading term: r_d² = q_{2d}
        if lead_q > 0:
            r_lead = np.sqrt(lead_q)
            return True, (
                f"POSSIBLE: deg(q) = {deg_q} is even, leading coeff > 0.\n"
                f"  Candidate: r(x) ≈ ±{r_lead:.4g}·x^{d} + lower terms.\n"
                f"  Full Kovacic algorithm needed to determine coefficients."
            )
        else:
            return True, (
                f"POSSIBLE (complex): deg(q) = {deg_q} is even, leading coeff < 0.\n"
                f"  Solutions would be oscillatory (complex exponential).\n"
                f"  Full Kovacic algorithm needed for complete analysis."
            )


if __name__ == "__main__":
    print("=== Polynomial Solution Test ===")
    test_cases = [
        ([0.0], "y'' = 0"),
        ([1.0], "y'' = y"),
        ([-1.0], "y'' = -y"),
        ([0.0, 1.0], "y'' = xy (Airy)"),
        ([0.0, 0.0, 1.0], "y'' = x²y"),
        ([-1.0, 0.0, 1.0], "y'' = (x²-1)y (Hermite-type)"),
    ]

    for coeffs, name in test_cases:
        has_sol, explanation = polynomial_solution_test(coeffs)
        print(f"\n{name}: {'HAS' if has_sol else 'NO'} polynomial solution")
        print(f"  {explanation}")

    print("\n\n=== Kovacic Case 1 Test ===")
    for coeffs, name in test_cases:
        possible, explanation = kovacic_case1_test(coeffs)
        print(f"\n{name}: {'POSSIBLE' if possible else 'IMPOSSIBLE'}")
        print(f"  {explanation}")

    print("\n\n=== EML Differentiation ===")
    # Example: d/dx[exp(x²)] = 2x·exp(x²)
    expr = Exp(Mul(Var(), Var()))  # exp(x·x) = exp(x²)
    deriv = eml_deriv(expr)
    print(f"Expression: {eml_to_string(expr)}")
    print(f"Derivative: {eml_to_string(deriv)}")
    print(f"Depth: {eml_depth(expr)} → {eml_depth(deriv)}")

    # Verify numerically
    x = 2.0
    print(f"At x={x}: expr = {eml_eval(expr, x):.6f}, "
          f"deriv = {eml_eval(deriv, x):.6f}, "
          f"expected = {2*x*np.exp(x**2):.6f}")
