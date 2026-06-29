#!/usr/bin/env python3
"""
Ordinal Classification of EML Growth — Core Algorithms

Implements:
1. OmegaBlock ordinal notation system for ordinals below ω²
2. Compositional rank inference for EML expressions
3. Benchmark function hierarchy F_{ω·k+m}
4. Hardy level classifier with growth certificates

Time complexity:
- Rank inference: O(n) where n = expression size
- Benchmark evaluation: O(k) where k = omega coefficient
- Growth comparison: O(k) per evaluation point
"""

import math
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable, List, Tuple


# ---------------------------------------------------------------------------
# Algorithm 1: OmegaBlock — Ordinal Notations Below ω²
# ---------------------------------------------------------------------------

@dataclass(frozen=True, order=False)
class OmegaBlock:
    """
    Ordinal notation for α < ω² in Cantor normal form.

    Represents the ordinal ω·k + m where:
    - k (omega_coeff): counts the number of ω-jumps (EML nesting depth)
    - m (finite_part): finite correction within the ω-block

    Ordering is lexicographic: first compare k, then m.

    Pseudocode:
        struct OmegaBlock:
            k: Nat  -- omega coefficient
            m: Nat  -- finite part
        ordinal(k, m) = ω·k + m
    """
    omega_coeff: int
    finite_part: int = 0

    def __le__(self, other: 'OmegaBlock') -> bool:
        return (self.omega_coeff, self.finite_part) <= (other.omega_coeff, other.finite_part)

    def __lt__(self, other: 'OmegaBlock') -> bool:
        return (self.omega_coeff, self.finite_part) < (other.omega_coeff, other.finite_part)

    def __repr__(self) -> str:
        if self.omega_coeff == 0:
            return f"⟨0, {self.finite_part}⟩"
        if self.finite_part == 0:
            return f"⟨{self.omega_coeff}, 0⟩ = ω·{self.omega_coeff}"
        return f"⟨{self.omega_coeff}, {self.finite_part}⟩ = ω·{self.omega_coeff}+{self.finite_part}"

    @staticmethod
    def max(a: 'OmegaBlock', b: 'OmegaBlock') -> 'OmegaBlock':
        """Lexicographic maximum. O(1)."""
        if a.omega_coeff > b.omega_coeff:
            return a
        if a.omega_coeff < b.omega_coeff:
            return b
        return OmegaBlock(a.omega_coeff, max(a.finite_part, b.finite_part))

    def succ_omega(self) -> 'OmegaBlock':
        """Jump to next ω-block: ⟨k,m⟩ → ⟨k+1, 0⟩. O(1)."""
        return OmegaBlock(self.omega_coeff + 1, 0)


# ---------------------------------------------------------------------------
# Algorithm 2: EML Expression AST with Rank Inference
# ---------------------------------------------------------------------------

class ExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()


class EmlExpr:
    """
    EML expression with compositional rank inference.

    Rank inference runs in O(n) time where n = number of AST nodes.
    Each node's rank is computed bottom-up in a single traversal.

    Pseudocode:
        function rank(e):
            match e:
                var       => ⟨0, 0⟩
                const(_)  => ⟨0, 0⟩
                add(a,b)  => max(rank(a), rank(b))
                mul(a,b)  => max(rank(a), rank(b))
                neg(a)    => rank(a)
                eml(a,b)  => ⟨1 + max(rank(a).k, rank(b).k), 0⟩
    """
    def __init__(self, kind: ExprKind, value=None, children=None):
        self.kind = kind
        self.value = value  # For CONST
        self.children = children or []

    @staticmethod
    def var() -> 'EmlExpr':
        return EmlExpr(ExprKind.VAR)

    @staticmethod
    def const(c: float) -> 'EmlExpr':
        return EmlExpr(ExprKind.CONST, value=c)

    @staticmethod
    def add(a: 'EmlExpr', b: 'EmlExpr') -> 'EmlExpr':
        return EmlExpr(ExprKind.ADD, children=[a, b])

    @staticmethod
    def mul(a: 'EmlExpr', b: 'EmlExpr') -> 'EmlExpr':
        return EmlExpr(ExprKind.MUL, children=[a, b])

    @staticmethod
    def neg(a: 'EmlExpr') -> 'EmlExpr':
        return EmlExpr(ExprKind.NEG, children=[a])

    @staticmethod
    def eml(a: 'EmlExpr', b: 'EmlExpr') -> 'EmlExpr':
        """eml(a,b) = a * exp(b)"""
        return EmlExpr(ExprKind.EML, children=[a, b])

    def eval(self, x: float) -> float:
        """Evaluate expression at x. O(n) time, O(depth) stack."""
        if self.kind == ExprKind.VAR:
            return x
        elif self.kind == ExprKind.CONST:
            return self.value
        elif self.kind == ExprKind.ADD:
            return self.children[0].eval(x) + self.children[1].eval(x)
        elif self.kind == ExprKind.MUL:
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.kind == ExprKind.NEG:
            return -self.children[0].eval(x)
        elif self.kind == ExprKind.EML:
            a_val = self.children[0].eval(x)
            b_val = self.children[1].eval(x)
            try:
                result = a_val * math.exp(b_val)
                return result if math.isfinite(result) else float('inf')
            except OverflowError:
                return float('inf')
        raise ValueError(f"Unknown kind: {self.kind}")

    def rank(self) -> OmegaBlock:
        """
        Compositional ordinal rank inference. O(n) time.

        Returns the OmegaBlock ⟨k, m⟩ representing the ordinal ω·k + m
        that classifies this expression's asymptotic growth.
        """
        if self.kind == ExprKind.VAR:
            return OmegaBlock(0, 0)
        elif self.kind == ExprKind.CONST:
            return OmegaBlock(0, 0)
        elif self.kind in (ExprKind.ADD, ExprKind.MUL):
            return OmegaBlock.max(self.children[0].rank(), self.children[1].rank())
        elif self.kind == ExprKind.NEG:
            return self.children[0].rank()
        elif self.kind == ExprKind.EML:
            r_a = self.children[0].rank()
            r_b = self.children[1].rank()
            return OmegaBlock(1 + max(r_a.omega_coeff, r_b.omega_coeff), 0)
        raise ValueError(f"Unknown kind: {self.kind}")

    def eml_depth(self) -> int:
        """EML nesting depth. O(n) time."""
        if self.kind in (ExprKind.VAR, ExprKind.CONST):
            return 0
        elif self.kind in (ExprKind.ADD, ExprKind.MUL):
            return max(self.children[0].eml_depth(), self.children[1].eml_depth())
        elif self.kind == ExprKind.NEG:
            return self.children[0].eml_depth()
        elif self.kind == ExprKind.EML:
            return 1 + max(self.children[0].eml_depth(), self.children[1].eml_depth())
        raise ValueError(f"Unknown kind: {self.kind}")

    def size(self) -> int:
        """Number of AST nodes. O(n)."""
        return 1 + sum(c.size() for c in self.children)


# ---------------------------------------------------------------------------
# Algorithm 3: Benchmark Hierarchy
# ---------------------------------------------------------------------------

def iter_exp(n: int, x: float) -> float:
    """
    Iterated exponential: iterExp(0, x) = x, iterExp(n+1, x) = exp(iterExp(n, x)).

    Time: O(n)
    Space: O(1)
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if not math.isfinite(result):
                return float('inf')
        except OverflowError:
            return float('inf')
    return result


def benchmark(block: OmegaBlock, x: float) -> float:
    """
    Benchmark function for ordinal level ⟨k, m⟩.

    benchmark(⟨k, m⟩, x) = iterExp(k, x + m + 1)

    This provides the growth reference for each ordinal level:
    - ⟨0, 0⟩: x + 1 (linear)
    - ⟨1, 0⟩: exp(x + 1) (exponential)
    - ⟨k, 0⟩: iterExp(k, x + 1) (k-fold iterated exponential)

    Time: O(k)
    Space: O(1)
    """
    return iter_exp(block.omega_coeff, x + block.finite_part + 1)


# ---------------------------------------------------------------------------
# Algorithm 4: Verified Ordinal Classifier
# ---------------------------------------------------------------------------

@dataclass
class ClassificationCertificate:
    """
    A growth classification certificate for an EML expression.

    Contains:
    - rank: the ordinal rank ⟨k, m⟩
    - depth: EML nesting depth (= rank.omega_coeff)
    - hardy_level: the Hardy level (= rank.omega_coeff)
    - growth_class: human-readable description

    The key invariant (proved in Lean):
        rank.omega_coeff == depth == hardy_level
    """
    rank: OmegaBlock
    depth: int
    hardy_level: int
    growth_class: str
    expression_size: int


def classify(expr: EmlExpr) -> ClassificationCertificate:
    """
    Classify an EML expression by its ordinal growth rank.

    Returns a ClassificationCertificate containing:
    - The ordinal rank ⟨k, m⟩
    - The EML depth (= k, by Theorem 2)
    - The Hardy level (= k, by Theorem 3)
    - A human-readable growth class description

    Time: O(n) where n = expression size
    Space: O(depth) for recursive traversal

    Pseudocode:
        function classify(e):
            r = rank(e)
            d = eml_depth(e)
            assert r.k == d  // Theorem 2
            growth = describe_growth(r.k)
            return Certificate(r, d, r.k, growth, size(e))
    """
    r = expr.rank()
    d = expr.eml_depth()
    assert r.omega_coeff == d, "Invariant violated: rank.ω ≠ depth"

    growth_descriptions = {
        0: "polynomial (at most polynomial growth)",
        1: "single exponential (exp-class)",
        2: "double exponential (exp∘exp-class)",
        3: "triple exponential (exp³-class)",
    }
    growth = growth_descriptions.get(
        r.omega_coeff,
        f"{r.omega_coeff}-fold iterated exponential"
    )

    return ClassificationCertificate(
        rank=r,
        depth=d,
        hardy_level=r.omega_coeff,
        growth_class=growth,
        expression_size=expr.size()
    )


# ---------------------------------------------------------------------------
# Algorithm 5: Canonical Expression Constructor
# ---------------------------------------------------------------------------

def canonical_iterexp(n: int) -> EmlExpr:
    """
    Build the canonical EML expression for iterExp(n).

    canonical_iterexp(0) = var
    canonical_iterexp(n+1) = eml(const(1), canonical_iterexp(n))

    Satisfies: rank(canonical_iterexp(n)) = ⟨n, 0⟩  (Theorem 1)

    Time: O(n)
    Space: O(n) for the expression tree
    """
    if n == 0:
        return EmlExpr.var()
    return EmlExpr.eml(EmlExpr.const(1), canonical_iterexp(n - 1))


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("Ordinal Classification — Algorithm Demonstrations\n")

    # Build and classify expressions
    expressions = [
        ("x", EmlExpr.var()),
        ("x²", EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        ("exp(x)", canonical_iterexp(1)),
        ("x·exp(x)", EmlExpr.eml(EmlExpr.var(), EmlExpr.var())),
        ("exp(exp(x))", canonical_iterexp(2)),
        ("exp³(x)", canonical_iterexp(3)),
        ("exp⁵(x)", canonical_iterexp(5)),
    ]

    print(f"{'Expression':<20} {'Rank':<20} {'Growth Class':<35} {'Size':>5}")
    print("-" * 80)
    for name, expr in expressions:
        cert = classify(expr)
        print(f"{name:<20} {str(cert.rank):<20} {cert.growth_class:<35} {cert.expression_size:>5}")

    print("\n--- Benchmark values at x=3 ---")
    for k in range(5):
        b = OmegaBlock(k, 0)
        val = benchmark(b, 3.0)
        if math.isfinite(val):
            print(f"  F_{{ω·{k}}}(3) = {val:.6e}")
        else:
            print(f"  F_{{ω·{k}}}(3) = ∞ (overflow)")
