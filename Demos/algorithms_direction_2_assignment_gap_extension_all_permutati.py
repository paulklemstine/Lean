"""
Algorithms for tropical assignment gap computation.

Implements exhaustive permutation search for the assignment gap,
transposition-only search, and classification of maximizing permutations.
"""

import numpy as np
from itertools import permutations
from typing import Tuple, List, Optional, Dict


def perm_weight(W: np.ndarray, sigma: List[int]) -> float:
    """Compute ∑_i W[i, sigma[i]] for a permutation sigma."""
    n = len(sigma)
    return sum(W[i, sigma[i]] for i in range(n))


def id_weight(W: np.ndarray) -> float:
    """Compute the identity assignment weight: ∑_i W[i,i]."""
    return float(np.trace(W))


def pair_deficit(W: np.ndarray, i: int, j: int) -> float:
    """Pairwise diagonal dominance deficit: W[i,i] + W[j,j] - 2*W[i,j]."""
    return W[i, i] + W[j, j] - 2 * W[i, j]


def all_permutations(n: int) -> List[List[int]]:
    """Generate all permutations of {0, ..., n-1}."""
    return [list(p) for p in permutations(range(n))]


def is_identity(sigma: List[int]) -> bool:
    """Check if sigma is the identity permutation."""
    return all(sigma[i] == i for i in range(len(sigma)))


def is_transposition(sigma: List[int]) -> bool:
    """Check if sigma swaps exactly two elements."""
    moved = [i for i in range(len(sigma)) if sigma[i] != i]
    if len(moved) != 2:
        return False
    a, b = moved
    return sigma[a] == b and sigma[b] == a


def cycle_structure(sigma: List[int]) -> List[List[int]]:
    """Decompose a permutation into its disjoint cycles."""
    n = len(sigma)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if visited[i] or sigma[i] == i:
            visited[i] = True
            continue
        cycle = []
        j = i
        while not visited[j]:
            visited[j] = True
            cycle.append(j)
            j = sigma[j]
        if len(cycle) > 1:
            cycles.append(cycle)
    return cycles


def classify_permutation(sigma: List[int]) -> str:
    """Classify a permutation by its cycle structure."""
    if is_identity(sigma):
        return "identity"
    if is_transposition(sigma):
        return "transposition"
    cycles = cycle_structure(sigma)
    lengths = sorted([len(c) for c in cycles], reverse=True)
    return f"cycles_{'-'.join(map(str, lengths))}"


def assignment_gap(W: np.ndarray) -> float:
    """
    Compute the full assignment gap: idWeight - max_{σ≠id} permWeight(σ).

    This is the energy barrier between the identity matching and
    the best alternative perfect matching.

    Complexity: O(n! * n) — exhaustive search over all permutations.
    """
    n = W.shape[0]
    assert n >= 2, "Need n >= 2"

    best_nonid = -np.inf
    for perm in all_permutations(n):
        if is_identity(perm):
            continue
        w = perm_weight(W, perm)
        if w > best_nonid:
            best_nonid = w
    return id_weight(W) - best_nonid


def best_transposition_weight(W: np.ndarray) -> float:
    """
    Compute the best transposition weight: max_{τ transposition} permWeight(τ).

    Complexity: O(n^2) — quadratic search over all pairs.
    """
    n = W.shape[0]
    best = -np.inf
    for i in range(n):
        for j in range(i + 1, n):
            # Transposition (i,j): swap entries i and j
            w = W[i, j] + W[j, i] + sum(W[k, k] for k in range(n) if k != i and k != j)
            if w > best:
                best = w
    return best


def trop_margin(W: np.ndarray) -> float:
    """
    Compute the tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j]).

    From the catalog definition in TropicalUniversality.
    """
    n = W.shape[0]
    margin = np.inf
    for i in range(n):
        for j in range(n):
            if i != j:
                slack = 2 * W[i, j] - W[i, i] - W[j, j]
                margin = min(margin, slack)
    return margin


def find_best_competitor(W: np.ndarray) -> Tuple[List[int], float, str]:
    """
    Find the best non-identity competitor permutation.

    Returns: (permutation, weight, classification)
    """
    n = W.shape[0]
    best_perm = None
    best_weight = -np.inf

    for perm in all_permutations(n):
        if is_identity(perm):
            continue
        w = perm_weight(W, perm)
        if w > best_weight:
            best_weight = w
            best_perm = perm

    return best_perm, best_weight, classify_permutation(best_perm)


def check_symmetric_diagonal_dominance(W: np.ndarray) -> Tuple[bool, bool]:
    """
    Check if W satisfies:
    1. Symmetry: W[i,j] = W[j,i] for all i,j
    2. Pairwise diagonal dominance: W[i,i]+W[j,j] > 2*W[i,j] for all i≠j

    Returns: (is_symmetric, has_diagonal_dominance)
    """
    n = W.shape[0]
    sym = np.allclose(W, W.T)
    dom = True
    for i in range(n):
        for j in range(n):
            if i != j and W[i, i] + W[j, j] <= 2 * W[i, j]:
                dom = False
                break
        if not dom:
            break
    return sym, dom


def verify_transposition_dominance(W: np.ndarray) -> Dict:
    """
    Verify whether transpositions realize the assignment gap.

    Returns a dict with:
    - 'gap': the assignment gap
    - 'trop_margin': the tropical margin
    - 'best_competitor': the best non-id permutation
    - 'best_type': classification of the best competitor
    - 'transposition_dominant': whether best competitor is a transposition
    - 'gap_equals_neg_margin': whether gap = -tropMargin (for symmetric W)
    """
    n = W.shape[0]
    gap = assignment_gap(W)
    margin = trop_margin(W)
    best_perm, best_w, best_type = find_best_competitor(W)
    is_sym, has_dom = check_symmetric_diagonal_dominance(W)

    return {
        'n': n,
        'gap': gap,
        'trop_margin': margin,
        'best_competitor': best_perm,
        'best_type': best_type,
        'transposition_dominant': is_transposition(best_perm),
        'is_symmetric': is_sym,
        'has_diagonal_dominance': has_dom,
        'gap_equals_neg_margin': is_sym and np.isclose(gap, -margin),
    }


if __name__ == "__main__":
    # Example: symmetric diagonally dominant matrix
    print("=" * 60)
    print("Example 1: Symmetric diagonally dominant matrix")
    W = np.array([
        [5.0, 1.0, 2.0],
        [1.0, 6.0, 1.5],
        [2.0, 1.5, 4.0]
    ])
    result = verify_transposition_dominance(W)
    print(f"  Matrix:\n{W}")
    print(f"  Assignment gap: {result['gap']:.4f}")
    print(f"  Tropical margin: {result['trop_margin']:.4f}")
    print(f"  Best competitor type: {result['best_type']}")
    print(f"  Transposition dominant: {result['transposition_dominant']}")
    print(f"  gap = -margin: {result['gap_equals_neg_margin']}")

    # Example: random Gaussian matrix (symmetric)
    print("\n" + "=" * 60)
    print("Example 2: Random symmetric Gaussian + diagonal boost")
    np.random.seed(42)
    n = 4
    G = np.random.randn(n, n)
    W2 = (G + G.T) / 2 + 5 * np.eye(n)
    result2 = verify_transposition_dominance(W2)
    print(f"  n = {n}")
    print(f"  Assignment gap: {result2['gap']:.4f}")
    print(f"  Best competitor type: {result2['best_type']}")
    print(f"  Transposition dominant: {result2['transposition_dominant']}")
    print(f"  Has diagonal dominance: {result2['has_diagonal_dominance']}")
