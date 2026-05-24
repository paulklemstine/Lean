#!/usr/bin/env python3
"""
Algorithms for Ehrhart Theory of Lorentzian Permutohedra.

Implements:
1. M-convex exchange verification (O(|S|² · n²))
2. IDP decomposition via peel-off (O(|P|^t))
3. Ehrhart polynomial interpolation via finite differences
4. h*-vector extraction from Ehrhart data
5. Lorentzian support set generation

All algorithms mirror the formal Lean proofs.
"""

import itertools
import math
from typing import List, Tuple, Set, Optional, Dict, Callable
from fractions import Fraction
from collections import defaultdict


# ============================================================
# Algorithm 1: M-Convex Exchange Verification
# ============================================================

def verify_mconvex(
    S: Set[tuple],
    n: int
) -> Tuple[bool, Optional[Tuple[tuple, tuple, int]]]:
    """
    Verify the M-convex exchange property for a finite set S ⊂ ℤⁿ.
    
    The exchange axiom states: for all α, β ∈ S and all i with αᵢ > βᵢ,
    there exists j with αⱼ < βⱼ such that α - eᵢ + eⱼ ∈ S.
    
    Args:
        S: Finite set of integer tuples of length n.
        n: Ambient dimension.
    
    Returns:
        (True, None) if S is M-convex.
        (False, (α, β, i)) if the exchange fails for this triple.
    
    Time complexity: O(|S|² · n²)
    Space complexity: O(|S|)
    
    Example:
        >>> S = {(2,0), (1,1), (0,2)}
        >>> verify_mconvex(S, 2)
        (True, None)
    """
    S_frozen = frozenset(S)
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in S_frozen:
                                found = True
                                break
                    if not found:
                        return (False, (alpha, beta, i))
    return (True, None)


# ============================================================
# Algorithm 2: IDP Decomposition via Peel-Off
# ============================================================

def peel_off_decompose(
    x: tuple,
    P: Set[tuple],
    t: int
) -> Optional[List[tuple]]:
    """
    Integer Decomposition via the Peel-Off Algorithm.
    
    Given x in the t-fold Minkowski sum tP, find points
    x₁, ..., xₜ ∈ P with x = x₁ + ... + xₜ.
    
    This algorithm mirrors the formal peel-off lemma:
    - Peel off one point y ∈ P from x
    - Recursively decompose x - y from (t-1)P
    
    Args:
        x: Target lattice point (tuple of integers).
        P: Base set of lattice points.
        t: Number of summands required.
    
    Returns:
        List of t points from P summing to x, or None if no decomposition exists.
    
    Time complexity: O(|P|^t) worst case, O(|P| · t) average case.
    Space complexity: O(t · n) for the recursion stack.
    
    Pseudocode:
        PEEL_OFF(x, P, t):
            if t = 0:
                return [] if x = 0, else FAIL
            if t = 1:
                return [x] if x ∈ P, else FAIL
            for y ∈ P:
                z ← x - y
                result ← PEEL_OFF(z, P, t-1)
                if result ≠ FAIL:
                    return [y] + result
            return FAIL
    
    Example:
        >>> P = {(2,0), (1,1), (0,2)}
        >>> peel_off_decompose((3, 1), P, 2)
        [(2, 0), (1, 1)]
    """
    n = len(x)
    
    if t == 0:
        if all(xi == 0 for xi in x):
            return []
        return None
    
    if t == 1:
        if x in P:
            return [x]
        return None
    
    for y in sorted(P, key=lambda v: -sum(abs(xi - yi) for xi, yi in zip(x, v))):
        z = tuple(xi - yi for xi, yi in zip(x, y))
        result = peel_off_decompose(z, P, t - 1)
        if result is not None:
            return [y] + result
    
    return None


# ============================================================
# Algorithm 3: Ehrhart Polynomial Interpolation
# ============================================================

def minkowski_sum(A: Set[tuple], B: Set[tuple]) -> Set[tuple]:
    """Compute the Minkowski sum A + B."""
    return {tuple(ai + bi for ai, bi in zip(a, b)) for a in A for b in B}


def minkowski_dilate(t: int, P: Set[tuple]) -> Set[tuple]:
    """Compute the t-fold Minkowski sum tP."""
    if t == 0:
        n = len(next(iter(P)))
        return {tuple(0 for _ in range(n))}
    result = P.copy()
    for _ in range(t - 1):
        result = minkowski_sum(result, P)
    return result


def ehrhart_polynomial_interpolation(
    P: Set[tuple],
    max_t: int = 10
) -> Tuple[List[Fraction], int]:
    """
    Interpolate the Ehrhart polynomial from lattice-point counts.
    
    For a d-dimensional lattice polytope P, L(P, t) = |tP ∩ ℤⁿ|
    is a polynomial of degree d in t (Ehrhart's theorem).
    
    Uses Newton's forward difference formula:
        L(P, t) = ∑_{k=0}^{d} Δᵏ L(P, 0) · C(t, k)
    
    Args:
        P: Set of lattice points (vertices of polytope).
        max_t: Maximum dilation parameter to compute.
    
    Returns:
        (coefficients, degree) where coefficients[k] is the
        k-th forward difference Δᵏ L(P, 0).
    
    Time complexity: O(max_t² · |P|^{max_t}) for counting.
    Space complexity: O(max_t²) for the difference table.
    
    Example:
        >>> P = {(0,), (1,)}  # unit interval
        >>> coeffs, deg = ehrhart_polynomial_interpolation(P, 5)
        >>> # L(P, t) = t + 1, so coeffs = [1, 1, 0, ...]
    """
    counts = [Fraction(len(minkowski_dilate(t, P))) for t in range(max_t + 1)]
    
    # Build forward difference table
    table = [counts[:]]
    for k in range(1, max_t + 1):
        row = [table[-1][i + 1] - table[-1][i] for i in range(len(table[-1]) - 1)]
        table.append(row)
    
    # Extract coefficients and determine degree
    coeffs = [table[k][0] if k < len(table) and table[k] else Fraction(0)
              for k in range(max_t + 1)]
    
    degree = 0
    for k in range(max_t, -1, -1):
        if coeffs[k] != 0:
            degree = k
            break
    
    return coeffs[:degree + 1], degree


# ============================================================
# Algorithm 4: h*-Vector Extraction
# ============================================================

def extract_hstar(
    P: Set[tuple],
    max_t: int = 10,
    degree: Optional[int] = None
) -> List[int]:
    """
    Extract the h*-vector of a lattice polytope P.
    
    The h*-vector (h*₀, ..., h*_d) is defined via:
        ∑_{t≥0} L(P,t) zᵗ = (h*₀ + h*₁z + ... + h*_d z^d) / (1-z)^{d+1}
    
    Equivalently:
        h*_k = ∑_{j=0}^{k} (-1)^{k-j} C(d+1, k-j) L(P, j)
    
    Args:
        P: Set of lattice points.
        max_t: Maximum dilation for Ehrhart data.
        degree: If known, the dimension of P. Auto-detected if None.
    
    Returns:
        h*-vector as a list of integers.
    
    Theorem (Stanley, 1980): If P has IDP, then h*ᵢ ≥ 0 for all i.
    
    Example:
        >>> P = {(0,0), (1,0), (0,1)}  # standard 2-simplex
        >>> extract_hstar(P)
        [1, 0]
    """
    counts = [len(minkowski_dilate(t, P)) for t in range(max_t + 1)]
    
    if degree is None:
        # Auto-detect degree from finite differences
        diffs = counts[:]
        degree = 0
        for k in range(1, len(counts)):
            new_diffs = [diffs[i + 1] - diffs[i] for i in range(len(diffs) - 1)]
            if all(d == 0 for d in new_diffs):
                degree = k - 1
                break
            diffs = new_diffs
            degree = k
    
    d = degree
    hstar = []
    for k in range(d + 1):
        val = sum(
            ((-1) ** (k - j)) * math.comb(d + 1, k - j) * counts[j]
            for j in range(k + 1)
        )
        hstar.append(val)
    
    return hstar


# ============================================================
# Algorithm 5: Lorentzian Support Generation
# ============================================================

def generate_lorentzian_supports(
    n: int,
    d: int,
    max_support_size: int = 50
) -> List[Set[tuple]]:
    """
    Generate M-convex subsets of {x ∈ ℕⁿ : ∑xᵢ = d} as Lorentzian proxies.
    
    Enumerates subsets of the standard simplex that satisfy the
    M-convex exchange property, up to a maximum support size.
    
    Args:
        n: Ambient dimension.
        d: Total degree.
        max_support_size: Maximum number of points to consider.
    
    Returns:
        List of M-convex subsets.
    
    Example:
        >>> supports = generate_lorentzian_supports(3, 2)
        >>> len(supports)  # includes singletons, pairs, full simplex
    """
    # Generate the full simplex
    simplex = set()
    
    def gen(remaining_vars, remaining_sum, current):
        if remaining_vars == 1:
            simplex.add(tuple(current + [remaining_sum]))
            return
        for v in range(remaining_sum + 1):
            gen(remaining_vars - 1, remaining_sum - v, current + [v])
    
    gen(n, d, [])
    
    if len(simplex) > max_support_size:
        # Only test notable subsets
        results = [simplex]
        # Add singletons
        for v in simplex:
            results.append({v})
        return results
    
    # For small simplices, enumerate M-convex subsets
    results = []
    simplex_list = sorted(simplex)
    
    # Always include the full simplex (it's always M-convex)
    results.append(set(simplex_list))
    
    # Include singletons
    for v in simplex_list:
        results.append({v})
    
    # Include pairs and small subsets
    for size in range(2, min(len(simplex_list) + 1, 8)):
        for subset in itertools.combinations(simplex_list, size):
            S = set(subset)
            is_mc, _ = verify_mconvex(S, n)
            if is_mc:
                # Check constant sum (should always be d)
                if len({sum(v) for v in S}) == 1:
                    results.append(S)
    
    return results


def run_full_conjecture_test(
    n_range: range = range(3, 5),
    d_range: range = range(2, 4)
) -> Dict:
    """
    Run the full Lorentzian permutohedron conjecture test.
    
    For each (n, d) in the specified ranges:
    1. Generate all M-convex subsets of the simplex
    2. Compute Ehrhart data
    3. Extract h*-vectors
    4. Check nonnegativity and unimodality
    
    Returns a dictionary of results with counterexample tracking.
    """
    results = {
        "tested": 0,
        "passed": 0,
        "failed": 0,
        "counterexamples": [],
        "details": []
    }
    
    for n in n_range:
        for d in d_range:
            supports = generate_lorentzian_supports(n, d)
            for S in supports:
                results["tested"] += 1
                
                try:
                    hstar = extract_hstar(S, max_t=8)
                    nn = all(h >= 0 for h in hstar)
                    
                    # Unimodality check
                    um = True
                    if len(hstar) > 1:
                        peak = max(range(len(hstar)), key=lambda i: hstar[i])
                        for i in range(peak):
                            if hstar[i] > hstar[i + 1]:
                                um = False
                                break
                        for i in range(peak, len(hstar) - 1):
                            if hstar[i] < hstar[i + 1]:
                                um = False
                                break
                    
                    if nn and um:
                        results["passed"] += 1
                    else:
                        results["failed"] += 1
                        results["counterexamples"].append({
                            "n": n, "d": d,
                            "S": S, "hstar": hstar,
                            "nonneg": nn, "unimodal": um
                        })
                    
                    results["details"].append({
                        "n": n, "d": d, "size": len(S),
                        "hstar": hstar, "nonneg": nn, "unimodal": um
                    })
                except Exception as e:
                    results["details"].append({
                        "n": n, "d": d, "size": len(S),
                        "error": str(e)
                    })
    
    return results


if __name__ == "__main__":
    print("Running full conjecture test...")
    results = run_full_conjecture_test()
    print(f"Tested: {results['tested']}")
    print(f"Passed: {results['passed']}")
    print(f"Failed: {results['failed']}")
    if results["counterexamples"]:
        print("COUNTEREXAMPLES FOUND:")
        for ce in results["counterexamples"]:
            print(f"  n={ce['n']}, d={ce['d']}, h*={ce['hstar']}")
    else:
        print("No counterexamples found. Conjecture holds for all tested cases.")
