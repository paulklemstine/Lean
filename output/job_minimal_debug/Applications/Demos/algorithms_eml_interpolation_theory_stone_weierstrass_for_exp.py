#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of EML algorithms.

Provides:
1. EML Term evaluation and construction
2. Monomial term builder (constant-depth x^n)
3. Polynomial-to-EML conversion
4. EML depth/size analysis
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Callable
from math import exp, log, factorial
from abc import ABC, abstractmethod


# =============================================================
# EML Term Abstract Syntax Tree
# =============================================================

class Term(ABC):
    """Abstract base class for EML terms."""

    @abstractmethod
    def eval(self, x: float) -> float:
        """Evaluate the term at x."""
        ...

    @abstractmethod
    def depth(self) -> int:
        """Compute the depth (maximum nesting) of the term."""
        ...

    @abstractmethod
    def size(self) -> int:
        """Compute the size (number of nodes) of the term."""
        ...

    @abstractmethod
    def to_str(self) -> str:
        """Pretty-print the term."""
        ...


@dataclass
class Const(Term):
    """Constant term."""
    c: float

    def eval(self, x: float) -> float:
        return self.c

    def depth(self) -> int:
        return 0

    def size(self) -> int:
        return 1

    def to_str(self) -> str:
        return f"{self.c}"


@dataclass
class Var(Term):
    """Variable term."""

    def eval(self, x: float) -> float:
        return x

    def depth(self) -> int:
        return 0

    def size(self) -> int:
        return 1

    def to_str(self) -> str:
        return "x"


@dataclass
class Exp(Term):
    """Exponential: exp(inner)."""
    inner: Term

    def eval(self, x: float) -> float:
        return exp(self.inner.eval(x))

    def depth(self) -> int:
        return self.inner.depth() + 1

    def size(self) -> int:
        return self.inner.size() + 1

    def to_str(self) -> str:
        return f"exp({self.inner.to_str()})"


@dataclass
class Log(Term):
    """Logarithm: log(inner). Requires inner > 0 for faithful evaluation."""
    inner: Term

    def eval(self, x: float) -> float:
        val = self.inner.eval(x)
        if val <= 0:
            raise ValueError(f"Log of non-positive value: {val}")
        return log(val)

    def depth(self) -> int:
        return self.inner.depth() + 1

    def size(self) -> int:
        return self.inner.size() + 1

    def to_str(self) -> str:
        return f"log({self.inner.to_str()})"


@dataclass
class Add(Term):
    """Addition: left + right."""
    left: Term
    right: Term

    def eval(self, x: float) -> float:
        return self.left.eval(x) + self.right.eval(x)

    def depth(self) -> int:
        return max(self.left.depth(), self.right.depth()) + 1

    def size(self) -> int:
        return self.left.size() + self.right.size() + 1

    def to_str(self) -> str:
        return f"({self.left.to_str()} + {self.right.to_str()})"


@dataclass
class Mul(Term):
    """Multiplication: left * right."""
    left: Term
    right: Term

    def eval(self, x: float) -> float:
        return self.left.eval(x) * self.right.eval(x)

    def depth(self) -> int:
        return max(self.left.depth(), self.right.depth()) + 1

    def size(self) -> int:
        return self.left.size() + self.right.size() + 1

    def to_str(self) -> str:
        return f"({self.left.to_str()} × {self.right.to_str()})"


# =============================================================
# Algorithm 1: Monomial Construction (depth 3)
# =============================================================

def monomial_term(n: int) -> Term:
    """
    Construct the EML term for x^n = exp(n * log(x)).

    Algorithm:
        MONOMIAL(n):
            return exp(mul(const(n), log(var)))

    Properties:
        - depth = 3 (constant, independent of n)
        - size = 5 (constant, independent of n)
        - Evaluates to x^n for x > 0

    This is the Monomial Depth Theorem in algorithmic form.
    """
    return Exp(Mul(Const(float(n)), Log(Var())))


# =============================================================
# Algorithm 2: Polynomial to EML conversion
# =============================================================

def polynomial_to_eml(coeffs: List[float]) -> Term:
    """
    Convert a polynomial p(x) = sum(coeffs[i] * x^i) to an EML term.

    Uses the monomial depth theorem: each x^i = exp(i * log(x)) has
    depth 3. The polynomial is then a sum of scaled monomials.

    The sum uses a balanced binary tree for minimal depth overhead.

    Properties:
        - Each monomial has depth 3
        - Total depth = 3 + ceil(log2(len(nonzero_coeffs))) + 1
        - Total size = O(len(coeffs))

    Algorithm:
        POLY_TO_EML(coeffs):
            terms = []
            for i, c in enumerate(coeffs):
                if c != 0:
                    terms.append(mul(const(c), MONOMIAL(i)))
            return BINARY_SUM(terms)
    """
    # Build individual monomial terms
    terms: List[Term] = []
    for i, c in enumerate(coeffs):
        if c != 0.0:
            if i == 0:
                terms.append(Const(c))
            else:
                terms.append(Mul(Const(c), monomial_term(i)))

    if not terms:
        return Const(0.0)

    # Binary tree summation for minimal depth
    while len(terms) > 1:
        new_terms: List[Term] = []
        for j in range(0, len(terms), 2):
            if j + 1 < len(terms):
                new_terms.append(Add(terms[j], terms[j + 1]))
            else:
                new_terms.append(terms[j])
        terms = new_terms

    return terms[0]


# =============================================================
# Algorithm 3: EML Evaluation with positivity tracking
# =============================================================

def safe_eval(term: Term, x: float) -> tuple[float, bool]:
    """
    Evaluate an EML term with positivity tracking.

    Returns (value, is_positive) where is_positive indicates whether
    the result is guaranteed positive (safe for further log application).

    Algorithm:
        SAFE_EVAL(t, x):
            match t:
                const(c) → return (c, c > 0)
                var → return (x, x > 0)
                exp(s) → (v, _) = SAFE_EVAL(s, x); return (exp(v), True)
                log(s) → (v, p) = SAFE_EVAL(s, x)
                          if not p: raise error
                          return (log(v), v > 1)
                add(s,t) → ... return (vs + vt, vs + vt > 0)
                mul(s,t) → ... return (vs * vt, vs > 0 and vt > 0)
    """
    if isinstance(term, Const):
        return (term.c, term.c > 0)
    elif isinstance(term, Var):
        return (x, x > 0)
    elif isinstance(term, Exp):
        v, _ = safe_eval(term.inner, x)
        return (exp(v), True)  # exp is always positive
    elif isinstance(term, Log):
        v, p = safe_eval(term.inner, x)
        if not p or v <= 0:
            raise ValueError(f"Log applied to non-positive value {v}")
        return (log(v), v > 1.0)
    elif isinstance(term, Add):
        vl, _ = safe_eval(term.left, x)
        vr, _ = safe_eval(term.right, x)
        s = vl + vr
        return (s, s > 0)
    elif isinstance(term, Mul):
        vl, pl = safe_eval(term.left, x)
        vr, pr = safe_eval(term.right, x)
        return (vl * vr, pl and pr)
    else:
        raise TypeError(f"Unknown term type: {type(term)}")


# =============================================================
# Algorithm 4: Depth analysis
# =============================================================

def depth_histogram(term: Term) -> dict[int, int]:
    """
    Compute a histogram of node counts by depth level.

    Returns {depth: count} mapping each depth level to the number
    of nodes at that level in the term tree.
    """
    result: dict[int, int] = {}

    def walk(t: Term, level: int) -> None:
        result[level] = result.get(level, 0) + 1
        if isinstance(t, (Exp, Log)):
            walk(t.inner, level + 1)
        elif isinstance(t, (Add, Mul)):
            walk(t.left, level + 1)
            walk(t.right, level + 1)

    walk(term, 0)
    return result


# =============================================================
# Main: demonstrate algorithms
# =============================================================

if __name__ == "__main__":
    print("Algorithm 1: Monomial Construction")
    print("-" * 40)
    for n in [1, 2, 10, 100]:
        t = monomial_term(n)
        val = t.eval(2.0)
        print(f"  x^{n} at x=2: {val:.6f} (true: {2.0**n:.6f}), "
              f"depth={t.depth()}, size={t.size()}")

    print()
    print("Algorithm 2: Polynomial to EML")
    print("-" * 40)
    # p(x) = 1 + 2x + 3x^2
    coeffs = [1.0, 2.0, 3.0]
    t = polynomial_to_eml(coeffs)
    print(f"  p(x) = 1 + 2x + 3x²")
    print(f"  EML: {t.to_str()}")
    print(f"  depth={t.depth()}, size={t.size()}")
    for x in [1.0, 2.0, 3.0]:
        eml_val = t.eval(x)
        true_val = sum(c * x**i for i, c in enumerate(coeffs))
        print(f"  p({x}) = {true_val:.4f}, EML = {eml_val:.4f}")

    print()
    print("Algorithm 3: Safe Evaluation")
    print("-" * 40)
    t = monomial_term(3)
    for x in [0.5, 1.0, 2.0, 10.0]:
        val, pos = safe_eval(t, x)
        print(f"  x^3 at x={x}: value={val:.6f}, positive={pos}")

    print()
    print("Algorithm 4: Depth Histogram")
    print("-" * 40)
    t = polynomial_to_eml([1.0, 0.0, -0.5, 0.0, 0.0416667])
    hist = depth_histogram(t)
    print(f"  cos(x) Taylor approx: {t.to_str()}")
    for d in sorted(hist):
        print(f"    Level {d}: {hist[d]} nodes")
