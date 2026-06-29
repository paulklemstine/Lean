#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Compression Stability Theory

Demonstrates how the categorical data processing inequality and
measurement rigidity theorem apply to concrete domains:

1. Sensor placement optimization
2. Feature selection in machine learning
3. Statistical sufficient statistics
4. Signal sampling resolution
"""

from algorithms import (
    FinitePresheaf,
    compute_measurement_invariant,
    compute_partition,
    check_no_new_separation,
    verify_compression_stability,
)
from itertools import combinations


# ─────────────────────────────────────────────────────────────────────────────
# Application 1: Sensor Placement Optimization
# ─────────────────────────────────────────────────────────────────────────────

def sensor_placement_demo():
    """Model a sensor network as a presheaf and optimize sensor placement.

    Scenario: A factory floor has 3 zones (objects). Each zone has several
    possible states (presheaf elements). Sensors placed in a zone can
    detect states in other zones via signal propagation (restriction maps).

    Question: What is the minimum number of sensors needed to distinguish
    all possible states? When does adding a sensor help vs. being redundant?
    """
    print("=" * 70)
    print("APPLICATION 1: Sensor Placement Optimization")
    print("=" * 70)
    print()
    print("Scenario: Factory floor with 3 zones, each with multiple states.")
    print("Sensors in one zone detect states in others via signal propagation.")
    print()

    presheaf = FinitePresheaf(
        objects=['zone1', 'zone2', 'zone3'],
        fibers={
            'zone1': ['normal', 'warning', 'critical', 'shutdown'],
            'zone2': ['idle', 'running', 'overload'],
            'zone3': ['cold', 'warm', 'hot'],
        },
        restrictions={
            ('zone1', 'zone1'): {s: s for s in ['normal', 'warning', 'critical', 'shutdown']},
            ('zone1', 'zone2'): {'normal': 'idle', 'warning': 'running',
                                  'critical': 'overload', 'shutdown': 'idle'},
            ('zone1', 'zone3'): {'normal': 'cold', 'warning': 'warm',
                                  'critical': 'hot', 'shutdown': 'cold'},
            ('zone2', 'zone1'): {'idle': 'normal', 'running': 'warning', 'overload': 'critical'},
            ('zone2', 'zone2'): {s: s for s in ['idle', 'running', 'overload']},
            ('zone2', 'zone3'): {'idle': 'cold', 'running': 'warm', 'overload': 'hot'},
            ('zone3', 'zone1'): {'cold': 'normal', 'warm': 'warning', 'hot': 'critical'},
            ('zone3', 'zone2'): {'cold': 'idle', 'warm': 'running', 'hot': 'overload'},
            ('zone3', 'zone3'): {s: s for s in ['cold', 'warm', 'hot']},
        }
    )

    zones = presheaf.objects
    print("Analysis of sensor placement strategies:")
    print()

    best_single = None
    best_single_mi = 0

    for size in range(len(zones) + 1):
        for subset in combinations(zones, size):
            s = set(subset)
            mi = compute_measurement_invariant(presheaf, s)
            label = sorted(s) if s else '∅'

            # Check if separating
            is_sep = all(
                len(compute_partition(presheaf, s, y)) == len(presheaf.fibers[y])
                for y in zones
            )

            sep_str = " [SEPARATING]" if is_sep else ""
            print(f"  Sensors at {str(label):>35s}: μ = {mi}{sep_str}")

            if len(s) == 1 and mi > best_single_mi:
                best_single = s
                best_single_mi = mi

    print()
    print(f"Best single sensor: {best_single} (μ = {best_single_mi})")

    # Analyze redundancy
    print()
    print("Redundancy analysis:")
    for s1 in combinations(zones, 1):
        s1 = set(s1)
        for z in zones:
            if z not in s1:
                s2 = s1 | {z}
                is_redundant, new_seps = check_no_new_separation(presheaf, s1, s2)
                if is_redundant:
                    print(f"  Adding {z} to {sorted(s1)} is REDUNDANT")
                else:
                    print(f"  Adding {z} to {sorted(s1)} creates {len(new_seps)} new separations")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Application 2: Feature Selection in Machine Learning
# ─────────────────────────────────────────────────────────────────────────────

def feature_selection_demo():
    """Model feature selection as probe family selection.

    Each "object" is a data point class, each "element" is a data instance,
    and each "probe" is a feature. The measurement invariant measures
    discriminative power.
    """
    print("=" * 70)
    print("APPLICATION 2: Feature Selection for Classification")
    print("=" * 70)
    print()
    print("Model: Objects = sample groups, Elements = instances,")
    print("       Probes = features, Signatures = feature vectors.")
    print()

    # 3 classes, each with several instances
    # Features are measurements that map instances to discrete values
    presheaf = FinitePresheaf(
        objects=['cat', 'dog', 'bird'],
        fibers={
            'cat': ['persian', 'siamese', 'tabby'],
            'dog': ['labrador', 'poodle'],
            'bird': ['eagle', 'sparrow', 'penguin'],
        },
        restrictions={
            # Feature "size": maps each animal to a size category
            ('cat', 'cat'): {'persian': 'persian', 'siamese': 'siamese', 'tabby': 'tabby'},
            ('cat', 'dog'): {'persian': 'poodle', 'siamese': 'poodle', 'tabby': 'labrador'},
            ('cat', 'bird'): {'persian': 'sparrow', 'siamese': 'sparrow', 'tabby': 'sparrow'},
            ('dog', 'cat'): {'labrador': 'tabby', 'poodle': 'siamese'},
            ('dog', 'dog'): {'labrador': 'labrador', 'poodle': 'poodle'},
            ('dog', 'bird'): {'labrador': 'eagle', 'poodle': 'sparrow'},
            ('bird', 'cat'): {'eagle': 'persian', 'sparrow': 'siamese', 'penguin': 'tabby'},
            ('bird', 'dog'): {'eagle': 'labrador', 'sparrow': 'poodle', 'penguin': 'labrador'},
            ('bird', 'bird'): {'eagle': 'eagle', 'sparrow': 'sparrow', 'penguin': 'penguin'},
        }
    )

    classes = presheaf.objects
    features = classes  # In this model, probes correspond to feature groups

    print("Feature discriminative power (measurement invariant):")
    for size in range(len(features) + 1):
        for subset in combinations(features, size):
            s = set(subset)
            mi = compute_measurement_invariant(presheaf, s)
            total = presheaf.total_card()
            pct = (mi / total * 100) if total > 0 else 0
            label = sorted(s) if s else 'none'
            print(f"  Features {str(label):>25s}: μ = {mi}/{total} ({pct:.0f}% resolution)")
    print()

    # Show partitions for each feature set at each class
    print("Partition refinement by class:")
    for y in classes:
        print(f"  Class '{y}': instances = {presheaf.fibers[y]}")
        for size in range(len(features) + 1):
            for subset in combinations(features, size):
                s = set(subset)
                part = compute_partition(presheaf, s, y)
                label = sorted(s) if s else 'none'
                print(f"    Features {str(label):>20s}: {part}")
        print()


# ─────────────────────────────────────────────────────────────────────────────
# Application 3: Statistical Sufficient Statistics
# ─────────────────────────────────────────────────────────────────────────────

def sufficient_statistics_demo():
    """Demonstrate the connection to sufficient statistics.

    If T(X) is a sufficient statistic for parameter θ, then the probe
    family consisting only of T has the same measurement invariant as
    the full data X. This is exactly our redundancy theorem.
    """
    print("=" * 70)
    print("APPLICATION 3: Sufficient Statistics Detection")
    print("=" * 70)
    print()
    print("Testing which statistics are sufficient (i.e., redundant over the full data).")
    print()

    # Simple model: 2 parameter values, data takes several possible values
    presheaf = FinitePresheaf(
        objects=['theta0', 'theta1'],
        fibers={
            'theta0': ['d1', 'd2', 'd3', 'd4'],
            'theta1': ['d1', 'd2', 'd3', 'd4'],
        },
        restrictions={
            ('theta0', 'theta0'): {'d1': 'd1', 'd2': 'd2', 'd3': 'd3', 'd4': 'd4'},
            ('theta0', 'theta1'): {'d1': 'd1', 'd2': 'd2', 'd3': 'd3', 'd4': 'd4'},
            ('theta1', 'theta0'): {'d1': 'd1', 'd2': 'd1', 'd3': 'd3', 'd4': 'd3'},
            ('theta1', 'theta1'): {'d1': 'd1', 'd2': 'd2', 'd3': 'd3', 'd4': 'd4'},
        }
    )

    # theta0 observes everything; theta1 collapses d1≡d2 and d3≡d4
    full_probes = {'theta0', 'theta1'}
    single_theta0 = {'theta0'}
    single_theta1 = {'theta1'}

    mi_full = compute_measurement_invariant(presheaf, full_probes)
    mi_t0 = compute_measurement_invariant(presheaf, single_theta0)
    mi_t1 = compute_measurement_invariant(presheaf, single_theta1)

    print(f"  Full observation μ({{θ₀, θ₁}}) = {mi_full}")
    print(f"  Statistic θ₀ only: μ({{θ₀}}) = {mi_t0}", end="")
    r0, _ = check_no_new_separation(presheaf, single_theta0, full_probes)
    print(f"  {'→ SUFFICIENT (redundant)' if r0 else '→ NOT sufficient'}")

    print(f"  Statistic θ₁ only: μ({{θ₁}}) = {mi_t1}", end="")
    r1, _ = check_no_new_separation(presheaf, single_theta1, full_probes)
    print(f"  {'→ SUFFICIENT (redundant)' if r1 else '→ NOT sufficient'}")

    print()
    print("Partition structure:")
    for y in presheaf.objects:
        print(f"  Parameter {y}:")
        for probes, name in [(full_probes, "full"), (single_theta0, "θ₀"), (single_theta1, "θ₁")]:
            part = compute_partition(presheaf, probes, y)
            print(f"    {name:>6s}: {part}")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Application 4: Signal Sampling Resolution
# ─────────────────────────────────────────────────────────────────────────────

def sampling_resolution_demo():
    """Demonstrate the connection to signal sampling.

    More sample points (probes) give finer signal resolution.
    Redundant sample points are those that don't improve resolution.
    """
    print("=" * 70)
    print("APPLICATION 4: Signal Sampling Resolution Analysis")
    print("=" * 70)
    print()
    print("Model: Discretized signal with multiple sample points.")
    print("Each sample point observes the signal through a measurement map.")
    print()

    # Signal takes values at 4 time points, observed through sampling
    presheaf = FinitePresheaf(
        objects=['t0', 't1', 't2', 't3'],
        fibers={
            't0': ['lo', 'mid', 'hi'],
            't1': ['lo', 'mid', 'hi'],
            't2': ['lo', 'mid', 'hi'],
            't3': ['lo', 'mid', 'hi'],
        },
        restrictions={
            (t1, t2): ({'lo': 'lo', 'mid': 'mid', 'hi': 'hi'} if t1 == t2
                       else {'lo': 'lo', 'mid': 'lo', 'hi': 'mid'})
            for t1 in ['t0', 't1', 't2', 't3']
            for t2 in ['t0', 't1', 't2', 't3']
        }
    )

    sample_points = presheaf.objects
    print("Sampling strategies and resolution:")
    for size in range(len(sample_points) + 1):
        for subset in combinations(sample_points, size):
            s = set(subset)
            mi = compute_measurement_invariant(presheaf, s)
            label = sorted(s) if s else 'none'
            print(f"  Samples at {str(label):>25s}: resolution = {mi}")
    print()

    # Find minimal separating sets
    print("Minimal separating sample sets:")
    found_min = False
    for size in range(1, len(sample_points) + 1):
        for subset in combinations(sample_points, size):
            s = set(subset)
            is_sep = all(
                len(compute_partition(presheaf, s, y)) == len(presheaf.fibers[y])
                for y in sample_points
            )
            if is_sep:
                # Check minimality: no proper subset is separating
                is_minimal = True
                for elem in s:
                    smaller = s - {elem}
                    is_sep_smaller = all(
                        len(compute_partition(presheaf, smaller, y)) == len(presheaf.fibers[y])
                        for y in sample_points
                    )
                    if is_sep_smaller:
                        is_minimal = False
                        break
                if is_minimal:
                    print(f"  {sorted(s)} (size {len(s)})")
                    found_min = True
        if found_min:
            break
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Applications of Compression Stability Theory                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    sensor_placement_demo()
    feature_selection_demo()
    sufficient_statistics_demo()
    sampling_resolution_demo()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Build PACKAGE.json from the individual deliverable files."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Pythagorean/ProbeComplexity/CompressionStability.lean')

package = {
    "title": "Compression Stability Under Probe Enlargement: A Categorical Data Processing Inequality",
    "domain": "Category Theory / Information Theory / Probe Complexity",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Compression Stability Interactive Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Measurement Invariant Computation",
            "pseudocode": (
                "Algorithm ComputeMeasurementInvariant(Ob, F, r, P):\n"
                "    total ← 0\n"
                "    for each Y ∈ Ob:\n"
                "        signatures ← {}\n"
                "        for each x ∈ F(Y):\n"
                "            sig ← (r(Y, Z)(x) for Z ∈ P)\n"
                "            signatures.add(sig)\n"
                "        total ← total + |signatures|\n"
                "    return total\n"
                "\n"
                "Complexity: O(Σ_Y |F(Y)| · |P|) time, O(max_Y |F(Y)|) space."
            ),
            "code": algorithms_code
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json built successfully.")


#!/usr/bin/env python3
"""
demo.py — Interactive Demonstration of Compression Stability Under Probe Enlargement

Demonstrates the categorical data processing inequality: enlarging a probe family
can only increase the measurement invariant, with equality iff no new separations
are created.
"""

from itertools import product, combinations
from collections import defaultdict
import json


# ─────────────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────────────

class FinitePresheaf:
    """A presheaf on a discrete finite category is just a family of finite sets
    with restriction maps r(Y, Z) : F(Y) → F(Z)."""

    def __init__(self, fibers: dict, restrictions: dict):
        """
        fibers: {object: [elements]}
        restrictions: {(Y, Z): {elem_of_FY: elem_of_FZ}}
        """
        self.objects = sorted(fibers.keys())
        self.fibers = fibers
        self.restrictions = restrictions

    def restrict(self, y, z, x):
        """Apply restriction map r(y, z) to element x of F(y)."""
        return self.restrictions[(y, z)][x]


def probe_signature(presheaf, probe_family, y, x):
    """Compute the probe signature of element x at object y.
    Returns a tuple of restriction values for each probe object."""
    return tuple(presheaf.restrict(y, z, x) for z in sorted(probe_family))


def measurement_space_image_card(presheaf, probe_family, y):
    """Count distinct probe signatures at object y."""
    sigs = set()
    for x in presheaf.fibers[y]:
        sig = probe_signature(presheaf, probe_family, y, x)
        sigs.add(sig)
    return len(sigs)


def measurement_invariant(presheaf, probe_family):
    """Sum of distinct signature counts over all objects."""
    return sum(measurement_space_image_card(presheaf, probe_family, y)
               for y in presheaf.objects)


def obs_eq(presheaf, probe_family, y, x1, x2):
    """Check if x1 and x2 are observationally equivalent under probe_family at y."""
    return probe_signature(presheaf, probe_family, y, x1) == \
           probe_signature(presheaf, probe_family, y, x2)


def no_new_separation(presheaf, p_small, p_large):
    """Check if p_large introduces no new separations beyond p_small."""
    for y in presheaf.objects:
        for x1, x2 in combinations(presheaf.fibers[y], 2):
            # If p_large separates but p_small doesn't, that's a new separation
            if not obs_eq(presheaf, p_large, y, x1, x2) and \
               obs_eq(presheaf, p_small, y, x1, x2):
                return False
    return True


def find_new_separations(presheaf, p_small, p_large):
    """Find all pairs newly separated by p_large but not by p_small."""
    new_seps = []
    for y in presheaf.objects:
        for x1, x2 in combinations(presheaf.fibers[y], 2):
            if not obs_eq(presheaf, p_large, y, x1, x2) and \
               obs_eq(presheaf, p_small, y, x1, x2):
                new_seps.append((y, x1, x2))
    return new_seps


# ─────────────────────────────────────────────────────────────────────────────
# Example presheaves
# ─────────────────────────────────────────────────────────────────────────────

def make_color_presheaf():
    """A presheaf over {A, B, C} where F(A)={r,g,b}, F(B)={0,1}, F(C)={x,y,z}.
    Restrictions project in various ways."""
    fibers = {
        'A': ['r', 'g', 'b'],
        'B': ['0', '1'],
        'C': ['x', 'y', 'z'],
    }
    restrictions = {
        ('A', 'A'): {'r': 'r', 'g': 'g', 'b': 'b'},
        ('A', 'B'): {'r': '0', 'g': '1', 'b': '0'},
        ('A', 'C'): {'r': 'x', 'g': 'y', 'b': 'z'},
        ('B', 'A'): {'0': 'r', '1': 'g'},
        ('B', 'B'): {'0': '0', '1': '1'},
        ('B', 'C'): {'0': 'x', '1': 'y'},
        ('C', 'A'): {'x': 'r', 'y': 'g', 'z': 'b'},
        ('C', 'B'): {'x': '0', 'y': '1', 'z': '0'},
        ('C', 'C'): {'x': 'x', 'y': 'y', 'z': 'z'},
    }
    return FinitePresheaf(fibers, restrictions)


def make_collapsing_presheaf():
    """A presheaf where some restrictions collapse elements, creating
    interesting separation behavior."""
    fibers = {
        'A': ['a1', 'a2', 'a3', 'a4'],
        'B': ['b1', 'b2'],
        'C': ['c1', 'c2', 'c3'],
    }
    restrictions = {
        ('A', 'A'): {'a1': 'a1', 'a2': 'a2', 'a3': 'a3', 'a4': 'a4'},
        ('A', 'B'): {'a1': 'b1', 'a2': 'b1', 'a3': 'b2', 'a4': 'b2'},
        ('A', 'C'): {'a1': 'c1', 'a2': 'c2', 'a3': 'c1', 'a4': 'c3'},
        ('B', 'A'): {'b1': 'a1', 'b2': 'a3'},
        ('B', 'B'): {'b1': 'b1', 'b2': 'b2'},
        ('B', 'C'): {'b1': 'c1', 'b2': 'c1'},
        ('C', 'A'): {'c1': 'a1', 'c2': 'a2', 'c3': 'a4'},
        ('C', 'B'): {'c1': 'b1', 'c2': 'b1', 'c3': 'b2'},
        ('C', 'C'): {'c1': 'c1', 'c2': 'c2', 'c3': 'c3'},
    }
    return FinitePresheaf(fibers, restrictions)


# ─────────────────────────────────────────────────────────────────────────────
# Demo 1: Monotonicity verification
# ─────────────────────────────────────────────────────────────────────────────

def demo_monotonicity():
    """Verify monotonicity for all nested probe families on a small presheaf."""
    print("=" * 70)
    print("DEMO 1: Monotonicity of Measurement Invariant")
    print("(Categorical Data Processing Inequality)")
    print("=" * 70)
    print()

    psh = make_color_presheaf()
    objects = psh.objects
    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(set(subset))

    print(f"Category objects: {objects}")
    print(f"Fiber sizes: {', '.join(f'|F({y})| = {len(psh.fibers[y])}' for y in objects)}")
    print()

    # Compute measurement invariant for each probe family
    results = {}
    for s in all_subsets:
        key = frozenset(s)
        mi = measurement_invariant(psh, s)
        results[key] = mi

    print("Measurement invariants by probe family:")
    for s in all_subsets:
        key = frozenset(s)
        label = str(sorted(s)) if s else '∅'
        print(f"  P = {label:>12s}  →  μ(P) = {results[key]}")
    print()

    # Verify monotonicity for all nested pairs
    violations = 0
    checks = 0
    for s1 in all_subsets:
        for s2 in all_subsets:
            if s1 <= s2:
                checks += 1
                k1, k2 = frozenset(s1), frozenset(s2)
                if results[k1] > results[k2]:
                    violations += 1
                    print(f"  VIOLATION: {sorted(s1)} ⊆ {sorted(s2)} but "
                          f"μ({sorted(s1)}) = {results[k1]} > {results[k2]} = μ({sorted(s2)})")

    print(f"Checked {checks} nested pairs: {'ALL MONOTONE ✓' if violations == 0 else f'{violations} VIOLATIONS!'}")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Demo 2: Equality characterization
# ─────────────────────────────────────────────────────────────────────────────

def demo_equality_characterization():
    """Verify the iff characterization: equality ⟺ no new separation."""
    print("=" * 70)
    print("DEMO 2: Equality ⟺ No New Separation (Rigidity Theorem)")
    print("=" * 70)
    print()

    psh = make_collapsing_presheaf()
    objects = psh.objects

    print(f"Category objects: {objects}")
    print(f"Fiber sizes: {', '.join(f'|F({y})| = {len(psh.fibers[y])}' for y in objects)}")
    print()

    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(set(subset))

    iff_holds = True
    for s1 in all_subsets:
        for s2 in all_subsets:
            if s1 <= s2 and s1 != s2:
                mi1 = measurement_invariant(psh, s1)
                mi2 = measurement_invariant(psh, s2)
                nns = no_new_separation(psh, s1, s2)
                eq = (mi1 == mi2)

                if eq != nns:
                    iff_holds = False

                marker = "=" if eq else "<"
                nns_str = "no new sep" if nns else "NEW SEP"
                consistent = "✓" if eq == nns else "✗ INCONSISTENT!"

                new_seps = find_new_separations(psh, s1, s2)
                sep_info = ""
                if new_seps:
                    sep_info = f"  [new: {new_seps[:2]}{'...' if len(new_seps)>2 else ''}]"

                print(f"  {sorted(s1)} ⊆ {sorted(s2)}: "
                      f"μ={mi1} {marker} {mi2}, {nns_str} {consistent}{sep_info}")

    print()
    print(f"Equality ⟺ No New Separation: {'VERIFIED ✓' if iff_holds else 'FAILED ✗'}")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Demo 3: Strict monotonicity
# ─────────────────────────────────────────────────────────────────────────────

def demo_strict_monotonicity():
    """Verify strict monotonicity: new separation ⟹ strict increase."""
    print("=" * 70)
    print("DEMO 3: Strict Monotonicity (New Separation ⟹ Strict Increase)")
    print("=" * 70)
    print()

    psh = make_collapsing_presheaf()
    objects = psh.objects

    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(set(subset))

    strict_holds = True
    for s1 in all_subsets:
        for s2 in all_subsets:
            if s1 < s2:  # strict subset
                mi1 = measurement_invariant(psh, s1)
                mi2 = measurement_invariant(psh, s2)
                new_seps = find_new_separations(psh, s1, s2)

                if new_seps and mi1 >= mi2:
                    strict_holds = False
                    print(f"  VIOLATION: {sorted(s1)} ⊂ {sorted(s2)}, "
                          f"new separation exists but μ={mi1} ≥ {mi2}")
                elif new_seps:
                    print(f"  {sorted(s1)} ⊂ {sorted(s2)}: "
                          f"new sep → μ={mi1} < {mi2} ✓")

    print()
    print(f"Strict monotonicity: {'VERIFIED ✓' if strict_holds else 'FAILED ✗'}")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Demo 4: Saturation — fully separating probes saturate
# ─────────────────────────────────────────────────────────────────────────────

def demo_saturation():
    """Verify that once a probe family fully separates, enlargement is redundant."""
    print("=" * 70)
    print("DEMO 4: Saturation — Separating Families Are Stable")
    print("=" * 70)
    print()

    psh = make_color_presheaf()
    objects = psh.objects

    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(set(subset))

    for s in all_subsets:
        # Check if s is fully separating (all signatures injective)
        separating = True
        for y in objects:
            sigs = [probe_signature(psh, s, y, x) for x in psh.fibers[y]]
            if len(sigs) != len(set(sigs)):
                separating = False
                break

        if separating:
            mi = measurement_invariant(psh, s)
            print(f"  P = {sorted(s)} is SEPARATING, μ(P) = {mi}")

            # Check all supersets
            for s2 in all_subsets:
                if s <= s2 and s != s2:
                    mi2 = measurement_invariant(psh, s2)
                    status = "✓" if mi == mi2 else "✗ DIFFERENT!"
                    print(f"    ⊆ {sorted(s2)}: μ = {mi2} {status}")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Demo 5: Partition visualization
# ─────────────────────────────────────────────────────────────────────────────

def demo_partition_refinement():
    """Visualize how probe enlargement refines the indistinguishability partition."""
    print("=" * 70)
    print("DEMO 5: Partition Refinement Under Probe Enlargement")
    print("=" * 70)
    print()

    psh = make_collapsing_presheaf()

    # Show partitions for increasing probe families
    probe_chain = [set(), {'B'}, {'B', 'C'}, {'A', 'B', 'C'}]

    for y in psh.objects:
        print(f"  Object {y}, elements: {psh.fibers[y]}")
        for probes in probe_chain:
            # Group elements by their signature
            groups = defaultdict(list)
            for x in psh.fibers[y]:
                sig = probe_signature(psh, probes, y, x)
                groups[sig].append(x)

            partition = [sorted(group) for group in groups.values()]
            mi_local = len(partition)
            probe_str = sorted(probes) if probes else '∅'
            print(f"    P = {str(probe_str):>16s}: "
                  f"partition = {partition}, classes = {mi_local}")
        print()


# ─────────────────────────────────────────────────────────────────────────────
# Demo 6: Exhaustive search over small discrete categories
# ─────────────────────────────────────────────────────────────────────────────

def demo_exhaustive_small_categories():
    """Enumerate all presheaves on 2-object categories with small fibers."""
    print("=" * 70)
    print("DEMO 6: Exhaustive Verification on Small Categories")
    print("=" * 70)
    print()

    objects = ['A', 'B']
    fiber_sizes = [2, 3]  # |F(A)| = 2, |F(B)| = 3

    fibers = {
        'A': list(range(fiber_sizes[0])),
        'B': list(range(fiber_sizes[1])),
    }

    # Enumerate all possible restriction maps r(A, B) : F(A) → F(B)
    # and r(B, A) : F(B) → F(A)
    all_r_AB = list(product(fibers['B'], repeat=len(fibers['A'])))
    all_r_BA = list(product(fibers['A'], repeat=len(fibers['B'])))

    total_presheaves = 0
    mono_verified = 0
    iff_verified = 0
    strict_verified = 0

    for r_ab_vals in all_r_AB:
        for r_ba_vals in all_r_BA:
            r_AB = dict(zip(fibers['A'], r_ab_vals))
            r_BA = dict(zip(fibers['B'], r_ba_vals))

            restrictions = {
                ('A', 'A'): {x: x for x in fibers['A']},
                ('A', 'B'): r_AB,
                ('B', 'A'): r_BA,
                ('B', 'B'): {x: x for x in fibers['B']},
            }

            psh = FinitePresheaf(fibers, restrictions)
            total_presheaves += 1

            # Probe families: ∅, {A}, {B}, {A,B}
            families = [set(), {'A'}, {'B'}, {'A', 'B'}]
            mis = {frozenset(s): measurement_invariant(psh, s) for s in families}

            # Check monotonicity
            for s1 in families:
                for s2 in families:
                    if set(s1) <= set(s2):
                        k1, k2 = frozenset(s1), frozenset(s2)
                        assert mis[k1] <= mis[k2], "Monotonicity violation!"
                        mono_verified += 1

            # Check iff characterization
            for s1 in families:
                for s2 in families:
                    if set(s1) <= set(s2):
                        k1, k2 = frozenset(s1), frozenset(s2)
                        eq = (mis[k1] == mis[k2])
                        nns = no_new_separation(psh, set(s1), set(s2))
                        assert eq == nns, "Iff characterization violation!"
                        iff_verified += 1

            # Check strict monotonicity
            for s1 in families:
                for s2 in families:
                    if set(s1) < set(s2):
                        k1, k2 = frozenset(s1), frozenset(s2)
                        new_seps = find_new_separations(psh, set(s1), set(s2))
                        if new_seps:
                            assert mis[k1] < mis[k2], "Strict monotonicity violation!"
                            strict_verified += 1

    print(f"Tested {total_presheaves} presheaves over {{A, B}} with |F(A)|=2, |F(B)|=3")
    print(f"Monotonicity checks passed: {mono_verified}")
    print(f"Iff characterization checks passed: {iff_verified}")
    print(f"Strict monotonicity checks passed: {strict_verified}")
    print("ALL CHECKS PASSED ✓")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Compression Stability Under Probe Enlargement — Interactive Demo  ║")
    print("║   Categorical Data Processing Inequality & Measurement Rigidity     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_monotonicity()
    demo_equality_characterization()
    demo_strict_monotonicity()
    demo_saturation()
    demo_partition_refinement()
    demo_exhaustive_small_categories()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
