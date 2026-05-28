#!/usr/bin/env python3
"""
Algorithms for Sheaf-Theoretic Tropical Persistence

Implements the core computational methods described in the research paper:
1. Critical stratification computation
2. Stalk/rank data computation
3. Cumulative sheaf jump computation
4. Constructibility verification
5. Stability bound computation

All algorithms are connected to the formal Lean theorem statements in
Pythagorean/TropicalBridge/SheafPersistence.lean.

Complexity Analysis:
- Critical stratification: O(n log n) where n = |V|
- Sheaf jump at single threshold: O(n)
- Full sheaf profile: O(n²) naive, O(n log n) with sorting
- Stability verification: O(n) per threshold sample
"""

from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass
import math


@dataclass
class GraphData:
    """Finite simple graph with vertex set {0, ..., n-1}."""
    n: int
    edges: List[Tuple[int, int]]

    def degree(self, v: int) -> int:
        """Degree of vertex v. O(|E|)."""
        return sum(1 for (a, b) in self.edges if a == v or b == v)

    def neighbors(self, v: int) -> Set[int]:
        """Neighbor set of vertex v. O(|E|)."""
        result = set()
        for (a, b) in self.edges:
            if a == v:
                result.add(b)
            elif b == v:
                result.add(a)
        return result

    @staticmethod
    def path(n: int) -> 'GraphData':
        """Path graph P_n. O(n)."""
        return GraphData(n, [(i, i + 1) for i in range(n - 1)])

    @staticmethod
    def cycle(n: int) -> 'GraphData':
        """Cycle graph C_n. O(n)."""
        return GraphData(n, [(i, (i + 1) % n) for i in range(n)])

    @staticmethod
    def complete(n: int) -> 'GraphData':
        """Complete graph K_n. O(n²)."""
        return GraphData(n, [(i, j) for i in range(n) for j in range(i + 1, n)])

    @staticmethod
    def star(n: int) -> 'GraphData':
        """Star graph S_n (center = 0). O(n)."""
        return GraphData(n, [(0, i) for i in range(1, n)])


@dataclass
class TropicalFiltration:
    """Vertex filtration: entrance-time function f: V → ℝ."""
    graph: GraphData
    entrance_times: List[float]

    def critical_values(self) -> List[float]:
        """
        Compute critical values (sorted unique entrance times).
        These form the singular support of the constructible sheaf.

        Complexity: O(n log n)
        Corresponds to: critVals in Lean
        """
        return sorted(set(self.entrance_times))

    def active_vertices(self, t: float) -> List[int]:
        """
        Vertices active at threshold t.

        Complexity: O(n)
        Corresponds to: activeVerts in Lean
        """
        return [v for v, fv in enumerate(self.entrance_times) if fv <= t]

    def entering_vertices(self, c: float) -> List[int]:
        """
        Vertices entering at exactly critical value c.

        Complexity: O(n)
        """
        return [v for v, fv in enumerate(self.entrance_times) if fv == c]


@dataclass
class SheafJumpData:
    """Result of sheaf jump computation at a critical value."""
    critical_value: float
    entering_vertices: List[int]
    jump_value: int
    cumulative_value: int


def compute_sheaf_jumps(filt: TropicalFiltration) -> List[SheafJumpData]:
    """
    Algorithm 1: Compute all sheaf jumps.

    For each critical value c, computes:
      jump(c) = Σ_{v: f(v)=c} (deg(v) + 1)

    Complexity: O(n log n + n·|E|/n) = O(n log n + |E|)
    Corresponds to: sheafJump in Lean
    """
    crit = filt.critical_values()
    results = []
    cumulative = 0

    for c in crit:
        entering = filt.entering_vertices(c)
        jump = sum(filt.graph.degree(v) + 1 for v in entering)
        cumulative += jump
        results.append(SheafJumpData(
            critical_value=c,
            entering_vertices=entering,
            jump_value=jump,
            cumulative_value=cumulative
        ))

    return results


def compute_sheaf_event_profile(filt: TropicalFiltration, t: float) -> int:
    """
    Algorithm 2: Compute sheaf event profile at threshold t.

    Sums sheaf jumps at all critical values ≤ t.

    Complexity: O(n log n)
    Corresponds to: sheafEvtProfile in Lean
    """
    crit = filt.critical_values()
    total = 0
    for c in crit:
        if c <= t:
            entering = filt.entering_vertices(c)
            total += sum(filt.graph.degree(v) + 1 for v in entering)
    return total


def compute_direct_profile(filt: TropicalFiltration, t: float) -> int:
    """
    Algorithm 3: Direct computation of tropical event profile.

    Sums (deg(v) + 1) over active vertices.

    Complexity: O(n)
    Corresponds to: tropEvtProfile in Lean
    """
    active = filt.active_vertices(t)
    return sum(filt.graph.degree(v) + 1 for v in active)


def verify_recovery_theorem(filt: TropicalFiltration) -> bool:
    """
    Algorithm 4: Verify the recovery theorem computationally.

    Checks: tropEvtProfile(t) = sheafEvtProfile(t) for all critical values t.
    This is the computational certificate for tropEvtProfile_eq_cumSheafJump.

    Complexity: O(n² log n)
    """
    crit = filt.critical_values()
    for c in crit:
        direct = compute_direct_profile(filt, c)
        sheaf = compute_sheaf_event_profile(filt, c)
        if direct != sheaf:
            return False
    return True


def verify_constructibility(filt: TropicalFiltration,
                           samples_per_interval: int = 10) -> bool:
    """
    Algorithm 5: Verify constructibility by sampling.

    Checks that the active vertex set (and hence the profile) is constant
    between consecutive critical values.

    Complexity: O(n · samples_per_interval · |crit|)
    Corresponds to: activeVerts_eq_of_sameCritGap in Lean
    """
    crit = filt.critical_values()
    for i in range(len(crit) - 1):
        ref_set = set(filt.active_vertices(crit[i]))
        gap = crit[i + 1] - crit[i]
        for j in range(1, samples_per_interval):
            t = crit[i] + j * gap / (samples_per_interval + 1)
            test_set = set(filt.active_vertices(t))
            if test_set != ref_set:
                return False
    return True


def compute_stability_bound(filt1: TropicalFiltration,
                           filt2: TropicalFiltration) -> Tuple[float, bool]:
    """
    Algorithm 6: Compute filtration distance and verify interleaving.

    Returns (epsilon, interleaving_holds) where epsilon is the sup distance
    and interleaving_holds is True if the sheaf profiles are epsilon-interleaved.

    Complexity: O(n² log n)
    Corresponds to: sheafEvtProfile_stability in Lean
    """
    n = filt1.graph.n
    assert n == filt2.graph.n

    epsilon = max(abs(filt1.entrance_times[v] - filt2.entrance_times[v])
                  for v in range(n))

    # Check interleaving at all critical values of both filtrations
    all_crit = sorted(set(filt1.critical_values() + filt2.critical_values()))

    interleaved = True
    for c in all_crit:
        p1 = compute_sheaf_event_profile(filt1, c)
        p2_shifted = compute_sheaf_event_profile(filt2, c + epsilon)
        if p1 > p2_shifted:
            interleaved = False
            break

        p2 = compute_sheaf_event_profile(filt2, c)
        p1_shifted = compute_sheaf_event_profile(filt1, c + epsilon)
        if p2 > p1_shifted:
            interleaved = False
            break

    return epsilon, interleaved


def compute_euler_characteristic(filt: TropicalFiltration, t: float) -> int:
    """
    Algorithm 7: Euler characteristic of active subgraph.

    χ(t) = |active vertices| - |active edges|

    Complexity: O(n + |E|)
    Corresponds to: activeEulerChar in Lean
    """
    active = set(filt.active_vertices(t))
    V = len(active)
    E = sum(1 for (a, b) in filt.graph.edges if a in active and b in active)
    return V - E


def compute_full_stratification(filt: TropicalFiltration) -> Dict:
    """
    Algorithm 8: Full critical stratification.

    Returns a dictionary containing:
    - critical_values: sorted list of critical thresholds
    - strata: for each stratum, the stalk data (active vertices, profile value, etc.)
    - jumps: sheaf jump at each critical value
    - euler_chars: Euler characteristic at each critical value

    This is the complete computational representation of the constructible sheaf.

    Complexity: O(n² + n·|E|)
    """
    crit = filt.critical_values()
    strata = []
    cumulative = 0

    for i, c in enumerate(crit):
        active = filt.active_vertices(c)
        entering = filt.entering_vertices(c)
        jump = sum(filt.graph.degree(v) + 1 for v in entering)
        cumulative += jump
        chi = compute_euler_characteristic(filt, c)

        strata.append({
            'critical_value': c,
            'active_vertices': active,
            'entering_vertices': entering,
            'sheaf_jump': jump,
            'cumulative_profile': cumulative,
            'euler_characteristic': chi,
            'active_vertex_count': len(active),
            'active_edge_count': len(active) - chi,
        })

    return {
        'critical_values': crit,
        'strata': strata,
        'total_profile': cumulative,
        'num_strata': len(crit),
    }


# ─── Example Usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Sheaf-Theoretic Tropical Persistence — Algorithm Suite\n")

    # Path graph example
    G = GraphData.path(6)
    filt = TropicalFiltration(G, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])

    print("=== Full Stratification for P_6 ===")
    strat = compute_full_stratification(filt)
    for s in strat['strata']:
        print(f"  c={s['critical_value']:.0f}: "
              f"entering={s['entering_vertices']}, "
              f"jump={s['sheaf_jump']}, "
              f"cum={s['cumulative_profile']}, "
              f"χ={s['euler_characteristic']}")

    print(f"\n=== Recovery Theorem: {verify_recovery_theorem(filt)} ===")
    print(f"=== Constructibility: {verify_constructibility(filt)} ===")

    # Stability example
    filt2 = TropicalFiltration(G, [0.1, 0.9, 2.1, 3.2, 3.8, 5.1])
    eps, interleaved = compute_stability_bound(filt, filt2)
    print(f"\n=== Stability ===")
    print(f"  ε = {eps:.4f}")
    print(f"  Interleaved: {interleaved}")
