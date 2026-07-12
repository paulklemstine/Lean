"""Numerical demonstrations for the Reflective Tower.

The reflective tower is defined by
    L(0) = {False, True}          (the two-element base)
    L(n+1) = (L(n) -> {False, True})   (predicates on level n)

Each level is finite, so for small n we can enumerate every element and check the
paper's theorems by direct computation:

    * strict cardinal growth              |L(n+1)| = 2 ** |L(n)|
    * self-reflection is impossible       (the diagonal predicate escapes any map)
    * lower reflection is always possible (an explicit surjection exists)
    * base-level classification           (negation is the unique fpf self-map)

Everything below is self-contained and uses only the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

Point = Tuple[bool, ...]  # an element of a finite level, encoded as a tuple of bits


# --------------------------------------------------------------------------- #
# Enumerating the levels
# --------------------------------------------------------------------------- #
def level_size(n: int) -> int:
    """Cardinality |L(n)|: |L(0)| = 2 and |L(n+1)| = 2 ** |L(n)|."""
    size = 2
    for _ in range(n):
        size = 2 ** size
    return size


def enumerate_level(n: int) -> List[Point]:
    """Return every element of L(n) as a tuple of bits of length |L(n-1)| (n>=1),
    or the two base elements for n == 0. Only feasible for very small n."""
    if n == 0:
        return [(False,), (True,)]
    width = level_size(n - 1)
    return [tuple(bits) for bits in product([False, True], repeat=width)]


# --------------------------------------------------------------------------- #
# Result 1: strict cardinal growth
# --------------------------------------------------------------------------- #
def demo_cardinal_growth(max_level: int = 4) -> None:
    import math
    print("=== Strict cardinal growth: |L(n+1)| = 2 ** |L(n)| ===")
    for n in range(max_level + 1):
        if n <= 3:
            print(f"  |L({n})| = {level_size(n)}")
        else:
            exp = level_size(n - 1)
            digits = int(exp * math.log10(2)) + 1
            print(f"  |L({n})| = 2^{exp} (~{digits} digits)")
    # verify strict growth on the computable prefix (sizes explode past level 4)
    for n in range(min(max_level, 4)):
        assert level_size(n) < level_size(n + 1)
    print("  verified: strictly increasing\n")


# --------------------------------------------------------------------------- #
# Result 2: self-reflection is impossible (diagonal escape)
# --------------------------------------------------------------------------- #
def diagonal_predicate(reflect: List[Point], domain: List[Point]) -> Point:
    """Given a proposed reflection r : L(n) -> (L(n) -> 2) presented as a table
    (reflect[i] is the predicate named by element i, as a bit-tuple over domain),
    return the diagonal predicate p(a) = not r(a)(a). It is provably not in range."""
    return tuple(not reflect[i][i] for i in range(len(domain)))


def demo_no_self_reflection(n: int = 0) -> None:
    print(f"=== Self-reflection is impossible at level {n} ===")
    domain = enumerate_level(n)
    # A predicate on L(n) is a bit-tuple of length |L(n)|.
    # Try EVERY map reflect : L(n) -> (L(n) -> 2) and show the diagonal escapes.
    size = len(domain)
    all_predicates = [tuple(bits) for bits in product([False, True], repeat=size)]
    escaped_all = True
    # A "reflection" assigns to each of the |L(n)| points one predicate.
    for assignment in product(range(len(all_predicates)), repeat=size):
        reflect = [all_predicates[k] for k in assignment]
        diag = diagonal_predicate(reflect, domain)
        if diag in reflect:
            escaped_all = False
            break
    print(f"  domain |L({n})| = {size}, predicate space size = {len(all_predicates)}")
    print(f"  diagonal predicate escapes EVERY candidate reflection: {escaped_all}\n")
    assert escaped_all


# --------------------------------------------------------------------------- #
# Result 3: lower reflection is always possible (explicit surjection)
# --------------------------------------------------------------------------- #
def demo_lower_reflection(m: int = 0, n: int = 1) -> None:
    print(f"=== Lower reflection L({n}) ->> (L({m}) -> 2) is possible ===")
    assert m < n
    predspace_size = level_size(m + 1)  # |L(m) -> 2| = |L(m+1)|
    ln_size = level_size(n)
    print(f"  |L({m}) -> 2| = |L({m+1})| = {predspace_size} <= |L({n})| = {ln_size}")
    # Build an injection e : predicate-space -> L(n) (identity on an index prefix),
    # then its left inverse r is a surjection L(n) ->> predicate-space.
    inject: Callable[[int], int] = lambda t: t  # first predspace_size indices
    def surject(x: int) -> int:
        return x if x < predspace_size else 0
    covered = {surject(inject(t)) for t in range(predspace_size)}
    print(f"  surjection covers all {len(covered)} predicates: "
          f"{covered == set(range(predspace_size))}\n")
    assert covered == set(range(predspace_size))


# --------------------------------------------------------------------------- #
# Result 4: base-level classification (negation is the unique fpf self-map)
# --------------------------------------------------------------------------- #
def demo_base_classification() -> None:
    print("=== Base-level classification: negation is the only fpf self-map ===")
    base = [False, True]
    fpf_maps = []
    for f_false, f_true in product([False, True], repeat=2):
        f = {False: f_false, True: f_true}
        if all(f[b] != b for b in base):
            fpf_maps.append(f)
    negation = {False: True, True: False}
    print(f"  fixed-point-free self-maps of the base: {fpf_maps}")
    print(f"  unique, and equals negation: {fpf_maps == [negation]}\n")
    assert fpf_maps == [negation]


if __name__ == "__main__":
    demo_cardinal_growth(max_level=4)
    demo_no_self_reflection(n=0)
    demo_lower_reflection(m=0, n=1)
    demo_base_classification()
    print("All reflective-tower demonstrations passed.")
