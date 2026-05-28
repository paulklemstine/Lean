#!/usr/bin/env python3
"""
Algorithms for Submodular Set Function Analysis

Implements algorithms for:
1. Submodularity checking via exhaustive enumeration
2. Greedy maximization of submodular functions
3. Diminishing returns verification
4. Principal minor computation and log-det analysis

All algorithms operate on set functions W: 2^[n] → ℝ represented
as dictionaries mapping frozensets to real values.

Complexity Analysis:
- Submodularity check: O(4^n) time, O(2^n) space
- Greedy maximization: O(n^2 · T_eval) time, O(n) space
- Diminishing returns check: O(3^n · n) time, O(2^n) space
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Optional, Callable


def principal_minor(K: np.ndarray, subset: tuple) -> float:
    """Compute det K[S] for a subset S of indices.
    
    Args:
        K: n×n matrix (numpy array)
        subset: tuple of indices
    
    Returns:
        Determinant of the principal submatrix K[S, S]
    
    Time complexity: O(|S|^3) for the determinant computation.
    """
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return float(np.linalg.det(K[np.ix_(idx, idx)]))


def compute_log_det_function(K: np.ndarray) -> Dict[tuple, float]:
    """Compute W(S) = log det K[S] for all subsets S ⊆ [n].
    
    Args:
        K: n×n PSD matrix
    
    Returns:
        Dictionary mapping subset tuples to log-det values
    
    Time complexity: O(2^n · n^3) — one determinant per subset.
    Space complexity: O(2^n).
    """
    n = K.shape[0]
    W = {}
    for r in range(n + 1):
        for S in combinations(range(n), r):
            det_val = principal_minor(K, S)
            W[S] = np.log(max(det_val, 1e-300))
    return W


def check_submodularity(W: Dict[tuple, float], n: int,
                         tol: float = 1e-10) -> Tuple[bool, List[dict]]:
    """Check if W: 2^[n] → ℝ is submodular by exhaustive enumeration.
    
    Tests all pairs (A, B) for the inequality:
        W(A) + W(B) ≥ W(A ∩ B) + W(A ∪ B)
    
    Args:
        W: set function as dict from subset tuples to reals
        n: size of ground set
        tol: numerical tolerance for violations
    
    Returns:
        (is_submodular, violations): bool and list of violation dicts
    
    Time complexity: O(4^n) — iterate all pairs of subsets.
    Space complexity: O(2^n) for storing W.
    
    Pseudocode:
        for each A ⊆ [n]:
            for each B ⊆ [n]:
                if W(A) + W(B) < W(A∩B) + W(A∪B) - tol:
                    report violation
    """
    subsets = []
    for r in range(n + 1):
        for S in combinations(range(n), r):
            subsets.append(S)
    
    violations = []
    for A in subsets:
        for B in subsets:
            A_set, B_set = set(A), set(B)
            inter = tuple(sorted(A_set & B_set))
            union = tuple(sorted(A_set | B_set))
            
            lhs = W[A] + W[B]
            rhs = W[inter] + W[union]
            
            if lhs < rhs - tol:
                violations.append({
                    'A': A, 'B': B,
                    'deficit': rhs - lhs
                })
    
    return len(violations) == 0, violations


def check_diminishing_returns(W: Dict[tuple, float], n: int,
                               tol: float = 1e-10) -> Tuple[bool, List[dict]]:
    """Check diminishing marginal returns property.
    
    For all A ⊆ B ⊆ [n] and e ∉ B:
        W(B ∪ {e}) - W(B) ≤ W(A ∪ {e}) - W(A)
    
    This is equivalent to submodularity (proven in our Lean formalization).
    
    Time complexity: O(3^n · n) — enumerate subset pairs and elements.
    """
    subsets = []
    for r in range(n + 1):
        for S in combinations(range(n), r):
            subsets.append(S)
    
    violations = []
    for A in subsets:
        for B in subsets:
            A_set, B_set = set(A), set(B)
            if not A_set.issubset(B_set):
                continue
            for e in range(n):
                if e in B_set:
                    continue
                Ae = tuple(sorted(A_set | {e}))
                Be = tuple(sorted(B_set | {e}))
                
                if W[Be] - W[B] > W[Ae] - W[A] + tol:
                    violations.append({
                        'A': A, 'B': B, 'e': e,
                        'marginal_A': W[Ae] - W[A],
                        'marginal_B': W[Be] - W[B]
                    })
    
    return len(violations) == 0, violations


def greedy_maximize(W: Callable[[tuple], float], n: int, k: int) -> Tuple[tuple, float]:
    """Greedy algorithm for maximizing a monotone submodular function.
    
    Implements the classical greedy algorithm that achieves a (1-1/e)
    approximation ratio for monotone submodular maximization under
    a cardinality constraint.
    
    Args:
        W: set function (callable taking a tuple, returning float)
        n: ground set size
        k: cardinality constraint (select at most k elements)
    
    Returns:
        (selected_set, value): the greedily selected set and its W-value
    
    Time complexity: O(n·k) function evaluations.
    Space complexity: O(n).
    
    Pseudocode:
        S ← ∅
        for i = 1 to k:
            e* ← argmax_{e ∉ S} W(S ∪ {e}) - W(S)
            S ← S ∪ {e*}
        return S
    """
    selected = set()
    current_val = W(())
    
    for _ in range(k):
        best_gain = -np.inf
        best_elem = None
        
        for e in range(n):
            if e in selected:
                continue
            new_set = tuple(sorted(selected | {e}))
            gain = W(new_set) - current_val
            if gain > best_gain:
                best_gain = gain
                best_elem = e
        
        if best_elem is not None:
            selected.add(best_elem)
            current_val += best_gain
    
    return tuple(sorted(selected)), current_val


def random_psd_kernel(n: int, rank: Optional[int] = None,
                       regularization: float = 0.01,
                       seed: Optional[int] = None) -> np.ndarray:
    """Generate a random n×n positive semidefinite kernel.
    
    Constructs K = M^T M + εI where M is a rank×n Gaussian matrix
    and ε is a small regularization parameter ensuring strict positivity.
    
    Args:
        n: matrix size
        rank: rank of the Gram component (default: n)
        regularization: diagonal regularization ε
        seed: random seed
    
    Returns:
        n×n PSD matrix K
    """
    if seed is not None:
        np.random.seed(seed)
    if rank is None:
        rank = n
    M = np.random.randn(rank, n)
    K = M.T @ M + regularization * np.eye(n)
    return K


def lovasz_extension(W: Dict[tuple, float], n: int, x: np.ndarray) -> float:
    """Compute the Lovász extension of a submodular function at point x ∈ [0,1]^n.
    
    The Lovász extension is:
        f^(x) = ∫_0^1 W({i : x_i ≥ t}) dt
    
    Computed via the permutation formula:
        Sort x so x_{π(1)} ≥ ... ≥ x_{π(n)}.
        f^(x) = W(∅) + Σ_i (x_{π(i)} - x_{π(i+1)}) · W({π(1),...,π(i)})
    where x_{π(n+1)} = 0.
    
    For submodular W, the Lovász extension is concave.
    
    Args:
        W: set function as dict
        n: ground set size
        x: point in [0,1]^n
    
    Returns:
        Value of the Lovász extension at x
    
    Time complexity: O(n log n) plus O(n) function evaluations.
    """
    perm = np.argsort(-x)  # descending sort
    x_sorted = x[perm]
    
    result = W[()]  # W(∅)
    for i in range(n):
        S = tuple(sorted(perm[:i + 1].tolist()))
        next_x = x_sorted[i + 1] if i + 1 < n else 0.0
        result += (x_sorted[i] - next_x) * W[S]
    
    return result


def check_lovasz_concavity(W: Dict[tuple, float], n: int,
                            num_samples: int = 1000,
                            seed: int = 42) -> Tuple[bool, float]:
    """Check midpoint concavity of the Lovász extension.
    
    Tests: f^((x+y)/2) ≥ (f^(x) + f^(y))/2 for random x, y ∈ [0,1]^n.
    
    Returns:
        (is_concave, worst_violation): bool and worst violation magnitude
    """
    np.random.seed(seed)
    worst = 0.0
    
    for _ in range(num_samples):
        x = np.random.rand(n)
        y = np.random.rand(n)
        mid = (x + y) / 2
        
        f_mid = lovasz_extension(W, n, mid)
        f_avg = (lovasz_extension(W, n, x) + lovasz_extension(W, n, y)) / 2
        
        violation = f_avg - f_mid
        worst = max(worst, violation)
    
    return worst < 1e-10, worst


if __name__ == '__main__':
    print("Algorithms for Submodular Set Function Analysis")
    print("=" * 50)
    
    # Example: log-det of a PSD kernel
    n = 4
    K = random_psd_kernel(n, seed=42)
    W = compute_log_det_function(K)
    
    print(f"\nGround set size: n = {n}")
    print(f"Kernel eigenvalues: {np.sort(np.linalg.eigvalsh(K))[::-1]}")
    
    # Check submodularity
    is_sub, violations = check_submodularity(W, n)
    print(f"\nSubmodularity: {'PASS' if is_sub else 'FAIL'}")
    
    # Check diminishing returns
    is_dr, dr_viol = check_diminishing_returns(W, n)
    print(f"Diminishing returns: {'PASS' if is_dr else 'FAIL'}")
    
    # Greedy maximization
    W_func = lambda S: W.get(S, W.get(tuple(sorted(S)), -np.inf))
    greedy_set, greedy_val = greedy_maximize(W_func, n, k=2)
    print(f"\nGreedy solution (k=2): {greedy_set}, value = {greedy_val:.4f}")
    
    # Find optimal k=2 subset
    best_val = -np.inf
    best_set = None
    for S in combinations(range(n), 2):
        if W[S] > best_val:
            best_val = W[S]
            best_set = S
    print(f"Optimal solution (k=2): {best_set}, value = {best_val:.4f}")
    print(f"Greedy ratio: {greedy_val / best_val:.4f}")
    
    # Lovász extension concavity
    is_concave, worst = check_lovasz_concavity(W, n)
    print(f"\nLovász extension concavity: {'PASS' if is_concave else 'FAIL'}")
    print(f"Worst midpoint violation: {worst:.2e}")
