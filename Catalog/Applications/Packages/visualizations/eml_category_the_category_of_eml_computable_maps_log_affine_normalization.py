#!/usr/bin/env python3
"""
EML Category Algorithms
========================
Implementations of the core algorithms from the EML category theory:
1. Log-affine normalization (verified in LogAffineNormal.lean)
2. Expression depth and size analysis
3. Composition of EML maps in log-affine normal form
4. Random EML expression generation for testing
"""

import math
import random
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict


# ============================================================
# Core Data Types
# ============================================================

class PosEMLExpr:
    """Abstract base for multiplicative positive EML expressions."""
    pass

@dataclass
class Coord(PosEMLExpr):
    """Coordinate projection x_i."""
    i: int
    def __repr__(self): return f"x[{self.i}]"

@dataclass
class PosConst(PosEMLExpr):
    """Positive constant c > 0."""
    c: float
    def __repr__(self): return f"{self.c:.4g}"

@dataclass
class Mul(PosEMLExpr):
    """Product e1 * e2."""
    e1: PosEMLExpr
    e2: PosEMLExpr
    def __repr__(self): return f"({self.e1} * {self.e2})"

@dataclass
class RPow(PosEMLExpr):
    """Real power e^r."""
    e: PosEMLExpr
    r: float
    def __repr__(self): return f"({self.e})^{self.r:.4g}"


@dataclass
class LogAffineForm:
    """
    Log-affine normal form: exp(sum_i w[i] * log(x[i]) + c).

    This represents a weighted geometric monomial:
    prod_i x[i]^w[i] * exp(c)
    """
    weights: List[float]
    constant: float
    dim: int

    def evaluate(self, x: List[float]) -> float:
        """Evaluate on a positive vector."""
        assert len(x) == self.dim
        return math.exp(
            sum(self.weights[i] * math.log(x[i]) for i in range(self.dim))
            + self.constant
        )

    def __repr__(self):
        terms = []
        for i, w in enumerate(self.weights):
            if abs(w) > 1e-12:
                terms.append(f"{w:.4g}·log(x[{i}])")
        c_str = f" + {self.constant:.4g}" if abs(self.constant) > 1e-12 else ""
        return f"exp({' + '.join(terms) if terms else '0'}{c_str})"


# ============================================================
# Algorithm 1: Log-Affine Normalization
# ============================================================

def normalize(expr: PosEMLExpr, dim: int) -> LogAffineForm:
    """
    Normalize a multiplicative positive EML expression to log-affine form.

    This is the verified algorithm from LogAffineNormal.lean:
    - Coord(i) → weights = e_i, c = 0
    - PosConst(c) → weights = 0, c = log(c)
    - Mul(e1, e2) → weights = w1 + w2, c = c1 + c2
    - RPow(e, r) → weights = r * w, c = r * c

    Time complexity: O(n * |expr|) where n = dim, |expr| = expression size
    Space complexity: O(n * depth(expr)) for the recursion stack

    Args:
        expr: A multiplicative positive EML expression
        dim: Input dimension

    Returns:
        LogAffineForm equivalent to the expression
    """
    if isinstance(expr, Coord):
        w = [0.0] * dim
        w[expr.i] = 1.0
        return LogAffineForm(w, 0.0, dim)

    elif isinstance(expr, PosConst):
        return LogAffineForm([0.0] * dim, math.log(expr.c), dim)

    elif isinstance(expr, Mul):
        f1 = normalize(expr.e1, dim)
        f2 = normalize(expr.e2, dim)
        return LogAffineForm(
            [f1.weights[i] + f2.weights[i] for i in range(dim)],
            f1.constant + f2.constant,
            dim
        )

    elif isinstance(expr, RPow):
        f = normalize(expr.e, dim)
        return LogAffineForm(
            [expr.r * w for w in f.weights],
            expr.r * f.constant,
            dim
        )

    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Algorithm 2: Composition of Log-Affine Maps
# ============================================================

def compose_log_affine(
    outer: LogAffineForm,
    inners: List[LogAffineForm]
) -> LogAffineForm:
    """
    Compose a scalar log-affine map with a vector of log-affine maps.

    Given outer: R^m -> R with form exp(sum_j v[j] * log(y[j]) + d)
    and inners: R^n -> R^m with inner[j] = exp(sum_i w_j[i] * log(x[i]) + c_j),

    the composition is:
    outer(inner(x)) = exp(sum_j v[j] * (sum_i w_j[i]*log(x[i]) + c_j) + d)
                     = exp(sum_i (sum_j v[j]*w_j[i]) * log(x[i]) + (sum_j v[j]*c_j + d))

    This shows that composition of log-affine maps is log-affine,
    which is the content of vecEMLComp_comp restricted to the multiplicative fragment.

    Time complexity: O(n * m)
    """
    assert len(inners) == outer.dim, "Dimension mismatch"
    n = inners[0].dim if inners else 0

    # Compute composed weights: w'[i] = sum_j v[j] * w_j[i]
    new_weights = [0.0] * n
    for j in range(outer.dim):
        for i in range(n):
            new_weights[i] += outer.weights[j] * inners[j].weights[i]

    # Compute composed constant: c' = sum_j v[j] * c_j + d
    new_constant = outer.constant
    for j in range(outer.dim):
        new_constant += outer.weights[j] * inners[j].constant

    return LogAffineForm(new_weights, new_constant, n)


# ============================================================
# Algorithm 3: Random Expression Generation
# ============================================================

def random_pos_eml(dim: int, max_depth: int = 4) -> PosEMLExpr:
    """
    Generate a random multiplicative positive EML expression.

    Used for testing the normalization theorem:
    for any generated expression, evaluate(expr, x) should equal
    normalize(expr, dim).evaluate(x) for all positive x.
    """
    if max_depth <= 0 or random.random() < 0.3:
        # Base case: coordinate or constant
        if random.random() < 0.6:
            return Coord(random.randint(0, dim - 1))
        else:
            return PosConst(random.uniform(0.1, 10.0))
    else:
        choice = random.random()
        if choice < 0.5:
            return Mul(
                random_pos_eml(dim, max_depth - 1),
                random_pos_eml(dim, max_depth - 1)
            )
        else:
            return RPow(
                random_pos_eml(dim, max_depth - 1),
                random.uniform(-3.0, 3.0)
            )


def evaluate_expr(expr: PosEMLExpr, x: List[float]) -> float:
    """Direct evaluation of a PosEMLExpr."""
    if isinstance(expr, Coord):
        return x[expr.i]
    elif isinstance(expr, PosConst):
        return expr.c
    elif isinstance(expr, Mul):
        return evaluate_expr(expr.e1, x) * evaluate_expr(expr.e2, x)
    elif isinstance(expr, RPow):
        return evaluate_expr(expr.e, x) ** expr.r
    else:
        raise ValueError(f"Unknown: {type(expr)}")


# ============================================================
# Algorithm 4: Expression Analysis
# ============================================================

def expr_depth(expr: PosEMLExpr) -> int:
    """Compute the depth of an expression tree."""
    if isinstance(expr, (Coord, PosConst)):
        return 0
    elif isinstance(expr, Mul):
        return 1 + max(expr_depth(expr.e1), expr_depth(expr.e2))
    elif isinstance(expr, RPow):
        return 1 + expr_depth(expr.e)
    return 0

def expr_size(expr: PosEMLExpr) -> int:
    """Compute the number of nodes in an expression tree."""
    if isinstance(expr, (Coord, PosConst)):
        return 1
    elif isinstance(expr, Mul):
        return 1 + expr_size(expr.e1) + expr_size(expr.e2)
    elif isinstance(expr, RPow):
        return 1 + expr_size(expr.e)
    return 1


# ============================================================
# Verification tests
# ============================================================

def test_normalization(num_tests: int = 100, dim: int = 3):
    """
    Empirically verify the normalization theorem:
    for random expressions, direct evaluation matches normal form evaluation.
    """
    print(f"Testing normalization on {num_tests} random expressions (dim={dim})...")
    max_error = 0.0
    for trial in range(num_tests):
        expr = random_pos_eml(dim, max_depth=4)
        nf = normalize(expr, dim)
        x = [random.uniform(0.1, 5.0) for _ in range(dim)]

        direct = evaluate_expr(expr, x)
        normal = nf.evaluate(x)

        if direct > 0 and normal > 0:
            # Use relative error in log space for numerical stability
            err = abs(math.log(direct) - math.log(normal))
            max_error = max(max_error, err)

    print(f"  Max log-space error: {max_error:.2e}")
    print(f"  Status: {'PASS' if max_error < 1e-8 else 'FAIL'}")
    return max_error < 1e-8


def test_composition(num_tests: int = 50, dim: int = 3):
    """
    Test that composition of log-affine maps produces correct results.
    """
    print(f"Testing composition on {num_tests} random pairs (dim={dim})...")
    max_error = 0.0
    for _ in range(num_tests):
        m = random.randint(1, 4)
        # Random outer function R^m -> R
        outer = LogAffineForm(
            [random.uniform(-2, 2) for _ in range(m)],
            random.uniform(-1, 1), m
        )
        # Random inner functions R^dim -> R, one per coordinate
        inners = [
            LogAffineForm(
                [random.uniform(-2, 2) for _ in range(dim)],
                random.uniform(-1, 1), dim
            ) for _ in range(m)
        ]

        composed = compose_log_affine(outer, inners)
        x = [random.uniform(0.1, 5.0) for _ in range(dim)]

        # Direct: outer(inner1(x), ..., innerm(x))
        inner_vals = [f.evaluate(x) for f in inners]
        direct = outer.evaluate(inner_vals)
        normal = composed.evaluate(x)

        if direct > 0 and normal > 0:
            err = abs(math.log(direct) - math.log(normal))
            max_error = max(max_error, err)

    print(f"  Max log-space error: {max_error:.2e}")
    print(f"  Status: {'PASS' if max_error < 1e-8 else 'FAIL'}")
    return max_error < 1e-8


if __name__ == "__main__":
    print("EML Category Algorithms — Verification Tests")
    print("=" * 60)
    print()

    random.seed(42)
    ok1 = test_normalization()
    print()
    ok2 = test_composition()
    print()

    if ok1 and ok2:
        print("All tests PASSED.")
    else:
        print("Some tests FAILED.")
