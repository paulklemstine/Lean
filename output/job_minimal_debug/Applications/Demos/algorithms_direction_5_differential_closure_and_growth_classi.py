#!/usr/bin/env python3
"""
Algorithms for Differential Spectrum Computation

Implements the key algorithms from the research paper:
1. Certified differential spectrum computation for EML expressions
2. Depth-preserving symbolic differentiation
3. Hardy level classification
"""

from typing import List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import math


# ═══════════════════════════════════════════════════════════
# Algorithm 1: PosEMLExpr with Certified Depth
# ═══════════════════════════════════════════════════════════

class ExprKind(Enum):
    CONST = "const"
    VAR = "var"
    ADD = "add"
    MUL = "mul"
    EXP = "exp"


@dataclass
class CertifiedExpr:
    """
    A PosEMLExpr with a certified depth bound.
    
    Invariant: self.cert_depth == self.compute_depth()
    This mirrors the Lean `certifiedDeriv` construction.
    """
    kind: ExprKind
    value: Optional[float] = None  # for CONST
    left: Optional['CertifiedExpr'] = None
    right: Optional['CertifiedExpr'] = None
    child: Optional['CertifiedExpr'] = None  # for EXP
    cert_depth: int = 0
    
    @staticmethod
    def const(c: float) -> 'CertifiedExpr':
        return CertifiedExpr(ExprKind.CONST, value=c, cert_depth=0)
    
    @staticmethod
    def var() -> 'CertifiedExpr':
        return CertifiedExpr(ExprKind.VAR, cert_depth=0)
    
    @staticmethod
    def add(a: 'CertifiedExpr', b: 'CertifiedExpr') -> 'CertifiedExpr':
        return CertifiedExpr(ExprKind.ADD, left=a, right=b,
                           cert_depth=max(a.cert_depth, b.cert_depth))
    
    @staticmethod
    def mul(a: 'CertifiedExpr', b: 'CertifiedExpr') -> 'CertifiedExpr':
        return CertifiedExpr(ExprKind.MUL, left=a, right=b,
                           cert_depth=max(a.cert_depth, b.cert_depth))
    
    @staticmethod
    def exp(a: 'CertifiedExpr') -> 'CertifiedExpr':
        return CertifiedExpr(ExprKind.EXP, child=a,
                           cert_depth=a.cert_depth + 1)
    
    def eval(self, x: float) -> float:
        """Evaluate the expression at x."""
        if self.kind == ExprKind.CONST:
            return self.value
        elif self.kind == ExprKind.VAR:
            return x
        elif self.kind == ExprKind.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprKind.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprKind.EXP:
            v = self.child.eval(x)
            return math.exp(min(v, 700))
    
    def certified_deriv(self) -> 'CertifiedExpr':
        """
        Compute the symbolic derivative with a certified depth bound.
        
        Returns a CertifiedExpr whose cert_depth is guaranteed to be
        ≤ self.cert_depth (depth-preserving property).
        
        Time complexity: O(n) where n is the expression size.
        Space complexity: O(n) for the new expression tree.
        
        Correctness certificate: cert_depth(deriv(e)) ≤ cert_depth(e)
        This is verified in Lean as PosEMLExpr.depth_deriv_le_self.
        """
        if self.kind == ExprKind.CONST:
            return CertifiedExpr.const(0)
        elif self.kind == ExprKind.VAR:
            return CertifiedExpr.const(1)
        elif self.kind == ExprKind.ADD:
            ld = self.left.certified_deriv()
            rd = self.right.certified_deriv()
            result = CertifiedExpr.add(ld, rd)
            # Certificate: depth(a'+b') = max(depth(a'), depth(b'))
            #   ≤ max(depth(a), depth(b)) = depth(a+b)
            assert result.cert_depth <= self.cert_depth
            return result
        elif self.kind == ExprKind.MUL:
            ld = self.left.certified_deriv()
            rd = self.right.certified_deriv()
            # Product rule: (a*b)' = a'*b + a*b'
            term1 = CertifiedExpr.mul(ld, self.right)
            term2 = CertifiedExpr.mul(self.left, rd)
            result = CertifiedExpr.add(term1, term2)
            assert result.cert_depth <= self.cert_depth
            return result
        elif self.kind == ExprKind.EXP:
            cd = self.child.certified_deriv()
            # Chain rule: (exp(a))' = a' * exp(a)
            result = CertifiedExpr.mul(cd, CertifiedExpr.exp(self.child))
            # Certificate: depth(a'*exp(a)) = max(depth(a'), depth(a)+1)
            #   = depth(a)+1 = depth(exp(a))  since depth(a') ≤ depth(a)
            assert result.cert_depth <= self.cert_depth
            return result


# ═══════════════════════════════════════════════════════════
# Algorithm 2: Differential Spectrum Computation
# ═══════════════════════════════════════════════════════════

def compute_diff_spectrum(e: CertifiedExpr, max_k: int = 10) -> List[int]:
    """
    Compute the differential spectrum of e.
    
    Returns [depth(e), depth(e'), depth(e''), ...] up to max_k terms.
    
    Certified property: the spectrum is non-increasing.
    For depth ≥ 1, the spectrum is constant (by depth_deriv_eq_of_pos).
    
    Time complexity: O(k * n_k) where n_k is the size of the k-th derivative.
                     Note: n_k can grow exponentially with k due to product rule.
    Space complexity: O(n_k) for the k-th derivative tree.
    """
    spectrum = []
    current = e
    for _ in range(max_k):
        spectrum.append(current.cert_depth)
        current = current.certified_deriv()
    
    # Verify non-increasing property
    for i in range(len(spectrum) - 1):
        assert spectrum[i + 1] <= spectrum[i], \
            f"Spectrum violated non-increasing at position {i}"
    
    return spectrum


def classify_hardy_level(spectrum: List[int]) -> int:
    """
    Classify the Hardy level of an expression from its differential spectrum.
    
    The Hardy level is the eventual value of the spectrum.
    Since the spectrum is non-increasing and ℕ-valued, it stabilizes.
    """
    if not spectrum:
        return 0
    return spectrum[-1]  # eventual value


# ═══════════════════════════════════════════════════════════
# Algorithm 3: Iterated Exponential Derivative Computation
# ═══════════════════════════════════════════════════════════

def iterexp_derivative_coefficients(n: int, x: float) -> List[float]:
    """
    Compute all intermediate values needed for d/dx iterExp(n, x).
    
    Returns [iterExp(0,x), iterExp(1,x), ..., iterExp(n,x)].
    
    The derivative is the product of all these values:
        d/dx iterExp(n, x) = prod_{k=1}^{n} iterExp(k, x)
    
    Time complexity: O(n)
    Space complexity: O(n)
    """
    values = [x]
    for k in range(n):
        prev = values[-1]
        if prev > 700:
            values.append(float('inf'))
        else:
            values.append(math.exp(prev))
    return values


# ═══════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithm 1: Certified Differentiation")
    print("-" * 40)
    
    # Build exp(exp(x))
    e = CertifiedExpr.exp(CertifiedExpr.exp(CertifiedExpr.var()))
    print(f"Expression depth: {e.cert_depth}")
    
    d = e.certified_deriv()
    print(f"Derivative depth: {d.cert_depth}")
    print(f"Depth preserved: {d.cert_depth == e.cert_depth}")
    
    print(f"\nEvaluation at x=1: {e.eval(1):.6f}")
    print(f"Derivative at x=1: {d.eval(1):.6f}")
    print()
    
    print("Algorithm 2: Differential Spectrum")
    print("-" * 40)
    
    expressions = {
        "exp(x)": CertifiedExpr.exp(CertifiedExpr.var()),
        "exp(exp(x))": CertifiedExpr.exp(CertifiedExpr.exp(CertifiedExpr.var())),
        "x * exp(x)": CertifiedExpr.mul(CertifiedExpr.var(),
                                          CertifiedExpr.exp(CertifiedExpr.var())),
        "x^2": CertifiedExpr.mul(CertifiedExpr.var(), CertifiedExpr.var()),
    }
    
    for name, expr in expressions.items():
        spectrum = compute_diff_spectrum(expr, 5)
        level = classify_hardy_level(spectrum)
        print(f"  {name:20s}  spectrum={spectrum}  Hardy level={level}")
    
    print()
    print("Algorithm 3: iterExp Derivative Coefficients")
    print("-" * 40)
    
    for n in range(1, 5):
        coeffs = iterexp_derivative_coefficients(n, 1.0)
        product = 1.0
        for c in coeffs[1:]:
            if c == float('inf'):
                product = float('inf')
                break
            product *= c
        print(f"  n={n}: coefficients={[f'{c:.4f}' for c in coeffs if c != float('inf')]}")
        if product != float('inf'):
            print(f"         derivative = {product:.6e}")
        else:
            print(f"         derivative = overflow")
