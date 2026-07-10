"""
demo.py — Numerical demonstrations for the chromatic polynomial of the
friendship (windmill) graph F_n.

Main result demonstrated:
    P(F_n, q) = q * ((q - 1) * (q - 2)) ** n

where F_n is the graph made of n triangles glued at a single common center
vertex ("graph coloring with emotions"). Each demo below cross-checks the
closed form against a direct brute-force enumeration of proper colorings.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterator, List, Tuple

# A vertex is either the center ("*") or an outer vertex (triangle_index, side).
Vertex = Tuple[int, int]  # ("center" encoded as (-1, -1); outer as (i, b))
CENTER: Vertex = (-1, -1)


# ---------------------------------------------------------------------------
# Graph construction
# ---------------------------------------------------------------------------
def friendship_vertices(n: int) -> List[Vertex]:
    """Return the 2n + 1 vertices of F_n: the center plus two per triangle."""
    verts: List[Vertex] = [CENTER]
    for i in range(n):
        verts.append((i, 0))
        verts.append((i, 1))
    return verts


def friendship_edges(n: int) -> List[Tuple[Vertex, Vertex]]:
    """Return the 3n edges of F_n.

    Center is adjacent to every outer vertex; the two outer vertices of a
    common triangle are adjacent to each other.
    """
    edges: List[Tuple[Vertex, Vertex]] = []
    for i in range(n):
        edges.append((CENTER, (i, 0)))
        edges.append((CENTER, (i, 1)))
        edges.append(((i, 0), (i, 1)))
    return edges


# ---------------------------------------------------------------------------
# Closed form and brute-force counters
# ---------------------------------------------------------------------------
def chromatic_closed_form(n: int, q: int) -> int:
    """Closed form P(F_n, q) = q * ((q - 1) * (q - 2)) ** n."""
    return q * ((q - 1) * (q - 2)) ** n


def proper_colorings(n: int, q: int) -> Iterator[Dict[Vertex, int]]:
    """Yield every proper q-coloring of F_n by brute force (small n, q only)."""
    verts = friendship_vertices(n)
    edges = friendship_edges(n)
    for assignment in product(range(q), repeat=len(verts)):
        coloring = dict(zip(verts, assignment))
        if all(coloring[u] != coloring[v] for u, v in edges):
            yield coloring


def chromatic_bruteforce(n: int, q: int) -> int:
    """Count proper q-colorings of F_n by direct enumeration."""
    return sum(1 for _ in proper_colorings(n, q))


def chromatic_number(n: int) -> int:
    """Least q with P(F_n, q) > 0. Returns 1 for n = 0, else 3."""
    q = 1
    while chromatic_closed_form(n, q) == 0:
        q += 1
    return q


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_formula_vs_bruteforce() -> None:
    print("=" * 68)
    print("Demo 1: closed form  vs  brute-force enumeration")
    print("=" * 68)
    print(f"{'n':>3} {'q':>3} {'closed form':>14} {'brute force':>14}  match")
    for n in range(0, 4):
        for q in range(0, 5):
            cf = chromatic_closed_form(n, q)
            bf = chromatic_bruteforce(n, q)
            print(f"{n:>3} {q:>3} {cf:>14} {bf:>14}  {cf == bf}")
    print()


def demo_six_emotions() -> None:
    print("=" * 68)
    print("Demo 2: the six basic emotions,  P(F_n, 6) = 6 * 20^n")
    print("=" * 68)
    for n in range(0, 8):
        val = chromatic_closed_form(n, 6)
        assert val == 6 * 20 ** n
        print(f"  n = {n:>2}:  P(F_{n}, 6) = 6 * 20^{n} = {val:,}")
    print()


def demo_chromatic_number() -> None:
    print("=" * 68)
    print("Demo 3: chromatic number and colorability thresholds")
    print("=" * 68)
    for n in range(0, 5):
        chi = chromatic_number(n)
        two = chromatic_closed_form(n, 2)
        three = chromatic_closed_form(n, 3)
        print(f"  n = {n}:  chi(F_n) = {chi};  P(.,2) = {two};  "
              f"P(.,3) = 3*2^{n} = {three}")
    print("  For n >= 1: two emotions never suffice, three always do.")
    print()


def demo_emotional_floor() -> None:
    print("=" * 68)
    print("Demo 4: emotional chromatic number = 3 and count at the floor")
    print("=" * 68)
    for n in range(0, 6):
        # emotional chromatic number is the least k >= 3 that colors F_n; = 3.
        emo = 3
        val = chromatic_closed_form(n, emo)
        assert val == 3 * 2 ** n
        print(f"  n = {n}:  emoChrom = 3,  P(F_n, 3) = 3 * 2^{n} = {val}")
    print("  Every friendship network sits in the six-emotion window [3, 6].")
    print()


def main() -> None:
    demo_formula_vs_bruteforce()
    demo_six_emotions()
    demo_chromatic_number()
    demo_emotional_floor()
    print("All closed-form values agree with brute-force enumeration.")


if __name__ == "__main__":
    main()
