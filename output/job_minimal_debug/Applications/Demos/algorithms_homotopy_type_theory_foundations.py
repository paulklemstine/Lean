#!/usr/bin/env python3
"""
Algorithms for HoTT-inspired constructions.

Implements:
1. Pushout computation via union-find (O(n α(n)) amortized)
2. Equivalence transport of computational structures
3. Contractibility checking for finite types
4. Identity system encode/decode for discrete sets
"""

from __future__ import annotations
from typing import TypeVar, Callable, Generic, Optional
from collections import defaultdict


# ===========================================================================
# Algorithm 1: Union-Find for Pushout Computation
# ===========================================================================

class UnionFind:
    """
    Disjoint-set data structure with union by rank and path compression.

    Time complexity:
    - find: O(α(n)) amortized, where α is the inverse Ackermann function
    - union: O(α(n)) amortized
    - classes: O(n)

    Space complexity: O(n)
    """

    def __init__(self, elements: list):
        self.parent = {e: e for e in elements}
        self.rank = {e: 0 for e in elements}
        self._n_classes = len(elements)

    def find(self, x):
        """Find representative with path compression."""
        root = x
        while self.parent[root] != root:
            root = self.parent[root]
        # Path compression
        while self.parent[x] != root:
            self.parent[x], x = root, self.parent[x]
        return root

    def union(self, x, y):
        """Union by rank."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self._n_classes -= 1
        return True

    def classes(self) -> list[set]:
        """Return all equivalence classes."""
        groups = defaultdict(set)
        for e in self.parent:
            groups[self.find(e)].add(e)
        return list(groups.values())

    @property
    def num_classes(self) -> int:
        return self._n_classes


# ===========================================================================
# Algorithm 2: Finite Pushout
# ===========================================================================

def compute_pushout(A, B, C, f: Callable, g: Callable) -> list[set]:
    """
    Compute the pushout of B <-f- A -g-> C.

    Algorithm:
    1. Tag elements: ('L', b) for B, ('R', c) for C
    2. Initialize union-find on all tagged elements
    3. For each a in A, union ('L', f(a)) with ('R', g(a))
    4. Return equivalence classes

    Time: O((|B| + |C| + |A|) · α(|B| + |C|))
    Space: O(|B| + |C|)

    Args:
        A: Source set (list)
        B: Left target set (list)
        C: Right target set (list)
        f: A -> B (left leg of span)
        g: A -> C (right leg of span)

    Returns:
        List of equivalence classes, each a set of tagged elements.
    """
    elements = [('L', b) for b in B] + [('R', c) for c in C]
    uf = UnionFind(elements)

    for a in A:
        uf.union(('L', f(a)), ('R', g(a)))

    return uf.classes()


def pushout_cardinality(A, B, C, f, g) -> int:
    """Compute |Pushout(f, g)|."""
    return len(compute_pushout(A, B, C, f, g))


# ===========================================================================
# Algorithm 3: Equivalence Transport
# ===========================================================================

class FiniteEquiv:
    """
    A verified equivalence between finite sets.

    Stores explicit forward and inverse maps, verifies bijectivity on
    construction.
    """

    def __init__(self, domain: list, codomain: list,
                 to_fun: Callable, inv_fun: Callable):
        self.domain = list(domain)
        self.codomain = list(codomain)
        self.to_fun = to_fun
        self.inv_fun = inv_fun
        self._verify()

    def _verify(self):
        """Verify equivalence conditions."""
        for x in self.domain:
            assert self.inv_fun(self.to_fun(x)) == x, \
                f"left_inv fails at {x}"
        for y in self.codomain:
            assert self.to_fun(self.inv_fun(y)) == y, \
                f"right_inv fails at {y}"

    def transport_decidable_eq(self, b1, b2) -> bool:
        """
        Transport decidable equality from domain to codomain.

        Algorithm: Pull back to domain via inv_fun, compare there.
        Time: O(1) per comparison (assuming O(1) inv_fun and domain equality)
        """
        return self.inv_fun(b1) == self.inv_fun(b2)

    def transport_predicate(self, pred: Callable[[any], bool]) -> Callable:
        """
        Transport a decidable predicate from domain to codomain.

        Given P : domain -> bool, returns P' : codomain -> bool
        where P'(y) = P(inv_fun(y)).
        """
        return lambda y: pred(self.inv_fun(y))

    def transport_fintype(self) -> list:
        """
        Transport finiteness: enumerate codomain via domain enumeration.

        Returns the codomain enumeration produced by mapping to_fun
        over the domain enumeration.
        """
        return [self.to_fun(x) for x in self.domain]


# ===========================================================================
# Algorithm 4: Contractibility Check
# ===========================================================================

def is_contractible(elements: list, eq_fn: Callable = None) -> tuple[bool, any]:
    """
    Check if a finite type is contractible (has exactly one element up to
    the given equality).

    Args:
        elements: List of elements
        eq_fn: Equality function (default: ==)

    Returns:
        (is_contractible, center_or_None)

    Time: O(n)
    Space: O(1)
    """
    if eq_fn is None:
        eq_fn = lambda x, y: x == y

    if not elements:
        return (False, None)

    center = elements[0]
    for e in elements[1:]:
        if not eq_fn(e, center):
            return (False, None)

    return (True, center)


def check_identity_system(universe: list, base: any,
                          R: Callable, rflR: any) -> dict:
    """
    Verify identity system conditions for a discrete finite type.

    An identity system (A, a₀, R, rflR) requires:
    1. rflR : R(a₀) — the reflexivity witness
    2. Σ a, R(a) is contractible with center (a₀, rflR)

    Args:
        universe: Elements of A
        base: The base point a₀
        R: Family R : A -> Set (returns list of elements)
        rflR: The reflexivity witness in R(a₀)

    Returns:
        Dict with verification results.
    """
    # Compute total space
    total_space = []
    for a in universe:
        for r in R(a):
            total_space.append((a, r))

    # Check rflR is in R(base)
    rflR_valid = rflR in R(base)

    # Check contractibility
    is_contr, center = is_contractible(total_space)

    # Check center is (base, rflR)
    center_correct = center == (base, rflR) if is_contr else False

    return {
        "total_space": total_space,
        "rflR_valid": rflR_valid,
        "contractible": is_contr,
        "center": center,
        "center_correct": center_correct,
        "is_identity_system": rflR_valid and is_contr and center_correct,
    }


# ===========================================================================
# Main: demonstrate algorithms
# ===========================================================================

if __name__ == "__main__":
    print("Algorithm 1: Finite Pushout Computation")
    print("-" * 50)

    A = [0, 1]
    B = [0, 1, 2]
    C = [10, 11, 12]
    classes = compute_pushout(A, B, C, lambda a: a, lambda a: 10 + a)
    print(f"  Span: {B} <-- {A} --> {C}")
    print(f"  Pushout classes: {[sorted(c) for c in classes]}")
    print(f"  |Pushout| = {len(classes)}")
    print()

    print("Algorithm 2: Equivalence Transport")
    print("-" * 50)

    e = FiniteEquiv(
        domain=['a', 'b', 'c'],
        codomain=[1, 2, 3],
        to_fun={'a': 1, 'b': 2, 'c': 3}.__getitem__,
        inv_fun={1: 'a', 2: 'b', 3: 'c'}.__getitem__
    )
    print(f"  Equivalence: {{a,b,c}} ≃ {{1,2,3}}")
    print(f"  Transport equality: 1=2? {e.transport_decidable_eq(1, 2)}")
    print(f"  Transport equality: 1=1? {e.transport_decidable_eq(1, 1)}")

    is_vowel = lambda x: x in ['a', 'e', 'i', 'o', 'u']
    transported = e.transport_predicate(is_vowel)
    print(f"  Transport 'is_vowel': P(1)={transported(1)}, P(2)={transported(2)}")
    print(f"  Transport fintype: {e.transport_fintype()}")
    print()

    print("Algorithm 3: Identity System Check")
    print("-" * 50)

    result = check_identity_system(
        universe=[0, 1, 2],
        base=0,
        R=lambda a: [True] if a == 0 else [],
        rflR=True
    )
    print(f"  Universe: [0,1,2], base: 0, R(a) = {{True}} if a=0 else ∅")
    print(f"  Result: {result}")
    print()

    result2 = check_identity_system(
        universe=[0, 1],
        base=0,
        R=lambda a: [True],  # R holds everywhere - not contractible
        rflR=True
    )
    print(f"  Universe: [0,1], base: 0, R(a) = {{True}} for all a")
    print(f"  Result: {result2}")
    print(f"  (Total space has 2 elements, not contractible)")
