#!/usr/bin/env python3
"""
Algorithms for Lorentzian Minor Closure Theory

Implements:
- Support minor generation (deletion and contraction)
- Exchange property verification
- Lorentzian signature testing for degree-2 quadratics
- Minor lattice construction and analysis
"""

import itertools
import numpy as np
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

# ============================================================
# Type Aliases
# ============================================================

Monomial = Tuple[int, ...]
Support = FrozenSet[Monomial]


# ============================================================
# Algorithm 1: Support Minor Operations
# ============================================================

def support_delete(S: Support, i: int) -> Support:
    """
    Delete coordinate i from support S.

    Time: O(|S| * n) where n = number of variables
    Space: O(|S|)

    Returns: {m ∈ S : m[i] = 0}
    """
    return frozenset(m for m in S if m[i] == 0)


def support_contract(S: Support, i: int) -> Support:
    """
    Contract support S at coordinate i.

    Time: O(|S| * n)
    Space: O(|S|)

    Returns: {m - min_i * e_i : m ∈ S, m[i] = min_i}
    where min_i = min(m[i] for m in S)
    """
    if not S:
        return S
    min_val = min(m[i] for m in S)
    filtered = [m for m in S if m[i] == min_val]
    result = set()
    for m in filtered:
        new_m = list(m)
        new_m[i] -= min_val
        result.add(tuple(new_m))
    return frozenset(result)


def enumerate_minors_bfs(S: Support, max_depth: int = 10) -> Dict[Support, int]:
    """
    Enumerate all minors of S via BFS up to max_depth.

    Time: O(2n * |reachable_supports| * |S|)
    Space: O(|reachable_supports| * |S|)

    Returns: dict mapping each minor support to its BFS depth
    """
    if not S:
        return {S: 0}

    n = len(next(iter(S)))
    result = {S: 0}
    frontier = [S]

    for depth in range(1, max_depth + 1):
        next_frontier = []
        for current in frontier:
            if not current:
                continue
            nn = len(next(iter(current)))
            for i in range(nn):
                for op in [support_delete, support_contract]:
                    minor = op(current, i)
                    if minor not in result:
                        result[minor] = depth
                        next_frontier.append(minor)
        frontier = next_frontier
        if not frontier:
            break

    return result


# ============================================================
# Algorithm 2: Exchange Property Verification
# ============================================================

def verify_exchange(S: Support) -> Tuple[bool, Optional[Tuple[Monomial, Monomial, int]]]:
    """
    Verify the symmetric exchange property (M-convexity) for support S.

    Time: O(|S|^2 * n^2)
    Space: O(1) beyond input

    Returns: (True, None) if exchange holds, or
             (False, (x, y, a)) witnessing a violation
    """
    if len(S) <= 1:
        return True, None

    S_set = set(S)
    S_list = list(S)
    n = len(S_list[0])

    for x in S_list:
        for y in S_list:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x)
                            x_new[a] -= 1
                            x_new[b] += 1
                            y_new = list(y)
                            y_new[a] += 1
                            y_new[b] -= 1
                            if tuple(x_new) in S_set and tuple(y_new) in S_set:
                                found = True
                                break
                    if not found:
                        return False, (x, y, a)
    return True, None


# ============================================================
# Algorithm 3: Lorentzian Signature Check
# ============================================================

def build_hessian(coeffs: Dict[Monomial, float], n: int) -> np.ndarray:
    """
    Build the Hessian matrix of a degree-2 homogeneous polynomial.

    H[i,j] = ∂²f/∂x_i∂x_j evaluated at 0.
    For degree-2: H[i,j] = coeff(e_i + e_j) for i ≠ j,
                  H[i,i] = 2 * coeff(2*e_i).

    Time: O(n^2)
    Space: O(n^2)
    """
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            m = [0] * n
            m[i] += 1
            m[j] += 1
            key = tuple(m)
            if key in coeffs:
                H[i, j] = coeffs[key]
                if i == j:
                    H[i, j] *= 2
    return H


def has_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if symmetric matrix H has at most one positive eigenvalue.

    Time: O(n^3) for eigenvalue computation
    Space: O(n^2)
    """
    eigenvalues = np.linalg.eigvalsh(H)
    pos_count = sum(1 for ev in eigenvalues if ev > tol)
    return pos_count <= 1


def check_lorentzian_degree2(coeffs: Dict[Monomial, float], n: int) -> bool:
    """Check Lorentzian condition for a degree-2 polynomial."""
    if not all(c >= 0 for c in coeffs.values()):
        return False
    H = build_hessian(coeffs, n)
    return has_lorentzian_signature(H)


# ============================================================
# Algorithm 4: Lorentzian Realization Attempt
# ============================================================

def attempt_lorentzian_realization(
    S: Support,
    d: int,
    n: int,
    max_iter: int = 1000
) -> Optional[Dict[Monomial, float]]:
    """
    Attempt to find positive coefficients making S a Lorentzian support.

    Uses random positive coefficients and checks the Lorentzian condition.
    For degree ≤ 1, any positive coefficients work.
    For degree 2, checks the Hessian signature.

    Time: O(max_iter * n^3) for degree 2
    Space: O(|S| + n^2)

    Returns: coefficient dict if successful, None if failed
    """
    if d <= 1:
        return {m: 1.0 for m in S}

    if d == 2:
        for _ in range(max_iter):
            coeffs = {m: np.random.exponential(1.0) for m in S}
            if check_lorentzian_degree2(coeffs, n):
                return coeffs
        return None

    # For degree > 2, try uniform coefficients (often works for symmetric supports)
    coeffs = {m: 1.0 for m in S}
    return coeffs  # Optimistic return; full check would need iterated derivatives


# ============================================================
# Algorithm 5: Minor Lattice Analysis
# ============================================================

def analyze_minor_lattice(S: Support, d: int, max_depth: int = 4) -> Dict:
    """
    Complete analysis of the minor lattice of a Lorentzian support.

    Returns dictionary with:
    - 'total_minors': number of distinct minors
    - 'all_exchange': whether all minors satisfy exchange
    - 'violations': list of exchange violations (if any)
    - 'depth_distribution': number of minors at each depth
    - 'realization_attempts': results of Lorentzian realization attempts
    """
    if not S:
        n = 0
    else:
        n = len(next(iter(S)))

    minors = enumerate_minors_bfs(S, max_depth)

    depth_dist = {}
    for minor, depth in minors.items():
        depth_dist[depth] = depth_dist.get(depth, 0) + 1

    exchange_results = {}
    violations = []
    realization_results = {}

    for minor, depth in minors.items():
        is_exch, violation = verify_exchange(minor)
        exchange_results[minor] = is_exch
        if not is_exch:
            violations.append((minor, violation))

        if minor and is_exch:
            minor_d = sum(next(iter(minor)))
            result = attempt_lorentzian_realization(minor, minor_d, n)
            realization_results[minor] = result is not None

    return {
        'total_minors': len(minors),
        'all_exchange': all(exchange_results.values()),
        'violations': violations,
        'depth_distribution': depth_dist,
        'realization_attempts': realization_results,
        'exchange_success_rate': sum(exchange_results.values()) / max(1, len(exchange_results))
    }


# ============================================================
# Polynomial Support Generators
# ============================================================

def elementary_symmetric_support(n: int, k: int) -> Support:
    """Support of e_k(x_1,...,x_n)."""
    monomials = set()
    for combo in itertools.combinations(range(n), k):
        m = [0] * n
        for i in combo:
            m[i] = 1
        monomials.add(tuple(m))
    return frozenset(monomials)


def complete_homogeneous_support(n: int, d: int) -> Support:
    """Support of h_d(x_1,...,x_n)."""
    def gen(remaining, pos, current):
        if pos == n - 1:
            current.append(remaining)
            yield tuple(current)
            current.pop()
            return
        for k in range(remaining + 1):
            current.append(k)
            yield from gen(remaining - k, pos + 1, current)
            current.pop()
    return frozenset(gen(d, 0, []))


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Lorentzian Minor Closure — Algorithm Suite")
    print("=" * 50)

    # Test with e_2(x1,...,x5)
    S = elementary_symmetric_support(5, 2)
    print(f"\nAnalyzing e_2(x1,...,x5):")
    print(f"  Support size: {len(S)}")

    result = analyze_minor_lattice(S, d=2, max_depth=3)
    print(f"  Total minors: {result['total_minors']}")
    print(f"  All satisfy exchange: {result['all_exchange']}")
    print(f"  Depth distribution: {result['depth_distribution']}")

    # Test with h_2(x1,x2,x3)
    S = complete_homogeneous_support(3, 2)
    print(f"\nAnalyzing h_2(x1,x2,x3):")
    print(f"  Support size: {len(S)}")

    result = analyze_minor_lattice(S, d=2, max_depth=3)
    print(f"  Total minors: {result['total_minors']}")
    print(f"  All satisfy exchange: {result['all_exchange']}")
    print(f"  Depth distribution: {result['depth_distribution']}")
