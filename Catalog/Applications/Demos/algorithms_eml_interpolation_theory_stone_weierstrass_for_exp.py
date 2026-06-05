#!/usr/bin/env python3
"""
EML Interpolation Algorithms

Type-hinted implementations of the core algorithms from the
EML Interpolation Theory research.
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, List, Tuple, Optional
import math


# ============================================================
# Core Data Structures
# ============================================================

class EMLOp(Enum):
    """Operations in an EML term."""
    CONST = auto()
    VAR = auto()
    EXP = auto()
    LOG = auto()
    ADD = auto()
    MUL = auto()


@dataclass
class EMLTerm:
    """An EML expression tree.

    Represents a function built from constants, variables,
    exp, log, addition, and multiplication.
    """
    op: EMLOp
    value: Optional[float] = None  # For CONST
    left: Optional['EMLTerm'] = None
    right: Optional['EMLTerm'] = None

    def eval(self, x: float) -> float:
        """Evaluate the EML term at point x."""
        if self.op == EMLOp.CONST:
            return self.value or 0.0
        elif self.op == EMLOp.VAR:
            return x
        elif self.op == EMLOp.EXP:
            assert self.left is not None
            return math.exp(self.left.eval(x))
        elif self.op == EMLOp.LOG:
            assert self.left is not None
            return math.log(self.left.eval(x))
        elif self.op == EMLOp.ADD:
            assert self.left is not None and self.right is not None
            return self.left.eval(x) + self.right.eval(x)
        elif self.op == EMLOp.MUL:
            assert self.left is not None and self.right is not None
            return self.left.eval(x) * self.right.eval(x)
        raise ValueError(f"Unknown op: {self.op}")

    @property
    def depth(self) -> int:
        """Composition depth of the EML term."""
        if self.op in (EMLOp.CONST, EMLOp.VAR):
            return 0
        elif self.op in (EMLOp.EXP, EMLOp.LOG):
            assert self.left is not None
            return self.left.depth + 1
        else:
            assert self.left is not None and self.right is not None
            return max(self.left.depth, self.right.depth)

    @property
    def size(self) -> int:
        """Number of nodes in the EML term."""
        if self.op in (EMLOp.CONST, EMLOp.VAR):
            return 1
        elif self.op in (EMLOp.EXP, EMLOp.LOG):
            assert self.left is not None
            return self.left.size + 1
        else:
            assert self.left is not None and self.right is not None
            return self.left.size + self.right.size + 1


# ============================================================
# EML Kernel
# ============================================================

def eml_kernel(x: float, y: float) -> float:
    """EML interpolation kernel K(x,y) = exp(-(log(x/y))^2).

    Properties (proved in Lean):
    - Symmetric: K(x,y) = K(y,x)
    - Peak: K(x,x) = 1
    - Off-diagonal: K(x,y) < 1 for x ≠ y
    - Nonneg: K(x,y) ≥ 0
    - Lower bound: K(x,y) ≥ exp(-δ²) when |log(x)-log(y)| ≤ δ
    """
    return math.exp(-(math.log(x / y))**2)


def log_diam(a: float, b: float) -> float:
    """Log-diameter of interval [a,b] ⊂ (0,∞)."""
    return math.log(b) - math.log(a)


# ============================================================
# EML Approximation Algorithms
# ============================================================

def eml_constant_approx(
    f: Callable[[float], float],
    a: float, b: float
) -> EMLTerm:
    """Construct constant EML approximation g = f(a).

    For L-Lipschitz f, achieves error ≤ L·(b-a).
    """
    return EMLTerm(op=EMLOp.CONST, value=f(a))


def eml_polynomial_approx(
    f: Callable[[float], float],
    a: float, b: float,
    degree: int
) -> Tuple[EMLTerm, float]:
    """Construct polynomial EML approximation of given degree.

    Uses Chebyshev nodes for near-optimal approximation.
    Returns (term, max_error).
    """
    import numpy as np

    # Chebyshev nodes on [a,b]
    k = np.arange(degree + 1)
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos(np.pi * k / degree)
    values = np.array([f(xi) for xi in nodes])

    # Polynomial interpolation coefficients
    coeffs = np.polyfit(nodes, values, degree)

    # Build EML term for polynomial
    # p(x) = c_0 * x^n + c_1 * x^{n-1} + ... + c_n
    # Using Horner's method: (...((c_0 * x + c_1) * x + c_2) * x + ...)
    term = EMLTerm(op=EMLOp.CONST, value=float(coeffs[0]))
    for c in coeffs[1:]:
        # term = term * x + c
        term = EMLTerm(
            op=EMLOp.ADD,
            left=EMLTerm(
                op=EMLOp.MUL,
                left=term,
                right=EMLTerm(op=EMLOp.VAR)
            ),
            right=EMLTerm(op=EMLOp.CONST, value=float(c))
        )

    # Estimate error
    x_dense = np.linspace(a, b, 1000)
    f_vals = np.array([f(xi) for xi in x_dense])
    approx_vals = np.polyval(coeffs, x_dense)
    max_error = float(np.max(np.abs(f_vals - approx_vals)))

    return term, max_error


def eml_kernel_interpolation(
    x_data: List[float],
    y_data: List[float],
    bandwidth: float = 1.0
) -> Callable[[float], float]:
    """Kernel interpolation using the EML kernel.

    Given data points (x_i, y_i), constructs the interpolant
    f(x) = Σ_i w_i · K(x, x_i) where weights w are determined
    by solving K·w = y.
    """
    import numpy as np

    n = len(x_data)
    x = np.array(x_data)
    y = np.array(y_data)

    # Build kernel matrix with bandwidth
    K = np.array([
        [math.exp(-(math.log(x[i] / x[j]))**2 / bandwidth**2)
         for j in range(n)]
        for i in range(n)
    ])

    # Solve for weights
    weights = np.linalg.solve(K, y)

    def interpolant(t: float) -> float:
        k_vec = np.array([
            math.exp(-(math.log(t / x[j]))**2 / bandwidth**2)
            for j in range(n)
        ])
        return float(k_vec @ weights)

    return interpolant


# ============================================================
# Vandermonde Matrix
# ============================================================

def eml_vandermonde(x: List[float]) -> List[List[float]]:
    """Construct EML Vandermonde matrix V[i,j] = x[i]^j.

    Non-degenerate when x values are distinct (proved in Lean).
    """
    n = len(x)
    return [[xi**j for j in range(n)] for xi in x]


def vandermonde_det(x: List[float]) -> float:
    """Compute Vandermonde determinant = ∏_{i<j} (x_j - x_i)."""
    n = len(x)
    det = 1.0
    for i in range(n):
        for j in range(i + 1, n):
            det *= (x[j] - x[i])
    return det


# ============================================================
# Depth Hierarchy
# ============================================================

def exp_tower(n: int, x: float) -> float:
    """Iterated exponential tower of height n.

    expTower(0, x) = x
    expTower(n+1, x) = exp(expTower(n, x))
    """
    result = x
    for _ in range(n):
        result = math.exp(result)
    return result


def build_exp_tower_term(n: int) -> EMLTerm:
    """Build EML term for expTower(n, ·) with depth exactly n."""
    term = EMLTerm(op=EMLOp.VAR)
    for _ in range(n):
        term = EMLTerm(op=EMLOp.EXP, left=term)
    return term


# ============================================================
# EML Modulus of Continuity
# ============================================================

def eml_modulus(
    f: Callable[[float], float],
    a: float, b: float,
    delta: float,
    n_samples: int = 1000
) -> float:
    """Estimate EML modulus of continuity ω_EML(f, δ) on [a,b].

    ω_EML(δ) = sup{|f(x)-f(y)| : x,y ∈ [a,b], |log(x)-log(y)| ≤ δ}
    """
    import numpy as np

    x = np.exp(np.linspace(np.log(a), np.log(b), n_samples))
    max_diff = 0.0
    for i in range(n_samples):
        for j in range(i, n_samples):
            if abs(np.log(x[i]) - np.log(x[j])) <= delta:
                diff = abs(f(x[i]) - f(x[j]))
                max_diff = max(max_diff, diff)
    return max_diff


if __name__ == "__main__":
    # Quick self-test
    print("EML Algorithms self-test:")

    # Test kernel
    assert abs(eml_kernel(2.0, 2.0) - 1.0) < 1e-10
    assert eml_kernel(2.0, 3.0) < 1.0
    assert eml_kernel(2.0, 3.0) > 0.0
    assert abs(eml_kernel(2.0, 3.0) - eml_kernel(3.0, 2.0)) < 1e-10
    print("  ✓ Kernel properties verified")

    # Test Vandermonde
    x = [1.0, 2.0, 4.0]
    det_computed = vandermonde_det(x)
    assert abs(det_computed - 6.0) < 1e-10  # (2-1)(4-1)(4-2) = 1*3*2 = 6
    print("  ✓ Vandermonde determinant verified")

    # Test depth hierarchy
    term = build_exp_tower_term(3)
    assert term.depth == 3
    print(f"  ✓ Depth-3 tower term has depth {term.depth}")

    # Test constant approximation
    t = eml_constant_approx(lambda x: x**2, 1.0, 3.0)
    assert abs(t.eval(1.0) - 1.0) < 1e-10
    print("  ✓ Constant approximation verified")

    print("\nAll self-tests passed!")
