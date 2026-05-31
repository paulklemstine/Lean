"""
Chip-Firing and Graph Riemann-Roch: Core Algorithms

Implements the Baker-Norine theory for finite graphs:
- Graph divisors and chip-firing
- Canonical divisors and genus computation
- Dhar's burning algorithm for rank computation
- The Riemann-Roch verification
"""

from typing import List, Tuple, Dict, Set, Optional
from itertools import product as iproduct


class Graph:
    """Simple undirected graph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
        for u, v in edges:
            assert u != v, "No self-loops"
            self.adj[u].add(v)
            self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def num_edges(self) -> int:
        return sum(self.degree(v) for v in range(self.n)) // 2

    def genus(self) -> int:
        """Cyclomatic number: |E| - |V| + 1."""
        return self.num_edges() - self.n + 1

    def laplacian(self) -> List[List[int]]:
        """The graph Laplacian matrix L: L[v][v] = deg(v), L[v][w] = -1 if adj."""
        L = [[0] * self.n for _ in range(self.n)]
        for v in range(self.n):
            L[v][v] = self.degree(v)
            for w in self.adj[v]:
                L[v][w] = -1
        return L

    @staticmethod
    def complete(n: int) -> 'Graph':
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return Graph(n, edges)

    @staticmethod
    def cycle(n: int) -> 'Graph':
        edges = [(i, (i + 1) % n) for i in range(n)]
        return Graph(n, edges)

    @staticmethod
    def path(n: int) -> 'Graph':
        edges = [(i, i + 1) for i in range(n - 1)]
        return Graph(n, edges)


class Divisor:
    """A divisor on a graph: assigns an integer to each vertex."""

    def __init__(self, values: List[int]):
        self.values = list(values)
        self.n = len(values)

    def __getitem__(self, v: int) -> int:
        return self.values[v]

    def __setitem__(self, v: int, val: int) -> None:
        self.values[v] = val

    def degree(self) -> int:
        return sum(self.values)

    def is_effective(self) -> bool:
        return all(v >= 0 for v in self.values)

    def __sub__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([a - b for a, b in zip(self.values, other.values)])

    def __add__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([a + b for a, b in zip(self.values, other.values)])

    def __repr__(self) -> str:
        return f"Divisor({self.values})"

    def copy(self) -> 'Divisor':
        return Divisor(list(self.values))


def canonical_divisor(G: Graph) -> Divisor:
    """The canonical divisor K_G: K_G(v) = deg(v) - 2."""
    return Divisor([G.degree(v) - 2 for v in range(G.n)])


def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: send one chip along each edge."""
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.adj[v]:
        result[w] += 1
    return result


def q_reduce(G: Graph, D: Divisor, q: int = 0) -> Divisor:
    """
    Compute the q-reduced divisor linearly equivalent to D.
    Uses Dhar's burning algorithm iteratively.

    The q-reduced divisor D' satisfies:
    1. D'(v) >= 0 for all v != q
    2. No non-empty subset of V\\{q} can legally fire
    """
    n = G.n
    D_vals = list(D.values)

    for _ in range(10000):
        # Phase 1: Make non-q vertices non-negative by anti-firing
        # Process in rounds until stable
        stabilized = False
        for __ in range(10000):
            worst_v = -1
            worst_val = 0
            for v in range(n):
                if v == q:
                    continue
                if D_vals[v] < worst_val:
                    worst_v = v
                    worst_val = D_vals[v]
            if worst_v == -1:
                stabilized = True
                break
            v = worst_v
            # Anti-fire v enough times to make it non-negative
            times = (-D_vals[v] + G.degree(v) - 1) // G.degree(v)
            D_vals[v] += times * G.degree(v)
            for w in G.adj[v]:
                D_vals[w] -= times

        if not stabilized:
            break

        # Phase 2: Dhar's burning from q
        burnt = {q}
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if v in burnt:
                    continue
                edges_to_burnt = sum(1 for w in G.adj[v] if w in burnt)
                if edges_to_burnt > D_vals[v]:
                    burnt.add(v)
                    changed = True

        if len(burnt) == n:
            break  # q-reduced!

        # Fire the unburnt set
        unburnt = [v for v in range(n) if v not in burnt]
        for v in unburnt:
            D_vals[v] -= G.degree(v)
            for w in G.adj[v]:
                D_vals[w] += 1

    return Divisor(D_vals)


def has_effective_equivalent(G: Graph, D: Divisor, q: int = 0) -> bool:
    """Check if D is linearly equivalent to an effective divisor.

    Uses q-reduced form: D ~ effective iff q-reduced form has D'(q) >= 0.
    """
    if D.degree() < 0:
        return False
    D_red = q_reduce(G, D, q)
    return D_red.is_effective()


def compute_rank(G: Graph, D: Divisor) -> int:
    """
    Compute the rank of divisor D on graph G.

    r(D) = -1 if D is not equivalent to an effective divisor.
    Otherwise r(D) = max{k : for all effective E with deg(E)=k, D-E ~ effective}.
    """
    if not has_effective_equivalent(G, D):
        return -1

    r = 0
    while r <= D.degree():
        if not _check_rank_at_least(G, D, r + 1):
            return r
        r += 1
    return r


def _check_rank_at_least(G: Graph, D: Divisor, k: int) -> bool:
    """Check if rank(D) >= k."""
    if k <= 0:
        return has_effective_equivalent(G, D)
    n = G.n
    for combo in _compositions(k, n):
        E = Divisor(list(combo))
        diff = D - E
        if not has_effective_equivalent(G, diff):
            return False
    return True


def _compositions(k: int, n: int):
    """Generate all compositions of k into n non-negative parts."""
    if n == 1:
        yield (k,)
        return
    for i in range(k + 1):
        for rest in _compositions(k - i, n - 1):
            yield (i,) + rest


def verify_riemann_roch(G: Graph, D: Divisor) -> Dict:
    """Verify the Riemann-Roch theorem for a specific divisor D on graph G."""
    K = canonical_divisor(G)
    K_minus_D = K - D
    g = G.genus()

    r_D = compute_rank(G, D)
    r_KD = compute_rank(G, K_minus_D)

    lhs = r_D - r_KD
    rhs = D.degree() + 1 - g

    return {
        'D': D.values,
        'K': K.values,
        'K-D': K_minus_D.values,
        'deg(D)': D.degree(),
        'g': g,
        'r(D)': r_D,
        'r(K-D)': r_KD,
        'LHS (r(D)-r(K-D))': lhs,
        'RHS (deg(D)+1-g)': rhs,
        'RR_holds': lhs == rhs
    }


def canonical_rank_conjecture_test(n: int) -> Dict:
    """Test: rank(K_{K_n}) = g - 1 for the complete graph K_n."""
    G = Graph.complete(n)
    K = canonical_divisor(G)
    g = G.genus()
    r_K = compute_rank(G, K)
    return {
        'n': n,
        'g': g,
        'K': K.values,
        'deg(K)': K.degree(),
        'r(K)': r_K,
        'g-1': g - 1,
        'conjecture_holds': r_K == g - 1
    }
