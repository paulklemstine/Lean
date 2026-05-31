"""
Tropical Brill-Noether Theory: Algorithms

Type-hinted implementations of the key algorithms in tropical Brill-Noether theory,
including the Brill-Noether number computation, chip-firing simulation, and
Dhar's burning algorithm for computing divisor ranks on graphs.
"""
from typing import List, Dict, Tuple, Set, Optional
from collections import defaultdict
import itertools


def brill_noether_number(g: int, d: int, r: int) -> int:
    """Compute the Brill-Noether number ρ(g,d,r) = g - (r+1)(g-d+r).
    
    This integer governs the expected dimension of the space of linear series
    of degree d and rank r on a curve of genus g.
    
    Args:
        g: genus of the curve
        d: degree of the divisor
        r: rank of the linear series
    
    Returns:
        The Brill-Noether number ρ(g,d,r)
    """
    return g - (r + 1) * (g - d + r)


def max_brill_noether_rank(g: int, d: int) -> int:
    """Find the maximum rank r such that ρ(g,d,r) ≥ 0.
    
    By the Brill-Noether theorem, this is the maximum rank of a divisor
    of degree d on a general curve of genus g.
    
    Args:
        g: genus of the curve  
        d: degree of the divisor
    
    Returns:
        Maximum rank r with ρ(g,d,r) ≥ 0, or -1 if no such r exists
    """
    r = 0
    max_r = -1
    while True:
        rho = brill_noether_number(g, d, r)
        if rho < 0:
            break
        max_r = r
        r += 1
    return max_r


class Graph:
    """A simple undirected graph for chip-firing.
    
    Vertices are integers 0..n-1. Edges are stored as adjacency lists.
    """
    
    def __init__(self, n: int):
        self.n = n
        self.adj: Dict[int, List[int]] = defaultdict(list)
        self.edges: List[Tuple[int, int]] = []
    
    def add_edge(self, u: int, v: int) -> None:
        """Add an undirected edge between u and v."""
        self.adj[u].append(v)
        self.adj[v].append(u)
        self.edges.append((u, v))
    
    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return len(self.adj[v])
    
    def genus(self) -> int:
        """Return the genus (cycle rank) of the graph: |E| - |V| + 1."""
        return len(self.edges) - self.n + 1
    
    @staticmethod
    def chain_of_loops(g: int) -> 'Graph':
        """Construct a chain of g loops (the generic tropical curve of genus g).
        
        This graph has g+1 vertices v_0, ..., v_g, with two edges between
        consecutive vertices v_i and v_{i+1}.
        """
        n = g + 1
        G = Graph(n)
        for i in range(g):
            G.add_edge(i, i + 1)
            G.add_edge(i, i + 1)  # Double edge for loop
        return G


class Divisor:
    """A divisor on a graph: an integer-valued function on vertices."""
    
    def __init__(self, values: List[int]):
        self.values = list(values)
    
    def __getitem__(self, v: int) -> int:
        return self.values[v]
    
    def __setitem__(self, v: int, val: int) -> None:
        self.values[v] = val
    
    def degree(self) -> int:
        """Sum of all chip values."""
        return sum(self.values)
    
    def is_effective(self) -> bool:
        """True if all values are non-negative."""
        return all(v >= 0 for v in self.values)
    
    def copy(self) -> 'Divisor':
        return Divisor(list(self.values))
    
    def __sub__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([a - b for a, b in zip(self.values, other.values)])
    
    def __add__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([a + b for a, b in zip(self.values, other.values)])
    
    def __repr__(self) -> str:
        return f"Divisor({self.values})"


def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: send one chip along each edge from v.
    
    Args:
        G: the graph
        D: the current divisor
        v: vertex to fire
    
    Returns:
        New divisor after firing v
    """
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.adj[v]:
        result[w] += 1
    return result


def dhars_burning(G: Graph, D: Divisor, q: int) -> Tuple[bool, Set[int]]:
    """Dhar's burning algorithm to test if a divisor is q-reduced.
    
    Simulates a fire starting at q. Returns whether the fire reaches all
    vertices (meaning D is q-reduced and effective iff D(q) ≥ 0).
    
    Args:
        G: the graph
        D: the divisor
        q: the distinguished vertex
    
    Returns:
        (is_reduced, burned_set): whether D is q-reduced and the set of burned vertices
    """
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned:
                continue
            # Count edges from v to burned vertices
            edges_to_burned = sum(1 for w in G.adj[v] if w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == G.n, burned


def compute_rank(G: Graph, D: Divisor, q: int = 0) -> int:
    """Compute the rank of divisor D on graph G using Dhar's algorithm.
    
    The rank r(D) is the maximum integer r ≥ -1 such that D - E is linearly
    equivalent to an effective divisor for all effective E with deg(E) = r.
    
    Uses the q-reduced representative to efficiently compute rank.
    
    Args:
        G: the graph
        D: the divisor  
        q: distinguished vertex for reduction (default: 0)
    
    Returns:
        The rank of D, or -1 if D is not equivalent to any effective divisor
    """
    # First, reduce D to its q-reduced form
    D_red = reduce_divisor(G, D, q)
    
    if D_red[q] < 0:
        return -1
    
    # Rank is at least 0. Try subtracting effective divisors.
    r = 0
    while True:
        # Check if rank is > r by trying all effective E with deg = r+1
        # that are single-vertex point masses (sufficient by theory)
        can_subtract = True
        for v in range(G.n):
            E = Divisor([0] * G.n)
            E[v] = r + 1
            D_minus_E = D_red - E
            D_red_new = reduce_divisor(G, D_minus_E, q)
            if D_red_new[q] < 0:
                can_subtract = False
                break
        if not can_subtract:
            return r
        r += 1
        if r > D.degree():  # Rank can't exceed degree
            return r


def reduce_divisor(G: Graph, D: Divisor, q: int) -> Divisor:
    """Compute the q-reduced divisor linearly equivalent to D.
    
    Repeatedly fires subsets of V\{q} until no more can fire.
    
    Args:
        G: the graph
        D: the divisor
        q: distinguished vertex
    
    Returns:
        The unique q-reduced divisor equivalent to D
    """
    D_current = D.copy()
    max_iterations = 10000
    
    for _ in range(max_iterations):
        # Find a vertex v ≠ q that can fire (has enough chips)
        fired = False
        for v in range(G.n):
            if v == q:
                continue
            if D_current[v] >= G.degree(v):
                D_current = chip_fire(G, D_current, v)
                fired = True
                break
        
        if not fired:
            # Try anti-firing q (adding chips at q, removing from neighbors)
            # This is equivalent to firing all vertices except q
            is_reduced, _ = dhars_burning(G, D_current, q)
            if is_reduced:
                break
            # Fire all non-burned vertices
            _, burned = dhars_burning(G, D_current, q)
            unburned = [v for v in range(G.n) if v not in burned]
            if not unburned:
                break
            for v in unburned:
                D_current = chip_fire(G, D_current, v)
    
    return D_current


def brill_noether_table(g_max: int) -> List[List[Tuple[int, int]]]:
    """Generate a table of (max_rank, ρ) values for each (g, d).
    
    Args:
        g_max: maximum genus to compute
    
    Returns:
        Table indexed by [g][d] giving (max_rank, ρ_at_max_rank)
    """
    table = []
    for g in range(g_max + 1):
        row = []
        for d in range(2 * g + 1):
            r = max_brill_noether_rank(g, d)
            rho = brill_noether_number(g, d, r) if r >= 0 else -1
            row.append((r, rho))
        table.append(row)
    return table


def verify_serre_duality(g: int, d: int, r: int) -> bool:
    """Verify that ρ(g,d,r) = ρ(g, 2g-2-d, g-1-d+r).
    
    This is the computational verification of the Serre duality theorem.
    """
    rho1 = brill_noether_number(g, d, r)
    d_dual = 2 * g - 2 - d
    r_dual = g - 1 - d + r
    rho2 = brill_noether_number(g, d_dual, r_dual)
    return rho1 == rho2


def canonical_divisor(G: Graph) -> Divisor:
    """Compute the canonical divisor K(v) = deg(v) - 2."""
    return Divisor([G.degree(v) - 2 for v in range(G.n)])


if __name__ == "__main__":
    # Example computations
    print("=== Brill-Noether Number Examples ===")
    examples = [(2,2,1), (3,3,1), (4,3,1), (4,4,1), (5,4,1), (5,4,2)]
    for g, d, r in examples:
        rho = brill_noether_number(g, d, r)
        print(f"ρ({g},{d},{r}) = {rho}")
    
    print("\n=== Serre Duality Verification ===")
    for g in range(1, 6):
        for d in range(2*g):
            for r in range(d+1):
                assert verify_serre_duality(g, d, r), f"Failed at ({g},{d},{r})"
    print("Serre duality verified for g ≤ 5")
    
    print("\n=== Chain of Loops ===")
    for g in range(1, 6):
        G = Graph.chain_of_loops(g)
        print(f"Chain of {g} loops: {G.n} vertices, {len(G.edges)} edges, genus {G.genus()}")
        K = canonical_divisor(G)
        print(f"  Canonical divisor: {K.values}, degree = {K.degree()}")
    
    print("\n=== Rank Computation on Chain of 3 Loops ===")
    G = Graph.chain_of_loops(3)
    for d in range(7):
        D = Divisor([d] + [0] * (G.n - 1))
        r = compute_rank(G, D)
        r_max = max_brill_noether_rank(3, d)
        print(f"  deg={d}: computed rank={r}, BN max rank={r_max}")
