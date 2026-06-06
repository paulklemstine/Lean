"""
Algorithms for Non-Standard Arithmetic
=======================================
Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import Callable, List, Set, Tuple, Optional
from dataclasses import dataclass
import math


# --- Core Types ---

Sequence = Callable[[int], int]
"""A sequence ℕ → ℕ, representing an element of the ultrapower."""

ULargeTest = Callable[[Set[int]], bool]
"""A predicate testing whether a set is 'U-large'."""


@dataclass
class UltrapowerElement:
    """An element of ℕ* represented as a sequence."""
    seq: Sequence
    name: str = ""

    def evaluate(self, indices: range) -> List[int]:
        return [self.seq(i) for i in indices]


@dataclass
class DivisionResult:
    """Result of the division algorithm in ℕ*."""
    quotient: UltrapowerElement
    remainder: UltrapowerElement
    dividend: UltrapowerElement
    divisor: UltrapowerElement


@dataclass
class GCDResult:
    """Result of GCD computation in ℕ*."""
    gcd: UltrapowerElement
    operand_a: UltrapowerElement
    operand_b: UltrapowerElement


# --- Algorithm 1: Ultrapower Division ---

def ultrapower_division(
    f: UltrapowerElement,
    g: UltrapowerElement,
) -> DivisionResult:
    """
    Division algorithm in ℕ*.

    Given f, g ∈ ℕ* with g > 0 (U-a.e.), compute q, r ∈ ℕ*
    such that f = g·q + r and r < g (U-a.e.).

    Pseudocode:
        q(i) = f(i) // g(i)
        r(i) = f(i) % g(i)

    Time complexity: O(1) per index (pointwise).
    """
    q = UltrapowerElement(
        seq=lambda i: f.seq(i) // g.seq(i) if g.seq(i) > 0 else 0,
        name=f"({f.name} / {g.name})"
    )
    r = UltrapowerElement(
        seq=lambda i: f.seq(i) % g.seq(i) if g.seq(i) > 0 else f.seq(i),
        name=f"({f.name} % {g.name})"
    )
    return DivisionResult(quotient=q, remainder=r, dividend=f, divisor=g)


# --- Algorithm 2: Ultrapower GCD ---

def ultrapower_gcd(
    f: UltrapowerElement,
    g: UltrapowerElement,
) -> GCDResult:
    """
    GCD in ℕ*.

    Given f, g ∈ ℕ*, compute gcd(f, g) ∈ ℕ* pointwise.

    Pseudocode:
        d(i) = gcd(f(i), g(i))

    The result satisfies:
        d | f and d | g (U-a.e.)
        For any c with c|f and c|g (U-a.e.), c | d (U-a.e.)
    """
    d = UltrapowerElement(
        seq=lambda i: math.gcd(f.seq(i), g.seq(i)),
        name=f"gcd({f.name}, {g.name})"
    )
    return GCDResult(gcd=d, operand_a=f, operand_b=g)


# --- Algorithm 3: Standard Part ---

def standard_part(
    f: UltrapowerElement,
    bound: int,
    is_large: ULargeTest,
    sample_size: int = 10000,
) -> Optional[int]:
    """
    Standard part of a bounded element of ℕ*.

    Given f ∈ ℕ* with f ≤ bound (U-a.e.), find m ≤ bound
    such that f = m (U-a.e.).

    Pseudocode:
        For m in {0, ..., bound}:
            If {i | f(i) = m} is U-large:
                return m
        return None  (should not happen by pigeonhole)

    Time complexity: O(bound × sample_size).
    """
    for m in range(bound + 1):
        eq_set = {i for i in range(sample_size) if f.seq(i) == m}
        if is_large(eq_set):
            return m
    return None


# --- Algorithm 4: Overspill Witness ---

def overspill_witness(
    P: Callable[[int, int], bool],
    max_standard: int = 1000,
) -> Tuple[Sequence, int]:
    """
    Construct an overspill witness function.

    Given a downward-closed predicate P(i, n) that holds for all
    standard n (on U-large sets), construct f : ℕ → ℕ such that
    f grows without bound and P(i, f(i)) holds.

    Strategy:
        For each i, f(i) = max{n ≤ i | P(i, n)}

    Returns: (f, estimated_growth_rate)

    Time complexity: O(max_standard²) for estimation.
    """
    def f(i: int) -> int:
        # Find max n with P(i, n)
        best = 0
        for n in range(min(i + 1, max_standard)):
            if P(i, n):
                best = n
            else:
                break
        return best

    # Estimate growth rate
    growth_samples = [f(i) for i in range(100, max_standard)]
    avg_growth = sum(growth_samples) / len(growth_samples) if growth_samples else 0

    return f, int(avg_growth)


# --- Algorithm 5: Trichotomy Decision ---

def trichotomy_decide(
    f: UltrapowerElement,
    g: UltrapowerElement,
    sample_size: int = 10000,
) -> str:
    """
    Decide the order relation between f and g in ℕ*.

    Returns one of '<', '=', '>' based on which set has
    the highest density (simulating the ultrafilter decision).

    Pseudocode:
        Count |{i < N | f(i) < g(i)}|
        Count |{i < N | f(i) = g(i)}|
        Count |{i < N | f(i) > g(i)}|
        Return the relation with highest count.

    Time complexity: O(sample_size).
    """
    lt_count = sum(1 for i in range(sample_size) if f.seq(i) < g.seq(i))
    eq_count = sum(1 for i in range(sample_size) if f.seq(i) == g.seq(i))
    gt_count = sum(1 for i in range(sample_size) if f.seq(i) > g.seq(i))

    if lt_count >= eq_count and lt_count >= gt_count:
        return '<'
    elif eq_count >= lt_count and eq_count >= gt_count:
        return '='
    else:
        return '>'


# --- Algorithm 6: Compositeness Witness Transfer ---

def composite_witness_transfer(
    f: UltrapowerElement,
    sample_size: int = 10000,
) -> Optional[Tuple[UltrapowerElement, UltrapowerElement]]:
    """
    Extract compositeness witnesses for f ∈ ℕ*.

    If f(i) is composite for U-a.e. i, return (a, b) ∈ ℕ*×ℕ*
    with 1 < a, 1 < b, and f = a·b (U-a.e.).

    Pseudocode:
        For each i:
            If f(i) is composite:
                a(i) = smallest factor > 1
                b(i) = f(i) / a(i)
            Else:
                a(i) = 1, b(i) = f(i)

    Time complexity: O(sample_size × √max_value).
    """
    def smallest_factor(n: int) -> int:
        if n <= 1:
            return n
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0:
                return d
        return n  # n is prime

    def a_seq(i: int) -> int:
        n = f.seq(i)
        sf = smallest_factor(n)
        return sf if sf != n and sf > 1 else 1

    def b_seq(i: int) -> int:
        n = f.seq(i)
        a = a_seq(i)
        return n // a if a > 1 else n

    a = UltrapowerElement(seq=a_seq, name="factor_a")
    b = UltrapowerElement(seq=b_seq, name="factor_b")

    # Check if f is indeed composite on most indices
    composite_count = sum(1 for i in range(sample_size)
                         if f.seq(i) > 1 and smallest_factor(f.seq(i)) != f.seq(i))

    if composite_count / sample_size > 0.5:
        return (a, b)
    return None


# --- Main ---

if __name__ == "__main__":
    # Example: division of ω² by ω+1
    omega = UltrapowerElement(seq=lambda i: i, name="ω")
    omega_sq = UltrapowerElement(seq=lambda i: i*i, name="ω²")
    omega_plus_1 = UltrapowerElement(seq=lambda i: i+1, name="ω+1")

    result = ultrapower_division(omega_sq, omega_plus_1)
    print("Division: ω² ÷ (ω+1)")
    print(f"  Quotient: {result.quotient.evaluate(range(10))}")
    print(f"  Remainder: {result.remainder.evaluate(range(10))}")

    # Example: GCD of 6ω and 4ω
    f = UltrapowerElement(seq=lambda i: 6*i, name="6ω")
    g = UltrapowerElement(seq=lambda i: 4*i, name="4ω")
    gcd_result = ultrapower_gcd(f, g)
    print(f"\nGCD(6ω, 4ω) = {gcd_result.gcd.evaluate(range(10))}")

    # Example: Trichotomy
    print(f"\nω² vs 2ω+1: {trichotomy_decide(omega_sq, UltrapowerElement(lambda i: 2*i+1, '2ω+1'))}")

    # Example: Overspill
    def P(i: int, n: int) -> bool:
        return i > n

    f_overspill, growth = overspill_witness(P)
    print(f"\nOverspill witness for P(i,n) = 'i > n':")
    print(f"  f(100) = {f_overspill(100)}, f(500) = {f_overspill(500)}")
    print(f"  Estimated growth rate: {growth}")
