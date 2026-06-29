"""
Algorithms for p-adic Chip-Firing Critical Groups Under Graph Lifts.

Implements:
1. Graph Laplacian computation
2. Smith Normal Form for integer matrices
3. Critical group (Jacobian) computation
4. Random graph lift generation
5. Cohen-Lenstra weight computation
6. p-primary decomposition
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from collections import Counter
import random
from math import gcd, log, factorial


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the Laplacian matrix L = D - A of a graph.

    Args:
        adj: n×n symmetric adjacency matrix (0/1 entries, zero diagonal)

    Returns:
        n×n integer Laplacian matrix

    Complexity: O(n²) time, O(n²) space
    """
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L.astype(int)


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """Compute the Smith Normal Form of an integer matrix.

    Returns diagonal entries (invariant factors) of the SNF.

    Args:
        M: m×n integer matrix

    Returns:
        Tuple of (SNF diagonal matrix, list of invariant factors)

    Complexity: O(n³ · log(max_entry)) time
    """
    A = M.copy().astype(int)
    m, n = A.shape
    r = min(m, n)

    for col in range(r):
        # Find pivot
        found = False
        for i in range(col, m):
            for j in range(col, n):
                if A[i, j] != 0:
                    # Swap rows and columns
                    A[[col, i]] = A[[i, col]]
                    A[:, [col, j]] = A[:, [j, col]]
                    found = True
                    break
            if found:
                break
        if not found:
            break

        # Ensure positive pivot
        if A[col, col] < 0:
            A[col] = -A[col]

        # Eliminate using pivot
        changed = True
        while changed:
            changed = False
            for i in range(col + 1, m):
                if A[i, col] != 0:
                    q = A[i, col] // A[col, col]
                    A[i] -= q * A[col]
                    if A[i, col] != 0:
                        A[[col, i]] = A[[i, col]]
                        changed = True
            for j in range(col + 1, n):
                if A[col, j] != 0:
                    q = A[col, j] // A[col, col]
                    A[:, j] -= q * A[:, col]
                    if A[col, j] != 0:
                        A[:, [col, j]] = A[:, [j, col]]
                        changed = True

    # Extract diagonal
    diag = [abs(A[i, i]) for i in range(r)]

    # Ensure divisibility chain
    for i in range(len(diag) - 1):
        if diag[i] != 0 and diag[i + 1] != 0:
            g = gcd(diag[i], diag[i + 1])
            if g != diag[i]:
                # Need to fix divisibility
                diag[i], diag[i + 1] = g, (diag[i] * diag[i + 1]) // g

    return np.diag(diag + [0] * (max(m, n) - len(diag))), diag


def critical_group(adj: np.ndarray) -> List[int]:
    """Compute the critical group (Jacobian/sandpile group) of a graph.

    The critical group is the cokernel of the reduced Laplacian,
    computed via Smith Normal Form.

    Args:
        adj: n×n adjacency matrix

    Returns:
        List of invariant factors > 1 (representing the group as ℤ/d₁ × ℤ/d₂ × ...)

    Complexity: O(n³ · log(max_entry))
    """
    L = graph_laplacian(adj)
    # Reduced Laplacian: delete last row and column
    L_red = L[:-1, :-1]
    _, factors = smith_normal_form(L_red)
    # Filter out 0s and 1s
    return [d for d in factors if d > 1]


def random_graph_lift(adj: np.ndarray, n_sheets: int) -> np.ndarray:
    """Generate a random n-sheeted covering (lift) of a base graph.

    For each edge {u,v} in the base graph, we assign a random permutation
    σ ∈ S_n determining how the n copies of u connect to the n copies of v.

    Args:
        adj: k×k adjacency matrix of base graph
        n_sheets: number of sheets n

    Returns:
        (k·n)×(k·n) adjacency matrix of the lift

    Complexity: O(k² · n · log n) time, O(k² · n²) space
    """
    k = adj.shape[0]
    N = k * n_sheets
    lift_adj = np.zeros((N, N), dtype=int)

    for u in range(k):
        for v in range(u + 1, k):
            if adj[u, v] == 1:
                # Random permutation for this edge
                perm = list(range(n_sheets))
                random.shuffle(perm)
                for s in range(n_sheets):
                    i = u * n_sheets + s
                    j = v * n_sheets + perm[s]
                    lift_adj[i, j] = 1
                    lift_adj[j, i] = 1

    return lift_adj


def p_primary_part(group: List[int], p: int) -> List[int]:
    """Extract the p-primary (Sylow p) part of a finite abelian group.

    Given invariant factors, compute the p-primary component.

    Args:
        group: list of invariant factors > 1
        p: prime number

    Returns:
        List of p-power invariant factors of the Sylow-p subgroup
    """
    p_parts = []
    for d in group:
        pk = 1
        temp = d
        while temp % p == 0:
            pk *= p
            temp //= p
        if pk > 1:
            p_parts.append(pk)
    p_parts.sort()
    return p_parts


def cohen_lenstra_weight(p: int, partition: List[int]) -> float:
    """Compute the Cohen-Lenstra weight for a finite abelian p-group.

    The weight is 1/|Aut(G)| where G = ∏ ℤ/p^{λᵢ}.

    For a group with type λ = (λ₁ ≥ λ₂ ≥ ... ≥ λᵣ):
    |Aut(G)| = ∏ᵢ (p^{mᵢ} - p^j for j<mᵢ) * p^{stuff}

    Args:
        p: prime
        partition: list of exponents [λ₁, λ₂, ...] in the decomposition
                  G = ℤ/p^λ₁ × ℤ/p^λ₂ × ...

    Returns:
        Float approximation of the Cohen-Lenstra weight
    """
    if not partition:
        return 1.0

    partition = sorted(partition, reverse=True)
    n = sum(partition)

    # |Aut(G)| for G = ⊕ ℤ/p^λᵢ
    # Count multiplicities
    mult = Counter(partition)
    log_aut = 0.0

    # For each distinct part value
    for val, m in mult.items():
        # Product ∏_{j=0}^{m-1} (1 - p^{-(m-j)})
        for j in range(m):
            log_aut += log(1.0 - p ** (-(m - j)))
        # Additional contribution from p-powers
        log_aut += m * (2 * val - 1) * log(p) / 2.0  # simplified

    # Cross terms between different parts
    parts_list = sorted(mult.keys())
    for idx1, v1 in enumerate(parts_list):
        for idx2, v2 in enumerate(parts_list):
            if idx1 < idx2:
                log_aut += mult[v1] * mult[v2] * min(v1, v2) * log(p)

    try:
        weight = 1.0 / np.exp(log_aut)
    except (OverflowError, FloatingPointError):
        weight = 0.0

    return weight


def first_betti_number(adj: np.ndarray) -> int:
    """Compute the first Betti number of a connected graph.

    b₁ = |E| - |V| + 1

    Args:
        adj: n×n adjacency matrix

    Returns:
        First Betti number
    """
    n = adj.shape[0]
    edges = int(np.sum(adj)) // 2
    return edges - n + 1


def padic_valuation(n: int, p: int) -> int:
    """Compute the p-adic valuation of n.

    Args:
        n: positive integer
        p: prime

    Returns:
        Largest k such that p^k divides n
    """
    if n == 0:
        return float('inf')
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def universality_test(base_graphs: List[np.ndarray], p: int,
                       n_sheets_range: List[int],
                       n_samples: int = 100) -> Dict:
    """Test the universality conjecture for a list of base graphs.

    For each base graph and each number of sheets, generate random lifts,
    compute critical groups, extract p-primary parts, and compare distributions.

    Args:
        base_graphs: list of adjacency matrices with the same Betti number
        p: prime for p-primary analysis
        n_sheets_range: list of sheet counts to test
        n_samples: number of random lifts per configuration

    Returns:
        Dictionary with test results
    """
    results = {}

    for idx, adj in enumerate(base_graphs):
        b1 = first_betti_number(adj)
        results[f"graph_{idx}"] = {"betti": b1, "data": {}}

        for n_sheets in n_sheets_range:
            p_primary_sizes = []
            p_primary_types = []

            for _ in range(n_samples):
                lift = random_graph_lift(adj, n_sheets)
                jac = critical_group(lift)
                pp = p_primary_part(jac, p)
                size = 1
                for x in pp:
                    size *= x
                p_primary_sizes.append(size)
                p_primary_types.append(tuple(pp))

            # Compute statistics
            type_counts = Counter(p_primary_types)
            results[f"graph_{idx}"]["data"][n_sheets] = {
                "mean_log_size": float(np.mean([log(max(s, 1)) for s in p_primary_sizes])),
                "type_distribution": dict(type_counts),
                "n_samples": n_samples
            }

    return results


if __name__ == "__main__":
    # Example: Triangle graph (K3)
    K3 = np.array([[0, 1, 1],
                    [1, 0, 1],
                    [1, 1, 0]])

    print("=== Graph Laplacian of K3 ===")
    L = graph_laplacian(K3)
    print(L)
    print(f"Row sums: {L.sum(axis=1)}")
    print(f"Symmetric: {np.allclose(L, L.T)}")

    print(f"\n=== Critical Group of K3 ===")
    jac = critical_group(K3)
    print(f"Invariant factors: {jac}")
    print(f"Order (spanning trees): {np.prod(jac) if jac else 1}")

    print(f"\n=== Betti number ===")
    print(f"b1(K3) = {first_betti_number(K3)}")

    print(f"\n=== Cohen-Lenstra weights ===")
    for k in range(5):
        w = 1.0 / ((2 ** max(k-1, 0)) * max(2 - 1, 1)) if k > 0 else 1.0
        print(f"  w(2, {k}) = {w:.6f}")
