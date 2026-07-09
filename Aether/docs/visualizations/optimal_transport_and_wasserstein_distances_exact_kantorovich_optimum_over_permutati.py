"""Exact Kantorovich optimum over permutation couplings (assignment problem)."""

from __future__ import annotations

from itertools import permutations
from typing import List, Tuple

Matrix = List[List[float]]


def transport_cost_perm(d: Matrix, sigma: Tuple[int, ...]) -> float:
    """(1/n) * sum_i d[i][sigma(i)] -- the cost of a permutation plan."""
    n = len(d)
    return sum(d[i][sigma[i]] for i in range(n)) / n


def wasserstein_perm_optimum(d: Matrix) -> Tuple[float, Tuple[int, ...]]:
    """Return (optimal cost, optimal permutation) over uniform-marginal couplings.

    By Birkhoff-von Neumann the optimum over the full transportation polytope
    of uniform marginals is attained at a permutation, so this exact search is
    the true Wasserstein value. Complexity O(n! * n).
    """
    n = len(d)
    best_cost = float("inf")
    best_sigma: Tuple[int, ...] = tuple(range(n))
    for sigma in permutations(range(n)):
        cost = transport_cost_perm(d, sigma)
        if cost < best_cost:
            best_cost, best_sigma = cost, sigma
    return best_cost, best_sigma


if __name__ == "__main__":
    d: Matrix = [[abs(i - j) ** 2 for j in range(4)] for i in range(4)]
    cost, sigma = wasserstein_perm_optimum(d)
    print(f"optimal permutation = {sigma}, cost = {cost:.4f}")
