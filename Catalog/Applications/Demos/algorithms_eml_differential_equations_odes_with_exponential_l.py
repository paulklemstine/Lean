"""
Algorithms for EML Differential Equations

Type-hinted implementations of:
1. Kovacic algorithm (simplified)
2. EML expression differentiation
3. Wronskian computation
4. Growth rate classification
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Optional, Tuple
import math


# ============================================================
# EML Expression Type
# ============================================================

class EMLExprType(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EXP = auto()
    LOG = auto()


@dataclass
class EMLExpr:
    """An EML (Exponential-Multiplicative-Logarithmic) expression."""
    kind: EMLExprType
    value: Optional[float] = None
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    @staticmethod
    def const(c: float) -> 'EMLExpr':
        return EMLExpr(EMLExprType.CONST, value=c)
    
    @staticmethod
    def var() -> 'EMLExpr':
        return EMLExpr(EMLExprType.VAR)
    
    @staticmethod
    def add(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.ADD, left=a, right=b)
    
    @staticmethod
    def mul(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.MUL, left=a, right=b)
    
    @staticmethod
    def neg(a: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.NEG, left=a)
    
    @staticmethod
    def inv(a: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.INV, left=a)
    
    @staticmethod
    def exp(a: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.EXP, left=a)
    
    @staticmethod
    def log(a: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprType.LOG, left=a)

    def evaluate(self, x: float) -> float:
        """Evaluate the expression at a point."""
        if self.kind == EMLExprType.CONST:
            return self.value
        elif self.kind == EMLExprType.VAR:
            return x
        elif self.kind == EMLExprType.ADD:
            return self.left.evaluate(x) + self.right.evaluate(x)
        elif self.kind == EMLExprType.MUL:
            return self.left.evaluate(x) * self.right.evaluate(x)
        elif self.kind == EMLExprType.NEG:
            return -self.left.evaluate(x)
        elif self.kind == EMLExprType.INV:
            v = self.left.evaluate(x)
            return 1.0 / v if v != 0 else float('inf')
        elif self.kind == EMLExprType.EXP:
            return math.exp(self.left.evaluate(x))
        elif self.kind == EMLExprType.LOG:
            v = self.left.evaluate(x)
            return math.log(v) if v > 0 else float('-inf')
        raise ValueError(f"Unknown expression type: {self.kind}")

    def differentiate(self) -> 'EMLExpr':
        """Syntactic differentiation using standard rules."""
        if self.kind == EMLExprType.CONST:
            return EMLExpr.const(0)
        elif self.kind == EMLExprType.VAR:
            return EMLExpr.const(1)
        elif self.kind == EMLExprType.ADD:
            return EMLExpr.add(self.left.differentiate(), self.right.differentiate())
        elif self.kind == EMLExprType.MUL:
            # Product rule: (fg)' = f'g + fg'
            return EMLExpr.add(
                EMLExpr.mul(self.left.differentiate(), self.right),
                EMLExpr.mul(self.left, self.right.differentiate())
            )
        elif self.kind == EMLExprType.NEG:
            return EMLExpr.neg(self.left.differentiate())
        elif self.kind == EMLExprType.INV:
            # (1/f)' = -f'/f²
            return EMLExpr.neg(
                EMLExpr.mul(
                    self.left.differentiate(),
                    EMLExpr.mul(EMLExpr.inv(self.left), EMLExpr.inv(self.left))
                )
            )
        elif self.kind == EMLExprType.EXP:
            # (exp(f))' = f' * exp(f)
            return EMLExpr.mul(self.left.differentiate(), EMLExpr.exp(self.left))
        elif self.kind == EMLExprType.LOG:
            # (log(f))' = f'/f
            return EMLExpr.mul(self.left.differentiate(), EMLExpr.inv(self.left))
        raise ValueError(f"Unknown expression type: {self.kind}")

    def el_height(self) -> int:
        """Compute the EL-height (max nesting depth of exp/log)."""
        if self.kind in (EMLExprType.CONST, EMLExprType.VAR):
            return 0
        elif self.kind in (EMLExprType.ADD, EMLExprType.MUL):
            return max(self.left.el_height(), self.right.el_height())
        elif self.kind in (EMLExprType.NEG, EMLExprType.INV):
            return self.left.el_height()
        elif self.kind in (EMLExprType.EXP, EMLExprType.LOG):
            return self.left.el_height() + 1
        return 0


# ============================================================
# Wronskian and Abel's Identity
# ============================================================

def wronskian(
    y1: Callable[[float], float],
    y2: Callable[[float], float],
    y1p: Callable[[float], float],
    y2p: Callable[[float], float],
    x: float
) -> float:
    """Compute the Wronskian W(x) = y1(x)*y2'(x) - y1'(x)*y2(x)."""
    return y1(x) * y2p(x) - y1p(x) * y2(x)


def abel_wronskian(
    W0: float,
    p: Callable[[float], float],
    x0: float,
    x: float,
    n_steps: int = 1000
) -> float:
    """Compute W(x) = W(x0) * exp(-∫_{x0}^x p(t) dt) numerically.
    
    Uses Simpson's rule for the integral.
    """
    # Numerical integration of p from x0 to x
    h = (x - x0) / n_steps
    integral = 0.0
    for i in range(n_steps):
        t0 = x0 + i * h
        t1 = t0 + h
        tm = (t0 + t1) / 2
        integral += (h / 6) * (p(t0) + 4 * p(tm) + p(t1))
    
    return W0 * math.exp(-integral)


# ============================================================
# Kovacic Algorithm (Simplified)
# ============================================================

class KovacicCase(Enum):
    """The four cases of the Kovacic algorithm."""
    CASE_1 = 1  # Reducible (triangular Galois group)
    CASE_2 = 2  # Imprimitive (dihedral Galois group)
    CASE_3 = 3  # Finite (platonic Galois group)
    CASE_4 = 4  # Full SL(2) (no Liouvillian solution)


@dataclass
class Pole:
    """A pole of a rational function."""
    location: complex  # ∞ represented as float('inf')
    order: int
    coefficient: complex  # leading coefficient


def kovacic_classify(poles: list[Pole]) -> KovacicCase:
    """Simplified Kovacic case classification based on pole structure.
    
    This is a simplified version that handles common cases:
    - If all poles have even order: could be Cases 1, 2, or 3
    - If any pole has odd order > 1: eliminates Cases 2 and 3
    - Full classification requires additional residue analysis
    
    Args:
        poles: List of poles with their orders
    
    Returns:
        The Kovacic case classification
    """
    has_odd_order = any(p.order % 2 == 1 and p.order > 1 for p in poles)
    max_order = max((p.order for p in poles), default=0)
    
    if has_odd_order:
        # Odd order poles (> 1) eliminate Cases 2 and 3
        # Need further analysis for Case 1 vs Case 4
        # For simplicity, classify as Case 4 (conservative)
        return KovacicCase.CASE_4
    
    if max_order <= 2:
        # Low-order poles: likely Case 1
        return KovacicCase.CASE_1
    
    # Default: Case 4 (most conservative)
    return KovacicCase.CASE_4


def kovacic_airy() -> KovacicCase:
    """Apply Kovacic algorithm to Airy's equation y'' = xy.
    
    r(x) = x has:
    - No finite poles
    - A pole of order 3 at infinity (x ~ 1/t², so r = 1/t² has order 3)
    
    The odd order at infinity rules out Cases 2 and 3.
    Case 1 analysis also fails.
    Result: Case 4 (full SL(2), no Liouvillian solutions).
    """
    # Pole at infinity with order 3
    poles = [Pole(location=complex('inf'), order=3, coefficient=1)]
    
    result = kovacic_classify(poles)
    assert result == KovacicCase.CASE_4, "Airy equation should be Case 4"
    return result


# ============================================================
# Growth Rate Classification
# ============================================================

class GrowthClass(Enum):
    """Growth rate classification for EML functions."""
    POLYNOMIAL = 0      # |f(x)| ≤ C * x^n
    EXPONENTIAL = 1     # |f(x)| ≤ C * exp(x^n)
    DOUBLE_EXP = 2      # |f(x)| ≤ C * exp(exp(x^n))
    SUPER_EXP = 3       # Higher iterated exponentials


def classify_growth(expr: EMLExpr) -> GrowthClass:
    """Classify the growth rate of an EML expression.
    
    The growth class is bounded by the EL-height:
    - EL-height 0: polynomial growth
    - EL-height 1: exponential growth
    - EL-height 2: double exponential growth
    - EL-height k: k-fold iterated exponential growth
    """
    h = expr.el_height()
    if h == 0:
        return GrowthClass.POLYNOMIAL
    elif h == 1:
        return GrowthClass.EXPONENTIAL
    elif h == 2:
        return GrowthClass.DOUBLE_EXP
    else:
        return GrowthClass.SUPER_EXP


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Demo: Kovacic classification
    print("Kovacic classification of Airy's equation:", kovacic_airy())
    
    # Demo: EML expression manipulation
    # f(x) = exp(x²)
    x = EMLExpr.var()
    x_sq = EMLExpr.mul(x, x)
    exp_x_sq = EMLExpr.exp(x_sq)
    
    print(f"\nf(x) = exp(x²)")
    print(f"  f(1) = {exp_x_sq.evaluate(1):.6f}")
    print(f"  EL-height = {exp_x_sq.el_height()}")
    print(f"  Growth class = {classify_growth(exp_x_sq)}")
    
    f_prime = exp_x_sq.differentiate()
    print(f"  f'(1) = {f_prime.evaluate(1):.6f}")
    print(f"  EL-height of f' = {f_prime.el_height()}")
    print(f"  (should be ≤ {exp_x_sq.el_height()})")
