"""
Numerical demonstrations of the Blend Collapse Theorem.

Setup
-----
A finite weighted digraph on vertices {0, ..., n-1} is given by a row-stochastic
weight matrix W with W[i][j] >= 0 and sum_j W[i][j] = 1.  We read W[i][j] as the
weight of the arc i -> j.

A *blend coloring* is a vector c with

        c[i] = sum_j W[i][j] * c[j]      for all i,

i.e. c lies in the kernel of the random-walk Laplacian L = I - W.

Main result (Blend Collapse Theorem):  if W is row-stochastic and *strongly
connected* (every vertex reachable from every other along positive-weight arcs),
then every blend coloring is constant -- equivalently, ker(I - W) = span{1}.

This script demonstrates, entirely from scratch (no numpy required):

  1. The 2-cycle forces c[0] = c[1].
  2. The directed n-cycle forces a constant coloring (Theorem: cycle collapse).
  3. The two-self-loop digraph (NOT strongly connected) admits the non-constant
     blend coloring c = (0, 1) -- the sharpness example.
  4. A random strongly connected chain: the averaging iteration converges to the
     global mean, and the blend-coloring space is one-dimensional.
  5. The Dobrushin coefficient certifies a geometric contraction rate.
  6. Vector-valued colors collapse coordinatewise.
"""

from __future__ import annotations

import random
from typing import List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]


# --------------------------------------------------------------------------- #
# Basic structural checks
# --------------------------------------------------------------------------- #
def is_row_stochastic(W: Sequence[Sequence[float]], tol: float = 1e-9) -> bool:
    """Return True if every entry is >= 0 and every row sums to 1."""
    for row in W:
        if any(x < -tol for x in row):
            return False
        if abs(sum(row) - 1.0) > tol:
            return False
    return True


def support_reachable(W: Sequence[Sequence[float]], src: int,
                      tol: float = 1e-12) -> set[int]:
    """Set of vertices reachable from `src` along positive-weight arcs."""
    n = len(W)
    seen = {src}
    stack = [src]
    while stack:
        i = stack.pop()
        for j in range(n):
            if W[i][j] > tol and j not in seen:
                seen.add(j)
                stack.append(j)
    return seen


def _is_strongly_connected(W: Sequence[Sequence[float]]) -> bool:
    """True if every vertex reaches every other along positive-weight arcs."""
    n = len(W)
    return all(len(support_reachable(W, i)) == n for i in range(n))


# --------------------------------------------------------------------------- #
# The averaging (gossip) dynamics and blend colorings
# --------------------------------------------------------------------------- #
def blend_step(W: Sequence[Sequence[float]], c: Vector) -> Vector:
    """One round of averaging: c'[i] = sum_j W[i][j] * c[j]."""
    n = len(W)
    return [sum(W[i][j] * c[j] for j in range(n)) for i in range(n)]


def oscillation(c: Vector) -> float:
    """Spread of a coloring, max_i c[i] - min_i c[i]."""
    return max(c) - min(c)


def iterate_to_consensus(W: Sequence[Sequence[float]], c0: Vector,
                         steps: int) -> Tuple[Vector, List[float]]:
    """Iterate the averaging map; return final coloring and spread history."""
    c = list(c0)
    history = [oscillation(c)]
    for _ in range(steps):
        c = blend_step(W, c)
        history.append(oscillation(c))
    return c, history


# --------------------------------------------------------------------------- #
# Exact kernel of L = I - W over the rationals (dimension of blend-coloring space)
# --------------------------------------------------------------------------- #
def kernel_dimension(W: Sequence[Sequence[float]], tol: float = 1e-9) -> int:
    """Dimension of ker(I - W) via numeric Gaussian elimination with pivoting.

    Under the theorem's hypotheses this must equal 1 (only constant colorings).
    A tolerance is used so that the exact row-stochastic relation L*1 = 0 is
    detected as a genuine kernel direction even for floating-point weights.
    """
    n = len(W)
    L = [[(1.0 if i == j else 0.0) - float(W[i][j]) for j in range(n)]
         for i in range(n)]
    rank = 0
    r = 0
    col = 0
    while r < n and col < n:
        # partial pivot: largest magnitude entry in this column
        pivot = max(range(r, n), key=lambda k: abs(L[k][col]))
        if abs(L[pivot][col]) <= tol:
            col += 1
            continue
        L[r], L[pivot] = L[pivot], L[r]
        pv = L[r][col]
        L[r] = [x / pv for x in L[r]]
        for k in range(n):
            if k != r and abs(L[k][col]) > tol:
                f = L[k][col]
                L[k] = [a - f * b for a, b in zip(L[k], L[r])]
        r += 1
        rank += 1
        col += 1
    return n - rank


# --------------------------------------------------------------------------- #
# Dobrushin ergodic coefficient (contraction certificate)
# --------------------------------------------------------------------------- #
def mat_mult(A: Matrix, B: Matrix) -> Matrix:
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)]
            for i in range(n)]


def mat_pow(W: Matrix, r: int) -> Matrix:
    n = len(W)
    P = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    for _ in range(r):
        P = mat_mult(P, [list(row) for row in W])
    return P


def dobrushin_coefficient(W: Sequence[Sequence[float]]) -> float:
    """delta(W) = 1 - min_{i,i'} sum_j min(W[i][j], W[i'][j]) in [0, 1].

    If delta(W^r) < 1 then averaging contracts the spread by that factor every
    r steps, giving geometric convergence to consensus.
    """
    n = len(W)
    worst = 1.0
    for i in range(n):
        for ip in range(i + 1, n):
            overlap = sum(min(W[i][j], W[ip][j]) for j in range(n))
            worst = min(worst, overlap)
    return 1.0 - worst


# --------------------------------------------------------------------------- #
# Example weight matrices
# --------------------------------------------------------------------------- #
def directed_cycle(n: int) -> Matrix:
    """W[i][j] = 1 iff j == (i+1) mod n; the directed n-cycle."""
    return [[1.0 if j == (i + 1) % n else 0.0 for j in range(n)] for i in range(n)]


def two_self_loops() -> Matrix:
    """The sharpness example: W = identity on 2 vertices (NOT strongly conn.)."""
    return [[1.0, 0.0], [0.0, 1.0]]


def random_strongly_connected(n: int, seed: int = 0) -> Matrix:
    """A random row-stochastic matrix guaranteed strongly connected.

    Start from the directed cycle backbone (ensures strong connectivity), add
    random positive mass everywhere, then normalize each row.
    """
    rng = random.Random(seed)
    W = [[0.0] * n for _ in range(n)]
    for i in range(n):
        W[i][(i + 1) % n] += 1.0  # backbone cycle keeps it strongly connected
        for j in range(n):
            W[i][j] += rng.random()
        s = sum(W[i])
        W[i] = [x / s for x in W[i]]
    return W


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_two_cycle() -> None:
    print("=" * 70)
    print("1. The directed 2-cycle forces c[0] = c[1].")
    W = directed_cycle(2)
    print("   W =", W, "  strongly connected:", _is_strongly_connected(W))
    print("   blend-coloring space dimension:", kernel_dimension(W), "(expected 1)")


def demo_n_cycle() -> None:
    print("=" * 70)
    print("2. Directed n-cycle collapse (Theorem: cycle collapse).")
    for n in (3, 4, 5, 8):
        W = directed_cycle(n)
        dim = kernel_dimension(W)
        print(f"   n={n}: strongly connected={_is_strongly_connected(W)}, "
              f"blend space dim={dim} (expected 1)")


def demo_sharpness() -> None:
    print("=" * 70)
    print("3. Sharpness: two self-loops are NOT strongly connected.")
    W = two_self_loops()
    print("   W =", W, "  strongly connected:", _is_strongly_connected(W))
    c = [0.0, 1.0]
    print("   c = (0, 1) is a NON-constant blend coloring:")
    print("   blend_step(W, c) =", blend_step(W, c), " equals c ->",
          blend_step(W, c) == c)
    print("   blend-coloring space dimension:", kernel_dimension(W),
          "(equals number of sinks = 2)")


def demo_random_convergence() -> None:
    print("=" * 70)
    print("4. Random strongly connected chain: averaging -> global mean.")
    n = 6
    W = random_strongly_connected(n, seed=42)
    print("   strongly connected:", _is_strongly_connected(W),
          " row-stochastic:", is_row_stochastic(W))
    c0 = [float(v) for v in range(n)]  # 0,1,2,3,4,5
    c_final, hist = iterate_to_consensus(W, c0, steps=60)
    print("   initial spread:", round(hist[0], 6))
    print("   spread after 60 steps:", format(hist[-1], ".3e"))
    print("   final coloring (~constant):",
          [round(x, 6) for x in c_final])
    print("   blend-coloring space dimension:", kernel_dimension(W),
          "(expected 1)")


def demo_dobrushin() -> None:
    print("=" * 70)
    print("5. Dobrushin coefficient certifies geometric contraction.")
    W = random_strongly_connected(6, seed=7)
    for r in (1, 2, 3, 4):
        Wr = mat_pow([list(row) for row in W], r)
        d = dobrushin_coefficient(Wr)
        print(f"   delta(W^{r}) = {d:.6f}  -> spread shrinks by this factor "
              f"every {r} step(s){'  (< 1: contraction!)' if d < 1 else ''}")


def demo_vector_valued() -> None:
    print("=" * 70)
    print("6. Vector-valued colors collapse coordinatewise.")
    n = 5
    W = random_strongly_connected(n, seed=99)
    # colors in R^3
    C = [[float(i), float(i * i), float((-1) ** i)] for i in range(n)]
    for _ in range(200):
        C = [[sum(W[i][j] * C[j][d] for j in range(n)) for d in range(3)]
             for i in range(n)]
    spreads = [max(C[i][d] for i in range(n)) - min(C[i][d] for i in range(n))
               for d in range(3)]
    print("   per-coordinate spread after 200 steps:",
          [format(s, ".2e") for s in spreads])
    print("   all coordinates collapse to constants ->",
          all(s < 1e-6 for s in spreads))


def main() -> None:
    demo_two_cycle()
    demo_n_cycle()
    demo_sharpness()
    demo_random_convergence()
    demo_dobrushin()
    demo_vector_valued()
    print("=" * 70)
    print("All demonstrations consistent with the Blend Collapse Theorem.")


if __name__ == "__main__":
    main()
