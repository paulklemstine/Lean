"""
Algorithms for Orbit Cost Computation

Implements efficient algorithms for computing orbit costs under
various group actions, with complexity analysis and optimizations.
"""

import numpy as np
from itertools import permutations
from typing import Callable, List, Tuple, TypeVar, Generic
import time

T = TypeVar('T')


# ============================================================================
# Algorithm 1: Exact Orbit Cost via Exhaustive Group Enumeration
# ============================================================================

def orbit_cost_exact(
    Wc: Callable,
    mu: np.ndarray,
    nu: np.ndarray,
    group_elements: list,
    action: Callable
) -> Tuple[float, object]:
    """
    Exact orbit cost computation by evaluating Wc(mu, g.nu) for all g in G.

    Time complexity: O(|G| * T_Wc * T_action)
    Space complexity: O(1) (beyond storing group elements)

    Parameters
    ----------
    Wc : callable
        Cost function (x, y) -> float
    mu, nu : array-like
        Points in the space alpha
    group_elements : list
        All elements of G (requires finite G)
    action : callable
        Group action (g, x) -> g.x

    Returns
    -------
    cost : float
        The orbit cost inf_g Wc(mu, g.nu)
    witness : object
        The optimal group element g*
    """
    best_cost = float('inf')
    best_g = None

    for g in group_elements:
        g_nu = action(g, nu)
        cost = Wc(mu, g_nu)
        if cost < best_cost:
            best_cost = cost
            best_g = g

    return best_cost, best_g


# ============================================================================
# Algorithm 2: Orbit Cost via Hungarian Algorithm (for permutation groups)
# ============================================================================

def orbit_cost_hungarian(
    mu: np.ndarray,
    nu: np.ndarray,
    cost_matrix_fn: Callable = None
) -> Tuple[float, np.ndarray]:
    """
    Orbit cost for permutation group action using the Hungarian algorithm.

    Instead of enumerating all n! permutations, solves the assignment problem
    in O(n^3) time.

    Parameters
    ----------
    mu, nu : ndarray of shape (n,) or (n, d)
        Points to compare
    cost_matrix_fn : callable, optional
        Function to compute pairwise costs. Default: absolute difference.

    Returns
    -------
    cost : float
        The orbit cost
    perm : ndarray
        The optimal permutation

    Time complexity: O(n^3)
    Space complexity: O(n^2)
    """
    from scipy.optimize import linear_sum_assignment

    n = len(mu)

    if cost_matrix_fn is None:
        # Default: L1 pairwise cost
        if mu.ndim == 1:
            C = np.abs(mu[:, None] - nu[None, :])
        else:
            C = np.sum(np.abs(mu[:, None, :] - nu[None, :, :]), axis=-1)
    else:
        C = cost_matrix_fn(mu, nu)

    row_ind, col_ind = linear_sum_assignment(C)
    cost = C[row_ind, col_ind].sum()

    perm = np.zeros(n, dtype=int)
    perm[row_ind] = col_ind

    return cost, perm


# ============================================================================
# Algorithm 3: Orbit Cost Lower Bound via Invariant Features
# ============================================================================

def orbit_cost_lower_bound_sorted(mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Fast lower bound on permutation orbit cost using sorted features.

    The sorted version of a vector is a complete invariant for the
    permutation orbit. For L1 cost, the orbit cost equals the L1
    distance between sorted vectors.

    Time complexity: O(n log n)
    Space complexity: O(n)
    """
    return np.sum(np.abs(np.sort(mu) - np.sort(nu)))


# ============================================================================
# Algorithm 4: Approximate Orbit Cost via Random Sampling
# ============================================================================

def orbit_cost_random_sampling(
    Wc: Callable,
    mu: np.ndarray,
    nu: np.ndarray,
    action: Callable,
    sample_group_element: Callable,
    n_samples: int = 1000,
    seed: int = 42
) -> Tuple[float, object]:
    """
    Approximate orbit cost by random sampling from the group.

    Provides an upper bound (never underestimates the true orbit cost).
    The gap vanishes as n_samples -> infinity for compact groups with
    Haar-uniform sampling.

    Time complexity: O(n_samples * (T_Wc + T_action + T_sample))
    Space complexity: O(1)

    Parameters
    ----------
    n_samples : int
        Number of random group elements to try

    Returns
    -------
    cost : float
        Upper bound on orbit cost
    witness : object
        Best group element found
    """
    rng = np.random.RandomState(seed)
    best_cost = float('inf')
    best_g = None

    for _ in range(n_samples):
        g = sample_group_element(rng)
        g_nu = action(g, nu)
        cost = Wc(mu, g_nu)
        if cost < best_cost:
            best_cost = cost
            best_g = g

    return best_cost, best_g


# ============================================================================
# Algorithm 5: Orbit Triangle Inequality Certificate
# ============================================================================

def verify_triangle_with_certificate(
    Wc: Callable,
    mu, nu, rho,
    group_elements: list,
    action: Callable
) -> dict:
    """
    Verify the triangle inequality and produce a certificate.

    The certificate consists of:
    - The optimal group elements g1*, g2* for (mu,nu) and (nu,rho)
    - The composed witness g1* * g2* for (mu,rho)
    - The exact costs and slack

    Returns
    -------
    dict with keys:
        'lhs': orbitCost(mu, rho)
        'rhs': orbitCost(mu, nu) + orbitCost(nu, rho)
        'slack': rhs - lhs (must be >= 0)
        'g1_star': optimal for (mu, nu)
        'g2_star': optimal for (nu, rho)
        'composed_cost': Wc(mu, (g1*g2).rho)
        'verified': bool
    """
    d_mu_nu, g1 = orbit_cost_exact(Wc, mu, nu, group_elements, action)
    d_nu_rho, g2 = orbit_cost_exact(Wc, nu, rho, group_elements, action)
    d_mu_rho, g_star = orbit_cost_exact(Wc, mu, rho, group_elements, action)

    # Compute composed witness cost
    # For permutation groups, composition is function composition
    if isinstance(g1, tuple) and isinstance(g2, tuple):
        composed = tuple(g2[g1[i]] for i in range(len(g1)))
    else:
        composed = g1  # fallback

    composed_cost = Wc(mu, action(composed, rho)) if isinstance(g1, tuple) else None

    slack = (d_mu_nu + d_nu_rho) - d_mu_rho

    return {
        'lhs': d_mu_rho,
        'rhs': d_mu_nu + d_nu_rho,
        'slack': slack,
        'g1_star': g1,
        'g2_star': g2,
        'composed_cost': composed_cost,
        'verified': slack >= -1e-12,
        'd_mu_nu': d_mu_nu,
        'd_nu_rho': d_nu_rho,
    }


# ============================================================================
# Benchmarks
# ============================================================================

def benchmark_algorithms():
    """Compare algorithm performance for permutation orbit cost."""
    print("=" * 70)
    print("ALGORITHM BENCHMARKS: Permutation Orbit Cost")
    print("=" * 70)

    def Wc(x, y):
        return np.sum(np.abs(x - y))

    for n in [3, 4, 5, 6, 7, 8]:
        mu = np.random.randn(n)
        nu = np.random.randn(n)

        # Method 1: Exhaustive (only feasible for small n)
        if n <= 8:
            perms = list(permutations(range(n)))
            def action(sigma, x):
                return x[list(sigma)]

            t0 = time.time()
            cost_exact, _ = orbit_cost_exact(Wc, mu, nu, perms, action)
            t_exact = time.time() - t0
        else:
            cost_exact = None
            t_exact = float('inf')

        # Method 2: Hungarian
        t0 = time.time()
        cost_hungarian, _ = orbit_cost_hungarian(mu, nu)
        t_hungarian = time.time() - t0

        # Method 3: Sorting (L1 specific)
        t0 = time.time()
        cost_sorted = orbit_cost_lower_bound_sorted(mu, nu)
        t_sorted = time.time() - t0

        print(f"\nn = {n}:")
        print(f"  Exact ({len(perms) if n <= 8 else '?'} perms): "
              f"cost = {cost_exact:.6f}, time = {t_exact:.6f}s")
        print(f"  Hungarian (O(n³)):  cost = {cost_hungarian:.6f}, time = {t_hungarian:.6f}s")
        print(f"  Sorted (O(n log n)): cost = {cost_sorted:.6f}, time = {t_sorted:.6f}s")

        if cost_exact is not None:
            assert abs(cost_exact - cost_hungarian) < 1e-8, "Hungarian mismatch!"
            assert abs(cost_exact - cost_sorted) < 1e-8, "Sorted mismatch!"


if __name__ == "__main__":
    benchmark_algorithms()
