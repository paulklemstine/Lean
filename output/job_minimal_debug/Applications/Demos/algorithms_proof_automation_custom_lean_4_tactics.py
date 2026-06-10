#!/usr/bin/env python3
"""
Algorithms: Certified Domain-Specific Proof Automation

Complete implementations of the core algorithms with docstrings,
type hints, complexity analysis, and examples.
"""

from typing import List, Tuple, Optional, Callable, Union, Dict
from dataclasses import dataclass
from enum import Enum
import math


# ============================================================
# 1. TROPICAL EXPRESSION NORMALIZATION
# ============================================================

class ExprType(Enum):
    VAR = "var"
    CONST = "const"
    ADD = "add"
    MIN = "min"

@dataclass
class TropExpr:
    """Reified tropical (min-plus) expression.

    Variables are strings, constants are non-negative integers.
    TAdd is ordinary addition, TMin is minimum.

    In tropical algebra, the semiring operations are:
    - Tropical addition: min(a, b)
    - Tropical multiplication: a + b

    So TAdd corresponds to tropical multiplication and
    TMin corresponds to tropical addition.
    """
    kind: ExprType
    name: Optional[str] = None      # for VAR
    value: Optional[int] = None     # for CONST
    left: Optional['TropExpr'] = None   # for ADD, MIN
    right: Optional['TropExpr'] = None  # for ADD, MIN

    @staticmethod
    def var(name: str) -> 'TropExpr':
        return TropExpr(ExprType.VAR, name=name)

    @staticmethod
    def const(val: int) -> 'TropExpr':
        return TropExpr(ExprType.CONST, value=val)

    @staticmethod
    def add(left: 'TropExpr', right: 'TropExpr') -> 'TropExpr':
        return TropExpr(ExprType.ADD, left=left, right=right)

    @staticmethod
    def tmin(left: 'TropExpr', right: 'TropExpr') -> 'TropExpr':
        return TropExpr(ExprType.MIN, left=left, right=right)

    def eval(self, sigma: Dict[str, int]) -> int:
        """Evaluate under valuation sigma.

        Args:
            sigma: mapping from variable names to non-negative integers

        Returns:
            Evaluation result (non-negative integer)

        Time: O(|e|) where |e| is expression size
        Space: O(depth(e)) for recursion stack
        """
        if self.kind == ExprType.VAR:
            return sigma[self.name]
        elif self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.ADD:
            return self.left.eval(sigma) + self.right.eval(sigma)
        elif self.kind == ExprType.MIN:
            return min(self.left.eval(sigma), self.right.eval(sigma))

    def __repr__(self):
        if self.kind == ExprType.VAR:
            return self.name
        elif self.kind == ExprType.CONST:
            return str(self.value)
        elif self.kind == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == ExprType.MIN:
            return f"min({self.left}, {self.right})"


# Type alias: a monomial is a list of base expressions to sum
Monomial = List[TropExpr]
# Normal form: list of monomials, semantics = min over sums
NormalForm = List[Monomial]


def tropical_normalize(e: TropExpr) -> NormalForm:
    """Convert tropical expression to min-of-sums normal form.

    The normal form distributes addition over minimum exhaustively:
      a + min(b, c) → min(a + b, a + c)

    This is the tropical analogue of expanding a polynomial into
    a sum of monomials, except the "sum" is min and "product" is +.

    Args:
        e: Tropical expression to normalize

    Returns:
        List of monomials (each a list of base expressions).
        Semantics: min over (sum within each monomial)

    Time complexity: O(|nf|) where |nf| is the size of the output.
        In the worst case, |nf| = O(2^d) where d is the min-depth.
    Space complexity: O(|nf|) for the output.

    Soundness guarantee (proved in Lean 4):
        eval(σ, e) = min_{m ∈ normalize(e)} Σ_{t ∈ m} eval(σ, t)
    """
    if e.kind in (ExprType.VAR, ExprType.CONST):
        return [[e]]
    elif e.kind == ExprType.MIN:
        nf_left = tropical_normalize(e.left)
        nf_right = tropical_normalize(e.right)
        return nf_left + nf_right
    elif e.kind == ExprType.ADD:
        nf_left = tropical_normalize(e.left)
        nf_right = tropical_normalize(e.right)
        return [m1 + m2 for m1 in nf_left for m2 in nf_right]


def eval_monomial(sigma: Dict[str, int], m: Monomial) -> int:
    """Evaluate a monomial (sum of base evaluations)."""
    return sum(e.eval(sigma) for e in m)


def eval_normal_form(sigma: Dict[str, int], nf: NormalForm) -> int:
    """Evaluate a normal form (min over monomial evaluations)."""
    return min(eval_monomial(sigma, m) for m in nf)


def tropical_expressions_equal(e1: TropExpr, e2: TropExpr,
                                test_valuations: List[Dict[str, int]]) -> bool:
    """Check if two tropical expressions are equal on given valuations.

    This is a computational approximation to the reflection principle:
    if normalize(e1) == normalize(e2) (structurally), then
    eval(σ, e1) == eval(σ, e2) for ALL σ.

    For testing, we check on finitely many valuations.

    Args:
        e1, e2: Tropical expressions
        test_valuations: List of variable assignments to test

    Returns:
        True if both expressions agree on all test valuations
    """
    for sigma in test_valuations:
        if e1.eval(sigma) != e2.eval(sigma):
            return False
    return True


# ============================================================
# 2. BOUNDED ARITHMETIC REFLECTION
# ============================================================

def nat_check_divisible(a: int, b: int) -> bool:
    """Boolean divisibility check: a | b.

    Convention: 0 | 0 is True, 0 | b is False for b > 0.

    Soundness (proved in Lean 4):
        nat_check_divisible(a, b) = True → a | b
    Completeness (proved in Lean 4):
        a | b → nat_check_divisible(a, b) = True

    Time: O(log(max(a, b))) for modular reduction
    Space: O(1)
    """
    if a == 0:
        return b == 0
    return b % a == 0


def nat_check_exists_up_to(N: int, p: Callable[[int], bool]) -> Tuple[bool, Optional[int]]:
    """Bounded existential search with witness extraction.

    Returns (True, witness) if ∃ n ≤ N with p(n), else (False, None).

    Soundness (proved in Lean 4):
        result = True → ∃ n ≤ N, p(n) = True
    Completeness (proved in Lean 4):
        (∃ n ≤ N, p(n) = True) → result = True

    Time: O(N · T_p) where T_p is cost of evaluating p
    Space: O(1) beyond p's workspace
    """
    for n in range(N + 1):
        if p(n):
            return True, n
    return False, None


def nat_check_forall_up_to(N: int, p: Callable[[int], bool]) -> Tuple[bool, Optional[int]]:
    """Bounded universal check with counterexample extraction.

    Returns (True, None) if ∀ n ≤ N, p(n), else (False, counterexample).

    Soundness (proved in Lean 4):
        result = True → ∀ n ≤ N, p(n) = True
    Completeness (proved in Lean 4):
        (∀ n ≤ N, p(n) = True) → result = True

    Time: O(N · T_p)
    Space: O(1)
    """
    for n in range(N + 1):
        if not p(n):
            return False, n
    return True, None


# ============================================================
# 2b. REIFIED DIVISIBILITY PREDICATES
# ============================================================

class DivPredType(Enum):
    DVD = "dvd"
    AND = "and"
    OR = "or"

@dataclass
class DivPred:
    """Reified divisibility predicate with certified checker.

    Supports: divisibility (a | b), conjunction, disjunction.

    Soundness (proved in Lean 4):
        check(p) = True → toProp(p)
    Completeness (proved in Lean 4):
        toProp(p) → check(p) = True
    """
    kind: DivPredType
    a: Optional[int] = None
    b: Optional[int] = None
    left: Optional['DivPred'] = None
    right: Optional['DivPred'] = None

    @staticmethod
    def dvd(a: int, b: int) -> 'DivPred':
        return DivPred(DivPredType.DVD, a=a, b=b)

    @staticmethod
    def conj(left: 'DivPred', right: 'DivPred') -> 'DivPred':
        return DivPred(DivPredType.AND, left=left, right=right)

    @staticmethod
    def disj(left: 'DivPred', right: 'DivPred') -> 'DivPred':
        return DivPred(DivPredType.OR, left=left, right=right)

    def check(self) -> bool:
        if self.kind == DivPredType.DVD:
            return nat_check_divisible(self.a, self.b)
        elif self.kind == DivPredType.AND:
            return self.left.check() and self.right.check()
        elif self.kind == DivPredType.OR:
            return self.left.check() or self.right.check()

    def to_prop_str(self) -> str:
        if self.kind == DivPredType.DVD:
            return f"{self.a} | {self.b}"
        elif self.kind == DivPredType.AND:
            return f"({self.left.to_prop_str()} ∧ {self.right.to_prop_str()})"
        elif self.kind == DivPredType.OR:
            return f"({self.left.to_prop_str()} ∨ {self.right.to_prop_str()})"


# ============================================================
# 3. MATRIX ROW-SUM CERTIFICATES
# ============================================================

def abs_row_sum(A: List[List[float]], i: int) -> float:
    """Compute absolute row sum of row i.

    Time: O(n) where n is the number of columns
    Space: O(1)
    """
    return sum(abs(A[i][j]) for j in range(len(A[i])))


def max_abs_row_sum(A: List[List[float]]) -> float:
    """Compute max absolute row sum (∞-operator-norm estimate).

    This is the certificate value C such that
    ∀i, Σⱼ |A_ij| ≤ C.

    Time: O(n²)
    Space: O(1)
    """
    n = len(A)
    if n == 0:
        return 0.0
    return max(abs_row_sum(A, i) for i in range(n))


def verify_row_sum_certificate(A: List[List[float]], C: float) -> Tuple[bool, Optional[int]]:
    """Verify that C is a valid row-sum certificate for A.

    Certificate condition: ∀i, Σⱼ |A_ij| ≤ C.

    Soundness (proved in Lean 4):
        If verified, then ∀i, |Σⱼ A_ij| ≤ C  (spectral_bound_sound)
        and ∀i, |Σⱼ A_ij x_j| ≤ C when ‖x‖_∞ ≤ 1  (spectral_bound_vec)

    Returns:
        (True, None) if certificate is valid
        (False, violating_row) if some row exceeds the bound

    Time: O(n²)
    Space: O(1)
    """
    n = len(A)
    for i in range(n):
        rs = abs_row_sum(A, i)
        if rs > C + 1e-15:
            return False, i
    return True, None


def matrix_vector_bound(A: List[List[float]], x: List[float],
                         C: float) -> Tuple[bool, float]:
    """Verify |Σⱼ A_ij x_j| ≤ C for all i, assuming ‖x‖_∞ ≤ 1.

    Uses the certified bound: if ∀i, Σⱼ |A_ij| ≤ C and ‖x‖_∞ ≤ 1,
    then ∀i, |Σⱼ A_ij x_j| ≤ C.

    Returns:
        (verified: bool, max_entry: float)
    """
    n = len(A)
    max_entry = 0.0
    for i in range(n):
        entry = abs(sum(A[i][j] * x[j] for j in range(n)))
        max_entry = max(max_entry, entry)
    return max_entry <= C + 1e-12, max_entry


# ============================================================
# EXAMPLES
# ============================================================

if __name__ == "__main__":
    # Tropical normalization
    a = TropExpr.var("a")
    b = TropExpr.var("b")
    c = TropExpr.var("c")

    expr = TropExpr.add(a, TropExpr.tmin(b, c))
    nf = tropical_normalize(expr)
    print(f"Tropical: {expr}")
    print(f"Normal form: {len(nf)} monomials")
    sigma = {"a": 3, "b": 5, "c": 2}
    print(f"eval({sigma}) = {expr.eval(sigma)}")
    print(f"nf_eval({sigma}) = {eval_normal_form(sigma, nf)}")

    # Divisibility
    print(f"\n3 | 12: {nat_check_divisible(3, 12)}")
    print(f"5 | 12: {nat_check_divisible(5, 12)}")

    # Bounded search
    found, witness = nat_check_exists_up_to(100, lambda n: n > 50 and n % 7 == 0)
    print(f"\nSmallest n > 50 with 7 | n: {witness}")

    # Matrix bounds
    A = [[1, -2, 0], [3, 1, -1], [0, 2, 1]]
    C = max_abs_row_sum(A)
    valid, _ = verify_row_sum_certificate(A, C)
    print(f"\nMatrix row-sum bound: {C}, valid: {valid}")
