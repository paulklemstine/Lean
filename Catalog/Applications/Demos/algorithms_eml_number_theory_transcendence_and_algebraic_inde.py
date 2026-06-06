#!/usr/bin/env python3
"""
EML Transcendence Theory — Core Algorithms

Type-hinted implementations of the key algorithms from the research:
1. EML expression evaluation
2. Polynomial lifting and retraction
3. Schanuel independence analysis
4. EML depth computation
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import List, Tuple, Dict, Optional, Callable
import math
from fractions import Fraction


# ============================================================
# Algorithm 1: EML Expression Trees
# ============================================================

class ExprType(Enum):
    RAT = auto()
    EXP = auto()
    LOG = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    EML = auto()


@dataclass
class EMLExpr:
    """An EML expression tree node."""
    op: ExprType
    value: Optional[Fraction] = None  # For RAT nodes
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self) -> float:
        """Evaluate the expression to a floating-point number."""
        if self.op == ExprType.RAT:
            return float(self.value)
        elif self.op == ExprType.EXP:
            return math.exp(self.left.eval())
        elif self.op == ExprType.LOG:
            val = self.left.eval()
            if val <= 0:
                raise ValueError(f"log of non-positive: {val}")
            return math.log(val)
        elif self.op == ExprType.ADD:
            return self.left.eval() + self.right.eval()
        elif self.op == ExprType.SUB:
            return self.left.eval() - self.right.eval()
        elif self.op == ExprType.MUL:
            return self.left.eval() * self.right.eval()
        elif self.op == ExprType.DIV:
            return self.left.eval() / self.right.eval()
        elif self.op == ExprType.EML:
            return math.exp(self.left.eval()) - math.log(self.right.eval())
        raise ValueError(f"Unknown operation: {self.op}")

    def depth(self) -> int:
        """Compute the transcendence depth of the expression."""
        if self.op == ExprType.RAT:
            return 0
        elif self.op in (ExprType.EXP, ExprType.LOG):
            return self.left.depth() + 1
        elif self.op in (ExprType.ADD, ExprType.SUB, ExprType.MUL, ExprType.DIV):
            return max(self.left.depth(), self.right.depth())
        elif self.op == ExprType.EML:
            return max(self.left.depth() + 1, self.right.depth() + 1)
        return 0

    def __repr__(self) -> str:
        if self.op == ExprType.RAT:
            return str(self.value)
        elif self.op == ExprType.EXP:
            return f"exp({self.left})"
        elif self.op == ExprType.LOG:
            return f"log({self.left})"
        elif self.op == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.op == ExprType.SUB:
            return f"({self.left} - {self.right})"
        elif self.op == ExprType.MUL:
            return f"({self.left} * {self.right})"
        elif self.op == ExprType.DIV:
            return f"({self.left} / {self.right})"
        elif self.op == ExprType.EML:
            return f"eml({self.left}, {self.right})"
        return "?"


# Convenience constructors
def rat(q: Fraction) -> EMLExpr:
    return EMLExpr(ExprType.RAT, value=q)

def exp_expr(e: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.EXP, left=e)

def log_expr(e: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.LOG, left=e)

def eml_expr(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.EML, left=e1, right=e2)

def add_expr(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.ADD, left=e1, right=e2)

def sub_expr(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.SUB, left=e1, right=e2)


# ============================================================
# Algorithm 2: Polynomial Lifting and Retraction
# ============================================================

class UniPoly:
    """Univariate polynomial over ℚ, represented as coefficient list."""

    def __init__(self, coeffs: List[Fraction]):
        # Remove trailing zeros
        while coeffs and coeffs[-1] == 0:
            coeffs.pop()
        self.coeffs = coeffs if coeffs else [Fraction(0)]

    def degree(self) -> int:
        return len(self.coeffs) - 1

    def is_zero(self) -> bool:
        return all(c == 0 for c in self.coeffs)

    def eval_at(self, x: float) -> float:
        result = 0.0
        for i, c in enumerate(self.coeffs):
            result += float(c) * (x ** i)
        return result

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}*X")
            else:
                terms.append(f"{c}*X^{i}")
        return " + ".join(terms) if terms else "0"


class MvPoly2:
    """Bivariate polynomial over ℚ, represented as dict {(i,j): coeff}."""

    def __init__(self, terms: Optional[Dict[Tuple[int, int], Fraction]] = None):
        self.terms = {k: v for k, v in (terms or {}).items() if v != 0}

    def is_zero(self) -> bool:
        return not self.terms

    def eval_at(self, x0: float, x1: float) -> float:
        result = 0.0
        for (i, j), c in self.terms.items():
            result += float(c) * (x0 ** i) * (x1 ** j)
        return result

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        terms = []
        for (i, j), c in sorted(self.terms.items()):
            if c == 0:
                continue
            monomial = ""
            if i > 0:
                monomial += f"X₀^{i}" if i > 1 else "X₀"
            if j > 0:
                monomial += f"X₁^{j}" if j > 1 else "X₁"
            if not monomial:
                terms.append(str(c))
            else:
                terms.append(f"{c}*{monomial}")
        return " + ".join(terms) if terms else "0"


def lift_sub_poly(p: UniPoly) -> MvPoly2:
    """
    The polynomial lift: sends P(X) to P(X₀ - X₁).
    
    This is liftSubPoly from the Lean formalization.
    """
    result: Dict[Tuple[int, int], Fraction] = {}
    for k, c_k in enumerate(p.coeffs):
        if c_k == 0:
            continue
        # (X₀ - X₁)^k = Σ_{j=0}^{k} C(k,j) X₀^{k-j} (-X₁)^j
        for j in range(k + 1):
            binom = math.comb(k, j)
            sign = (-1) ** j
            key = (k - j, j)
            result[key] = result.get(key, Fraction(0)) + c_k * Fraction(binom * sign)
    return MvPoly2(result)


def retract_poly(q: MvPoly2) -> UniPoly:
    """
    The retraction: sends Q(X₀, X₁) to Q(X, 0).
    
    This is retractPoly from the Lean formalization.
    """
    max_deg = max((i for (i, j) in q.terms if j == 0), default=0)
    coeffs = [Fraction(0)] * (max_deg + 1)
    for (i, j), c in q.terms.items():
        if j == 0:
            coeffs[i] += c
    return UniPoly(coeffs)


def verify_lifting_retraction():
    """Verify that retract ∘ lift = id."""
    print("Verifying retract ∘ lift = id:")
    test_polys = [
        UniPoly([Fraction(1)]),                          # 1
        UniPoly([Fraction(0), Fraction(1)]),              # X
        UniPoly([Fraction(1), Fraction(-2), Fraction(1)]),  # 1 - 2X + X²
        UniPoly([Fraction(3), Fraction(0), Fraction(-1), Fraction(2)]),  # 3 - X² + 2X³
    ]

    for p in test_polys:
        lifted = lift_sub_poly(p)
        retracted = retract_poly(lifted)
        # Check coefficients match
        for i in range(max(len(p.coeffs), len(retracted.coeffs))):
            c1 = p.coeffs[i] if i < len(p.coeffs) else Fraction(0)
            c2 = retracted.coeffs[i] if i < len(retracted.coeffs) else Fraction(0)
            assert c1 == c2, f"Mismatch at degree {i}: {c1} vs {c2}"
        print(f"  P = {p}  →  lift(P) = {lifted}  →  retract = {retracted}  ✓")


# ============================================================
# Algorithm 3: Schanuel Independence Checker
# ============================================================

def check_q_linear_independence(values: List[float], tolerance: float = 1e-10) -> bool:
    """
    Heuristic check for ℚ-linear independence using LLL-like approach.
    For small lists, check if any integer relation of small height exists.
    """
    n = len(values)
    if n == 0:
        return True
    if n == 1:
        return abs(values[0]) > tolerance

    # For n=2: check if v1/v2 is "close" to any simple rational
    if n == 2 and abs(values[1]) > tolerance:
        ratio = values[0] / values[1]
        # Check rationals p/q for |p|, |q| ≤ 100
        for q in range(1, 101):
            for p in range(-100, 101):
                if abs(ratio - p / q) < tolerance:
                    return False
        return True

    return True  # Conservative: assume independent


def schanuel_analysis(z_values: List[float]) -> Dict:
    """
    Analyze a Schanuel instance: given z-values, compute the combined
    tuple and identify which elements could be algebraically independent.
    """
    n = len(z_values)
    exp_values = [math.exp(z) for z in z_values]
    combined = z_values + exp_values

    # Heuristic: identify algebraic values (close to simple rationals)
    def is_likely_algebraic(x: float) -> bool:
        for q in range(1, 20):
            for p in range(-50, 51):
                if abs(x - p / q) < 1e-10:
                    return True
        return False

    algebraic_mask = [is_likely_algebraic(v) for v in combined]
    transcendental_indices = [i for i, alg in enumerate(algebraic_mask) if not alg]

    return {
        "n": n,
        "z": z_values,
        "exp_z": exp_values,
        "combined": combined,
        "labels": [f"z_{i+1}" for i in range(n)] + [f"e^z_{i+1}" for i in range(n)],
        "algebraic": algebraic_mask,
        "transcendental_count": len(transcendental_indices),
        "transcendental_indices": transcendental_indices,
        "schanuel_predicts": len(transcendental_indices) >= n,
    }


# ============================================================
# Algorithm 4: EML Depth Analysis
# ============================================================

def enumerate_eml_numbers(max_depth: int, rationals: List[Fraction]) -> List[Tuple[str, float, int]]:
    """
    Enumerate EML-constructible numbers up to a given depth.
    Returns list of (expression_string, value, depth).
    """
    results: List[Tuple[str, float, int]] = []

    # Depth 0: rationals
    for q in rationals:
        results.append((str(q), float(q), 0))

    if max_depth < 1:
        return results

    # Depth 1: exp and log of rationals, and eml of rational pairs
    for q in rationals:
        fq = float(q)
        results.append((f"exp({q})", math.exp(fq), 1))
        if fq > 0:
            results.append((f"log({q})", math.log(fq), 1))

    for q1 in rationals:
        for q2 in rationals:
            if float(q2) > 0:
                val = math.exp(float(q1)) - math.log(float(q2))
                results.append((f"eml({q1},{q2})", val, 1))

    if max_depth < 2:
        return results

    # Depth 2: compose exp/log with depth-1 values
    depth1_vals = [(n, v) for n, v, d in results if d == 1]
    for name, val in depth1_vals[:5]:  # Limit to avoid explosion
        results.append((f"exp({name})", math.exp(val), 2))
        if val > 0:
            results.append((f"log({name})", math.log(val), 2))

    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("EML Transcendence Theory — Algorithm Demonstrations")
    print("=" * 60)

    # Demo 1: Expression trees
    print("\n1. EML Expression Trees:")
    e1 = eml_expr(rat(Fraction(1)), rat(Fraction(2)))
    e2 = exp_expr(exp_expr(rat(Fraction(1))))
    e3 = add_expr(e2, log_expr(rat(Fraction(2))))

    for expr in [e1, e2, e3]:
        print(f"   {expr}  =  {expr.eval():.10f}  (depth {expr.depth()})")

    # Demo 2: Lifting verification
    print("\n2. Polynomial Lifting:")
    verify_lifting_retraction()

    # Demo 3: Schanuel analysis
    print("\n3. Schanuel Instance Analysis:")
    for z_vals in [[1.0, math.log(2)], [1.0, math.e], [1.0]]:
        result = schanuel_analysis(z_vals)
        print(f"\n   z = {result['z']}")
        for i, (label, val, alg) in enumerate(
            zip(result["labels"], result["combined"], result["algebraic"])
        ):
            print(f"     {label:10s} = {val:12.6f}  {'(alg)' if alg else '(trans)'}")
        print(f"   Schanuel predicts ≥{result['n']} alg. indep.: {result['schanuel_predicts']}")

    # Demo 4: Depth hierarchy
    print("\n4. EML Depth Hierarchy:")
    rats = [Fraction(1), Fraction(2), Fraction(3)]
    numbers = enumerate_eml_numbers(2, rats)
    for depth in range(3):
        level = [(n, v) for n, v, d in numbers if d == depth]
        print(f"\n   Depth {depth}: ({len(level)} numbers)")
        for name, val in level[:6]:
            print(f"     {name:25s} = {val:.10f}")
        if len(level) > 6:
            print(f"     ... and {len(level) - 6} more")
