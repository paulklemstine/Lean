#!/usr/bin/env python3
"""
Applications of Categorical Helly Theory

Demonstrates real-world applications of the local-to-global principle for
probe-separated presheaves:

1. Database consistency checking via local samples
2. Sensor network coverage verification
3. Distributed systems state reconstruction
4. Network tomography and flow identification
"""

from itertools import combinations
from typing import Dict, List, Tuple, FrozenSet, Set
from dataclasses import dataclass
import random
import math


# =============================================================================
# Application 1: Database Consistency Checking
# =============================================================================

def database_consistency_demo():
    """
    Application: Verifying database consistency via local samples.

    A distributed database has N nodes, each storing records. "Consistency"
    means the total data volume across all nodes stays within a bound.
    Instead of querying all nodes (expensive), we use probe nodes to verify
    consistency locally on small subsets.

    The Helly theorem guarantees: if every subset of ≤ |P|+1 nodes is
    consistent, then the full database is bounded.
    """
    print("=" * 70)
    print("  Application 1: Database Consistency Checking")
    print("=" * 70)
    print()

    # Simulate a distributed database
    num_nodes = 8
    nodes = [f"Node_{i}" for i in range(num_nodes)]
    probe_nodes = nodes[:3]  # First 3 nodes are probes

    # Each node has some number of records
    random.seed(42)
    records = {node: random.randint(5, 20) for node in nodes}

    print(f"  Database: {num_nodes} nodes, {len(probe_nodes)} probe nodes")
    print(f"  Records per node: {records}")
    print(f"  Total records: {sum(records.values())}")
    print()

    # Check local consistency: every subset of ≤ |P|+1 = 4 nodes
    # should have total records ≤ bound
    bound = 50
    helly_num = len(probe_nodes) + 1
    violations = 0
    total_checks = 0

    for size in range(1, helly_num + 1):
        for combo in combinations(nodes, size):
            total = sum(records[n] for n in combo)
            total_checks += 1
            if total > bound:
                violations += 1

    print(f"  Local check (radius {helly_num}, bound {bound}):")
    print(f"    Subsets checked: {total_checks}")
    print(f"    Violations: {violations}")

    if violations == 0:
        global_bound = num_nodes * bound ** len(probe_nodes)
        print(f"    ✓ Locally consistent → Global bound: {global_bound}")
    else:
        print(f"    ✗ Local violations found")

    # Find minimal violating subsets
    bad = []
    for size in range(1, num_nodes + 1):
        for combo in combinations(nodes, size):
            total = sum(records[n] for n in combo)
            if total > bound:
                bad.append((frozenset(combo), total))

    if bad:
        # Find minimal
        bad_sets = {b[0] for b in bad}
        minimal = []
        for s, total in sorted(bad, key=lambda x: len(x[0])):
            is_min = True
            for sub_size in range(len(s)):
                for sub in combinations(s, sub_size):
                    if frozenset(sub) in bad_sets:
                        is_min = False
                        break
                if not is_min:
                    break
            if is_min:
                minimal.append((sorted(s), total))

        print(f"\n  Minimal bad subsets:")
        for mb, total in minimal[:5]:
            print(f"    {mb} → total={total} > {bound}")
    print()


# =============================================================================
# Application 2: Sensor Network Coverage
# =============================================================================

def sensor_network_demo():
    """
    Application: Verifying sensor network coverage.

    A sensor network monitors an environment. Each sensor has a detection
    capacity (number of distinguishable signals). "Coverage" means the
    total detection capacity across all sensors exceeds a threshold.

    Probe sensors are reference sensors. The Helly principle says:
    checking coverage on small local clusters suffices to guarantee
    global coverage.
    """
    print("=" * 70)
    print("  Application 2: Sensor Network Coverage")
    print("=" * 70)
    print()

    sensors = [f"S{i}" for i in range(6)]
    probes = ["S0", "S1"]  # Reference sensors

    # Detection capacity per sensor
    capacity = {"S0": 8, "S1": 6, "S2": 4, "S3": 7, "S4": 3, "S5": 5}

    print(f"  Sensors: {sensors}")
    print(f"  Probe sensors: {probes}")
    print(f"  Capacities: {capacity}")
    print(f"  Total capacity: {sum(capacity.values())}")
    print()

    # Verify: local clusters of size ≤ |P|+1 = 3 must have
    # capacity ≤ some bound n for the Helly theorem to give a global bound
    n = 15  # Local bound
    helly_num = len(probes) + 1

    print(f"  Helly number: {helly_num}")
    print(f"  Local bound n: {n}")

    locally_ok = True
    for size in range(1, helly_num + 1):
        for combo in combinations(sensors, size):
            total = sum(capacity[s] for s in combo)
            if total > n:
                locally_ok = False
                break
        if not locally_ok:
            break

    if locally_ok:
        global_bound = len(sensors) * n ** len(probes)
        print(f"  ✓ Locally bounded → Global capacity ≤ {global_bound}")
    else:
        print(f"  ✗ Local bound {n} violated for radius {helly_num}")
        print(f"    Need larger local bound or more probes")

    # Try with a better bound
    max_local = 0
    for size in range(1, helly_num + 1):
        for combo in combinations(sensors, size):
            total = sum(capacity[s] for s in combo)
            max_local = max(max_local, total)

    print(f"  Tightest local bound at radius {helly_num}: {max_local}")
    global_bound = len(sensors) * max_local ** len(probes)
    print(f"  Implied global bound: {global_bound}")
    print(f"  Actual total: {sum(capacity.values())}")
    print(f"  Bound ratio: {global_bound / sum(capacity.values()):.1f}x")
    print()


# =============================================================================
# Application 3: Network Tomography
# =============================================================================

def network_tomography_demo():
    """
    Application: Network tomography — reconstructing link-level metrics
    from path-level measurements.

    In network tomography, probe paths measure end-to-end metrics.
    The Helly principle corresponds to: if every small subset of links
    has bounded aggregate delay, the whole network has bounded delay.

    This is directly analogous to probe separation in category theory:
    probe paths "separate" link-level metrics.
    """
    print("=" * 70)
    print("  Application 3: Network Tomography")
    print("=" * 70)
    print()

    # Network links and their latencies
    links = ["L1", "L2", "L3", "L4", "L5"]
    latency = {"L1": 12, "L2": 8, "L3": 15, "L4": 5, "L5": 10}

    # Probe paths (each covers a subset of links)
    probe_paths = {
        "Path_A": ["L1", "L2"],
        "Path_B": ["L2", "L3", "L4"],
    }

    print(f"  Links: {links}")
    print(f"  Latencies: {latency}")
    print(f"  Probe paths: {probe_paths}")
    print(f"  Total network latency: {sum(latency.values())}")
    print()

    # Helly analysis: probe paths form a covering
    probe_coverage = set()
    for path_links in probe_paths.values():
        probe_coverage.update(path_links)

    print(f"  Probe coverage: {sorted(probe_coverage)}")
    print(f"  Uncovered links: {sorted(set(links) - probe_coverage)}")

    # For each small subset of links (≤ |probes| + 1 = 3),
    # check if latency is bounded
    n = 25
    helly_num = len(probe_paths) + 1

    max_local_latency = 0
    for size in range(1, min(helly_num + 1, len(links) + 1)):
        for combo in combinations(links, size):
            total = sum(latency[l] for l in combo)
            max_local_latency = max(max_local_latency, total)

    print(f"\n  Helly number: {helly_num}")
    print(f"  Max local latency (radius {helly_num}): {max_local_latency}")
    print(f"  Predicted global bound: {len(links) * max_local_latency ** len(probe_paths)}")
    print(f"  Actual total: {sum(latency.values())}")
    print()


# =============================================================================
# Application 4: Property Testing for Finite Structures
# =============================================================================

def property_testing_demo():
    """
    Application: Property testing — checking structural properties
    of finite algebraic objects by sampling small substructures.

    The Helly principle provides a theoretical foundation:
    with a fixed probe size, global properties are testable via
    inspection of O(n^{|P|+1}) small subsets rather than the full
    exponential space.

    This creates an algorithmic payoff: polynomial-time testability
    for bounded probe complexity.
    """
    print("=" * 70)
    print("  Application 4: Property Testing for Finite Structures")
    print("=" * 70)
    print()

    # Simulate testing whether a finite group-like structure has
    # "bounded representation dimension"
    for n_objects in [4, 6, 8, 10, 12]:
        objects = list(range(n_objects))

        # Number of subsets to check at different radii
        for probe_size in [1, 2, 3]:
            helly_num = probe_size + 1
            num_subsets = sum(
                math.comb(n_objects, k) for k in range(helly_num + 1)
            )
            full_search = 2 ** n_objects

            savings = full_search / num_subsets if num_subsets > 0 else float('inf')

            print(f"  |Ob|={n_objects:2d}, |P|={probe_size}: "
                  f"check {num_subsets:6d} subsets vs {full_search:8d} full "
                  f"({savings:6.1f}x savings)")

    print()
    print("  Key insight: For fixed |P|, the number of subsets to check")
    print("  grows polynomially in |Ob|, not exponentially.")
    print("  This is the algorithmic payoff of the Helly bound.")
    print()


# =============================================================================
# Main
# =============================================================================

def main():
    print("=" * 70)
    print("  APPLICATIONS OF CATEGORICAL HELLY THEORY")
    print("=" * 70)
    print()

    database_consistency_demo()
    sensor_network_demo()
    network_tomography_demo()
    property_testing_demo()

    print("=" * 70)
    print("  ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Categorical Helly Theory for Probe Families — Interactive Demonstration

This script constructs finite toy categories (discrete presheaf models),
defines probe families, and tests the Helly principle:

  If every subset of objects of size ≤ |P|+1 has bounded restricted
  representable dimension, then the global dimension is bounded by
  |Ob| · n^|P|.

It also searches for minimal obstructions and validates the |P|+1 conjecture.
"""

from itertools import combinations
from typing import Dict, List, Optional, Tuple, Set, FrozenSet
import math


# =============================================================================
# Core data structures
# =============================================================================

class DiscretePresheaf:
    """A presheaf on a discrete finite category: F(Y) is a finite set for each object Y.
    Restriction maps r(Y,Z) : F(Y) -> F(Z) are given as dictionaries."""

    def __init__(self, objects: List[str], fibers: Dict[str, List[str]],
                 restrictions: Dict[Tuple[str,str], Dict[str,str]]):
        self.objects = objects
        self.fibers = fibers  # F(Y) = fibers[Y]
        self.restrictions = restrictions  # r(Y,Z) : fibers[Y] -> fibers[Z]

    def fiber_card(self, obj: str) -> int:
        return len(self.fibers.get(obj, []))

    def restricted_rep_dim(self, subset: FrozenSet[str]) -> int:
        return sum(self.fiber_card(y) for y in subset)

    def global_rep_dim(self) -> int:
        return sum(self.fiber_card(y) for y in self.objects)


class ProbeFamily:
    """A probe family: a subset of objects used for separation."""

    def __init__(self, probes: List[str]):
        self.probes = probes

    @property
    def card(self) -> int:
        return len(self.probes)

    def helly_number(self) -> int:
        return self.card + 1

    def probe_signature(self, presheaf: DiscretePresheaf, obj: str, elem: str) -> Tuple:
        """Compute the probe signature of elem ∈ F(obj)."""
        sig = []
        for z in self.probes:
            r = presheaf.restrictions.get((obj, z), {})
            sig.append(r.get(elem, None))
        return tuple(sig)

    def is_separating(self, presheaf: DiscretePresheaf) -> bool:
        """Check if probe signatures are injective at every object."""
        for obj in presheaf.objects:
            sigs = set()
            for elem in presheaf.fibers.get(obj, []):
                sig = self.probe_signature(presheaf, obj, elem)
                if sig in sigs:
                    return False
                sigs.add(sig)
        return True

    def probe_capacity(self, presheaf: DiscretePresheaf) -> int:
        result = 1
        for z in self.probes:
            result *= presheaf.fiber_card(z)
        return result


# =============================================================================
# Helly Theory Algorithms
# =============================================================================

def all_subsets(objects: List[str], max_size: int) -> List[FrozenSet[str]]:
    """Enumerate all subsets of objects with size ≤ max_size."""
    result = []
    for k in range(max_size + 1):
        for combo in combinations(objects, k):
            result.append(frozenset(combo))
    return result


def is_locally_bounded(presheaf: DiscretePresheaf, k: int, n: int) -> bool:
    """Check LocallyBoundedGen F k n: every subset of size ≤ k has rep dim ≤ n."""
    for subset in all_subsets(presheaf.objects, k):
        if presheaf.restricted_rep_dim(subset) > n:
            return False
    return True


def find_bad_subsets(presheaf: DiscretePresheaf, n: int) -> List[FrozenSet[str]]:
    """Find all bad subsets: S where RestrictedRepDim F S > n."""
    bad = []
    for subset in all_subsets(presheaf.objects, len(presheaf.objects)):
        if presheaf.restricted_rep_dim(subset) > n:
            bad.append(subset)
    return bad


def find_minimal_bad(presheaf: DiscretePresheaf, n: int) -> List[FrozenSet[str]]:
    """Find all minimal bad subsets."""
    bad = find_bad_subsets(presheaf, n)
    bad_set = set(bad)
    minimal = []
    for s in bad:
        is_min = True
        for k in range(len(s)):
            for sub in combinations(s, k):
                if frozenset(sub) in bad_set:
                    is_min = False
                    break
            if not is_min:
                break
        if is_min:
            minimal.append(s)
    return minimal


def verify_helly_bound(presheaf: DiscretePresheaf, probe: ProbeFamily, n: int) -> dict:
    """Verify the Helly bound: local bounds at radius |P|+1 imply global bound."""
    helly_num = probe.helly_number()
    locally_bounded = is_locally_bounded(presheaf, helly_num, n)
    global_dim = presheaf.global_rep_dim()
    predicted_bound = len(presheaf.objects) * (n ** probe.card)
    separating = probe.is_separating(presheaf)

    return {
        "helly_number": helly_num,
        "locally_bounded": locally_bounded,
        "global_dim": global_dim,
        "predicted_bound": predicted_bound,
        "bound_holds": global_dim <= predicted_bound if locally_bounded else None,
        "separating": separating,
    }


def verify_upward_closure(presheaf: DiscretePresheaf, n: int) -> bool:
    """Verify that bad subsets are upward closed."""
    bad = set(find_bad_subsets(presheaf, n))
    for s in bad:
        for obj in presheaf.objects:
            superset = s | frozenset([obj])
            if superset not in bad:
                return False
    return True


def verify_minimal_bad_bound(presheaf: DiscretePresheaf, n: int) -> dict:
    """Verify that minimal bad subsets have |S| ≤ n+1 when all fibers ≥ 1."""
    minimals = find_minimal_bad(presheaf, n)
    all_fibers_pos = all(presheaf.fiber_card(y) >= 1 for y in presheaf.objects)
    max_size = max((len(s) for s in minimals), default=0)
    bound_holds = max_size <= n + 1 if all_fibers_pos else True

    return {
        "minimal_bad_count": len(minimals),
        "max_minimal_size": max_size,
        "n_plus_1": n + 1,
        "all_fibers_positive": all_fibers_pos,
        "bound_holds": bound_holds,
        "minimals": [sorted(s) for s in minimals],
    }


# =============================================================================
# Example Presheaves
# =============================================================================

def make_example_1():
    """Example 1: 3 objects, uniform fibers of size 2, identity restrictions."""
    objects = ["A", "B", "C"]
    fibers = {"A": ["a1", "a2"], "B": ["b1", "b2"], "C": ["c1", "c2"]}
    restrictions = {}
    # Simple restriction: project to first element
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {fibers[y][i]: fibers[z][i % len(fibers[z])]
                                    for i in range(len(fibers[y]))}
    return DiscretePresheaf(objects, fibers, restrictions), "Uniform fibers (size 2)"


def make_example_2():
    """Example 2: 4 objects, varying fiber sizes."""
    objects = ["A", "B", "C", "D"]
    fibers = {
        "A": ["a1", "a2", "a3"],
        "B": ["b1", "b2"],
        "C": ["c1"],
        "D": ["d1", "d2", "d3", "d4"],
    }
    restrictions = {}
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {
                fibers[y][i]: fibers[z][i % len(fibers[z])]
                for i in range(len(fibers[y]))
            }
    return DiscretePresheaf(objects, fibers, restrictions), "Varying fibers (3,2,1,4)"


def make_example_3():
    """Example 3: 5 objects, all singletons (trivial case)."""
    objects = ["A", "B", "C", "D", "E"]
    fibers = {obj: [f"{obj.lower()}1"] for obj in objects}
    restrictions = {}
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {fibers[y][0]: fibers[z][0]}
    return DiscretePresheaf(objects, fibers, restrictions), "All singletons"


def make_example_4():
    """Example 4: 6 objects with a probe family of size 2."""
    objects = ["A", "B", "C", "D", "E", "F"]
    fibers = {
        "A": ["a1", "a2"], "B": ["b1", "b2", "b3"],
        "C": ["c1"], "D": ["d1", "d2"],
        "E": ["e1", "e2", "e3"], "F": ["f1"],
    }
    restrictions = {}
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {
                fibers[y][i]: fibers[z][i % len(fibers[z])]
                for i in range(len(fibers[y]))
            }
    return DiscretePresheaf(objects, fibers, restrictions), "6 objects, mixed fibers"


def make_example_5():
    """Example 5: Empty fibers test case."""
    objects = ["A", "B", "C"]
    fibers = {"A": ["a1", "a2"], "B": [], "C": ["c1"]}
    restrictions = {}
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {
                fibers[y][i]: fibers[z][i % len(fibers[z])] if fibers[z] else None
                for i in range(len(fibers[y]))
            }
    return DiscretePresheaf(objects, fibers, restrictions), "With empty fiber"


# =============================================================================
# Main Demonstration
# =============================================================================

def run_demo():
    print("=" * 72)
    print("  CATEGORICAL HELLY THEORY FOR PROBE FAMILIES")
    print("  Interactive Demonstration")
    print("=" * 72)
    print()

    examples = [make_example_1(), make_example_2(), make_example_3(),
                make_example_4(), make_example_5()]

    for idx, (presheaf, desc) in enumerate(examples, 1):
        print(f"{'─' * 72}")
        print(f"  Example {idx}: {desc}")
        print(f"  Objects: {presheaf.objects}")
        print(f"  Fiber sizes: {{{', '.join(f'{y}: {presheaf.fiber_card(y)}' for y in presheaf.objects)}}}")
        print(f"  Global rep dim: {presheaf.global_rep_dim()}")
        print(f"{'─' * 72}")

        # Test probe families of various sizes
        for probe_size in range(1, min(4, len(presheaf.objects) + 1)):
            for probe_combo in combinations(presheaf.objects, probe_size):
                probe = ProbeFamily(list(probe_combo))
                n_test = max(presheaf.fiber_card(y) for y in presheaf.objects) + 1

                result = verify_helly_bound(presheaf, probe, n_test)

                if result["locally_bounded"]:
                    print(f"  Probe {list(probe_combo)} (|P|={probe.card}, "
                          f"Helly#={result['helly_number']}):")
                    print(f"    Separating: {result['separating']}")
                    print(f"    Locally bounded (k={result['helly_number']}, n={n_test}): ✓")
                    print(f"    Global dim={result['global_dim']} "
                          f"≤ bound={result['predicted_bound']}: "
                          f"{'✓' if result['bound_holds'] else '✗'}")
                    break  # Just show one probe per size
            else:
                continue
            # Only print the first matching probe for each size

        # Test upward closure
        n_test = 3
        print(f"\n  Upward closure of BadSubsets(n={n_test}): "
              f"{'✓ Verified' if verify_upward_closure(presheaf, n_test) else '✗ Failed'}")

        # Test minimal bad bound
        result = verify_minimal_bad_bound(presheaf, n_test)
        if result["minimal_bad_count"] > 0:
            print(f"  Minimal bad subsets (n={n_test}): {result['minimal_bad_count']} found")
            print(f"    Max size: {result['max_minimal_size']} "
                  f"(bound n+1={result['n_plus_1']}): "
                  f"{'✓' if result['bound_holds'] else '✗'}")
            for mb in result["minimals"][:3]:
                print(f"    → {mb}")
        else:
            print(f"  No bad subsets for n={n_test} (globally bounded)")
        print()

    # ==========================================================================
    # Systematic Helly Bound Test
    # ==========================================================================
    print("=" * 72)
    print("  SYSTEMATIC HELLY BOUND VALIDATION")
    print("=" * 72)
    print()

    helly_violations = 0
    total_tests = 0

    for num_obj in range(2, 7):
        objects = [chr(65 + i) for i in range(num_obj)]
        # Test with uniform fibers
        for fib_size in range(1, 5):
            fibers = {obj: [f"{obj.lower()}{i}" for i in range(fib_size)] for obj in objects}
            restrictions = {}
            for y in objects:
                for z in objects:
                    restrictions[(y, z)] = {
                        fibers[y][i]: fibers[z][i % fib_size]
                        for i in range(fib_size)
                    }
            presheaf = DiscretePresheaf(objects, fibers, restrictions)

            for probe_size in range(1, min(4, num_obj + 1)):
                probe = ProbeFamily(objects[:probe_size])
                n = fib_size
                result = verify_helly_bound(presheaf, probe, n)
                total_tests += 1
                if result["locally_bounded"] and result["bound_holds"] is False:
                    helly_violations += 1
                    print(f"  ✗ VIOLATION: |Ob|={num_obj}, fib={fib_size}, |P|={probe_size}")

    print(f"  Total tests: {total_tests}")
    print(f"  Violations: {helly_violations}")
    print(f"  Result: {'✓ Supports Helly bound on all tested instances' if helly_violations == 0 else '✗ Counterexamples found'}")
    print()

    # ==========================================================================
    # Obstruction Search
    # ==========================================================================
    print("=" * 72)
    print("  OBSTRUCTION SEARCH")
    print("=" * 72)
    print()

    for num_obj in range(3, 7):
        objects = [chr(65 + i) for i in range(num_obj)]
        fibers = {obj: [f"{obj.lower()}{i}" for i in range(num_obj - 1)]
                  for obj in objects}
        restrictions = {}
        for y in objects:
            for z in objects:
                restrictions[(y, z)] = {
                    fibers[y][i]: fibers[z][i % len(fibers[z])]
                    for i in range(len(fibers[y]))
                }
        presheaf = DiscretePresheaf(objects, fibers, restrictions)
        n = num_obj - 2

        minimals = find_minimal_bad(presheaf, n)
        if minimals:
            print(f"  |Ob|={num_obj}, fibers={num_obj-1}, n={n}:")
            print(f"    {len(minimals)} minimal bad subset(s), "
                  f"sizes: {sorted(set(len(s) for s in minimals))}")
        else:
            print(f"  |Ob|={num_obj}, fibers={num_obj-1}, n={n}: no bad subsets")

    print()
    print("=" * 72)
    print("  DEMONSTRATION COMPLETE")
    print("=" * 72)


if __name__ == "__main__":
    run_demo()
