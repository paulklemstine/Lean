"""
EML (Exponential-Multiplicative-Logarithmic) Expression Algorithms

Type-hinted implementations of EML expression construction,
evaluation, complexity measurement, and approximation.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Optional
import math


class NodeType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()  # eml(a,b) = a * exp(b)


@dataclass
class EMLExpr:
    """An EML expression tree node."""
    node_type: NodeType
    value: Optional[float] = None  # for CONST nodes
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x."""
        match self.node_type:
            case NodeType.VAR:
                return x
            case NodeType.CONST:
                return self.value or 0.0
            case NodeType.ADD:
                return self.left.eval(x) + self.right.eval(x)
            case NodeType.MUL:
                return self.left.eval(x) * self.right.eval(x)
            case NodeType.NEG:
                return -self.left.eval(x)
            case NodeType.INV:
                val = self.left.eval(x)
                return 1.0 / val if val != 0 else float('inf')
            case NodeType.EML:
                a = self.left.eval(x)
                b = self.right.eval(x)
                try:
                    return a * math.exp(b)
                except OverflowError:
                    return float('inf')

    def size(self) -> int:
        """Number of nodes in the expression tree."""
        match self.node_type:
            case NodeType.VAR | NodeType.CONST:
                return 1
            case NodeType.ADD | NodeType.MUL | NodeType.EML:
                return 1 + self.left.size() + self.right.size()
            case NodeType.NEG | NodeType.INV:
                return 1 + self.left.size()

    def depth(self) -> int:
        """Tree depth (longest root-to-leaf path)."""
        match self.node_type:
            case NodeType.VAR | NodeType.CONST:
                return 0
            case NodeType.ADD | NodeType.MUL | NodeType.EML:
                return 1 + max(self.left.depth(), self.right.depth())
            case NodeType.NEG | NodeType.INV:
                return 1 + self.left.depth()

    def eml_depth(self) -> int:
        """EML depth: count only nesting of eml operations."""
        match self.node_type:
            case NodeType.VAR | NodeType.CONST:
                return 0
            case NodeType.ADD | NodeType.MUL:
                return max(self.left.eml_depth(), self.right.eml_depth())
            case NodeType.NEG | NodeType.INV:
                return self.left.eml_depth()
            case NodeType.EML:
                return 1 + max(self.left.eml_depth(), self.right.eml_depth())

    def eml_count(self) -> int:
        """Number of eml nodes in the expression."""
        match self.node_type:
            case NodeType.VAR | NodeType.CONST:
                return 0
            case NodeType.ADD | NodeType.MUL | NodeType.EML:
                base = 1 if self.node_type == NodeType.EML else 0
                return base + self.left.eml_count() + self.right.eml_count()
            case NodeType.NEG | NodeType.INV:
                return self.left.eml_count()

    def subst(self, inner: 'EMLExpr') -> 'EMLExpr':
        """Substitute inner for the variable in this expression."""
        match self.node_type:
            case NodeType.VAR:
                return inner
            case NodeType.CONST:
                return self
            case NodeType.ADD:
                return EMLExpr(NodeType.ADD, left=self.left.subst(inner), right=self.right.subst(inner))
            case NodeType.MUL:
                return EMLExpr(NodeType.MUL, left=self.left.subst(inner), right=self.right.subst(inner))
            case NodeType.NEG:
                return EMLExpr(NodeType.NEG, left=self.left.subst(inner))
            case NodeType.INV:
                return EMLExpr(NodeType.INV, left=self.left.subst(inner))
            case NodeType.EML:
                return EMLExpr(NodeType.EML, left=self.left.subst(inner), right=self.right.subst(inner))


# Constructors
def var() -> EMLExpr:
    return EMLExpr(NodeType.VAR)

def const(c: float) -> EMLExpr:
    return EMLExpr(NodeType.CONST, value=c)

def add(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(NodeType.ADD, left=a, right=b)

def mul(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(NodeType.MUL, left=a, right=b)

def neg(a: EMLExpr) -> EMLExpr:
    return EMLExpr(NodeType.NEG, left=a)

def inv(a: EMLExpr) -> EMLExpr:
    return EMLExpr(NodeType.INV, left=a)

def eml(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(NodeType.EML, left=a, right=b)


def iter_exp_expr(n: int) -> EMLExpr:
    """Build the canonical EML expression for iterExp n = exp^n(x)."""
    if n == 0:
        return var()
    return eml(const(1.0), iter_exp_expr(n - 1))


def iter_exp(n: int, x: float) -> float:
    """Compute iterExp n x = exp(exp(...exp(x)...))."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def monomial_expr(c: float, n: int) -> EMLExpr:
    """Build EML expression for c * x^n."""
    if n == 0:
        return const(c)
    return mul(var(), monomial_expr(c, n - 1))


def eml_description_complexity(
    f: Callable[[float], float],
    a: float, b: float, eps: float,
    max_size: int = 100
) -> int:
    """
    Estimate EML description complexity by enumeration.
    Returns the minimum size of an EML expression that eps-approximates f on [a,b].
    (Approximate — only checks canonical constructions.)
    """
    # Check constant approximation
    import numpy as np
    xs = np.linspace(a, b, 100)
    fvals = np.array([f(x) for x in xs])

    # Try constant
    c = np.mean(fvals)
    if np.max(np.abs(fvals - c)) <= eps:
        return 1

    # Try identity
    if np.max(np.abs(fvals - xs)) <= eps:
        return 1

    # Try monomials c*x^n
    for n in range(1, max_size // 2):
        # Least squares fit
        A = xs ** n
        c_fit = np.dot(A, fvals) / np.dot(A, A) if np.dot(A, A) > 0 else 0
        approx = c_fit * xs ** n
        if np.max(np.abs(fvals - approx)) <= eps:
            return 2 * n + 1

    return max_size


def retained_info(alpha: float, l: int, K: int) -> float:
    """Retained symbolic information after l layers with contraction alpha."""
    return alpha ** l * K


def info_depth_product(alpha: float, l: int, K: int) -> float:
    """Information-depth product: retained_info * depth."""
    return retained_info(alpha, l, K) * l


if __name__ == "__main__":
    # Demo: verify key properties
    print("=== EML Expression Properties ===\n")

    # Build iterExp 3
    e = iter_exp_expr(3)
    print(f"iterExp 3 expression:")
    print(f"  size = {e.size()} (expected: 7 = 2*3+1)")
    print(f"  eml_depth = {e.eml_depth()} (expected: 3)")
    print(f"  eml_count = {e.eml_count()} (expected: 3)")

    # Verify evaluation
    x = 0.5
    print(f"\n  eval(0.5) = {e.eval(x):.6f}")
    print(f"  iterExp(3, 0.5) = {iter_exp(3, x):.6f}")
    print(f"  match: {abs(e.eval(x) - iter_exp(3, x)) < 1e-10}")

    # Monomial
    m = monomial_expr(2.0, 3)
    print(f"\nMonomial 2*x^3:")
    print(f"  size = {m.size()} (expected: 7)")
    print(f"  eml_depth = {m.eml_depth()} (expected: 0)")
    print(f"  eval(2.0) = {m.eval(2.0)} (expected: 16.0)")

    # Information decay
    print("\n=== Information Decay ===")
    K = 100
    for alpha in [0.9, 0.5, 0.1]:
        print(f"\nalpha = {alpha}, K = {K}:")
        for l in range(6):
            ri = retained_info(alpha, l, K)
            prod = info_depth_product(alpha, l, K)
            print(f"  depth {l}: retained = {ri:.2f}, product = {prod:.2f}")
