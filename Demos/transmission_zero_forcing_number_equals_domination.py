"""
demo.py — Numerical demonstrations for:

    The Exact Domination Number of the Path, gamma(P_n) = ceil(n/3),
    and its sharp separation from ordinary zero forcing (Z(P_n) = 1).

This module is fully self-contained (standard library only) and uses type
hints throughout. Every function is inlined; running the file prints a series
of verification tables confirming the theorems from the accompanying paper:

  * Theorem (counting lower bound):        n <= 3 * |S| for any dominating set S
  * Theorem (optimal construction):        domConstruction(n) dominates P_n
  * Theorem (exact value):                 gamma(P_n) = ceil(n/3) = (n+2)//3
  * Proposition (zero forcing):            Z(P_n) = 1 for all n >= 1
  * Corollary (sharp separation):          gamma(P_n) - Z(P_n) -> infinity

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# Path model: vertices are 0, 1, ..., n-1; edges between consecutive integers.
# ---------------------------------------------------------------------------

def closed_neighborhood(n: int, v: int) -> Set[int]:
    """Return the closed neighborhood {v-1, v, v+1} of vertex v in P_n,
    intersected with the valid vertex range {0, ..., n-1}."""
    return {u for u in (v - 1, v, v + 1) if 0 <= u < n}


def dominates_path(n: int, s: FrozenSet[int]) -> bool:
    """Return True iff S subseteq {0,...,n-1} dominates the path P_n:
    every vertex i < n lies within graph distance 1 of some s in S."""
    if not s.issubset(range(n)):
        return False
    for i in range(n):
        if not any(abs(i - guard) <= 1 for guard in s):
            return False
    return True


# ---------------------------------------------------------------------------
# Closed-form domination number and the explicit optimal construction.
# ---------------------------------------------------------------------------

def gamma_path_closed_form(n: int) -> int:
    """The closed-form domination number gamma(P_n) = ceil(n/3) = (n+2)//3."""
    return (n + 2) // 3


def dom_construction(n: int) -> FrozenSet[int]:
    """The explicit optimal dominating set: a guard at min(3k+1, n-1)
    for each k < ceil(n/3). Clamping the last guard to n-1 prevents
    overshooting the end of the path (Definition 2.7 of the paper)."""
    if n == 0:
        return frozenset()
    guards = {min(3 * k + 1, n - 1) for k in range(gamma_path_closed_form(n))}
    return frozenset(guards)


# ---------------------------------------------------------------------------
# Brute-force domination number (Algorithm A): ground-truth checker.
# ---------------------------------------------------------------------------

def gamma_path_bruteforce(n: int) -> int:
    """Compute gamma(P_n) by exhaustive search over subset sizes k = 0, 1, ...
    Returns the smallest k for which some k-subset dominates P_n."""
    if n == 0:
        return 0
    verts: List[int] = list(range(n))
    for k in range(0, n + 1):
        for combo in combinations(verts, k):
            if dominates_path(n, frozenset(combo)):
                return k
    return n  # unreachable for n >= 0


# ---------------------------------------------------------------------------
# Ordinary zero forcing (Algorithm for Z): the color-change closure.
# ---------------------------------------------------------------------------

def zero_forcing_closure(n: int, blue: Set[int]) -> Set[int]:
    """Apply the zero-forcing color-change rule to closure on P_n:
    a blue vertex with exactly one white neighbor forces that neighbor blue."""
    blue = set(blue)
    changed = True
    while changed:
        changed = False
        for v in list(blue):
            white_neighbors = [u for u in closed_neighborhood(n, v)
                               if u != v and u not in blue]
            if len(white_neighbors) == 1:
                blue.add(white_neighbors[0])
                changed = True
    return blue


def is_zero_forcing_set(n: int, blue: Set[int]) -> bool:
    """Return True iff `blue` zero-forces all of P_n."""
    return len(zero_forcing_closure(n, blue)) == n


def zero_forcing_number_bruteforce(n: int) -> int:
    """Compute Z(P_n) by exhaustive search over subset sizes."""
    if n == 0:
        return 0
    verts: List[int] = list(range(n))
    for k in range(0, n + 1):
        for combo in combinations(verts, k):
            if is_zero_forcing_set(n, set(combo)):
                return k
    return n


# ---------------------------------------------------------------------------
# Demonstration driver.
# ---------------------------------------------------------------------------

def verify_lower_bound(n: int) -> bool:
    """Check the counting lower bound n <= 3*|S| over ALL dominating sets S
    of P_n (small n only). Returns True iff it holds for every such S."""
    verts: List[int] = list(range(n))
    for k in range(0, n + 1):
        for combo in combinations(verts, k):
            s = frozenset(combo)
            if dominates_path(n, s) and not (n <= 3 * len(s)):
                return False
    return True


def main() -> None:
    print("=" * 70)
    print("Domination number of the path  gamma(P_n) = ceil(n/3) = (n+2)//3")
    print("=" * 70)
    header: Tuple[str, ...] = (
        "n", "closed", "brute", "match",
        "|domConstr|", "dominates?", "Z(P_n)",
    )
    print("{:>3} {:>7} {:>6} {:>6} {:>12} {:>11} {:>7}".format(*header))
    print("-" * 70)

    gammas: List[int] = []
    zs: List[int] = []
    for n in range(1, 10):
        cf = gamma_path_closed_form(n)
        bf = gamma_path_bruteforce(n)
        construction = dom_construction(n)
        dominates = dominates_path(n, construction)
        z = zero_forcing_number_bruteforce(n)
        gammas.append(bf)
        zs.append(z)
        print("{:>3} {:>7} {:>6} {:>6} {:>12} {:>11} {:>7}".format(
            n, cf, bf, "OK" if cf == bf else "FAIL",
            len(construction), "yes" if dominates else "NO", z,
        ))

    print("-" * 70)
    print(f"gamma(P_1..P_9) = {gammas}")
    print(f"Z(P_1..P_9)     = {zs}")
    print()

    print("Counting lower bound  n <= 3*|S|  over ALL dominating sets:")
    for n in range(1, 11):
        ok = verify_lower_bound(n)
        print(f"  n = {n:>2}: {'holds for every dominating set' if ok else 'VIOLATED'}")
    print()

    print("Sharp separation gamma - Z (grows without bound):")
    for n in (3, 6, 9, 12, 15):
        g = gamma_path_closed_form(n)
        z = zero_forcing_number_bruteforce(n) if n <= 12 else 1
        print(f"  n = {n:>2}:  gamma = {g:>2},  Z = {z},  gap = {g - z}")
    print()

    # Explicit optimal dominating sets.
    print("Explicit optimal dominating sets (domConstruction):")
    for n in (4, 7, 10):
        print(f"  P_{n}: {sorted(dom_construction(n))}")


if __name__ == "__main__":
    main()
