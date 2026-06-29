"""
Algorithms for Leaf Witness Exchange Properties of Valuated Matroids.

This module implements the core algorithms for computing leaf witnesses
of basis generating polynomials, verifying the tropical exchange axiom,
and testing the tropical Plücker conjecture.

References:
    - Dress-Wenzel, "Valuated Matroids", Advances in Mathematics, 1992
    - Brändén-Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
"""

from __future__ import annotations
from typing import FrozenSet, Dict, Tuple, List, Set, Optional
from itertools import combinations
import math


# Type aliases
Element = int
Basis = FrozenSet[int]
Monomial = Tuple[int, ...]  # exponent vector
Polynomial = Dict[Monomial, float]  # monomial -> coefficient


class Matroid:
    """A matroid defined by its ground set and collection of bases.

    Attributes:
        ground_set: The ground set E as a frozenset of integers.
        bases: The collection of bases as a set of frozensets.
        rank: The common cardinality of all bases.
    """

    def __init__(self, ground_set: FrozenSet[int], bases: Set[Basis]):
        self.ground_set = ground_set
        self.bases = bases
        if bases:
            ranks = {len(b) for b in bases}
            assert len(ranks) == 1, "All bases must have the same cardinality"
            self.rank = ranks.pop()
        else:
            self.rank = 0

    def is_base(self, s: FrozenSet[int]) -> bool:
        """Check if a set is a basis."""
        return s in self.bases

    @staticmethod
    def uniform(n: int, r: int) -> 'Matroid':
        """Create the uniform matroid U(r, n) on ground set {0, ..., n-1}.

        U(r, n) has as bases all r-element subsets of {0, ..., n-1}.

        Args:
            n: Size of ground set.
            r: Rank (basis size).

        Returns:
            The uniform matroid U(r, n).
        """
        E = frozenset(range(n))
        bases = {frozenset(c) for c in combinations(range(n), r)}
        return Matroid(E, bases)

    @staticmethod
    def graphic(n: int, edges: List[Tuple[int, int]]) -> 'Matroid':
        """Create a graphic matroid from a graph.

        The ground set is the set of edge indices. A subset of edges
        is independent iff it contains no cycle. Bases are spanning forests.

        Args:
            n: Number of vertices.
            edges: List of edges as (u, v) pairs.

        Returns:
            The graphic matroid.
        """
        E = frozenset(range(len(edges)))

        def is_acyclic(edge_set: FrozenSet[int]) -> bool:
            """Check if edge subset is acyclic using union-find."""
            parent = list(range(n))

            def find(x: int) -> int:
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x

            def union(x: int, y: int) -> bool:
                rx, ry = find(x), find(y)
                if rx == ry:
                    return False
                parent[rx] = ry
                return True

            for idx in edge_set:
                u, v = edges[idx]
                if not union(u, v):
                    return False
            return True

        def components(edge_set: FrozenSet[int]) -> int:
            """Count connected components."""
            parent = list(range(n))

            def find(x: int) -> int:
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x

            def union(x: int, y: int) -> None:
                rx, ry = find(x), find(y)
                if rx != ry:
                    parent[rx] = ry

            for idx in edge_set:
                u, v = edges[idx]
                union(u, v)

            return len({find(i) for i in range(n)})

        # Bases are maximal acyclic subsets (spanning forests)
        # A spanning forest has n - c edges where c is the number of components
        # For a connected graph, rank = n - 1
        target_rank = n - components(E)
        bases: Set[Basis] = set()
        for r_sub in combinations(range(len(edges)), target_rank):
            fs = frozenset(r_sub)
            if is_acyclic(fs):
                bases.add(fs)

        return Matroid(E, bases)


def basis_generating_polynomial(M: Matroid) -> Polynomial:
    """Compute the basis generating polynomial g_M.

    g_M = sum_{B in bases(M)} prod_{i in B} x_i

    The polynomial is represented as a dictionary from exponent vectors
    (tuples of nonneg integers) to coefficients.

    Args:
        M: A matroid.

    Returns:
        The basis generating polynomial as a dict of monomials.

    Example:
        >>> M = Matroid.uniform(3, 2)
        >>> p = basis_generating_polynomial(M)
        >>> len(p)  # 3 bases: {0,1}, {0,2}, {1,2}
        3
    """
    n = max(M.ground_set) + 1 if M.ground_set else 0
    poly: Polynomial = {}
    for basis in M.bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly


def partial_derivative(p: Polynomial, var: int) -> Polynomial:
    """Compute the partial derivative of p with respect to x_var.

    Args:
        p: A polynomial as a dict of monomials.
        var: The variable index to differentiate by.

    Returns:
        The partial derivative ∂p/∂x_var.
    """
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            new_exp = list(exp)
            new_coeff = coeff * exp[var]
            new_exp[var] -= 1
            new_key = tuple(new_exp)
            result[new_key] = result.get(new_key, 0.0) + new_coeff
    return result


def evaluate_at_ones(p: Polynomial) -> float:
    """Evaluate a polynomial at x = (1, 1, ..., 1).

    Args:
        p: A polynomial as a dict of monomials.

    Returns:
        p(1, 1, ..., 1).
    """
    return sum(p.values())


def leaf_witness(p: Polynomial, S: FrozenSet[int]) -> float:
    """Compute the leaf witness of polynomial p at subset S.

    The leaf witness is the value of the iterated partial derivative
    of p along all coordinates in S, evaluated at x = (1, ..., 1).

    leafWitness(p, S) = (prod_{i in S} d/dx_i) p |_{x=1}

    Args:
        p: A polynomial.
        S: A subset of variable indices.

    Returns:
        The leaf witness value.

    Example:
        >>> M = Matroid.uniform(3, 2)
        >>> p = basis_generating_polynomial(M)
        >>> leaf_witness(p, frozenset({0, 1}))
        1.0
    """
    current = p
    for i in sorted(S):
        current = partial_derivative(current, i)
    return evaluate_at_ones(current)


def verify_tropical_exchange(M: Matroid, v: Dict[Basis, float]) -> Tuple[bool, Optional[str]]:
    """Verify the tropical exchange axiom for a valuation on matroid bases.

    For each pair (B1, B2) of bases and each a in B1 \\ B2, checks that
    there exists b in B2 \\ B1 such that:
    1. (B1 \\ {a}) ∪ {b} is a basis
    2. v((B1 \\ {a}) ∪ {b}) >= min(v(B1), v(B2))

    Args:
        M: A matroid.
        v: A valuation function on bases (dict from basis to real value).

    Returns:
        (True, None) if the axiom holds, (False, description) otherwise.
    """
    for B1 in M.bases:
        for B2 in M.bases:
            if B1 == B2:
                continue
            for a in B1 - B2:
                found = False
                for b in B2 - B1:
                    B_new = (B1 - {a}) | {b}
                    if M.is_base(B_new) and v.get(B_new, float('-inf')) >= min(v[B1], v[B2]) - 1e-10:
                        found = True
                        break
                if not found:
                    return False, f"Exchange failed: B1={B1}, B2={B2}, a={a}"
    return True, None


def verify_tropical_pluecker(
    v: Dict[Basis, float],
    ground_set: FrozenSet[int],
    rank: int
) -> Tuple[bool, Optional[str]]:
    """Verify the tropical Plücker relations for a valuation.

    For each (r-2)-subset S and each 4-tuple (i,j,k,l) of elements not in S,
    checks:
        v(S∪{i,j}) + v(S∪{k,l}) >= min(
            v(S∪{i,k}) + v(S∪{j,l}),
            v(S∪{i,l}) + v(S∪{j,k})
        )

    Args:
        v: Valuation on rank-r subsets.
        ground_set: The ground set.
        rank: The rank (basis size).

    Returns:
        (True, None) if relations hold, (False, description) otherwise.
    """
    if rank < 2:
        return True, None

    elements = sorted(ground_set)

    for S_tuple in combinations(elements, rank - 2):
        S = frozenset(S_tuple)
        remaining = sorted(ground_set - S)
        if len(remaining) < 4:
            continue

        for i, j, k, l in combinations(remaining, 4):
            sets = {}
            for a, b in [(i,j), (i,k), (i,l), (j,k), (j,l), (k,l)]:
                key = S | {a, b}
                if key in v:
                    sets[(a,b)] = v[key]

            if len(sets) < 6:
                continue  # Skip if not all subsets are bases

            lhs = sets[(i,j)] + sets[(k,l)]
            rhs1 = sets[(i,k)] + sets[(j,l)]
            rhs2 = sets[(i,l)] + sets[(j,k)]

            if lhs < min(rhs1, rhs2) - 1e-10:
                return False, (
                    f"Plücker violation: S={S}, (i,j,k,l)=({i},{j},{k},{l}), "
                    f"LHS={lhs:.6f}, RHS=min({rhs1:.6f}, {rhs2:.6f})={min(rhs1,rhs2):.6f}"
                )

    return True, None


def exchange_distance(A: FrozenSet[int], B: FrozenSet[int]) -> int:
    """Compute the exchange distance |A △ B|.

    Args:
        A, B: Two sets.

    Returns:
        The cardinality of the symmetric difference.
    """
    return len(A.symmetric_difference(B))


def exchange_graph(M: Matroid) -> Dict[Basis, List[Basis]]:
    """Compute the base exchange graph of a matroid.

    Two bases are adjacent if they differ by a single exchange
    (symmetric difference has size 2).

    Args:
        M: A matroid.

    Returns:
        Adjacency list representation.
    """
    graph: Dict[Basis, List[Basis]] = {b: [] for b in M.bases}
    bases_list = list(M.bases)
    for i, b1 in enumerate(bases_list):
        for b2 in bases_list[i+1:]:
            if exchange_distance(b1, b2) == 2:
                graph[b1].append(b2)
                graph[b2].append(b1)
    return graph


def leaf_witness_valuation(M: Matroid) -> Dict[Basis, float]:
    """Compute the leaf witness valuation for all bases of a matroid.

    Args:
        M: A matroid.

    Returns:
        Dictionary mapping each basis to its leaf witness value.
    """
    p = basis_generating_polynomial(M)
    return {b: leaf_witness(p, b) for b in M.bases}


if __name__ == "__main__":
    # Example: Uniform matroid U(2, 4)
    print("=== Uniform Matroid U(2, 4) ===")
    M = Matroid.uniform(4, 2)
    print(f"Ground set: {sorted(M.ground_set)}")
    print(f"Bases: {[sorted(b) for b in sorted(M.bases)]}")
    print(f"Rank: {M.rank}")

    # Compute leaf witnesses
    lw = leaf_witness_valuation(M)
    print("\nLeaf witnesses:")
    for b in sorted(M.bases):
        print(f"  {sorted(b)}: {lw[b]:.4f}")

    # Verify tropical exchange
    ok, msg = verify_tropical_exchange(M, lw)
    print(f"\nTropical exchange: {'PASS' if ok else 'FAIL'}")
    if msg:
        print(f"  {msg}")

    # Verify Plücker
    ok, msg = verify_tropical_pluecker(lw, M.ground_set, M.rank)
    print(f"Tropical Plücker: {'PASS' if ok else 'FAIL'}")
    if msg:
        print(f"  {msg}")

    # Example: Graphic matroid (K4)
    print("\n=== Graphic Matroid of K4 ===")
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    M_k4 = Matroid.graphic(4, edges)
    print(f"Edges: {edges}")
    print(f"Bases (spanning trees): {len(M_k4.bases)}")
    print(f"Rank: {M_k4.rank}")

    lw_k4 = leaf_witness_valuation(M_k4)
    ok, msg = verify_tropical_exchange(M_k4, lw_k4)
    print(f"Tropical exchange: {'PASS' if ok else 'FAIL'}")

    ok, msg = verify_tropical_pluecker(lw_k4, M_k4.ground_set, M_k4.rank)
    print(f"Tropical Plücker: {'PASS' if ok else 'FAIL'}")
