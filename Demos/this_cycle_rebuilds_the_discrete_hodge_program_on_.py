"""
Markov Basis of the Two-Way Independence Model — numerical demonstrations.

This self-contained script illustrates the theorems proved (and machine-verified)
for the basic 2x2 swap moves on integer contingency tables:

  * margin preservation               (Theorem: basicMove_preserves_margins)
  * faithfulness of the L1 distance   (Theorem: D_eq_zero_iff)
  * sign-pattern pigeonhole           (Theorem: exists_good_indices)
  * strict distance decrease          (Theorem: dist_decrease)
  * the Fundamental Theorem of Markov Bases: any two non-negative tables with
    equal margins are connected by a non-negative walk of basic 2x2 moves
                                       (Theorem: twoWay_fiber_connected)
  * symmetry of the step relation     (Theorem: step_symm)

Run:  python demo.py
"""

from __future__ import annotations

import random
from typing import List, Optional, Tuple

# A table is a list of lists of ints (m rows, n cols).
Table = List[List[int]]
# A 2x2 frame (i, i', j, j') with i != i', j != j'.
Frame = Tuple[int, int, int, int]


# --------------------------------------------------------------------------- #
# Core definitions mirroring the Lean development
# --------------------------------------------------------------------------- #

def row_sum(u: Table, i: int) -> int:
    """The i-th row margin: sum over columns."""
    return sum(u[i])


def col_sum(u: Table, j: int) -> int:
    """The j-th column margin: sum over rows."""
    return sum(row[j] for row in u)


def margins(u: Table) -> Tuple[Tuple[int, ...], Tuple[int, ...]]:
    """All row sums and all column sums."""
    m, n = len(u), len(u[0])
    return (tuple(row_sum(u, i) for i in range(m)),
            tuple(col_sum(u, j) for j in range(n)))


def same_margins(u: Table, v: Table) -> bool:
    """SameMargins: all row sums and all column sums agree."""
    return margins(u) == margins(v)


def is_nonneg(u: Table) -> bool:
    """Nonneg: every entry is >= 0."""
    return all(x >= 0 for row in u for x in row)


def basic_move(m: int, n: int, frame: Frame) -> Table:
    """
    The basic 2x2 swap move
        B(i,i',j,j') = e(i,j') + e(i',j) - e(i,j) - e(i',j').
    """
    i, ip, j, jp = frame
    B = [[0] * n for _ in range(m)]
    B[i][jp] += 1
    B[ip][j] += 1
    B[i][j] -= 1
    B[ip][jp] -= 1
    return B


def add(u: Table, B: Table) -> Table:
    """Cell-wise addition of two tables."""
    return [[u[i][j] + B[i][j] for j in range(len(u[0]))] for i in range(len(u))]


def l1_distance(u: Table, v: Table) -> int:
    """D(u,v) = sum |u(i,j) - v(i,j)|."""
    return sum(abs(u[i][j] - v[i][j])
               for i in range(len(u)) for j in range(len(u[0])))


# --------------------------------------------------------------------------- #
# Sign-pattern pigeonhole (Theorem 3.3 / exists_good_indices)
# --------------------------------------------------------------------------- #

def find_good_frame(u: Table, v: Table) -> Optional[Frame]:
    """
    Three-stage pigeonhole on d = u - v (which has all margins 0 when u,v share
    margins). Returns a frame (i, i', j, j') with i != i', j != j' and sign
    pattern  v[i][j] < u[i][j],  u[i][j'] < v[i][j'],  v[i'][j'] < u[i'][j'].
    Returns None iff u == v.
    """
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]

    # Stage 1: a strictly positive cell (i, j).
    cell = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if cell is None:
        return None
    i, j = cell

    # Stage 2: a strictly negative cell (i, j') in the same row.
    jp = next(jj for jj in range(n) if d[i][jj] < 0)

    # Stage 3: a strictly positive cell (i', j') in that column.
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)

    return (i, ip, j, jp)


# --------------------------------------------------------------------------- #
# Greedy connecting walk (constructive Fundamental Theorem of Markov Bases)
# --------------------------------------------------------------------------- #

def connect(u: Table, v: Table) -> List[Table]:
    """
    Build an explicit non-negative walk of basic 2x2 moves from u to v.
    Precondition: u, v non-negative with equal margins.
    """
    assert is_nonneg(u) and is_nonneg(v), "tables must be non-negative"
    assert same_margins(u, v), "tables must share all margins"
    m, n = len(u), len(u[0])
    path: List[Table] = [u]
    cur = [row[:] for row in u]
    while cur != v:
        frame = find_good_frame(cur, v)
        assert frame is not None
        nxt = add(cur, basic_move(m, n, frame))
        assert is_nonneg(nxt), "step must preserve non-negativity"
        assert same_margins(cur, nxt), "step must preserve margins"
        assert l1_distance(nxt, v) < l1_distance(cur, v), "step must decrease D"
        path.append(nxt)
        cur = nxt
    return path


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_margin_preservation() -> None:
    print("=" * 70)
    print("DEMO 1  Margin preservation: a basic move changes no margin")
    print("=" * 70)
    u = [[2, 1, 0],
         [0, 3, 1],
         [1, 0, 2]]
    frame = (0, 2, 0, 2)  # rows 0,2 and cols 0,2
    B = basic_move(3, 3, frame)
    w = add(u, B)
    print("u           margins:", margins(u))
    print("u + B       margins:", margins(w))
    print("basic move B =", B)
    print("margins preserved:", same_margins(u, w))
    print()


def demo_pigeonhole_and_decrease() -> None:
    print("=" * 70)
    print("DEMO 2  Sign-pattern pigeonhole + strict distance decrease")
    print("=" * 70)
    u = [[3, 0],
         [0, 3]]
    v = [[0, 3],
         [3, 0]]
    print("u =", u, " v =", v, " same margins:", same_margins(u, v))
    frame = find_good_frame(u, v)
    print("found frame (i, i', j, j'):", frame)
    w = add(u, basic_move(2, 2, frame))
    print("D(u, v)        =", l1_distance(u, v))
    print("D(u + B, v)    =", l1_distance(w, v), " (strictly smaller)")
    print()


def demo_fundamental_theorem() -> None:
    print("=" * 70)
    print("DEMO 3  Fundamental Theorem: connect two equal-margin tables")
    print("=" * 70)
    u = [[3, 0, 1],
         [0, 2, 2],
         [2, 1, 0]]
    v = [[1, 1, 2],
         [1, 2, 1],
         [3, 0, 0]]
    print("u =", u)
    print("v =", v)
    print("same margins:", same_margins(u, v), "  initial D:", l1_distance(u, v))
    path = connect(u, v)
    print(f"connected via {len(path) - 1} basic moves; every table non-negative.")
    print("distance trace:", [l1_distance(t, v) for t in path])
    print("reached v:", path[-1] == v)
    print()


def demo_symmetry_via_random_walk() -> None:
    print("=" * 70)
    print("DEMO 4  Symmetry: a random basic-move walk and its exact reversal")
    print("=" * 70)
    random.seed(7)
    m, n = 3, 4
    u = [[random.randint(0, 4) for _ in range(n)] for _ in range(m)]
    cur = [row[:] for row in u]
    moves: List[Frame] = []
    for _ in range(12):
        i, ip = random.sample(range(m), 2)
        j, jp = random.sample(range(n), 2)
        frame = (i, ip, j, jp)
        nxt = add(cur, basic_move(m, n, frame))
        if is_nonneg(nxt):
            moves.append(frame)
            cur = nxt
    print("start u =", u)
    print("after", len(moves), "random legal moves, margins unchanged:",
          same_margins(u, cur))
    # Reverse each move by swapping the two rows (B(i',i,j,j') = -B(i,i',j,j')).
    back = [row[:] for row in cur]
    for (i, ip, j, jp) in reversed(moves):
        back = add(back, basic_move(m, n, (ip, i, j, jp)))
    print("reversing every move returns to u:", back == u)
    print()


def demo_exact_test_sampler() -> None:
    print("=" * 70)
    print("DEMO 5  MCMC on a fiber: estimate an exact-test tail probability")
    print("=" * 70)
    # 2x2 fiber: all non-negative integer tables with these margins.
    # Margins: rows (5,5), cols (4,6).  Free parameter a = u[0][0] in {0..4}.
    observed = [[1, 4],
                [3, 2]]
    r0, r1 = 5, 5
    c0 = 4
    print("observed table:", observed, " margins:", margins(observed))

    def chisq(u: Table) -> float:
        m, n = len(u), len(u[0])
        rs = [row_sum(u, i) for i in range(m)]
        cs = [col_sum(u, j) for j in range(n)]
        tot = sum(rs)
        s = 0.0
        for i in range(m):
            for j in range(n):
                e = rs[i] * cs[j] / tot
                if e > 0:
                    s += (u[i][j] - e) ** 2 / e
        return s

    obs_stat = chisq(observed)
    # Uniform-on-fiber sampler via symmetric basic-move proposals (Metropolis
    # with target pi = uniform, so every non-negative proposal is accepted).
    random.seed(123)
    cur = [row[:] for row in observed]
    hits = 0
    T = 20000
    for _ in range(T):
        sign = random.choice((1, -1))
        B = basic_move(2, 2, (0, 1, 0, 1))
        prop = add(cur, [[sign * x for x in row] for row in B])
        if is_nonneg(prop):       # symmetric proposal, uniform target -> accept
            cur = prop
        if chisq(cur) >= obs_stat - 1e-9:
            hits += 1
    print(f"chi-square of observed = {obs_stat:.3f}")
    print(f"MCMC estimate of P(stat >= observed | margins) over fiber = "
          f"{hits / T:.3f}")
    # Exact enumeration check (the fiber is tiny here).
    fiber = [[[a, r0 - a], [c0 - a, r1 - (c0 - a)]] for a in range(0, c0 + 1)
             if 0 <= c0 - a <= r1 and 0 <= r0 - a]
    fiber = [t for t in fiber if is_nonneg(t)]
    exact = sum(1 for t in fiber if chisq(t) >= obs_stat - 1e-9) / len(fiber)
    print(f"exact (uniform over fiber, |fiber|={len(fiber)}) = {exact:.3f}")
    print()


if __name__ == "__main__":
    demo_margin_preservation()
    demo_pigeonhole_and_decrease()
    demo_fundamental_theorem()
    demo_symmetry_via_random_walk()
    demo_exact_test_sampler()
    print("All demonstrations completed.")
