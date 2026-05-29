#!/usr/bin/env python3
"""
Algorithms for Lorentzian Recognition Complexity Analysis

Implements:
1. Multiindex enumeration and counting
2. Derivative tree construction and leaf counting
3. Spectral (Hessian) analysis for Lorentzian signature detection
4. CNF-to-polynomial encoding
5. Certificate complexity estimation

All algorithms include docstrings, type hints, and example usage.
"""

import math
import itertools
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Multiindex Enumeration
# ═══════════════════════════════════════════════════════════════════

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all multiindices α ∈ ℕ^n with |α| = d.

    Uses the stars-and-bars method: distribute d identical objects
    into n bins.

    Time complexity: O(C(d+n-1, n-1))
    Space complexity: O(n * C(d+n-1, n-1))

    Args:
        n: Number of variables (bins)
        d: Total weight (objects to distribute)

    Returns:
        List of all multiindices as tuples

    Example:
        >>> enumerate_multiindices(2, 3)
        [(3, 0), (2, 1), (1, 2), (0, 3)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def multiindex_count(n: int, d: int) -> int:
    """
    Count multiindices of weight d in n variables.

    Formula: C(d+n-1, n-1)

    This matches the formal definition in LorentzianHardness.lean
    and satisfies both:
    - Upper bound: ≤ n^d  (card_multiindex_le_pow)
    - Lower bound: ≥ d+1 for n ≥ 2  (multiindex_count_linear_lower)
    - Lower bound: ≥ 2^n for n+1 vars  (certificate_size_exponential_lower)
    """
    if n == 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Derivative Tree Analysis
# ═══════════════════════════════════════════════════════════════════

@dataclass
class DerivativeTreeNode:
    """A node in the derivative recognition tree."""
    multiindex: Tuple[int, ...]
    weight: int
    children: List['DerivativeTreeNode']
    is_leaf: bool
    lorentzian_check: Optional[bool] = None


def build_derivative_tree(n: int, d: int, max_depth: int = None) -> DerivativeTreeNode:
    """
    Build the recursive derivative tree for Lorentzian recognition.

    At each non-leaf node, we branch by differentiating with respect
    to each variable, producing n children. Leaves are reached when
    the remaining degree is 2 (quadratic forms to check).

    Time: O(n^(d-2)) nodes
    Space: O(n^(d-2))

    Args:
        n: Number of variables
        d: Degree of the polynomial
        max_depth: Maximum tree depth (for large examples)

    Returns:
        Root of the derivative tree
    """
    root_idx = tuple([0] * n)

    def build(alpha: Tuple[int, ...], remaining: int, depth: int) -> DerivativeTreeNode:
        if remaining <= 2 or (max_depth and depth >= max_depth):
            return DerivativeTreeNode(
                multiindex=alpha,
                weight=sum(alpha),
                children=[],
                is_leaf=True
            )
        children = []
        for i in range(n):
            new_alpha = list(alpha)
            new_alpha[i] += 1
            child = build(tuple(new_alpha), remaining - 1, depth + 1)
            children.append(child)
        return DerivativeTreeNode(
            multiindex=alpha,
            weight=sum(alpha),
            children=children,
            is_leaf=False
        )

    return build(root_idx, d, 0)


def count_leaves(tree: DerivativeTreeNode) -> int:
    """Count the number of leaves in a derivative tree."""
    if tree.is_leaf:
        return 1
    return sum(count_leaves(c) for c in tree.children)


def count_unique_leaves(tree: DerivativeTreeNode) -> int:
    """Count distinct multiindices among leaves."""
    leaves = set()

    def collect(node):
        if node.is_leaf:
            leaves.add(node.multiindex)
        else:
            for c in node.children:
                collect(c)

    collect(tree)
    return len(leaves)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Spectral Analysis
# ═══════════════════════════════════════════════════════════════════

def eigenvalues_2x2(a: float, b: float, c: float) -> Tuple[float, float]:
    """
    Compute eigenvalues of symmetric 2×2 matrix [[a,b],[b,c]].

    Returns (λ₁, λ₂) with λ₁ ≥ λ₂.
    """
    trace = a + c
    det = a * c - b * b
    disc = max(0, trace ** 2 - 4 * det)
    sqrt_disc = math.sqrt(disc)
    return (trace + sqrt_disc) / 2, (trace - sqrt_disc) / 2


def has_lorentzian_signature_2x2(a: float, b: float, c: float) -> bool:
    """
    Check if 2×2 symmetric matrix has at most one positive eigenvalue.

    Formally proved in pos_def_not_lorentzian:
    If a > 0, c > 0, ac - b² > 0, then NOT Lorentzian.
    """
    e1, e2 = eigenvalues_2x2(a, b, c)
    return not (e1 > 1e-12 and e2 > 1e-12)


def check_reversed_cauchy_schwarz(A: List[List[float]],
                                   x: List[float],
                                   y: List[float]) -> dict:
    """
    Check the reversed Cauchy-Schwarz inequality for Lorentzian forms.

    Formally proved in spectral_obstruction_bilinear:
    For symmetric A with Lorentzian signature, if Q(x) > 0 and Q(y) > 0,
    then B(x,y)² ≥ Q(x)·Q(y).
    """
    n = len(x)
    qx = sum(A[i][j] * x[i] * x[j] for i in range(n) for j in range(n))
    qy = sum(A[i][j] * y[i] * y[j] for i in range(n) for j in range(n))
    bxy = sum(A[i][j] * x[i] * y[j] for i in range(n) for j in range(n))
    return {
        'Q(x)': qx,
        'Q(y)': qy,
        'B(x,y)': bxy,
        'B(x,y)²': bxy ** 2,
        'Q(x)·Q(y)': qx * qy,
        'inequality_holds': bxy ** 2 >= qx * qy - 1e-10
    }


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: CNF-to-Polynomial Encoding
# ═══════════════════════════════════════════════════════════════════

@dataclass
class CNFFormula:
    """A CNF formula with n variables and a list of clauses."""
    n_vars: int
    clauses: List[List[Tuple[int, bool]]]

    def is_satisfiable(self) -> Tuple[bool, Optional[Dict[int, bool]]]:
        """Brute-force SAT solving."""
        for bits in itertools.product([False, True], repeat=self.n_vars):
            assignment = {i: bits[i] for i in range(self.n_vars)}
            if all(
                any(assignment[v] == p for v, p in clause)
                for clause in self.clauses
            ):
                return True, assignment
        return False, None


def cnf_to_polynomial_terms(phi: CNFFormula) -> List[Dict[int, int]]:
    """
    Encode a CNF formula into polynomial terms.

    Each clause C_j maps to a product of linear forms:
    - literal (x_i, True) → variable x_i
    - literal (x_i, False) → variable x_i' (complementary)

    The polynomial P_φ is the product of clause polynomials,
    expanded into monomials.

    This implements the conceptual bridge between SAT and
    derivative tree structure.
    """
    # Each clause gives a sum of literal monomials
    clause_polys = []
    for clause in phi.clauses:
        terms = []
        for var, polarity in clause:
            if polarity:
                terms.append({var: 1})  # x_var
            else:
                terms.append({var + phi.n_vars: 1})  # complement var
        clause_polys.append(terms)
    return clause_polys


def certificate_complexity_estimate(n: int, d: int) -> dict:
    """
    Estimate the certificate complexity for Lorentzian recognition.

    Returns bounds from the formal theorems:
    - Upper: n^(d-2) from quadratic_leaf_count_le
    - Lower: 2^(d-2) when n ≥ d-1 from certificate_size_exponential_lower
    """
    if d < 2:
        return {'upper': 1, 'lower': 1, 'exact': 1}

    exact = multiindex_count(n, d - 2)
    upper = n ** (d - 2)
    lower = 2 ** (d - 2) if n >= d - 1 else d - 1

    return {
        'upper_bound': upper,
        'lower_bound': lower,
        'exact_count': exact,
        'n': n,
        'd': d,
        'is_exponential': exact >= 2 ** (d // 3)
    }


# ═══════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithm Examples")
    print("=" * 60)

    # Multiindex enumeration
    print("\n1. Multiindices of weight 3 in 3 variables:")
    for alpha in enumerate_multiindices(3, 3):
        print(f"   {alpha}")
    print(f"   Count: {multiindex_count(3, 3)} = C(5,2) = 10")

    # Derivative tree
    print("\n2. Derivative tree for n=3, d=4:")
    tree = build_derivative_tree(3, 4)
    print(f"   Total leaves: {count_leaves(tree)}")
    print(f"   Unique leaves: {count_unique_leaves(tree)}")
    print(f"   Upper bound n^(d-2) = {3**2}")

    # Spectral analysis
    print("\n3. Spectral analysis:")
    print(f"   [[1,0],[0,-1]] Lorentzian: {has_lorentzian_signature_2x2(1, 0, -1)}")
    print(f"   [[2,1],[1,2]] Lorentzian: {has_lorentzian_signature_2x2(2, 1, 2)}")

    # Certificate complexity
    print("\n4. Certificate complexity estimates:")
    for d in [4, 6, 8, 10, 12]:
        n = d + 1
        est = certificate_complexity_estimate(n, d)
        print(f"   d={d}, n={n}: exact={est['exact_count']}, "
              f"upper={est['upper_bound']}, lower={est['lower_bound']}, "
              f"exponential={est['is_exponential']}")
