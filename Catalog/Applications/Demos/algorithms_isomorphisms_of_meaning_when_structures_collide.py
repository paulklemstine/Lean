#!/usr/bin/env python3
"""
Semantic Fiber Theory — Core Algorithms

Type-hinted implementations of the key algorithms from the theory.
"""

from typing import TypeVar, Dict, Set, List, Tuple, Callable, Optional, FrozenSet
from itertools import permutations
from dataclasses import dataclass
from math import factorial

A = TypeVar('A')
S = TypeVar('S')
T = TypeVar('T')


@dataclass(frozen=True)
class DecoratedType:
    """A type equipped with a meaning function."""
    elements: FrozenSet[int]
    meaning: Dict[int, str]

    def opacity_index(self) -> int:
        """Compute the opacity index = |range(meaning)|."""
        return len(set(self.meaning.values()))

    def is_faithful(self) -> bool:
        """Check if the decoration is injective."""
        vals = list(self.meaning.values())
        return len(vals) == len(set(vals))

    def is_constant(self) -> bool:
        """Check if the decoration is constant."""
        vals = list(self.meaning.values())
        return len(set(vals)) <= 1

    def semantic_kernel(self) -> List[FrozenSet[int]]:
        """Compute the semantic kernel: equivalence classes of same-meaning elements."""
        classes: Dict[str, Set[int]] = {}
        for x, m in self.meaning.items():
            classes.setdefault(m, set()).add(x)
        return [frozenset(c) for c in classes.values()]

    def compose(self, f: Callable[[str], str]) -> 'DecoratedType':
        """Compose the meaning function with f, yielding a coarser decoration."""
        new_meaning = {x: f(m) for x, m in self.meaning.items()}
        return DecoratedType(self.elements, new_meaning)


def is_meaning_preserving(dt: DecoratedType, perm: Dict[int, int]) -> bool:
    """Check if a permutation preserves the meaning function."""
    return all(dt.meaning[perm[x]] == dt.meaning[x] for x in dt.elements)


def meaning_preserving_subgroup(dt: DecoratedType) -> List[Dict[int, int]]:
    """Compute all meaning-preserving permutations (the automorphism subgroup)."""
    elems = sorted(dt.elements)
    result = []
    for p in permutations(elems):
        perm = dict(zip(elems, p))
        if is_meaning_preserving(dt, perm):
            result.append(perm)
    return result


def is_decorated_equiv(
    d1: DecoratedType,
    d2: DecoratedType,
    bijection: Dict[int, int]
) -> bool:
    """Check if a bijection is a decorated equivalence between d1 and d2."""
    if set(bijection.keys()) != d1.elements:
        return False
    if set(bijection.values()) != d2.elements:
        return False
    return all(d2.meaning[bijection[x]] == d1.meaning[x] for x in d1.elements)


def find_decorated_equiv(
    d1: DecoratedType,
    d2: DecoratedType
) -> Optional[Dict[int, int]]:
    """Find a decorated equivalence between d1 and d2, or None if none exists."""
    if d1.opacity_index() != d2.opacity_index():
        return None
    if set(d1.meaning.values()) != set(d2.meaning.values()):
        return None

    elems1 = sorted(d1.elements)
    elems2 = sorted(d2.elements)
    if len(elems1) != len(elems2):
        return None

    for p in permutations(elems2):
        bijection = dict(zip(elems1, p))
        if is_decorated_equiv(d1, d2, bijection):
            return bijection
    return None


def find_cycles(n: int, perm: Tuple[int, ...]) -> List[List[int]]:
    """Find the cycle decomposition of a permutation on {0, ..., n-1}."""
    visited: Set[int] = set()
    cycles: List[List[int]] = []
    for start in range(n):
        if start not in visited:
            cycle: List[int] = []
            x = start
            while x not in visited:
                visited.add(x)
                cycle.append(x)
                x = perm[x]
            cycles.append(cycle)
    return cycles


def burnside_count(n: int, k: int) -> int:
    """
    Count equivalence classes of decorations Fin(n) → Fin(k)
    under the action of Sym(n), using Burnside's lemma.

    Returns (1/|Sym(n)|) * Σ_{σ ∈ Sym(n)} k^{c(σ)}
    where c(σ) is the number of cycles of σ.
    """
    total_fixed = 0
    for p in permutations(range(n)):
        cycles = find_cycles(n, p)
        total_fixed += k ** len(cycles)
    return total_fixed // factorial(n)


def opacity_spectrum(n: int, k: int) -> Dict[int, int]:
    """
    Compute the distribution of opacity indices across all
    decorations Fin(n) → Fin(k).

    Returns a dictionary mapping opacity_index → count.
    """
    from itertools import product as cartprod
    spectrum: Dict[int, int] = {}
    for decoration in cartprod(range(k), repeat=n):
        oi = len(set(decoration))
        spectrum[oi] = spectrum.get(oi, 0) + 1
    return spectrum


def semantic_distance(d1: DecoratedType, d2: DecoratedType) -> float:
    """
    Compute a semantic distance between two decorated types on the same carrier.
    Defined as the fraction of elements with different meanings.
    """
    assert d1.elements == d2.elements
    total = len(d1.elements)
    if total == 0:
        return 0.0
    diff = sum(1 for x in d1.elements if d1.meaning[x] != d2.meaning[x])
    return diff / total


# --- Example usage ---

if __name__ == "__main__":
    # Create a decorated type
    dt = DecoratedType(
        elements=frozenset({0, 1, 2, 3}),
        meaning={0: 'A', 1: 'B', 2: 'A', 3: 'C'}
    )

    print(f"Decorated type: {dt.meaning}")
    print(f"Opacity index: {dt.opacity_index()}")
    print(f"Faithful: {dt.is_faithful()}")
    print(f"Constant: {dt.is_constant()}")
    print(f"Semantic kernel: {dt.semantic_kernel()}")

    # Meaning-preserving subgroup
    subgroup = meaning_preserving_subgroup(dt)
    print(f"\nMeaning-preserving permutations: {len(subgroup)} / {factorial(4)}")
    print(f"Restriction ratio: {factorial(4) / len(subgroup):.1f}x")

    # Burnside enumeration
    print("\nBurnside enumeration (n, k) → classes:")
    for n in range(1, 5):
        for k in [2, 3]:
            print(f"  ({n}, {k}): {burnside_count(n, k)} classes")

    # Opacity spectrum
    print("\nOpacity spectrum for n=3, k=3:")
    spec = opacity_spectrum(3, 3)
    for oi in sorted(spec):
        print(f"  Opacity {oi}: {spec[oi]} decorations")
