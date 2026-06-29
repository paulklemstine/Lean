"""
Wall-Menger Separator Optimality -- Numerical demonstrations.

This self-contained script demonstrates, on the (m+1) x (n+1) grid graph
(the Cartesian/box product of two path graphs), the main results of the
accompanying paper:

  * Every column is an A-B separator (left column -> right column), and a
    column has exactly m+1 vertices.
  * The m+1 rows are pairwise vertex-disjoint left-to-right paths.
  * The minimum A-B vertex separator equals the maximum number of disjoint
    A-B paths equals m+1 (the HEIGHT), independent of the width n+1.

We verify these facts independently of the theory by:
  - a brute-force minimum vertex cut between the left and right columns
    (via a max-flow / vertex-splitting reduction), and
  - the discrete intermediate value theorem along a walk.

All functions are inlined; only the Python standard library is used.
"""

from __future__ import annotations

from collections import deque
from typing import Dict, List, Set, Tuple

Vertex = Tuple[int, int]  # (row, col)


# ---------------------------------------------------------------------------
# Grid construction
# ---------------------------------------------------------------------------
def grid_vertices(m: int, n: int) -> List[Vertex]:
    """All vertices of the (m+1) x (n+1) grid: rows 0..m, columns 0..n."""
    return [(i, j) for i in range(m + 1) for j in range(n + 1)]


def grid_neighbors(v: Vertex, m: int, n: int) -> List[Vertex]:
    """Orthogonal (box-product) neighbors of v inside the grid."""
    i, j = v
    out: List[Vertex] = []
    for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        ni, nj = i + di, j + dj
        if 0 <= ni <= m and 0 <= nj <= n:
            out.append((ni, nj))
    return out


def left_col(m: int, n: int) -> List[Vertex]:
    """Region A: the leftmost column {x : col(x) = 0}."""
    return [(i, 0) for i in range(m + 1)]


def right_col(m: int, n: int) -> List[Vertex]:
    """Region B: the rightmost column {x : col(x) = n}."""
    return [(i, n) for i in range(m + 1)]


# ---------------------------------------------------------------------------
# Constructive optimal objects (from the theory)
# ---------------------------------------------------------------------------
def column_separator(m: int, n: int, c: int) -> List[Vertex]:
    """The c-th column: a minimum A-B separator of size m+1 (0 <= c <= n)."""
    assert 0 <= c <= n
    return [(i, c) for i in range(m + 1)]


def row_paths(m: int, n: int) -> List[List[Vertex]]:
    """The m+1 pairwise vertex-disjoint left-to-right row paths."""
    return [[(i, j) for j in range(n + 1)] for i in range(m + 1)]


# ---------------------------------------------------------------------------
# Discrete intermediate value theorem along a walk
# ---------------------------------------------------------------------------
def discrete_ivt_witness(
    walk: List[Vertex], label, c: int
) -> Vertex:
    """
    Given a walk (list of vertices) and a label function changing by at most 1
    per step, with label(start) <= c <= label(end), return the first vertex on
    the walk whose label equals c. (walk_exists_mem_support_of_le)
    """
    for v in walk:
        if label(v) == c:
            return v
    raise ValueError("no vertex with the requested label -- hypotheses violated")


# ---------------------------------------------------------------------------
# Brute-force ground truth: minimum vertex cut via max-flow
# ---------------------------------------------------------------------------
def min_vertex_cut_lr(m: int, n: int) -> int:
    """
    Compute the minimum number of vertices whose removal disconnects the left
    column from the right column, via vertex-splitting + integer max-flow
    (Edmonds-Karp). This is the ground-truth min A-B separator size.
    """
    # Vertex splitting: each grid vertex v becomes v_in -> v_out (capacity 1),
    # except super-source S and super-sink T which connect with infinite cap.
    INF = 10 ** 9
    cap: Dict[Tuple, int] = {}
    adj: Dict[object, Set[object]] = {}

    def add_edge(u: object, w: object, c: int) -> None:
        adj.setdefault(u, set()).add(w)
        adj.setdefault(w, set()).add(u)
        cap[(u, w)] = cap.get((u, w), 0) + c
        cap.setdefault((w, u), 0)

    for v in grid_vertices(m, n):
        add_edge((v, "in"), (v, "out"), 1)
    for v in grid_vertices(m, n):
        for w in grid_neighbors(v, m, n):
            add_edge((v, "out"), (w, "in"), INF)

    S, T = "S", "T"
    for v in left_col(m, n):
        add_edge(S, (v, "in"), INF)
    for v in right_col(m, n):
        add_edge((v, "out"), T, INF)

    # Edmonds-Karp
    flow = 0
    while True:
        parent: Dict[object, object] = {S: S}
        q: deque = deque([S])
        while q:
            u = q.popleft()
            if u == T:
                break
            for w in adj.get(u, ()):
                if w not in parent and cap.get((u, w), 0) > 0:
                    parent[w] = u
                    q.append(w)
        if T not in parent:
            break
        # bottleneck
        bottleneck = INF
        v = T
        while v != S:
            u = parent[v]
            bottleneck = min(bottleneck, cap[(u, v)])
            v = u
        v = T
        while v != S:
            u = parent[v]
            cap[(u, v)] -= bottleneck
            cap[(v, u)] += bottleneck
            v = u
        flow += bottleneck
    return flow


# ---------------------------------------------------------------------------
# Verification helpers
# ---------------------------------------------------------------------------
def is_separator(sep: Set[Vertex], m: int, n: int) -> bool:
    """Check S meets every A-B path: BFS from A avoiding S must not reach B."""
    A = [v for v in left_col(m, n) if v not in sep]
    B = set(right_col(m, n))
    seen: Set[Vertex] = set(A)
    q: deque = deque(A)
    while q:
        u = q.popleft()
        if u in B:
            return False
        for w in grid_neighbors(u, m, n):
            if w not in seen and w not in sep:
                seen.add(w)
                q.append(w)
    return True


def paths_vertex_disjoint(paths: List[List[Vertex]]) -> bool:
    """Check pairwise vertex-disjointness of a family of paths."""
    seen: Set[Vertex] = set()
    for p in paths:
        for v in p:
            if v in seen:
                return False
            seen.add(v)
    return True


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------
def demo(m: int, n: int) -> None:
    print(f"=== Grid {(m + 1)} x {(n + 1)}  (height = {m + 1}, width = {n + 1}) ===")

    # 1. Column separator
    sep = set(column_separator(m, n, c=min(1, n)))
    print(f"  column separator size           : {len(sep)}  (expected {m + 1})")
    print(f"  column is a valid A-B separator : {is_separator(sep, m, n)}")

    # 2. Row paths
    rows = row_paths(m, n)
    print(f"  number of row paths             : {len(rows)}  (expected {m + 1})")
    print(f"  rows pairwise vertex-disjoint   : {paths_vertex_disjoint(rows)}")

    # 3. Discrete IVT: every row walk passes through column c
    c = min(1, n)
    witness = discrete_ivt_witness(rows[0], label=lambda v: v[1], c=c)
    print(f"  IVT witness in column {c} on row 0  : {witness}")

    # 4. Ground-truth min cut via max-flow
    cut = min_vertex_cut_lr(m, n)
    print(f"  brute-force min vertex cut      : {cut}  (expected {m + 1})")
    assert cut == m + 1, "min-cut should equal the height m+1"
    print(f"  --> min-cut = max-disjoint-paths = {m + 1}  (width-independent)\n")


def main() -> None:
    print("Wall-Menger Separator Optimality -- numerical verification\n")
    # Width-independence: fix height, vary width.
    for n in (2, 4, 8, 16):
        demo(m=3, n=n)  # height 4 throughout
    # Vary height too.
    for m in (0, 1, 2, 5):
        demo(m=m, n=5)


if __name__ == "__main__":
    main()
