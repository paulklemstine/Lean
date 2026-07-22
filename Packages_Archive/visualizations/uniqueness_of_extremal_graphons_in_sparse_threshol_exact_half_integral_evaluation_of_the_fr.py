"""Exact half-integral evaluation of the fractional independence number alpha*(G).

Mathematical foundation. The LP

    maximize   sum_v x_v
    subject to 0 <= x_v <= 1            (box constraints, Definition 2.1)
               x_u + x_v <= 1           (one per edge uv)

is the relaxation of maximum independent set. By the Nemhauser-Trotter theorem
(1975) this LP is *half-integral*: it always has an optimal vertex whose every
coordinate lies in {0, 1/2, 1}. Hence the continuous optimum equals the maximum
of the objective over the finite grid {0, 1/2, 1}^n. This algorithm performs that
search, returning the exact alpha*(G) together with a maximizing assignment.

Complexity. The grid has 3^n points and feasibility of each costs O(n + |E|), so
the running time is O(3^n (n + |E|)). This is exponential but exact and dependency
free; it is intended for verification on the small graphs of the paper (n <= ~16).
For larger graphs one would call a polynomial-time LP solver instead, using the
theorems of the paper (sandwich, single-edge ceiling) as certified sanity bounds.
"""

from __future__ import annotations

from itertools import product

Edge = tuple[int, int]
Graph = tuple[int, frozenset[Edge]]


def alpha_star_exact(graph: Graph) -> tuple[float, tuple[float, ...]]:
    """Return (alpha*(G), argmax x) by exact search over the half-integral grid."""
    n, edges = graph
    grid: tuple[float, ...] = (0.0, 0.5, 1.0)
    best_val: float = 0.0
    best_x: tuple[float, ...] = tuple(0.0 for _ in range(n))
    for x in product(grid, repeat=n):
        feasible: bool = all(x[u] + x[v] <= 1.0 + 1e-12 for (u, v) in edges)
        if not feasible:
            continue
        val: float = float(sum(x))
        if val > best_val:
            best_val, best_x = val, x
    return best_val, best_x
