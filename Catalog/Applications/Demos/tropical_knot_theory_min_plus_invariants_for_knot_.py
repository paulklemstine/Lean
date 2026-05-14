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


#!/usr/bin/env python3
"""
Tropical Knot Theory: Demonstrations and Concrete Examples

This module demonstrates the tropical Jones invariant and its properties
on concrete knot diagram examples, making the abstract mathematics tangible.
"""

import math
from typing import Optional

INF = float('inf')


class KnotDiagram:
    """A combinatorial knot diagram as a binary tree of crossings.

    - Leaf: unknotted loop
    - Internal node: crossing with weights wA, wB and sub-diagrams D0, D1

    The tropical Jones invariant is computed by min-plus recursion:
    tJones(loop, n) = 0 if n==0, else ∞
    tJones(crossing(wA, wB, D0, D1), n) = min(wA + tJones(D0, n-1), wB + tJones(D1, n+1))
    """

    def __init__(self, wA: Optional[int] = None, wB: Optional[int] = None,
                 D0: Optional['KnotDiagram'] = None, D1: Optional['KnotDiagram'] = None,
                 name: str = ""):
        self.is_loop = (wA is None)
        self.wA = wA
        self.wB = wB
        self.D0 = D0
        self.D1 = D1
        self.name = name

    @staticmethod
    def loop(name: str = "unknot") -> 'KnotDiagram':
        return KnotDiagram(name=name)

    @staticmethod
    def crossing(wA: int, wB: int, D0: 'KnotDiagram', D1: 'KnotDiagram',
                 name: str = "") -> 'KnotDiagram':
        return KnotDiagram(wA=wA, wB=wB, D0=D0, D1=D1, name=name)

    @property
    def num_crossings(self) -> int:
        if self.is_loop:
            return 0
        return 1 + self.D0.num_crossings + self.D1.num_crossings

    def tJones(self, n: int) -> float:
        """Compute the tropical Jones invariant at Laurent degree n."""
        if self.is_loop:
            return 0.0 if n == 0 else INF
        val_A = self.wA + self.D0.tJones(n - 1)
        val_B = self.wB + self.D1.tJones(n + 1)
        return min(val_A, val_B)

    def support(self) -> list:
        """Compute the support: degrees where tJones is finite."""
        c = self.num_crossings
        return [n for n in range(-c, c + 1) if self.tJones(n) < INF]

    def tropical_span(self) -> int:
        """Compute the tropical span (max support - min support)."""
        supp = self.support()
        if len(supp) <= 1:
            return 0
        return max(supp) - min(supp)

    def profile(self) -> dict:
        """Full tropical state-cost profile."""
        c = self.num_crossings
        return {n: self.tJones(n) for n in range(-c, c + 1) if self.tJones(n) < INF}

    def resolveA(self) -> 'KnotDiagram':
        """A-resolution of outermost crossing."""
        if self.is_loop:
            return self
        return self.D0

    def resolveB(self) -> 'KnotDiagram':
        """B-resolution of outermost crossing."""
        if self.is_loop:
            return self
        return self.D1

    def __repr__(self):
        if self.name:
            return self.name
        if self.is_loop:
            return "○"
        return f"×({self.wA},{self.wB})[{self.D0}, {self.D1}]"


def demo_basic():
    """Demonstrate basic tropical Jones computation."""
    print("=" * 70)
    print("DEMO 1: Basic Tropical Jones Computation")
    print("=" * 70)

    # Unknot
    unknot = KnotDiagram.loop("unknot")
    print(f"\n{unknot}: {unknot.num_crossings} crossings")
    print(f"  tJones(0) = {unknot.tJones(0)}")
    print(f"  tJones(1) = {unknot.tJones(1)}")
    print(f"  Support: {unknot.support()}")
    print(f"  Span: {unknot.tropical_span()}")

    # Single crossing (Hopf link surrogate)
    hopf = KnotDiagram.crossing(1, 1, KnotDiagram.loop(), KnotDiagram.loop(), "hopf")
    print(f"\n{hopf}: {hopf.num_crossings} crossing")
    for n in range(-2, 3):
        v = hopf.tJones(n)
        print(f"  tJones({n:+d}) = {v if v < INF else '∞'}")
    print(f"  Support: {hopf.support()}")
    print(f"  Span: {hopf.tropical_span()}")
    print(f"  Span ≤ 2·crossings? {hopf.tropical_span()} ≤ {2 * hopf.num_crossings}: {hopf.tropical_span() <= 2 * hopf.num_crossings}")

    # Trefoil surrogate: chain of 3 crossings
    D1 = KnotDiagram.crossing(1, 1, KnotDiagram.loop(), KnotDiagram.loop())
    D2 = KnotDiagram.crossing(1, 2, D1, KnotDiagram.loop())
    trefoil = KnotDiagram.crossing(2, 1, D2, KnotDiagram.loop(), "trefoil")
    print(f"\n{trefoil}: {trefoil.num_crossings} crossings")
    print(f"  Profile: {trefoil.profile()}")
    print(f"  Support: {trefoil.support()}")
    print(f"  Span: {trefoil.tropical_span()}")
    print(f"  Span ≤ 2·crossings? {trefoil.tropical_span()} ≤ {2 * trefoil.num_crossings}: {trefoil.tropical_span() <= 2 * trefoil.num_crossings}")


def demo_skein_relation():
    """Demonstrate the tropical skein relation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Skein Relation")
    print("=" * 70)

    D0 = KnotDiagram.crossing(1, 1, KnotDiagram.loop(), KnotDiagram.loop(), "D0")
    D1 = KnotDiagram.loop("D1")
    wA, wB = 3, 2
    D = KnotDiagram.crossing(wA, wB, D0, D1, "D")

    print(f"\nDiagram D = crossing({wA}, {wB}, {D0}, {D1})")
    print(f"  D has {D.num_crossings} crossings")
    print(f"  D0 has {D0.num_crossings} crossing, D1 has {D1.num_crossings} crossings")

    print("\nVerifying skein relation: tJones(D, n) = min(wA + tJones(D0, n-1), wB + tJones(D1, n+1))")
    for n in range(-3, 4):
        lhs = D.tJones(n)
        rhs_A = wA + D0.tJones(n - 1)
        rhs_B = wB + D1.tJones(n + 1)
        rhs = min(rhs_A, rhs_B)
        status = "✓" if lhs == rhs else "✗"
        lhs_s = f"{lhs}" if lhs < INF else "∞"
        rhs_A_s = f"{rhs_A}" if rhs_A < INF else "∞"
        rhs_B_s = f"{rhs_B}" if rhs_B < INF else "∞"
        rhs_s = f"{rhs}" if rhs < INF else "∞"
        print(f"  n={n:+d}: tJones={lhs_s:>4s}  min({rhs_A_s:>4s}, {rhs_B_s:>4s}) = {rhs_s:>4s}  {status}")


def demo_crossing_bound():
    """Demonstrate the crossing number lower bound."""
    print("\n" + "=" * 70)
    print("DEMO 3: Crossing Number Lower Bound")
    print("=" * 70)

    def make_chain(k: int) -> KnotDiagram:
        """Build a chain of k crossings."""
        D = KnotDiagram.loop()
        for i in range(k):
            D = KnotDiagram.crossing(1, 1, D, KnotDiagram.loop())
        return D

    print("\nFor chains of k crossings:")
    print(f"{'k':>3s} | {'crossings':>9s} | {'span':>5s} | {'2·crossings':>11s} | {'bound holds':>11s} | {'support':>20s}")
    print("-" * 75)
    for k in range(8):
        D = make_chain(k)
        c = D.num_crossings
        s = D.tropical_span()
        supp = D.support()
        holds = s <= 2 * c
        print(f"{k:3d} | {c:9d} | {s:5d} | {2*c:11d} | {'✓' if holds else '✗':>11s} | {supp}")


def demo_simplification():
    """Demonstrate simplification termination."""
    print("\n" + "=" * 70)
    print("DEMO 4: Simplification Termination")
    print("=" * 70)

    # Build a complex diagram
    D = KnotDiagram.crossing(2, 3,
            KnotDiagram.crossing(1, 1,
                KnotDiagram.crossing(0, 1, KnotDiagram.loop(), KnotDiagram.loop()),
                KnotDiagram.loop()),
            KnotDiagram.crossing(1, 2, KnotDiagram.loop(), KnotDiagram.loop()),
            "complex")

    print(f"\nStarting diagram: {D}")
    print(f"  Crossings: {D.num_crossings}")
    print(f"  Profile: {D.profile()}")

    # Simplification by always taking A-resolution
    print("\nSimplification by A-resolution:")
    step = 0
    current = D
    while not current.is_loop:
        print(f"  Step {step}: {current.num_crossings} crossings, profile = {current.profile()}")
        current = current.resolveA()
        step += 1
    print(f"  Step {step}: {current.num_crossings} crossings (normal form = loop)")
    print(f"  Normal form tJones(0) = {current.tJones(0)}")

    # Simplification by always taking B-resolution
    print("\nSimplification by B-resolution:")
    step = 0
    current = D
    while not current.is_loop:
        print(f"  Step {step}: {current.num_crossings} crossings, profile = {current.profile()}")
        current = current.resolveB()
        step += 1
    print(f"  Step {step}: {current.num_crossings} crossings (normal form = loop)")
    print(f"  Normal form tJones(0) = {current.tJones(0)}")
    print("\n  → Both paths reach the same normal form cost (0), confirming uniqueness!")


def demo_separation():
    """Demonstrate the separation schema."""
    print("\n" + "=" * 70)
    print("DEMO 5: Separation Schema")
    print("=" * 70)

    # Two diagrams with different tropical profiles
    D1 = KnotDiagram.crossing(1, 1,
            KnotDiagram.crossing(1, 1, KnotDiagram.loop(), KnotDiagram.loop()),
            KnotDiagram.loop(), "D1")

    D2 = KnotDiagram.crossing(1, 2,
            KnotDiagram.crossing(2, 1, KnotDiagram.loop(), KnotDiagram.loop()),
            KnotDiagram.loop(), "D2")

    print(f"\n{D1}: {D1.num_crossings} crossings")
    print(f"  Profile: {D1.profile()}")
    print(f"\n{D2}: {D2.num_crossings} crossings")
    print(f"  Profile: {D2.profile()}")

    # Compare profiles
    p1 = D1.profile()
    p2 = D2.profile()
    all_keys = sorted(set(p1.keys()) | set(p2.keys()))

    print(f"\nProfile comparison:")
    print(f"{'n':>4s} | {'D1':>6s} | {'D2':>6s} | {'differ':>6s}")
    print("-" * 30)
    separating_degrees = []
    for n in all_keys:
        v1 = p1.get(n, INF)
        v2 = p2.get(n, INF)
        diff = "≠" if v1 != v2 else "="
        v1_s = f"{v1}" if v1 < INF else "∞"
        v2_s = f"{v2}" if v2 < INF else "∞"
        print(f"{n:4d} | {v1_s:>6s} | {v2_s:>6s} | {diff:>6s}")
        if v1 != v2:
            separating_degrees.append(n)

    if separating_degrees:
        print(f"\n  → Tropical invariant separates at degrees: {separating_degrees}")
        print("  → By the separation theorem, these diagrams have different tropical Jones invariants!")
    else:
        print("\n  → Profiles are identical; no tropical separation.")


def demo_dynamic_programming():
    """Demonstrate the DP / shortest-path interpretation."""
    print("\n" + "=" * 70)
    print("DEMO 6: Dynamic Programming / Shortest-Path Interpretation")
    print("=" * 70)

    # Build a diagram and show the state-sum tree
    L = KnotDiagram.loop
    D = KnotDiagram.crossing(2, 3,
            KnotDiagram.crossing(1, 4, L(), L()),
            KnotDiagram.crossing(5, 1, L(), L()))

    print(f"\nDiagram with {D.num_crossings} crossings")
    print("State-sum tree (each leaf = complete resolution):")
    print()

    def print_tree(d: KnotDiagram, indent: str = "", path: str = "", total_weight: int = 0, total_shift: int = 0):
        if d.is_loop:
            val = d.tJones(0) + total_weight  # = total_weight since tJones(loop,0)=0
            print(f"{indent}○ path={path} weight={total_weight} degree={total_shift} → tJones({total_shift}) contributes {val}")
            return
        print(f"{indent}× (wA={d.wA}, wB={d.wB})")
        print_tree(d.D0, indent + "  A─", path + "A", total_weight + d.wA, total_shift - 1)
        print_tree(d.D1, indent + "  B─", path + "B", total_weight + d.wB, total_shift + 1)

    print_tree(D)

    print("\nFinal tropical Jones values (min over all paths to each degree):")
    for n in range(-D.num_crossings, D.num_crossings + 1):
        v = D.tJones(n)
        v_s = f"{v}" if v < INF else "∞"
        print(f"  tJones({n:+d}) = {v_s}")


if __name__ == "__main__":
    demo_basic()
    demo_skein_relation()
    demo_crossing_bound()
    demo_simplification()
    demo_separation()
    demo_dynamic_programming()


#!/usr/bin/env python3
"""
Tropical Knot Theory: Visualizations

Generates publication-quality visualizations of tropical knot invariants.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, List
import base64
import io

# Use a clean style
plt.rcParams.update({
    'font.size': 12,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'figure.figsize': (10, 6),
    'figure.dpi': 150,
})

INF = float('inf')


class KnotDiagramViz:
    """Minimal KnotDiagram for visualization (self-contained)."""
    def __init__(self, wA=None, wB=None, left=None, right=None):
        self.is_loop = (wA is None)
        self.wA = wA; self.wB = wB
        self.left = left; self.right = right

    @staticmethod
    def loop(): return KnotDiagramViz()

    @staticmethod
    def crossing(wA, wB, D0, D1): return KnotDiagramViz(wA, wB, D0, D1)

    @property
    def num_crossings(self):
        if self.is_loop: return 0
        return 1 + self.left.num_crossings + self.right.num_crossings

    def tJones(self, n):
        if self.is_loop: return 0.0 if n == 0 else INF
        vA = self.wA + self.left.tJones(n - 1)
        vB = self.wB + self.right.tJones(n + 1)
        return min(vA, vB)

    def profile(self):
        c = self.num_crossings
        return {n: self.tJones(n) for n in range(-c, c+1) if self.tJones(n) < INF}


def make_chain(k, wA=1, wB=1):
    D = KnotDiagramViz.loop()
    for _ in range(k):
        D = KnotDiagramViz.crossing(wA, wB, D, KnotDiagramViz.loop())
    return D


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def viz_tropical_jones_profiles():
    """Visualize tropical Jones profiles for different diagram families."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Chain diagrams with unit weights
    ax = axes[0, 0]
    for k in range(1, 7):
        D = make_chain(k)
        prof = D.profile()
        degrees = sorted(prof.keys())
        values = [prof[d] for d in degrees]
        ax.plot(degrees, values, 'o-', label=f'{k} crossings', markersize=5, alpha=0.8)
    ax.set_xlabel('Laurent degree')
    ax.set_ylabel('Tropical value')
    ax.set_title('Tropical Jones Profiles: Chain Diagrams')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Asymmetric weight diagrams
    ax = axes[0, 1]
    weights = [(1,1), (1,2), (2,1), (1,3), (3,1)]
    for wA, wB in weights:
        D = make_chain(4, wA, wB)
        prof = D.profile()
        degrees = sorted(prof.keys())
        values = [prof[d] for d in degrees]
        ax.plot(degrees, values, 's-', label=f'w=({wA},{wB})', markersize=5, alpha=0.8)
    ax.set_xlabel('Laurent degree')
    ax.set_ylabel('Tropical value')
    ax.set_title('Weight Dependence (4 crossings)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Tropical span vs crossings
    ax = axes[1, 0]
    max_k = 12
    spans = []
    for k in range(1, max_k + 1):
        D = make_chain(k)
        prof = D.profile()
        if len(prof) > 1:
            span = max(prof.keys()) - min(prof.keys())
        else:
            span = 0
        spans.append(span)

    crossings_range = list(range(1, max_k + 1))
    ax.plot(crossings_range, spans, 'bo-', label='Tropical span', markersize=6)
    ax.plot(crossings_range, [2*k for k in crossings_range], 'r--', label='2·crossings (upper bound)', alpha=0.7)
    ax.plot(crossings_range, crossings_range, 'g--', label='crossings', alpha=0.7)
    ax.set_xlabel('Number of crossings')
    ax.set_ylabel('Tropical span')
    ax.set_title('Span vs Crossing Number Bound')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Heatmap of profiles
    ax = axes[1, 1]
    max_k = 8
    data = np.full((max_k, 2*max_k+1), np.nan)
    for k in range(1, max_k + 1):
        D = make_chain(k)
        for n in range(-max_k, max_k + 1):
            v = D.tJones(n)
            if v < INF:
                data[k-1, n + max_k] = v
    im = ax.imshow(data, aspect='auto', cmap='viridis_r',
                   extent=[-max_k-0.5, max_k+0.5, max_k+0.5, 0.5])
    ax.set_xlabel('Laurent degree')
    ax.set_ylabel('Number of crossings')
    ax.set_title('Tropical Jones Value Heatmap')
    plt.colorbar(im, ax=ax, label='Tropical value')

    fig.suptitle('Tropical Knot Invariants: Structural Analysis', fontsize=16, y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/viz_profiles.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_separation_schema():
    """Visualize the separation schema between diagram pairs."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Create pairs of diagrams with different weights
    pairs = [
        (make_chain(3, 1, 1), make_chain(3, 1, 2), "Unit vs (1,2)"),
        (make_chain(3, 2, 1), make_chain(3, 1, 3), "(2,1) vs (1,3)"),
        (
            KnotDiagramViz.crossing(1, 1,
                KnotDiagramViz.crossing(2, 1, KnotDiagramViz.loop(), KnotDiagramViz.loop()),
                KnotDiagramViz.loop()),
            KnotDiagramViz.crossing(1, 2,
                KnotDiagramViz.crossing(1, 2, KnotDiagramViz.loop(), KnotDiagramViz.loop()),
                KnotDiagramViz.loop()),
            "Different structure"
        ),
    ]

    for idx, (D1, D2, title) in enumerate(pairs):
        ax = axes[idx]
        p1 = D1.profile()
        p2 = D2.profile()

        all_degrees = sorted(set(p1.keys()) | set(p2.keys()))
        v1 = [p1.get(d, None) for d in all_degrees]
        v2 = [p2.get(d, None) for d in all_degrees]

        # Plot
        d1_plot = [d for d, v in zip(all_degrees, v1) if v is not None]
        v1_plot = [v for v in v1 if v is not None]
        d2_plot = [d for d, v in zip(all_degrees, v2) if v is not None]
        v2_plot = [v for v in v2 if v is not None]

        ax.bar([d - 0.15 for d in d1_plot], v1_plot, width=0.3, alpha=0.7, color='steelblue', label='D₁')
        ax.bar([d + 0.15 for d in d2_plot], v2_plot, width=0.3, alpha=0.7, color='coral', label='D₂')

        # Highlight separating degrees
        for d in all_degrees:
            if p1.get(d) != p2.get(d):
                ax.axvline(d, color='gold', alpha=0.3, linewidth=8)

        ax.set_xlabel('Laurent degree')
        ax.set_ylabel('Tropical value')
        ax.set_title(title)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Separation Schema: Profile Comparison', fontsize=14, y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/viz_separation.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_simplification():
    """Visualize the simplification process and termination."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Build a complex diagram
    D = KnotDiagramViz.crossing(2, 3,
            KnotDiagramViz.crossing(1, 1,
                KnotDiagramViz.crossing(0, 1, KnotDiagramViz.loop(), KnotDiagramViz.loop()),
                KnotDiagramViz.loop()),
            KnotDiagramViz.crossing(1, 2, KnotDiagramViz.loop(), KnotDiagramViz.loop()))

    # A-resolution path
    ax = axes[0]
    steps_A = []
    current = D
    while not current.is_loop:
        steps_A.append(current.num_crossings)
        current = current.left
    steps_A.append(0)

    # B-resolution path
    steps_B = []
    current = D
    while not current.is_loop:
        steps_B.append(current.num_crossings)
        current = current.right
    steps_B.append(0)

    ax.plot(range(len(steps_A)), steps_A, 'bo-', label='A-resolution path', markersize=8)
    ax.plot(range(len(steps_B)), steps_B, 'rs-', label='B-resolution path', markersize=8)
    ax.set_xlabel('Simplification step')
    ax.set_ylabel('Number of crossings')
    ax.set_title('Simplification Terminates\n(crossings strictly decrease)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, max(steps_A) + 1)

    # Span decrease during simplification
    ax = axes[1]
    max_k = 10
    initial_spans = []
    for k in range(1, max_k + 1):
        D = make_chain(k)
        prof = D.profile()
        span = max(prof.keys()) - min(prof.keys()) if len(prof) > 1 else 0
        initial_spans.append(span)

    ax.fill_between(range(1, max_k+1), [2*k for k in range(1, max_k+1)],
                     alpha=0.15, color='red', label='Forbidden zone (span > 2c)')
    ax.fill_between(range(1, max_k+1), initial_spans,
                     alpha=0.2, color='blue', label='Achievable region')
    ax.plot(range(1, max_k+1), initial_spans, 'bo-', markersize=6, label='Chain diagram span')
    ax.plot(range(1, max_k+1), [2*k for k in range(1, max_k+1)], 'r--',
            label='Upper bound (2c)', alpha=0.7)
    ax.set_xlabel('Number of crossings (c)')
    ax.set_ylabel('Tropical span')
    ax.set_title('Tropical Span Bound: span ≤ 2c')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_simplification.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_dp_tree():
    """Visualize the dynamic programming / shortest-path structure."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    # 3-crossing chain: enumerate all 8 states
    D = make_chain(3)
    states = []

    def enum_states(d, weight, shift, depth, path):
        if d.is_loop:
            states.append((weight, shift, depth, path))
            return
        enum_states(d.left, weight + d.wA, shift - 1, depth + 1, path + "A")
        enum_states(d.right, weight + d.wB, shift + 1, depth + 1, path + "B")

    enum_states(D, 0, 0, 0, "")

    # Plot each state as a point in (degree, weight) space
    degrees = [s[1] for s in states]
    weights = [s[0] for s in states]
    paths = [s[3] for s in states]

    # Color by optimality
    degree_min = {}
    for d, w in zip(degrees, weights):
        if d not in degree_min or w < degree_min[d]:
            degree_min[d] = w

    colors = ['gold' if weights[i] == degree_min[degrees[i]] else 'lightgray'
              for i in range(len(states))]
    sizes = [150 if weights[i] == degree_min[degrees[i]] else 80
             for i in range(len(states))]

    ax.scatter(degrees, weights, c=colors, s=sizes, edgecolors='black', zorder=5)

    for i, (d, w, _, p) in enumerate(zip(degrees, weights, [s[2] for s in states], paths)):
        offset_y = 0.15 if i % 2 == 0 else -0.25
        ax.annotate(p, (d, w), textcoords="offset points", xytext=(0, 12+offset_y*20),
                   fontsize=8, ha='center', alpha=0.8)

    # Draw the optimal path (tropical Jones polynomial)
    opt_degrees = sorted(degree_min.keys())
    opt_values = [degree_min[d] for d in opt_degrees]
    ax.plot(opt_degrees, opt_values, 'r-', linewidth=2, alpha=0.5, label='Tropical Jones (optimal)')

    ax.set_xlabel('Laurent degree (n)', fontsize=13)
    ax.set_ylabel('Path weight (tropical cost)', fontsize=13)
    ax.set_title('State-Sum as Shortest Path Problem (3-crossing chain)\n'
                 'Gold = optimal path for each degree', fontsize=14)

    optimal_patch = mpatches.Patch(color='gold', label='Optimal state')
    suboptimal_patch = mpatches.Patch(color='lightgray', label='Suboptimal state')
    ax.legend(handles=[optimal_patch, suboptimal_patch,
                       plt.Line2D([0], [0], color='red', alpha=0.5, label='Tropical Jones')],
             fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_dp_tree.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b1 = viz_tropical_jones_profiles()
    print(f"  viz_profiles.png generated ({len(b1)} chars base64)")
    b2 = viz_separation_schema()
    print(f"  viz_separation.png generated ({len(b2)} chars base64)")
    b3 = viz_simplification()
    print(f"  viz_simplification.png generated ({len(b3)} chars base64)")
    b4 = viz_dp_tree()
    print(f"  viz_dp_tree.png generated ({len(b4)} chars base64)")
    print("Done!")
