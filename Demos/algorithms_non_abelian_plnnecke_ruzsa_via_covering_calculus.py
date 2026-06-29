#!/usr/bin/env python3
"""
Algorithms for Non-Abelian Covering Calculus

Implements the core algorithms for computing covering numbers,
approximate subgroup detection, and the inductive covering bound.
"""

from itertools import permutations
from typing import Set, List, Tuple, Callable, Any, Optional
from collections import defaultdict


class FiniteGroup:
    """
    A finite group represented by its elements and composition law.

    Attributes:
        elements: list of group elements
        compose: binary operation (a, b) -> a*b
        inverse: unary operation a -> a^(-1)
        identity: the identity element
    """

    def __init__(self, elements: list, compose: Callable, inverse: Callable, identity):
        self.elements = elements
        self.compose = compose
        self.inverse = inverse
        self.identity = identity

    def set_product(self, A: set, B: set) -> set:
        """Compute A·B = {a·b : a ∈ A, b ∈ B}."""
        return {self.compose(a, b) for a in A for b in B}

    def set_pow(self, H: set, n: int) -> set:
        """Compute H^n (n-fold iterated product set)."""
        if n == 0:
            return {self.identity}
        result = {self.identity}
        for _ in range(n):
            result = self.set_product(result, H)
        return result

    def left_translate(self, g, H: set) -> set:
        """Compute g·H = {g·h : h ∈ H}."""
        return {self.compose(g, h) for h in H}


def symmetric_group(n: int) -> FiniteGroup:
    """Construct S_n as a FiniteGroup."""
    elts = list(permutations(range(n)))
    identity = tuple(range(n))

    def compose(p, q):
        return tuple(p[q[i]] for i in range(n))

    def inverse(p):
        inv = [0] * n
        for i, v in enumerate(p):
            inv[v] = i
        return tuple(inv)

    return FiniteGroup(elts, compose, inverse, identity)


def greedy_covering_number(G: FiniteGroup, A: set, H: set) -> int:
    """
    Compute an upper bound on cov(A, H) using greedy set cover.

    Algorithm:
    1. Initialize uncovered = A
    2. While uncovered is nonempty:
       a. Find g ∈ G maximizing |uncovered ∩ g·H|
       b. Remove g·H from uncovered
       c. Increment counter
    3. Return counter

    Time complexity: O(|G| · |A| · |H|)
    Space complexity: O(|G| + |A| + |H|)
    """
    if not A:
        return 0

    uncovered = set(A)
    count = 0

    while uncovered:
        best_g = None
        best_covered = 0

        for g in G.elements:
            translate = G.left_translate(g, H)
            covered = len(uncovered & translate)
            if covered > best_covered:
                best_covered = covered
                best_g = g

        if best_covered == 0:
            return float('inf')

        translate = G.left_translate(best_g, H)
        uncovered -= translate
        count += 1

    return count


def exact_covering_number(G: FiniteGroup, A: set, H: set, max_size: Optional[int] = None) -> int:
    """
    Compute the exact covering number cov(A, H) by exhaustive search.

    Warning: Exponential time complexity O(|G|^cov).

    Args:
        G: the ambient group
        A: set to cover
        H: covering set
        max_size: upper bound on covering number (for pruning)

    Returns:
        Exact minimum number of translates needed
    """
    if not A:
        return 0

    if max_size is None:
        max_size = greedy_covering_number(G, A, H)

    # Precompute all translates
    translates = {}
    for g in G.elements:
        t = frozenset(G.left_translate(g, H))
        if t & A:  # Only keep relevant translates
            translates[g] = t

    A_frozen = frozenset(A)

    def search(uncovered: frozenset, depth: int, max_depth: int) -> int:
        if not uncovered:
            return 0
        if depth >= max_depth:
            return float('inf')

        best = max_depth - depth + 1
        for g, t in translates.items():
            new_uncovered = uncovered - t
            if len(new_uncovered) < len(uncovered):
                result = search(new_uncovered, depth + 1, min(max_depth, depth + best - 1))
                if result + 1 < best:
                    best = result + 1
                    if best == 1:
                        return 1
        return best

    return search(A_frozen, 0, max_size)


def detect_approximate_subgroup(G: FiniteGroup, H: set) -> dict:
    """
    Analyze whether H is a K-approximate subgroup.

    Returns a dictionary with:
    - is_symmetric: whether H = H^(-1)
    - contains_identity: whether 1 ∈ H
    - doubling_ratio: |H·H| / |H|
    - covering_K: cov(H·H, H)
    - is_approximate_subgroup: True if all conditions met
    """
    identity = G.identity

    is_sym = all(G.inverse(h) in H for h in H)
    has_id = identity in H
    HH = G.set_product(H, H)
    ratio = len(HH) / len(H) if H else float('inf')
    K = greedy_covering_number(G, HH, H)

    return {
        'is_symmetric': is_sym,
        'contains_identity': has_id,
        'doubling_ratio': ratio,
        'covering_K': K,
        'card_H': len(H),
        'card_HH': len(HH),
        'is_approximate_subgroup': is_sym and has_id and K < float('inf'),
    }


def covering_growth_profile(G: FiniteGroup, H: set, max_n: int = 6) -> List[dict]:
    """
    Compute the covering growth profile for H^n.

    For each n from 1 to max_n, computes:
    - |H^n|
    - cov(H^n, H) (greedy upper bound)
    - The conjectured bound K^(n-1)

    Returns a list of dictionaries.
    """
    HH = G.set_product(H, H)
    K = greedy_covering_number(G, HH, H)

    results = []
    for n in range(1, max_n + 1):
        Hn = G.set_pow(H, n)
        cov = greedy_covering_number(G, Hn, H)
        bound = K ** (n - 1)
        results.append({
            'n': n,
            'card_Hn': len(Hn),
            'cov_Hn_H': cov,
            'conjectured_bound': bound,
            'K': K,
            'conjecture_holds': cov <= bound,
        })

    return results


def inductive_covering_bound(K: int, n: int) -> int:
    """
    Compute the inductive covering bound K^(n-1).

    This is the bound proved in the commutative case:
    cov(H^n, H) ≤ K^(n-1).

    For the non-abelian case, the conjectured bound is also K^(n-1),
    but only the weaker K^(2(n-1)) is proved.
    """
    return K ** max(0, n - 1)


def covering_entropy(K: int, n: int) -> float:
    """
    Compute the covering entropy: log(K^(n-1)) = (n-1) * log(K).

    This is the information-theoretic analog of the covering bound:
    the entropy of the covering grows linearly in n.
    """
    import math
    if K <= 0:
        return 0.0
    return (n - 1) * math.log(K)


if __name__ == "__main__":
    # Example: S₃ with H = {e, (12), (13), (23)}
    G = symmetric_group(3)
    e = (0, 1, 2)
    s12 = (1, 0, 2)
    s13 = (2, 1, 0)
    s23 = (0, 2, 1)
    H = {e, s12, s13, s23}

    print("Approximate Subgroup Analysis for H = {e, (12), (13), (23)} in S₃:")
    info = detect_approximate_subgroup(G, H)
    for k, v in info.items():
        print(f"  {k}: {v}")

    print("\nCovering Growth Profile:")
    profile = covering_growth_profile(G, H, max_n=6)
    print(f"  {'n':>3} | {'|H^n|':>6} | {'cov':>5} | {'bound':>6} | {'OK?':>4}")
    for p in profile:
        print(f"  {p['n']:>3} | {p['card_Hn']:>6} | {p['cov_Hn_H']:>5} | {p['conjectured_bound']:>6} | {'✓' if p['conjecture_holds'] else '✗':>4}")
