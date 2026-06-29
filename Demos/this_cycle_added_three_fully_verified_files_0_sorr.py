"""
Numerical demonstrations for:

    Relabeling Invariance and Quotient Transport
    for the Categorical Tropical Rips Interleaving Geometry

A *filtration* on a finite label set assigns to each nonempty simplex (finite
subset of labels) a real "appearance time" `weight(sigma)`, subject to
monotonicity `sigma subset tau => weight(sigma) <= weight(tau)`.

Two operations:
  * shift(a, F):   weight(sigma) - a            (additive smoothing, a >= 0)
  * comap(e, F):   weight( e(sigma) )           (relabeling along a bijection e)

For sublevel filtrations the interleaving distance has the explicit form
  interleavingDist(F, G) = max over simplices |F.weight(sigma) - G.weight(sigma)|.

This script demonstrates, on concrete finite examples, the four headline results:
  1. shift_comap:               smoothing commutes with relabeling.
  2. interleavingDist_comap:     relabeling preserves interleaving distance.
  3. self-shift distance = a:    smoothing a filtration by a moves it by exactly a.
  4. transport principle:        an exact self-shift distance carries to every relabeling.

Everything is self-contained: standard library only, full type hints, no I/O beyond
print.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# A simplex is a frozenset of integer labels; a filtration is a dict simplex -> weight.
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def all_nonempty_simplices(labels: Iterable[int]) -> List[Simplex]:
    """Enumerate every nonempty subset of `labels` as a frozenset."""
    items: List[int] = list(labels)
    subsets = chain.from_iterable(
        combinations(items, r) for r in range(1, len(items) + 1)
    )
    return [frozenset(s) for s in subsets]


def make_monotone_filtration(
    labels: Iterable[int], vertex_time: Dict[int, float]
) -> Filtration:
    """
    Build a monotone filtration on `labels` from per-vertex appearance times.

    A simplex appears when its *last* vertex appears: weight(sigma) = max_{v in sigma}
    vertex_time[v]. This is automatically monotone under inclusion.
    """
    F: Filtration = {}
    for sigma in all_nonempty_simplices(labels):
        F[sigma] = max(vertex_time[v] for v in sigma)
    return F


def shift(a: float, F: Filtration) -> Filtration:
    """Additive smoothing: lower every weight by a >= 0."""
    if a < 0:
        raise ValueError("shift amount must be non-negative")
    return {sigma: w - a for sigma, w in F.items()}


def comap(e: Callable[[int], int], F: Filtration) -> Filtration:
    """
    Relabel along a bijection e: pull back F to a filtration whose value on sigma is
    F evaluated on the relabeled simplex e(sigma).
    """
    return {sigma: F[frozenset(e(v) for v in sigma)] for sigma in F}


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """
    Interleaving distance for sublevel filtrations on the same simplex set:
    the largest absolute disagreement in appearance times.
    """
    if set(F.keys()) != set(G.keys()):
        raise ValueError("filtrations must share the same simplex set")
    return max(abs(F[sigma] - G[sigma]) for sigma in F)


def permutation_to_map(perm: Dict[int, int]) -> Callable[[int], int]:
    """Turn an explicit permutation dict into a callable label map."""
    return lambda v: perm[v]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_shift_comap() -> None:
    """Result 1: comap(e, shift(a, F)) == shift(a, comap(e, F))."""
    print("=" * 70)
    print("Demo 1 — shift commutes with relabeling (shift_comap)")
    print("=" * 70)
    labels = [0, 1, 2]
    F = make_monotone_filtration(labels, {0: 0.5, 1: 1.5, 2: 3.0})
    e = permutation_to_map({0: 1, 1: 2, 2: 0})  # a 3-cycle on labels
    a = 0.75

    lhs = comap(e, shift(a, F))
    rhs = shift(a, comap(e, F))
    agree = all(abs(lhs[s] - rhs[s]) < 1e-12 for s in lhs)
    print(f"  labels = {labels}, shift a = {a}, permutation = 3-cycle (0->1->2->0)")
    print(f"  comap(e, shift(a,F)) == shift(a, comap(e,F)) ?  {agree}")
    print()


def demo_relabeling_invariance() -> None:
    """Result 2: interleavingDist is invariant under relabeling."""
    print("=" * 70)
    print("Demo 2 — relabeling preserves interleaving distance")
    print("=" * 70)
    labels = [0, 1, 2, 3]
    F = make_monotone_filtration(labels, {0: 0.0, 1: 1.0, 2: 2.0, 3: 4.0})
    G = make_monotone_filtration(labels, {0: 0.3, 1: 0.9, 2: 2.4, 3: 3.1})
    e = permutation_to_map({0: 3, 1: 0, 2: 1, 3: 2})

    d_before = interleaving_distance(F, G)
    d_after = interleaving_distance(comap(e, F), comap(e, G))
    print(f"  interleavingDist(F, G)                 = {d_before:.4f}")
    print(f"  interleavingDist(comap e F, comap e G) = {d_after:.4f}")
    print(f"  equal up to tolerance ?  {abs(d_before - d_after) < 1e-12}")
    print()


def demo_self_shift_distance() -> None:
    """Result 3: interleavingDist(F, shift(a, F)) == a."""
    print("=" * 70)
    print("Demo 3 — a shift moves a filtration by exactly its size")
    print("=" * 70)
    labels = [0, 1, 2]
    F = make_monotone_filtration(labels, {0: 0.2, 1: 1.1, 2: 2.7})
    for a in (0.0, 0.5, 1.25, 3.0):
        d = interleaving_distance(F, shift(a, F))
        print(f"  a = {a:>4}:  interleavingDist(F, shift a F) = {d:.4f}  (expected {a})")
    print()


def demo_transport_principle() -> None:
    """Result 4: an exact self-shift distance transports to every relabeling."""
    print("=" * 70)
    print("Demo 4 — transport principle (selfShiftDist_comap)")
    print("=" * 70)
    labels = [0, 1, 2, 3]
    F = make_monotone_filtration(labels, {0: 0.0, 1: 1.0, 2: 2.0, 3: 5.0})
    a = 1.4
    base = interleaving_distance(F, shift(a, F))
    print(f"  exact self-shift distance for F:  interleavingDist(F, shift a F) = {base:.4f}")

    permutations: List[Tuple[str, Dict[int, int]]] = [
        ("identity", {0: 0, 1: 1, 2: 2, 3: 3}),
        ("swap 0,3", {0: 3, 1: 1, 2: 2, 3: 0}),
        ("reverse ", {0: 3, 1: 2, 2: 1, 3: 0}),
        ("4-cycle ", {0: 1, 1: 2, 2: 3, 3: 0}),
    ]
    print("  transported distances for relabelings comap e F:")
    for name, perm in permutations:
        e = permutation_to_map(perm)
        Fe = comap(e, F)
        d = interleaving_distance(Fe, shift(a, Fe))
        print(f"    e = {name}:  interleavingDist(comap e F, shift a (comap e F)) = {d:.4f}")
    print(f"  all equal to the original exact value {base:.4f}.")
    print()


def main() -> None:
    demo_shift_comap()
    demo_relabeling_invariance()
    demo_self_shift_distance()
    demo_transport_principle()
    print("All demonstrations completed: the interleaving geometry is blind to labels.")


if __name__ == "__main__":
    main()
