#!/usr/bin/env python3
"""
Tropical Holographic Reconstruction — Algorithms

Implements the core algorithms from the research paper:
1. Boundary data extraction
2. Canonical bulk reconstruction
3. Gauge equivalence detection
4. Entropy profile computation
5. Propagation cost via dynamic programming
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass
import itertools

INF = float('inf')


@dataclass(frozen=True)
class BoundaryDataPoint:
    """A single entry in the boundary data set: (signature, weight)."""
    signature: FrozenSet[str]
    weight: float


@dataclass
class WeightedClosureSystem:
    """A weighted closure system with named generators.

    Attributes:
        states: set of all state names
        generators: dict mapping generator name -> (output_set, weight)
    """
    states: Set[str]
    generators: Dict[str, Tuple[Set[str], float]]

    def boundary_signature(self, gen: str, boundary: Set[str]) -> FrozenSet[str]:
        """Compute the boundary signature of a generator.

        Time: O(|out(g)|)
        Space: O(|B|)
        """
        out_set = self.generators[gen][0]
        return frozenset(out_set & boundary)

    def extract_boundary_data(self, boundary: Set[str]) -> Set[BoundaryDataPoint]:
        """Extract the complete boundary data set.

        Time: O(|G| · |out_max|) where out_max = max |out(g)|
        Space: O(|G| · |B|)
        """
        return {
            BoundaryDataPoint(
                signature=self.boundary_signature(g, boundary),
                weight=self.generators[g][1]
            )
            for g in self.generators
        }

    def is_normal_form(self, boundary: Set[str]) -> bool:
        """Check normal form (injective sig+weight map).

        Time: O(|G| · |out_max|)
        Space: O(|G|)
        """
        pairs = [
            (self.boundary_signature(g, boundary), self.generators[g][1])
            for g in self.generators
        ]
        return len(pairs) == len(set(pairs))

    def boundary_kernel(self, boundary: Set[str]) -> Dict[str, float]:
        """Compute the full boundary kernel.

        Returns dict mapping each boundary element to its min-cost.
        Time: O(|G| · |B|)
        Space: O(|B|)
        """
        kernel = {b: INF for b in boundary}
        for g in self.generators:
            sig = self.boundary_signature(g, boundary)
            w = self.generators[g][1]
            for b in sig:
                kernel[b] = min(kernel[b], w)
        return kernel

    def entropy_profile(self, boundary: Set[str]) -> List[float]:
        """Compute the boundary entropy profile h(k) for k = 0, ..., |B|+1.

        h(k) = min weight among generators with |boundary_sig| >= k.

        Time: O(|G| · |out_max| + |B| · |G|)
        Space: O(|B| + |G|)
        """
        max_k = len(boundary) + 1
        profile = [INF] * (max_k + 1)
        for g in self.generators:
            sig_card = len(self.boundary_signature(g, boundary))
            w = self.generators[g][1]
            for k in range(sig_card + 1):
                profile[k] = min(profile[k], w)
        return profile

    def propagation_cost_dp(self, seed: Set[str], target: Set[str]) -> float:
        """Compute propagation cost using subset enumeration.

        For small |G|, enumerates all 2^|G| subsets.
        Time: O(2^|G| · |G|)
        Space: O(2^|G|)

        For larger systems, use propagation_cost_greedy for an approximation.
        """
        gen_list = list(self.generators.keys())
        n = len(gen_list)
        best = INF

        for mask in range(1 << n):
            covered = set(seed)
            cost = 0.0
            for i in range(n):
                if mask & (1 << i):
                    g = gen_list[i]
                    covered |= self.generators[g][0]
                    cost += self.generators[g][1]
            if target <= covered:
                best = min(best, cost)
        return best

    def propagation_cost_greedy(self, seed: Set[str], target: Set[str]) -> float:
        """Greedy approximation of propagation cost.

        Repeatedly selects the generator with best cost-per-new-coverage ratio.
        Time: O(|G|^2 · |X|)
        Space: O(|G| + |X|)

        Returns an upper bound on the true propagation cost.
        """
        covered = set(seed)
        remaining = target - covered
        total_cost = 0.0
        used = set()

        while remaining:
            best_gen = None
            best_ratio = INF
            for g in self.generators:
                if g in used:
                    continue
                out, w = self.generators[g]
                new_coverage = len(out & remaining)
                if new_coverage > 0:
                    ratio = w / new_coverage
                    if ratio < best_ratio:
                        best_ratio = ratio
                        best_gen = g

            if best_gen is None:
                return INF  # cannot cover target

            out, w = self.generators[best_gen]
            covered |= out
            remaining = target - covered
            total_cost += w
            used.add(best_gen)

        return total_cost


def reconstruct_bulk(
    boundary_data: Set[BoundaryDataPoint],
    name_prefix: str = "gen"
) -> WeightedClosureSystem:
    """Canonical bulk reconstruction from boundary data.

    Algorithm:
    1. For each (signature, weight) pair in the data, create a generator
       whose output is the signature and whose weight is the given weight.

    Time: O(|d| · |B|)
    Space: O(|d| · |B|)

    Args:
        boundary_data: set of BoundaryDataPoint
        name_prefix: prefix for generated generator names

    Returns:
        A WeightedClosureSystem in normal form realizing the given data.
    """
    states: Set[str] = set()
    generators: Dict[str, Tuple[Set[str], float]] = {}

    for i, dp in enumerate(sorted(boundary_data, key=lambda x: (len(x.signature), x.weight))):
        states |= dp.signature
        generators[f"{name_prefix}_{i}"] = (set(dp.signature), dp.weight)

    return WeightedClosureSystem(states=states, generators=generators)


def find_gauge_equivalence(
    sys1: WeightedClosureSystem,
    sys2: WeightedClosureSystem,
    boundary: Set[str]
) -> Optional[Dict[str, str]]:
    """Find a gauge equivalence between two normal-form systems.

    Algorithm:
    1. Build lookup tables from (signature, weight) to generator name.
    2. For each generator in sys1, find the matching generator in sys2.
    3. If all matches exist and the map is bijective, return it.

    Time: O(|G| · |out_max|)
    Space: O(|G|)

    Returns:
        Dict mapping sys1 generator names to sys2 generator names,
        or None if no gauge equivalence exists.
    """
    lookup1: Dict[Tuple[FrozenSet[str], float], str] = {}
    for g in sys1.generators:
        key = (sys1.boundary_signature(g, boundary), sys1.generators[g][1])
        if key in lookup1:
            return None  # Not normal form
        lookup1[key] = g

    lookup2: Dict[Tuple[FrozenSet[str], float], str] = {}
    for g in sys2.generators:
        key = (sys2.boundary_signature(g, boundary), sys2.generators[g][1])
        if key in lookup2:
            return None  # Not normal form
        lookup2[key] = g

    if set(lookup1.keys()) != set(lookup2.keys()):
        return None

    return {lookup1[key]: lookup2[key] for key in lookup1}


def verify_reconstruction(
    original: WeightedClosureSystem,
    boundary: Set[str]
) -> Tuple[bool, Optional[Dict[str, str]]]:
    """Verify the reconstruction theorem computationally.

    1. Extract boundary data from the original system.
    2. Reconstruct a canonical bulk system.
    3. Verify the reconstructed system realizes the same boundary data.
    4. Find a gauge equivalence between original and reconstruction.

    Returns:
        (success, gauge_equivalence)
    """
    data = original.extract_boundary_data(boundary)
    recon = reconstruct_bulk(data)
    recon_data = recon.extract_boundary_data(boundary)

    if data != recon_data:
        return False, None

    equiv = find_gauge_equivalence(original, recon, boundary)
    return equiv is not None, equiv


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build a sample system
    sys = WeightedClosureSystem(
        states={'i1', 'i2', 'b1', 'b2', 'b3'},
        generators={
            'alpha': ({'b1', 'b2', 'i1'}, 2.0),
            'beta':  ({'b2', 'b3'}, 3.0),
            'gamma': ({'b1', 'b3', 'i2'}, 1.5),
        }
    )
    boundary = {'b1', 'b2', 'b3'}

    print("=== Boundary Data ===")
    for dp in sorted(sys.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  sig={sorted(dp.signature)}, weight={dp.weight}")

    print("\n=== Boundary Kernel ===")
    kernel = sys.boundary_kernel(boundary)
    for b in sorted(kernel):
        print(f"  K({b}) = {kernel[b]}")

    print("\n=== Entropy Profile ===")
    profile = sys.entropy_profile(boundary)
    for k, h in enumerate(profile):
        print(f"  h({k}) = {h}")

    print("\n=== Reconstruction Verification ===")
    success, equiv = verify_reconstruction(sys, boundary)
    print(f"  Success: {success}")
    if equiv:
        print(f"  Gauge equivalence: {equiv}")

    print("\n=== Propagation Cost (exact) ===")
    for target in [{'b1'}, {'b2'}, {'b1', 'b2', 'b3'}]:
        cost = sys.propagation_cost_dp({'i1'}, target)
        print(f"  {{i1}} -> {sorted(target)}: cost = {cost}")


#!/usr/bin/env python3
"""
Tropical Holographic Reconstruction — Applications

Demonstrates real-world applications of the boundary rigidity and
reconstruction theorems:

1. Supply Chain Analysis: Identifying equivalent production networks
2. Inference Engine Fingerprinting: Determining rule sets from query responses
3. Network Tomography: Reconstructing internal link costs from boundary measurements
"""

from typing import Dict, Set, Tuple, List
from algorithms import (
    WeightedClosureSystem, BoundaryDataPoint,
    reconstruct_bulk, find_gauge_equivalence, verify_reconstruction
)

INF = float('inf')


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Supply Chain Analysis
# ═══════════════════════════════════════════════════════════════════════

def supply_chain_demo():
    """
    Two factories produce the same set of products from raw materials.
    Each production step (generator) transforms inputs into outputs at a cost.
    
    Question: Do the factories have the same internal production structure?
    Answer: Apply the boundary rigidity theorem — if they have the same
    boundary data (observable product-cost pairs), they must be structurally
    equivalent.
    """
    print("=" * 70)
    print("APPLICATION 1: Supply Chain Equivalence Analysis")
    print("=" * 70)
    
    # Factory A: produces electronics
    factory_a = WeightedClosureSystem(
        states={'raw_silicon', 'raw_plastic', 'chip', 'case', 'phone', 'tablet', 'charger'},
        generators={
            'chip_fab':   ({'chip', 'phone', 'tablet'}, 50.0),  # produces chips + enables phone/tablet
            'molding':    ({'case', 'phone', 'charger'}, 20.0),  # produces cases + enables phone/charger
            'assembly':   ({'tablet', 'charger'}, 30.0),         # enables tablet, charger
        }
    )
    
    # Factory B: different internal naming, same products
    factory_b = WeightedClosureSystem(
        states={'material_1', 'material_2', 'phone', 'tablet', 'charger'},
        generators={
            'process_X': ({'tablet', 'charger'}, 30.0),
            'process_Y': ({'phone', 'tablet', 'charger'}, 50.0),  # different sig from chip_fab!
            'process_Z': ({'phone', 'charger'}, 20.0),
        }
    )
    
    # Factory C: genuinely different structure
    factory_c = WeightedClosureSystem(
        states={'raw_1', 'phone', 'tablet', 'charger'},
        generators={
            'line_1': ({'phone', 'tablet', 'charger'}, 100.0),  # one expensive line does everything
        }
    )
    
    boundary = {'phone', 'tablet', 'charger'}  # observable products
    
    print("\nFactory A boundary data:")
    for dp in sorted(factory_a.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Products: {sorted(dp.signature)}, Cost: ${dp.weight}")
    
    print("\nFactory B boundary data:")
    for dp in sorted(factory_b.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Products: {sorted(dp.signature)}, Cost: ${dp.weight}")
    
    print("\nFactory C boundary data:")
    for dp in sorted(factory_c.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Products: {sorted(dp.signature)}, Cost: ${dp.weight}")
    
    # Check equivalence
    data_a = factory_a.extract_boundary_data(boundary)
    data_b = factory_b.extract_boundary_data(boundary)
    data_c = factory_c.extract_boundary_data(boundary)
    
    print(f"\nA ≡ B (same boundary data)? {data_a == data_b}")
    print(f"A ≡ C (same boundary data)? {data_a == data_c}")
    
    if data_a == data_b:
        equiv = find_gauge_equivalence(factory_a, factory_b, boundary)
        if equiv:
            print(f"\nGauge equivalence A→B: {equiv}")
            print("→ Factories have identical production capabilities (up to naming)")
    
    # Kernel comparison
    print("\nBoundary kernels (min cost per product):")
    for name, factory in [("A", factory_a), ("B", factory_b), ("C", factory_c)]:
        kernel = factory.boundary_kernel(boundary)
        costs = [f"{b}: ${kernel[b]}" for b in sorted(kernel)]
        print(f"  Factory {name}: {', '.join(costs)}")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Inference Engine Fingerprinting
# ═══════════════════════════════════════════════════════════════════════

def inference_engine_demo():
    """
    An inference engine applies rules to derive conclusions from premises.
    Each rule has a computational cost. The boundary is the set of observable
    conclusions; the interior is the intermediate reasoning steps.
    
    The rigidity theorem says: if two inference engines produce the same
    observable conclusions at the same costs, their rule sets are identical
    (up to relabeling).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Inference Engine Fingerprinting")
    print("=" * 70)
    
    # Engine 1: medical diagnosis rules
    engine_1 = WeightedClosureSystem(
        states={'symptom_A', 'symptom_B', 'test_result',
                'diagnosis_flu', 'diagnosis_cold', 'diagnosis_allergy',
                'intermediate_1'},
        generators={
            'rule_fever':   ({'diagnosis_flu', 'diagnosis_cold'}, 1.0),
            'rule_sneeze':  ({'diagnosis_cold', 'diagnosis_allergy'}, 0.5),
            'rule_rash':    ({'diagnosis_allergy'}, 2.0),
        }
    )
    
    # Engine 2: same diagnoses, different internal names
    engine_2 = WeightedClosureSystem(
        states={'input_1', 'input_2',
                'diagnosis_flu', 'diagnosis_cold', 'diagnosis_allergy'},
        generators={
            'R1': ({'diagnosis_allergy'}, 2.0),
            'R2': ({'diagnosis_cold', 'diagnosis_allergy'}, 0.5),
            'R3': ({'diagnosis_flu', 'diagnosis_cold'}, 1.0),
        }
    )
    
    boundary = {'diagnosis_flu', 'diagnosis_cold', 'diagnosis_allergy'}
    
    print("\nEngine 1 rules (boundary view):")
    for dp in sorted(engine_1.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Diagnoses: {sorted(dp.signature)}, Cost: {dp.weight}")
    
    print("\nEngine 2 rules (boundary view):")
    for dp in sorted(engine_2.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Diagnoses: {sorted(dp.signature)}, Cost: {dp.weight}")
    
    data_1 = engine_1.extract_boundary_data(boundary)
    data_2 = engine_2.extract_boundary_data(boundary)
    
    print(f"\nSame observable behavior? {data_1 == data_2}")
    
    if data_1 == data_2:
        equiv = find_gauge_equivalence(engine_1, engine_2, boundary)
        if equiv:
            print(f"Rule correspondence: {equiv}")
            print("→ By rigidity theorem: engines have identical inferential structure")
    
    # Reconstruction from observations alone
    print("\n--- Reconstruction from boundary observations ---")
    recon = reconstruct_bulk(data_1, name_prefix="inferred_rule")
    print("Reconstructed rule set:")
    for g in sorted(recon.generators):
        out, w = recon.generators[g]
        print(f"  {g}: diagnoses={sorted(out)}, cost={w}")
    
    success, _ = verify_reconstruction(engine_1, boundary)
    print(f"Reconstruction verified: {success}")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Network Tomography
# ═══════════════════════════════════════════════════════════════════════

def network_tomography_demo():
    """
    A communication network has internal routers and boundary access points.
    Each link (generator) connects certain nodes at a latency cost.
    
    From boundary-to-boundary latency measurements, can we reconstruct
    the internal link structure?
    
    The reconstruction theorem says: yes, up to gauge equivalence.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Tomography")
    print("=" * 70)
    
    # Network with 3 boundary nodes and 2 internal routers
    network = WeightedClosureSystem(
        states={'router_1', 'router_2', 'access_A', 'access_B', 'access_C'},
        generators={
            'link_north':  ({'access_A', 'access_B'}, 10.0),  # connects A and B
            'link_south':  ({'access_B', 'access_C'}, 15.0),  # connects B and C
            'link_cross':  ({'access_A', 'access_C'}, 25.0),  # connects A and C directly
        }
    )
    
    boundary = {'access_A', 'access_B', 'access_C'}
    
    print("\nNetwork topology (boundary view):")
    for dp in sorted(network.extract_boundary_data(boundary), key=lambda x: x.weight):
        print(f"  Connects: {sorted(dp.signature)}, Latency: {dp.weight}ms")
    
    # Boundary kernel = min latency to each access point
    kernel = network.boundary_kernel(boundary)
    print("\nMin-cost boundary kernel:")
    for b in sorted(kernel):
        print(f"  K({b}) = {kernel[b]}ms")
    
    # Entropy profile
    profile = network.entropy_profile(boundary)
    print("\nEntropy profile (min cost for k-coverage):")
    for k, h in enumerate(profile):
        cost_str = f"{h}ms" if h != INF else "∞"
        print(f"  h({k}) = {cost_str}")
    
    # Reconstruct from boundary data
    print("\n--- Reconstruction from boundary measurements ---")
    data = network.extract_boundary_data(boundary)
    recon = reconstruct_bulk(data, name_prefix="inferred_link")
    
    print("Inferred network links:")
    for g in sorted(recon.generators):
        out, w = recon.generators[g]
        print(f"  {g}: connects {sorted(out)}, latency={w}ms")
    
    success, equiv = verify_reconstruction(network, boundary)
    print(f"\nReconstruction matches original: {success}")
    if equiv:
        print(f"Link correspondence: {equiv}")
    
    # Propagation costs
    print("\nPropagation costs (boundary-to-boundary):")
    for src in sorted(boundary):
        for tgt in sorted(boundary):
            if src != tgt:
                cost = network.propagation_cost_dp({src}, {tgt})
                print(f"  {src} → {tgt}: {cost}ms")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    supply_chain_demo()
    inference_engine_demo()
    network_tomography_demo()
    
    print("\n" + "=" * 70)
    print("✅ All application demos complete!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Holographic Reconstruction — Demo & Visualization

Demonstrates the core concepts of tropical (min-plus) boundary-to-bulk
reconstruction for weighted closure systems:

1. Builds example weighted closure systems
2. Computes boundary kernels and entropy profiles
3. Demonstrates the rigidity theorem: normal-form systems with equal
   boundary data must be gauge-equivalent
4. Shows reconstruction from boundary data
5. Visualizes boundary response matrices and entropy profiles
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import Dict, List, Set, Tuple, Optional
import json

INF = float('inf')

# ─────────────────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────────────────

class WeightedClosureSystem:
    """A weighted closure system with generators acting on a finite state space.

    Each generator g has:
      - out[g]: set of states produced
      - weight[g]: tropical cost (non-negative real or infinity)
    """

    def __init__(self, states: List[str], generators: Dict[str, Tuple[Set[str], float]]):
        """
        Args:
            states: list of state names
            generators: dict mapping generator name -> (output_set, weight)
        """
        self.states = list(states)
        self.generators = dict(generators)

    def boundary_sig(self, gen_name: str, boundary: Set[str]) -> frozenset:
        """Boundary signature of a generator: outputs restricted to boundary."""
        out_set = self.generators[gen_name][0]
        return frozenset(out_set & boundary)

    def boundary_data(self, boundary: Set[str]) -> Set[Tuple[frozenset, float]]:
        """The boundary data set: {(sig, weight)} for all generators."""
        return {(self.boundary_sig(g, boundary), self.generators[g][1])
                for g in self.generators}

    def is_normal_form(self, boundary: Set[str]) -> bool:
        """Check if the system is in normal form (injective sig+weight map)."""
        pairs = [(self.boundary_sig(g, boundary), self.generators[g][1])
                 for g in self.generators]
        return len(pairs) == len(set(pairs))

    def is_reduced(self, boundary: Set[str]) -> bool:
        """Check if every generator has nonempty boundary signature."""
        return all(len(self.boundary_sig(g, boundary)) > 0
                   for g in self.generators)

    def is_separating(self, boundary: Set[str]) -> bool:
        """Check if distinct generators have distinct boundary signatures."""
        sigs = [self.boundary_sig(g, boundary) for g in self.generators]
        return len(sigs) == len(set(sigs))

    def boundary_kernel(self, boundary: Set[str], b: str) -> float:
        """Min cost to produce boundary element b."""
        costs = [self.generators[g][1] for g in self.generators
                 if b in self.boundary_sig(g, boundary)]
        return min(costs) if costs else INF

    def boundary_kernel_matrix(self, boundary: Set[str]) -> np.ndarray:
        """Full boundary kernel as a matrix (rows = boundary elements)."""
        b_list = sorted(boundary)
        return np.array([self.boundary_kernel(boundary, b) for b in b_list])

    def entropy_profile(self, boundary: Set[str], max_k: Optional[int] = None) -> List[float]:
        """Boundary entropy profile: h(k) = min weight among generators
        whose boundary signature has cardinality >= k."""
        if max_k is None:
            max_k = len(boundary) + 1
        profile = []
        for k in range(max_k + 1):
            costs = [self.generators[g][1] for g in self.generators
                     if len(self.boundary_sig(g, boundary)) >= k]
            profile.append(min(costs) if costs else INF)
        return profile

    def propagation_cost(self, seed: Set[str], target: Set[str]) -> float:
        """Min cost to cover target starting from seed, using subsets of generators."""
        gen_list = list(self.generators.keys())
        n = len(gen_list)
        best = INF
        # Enumerate all subsets of generators (feasible for small systems)
        for mask in range(1 << n):
            covered = set(seed)
            cost = 0.0
            for i in range(n):
                if mask & (1 << i):
                    g = gen_list[i]
                    covered |= self.generators[g][0]
                    cost += self.generators[g][1]
            if target <= covered:
                best = min(best, cost)
        return best


def reconstruct_bulk(boundary_data_set: Set[Tuple[frozenset, float]]) -> WeightedClosureSystem:
    """Reconstruct a canonical bulk system from boundary data."""
    states = set()
    generators = {}
    for i, (sig, weight) in enumerate(sorted(boundary_data_set, key=lambda x: (len(x[0]), x[1]))):
        states |= sig
        generators[f"g_recon_{i}"] = (set(sig), weight)
    return WeightedClosureSystem(sorted(states), generators)


def find_gauge_equiv(sys1: WeightedClosureSystem, sys2: WeightedClosureSystem,
                     boundary: Set[str]) -> Optional[Dict[str, str]]:
    """Find a gauge equivalence (generator bijection) between two normal-form systems."""
    data1 = {}
    for g in sys1.generators:
        key = (sys1.boundary_sig(g, boundary), sys1.generators[g][1])
        data1[key] = g
    data2 = {}
    for g in sys2.generators:
        key = (sys2.boundary_sig(g, boundary), sys2.generators[g][1])
        data2[key] = g

    if set(data1.keys()) != set(data2.keys()):
        return None

    equiv = {}
    for key in data1:
        equiv[data1[key]] = data2[key]
    return equiv


# ─────────────────────────────────────────────────────────────────────
# Example Systems
# ─────────────────────────────────────────────────────────────────────

def example_system_1():
    """A 5-state system with 3 generators and boundary {b1, b2, b3}."""
    states = ['i1', 'i2', 'b1', 'b2', 'b3']
    generators = {
        'alpha': ({'b1', 'b2', 'i1'}, 2.0),
        'beta':  ({'b2', 'b3'}, 3.0),
        'gamma': ({'b1', 'b3', 'i2'}, 1.5),
    }
    boundary = {'b1', 'b2', 'b3'}
    return WeightedClosureSystem(states, generators), boundary


def example_system_2():
    """A relabeled version of system 1 — should be gauge-equivalent."""
    states = ['x1', 'x2', 'b1', 'b2', 'b3']
    generators = {
        'A': ({'b1', 'b3', 'x2'}, 1.5),   # same boundary sig as gamma
        'B': ({'b1', 'b2', 'x1'}, 2.0),   # same boundary sig as alpha
        'C': ({'b2', 'b3'}, 3.0),          # same boundary sig as beta
    }
    boundary = {'b1', 'b2', 'b3'}
    return WeightedClosureSystem(states, generators), boundary


def example_non_equivalent():
    """A system with different boundary data."""
    states = ['i1', 'b1', 'b2', 'b3']
    generators = {
        'p': ({'b1', 'b2'}, 1.0),
        'q': ({'b3'}, 4.0),
        'r': ({'b1', 'b2', 'b3'}, 5.0),
    }
    boundary = {'b1', 'b2', 'b3'}
    return WeightedClosureSystem(states, generators), boundary


# ─────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────

def demo_boundary_signatures():
    """Demonstrate boundary signature computation."""
    print("=" * 70)
    print("DEMO 1: Boundary Signatures and Structural Predicates")
    print("=" * 70)

    sys1, boundary = example_system_1()
    print(f"\nStates: {sys1.states}")
    print(f"Boundary: {sorted(boundary)}")
    print(f"\nGenerators and their boundary signatures:")
    for g in sys1.generators:
        out, w = sys1.generators[g]
        sig = sys1.boundary_sig(g, boundary)
        print(f"  {g}: out={sorted(out)}, weight={w}, bSig={sorted(sig)}")

    print(f"\nReduced? {sys1.is_reduced(boundary)}")
    print(f"Separating? {sys1.is_separating(boundary)}")
    print(f"Normal form? {sys1.is_normal_form(boundary)}")


def demo_boundary_kernel():
    """Demonstrate boundary kernel computation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Boundary Kernel")
    print("=" * 70)

    sys1, boundary = example_system_1()
    b_list = sorted(boundary)

    print("\nBoundary kernel (min cost to produce each boundary element):")
    for b in b_list:
        k = sys1.boundary_kernel(boundary, b)
        print(f"  K({b}) = {k}")


def demo_entropy_profile():
    """Demonstrate entropy profile computation."""
    print("\n" + "=" * 70)
    print("DEMO 3: Boundary Entropy Profile")
    print("=" * 70)

    sys1, boundary = example_system_1()
    profile = sys1.entropy_profile(boundary)

    print("\nEntropy profile h(k) = min weight with |bSig| >= k:")
    for k, h in enumerate(profile):
        print(f"  h({k}) = {h}")
    print("\nMonotonicity verified:", all(profile[i] <= profile[i+1]
                                         for i in range(len(profile)-1)))


def demo_rigidity():
    """Demonstrate the boundary rigidity theorem."""
    print("\n" + "=" * 70)
    print("DEMO 4: Boundary Rigidity Theorem")
    print("=" * 70)

    sys1, b1 = example_system_1()
    sys2, b2 = example_system_2()

    data1 = sys1.boundary_data(b1)
    data2 = sys2.boundary_data(b2)

    print(f"\nSystem 1 boundary data: {sorted((sorted(s), w) for s, w in data1)}")
    print(f"System 2 boundary data: {sorted((sorted(s), w) for s, w in data2)}")
    print(f"\nBoundary data equal? {data1 == data2}")
    print(f"Both in normal form? {sys1.is_normal_form(b1) and sys2.is_normal_form(b2)}")

    equiv = find_gauge_equiv(sys1, sys2, b1)
    if equiv:
        print(f"\nGauge equivalence found!")
        for g1, g2 in equiv.items():
            sig1 = sorted(sys1.boundary_sig(g1, b1))
            w1 = sys1.generators[g1][1]
            print(f"  {g1} (sig={sig1}, w={w1}) <-> {g2}")
    else:
        print("\nNo gauge equivalence (different boundary data)")


def demo_reconstruction():
    """Demonstrate bulk reconstruction from boundary data."""
    print("\n" + "=" * 70)
    print("DEMO 5: Bulk Reconstruction")
    print("=" * 70)

    sys1, boundary = example_system_1()
    data = sys1.boundary_data(boundary)

    print(f"\nOriginal boundary data: {sorted((sorted(s), w) for s, w in data)}")

    recon = reconstruct_bulk(data)
    print(f"\nReconstructed system generators:")
    for g in recon.generators:
        out, w = recon.generators[g]
        print(f"  {g}: out={sorted(out)}, weight={w}")

    recon_data = recon.boundary_data(boundary)
    print(f"\nReconstructed boundary data: {sorted((sorted(s), w) for s, w in recon_data)}")
    print(f"Data preserved? {data == recon_data}")
    print(f"Reconstructed system in normal form? {recon.is_normal_form(boundary)}")

    # Check gauge equivalence with original
    equiv = find_gauge_equiv(sys1, recon, boundary)
    print(f"Gauge equivalent to original? {equiv is not None}")


def demo_non_equivalent():
    """Demonstrate that different systems have different boundary data."""
    print("\n" + "=" * 70)
    print("DEMO 6: Non-Equivalent Systems")
    print("=" * 70)

    sys1, b1 = example_system_1()
    sys3, b3 = example_non_equivalent()

    data1 = sys1.boundary_data(b1)
    data3 = sys3.boundary_data(b3)

    print(f"\nSystem 1 boundary data: {sorted((sorted(s), w) for s, w in data1)}")
    print(f"System 3 boundary data: {sorted((sorted(s), w) for s, w in data3)}")
    print(f"\nBoundary data equal? {data1 == data3}")

    k1 = [sys1.boundary_kernel(b1, b) for b in sorted(b1)]
    k3 = [sys3.boundary_kernel(b3, b) for b in sorted(b3)]
    print(f"\nKernels differ: {k1} vs {k3}")


def demo_propagation():
    """Demonstrate propagation cost computation."""
    print("\n" + "=" * 70)
    print("DEMO 7: Propagation Cost")
    print("=" * 70)

    sys1, boundary = example_system_1()

    seeds = [{'i1'}, {'i2'}, {'i1', 'i2'}]
    targets = [{'b1'}, {'b2'}, {'b3'}, {'b1', 'b2', 'b3'}]

    print("\nPropagation costs (seed -> target):")
    for seed in seeds:
        for target in targets:
            cost = sys1.propagation_cost(seed, target)
            print(f"  {sorted(seed)} -> {sorted(target)}: cost = {cost}")


# ─────────────────────────────────────────────────────────────────────
# Visualizations
# ─────────────────────────────────────────────────────────────────────

def plot_entropy_profiles():
    """Plot entropy profiles for multiple systems."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    systems = [
        ("System 1", *example_system_1()),
        ("System 2 (gauge-equiv)", *example_system_2()),
        ("System 3 (different)", *example_non_equivalent()),
    ]

    colors = ['#2196F3', '#FF9800', '#4CAF50']
    markers = ['o', 's', '^']

    for (name, sys, boundary), color, marker in zip(systems, colors, markers):
        profile = sys.entropy_profile(boundary)
        ks = list(range(len(profile)))
        # Replace INF for plotting
        plot_vals = [v if v != INF else None for v in profile]
        valid_k = [k for k, v in zip(ks, plot_vals) if v is not None]
        valid_v = [v for v in plot_vals if v is not None]
        ax.plot(valid_k, valid_v, f'-{marker}', color=color, label=name,
                linewidth=2, markersize=8)

    ax.set_xlabel('k (minimum boundary coverage)', fontsize=12)
    ax.set_ylabel('h(k) (minimum tropical cost)', fontsize=12)
    ax.set_title('Boundary Entropy Profiles', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(5))

    plt.tight_layout()
    plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: entropy_profiles.png")


def plot_boundary_kernel_heatmap():
    """Plot boundary kernel as a heatmap for multiple systems."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    systems = [
        ("System 1", *example_system_1()),
        ("System 2 (gauge-equiv)", *example_system_2()),
        ("System 3 (different)", *example_non_equivalent()),
    ]

    for ax, (name, sys, boundary) in zip(axes, systems):
        b_list = sorted(boundary)
        gen_list = sorted(sys.generators.keys())

        # Build matrix: rows = generators, cols = boundary elements
        matrix = np.zeros((len(gen_list), len(b_list)))
        for i, g in enumerate(gen_list):
            for j, b in enumerate(b_list):
                if b in sys.boundary_sig(g, boundary):
                    matrix[i, j] = sys.generators[g][1]
                else:
                    matrix[i, j] = np.nan

        im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto',
                       vmin=0, vmax=6)
        ax.set_xticks(range(len(b_list)))
        ax.set_xticklabels(b_list)
        ax.set_yticks(range(len(gen_list)))
        ax.set_yticklabels(gen_list)
        ax.set_xlabel('Boundary element')
        ax.set_ylabel('Generator')
        ax.set_title(name, fontsize=11)

        # Annotate cells
        for i in range(len(gen_list)):
            for j in range(len(b_list)):
                if not np.isnan(matrix[i, j]):
                    ax.text(j, i, f'{matrix[i,j]:.1f}', ha='center', va='center',
                            fontsize=10, fontweight='bold')
                else:
                    ax.text(j, i, '∅', ha='center', va='center',
                            fontsize=10, color='gray')

    fig.colorbar(im, ax=axes, label='Weight', shrink=0.8)
    fig.suptitle('Generator-Boundary Response Matrices', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('boundary_kernel_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: boundary_kernel_heatmap.png")


def plot_reconstruction_diagram():
    """Visualize the reconstruction pipeline."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    sys1, boundary = example_system_1()

    # Panel 1: Original system
    ax = axes[0]
    ax.set_title("Original Bulk System", fontsize=12, fontweight='bold')
    y_positions = {}
    states = sys1.states
    for i, s in enumerate(states):
        color = '#2196F3' if s in boundary else '#FF9800'
        label = 'Boundary' if s in boundary and i == 2 else ('Interior' if s not in boundary and i == 0 else None)
        y = len(states) - i
        y_positions[s] = y
        ax.scatter(0.5, y, s=300, c=color, zorder=5, label=label)
        ax.text(0.7, y, s, fontsize=11, va='center')

    for g in sys1.generators:
        out, w = sys1.generators[g]
        for s in out:
            if s in y_positions:
                ax.annotate('', xy=(0.45, y_positions[s]),
                           xytext=(0.1, y_positions[s]),
                           arrowprops=dict(arrowstyle='->', color='gray', lw=1))
        ax.text(0.05, np.mean([y_positions[s] for s in out if s in y_positions]),
                f'{g}\nw={w}', fontsize=9, ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange'))
    ax.set_xlim(-0.2, 1.2)
    ax.set_ylim(0, len(states) + 1)
    ax.axis('off')
    ax.legend(loc='lower right', fontsize=9)

    # Panel 2: Boundary data
    ax = axes[1]
    ax.set_title("Boundary Data\n(Observable)", fontsize=12, fontweight='bold')
    data = sorted(sys1.boundary_data(boundary), key=lambda x: (len(x[0]), x[1]))
    for i, (sig, w) in enumerate(data):
        y = len(data) - i
        text = f"sig={sorted(sig)}\nweight={w}"
        ax.text(0.5, y, text, fontsize=10, ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='lightblue', edgecolor='steelblue'))
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(0, len(data) + 1)
    ax.axis('off')

    # Panel 3: Reconstructed system
    ax = axes[2]
    ax.set_title("Reconstructed Bulk\n(Canonical Form)", fontsize=12, fontweight='bold')
    recon = reconstruct_bulk(sys1.boundary_data(boundary))
    gen_list = sorted(recon.generators.keys())
    for i, g in enumerate(gen_list):
        out, w = recon.generators[g]
        y = len(gen_list) - i
        text = f"{g}\nout={sorted(out)}, w={w}"
        ax.text(0.5, y, text, fontsize=9, ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='lightgreen', edgecolor='green'))
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(0, len(gen_list) + 1)
    ax.axis('off')

    # Arrows between panels
    fig.patches.extend([
        plt.matplotlib.patches.FancyArrowPatch(
            (0.35, 0.5), (0.38, 0.5), transform=fig.transFigure,
            arrowstyle='->', mutation_scale=20, color='red', lw=2),
        plt.matplotlib.patches.FancyArrowPatch(
            (0.64, 0.5), (0.67, 0.5), transform=fig.transFigure,
            arrowstyle='->', mutation_scale=20, color='green', lw=2),
    ])

    plt.tight_layout()
    plt.savefig('reconstruction_pipeline.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: reconstruction_pipeline.png")


def plot_propagation_cost_matrix():
    """Visualize propagation costs as a matrix."""
    sys1, boundary = example_system_1()

    seeds = [frozenset({s}) for s in sys1.states]
    targets = [frozenset({b}) for b in sorted(boundary)]

    matrix = np.zeros((len(seeds), len(targets)))
    for i, seed in enumerate(seeds):
        for j, target in enumerate(targets):
            cost = sys1.propagation_cost(set(seed), set(target))
            matrix[i, j] = cost if cost != INF else 10  # cap for display

    fig, ax = plt.subplots(figsize=(7, 5))
    im = ax.imshow(matrix, cmap='viridis_r', aspect='auto')

    ax.set_xticks(range(len(targets)))
    ax.set_xticklabels([sorted(t) for t in targets])
    ax.set_yticks(range(len(seeds)))
    ax.set_yticklabels([sorted(s) for s in seeds])
    ax.set_xlabel('Target (boundary element)', fontsize=11)
    ax.set_ylabel('Seed', fontsize=11)
    ax.set_title('Propagation Cost Matrix', fontsize=13)

    for i in range(len(seeds)):
        for j in range(len(targets)):
            val = matrix[i, j]
            text = f'{val:.1f}' if val < 10 else '∞'
            ax.text(j, i, text, ha='center', va='center', fontsize=10,
                    color='white' if val > 3 else 'black', fontweight='bold')

    plt.colorbar(im, label='Cost')
    plt.tight_layout()
    plt.savefig('propagation_costs.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: propagation_costs.png")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    # Run all demos
    demo_boundary_signatures()
    demo_boundary_kernel()
    demo_entropy_profile()
    demo_rigidity()
    demo_reconstruction()
    demo_non_equivalent()
    demo_propagation()

    # Generate visualizations
    print("\n" + "=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    plot_entropy_profiles()
    plot_boundary_kernel_heatmap()
    plot_reconstruction_diagram()
    plot_propagation_cost_matrix()

    print("\n✅ All demos and visualizations complete!")
