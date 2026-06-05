#!/usr/bin/env python3
"""
EML Differential Algebra — Algorithms

Implements the EML term algebra with syntactic differentiation,
evaluation, and related algorithms.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable
import math


# =============================================================================
# EMLTerm — The EML Term Algebra
# =============================================================================

class EMLTerm:
    """Base class for EML term algebra expressions."""
    
    def eval(self, x: float) -> float:
        """Evaluate the term at x."""
        raise NotImplementedError
    
    def sdiff(self) -> 'EMLTerm':
        """Syntactic differentiation: returns a new EMLTerm."""
        raise NotImplementedError
    
    def size(self) -> int:
        """Count nodes in the expression tree."""
        raise NotImplementedError
    
    def __repr__(self) -> str:
        raise NotImplementedError


@dataclass
class Var(EMLTerm):
    """The identity function x."""
    def eval(self, x: float) -> float:
        return x
    
    def sdiff(self) -> EMLTerm:
        return Cst(1.0)
    
    def size(self) -> int:
        return 1
    
    def __repr__(self) -> str:
        return "x"


@dataclass
class Cst(EMLTerm):
    """A constant c."""
    c: float
    
    def eval(self, x: float) -> float:
        return self.c
    
    def sdiff(self) -> EMLTerm:
        return Cst(0.0)
    
    def size(self) -> int:
        return 1
    
    def __repr__(self) -> str:
        return f"{self.c:.4g}"


@dataclass
class Add(EMLTerm):
    """Sum of two terms."""
    t1: EMLTerm
    t2: EMLTerm
    
    def eval(self, x: float) -> float:
        return self.t1.eval(x) + self.t2.eval(x)
    
    def sdiff(self) -> EMLTerm:
        return Add(self.t1.sdiff(), self.t2.sdiff())
    
    def size(self) -> int:
        return 1 + self.t1.size() + self.t2.size()
    
    def __repr__(self) -> str:
        return f"({self.t1} + {self.t2})"


@dataclass
class Neg(EMLTerm):
    """Negation of a term."""
    t: EMLTerm
    
    def eval(self, x: float) -> float:
        return -self.t.eval(x)
    
    def sdiff(self) -> EMLTerm:
        return Neg(self.t.sdiff())
    
    def size(self) -> int:
        return 1 + self.t.size()
    
    def __repr__(self) -> str:
        return f"(-{self.t})"


@dataclass
class Mul(EMLTerm):
    """Product of two terms (Leibniz rule applies)."""
    t1: EMLTerm
    t2: EMLTerm
    
    def eval(self, x: float) -> float:
        return self.t1.eval(x) * self.t2.eval(x)
    
    def sdiff(self) -> EMLTerm:
        # Product rule: (f*g)' = f'*g + f*g'
        return Add(Mul(self.t1.sdiff(), self.t2), Mul(self.t1, self.t2.sdiff()))
    
    def size(self) -> int:
        return 1 + self.t1.size() + self.t2.size()
    
    def __repr__(self) -> str:
        return f"({self.t1} * {self.t2})"


@dataclass
class Inv(EMLTerm):
    """Multiplicative inverse 1/t."""
    t: EMLTerm
    
    def eval(self, x: float) -> float:
        v = self.t.eval(x)
        if v == 0:
            return float('inf')
        return 1.0 / v
    
    def sdiff(self) -> EMLTerm:
        # (1/f)' = -f'/(f^2)
        return Neg(Mul(Inv(Mul(self.t, self.t)), self.t.sdiff()))
    
    def size(self) -> int:
        return 1 + self.t.size()
    
    def __repr__(self) -> str:
        return f"(1/{self.t})"


@dataclass
class Comp(EMLTerm):
    """Composition t1 ∘ t2."""
    t1: EMLTerm
    t2: EMLTerm
    
    def eval(self, x: float) -> float:
        return self.t1.eval(self.t2.eval(x))
    
    def sdiff(self) -> EMLTerm:
        # Chain rule: (f∘g)' = (f'∘g) * g'
        return Mul(Comp(self.t1.sdiff(), self.t2), self.t2.sdiff())
    
    def size(self) -> int:
        return 1 + self.t1.size() + self.t2.size()
    
    def __repr__(self) -> str:
        return f"({self.t1} ∘ {self.t2})"


@dataclass
class ExpT(EMLTerm):
    """The exponential function exp."""
    def eval(self, x: float) -> float:
        return math.exp(x)
    
    def sdiff(self) -> EMLTerm:
        # d/dx exp = exp (FIXED POINT!)
        return ExpT()
    
    def size(self) -> int:
        return 1
    
    def __repr__(self) -> str:
        return "exp"


@dataclass
class LogT(EMLTerm):
    """The natural logarithm log."""
    def eval(self, x: float) -> float:
        if x <= 0:
            return float('-inf')
        return math.log(x)
    
    def sdiff(self) -> EMLTerm:
        # d/dx log = 1/x = inv(var)
        return Inv(Var())
    
    def size(self) -> int:
        return 1
    
    def __repr__(self) -> str:
        return "log"


# =============================================================================
# The EML Function
# =============================================================================

def eml_term(t1: EMLTerm, t2: EMLTerm) -> EMLTerm:
    """Construct eml(t1, t2) = exp(t1) - log(t2) as an EMLTerm."""
    return Add(Comp(ExpT(), t1), Neg(Comp(LogT(), t2)))


# =============================================================================
# Algorithms
# =============================================================================

def syntactic_differentiate(term: EMLTerm, n: int = 1) -> EMLTerm:
    """Apply syntactic differentiation n times.
    
    Algorithm: Recursively apply sdiff.
    Time complexity: O(3^n * size(term)) — exponential swell.
    Space complexity: Same as time (tree grows).
    
    Args:
        term: An EMLTerm to differentiate.
        n: Number of times to differentiate.
    
    Returns:
        The n-th syntactic derivative as an EMLTerm.
    """
    result = term
    for _ in range(n):
        result = result.sdiff()
    return result


def verify_derivative(term: EMLTerm, x: float, h: float = 1e-7) -> tuple[float, float, float]:
    """Verify syntactic differentiation against numerical differentiation.
    
    Args:
        term: An EMLTerm.
        x: Point at which to evaluate.
        h: Step size for numerical derivative.
    
    Returns:
        (syntactic_value, numerical_value, absolute_error)
    """
    deriv_term = term.sdiff()
    syntactic_val = deriv_term.eval(x)
    numerical_val = (term.eval(x + h) - term.eval(x - h)) / (2 * h)
    return syntactic_val, numerical_val, abs(syntactic_val - numerical_val)


def expression_swell(term: EMLTerm, max_derivs: int = 8) -> list[int]:
    """Measure the expression swell under iterated differentiation.
    
    Returns a list of sizes [size(t), size(t'), size(t''), ...].
    """
    sizes = [term.size()]
    current = term
    for _ in range(max_derivs):
        current = current.sdiff()
        sizes.append(current.size())
    return sizes


def wronskian(f: EMLTerm, g: EMLTerm, x: float) -> float:
    """Compute the Wronskian W(f, g)(x) = f(x)*g'(x) - f'(x)*g(x)."""
    f_val = f.eval(x)
    g_val = g.eval(x)
    f_deriv_val = f.sdiff().eval(x)
    g_deriv_val = g.sdiff().eval(x)
    return f_val * g_deriv_val - f_deriv_val * g_val


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("EML Term Algebra with Syntactic Differentiation")
    print("=" * 50)
    
    # Example 1: exp is a fixed point
    t = ExpT()
    print(f"\nTerm: {t}")
    print(f"  sdiff(exp) = {t.sdiff()}")
    print(f"  exp is a fixed point of differentiation!")
    
    # Example 2: x^2 = x * x
    t2 = Mul(Var(), Var())
    print(f"\nTerm: {t2}")
    d = t2.sdiff()
    print(f"  sdiff(x*x) = {d}")
    print(f"  eval at x=3: {d.eval(3):.4f} (should be 6.0)")
    
    # Example 3: Expression swell
    print(f"\nExpression swell for x*x:")
    sizes = expression_swell(t2, 6)
    for i, s in enumerate(sizes):
        print(f"  d^{i}/dx^{i}: size = {s}")
    
    # Example 4: Wronskian
    print(f"\nWronskian W(exp, log) at various points:")
    for x in [0.5, 1.0, 1.5, 2.0]:
        w = wronskian(ExpT(), LogT(), x)
        print(f"  W(exp, log)({x:.1f}) = {w:.6f}")
    
    # Example 5: Verify derivatives
    print(f"\nVerification of syntactic vs numerical derivatives:")
    terms = [
        ("exp", ExpT()),
        ("log", LogT()),
        ("x*x", Mul(Var(), Var())),
        ("exp(x^2)", Comp(ExpT(), Mul(Var(), Var()))),
    ]
    for name, term in terms:
        syn, num, err = verify_derivative(term, 1.5)
        print(f"  d/dx({name}) at 1.5: syntactic={syn:.6f}, "
              f"numerical={num:.6f}, error={err:.2e}")
