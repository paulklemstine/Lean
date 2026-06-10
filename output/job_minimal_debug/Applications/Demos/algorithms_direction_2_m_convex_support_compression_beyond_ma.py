#!/usr/bin/env python3
"""
Algorithms for M-Convex Support Shadow Compression

Implements:
  1. M-convex exchange verification
  2. Degree shadow computation
  3. Shadow certificate construction
  4. Tropical initial support computation
  5. Active coordinate analysis

All algorithms include complexity analysis in docstrings.
"""

from itertools import combinations
from math import comb
from typing import Set, Tuple, List, Dict, FrozenSet, Optional
from collections import defaultdict


Exponent = Tuple[int, ...]


class MConvexFamily:
    """An M-convex family of exponent vectors with efficient operations.

    Attributes:
        elements: The set of exponent vectors.
        degree: Common total degree of all elements.
        dim: Number of coordinates.
        active: Set of active coordinate indices.
    """

    def __init__(self, elements: Set[Exponent]):
        """Initialize from a set of exponent vectors.

        Time: O(|S| * n) where n = dimension
        Space: O(|S| * n)
        """
        if not elements:
            raise ValueError("M-convex family must be nonempty")

        self.elements = frozenset(elements)
        self._elem_set = set(elements)
        sample = next(iter(elements))
        self.dim = len(sample)
        self.degree = sum(sample)

        # Validate constant degree
        for m in elements:
            assert len(m) == self.dim, f"Inconsistent dimension: {m}"
            assert sum(m) == self.degree, f"Inconsistent degree: {m} has degree {sum(m)}, expected {self.degree}"

        # Compute active coordinates
        self.active: Set[int] = set()
        for m in elements:
            for i in range(self.dim):
                if m[i] > 0:
                    self.active.add(i)
        self.omega = len(self.active)

    def verify_exchange(self) -> bool:
        """Verify the M-convex symmetric exchange property.

        Time: O(|S|^2 * n^2) where n = dimension
        Space: O(1) auxiliary
        Returns: True if the family satisfies M-convex exchange.
        """
        for alpha in self.elements:
            for beta in self.elements:
                for i in range(self.dim):
                    if alpha[i] > beta[i]:
                        found = False
                        for j in range(self.dim):
                            if alpha[j] < beta[j]:
                                exchanged = list(alpha)
                                exchanged[i] -= 1
                                exchanged[j] += 1
                                if tuple(exchanged) in self._elem_set:
                                    found = True
                                    break
                        if not found:
                            return False
        return True

    def degree_shadow(self, k: int) -> Set[Exponent]:
        """Compute the degree-k shadow.

        The degree-k shadow is {u : deg(u)=k, ∃ m ∈ S, u ≤ m}.

        Time: O(|S| * prod(m[i]+1)) worst case, practical O(|S| * C(n+k-1,k))
        Space: O(|shadow|)
        """
        shadow = set()
        for m in self.elements:
            for u in self._dominated_of_degree(m, k):
                shadow.add(u)
        return shadow

    def _dominated_of_degree(self, m: Exponent, k: int) -> List[Exponent]:
        """All u with u ≤ m and deg(u) = k."""
        results: List[Exponent] = []
        self._gen_dom(m, k, 0, [], results)
        return results

    def _gen_dom(self, m, remaining, idx, current, results):
        if idx == self.dim:
            if remaining == 0:
                results.append(tuple(current))
            return
        max_val = min(m[idx], remaining)
        for v in range(max_val + 1):
            current.append(v)
            self._gen_dom(m, remaining - v, idx + 1, current, results)
            current.pop()

    def quadratic_leaf_set(self) -> Set[Exponent]:
        """Compute LeafSet₂(S) = degree-(d-2) shadow.

        Time: same as degree_shadow(d-2)
        """
        if self.degree < 2:
            return set()
        return self.degree_shadow(self.degree - 2)

    def shadow_certificate(self, k: int) -> Dict:
        """Build a shadow certificate: for each shadow element u,
        record a witness m ∈ S with u ≤ m.

        Time: O(|shadow| * |S| * n)
        Space: O(|shadow|)
        Returns: dict mapping each shadow element to its witness.
        """
        shadow = self.degree_shadow(k)
        certificate = {}
        for u in shadow:
            for m in self.elements:
                if all(u[i] <= m[i] for i in range(self.dim)):
                    certificate[u] = m
                    break
        return certificate

    def is_multiaffine(self) -> bool:
        """Check if all elements are multiaffine (0/1 vectors).

        Time: O(|S| * n)
        """
        return all(all(v <= 1 for v in m) for m in self.elements)

    def shadow_bound(self, k: int) -> int:
        """The theoretical upper bound on |shadow_k|.

        For multiaffine families: C(ω, k)
        For general families: C(ω + k - 1, k) (stars and bars)
        """
        if self.is_multiaffine():
            return comb(self.omega, k)
        else:
            return comb(self.omega + k - 1, k)

    def shadow_profile(self) -> List[Tuple[int, int, int, bool]]:
        """Compute the full shadow profile.

        Returns: list of (k, |shadow_k|, bound, holds) for k = 0,...,d
        """
        profile = []
        multiaffine = self.is_multiaffine()
        for k in range(self.degree + 1):
            shadow = self.degree_shadow(k)
            bound = comb(self.omega, k) if multiaffine else comb(self.omega + k - 1, k)
            profile.append((k, len(shadow), bound, len(shadow) <= bound))
        return profile

    def tropical_initial(self, w: Tuple[int, ...]) -> 'MConvexFamily':
        """Compute the tropical initial support under weight vector w.

        Time: O(|S| * n)
        Space: O(|init|)
        """
        min_val = min(sum(w[i] * m[i] for i in range(self.dim)) for m in self.elements)
        init_elems = {m for m in self.elements
                      if sum(w[i] * m[i] for i in range(self.dim)) == min_val}
        return MConvexFamily(init_elems)

    def exchange_graph(self) -> Dict[Exponent, List[Tuple[int, int, Exponent]]]:
        """Build the exchange graph.

        Nodes = elements, edges = single-step exchanges.
        Time: O(|S|^2 * n^2)
        Returns: adjacency list mapping each element to its exchange neighbors.
        """
        graph: Dict[Exponent, List[Tuple[int, int, Exponent]]] = defaultdict(list)
        for alpha in self.elements:
            for i in range(self.dim):
                if alpha[i] > 0:
                    for j in range(self.dim):
                        if i != j:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            t = tuple(exchanged)
                            if t in self._elem_set:
                                graph[alpha].append((i, j, t))
        return dict(graph)


# ─── Factory Functions ───────────────────────────────────────────────

def uniform_matroid(n: int, r: int) -> MConvexFamily:
    """Create the uniform matroid U_{r,n}."""
    bases = set()
    for subset in combinations(range(n), r):
        vec = [0] * n
        for i in subset:
            vec[i] = 1
        bases.add(tuple(vec))
    return MConvexFamily(bases)


def full_simplex(n: int, d: int) -> MConvexFamily:
    """Create the full simplex: all degree-d vectors on n coordinates."""
    vecs: List[Exponent] = []
    _gen_all(n, d, d, 0, [], vecs)
    return MConvexFamily(set(vecs))


def _gen_all(n, d, remaining, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(remaining + 1):
        current.append(v)
        _gen_all(n, d, remaining - v, idx + 1, current, results)
        current.pop()


def schur_family(partition: Tuple[int, ...], n: int) -> MConvexFamily:
    """Create the Schur polynomial Newton support."""
    lam = list(partition)
    d = sum(lam)
    support = set()

    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)

    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return MConvexFamily(support)


if __name__ == "__main__":
    # Quick demonstration
    print("=== M-Convex Shadow Compression Algorithms ===\n")

    # Uniform matroid
    F = uniform_matroid(5, 3)
    print(f"U_{{3,5}}: |S|={len(F.elements)}, ω={F.omega}, multiaffine={F.is_multiaffine()}")
    print(f"  M-convex: {F.verify_exchange()}")
    print(f"  Shadow profile: {F.shadow_profile()}")

    # Schur polynomial
    G = schur_family((2, 1), 3)
    print(f"\nSchur s_(2,1): |S|={len(G.elements)}, ω={G.omega}")
    print(f"  M-convex: {G.verify_exchange()}")
    print(f"  Shadow profile: {G.shadow_profile()}")
    cert = G.shadow_certificate(1)
    print(f"  Leaf certificate (k=1): {cert}")

    # Tropical
    init = G.tropical_initial((1, 2, 3))
    print(f"  Initial support w=(1,2,3): {sorted(init.elements)}")
    print(f"  Initial M-convex: {init.verify_exchange()}")
