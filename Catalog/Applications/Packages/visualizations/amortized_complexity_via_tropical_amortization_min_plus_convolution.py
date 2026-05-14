#!/usr/bin/env python3
"""
Tropical Amortization: Core Algorithms

Implementations of the key algorithms from the tropical amortization framework:
1. Potential synthesis from prefix domination
2. Min-plus (tropical) convolution
3. Amortized bound verification
4. Iterated tropical convolution
"""

from typing import Callable, List, Optional, Tuple
import numpy as np


# =============================================================================
# Algorithm 1: Potential Synthesis
# =============================================================================

def synthesize_potential(costs: List[int], amortized_charge: int) -> Optional[List[int]]:
    """
    Synthesize the canonical accounting potential from costs and amortized charge.

    Given a cost sequence c and uniform amortized charge B, compute:
        Phi(n) = n * B - sum_{i<n} c(i)

    Returns None if prefix domination fails (no valid potential exists).

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        costs: Actual cost sequence c(0), c(1), ..., c(n-1).
        amortized_charge: Uniform amortized charge B.

    Returns:
        List of potential values [Phi(0), Phi(1), ..., Phi(n)], or None.

    Example:
        >>> synthesize_potential([1, 1, 5, 1, 1, 1, 9, 1], 3)
        [0, 2, 4, 2, 4, 6, 8, 2, 4]
    """
    n = len(costs)
    phi = [0] * (n + 1)
    sum_c = 0
    for i in range(n):
        sum_c += costs[i]
        phi[i + 1] = (i + 1) * amortized_charge - sum_c
        if phi[i + 1] < 0:
            return None  # Prefix domination violated
    return phi


def find_minimum_amortized_charge(costs: List[int]) -> Tuple[int, List[int]]:
    """
    Find the minimum uniform amortized charge B such that prefix domination holds.

    The minimum B satisfies: B >= max_{n>=1} (sum_{i<n} c(i)) / n,
    i.e., B is the ceiling of the maximum average prefix cost.

    Time complexity: O(n)
    Space complexity: O(1) for B, O(n) for potential

    Args:
        costs: Actual cost sequence.

    Returns:
        Tuple of (minimum amortized charge B, potential Phi).

    Example:
        >>> find_minimum_amortized_charge([1, 1, 5, 1])
        (2, [0, 1, 2, -1, 0])  # B=2, note Phi can go to -1 at intermediate
    """
    n = len(costs)
    if n == 0:
        return 0, [0]

    # Find minimum B such that n*B >= sum_{i<n} c(i) for all n
    # Equivalently, B >= ceil(sum_c / n) for all prefixes
    sum_c = 0
    min_b = 0
    for i in range(n):
        sum_c += costs[i]
        # Need (i+1) * B >= sum_c, so B >= ceil(sum_c / (i+1))
        b_needed = (sum_c + i) // (i + 1)  # ceiling division
        min_b = max(min_b, b_needed)

    phi = synthesize_potential(costs, min_b)
    assert phi is not None
    return min_b, phi


# =============================================================================
# Algorithm 2: Min-Plus (Tropical) Convolution
# =============================================================================

def tropical_conv(f: List[int], g: List[int], n: int) -> int:
    """
    Compute the min-plus convolution (f ⋆ g)(n) = min_{0<=k<=n} (f[k] + g[n-k]).

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        f: First cost function (as list, f[k] for k=0,1,...).
        g: Second cost function (as list).
        n: Point at which to evaluate the convolution.

    Returns:
        The min-plus convolution value at n.

    Example:
        >>> tropical_conv([0, 1, 4, 9], [0, 1, 4, 9], 4)
        8  # min(0+16, 1+9, 4+4, 9+1, 16+0) -- but lists are length 4
    """
    result = float('inf')
    for k in range(min(n + 1, len(f))):
        j = n - k
        if 0 <= j < len(g):
            result = min(result, f[k] + g[j])
    return result


def tropical_conv_full(f: List[int], g: List[int]) -> List[int]:
    """
    Compute the full min-plus convolution of two sequences.

    (f ⋆ g)[n] = min_{k+j=n} (f[k] + g[j])

    Time complexity: O(n * m) where n = len(f), m = len(g)
    Space complexity: O(n + m)

    Args:
        f: First sequence.
        g: Second sequence.

    Returns:
        Convolution result of length len(f) + len(g) - 1.
    """
    n = len(f) + len(g) - 1
    result = []
    for i in range(n):
        result.append(tropical_conv(f, g, i))
    return result


def iterated_tropical_conv(sequences: List[List[int]]) -> List[int]:
    """
    Compute iterated min-plus convolution of multiple sequences.

    By associativity (Theorem 6), the result is independent of grouping.

    Time complexity: O(k * n^2) where k = number of sequences, n = max length
    Space complexity: O(n)

    Args:
        sequences: List of cost sequences to convolve.

    Returns:
        Iterated convolution result.
    """
    if not sequences:
        return [0]  # tropical identity: delta at 0
    result = sequences[0]
    for seq in sequences[1:]:
        result = tropical_conv_full(result, seq)
    return result


# =============================================================================
# Algorithm 3: Amortized Bound Verification
# =============================================================================

def verify_amortized_bound(
    costs: List[int],
    amortized: List[int],
    potential: List[int]
) -> Tuple[bool, Optional[str]]:
    """
    Verify that a potential function certifies an amortized bound.

    Checks:
    1. Phi(0) = 0
    2. Phi(n) >= 0 for all n
    3. c(i) + Phi(i+1) - Phi(i) <= a(i) for all i

    If all hold, by Theorem 1: sum(c) <= sum(a).

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        costs: Actual costs c(0), ..., c(n-1).
        amortized: Amortized charges a(0), ..., a(n-1).
        potential: Potential values Phi(0), ..., Phi(n).

    Returns:
        (True, None) if valid, (False, error_message) if invalid.
    """
    n = len(costs)
    if len(amortized) != n:
        return False, f"Length mismatch: {len(costs)} costs vs {len(amortized)} amortized"
    if len(potential) != n + 1:
        return False, f"Potential should have {n + 1} entries, got {len(potential)}"

    if potential[0] != 0:
        return False, f"Phi(0) = {potential[0]} != 0"

    for i in range(n + 1):
        if potential[i] < 0:
            return False, f"Phi({i}) = {potential[i]} < 0"

    for i in range(n):
        step_val = costs[i] + potential[i + 1] - potential[i]
        if step_val > amortized[i]:
            return False, (f"Step {i}: c({i}) + Phi({i + 1}) - Phi({i}) = "
                          f"{costs[i]} + {potential[i + 1]} - {potential[i]} = "
                          f"{step_val} > {amortized[i]} = a({i})")

    return True, None


def verify_prefix_domination(costs: List[int], amortized: List[int]) -> Tuple[bool, Optional[int]]:
    """
    Verify prefix domination: sum_{i<n} c(i) <= sum_{i<n} a(i) for all n.

    By Theorem 2, this is equivalent to existence of a valid potential.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        costs: Actual costs.
        amortized: Amortized charges.

    Returns:
        (True, None) if holds, (False, first_violation_n) otherwise.
    """
    sum_c, sum_a = 0, 0
    for i in range(len(costs)):
        sum_c += costs[i]
        sum_a += amortized[i]
        if sum_c > sum_a:
            return False, i + 1
    return True, None


# =============================================================================
# Algorithm 4: Optimal Split via Tropical Convolution
# =============================================================================

def optimal_split(f: Callable[[int], int], g: Callable[[int], int], n: int) -> Tuple[int, int]:
    """
    Find the optimal split point for composing two cost phases.

    Computes argmin_{0<=k<=n} (f(k) + g(n-k)) and the optimal cost.

    This is the core dynamic programming step, formalized as tropical convolution.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        f: Cost function for first phase.
        g: Cost function for second phase.
        n: Total number of items to process.

    Returns:
        (optimal_k, optimal_cost) where optimal_cost = f(k) + g(n-k).
    """
    best_k = 0
    best_cost = f(0) + g(n)
    for k in range(1, n + 1):
        cost = f(k) + g(n - k)
        if cost < best_cost:
            best_cost = cost
            best_k = k
    return best_k, best_cost


# =============================================================================
# Main: demonstrate all algorithms
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm 1: Potential Synthesis")
    print("=" * 70)

    # Dynamic array costs
    costs = []
    cap = 1
    sz = 0
    for i in range(20):
        if sz == cap:
            costs.append(cap + 1)
            cap *= 2
        else:
            costs.append(1)
        sz += 1

    min_b, phi = find_minimum_amortized_charge(costs)
    print(f"Costs: {costs}")
    print(f"Minimum amortized charge: {min_b}")
    print(f"Canonical potential: {phi}")
    print(f"All Phi >= 0: {all(p >= 0 for p in phi)}")

    print()
    print("=" * 70)
    print("Algorithm 2: Min-Plus Convolution")
    print("=" * 70)

    f = [0, 1, 4, 9, 16]
    g = [0, 1, 4, 9, 16]
    conv = tropical_conv_full(f, g)
    print(f"f = {f}")
    print(f"g = {g}")
    print(f"f ⋆ g = {conv}")

    # Verify associativity
    h = [0, 2, 3, 5, 8]
    fg_h = tropical_conv_full(tropical_conv_full(f, g), h)
    f_gh = tropical_conv_full(f, tropical_conv_full(g, h))
    print(f"\nh = {h}")
    print(f"(f⋆g)⋆h = {fg_h}")
    print(f"f⋆(g⋆h) = {f_gh}")
    print(f"Associativity: {fg_h == f_gh}")

    print()
    print("=" * 70)
    print("Algorithm 3: Amortized Bound Verification")
    print("=" * 70)

    amortized = [3] * len(costs)
    phi_synth = synthesize_potential(costs, 3)
    valid, msg = verify_amortized_bound(costs, amortized, phi_synth)
    print(f"Verification result: {'VALID' if valid else 'INVALID'}")
    if msg:
        print(f"  Error: {msg}")

    ok, violation = verify_prefix_domination(costs, amortized)
    print(f"Prefix domination: {'HOLDS' if ok else f'VIOLATED at n={violation}'}")

    print()
    print("=" * 70)
    print("Algorithm 4: Optimal Split")
    print("=" * 70)

    f_func = lambda k: k * k
    g_func = lambda k: 2 * k
    for n in [5, 10, 20]:
        k_opt, cost_opt = optimal_split(f_func, g_func, n)
        print(f"n={n}: optimal split k={k_opt}, cost={cost_opt} "
              f"(f({k_opt})={f_func(k_opt)}, g({n - k_opt})={g_func(n - k_opt)})")
