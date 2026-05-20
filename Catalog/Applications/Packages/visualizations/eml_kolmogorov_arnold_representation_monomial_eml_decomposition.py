#!/usr/bin/env python3
"""
EML Kolmogorov-Arnold Representation: Algorithms

Implements constructive algorithms for EML superposition decomposition,
including exact monomial/polynomial decomposition and approximate
template fitting for general functions on positive domains.
"""

import numpy as np
from typing import List, Tuple, Callable, Optional


# ============================================================================
# Core Data Structures
# ============================================================================

class EMLSuperposition:
    """
    An EML superposition model for bivariate functions.

    Represents f(x,y) = sum_i outer_i(inner1_i(x) + inner2_i(y))

    Each term has:
      - outer: R -> R  (outer univariate function)
      - inner1: R -> R  (first inner function, applied to x)
      - inner2: R -> R  (second inner function, applied to y)
    """

    def __init__(self):
        self.terms: List[Tuple[Callable, Callable, Callable]] = []

    def add_term(self, outer: Callable, inner1: Callable, inner2: Callable):
        """Add a superposition term."""
        self.terms.append((outer, inner1, inner2))

    def eval(self, x: np.ndarray, y: np.ndarray) -> np.ndarray:
        """Evaluate the superposition at points (x, y)."""
        result = np.zeros_like(x, dtype=float)
        for outer, inner1, inner2 in self.terms:
            result += outer(inner1(x) + inner2(y))
        return result

    def __repr__(self) -> str:
        return f"EMLSuperposition(terms={len(self.terms)})"


# ============================================================================
# Algorithm 1: Monomial EML Decomposition
# ============================================================================

def monomial_witness(a: float, b: float, coeff: float = 1.0) -> EMLSuperposition:
    """
    Construct an EML superposition witness for c * x^a * y^b.

    Uses the identity: c * x^a * y^b = c * exp(a*log(x) + b*log(y))

    Args:
        a: Exponent for x
        b: Exponent for y
        coeff: Coefficient (default 1.0)

    Returns:
        EMLSuperposition with 1 term

    Complexity: O(1) construction, O(1) evaluation per point

    Example:
        >>> S = monomial_witness(2.0, 3.0, coeff=5.0)
        >>> S.eval(np.array([2.0]), np.array([3.0]))  # 5 * 4 * 27 = 540
        array([540.])
    """
    S = EMLSuperposition()
    S.add_term(
        outer=lambda t, c=coeff: c * np.exp(t),
        inner1=lambda x, a=a: a * np.log(x),
        inner2=lambda y, b=b: b * np.log(y)
    )
    return S


# ============================================================================
# Algorithm 2: Polynomial EML Decomposition
# ============================================================================

def polynomial_witness(
    terms: List[Tuple[float, float, float]]
) -> EMLSuperposition:
    """
    Construct an EML superposition for a positive-coefficient polynomial.

    Decomposes p(x,y) = sum_k c_k * x^{a_k} * y^{b_k} into
    sum_k c_k * exp(a_k * log(x) + b_k * log(y))

    Args:
        terms: List of (coefficient, x_exponent, y_exponent) tuples.
               Coefficients must be positive.

    Returns:
        EMLSuperposition with len(terms) terms

    Complexity: O(K) construction, O(K) evaluation per point

    Example:
        >>> # p(x,y) = x^2 + 3xy + 2y^2
        >>> S = polynomial_witness([(1, 2, 0), (3, 1, 1), (2, 0, 2)])
        >>> x, y = np.array([2.0]), np.array([3.0])
        >>> S.eval(x, y)  # 4 + 18 + 18 = 40
        array([40.])
    """
    S = EMLSuperposition()
    for c, a, b in terms:
        if c <= 0:
            raise ValueError(f"Coefficient {c} must be positive")
        S.add_term(
            outer=lambda t, c=c: c * np.exp(t),
            inner1=lambda x, a=a: a * np.log(x),
            inner2=lambda y, b=b: b * np.log(y)
        )
    return S


# ============================================================================
# Algorithm 3: Approximate EML Template Fitting
# ============================================================================

def fit_eml_template(
    f: Callable[[np.ndarray, np.ndarray], np.ndarray],
    x_range: Tuple[float, float],
    y_range: Tuple[float, float],
    m: int = 5,
    grid_size: int = 50,
    max_iter: int = 2000,
    lr: float = 0.01,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, float]:
    """
    Fit an m-term EML template to a target function via gradient descent.

    Finds parameters (alpha, beta, gamma) minimizing:
      sum_{grid} |f(x,y) - sum_i exp(alpha_i*log(x) + beta_i*log(y) + gamma_i)|^2

    Args:
        f: Target function f(x, y) -> z
        x_range: (x_min, x_max) with x_min > 0
        y_range: (y_min, y_max) with y_min > 0
        m: Number of EML terms
        grid_size: Points per axis
        max_iter: Maximum gradient descent iterations
        lr: Learning rate
        seed: Random seed

    Returns:
        (alpha, beta, gamma, final_residual)

    Example:
        >>> alpha, beta, gamma, res = fit_eml_template(
        ...     lambda x, y: x * y, (0.5, 2.0), (0.5, 2.0), m=1)
        >>> print(f"Residual: {res:.2e}")  # Should be ~0
    """
    rng = np.random.RandomState(seed)

    x_grid = np.linspace(x_range[0], x_range[1], grid_size)
    y_grid = np.linspace(y_range[0], y_range[1], grid_size)
    X, Y = np.meshgrid(x_grid, y_grid)
    log_X = np.log(X)
    log_Y = np.log(Y)
    target = f(X, Y)

    # Initialize parameters
    alpha = rng.randn(m) * 0.5 + 1.0
    beta = rng.randn(m) * 0.5 + 1.0
    gamma = rng.randn(m) * 0.5

    best_residual = float('inf')
    best_params = (alpha.copy(), beta.copy(), gamma.copy())

    for iteration in range(max_iter):
        # Forward pass
        predicted = np.zeros_like(X)
        exp_terms = []
        for i in range(m):
            arg = alpha[i] * log_X + beta[i] * log_Y + gamma[i]
            exp_term = np.exp(np.clip(arg, -50, 50))
            exp_terms.append(exp_term)
            predicted += exp_term

        residual_matrix = predicted - target
        residual = np.sum(residual_matrix ** 2)

        if residual < best_residual:
            best_residual = residual
            best_params = (alpha.copy(), beta.copy(), gamma.copy())

        # Gradient descent
        for i in range(m):
            grad_common = 2 * residual_matrix * exp_terms[i]
            alpha[i] -= lr * np.sum(grad_common * log_X) / X.size
            beta[i] -= lr * np.sum(grad_common * log_Y) / X.size
            gamma[i] -= lr * np.sum(grad_common) / X.size

        # Reduce learning rate
        if iteration > 0 and iteration % 500 == 0:
            lr *= 0.5

    alpha, beta, gamma = best_params
    # Compute final residual as max absolute error
    predicted = np.zeros_like(X)
    for i in range(m):
        predicted += np.exp(np.clip(alpha[i]*log_X + beta[i]*log_Y + gamma[i], -50, 50))
    max_error = np.max(np.abs(predicted - target))

    return alpha, beta, gamma, max_error


# ============================================================================
# Algorithm 4: Separability Test
# ============================================================================

def test_additive_separability(
    f: Callable[[np.ndarray, np.ndarray], np.ndarray],
    x_range: Tuple[float, float],
    y_range: Tuple[float, float],
    grid_size: int = 50
) -> Tuple[float, float]:
    """
    Test whether a function is additively separable: f(x,y) ≈ u(x) + v(y).

    Uses SVD of the function's evaluation matrix. If f is additively separable,
    the matrix has rank 1 (up to a constant). The ratio of the second to first
    singular value measures non-separability.

    Args:
        f: Target function
        x_range, y_range: Domain bounds (positive)
        grid_size: Grid resolution

    Returns:
        (relative_error, singular_value_ratio)

    Example:
        >>> err, ratio = test_additive_separability(
        ...     lambda x, y: x * y, (1, 3), (1, 3))
        >>> print(f"Error: {err:.4f}, ratio: {ratio:.4f}")
    """
    x_grid = np.linspace(x_range[0], x_range[1], grid_size)
    y_grid = np.linspace(y_range[0], y_range[1], grid_size)
    X, Y = np.meshgrid(x_grid, y_grid)
    Z = f(X, Y)

    # Remove mean to get the interactive part
    row_means = Z.mean(axis=1, keepdims=True)
    col_means = Z.mean(axis=0, keepdims=True)
    grand_mean = Z.mean()
    additive_approx = row_means + col_means - grand_mean

    residual = Z - additive_approx
    rel_error = np.linalg.norm(residual) / np.linalg.norm(Z)

    U, S, Vt = np.linalg.svd(Z - grand_mean)
    sv_ratio = S[1] / S[0] if S[0] > 0 else 0.0

    return rel_error, sv_ratio


# ============================================================================
# Main: Run examples
# ============================================================================

def main():
    print("EML Kolmogorov-Arnold: Algorithm Examples")
    print("=" * 60)

    # Example 1: Monomial decomposition
    print("\n1. Monomial witness for 5*x^2*y^3:")
    S = monomial_witness(2.0, 3.0, coeff=5.0)
    x = np.array([2.0, 3.0, 1.5])
    y = np.array([3.0, 2.0, 4.0])
    print(f"   Direct:  {5 * x**2 * y**3}")
    print(f"   EML:     {S.eval(x, y)}")
    print(f"   Error:   {np.max(np.abs(5*x**2*y**3 - S.eval(x, y))):.2e}")

    # Example 2: Polynomial decomposition
    print("\n2. Polynomial witness for x^2 + 3xy + 2y^2:")
    S = polynomial_witness([(1, 2, 0), (3, 1, 1), (2, 0, 2)])
    direct = x**2 + 3*x*y + 2*y**2
    print(f"   Direct:  {direct}")
    print(f"   EML:     {S.eval(x, y)}")
    print(f"   Error:   {np.max(np.abs(direct - S.eval(x, y))):.2e}")

    # Example 3: Approximate fitting
    print("\n3. Approximate EML fitting for sqrt(x^2 + y^2):")
    alpha, beta, gamma, res = fit_eml_template(
        lambda x, y: np.sqrt(x**2 + y**2),
        (0.5, 2.0), (0.5, 2.0), m=5, max_iter=3000
    )
    print(f"   Max error with 5 terms: {res:.6f}")
    print(f"   Parameters:")
    for i in range(len(alpha)):
        print(f"     Term {i+1}: exp({alpha[i]:.4f}*log(x) + {beta[i]:.4f}*log(y) + {gamma[i]:.4f})")

    # Example 4: Separability test
    print("\n4. Additive separability tests:")
    functions = {
        "x*y (non-separable)": lambda x, y: x * y,
        "x + y (separable)": lambda x, y: x + y,
        "x^2*y^2 (non-separable)": lambda x, y: x**2 * y**2,
        "sin(x) + cos(y) (separable)": lambda x, y: np.sin(x) + np.cos(y),
    }
    for name, f in functions.items():
        err, ratio = test_additive_separability(f, (1, 3), (1, 3))
        print(f"   {name:35s} rel_error={err:.6f}  sv_ratio={ratio:.6f}")

    print("\nDone.")


if __name__ == "__main__":
    main()
