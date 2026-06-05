#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for non-standard arithmetic.

Type-hinted implementations of:
1. Ultrapower element representation
2. Ultrapower arithmetic operations
3. Overspill detection
4. GCD transfer computation
5. Polynomial identity verification
"""

from typing import List, Callable, Optional, Tuple, Dict, Any
from dataclasses import dataclass
from enum import Enum
import math


# ============================================================
# §1. Ultrapower Element Representation
# ============================================================

@dataclass
class UltraPowerElement:
    """Represents an element of *ℕ = ℕ^ℕ / U.

    In practice, we store a finite prefix of the representing sequence
    and a description of its asymptotic behavior.
    """
    sequence: List[int]        # finite prefix
    generator: Optional[Callable[[int], int]] = None  # infinite extension
    name: str = "anonymous"

    def evaluate(self, i: int) -> int:
        """Evaluate the representing sequence at index i."""
        if i < len(self.sequence):
            return self.sequence[i]
        elif self.generator is not None:
            return self.generator(i)
        else:
            raise IndexError(f"Index {i} out of range and no generator provided")

    def is_standard(self, window: int = 100) -> Optional[int]:
        """Check if this element appears to be standard (eventually constant).

        Returns the standard value if found, None otherwise.
        """
        values = set()
        for i in range(window):
            values.add(self.evaluate(i))
        if len(values) == 1:
            return values.pop()
        return None


def standard_element(n: int) -> UltraPowerElement:
    """Create the standard element std(n) = [n, n, n, ...]."""
    return UltraPowerElement(
        sequence=[n] * 10,
        generator=lambda _: n,
        name=f"std({n})"
    )


def omega_element() -> UltraPowerElement:
    """Create the canonical non-standard element ω = [0, 1, 2, ...]."""
    return UltraPowerElement(
        sequence=list(range(20)),
        generator=lambda i: i,
        name="ω"
    )


# ============================================================
# §2. Ultrapower Arithmetic
# ============================================================

def ultrapower_add(a: UltraPowerElement, b: UltraPowerElement,
                   window: int = 20) -> UltraPowerElement:
    """Componentwise addition in *ℕ."""
    seq = [a.evaluate(i) + b.evaluate(i) for i in range(window)]
    gen = None
    if a.generator and b.generator:
        gen = lambda i: a.generator(i) + b.generator(i)
    return UltraPowerElement(sequence=seq, generator=gen,
                             name=f"({a.name} + {b.name})")


def ultrapower_mul(a: UltraPowerElement, b: UltraPowerElement,
                   window: int = 20) -> UltraPowerElement:
    """Componentwise multiplication in *ℕ."""
    seq = [a.evaluate(i) * b.evaluate(i) for i in range(window)]
    gen = None
    if a.generator and b.generator:
        gen = lambda i: a.generator(i) * b.generator(i)
    return UltraPowerElement(sequence=seq, generator=gen,
                             name=f"({a.name} * {b.name})")


def ultrapower_compare(a: UltraPowerElement, b: UltraPowerElement,
                       window: int = 100) -> str:
    """Compare elements: returns '<', '>', '=', or '?' (undetermined).

    Uses majority voting on a finite window as a heuristic for the
    ultrafilter selection.
    """
    less_count = 0
    greater_count = 0
    equal_count = 0
    for i in range(window):
        ai, bi = a.evaluate(i), b.evaluate(i)
        if ai < bi:
            less_count += 1
        elif ai > bi:
            greater_count += 1
        else:
            equal_count += 1

    total = less_count + greater_count + equal_count
    if less_count > total * 0.9:
        return "<"
    elif greater_count > total * 0.9:
        return ">"
    elif equal_count > total * 0.9:
        return "="
    else:
        return "?"


# ============================================================
# §3. Overspill Detection
# ============================================================

def detect_overspill(
    property_fn: Callable[[int], bool],
    max_standard: int = 10000,
    overspill_test: int = 10**8
) -> Dict[str, Any]:
    """Detect overspill: if property holds for all n < max_standard,
    test whether it 'spills over' to larger values.

    Returns a report dict.
    """
    # Check standard range
    standard_holds = True
    first_failure = None
    for n in range(max_standard):
        if not property_fn(n):
            standard_holds = False
            first_failure = n
            break

    # Check overspill candidates
    overspill_values = [max_standard * 10, max_standard * 100, overspill_test]
    overspill_results = {}
    for val in overspill_values:
        try:
            overspill_results[val] = property_fn(val)
        except (OverflowError, RecursionError):
            overspill_results[val] = "computation overflow"

    return {
        "standard_range": max_standard,
        "holds_in_standard": standard_holds,
        "first_failure": first_failure,
        "overspill_tests": overspill_results,
        "overspill_detected": (
            standard_holds and all(
                v is True for v in overspill_results.values()
                if isinstance(v, bool)
            )
        )
    }


# ============================================================
# §4. GCD Transfer
# ============================================================

def gcd(a: int, b: int) -> int:
    """Euclidean GCD algorithm."""
    while b:
        a, b = b, a % b
    return a


def gcd_transfer(
    f: Callable[[int], int],
    g: Callable[[int], int],
    window: int = 20
) -> Tuple[UltraPowerElement, UltraPowerElement, UltraPowerElement]:
    """Compute the GCD transfer: returns (d, q_f, q_g) where
    d = [gcd(f(i), g(i))], f = d * q_f, g = d * q_g in *ℕ.
    """
    d_seq = [gcd(f(i), g(i)) for i in range(window)]
    qf_seq = [f(i) // gcd(f(i), g(i)) if gcd(f(i), g(i)) > 0 else 0
              for i in range(window)]
    qg_seq = [g(i) // gcd(f(i), g(i)) if gcd(f(i), g(i)) > 0 else 0
              for i in range(window)]

    d = UltraPowerElement(sequence=d_seq,
                          generator=lambda i: gcd(f(i), g(i)),
                          name="gcd([f],[g])")
    qf = UltraPowerElement(sequence=qf_seq, name="[f]/gcd")
    qg = UltraPowerElement(sequence=qg_seq, name="[g]/gcd")

    return d, qf, qg


# ============================================================
# §5. Polynomial Identity Verification
# ============================================================

class NatExpr(Enum):
    """Types of arithmetic expressions."""
    VAR = "var"
    CONST = "const"
    ADD = "add"
    MUL = "mul"


@dataclass
class Expr:
    """Arithmetic expression tree."""
    kind: NatExpr
    value: Optional[int] = None  # for CONST and VAR (index)
    left: Optional['Expr'] = None
    right: Optional['Expr'] = None

    def eval_nat(self, env: List[int]) -> int:
        """Evaluate in ℕ."""
        if self.kind == NatExpr.VAR:
            return env[self.value]
        elif self.kind == NatExpr.CONST:
            return self.value
        elif self.kind == NatExpr.ADD:
            return self.left.eval_nat(env) + self.right.eval_nat(env)
        elif self.kind == NatExpr.MUL:
            return self.left.eval_nat(env) * self.right.eval_nat(env)

    def eval_ultra(self, env: List[UltraPowerElement],
                   window: int = 20) -> UltraPowerElement:
        """Evaluate in *ℕ."""
        if self.kind == NatExpr.VAR:
            return env[self.value]
        elif self.kind == NatExpr.CONST:
            return standard_element(self.value)
        elif self.kind == NatExpr.ADD:
            return ultrapower_add(
                self.left.eval_ultra(env, window),
                self.right.eval_ultra(env, window),
                window
            )
        elif self.kind == NatExpr.MUL:
            return ultrapower_mul(
                self.left.eval_ultra(env, window),
                self.right.eval_ultra(env, window),
                window
            )


def verify_polynomial_identity(
    lhs: Expr, rhs: Expr, num_vars: int,
    num_tests: int = 1000, max_val: int = 100
) -> bool:
    """Verify a polynomial identity by random testing.

    By transfer, if it holds in ℕ, it holds in *ℕ.
    """
    import random
    for _ in range(num_tests):
        env = [random.randint(0, max_val) for _ in range(num_vars)]
        if lhs.eval_nat(env) != rhs.eval_nat(env):
            return False
    return True


if __name__ == "__main__":
    # Demo: ω exceeds all standard elements
    w = omega_element()
    for n in [10, 100, 1000]:
        s = standard_element(n)
        cmp = ultrapower_compare(s, w)
        print(f"std({n}) {cmp} ω")

    # Demo: GCD transfer
    d, qf, qg = gcd_transfer(lambda i: 12*(i+1), lambda i: 18*(i+1))
    print(f"\ngcd sequence: {d.sequence[:8]}")
    print(f"quotient f:   {qf.sequence[:8]}")
    print(f"quotient g:   {qg.sequence[:8]}")

    # Demo: overspill
    result = detect_overspill(lambda n: n + 1 > n)
    print(f"\nOverspill for 'n+1 > n': {result}")
