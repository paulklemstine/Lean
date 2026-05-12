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