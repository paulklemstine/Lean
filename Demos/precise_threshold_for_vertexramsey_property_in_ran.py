"""Numerical demonstrations of the exact vertex-Ramsey threshold for clique
families on the complete graph K_n.

Central fact proved in the accompanying work: for target clique sizes
s_1, ..., s_r (each >= 1), the complete graph on n vertices vertex-arrows the
family (K_{s_1}, ..., K_{s_r}) -- i.e. every vertex-coloring produces a
monochromatic clique of size s_i in some color i -- if and only if

        sum_i (s_i - 1) < n.

Equivalently, the vertex-Ramsey number is N(s) = 1 + sum_i (s_i - 1).

This script:
  * computes the threshold and vertex-Ramsey number,
  * exhaustively verifies arrowing / non-arrowing by brute force over all
    colorings for small n (a genuine finite check),
  * builds the explicit extremal (capacity-respecting) coloring witnessing the
    lower bound,
  * illustrates the pigeonhole (all-edges) specialization,
  * contrasts the additive vertex parameter with the multiplicative
    edge-density parameter.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Optional


# --------------------------------------------------------------------------- #
#  Core threshold arithmetic                                                   #
# --------------------------------------------------------------------------- #
def escape_capacity(targets: list[int]) -> int:
    """Total escape capacity C(s) = sum_i (s_i - 1)."""
    return sum(s - 1 for s in targets)


def vertex_ramsey_number(targets: list[int]) -> int:
    """Vertex-Ramsey number N(s) = 1 + sum_i (s_i - 1)."""
    return 1 + escape_capacity(targets)


def arrows(n: int, targets: list[int]) -> bool:
    """Predicate: does K_n vertex-arrow (K_{s_1}, ..., K_{s_r})?

    By the main theorem this is exactly sum_i (s_i - 1) < n.
    """
    return escape_capacity(targets) < n


# --------------------------------------------------------------------------- #
#  Brute-force verification over all colorings of K_n                          #
# --------------------------------------------------------------------------- #
def has_monochromatic_clique(coloring: tuple[int, ...], targets: list[int]) -> bool:
    """In K_n every subset is a clique, so we only need a monochromatic set of
    size s_i in some color i. Returns True if the coloring FAILS to escape."""
    n = len(coloring)
    for color, s in enumerate(targets):
        same = [v for v in range(n) if coloring[v] == color]
        if len(same) >= s:
            return True  # some s-subset is monochromatic and (in K_n) a clique
    return False


def arrows_bruteforce(n: int, targets: list[int]) -> bool:
    """Exhaustively check every one of r^n colorings of K_n. K_n arrows the
    family iff NO coloring escapes (every coloring has a monochromatic clique).
    """
    r = len(targets)
    for coloring in product(range(r), repeat=n):
        if not has_monochromatic_clique(coloring, targets):
            return False  # found an escaping coloring
    return True


# --------------------------------------------------------------------------- #
#  Explicit extremal (capacity-respecting) coloring for the lower bound        #
# --------------------------------------------------------------------------- #
def extremal_coloring(n: int, targets: list[int]) -> Optional[tuple[int, ...]]:
    """When n <= sum_i (s_i - 1), build a coloring of {0,...,n-1} in which color
    i is used at most s_i - 1 times, so no monochromatic clique of size s_i
    appears. Returns None if no such coloring exists (i.e. above threshold)."""
    if n > escape_capacity(targets):
        return None
    coloring: list[int] = []
    for color, s in enumerate(targets):
        cap = s - 1
        coloring.extend([color] * cap)
        if len(coloring) >= n:
            break
    return tuple(coloring[:n])


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_threshold_table() -> None:
    print("=" * 68)
    print("Vertex-Ramsey thresholds:  K_n arrows (K_{s_i})  <=>  sum(s_i-1) < n")
    print("=" * 68)
    families = [
        [2, 2],           # 2-color monochromatic edge (pigeonhole)
        [2, 2, 2],        # 3-color monochromatic edge
        [3, 3],           # two triangles
        [3, 4, 2],        # mixed targets
        [5],              # single color, clique of 5
    ]
    for targets in families:
        C = escape_capacity(targets)
        N = vertex_ramsey_number(targets)
        print(f"\ntargets s = {targets}")
        print(f"  escape capacity  C(s) = sum(s_i-1) = {C}")
        print(f"  vertex-Ramsey number N(s) = 1 + C  = {N}")
        print(f"  => K_{N} arrows the family, K_{N-1} does not")


def demo_bruteforce_matches_formula() -> None:
    print("\n" + "=" * 68)
    print("Brute-force check: formula vs. exhaustive enumeration of colorings")
    print("=" * 68)
    families = [[2, 2], [2, 2, 2], [3, 2], [3, 3]]
    for targets in families:
        print(f"\ntargets s = {targets}  (threshold n_c = {vertex_ramsey_number(targets)})")
        for n in range(1, vertex_ramsey_number(targets) + 2):
            formula = arrows(n, targets)
            brute = arrows_bruteforce(n, targets)
            status = "OK" if formula == brute else "MISMATCH!"
            print(f"  n={n:2d}: formula={formula!s:5}  brute={brute!s:5}  [{status}]")
            assert formula == brute, "theorem contradicted by brute force!"


def demo_extremal_coloring() -> None:
    print("\n" + "=" * 68)
    print("Explicit extremal colorings (lower-bound witnesses)")
    print("=" * 68)
    for targets, n in [([3, 3], 4), ([2, 2, 2], 3), ([4, 2], 4)]:
        c = extremal_coloring(n, targets)
        print(f"\ntargets s = {targets}, n = {n} (<= C(s) = {escape_capacity(targets)})")
        print(f"  capacity-respecting coloring of K_{n}: {c}")
        assert c is not None
        assert not has_monochromatic_clique(c, targets), "coloring should escape"
        counts = [c.count(i) for i in range(len(targets))]
        print(f"  color-class sizes {counts}  (each i has <= s_i-1 = "
              f"{[s - 1 for s in targets]})")
        print("  -> no monochromatic clique of target size: escape succeeds")


def demo_pigeonhole() -> None:
    print("\n" + "=" * 68)
    print("Pigeonhole specialization: all targets = 2 (monochromatic edge)")
    print("=" * 68)
    for r in range(2, 6):
        targets = [2] * r
        nc = vertex_ramsey_number(targets)  # = r + 1
        print(f"  r={r} colors: K_n has a monochromatic edge  <=>  r < n; "
              f"threshold n = {nc} (= r+1)")
        assert nc == r + 1


def demo_sum_vs_product() -> None:
    print("\n" + "=" * 68)
    print("Sum (vertex) vs. product (edge-density) governing parameters")
    print("=" * 68)
    # omega(H_j) - 1 for a few clique numbers
    omegas = [3, 4, 3]  # e.g. K_3, K_4, K_3 targets -> omega-1 = 2,3,2
    atoms = [w - 1 for w in omegas]
    additive = sum(atoms)                       # vertex side
    multiplicative = 1
    for a in atoms:
        multiplicative *= a                     # edge-density side psi
    print(f"  clique numbers omega(H_j) = {omegas}, atoms (omega-1) = {atoms}")
    print(f"  VERTEX side  : sum(omega-1)  = {additive}   "
          f"-> vertex-Ramsey number = {additive + 1}")
    print(f"  EDGE  side   : prod(omega-1) = psi = {multiplicative}   "
          f"-> Turan density pi_c = 1 - 1/psi = {1 - 1/multiplicative:.4f}")


if __name__ == "__main__":
    demo_threshold_table()
    demo_bruteforce_matches_formula()
    demo_extremal_coloring()
    demo_pigeonhole()
    demo_sum_vs_product()
    print("\nAll demonstrations completed and cross-checked.")
