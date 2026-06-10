#!/usr/bin/env python3
"""
Holographic Proof Renormalization — Core Algorithms

Implements the algorithmic core of proof renormalization theory:
- RG flow iteration with convergence detection
- Approximate theoremhood search
- Ultrametric clustering of proof states
- Orbit analysis and complexity profiling
"""

from dataclasses import dataclass, field
from typing import Callable, List, Optional, Set, Tuple, Dict
import heapq


@dataclass(frozen=True)
class ProofState:
    """Proof state in the renormalization framework."""
    size: int
    depth: int
    cuts: int

    def valuation(self) -> int:
        """Complexity valuation: total energy of the proof state."""
        return self.size + self.depth + self.cuts

    def __lt__(self, other):
        return self.valuation() < other.valuation()


def proof_dist(x: ProofState, y: ProofState) -> int:
    """Ultrametric proof distance."""
    if x == y:
        return 0
    return 1 + max(x.valuation(), y.valuation())


# =============================================================================
# Algorithm 1: RG Flow with Convergence Bound
# =============================================================================
def rg_flow(
    R: Callable[[ProofState], ProofState],
    x: ProofState,
    max_steps: Optional[int] = None
) -> Tuple[List[ProofState], int]:
    """
    Compute the RG flow orbit of x under R.

    Returns:
        (orbit, fixed_step) where orbit[fixed_step] is the fixed point.

    Complexity: O(valuation(x)) steps, O(valuation(x)) space.

    By Theorem exists_fixed_point_on_orbit_with_bound,
    convergence is guaranteed in at most valuation(x) steps
    for any R satisfying strict descent away from fixed points.
    """
    bound = max_steps if max_steps is not None else x.valuation()
    orbit = [x]
    current = x

    for step in range(bound + 1):
        next_state = R(current)
        if next_state == current:
            return orbit, step
        orbit.append(next_state)
        current = next_state

    return orbit, len(orbit) - 1


# =============================================================================
# Algorithm 2: Approximate Theoremhood Search
# =============================================================================
def approx_theoremhood_search(
    sigma: Callable[[ProofState], int],
    T: Callable[[int], bool],
    k: int,
    state_generator: Optional[Callable[[int], List[ProofState]]] = None
) -> Optional[ProofState]:
    """
    Search for a proof state of valuation ≤ k satisfying T ∘ σ.

    This implements the decidable procedure from
    Theorem decidable_approx_theoremhood_fintype.

    Args:
        sigma: Semantic map from proof states to semantic values.
        T: Target predicate on semantics.
        k: Valuation bound (scale cutoff).
        state_generator: Optional generator for states at given valuation.

    Returns:
        A witness ProofState if found, None otherwise.

    Complexity: O(k^3) for the default generator (3 components summing to ≤ k).
    """
    if state_generator is None:
        def default_generator(bound):
            states = []
            for s in range(bound + 1):
                for d in range(bound + 1 - s):
                    for c in range(bound + 1 - s - d):
                        states.append(ProofState(s, d, c))
            return states
        state_generator = default_generator

    for x in state_generator(k):
        if x.valuation() <= k and T(sigma(x)):
            return x
    return None


# =============================================================================
# Algorithm 3: Ultrametric Clustering
# =============================================================================
def ultrametric_cluster(
    states: List[ProofState],
    radius: int
) -> List[List[ProofState]]:
    """
    Cluster proof states by ultrametric distance.

    In an ultrametric space, every point inside a ball is a center.
    This means clustering is canonical: two balls either coincide or
    are disjoint.

    Args:
        states: List of proof states to cluster.
        radius: Maximum intra-cluster distance.

    Returns:
        List of clusters (each a list of ProofStates).

    Complexity: O(n^2) where n = len(states).
    """
    clusters: List[List[ProofState]] = []
    assigned: Set[int] = set()

    for i, x in enumerate(states):
        if i in assigned:
            continue
        cluster = [x]
        assigned.add(i)
        for j, y in enumerate(states):
            if j not in assigned and proof_dist(x, y) <= radius:
                cluster.append(y)
                assigned.add(j)
        clusters.append(cluster)

    return clusters


# =============================================================================
# Algorithm 4: Orbit Analysis
# =============================================================================
@dataclass
class OrbitAnalysis:
    """Complete analysis of an RG orbit."""
    initial: ProofState
    fixed_point: ProofState
    orbit_length: int
    valuations: List[int]
    fixed_step: int
    is_strictly_decreasing: bool
    compression_ratio: float


def analyze_orbit(
    R: Callable[[ProofState], ProofState],
    x: ProofState
) -> OrbitAnalysis:
    """
    Perform complete orbit analysis of x under R.

    Computes the full orbit, identifies the fixed point,
    verifies strict descent, and computes compression ratio.

    Complexity: O(valuation(x)) time and space.
    """
    orbit, fixed_step = rg_flow(R, x)
    fixed_point = orbit[-1]
    valuations = [s.valuation() for s in orbit]

    is_decreasing = all(
        valuations[i] > valuations[i + 1]
        for i in range(len(valuations) - 1)
        if orbit[i] != orbit[i + 1]
    )

    v0 = x.valuation()
    vf = fixed_point.valuation()
    ratio = vf / v0 if v0 > 0 else 1.0

    return OrbitAnalysis(
        initial=x,
        fixed_point=fixed_point,
        orbit_length=len(orbit),
        valuations=valuations,
        fixed_step=fixed_step,
        is_strictly_decreasing=is_decreasing,
        compression_ratio=ratio
    )


# =============================================================================
# Algorithm 5: Stratified Proof Space Enumeration
# =============================================================================
def valuation_strata(max_val: int) -> Dict[int, List[ProofState]]:
    """
    Enumerate proof states organized by valuation stratum.

    Returns a dictionary mapping each valuation level k to the list
    of all proof states with valuation exactly k.

    Complexity: O(max_val^3) total states.
    """
    strata: Dict[int, List[ProofState]] = {}
    for k in range(max_val + 1):
        level = []
        for s in range(k + 1):
            for d in range(k + 1 - s):
                c = k - s - d
                level.append(ProofState(s, d, c))
        strata[k] = level
    return strata


# =============================================================================
# Algorithm 6: RG-Guided Theorem Search
# =============================================================================
def rg_guided_search(
    R: Callable[[ProofState], ProofState],
    sigma: Callable[[ProofState], int],
    T: Callable[[int], bool],
    max_valuation: int,
    semantic_hint: Optional[int] = None
) -> Optional[Tuple[ProofState, List[ProofState]]]:
    """
    RG-guided theorem search: find a proof state satisfying T ∘ σ
    by combining enumeration with RG flow.

    Strategy:
    1. Enumerate states at each valuation level.
    2. For each state, check if it satisfies T ∘ σ.
    3. Also follow RG flow to find fixed points that satisfy T ∘ σ.
    4. Return the lowest-valuation witness.

    This leverages Theorem renorm_semantic_stability: if R preserves σ,
    then checking T ∘ σ at any orbit point suffices.

    Args:
        R: Renormalization operator.
        sigma: Semantic map.
        T: Target predicate.
        max_valuation: Maximum valuation to search.
        semantic_hint: If provided, prefer states with this semantic value.

    Returns:
        (witness, orbit_to_witness) or None.
    """
    best: Optional[Tuple[ProofState, List[ProofState]]] = None

    strata = valuation_strata(max_valuation)

    for k in sorted(strata.keys()):
        for x in strata[k]:
            if T(sigma(x)):
                if best is None or x.valuation() < best[0].valuation():
                    best = (x, [x])
                    if k == 0:
                        return best

            # Follow RG flow
            orbit, _ = rg_flow(R, x)
            fp = orbit[-1]
            if T(sigma(fp)):
                if best is None or fp.valuation() < best[0].valuation():
                    best = (fp, orbit)

    return best


# =============================================================================
# Example usage
# =============================================================================
if __name__ == "__main__":
    # Define a concrete renormalization operator
    def cut_elim(x: ProofState) -> ProofState:
        if x.cuts > 0:
            return ProofState(x.size, x.depth, x.cuts - 1)
        if x.depth > 1:
            return ProofState(x.size, x.depth - 1, 0)
        return x

    # Analyze some orbits
    print("=== Orbit Analysis ===")
    test_states = [
        ProofState(5, 3, 7),
        ProofState(2, 2, 2),
        ProofState(10, 0, 0),
    ]

    for x in test_states:
        analysis = analyze_orbit(cut_elim, x)
        print(f"\n  Initial: {analysis.initial}")
        print(f"  Fixed point: {analysis.fixed_point}")
        print(f"  Steps: {analysis.fixed_step}")
        print(f"  Compression ratio: {analysis.compression_ratio:.2%}")
        print(f"  Strictly decreasing: {analysis.is_strictly_decreasing}")

    # Ultrametric clustering
    print("\n=== Ultrametric Clustering (radius=5) ===")
    states = [ProofState(s, d, c)
              for s in range(4) for d in range(4) for c in range(4)]
    clusters = ultrametric_cluster(states, radius=5)
    print(f"  {len(states)} states → {len(clusters)} clusters")
    for i, cluster in enumerate(clusters[:5]):
        vals = [s.valuation() for s in cluster]
        print(f"  Cluster {i}: {len(cluster)} states, "
              f"valuations {min(vals)}-{max(vals)}")

    # RG-guided search
    print("\n=== RG-Guided Theorem Search ===")
    sigma = lambda x: 1 if x.size == x.depth and x.cuts == 0 else 0
    result = rg_guided_search(cut_elim, sigma, lambda s: s == 1, max_valuation=10)
    if result:
        witness, orbit = result
        print(f"  Found witness: {witness}, valuation={witness.valuation()}")
        print(f"  Orbit length: {len(orbit)}")
    else:
        print("  No witness found.")

    # Valuation strata
    print("\n=== Valuation Strata ===")
    strata = valuation_strata(8)
    for k, level in strata.items():
        print(f"  Stratum {k}: {len(level)} states")
