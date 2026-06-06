#!/usr/bin/env python3
"""
EML Differential Equations: Core Algorithms

Type-hinted implementations of the key algorithms from the
EML Differential Ring theory.
"""

from typing import Callable, Tuple, List, Optional
import numpy as np


# Type aliases
RealFunc = Callable[[float], float]
VectorFunc = Callable[[float], np.ndarray]


def wronskian(y1: RealFunc, y2: RealFunc, x: float, h: float = 1e-8) -> float:
    """
    Compute the Wronskian W(y1, y2) at point x using numerical differentiation.

    W(y1, y2)(x) = y1(x) * y2'(x) - y2(x) * y1'(x)

    Args:
        y1: First solution function
        y2: Second solution function
        x: Point of evaluation
        h: Step size for numerical differentiation

    Returns:
        Wronskian value at x
    """
    dy1 = (y1(x + h) - y1(x - h)) / (2 * h)
    dy2 = (y2(x + h) - y2(x - h)) / (2 * h)
    return y1(x) * dy2 - y2(x) * dy1


def abel_wronskian(
    p: RealFunc,
    W0: float,
    x0: float,
    x: float,
    n_steps: int = 1000
) -> float:
    """
    Compute the Wronskian using Abel's formula:
    W(x) = W(x0) * exp(-∫_{x0}^{x} p(t) dt)

    Uses composite Simpson's rule for the integral.

    Args:
        p: The p-coefficient in y'' + p*y' + q*y = 0
        W0: Initial Wronskian value W(x0)
        x0: Initial point
        x: Target point
        n_steps: Number of integration steps

    Returns:
        Wronskian value at x via Abel's formula
    """
    # Composite Simpson's rule for ∫p
    t = np.linspace(x0, x, 2 * n_steps + 1)
    dt = (x - x0) / (2 * n_steps)
    values = np.array([p(ti) for ti in t])

    integral = dt / 3 * (
        values[0] + values[-1] +
        4 * np.sum(values[1::2]) +
        2 * np.sum(values[2:-1:2])
    )

    return W0 * np.exp(-integral)


def riccati_solve(
    q: RealFunc,
    v0: float,
    x_span: Tuple[float, float],
    n_steps: int = 10000
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Solve the Riccati equation v' + v² + q = 0 using RK4.

    This is the reduction of y'' + q*y = 0 via y = exp(∫v dx).

    Args:
        q: The q-coefficient
        v0: Initial value v(x0)
        x_span: (x_start, x_end)
        n_steps: Number of steps

    Returns:
        (x_array, v_array): Solution arrays
    """
    x0, x1 = x_span
    h = (x1 - x0) / n_steps
    x = np.zeros(n_steps + 1)
    v = np.zeros(n_steps + 1)
    x[0] = x0
    v[0] = v0

    def f(t: float, vt: float) -> float:
        return -(vt ** 2) - q(t)

    for i in range(n_steps):
        k1 = f(x[i], v[i])
        k2 = f(x[i] + h/2, v[i] + h*k1/2)
        k3 = f(x[i] + h/2, v[i] + h*k2/2)
        k4 = f(x[i] + h, v[i] + h*k3)
        v[i+1] = v[i] + h/6 * (k1 + 2*k2 + 2*k3 + k4)
        x[i+1] = x[i] + h

        # Detect blow-up (Riccati pole)
        if abs(v[i+1]) > 1e10:
            return x[:i+2], v[:i+2]

    return x, v


def sl2_transform(
    y1: np.ndarray,
    y2: np.ndarray,
    matrix: Tuple[float, float, float, float]
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Apply an SL(2) transformation to a pair of solutions.

    [y1_new]   [a b] [y1]
    [y2_new] = [c d] [y2]

    Args:
        y1, y2: Original solution arrays
        matrix: (a, b, c, d) with ad - bc = 1

    Returns:
        (y1_new, y2_new): Transformed solutions
    """
    a, b, c, d = matrix
    det = a * d - b * c
    if abs(det - 1.0) > 1e-6:
        raise ValueError(f"Matrix determinant {det} ≠ 1 (not in SL(2))")

    return a * y1 + b * y2, c * y1 + d * y2


def eml_tower_height(expr: str) -> int:
    """
    Compute the EML tower height of a symbolic expression.

    Tower height 0: constants, polynomials
    Tower height n+1: exp(height-n) or log(height-n)

    Args:
        expr: String representation of the expression

    Returns:
        Tower height
    """
    # Simple recursive parser
    expr = expr.strip()

    if expr.startswith("exp(") and expr.endswith(")"):
        inner = expr[4:-1]
        return eml_tower_height(inner) + 1

    if expr.startswith("log(") and expr.endswith(")"):
        inner = expr[4:-1]
        return eml_tower_height(inner) + 1

    # Check for nested operations
    if "exp(" in expr or "log(" in expr:
        # Find the maximum tower height among subexpressions
        max_h = 0
        i = 0
        while i < len(expr):
            for prefix in ["exp(", "log("]:
                if expr[i:].startswith(prefix):
                    depth = 1
                    j = i + len(prefix)
                    while j < len(expr) and depth > 0:
                        if expr[j] == '(':
                            depth += 1
                        elif expr[j] == ')':
                            depth -= 1
                        j += 1
                    sub = expr[i:j]
                    max_h = max(max_h, eml_tower_height(sub))
                    i = j
                    break
            else:
                i += 1
        return max_h

    # Base case: polynomial expression
    return 0


def classify_ode_solvability(
    p: RealFunc,
    q: RealFunc,
    x_test: List[float]
) -> dict:
    """
    Heuristic classification of 2nd-order linear ODE solvability.

    Uses numerical invariants to guess whether y'' + p*y' + q*y = 0
    might have EML solutions.

    Args:
        p: Coefficient of y'
        q: Coefficient of y
        x_test: Test points for evaluation

    Returns:
        Dictionary with classification results
    """
    results: dict = {
        "p_zero": all(abs(p(x)) < 1e-10 for x in x_test),
        "q_polynomial_degree": None,
        "abel_integral_eml": None,
        "classification": "unknown"
    }

    # Check if q is a polynomial (finite differences stabilize)
    q_vals = [q(x) for x in x_test]
    for deg in range(10):
        diffs = q_vals
        for _ in range(deg + 1):
            diffs = [diffs[i+1] - diffs[i] for i in range(len(diffs) - 1)]
            if not diffs:
                break
        if diffs and all(abs(d) < 1e-6 for d in diffs):
            results["q_polynomial_degree"] = deg
            break

    # Classification heuristics
    if results["p_zero"] and results["q_polynomial_degree"] == 1:
        results["classification"] = "Airy-type (likely non-EML)"
    elif results["p_zero"] and results["q_polynomial_degree"] == 0:
        results["classification"] = "Constant coefficient (EML-solvable)"
    elif results["q_polynomial_degree"] is not None:
        results["classification"] = "Polynomial coefficient (requires Kovacic)"

    return results


if __name__ == "__main__":
    # Quick test
    print("Testing Wronskian computation...")
    W = wronskian(np.sin, np.cos, 1.0)
    print(f"  W(sin, cos)(1) = {W:.10f} (should be ≈ -1)")

    print("\nTesting EML tower heights...")
    examples = ["x^2 + 3", "exp(x)", "log(x)", "exp(exp(x))", "exp(x*log(x))"]
    for e in examples:
        print(f"  height('{e}') = {eml_tower_height(e)}")

    print("\nTesting ODE classification...")
    x_test = list(np.linspace(0.5, 5, 20))

    # Airy equation: p=0, q=-x
    result = classify_ode_solvability(lambda x: 0, lambda x: -x, x_test)
    print(f"  Airy (y''=xy): {result['classification']}")

    # Constant coefficient: p=0, q=1
    result = classify_ode_solvability(lambda x: 0, lambda x: 1, x_test)
    print(f"  y''+y=0: {result['classification']}")
