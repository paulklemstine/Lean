#!/usr/bin/env python3
"""
EML Filtered Approximation Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional
import math


# ============================================================
# Algorithm 1: EML Expression Tree with Evaluation
# ============================================================

@dataclass
class EMLNode:
    """Base class for EML expression nodes."""
    pass

@dataclass
class VarNode(EMLNode):
    """Variable node: evaluates to the input."""
    pass

@dataclass
class ConstNode(EMLNode):
    """Constant node."""
    value: float

@dataclass
class AddNode(EMLNode):
    """Addition: left + right."""
    left: EMLNode
    right: EMLNode

@dataclass
class MulNode(EMLNode):
    """Multiplication: left * right."""
    left: EMLNode
    right: EMLNode

@dataclass
class NegNode(EMLNode):
    """Negation: -child."""
    child: EMLNode

@dataclass
class InvNode(EMLNode):
    """Inversion: 1/child."""
    child: EMLNode

@dataclass
class EmlNode(EMLNode):
    """EML primitive: coeff * exp(exponent)."""
    coeff: EMLNode
    exponent: EMLNode


def eml_eval(node: EMLNode, x: float) -> float:
    """Evaluate an EML expression tree at point x."""
    if isinstance(node, VarNode):
        return x
    elif isinstance(node, ConstNode):
        return node.value
    elif isinstance(node, AddNode):
        return eml_eval(node.left, x) + eml_eval(node.right, x)
    elif isinstance(node, MulNode):
        return eml_eval(node.left, x) * eml_eval(node.right, x)
    elif isinstance(node, NegNode):
        return -eml_eval(node.child, x)
    elif isinstance(node, InvNode):
        v = eml_eval(node.child, x)
        return 1.0 / v if v != 0 else float('inf')
    elif isinstance(node, EmlNode):
        a = eml_eval(node.coeff, x)
        b = eml_eval(node.exponent, x)
        return a * math.exp(min(b, 500))  # overflow protection
    else:
        raise ValueError(f"Unknown node type: {type(node)}")


def eml_size(node: EMLNode) -> int:
    """Compute the size (number of nodes) of an EML expression."""
    if isinstance(node, (VarNode, ConstNode)):
        return 1
    elif isinstance(node, (AddNode, MulNode, EmlNode)):
        return 1 + eml_size(node.left if hasattr(node, 'left') else node.coeff) + \
               eml_size(node.right if hasattr(node, 'right') else node.exponent)
    elif isinstance(node, (NegNode, InvNode)):
        return 1 + eml_size(node.child)
    return 0


def eml_depth(node: EMLNode) -> int:
    """Compute the EML depth (maximum eml-nesting depth)."""
    if isinstance(node, (VarNode, ConstNode)):
        return 0
    elif isinstance(node, (AddNode, MulNode)):
        return max(eml_depth(node.left), eml_depth(node.right))
    elif isinstance(node, (NegNode, InvNode)):
        return eml_depth(node.child)
    elif isinstance(node, EmlNode):
        return 1 + max(eml_depth(node.coeff), eml_depth(node.exponent))
    return 0


# ============================================================
# Algorithm 2: Iterated Exponential Tower Construction
# ============================================================

def build_iter_exp_expr(n: int) -> EMLNode:
    """
    Build the canonical EML expression for exp^n(x).
    
    tower(0) = var
    tower(n+1) = eml(const(1), tower(n))
    
    Properties:
        - size = 2n + 1
        - eml_depth = n
        - eval(x) = exp^n(x)
    """
    if n == 0:
        return VarNode()
    return EmlNode(ConstNode(1.0), build_iter_exp_expr(n - 1))


# ============================================================
# Algorithm 3: Polynomial-to-EML via Horner's Method
# ============================================================

def horner_to_eml(coefficients: List[float]) -> EMLNode:
    """
    Convert polynomial coefficients [c₀, c₁, ..., cₙ] to EML expression
    using Horner's method.
    
    Result: c₀ + x*(c₁ + x*(c₂ + ... + x*cₙ))
    
    Properties:
        - eml_depth = 0 (no transcendental operations)
        - size = O(n)
    """
    if len(coefficients) == 0:
        return ConstNode(0.0)
    if len(coefficients) == 1:
        return ConstNode(coefficients[0])
    
    # Build from innermost coefficient outward
    result: EMLNode = ConstNode(coefficients[-1])
    for i in range(len(coefficients) - 2, -1, -1):
        result = AddNode(ConstNode(coefficients[i]), MulNode(VarNode(), result))
    return result


# ============================================================
# Algorithm 4: EML Approximation Chain
# ============================================================

@dataclass
class ApproxChainEntry:
    """One entry in an EML approximation chain."""
    expr: EMLNode
    error_bound: float


def build_taylor_approx_chain(
    f: Callable[[float], float],
    coefficients_fn: Callable[[int], List[float]],
    a: float, b: float,
    max_terms: int = 10
) -> List[ApproxChainEntry]:
    """
    Build an approximation chain for f on [a, b] using Taylor-like expansions.
    
    Args:
        f: target function
        coefficients_fn: function mapping n -> first n+1 Taylor coefficients
        a, b: interval endpoints
        max_terms: maximum number of terms
    
    Returns:
        List of (expression, error_bound) pairs with decreasing errors
    """
    chain: List[ApproxChainEntry] = []
    
    for n in range(1, max_terms + 1):
        coeffs = coefficients_fn(n)
        expr = horner_to_eml(coeffs)
        
        # Compute maximum error on [a, b]
        max_error = 0.0
        num_points = 200
        for i in range(num_points + 1):
            x = a + (b - a) * i / num_points
            error = abs(f(x) - eml_eval(expr, x))
            max_error = max(max_error, error)
        
        chain.append(ApproxChainEntry(expr, max_error))
    
    return chain


# ============================================================
# Algorithm 5: EML Complexity Spectrum Estimation
# ============================================================

def estimate_complexity_spectrum(
    f: Callable[[float], float],
    a: float, b: float,
    max_size: int = 50,
    num_test_points: int = 100
) -> List[Tuple[int, float]]:
    """
    Estimate the EML complexity spectrum of f on [a, b].
    
    For each size budget n, find the best achievable approximation error
    using polynomial (Horner) EML expressions of that size.
    
    Returns: list of (size, min_error) pairs
    """
    spectrum: List[Tuple[int, float]] = []
    
    # Use Taylor coefficients of exp as a proxy
    # For general f, this would use optimization
    for n_terms in range(1, max_size // 2 + 1):
        # Build Chebyshev-like polynomial approximation
        # Using Taylor around midpoint
        mid = (a + b) / 2
        half = (b - a) / 2
        
        coeffs = []
        factorial = 1.0
        f_val = f(mid)
        # Simple Taylor approximation
        h = 1e-6
        derivs = [f(mid)]
        for k in range(1, n_terms):
            # Numerical derivative (crude but functional)
            factorial *= k
            # Use central differences
            deriv_val = 0.0
            for j in range(k + 1):
                sign = (-1) ** (k - j)
                binom = math.comb(k, j)
                deriv_val += sign * binom * f(mid + (j - k/2) * h)
            deriv_val /= h ** k
            derivs.append(deriv_val)
        
        coeffs = [derivs[i] / math.factorial(i) for i in range(n_terms)]
        
        # Shift to evaluate at (x - mid)
        # For simplicity, evaluate directly
        expr = horner_to_eml(coeffs)
        
        max_error = 0.0
        for i in range(num_test_points + 1):
            x = a + (b - a) * i / num_test_points
            # Evaluate at (x - mid) since Taylor is centered there
            error = abs(f(x) - eml_eval(expr, x - mid))
            max_error = max(max_error, error)
        
        expr_size = eml_size(expr)
        spectrum.append((expr_size, max_error))
    
    return spectrum


# ============================================================
# Algorithm 6: Information Decay Calculator
# ============================================================

def compute_information_decay(
    alpha: float,
    initial_info: float,
    max_layers: int = 20
) -> List[Tuple[int, float]]:
    """
    Compute retained symbolic information through layers.
    
    I(l) = alpha^l * K
    
    Args:
        alpha: per-layer contraction factor in [0, 1]
        initial_info: initial information K
        max_layers: number of layers to compute
    
    Returns:
        list of (layer, retained_info) pairs
    """
    return [(l, alpha ** l * initial_info) for l in range(max_layers + 1)]


def compute_depth_complexity_tradeoff(
    threshold: float,
    alpha: float,
    max_depth: int = 20
) -> List[Tuple[int, float]]:
    """
    Compute minimum initial complexity K needed at each depth l
    to retain at least `threshold` information.
    
    K >= threshold / alpha^l
    """
    return [(l, threshold / (alpha ** l) if alpha > 0 else float('inf'))
            for l in range(max_depth + 1)]


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("EML Algorithms Demo")
    print("=" * 60)
    
    # Algorithm 1 & 2: Iterated exponential towers
    print("\n--- Iterated Exponential Towers ---")
    for n in range(5):
        expr = build_iter_exp_expr(n)
        print(f"  exp^{n}: size={eml_size(expr)}, depth={eml_depth(expr)}, "
              f"eval(0.5)={eml_eval(expr, 0.5):.6f}")
    
    # Algorithm 3: Polynomial conversion
    print("\n--- Polynomial-to-EML (Horner) ---")
    coeffs = [1, 1, 0.5, 1/6, 1/24]  # exp Taylor coefficients
    expr = horner_to_eml(coeffs)
    print(f"  Taylor exp(x) ≈ 1 + x + x²/2 + x³/6 + x⁴/24")
    print(f"  Size: {eml_size(expr)}, Depth: {eml_depth(expr)}")
    print(f"  eval(1.0) = {eml_eval(expr, 1.0):.6f} (exact: {math.e:.6f})")
    
    # Algorithm 4: Approximation chain
    print("\n--- Approximation Chain for exp(x) on [0, 1] ---")
    def exp_coeffs(n: int) -> List[float]:
        return [1.0 / math.factorial(i) for i in range(n)]
    
    chain = build_taylor_approx_chain(math.exp, exp_coeffs, 0, 1, max_terms=8)
    for i, entry in enumerate(chain):
        print(f"  Step {i+1}: size={eml_size(entry.expr)}, error={entry.error_bound:.2e}")
    
    # Algorithm 6: Information decay
    print("\n--- Information Decay (α=0.7, K=100) ---")
    decay = compute_information_decay(0.7, 100, max_layers=10)
    for l, info in decay:
        print(f"  Layer {l}: retained = {info:.4f}")
