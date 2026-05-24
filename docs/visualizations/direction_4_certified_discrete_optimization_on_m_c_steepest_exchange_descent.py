"""
Algorithms for M-Convex Set Optimization via Exchange Descent.

Implements the core algorithms from the certified discrete optimization theory:
- M-convex set generation and verification
- Exchange descent optimization with certificates
- Exchange graph construction and diameter computation

All algorithms operate on simplex layers Δ_{n,d} = {x ∈ ℤ_≥0^n : ∑ x_i = d}
and M-convex subsets thereof.
"""

from __future__ import annotations
from itertools import product as cartesian_product
from typing import Callable
import random
from collections import deque


def simplex_layer(n: int, d: int) -> list[tuple[int, ...]]:
    """Generate all points in the simplex layer Δ_{n,d} = {x ∈ ℤ_≥0^n : ∑x_i = d}.

    Args:
        n: dimension (number of coordinates)
        d: mass (coordinate sum)

    Returns:
        List of all integer points with non-negative coordinates summing to d.

    >>> len(simplex_layer(3, 2))
    6
    """
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in simplex_layer(n - 1, d - first):
            result.append((first,) + rest)
    return result


def exchange_vec(x: tuple[int, ...], i: int, j: int) -> tuple[int, ...]:
    """Apply exchange operation: decrement coordinate i, increment coordinate j.

    Args:
        x: input vector
        i: source coordinate (decremented)
        j: target coordinate (incremented)

    Returns:
        New vector x - e_i + e_j

    >>> exchange_vec((2, 0, 1), 0, 1)
    (1, 1, 1)
    """
    lst = list(x)
    lst[i] -= 1
    lst[j] += 1
    return tuple(lst)


def linear_objective(c: tuple[int, ...], x: tuple[int, ...]) -> int:
    """Compute the linear objective ∑ c_k * x_k.

    >>> linear_objective((1, 2, 3), (1, 1, 1))
    6
    """
    return sum(ci * xi for ci, xi in zip(c, x))


def check_m_convex(S: set[tuple[int, ...]]) -> bool:
    """Check whether a finite set S satisfies the M-convex exchange property.

    For all x, y ∈ S and all i with x_i > y_i, there must exist j ≠ i
    with x_j < y_j such that exchange_vec(x, i, j) ∈ S.

    Args:
        S: set of integer vectors (must have constant coordinate sum)

    Returns:
        True iff S is M-convex.

    >>> S = set(simplex_layer(3, 2))
    >>> check_m_convex(S)
    True
    """
    for x in S:
        for y in S:
            n = len(x)
            for i in range(n):
                if x[i] > y[i]:
                    found = False
                    for j in range(n):
                        if j != i and x[j] < y[j]:
                            xp = exchange_vec(x, i, j)
                            if xp in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def exchange_neighbors(x: tuple[int, ...], S: set[tuple[int, ...]]) -> list[tuple[int, int, tuple[int, ...]]]:
    """Find all feasible exchange neighbors of x in S.

    Returns:
        List of (i, j, x') where x' = exchange_vec(x, i, j) ∈ S.
    """
    n = len(x)
    neighbors = []
    for i in range(n):
        if x[i] > 0:
            for j in range(n):
                if j != i:
                    xp = exchange_vec(x, i, j)
                    if xp in S:
                        neighbors.append((i, j, xp))
    return neighbors


def steepest_exchange_descent(
    S: set[tuple[int, ...]],
    c: tuple[int, ...],
    x0: tuple[int, ...],
    verbose: bool = False
) -> tuple[tuple[int, ...], list[tuple[int, ...]], list[tuple[int, int]]]:
    """Run steepest exchange descent from x0 on M-convex set S with objective c.

    At each step, choose the exchange that maximally decreases the objective.
    By the local-to-global theorem, the result is a global minimum.

    Args:
        S: M-convex feasible set
        c: linear objective coefficients
        x0: starting point (must be in S)
        verbose: print each step if True

    Returns:
        (optimum, path, moves) where:
        - optimum: the certified optimal point
        - path: sequence of visited points
        - moves: list of (i, j) exchange pairs applied
    """
    x = x0
    path = [x]
    moves = []

    while True:
        nbrs = exchange_neighbors(x, S)
        best_val = linear_objective(c, x)
        best_move = None
        best_point = None

        for i, j, xp in nbrs:
            val = linear_objective(c, xp)
            if val < best_val:
                best_val = val
                best_move = (i, j)
                best_point = xp

        if best_move is None:
            break

        if verbose:
            print(f"  {x} → {best_point}  (exchange {best_move[0]}→{best_move[1]}, "
                  f"obj: {linear_objective(c, x)} → {best_val})")

        x = best_point
        path.append(x)
        moves.append(best_move)

    return x, path, moves


def brute_force_optimum(
    S: set[tuple[int, ...]],
    c: tuple[int, ...]
) -> tuple[tuple[int, ...], int]:
    """Find the global minimum of c·x over S by exhaustive search.

    Returns:
        (optimum_point, optimum_value)
    """
    best = None
    best_val = float('inf')
    for x in S:
        val = linear_objective(c, x)
        if val < best_val:
            best_val = val
            best = x
    return best, best_val


def exchange_graph_diameter(S: set[tuple[int, ...]]) -> int:
    """Compute the exchange diameter of S: max shortest-path distance in the exchange graph.

    The exchange graph has vertices S and edges {x, x'} whenever x' = exchange_vec(x, i, j)
    for some i, j.

    Returns:
        The diameter (maximum BFS distance between any two points in S).
    """
    S_list = list(S)
    S_idx = {x: idx for idx, x in enumerate(S_list)}
    n_pts = len(S_list)

    # Build adjacency list
    adj: list[list[int]] = [[] for _ in range(n_pts)]
    for idx, x in enumerate(S_list):
        dim = len(x)
        for i in range(dim):
            if x[i] > 0:
                for j in range(dim):
                    if j != i:
                        xp = exchange_vec(x, i, j)
                        if xp in S_idx:
                            adj[idx].append(S_idx[xp])

    diameter = 0
    for src in range(n_pts):
        dist = [-1] * n_pts
        dist[src] = 0
        queue = deque([src])
        while queue:
            u = queue.popleft()
            for v in adj[u]:
                if dist[v] == -1:
                    dist[v] = dist[u] + 1
                    queue.append(v)
        max_dist = max(d for d in dist if d >= 0)
        diameter = max(diameter, max_dist)

    return diameter


def exchange_dist(
    S: set[tuple[int, ...]],
    x: tuple[int, ...],
    y: tuple[int, ...]
) -> int:
    """Compute the exchange distance between x and y in S via BFS."""
    if x == y:
        return 0
    S_set = set(S)
    visited = {x}
    queue = deque([(x, 0)])
    dim = len(x)

    while queue:
        curr, d = queue.popleft()
        for i in range(dim):
            if curr[i] > 0:
                for j in range(dim):
                    if j != i:
                        nxt = exchange_vec(curr, i, j)
                        if nxt == y:
                            return d + 1
                        if nxt in S_set and nxt not in visited:
                            visited.add(nxt)
                            queue.append((nxt, d + 1))
    return -1  # unreachable in connected M-convex set


def pos_diff(x: tuple[int, ...], y: tuple[int, ...]) -> int:
    """Compute the positive difference potential: ∑ max(x_k - y_k, 0)."""
    return sum(max(xk - yk, 0) for xk, yk in zip(x, y))


def random_m_convex_subset(n: int, d: int, min_size: int = 2) -> set[tuple[int, ...]]:
    """Generate a random M-convex subset of the simplex layer Δ_{n,d}.

    Strategy: start with the full simplex layer (which is M-convex) and
    randomly remove points while maintaining M-convexity.

    Args:
        n: dimension
        d: mass
        min_size: minimum size of the resulting set

    Returns:
        A random M-convex subset.
    """
    full = set(simplex_layer(n, d))
    S = set(full)
    pts = list(S)
    random.shuffle(pts)

    for pt in pts:
        if len(S) <= min_size:
            break
        S_trial = S - {pt}
        if check_m_convex(S_trial):
            S = S_trial

    return S


def certified_argmin(
    S: set[tuple[int, ...]],
    c: tuple[int, ...],
    x0: tuple[int, ...] | None = None
) -> dict:
    """Compute a certified argmin on M-convex set S with objective c.

    Returns a dictionary containing:
    - 'point': the optimal point
    - 'value': the optimal objective value
    - 'path': the descent path from x0
    - 'moves': the exchange moves applied
    - 'steps': number of descent steps
    - 'is_m_convex': verification that S is M-convex
    - 'brute_force_value': brute-force optimum for cross-check
    - 'certificate': 'VERIFIED' if descent matches brute-force
    """
    if x0 is None:
        x0 = next(iter(S))

    opt, path, moves = steepest_exchange_descent(S, c, x0)
    opt_val = linear_objective(c, opt)
    bf_opt, bf_val = brute_force_optimum(S, c)

    return {
        'point': opt,
        'value': opt_val,
        'path': path,
        'moves': moves,
        'steps': len(moves),
        'is_m_convex': check_m_convex(S),
        'brute_force_value': bf_val,
        'certificate': 'VERIFIED' if opt_val == bf_val else 'FAILED'
    }
