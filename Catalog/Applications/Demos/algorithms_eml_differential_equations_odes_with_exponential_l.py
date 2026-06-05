#!/usr/bin/env python3
"""
EML Differential Equations: Algorithms

Type-hinted implementations of the key algorithms from the EML differential
obstruction theory.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Optional
import math


# ============================================================================
# EML Expression Type
# ============================================================================

class EMLNodeType(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EXP = auto()
    LOG = auto()


@dataclass
class EMLExpr:
    """An EML expression tree."""
    node_type: EMLNodeType
    value: Optional[float] = None  # For CONST nodes
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None  # For ADD, MUL

    @staticmethod
    def const(c: float) -> 'EMLExpr':
        return EMLExpr(EMLNodeType.CONST, value=c)

    @staticmethod
    def var() -> 'EMLExpr':
        return EMLExpr(EMLNodeType.VAR)

    @staticmethod
    def add(e1: 'EMLExpr', e2: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLNodeType.ADD, left=e1, right=e2)

    @staticmethod
    def mul(e1: 'EMLExpr', e2: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLNodeType.MUL, left=e1, right=e2)

    @staticmethod
    def neg(e: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLNodeType.NEG, left=e)

    @staticmethod
    def exp(e: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLNodeType.EXP, left=e)

    @staticmethod
    def log(e: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLNodeType.LOG, left=e)

    def depth(self) -> int:
        """Compute the EML depth (nesting level of exp/log)."""
        match self.node_type:
            case EMLNodeType.CONST | EMLNodeType.VAR:
                return 0
            case EMLNodeType.ADD | EMLNodeType.MUL:
                return max(self.left.depth(), self.right.depth())
            case EMLNodeType.NEG:
                return self.left.depth()
            case EMLNodeType.EXP | EMLNodeType.LOG:
                return self.left.depth() + 1

    def size(self) -> int:
        """Compute the total number of nodes."""
        match self.node_type:
            case EMLNodeType.CONST | EMLNodeType.VAR:
                return 1
            case EMLNodeType.ADD | EMLNodeType.MUL:
                return self.left.size() + self.right.size() + 1
            case EMLNodeType.NEG | EMLNodeType.EXP | EMLNodeType.LOG:
                return self.left.size() + 1

    def evaluate(self, x: float) -> float:
        """Evaluate the expression at a point."""
        match self.node_type:
            case EMLNodeType.CONST:
                return self.value
            case EMLNodeType.VAR:
                return x
            case EMLNodeType.ADD:
                return self.left.evaluate(x) + self.right.evaluate(x)
            case EMLNodeType.MUL:
                return self.left.evaluate(x) * self.right.evaluate(x)
            case EMLNodeType.NEG:
                return -self.left.evaluate(x)
            case EMLNodeType.EXP:
                val = self.left.evaluate(x)
                return math.exp(min(val, 500))
            case EMLNodeType.LOG:
                val = self.left.evaluate(x)
                return math.log(val) if val > 0 else 0.0

    def differentiate(self) -> 'EMLExpr':
        """Compute the formal derivative (symbolic differentiation)."""
        match self.node_type:
            case EMLNodeType.CONST:
                return EMLExpr.const(0.0)
            case EMLNodeType.VAR:
                return EMLExpr.const(1.0)
            case EMLNodeType.ADD:
                return EMLExpr.add(self.left.differentiate(), self.right.differentiate())
            case EMLNodeType.MUL:
                # Product rule: (f*g)' = f'*g + f*g'
                return EMLExpr.add(
                    EMLExpr.mul(self.left.differentiate(), self.right),
                    EMLExpr.mul(self.left, self.right.differentiate())
                )
            case EMLNodeType.NEG:
                return EMLExpr.neg(self.left.differentiate())
            case EMLNodeType.EXP:
                # (exp(f))' = f' * exp(f)
                return EMLExpr.mul(self.left.differentiate(), EMLExpr.exp(self.left))
            case EMLNodeType.LOG:
                # (log(f))' = f' / f = f' * exp(-log(f))
                return EMLExpr.mul(
                    self.left.differentiate(),
                    EMLExpr.exp(EMLExpr.neg(EMLExpr.log(self.left)))
                )

    def __repr__(self) -> str:
        match self.node_type:
            case EMLNodeType.CONST:
                return f"{self.value}"
            case EMLNodeType.VAR:
                return "x"
            case EMLNodeType.ADD:
                return f"({self.left} + {self.right})"
            case EMLNodeType.MUL:
                return f"({self.left} * {self.right})"
            case EMLNodeType.NEG:
                return f"(-{self.left})"
            case EMLNodeType.EXP:
                return f"exp({self.left})"
            case EMLNodeType.LOG:
                return f"log({self.left})"


# ============================================================================
# EML Differential Operator
# ============================================================================

@dataclass
class EMLDiffOp:
    """Second-order linear ODE: y'' + p(x)*y' + q(x)*y = 0."""
    p: EMLExpr  # coefficient of y'
    q: EMLExpr  # coefficient of y

    def depth(self) -> int:
        return max(self.p.depth(), self.q.depth())

    def companion_matrix(self, x: float) -> tuple[tuple[float, float], tuple[float, float]]:
        """Return the 2x2 companion matrix at point x."""
        px = self.p.evaluate(x)
        qx = self.q.evaluate(x)
        return ((0.0, 1.0), (-qx, -px))

    def diff_invariant(self, x: float, p_prime: float) -> float:
        """Compute the differential invariant I(x) = q - p²/4 - p'/2."""
        px = self.p.evaluate(x)
        qx = self.q.evaluate(x)
        return qx - px**2 / 4 - p_prime / 2

    @staticmethod
    def airy() -> 'EMLDiffOp':
        """The Airy operator: y'' - x*y = 0, i.e., p=0, q=-x."""
        return EMLDiffOp(p=EMLExpr.const(0.0), q=EMLExpr.neg(EMLExpr.var()))


# ============================================================================
# Growth Rate Analysis Algorithm
# ============================================================================

@dataclass
class GrowthClass:
    """Classifies asymptotic growth of an EML function."""
    level: int  # Number of nested exponentials
    poly_deg: int  # Polynomial degree at outermost level

    def dominates(self, other: 'GrowthClass') -> bool:
        """Does this growth class dominate the other?"""
        if self.level > other.level:
            return True
        if self.level == other.level and self.poly_deg > other.poly_deg:
            return True
        return False


def classify_growth(expr: EMLExpr) -> GrowthClass:
    """Classify the growth rate of an EML expression."""
    match expr.node_type:
        case EMLNodeType.CONST:
            return GrowthClass(0, 0)
        case EMLNodeType.VAR:
            return GrowthClass(0, 1)
        case EMLNodeType.ADD | EMLNodeType.MUL:
            g1 = classify_growth(expr.left)
            g2 = classify_growth(expr.right)
            if expr.node_type == EMLNodeType.ADD:
                return GrowthClass(max(g1.level, g2.level), max(g1.poly_deg, g2.poly_deg))
            else:
                return GrowthClass(max(g1.level, g2.level), g1.poly_deg + g2.poly_deg)
        case EMLNodeType.NEG:
            return classify_growth(expr.left)
        case EMLNodeType.EXP:
            g = classify_growth(expr.left)
            return GrowthClass(g.level + 1, 0)
        case EMLNodeType.LOG:
            return classify_growth(expr.left)


def check_airy_obstruction(candidate: EMLExpr) -> str:
    """
    Check whether a candidate EML expression can match the Airy growth rate.
    
    The Airy growth rate is exp(2/3 * x^{3/2}), which requires:
    - Level 1 (one exponential layer)  
    - But the argument x^{3/2} has non-integer degree
    
    Returns a diagnosis string.
    """
    growth = classify_growth(candidate)
    
    if growth.level == 0:
        return (f"OBSTRUCTION: Growth level {growth.level} (polynomial). "
                f"Airy solutions grow exponentially — too slow.")
    elif growth.level == 1:
        return (f"Growth level 1 with poly_deg {growth.poly_deg}. "
                f"Airy needs exp(x^{{3/2}}) but EML requires integer degree. "
                f"OBSTRUCTION: No integer polynomial degree matches 3/2.")
    else:
        return (f"Growth level {growth.level} ≥ 2. "
                f"Airy solutions grow like exp(x^{{3/2}}), which is level 1. "
                f"OBSTRUCTION: Growth too fast — overshoots Airy rate.")


# ============================================================================
# Wronskian Computation
# ============================================================================

def compute_wronskian(y1: float, y1p: float, y2: float, y2p: float) -> float:
    """Compute W(y1, y2) = y1*y2' - y1'*y2."""
    return y1 * y2p - y1p * y2


def abel_wronskian_evolution(
    p_func: Callable[[float], float],
    W0: float,
    x0: float,
    x1: float,
    n_steps: int = 1000
) -> list[tuple[float, float]]:
    """
    Evolve the Wronskian using Abel's formula: W(x) = W(x0) * exp(-∫p dx).
    
    For the Airy equation (p=0), this gives W(x) = W(x0) = constant.
    """
    dx = (x1 - x0) / n_steps
    results = [(x0, W0)]
    integral = 0.0
    
    for i in range(1, n_steps + 1):
        x = x0 + i * dx
        integral += p_func(x) * dx
        W = W0 * math.exp(-integral)
        results.append((x, W))
    
    return results


# ============================================================================
# Tower Function Computation
# ============================================================================

def tower_exp(d: int, x: float) -> float:
    """Compute the d-fold iterated exponential of x."""
    result = x
    for _ in range(d):
        result = math.exp(min(result, 500))
    return result


def find_growth_gap(x: float) -> dict[str, float]:
    """
    At a given x, show the growth gap between EML levels.
    
    Returns a dict mapping growth descriptions to values.
    """
    return {
        "polynomial x²": x**2,
        "polynomial x¹⁰": x**10,
        "exp(x) [EML depth 1, deg 1]": math.exp(x) if x < 500 else float('inf'),
        "exp(2/3·x^{3/2}) [AIRY - NO EML DEPTH]": math.exp(2/3 * x**1.5) if x**1.5 < 750 else float('inf'),
        "exp(x²) [EML depth 1, deg 2]": math.exp(x**2) if x**2 < 500 else float('inf'),
        "exp(exp(x)) [EML depth 2]": tower_exp(2, x) if x < 6 else float('inf'),
    }


if __name__ == "__main__":
    # Quick algorithm demo
    print("EML Expression Algebra Demo")
    print("=" * 40)
    
    # Build exp(x²)
    x = EMLExpr.var()
    x_sq = EMLExpr.mul(x, EMLExpr.var())
    exp_x_sq = EMLExpr.exp(x_sq)
    
    print(f"Expression: {exp_x_sq}")
    print(f"Depth: {exp_x_sq.depth()}")
    print(f"Size: {exp_x_sq.size()}")
    print(f"Value at x=2: {exp_x_sq.evaluate(2.0):.4f}")
    print(f"Growth class: level={classify_growth(exp_x_sq).level}, "
          f"poly_deg={classify_growth(exp_x_sq).poly_deg}")
    
    print(f"\nDerivative: {exp_x_sq.differentiate()}")
    print(f"Derivative depth: {exp_x_sq.differentiate().depth()}")
    
    print("\nAiry obstruction check:")
    print(f"  For exp(x²): {check_airy_obstruction(exp_x_sq)}")
    print(f"  For x²: {check_airy_obstruction(x_sq)}")
    
    print("\nGrowth gap at x=5:")
    for name, val in find_growth_gap(5.0).items():
        print(f"  {name}: {val:.4e}")
