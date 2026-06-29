"""
Geodesics in the Markov Graph of the 2x2x2 No-Three-Way Interaction Model
=========================================================================

This self-contained script demonstrates, numerically, the main theorem:

    For two nonnegative 2x2x2 integer tables u, v with the SAME two-way margins,
    the graph distance between them in the Markov graph of their fiber is EXACTLY

        | v(0,0,0) - u(0,0,0) |

    the absolute difference of their corner cells. The distance is realized by an
    explicit nonnegative walk that adds/subtracts the single checkerboard move M3
    one unit at a time, and no walk is shorter.

A 2x2x2 table is represented as a dict mapping (i, j, k) -> count, with i,j,k in
{0,1}. The corner cell is (0,0,0).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]

CELLS: List[Cell] = list(product((0, 1), repeat=3))
CORNER: Cell = (0, 0, 0)


# ---------------------------------------------------------------------------
# Core definitions (inlined)
# ---------------------------------------------------------------------------
def m3(i: int, j: int, k: int) -> int:
    """The single checkerboard move M3(i,j,k) = (-1)^(i+j+k). M3(0,0,0) = +1."""
    return 1 if (i + j + k) % 2 == 0 else -1


def add_smul(u: Table, t: int) -> Table:
    """Return u + t * M3 cell-by-cell."""
    return {(i, j, k): u[(i, j, k)] + t * m3(i, j, k) for (i, j, k) in CELLS}


def is_nonneg(u: Table) -> bool:
    """True iff every cell count is >= 0."""
    return all(v >= 0 for v in u.values())


def two_way_margins(u: Table) -> Tuple[Tuple[int, ...], ...]:
    """The three families of 2x2 slice sums (sum out one index at a time)."""
    sum_k = tuple(u[(i, j, 0)] + u[(i, j, 1)] for i in (0, 1) for j in (0, 1))
    sum_j = tuple(u[(i, 0, k)] + u[(i, 1, k)] for i in (0, 1) for k in (0, 1))
    sum_i = tuple(u[(0, j, k)] + u[(1, j, k)] for j in (0, 1) for k in (0, 1))
    return (sum_k, sum_j, sum_i)


def same_margins(u: Table, v: Table) -> bool:
    """True iff u and v share all two-way margins (lie in the same fiber)."""
    return two_way_margins(u) == two_way_margins(v)


def corner_distance(u: Table, v: Table) -> int:
    """The closed-form geodesic distance: |v(0,0,0) - u(0,0,0)|."""
    return abs(v[CORNER] - u[CORNER])


# ---------------------------------------------------------------------------
# Algorithm: explicit geodesic construction (Lemma walk_add_smul)
# ---------------------------------------------------------------------------
def geodesic_walk(u: Table, v: Table) -> List[Table]:
    """
    Construct a shortest walk from u to v by adding/subtracting M3 one unit at a
    time. Requires same_margins(u, v) and both nonnegative. Returns the list of
    tables visited (length = distance + 1). Raises if any step leaves the
    nonnegative orthant (which the theorem guarantees never happens).
    """
    assert same_margins(u, v), "tables must share two-way margins"
    assert is_nonneg(u) and is_nonneg(v), "endpoints must be nonnegative"
    t: int = v[CORNER] - u[CORNER]
    step: int = 1 if t >= 0 else -1
    path: List[Table] = [dict(u)]
    cur: Table = dict(u)
    for _ in range(abs(t)):
        cur = add_smul(cur, step)
        assert is_nonneg(cur), "discrete convexity violated (should be impossible)"
        path.append(cur)
    assert cur == v, "walk did not reach v"
    return path


# ---------------------------------------------------------------------------
# Algorithm: fiber enumeration & diameter (Corollary 3.5)
# ---------------------------------------------------------------------------
def fiber(u: Table) -> List[Table]:
    """
    Enumerate the fiber of u: all nonnegative tables u + t*M3, t in Z. The
    admissible t form an integer interval (intersection of eight half-lines).
    Returned in order of increasing corner value.
    """
    # +1 cells force t >= -u[cell]; -1 cells force t <=  u[cell].
    lower = max(-u[c] for c in CELLS if m3(*c) == 1)
    upper = min(u[c] for c in CELLS if m3(*c) == -1)
    return [add_smul(u, t) for t in range(lower, upper + 1)]


def fiber_diameter(u: Table) -> int:
    """Graph diameter of the fiber containing u (= number of tables - 1)."""
    f = fiber(u)
    return corner_distance(f[0], f[-1])


# ---------------------------------------------------------------------------
# Brute-force verification of the geodesic distance (BFS on the Markov graph)
# ---------------------------------------------------------------------------
def bfs_distance(u: Table, v: Table) -> int:
    """
    Independent ground truth: breadth-first search over the Markov graph (edges
    = +/- M3 staying nonnegative). Used to confirm the closed-form theorem.
    """
    from collections import deque

    def key(t: Table) -> Tuple[int, ...]:
        return tuple(t[c] for c in CELLS)

    start, goal = key(u), key(v)
    seen = {start: 0}
    q: "deque[Table]" = deque([dict(u)])
    while q:
        cur = q.popleft()
        d = seen[key(cur)]
        if key(cur) == goal:
            return d
        for s in (1, -1):
            nxt = add_smul(cur, s)
            if is_nonneg(nxt) and key(nxt) not in seen:
                seen[key(nxt)] = d + 1
                q.append(nxt)
    raise ValueError("v not reachable from u (different fibers?)")


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def make_table(values: Dict[Cell, int]) -> Table:
    """Build a table from a full dict of the eight cells."""
    assert set(values.keys()) == set(CELLS)
    return dict(values)


def show(u: Table, label: str = "") -> None:
    """Pretty-print the cube as its two 2x2 slices k=0 and k=1."""
    if label:
        print(f"  {label}: corner = {u[CORNER]}")
    for k in (0, 1):
        row0 = f"[{u[(0,0,k)]:>2} {u[(0,1,k)]:>2}]"
        row1 = f"[{u[(1,0,k)]:>2} {u[(1,1,k)]:>2}]"
        print(f"    k={k}: {row0} {row1}")


def demo_main() -> None:
    print("=" * 72)
    print("DEMO 1: The corner cell is an exact ruler for graph distance")
    print("=" * 72)
    # even-parity cells (i+j+k even) gain under +M3; odd-parity cells lose.
    # To keep u + 3*M3 nonnegative we give the odd-parity cells >= 3.
    u = make_table(
        {
            (0, 0, 0): 2, (0, 1, 1): 2, (1, 0, 1): 2, (1, 1, 0): 2,   # even parity
            (0, 0, 1): 3, (0, 1, 0): 3, (1, 0, 0): 3, (1, 1, 1): 3,   # odd parity
        }
    )
    v = add_smul(u, 3)  # move corner from 2 to 5
    show(u, "u")
    show(v, "v = u + 3*M3")
    print(f"  same two-way margins?         {same_margins(u, v)}")
    print(f"  closed-form distance |dc|:    {corner_distance(u, v)}")
    print(f"  brute-force BFS distance:     {bfs_distance(u, v)}")
    assert corner_distance(u, v) == bfs_distance(u, v)
    print("  -> theorem confirmed: distance == |corner(v) - corner(u)|")

    print()
    print("=" * 72)
    print("DEMO 2: Explicit shortest walk (each step stays nonnegative)")
    print("=" * 72)
    path = geodesic_walk(u, v)
    print(f"  walk length = {len(path) - 1} edges")
    for n, t in enumerate(path):
        print(f"  step {n}: corner = {t[CORNER]}, nonneg = {is_nonneg(t)}")

    print()
    print("=" * 72)
    print("DEMO 3: Fibers are path graphs (intervals); diameter in closed form")
    print("=" * 72)
    f = fiber(u)
    corners = [t[CORNER] for t in f]
    print(f"  fiber size      = {len(f)} tables")
    print(f"  corner values   = {corners}  (a contiguous integer interval)")
    print(f"  fiber diameter  = {fiber_diameter(u)}")
    # confirm all members share margins and are pairwise at corner distance
    assert all(same_margins(u, t) for t in f)
    for a in f:
        for b in f:
            assert corner_distance(a, b) == bfs_distance(a, b)
    print("  -> every pair of tables in the fiber: BFS distance == corner distance")

    print()
    print("=" * 72)
    print("DEMO 4: Lower bound is tight for many random fibers")
    print("=" * 72)
    import random

    random.seed(0)
    trials, ok = 0, 0
    for _ in range(2000):
        base = {c: random.randint(0, 6) for c in CELLS}
        u0 = make_table(base)
        members = fiber(u0)
        if len(members) < 2:
            continue
        a, b = random.sample(members, 2)
        trials += 1
        if corner_distance(a, b) == bfs_distance(a, b):
            ok += 1
    print(f"  random fiber pairs tested: {trials}")
    print(f"  closed form == BFS:        {ok}/{trials}")
    assert ok == trials
    print("  -> theorem holds on every random instance")


if __name__ == "__main__":
    demo_main()
    print("\nAll demonstrations passed: the corner cell is a graph isometry.")
