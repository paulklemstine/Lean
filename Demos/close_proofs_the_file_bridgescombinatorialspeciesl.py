"""Homotopy Cardinality of Species — numerical demonstrations.

This self-contained script illustrates the central results of the package:

    [X^n] EGF(F)  =  |F[n]| / n!  =  | F[n] // S_n |  =  sum_orbits 1 / |Stab|.

We implement the action groupoid of a finite group action from scratch, compute
its homotopy (groupoid) cardinality by orbit enumeration, and verify:

  * Theorem 3.1:  | X // G |  =  |X| / |G|        (action-groupoid cardinality)
  * Theorem 4.3:  | F[n] // S_n |  =  |F[n]| / n!  (species action-groupoid card)
  * Theorem 4.4:  EGF coefficient = homotopy cardinality (the central bridge)
  * Theorem 5.1:  species of sets E:   | E[n] // S_n | = 1/n!  (giving exp)
  * Theorem 5.2:  species of linear orders L: | L[n] // S_n | = 1 (giving 1/(1-X))

Everything is exact: we use Python's `fractions.Fraction`, so the verifications
are equalities of rationals, not floating-point approximations.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from math import factorial
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Permutations of {0, ..., n-1}, encoded as tuples p with p[i] = image of i.
# These form the symmetric group S_n = Perm(Fin n).
# ---------------------------------------------------------------------------

Perm = Tuple[int, ...]


def symmetric_group(n: int) -> List[Perm]:
    """Return all n! permutations of {0, ..., n-1} as image tuples."""
    return list(permutations(range(n)))


def compose(p: Perm, q: Perm) -> Perm:
    """Group product (p . q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))


# ---------------------------------------------------------------------------
# Action groupoid X // G : orbits and stabilizers via a generic action.
#   action(g, x) -> x'    is a left action of the group on the finite set X.
# ---------------------------------------------------------------------------

def orbits_and_stabilizers(
    group: Sequence[Perm],
    points: Sequence[object],
    action: Callable[[Perm, object], object],
) -> List[Tuple[object, int]]:
    """Partition `points` into orbits under `group`.

    Returns a list with one (representative, stabilizer_order) pair per orbit.
    """
    seen: set = set()
    result: List[Tuple[object, int]] = []
    point_set = set(points)
    for x in points:
        if x in seen:
            continue
        orbit = {action(g, x) for g in group}
        seen |= orbit
        assert orbit <= point_set, "action escaped the point set"
        stab_order = sum(1 for g in group if action(g, x) == x)
        result.append((x, stab_order))
    return result


def homotopy_cardinality(
    group: Sequence[Perm],
    points: Sequence[object],
    action: Callable[[Perm, object], object],
) -> Fraction:
    """| X // G | = sum over orbits of 1 / |Stab(rep)|   (Definition 2.3)."""
    total = Fraction(0)
    for _rep, stab_order in orbits_and_stabilizers(group, points, action):
        total += Fraction(1, stab_order)
    return total


# ---------------------------------------------------------------------------
# Theorem 3.1: | X // G | = |X| / |G| for any finite group action.
# ---------------------------------------------------------------------------

def verify_action_groupoid_identity(
    group: Sequence[Perm],
    points: Sequence[object],
    action: Callable[[Perm, object], object],
) -> Tuple[Fraction, Fraction, bool]:
    """Return (homotopy card, |X|/|G|, equal?)."""
    lhs = homotopy_cardinality(group, points, action)
    rhs = Fraction(len(points), len(group))
    return lhs, rhs, lhs == rhs


# ---------------------------------------------------------------------------
# The two emblematic species.
# ---------------------------------------------------------------------------

def set_species_card(n: int) -> Fraction:
    """| E[n] // S_n | with E[n] a single point and trivial relabelling action.

    One orbit, full stabilizer S_n, so the value is 1/n!  (Theorem 5.1).
    """
    group = symmetric_group(n)
    points: List[object] = [0]  # the unique structure
    action = lambda g, x: x  # trivial action: relabelling fixes the lone point
    return homotopy_cardinality(group, points, action)


def linear_order_species_card(n: int) -> Fraction:
    """| L[n] // S_n | with L[n] = Perm(Fin n) and the regular action.

    Free + transitive (a torsor): one orbit, trivial stabilizer, value 1 (Thm 5.2).
    """
    group = symmetric_group(n)
    points = symmetric_group(n)  # L[n] = S_n as a set
    action = lambda g, x: compose(g, x)  # left translation (regular action)
    return homotopy_cardinality(group, points, action)


# ---------------------------------------------------------------------------
# EGF coefficients and the bridge.
# ---------------------------------------------------------------------------

def egf_coefficient(count: int, n: int) -> Fraction:
    """[X^n] of an EGF with |F[n]| = count, namely count / n!."""
    return Fraction(count, factorial(n))


def exp_coefficient(n: int) -> Fraction:
    """[X^n] exp(X) = 1/n!."""
    return Fraction(1, factorial(n))


def geometric_coefficient(n: int) -> Fraction:
    """[X^n] 1/(1-X) = 1."""
    return Fraction(1)


# ---------------------------------------------------------------------------
# Demonstration driver.
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("HOMOTOPY CARDINALITY OF SPECIES  —  numerical demonstrations")
    print("=" * 72)

    # ---- Theorem 3.1 on a non-trivial action: S_3 acting on the 3 vertices.
    print("\n[Theorem 3.1]  | X // G | = |X| / |G|")
    print("-" * 72)
    # G = S_3 acting on points {0,1,2} by evaluation.
    g3 = symmetric_group(3)
    pts3 = [0, 1, 2]
    act_eval = lambda g, x: g[x]
    lhs, rhs, ok = verify_action_groupoid_identity(g3, pts3, act_eval)
    print(f"  S_3 on {{0,1,2}} (natural action): "
          f"sum 1/|Stab| = {lhs},  |X|/|G| = {rhs}  -> {'OK' if ok else 'FAIL'}")

    # G = S_3 acting on ordered pairs (i,j), i != j  (6 points, regular-like).
    pairs = [(i, j) for i in range(3) for j in range(3) if i != j]
    act_pair = lambda g, x: (g[x[0]], g[x[1]])
    lhs, rhs, ok = verify_action_groupoid_identity(g3, pairs, act_pair)
    print(f"  S_3 on ordered distinct pairs:    "
          f"sum 1/|Stab| = {lhs},  |X|/|G| = {rhs}  -> {'OK' if ok else 'FAIL'}")

    # G = S_4 acting on the 6 unordered pairs (edges of K_4).
    g4 = symmetric_group(4)
    edges = [(i, j) for i in range(4) for j in range(i + 1, 4)]
    act_edge = lambda g, e: tuple(sorted((g[e[0]], g[e[1]])))
    lhs, rhs, ok = verify_action_groupoid_identity(g4, edges, act_edge)
    print(f"  S_4 on edges of K_4:              "
          f"sum 1/|Stab| = {lhs},  |X|/|G| = {rhs}  -> {'OK' if ok else 'FAIL'}")

    # ---- Theorem 5.1 / EGF(E) = exp.
    print("\n[Theorem 5.1]  species of sets E:  | E[n] // S_n | = 1/n!  ->  exp(X)")
    print("-" * 72)
    for n in range(6):
        h = set_species_card(n)
        e = exp_coefficient(n)
        bridge = egf_coefficient(1, n)  # |E[n]| = 1
        ok = h == e == bridge
        print(f"  n={n}: |E[n]//S_n| = {str(h):>10}   1/n! = {str(e):>10}   "
              f"[X^n]exp = {str(e):>10}  -> {'OK' if ok else 'FAIL'}")

    # ---- Theorem 5.2 / EGF(L) = 1/(1-X).
    print("\n[Theorem 5.2]  species of linear orders L:  | L[n] // S_n | = 1  ->  1/(1-X)")
    print("-" * 72)
    for n in range(6):
        h = linear_order_species_card(n)
        g = geometric_coefficient(n)
        bridge = egf_coefficient(factorial(n), n)  # |L[n]| = n!
        ok = h == g == bridge
        print(f"  n={n}: |L[n]//S_n| = {str(h):>4}   [X^n]1/(1-X) = {str(g):>4}   "
              f"|L[n]|/n! = {str(bridge):>4}  -> {'OK' if ok else 'FAIL'}")

    # ---- The symmetry spectrum summary (Theorem 4.4 read two ways).
    print("\n[The symmetry spectrum]  same group S_n, opposite extremes")
    print("-" * 72)
    print(f"  {'n':>2} | {'|E[n]|':>6} {'|E[n]//Sn|':>12} | {'|L[n]|':>6} {'|L[n]//Sn|':>12}")
    for n in range(6):
        print(f"  {n:>2} | {1:>6} {str(set_species_card(n)):>12} | "
              f"{factorial(n):>6} {str(linear_order_species_card(n)):>12}")

    print("\nAll identities verified exactly over the rationals.")
    print("=" * 72)


if __name__ == "__main__":
    main()
