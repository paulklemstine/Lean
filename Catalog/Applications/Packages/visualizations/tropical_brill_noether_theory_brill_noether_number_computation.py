#!/usr/bin/env python3
"""
Algorithms for Tropical Brill-Noether Theory

Implements the core computational algorithms related to the Brill-Noether
number, chip-firing on graphs, and divisor rank computation.
"""

from typing import List, Tuple, Optional, Dict, Set
from collections import defaultdict
import itertools


def brill_noether_number(g: int, r: int, d: int) -> int:
    """
    Compute ρ(g, r, d) = g - (r+1)(g - d + r).

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return g - (r + 1) * (g - d + r)


def min_degree_for_rank(g: int, r: int) -> int:
    """
    Find the minimum degree d such that ρ(g, r, d) ≥ 0.

    ρ ≥ 0 ⟺ (r+1)d ≥ r(g + r + 1)
    ⟺ d ≥ r(g + r + 1) / (r + 1)

    Time complexity: O(1)
    Space complexity: O(1)
    """
    if r == 0:
        return 0
    # Ceiling of r(g + r + 1) / (r + 1)
    numerator = r * (g + r + 1)
    return (numerator + r) // (r + 1)


def max_rank_for_degree(g: int, d: int) -> int:
    """
    Find the maximum rank r such that ρ(g, r, d) ≥ 0.

    Binary search on r.

    Time complexity: O(log(d))
    Space complexity: O(1)
    """
    if d < 0:
        return -1

    lo, hi = 0, d
    best = -1
    while lo <= hi:
        mid = (lo + hi) // 2
        if brill_noether_number(g, mid, d) >= 0:
            best = mid
            lo = mid + 1
        else:
            hi = mid - 1
    return best


class ChainOfLoops:
    """
    Represents a chain of g loops (banana graph).

    Vertices: 0, 1, ..., g
    Edges: for each i in 0..g-1, there are two edges from i to i+1
           (top edge and bottom edge)
    """

    def __init__(self, g: int, top_lengths: Optional[List[float]] = None,
                 bot_lengths: Optional[List[float]] = None):
        self.g = g
        self.num_vertices = g + 1

        if top_lengths is None:
            top_lengths = [float(i + 1) for i in range(g)]
        if bot_lengths is None:
            bot_lengths = [1.0] * g

        assert len(top_lengths) == g
        assert len(bot_lengths) == g
        assert all(t > 0 for t in top_lengths)
        assert all(b > 0 for b in bot_lengths)

        self.top_lengths = top_lengths
        self.bot_lengths = bot_lengths

    def is_generic(self) -> bool:
        """Check if edge-length ratios are pairwise distinct."""
        ratios = [t / b for t, b in zip(self.top_lengths, self.bot_lengths)]
        return len(set(ratios)) == len(ratios)

    def adjacency_matrix(self) -> List[List[int]]:
        """Return the multigraph adjacency matrix."""
        n = self.num_vertices
        adj = [[0] * n for _ in range(n)]
        for i in range(self.g):
            adj[i][i + 1] = 2
            adj[i + 1][i] = 2
        return adj

    def degree_of_vertex(self, v: int) -> int:
        """Degree of vertex v in the multigraph."""
        if v == 0 or v == self.g:
            return 2
        return 4

    def genus(self) -> int:
        """First Betti number = number of independent cycles."""
        return self.g


class GraphDivisor:
    """A divisor on a finite graph: integer-valued function on vertices."""

    def __init__(self, values: List[int]):
        self.values = list(values)
        self.n = len(values)

    def degree(self) -> int:
        """Sum of all values."""
        return sum(self.values)

    def is_effective(self) -> bool:
        """All values ≥ 0."""
        return all(v >= 0 for v in self.values)

    def __sub__(self, other: 'GraphDivisor') -> 'GraphDivisor':
        return GraphDivisor([a - b for a, b in zip(self.values, other.values)])

    def __add__(self, other: 'GraphDivisor') -> 'GraphDivisor':
        return GraphDivisor([a + b for a, b in zip(self.values, other.values)])

    def __repr__(self) -> str:
        return f"Divisor({self.values})"


def chip_fire(divisor: GraphDivisor, adj: List[List[int]], vertex: int) -> GraphDivisor:
    """
    Perform a chip-firing move at the given vertex.

    Each neighbor w of v receives adj[v][w] chips from v,
    and v loses sum(adj[v][w]) chips.

    Time complexity: O(n) where n is number of vertices
    """
    new_values = list(divisor.values)
    n = len(new_values)
    total_fired = 0
    for w in range(n):
        if w != vertex:
            new_values[w] += adj[vertex][w]
            total_fired += adj[vertex][w]
    new_values[vertex] -= total_fired
    return GraphDivisor(new_values)


def compute_rank_bruteforce(divisor: GraphDivisor, adj: List[List[int]],
                            max_depth: int = 10) -> int:
    """
    Compute the Baker-Norine rank of a divisor by brute force.

    Uses BFS over chip-firing moves to find all linearly equivalent divisors.
    Then checks the rank definition.

    WARNING: Exponential in the number of vertices. Only for small examples.

    Time complexity: O(2^(max_depth * n))
    """
    n = divisor.n

    # Find all reachable effective divisors via chip-firing
    def find_effective_equivalents(D: GraphDivisor, depth: int) -> Set[tuple]:
        visited = set()
        queue = [tuple(D.values)]
        visited.add(queue[0])
        effective = set()

        for _ in range(depth):
            next_queue = []
            for state in queue:
                d = GraphDivisor(list(state))
                if d.is_effective():
                    effective.add(state)
                for v in range(n):
                    new_d = chip_fire(d, adj, v)
                    key = tuple(new_d.values)
                    if key not in visited:
                        visited.add(key)
                        next_queue.append(key)
            queue = next_queue

        return effective

    # Check if D - E has an effective representative
    def has_effective_rep(D: GraphDivisor, E: GraphDivisor) -> bool:
        diff = D - E
        effs = find_effective_equivalents(diff, max_depth)
        return len(effs) > 0

    # Check rank
    rank = -1
    for r in range(divisor.degree() + 1):
        # Check if for ALL effective E of degree r, D-E has effective rep
        all_pass = True
        for combo in itertools.combinations_with_replacement(range(n), r):
            E_vals = [0] * n
            for v in combo:
                E_vals[v] += 1
            E = GraphDivisor(E_vals)
            if not has_effective_rep(divisor, E):
                all_pass = False
                break
        if all_pass:
            rank = r
        else:
            break

    return rank


def bn_existence_table(max_g: int = 10, max_r: int = 5) -> Dict[Tuple[int, int], int]:
    """
    Build a table: (g, r) -> minimum degree d for existence.

    Time complexity: O(max_g * max_r)
    """
    table = {}
    for g in range(max_g + 1):
        for r in range(max_r + 1):
            table[(g, r)] = min_degree_for_rank(g, r)
    return table


def verify_clifford_bound(max_g: int = 20) -> bool:
    """
    Verify the Clifford bound computationally.

    For all g ≥ 2, r ≥ 1, d ≤ 2g-2 with ρ ≥ 0: check d ≥ 2r.

    Time complexity: O(max_g^3)
    """
    for g in range(2, max_g + 1):
        for r in range(1, g + 1):
            for d in range(2 * g - 1):
                rho = brill_noether_number(g, r, d)
                if rho >= 0 and d < 2 * r:
                    return False
    return True


if __name__ == "__main__":
    print("Tropical Brill-Noether Algorithms")
    print("=" * 50)

    # Minimum degree table
    print("\nMinimum degree for rank-r divisors on genus-g curves:")
    table = bn_existence_table(8, 4)
    header = f"{'g':>2}\{'r':>2}"
    for r in range(5):
        header += f" r={r:>2}"
    print(header)
    for g in range(9):
        row = f"{g:>4}"
        for r in range(5):
            row += f" {table[(g, r)]:>4}"
        print(row)

    # Max rank table
    print("\nMaximum rank for degree-d divisors on genus-g curves:")
    header = "g\d".rjust(4)
    for d in range(11):
        header += f" d={d:>2}"
    print(header)
    for g in range(7):
        row = f"{g:>4}"
        for d in range(11):
            row += f" {max_rank_for_degree(g, d):>4}"
        print(row)

    # Clifford bound
    print(f"\nClifford bound verified up to g=20: {verify_clifford_bound(20)}")

    # Chain of loops example
    print("\nChain of 3 loops (genus 3):")
    chain = ChainOfLoops(3)
    print(f"  Generic: {chain.is_generic()}")
    print(f"  Adjacency: {chain.adjacency_matrix()}")
    print(f"  Gonality: {min_degree_for_rank(3, 1)}")
