#!/usr/bin/env python3
"""
Algorithms for Non-Standard Arithmetic

Type-hinted implementations of key algorithms related to ultrapower
constructions and non-standard models of arithmetic.
"""

from typing import Callable, Set, List, Tuple, Optional
from dataclasses import dataclass
import math


# =============================================================
# Algorithm 1: Simulated Ultrafilter Decision
# =============================================================

@dataclass
class SimulatedUltrafilter:
    """A simulated ultrafilter on ℕ using majority voting on finite prefixes.

    A true free ultrafilter requires the axiom of choice and cannot be
    computed. This simulation approximates its behavior by checking
    whether a property holds on a large fraction of {0, ..., N-1}.

    Pseudocode:
        ULTRAFILTER_DECIDE(property P, bound N, threshold t):
            count ← |{i ∈ [0,N) : P(i)}|
            return count/N > t
    """
    bound: int = 100000
    threshold: float = 0.9

    def decides(self, prop: Callable[[int], bool]) -> bool:
        """Decide if property holds on a 'U-large' set."""
        count = sum(1 for i in range(self.bound) if prop(i))
        return count / self.bound > self.threshold

    def compare(self, f: Callable[[int], int],
                g: Callable[[int], int]) -> str:
        """Compare f and g in the ultrapower ordering."""
        lt_count = sum(1 for i in range(self.bound) if f(i) < g(i))
        eq_count = sum(1 for i in range(self.bound) if f(i) == g(i))
        gt_count = self.bound - lt_count - eq_count
        if lt_count / self.bound > self.threshold:
            return "f < g"
        elif gt_count / self.bound > self.threshold:
            return "f > g"
        elif eq_count / self.bound > self.threshold:
            return "f = g"
        else:
            return "indeterminate"


# =============================================================
# Algorithm 2: Cofinite Set Membership Test
# =============================================================

def is_cofinite_member(complement_bound: int, n: int) -> bool:
    """Test if n belongs to a set whose complement is {0, ..., complement_bound - 1}.

    In a free ultrafilter, any cofinite set is a member.
    This is the key lemma enabling the non-Archimedean property.

    Pseudocode:
        IS_COFINITE(complement_bound, n):
            return n >= complement_bound
    """
    return n >= complement_bound


def cofinite_fraction(complement_size: int, N: int) -> float:
    """Fraction of {0,...,N-1} in a set with `complement_size` elements missing.

    This fraction → 1 as N → ∞, showing cofinite sets are "eventually all".
    """
    return max(0, N - complement_size) / N


# =============================================================
# Algorithm 3: Ultrapower Arithmetic
# =============================================================

@dataclass
class UltrapowerElement:
    """An element of *ℕ represented as a sequence.

    In the actual ultrapower, two sequences are identified if they agree
    on a U-large set. Here we just store the generating function.
    """
    seq: Callable[[int], int]
    name: str = "unnamed"

    def __repr__(self) -> str:
        return f"[{self.name}]"

    def evaluate(self, indices: List[int]) -> List[int]:
        """Evaluate the sequence at given indices."""
        return [self.seq(i) for i in indices]


def std(n: int) -> UltrapowerElement:
    """The standard embedding: n ↦ [i ↦ n]."""
    return UltrapowerElement(lambda i, n=n: n, f"std({n})")


def omega() -> UltrapowerElement:
    """The canonical non-standard element ω = [i ↦ i]."""
    return UltrapowerElement(lambda i: i, "ω")


def omega_factorial() -> UltrapowerElement:
    """The non-standard factorial ω! = [i ↦ i!]."""
    return UltrapowerElement(lambda i: math.factorial(i), "ω!")


def omega_power(k: int) -> UltrapowerElement:
    """ω^k = [i ↦ i^k]."""
    return UltrapowerElement(lambda i, k=k: i**k, f"ω^{k}")


def ultrapower_add(a: UltrapowerElement,
                   b: UltrapowerElement) -> UltrapowerElement:
    """Pointwise addition in *ℕ."""
    return UltrapowerElement(
        lambda i: a.seq(i) + b.seq(i),
        f"({a.name}+{b.name})"
    )


def ultrapower_mul(a: UltrapowerElement,
                   b: UltrapowerElement) -> UltrapowerElement:
    """Pointwise multiplication in *ℕ."""
    return UltrapowerElement(
        lambda i: a.seq(i) * b.seq(i),
        f"({a.name}·{b.name})"
    )


def ultrapower_divides(d: UltrapowerElement, n: UltrapowerElement,
                       U: SimulatedUltrafilter) -> bool:
    """Check if d | n in *ℕ (via simulated ultrafilter)."""
    return U.decides(lambda i: d.seq(i) != 0 and n.seq(i) % d.seq(i) == 0
                     if d.seq(i) != 0 else n.seq(i) == 0)


# =============================================================
# Algorithm 4: Transfer Principle Checker
# =============================================================

def check_transfer(identity: Callable[[int, int, int], bool],
                   description: str,
                   N: int = 10000) -> Tuple[bool, float]:
    """Verify a polynomial identity transfers to the ultrapower.

    Tests if identity(a, b, c) holds for all triples drawn from
    sequence values. Returns (all_hold, fraction_holding).

    Pseudocode:
        CHECK_TRANSFER(identity, N):
            count ← 0
            for a, b, c in sample(N):
                if identity(a, b, c): count += 1
            return count == N, count/N
    """
    import random
    random.seed(42)
    count = 0
    total = min(N, 10000)
    for _ in range(total):
        a = random.randint(0, 1000)
        b = random.randint(0, 1000)
        c = random.randint(0, 1000)
        if identity(a, b, c):
            count += 1
    return count == total, count / total


# =============================================================
# Algorithm 5: Overflow Principle Detector
# =============================================================

def find_overflow_threshold(prop: Callable[[int], bool],
                            max_search: int = 100000) -> Optional[int]:
    """Find the threshold N₀ after which property P holds for all n ≥ N₀.

    If P holds for all n ≥ N₀, the overflow principle guarantees
    P holds at ω in *ℕ.

    Pseudocode:
        FIND_THRESHOLD(P, max_search):
            for N₀ = max_search down to 0:
                if not P(N₀): return N₀ + 1
            return 0  # P holds everywhere
    """
    for n in range(max_search, -1, -1):
        if not prop(n):
            return n + 1 if n + 1 <= max_search else None
    return 0


if __name__ == "__main__":
    # Demo: ultrapower arithmetic
    U = SimulatedUltrafilter(bound=10000)
    w = omega()
    five = std(5)

    print("Ultrapower Arithmetic Demo")
    print(f"  ω at indices [0..9]: {w.evaluate(list(range(10)))}")
    print(f"  std(5) at indices [0..9]: {five.evaluate(list(range(10)))}")
    print(f"  ω vs std(5): {U.compare(w.seq, five.seq)}")
    print(f"  ω vs ω²: {U.compare(w.seq, omega_power(2).seq)}")
    print(f"  std(100) | ω!: {ultrapower_divides(std(100), omega_factorial(), U)}")
    print()

    # Demo: transfer checker
    print("Transfer Principle Checks:")
    ok, frac = check_transfer(lambda a, b, c: a + b == b + a,
                               "commutativity of +")
    print(f"  a + b = b + a: {ok} ({frac*100:.0f}%)")
    ok, frac = check_transfer(lambda a, b, c: a * (b + c) == a*b + a*c,
                               "distributivity")
    print(f"  a*(b+c) = ab+ac: {ok} ({frac*100:.0f}%)")
    print()

    # Demo: overflow threshold finder
    print("Overflow Thresholds:")
    threshold = find_overflow_threshold(lambda n: n*n > 100*n)
    print(f"  n² > 100n holds for all n ≥ {threshold}")
    threshold = find_overflow_threshold(lambda n: n > 42)
    print(f"  n > 42 holds for all n ≥ {threshold}")
