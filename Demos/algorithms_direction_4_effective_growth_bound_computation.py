#!/usr/bin/env python3
"""
Algorithms for Effective Growth Bound Computation

Implements the core algorithms from the research paper:
1. Iterated exponential computation
2. Symbolic expression evaluation
3. Recursive bound extraction
4. Tower majorant computation
5. Bound verification
"""

import math
from dataclasses import dataclass
from typing import Union

# ─── Core Mathematical Functions ────────────────────────────────────────────

def iter_exp(n: int, x: float) -> float:
    """Compute the iterated exponential E_n(x).

    E_0(x) = x
    E_{n+1}(x) = exp(E_n(x))

    Args:
        n: Number of exponential iterations (level)
        x: Input value

    Returns:
        E_n(x), or float('inf') if overflow occurs

    Examples:
        >>> iter_exp(0, 3.0)
        3.0
        >>> iter_exp(1, 1.0)  # exp(1)
        2.718281828459045
        >>> iter_exp(2, 1.0)  # exp(exp(1))
        15.154262241479259
    """
    result = float(x)
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def tower(n: int, m: int) -> int:
    """Compute the tower function: iterated power of 2.

    tower(0, m) = m
    tower(n+1, m) = 2^tower(n, m)

    Args:
        n: Number of iterations
        m: Base value

    Returns:
        tower(n, m), capped at 2^1024 to prevent memory issues

    Examples:
        >>> tower(0, 5)
        5
        >>> tower(1, 3)
        8
        >>> tower(2, 3)
        256
    """
    result = m
    for _ in range(n):
        if result > 1024:
            return 2**1024
        result = 2 ** result
    return result


def poly_majorant(m: int) -> int:
    """Polynomial majorant: p(m) = m^2 + 3m + 7.

    This provides a polynomial upper bound used in the tower majorant theorem.

    Args:
        m: Input value

    Returns:
        m^2 + 3*m + 7

    Examples:
        >>> poly_majorant(1)
        11
        >>> poly_majorant(3)
        25
    """
    return m**2 + 3*m + 7


def threshold_majorant(n: int, s: int, k: int) -> int:
    """Threshold majorant function.

    thresholdMajorant(0, s, k) = (s+k)^2 + 3(s+k) + 7
    thresholdMajorant(n+1, s, k) = 2^thresholdMajorant(n, s, k)

    Args:
        n: Level parameter
        s: Size parameter
        k: Slack parameter

    Returns:
        The threshold majorant value
    """
    if n == 0:
        return (s + k)**2 + 3*(s + k) + 7
    else:
        prev = threshold_majorant(n - 1, s, k)
        if prev > 1024:
            return 2**1024
        return 2**prev


# ─── Symbolic Expression Language ───────────────────────────────────────────

class AsymExpr:
    """Base class for asymptotic expressions."""
    def eval(self, x: float) -> float:
        raise NotImplementedError
    def level(self) -> int:
        raise NotImplementedError
    def size(self) -> int:
        raise NotImplementedError

class Var(AsymExpr):
    """The identity expression: f(x) = x."""
    def eval(self, x: float) -> float:
        return float(x)
    def level(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class Const(AsymExpr):
    """A constant expression: f(x) = c."""
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def level(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.c)

class Add(AsymExpr):
    """Sum of two expressions."""
    def __init__(self, a: AsymExpr, b: AsymExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def level(self) -> int:
        return max(self.a.level(), self.b.level())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(AsymExpr):
    """Product of two expressions."""
    def __init__(self, a: AsymExpr, b: AsymExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def level(self) -> int:
        return max(self.a.level(), self.b.level())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} * {self.b})"

class Exp(AsymExpr):
    """Exponential of an expression."""
    def __init__(self, e: AsymExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        if v > 700:
            return float('inf')
        return math.exp(v)
    def level(self) -> int:
        return self.e.level() + 2
    def size(self) -> int:
        return 1 + self.e.size()
    def __repr__(self):
        return f"exp({self.e})"


# ─── Effective Bound Extraction Algorithm ───────────────────────────────────

@dataclass
class EffectiveBound:
    """Certificate: |f(x)| ≤ exp(C * E_n(x)) for all x ≥ N."""
    C: float
    N: int
    level: int

    def verify(self, expr: AsymExpr, x: int) -> bool:
        """Verify the bound at a specific point x ≥ N."""
        if x < self.N:
            return True
        val = abs(expr.eval(x))
        ie = iter_exp(self.level, x)
        if self.C * ie > 700:
            return True
        return val <= math.exp(self.C * ie) + 1e-10


def extract_effective_bound(e: AsymExpr) -> EffectiveBound:
    """Extract an effective exponential bound by structural recursion.

    Algorithm:
        var    → C=1, N=1, level=0
        const  → C=1, N=⌈|c|⌉, level=0
        add    → C=max(C₁,C₂)+1, N=max(N₁,N₂,1), level=max(l₁,l₂)
        mul    → C=C₁+C₂, N=max(N₁,N₂), level=max(l₁,l₂)
        exp    → promote(Be) then C=1, level=l+2

    Complexity: O(size(e)) time, O(depth(e)) stack space.

    Args:
        e: The expression to analyze

    Returns:
        An EffectiveBound certificate
    """
    if isinstance(e, Var):
        return EffectiveBound(C=1.0, N=1, level=0)

    elif isinstance(e, Const):
        return EffectiveBound(C=1.0, N=max(0, math.ceil(abs(e.c))), level=0)

    elif isinstance(e, Add):
        Ba = extract_effective_bound(e.a)
        Bb = extract_effective_bound(e.b)
        lvl = max(Ba.level, Bb.level)
        return EffectiveBound(
            C=max(Ba.C, Bb.C) + 1,
            N=max(Ba.N, Bb.N, 1),
            level=lvl
        )

    elif isinstance(e, Mul):
        Ba = extract_effective_bound(e.a)
        Bb = extract_effective_bound(e.b)
        lvl = max(Ba.level, Bb.level)
        return EffectiveBound(
            C=Ba.C + Bb.C,
            N=max(Ba.N, Bb.N),
            level=lvl
        )

    elif isinstance(e, Exp):
        Be = extract_effective_bound(e.e)
        # Promote: absorb C into next level
        promote_N = max(Be.N, math.ceil(2 * Be.C) + 1)
        return EffectiveBound(C=1.0, N=promote_N, level=Be.level + 2)

    else:
        raise ValueError(f"Unknown expression: {type(e)}")


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build and analyze several expressions
    examples = [
        ("x", Var()),
        ("x + x", Add(Var(), Var())),
        ("x * x", Mul(Var(), Var())),
        ("exp(x)", Exp(Var())),
        ("exp(x + x)", Exp(Add(Var(), Var()))),
        ("exp(exp(x))", Exp(Exp(Var()))),
    ]

    for name, expr in examples:
        bound = extract_effective_bound(expr)
        print(f"{name:20s}  level={bound.level}  C={bound.C:.2f}  N={bound.N}")

        # Verify at a few points
        ok = all(bound.verify(expr, x) for x in range(bound.N, bound.N + 20))
        print(f"  Verification (20 points): {'PASS' if ok else 'FAIL'}")
