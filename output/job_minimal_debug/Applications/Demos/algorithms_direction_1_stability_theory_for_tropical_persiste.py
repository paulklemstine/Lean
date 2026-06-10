"""
algorithms.py — Certified algorithms for tropical persistence barcode stability.

Implements:
1. Tropical event profile computation from graph filtrations
2. Tropical barcode extraction and distance computation
3. Certified stability bound computation

All algorithms correspond to the formally verified Lean 4 definitions.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class SimpleGraph:
    """A finite simple graph represented by adjacency lists."""
    n: int  # number of vertices
    adj: Dict[int, List[int]]  # adjacency lists

    @property
    def vertices(self) -> List[int]:
        return list(range(self.n))

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return len(self.adj.get(v, []))

    def max_degree(self) -> int:
        """Maximum degree of the graph."""
        return max((self.degree(v) for v in self.vertices), default=0)

    def neighbors(self, v: int) -> List[int]:
        """Neighbors of vertex v."""
        return self.adj.get(v, [])

    @classmethod
    def from_edges(cls, n: int, edges: List[Tuple[int, int]]) -> 'SimpleGraph':
        """Construct from edge list."""
        adj: Dict[int, List[int]] = {i: [] for i in range(n)}
        for u, v in edges:
            if u != v:
                adj[u].append(v)
                adj[v].append(u)
        return cls(n=n, adj=adj)

    @classmethod
    def erdos_renyi(cls, n: int, p: float, rng=None) -> 'SimpleGraph':
        """Generate Erdős-Rényi random graph G(n,p)."""
        if rng is None:
            rng = np.random.default_rng()
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng.random() < p:
                    edges.append((i, j))
        return cls.from_edges(n, edges)


@dataclass
class VertexFiltration:
    """Vertex filtration: entrance time for each vertex."""
    times: np.ndarray  # shape (n,), entrance times

    def active_vertices(self, t: float) -> np.ndarray:
        """Indices of vertices active at time t."""
        return np.where(self.times <= t)[0]

    @classmethod
    def random(cls, n: int, rng=None) -> 'VertexFiltration':
        """Generate random filtration with uniform entrance times in [0, 1]."""
        if rng is None:
            rng = np.random.default_rng()
        return cls(times=rng.uniform(0, 1, n))


@dataclass
class TropicalBarcode:
    """Tropical barcode: event times and weights for each vertex."""
    event_times: np.ndarray  # shape (n,)
    event_weights: np.ndarray  # shape (n,), each = degree(v) + 1


def filtration_sup_dist(f: VertexFiltration, g: VertexFiltration) -> float:
    """
    Compute FiltrationSupDist(f, g) = max_v |f(v) - g(v)|.

    Corresponds to the Lean definition:
        def FiltrationSupDist [Nonempty V] (f g : VertexFiltration V) : ℝ :=
          Finset.univ.sup' Finset.univ_nonempty (fun v => |f v - g v|)

    Time complexity: O(n)
    """
    return float(np.max(np.abs(f.times - g.times)))


def neighbor_count_in(G: SimpleGraph, v: int, S: set) -> int:
    """
    Count neighbors of v within subset S.

    Corresponds to the Lean definition:
        def neighborCountIn (G : SimpleGraph V) [DecidableRel G.Adj]
            (v : V) (S : Finset V) : ℕ :=
          (S.filter (fun w => G.Adj v w)).card

    Time complexity: O(deg(v))
    """
    return sum(1 for w in G.neighbors(v) if w in S)


def tropical_event_profile(G: SimpleGraph, f: VertexFiltration, t: float) -> int:
    """
    Compute the tropical event profile at time t.

    Corresponds to the Lean definition:
        def tropicalEventProfile (G : SimpleGraph V) [DecidableRel G.Adj]
            (f : VertexFiltration V) (t : ℝ) : ℤ :=
          ∑ v ∈ activeVertices f t, (↑(G.degree v) + 1 : ℤ)

    Time complexity: O(n)
    """
    active = f.active_vertices(t)
    return sum(G.degree(v) + 1 for v in active)


def compute_tpb(G: SimpleGraph, f: VertexFiltration) -> TropicalBarcode:
    """
    Extract tropical persistence barcode from graph filtration.

    Corresponds to the Lean definition:
        def TPB (G : SimpleGraph V) [DecidableRel G.Adj] (f : VertexFiltration V) :
            TropicalBarcode V where
          eventTime := f
          eventWeight v := G.degree v + 1

    Time complexity: O(n)
    """
    n = G.n
    weights = np.array([G.degree(v) + 1 for v in range(n)])
    return TropicalBarcode(event_times=f.times.copy(), event_weights=weights)


def tropical_barcode_dist(B1: TropicalBarcode, B2: TropicalBarcode) -> float:
    """
    Compute tropical barcode distance.

    Corresponds to the Lean definition:
        def tropicalBarcodeDist [Nonempty V] (B₁ B₂ : TropicalBarcode V) : ℝ :=
          Finset.univ.sup' Finset.univ_nonempty
            (fun v => |B₁.eventTime v - B₂.eventTime v| *
              ↑(max (B₁.eventWeight v) (B₂.eventWeight v)))

    Time complexity: O(n)
    """
    time_diffs = np.abs(B1.event_times - B2.event_times)
    max_weights = np.maximum(B1.event_weights, B2.event_weights)
    return float(np.max(time_diffs * max_weights))


def certified_stability_bound(G: SimpleGraph, epsilon: float) -> float:
    """
    Compute the certified stability bound (D+1) * epsilon.

    This is the main output of the stability theorem:
        tropicalBarcodeDist (TPB G f) (TPB G g) ≤ (D + 1) * ε

    where D = max_degree(G) and ε = FiltrationSupDist(f, g) ≤ epsilon.

    Time complexity: O(n)
    """
    D = G.max_degree()
    return (D + 1) * epsilon


def spectral_stability_bound(G: SimpleGraph, epsilon: float) -> float:
    """
    Compute the spectral stability bound (Λ/2 + 1) * epsilon.

    Uses the graph Laplacian norm bound Λ = 2 * max_degree:
        tropicalBarcodeDist (TPB G f) (TPB G g) ≤ (Λ/2 + 1) * ε

    Time complexity: O(n)
    """
    Lambda = graph_laplacian_norm(G)
    return (Lambda / 2 + 1) * epsilon


def graph_laplacian_norm(G: SimpleGraph) -> float:
    """
    Compute the graph Laplacian operator norm bound: 2 * max_degree.

    Corresponds to the Lean definition:
        def graphLaplacianNorm [Nonempty V] (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
          2 * Finset.univ.sup' Finset.univ_nonempty (fun v => (G.degree v : ℝ))

    Time complexity: O(n)
    """
    return 2.0 * G.max_degree()


def perturb_filtration(f: VertexFiltration, epsilon: float, rng=None) -> VertexFiltration:
    """
    Perturb a filtration by at most epsilon in sup-norm.

    Returns g such that FiltrationSupDist(f, g) ≤ epsilon.

    Time complexity: O(n)
    """
    if rng is None:
        rng = np.random.default_rng()
    noise = rng.uniform(-epsilon, epsilon, len(f.times))
    return VertexFiltration(times=f.times + noise)


def compute_event_profile_curve(
    G: SimpleGraph, f: VertexFiltration,
    t_values: Optional[np.ndarray] = None
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the tropical event profile as a function of time.

    Returns (t_values, profile_values).

    Time complexity: O(n * len(t_values))
    """
    if t_values is None:
        t_min = float(np.min(f.times)) - 0.1
        t_max = float(np.max(f.times)) + 0.1
        t_values = np.linspace(t_min, t_max, 200)

    profile = np.array([tropical_event_profile(G, f, t) for t in t_values])
    return t_values, profile


def verify_stability_bound(
    G: SimpleGraph,
    f: VertexFiltration,
    g: VertexFiltration
) -> Dict[str, float]:
    """
    Verify the stability theorem computationally.

    Returns a dictionary with:
    - 'sup_dist': FiltrationSupDist(f, g)
    - 'barcode_dist': tropicalBarcodeDist(TPB(G,f), TPB(G,g))
    - 'degree_bound': (D+1) * sup_dist
    - 'spectral_bound': (Λ/2 + 1) * sup_dist
    - 'ratio': barcode_dist / degree_bound (should be ≤ 1)

    Time complexity: O(n)
    """
    eps = filtration_sup_dist(f, g)
    B1 = compute_tpb(G, f)
    B2 = compute_tpb(G, g)
    dist = tropical_barcode_dist(B1, B2)
    D = G.max_degree()
    Lambda = graph_laplacian_norm(G)

    degree_bound = (D + 1) * eps
    spectral_bound = (Lambda / 2 + 1) * eps

    return {
        'sup_dist': eps,
        'barcode_dist': dist,
        'max_degree': D,
        'laplacian_norm': Lambda,
        'degree_bound': degree_bound,
        'spectral_bound': spectral_bound,
        'ratio': dist / degree_bound if degree_bound > 0 else 0.0,
    }


if __name__ == '__main__':
    # Example usage
    rng = np.random.default_rng(42)

    # Create a small graph
    G = SimpleGraph.from_edges(6, [(0,1), (1,2), (2,3), (3,4), (4,5), (0,5), (1,4)])
    print(f"Graph: {G.n} vertices, max degree = {G.max_degree()}")

    # Create filtration and perturbation
    f = VertexFiltration.random(G.n, rng)
    g = perturb_filtration(f, 0.05, rng)

    # Verify stability
    result = verify_stability_bound(G, f, g)
    print(f"\nStability verification:")
    for k, v in result.items():
        print(f"  {k}: {v:.6f}")
    print(f"\n  Bound satisfied: {result['barcode_dist'] <= result['degree_bound']}")
