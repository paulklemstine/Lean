"""
Sheaf-Theoretic Data Integration: Core Algorithms
===================================================

Type-hinted implementations of the main algorithms from the paper:
1. Consistency defect computation
2. Weighted defect (Laplacian form)
3. Optimal mean imputation
4. Tropical consistency cost
5. Tropical shortest-path merge optimization
"""

from __future__ import annotations
import math
from typing import List, Tuple, Optional
import heapq


def consistency_defect(values: List[float]) -> float:
    """Compute the consistency defect: Σ_{i,j} (f[j] - f[i])².
    
    Args:
        values: Data values from each source.
    
    Returns:
        Total squared pairwise disagreement.
    
    Time complexity: O(n²)
    """
    n = len(values)
    total = 0.0
    for i in range(n):
        for j in range(n):
            diff = values[j] - values[i]
            total += diff * diff
    return total


def is_consistent(values: List[float], tol: float = 1e-12) -> bool:
    """Check if data sources are consistent (all agree).
    
    Args:
        values: Data values from each source.
        tol: Numerical tolerance for equality.
    
    Returns:
        True if all values are equal within tolerance.
    """
    if not values:
        return True
    return all(abs(v - values[0]) < tol for v in values)


def weighted_defect(
    values: List[float],
    weights: List[List[float]]
) -> float:
    """Compute the weighted consistency defect: Σ_{i,j} w[i][j]·(f[j]-f[i])².
    
    Args:
        values: Data values from each source.
        weights: Symmetric non-negative weight matrix (overlap counts).
    
    Returns:
        Weighted total squared disagreement.
    
    Time complexity: O(n²)
    """
    n = len(values)
    total = 0.0
    for i in range(n):
        for j in range(n):
            diff = values[j] - values[i]
            total += weights[i][j] * diff * diff
    return total


def laplacian_form(
    values: List[float],
    weights: List[List[float]]
) -> float:
    """Compute the Laplacian quadratic form: x^T L x.
    
    L[i,i] = degree(i), L[i,j] = -w[i][j] for i ≠ j.
    Q_L(f) = Σ_i deg(i)·f[i]² - Σ_{i,j} w[i][j]·f[i]·f[j]
    
    The Laplacian-Defect Identity: weighted_defect = 2 * laplacian_form.
    
    Args:
        values: Data values from each source.
        weights: Symmetric non-negative weight matrix.
    
    Returns:
        Laplacian quadratic form value.
    """
    n = len(values)
    degree_term = 0.0
    cross_term = 0.0
    for i in range(n):
        deg_i = sum(weights[i])
        degree_term += deg_i * values[i] ** 2
        for j in range(n):
            cross_term += weights[i][j] * values[i] * values[j]
    return degree_term - cross_term


def source_mean(values: List[float]) -> float:
    """Compute the arithmetic mean of source values.
    
    This is the optimal constant imputation that minimizes
    the sum of squared deviations.
    
    Args:
        values: Data values from each source.
    
    Returns:
        Arithmetic mean.
    """
    return sum(values) / len(values)


def deviation_sum(values: List[float], c: float) -> float:
    """Compute sum of squared deviations from constant c.
    
    D(f, c) = Σ_i (f[i] - c)²
    
    Args:
        values: Data values from each source.
        c: Constant to measure deviation from.
    
    Returns:
        Total squared deviation.
    """
    return sum((v - c) ** 2 for v in values)


def deviation_decomposition(
    values: List[float], c: float
) -> Tuple[float, float, float]:
    """Bias-variance decomposition of deviation sum.
    
    D(f, c) = D(f, mean) + n·(mean - c)²
    
    Args:
        values: Data values from each source.
        c: Arbitrary constant.
    
    Returns:
        Tuple of (deviation_from_mean, bias_term, total_deviation).
    """
    n = len(values)
    m = source_mean(values)
    dev_from_mean = deviation_sum(values, m)
    bias = n * (m - c) ** 2
    return dev_from_mean, bias, dev_from_mean + bias


def tropical_cost(r: float, C: int) -> float:
    """Compute the tropical consistency cost.
    
    τ(r, C) = -C · log(1-r)
    
    This is the negative log-probability of consistency when
    each of C overlapping features has independent error rate r.
    
    Args:
        r: Error rate, must be in (0, 1).
        C: Number of overlapping features.
    
    Returns:
        Tropical cost (non-negative).
    
    Raises:
        ValueError: If r is not in (0, 1).
    """
    if not (0 < r < 1):
        raise ValueError(f"Error rate r={r} must be in (0, 1)")
    return -C * math.log(1 - r)


def cech_delta0(f: List[float]) -> List[List[float]]:
    """Compute the 0th Čech coboundary: δ⁰(f)[i][j] = f[j] - f[i].
    
    Args:
        f: 0-cochain (source values).
    
    Returns:
        1-cochain (pairwise differences).
    """
    n = len(f)
    return [[f[j] - f[i] for j in range(n)] for i in range(n)]


def cech_delta1(g: List[List[float]]) -> List[List[List[float]]]:
    """Compute the 1st Čech coboundary: δ¹(g)[i][j][k] = g[j][k] - g[i][k] + g[i][j].
    
    Args:
        g: 1-cochain (pairwise comparison data).
    
    Returns:
        2-cochain (triple comparison data).
    """
    n = len(g)
    return [[[g[j][k] - g[i][k] + g[i][j]
              for k in range(n)]
             for j in range(n)]
            for i in range(n)]


def verify_coboundary_sq_zero(f: List[float], tol: float = 1e-10) -> bool:
    """Verify the identity δ¹ ∘ δ⁰ = 0 numerically.
    
    Args:
        f: 0-cochain (source values).
        tol: Numerical tolerance.
    
    Returns:
        True if δ¹(δ⁰(f)) is zero within tolerance.
    """
    delta0_f = cech_delta0(f)
    delta1_delta0_f = cech_delta1(delta0_f)
    n = len(f)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if abs(delta1_delta0_f[i][j][k]) > tol:
                    return False
    return True


def tropical_shortest_path_merge(
    n: int,
    weights: List[List[float]],
    error_rates: List[List[float]]
) -> Tuple[float, List[Tuple[int, int]]]:
    """Find optimal merge order via tropical shortest-path MST.
    
    Computes the minimum spanning tree of the tropical cost graph,
    where edge costs are τ(r[i][j], w[i][j]).
    
    Args:
        n: Number of data sources.
        weights: Overlap counts between source pairs.
        error_rates: Pairwise error rates.
    
    Returns:
        Tuple of (total_cost, mst_edges).
    """
    # Build edge list with tropical costs
    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            if weights[i][j] > 0 and 0 < error_rates[i][j] < 1:
                cost = tropical_cost(error_rates[i][j], int(weights[i][j]))
                edges.append((cost, i, j))
    
    # Kruskal's MST
    edges.sort()
    parent = list(range(n))
    rank = [0] * n
    
    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x: int, y: int) -> bool:
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True
    
    total_cost = 0.0
    mst_edges: List[Tuple[int, int]] = []
    for cost, i, j in edges:
        if union(i, j):
            total_cost += cost
            mst_edges.append((i, j))
            if len(mst_edges) == n - 1:
                break
    
    return total_cost, mst_edges


def overlap_nerve_laplacian(weights: List[List[float]]) -> List[List[float]]:
    """Compute the graph Laplacian of an overlap nerve.
    
    L[i,i] = Σ_j w[i][j]
    L[i,j] = -w[i][j]  for i ≠ j
    
    Args:
        weights: Symmetric non-negative weight matrix.
    
    Returns:
        Laplacian matrix.
    """
    n = len(weights)
    L = [[0.0] * n for _ in range(n)]
    for i in range(n):
        deg = sum(weights[i])
        L[i][i] = deg
        for j in range(n):
            if i != j:
                L[i][j] = -weights[i][j]
    return L
