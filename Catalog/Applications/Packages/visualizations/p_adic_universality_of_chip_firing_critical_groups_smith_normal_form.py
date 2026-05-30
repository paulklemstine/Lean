"""
Algorithms for p-adic Universality of Chip-Firing Critical Groups

Implements:
1. Graph Laplacian computation
2. Smith Normal Form for integer matrices
3. Critical group (Jacobian) computation via SNF
4. Random graph lift generation
5. Sylow-p extraction
6. Cohen-Lenstra probability computation
"""

import numpy as np
from typing import List, Tuple, Optional
from collections import Counter
import random
import math


# ============================================================
# Algorithm 1: Smith Normal Form (SNF)
# ============================================================

def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """
    Compute the Smith Normal Form of an integer matrix M.

    The SNF is a diagonal matrix D = U M V where U, V are unimodular,
    and the diagonal entries d_1 | d_2 | ... | d_r are the invariant factors.

    Time complexity: O(n^3 · log(max|M_ij|)) in practice
    Space complexity: O(n^2)

    Args:
        M: Integer matrix (n × m)

    Returns:
        (D, invariant_factors): Diagonal matrix and list of non-unit invariant factors
    """
    M = M.astype(int).tolist()
    n = len(M)
    m = len(M[0]) if n > 0 else 0

    for k in range(min(n, m)):
        # Find a nonzero pivot in the submatrix M[k:, k:]
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i][j] != 0:
                    # Swap rows k and i
                    M[k], M[i] = M[i], M[k]
                    # Swap columns k and j
                    for row in M:
                        row[k], row[j] = row[j], row[k]
                    found = True
                    break
            if found:
                break
        if not found:
            continue

        # Iterate until M[k][k] divides all entries in row k and column k
        changed = True
        while changed:
            changed = False
            if M[k][k] < 0:
                for j in range(m):
                    M[k][j] = -M[k][j]

            # Eliminate column entries below pivot
            for i in range(k + 1, n):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j in range(m):
                        M[i][j] -= q * M[k][j]
                    if M[i][k] != 0:
                        M[k], M[i] = M[i], M[k]
                        changed = True

            # Eliminate row entries to the right of pivot
            for j in range(k + 1, m):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i in range(n):
                        M[i][j] -= q * M[i][k]
                    if M[k][j] != 0:
                        for i in range(n):
                            M[i][k], M[i][j] = M[i][j], M[i][k]
                        changed = True

    D = np.array(M)
    diag = [abs(M[i][i]) for i in range(min(n, m))]
    invariant_factors = [d for d in diag if d > 1]
    return D, invariant_factors


# ============================================================
# Algorithm 2: Graph Laplacian and Critical Group
# ============================================================

def compute_laplacian(adj: np.ndarray) -> np.ndarray:
    """
    Compute the graph Laplacian L = D - A.

    L is positive semidefinite with kernel spanned by the all-ones vector
    for connected graphs.

    Time: O(n²), Space: O(n²)
    """
    deg = np.diag(adj.sum(axis=1).astype(int))
    return deg - adj.astype(int)


def compute_critical_group(adj: np.ndarray) -> Tuple[List[int], int]:
    """
    Compute the critical group Jac(G) of a graph.

    The critical group is isomorphic to ℤ^(n-1) / Im(L̃)
    where L̃ is the reduced Laplacian.

    By Kirchhoff's matrix tree theorem, |Jac(G)| = number of spanning trees.

    Time: O(n³ · log(max entry))
    Space: O(n²)

    Returns:
        (invariant_factors, order): Group structure and order
    """
    L = compute_laplacian(adj)
    Lr = L[:-1, :-1]  # Reduced Laplacian
    _, inv_factors = smith_normal_form(Lr)
    order = 1
    for d in inv_factors:
        order *= d
    return inv_factors, order


# ============================================================
# Algorithm 3: Random Graph Lift
# ============================================================

def generate_random_lift(adj: np.ndarray, n_sheets: int,
                         seed: Optional[int] = None) -> np.ndarray:
    """
    Generate a random n-sheeted covering (lift) of a graph.

    For each edge {u,v}, assign a uniformly random permutation σ_{uv} ∈ S_n.
    The lift graph has:
    - Vertices: V × {0, ..., n-1}
    - Edges: {(u,i), (v, σ_{uv}(i))} for each base edge {u,v} and i ∈ [n]

    This is the standard model for random graph covers (Friedman, 2003).

    Time: O(|E| · n)
    Space: O(n² · |V|²)

    Args:
        adj: Adjacency matrix of base graph
        n_sheets: Number of sheets
        seed: Random seed for reproducibility

    Returns:
        Adjacency matrix of the lift
    """
    if seed is not None:
        random.seed(seed)

    num_v = adj.shape[0]
    total = num_v * n_sheets
    lift = np.zeros((total, total), dtype=int)

    for u in range(num_v):
        for v in range(u + 1, num_v):
            if adj[u][v] > 0:
                perm = list(range(n_sheets))
                random.shuffle(perm)
                for i in range(n_sheets):
                    u_lift = u * n_sheets + i
                    v_lift = v * n_sheets + perm[i]
                    lift[u_lift][v_lift] = 1
                    lift[v_lift][u_lift] = 1

    return lift


# ============================================================
# Algorithm 4: Sylow-p Subgroup Extraction
# ============================================================

def extract_sylow_p(invariant_factors: List[int], p: int) -> List[int]:
    """
    Extract the Sylow-p subgroup from invariant factors.

    For each invariant factor d, compute v_p(d) = max k such that p^k | d.
    The p-primary part is ⊕ ℤ/p^{v_p(d_i)}.

    Time: O(r · log(max d_i) / log p) where r = number of factors
    """
    p_parts = []
    for d in invariant_factors:
        pk = 1
        temp = d
        while temp % p == 0:
            pk *= p
            temp //= p
        if pk > 1:
            p_parts.append(pk)
    return sorted(p_parts)


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n) = max k such that p^k divides n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


# ============================================================
# Algorithm 5: Cohen-Lenstra Distribution
# ============================================================

def cohen_lenstra_probability(p: int, b1: int, group_type: Tuple[int, ...],
                               max_terms: int = 20) -> float:
    """
    Compute the Cohen-Lenstra probability for a given p-group type.

    For the conjectured universal distribution with Betti number b1,
    the probability of a p-group of type λ = (λ_1, ..., λ_r) is:

    P(λ) ∝ 1 / |Aut(G_λ)| · (size correction)

    For the simplest case (trivial group, rank 0):
    P(trivial) = ∏_{i=1}^{b1} (1 - p^{-i})

    This is the probability that a random b1×b1 matrix over Z_p is invertible.

    Time: O(max_terms)

    Args:
        p: Prime
        b1: First Betti number of base graph
        group_type: Tuple of p-powers giving the p-group type
        max_terms: Number of terms in infinite product approximation

    Returns:
        Approximate probability
    """
    if len(group_type) == 0:
        # Probability of trivial Sylow-p: random matrix invertibility over Z_p
        prob = 1.0
        for i in range(1, b1 + 1):
            prob *= (1 - p ** (-i))
        return prob
    else:
        # For non-trivial types, use the general Cohen-Lenstra weight
        # This is an approximation based on the heuristic
        r = len(group_type)
        if r > b1:
            return 0.0  # rank cannot exceed b1

        # Weight = 1/|Aut(G_λ)| · correction
        total_size = 1
        for pk in group_type:
            total_size *= pk

        # Automorphism group order approximation for cyclic p-groups
        aut_order = 1
        for pk in group_type:
            k = int(round(math.log(pk) / math.log(p)))
            aut_order *= pk - pk // p  # Euler's phi

        inv_aut = 1.0 / aut_order
        # Normalization: multiply by matrix count factor
        factor = p ** (-(sum(int(round(math.log(pk)/math.log(p))) for pk in group_type)))

        return inv_aut * factor


def universality_test(graphs: List[np.ndarray], p: int, n_sheets: int,
                      num_samples: int = 500) -> dict:
    """
    Test the universality conjecture by comparing p-rank distributions
    across graphs with the same Betti number.

    Returns a dictionary mapping graph index to p-rank distribution.
    """
    results = {}
    for idx, G in enumerate(graphs):
        b1 = int(G.sum()) // 2 - G.shape[0] + 1
        p_ranks = []
        for _ in range(num_samples):
            lift = generate_random_lift(G, n_sheets)
            inv, _ = compute_critical_group(lift)
            pr = len(extract_sylow_p(inv, p))
            p_ranks.append(pr)

        dist = Counter(p_ranks)
        total = sum(dist.values())
        norm_dist = {k: v / total for k, v in sorted(dist.items())}
        results[idx] = {
            'betti': b1,
            'distribution': norm_dist,
            'mean_rank': sum(p_ranks) / len(p_ranks),
            'samples': num_samples
        }

    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: Triangle (K_3)
    K3 = np.array([[0, 1, 1],
                    [1, 0, 1],
                    [1, 1, 0]])

    print("K₃ Laplacian:")
    print(compute_laplacian(K3))

    inv, order = compute_critical_group(K3)
    print(f"Jac(K₃) = Z/{' × Z/'.join(map(str, inv))}, order = {order}")
    print(f"(Kirchhoff: K₃ has {order} spanning trees)")

    # Random 3-sheeted lift
    lift = generate_random_lift(K3, 3, seed=42)
    inv_lift, order_lift = compute_critical_group(lift)
    print(f"\nRandom 3-sheeted lift of K₃:")
    print(f"Jac = Z/{' × Z/'.join(map(str, inv_lift))}, order = {order_lift}")
    print(f"Sylow-2: {extract_sylow_p(inv_lift, 2)}")
    print(f"Sylow-3: {extract_sylow_p(inv_lift, 3)}")
