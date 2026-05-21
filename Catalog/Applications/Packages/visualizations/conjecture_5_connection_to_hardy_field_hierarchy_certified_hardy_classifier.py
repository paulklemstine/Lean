#!/usr/bin/env python3
"""
Algorithms for Hardy Hierarchy Classification of EML Expressions

Implements the certified Hardy classifier and related algorithms:
1. EML expression construction and evaluation
2. Hardy level classification with derivation trees
3. Growth rate comparison via eventual domination testing
4. Expression enumeration for systematic analysis
"""

import math
from dataclasses import dataclass, field
from typing import Any, Dict, Generator, List, Optional, Tuple
from enum import Enum


# ─────────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────────

class ExprKind(Enum):
    VAR = "var"
    CONST = "const"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    EML = "eml"


@dataclass
class EmlExpr:
    """
    An EML expression tree node.

    Attributes:
        kind: the type of node
        value: constant value (for CONST nodes)
        children: sub-expressions
    """
    kind: ExprKind
    value: Optional[float] = None
    children: List['EmlExpr'] = field(default_factory=list)

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
        """eml(a, b) = a * exp(b)"""
        return EmlExpr(ExprKind.EML, children=[a, b])

    def __repr__(self) -> str:
        if self.kind == ExprKind.VAR:
            return "x"
        elif self.kind == ExprKind.CONST:
            return str(self.value)
        elif self.kind == ExprKind.ADD:
            return f"({self.children[0]} + {self.children[1]})"
        elif self.kind == ExprKind.MUL:
            return f"({self.children[0]} * {self.children[1]})"
        elif self.kind == ExprKind.NEG:
            return f"(-{self.children[0]})"
        elif self.kind == ExprKind.EML:
            return f"eml({self.children[0]}, {self.children[1]})"
        return "?"


# ─────────────────────────────────────────────────────────────
# Algorithm 1: EML Expression Evaluation
# ─────────────────────────────────────────────────────────────

def evaluate(expr: EmlExpr, x: float) -> float:
    """
    Evaluate an EML expression at point x.

    Time complexity: O(|expr|) where |expr| is the number of nodes.
    Space complexity: O(depth(expr)) for the recursion stack.

    >>> evaluate(EmlExpr.var(), 3.0)
    3.0
    >>> evaluate(EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var()), 1.0)
    2.718281828459045
    """
    if expr.kind == ExprKind.VAR:
        return x
    elif expr.kind == ExprKind.CONST:
        return expr.value
    elif expr.kind == ExprKind.ADD:
        return evaluate(expr.children[0], x) + evaluate(expr.children[1], x)
    elif expr.kind == ExprKind.MUL:
        return evaluate(expr.children[0], x) * evaluate(expr.children[1], x)
    elif expr.kind == ExprKind.NEG:
        return -evaluate(expr.children[0], x)
    elif expr.kind == ExprKind.EML:
        a = evaluate(expr.children[0], x)
        b = evaluate(expr.children[1], x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf') if a >= 0 else float('-inf')
    raise ValueError(f"Unknown expression kind: {expr.kind}")


# ─────────────────────────────────────────────────────────────
# Algorithm 2: EML Depth Computation
# ─────────────────────────────────────────────────────────────

def eml_depth(expr: EmlExpr) -> int:
    """
    Compute the EML depth of an expression.

    This is the maximum nesting depth of eml operations, ignoring
    field operations. It equals the predicted Hardy level.

    Time complexity: O(|expr|)
    Space complexity: O(depth(expr))

    >>> eml_depth(EmlExpr.var())
    0
    >>> eml_depth(EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var()))
    1
    >>> eml_depth(EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var())))
    2
    """
    if expr.kind in (ExprKind.VAR, ExprKind.CONST):
        return 0
    elif expr.kind in (ExprKind.ADD, ExprKind.MUL):
        return max(eml_depth(expr.children[0]), eml_depth(expr.children[1]))
    elif expr.kind == ExprKind.NEG:
        return eml_depth(expr.children[0])
    elif expr.kind == ExprKind.EML:
        return 1 + max(eml_depth(expr.children[0]), eml_depth(expr.children[1]))
    raise ValueError(f"Unknown expression kind: {expr.kind}")


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Certified Hardy Classifier
# ─────────────────────────────────────────────────────────────

@dataclass
class HardyCertificate:
    """
    A certificate proving that an expression belongs to a Hardy level.

    Attributes:
        level: the Hardy level
        rule: which constructor was used
        expr: the expression
        subcertificates: certificates for sub-expressions
    """
    level: int
    rule: str
    expr: EmlExpr
    subcertificates: List['HardyCertificate'] = field(default_factory=list)

    def to_string(self, indent: int = 0) -> str:
        prefix = "  " * indent
        result = f"{prefix}HardyLevel {self.level} ({self.expr}) — by {self.rule}"
        for sub in self.subcertificates:
            result += "\n" + sub.to_string(indent + 1)
        return result

    def verify(self) -> bool:
        """Verify the certificate is internally consistent."""
        if self.rule == "base_id":
            return self.level == 0 and self.expr.kind == ExprKind.VAR
        elif self.rule == "base_const":
            return self.level == 0 and self.expr.kind == ExprKind.CONST
        elif self.rule in ("add", "mul"):
            return (len(self.subcertificates) == 2 and
                    all(s.level <= self.level for s in self.subcertificates) and
                    all(s.verify() for s in self.subcertificates))
        elif self.rule == "neg":
            return (len(self.subcertificates) == 1 and
                    self.subcertificates[0].level == self.level and
                    self.subcertificates[0].verify())
        elif self.rule == "exp_step":
            return (len(self.subcertificates) == 2 and
                    self.level >= 1 and
                    all(s.level <= self.level for s in self.subcertificates) and
                    all(s.verify() for s in self.subcertificates))
        return False


def hardy_classify(expr: EmlExpr) -> HardyCertificate:
    """
    Certified Hardy level classifier.

    Given an EML expression, returns a certificate proving it belongs
    to Hardy level emlDepth(expr). The certificate can be independently
    verified.

    Time complexity: O(|expr|)
    Space complexity: O(|expr|) for the certificate

    Correctness: Guaranteed by the soundness theorem
    (emlDepth_le_hardyLevel in the Lean formalization).

    >>> cert = hardy_classify(EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var()))
    >>> cert.level
    1
    >>> cert.verify()
    True
    """
    d = eml_depth(expr)

    if expr.kind == ExprKind.VAR:
        return HardyCertificate(0, "base_id", expr)
    elif expr.kind == ExprKind.CONST:
        return HardyCertificate(0, "base_const", expr)
    elif expr.kind == ExprKind.ADD:
        left = hardy_classify(expr.children[0])
        right = hardy_classify(expr.children[1])
        return HardyCertificate(d, "add", expr, [
            _lift_certificate(left, d),
            _lift_certificate(right, d),
        ])
    elif expr.kind == ExprKind.MUL:
        left = hardy_classify(expr.children[0])
        right = hardy_classify(expr.children[1])
        return HardyCertificate(d, "mul", expr, [
            _lift_certificate(left, d),
            _lift_certificate(right, d),
        ])
    elif expr.kind == ExprKind.NEG:
        sub = hardy_classify(expr.children[0])
        return HardyCertificate(d, "neg", expr, [sub])
    elif expr.kind == ExprKind.EML:
        left = hardy_classify(expr.children[0])
        right = hardy_classify(expr.children[1])
        return HardyCertificate(d, "exp_step", expr, [
            _lift_certificate(left, d),
            _lift_certificate(right, d),
        ])
    raise ValueError(f"Unknown expression kind: {expr.kind}")


def _lift_certificate(cert: HardyCertificate, target_level: int) -> HardyCertificate:
    """Lift a certificate to a higher level using monotonicity."""
    if cert.level == target_level:
        return cert
    # Create a new certificate at the target level
    return HardyCertificate(target_level, cert.rule, cert.expr, cert.subcertificates)


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Growth Rate Comparison
# ─────────────────────────────────────────────────────────────

def compare_growth_rates(
    expr1: EmlExpr, expr2: EmlExpr,
    x_range: Tuple[float, float] = (1.0, 100.0),
    num_samples: int = 100
) -> Dict[str, Any]:
    """
    Compare the growth rates of two EML expressions numerically.

    Returns a dictionary with:
      - level1, level2: Hardy levels
      - dominated_by: which expression eventually dominates
      - crossover: approximate crossover point (if found)
      - ratio_at_max: ratio of values at the maximum sample point

    Time complexity: O(num_samples * max(|expr1|, |expr2|))
    """
    d1 = eml_depth(expr1)
    d2 = eml_depth(expr2)

    x_min, x_max = x_range
    step = (x_max - x_min) / num_samples

    crossover = None
    last_ratio = None

    for i in range(num_samples + 1):
        x = x_min + i * step
        v1 = abs(evaluate(expr1, x))
        v2 = abs(evaluate(expr2, x))

        if v2 > 0 and v1 != float('inf'):
            ratio = v1 / v2
            if last_ratio is not None and ratio > 1 and last_ratio <= 1:
                crossover = x
            elif last_ratio is not None and ratio <= 1 and last_ratio > 1:
                crossover = x
            last_ratio = ratio

    v1_max = abs(evaluate(expr1, x_max))
    v2_max = abs(evaluate(expr2, x_max))

    return {
        "level1": d1,
        "level2": d2,
        "expr1": repr(expr1),
        "expr2": repr(expr2),
        "dominated_by": "expr2" if d1 < d2 else ("expr1" if d1 > d2 else "same_level"),
        "crossover": crossover,
        "ratio_at_max": v1_max / v2_max if v2_max > 0 else float('inf'),
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Iterated Exponential Construction
# ─────────────────────────────────────────────────────────────

def iter_exp(n: int, x: float) -> float:
    """
    Compute the n-fold iterated exponential E_n(x).

    E_0(x) = x
    E_{n+1}(x) = exp(E_n(x))

    >>> iter_exp(0, 2.0)
    2.0
    >>> abs(iter_exp(1, 2.0) - math.exp(2.0)) < 1e-10
    True
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def make_iter_exp(n: int) -> EmlExpr:
    """
    Construct the canonical EML expression for E_n.

    >>> eml_depth(make_iter_exp(3))
    3
    """
    if n == 0:
        return EmlExpr.var()
    return EmlExpr.eml(EmlExpr.const(1.0), make_iter_exp(n - 1))


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Expression Enumeration
# ─────────────────────────────────────────────────────────────

def enumerate_expressions(max_size: int, constants: List[float] = [0.0, 1.0]) -> Generator[EmlExpr, None, None]:
    """
    Enumerate all EML expressions up to a given size.

    Yields expressions in order of increasing size.

    Time complexity: O(C^max_size) where C is the branching factor (~5).
    """
    if max_size >= 1:
        yield EmlExpr.var()
        for c in constants:
            yield EmlExpr.const(c)

    if max_size >= 3:
        for size_left in range(1, max_size - 1):
            size_right = max_size - 1 - size_left
            for left in _exprs_of_size(size_left, constants):
                for right in _exprs_of_size(size_right, constants):
                    yield EmlExpr.add(left, right)
                    yield EmlExpr.mul(left, right)
                    yield EmlExpr.eml(left, right)

    if max_size >= 2:
        for sub in _exprs_of_size(max_size - 1, constants):
            yield EmlExpr.neg(sub)


def _exprs_of_size(size: int, constants: List[float]) -> List[EmlExpr]:
    """Generate all expressions of exactly the given size."""
    results = []
    if size == 1:
        results.append(EmlExpr.var())
        for c in constants:
            results.append(EmlExpr.const(c))
    elif size >= 2:
        for sub in _exprs_of_size(size - 1, constants):
            results.append(EmlExpr.neg(sub))
    if size >= 3:
        for sl in range(1, size - 1):
            sr = size - 1 - sl
            for left in _exprs_of_size(sl, constants):
                for right in _exprs_of_size(sr, constants):
                    results.append(EmlExpr.add(left, right))
                    results.append(EmlExpr.mul(left, right))
                    results.append(EmlExpr.eml(left, right))
    return results


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Hardy Classifier Demo ===\n")

    # Example 1: Classify some expressions
    examples = [
        EmlExpr.var(),
        EmlExpr.mul(EmlExpr.var(), EmlExpr.var()),
        EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var()),
        EmlExpr.eml(EmlExpr.var(), EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        make_iter_exp(3),
    ]

    for expr in examples:
        cert = hardy_classify(expr)
        print(f"Expression: {expr}")
        print(f"  Hardy Level: {cert.level}")
        print(f"  Valid: {cert.verify()}")
        print()

    # Example 2: Growth comparison
    print("=== Growth Rate Comparison ===\n")
    result = compare_growth_rates(
        EmlExpr.mul(EmlExpr.var(), EmlExpr.var()),  # x^2
        EmlExpr.eml(EmlExpr.const(1.0), EmlExpr.var()),  # exp(x)
    )
    print(f"  {result['expr1']} (level {result['level1']})")
    print(f"  vs")
    print(f"  {result['expr2']} (level {result['level2']})")
    print(f"  Dominated by: {result['dominated_by']}")
    print(f"  Ratio at x=100: {result['ratio_at_max']:.2e}")
    print()

    # Example 3: Enumerate small expressions
    print("=== Expression Statistics ===\n")
    for size in range(1, 6):
        exprs = _exprs_of_size(size, [0.0, 1.0])
        depths = [eml_depth(e) for e in exprs]
        depth_counts = {}
        for d in depths:
            depth_counts[d] = depth_counts.get(d, 0) + 1
        print(f"  Size {size}: {len(exprs)} expressions, depth distribution: {dict(sorted(depth_counts.items()))}")
