"""
Numerical demonstrations for:

    Zero-Knowledge Proofs in Lean: Verifiable Computation
    GMW 3-colouring protocol + PCP-style constant-query local verifier

Every result demonstrated here mirrors a formally verified theorem:

  * completeness                     -> permutations preserve proper colourings
  * soundness_prob / pcp_soundness_gap -> rejection probability >= 1/|E|
  * hvzk_bijection                   -> pi |-> (pi(a), pi(b)) is a bijection S_3 -> distinct pairs
                                        => real view == uniform over distinct pairs
  * query_count_le_two               -> the local verifier reads <= 2 proof symbols
  * pcp_accepts_all_iff_proper       -> local checks over all edges == global properness

Self-contained: standard library only. Run with `python demo.py`.
"""

from __future__ import annotations

from itertools import permutations
from typing import Dict, List, Set, Tuple

# A colouring assigns each vertex (an int) one of three colours {0, 1, 2}.
Colour = int
Vertex = int
Edge = Tuple[Vertex, Vertex]
Colouring = Dict[Vertex, Colour]
Permutation = Tuple[int, int, int]  # pi where pi[i] is the image of colour i


# ---------------------------------------------------------------------------
# Core definitions (mirrors IsProperColoring, pcpVerifier, queryPositions)
# ---------------------------------------------------------------------------

def is_proper_colouring(edges: List[Edge], c: Colouring) -> bool:
    """True iff every edge has differently-coloured endpoints (Definition 2.1)."""
    return all(c[u] != c[v] for (u, v) in edges)


def pcp_verifier(c: Colouring, e: Edge) -> bool:
    """Single-round local accept predicate: endpoints differ (Definition 5.1)."""
    u, v = e
    return c[u] != c[v]


def query_positions(e: Edge) -> Set[Vertex]:
    """The proof positions read on challenge e (Definition 5.2)."""
    return {e[0], e[1]}


def recolour(c: Colouring, pi: Permutation) -> Colouring:
    """Apply a colour permutation pi to a colouring: v |-> pi(c(v))."""
    return {v: pi[col] for v, col in c.items()}


def all_perms_S3() -> List[Permutation]:
    """The six elements of S_3 as image-tuples."""
    return list(permutations((0, 1, 2)))


def catching_edges(edges: List[Edge], c: Colouring) -> List[Edge]:
    """Edges that 'catch' the prover: monochromatic endpoints (Catch(E, c))."""
    return [(u, v) for (u, v) in edges if c[u] == c[v]]


# ---------------------------------------------------------------------------
# Demo 1: Completeness -- permutations preserve properness
# ---------------------------------------------------------------------------

def demo_completeness() -> None:
    print("=" * 70)
    print("DEMO 1  Completeness: colour permutations preserve properness")
    print("=" * 70)
    # A 4-cycle C4: vertices 0-1-2-3-0, which IS 3-colourable (even bipartite).
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 0)]
    c: Colouring = {0: 0, 1: 1, 2: 0, 3: 1}
    assert is_proper_colouring(edges, c)
    print(f"Base proper colouring of C4: {c}")
    all_proper = True
    for pi in all_perms_S3():
        cpi = recolour(c, pi)
        proper = is_proper_colouring(edges, cpi)
        all_proper &= proper
        print(f"  pi = {pi}:  recoloured = {cpi}   proper? {proper}")
    print(f"\n=> All 6 permutations preserve properness: {all_proper}")
    print("   (Theorem 'completeness': honest prover always accepted.)\n")


# ---------------------------------------------------------------------------
# Demo 2: Soundness gap -- a non-3-colourable graph rejects every proof
# ---------------------------------------------------------------------------

def demo_soundness_gap() -> None:
    print("=" * 70)
    print("DEMO 2  Soundness gap: K4 is NOT 3-colourable; gap >= 1/|E|")
    print("=" * 70)
    # K4: complete graph on 4 vertices. Chromatic number 4 > 3 => not 3-colourable.
    verts = [0, 1, 2, 3]
    edges: List[Edge] = [(u, v) for u in verts for v in verts if u < v]
    m = len(edges)
    print(f"K4 has |E| = {m} edges.  Theoretical soundness gap >= 1/|E| = {1/m:.4f}")

    # Brute force over ALL 3^4 = 81 colourings: each has >= 1 catching edge,
    # and the empirical minimum catching fraction matches the 1/|E| bound.
    min_fraction = 1.0
    any_proper = False
    total = 0
    for code in range(3 ** len(verts)):
        c = {}
        x = code
        for v in verts:
            c[v] = x % 3
            x //= 3
        total += 1
        if is_proper_colouring(edges, c):
            any_proper = True
        catches = catching_edges(edges, c)
        frac = len(catches) / m
        min_fraction = min(min_fraction, frac)
    print(f"Enumerated {total} colourings.  Any proper colouring found? {any_proper}")
    print(f"Minimum catching fraction over all proofs: {min_fraction:.4f}")
    print(f"Lower bound 1/|E|:                          {1/m:.4f}")
    print(f"=> Every proof is rejected with prob >= 1/|E|: {min_fraction >= 1/m}")
    print("   (Theorems 'soundness_prob' / 'pcp_soundness_gap'.)\n")


# ---------------------------------------------------------------------------
# Demo 3: Perfect HVZK -- pi |-> (pi(a), pi(b)) is a bijection S_3 -> distinct pairs
# ---------------------------------------------------------------------------

def distinct_pairs() -> List[Tuple[Colour, Colour]]:
    return [(x, y) for x in range(3) for y in range(3) if x != y]


def demo_hvzk_bijection() -> None:
    print("=" * 70)
    print("DEMO 3  Perfect HVZK: real view == uniform over distinct pairs")
    print("=" * 70)
    dps = distinct_pairs()
    print(f"|S_3| = {len(all_perms_S3())}   |DistinctPairs| = {len(dps)}   (both 6)")
    for (a, b) in dps:  # for every possible true endpoint colour pair a != b
        images = [(pi[a], pi[b]) for pi in all_perms_S3()]
        is_bijection = sorted(images) == sorted(dps)
        print(f"  true colours (a,b)=({a},{b}): view map onto distinct pairs? "
              f"bijection={is_bijection}")
    print("\nDistribution of the real view for a FIXED true pair (a,b)=(0,1):")
    counts: Dict[Tuple[int, int], int] = {p: 0 for p in dps}
    for pi in all_perms_S3():
        counts[(pi[0], pi[1])] += 1
    for p in dps:
        print(f"  view {p}: probability {counts[p]}/6 = {counts[p]/6:.4f}")
    print("=> Each distinct pair has probability exactly 1/6, independent of (a,b).")
    print("   A simulator outputting a uniform distinct pair reproduces the view")
    print("   PERFECTLY without the colouring. (Theorem 'hvzk_bijection'.)\n")


# ---------------------------------------------------------------------------
# Demo 4: Constant query complexity + local==global bridge
# ---------------------------------------------------------------------------

def demo_pcp_local_verifier() -> None:
    print("=" * 70)
    print("DEMO 4  PCP-style local verifier: <= 2 queries; local == global")
    print("=" * 70)
    # A larger graph: a path on 8 vertices (3-colourable).
    edges: List[Edge] = [(i, i + 1) for i in range(7)]
    print(f"Path graph on 8 vertices, |E| = {len(edges)}.")
    max_q = max(len(query_positions(e)) for e in edges)
    print(f"Maximum query positions read on any challenge: {max_q} (<= 2). "
          f"(Theorem 'query_count_le_two')")

    c: Colouring = {i: i % 2 for i in range(8)}  # 2-colouring is also a 3-colouring
    accepts_all = all(pcp_verifier(c, e) for e in edges)
    proper = is_proper_colouring(edges, c)
    print(f"Verifier accepts on EVERY edge: {accepts_all}")
    print(f"Colouring is globally proper:   {proper}")
    print(f"=> local-checks-on-all-edges  <=>  global properness: "
          f"{accepts_all == proper}")
    print("   (Theorem 'pcp_accepts_all_iff_proper'.)\n")


# ---------------------------------------------------------------------------
# Demo 5: Amplification -- repetition crushes the cheating probability
# ---------------------------------------------------------------------------

def demo_amplification() -> None:
    print("=" * 70)
    print("DEMO 5  Soundness amplification by independent repetition")
    print("=" * 70)
    m = 6  # |E| for K4
    gap = 1 / m
    print(f"Single-round rejection >= {gap:.4f}; survival <= {1-gap:.4f} per round.")
    target = 1e-6
    rounds = 1
    while (1 - gap) ** rounds > target:
        rounds += 1
    for r in (1, 5, 10, 25, 50, rounds):
        print(f"  m = {r:3d} rounds: cheating probability <= {(1-gap)**r:.3e}")
    print(f"=> {rounds} rounds suffice to push cheating probability below {target}.")
    print("   (Future Direction 2; built on the formal 1/|E| gap.)\n")


def main() -> None:
    demo_completeness()
    demo_soundness_gap()
    demo_hvzk_bijection()
    demo_pcp_local_verifier()
    demo_amplification()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
