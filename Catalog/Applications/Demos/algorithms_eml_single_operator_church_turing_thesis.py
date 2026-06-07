"""
EML Algorithms: Type-hinted implementations for EML computation

Core algorithms for working with the EML primitive eml(x,y) = exp(x) - log(y),
including:
- Expression tree evaluation
- UExpr -> EMLExpr compilation
- Log-polynomial fitting for universal approximation
- EML complexity analysis
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Optional, Callable
from enum import Enum, auto


# ============================================================
# Expression Trees
# ============================================================

class UExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    EXP = auto()
    LOG = auto()


@dataclass
class UExpr:
    """Unary elementary expression over ℝ."""
    kind: UExprKind
    value: Optional[float] = None  # For CONST
    left: Optional[UExpr] = None
    right: Optional[UExpr] = None

    @staticmethod
    def var() -> UExpr:
        return UExpr(UExprKind.VAR)
    
    @staticmethod
    def const(c: float) -> UExpr:
        return UExpr(UExprKind.CONST, value=c)
    
    @staticmethod
    def add(e1: UExpr, e2: UExpr) -> UExpr:
        return UExpr(UExprKind.ADD, left=e1, right=e2)
    
    @staticmethod
    def sub(e1: UExpr, e2: UExpr) -> UExpr:
        return UExpr(UExprKind.SUB, left=e1, right=e2)
    
    @staticmethod
    def mul(e1: UExpr, e2: UExpr) -> UExpr:
        return UExpr(UExprKind.MUL, left=e1, right=e2)
    
    @staticmethod
    def div(e1: UExpr, e2: UExpr) -> UExpr:
        return UExpr(UExprKind.DIV, left=e1, right=e2)
    
    @staticmethod
    def exp(e: UExpr) -> UExpr:
        return UExpr(UExprKind.EXP, left=e)
    
    @staticmethod
    def log(e: UExpr) -> UExpr:
        return UExpr(UExprKind.LOG, left=e)

    def eval(self, x: float) -> Optional[float]:
        """Evaluate expression at x. Returns None if undefined."""
        match self.kind:
            case UExprKind.VAR:
                return x
            case UExprKind.CONST:
                return self.value
            case UExprKind.ADD:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 + v2 if v1 is not None and v2 is not None else None
            case UExprKind.SUB:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 - v2 if v1 is not None and v2 is not None else None
            case UExprKind.MUL:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 * v2 if v1 is not None and v2 is not None else None
            case UExprKind.DIV:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                if v1 is None or v2 is None or v2 == 0:
                    return None
                return v1 / v2
            case UExprKind.EXP:
                v = self.left.eval(x)
                return math.exp(v) if v is not None else None
            case UExprKind.LOG:
                v = self.left.eval(x)
                if v is None or v <= 0:
                    return None
                return math.log(v)
    
    def size(self) -> int:
        """Count all nodes."""
        match self.kind:
            case UExprKind.VAR | UExprKind.CONST:
                return 1
            case UExprKind.EXP | UExprKind.LOG:
                return 1 + self.left.size()
            case _:
                return 1 + self.left.size() + self.right.size()
    
    def transcendence_rank(self) -> int:
        """Count exp/log nodes."""
        match self.kind:
            case UExprKind.VAR | UExprKind.CONST:
                return 0
            case UExprKind.EXP | UExprKind.LOG:
                return 1 + self.left.transcendence_rank()
            case _:
                return (self.left.transcendence_rank() + 
                        self.right.transcendence_rank())


class EMLExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    EML = auto()


@dataclass
class EMLExpr:
    """EML expression: uses eml(x,y) = exp(x) - log(y) as sole transcendental."""
    kind: EMLExprKind
    value: Optional[float] = None
    left: Optional[EMLExpr] = None
    right: Optional[EMLExpr] = None
    
    @staticmethod
    def var() -> EMLExpr:
        return EMLExpr(EMLExprKind.VAR)
    
    @staticmethod
    def const(c: float) -> EMLExpr:
        return EMLExpr(EMLExprKind.CONST, value=c)
    
    @staticmethod
    def eml_node(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLExprKind.EML, left=e1, right=e2)

    def eval(self, x: float) -> Optional[float]:
        """Evaluate EML expression at x."""
        match self.kind:
            case EMLExprKind.VAR:
                return x
            case EMLExprKind.CONST:
                return self.value
            case EMLExprKind.ADD:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 + v2 if v1 is not None and v2 is not None else None
            case EMLExprKind.SUB:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 - v2 if v1 is not None and v2 is not None else None
            case EMLExprKind.MUL:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 * v2 if v1 is not None and v2 is not None else None
            case EMLExprKind.DIV:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                if v1 is None or v2 is None or v2 == 0:
                    return None
                return v1 / v2
            case EMLExprKind.EML:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                if v1 is None or v2 is None or v2 <= 0:
                    return None
                return math.exp(v1) - math.log(v2)
    
    def size(self) -> int:
        match self.kind:
            case EMLExprKind.VAR | EMLExprKind.CONST:
                return 1
            case _:
                return 1 + self.left.size() + self.right.size()
    
    def eml_rank(self) -> int:
        """Count eml nodes."""
        match self.kind:
            case EMLExprKind.VAR | EMLExprKind.CONST:
                return 0
            case EMLExprKind.EML:
                return 1 + self.left.eml_rank() + self.right.eml_rank()
            case _:
                return self.left.eml_rank() + self.right.eml_rank()


# ============================================================
# The EML Compiler
# ============================================================

def compile(expr: UExpr) -> EMLExpr:
    """Compile UExpr to EMLExpr.
    
    Key translations:
      exp(e) -> eml(compile(e), const(1))     since eml(x,1) = exp(x)
      log(e) -> sub(const(1), eml(const(0), compile(e)))  since eml(0,y) = 1 - log(y)
    
    Proven properties (in Lean):
      - Semantic correctness: compile preserves evaluation
      - Linear size bound: size(compile(e)) ≤ 4 * size(e)
      - Exact rank preservation: eml_rank(compile(e)) = transcendence_rank(e)
    """
    match expr.kind:
        case UExprKind.VAR:
            return EMLExpr.var()
        case UExprKind.CONST:
            return EMLExpr.const(expr.value)
        case UExprKind.ADD:
            return EMLExpr(EMLExprKind.ADD, left=compile(expr.left), 
                          right=compile(expr.right))
        case UExprKind.SUB:
            return EMLExpr(EMLExprKind.SUB, left=compile(expr.left), 
                          right=compile(expr.right))
        case UExprKind.MUL:
            return EMLExpr(EMLExprKind.MUL, left=compile(expr.left), 
                          right=compile(expr.right))
        case UExprKind.DIV:
            return EMLExpr(EMLExprKind.DIV, left=compile(expr.left), 
                          right=compile(expr.right))
        case UExprKind.EXP:
            return EMLExpr.eml_node(compile(expr.left), EMLExpr.const(1.0))
        case UExprKind.LOG:
            return EMLExpr(EMLExprKind.SUB, 
                          left=EMLExpr.const(1.0),
                          right=EMLExpr.eml_node(EMLExpr.const(0.0), 
                                                 compile(expr.left)))


def verify_compilation(expr: UExpr, test_points: list[float]) -> bool:
    """Verify that compile preserves semantics on test points."""
    compiled = compile(expr)
    for x in test_points:
        v1 = expr.eval(x)
        v2 = compiled.eval(x)
        if v1 is None and v2 is None:
            continue
        if v1 is None or v2 is None:
            return False
        if abs(v1 - v2) > 1e-10:
            return False
    return True


# ============================================================
# Log-Polynomial Approximation (Stone-Weierstrass)
# ============================================================

def fit_log_polynomial(f: Callable[[float], float], 
                       a: float, b: float, 
                       degree: int) -> list[float]:
    """Fit a polynomial in log(x) to approximate f on [a, b].
    
    Returns coefficients [c0, c1, ..., cd] such that
    f(x) ≈ c0 + c1*log(x) + c2*log(x)^2 + ... + cd*log(x)^d
    
    By the Stone-Weierstrass theorem (formally proved in Lean),
    as degree → ∞, the approximation converges uniformly.
    
    Args:
        f: Target function
        a: Left endpoint (must be > 0)
        b: Right endpoint (must be > a)
        degree: Polynomial degree
    
    Returns:
        Coefficient list [c0, c1, ..., cd]
    """
    import numpy as np
    
    assert a > 0, "Left endpoint must be positive"
    assert b > a, "Right endpoint must exceed left"
    
    n_points = max(degree + 1, 100)
    xs = np.linspace(a, b, n_points)
    log_xs = np.log(xs)
    ys = np.array([f(x) for x in xs])
    
    # Vandermonde matrix in log(x)
    V = np.vander(log_xs, degree + 1, increasing=True)
    
    # Least squares fit
    coeffs, _, _, _ = np.linalg.lstsq(V, ys, rcond=None)
    return list(coeffs)


def eval_log_polynomial(coeffs: list[float], x: float) -> float:
    """Evaluate a log-polynomial at x."""
    log_x = math.log(x)
    return sum(c * log_x ** k for k, c in enumerate(coeffs))


def max_approximation_error(f: Callable[[float], float], 
                            coeffs: list[float],
                            a: float, b: float, 
                            n: int = 1000) -> float:
    """Compute max |f(x) - p(log(x))| over [a, b]."""
    import numpy as np
    xs = np.linspace(a, b, n)
    return max(abs(f(x) - eval_log_polynomial(coeffs, x)) for x in xs)


# ============================================================
# EML Complexity Analysis
# ============================================================

def analyze_compilation(expr: UExpr) -> dict:
    """Analyze the compilation of a UExpr to EMLExpr."""
    compiled = compile(expr)
    return {
        "source_size": expr.size(),
        "compiled_size": compiled.size(),
        "blowup_ratio": compiled.size() / expr.size(),
        "transcendence_rank": expr.transcendence_rank(),
        "eml_rank": compiled.eml_rank(),
        "rank_preserved": expr.transcendence_rank() == compiled.eml_rank(),
    }


if __name__ == "__main__":
    # Test compilation
    print("=== EML Compilation Test ===")
    
    # exp(x) + log(x)
    expr = UExpr.add(UExpr.exp(UExpr.var()), UExpr.log(UExpr.var()))
    test_points = [0.5, 1.0, 2.0, 3.0]
    
    print(f"Expression: exp(x) + log(x)")
    print(f"Compilation correct: {verify_compilation(expr, test_points)}")
    print(f"Analysis: {analyze_compilation(expr)}")
    
    # exp(log(x)) = x for x > 0
    expr2 = UExpr.exp(UExpr.log(UExpr.var()))
    print(f"\nExpression: exp(log(x))")
    print(f"Compilation correct: {verify_compilation(expr2, [0.5, 1.0, 2.0])}")
    print(f"Analysis: {analyze_compilation(expr2)}")
    
    # Stone-Weierstrass approximation demo
    print("\n=== Stone-Weierstrass Approximation ===")
    target = lambda x: math.sin(x)
    for deg in [3, 5, 8, 12, 20]:
        coeffs = fit_log_polynomial(target, 0.1, 3.0, deg)
        err = max_approximation_error(target, coeffs, 0.1, 3.0)
        print(f"  log-poly degree {deg:2d}: max error = {err:.2e}")
