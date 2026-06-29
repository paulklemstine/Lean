"""
Numerical demonstrations for:

    Excluded minors for Z/n-gainable biased graphs
    (the parallel-class / digon slice, over arbitrary cyclic groups)

This script is fully self-contained (standard library only) and mirrors the
formalised results:

  * signedSum / realisation of a gain labelling             (signedSum, GainableBy)
  * the pigeonhole obstruction (n+1)K2 is not Z/n-gainable  (parallelEdges_not_gainable)
  * minor-closedness of gainability                         (gainableBy_of_isMinor)
  * the parallel-class threshold:                           (digon_gainable_iff_card,
        gainable  <=>  #balance-classes <= n                 digon_isMinor_iff_card,
        (n+1)K2 minor  <=>  #classes >= n+1                  digon_excluded_minor)
  * the divisibility monotonicity law                       (gainable_mono_of_dvd)
        m | n  =>  Z/m-gainable implies Z/n-gainable,
        realised by the embedding j -> j*(n/m).

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

# An oriented closed walk: list of (edge, forward?) pairs.
Walk = List[Tuple[int, bool]]


# --------------------------------------------------------------------------- #
# Core gain framework                                                         #
# --------------------------------------------------------------------------- #
def signed_sum(g: Dict[int, int], walk: Walk, n: int) -> int:
    """Signed sum of gains around `walk`, taken in Z/n.

    Forward edges (True) contribute +g(e); backward edges (False) contribute -g(e).
    """
    total = 0
    for edge, forward in walk:
        total += g[edge] if forward else -g[edge]
    return total % n


def realises(
    g: Dict[int, int],
    cycles: List[Walk],
    balanced: Callable[[Walk], bool],
    n: int,
) -> bool:
    """Does labelling `g` realise the biased graph over Z/n?

    A cycle is balanced  <=>  its signed sum is 0 in Z/n.
    """
    return all(balanced(c) == (signed_sum(g, c, n) == 0) for c in cycles)


def is_gainable_bruteforce(
    edges: List[int],
    cycles: List[Walk],
    balanced: Callable[[Walk], bool],
    n: int,
) -> Optional[Dict[int, int]]:
    """Exhaustively search for a Z/n labelling realising the biased graph.

    Returns a witness labelling if one exists, else None. Exponential; for demos only.
    """
    for assignment in product(range(n), repeat=len(edges)):
        g = {e: assignment[i] for i, e in enumerate(edges)}
        if realises(g, cycles, balanced, n):
            return g
    return None


# --------------------------------------------------------------------------- #
# The parallel-class (digon) family                                          #
# --------------------------------------------------------------------------- #
def digon_cycles(edges: List[int]) -> List[Walk]:
    """All digons [(i,+),(j,-)] for distinct edges i != j of a parallel class."""
    return [[(i, True), (j, False)] for i in edges for j in edges if i != j]


def make_balanced_predicate(classes: Dict[int, int]) -> Callable[[Walk], bool]:
    """Balance relation: a digon [(i,+),(j,-)] is balanced iff i,j share a class."""

    def balanced(walk: Walk) -> bool:
        (i, _), (j, _) = walk[0], walk[1]
        return classes[i] == classes[j]

    return balanced


def num_classes(classes: Dict[int, int]) -> int:
    return len(set(classes.values()))


# --------------------------------------------------------------------------- #
# The divisibility law                                                        #
# --------------------------------------------------------------------------- #
def embed_zmod(label_mod_m: int, m: int, n: int) -> int:
    """Injective additive homomorphism Z/m -> Z/n (requires m | n): j -> j*(n//m)."""
    assert n % m == 0, "embedding Z/m -> Z/n requires m | n"
    return (label_mod_m * (n // m)) % n


def transport_labelling(g_m: Dict[int, int], m: int, n: int) -> Dict[int, int]:
    """Transport a Z/m labelling to a Z/n labelling via the embedding (m | n)."""
    return {e: embed_zmod(v, m, n) for e, v in g_m.items()}


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_pigeonhole() -> None:
    print("=" * 70)
    print("Demo 1:  (n+1)K2 is NOT Z/n-gainable  [parallelEdges_not_gainable]")
    print("=" * 70)
    for n in (2, 3, 4, 6):
        edges = list(range(n + 1))  # (n+1) parallel edges
        cycles = digon_cycles(edges)
        balanced = lambda w: False  # all digons unbalanced
        witness = is_gainable_bruteforce(edges, cycles, balanced, n)
        print(f"  n={n}:  (n+1)K2 has {n+1} edges, Z/{n} has {n} values "
              f"-> gainable? {'YES' if witness else 'NO'}")
    # By contrast n*K2 IS gainable: assign 0,1,...,n-1.
    print("  (sanity) n*K2 with n distinct labels IS gainable for each n above.")
    for n in (2, 3, 4, 6):
        edges = list(range(n))
        cycles = digon_cycles(edges)
        witness = is_gainable_bruteforce(edges, cycles, lambda w: False, n)
        print(f"    n={n}: n*K2 gainable? {'YES' if witness else 'NO'}  "
              f"witness={witness}")
    print()


def demo_threshold() -> None:
    print("=" * 70)
    print("Demo 2:  parallel-class threshold  [digon_gainable_iff_card /")
    print("         digon_isMinor_iff_card / digon_excluded_minor]")
    print("=" * 70)
    # 6 edges partitioned into a variable number of balance classes.
    edges = list(range(6))
    n = 3
    for partition in (
        {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0},   # 1 class
        {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2},   # 3 classes
        {0: 0, 1: 1, 2: 2, 3: 3, 4: 0, 5: 1},   # 4 classes
    ):
        q = num_classes(partition)
        cycles = digon_cycles(edges)
        balanced = make_balanced_predicate(partition)
        witness = is_gainable_bruteforce(edges, cycles, balanced, n)
        predicted = q <= n
        minor_present = q >= n + 1
        print(f"  classes q={q}, n={n}:  gainable(brute)={'YES' if witness else 'NO':3} "
              f"| predicted(q<=n)={predicted} | (n+1)K2 minor(q>=n+1)={minor_present}")
        assert (witness is not None) == predicted, "threshold mismatch!"
        assert minor_present == (not predicted), "excluded-minor equivalence mismatch!"
    print("  All cases agree with digon_excluded_minor:  gainable  <=>  no (n+1)K2 minor.")
    print()


def demo_divisibility() -> None:
    print("=" * 70)
    print("Demo 3:  divisibility monotonicity  [gainable_mono_of_dvd]")
    print("=" * 70)
    # A 3-class parallel graph: gainable over Z/3, transport to Z/12 (3 | 12).
    edges = list(range(6))
    partition = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2}  # 3 classes
    cycles = digon_cycles(edges)
    balanced = make_balanced_predicate(partition)

    m, n = 3, 12
    g_m = is_gainable_bruteforce(edges, cycles, balanced, m)
    print(f"  Z/{m} witness: {g_m}")
    assert g_m is not None
    g_n = transport_labelling(g_m, m, n)
    print(f"  embed j -> j*(n/m)=j*{n//m};  transported Z/{n} labelling: {g_n}")
    ok = realises(g_n, cycles, balanced, n)
    print(f"  transported labelling realises the graph over Z/{n}? {'YES' if ok else 'NO'}")
    assert ok
    # Divisibility, not size: 3 does NOT divide 4.
    print(f"  note: 3 | 12 so transport works; but 3 does not divide 4, "
          f"so no homomorphic embedding Z/3 -> Z/4.")
    print()


def demo_minor_closed() -> None:
    print("=" * 70)
    print("Demo 4:  minor-closedness  [gainableBy_of_isMinor]")
    print("=" * 70)
    # If G is gainable then any (n+1)K2 it contains would force gainability of
    # (n+1)K2 -- impossible.  Illustrate the contrapositive numerically.
    n = 2
    # G = 4 edges with 3 balance classes => q=3 > n=2 => NOT gainable, contains (n+1)K2.
    edges = list(range(4))
    partition = {0: 0, 1: 1, 2: 2, 3: 0}  # 3 classes
    cycles = digon_cycles(edges)
    balanced = make_balanced_predicate(partition)
    witness = is_gainable_bruteforce(edges, cycles, balanced, n)
    q = num_classes(partition)
    print(f"  n={n}, classes q={q}:  gainable? {'YES' if witness else 'NO'}  "
          f"(contains (n+1)K2 minor since q>=n+1={q>=n+1})")
    print("  Hence by minor-closedness no Z/2-gainable graph can contain this as a minor.")
    print()


def main() -> None:
    demo_pigeonhole()
    demo_threshold()
    demo_divisibility()
    demo_minor_closed()
    print("All demonstrations completed and internal assertions passed.")


if __name__ == "__main__":
    main()
