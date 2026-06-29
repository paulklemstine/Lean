#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Contraction and Support Truncation

Implements:
1. Exponent contraction on integer vectors
2. Support contraction on finite sets
3. Tropical truncation on weighted supports
4. M-convex exchange checking
5. Valuated exchange checking
6. Newton polytope computation

Time complexity analysis included in docstrings.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple

ExponentVector = Tuple[int, ...]


def exponent_contract(i: int, m: ExponentVector) -> Optional[ExponentVector]:
    """Contract exponent vector m in direction i.

    Time: O(d) where d = len(m)
    Space: O(d)

    Args:
        i: coordinate direction to contract
        m: exponent vector (d-tuple of non-negative integers)

    Returns:
        None if m[i] == 0, else m with m[i] decremented by 1

    Example:
        >>> exponent_contract(0, (3, 1, 2))
        (2, 1, 2)
        >>> exponent_contract(1, (3, 0, 2))
        None
    """
    if i < 0 or i >= len(m):
        raise IndexError(f"Direction {i} out of range for vector of dimension {len(m)}")
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i + 1:]


def support_contract(i: int, S: Set[ExponentVector]) -> Set[ExponentVector]:
    """Contract a finite set of exponent vectors in direction i.

    Filters to vectors with positive i-coordinate, then subtracts e_i.

    Time: O(|S| * d)
    Space: O(|S| * d)

    Args:
        i: coordinate direction
        S: finite set of exponent vectors

    Returns:
        {m - e_i : m ∈ S, m[i] > 0}

    Example:
        >>> support_contract(0, {(2, 1), (0, 3), (1, 0)})
        {(1, 1), (0, 0)}
    """
    result = set()
    for m in S:
        mc = exponent_contract(i, m)
        if mc is not None:
            result.add(mc)
    return result


def support_contract_inverse(i: int, contracted: Set[ExponentVector]) -> Set[ExponentVector]:
    """Lift a contracted support back by adding e_i.

    This is the inverse of support_contract: for any S,
    support_contract_inverse(i, support_contract(i, S)) == {m in S : m[i] > 0}

    Time: O(|contracted| * d)
    Space: O(|contracted| * d)

    Example:
        >>> support_contract_inverse(0, {(1, 1), (0, 0)})
        {(2, 1), (1, 0)}
    """
    return {m[:i] + (m[i] + 1,) + m[i + 1:] for m in contracted}


class TropicalSupport:
    """A tropical polynomial represented by finite support and integer weight function.

    Attributes:
        supp: frozenset of exponent vectors (the support)
        weight: dict mapping exponent vectors to integer weights

    The weight function satisfies weight[m] = 0 for m not in supp.
    """

    def __init__(self, supp: Set[ExponentVector], weight: Dict[ExponentVector, int]):
        self.supp = frozenset(supp)
        self.weight = {}
        for m in self.supp:
            self.weight[m] = weight.get(m, 0)

    def get_weight(self, m: ExponentVector) -> int:
        """Get weight of exponent vector (0 if not in support)."""
        return self.weight.get(m, 0)

    def __repr__(self):
        return f"TropicalSupport(supp={sorted(self.supp)}, weight={self.weight})"


def tropical_truncate(i: int, T: TropicalSupport) -> TropicalSupport:
    """Truncate a tropical support in direction i.

    Contracts the support and propagates weights from original vectors.
    Weight of contracted vector m' = weight of (m' + e_i) in original.

    Time: O(|supp| * d)
    Space: O(|supp| * d)

    Args:
        i: coordinate direction
        T: tropical support to truncate

    Returns:
        Truncated tropical support
    """
    new_supp = support_contract(i, T.supp)
    new_weight = {}
    for m_prime in new_supp:
        m_lifted = m_prime[:i] + (m_prime[i] + 1,) + m_prime[i + 1:]
        new_weight[m_prime] = T.get_weight(m_lifted)
    return TropicalSupport(new_supp, new_weight)


def check_mconvex_exchange(S: Set[ExponentVector]) -> bool:
    """Check if S satisfies the M-convex symmetric exchange property.

    For all α, β ∈ S and all k with α[k] > β[k],
    there exists j with α[j] < β[j] such that α - e_k + e_j ∈ S.

    Time: O(|S|² * d²) where d is the dimension
    Space: O(|S| * d)

    Args:
        S: finite set of exponent vectors

    Returns:
        True if S satisfies the exchange property
    """
    if not S:
        return True
    S_frozen = frozenset(S)
    d = len(next(iter(S)))
    for alpha in S:
        for beta in S:
            for k in range(d):
                if alpha[k] > beta[k]:
                    found = False
                    for j in range(d):
                        if alpha[j] < beta[j]:
                            exc = list(alpha)
                            exc[k] -= 1
                            exc[j] += 1
                            if tuple(exc) in S_frozen:
                                found = True
                                break
                    if not found:
                        return False
    return True


def check_valuated_exchange(T: TropicalSupport) -> bool:
    """Check valuated M-convex exchange on a weighted tropical support.

    For all α, β ∈ supp with α[k] > β[k],
    ∃ j with α[j] < β[j] such that:
      α - e_k + e_j ∈ supp AND
      w(α - e_k + e_j) + w(β + e_k - e_j) ≥ w(α) + w(β)

    Time: O(|supp|² * d²)
    Space: O(|supp| * d)
    """
    S = T.supp
    if not S:
        return True
    d = len(next(iter(S)))
    for alpha in S:
        for beta in S:
            for k in range(d):
                if alpha[k] > beta[k]:
                    found = False
                    for j in range(d):
                        if alpha[j] < beta[j]:
                            exc_a = list(alpha)
                            exc_a[k] -= 1
                            exc_a[j] += 1
                            exc_a = tuple(exc_a)
                            if exc_a not in S:
                                continue
                            exc_b = list(beta)
                            exc_b[j] -= 1
                            exc_b[k] += 1
                            exc_b = tuple(exc_b)
                            w_new = T.get_weight(exc_a) + T.get_weight(exc_b)
                            w_old = T.get_weight(alpha) + T.get_weight(beta)
                            if w_new >= w_old:
                                found = True
                                break
                    if not found:
                        return False
    return True


def generate_simplex_support(d: int, total: int) -> Set[ExponentVector]:
    """Generate the standard simplex slice: {(a_1,...,a_d) : sum = total, a_i ≥ 0}.

    This is always M-convex (it's the base of a uniform matroid).

    Time: O(C(total+d-1, d-1) * d)

    Example:
        >>> sorted(generate_simplex_support(2, 3))
        [(0, 3), (1, 2), (2, 1), (3, 0)]
    """
    if d == 1:
        return {(total,)}
    result = set()
    for first in range(total + 1):
        for rest in generate_simplex_support(d - 1, total - first):
            result.add((first,) + rest)
    return result


def convex_hull_2d(points: Set[Tuple[int, int]]) -> List[Tuple[int, int]]:
    """Compute the convex hull of 2D integer points (Graham scan).

    Time: O(n log n)
    """
    pts = sorted(points)
    if len(pts) <= 1:
        return pts

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)

    upper = []
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)

    return lower[:-1] + upper[:-1]


if __name__ == "__main__":
    # Quick self-test
    S = generate_simplex_support(3, 3)
    print(f"Simplex(3,3): {sorted(S)}")
    print(f"M-convex: {check_mconvex_exchange(S)}")

    for i in range(3):
        Sc = support_contract(i, S)
        print(f"Contract dir {i}: {sorted(Sc)}, M-convex: {check_mconvex_exchange(Sc)}")

    # Test valuated exchange
    import random
    random.seed(0)
    w = {m: random.randint(-5, 5) for m in S}
    T = TropicalSupport(S, w)
    print(f"\nValuated exchange check: {check_valuated_exchange(T)}")
    for i in range(3):
        Tt = tropical_truncate(i, T)
        print(f"Truncated dir {i} valuated exchange: {check_valuated_exchange(Tt)}")
