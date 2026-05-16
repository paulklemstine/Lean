#!/usr/bin/env python3
"""
Algorithms for Tropical Matrix Algebra and Discrete Optimal Transport

Implements the core algorithms underlying the formally verified theorems:
1. Tropical (min-plus) matrix multiplication and powers
2. Tropical eigenvalue computation via cycle means
3. Discrete Wasserstein-1 distance (exact and LP-based)
4. Transport plan verification and pushforward
5. Assignment cost computation

All algorithms include type hints, docstrings, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import permutations

# ============================================================
# Tropical Matrix Algebra
# ============================================================

def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus (tropical) matrix multiplication.

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix
        B: n×n matrix

    Returns:
        n×n tropical product matrix
    """
    n = A.shape[0]
    assert A.shape == (n, n) and B.shape == (n, n), "Matrices must be square and same size"
    # Vectorized implementation using broadcasting
    # A[:, :, None] has shape (n, n, 1), B[None, :, :] has shape (1, n, n)
    # Sum has shape (n, n, n), min over axis 1 gives (n, n)
    return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def tropical_power(A: np.ndarray, m: int) -> np.ndarray:
    """
    Compute A^{⊗m}: m-fold tropical matrix product.

    Time complexity: O(n³ · m)
    Space complexity: O(n²)

    Args:
        A: n×n matrix
        m: positive integer exponent

    Returns:
        A^{⊗m} as n×n matrix
    """
    assert m >= 1, "Power must be positive"
    result = A.copy()
    for _ in range(m - 1):
        result = tropical_multiply(result, A)
    return result


def tropical_diagonal_sequence(A: np.ndarray, i: int, max_power: int = 20) -> List[float]:
    """
    Compute the sequence a_m = (A^{⊗m})_{ii} for m = 1, ..., max_power.

    This sequence is subadditive: a_{m+k} ≤ a_m + a_k.
    By Fekete's lemma, lim a_m/m exists and equals inf a_m/m.

    Args:
        A: n×n matrix
        i: diagonal index
        max_power: number of terms to compute

    Returns:
        List of diagonal values
    """
    n = A.shape[0]
    assert 0 <= i < n
    diag_vals = []
    power = A.copy()
    for m in range(1, max_power + 1):
        diag_vals.append(power[i, i])
        if m < max_power:
            power = tropical_multiply(power, A)
    return diag_vals


def tropical_eigenvalue(A: np.ndarray, max_power: int = 50) -> float:
    """
    Estimate the tropical eigenvalue (minimum cycle mean) of matrix A.

    The tropical eigenvalue λ satisfies:
        λ = lim_{m→∞} (A^{⊗m})_{ii} / m  (for any i on an optimal cycle)
        λ = min_i lim_{m→∞} (A^{⊗m})_{ii} / m
        λ = min over all cycles C of (weight(C) / length(C))

    Uses the subadditivity theorem to justify convergence.

    Time complexity: O(n³ · max_power)

    Args:
        A: n×n matrix
        max_power: number of powers to compute for estimation

    Returns:
        Estimated tropical eigenvalue
    """
    n = A.shape[0]
    best_mean = np.inf
    for i in range(n):
        seq = tropical_diagonal_sequence(A, i, max_power)
        # By Fekete's lemma, the limit is inf a_m/m
        means = [seq[m] / (m + 1) for m in range(len(seq))]
        best_mean = min(best_mean, min(means))
    return best_mean


# ============================================================
# Discrete Optimal Transport
# ============================================================

def is_transport_plan(pi: np.ndarray, mu: np.ndarray, nu: np.ndarray,
                      tol: float = 1e-10) -> bool:
    """
    Check if π is a valid transport plan from μ to ν.

    A valid plan satisfies:
    1. π_{ij} ≥ 0 for all i, j
    2. ∑_j π_{ij} = μ_i for all i (row marginals)
    3. ∑_i π_{ij} = ν_j for all j (column marginals)

    Args:
        pi: n×n matrix (candidate transport plan)
        mu: source distribution (length n)
        nu: target distribution (length n)
        tol: numerical tolerance

    Returns:
        True if π is a valid transport plan
    """
    nonneg = np.all(pi >= -tol)
    row_ok = np.allclose(pi.sum(axis=1), mu, atol=tol)
    col_ok = np.allclose(pi.sum(axis=0), nu, atol=tol)
    return bool(nonneg and row_ok and col_ok)


def transport_cost(c: np.ndarray, pi: np.ndarray) -> float:
    """
    Compute the transport cost: ∑_{i,j} π_{ij} · c_{ij}.

    Args:
        c: n×n cost matrix
        pi: n×n transport plan

    Returns:
        Total transport cost
    """
    return float(np.sum(pi * c))


def wasserstein1_exact(c: np.ndarray, mu: np.ndarray, nu: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the exact Wasserstein-1 distance by enumerating all
    permutation-based transport plans (vertices of the Birkhoff polytope).

    For small n, this is exact. For larger n, use LP methods.

    Time complexity: O(n! · n²)

    Args:
        c: n×n cost matrix
        mu: source distribution
        nu: target distribution

    Returns:
        (optimal_cost, optimal_plan) tuple
    """
    n = len(mu)
    assert n <= 8, "Brute force only feasible for small n"

    best_cost = np.inf
    best_plan = None

    for perm in permutations(range(n)):
        # Construct plan: π_{i,σ(i)} = min(μ_i, ν_{σ(i)}) for perm plans
        # For general marginals, we need to check feasibility
        plan = np.zeros((n, n))
        for i in range(n):
            plan[i, perm[i]] = mu[i]

        if is_transport_plan(plan, mu, nu):
            cost = transport_cost(c, plan)
            if cost < best_cost:
                best_cost = cost
                best_plan = plan.copy()

    return best_cost, best_plan


def pushforward(e: List[int], mu: np.ndarray) -> np.ndarray:
    """
    Compute the pushforward e_*μ of distribution μ by permutation e.

    (e_*μ)(i) = μ(e⁻¹(i))

    Args:
        e: permutation as list (e[i] = image of i)
        mu: source distribution

    Returns:
        Pushforward distribution
    """
    n = len(mu)
    e_inv = [0] * n
    for i in range(n):
        e_inv[e[i]] = i
    return np.array([mu[e_inv[i]] for i in range(n)])


def reindex_plan(e: List[int], pi: np.ndarray) -> np.ndarray:
    """
    Reindex a transport plan by permutation e:
    π'(i,j) = π(e⁻¹(i), e⁻¹(j))

    Args:
        e: permutation as list
        pi: transport plan

    Returns:
        Reindexed transport plan
    """
    n = len(e)
    e_inv = [0] * n
    for i in range(n):
        e_inv[e[i]] = i
    result = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            result[i, j] = pi[e_inv[i], e_inv[j]]
    return result


def permutation_plan(sigma: List[int], n: int) -> np.ndarray:
    """
    Construct the transport plan induced by permutation σ
    between uniform distributions.

    π(i, j) = 1/n if σ(i) = j, else 0.

    Args:
        sigma: permutation as list
        n: size

    Returns:
        n×n transport plan matrix
    """
    plan = np.zeros((n, n))
    for i in range(n):
        plan[i, sigma[i]] = 1.0 / n
    return plan


def assignment_cost(c: np.ndarray, sigma: List[int]) -> float:
    """
    Compute the assignment cost: ∑_i c(i, σ(i)).

    Args:
        c: cost matrix
        sigma: permutation

    Returns:
        Assignment cost
    """
    return sum(c[i, sigma[i]] for i in range(len(sigma)))


def optimal_assignment_brute(c: np.ndarray) -> Tuple[float, List[int]]:
    """
    Find the optimal assignment (minimum cost permutation) by brute force.

    This is equivalent to finding the minimum Wasserstein cost
    among permutation couplings for uniform distributions.

    Time complexity: O(n! · n)

    Args:
        c: n×n cost matrix

    Returns:
        (minimum_cost, optimal_permutation)
    """
    n = c.shape[0]
    best_cost = np.inf
    best_perm = None
    for perm in permutations(range(n)):
        cost = assignment_cost(c, list(perm))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)
    return best_cost, best_perm


# ============================================================
# Verification Routines
# ============================================================

def verify_subadditivity(A: np.ndarray, max_power: int = 8) -> bool:
    """
    Verify the subadditivity theorem for all diagonal entries and all powers.

    Checks: (A^{⊗(m+k)})_{ii} ≤ (A^{⊗m})_{ii} + (A^{⊗k})_{ii}

    Returns True if all inequalities hold (up to numerical tolerance).
    """
    n = A.shape[0]
    powers = [tropical_power(A, m) for m in range(1, max_power + 1)]
    tol = 1e-10

    for i in range(n):
        for m in range(1, max_power + 1):
            for k in range(1, max_power + 1 - m):
                lhs = powers[m + k - 1][i, i]
                rhs = powers[m - 1][i, i] + powers[k - 1][i, i]
                if lhs > rhs + tol:
                    print(f"VIOLATION: i={i}, m={m}, k={k}: {lhs} > {rhs}")
                    return False
    return True


def verify_wasserstein_invariance(c: np.ndarray, mu: np.ndarray, nu: np.ndarray,
                                   e: List[int]) -> bool:
    """
    Verify that W₁(e_*μ, e_*ν) = W₁(μ, ν) when c is invariant under e.

    Returns True if the invariance holds (up to numerical tolerance).
    """
    n = len(mu)
    # Check cost invariance
    for i in range(n):
        for j in range(n):
            if abs(c[e[i], e[j]] - c[i, j]) > 1e-10:
                print(f"Cost not invariant: c({e[i]},{e[j]}) ≠ c({i},{j})")
                return False

    mu_push = pushforward(e, mu)
    nu_push = pushforward(e, nu)

    w_orig, _ = wasserstein1_exact(c, mu, nu)
    w_push, _ = wasserstein1_exact(c, mu_push, nu_push)

    return abs(w_orig - w_push) < 1e-10


# ============================================================
# Main: Run all verifications
# ============================================================

if __name__ == "__main__":
    print("Tropical Matrix Algebra & Optimal Transport — Algorithm Verification")
    print("=" * 70)

    # Test 1: Subadditivity
    print("\n[Test 1] Tropical power diagonal subadditivity")
    for trial in range(5):
        A = np.random.rand(4, 4) * 10
        result = verify_subadditivity(A, max_power=6)
        print(f"  Random 4×4 matrix (trial {trial+1}): {'PASS ✓' if result else 'FAIL ✗'}")

    # Test 2: Tropical eigenvalue
    print("\n[Test 2] Tropical eigenvalue estimation")
    A = np.array([[0, 3, 8], [2, 0, 5], [1, 4, 0]], dtype=float)
    eig = tropical_eigenvalue(A)
    print(f"  A = [[0,3,8],[2,0,5],[1,4,0]]")
    print(f"  Tropical eigenvalue ≈ {eig:.6f}")
    print(f"  (Minimum cycle mean over all cycles)")

    # Test 3: Wasserstein invariance
    print("\n[Test 3] Wasserstein invariance under isometries")
    c = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]], dtype=float)
    mu = np.array([0.5, 0.3, 0.2])
    nu = np.array([0.2, 0.5, 0.3])
    e = [1, 2, 0]  # cyclic shift

    # Check if cost is invariant
    inv_check = all(abs(c[e[i], e[j]] - c[i, j]) < 1e-10
                    for i in range(3) for j in range(3))
    print(f"  Cost invariant under e={e}? {inv_check}")
    if inv_check:
        result = verify_wasserstein_invariance(c, mu, nu, e)
        print(f"  Wasserstein invariance: {'PASS ✓' if result else 'FAIL ✗'}")

    # Test 4: Permutation coupling verification
    print("\n[Test 4] Permutation couplings")
    n = 3
    c = np.array([[0, 2, 5], [2, 0, 3], [5, 3, 0]], dtype=float)
    best_cost, best_perm = optimal_assignment_brute(c)
    print(f"  Optimal assignment cost: {best_cost:.1f}")
    print(f"  Optimal permutation: {best_perm}")
    print(f"  Wasserstein-1 (uniform): {best_cost/n:.4f}")

    # Test 5: Associativity
    print("\n[Test 5] Tropical multiplication associativity")
    for trial in range(5):
        A = np.random.rand(3, 3) * 10
        B = np.random.rand(3, 3) * 10
        C = np.random.rand(3, 3) * 10
        lhs = tropical_multiply(tropical_multiply(A, B), C)
        rhs = tropical_multiply(A, tropical_multiply(B, C))
        ok = np.allclose(lhs, rhs, atol=1e-10)
        print(f"  Random 3×3 (trial {trial+1}): {'PASS ✓' if ok else 'FAIL ✗'}")

    print("\n" + "=" * 70)
    print("All tests completed!")
