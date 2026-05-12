#!/usr/bin/env python3
"""
Tropical Persistence Realization Duality — Applications

Demonstrates real-world applications of the certified reconstruction:
1. Network evolution analysis
2. Supply chain resilience monitoring
3. Sensor network topology tracking
"""

from typing import List, Tuple, Dict
from algorithms import (
    Interval, BarcodeResult, GraphRealization,
    extract_barcode, realize_as_graph, certified_reconstruction,
    verify_barcode_correctness
)


# ═══════════════════════════════════════════════════════════════════
# Application 1: Network Evolution Analysis
# ═══════════════════════════════════════════════════════════════════

def network_evolution_analysis():
    """
    Analyze the topological evolution of a communication network.

    Links activate and deactivate over time. The tropical rank invariant
    captures the number of independent communication paths surviving
    across time windows.
    """
    print("=" * 60)
    print("Application 1: Network Evolution Analysis")
    print("=" * 60)
    print()

    # Network links with activation periods
    # (link_name, birth_time, death_time)
    network_links = [
        ("Server A-B", 0, 5),
        ("Server B-C", 1, 7),
        ("Server A-C", 2, 4),
        ("Server C-D", 3, 8),
        ("Server A-D", 4, 6),
        ("Server B-D", 5, 9),
    ]

    generators = [(b, d) for _, b, d in network_links]
    barcode, graph, certs = certified_reconstruction(generators)

    print("Network links:")
    for name, b, d in network_links:
        print(f"  {name}: active during [{b}, {d}]")
    print()

    print("Topological analysis:")
    print("  Time | Active Links | Rank (independent paths)")
    print("  -----+-------------+-----------------------")
    for t in range(11):
        active = [name for name, b, d in network_links if b <= t <= d]
        rank = barcode.rank(t, t)
        print(f"  t={t:2d}  | {len(active):11d} | {rank}")
    print()

    print(f"Critical transition times: {sorted(barcode.critical_scales)}")
    print(f"Number of independent topological features: {barcode.size}")
    print()

    # Identify vulnerability windows
    print("Vulnerability analysis (rank drops):")
    prev_rank = barcode.rank(0, 0)
    for t in range(1, 11):
        curr_rank = barcode.rank(t, t)
        if curr_rank < prev_rank:
            print(f"  ⚠ Rank drops at t={t}: {prev_rank} → {curr_rank}")
        prev_rank = curr_rank
    print()

    print(f"Certificates: {certs}")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Supply Chain Resilience
# ═══════════════════════════════════════════════════════════════════

def supply_chain_resilience():
    """
    Monitor supply chain resilience using tropical persistence.

    Each supply route has an activation period (when it's cost-effective)
    and a deactivation period (when disruptions make it infeasible).
    The barcode identifies critical transition points.
    """
    print("=" * 60)
    print("Application 2: Supply Chain Resilience")
    print("=" * 60)
    print()

    # Supply routes with cost-effective periods
    routes = [
        ("Pacific Shipping", 0, 6),
        ("Rail Corridor", 1, 8),
        ("Air Freight", 2, 3),
        ("Atlantic Shipping", 3, 7),
        ("Local Distribution", 4, 9),
        ("Emergency Air", 5, 10),
    ]

    generators = [(b, d) for _, b, d in routes]
    barcode, graph, certs = certified_reconstruction(generators)

    print("Supply routes:")
    for name, b, d in routes:
        lifetime = d - b
        print(f"  {name:20s}: months [{b:2d}, {d:2d}] (lifetime: {lifetime} months)")
    print()

    # Resilience score at each time
    print("Monthly resilience scores:")
    for month in range(12):
        # Resilience = rank (number of independent routes)
        resilience = barcode.rank(month, month)
        bar = "█" * resilience + "░" * (6 - resilience)
        status = "CRITICAL" if resilience <= 1 else "LOW" if resilience <= 2 else "OK"
        print(f"  Month {month:2d}: [{bar}] {resilience} routes  ({status})")
    print()

    # Time windows with sustained redundancy
    print("Sustained redundancy windows:")
    for i in range(12):
        for j in range(i, 12):
            r = barcode.rank(i, j)
            if r >= 3 and (j == i or barcode.rank(i, j - 1) >= 3):
                if j == 11 or barcode.rank(i, j + 1) < 3:
                    print(f"  Months [{i}, {j}]: {r} independent routes sustained")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 3: Sensor Network Topology
# ═══════════════════════════════════════════════════════════════════

def sensor_network_topology():
    """
    Track the evolving topology of a sensor network as sensors
    activate and deactivate due to battery life.
    """
    print("=" * 60)
    print("Application 3: Sensor Network Topology Tracking")
    print("=" * 60)
    print()

    # Sensors with battery life periods
    sensors = [
        ("Temp-1", 0, 10),
        ("Temp-2", 2, 8),
        ("Humidity-1", 1, 12),
        ("Pressure-1", 3, 9),
        ("Wind-1", 5, 15),
        ("Light-1", 0, 7),
        ("Light-2", 4, 11),
        ("Rain-1", 6, 14),
    ]

    generators = [(b, d) for _, b, d in sensors]
    barcode, graph, certs = certified_reconstruction(generators)

    print(f"Total sensors: {len(sensors)}")
    print(f"Unique barcode intervals: {barcode.size}")
    print(f"Critical scales: {sorted(barcode.critical_scales)}")
    print()

    # Coverage quality over time
    print("Coverage quality timeline:")
    for hour in range(17):
        active = sum(1 for _, b, d in sensors if b <= hour <= d)
        rank = barcode.rank(hour, hour)
        coverage = "████" if active >= 6 else "███" if active >= 4 else "██" if active >= 2 else "█"
        print(f"  Hour {hour:2d}: {active} sensors active, rank={rank}  {coverage}")
    print()

    # Identify coverage gaps
    print("Coverage gap analysis:")
    for i in range(17):
        for j in range(i, 17):
            if barcode.rank(i, j) == 0:
                print(f"  ⚠ No persistent coverage during [{i}, {j}]")
                break
    print()

    print(f"All certificates passed: {all(certs.values())}")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 4: Roundtrip Verification Benchmark
# ═══════════════════════════════════════════════════════════════════

def roundtrip_benchmark():
    """
    Benchmark the Möbius roundtrip: barcode → rank → Möbius → barcode.
    Verifies correctness on many random-ish test cases.
    """
    import random
    random.seed(42)

    print("=" * 60)
    print("Application 4: Roundtrip Verification Benchmark")
    print("=" * 60)
    print()

    num_tests = 50
    max_intervals = 20
    max_scale = 30
    failures = 0

    for test_id in range(num_tests):
        # Generate random barcode
        num_ivs = random.randint(1, max_intervals)
        intervals = set()
        for _ in range(num_ivs):
            b = random.randint(0, max_scale - 1)
            d = random.randint(b, max_scale)
            intervals.add((b, d))

        intervals = sorted(intervals)

        # Compute rank function
        def rho(i, j, ivs=intervals):
            return sum(1 for b, d in ivs if b <= i and j <= d)

        # Extract via Möbius
        result = extract_barcode(rho, max_scale + 1)
        recovered = sorted([(iv.birth, iv.death) for iv in result.intervals])

        # Verify
        if recovered != intervals:
            failures += 1
            print(f"  ✗ Test {test_id}: FAILED")
            print(f"    Original:  {intervals}")
            print(f"    Recovered: {recovered}")
        else:
            # Also verify rank function match
            if not verify_barcode_correctness(result, rho, max_scale + 1):
                failures += 1
                print(f"  ✗ Test {test_id}: rank mismatch")

    success_rate = (num_tests - failures) / num_tests * 100
    print(f"Results: {num_tests - failures}/{num_tests} tests passed ({success_rate:.0f}%)")
    if failures == 0:
        print("✓ Perfect roundtrip verification across all test cases")
    print()


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Persistence — Real-World Applications        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    network_evolution_analysis()
    supply_chain_resilience()
    sensor_network_topology()
    roundtrip_benchmark()

    print("All applications completed successfully! ✓")


#!/usr/bin/env python3
"""
Tropical Persistence Realization Duality — Demo

Demonstrates the core algorithms:
1. Barcode rank invariant computation
2. Möbius inversion recovering barcode membership
3. Filtered graph realization of a barcode
4. Certified reconstruction from a tropical presentation
"""

from typing import List, Tuple, Dict, Set
import itertools


# ═══════════════════════════════════════════════════════════════════
# §1. Core Data Structures
# ═══════════════════════════════════════════════════════════════════

class Barcode:
    """A barcode: a set of intervals (birth, death) with birth ≤ death."""

    def __init__(self, intervals: List[Tuple[int, int]]):
        for b, d in intervals:
            assert b <= d, f"Invalid interval ({b}, {d}): birth must ≤ death"
        # Store as sorted list of unique intervals
        self.intervals = sorted(set(intervals))

    def rank(self, i: int, j: int) -> int:
        """Rank invariant: count intervals [b,d] with b ≤ i and j ≤ d."""
        return sum(1 for b, d in self.intervals if b <= i and j <= d)

    def __repr__(self):
        return f"Barcode({self.intervals})"

    def __eq__(self, other):
        return isinstance(other, Barcode) and self.intervals == other.intervals


class FilteredGraph:
    """A filtered metric graph: edges with birth and death scales."""

    def __init__(self, edges: List[Tuple[int, int]]):
        for b, d in edges:
            assert b <= d, f"Invalid edge ({b}, {d}): birth must ≤ death"
        self.edges = edges

    def rank(self, i: int, j: int) -> int:
        """Rank invariant: count edges active during [i, j]."""
        return sum(1 for b, d in self.edges if b <= i and j <= d)

    def __repr__(self):
        return f"FilteredGraph(edges={self.edges})"


class TropPresentation:
    """A tropical presentation: generators with birth/death scales."""

    def __init__(self, generators: List[Tuple[int, int]]):
        for b, d in generators:
            assert b <= d, f"Invalid generator ({b}, {d})"
        self.generators = generators

    def rank(self, i: int, j: int) -> int:
        """Rank of the presentation at (i, j)."""
        return sum(1 for b, d in self.generators if b <= i and j <= d)


# ═══════════════════════════════════════════════════════════════════
# §2. Möbius Inversion
# ═══════════════════════════════════════════════════════════════════

def mobius_coeff(rho, a: int, b: int) -> int:
    """
    Möbius coefficient of a rank function at (a, b).

    μ(a,b) = ρ(a,b) - ρ(a,b+1) - (ρ(a-1,b) - ρ(a-1,b+1))  for a > 0
    μ(0,b) = ρ(0,b) - ρ(0,b+1)

    For a barcode's rank function, this recovers interval membership:
    μ(a,b) = 1 iff (a,b) is an interval in the barcode, 0 otherwise.
    """
    val = rho(a, b) - rho(a, b + 1)
    if a > 0:
        val -= rho(a - 1, b) - rho(a - 1, b + 1)
    return val


def extract_barcode_from_rank(rho, max_scale: int) -> Barcode:
    """
    Extract a barcode from a rank function via Möbius inversion.

    Scans all (a, b) with 0 ≤ a ≤ b ≤ max_scale and includes (a, b)
    in the barcode whenever μ(a, b) = 1.
    """
    intervals = []
    for a in range(max_scale + 1):
        for b in range(a, max_scale + 1):
            mu = mobius_coeff(rho, a, b)
            if mu == 1:
                intervals.append((a, b))
            elif mu != 0:
                raise ValueError(
                    f"Non-binary Möbius coefficient μ({a},{b}) = {mu}; "
                    f"rank function does not come from a simple barcode"
                )
    return Barcode(intervals)


# ═══════════════════════════════════════════════════════════════════
# §3. Realization
# ═══════════════════════════════════════════════════════════════════

def realize_barcode_as_graph(B: Barcode) -> FilteredGraph:
    """
    Realize a barcode as a minimal filtered graph.

    Each interval (b, d) becomes an edge with birth=b, death=d.
    The resulting graph has the same rank invariant as the barcode.
    """
    return FilteredGraph(list(B.intervals))


def reconstruct_from_presentation(pres: TropPresentation) -> Tuple[Barcode, FilteredGraph]:
    """
    Certified reconstruction: extract barcode and graph from a presentation.

    If generators have distinct (birth, death) pairs, the barcode rank
    equals the presentation rank.
    """
    barcode = Barcode(list(set(pres.generators)))
    graph = FilteredGraph(pres.generators)
    return barcode, graph


# ═══════════════════════════════════════════════════════════════════
# §4. Demonstrations
# ═══════════════════════════════════════════════════════════════════

def demo_single_interval():
    """Demo 1: Single interval barcode."""
    print("=" * 60)
    print("Demo 1: Single Interval Barcode {(2, 5)}")
    print("=" * 60)

    B = Barcode([(2, 5)])
    print(f"Barcode: {B}")
    print()

    # Compute rank invariant
    print("Rank invariant ρ(i, j):")
    print(f"  ρ(1, 5) = {B.rank(1, 5)}  (birth too late)")
    print(f"  ρ(2, 5) = {B.rank(2, 5)}  (exactly matches)")
    print(f"  ρ(3, 4) = {B.rank(3, 4)}  (contained)")
    print(f"  ρ(2, 6) = {B.rank(2, 6)}  (death too early)")
    print()

    # Möbius inversion
    print("Möbius coefficients:")
    for a in range(7):
        for b in range(a, 7):
            mu = mobius_coeff(B.rank, a, b)
            if mu != 0:
                print(f"  μ({a}, {b}) = {mu}")

    # Extract barcode from rank
    B_recovered = extract_barcode_from_rank(B.rank, 7)
    print(f"\nRecovered barcode: {B_recovered}")
    assert B == B_recovered, "Roundtrip failed!"
    print("✓ Roundtrip successful: rank → Möbius → barcode")

    # Realize as graph
    G = realize_barcode_as_graph(B)
    print(f"\nRealized graph: {G}")
    for i, j in [(2, 5), (1, 5), (3, 4)]:
        assert B.rank(i, j) == G.rank(i, j), f"Rank mismatch at ({i},{j})"
    print("✓ Graph rank matches barcode rank")
    print()


def demo_two_intervals():
    """Demo 2: Two-interval barcode."""
    print("=" * 60)
    print("Demo 2: Two-Interval Barcode {(1, 3), (2, 5)}")
    print("=" * 60)

    B = Barcode([(1, 3), (2, 5)])
    print(f"Barcode: {B}")
    print()

    # Rank table
    print("Rank invariant table:")
    print("     j=0  j=1  j=2  j=3  j=4  j=5  j=6")
    for i in range(7):
        row = "  ".join(f"{B.rank(i, j):3d}" for j in range(7))
        print(f"i={i}: {row}")
    print()

    # Möbius recovery
    print("Möbius coefficients (nonzero):")
    for a in range(7):
        for b in range(a, 7):
            mu = mobius_coeff(B.rank, a, b)
            if mu != 0:
                print(f"  μ({a}, {b}) = {mu}  →  interval ({a}, {b}) {'∈' if mu == 1 else '∉'} B")

    B_recovered = extract_barcode_from_rank(B.rank, 7)
    print(f"\nRecovered barcode: {B_recovered}")
    assert B == B_recovered
    print("✓ Roundtrip successful")

    # Reconstruction from presentation
    pres = TropPresentation([(1, 3), (2, 5)])
    barcode, graph = reconstruct_from_presentation(pres)
    print(f"\nPresentation: generators = {pres.generators}")
    print(f"Reconstructed barcode: {barcode}")
    print(f"Reconstructed graph: {graph}")
    for i in range(7):
        for j in range(7):
            assert barcode.rank(i, j) == pres.rank(i, j), f"Mismatch at ({i},{j})"
    print("✓ Reconstruction correct: barcode rank = presentation rank")
    print()


def demo_uniqueness():
    """Demo 3: Uniqueness — two barcodes with same rank must be equal."""
    print("=" * 60)
    print("Demo 3: Uniqueness of Barcode from Rank Invariant")
    print("=" * 60)

    B1 = Barcode([(0, 2), (1, 4), (3, 6)])
    B2 = Barcode([(0, 2), (1, 4), (3, 6)])
    B3 = Barcode([(0, 3), (1, 4), (3, 6)])  # Different!

    print(f"B1 = {B1}")
    print(f"B2 = {B2}")
    print(f"B3 = {B3}")

    # Check rank equality
    same_12 = all(B1.rank(i, j) == B2.rank(i, j) for i in range(8) for j in range(8))
    same_13 = all(B1.rank(i, j) == B3.rank(i, j) for i in range(8) for j in range(8))

    print(f"\nB1 and B2 have same rank? {same_12}")
    print(f"B1 and B3 have same rank? {same_13}")

    if same_12:
        assert B1 == B2, "Uniqueness violated!"
        print("✓ Same rank → same barcode (uniqueness holds for B1, B2)")
    if not same_13:
        print("✓ Different barcodes have different rank invariants")

    # Show distinguishing rank values
    for i in range(8):
        for j in range(8):
            if B1.rank(i, j) != B3.rank(i, j):
                print(f"  Distinguishing: ρ_B1({i},{j})={B1.rank(i,j)}, "
                      f"ρ_B3({i},{j})={B3.rank(i,j)}")
                break
        else:
            continue
        break
    print()


def demo_graph_realization():
    """Demo 4: Graph realization of barcodes."""
    print("=" * 60)
    print("Demo 4: Filtered Graph Realization")
    print("=" * 60)

    B = Barcode([(0, 1), (0, 3), (2, 4), (1, 2)])
    print(f"Barcode: {B}")

    G = realize_barcode_as_graph(B)
    print(f"Minimal graph: {G}")
    print(f"Number of edges: {len(G.edges)}")
    print(f"Number of intervals: {len(B.intervals)}")

    # Verify rank match
    max_s = 6
    all_match = True
    for i in range(max_s):
        for j in range(max_s):
            if B.rank(i, j) != G.rank(i, j):
                all_match = False
                print(f"  MISMATCH at ({i},{j}): barcode={B.rank(i,j)}, graph={G.rank(i,j)}")
    if all_match:
        print("✓ Graph rank matches barcode rank at all tested scales")

    # Show graph filtration evolution
    print("\nFiltration evolution:")
    for t in range(max_s):
        active = [(b, d) for b, d in G.edges if b <= t and t <= d]
        print(f"  Scale t={t}: {len(active)} active edges: {active}")
    print()


def demo_certified_reconstruction():
    """Demo 5: Certified reconstruction from tropical presentation."""
    print("=" * 60)
    print("Demo 5: Certified Reconstruction from Presentation")
    print("=" * 60)

    # Create a presentation (generators with birth/death times)
    pres = TropPresentation([(0, 2), (1, 3), (2, 5), (4, 7)])
    print(f"Presentation generators: {pres.generators}")

    # Reconstruct
    barcode, graph = reconstruct_from_presentation(pres)
    print(f"Extracted barcode: {barcode}")
    print(f"Realized graph: {graph}")

    # Verify correctness certificates
    max_s = 9
    barcode_correct = all(
        barcode.rank(i, j) == pres.rank(i, j)
        for i in range(max_s) for j in range(max_s)
    )
    graph_correct = all(
        graph.rank(i, j) == pres.rank(i, j)
        for i in range(max_s) for j in range(max_s)
    )

    print(f"\nBarcode rank = presentation rank? {barcode_correct}")
    print(f"Graph rank = presentation rank? {graph_correct}")

    # Verify barcode-graph agreement
    bg_agree = all(
        barcode.rank(i, j) == graph.rank(i, j)
        for i in range(max_s) for j in range(max_s)
    )
    print(f"Barcode rank = graph rank? {bg_agree}")

    if barcode_correct:
        print("✓ Barcode reconstruction certified correct")
    if graph_correct:
        print("✓ Graph reconstruction certified correct")

    # Show Möbius recovery
    print("\nMöbius coefficient check:")
    B_recovered = extract_barcode_from_rank(barcode.rank, max_s)
    assert B_recovered == barcode
    print("✓ Möbius inversion recovers the extracted barcode")

    # Critical scales
    critical = set()
    for b, d in barcode.intervals:
        critical.add(b)
        critical.add(d)
    print(f"\nCritical scales: {sorted(critical)}")
    print(f"Number of intervals: {len(barcode.intervals)}")
    print()


# ═══════════════════════════════════════════════════════════════════
# §5. Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Persistence Realization Duality — Demos       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_single_interval()
    demo_two_intervals()
    demo_uniqueness()
    demo_graph_realization()
    demo_certified_reconstruction()

    print("All demos completed successfully! ✓")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all content embedded."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read images
images = {}
for name in ['barcode_diagram', 'rank_heatmap', 'mobius_recovery',
             'filtration_evolution', 'pipeline_diagram']:
    path = f'{name}.png'
    if os.path.exists(path):
        images[name] = image_to_base64(path)

# Build package
package = {
    "title": "Tropical Persistence Realization Duality via Idempotent Filtration Semimodules and Certified Barcode Reconstruction",
    "domain": "Bridges: Tropical Geometry × Topological Data Analysis × Formal Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Persistence Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Möbius Barcode Extraction",
            "pseudocode": """Input: Rank function ρ : N × N → N, bound N
Output: Barcode B

B ← ∅
for a = 0 to N:
    for b = a to N:
        μ ← ρ(a,b) - ρ(a,b+1)
        if a > 0: μ ← μ - ρ(a-1,b) + ρ(a-1,b+1)
        if μ = 1: B ← B ∪ {(a, b)}
        if μ ∉ {0, 1}: REJECT
return B

Time: O(N²)  Space: O(N²)""",
            "code": algorithms_code
        },
        {
            "name": "Filtered Graph Realization",
            "pseudocode": """Input: Barcode B = {I₁, ..., I_k}
Output: Filtered graph G

V ← {v₁, ..., v_{2k}}
E ← ∅
for j = 1 to k:
    E ← E ∪ {(v_{2j-1}, v_{2j}, birth(Iⱼ), death(Iⱼ))}
return G = (V, E)

Time: O(k)  Space: O(k)""",
            "code": algorithms_code
        },
        {
            "name": "Certified Reconstruction Pipeline",
            "pseudocode": """Input: Generators {(b₁,d₁), ..., (b_k,d_k)}
Output: (Barcode, Graph, Certificates)

1. Compute ρ(i,j) = |{g : b_g ≤ i ∧ j ≤ d_g}|
2. B ← MöbiusExtraction(ρ, N)
3. G ← GraphRealization(B)
4. Verify certificates
return (B, G, certs)

Time: O(N² + kN²)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Persistence Barcode Diagram", "data": images.get('barcode_diagram', '')},
        {"name": "Rank Invariant Heatmap", "data": images.get('rank_heatmap', '')},
        {"name": "Möbius Recovery & Barcode Extraction", "data": images.get('mobius_recovery', '')},
        {"name": "Filtered Graph Evolution", "data": images.get('filtration_evolution', '')},
        {"name": "Certified Reconstruction Pipeline", "data": images.get('pipeline_diagram', '')},
    ],
    "lean_proofs": lean_proofs
}

# Write package
with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully!")
print(f"  Article: {len(article)} chars")
print(f"  Research paper: {len(research_paper)} chars")
print(f"  Future directions: {len(future_directions)} chars")
print(f"  Lean proofs: {len(lean_proofs)} chars")
print(f"  Visualizations: {len(images)} images")


#!/usr/bin/env python3
"""
Tropical Persistence Realization Duality — Visualizations

Generates publication-quality figures illustrating the core theory:
1. Barcode diagram with persistence intervals
2. Rank invariant heatmap
3. Möbius coefficient matrix
4. Filtered graph evolution
5. Reconstruction pipeline diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def barcode_rank(intervals, i, j):
    """Compute rank invariant."""
    return sum(1 for b, d in intervals if b <= i and j <= d)


def mobius_coeff(rho, a, b):
    """Compute Möbius coefficient."""
    val = rho(a, b) - rho(a, b + 1)
    if a > 0:
        val -= rho(a - 1, b) - rho(a - 1, b + 1)
    return val


# ═══════════════════════════════════════════════════════════════════
# Figure 1: Barcode Diagram
# ═══════════════════════════════════════════════════════════════════

def create_barcode_diagram():
    """Create a barcode persistence diagram."""
    intervals = [(0, 3), (1, 5), (2, 4), (3, 7), (5, 8)]
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']

    fig, ax = plt.subplots(1, 1, figsize=(10, 4))

    for idx, (b, d) in enumerate(intervals):
        y = idx
        ax.plot([b, d], [y, y], color=colors[idx], linewidth=4,
                solid_capstyle='round', zorder=2)
        ax.plot(b, y, 'o', color=colors[idx], markersize=8, zorder=3)
        ax.plot(d, y, 's', color=colors[idx], markersize=8, zorder=3)
        ax.annotate(f'[{b}, {d}]', xy=(d + 0.2, y), va='center',
                   fontsize=10, color=colors[idx], fontweight='bold')

    ax.set_xlabel('Scale Parameter', fontsize=12)
    ax.set_ylabel('Feature Index', fontsize=12)
    ax.set_title('Tropical Persistence Barcode', fontsize=14, fontweight='bold')
    ax.set_yticks(range(len(intervals)))
    ax.set_yticklabels([f'Feature {i}' for i in range(len(intervals))])
    ax.set_xlim(-0.5, 10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=-0.5, color='gray', linewidth=0.5)

    return fig


# ═══════════════════════════════════════════════════════════════════
# Figure 2: Rank Invariant Heatmap
# ═══════════════════════════════════════════════════════════════════

def create_rank_heatmap():
    """Create a heatmap of the rank invariant."""
    intervals = [(0, 3), (1, 5), (2, 4), (3, 7)]
    N = 9

    rank_matrix = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            rank_matrix[j, i] = barcode_rank(intervals, i, j)

    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    cmap = LinearSegmentedColormap.from_list('tropical',
        ['#FFFFFF', '#E3F2FD', '#64B5F6', '#1976D2', '#0D47A1'])

    im = ax.imshow(rank_matrix, cmap=cmap, interpolation='nearest',
                    origin='lower', aspect='equal')

    # Add text annotations
    for i in range(N):
        for j in range(N):
            val = int(rank_matrix[j, i])
            color = 'white' if val >= 3 else 'black'
            ax.text(i, j, str(val), ha='center', va='center',
                   fontsize=11, fontweight='bold', color=color)

    ax.set_xlabel('Birth threshold (i)', fontsize=12)
    ax.set_ylabel('Death threshold (j)', fontsize=12)
    ax.set_title('Rank Invariant ρ(i, j)', fontsize=14, fontweight='bold')

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Number of containing intervals', fontsize=10)

    # Mark the diagonal
    ax.plot([-0.5, N-0.5], [-0.5, N-0.5], 'r--', alpha=0.3, linewidth=1)

    return fig


# ═══════════════════════════════════════════════════════════════════
# Figure 3: Möbius Coefficient Matrix
# ═══════════════════════════════════════════════════════════════════

def create_mobius_matrix():
    """Create a visualization of the Möbius coefficients."""
    intervals = [(0, 3), (1, 5), (2, 4), (3, 7)]
    N = 9

    def rho(i, j):
        return barcode_rank(intervals, i, j)

    mobius_matrix = np.zeros((N, N))
    for a in range(N):
        for b in range(N):
            mobius_matrix[b, a] = mobius_coeff(rho, a, b)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Möbius matrix
    ax = axes[0]
    cmap = LinearSegmentedColormap.from_list('mobius',
        ['#E8EAF6', '#FFFFFF', '#E8F5E9', '#4CAF50'])
    im = ax.imshow(mobius_matrix, cmap=cmap, interpolation='nearest',
                    origin='lower', aspect='equal', vmin=-0.5, vmax=1.5)

    for a in range(N):
        for b in range(N):
            val = int(mobius_matrix[b, a])
            if val != 0:
                ax.text(a, b, str(val), ha='center', va='center',
                       fontsize=14, fontweight='bold',
                       color='#1B5E20' if val == 1 else '#B71C1C',
                       bbox=dict(boxstyle='round,pad=0.2',
                                facecolor='#C8E6C9' if val == 1 else '#FFCDD2',
                                edgecolor='none', alpha=0.8))

    ax.set_xlabel('Birth (a)', fontsize=12)
    ax.set_ylabel('Death (b)', fontsize=12)
    ax.set_title('Möbius Coefficients μ(a, b)', fontsize=14, fontweight='bold')
    ax.plot([-0.5, N-0.5], [-0.5, N-0.5], 'r--', alpha=0.3, linewidth=1)

    # Right: Reconstruction verification
    ax2 = axes[1]
    recovered_intervals = []
    for a in range(N):
        for b in range(a, N):
            if mobius_coeff(rho, a, b) == 1:
                recovered_intervals.append((a, b))

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    for idx, (a, b) in enumerate(recovered_intervals):
        c = colors[idx % len(colors)]
        ax2.barh(idx, b - a, left=a, height=0.6, color=c, alpha=0.8,
                edgecolor='black', linewidth=1)
        ax2.text(a + (b - a) / 2, idx, f'[{a},{b}]', ha='center', va='center',
                fontsize=11, fontweight='bold', color='white')

    ax2.set_xlabel('Scale', fontsize=12)
    ax2.set_ylabel('Interval', fontsize=12)
    ax2.set_title('Recovered Barcode (from Möbius)', fontsize=14, fontweight='bold')
    ax2.set_yticks(range(len(recovered_intervals)))
    ax2.set_xlim(-0.5, N)
    ax2.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    return fig


# ═══════════════════════════════════════════════════════════════════
# Figure 4: Filtered Graph Evolution
# ═══════════════════════════════════════════════════════════════════

def create_filtration_evolution():
    """Visualize the evolution of a filtered graph through scales."""
    intervals = [(0, 2), (1, 4), (2, 3), (3, 5)]
    max_t = 6

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    axes = axes.flatten()

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

    for t_idx, t in enumerate(range(max_t)):
        ax = axes[t_idx]

        # Draw edges
        active = []
        for idx, (b, d) in enumerate(intervals):
            is_active = b <= t and t <= d
            y = idx * 0.8
            color = colors[idx] if is_active else '#E0E0E0'
            alpha = 1.0 if is_active else 0.3
            lw = 3 if is_active else 1

            # Draw as a simple path between two vertices
            ax.plot([0, 2], [y, y], color=color, linewidth=lw, alpha=alpha,
                   solid_capstyle='round')
            ax.plot([0, 2], [y, y], 'o', color=color, markersize=8, alpha=alpha)

            if is_active:
                active.append(f'[{b},{d}]')
                ax.text(2.3, y, f'[{b},{d}]', va='center', fontsize=9,
                       color=color, fontweight='bold')

        rank = barcode_rank(intervals, t, t)
        ax.set_title(f't = {t}  |  rank = {rank}', fontsize=12, fontweight='bold')
        ax.set_xlim(-0.5, 4)
        ax.set_ylim(-0.5, len(intervals) * 0.8)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_frame_on(True)
        for spine in ax.spines.values():
            spine.set_linewidth(2 if len(active) > 0 else 1)
            spine.set_color('#1565C0' if len(active) > 0 else '#BDBDBD')

    fig.suptitle('Filtered Graph Evolution Through Scales',
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# ═══════════════════════════════════════════════════════════════════
# Figure 5: Reconstruction Pipeline
# ═══════════════════════════════════════════════════════════════════

def create_pipeline_diagram():
    """Create a diagram of the reconstruction pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 5))

    # Pipeline boxes
    boxes = [
        (0.5, 2, 'Tropical\nPresentation\nA', '#E3F2FD', '#1565C0'),
        (3.5, 2, 'Rank\nInvariant\nρ(i,j)', '#FFF3E0', '#E65100'),
        (6.5, 2, 'Möbius\nCoefficients\nμ(a,b)', '#E8F5E9', '#2E7D32'),
        (9.5, 2, 'Minimal\nBarcode\nB(M)', '#F3E5F5', '#6A1B9A'),
        (12.5, 2, 'Filtered\nGraph\nX(M)', '#FFEBEE', '#C62828'),
    ]

    for x, y, text, facecolor, edgecolor in boxes:
        rect = patches.FancyBboxPatch(
            (x - 1.1, y - 0.9), 2.2, 1.8,
            boxstyle="round,pad=0.1",
            facecolor=facecolor, edgecolor=edgecolor, linewidth=2
        )
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center',
               fontsize=11, fontweight='bold', color=edgecolor)

    # Arrows
    arrow_props = dict(arrowstyle='->', color='#424242', lw=2,
                       connectionstyle='arc3,rad=0')
    for i in range(len(boxes) - 1):
        x1 = boxes[i][0] + 1.2
        x2 = boxes[i + 1][0] - 1.2
        y = 2
        ax.annotate('', xy=(x2, y), xytext=(x1, y),
                   arrowprops=arrow_props)

    # Labels on arrows
    arrow_labels = [
        'count\nactive', 'Möbius\ninversion', 'extract\nintervals', 'graph\ngadget'
    ]
    for i, label in enumerate(arrow_labels):
        x = (boxes[i][0] + boxes[i + 1][0]) / 2
        ax.text(x, 2.7, label, ha='center', va='bottom',
               fontsize=9, style='italic', color='#616161')

    # Theorem labels
    thm_labels = [
        (2, 0.5, 'Theorem C', '#1565C0'),
        (5, 0.5, 'Theorem A', '#E65100'),
        (8, 0.5, 'Theorem A', '#2E7D32'),
        (11, 0.5, 'Theorem B', '#6A1B9A'),
    ]
    for x, y, label, color in thm_labels:
        ax.text(x, y, label, ha='center', va='center',
               fontsize=10, fontweight='bold', color=color,
               bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                        edgecolor=color, linewidth=1.5))

    ax.set_xlim(-1, 14.5)
    ax.set_ylim(-0.5, 4)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Certified Reconstruction Pipeline',
                fontsize=16, fontweight='bold')

    return fig


# ═══════════════════════════════════════════════════════════════════
# Main: Generate all figures
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = create_barcode_diagram()
    fig1.savefig('barcode_diagram.png', dpi=150, bbox_inches='tight')
    print("  ✓ barcode_diagram.png")

    fig2 = create_rank_heatmap()
    fig2.savefig('rank_heatmap.png', dpi=150, bbox_inches='tight')
    print("  ✓ rank_heatmap.png")

    fig3 = create_mobius_matrix()
    fig3.savefig('mobius_recovery.png', dpi=150, bbox_inches='tight')
    print("  ✓ mobius_recovery.png")

    fig4 = create_filtration_evolution()
    fig4.savefig('filtration_evolution.png', dpi=150, bbox_inches='tight')
    print("  ✓ filtration_evolution.png")

    fig5 = create_pipeline_diagram()
    fig5.savefig('pipeline_diagram.png', dpi=150, bbox_inches='tight')
    print("  ✓ pipeline_diagram.png")

    print("\nAll visualizations generated successfully!")
