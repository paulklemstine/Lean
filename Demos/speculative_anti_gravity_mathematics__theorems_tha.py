"""
Anti-Gravity Mathematics: numerical demonstrations.

A *library* is a finite set of theorems V with a dependency relation D, where
D(a, b) means "theorem b depends on theorem a" (a is used in the proof of b).

  * gravitational weight w(a) = #{ b : D(a, b) }   (number of dependents)
  * in-degree         d(b)   = #{ a : D(a, b) }   (number of direct dependencies)
  * a theorem a is ANTI-GRAVITY at (w0, l0) if  w(a) >= w0  and  plen(a) <= l0
    (high weight, short proof).

This script verifies, on concrete libraries, every result of the accompanying
paper: the handshake identity, weight bounds, the averaging principle, the
pigeonhole existence theorem, monotonicity under transitivity, the explicit
linear and grid witnesses, and the refutation of the universal "fixed fraction"
prediction.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Set, Tuple


# --------------------------------------------------------------------------- #
# Core model                                                                  #
# --------------------------------------------------------------------------- #

def dep_weight(vertices: List[object], dep: Callable[[object, object], bool],
               a: object) -> int:
    """Gravitational weight of a: number of theorems that depend on a."""
    return sum(1 for b in vertices if dep(a, b))


def in_degree(vertices: List[object], dep: Callable[[object, object], bool],
              b: object) -> int:
    """In-degree of b: number of theorems b directly depends on."""
    return sum(1 for a in vertices if dep(a, b))


def is_anti_gravity(vertices: List[object], dep: Callable[[object, object], bool],
                    plen: Callable[[object], int], w0: int, l0: int,
                    a: object) -> bool:
    """True iff a has weight >= w0 and proof length <= l0."""
    return dep_weight(vertices, dep, a) >= w0 and plen(a) <= l0


def anti_gravity_set(vertices: List[object], dep: Callable[[object, object], bool],
                     plen: Callable[[object], int], w0: int, l0: int
                     ) -> List[object]:
    """All anti-gravity theorems in the library at thresholds (w0, l0)."""
    return [a for a in vertices if is_anti_gravity(vertices, dep, plen, w0, l0, a)]


# --------------------------------------------------------------------------- #
# Demo 1: handshake identity and weight bounds                                #
# --------------------------------------------------------------------------- #

def demo_handshake() -> None:
    print("=" * 70)
    print("DEMO 1: Handshake identity  sum w(a) = sum d(b), and weight bounds")
    print("=" * 70)
    # A small irreflexive library on {0,...,4}: j depends on i iff i < j.
    n = 5
    V = list(range(n))
    dep = lambda i, j: i < j

    total_weight = sum(dep_weight(V, dep, a) for a in V)
    total_indeg = sum(in_degree(V, dep, b) for b in V)
    print(f"  vertices           : {V}")
    print(f"  sum of weights     : {total_weight}")
    print(f"  sum of in-degrees  : {total_indeg}")
    assert total_weight == total_indeg, "handshake identity failed"
    print("  handshake identity : sum w = sum d   OK")

    for a in V:
        w = dep_weight(V, dep, a)
        assert w <= n, "weight ceiling failed"
        assert w < n, "strict ceiling (irreflexive) failed"
    print(f"  all weights < N={n} (irreflexive strict ceiling)   OK")
    print(f"  weights            : {[dep_weight(V, dep, a) for a in V]}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: averaging principle and pigeonhole existence                        #
# --------------------------------------------------------------------------- #

def demo_existence() -> None:
    print("=" * 70)
    print("DEMO 2: Averaging bound + pigeonhole existence of anti-gravity")
    print("=" * 70)
    n = 8
    V = list(range(n))
    dep = lambda i, j: i < j           # linear library
    plen = lambda a: 1                  # every proof has length 1

    weights = [dep_weight(V, dep, a) for a in V]
    a_star = max(V, key=lambda a: dep_weight(V, dep, a))
    w_max = dep_weight(V, dep, a_star)
    total = sum(weights)
    print(f"  weights            : {weights}")
    print(f"  max weight w(a*)   : {w_max}  (at a*={a_star})")
    print(f"  averaging bound    : sum w = {total} <= N*w(a*) = {n * w_max}   "
          f"{'OK' if total <= n * w_max else 'FAIL'}")

    # Pigeonhole existence: short-proof set S = all (l0 = 1); if |S|*w0 <= sum,
    # an anti-gravity theorem must exist.
    l0 = 1
    S = [a for a in V if plen(a) <= l0]
    sum_S = sum(dep_weight(V, dep, a) for a in S)
    w0 = sum_S // len(S)               # the guaranteed floor: average weight
    print(f"  short-proof set S  : {S}")
    print(f"  |S|*w0={len(S) * w0} <= sum_S={sum_S}   "
          f"{'(hypothesis holds)' if len(S) * w0 <= sum_S else '(fails)'}")
    witnesses = anti_gravity_set(V, dep, plen, w0, l0)
    print(f"  guaranteed w0      : {w0}")
    print(f"  anti-gravity found : {witnesses}   (nonempty as predicted)")
    assert witnesses, "existence theorem prediction failed"
    print()


# --------------------------------------------------------------------------- #
# Demo 3: monotonicity under transitive dependency (foundations are heaviest) #
# --------------------------------------------------------------------------- #

def demo_monotonicity() -> None:
    print("=" * 70)
    print("DEMO 3: Foundations are heaviest (weight monotone under transitivity)")
    print("=" * 70)
    n = 6
    V = list(range(n))
    dep = lambda i, j: i < j           # transitive
    for a in V:
        for b in V:
            if dep(a, b):              # b depends on a  =>  w(b) <= w(a)
                assert dep_weight(V, dep, b) <= dep_weight(V, dep, a)
    print("  verified: D(a,b) implies w(b) <= w(a) for all pairs   OK")
    print(f"  weights (descending toward foundation 0): "
          f"{[dep_weight(V, dep, a) for a in V]}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: explicit witnesses (linear O(n) and grid O(n*m))                    #
# --------------------------------------------------------------------------- #

def demo_witnesses() -> None:
    print("=" * 70)
    print("DEMO 4: Explicit anti-gravity witnesses (linear and grid libraries)")
    print("=" * 70)
    # Linear library: bottom theorem 0 has weight n-1.
    for n in (3, 10, 50):
        V = list(range(n))
        dep = lambda i, j: i < j
        w0 = dep_weight(V, dep, 0)
        print(f"  linear n={n:<3}: w(0) = {w0}  (predicted n-1 = {n - 1})   "
              f"{'OK' if w0 == n - 1 else 'FAIL'},  proof length 1")
        assert w0 == n - 1

    print()
    # Grid library on Fin n x Fin m: node q depends on p iff p.row < q.row.
    for n, m in ((3, 4), (5, 5), (10, 8)):
        V = [(r, c) for r in range(n) for c in range(m)]
        dep = lambda p, q: p[0] < q[0]
        bottom = (0, 0)
        w = dep_weight(V, dep, bottom)
        pred = (n - 1) * m
        print(f"  grid {n}x{m}: w(bottom-row) = {w}  "
              f"(predicted (n-1)*m = {pred})   {'OK' if w == pred else 'FAIL'},"
              f"  proof length 1")
        assert w == pred
    print("  -> weight Theta(n^2) with m=Theta(n), constant proof length")
    print()


# --------------------------------------------------------------------------- #
# Demo 5: refutation of the universal "fixed fraction" prediction            #
# --------------------------------------------------------------------------- #

def demo_refutation() -> None:
    print("=" * 70)
    print("DEMO 5: Refutation -- a dependency-free library has NO anti-gravity")
    print("=" * 70)
    n = 20
    V = list(range(n))
    dep = lambda i, j: False           # empty dependency relation
    plen = lambda a: 1
    for w0 in (1, 2, 5):
        found = anti_gravity_set(V, dep, plen, w0, l0=1)
        frac = len(found) / n
        print(f"  w0={w0}: anti-gravity count = {len(found)}  "
              f"(fraction = {frac:.0%})")
        assert not found
    print("  -> fraction is exactly 0%, refuting any universal positive fraction")
    print()


if __name__ == "__main__":
    demo_handshake()
    demo_existence()
    demo_monotonicity()
    demo_witnesses()
    demo_refutation()
    print("All demonstrations passed.")
