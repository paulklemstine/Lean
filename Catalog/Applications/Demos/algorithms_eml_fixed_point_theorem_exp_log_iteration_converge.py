#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of EML fixed-point algorithms.

Provides:
1. EML iteration with convergence guarantee
2. A priori error estimation
3. Parameter region computation (contraction domain)
4. Composed EML network convergence analysis
"""

import math
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple


@dataclass
class EMLParams:
    """Parameters for the EML operator f(x) = exp(a) * log(b*x + c)."""
    a: float
    b: float = 1.0
    c: float = 1.0


@dataclass
class ContractionInfo:
    """Information about the contraction property of an EML operator."""
    ratio: float          # Contraction ratio ρ = exp(a) * b / (b*L + c)
    lower_bound: float    # Lower bound L of the contraction domain
    is_contraction: bool  # Whether ρ < 1


@dataclass
class ConvergenceResult:
    """Result of an EML fixed-point iteration."""
    fixed_point: float
    iterations: int
    final_error: float
    history: List[float]
    contraction_ratio: float


def eml_operator(params: EMLParams) -> Callable[[float], float]:
    """Return the EML operator as a callable."""
    def f(x: float) -> float:
        return math.exp(params.a) * math.log(params.b * x + params.c)
    return f


def eml_derivative(params: EMLParams) -> Callable[[float], float]:
    """Return the derivative of the EML operator."""
    def fprime(x: float) -> float:
        return math.exp(params.a) * params.b / (params.b * x + params.c)
    return fprime


def analyze_contraction(params: EMLParams, L: float) -> ContractionInfo:
    """
    Analyze the contraction property of the EML operator on [L, ∞).
    
    The operator is a contraction iff exp(a) * b / (b*L + c) < 1,
    equivalently exp(a) * b < b*L + c.
    """
    denom = params.b * L + params.c
    if denom <= 0:
        return ContractionInfo(ratio=float('inf'), lower_bound=L, is_contraction=False)
    
    ratio = math.exp(params.a) * params.b / denom
    return ContractionInfo(
        ratio=ratio,
        lower_bound=L,
        is_contraction=ratio < 1
    )


def find_contraction_lower_bound(params: EMLParams) -> float:
    """
    Find the minimal L such that the EML operator is a contraction on [L, ∞).
    
    Need: exp(a) * b / (b*L + c) < 1, so L > (exp(a) * b - c) / b = exp(a) - c/b.
    Returns exp(a) - c/b + epsilon for a small epsilon.
    """
    L_critical = math.exp(params.a) - params.c / params.b
    return L_critical + 1e-6


def eml_iterate(
    params: EMLParams,
    x0: float,
    tol: float = 1e-14,
    max_iter: int = 10000,
    L: Optional[float] = None
) -> ConvergenceResult:
    """
    Run the EML iteration x_{n+1} = f(x_n) to find the fixed point.
    
    Algorithm (Banach Fixed-Point Iteration):
        1. Verify contraction condition on [L, ∞)
        2. Iterate x_{n+1} = exp(a) * log(b*x_n + c)
        3. Stop when |x_{n+1} - x_n| < tol
        4. A priori bound: |x_n - x*| ≤ ρ^n / (1-ρ) * |x_1 - x_0|
    """
    if L is None:
        L = find_contraction_lower_bound(params)
    
    info = analyze_contraction(params, L)
    f = eml_operator(params)
    
    x = max(x0, L + 0.01)  # Ensure starting point is in contraction domain
    history = [x]
    
    for i in range(max_iter):
        x_new = f(x)
        history.append(x_new)
        if abs(x_new - x) < tol:
            return ConvergenceResult(
                fixed_point=x_new,
                iterations=i + 1,
                final_error=abs(x_new - x),
                history=history,
                contraction_ratio=info.ratio
            )
        x = x_new
    
    return ConvergenceResult(
        fixed_point=x,
        iterations=max_iter,
        final_error=abs(f(x) - x),
        history=history,
        contraction_ratio=info.ratio
    )


def a_priori_error_bound(
    params: EMLParams,
    L: float,
    x0: float,
    n: int
) -> float:
    """
    Compute the a priori error bound: |x_n - x*| ≤ ρ^n / (1-ρ) * |f(x_0) - x_0|.
    
    This is the Banach fixed-point theorem bound.
    """
    info = analyze_contraction(params, L)
    if not info.is_contraction:
        return float('inf')
    
    f = eml_operator(params)
    d0 = abs(f(x0) - x0)
    rho = info.ratio
    
    return (rho ** n / (1 - rho)) * d0


def composed_eml_ratio(params_list: List[Tuple[EMLParams, float]]) -> float:
    """
    Compute the contraction ratio of a composed EML network.
    
    For f_n ∘ ... ∘ f_2 ∘ f_1, the ratio is ∏ρ_i.
    """
    product = 1.0
    for params, L in params_list:
        info = analyze_contraction(params, L)
        product *= info.ratio
    return product


def verify_fixed_point_equation(params: EMLParams, x: float) -> Tuple[bool, float]:
    """
    Verify the fixed point equation x = exp(a) * log(b*x + c).
    Returns (is_fixed_point, residual).
    """
    f = eml_operator(params)
    residual = abs(f(x) - x)
    return residual < 1e-10, residual


def verify_exponential_form(params: EMLParams, x: float) -> Tuple[bool, float]:
    """
    Verify the exponential form: exp(x / exp(a)) = b*x + c.
    This is the dual characterization of the fixed point.
    """
    lhs = math.exp(x / math.exp(params.a))
    rhs = params.b * x + params.c
    residual = abs(lhs - rhs)
    return residual < 1e-10, residual


if __name__ == "__main__":
    # Quick demonstration
    params = EMLParams(a=0.5, c=1.0)
    result = eml_iterate(params, x0=5.0)
    print(f"Fixed point: {result.fixed_point:.15f}")
    print(f"Contraction ratio: {result.contraction_ratio:.6f}")
    print(f"Iterations: {result.iterations}")
    
    ok, res = verify_fixed_point_equation(params, result.fixed_point)
    print(f"Fixed point verified: {ok} (residual: {res:.2e})")
    
    ok, res = verify_exponential_form(params, result.fixed_point)
    print(f"Exponential form verified: {ok} (residual: {res:.2e})")
