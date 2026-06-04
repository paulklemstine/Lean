"""
Chip-Firing and Divisor Energy Algorithms on Graphs

Type-hinted implementations of the key algorithms from the chip-firing theory:
1. Graph divisor operations (addition, subtraction, degree)
2. The energy functional E_G(D)
3. Chip-firing simulation
4. Greedy energy-minimization chip-firing
5. Divisor variance computation
6. Canonical divisor construction
"""

from typing import List, Tuple, Set, Dict, Optional
import numpy as np


class Graph:
    """A simple undirected graph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def num_edges(self) -> int:
        return sum(self.degree(v) for v in range(self.n)) // 2

    @staticmethod
    def complete(n: int) -> 'Graph':
        """Construct the complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return Graph(n, edges)

    @staticmethod
    def cycle(n: int) -> 'Graph':
        """Construct the cycle graph C_n."""
        edges = [(i, (i + 1) % n) for i in range(n)]
        return Graph(n, edges)

    @staticmethod
    def path(n: int) -> 'Graph':
        """Construct the path graph P_n."""
        edges = [(i, i + 1) for i in range(n - 1)]
        return Graph(n, edges)


class Divisor:
    """A divisor on a graph: an integer-valued function on vertices."""

    def __init__(self, values: List[int]):
        self.values = list(values)
        self.n = len(values)

    def __getitem__(self, v: int) -> int:
        return self.values[v]

    def __setitem__(self, v: int, val: int) -> None:
        self.values[v] = val

    def __add__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([self[v] + other[v] for v in range(self.n)])

    def __sub__(self, other: 'Divisor') -> 'Divisor':
        return Divisor([self[v] - other[v] for v in range(self.n)])

    def __neg__(self) -> 'Divisor':
        return Divisor([-self[v] for v in range(self.n)])

    def __repr__(self) -> str:
        return f"Divisor({self.values})"

    def degree(self) -> int:
        """deg(D) = Σ_v D(v)."""
        return sum(self.values)

    def is_effective(self) -> bool:
        """D ≥ 0 iff all values are non-negative."""
        return all(v >= 0 for v in self.values)

    def copy(self) -> 'Divisor':
        return Divisor(list(self.values))


def canonical_divisor(G: Graph) -> Divisor:
    """K_G(v) = deg(v) - 2."""
    return Divisor([G.degree(v) - 2 for v in range(G.n)])


def genus(G: Graph) -> int:
    """g(G) = |E| - |V| + 1."""
    return G.num_edges() - G.n + 1


def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: send one chip along each edge from v."""
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.neighbors(v):
        result[w] += 1
    return result


def energy(G: Graph, D: Divisor) -> int:
    """E_G(D) = Σ_v Σ_{w~v} (D(v) - D(w))²."""
    total = 0
    for v in range(G.n):
        for w in G.neighbors(v):
            total += (D[v] - D[w]) ** 2
    return total


def laplacian_quad_form(G: Graph, D: Divisor) -> int:
    """Q_G(D) = Σ_v D(v) · Σ_{w~v} (D(v) - D(w))."""
    total = 0
    for v in range(G.n):
        lap_v = sum(D[v] - D[w] for w in G.neighbors(v))
        total += D[v] * lap_v
    return total


def excess(G: Graph, D: Divisor, v: int) -> int:
    """exc(D, v) = D(v)·deg(v) - Σ_{w~v} D(w)."""
    return D[v] * G.degree(v) - sum(D[w] for w in G.neighbors(v))


def divisor_variance(D: Divisor) -> int:
    """Var(D) = n·Σ D(v)² - (Σ D(v))²."""
    n = D.n
    sum_sq = sum(v ** 2 for v in D.values)
    sum_val = sum(D.values)
    return n * sum_sq - sum_val ** 2


def greedy_chip_fire(G: Graph, D: Divisor, max_steps: int = 1000) -> Tuple[Divisor, List[int]]:
    """
    Greedy chip-firing: repeatedly fire the vertex with highest excess.
    Returns the final divisor and the firing sequence.
    """
    current = D.copy()
    firing_seq: List[int] = []

    for _ in range(max_steps):
        # Find vertex with highest excess
        excesses = [(excess(G, current, v), v) for v in range(G.n)]
        max_exc, best_v = max(excesses)

        if max_exc <= 0:
            break  # No vertex wants to fire

        current = chip_fire(G, current, best_v)
        firing_seq.append(best_v)

    return current, firing_seq


def energy_spectrum_sample(G: Graph, D: Divisor,
                           num_random: int = 1000) -> List[int]:
    """
    Sample the energy spectrum by random chip-firing sequences.
    Returns a list of achieved energy values.
    """
    import random
    energies: Set[int] = {energy(G, D)}
    current = D.copy()

    for _ in range(num_random):
        v = random.randint(0, G.n - 1)
        current = chip_fire(G, current, v)
        energies.add(energy(G, current))

    return sorted(energies)


def complete_graph_energy_formula(n: int, D: Divisor) -> int:
    """
    Closed-form energy for K_n:
    E_{K_n}(D) = 2n·Σ D(v)² - 2·(Σ D(v))².
    """
    sum_sq = sum(v ** 2 for v in D.values)
    sum_val = sum(D.values)
    return 2 * n * sum_sq - 2 * sum_val ** 2


def laplacian_matrix(G: Graph) -> np.ndarray:
    """Compute the graph Laplacian matrix L = D - A."""
    L = np.zeros((G.n, G.n), dtype=int)
    for v in range(G.n):
        L[v, v] = G.degree(v)
        for w in G.neighbors(v):
            L[v, w] = -1
    return L


def jacobian_order(G: Graph) -> int:
    """
    |Jac(G)| = number of spanning trees (by Kirchhoff's matrix-tree theorem).
    Computed as det of any (n-1)×(n-1) cofactor of the Laplacian.
    """
    L = laplacian_matrix(G)
    # Delete last row and column
    L_red = L[:-1, :-1]
    return abs(int(round(np.linalg.det(L_red))))
