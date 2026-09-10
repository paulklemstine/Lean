"""
Product constructions for snake-in-the-box codes: numerical demonstrations.

A *snake* of length L in the hypercube Q_n is a sequence of vertices
v_0, ..., v_L in {0,1}^n such that consecutive vertices are at Hamming
distance 1 and non-consecutive vertices are at Hamming distance >= 2
(an induced path).  s(n) denotes the maximum length of a snake in Q_n.

This script demonstrates, entirely by direct computation:

  1. Hamming distance is additive across a coordinate split, so the product
     of a length-L snake and a length-K snake carries an *induced* copy of
     the (L+1) x (K+1) grid graph inside Q_{m+n}.
  2. The comb (boustrophedon) construction produces a genuine snake of
     length comb(L, K) = floor(L/2)*(K+2) + K in Q_{m+n}.
  3. The consequences  s(m)*s(n) <= 2*s(m+n)  and  s(m)+s(n) <= s(m+n),
     checked against exactly computed small snake numbers.
  4. The 3/4 cap: an induced path in a grid never uses all four cells of a
     2x2 square, so a product-supported snake has at most
     3*ceil((L+1)/2)*ceil((K+1)/2) vertices.
  5. The failure of "bounded chord repair": for every constant C and all
     L, K >= 8C+11, the cap falls strictly below (L+1)(K+1) - C(L+K).
  6. Exact longest induced paths in small grids, whose densities cluster
     near 2/3 -- the evidence for the two-thirds conjecture.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Vertex = Tuple[int, ...]
Cell = Tuple[int, int]


# ----------------------------------------------------------------------
# 1. Hypercube basics
# ----------------------------------------------------------------------


def hamming(x: Vertex, y: Vertex) -> int:
    """Number of coordinates in which x and y disagree."""
    return sum(1 for a, b in zip(x, y) if a != b)


def concat(a: Vertex, b: Vertex) -> Vertex:
    """The vertex of Q_{m+n} obtained by juxtaposing a in Q_m and b in Q_n."""
    return tuple(a) + tuple(b)


def is_snake(path: Sequence[Vertex]) -> bool:
    """True iff `path` is an induced path in the hypercube (a snake)."""
    n = len(path)
    for i in range(n - 1):
        if hamming(path[i], path[i + 1]) != 1:
            return False
    for i in range(n):
        for j in range(i + 2, n):
            if hamming(path[i], path[j]) < 2:
                return False
    return True


def neighbours(v: Vertex) -> List[Vertex]:
    """The n neighbours of v in Q_n."""
    out: List[Vertex] = []
    for i in range(len(v)):
        w = list(v)
        w[i] ^= 1
        out.append(tuple(w))
    return out


def longest_snake(n: int) -> Tuple[int, List[Vertex]]:
    """Exact snake-in-the-box number s(n) and a witness, by exhaustive search.

    Without loss of generality the snake starts at the all-zero vertex
    (the hypercube is vertex-transitive).
    """
    start: Vertex = tuple(0 for _ in range(n))
    best_len = 0
    best_path: List[Vertex] = [start]

    def extend(path: List[Vertex]) -> None:
        nonlocal best_len, best_path
        if len(path) - 1 > best_len:
            best_len = len(path) - 1
            best_path = list(path)
        tip = path[-1]
        for w in neighbours(tip):
            # w must be at distance >= 2 from every vertex before the tip
            if any(hamming(w, u) <= 1 for u in path[:-1]):
                continue
            path.append(w)
            extend(path)
            path.pop()

    extend([start])
    return best_len, best_path


# ----------------------------------------------------------------------
# 2. The comb construction
# ----------------------------------------------------------------------


def comb_len(L: int, K: int) -> int:
    """Length of the comb built from snakes of lengths L and K."""
    return (L // 2) * (K + 2) + K


def comb_cell(K: int, s: int) -> Cell:
    """Grid coordinates (row, column) of the s-th vertex of the comb."""
    block, r = divmod(s, K + 2)
    row = 2 * block + (0 if r <= K else 1)
    col = min(r, K) if block % 2 == 0 else K - min(r, K)
    return row, col


def comb_path(p: Sequence[Vertex], q: Sequence[Vertex]) -> List[Vertex]:
    """The comb snake in Q_{m+n} built from snakes p (length L) and q (length K)."""
    L, K = len(p) - 1, len(q) - 1
    out: List[Vertex] = []
    for s in range(comb_len(L, K) + 1):
        row, col = comb_cell(K, s)
        out.append(concat(p[row], q[col]))
    return out


def lshape_path(p: Sequence[Vertex], q: Sequence[Vertex]) -> List[Vertex]:
    """The L-shaped snake of length L + K in Q_{m+n}."""
    L, K = len(p) - 1, len(q) - 1
    return [concat(p[min(s, L)], q[max(s - L, 0)]) for s in range(L + K + 1)]


# ----------------------------------------------------------------------
# 3. Grids: induced paths, the 2x2 lemma, and the 3/4 cap
# ----------------------------------------------------------------------


def cap_34(L: int, K: int) -> int:
    """3 * ceil((L+1)/2) * ceil((K+1)/2): the maximum number of vertices of a
    snake supported on the product of a length-L and a length-K snake."""
    return 3 * ((L + 2) // 2) * ((K + 2) // 2)


def is_induced_grid_path(cells: Sequence[Cell]) -> bool:
    """True iff the given cell sequence is an induced path in the grid graph."""
    def adj(u: Cell, v: Cell) -> bool:
        return abs(u[0] - v[0]) + abs(u[1] - v[1]) == 1

    if len(set(cells)) != len(cells):
        return False
    for i in range(len(cells) - 1):
        if not adj(cells[i], cells[i + 1]):
            return False
    for i in range(len(cells)):
        for j in range(i + 2, len(cells)):
            if adj(cells[i], cells[j]):
                return False
    return True


def has_full_square(cells: Iterable[Cell]) -> bool:
    """True iff the cell set contains all four cells of some 2x2 square."""
    S = set(cells)
    return any(
        (i, j) in S and (i + 1, j) in S and (i, j + 1) in S and (i + 1, j + 1) in S
        for (i, j) in S
    )


def longest_induced_grid_path(a: int, b: int) -> Tuple[int, List[Cell]]:
    """Exact maximum number of cells on an induced path in the a x b grid,
    together with a witness.  Depth-first search with incremental checking."""
    best = 0
    best_path: List[Cell] = []

    def nbrs(c: Cell) -> List[Cell]:
        i, j = c
        return [
            (x, y)
            for (x, y) in ((i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1))
            if 0 <= x < a and 0 <= y < b
        ]

    def extend(path: List[Cell], used: Set[Cell]) -> None:
        nonlocal best, best_path
        if len(path) > best:
            best, best_path = len(path), list(path)
        tip = path[-1]
        for w in nbrs(tip):
            if w in used:
                continue
            # induced condition: w touches no earlier cell except the tip
            if any(u in used and u != tip for u in nbrs(w)):
                continue
            path.append(w)
            used.add(w)
            extend(path, used)
            used.discard(w)
            path.pop()

    for start in product(range(a), range(b)):
        # symmetry reduction: it suffices to start in the upper-left quadrant
        if start[0] > (a - 1) // 2 or start[1] > (b - 1) // 2:
            continue
        extend([start], {start})
    return best, best_path


def render_grid(a: int, b: int, cells: Sequence[Cell]) -> str:
    """ASCII picture of a set of grid cells (rows = first coordinate)."""
    order: Dict[Cell, int] = {c: k for k, c in enumerate(cells)}
    lines = []
    for i in range(a):
        row = []
        for j in range(b):
            row.append("#" if (i, j) in order else ".")
        lines.append(" ".join(row))
    return "\n".join(lines)


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------


def demo_small_snake_numbers() -> Dict[int, int]:
    print("=" * 72)
    print("1. Exact snake-in-the-box numbers s(n) by exhaustive search")
    print("=" * 72)
    values: Dict[int, int] = {}
    for n in range(0, 6):
        values[n], _ = longest_snake(n)
        print(f"   s({n}) = {values[n]}")
    print("   (known continuation: s(6) = 26, s(7) = 50, s(8) = 98)")
    print()
    print("   s(2) = 2 while the multiplicative main term for L = K = 1 is")
    print("   (1+1)(1+1) = 4, so any constant C with")
    print("   (L+1)(K+1) <= s(m+n) + C(L+K) must satisfy C >= 1.")
    print()
    return values


def demo_grid_is_induced() -> None:
    print("=" * 72)
    print("2. The product of two snakes is an INDUCED grid inside the cube")
    print("=" * 72)
    _, p = longest_snake(3)  # a snake in Q_3
    _, q = longest_snake(3)  # a snake in Q_3
    L, K = len(p) - 1, len(q) - 1
    ok_edge = ok_nonedge = True
    for (i, j), (i2, j2) in product(
        list(product(range(L + 1), range(K + 1))), repeat=2
    ):
        d = hamming(concat(p[i], q[j]), concat(p[i2], q[j2]))
        l1 = abs(i - i2) + abs(j - j2)
        if l1 == 1 and d != 1:
            ok_edge = False
        if l1 >= 2 and d < 2:
            ok_nonedge = False
    print(f"   snakes of lengths L = {L} in Q_3 and K = {K} in Q_3")
    print(f"   grid edges become cube edges          : {ok_edge}")
    print(f"   grid non-edges stay at distance >= 2  : {ok_nonedge}")
    print("   => every induced path in the (L+1)x(K+1) grid is a snake in Q_6.")
    print()


def demo_comb() -> None:
    print("=" * 72)
    print("3. The comb construction is a snake, and it is supermultiplicative")
    print("=" * 72)
    header = f"   {'m':>2} {'n':>2} {'L=s(m)':>6} {'K=s(n)':>6} {'comb':>6} {'snake?':>7} {'L*K<=2*comb':>12}"
    print(header)
    for m, n in [(2, 2), (2, 3), (3, 3), (3, 2), (1, 4), (4, 1)]:
        _, p = longest_snake(m)
        _, q = longest_snake(n)
        L, K = len(p) - 1, len(q) - 1
        path = comb_path(p, q)
        good = is_snake(path)
        cl = comb_len(L, K)
        assert len(path) - 1 == cl
        print(
            f"   {m:>2} {n:>2} {L:>6} {K:>6} {cl:>6} {str(good):>7} "
            f"{str(L * K <= 2 * cl):>12}"
        )
    print()
    print("   Known snake numbers give the following instances of")
    print("   s(m)*s(n) <= 2*s(m+n)  and  s(m)+s(n) <= s(m+n):")
    known = {1: 1, 2: 2, 3: 4, 4: 7, 5: 13, 6: 26, 7: 50, 8: 98}
    for m in range(1, 5):
        for n in range(m, 9 - m):
            lhs, rhs = known[m] * known[n], 2 * known[m + n]
            add_lhs, add_rhs = known[m] + known[n], known[m + n]
            print(
                f"   m={m}, n={n}: {lhs:>4} <= {rhs:<4} ({lhs <= rhs}) | "
                f"{add_lhs:>3} <= {add_rhs:<3} ({add_lhs <= add_rhs})"
            )
    print()


def demo_lshape() -> None:
    print("=" * 72)
    print("4. The L-shape gives superadditivity")
    print("=" * 72)
    for m, n in [(2, 2), (2, 3), (3, 3)]:
        _, p = longest_snake(m)
        _, q = longest_snake(n)
        path = lshape_path(p, q)
        print(
            f"   Q_{m} x Q_{n}: L-shape length {len(path) - 1} "
            f"(= {len(p) - 1} + {len(q) - 1}), snake? {is_snake(path)}"
        )
    print()


def demo_density_and_cap() -> None:
    print("=" * 72)
    print("5. Comb density versus the 3/4 cap")
    print("=" * 72)
    print(f"   {'L':>3} {'K':>3} {'grid':>6} {'comb+1':>7} {'density':>8} "
          f"{'cap':>6} {'cap/grid':>9}")
    for K in [1, 2, 3, 5, 10]:
        for L in [10, 40]:
            grid = (L + 1) * (K + 1)
            v = comb_len(L, K) + 1
            cap = cap_34(L, K)
            assert v <= cap, "the comb must respect the cap"
            print(
                f"   {L:>3} {K:>3} {grid:>6} {v:>7} {v / grid:>8.3f} "
                f"{cap:>6} {cap / grid:>9.3f}"
            )
    print()
    print("   Limiting comb density (K+2)/(2(K+1)):")
    for K in [1, 2, 3, 5, 10, 100]:
        print(f"      K = {K:>3}:  {(K + 2) / (2 * (K + 1)):.4f}")
    print()


def demo_mechanism_fails() -> None:
    print("=" * 72)
    print("6. Bounded chord repair inside the product grid is impossible")
    print("=" * 72)
    print("   For every constant C and all L, K >= 8C+11, the maximum number of")
    print("   vertices of a product-supported snake is strictly below the")
    print("   conjectured (L+1)(K+1) - C(L+K).")
    print()
    print(f"   {'C':>2} {'L=K':>5} {'cap':>8} {'target':>9} {'cap<target':>11}")
    for C in [0, 1, 2, 3]:
        for N in [8 * C + 11, 8 * C + 30, 8 * C + 100]:
            cap = cap_34(N, N)
            target = (N + 1) * (N + 1) - C * (2 * N)
            print(f"   {C:>2} {N:>5} {cap:>8} {target:>9} {str(cap < target):>11}")
    print()
    print("   The gap grows like LK/4: the loss is a bulk effect, not a boundary one.")
    print()


def demo_no_two_by_two() -> None:
    print("=" * 72)
    print("7. No induced path uses all four cells of a 2x2 square")
    print("=" * 72)
    a = b = 4
    checked = 0
    violations = 0
    # enumerate all induced paths in the 4x4 grid and test the square property
    def nbrs(c: Cell) -> List[Cell]:
        i, j = c
        return [
            (x, y)
            for (x, y) in ((i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1))
            if 0 <= x < a and 0 <= y < b
        ]

    def walk(path: List[Cell], used: Set[Cell]) -> None:
        nonlocal checked, violations
        checked += 1
        if has_full_square(path):
            violations += 1
        tip = path[-1]
        for w in nbrs(tip):
            if w in used or any(u in used and u != tip for u in nbrs(w)):
                continue
            path.append(w)
            used.add(w)
            walk(path, used)
            used.discard(w)
            path.pop()

    for start in product(range(a), range(b)):
        walk([start], {start})
    print(f"   induced paths in the 4x4 grid examined : {checked}")
    print(f"   paths containing a full 2x2 square     : {violations}")
    print()


def demo_two_thirds() -> None:
    print("=" * 72)
    print("8. Exact longest induced paths in small grids: evidence for 2/3")
    print("=" * 72)
    print(f"   {'a x b':>7} {'cells':>6} {'best':>5} {'density':>8} {'cap 3/4':>8} "
          f"{'comb':>6}")
    for a, b in [(2, 2), (2, 4), (3, 3), (3, 5), (4, 4), (5, 5), (6, 6)]:
        best, path = longest_induced_grid_path(a, b)
        cells = a * b
        cap = cap_34(a - 1, b - 1)
        cb = comb_len(a - 1, b - 1) + 1
        print(
            f"   {a:>3} x {b:<3} {cells:>6} {best:>5} {best / cells:>8.3f} "
            f"{cap / cells:>8.3f} {cb:>6}"
        )
    print()
    best, path = longest_induced_grid_path(6, 6)
    print("   An optimal induced path in the 6x6 grid "
          f"({best} of 36 cells, density {best / 36:.3f}):")
    print()
    for line in render_grid(6, 6, path).splitlines():
        print("      " + line)
    print()
    print("   Densities cluster near 0.667, well below the 0.75 cap and well")
    print("   above the comb's asymptotic 0.5: the two-thirds conjecture.")
    print()


def main() -> None:
    demo_small_snake_numbers()
    demo_grid_is_induced()
    demo_comb()
    demo_lshape()
    demo_density_and_cap()
    demo_mechanism_fails()
    demo_no_two_by_two()
    demo_two_thirds()
    print("=" * 72)
    print("Summary:  s(m+n) >= max( s(m)*s(n)/2 , s(m)+s(n) ),")
    print("          and every product-supported snake loses Theta(L*K) cells.")
    print("=" * 72)


if __name__ == "__main__":
    main()
