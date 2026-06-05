#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Core Algorithms

Type-hinted implementations of the key algorithmic concepts from the
formalized non-standard arithmetic theory.
"""

from typing import (
    Callable, FrozenSet, Generic, List, Optional, Set, Tuple, TypeVar
)
from dataclasses import dataclass
from functools import reduce


T = TypeVar('T')


# =============================================================================
# Algorithm 1: Ultrafilter Operations
# =============================================================================

@dataclass
class UltrafilterApprox:
    """
    Finite approximation of an ultrafilter on {0, ..., N-1}.

    Pseudocode:
        ULTRAFILTER-APPROX(N):
            universe ← {0, ..., N-1}
            large_sets ← maximal filter on universe
            RETURN large_sets

    In practice, we use a principal ultrafilter (concentrated at a point)
    as the approximation, since non-principal ultrafilters on finite sets
    don't exist.
    """
    N: int
    principal_point: int

    def is_large(self, S: FrozenSet[int]) -> bool:
        """O(1) membership test."""
        return self.principal_point in S

    def complement(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """O(N) complement computation."""
        return frozenset(range(self.N)) - S

    def intersection(self, S1: FrozenSet[int], S2: FrozenSet[int]) -> FrozenSet[int]:
        """O(min(|S1|, |S2|)) intersection."""
        return S1 & S2

    def dichotomy(self, S: FrozenSet[int]) -> Tuple[bool, bool]:
        """
        Ultrafilter dichotomy: exactly one of S, Sᶜ is large.
        Returns (S_large, Sc_large).
        """
        s_large = self.is_large(S)
        return (s_large, not s_large)


# =============================================================================
# Algorithm 2: Non-Standard Number Arithmetic
# =============================================================================

@dataclass
class NonstandardNumber:
    """
    Representation of a non-standard natural number.

    A non-standard number is an equivalence class [f] of sequences
    f : I → ℕ under the ultrafilter equivalence relation.

    Pseudocode:
        NONSTANDARD-ADD([f], [g]):
            RETURN [i ↦ f(i) + g(i)]

        NONSTANDARD-MUL([f], [g]):
            RETURN [i ↦ f(i) * g(i)]

        NONSTANDARD-LE([f], [g], U):
            S ← {i | f(i) ≤ g(i)}
            RETURN U.is_large(S)
    """
    values: List[int]
    label: str = ""

    @staticmethod
    def standard(n: int, length: int = 100) -> 'NonstandardNumber':
        """Standard embedding: std(n) = [n, n, n, ...]."""
        return NonstandardNumber([n] * length, f"std({n})")

    @staticmethod
    def omega(length: int = 100) -> 'NonstandardNumber':
        """Canonical infinite element: ω = [0, 1, 2, ...]."""
        return NonstandardNumber(list(range(length)), "ω")

    def add(self, other: 'NonstandardNumber') -> 'NonstandardNumber':
        """Pointwise addition."""
        n = min(len(self.values), len(other.values))
        return NonstandardNumber(
            [self.values[i] + other.values[i] for i in range(n)],
            f"({self.label}+{other.label})"
        )

    def mul(self, other: 'NonstandardNumber') -> 'NonstandardNumber':
        """Pointwise multiplication."""
        n = min(len(self.values), len(other.values))
        return NonstandardNumber(
            [self.values[i] * other.values[i] for i in range(n)],
            f"({self.label}×{other.label})"
        )

    def le_set(self, other: 'NonstandardNumber') -> FrozenSet[int]:
        """Return {i | self(i) ≤ other(i)}."""
        n = min(len(self.values), len(other.values))
        return frozenset(i for i in range(n) if self.values[i] <= other.values[i])

    def is_infinite(self, U: UltrafilterApprox) -> bool:
        """Check if self exceeds every standard element (approximation)."""
        N = len(self.values)
        for n in range(N):
            s = NonstandardNumber.standard(n, N)
            le_set = s.le_set(self)
            if not U.is_large(le_set):
                return False
        return True


# =============================================================================
# Algorithm 3: Overspill Detection
# =============================================================================

def overspill_check(
    P: Callable[[int], bool],
    N: int,
    threshold: int = 10
) -> Tuple[bool, Optional[int]]:
    """
    Check if property P satisfies the overspill condition.

    Pseudocode:
        OVERSPILL-CHECK(P, N, threshold):
            FOR n = 0 TO threshold:
                tail ← {i ∈ {n,...,N-1} | P(i)}
                IF tail ≠ {n,...,N-1}:
                    RETURN (False, n)  // P fails for some i ≥ n
            RETURN (True, None)  // P holds on all tails → overspill

    Returns (overspills, failure_point).
    """
    for n in range(min(threshold, N)):
        for i in range(n, N):
            if not P(i):
                return (False, i)
    return (True, None)


# =============================================================================
# Algorithm 4: Transfer Verification
# =============================================================================

def verify_transfer(
    identity: Callable[[int], bool],
    N: int,
    U: UltrafilterApprox
) -> Tuple[bool, FrozenSet[int]]:
    """
    Verify that an arithmetic identity transfers to the ultrapower.

    Pseudocode:
        VERIFY-TRANSFER(identity, N, U):
            S ← {i ∈ {0,...,N-1} | identity(i)}
            RETURN (U.is_large(S), S)

    The identity holds in the ultrapower iff S ∈ U.
    """
    S = frozenset(i for i in range(N) if identity(i))
    return (U.is_large(S), S)


# =============================================================================
# Algorithm 5: Integral Domain Check
# =============================================================================

def integral_domain_transfer(
    f: List[int],
    g: List[int],
    U: UltrafilterApprox
) -> Tuple[str, FrozenSet[int]]:
    """
    Check the zero-product property for sequences f, g.

    Pseudocode:
        INTEGRAL-DOMAIN-CHECK(f, g, U):
            zero_product ← {i | f(i) * g(i) = 0}
            IF NOT U.is_large(zero_product):
                RETURN "product nonzero"
            f_zero ← {i | f(i) = 0}
            g_zero ← {i | g(i) = 0}
            IF U.is_large(f_zero):
                RETURN "[f] = 0"
            ELIF U.is_large(g_zero):
                RETURN "[g] = 0"
            ELSE:
                RETURN "VIOLATION" // should not happen for domains
    """
    N = min(len(f), len(g))
    zero_product = frozenset(i for i in range(N) if f[i] * g[i] == 0)

    if not U.is_large(zero_product):
        return ("product nonzero", zero_product)

    f_zero = frozenset(i for i in range(N) if f[i] == 0)
    g_zero = frozenset(i for i in range(N) if g[i] == 0)

    if U.is_large(f_zero):
        return ("[f] = 0", f_zero)
    elif U.is_large(g_zero):
        return ("[g] = 0", g_zero)
    else:
        return ("VIOLATION", zero_product)


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    N = 50
    U = UltrafilterApprox(N, principal_point=37)

    print("=== Non-Standard Arithmetic Algorithms ===\n")

    # 1. Ultrafilter dichotomy
    S = frozenset(range(0, N, 2))  # even numbers
    s_large, sc_large = U.dichotomy(S)
    print(f"1. Dichotomy: evens large={s_large}, odds large={sc_large}")

    # 2. Infinite element
    w = NonstandardNumber.omega(N)
    print(f"\n2. ω is infinite: {w.is_infinite(U)}")

    # 3. Overspill
    overspills, fail = overspill_check(lambda n: n * n > 100, N)
    print(f"\n3. Overspill for n²>100: overspills={overspills}, fail_at={fail}")

    # 4. Transfer verification
    transfers, agree_set = verify_transfer(
        lambda i: (i + 1) * (i + 1) == i * i + 2 * i + 1, N, U
    )
    print(f"\n4. Transfer (n+1)²=n²+2n+1: holds={transfers}, "
          f"agree on {len(agree_set)}/{N} indices")

    # 5. Integral domain
    f_seq = [0 if i % 2 == 0 else i for i in range(N)]
    g_seq = [i if i % 2 == 0 else 0 for i in range(N)]
    result, witness = integral_domain_transfer(f_seq, g_seq, U)
    print(f"\n5. Zero-product: {result}")
