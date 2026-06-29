"""
Numerical demonstrations of the exact local threshold for monochromatic stars.

This module is fully self-contained (standard library only) and illustrates the
results of the accompanying paper:

  * forcingF / sum_cc      -- the exact local pigeonhole threshold
                              sum_j (t_j - 1) + 1 on a colored finite set.
  * hasMonoStar_of_degree  -- graph-level forcing via vertex degree.
  * completeGraph_hasMonoStar -- the explicit K_N threshold sum_j (t_j - 1) + 2.
  * star_and_matching_pigeonhole -- one hypothesis, two conclusions
                              (a monochromatic star AND a 1/q sub-matching).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core counting engine (Lemma 3.1 / Theorem 3.2)
# ---------------------------------------------------------------------------

def color_class_counts(colors: Sequence[int], q: int) -> List[int]:
    """cc(M, c, j) for every color j in {0, ..., q-1}.

    `colors[i]` is the color assigned to the i-th object of the set M.
    Returns the list [cc_0, cc_1, ..., cc_{q-1}].
    """
    counts: List[int] = [0] * q
    for c in colors:
        counts[c] += 1
    return counts


def conservation_holds(colors: Sequence[int], q: int) -> bool:
    """Lemma 3.1 (sum_cc): sum_j cc_j == #M, checked numerically."""
    return sum(color_class_counts(colors, q)) == len(colors)


def local_threshold(t: Sequence[int]) -> int:
    """The exact forcing threshold sum_j (t_j - 1) + 1 on #M (Theorem 3.2)."""
    return sum(max(tj - 1, 0) for tj in t) + 1


def forced_star_color(colors: Sequence[int], t: Sequence[int]) -> Optional[int]:
    """Return a color j with cc_j >= t_j if one exists, else None (Theorem 3.2).

    When len(colors) >= local_threshold(t), the return value is guaranteed
    non-None for *every* coloring `colors`.
    """
    counts = color_class_counts(colors, len(t))
    for j, (cj, tj) in enumerate(zip(counts, t)):
        if cj >= tj:
            return j
    return None


# ---------------------------------------------------------------------------
# Graph-level forcing (Theorems 4.2, 4.4)
# ---------------------------------------------------------------------------

Edge = Tuple[int, int]


def neighbor_colors(
    vertex: int, edge_coloring: Dict[Edge, int]
) -> List[int]:
    """Colors of the edges incident to `vertex` (the colored set M = N(v))."""
    out: List[int] = []
    for (a, b), col in edge_coloring.items():
        if a == vertex or b == vertex:
            out.append(col)
    return out


def degree(vertex: int, edge_coloring: Dict[Edge, int]) -> int:
    """deg(v) = #N(v), the number of incident edges."""
    return len(neighbor_colors(vertex, edge_coloring))


def find_mono_star(
    vertices: Iterable[int], edge_coloring: Dict[Edge, int], t: Sequence[int]
) -> Optional[Tuple[int, int]]:
    """Return (v, j) witnessing a monochromatic star K_{1,t_j}, else None.

    Realizes Theorem 4.2: if some vertex has degree >= local_threshold(t),
    a witness is guaranteed.
    """
    for v in vertices:
        j = forced_star_color(neighbor_colors(v, edge_coloring), t)
        if j is not None:
            return (v, j)
    return None


def complete_graph_threshold(t: Sequence[int]) -> int:
    """The exact K_N threshold sum_j (t_j - 1) + 2 (Theorem 4.4)."""
    return sum(max(tj - 1, 0) for tj in t) + 2


def complete_graph_edges(n: int) -> List[Edge]:
    """Edge list of K_n on vertices {0, ..., n-1}."""
    return [(a, b) for a in range(n) for b in range(a + 1, n)]


# ---------------------------------------------------------------------------
# Star / matching bridge (Theorem 5.2)
# ---------------------------------------------------------------------------

def matching_pigeonhole_color(colors: Sequence[int], q: int) -> Tuple[int, int]:
    """Theorem 5.1: a color i with q * #class_i >= #M.

    Returns (i, size_of_class_i) for the largest color class.
    """
    counts = color_class_counts(colors, q)
    i = max(range(q), key=lambda k: counts[k])
    return i, counts[i]


def star_and_matching(
    colors: Sequence[int], t: Sequence[int]
) -> Tuple[Optional[int], Tuple[int, int]]:
    """Theorem 5.2: from one colored matching, extract both conclusions.

    Returns (star_color, (matching_color, class_size)).
    With #M >= local_threshold(t) the star color is guaranteed non-None.
    """
    q = len(t)
    star = forced_star_color(colors, t)
    match = matching_pigeonhole_color(colors, q)
    return star, match


# ---------------------------------------------------------------------------
# Exhaustive sharpness verification (Corollary 4.5)
# ---------------------------------------------------------------------------

def complete_graph_forces_star_for_all_colorings(n: int, t: Sequence[int]) -> bool:
    """Brute force: does EVERY q-coloring of K_n contain a monochromatic star?"""
    q = len(t)
    edges = complete_graph_edges(n)
    vertices = list(range(n))
    for assignment in product(range(q), repeat=len(edges)):
        coloring = {e: assignment[k] for k, e in enumerate(edges)}
        if find_mono_star(vertices, coloring, t) is None:
            return False
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_conservation_and_threshold() -> None:
    print("=" * 70)
    print("1. Conservation identity and the exact local threshold")
    print("=" * 70)
    q = 3
    t = [2, 3, 2]
    colors = [0, 1, 1, 2, 0, 1, 2, 0]  # an 8-element colored set
    print(f"  colors          = {colors}")
    print(f"  q               = {q}, targets t = {t}")
    print(f"  cc per color    = {color_class_counts(colors, q)}")
    print(f"  sum(cc) == #M ? = {conservation_holds(colors, q)}  "
          f"(sum={sum(color_class_counts(colors, q))}, #M={len(colors)})")
    print(f"  threshold sum_j(t_j-1)+1 = {local_threshold(t)}")
    j = forced_star_color(colors, t)
    print(f"  forced star color (cc_j >= t_j): {j}")
    print()


def demo_threshold_is_sharp() -> None:
    print("=" * 70)
    print("2. The threshold is sharp: one edge flips 'maybe' to 'guaranteed'")
    print("=" * 70)
    t = [2, 2]
    thr = local_threshold(t)
    print(f"  targets t = {t}, local threshold = {thr}")
    # At #M = threshold - 1 there is an evasive coloring.
    evasive = [0, 1]  # one of each color: no class reaches 2
    print(f"  #M = {len(evasive)} (= threshold-1): coloring {evasive} -> "
          f"forced star color = {forced_star_color(evasive, t)} (escape!)")
    # At #M = threshold every coloring is forced.
    print(f"  #M = {thr}: checking ALL 2-colorings are forced ...")
    all_forced = all(
        forced_star_color(list(a), t) is not None
        for a in product(range(2), repeat=thr)
    )
    print(f"    every coloring forces a star? {all_forced}")
    print()


def demo_complete_graph() -> None:
    print("=" * 70)
    print("3. Complete-graph threshold  N >= sum_j(t_j-1)+2  (and sharpness)")
    print("=" * 70)
    t = [2, 2]
    thr = complete_graph_threshold(t)
    print(f"  targets t = {t}: predicted K_N threshold N = {thr}")
    for n in range(3, 6):
        forced = complete_graph_forces_star_for_all_colorings(n, t)
        tag = ">= threshold" if n >= thr else "< threshold"
        print(f"    K_{n}: every coloring forces a star? {forced}  ({tag})")
    print()


def demo_bridge() -> None:
    print("=" * 70)
    print("4. Star/matching bridge: one hypothesis, two conclusions")
    print("=" * 70)
    t = [2, 3, 2]
    # A matching of 8 edges, colored; #M >= local_threshold(t).
    colors = [0, 1, 1, 2, 0, 1, 2, 0]
    star, (mi, msize) = star_and_matching(colors, t)
    q = len(t)
    print(f"  #M = {len(colors)} >= threshold {local_threshold(t)}")
    print(f"  STAR     reading: color {star} has cc >= t_{star} = {t[star]}")
    print(f"  MATCHING reading: color {mi} has sub-matching size {msize}, "
          f"q*size = {q*msize} >= #M = {len(colors)}")
    print()


def main() -> None:
    demo_conservation_and_threshold()
    demo_threshold_is_sharp()
    demo_complete_graph()
    demo_bridge()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
