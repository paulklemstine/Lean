#!/usr/bin/env python3
"""
Algorithms for Dependent Ultraproduct Computations

Type-hinted implementations of the key algorithms from the formal development.
"""

from typing import (
    TypeVar, Generic, List, Set, Dict, Tuple, Callable, Optional, Sequence
)
from dataclasses import dataclass
from enum import Enum
import math

T = TypeVar('T')
A = TypeVar('A')


# ---------------------------------------------------------------------------
# §1. Ultrafilter representation (for finite index sets)
# ---------------------------------------------------------------------------

@dataclass
class PrincipalUltrafilter(Generic[T]):
    """A principal ultrafilter on a finite set, focused at a single element.

    On finite sets, all ultrafilters are principal (by a classical result).
    """
    focus: T

    def is_large(self, s: Set[T]) -> bool:
        """Check if a set is in the ultrafilter (i.e., contains the focus)."""
        return self.focus in s

    def selected_value(self, f: Callable[[T], A], domain: Set[T]) -> A:
        """The unique U-selected value of f. For principal ultrafilters, this is f(focus)."""
        return f(self.focus)


# ---------------------------------------------------------------------------
# §2. Ultraproduct equivalence (computational simulation)
# ---------------------------------------------------------------------------

def ultra_eq(
    f: Callable[[int], T],
    g: Callable[[int], T],
    U: PrincipalUltrafilter[int],
    index_set: Set[int]
) -> bool:
    """Check if f ≈_U g (for principal ultrafilters, just checks f(focus) == g(focus))."""
    agreement_set = {i for i in index_set if f(i) == g(i)}
    return U.is_large(agreement_set)


def ultraproduct_add(
    f: Callable[[int], float],
    g: Callable[[int], float]
) -> Callable[[int], float]:
    """Pointwise addition in the ultraproduct."""
    return lambda i: f(i) + g(i)


def ultraproduct_mul(
    f: Callable[[int], float],
    g: Callable[[int], float]
) -> Callable[[int], float]:
    """Pointwise multiplication in the ultraproduct."""
    return lambda i: f(i) * g(i)


def ultraproduct_neg(
    f: Callable[[int], float]
) -> Callable[[int], float]:
    """Pointwise negation in the ultraproduct."""
    return lambda i: -f(i)


# ---------------------------------------------------------------------------
# §3. Finite image resolution algorithm
# ---------------------------------------------------------------------------

def finite_image_resolution(
    f: Callable[[int], A],
    index_set: Set[int],
    value_set: Set[A],
    U: PrincipalUltrafilter[int]
) -> Tuple[A, Set[int]]:
    """Find the U-selected value and its preimage.

    Returns (selected_value, preimage_set).
    For principal ultrafilters, the selected value is f(focus).
    """
    selected = f(U.focus)
    preimage = {i for i in index_set if f(i) == selected}
    return selected, preimage


# ---------------------------------------------------------------------------
# §4. Characteristic transfer computation
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def characteristic_transfer(
    char_of: Callable[[int], int],
    index_set: Set[int],
    prime_set: Set[int],
    U: PrincipalUltrafilter[int]
) -> int:
    """Compute the transferred characteristic.

    For principal ultrafilters, this is just char_of(focus).
    The theorem guarantees: if no prime is U-selected, the result is 0.
    """
    focus_char = char_of(U.focus)

    # Verify the transfer theorem conditions
    for p in prime_set:
        preimage_p = {i for i in index_set if char_of(i) == p}
        if U.is_large(preimage_p):
            return p  # This prime is selected

    # No prime selected → characteristic 0
    preimage_0 = {i for i in index_set if char_of(i) == 0}
    if U.is_large(preimage_0):
        return 0

    return focus_char  # Fallback for principal case


# ---------------------------------------------------------------------------
# §5. Bounded quantifier transfer
# ---------------------------------------------------------------------------

def bounded_forall_transfer(
    n: int,
    P: Callable[[int, int], bool],
    index_set: Set[int],
    U: PrincipalUltrafilter[int]
) -> Tuple[bool, Set[int]]:
    """Compute the bounded universal transfer.

    Returns (holds_at_focus, conjunction_set).
    The conjunction_set is {i : ∀k<n, P(i,k)}.
    """
    conjunction_set = set(index_set)  # Start with everything
    for k in range(n):
        level_k = {i for i in index_set if P(i, k)}
        conjunction_set = conjunction_set & level_k

    holds = U.is_large(conjunction_set)
    return holds, conjunction_set


# ---------------------------------------------------------------------------
# §6. Ultrafilter Ramsey AP test
# ---------------------------------------------------------------------------

def find_longest_ap_in_set(
    color_class: Set[int],
    max_start: int = 500,
    max_diff: int = 500,
    max_len: int = 100
) -> Tuple[int, int, int]:
    """Find the longest arithmetic progression in a color class.

    Returns (length, start, common_difference).
    """
    best_len, best_a, best_d = 0, 0, 0
    elements = sorted(color_class)
    if not elements:
        return 0, 0, 0

    for a in elements[:max_start]:
        for d in range(1, max_diff):
            length = 0
            while a + length * d in color_class and length < max_len:
                length += 1
            if length > best_len:
                best_len, best_a, best_d = length, a, d

    return best_len, best_a, best_d


def test_ramsey_coloring(
    coloring: Callable[[int], int],
    num_colors: int,
    N: int = 10000,
    name: str = "unnamed"
) -> Dict[int, Tuple[int, int, int]]:
    """Test the Ramsey AP conjecture for a specific coloring.

    Returns a dict mapping each color to (longest_ap_length, start, diff).
    """
    color_classes: Dict[int, Set[int]] = {c: set() for c in range(num_colors)}
    for n in range(N):
        c = coloring(n) % num_colors
        color_classes[c].add(n)

    results = {}
    for c in range(num_colors):
        length, a, d = find_longest_ap_in_set(color_classes[c])
        results[c] = (length, a, d)

    return results


# ---------------------------------------------------------------------------
# §7. Compactness bridge simulation
# ---------------------------------------------------------------------------

def finite_compactness_check(
    axioms: List[Callable[[T], bool]],
    witnesses: Callable[[int], T],
    index_set: Set[int],
    U: PrincipalUltrafilter[int]
) -> bool:
    """Check the finite compactness principle.

    Returns True if all axioms are simultaneously satisfied at the focus.
    """
    focus_witness = witnesses(U.focus)
    return all(axiom(focus_witness) for axiom in axioms)


# ---------------------------------------------------------------------------
# Demo
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Quick demo
    I = set(range(100))
    U = PrincipalUltrafilter(focus=42)

    # Finite image resolution
    f = lambda i: i % 5
    val, preimage = finite_image_resolution(f, I, {0,1,2,3,4}, U)
    print(f"Finite image resolution: f(i) = i mod 5, focus=42")
    print(f"  Selected value: {val}, preimage size: {len(preimage)}")

    # Characteristic transfer
    primes_list = [p for p in range(2, 100) if is_prime(p)]
    char_fn = lambda i: primes_list[i % len(primes_list)]
    transferred = characteristic_transfer(char_fn, I, set(primes_list), U)
    print(f"\nCharacteristic transfer: char_of(42) = {char_fn(42)}")
    print(f"  Transferred characteristic: {transferred}")

    # Bounded forall transfer
    P = lambda i, k: (i >> k) & 1 == 0  # k-th bit of i is 0
    holds, conj = bounded_forall_transfer(3, P, I, U)
    print(f"\nBounded forall (n=3): holds at focus? {holds}")
    print(f"  Conjunction set size: {len(conj)}")

    # Ramsey test
    results = test_ramsey_coloring(lambda n: n % 2, 2, N=5000, name="mod2")
    print(f"\nRamsey test (mod 2 coloring):")
    for c, (l, a, d) in results.items():
        print(f"  Color {c}: longest AP = {l} (start={a}, diff={d})")
