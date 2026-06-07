#!/usr/bin/env python3
"""
EML Approximation Filtration — Core Algorithms

Type-hinted implementations of the key algorithms from the EML
Approximation Filtration framework.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
import math


# ============================================================
# Algorithm 1: Horner's Method for Polynomial-to-EML Conversion
# ============================================================

@dataclass
class EMLExprTree:
    """Represents an EML expression tree."""
    kind: str  # 'var', 'lit', 'add', 'mul', 'neg', 'exp', 'log'
    value: Optional[float] = None
    left: Optional['EMLExprTree'] = None
    right: Optional['EMLExprTree'] = None

    def eval(self, x: float) -> float:
        if self.kind == 'var':
            return x
        elif self.kind == 'lit':
            return self.value  # type: ignore
        elif self.kind == 'add':
            return self.left.eval(x) + self.right.eval(x)  # type: ignore
        elif self.kind == 'mul':
            return self.left.eval(x) * self.right.eval(x)  # type: ignore
        elif self.kind == 'neg':
            return -self.left.eval(x)  # type: ignore
        elif self.kind == 'exp':
            return math.exp(self.left.eval(x))  # type: ignore
        elif self.kind == 'log':
            return math.log(max(self.left.eval(x), 1e-300))  # type: ignore
        raise ValueError(f"Unknown kind: {self.kind}")

    def exp_log_depth(self) -> int:
        if self.kind in ('var', 'lit'):
            return 0
        elif self.kind in ('add', 'mul'):
            return max(self.left.exp_log_depth(), self.right.exp_log_depth())  # type: ignore
        elif self.kind == 'neg':
            return self.left.exp_log_depth()  # type: ignore
        elif self.kind in ('exp', 'log'):
            return 1 + self.left.exp_log_depth()  # type: ignore
        raise ValueError(f"Unknown kind: {self.kind}")

    def node_count(self) -> int:
        if self.kind in ('var', 'lit'):
            return 1
        elif self.kind in ('add', 'mul'):
            return 1 + self.left.node_count() + self.right.node_count()  # type: ignore
        else:
            return 1 + self.left.node_count()  # type: ignore

    def transc_count(self) -> int:
        if self.kind in ('var', 'lit'):
            return 0
        elif self.kind in ('add', 'mul'):
            return self.left.transc_count() + self.right.transc_count()  # type: ignore
        elif self.kind == 'neg':
            return self.left.transc_count()  # type: ignore
        elif self.kind in ('exp', 'log'):
            return 1 + self.left.transc_count()  # type: ignore
        raise ValueError(f"Unknown kind: {self.kind}")


def horner_to_eml(coeffs: List[float]) -> EMLExprTree:
    """
    Convert polynomial coefficients to an EML expression via Horner's method.

    Pseudocode:
        HORNER(c[0..n]):
            if n == 0: return LIT(c[0])
            return ADD(LIT(c[0]), MUL(VAR, HORNER(c[1..n])))

    Args:
        coeffs: Polynomial coefficients [c₀, c₁, ..., cₙ] where p(x) = Σ cᵢxⁱ

    Returns:
        EML expression tree evaluating to p(x) using Horner's method
    """
    if len(coeffs) == 1:
        return EMLExprTree('lit', value=coeffs[0])
    inner = horner_to_eml(coeffs[1:])
    return EMLExprTree('add',
                       left=EMLExprTree('lit', value=coeffs[0]),
                       right=EMLExprTree('mul',
                                         left=EMLExprTree('var'),
                                         right=inner))


# ============================================================
# Algorithm 2: Filtration Level Checker
# ============================================================

@dataclass
class ComplexityProfile:
    """The complexity profile of an EML expression."""
    exp_log_depth: int
    node_count: int
    transc_count: int


def check_filtration_level(
    expr: EMLExprTree,
    f: Callable[[float], float],
    a: float, b: float,
    epsilon: float,
    n_points: int = 1000
) -> Tuple[bool, float]:
    """
    Check if an EML expression approximates f on [a,b] to within epsilon.

    Pseudocode:
        CHECK_FILTRATION(expr, f, a, b, ε, N):
            max_err = 0
            for i = 0 to N:
                x = a + i*(b-a)/N
                err = |f(x) - expr.eval(x)|
                max_err = max(max_err, err)
            return (max_err ≤ ε, max_err)

    Returns:
        (is_in_filtration, max_error)
    """
    max_err = 0.0
    for i in range(n_points + 1):
        x = a + i * (b - a) / n_points
        err = abs(f(x) - expr.eval(x))
        max_err = max(max_err, err)
    return max_err <= epsilon, max_err


# ============================================================
# Algorithm 3: Composition Error Bound Calculator
# ============================================================

def composition_error_bound(
    eps_outer: float,
    eps_inner: float,
    lipschitz_const: float
) -> float:
    """
    Compute the composition error bound: ε₁ + L·ε₂.

    Pseudocode:
        COMP_ERROR(ε₁, ε₂, L):
            return ε₁ + L * ε₂

    This is the Composition Contraction Principle:
    If f_outer is L-Lipschitz and approximated to ε₁,
    and f_inner is approximated to ε₂,
    then f_outer ∘ f_inner is approximated to ε₁ + L·ε₂.
    """
    return eps_outer + lipschitz_const * eps_inner


# ============================================================
# Algorithm 4: Information Decay Calculator
# ============================================================

def retained_info(alpha: float, depth: int, k0: float) -> float:
    """
    Compute retained information after 'depth' layers.

    Pseudocode:
        RETAINED_INFO(α, l, K₀):
            return α^l * K₀

    Models exponential information decay through depth.
    """
    return alpha ** depth * k0


def min_depth_for_threshold(
    alpha: float, k0: float, threshold: float
) -> int:
    """
    Find minimum depth where retained information drops below threshold.

    Pseudocode:
        MIN_DEPTH(α, K₀, θ):
            l = 0
            while α^l * K₀ ≥ θ:
                l += 1
            return l
    """
    depth = 0
    while alpha ** depth * k0 >= threshold:
        depth += 1
        if depth > 10000:
            break
    return depth


# ============================================================
# Algorithm 5: Filtration Algebraic Operations
# ============================================================

def eml_add(e1: EMLExprTree, e2: EMLExprTree) -> EMLExprTree:
    """Construct e1 + e2 in the filtration algebra."""
    return EMLExprTree('add', left=e1, right=e2)


def eml_mul(e1: EMLExprTree, e2: EMLExprTree) -> EMLExprTree:
    """Construct e1 * e2 in the filtration algebra."""
    return EMLExprTree('mul', left=e1, right=e2)


def eml_neg(e: EMLExprTree) -> EMLExprTree:
    """Construct -e in the filtration algebra."""
    return EMLExprTree('neg', left=e)


def filtration_add_profile(
    p1: ComplexityProfile, eps1: float,
    p2: ComplexityProfile, eps2: float
) -> Tuple[ComplexityProfile, float]:
    """
    Compute the filtration profile of e1 + e2.

    Returns (profile, new_epsilon) where:
    - depth = max(d1, d2)
    - size = s1 + s2 + 1
    - epsilon = eps1 + eps2
    """
    return (
        ComplexityProfile(
            exp_log_depth=max(p1.exp_log_depth, p2.exp_log_depth),
            node_count=p1.node_count + p2.node_count + 1,
            transc_count=p1.transc_count + p2.transc_count
        ),
        eps1 + eps2
    )


def filtration_mul_profile(
    p1: ComplexityProfile, eps1: float, bound1: float,
    p2: ComplexityProfile, eps2: float, bound2: float
) -> Tuple[ComplexityProfile, float]:
    """
    Compute the filtration profile of e1 * e2.

    Returns (profile, new_epsilon) where:
    - depth = max(d1, d2)
    - size = s1 + s2 + 1
    - epsilon = eps1 * bound2 + eps2 * bound1 + eps1 * eps2
    """
    return (
        ComplexityProfile(
            exp_log_depth=max(p1.exp_log_depth, p2.exp_log_depth),
            node_count=p1.node_count + p2.node_count + 1,
            transc_count=p1.transc_count + p2.transc_count
        ),
        eps1 * bound2 + eps2 * bound1 + eps1 * eps2
    )


# ============================================================
# Main: Run demonstrations
# ============================================================

if __name__ == "__main__":
    # Demo: Horner approximation of sin(x)
    coeffs = [0, 1, 0, -1/6, 0, 1/120, 0, -1/5040]  # degree 7
    expr = horner_to_eml(coeffs)
    print(f"Horner EML for sin(x) (degree 7):")
    print(f"  exp_log_depth = {expr.exp_log_depth()}")
    print(f"  node_count = {expr.node_count()}")
    print(f"  transc_count = {expr.transc_count()}")

    in_filt, max_err = check_filtration_level(expr, math.sin, 0, math.pi, 0.01)
    print(f"  In F(0, {expr.node_count()}, 0.01)? {in_filt} (max error = {max_err:.6e})")

    # Demo: composition error
    bound = composition_error_bound(0.001, 0.01, math.e)
    print(f"\nComposition error bound: ε₁=0.001, ε₂=0.01, L=e")
    print(f"  Bound = {bound:.6f}")

    # Demo: information decay
    print(f"\nInformation decay (α=0.8, K₀=100):")
    for d in [1, 5, 10, 20]:
        print(f"  depth {d:2d}: retained = {retained_info(0.8, d, 100):.4f}")
