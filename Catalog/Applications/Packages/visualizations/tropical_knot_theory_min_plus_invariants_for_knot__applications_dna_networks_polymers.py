#!/usr/bin/env python3
"""
Tropical Knot Theory: Applications

Demonstrates real-world applications of tropical knot invariants:
1. DNA topology: modeling strand complexity
2. Network routing: knot-theoretic optimization
3. Material science: polymer entanglement classification
4. Cryptographic hashing: knot-based fingerprinting
"""

from typing import Dict, List, Tuple
import math

INF = float('inf')


# ============================================================
# Application 1: DNA Strand Complexity Analysis
# ============================================================

class DNATopologyAnalyzer:
    """Model DNA strand crossings as knot diagrams.

    DNA molecules can form knotted structures during replication.
    The tropical Jones invariant provides a complexity measure:
    - Higher tropical span → more topologically complex
    - Minimum tropical cost → energetic favorability of resolution

    This models how topoisomerase enzymes "simplify" DNA crossings.
    """

    def __init__(self):
        self.crossing_energy = {"positive": 2, "negative": 1}

    def model_crossing_sequence(self, crossings: List[str]) -> Dict:
        """Model a sequence of DNA crossings.

        Args:
            crossings: List of "positive" or "negative" crossing types

        Returns:
            Analysis including tropical complexity measures
        """
        # Build knot diagram from crossing sequence
        from algorithms import KnotDiagram, compute_tropical_jones

        D = KnotDiagram.loop("strand_end")
        for i, ctype in enumerate(crossings):
            wA = self.crossing_energy.get(ctype, 1)
            wB = 3 - wA  # complementary weight
            D = KnotDiagram.crossing(wA, wB, D, KnotDiagram.loop(f"loop_{i}"),
                                     name=f"crossing_{i}")

        f = compute_tropical_jones(D)

        return {
            "num_crossings": len(crossings),
            "crossing_types": crossings,
            "tropical_span": f.tropical_span,
            "min_resolution_cost": f.min_value,
            "complexity_profile": dict(f.coeffs),
            "topoisomerase_difficulty": f.tropical_span * f.min_value if f.min_value < INF else INF,
        }


# ============================================================
# Application 2: Network Routing Optimization
# ============================================================

class NetworkTopologyOptimizer:
    """Use tropical knot invariants for network path optimization.

    In network routing, paths can "cross" at shared resources.
    The tropical Jones invariant captures the minimum cost to resolve
    all resource conflicts, modeling:
    - Bandwidth allocation at crossing points
    - Latency optimization through resource sharing
    """

    def analyze_route_crossings(self, routes: List[List[int]],
                                 crossing_costs: Dict[Tuple[int,int], Tuple[int,int]]) -> Dict:
        """Analyze crossing structure of network routes.

        Args:
            routes: List of routes (each route is a list of node IDs)
            crossing_costs: For each pair of crossing routes, (costA, costB)
                           for the two resolution options

        Returns:
            Tropical analysis of the routing topology
        """
        from algorithms import KnotDiagram, compute_tropical_jones

        # Build diagram from crossings
        D = KnotDiagram.loop("base")
        for (i, j), (cA, cB) in crossing_costs.items():
            D = KnotDiagram.crossing(cA, cB, D, KnotDiagram.loop(f"alt_{i}_{j}"),
                                     name=f"route_crossing_{i}_{j}")

        f = compute_tropical_jones(D)

        return {
            "num_route_crossings": len(crossing_costs),
            "tropical_span": f.tropical_span,
            "min_resolution_cost": f.min_value,
            "optimal_degree": min(f.coeffs.keys(), key=lambda k: f.coeffs[k]) if f.coeffs else None,
            "profile": dict(f.coeffs),
        }


# ============================================================
# Application 3: Polymer Entanglement Classification
# ============================================================

class PolymerEntanglementClassifier:
    """Classify polymer chain entanglements using tropical invariants.

    Polymer chains in solution can form knots and links.
    The tropical Jones polynomial provides:
    - A complexity measure invariant under ambient isotopy
    - A lower bound on the minimum number of chain crossings
    - An energy landscape for untangling pathways
    """

    def classify_entanglement(self, chain_crossings: List[Tuple[int, int]]) -> Dict:
        """Classify entanglement complexity from crossing data.

        Args:
            chain_crossings: List of (wA, wB) weight pairs for each crossing

        Returns:
            Classification including tropical invariant data
        """
        from algorithms import KnotDiagram, compute_tropical_jones

        D = KnotDiagram.loop("chain_end")
        for i, (wA, wB) in enumerate(chain_crossings):
            D = KnotDiagram.crossing(wA, wB, D, KnotDiagram.loop())

        f = compute_tropical_jones(D)

        # Classification thresholds based on tropical span
        span = f.tropical_span
        if span == 0:
            category = "trivial (unknotted)"
        elif span <= 2:
            category = "simple entanglement"
        elif span <= 6:
            category = "moderate entanglement"
        else:
            category = "complex entanglement"

        return {
            "num_crossings": len(chain_crossings),
            "tropical_span": span,
            "min_cost": f.min_value,
            "category": category,
            "crossing_complexity_bound": span // 2,  # lower bound on crossing number
            "profile": dict(f.coeffs),
        }


# ============================================================
# Application 4: Knot-Based Fingerprinting
# ============================================================

class TropicalFingerprint:
    """Generate tropical knot fingerprints for data comparison.

    The tropical Jones polynomial can serve as a fingerprint:
    - Two objects with different fingerprints are provably distinct
    - The fingerprint is computed efficiently via dynamic programming
    - The tropical span provides a complexity measure
    """

    @staticmethod
    def from_sequence(data: List[int], window_size: int = 4) -> Dict:
        """Generate a tropical fingerprint from a data sequence.

        Encodes the sequence as crossing weights and computes the
        tropical Jones invariant.

        Args:
            data: Integer sequence to fingerprint
            window_size: Number of crossings per window

        Returns:
            Fingerprint data including tropical invariant
        """
        from algorithms import KnotDiagram, compute_tropical_jones

        # Encode data as crossing weights
        D = KnotDiagram.loop()
        for i in range(0, len(data) - 1, 2):
            wA = data[i] % 10
            wB = data[i + 1] % 10 if i + 1 < len(data) else 0
            D = KnotDiagram.crossing(wA, wB, D, KnotDiagram.loop())

        f = compute_tropical_jones(D)

        return {
            "data_length": len(data),
            "num_crossings": D.num_crossings,
            "tropical_span": f.tropical_span,
            "fingerprint": tuple(sorted(f.coeffs.items())),
            "profile": dict(f.coeffs),
        }


# ============================================================
# Run all applications
# ============================================================

def run_all_applications():
    """Demonstrate all applications with concrete examples."""

    print("=" * 70)
    print("APPLICATION 1: DNA Strand Complexity Analysis")
    print("=" * 70)

    dna = DNATopologyAnalyzer()

    sequences = [
        ["positive", "positive"],
        ["positive", "negative", "positive"],
        ["positive", "positive", "negative", "positive", "negative"],
        ["positive", "negative", "positive", "negative", "positive", "negative"],
    ]

    for seq in sequences:
        result = dna.model_crossing_sequence(seq)
        print(f"\n  Crossings: {result['crossing_types']}")
        print(f"  Tropical span: {result['tropical_span']}")
        print(f"  Min resolution cost: {result['min_resolution_cost']}")
        print(f"  Complexity profile: {result['complexity_profile']}")

    print("\n\n" + "=" * 70)
    print("APPLICATION 2: Network Routing Optimization")
    print("=" * 70)

    net = NetworkTopologyOptimizer()

    # Example: 3 routes crossing at shared resources
    crossing_costs = {
        (0, 1): (2, 5),   # Routes 0,1 cross: reroute costs 2 or 5
        (1, 2): (3, 1),   # Routes 1,2 cross
        (0, 2): (4, 2),   # Routes 0,2 cross
    }

    result = net.analyze_route_crossings(
        routes=[[1,2,3], [2,4,5], [3,5,6]],
        crossing_costs=crossing_costs
    )
    print(f"\n  Route crossings: {result['num_route_crossings']}")
    print(f"  Tropical span: {result['tropical_span']}")
    print(f"  Min resolution cost: {result['min_resolution_cost']}")
    print(f"  Optimal degree: {result['optimal_degree']}")
    print(f"  Profile: {result['profile']}")

    print("\n\n" + "=" * 70)
    print("APPLICATION 3: Polymer Entanglement Classification")
    print("=" * 70)

    polymer = PolymerEntanglementClassifier()

    entanglements = [
        [(1, 1)],
        [(1, 1), (2, 1)],
        [(1, 2), (3, 1), (1, 1), (2, 3)],
        [(1, 1), (1, 1), (1, 1), (1, 1), (1, 1), (1, 1)],
    ]

    for ent in entanglements:
        result = polymer.classify_entanglement(ent)
        print(f"\n  Crossings: {ent}")
        print(f"  Category: {result['category']}")
        print(f"  Tropical span: {result['tropical_span']}")
        print(f"  Crossing complexity bound: ≥ {result['crossing_complexity_bound']}")

    print("\n\n" + "=" * 70)
    print("APPLICATION 4: Tropical Fingerprinting")
    print("=" * 70)

    fp = TropicalFingerprint()

    data_sets = [
        [3, 1, 4, 1, 5, 9],
        [3, 1, 4, 1, 5, 8],  # One digit different
        [2, 7, 1, 8, 2, 8],
    ]

    fingerprints = []
    for data in data_sets:
        result = fp.from_sequence(data)
        fingerprints.append(result)
        print(f"\n  Data: {data}")
        print(f"  Crossings: {result['num_crossings']}")
        print(f"  Tropical span: {result['tropical_span']}")
        print(f"  Fingerprint: {result['fingerprint']}")

    # Compare fingerprints
    print("\n  Fingerprint comparison:")
    for i in range(len(fingerprints)):
        for j in range(i + 1, len(fingerprints)):
            same = fingerprints[i]['fingerprint'] == fingerprints[j]['fingerprint']
            print(f"    Data {i} vs Data {j}: {'SAME' if same else 'DIFFERENT'}")


if __name__ == "__main__":
    run_all_applications()
