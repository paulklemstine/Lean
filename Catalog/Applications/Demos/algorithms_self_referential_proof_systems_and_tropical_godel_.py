"""
Tropical Incompleteness — Algorithms

Implements the core algorithms from the research paper:
1. Tropical fixed-point iteration (Knaster-Tarski descent)
2. Tropical Gödel sentence construction
3. Incompleteness gap computation
4. Tropical closure operator construction
"""

import numpy as np
from typing import Callable, Tuple, List, Optional, Dict
from dataclasses import dataclass

# Type alias
CostProfile = np.ndarray


@dataclass
class TropicalProofSystem:
    """
    A tropical proof system on n sentences.
    
    Attributes:
        n: dimension (number of "sentences" / coordinates)
        provable: the provability closure operator P : ℕⁿ → ℕⁿ
        name: descriptive name
    
    Properties (not checked at construction, assumed by theorems):
        - Monotone: f ≤ g implies P(f) ≤ P(g)
        - Idempotent: P(P(f)) = P(f)
        - Extensive: f ≤ P(f)
    """
    n: int
    provable: Callable[[CostProfile], CostProfile]
    name: str = "unnamed"
    
    def is_monotone(self, samples: int = 100, max_val: int = 20) -> bool:
        """Check monotonicity on random samples."""
        for _ in range(samples):
            f = np.random.randint(0, max_val, self.n)
            g = f + np.random.randint(0, 5, self.n)
            Pf, Pg = self.provable(f), self.provable(g)
            if not np.all(Pf <= Pg):
                return False
        return True
    
    def is_idempotent(self, samples: int = 100, max_val: int = 20) -> bool:
        """Check idempotency on random samples."""
        for _ in range(samples):
            f = np.random.randint(0, max_val, self.n)
            Pf = self.provable(f)
            PPf = self.provable(Pf)
            if not np.array_equal(Pf, PPf):
                return False
        return True
    
    def is_extensive(self, samples: int = 100, max_val: int = 20) -> bool:
        """Check extensiveness on random samples."""
        for _ in range(samples):
            f = np.random.randint(0, max_val, self.n)
            Pf = self.provable(f)
            if not np.all(f <= Pf):
                return False
        return True
    
    def is_complete(self, samples: int = 1000, max_val: int = 20) -> bool:
        """Check if P = id on random samples (necessary condition for completeness)."""
        for _ in range(samples):
            f = np.random.randint(0, max_val, self.n)
            if not np.array_equal(self.provable(f), f):
                return False
        return True
    
    def validate(self, samples: int = 100) -> Dict[str, bool]:
        """Validate all closure operator properties."""
        return {
            "monotone": self.is_monotone(samples),
            "idempotent": self.is_idempotent(samples),
            "extensive": self.is_extensive(samples),
            "complete (on samples)": self.is_complete(samples),
        }


def knaster_tarski_descent(
    T: Callable[[CostProfile], CostProfile],
    B: CostProfile,
    max_iter: int = 10000
) -> Tuple[CostProfile, List[CostProfile]]:
    """
    Algorithm 1: Knaster-Tarski Fixed-Point by Descent
    
    Find the greatest fixed point of T below B by iterating T from B.
    
    Preconditions:
        - T is monotone
        - T(f) ≤ B for all f ≤ B (bounded)
    
    Postcondition:
        - Returns f* with T(f*) = f*
    
    Complexity: O(n * max_val * cost_of_T) where max_val = max(B)
    
    Args:
        T: monotone operator
        B: upper bound
        max_iter: iteration limit
    
    Returns:
        (fixed_point, trajectory) where trajectory records each iterate
    """
    trajectory = [B.copy()]
    x = B.copy()
    
    for _ in range(max_iter):
        x_new = T(x)
        trajectory.append(x_new.copy())
        if np.array_equal(x_new, x):
            return x, trajectory
        x = x_new
    
    return x, trajectory


def construct_godel_sentence(
    system: TropicalProofSystem,
    max_val: int = 50,
    num_trials: int = 1000
) -> Optional[Tuple[CostProfile, int, int]]:
    """
    Algorithm 2: Tropical Gödel Sentence Construction
    
    Given a tropical proof system S, find a fixed point g and coordinate i
    such that g(i) < P(DiagBump_i(g))(i).
    
    Strategy (from Theorem B proof):
        1. Search for f, i with P(f)(i) < P(DiagBump_i(f))(i)
        2. Set g = P(f) (guaranteed fixed point by idempotency)
        3. If f ≤ P(f) (extensiveness), the gap transfers to g
    
    Returns:
        (g, i, gap) where g is the Gödel sentence, i is the witnessing
        coordinate, and gap = P(DiagBump_i(g))(i) - g(i)
        Returns None if no Gödel sentence found in the trials.
    """
    P = system.provable
    n = system.n
    
    for _ in range(num_trials):
        f = np.random.randint(0, max_val, n)
        Pf = P(f)
        
        for i in range(n):
            f_bumped = f.copy()
            f_bumped[i] += 1
            Pf_bumped = P(f_bumped)
            
            if Pf[i] < Pf_bumped[i]:
                # Found diagonal sensitivity! Construct Gödel sentence.
                g = Pf  # Fixed point by idempotency
                
                # Verify g is a fixed point
                Pg = P(g)
                if not np.array_equal(Pg, g):
                    continue  # System might not be perfectly idempotent numerically
                
                # Check if the gap transfers
                g_bumped = g.copy()
                g_bumped[i] += 1
                Pg_bumped = P(g_bumped)
                
                if g[i] < Pg_bumped[i]:
                    gap = int(Pg_bumped[i] - g[i])
                    return g, i, gap
    
    return None


def compute_incompleteness_gap(
    system: TropicalProofSystem,
    max_val: int = 20,
    num_samples: int = 1000
) -> Dict:
    """
    Algorithm 3: Incompleteness Gap Analysis
    
    Measure the incompleteness of a tropical proof system by sampling
    valuations and computing the gap P(f) - f.
    
    Returns a dictionary with:
        - total_gap_mean: average total gap sum(P(f) - f)
        - total_gap_max: maximum total gap
        - coord_gaps: per-coordinate gap statistics
        - incomplete_fraction: fraction of samples where P(f) ≠ f
        - witness: a specific (f, i) witnessing incompleteness (if any)
    """
    P = system.provable
    n = system.n
    
    total_gaps = []
    coord_gaps = [[] for _ in range(n)]
    witness = None
    incomplete_count = 0
    
    for _ in range(num_samples):
        f = np.random.randint(0, max_val, n)
        Pf = P(f)
        gap = Pf - f
        
        total_gaps.append(np.sum(gap))
        for i in range(n):
            coord_gaps[i].append(gap[i])
        
        if not np.array_equal(Pf, f):
            incomplete_count += 1
            if witness is None:
                # Find the coordinate with the largest gap
                i_max = int(np.argmax(gap))
                witness = (f.copy(), i_max, int(gap[i_max]))
    
    return {
        "total_gap_mean": float(np.mean(total_gaps)),
        "total_gap_max": int(max(total_gaps)),
        "coord_gap_means": [float(np.mean(g)) for g in coord_gaps],
        "incomplete_fraction": incomplete_count / num_samples,
        "witness": witness,
    }


def build_closure_from_graph(
    adj_matrix: np.ndarray,
    source: int = 0
) -> TropicalProofSystem:
    """
    Algorithm 4: Build a Tropical Proof System from a Graph
    
    Given an adjacency matrix of a weighted directed graph, construct
    the tropical proof system corresponding to one step of Bellman-Ford
    shortest-path relaxation.
    
    The provability operator T(d)(v) = min(d(v), min_u(d(u) + W[u][v]))
    models "what distances are provable in one more step of relaxation."
    """
    n = adj_matrix.shape[0]
    INF = int(1e9)
    
    def relaxation_step(d: CostProfile) -> CostProfile:
        d_new = d.copy()
        for v in range(n):
            for u in range(n):
                if adj_matrix[u][v] < INF:
                    d_new[v] = min(d_new[v], d[u] + adj_matrix[u][v])
        return d_new
    
    # Build the full closure (iterate to convergence)
    def full_closure(d: CostProfile) -> CostProfile:
        prev = d.copy()
        for _ in range(n):
            curr = relaxation_step(prev)
            if np.array_equal(curr, prev):
                break
            prev = curr
        return prev
    
    return TropicalProofSystem(
        n=n,
        provable=full_closure,
        name=f"Bellman-Ford closure ({n} vertices)"
    )


def tropical_fixed_point_lattice(
    T: Callable[[CostProfile], CostProfile],
    n: int,
    max_val: int = 10
) -> List[CostProfile]:
    """
    Algorithm 5: Enumerate Fixed Points
    
    For small n and max_val, enumerate all fixed points of T
    by brute-force search.
    
    Complexity: O(max_val^n * cost_of_T)
    Only practical for n ≤ 4 and max_val ≤ 10.
    """
    fixed_points = []
    
    def enumerate(prefix, depth):
        if depth == n:
            f = np.array(prefix, dtype=int)
            if np.array_equal(T(f), f):
                fixed_points.append(f.copy())
            return
        for v in range(max_val + 1):
            enumerate(prefix + [v], depth + 1)
    
    enumerate([], 0)
    return fixed_points


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("Tropical Incompleteness — Algorithm Demonstrations")
    print("=" * 60)
    
    # Build example systems
    n = 4
    
    # System 1: Max-clamp closure
    threshold = np.array([2, 3, 1, 4])
    sys1 = TropicalProofSystem(
        n=n,
        provable=lambda f: np.maximum(f, threshold),
        name="Max-clamp (threshold=[2,3,1,4])"
    )
    
    # System 2: Identity (complete system)
    sys2 = TropicalProofSystem(
        n=n,
        provable=lambda f: f.copy(),
        name="Identity (complete)"
    )
    
    print(f"\n--- System: {sys1.name} ---")
    props = sys1.validate()
    for k, v in props.items():
        print(f"  {k}: {v}")
    
    gap_info = compute_incompleteness_gap(sys1)
    print(f"  Incompleteness fraction: {gap_info['incomplete_fraction']:.0%}")
    print(f"  Average total gap: {gap_info['total_gap_mean']:.2f}")
    if gap_info['witness']:
        f, i, g = gap_info['witness']
        print(f"  Witness: f={f}, coord={i}, gap={g}")
    
    godel = construct_godel_sentence(sys1)
    if godel:
        g, i, gap = godel
        print(f"  Gödel sentence: g={g}, coord={i}, gap={gap}")
    
    print(f"\n--- System: {sys2.name} ---")
    props = sys2.validate()
    for k, v in props.items():
        print(f"  {k}: {v}")
    
    # Enumerate fixed points for small system
    print(f"\n--- Fixed point enumeration (n=2, max_val=3) ---")
    small_T = lambda f: np.maximum(f, np.array([1, 2]))
    fps = tropical_fixed_point_lattice(small_T, n=2, max_val=3)
    print(f"  Found {len(fps)} fixed points:")
    for fp in fps:
        print(f"    {fp}")
    
    print(f"\n--- Graph-based system ---")
    INF = int(1e9)
    adj = np.full((4, 4), INF)
    adj[0][1] = 2; adj[0][2] = 5; adj[1][2] = 1; adj[1][3] = 4; adj[2][3] = 1
    graph_sys = build_closure_from_graph(adj, source=0)
    
    d0 = np.array([0, INF, INF, INF])
    d_closed = graph_sys.provable(d0)
    print(f"  Initial distances: {d0}")
    print(f"  After closure: {d_closed}")
    print(f"  (Shortest paths from vertex 0)")
