"""Numerical demonstrations for long nontrivial cycles in Hamiltonian graphs.

This self-contained script illustrates the main results of the accompanying paper
for Hamiltonian graphs whose vertices are the cyclic group Z_n = {0, ..., n-1}
containing the standard cyclic frame  0 ~ 1 ~ ... ~ (n-1) ~ 0.

Results demonstrated:
  1. Arc-cycle construction: each chord {a, b} yields a cycle of length
     ((b - a) mod n) + 1, strictly between 3 and n.
  2. Complementary-arc identity: the two arc cycles of a chord have lengths
     summing to n + 2, so the longer is at least n // 2 + 1.
  3. Vertex-uniformity: minimum degree three forces a chord (hence a long second
     cycle) at every vertex.
  4. Tightness: a single half-spanning chord yields exactly two cycles of
     length n // 2 + 1.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Dict, List, Set, Tuple


# ---------------------------------------------------------------------------
# Core graph representation
# ---------------------------------------------------------------------------

def frame_neighbors(n: int, v: int) -> Tuple[int, int]:
    """Return the two cyclic (frame) neighbours of vertex v in Z_n."""
    return ((v + 1) % n, (v - 1) % n)


def is_frame_adjacent(n: int, a: int, b: int) -> bool:
    """True iff a and b are cyclically consecutive in Z_n."""
    return b == (a + 1) % n or a == (b + 1) % n


def build_graph(n: int, chords: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    """Build an undirected graph on Z_n containing the frame plus given chords."""
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for v in range(n):
        adj[v].add((v + 1) % n)
        adj[(v + 1) % n].add(v)
    for a, b in chords:
        adj[a % n].add(b % n)
        adj[b % n].add(a % n)
    return adj


def forward_span(n: int, a: int, b: int) -> int:
    """Number of forward frame steps from a to b, i.e. (b - a) mod n."""
    return (b - a) % n


# ---------------------------------------------------------------------------
# Arc-cycle construction (Theorem 3.1 / Lemma 3.0)
# ---------------------------------------------------------------------------

def arc_cycle(n: int, a: int, k: int) -> List[int]:
    """The arc cycle: walk a, a+1, ..., a+k along the frame, then close to a.

    Returns the list of vertices [a, a+1, ..., a+k]; the closing edge (a+k)~a is
    the chord. The cycle length is k + 1 = len(list).
    """
    return [(a + j) % n for j in range(k + 1)]


def chord_arc_cycle(n: int, a: int, b: int) -> List[int]:
    """The arc cycle determined by the chord {a, b}, anchored at a."""
    k = forward_span(n, a, b)
    return arc_cycle(n, a, k)


def is_valid_cycle(adj: Dict[int, Set[int]], cycle: List[int]) -> bool:
    """Check that `cycle` is a genuine cycle: distinct vertices, length >= 3,
    and consecutive (cyclically) vertices adjacent in the graph."""
    if len(cycle) < 3:
        return False
    if len(set(cycle)) != len(cycle):
        return False
    m = len(cycle)
    return all(cycle[(i + 1) % m] in adj[cycle[i]] for i in range(m))


# ---------------------------------------------------------------------------
# Degree three forces a chord (Lemma 4.1) and long second cycle (Theorem 4.2)
# ---------------------------------------------------------------------------

def find_chord_at(n: int, adj: Dict[int, Set[int]], v: int) -> Tuple[int, int] | None:
    """Return a chord {v, w} incident to v, or None if v has no chord."""
    fn = frame_neighbors(n, v)
    for w in adj[v]:
        if w not in fn and w != v:
            return (v, w)
    return None


def long_second_cycle(n: int, adj: Dict[int, Set[int]]) -> List[int]:
    """Return a second cycle of length >= n // 2 + 1 (min degree three assumed)."""
    for v in range(n):
        chord = find_chord_at(n, adj, v)
        if chord is not None:
            a, b = chord
            forward = chord_arc_cycle(n, a, b)
            backward = chord_arc_cycle(n, b, a)
            return forward if len(forward) >= len(backward) else backward
    raise ValueError("no chord found: minimum degree three is required")


def every_vertex_second_cycle(n: int, adj: Dict[int, Set[int]]) -> Dict[int, List[int]]:
    """For each vertex, a second cycle through it (min degree three assumed)."""
    result: Dict[int, List[int]] = {}
    for v in range(n):
        chord = find_chord_at(n, adj, v)
        if chord is None:
            raise ValueError(f"vertex {v} has no chord")
        a, b = chord
        result[v] = chord_arc_cycle(n, a, b)
    return result


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_arc_cycle() -> None:
    print("=" * 70)
    print("DEMO 1: Arc-cycle construction from a single chord")
    print("=" * 70)
    n = 12
    a, b = 2, 9
    adj = build_graph(n, [(a, b)])
    cyc = chord_arc_cycle(n, a, b)
    print(f"n = {n}, chord {{{a}, {b}}}, forward span = {forward_span(n, a, b)}")
    print(f"arc cycle: {cyc}   (length {len(cyc)})")
    print(f"valid cycle? {is_valid_cycle(adj, cyc)}")
    print(f"length strictly between 3 and n? {3 <= len(cyc) < n}")
    print()


def demo_complementary_arcs() -> None:
    print("=" * 70)
    print("DEMO 2: Complementary-arc identity  L_fwd + L_bwd = n + 2")
    print("=" * 70)
    n = 15
    for a, b in [(0, 5), (0, 7), (3, 4 + 3)]:
        if is_frame_adjacent(n, a, b):
            continue
        fwd = chord_arc_cycle(n, a, b)
        bwd = chord_arc_cycle(n, b, a)
        print(f"chord {{{a}, {b}}}: L_fwd = {len(fwd)}, L_bwd = {len(bwd)}, "
              f"sum = {len(fwd) + len(bwd)} (n + 2 = {n + 2})")
        print(f"   longer arc has length {max(len(fwd), len(bwd))} "
              f">= n//2 + 1 = {n // 2 + 1}? "
              f"{max(len(fwd), len(bwd)) >= n // 2 + 1}")
    print()


def demo_min_degree_three() -> None:
    print("=" * 70)
    print("DEMO 3: Minimum degree three forces a long second cycle")
    print("=" * 70)
    n = 10
    # Add one chord per vertex so every vertex has degree >= 3.
    chords = [(v, (v + 3) % n) for v in range(n)]
    adj = build_graph(n, chords)
    degrees = {v: len(adj[v]) for v in range(n)}
    print(f"n = {n}, minimum degree = {min(degrees.values())}")
    cyc = long_second_cycle(n, adj)
    print(f"long second cycle: {cyc}  (length {len(cyc)})")
    print(f"length >= n//2 + 1 = {n // 2 + 1}? {len(cyc) >= n // 2 + 1}")
    print(f"valid and shorter than frame? "
          f"{is_valid_cycle(adj, cyc) and len(cyc) < n}")
    print()


def demo_vertex_uniform() -> None:
    print("=" * 70)
    print("DEMO 4: Every vertex lies on a second cycle")
    print("=" * 70)
    n = 9
    chords = [(v, (v + 4) % n) for v in range(n)]
    adj = build_graph(n, chords)
    per_vertex = every_vertex_second_cycle(n, adj)
    for v in range(n):
        cyc = per_vertex[v]
        ok = is_valid_cycle(adj, cyc) and v in cyc and 3 <= len(cyc) < n
        print(f"vertex {v}: cycle length {len(cyc)}, contains {v}? "
              f"{v in cyc}, valid second cycle? {ok}")
    print()


def demo_tightness() -> None:
    print("=" * 70)
    print("DEMO 5: Tightness -- a single half-spanning chord gives exactly n//2+1")
    print("=" * 70)
    n = 12
    a, b = 0, n // 2
    adj = build_graph(n, [(a, b)])
    fwd = chord_arc_cycle(n, a, b)
    bwd = chord_arc_cycle(n, b, a)
    print(f"n = {n}, half-spanning chord {{{a}, {b}}}")
    print(f"both arcs have length {len(fwd)} = {len(bwd)} = n//2 + 1 = {n // 2 + 1}")
    print("no distinct cycle longer than n//2 + 1 exists from a single chord.")
    print()


def main() -> None:
    demo_arc_cycle()
    demo_complementary_arcs()
    demo_min_degree_three()
    demo_vertex_uniform()
    demo_tightness()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
