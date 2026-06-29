"""
Energy Landscape Metastability: Core Algorithms

Implements the mathematical framework for analyzing metastability in discrete
spin systems. Provides algorithms for:
  - Hamming distance computation
  - Energy landscape construction from interaction hypergraphs
  - Local minimum detection
  - Metastable relaxation time measurement
  - Speed limit bound verification

All functions are type-hinted and documented.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import itertools
import math


# ============================================================
# § 1. Configuration Space
# ============================================================

def hamming_distance(sigma: Tuple[int, ...], tau: Tuple[int, ...]) -> int:
    """Compute Hamming distance between two spin configurations.
    
    Args:
        sigma: First configuration (tuple of spin values).
        tau: Second configuration (same length as sigma).
    
    Returns:
        Number of sites where sigma and tau disagree.
    """
    assert len(sigma) == len(tau), "Configurations must have same length"
    return sum(1 for s, t in zip(sigma, tau) if s != t)


def all_configurations(d: int, q: int = 2) -> List[Tuple[int, ...]]:
    """Generate all spin configurations on d sites with q states each.
    
    Args:
        d: Number of sites.
        q: Number of states per site (default 2 for Ising).
    
    Returns:
        List of all q^d configurations as tuples.
    """
    return list(itertools.product(range(q), repeat=d))


def neighbors(sigma: Tuple[int, ...], q: int = 2) -> List[Tuple[int, ...]]:
    """Generate all single-flip neighbors of a configuration.
    
    Args:
        sigma: Configuration.
        q: Number of states per site.
    
    Returns:
        List of configurations differing from sigma at exactly one site.
    """
    result = []
    for i in range(len(sigma)):
        for val in range(q):
            if val != sigma[i]:
                neighbor = list(sigma)
                neighbor[i] = val
                result.append(tuple(neighbor))
    return result


# ============================================================
# § 2. Interaction Hypergraph
# ============================================================

class InteractionHypergraph:
    """Represents the interaction structure of a Hamiltonian.
    
    An interaction hypergraph on d sites captures which subsets of sites
    interact. Each hyperedge is a frozenset of site indices.
    
    Attributes:
        d: Number of sites.
        edges: Set of frozensets (hyperedges).
        depth: Maximum hyperedge cardinality.
    """
    
    def __init__(self, d: int, edges: List[Set[int]]):
        self.d = d
        self.edges = [frozenset(e) for e in edges]
        self.depth = max((len(e) for e in self.edges), default=0)
        
        # Validate
        for e in self.edges:
            assert all(0 <= i < d for i in e), f"Edge {e} contains invalid site"
            assert len(e) <= d, f"Edge {e} exceeds number of sites"
    
    def site_degree(self, i: int) -> int:
        """Number of interactions containing site i."""
        return sum(1 for e in self.edges if i in e)
    
    def max_degree(self) -> int:
        """Maximum site degree."""
        if self.d == 0:
            return 0
        return max(self.site_degree(i) for i in range(self.d))
    
    def num_edges(self) -> int:
        """Number of distinct interactions."""
        return len(self.edges)


def nearest_neighbor_hypergraph(d: int) -> InteractionHypergraph:
    """Create nearest-neighbor interaction hypergraph on a 1D chain.
    
    Depth = 2 (pairwise interactions).
    """
    edges = [{i, (i + 1) % d} for i in range(d)]
    return InteractionHypergraph(d, edges)


def all_pairs_hypergraph(d: int) -> InteractionHypergraph:
    """Create all-pairs interaction hypergraph (complete graph).
    
    Depth = 2, but every pair interacts.
    """
    edges = [{i, j} for i in range(d) for j in range(i + 1, d)]
    return InteractionHypergraph(d, edges)


def k_local_hypergraph(d: int, k: int) -> InteractionHypergraph:
    """Create a k-local hypergraph with all subsets of size ≤ k.
    
    Warning: exponentially many edges for large k.
    """
    edges = []
    for size in range(1, k + 1):
        for subset in itertools.combinations(range(d), size):
            edges.append(set(subset))
    return InteractionHypergraph(d, edges)


# ============================================================
# § 3. Energy Functions
# ============================================================

class BoundedLocalEnergy:
    """Energy function with certified single-flip bound.
    
    Attributes:
        d: Number of sites.
        q: States per site.
        energy_fn: Maps configurations to real-valued energies.
        step_bound: Upper bound on |E(σ) - E(τ)| for Hamming-1 pairs.
    """
    
    def __init__(self, d: int, q: int, energy_fn: Callable[[Tuple[int, ...]], float],
                 step_bound: float):
        self.d = d
        self.q = q
        self.energy_fn = energy_fn
        self.step_bound = step_bound
    
    def energy(self, sigma: Tuple[int, ...]) -> float:
        return self.energy_fn(sigma)
    
    def verify_step_bound(self) -> bool:
        """Verify the step bound by exhaustive check (small systems only)."""
        configs = all_configurations(self.d, self.q)
        for sigma in configs:
            for tau in neighbors(sigma, self.q):
                if abs(self.energy(sigma) - self.energy(tau)) > self.step_bound + 1e-10:
                    return False
        return True


def ising_energy(couplings: Dict[Tuple[int, int], float],
                 fields: Dict[int, float],
                 sigma: Tuple[int, ...]) -> float:
    """Compute Ising energy E(σ) = -Σ_{ij} J_{ij} s_i s_j - Σ_i h_i s_i.
    
    Spins are mapped: 0 -> -1, 1 -> +1.
    """
    spins = [2 * s - 1 for s in sigma]
    energy = 0.0
    for (i, j), J in couplings.items():
        energy -= J * spins[i] * spins[j]
    for i, h in fields.items():
        energy -= h * spins[i]
    return energy


def make_ising_energy(d: int, couplings: Dict[Tuple[int, int], float],
                      fields: Dict[int, float]) -> BoundedLocalEnergy:
    """Create a BoundedLocalEnergy from Ising model parameters.
    
    Step bound = max over sites i of (2|h_i| + 2 Σ_{j≠i} |J_{ij}|).
    """
    def energy_fn(sigma: Tuple[int, ...]) -> float:
        return ising_energy(couplings, fields, sigma)
    
    # Compute step bound
    step_bound = 0.0
    for site in range(d):
        site_bound = 2 * abs(fields.get(site, 0.0))
        for (i, j), J in couplings.items():
            if i == site or j == site:
                site_bound += 2 * abs(J)
        step_bound = max(step_bound, site_bound)
    
    return BoundedLocalEnergy(d, 2, energy_fn, step_bound)


# ============================================================
# § 4. Metastability Analysis
# ============================================================

def find_local_minima(E: BoundedLocalEnergy) -> List[Tuple[int, ...]]:
    """Find all local minima of the energy function.
    
    A configuration σ is a local minimum if E(σ) ≤ E(τ) for all
    single-flip neighbors τ.
    """
    configs = all_configurations(E.d, E.q)
    minima = []
    for sigma in configs:
        e_sigma = E.energy(sigma)
        is_min = all(e_sigma <= E.energy(tau) for tau in neighbors(sigma, E.q))
        if is_min:
            minima.append(sigma)
    return minima


def find_global_minimum(E: BoundedLocalEnergy) -> Tuple[Tuple[int, ...], float]:
    """Find a global minimum configuration."""
    configs = all_configurations(E.d, E.q)
    best = min(configs, key=E.energy)
    return best, E.energy(best)


def is_metastable(E: BoundedLocalEnergy, sigma: Tuple[int, ...]) -> bool:
    """Check if σ is metastable: a local but not global minimum."""
    if not all(E.energy(sigma) <= E.energy(tau) 
               for tau in neighbors(sigma, E.q)):
        return False
    global_min, global_e = find_global_minimum(E)
    return E.energy(sigma) > global_e + 1e-10


def relaxation_time(E: BoundedLocalEnergy, sigma0: Tuple[int, ...]) -> int:
    """Compute minimum number of single-flip moves to reach a lower-energy
    configuration from sigma0.
    
    Uses BFS on the Hamming graph. Returns the length of the shortest path
    from sigma0 to any configuration with strictly lower energy.
    Returns -1 if sigma0 is already a global minimum.
    """
    from collections import deque
    
    e0 = E.energy(sigma0)
    target_energy = e0 - 1e-10  # anything strictly lower
    
    visited = {sigma0}
    queue = deque([(sigma0, 0)])
    
    while queue:
        current, dist = queue.popleft()
        
        for nbr in neighbors(current, E.q):
            if E.energy(nbr) < target_energy:
                return dist + 1
            if nbr not in visited:
                visited.add(nbr)
                queue.append((nbr, dist + 1))
    
    return -1  # No lower-energy state reachable (sigma0 is global min)


def barrier_height(E: BoundedLocalEnergy, sigma: Tuple[int, ...],
                   tau: Tuple[int, ...]) -> float:
    """Compute the energy barrier between sigma and tau.
    
    The barrier is the minimum over all paths of the maximum energy
    along the path. Uses modified Dijkstra (minimax path).
    """
    import heapq
    
    # Minimax shortest path: minimize the maximum energy along any path
    # from sigma to tau
    best = {sigma: E.energy(sigma)}
    heap = [(E.energy(sigma), sigma)]
    
    while heap:
        max_e, current = heapq.heappop(heap)
        
        if current == tau:
            return max_e - E.energy(sigma)
        
        if max_e > best.get(current, float('inf')):
            continue
        
        for nbr in neighbors(current, E.q):
            nbr_e = max(max_e, E.energy(nbr))
            if nbr_e < best.get(nbr, float('inf')):
                best[nbr] = nbr_e
                heapq.heappush(heap, (nbr_e, nbr))
    
    return float('inf')  # tau not reachable


# ============================================================
# § 5. Speed Limit Verification
# ============================================================

def verify_speed_limit(path_energies: List[float], delta: float) -> Dict[str, float]:
    """Verify the speed limit theorem for a concrete energy path.
    
    Args:
        path_energies: E(path(0)), E(path(1)), ..., E(path(n))
        delta: Per-step bound
    
    Returns:
        Dictionary with total_change, n*delta bound, and verification status.
    """
    n = len(path_energies) - 1
    if n <= 0:
        return {"total_change": 0, "bound": 0, "satisfied": True}
    
    # Check step bound
    max_step = max(abs(path_energies[i + 1] - path_energies[i]) for i in range(n))
    total_change = abs(path_energies[-1] - path_energies[0])
    bound = n * delta
    
    return {
        "n": n,
        "total_change": total_change,
        "max_step": max_step,
        "step_bound_satisfied": max_step <= delta + 1e-10,
        "speed_limit_bound": bound,
        "speed_limit_satisfied": total_change <= bound + 1e-10,
    }


def predicted_relaxation(d: int, k: int) -> int:
    """Compute the conjectured metastable relaxation time d^(d-k-1)."""
    if k + 1 >= d:
        return 1
    return d ** (d - k - 1)
