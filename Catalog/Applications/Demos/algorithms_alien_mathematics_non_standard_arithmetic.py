#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Nonstandard Arithmetic

Implements the core algorithms from the research paper:
1. Eventual equivalence checking
2. Arithmetic term evaluation and transfer
3. Eventual ordering comparison
4. Divisibility checking
"""

from typing import Callable, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Algorithm 1: Eventual Equivalence Checker
# ============================================================

def check_eventual_equality(
    f: Callable[[int], int],
    g: Callable[[int], int],
    max_check: int = 10000
) -> Tuple[bool, Optional[int]]:
    """Check if two sequences are eventually equal.

    Scans up to max_check terms and returns (True, N) where N is
    the threshold from which the sequences agree, or (False, None)
    if a disagreement is found at the boundary.

    Time complexity: O(max_check)
    Space complexity: O(1)

    >>> check_eventual_equality(lambda n: n**2, lambda n: n**2)
    (True, 0)
    >>> check_eventual_equality(lambda n: n if n < 5 else n+1, lambda n: n+1)
    (True, 5)
    """
    last_disagreement = -1
    for n in range(max_check):
        if f(n) != g(n):
            last_disagreement = n

    if last_disagreement == -1:
        return True, 0
    elif last_disagreement < max_check - 1:
        return True, last_disagreement + 1
    else:
        return False, None


def check_eventual_le(
    f: Callable[[int], int],
    g: Callable[[int], int],
    max_check: int = 10000
) -> Tuple[bool, Optional[int]]:
    """Check if f(n) ≤ g(n) eventually.

    Time complexity: O(max_check)
    Space complexity: O(1)

    >>> check_eventual_le(lambda n: n, lambda n: n**2)
    (True, 0)
    """
    last_violation = -1
    for n in range(max_check):
        if f(n) > g(n):
            last_violation = n

    if last_violation == -1:
        return True, 0
    elif last_violation < max_check - 1:
        return True, last_violation + 1
    else:
        return False, None


# ============================================================
# Algorithm 2: Arithmetic Term Language and Evaluation
# ============================================================

class TermKind(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()


@dataclass
class ArithTerm:
    """An arithmetic term in the language {const, var, +, ×}.

    This mirrors the Lean `ArithTerm` inductive type.
    """
    kind: TermKind
    value: Optional[int] = None  # For CONST
    left: Optional['ArithTerm'] = None  # For ADD, MUL
    right: Optional['ArithTerm'] = None  # For ADD, MUL

    @staticmethod
    def const(k: int) -> 'ArithTerm':
        return ArithTerm(TermKind.CONST, value=k)

    @staticmethod
    def var() -> 'ArithTerm':
        return ArithTerm(TermKind.VAR)

    @staticmethod
    def add(left: 'ArithTerm', right: 'ArithTerm') -> 'ArithTerm':
        return ArithTerm(TermKind.ADD, left=left, right=right)

    @staticmethod
    def mul(left: 'ArithTerm', right: 'ArithTerm') -> 'ArithTerm':
        return ArithTerm(TermKind.MUL, left=left, right=right)

    def eval_nat(self, n: int) -> int:
        """Evaluate the term at a natural number.

        Time complexity: O(|term|) where |term| is the number of nodes.
        Space complexity: O(depth) for recursion stack.

        >>> ArithTerm.var().eval_nat(5)
        5
        >>> ArithTerm.add(ArithTerm.var(), ArithTerm.const(1)).eval_nat(5)
        6
        """
        if self.kind == TermKind.CONST:
            return self.value
        elif self.kind == TermKind.VAR:
            return n
        elif self.kind == TermKind.ADD:
            return self.left.eval_nat(n) + self.right.eval_nat(n)
        elif self.kind == TermKind.MUL:
            return self.left.eval_nat(n) * self.right.eval_nat(n)

    def eval_hyper(self, seq: Callable[[int], int], num_terms: int = 15) -> List[int]:
        """Evaluate the term at a hypernatural (represented by a sequence).

        Returns the first num_terms values of the resulting sequence.
        This mirrors evalHyper in the Lean formalization.

        Time complexity: O(num_terms * |term|)

        >>> x = ArithTerm.var()
        >>> t = ArithTerm.mul(x, ArithTerm.add(x, ArithTerm.const(1)))
        >>> t.eval_hyper(lambda n: n, 5)
        [0, 2, 6, 12, 20]
        """
        return [self.eval_nat(seq(n)) for n in range(num_terms)]

    def __repr__(self):
        if self.kind == TermKind.CONST:
            return str(self.value)
        elif self.kind == TermKind.VAR:
            return "x"
        elif self.kind == TermKind.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == TermKind.MUL:
            return f"({self.left} * {self.right})"


def verify_transfer(
    t1: ArithTerm,
    t2: ArithTerm,
    test_values: List[int] = None,
    hyper_seq: Callable[[int], int] = None,
    num_hyper_terms: int = 20
) -> dict:
    """Verify that a term identity transfers from ℕ to HyperNat.

    Algorithm:
    1. Check t1(n) = t2(n) for all test values in ℕ.
    2. Compute t1 and t2 on a hypernatural sequence.
    3. Check eventual equality of the resulting sequences.

    This is the computational counterpart of Theorem 4.4 (transfer_arith_eq).

    Time complexity: O(|test_values| * |term| + num_hyper_terms * |term|)

    >>> x = ArithTerm.var()
    >>> t1 = ArithTerm.mul(x, ArithTerm.add(x, ArithTerm.const(1)))
    >>> t2 = ArithTerm.add(ArithTerm.mul(x, x), x)
    >>> result = verify_transfer(t1, t2)
    >>> result['nat_verified']
    True
    """
    if test_values is None:
        test_values = list(range(100))
    if hyper_seq is None:
        hyper_seq = lambda n: n  # omega

    # Step 1: Verify in ℕ
    nat_ok = all(t1.eval_nat(n) == t2.eval_nat(n) for n in test_values)

    # Step 2: Evaluate on hypernatural
    hyper_vals_1 = t1.eval_hyper(hyper_seq, num_hyper_terms)
    hyper_vals_2 = t2.eval_hyper(hyper_seq, num_hyper_terms)

    # Step 3: Check eventual equality
    hyper_eq = hyper_vals_1 == hyper_vals_2

    return {
        'term1': str(t1),
        'term2': str(t2),
        'nat_verified': nat_ok,
        'hyper_verified': hyper_eq,
        'hyper_values_1': hyper_vals_1,
        'hyper_values_2': hyper_vals_2,
    }


# ============================================================
# Algorithm 3: Non-Archimedean Witness
# ============================================================

def find_domination_threshold(k: int, seq: Callable[[int], int] = None) -> int:
    """Find the index N from which seq(n) ≥ k.

    For the identity sequence (omega), this is simply k itself.
    This witnesses the proof of ofNat_le_omega.

    Time complexity: O(N) where N is the threshold.

    >>> find_domination_threshold(42)
    42
    >>> find_domination_threshold(100, lambda n: n**2)
    10
    """
    if seq is None:
        seq = lambda n: n
    for n in range(10 * k + 100):
        if seq(n) >= k:
            return n
    return -1  # Not found in range


# ============================================================
# Algorithm 4: Eventual Divisibility Checker
# ============================================================

def check_eventual_divisibility(
    f: Callable[[int], int],
    g: Callable[[int], int],
    max_check: int = 10000
) -> Tuple[bool, Optional[int]]:
    """Check if f(n) | g(n) eventually.

    Mirrors the EventuallyDvd definition in the Lean formalization.

    Time complexity: O(max_check)
    Space complexity: O(1)

    >>> check_eventual_divisibility(lambda n: n, lambda n: n**2)
    (True, 0)
    """
    last_failure = -1
    for n in range(max_check):
        fn = f(n)
        gn = g(n)
        if fn == 0:
            if gn != 0:
                last_failure = n
        elif gn % fn != 0:
            last_failure = n

    if last_failure == -1:
        return True, 0
    elif last_failure < max_check - 1:
        return True, last_failure + 1
    else:
        return False, None


# ============================================================
# Algorithm 5: Polynomial Growth Comparison
# ============================================================

def compare_polynomial_growth(
    p_coeffs: List[int],
    q_coeffs: List[int],
    max_check: int = 1000
) -> dict:
    """Compare two polynomials asymptotically via HyperNat.

    Given polynomial coefficients [a₀, a₁, ..., aₙ] representing
    a₀ + a₁x + a₂x² + ... + aₙxⁿ, determine eventual ordering.

    Time complexity: O(max_check * max(deg_p, deg_q))

    >>> compare_polynomial_growth([0, 1], [0, 0, 1])  # x vs x²
    {'p_le_q': True, 'q_le_p': False, 'threshold_p_le_q': 0, 'relationship': 'p < q eventually'}
    """
    def eval_poly(coeffs, x):
        return sum(c * x**i for i, c in enumerate(coeffs))

    p = lambda n: eval_poly(p_coeffs, n)
    q = lambda n: eval_poly(q_coeffs, n)

    p_le_q, thresh_pq = check_eventual_le(p, q, max_check)
    q_le_p, thresh_qp = check_eventual_le(q, p, max_check)

    if p_le_q and q_le_p:
        relationship = "p = q eventually"
    elif p_le_q:
        relationship = "p < q eventually"
    elif q_le_p:
        relationship = "q < p eventually"
    else:
        relationship = "incomparable in checked range"

    return {
        'p_le_q': p_le_q,
        'q_le_p': q_le_p,
        'threshold_p_le_q': thresh_pq,
        'threshold_q_le_p': thresh_qp,
        'relationship': relationship,
    }


# ============================================================
# Main: Run examples
# ============================================================

if __name__ == "__main__":
    print("Algorithm 1: Eventual Equivalence")
    print("-" * 40)
    f = lambda n: n**2 + (3 if n < 10 else 0)
    g = lambda n: n**2
    result = check_eventual_equality(f, g)
    print(f"  n² + 3·[n<10] ≈ n²? {result}")

    print()
    print("Algorithm 2: Term Transfer Verification")
    print("-" * 40)
    x = ArithTerm.var()
    # x(x+1) = x² + x
    t1 = ArithTerm.mul(x, ArithTerm.add(x, ArithTerm.const(1)))
    t2 = ArithTerm.add(ArithTerm.mul(x, x), x)
    result = verify_transfer(t1, t2)
    print(f"  {result['term1']} = {result['term2']}")
    print(f"  ℕ verified: {result['nat_verified']}")
    print(f"  HyperNat verified: {result['hyper_verified']}")

    print()
    print("Algorithm 3: Non-Archimedean Witness")
    print("-" * 40)
    for k in [10, 100, 1000]:
        N = find_domination_threshold(k)
        print(f"  ω ≥ {k} from index {N}")

    print()
    print("Algorithm 4: Eventual Divisibility")
    print("-" * 40)
    result = check_eventual_divisibility(lambda n: n+1, lambda n: (n+1)**2)
    print(f"  (n+1) | (n+1)²? {result}")
    result = check_eventual_divisibility(lambda n: n+2, lambda n: n+1)
    print(f"  (n+2) | (n+1)? {result}")

    print()
    print("Algorithm 5: Polynomial Growth Comparison")
    print("-" * 40)
    result = compare_polynomial_growth([0, 3, 0], [0, 0, 1])  # 3x vs x²
    print(f"  3x vs x²: {result['relationship']}")
    result = compare_polynomial_growth([0, 0, 1], [0, 0, 1])  # x² vs x²
    print(f"  x² vs x²: {result['relationship']}")
