#!/usr/bin/env python3
"""
Applications of Compression Stability Theory

This module demonstrates real-world applications of the probe enlargement
monotonicity and rigidity theorems across several domains:

1. Sensor array design (signal processing)
2. Feature selection (machine learning)
3. Experimental design (statistics)
4. Formula refinement (finite model theory)

Each application constructs a concrete finite presheaf model and uses
the measurement invariant machinery to analyze observational complexity.
"""

from typing import Any, Callable, Dict, List, Set, Tuple
from itertools import combinations
from collections import defaultdict


# =============================================================================
# Shared infrastructure
# =============================================================================

class FinitePresheaf:
    """A presheaf on a finite discrete category."""

    def __init__(self, objects: List[str], fibers: Dict[str, List[Any]],
                 restriction: Dict[Tuple[str, str], Callable]):
        self.objects = objects
        self.fibers = fibers
        self.restriction = restriction

    def restrict(self, y: str, z: str, x: Any) -> Any:
        return self.restriction[(y, z)](x)


def probe_signature(F: FinitePresheaf, P: Set[str], y: str, x: Any) -> Tuple:
    return tuple(F.restrict(y, z, x) for z in sorted(P))


def measurement_invariant(F: FinitePresheaf, P: Set[str]) -> int:
    total = 0
    for y in F.objects:
        sigs = set(probe_signature(F, P, y, x) for x in F.fibers[y])
        total += len(sigs)
    return total


def no_new_separation(F: FinitePresheaf, P: Set[str], Pp: Set[str]) -> bool:
    for y in F.objects:
        elems = F.fibers[y]
        for i in range(len(elems)):
            for j in range(i + 1, len(elems)):
                sig_Pp_i = probe_signature(F, Pp, y, elems[i])
                sig_Pp_j = probe_signature(F, Pp, y, elems[j])
                sig_P_i = probe_signature(F, P, y, elems[i])
                sig_P_j = probe_signature(F, P, y, elems[j])
                if sig_Pp_i != sig_Pp_j and sig_P_i == sig_P_j:
                    return False
    return True


# =============================================================================
# Application 1: Sensor Array Design
# =============================================================================

def app_sensor_array():
    """Model a sensor array monitoring a physical system.

    Objects represent spatial locations. Fibers represent possible states
    at each location. Restriction maps model how a sensor at one location
    can partially observe the state at another.

    Scenario: A factory floor with 4 zones, each with a set of possible
    machine states. Sensors at each zone can detect states at other zones
    with varying resolution (e.g., noise, distance).
    """
    print("=" * 70)
    print("APPLICATION 1: Sensor Array Design")
    print("=" * 70)

    zones = ['Z1', 'Z2', 'Z3', 'Z4']
    # Each zone has 4 possible states
    states = {
        'Z1': ['idle', 'running', 'warning', 'critical'],
        'Z2': ['idle', 'running', 'warning', 'critical'],
        'Z3': ['idle', 'running', 'warning', 'critical'],
        'Z4': ['idle', 'running', 'warning', 'critical'],
    }

    # Sensors detect: same zone = full resolution
    # Adjacent zones = partial (merge warning/critical)
    # Distant zones = coarse (merge running/warning/critical into "active")
    def make_sensor_map(from_zone: str, to_zone: str):
        dist = abs(int(from_zone[1]) - int(to_zone[1]))
        if dist == 0:
            return lambda x: x  # full resolution
        elif dist == 1:
            # merge warning and critical
            return lambda x: 'alarm' if x in ('warning', 'critical') else x
        else:
            # merge everything except idle
            return lambda x: 'idle' if x == 'idle' else 'active'

    restriction = {}
    for z1 in zones:
        for z2 in zones:
            restriction[(z1, z2)] = make_sensor_map(z1, z2)

    F = FinitePresheaf(zones, states, restriction)

    print("\n  Scenario: 4-zone factory, sensors with distance-based resolution")
    print("  States per zone: idle, running, warning, critical")
    print("  Sensor resolution: full (same zone), partial (adjacent), coarse (distant)")

    # Evaluate different sensor placements
    print("\n  Sensor Placement     | Meas. Invariant | Separating?")
    print("  " + "-" * 55)

    all_placements = []
    for size in range(len(zones) + 1):
        for subset in combinations(zones, size):
            P = set(subset)
            inv = measurement_invariant(F, P)
            is_sep = all(
                len(set(probe_signature(F, P, y, x) for x in F.fibers[y])) == len(F.fibers[y])
                for y in F.objects
            )
            all_placements.append((P, inv, is_sep))
            print(f"  {str(P):23s}| {inv:15d} | {'YES' if is_sep else 'no'}")

    # Find optimal placement
    min_sep = min((p for p in all_placements if p[2]), key=lambda p: len(p[0]))
    print(f"\n  Optimal placement (minimum sensors for full separation): {min_sep[0]}")
    print(f"  Measurement invariant: {min_sep[1]}")

    # Show redundancy analysis
    full = set(zones)
    for z in zones:
        reduced = full - {z}
        nns = no_new_separation(F, reduced, full)
        print(f"  Removing {z} from full array: redundant = {nns}")


# =============================================================================
# Application 2: Feature Selection in ML
# =============================================================================

def app_feature_selection():
    """Model feature selection as probe family comparison.

    Objects represent data classes. Fibers represent data points in each class.
    Features (probes) project data points to feature values.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Feature Selection")
    print("=" * 70)

    classes = ['cat', 'dog', 'bird']
    # Each class has several exemplars characterized by features
    data = {
        'cat':  [(2, 4, 1, 0), (3, 4, 1, 0), (2, 4, 2, 0)],  # (size, legs, tail, wings)
        'dog':  [(3, 4, 1, 0), (4, 4, 1, 0), (5, 4, 1, 0)],
        'bird': [(1, 2, 0, 1), (2, 2, 0, 1)],
    }

    features = ['size', 'legs', 'tail', 'wings']

    # Restriction maps: project to feature value
    restriction = {}
    for cls in classes:
        for i, feat in enumerate(features):
            restriction[(cls, feat)] = (lambda idx: lambda x: x[idx])(i)
        for cls2 in classes:
            restriction[(cls, cls2)] = lambda x: x  # identity between classes

    # Use features as probe objects
    all_objects = features
    fibers = data

    F = FinitePresheaf(classes, fibers, restriction)

    print("\n  Data: animals with features (size, legs, tail, wings)")
    for cls in classes:
        print(f"    {cls}: {data[cls]}")

    print(f"\n  Features: {features}")
    print("\n  Feature Set        | Meas. Invariant | Classes distinguished")
    print("  " + "-" * 60)

    for size in range(len(features) + 1):
        for subset in combinations(features, size):
            P = set(subset)
            inv = measurement_invariant(F, P)
            # Count how many elements are uniquely identified
            n_distinct = sum(
                len(set(probe_signature(F, P, y, x) for x in F.fibers[y]))
                for y in classes
            )
            print(f"  {str(P):21s}| {inv:15d} | {n_distinct} / {sum(len(v) for v in data.values())}")

    # Find minimal feature set that separates all exemplars
    for size in range(len(features) + 1):
        for subset in combinations(features, size):
            P = set(subset)
            is_sep = all(
                len(set(probe_signature(F, P, y, x) for x in F.fibers[y])) == len(F.fibers[y])
                for y in classes
            )
            if is_sep:
                print(f"\n  Minimal separating feature set: {P}")
                print(f"  These {len(P)} features suffice to uniquely identify all exemplars.")
                break
        else:
            continue
        break


# =============================================================================
# Application 3: Experimental Design
# =============================================================================

def app_experimental_design():
    """Model statistical experiment design as probe family selection.

    Each "test" is a probe that maps subjects to outcomes.
    The question: how many tests are needed to distinguish all subjects?
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Experimental Design (Diagnostic Tests)")
    print("=" * 70)

    # 5 diseases, each with a set of patients (represented by symptom profiles)
    diseases = ['flu', 'cold', 'allergy', 'covid', 'strep']
    patients = {
        'flu':     ['p1', 'p2', 'p3'],
        'cold':    ['p4', 'p5'],
        'allergy': ['p6', 'p7', 'p8'],
        'covid':   ['p9', 'p10'],
        'strep':   ['p11', 'p12'],
    }

    # Available tests and their outcomes per patient
    tests = ['blood', 'swab', 'temp', 'xray']
    test_results = {
        'blood': {'p1': 'high_wbc', 'p2': 'high_wbc', 'p3': 'normal',
                  'p4': 'normal', 'p5': 'normal',
                  'p6': 'high_ige', 'p7': 'high_ige', 'p8': 'normal',
                  'p9': 'high_wbc', 'p10': 'high_wbc',
                  'p11': 'high_wbc', 'p12': 'normal'},
        'swab':  {'p1': 'neg', 'p2': 'neg', 'p3': 'neg',
                  'p4': 'neg', 'p5': 'neg',
                  'p6': 'neg', 'p7': 'neg', 'p8': 'neg',
                  'p9': 'pos_covid', 'p10': 'pos_covid',
                  'p11': 'pos_strep', 'p12': 'pos_strep'},
        'temp':  {'p1': 'high', 'p2': 'high', 'p3': 'moderate',
                  'p4': 'normal', 'p5': 'low_grade',
                  'p6': 'normal', 'p7': 'normal', 'p8': 'normal',
                  'p9': 'high', 'p10': 'moderate',
                  'p11': 'high', 'p12': 'moderate'},
        'xray':  {'p1': 'clear', 'p2': 'clear', 'p3': 'clear',
                  'p4': 'clear', 'p5': 'clear',
                  'p6': 'clear', 'p7': 'clear', 'p8': 'clear',
                  'p9': 'hazy', 'p10': 'clear',
                  'p11': 'clear', 'p12': 'clear'},
    }

    restriction = {}
    for disease in diseases:
        for test in tests:
            restriction[(disease, test)] = (lambda t: lambda p: test_results[t][p])(test)
        for d2 in diseases:
            restriction[(disease, d2)] = lambda p: p

    F = FinitePresheaf(diseases, patients, restriction)

    print("\n  Scenario: 12 patients with 5 possible diseases")
    print(f"  Available tests: {tests}")

    print("\n  Test Battery          | Meas. Invariant | Patients distinguished")
    print("  " + "-" * 65)

    for size in range(len(tests) + 1):
        for subset in combinations(tests, size):
            P = set(subset)
            inv = measurement_invariant(F, P)
            n_distinct = sum(
                len(set(probe_signature(F, P, y, x) for x in F.fibers[y]))
                for y in diseases
            )
            total = sum(len(patients[d]) for d in diseases)
            print(f"  {str(P):24s}| {inv:15d} | {n_distinct} / {total}")

    # Redundancy analysis
    full_battery = set(tests)
    print(f"\n  Redundancy analysis for full battery {full_battery}:")
    for test in tests:
        reduced = full_battery - {test}
        inv_full = measurement_invariant(F, full_battery)
        inv_reduced = measurement_invariant(F, reduced)
        is_redundant = (inv_full == inv_reduced)
        print(f"    Remove {test:6s}: invariant {inv_reduced:2d} → {inv_full:2d}, "
              f"redundant = {is_redundant}")


# =============================================================================
# Application 4: Logical Formula Refinement
# =============================================================================

def app_formula_refinement():
    """Model logical formula sets as probe families.

    In finite model theory, adding formulas to a language refines
    the indistinguishability relation on structures. This application
    models that phenomenon.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Logical Formula Refinement (Finite Model Theory)")
    print("=" * 70)

    # Finite structures (small graphs) as "elements"
    # Formulas as "probes" that evaluate to truth values
    graph_types = ['empty', 'path', 'cycle', 'star', 'complete']
    structures = {
        'empty':    ['E2', 'E3', 'E4'],      # empty on 2,3,4 vertices
        'path':     ['P2', 'P3', 'P4'],
        'cycle':    ['C3', 'C4', 'C5'],
        'star':     ['S3', 'S4', 'S5'],
        'complete': ['K2', 'K3', 'K4'],
    }

    # Formulas and their truth values on each structure
    formulas = ['has_edge', 'connected', 'has_triangle', 'regular', 'has_leaf']
    formula_eval = {
        'has_edge':     {'E2': 0, 'E3': 0, 'E4': 0, 'P2': 1, 'P3': 1, 'P4': 1,
                         'C3': 1, 'C4': 1, 'C5': 1, 'S3': 1, 'S4': 1, 'S5': 1,
                         'K2': 1, 'K3': 1, 'K4': 1},
        'connected':    {'E2': 0, 'E3': 0, 'E4': 0, 'P2': 1, 'P3': 1, 'P4': 1,
                         'C3': 1, 'C4': 1, 'C5': 1, 'S3': 1, 'S4': 1, 'S5': 1,
                         'K2': 1, 'K3': 1, 'K4': 1},
        'has_triangle': {'E2': 0, 'E3': 0, 'E4': 0, 'P2': 0, 'P3': 0, 'P4': 0,
                         'C3': 1, 'C4': 0, 'C5': 0, 'S3': 0, 'S4': 0, 'S5': 0,
                         'K2': 0, 'K3': 1, 'K4': 1},
        'regular':      {'E2': 1, 'E3': 1, 'E4': 1, 'P2': 1, 'P3': 0, 'P4': 0,
                         'C3': 1, 'C4': 1, 'C5': 1, 'S3': 0, 'S4': 0, 'S5': 0,
                         'K2': 1, 'K3': 1, 'K4': 1},
        'has_leaf':     {'E2': 0, 'E3': 0, 'E4': 0, 'P2': 1, 'P3': 1, 'P4': 1,
                         'C3': 0, 'C4': 0, 'C5': 0, 'S3': 1, 'S4': 1, 'S5': 1,
                         'K2': 0, 'K3': 0, 'K4': 0},
    }

    restriction = {}
    for gt in graph_types:
        for f in formulas:
            restriction[(gt, f)] = (lambda ff: lambda s: formula_eval[ff][s])(f)
        for gt2 in graph_types:
            restriction[(gt, gt2)] = lambda s: s

    F = FinitePresheaf(graph_types, structures, restriction)

    print("\n  Structures: small graphs (empty, paths, cycles, stars, complete)")
    print(f"  Formulas: {formulas}")

    print("\n  Formula Set               | Inv | Types distinguished")
    print("  " + "-" * 55)

    for size in range(len(formulas) + 1):
        for subset in combinations(formulas, size):
            P = set(subset)
            inv = measurement_invariant(F, P)
            n_types = sum(
                len(set(probe_signature(F, P, y, x) for x in F.fibers[y]))
                for y in graph_types
            )
            total = sum(len(v) for v in structures.values())
            if size <= 2 or size == len(formulas):
                print(f"  {str(P):28s}| {inv:3d} | {n_types} / {total}")

    print("\n  (Showing only formulas sets of size 0-2 and full set)")
    print("  Monotonicity: adding formulas never decreases the invariant.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║    Applications of Compression Stability Theory                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    app_sensor_array()
    app_feature_selection()
    app_experimental_design()
    app_formula_refinement()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Compression Stability Under Probe Enlargement — Interactive Demo

This script demonstrates the core theorems of observational compression
stability on finite discrete categories. It implements the measurement
invariant, probe signatures, and verifies the monotonicity/rigidity
package computationally on small examples.

Usage:
    python demo.py
"""

from itertools import combinations, product
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Any, Callable


# =============================================================================
# Core Definitions
# =============================================================================

class FinitePresheaf:
    """A presheaf on a finite discrete category.

    Represented as:
    - objects: list of object names
    - fibers: dict mapping each object Y to a list of elements of F(Y)
    - restriction: dict mapping (Y, Z) to a function F(Y) -> F(Z)
    """

    def __init__(self, objects: List[str], fibers: Dict[str, List[Any]],
                 restriction: Dict[Tuple[str, str], Callable]):
        self.objects = objects
        self.fibers = fibers
        self.restriction = restriction

    def restrict(self, y: str, z: str, x: Any) -> Any:
        """Apply the restriction map r(Y, Z) to element x ∈ F(Y)."""
        return self.restriction[(y, z)](x)


def probe_signature(presheaf: FinitePresheaf, probe_family: Set[str],
                     y: str, x: Any) -> Tuple:
    """Compute the probe signature of element x ∈ F(Y) with respect to probe family P.

    The signature is the tuple (r(Y, Z)(x) for Z in P), recording how x
    is "seen" by each probe object.
    """
    return tuple(presheaf.restrict(y, z, x) for z in sorted(probe_family))


def measurement_space_image_card(presheaf: FinitePresheaf,
                                  probe_family: Set[str], y: str) -> int:
    """Count the number of distinct probe signatures at object Y."""
    sigs = set()
    for x in presheaf.fibers[y]:
        sig = probe_signature(presheaf, probe_family, y, x)
        sigs.add(sig)
    return len(sigs)


def measurement_invariant(presheaf: FinitePresheaf,
                           probe_family: Set[str]) -> int:
    """Compute the measurement invariant: sum of distinct signatures over all objects."""
    return sum(measurement_space_image_card(presheaf, probe_family, y)
               for y in presheaf.objects)


def separates_elements(presheaf: FinitePresheaf, probe_family: Set[str],
                        y: str, x1: Any, x2: Any) -> bool:
    """Check whether probe family P separates elements x1, x2 at object Y."""
    return probe_signature(presheaf, probe_family, y, x1) != \
           probe_signature(presheaf, probe_family, y, x2)


def no_new_separation(presheaf: FinitePresheaf, P: Set[str],
                       P_prime: Set[str]) -> bool:
    """Check whether P' introduces no new separations relative to P.

    Returns True iff every pair separated by P' is already separated by P.
    """
    for y in presheaf.objects:
        elems = presheaf.fibers[y]
        for i in range(len(elems)):
            for j in range(i + 1, len(elems)):
                x1, x2 = elems[i], elems[j]
                if separates_elements(presheaf, P_prime, y, x1, x2) and \
                   not separates_elements(presheaf, P, y, x1, x2):
                    return False
    return True


def has_new_separation(presheaf: FinitePresheaf, P: Set[str],
                        P_prime: Set[str]) -> bool:
    """Check whether P' introduces at least one new separation."""
    return not no_new_separation(presheaf, P, P_prime)


def restriction_map(presheaf: FinitePresheaf, P: Set[str], P_prime: Set[str],
                     y: str) -> Dict[Tuple, Tuple]:
    """Build the restriction map from P'-signatures to P-signatures at object Y.

    For each realized P'-signature, compute the corresponding P-signature.
    """
    result = {}
    for x in presheaf.fibers[y]:
        sig_prime = probe_signature(presheaf, P_prime, y, x)
        sig = probe_signature(presheaf, P, y, x)
        result[sig_prime] = sig
    return result


def algorithm_compare(presheaf: FinitePresheaf, P: Set[str],
                       P_prime: Set[str]) -> Dict:
    """Complete comparison algorithm for nested probe families.

    Returns a dictionary with:
    - invariant_P: measurement invariant of P
    - invariant_P': measurement invariant of P'
    - is_monotone: whether invariant_P ≤ invariant_P'
    - is_equal: whether invariant_P = invariant_P'
    - no_new_sep: whether P' introduces no new separations
    - restriction_maps: the restriction map at each object
    - signatures_P: realized signatures under P at each object
    - signatures_P': realized signatures under P' at each object
    """
    inv_P = measurement_invariant(presheaf, P)
    inv_P_prime = measurement_invariant(presheaf, P_prime)

    rest_maps = {}
    sigs_P = {}
    sigs_P_prime = {}
    for y in presheaf.objects:
        rest_maps[y] = restriction_map(presheaf, P, P_prime, y)
        sigs_P[y] = set(probe_signature(presheaf, P, y, x)
                        for x in presheaf.fibers[y])
        sigs_P_prime[y] = set(probe_signature(presheaf, P_prime, y, x)
                              for x in presheaf.fibers[y])

    return {
        'invariant_P': inv_P,
        'invariant_P_prime': inv_P_prime,
        'is_monotone': inv_P <= inv_P_prime,
        'is_equal': inv_P == inv_P_prime,
        'no_new_sep': no_new_separation(presheaf, P, P_prime),
        'restriction_maps': rest_maps,
        'signatures_P': sigs_P,
        'signatures_P_prime': sigs_P_prime,
    }


# =============================================================================
# Example Presheaves
# =============================================================================

def example_color_presheaf():
    """A presheaf modeling colored points with projection-based restrictions.

    Objects: {A, B, C}
    F(A) = {a1, a2, a3}, F(B) = {b1, b2}, F(C) = {c1, c2, c3, c4}
    Restriction maps project to "color classes."
    """
    objects = ['A', 'B', 'C']
    fibers = {
        'A': ['a1', 'a2', 'a3'],
        'B': ['b1', 'b2'],
        'C': ['c1', 'c2', 'c3', 'c4'],
    }
    # Define restriction maps based on "color" equivalence classes
    # r(Y, Z): elements of F(Y) map to elements of F(Z)
    color_map = {
        ('A', 'A'): {'a1': 'a1', 'a2': 'a2', 'a3': 'a3'},
        ('A', 'B'): {'a1': 'b1', 'a2': 'b1', 'a3': 'b2'},
        ('A', 'C'): {'a1': 'c1', 'a2': 'c2', 'a3': 'c3'},
        ('B', 'A'): {'b1': 'a1', 'b2': 'a3'},
        ('B', 'B'): {'b1': 'b1', 'b2': 'b2'},
        ('B', 'C'): {'b1': 'c1', 'b2': 'c3'},
        ('C', 'A'): {'c1': 'a1', 'c2': 'a2', 'c3': 'a3', 'c4': 'a3'},
        ('C', 'B'): {'c1': 'b1', 'c2': 'b1', 'c3': 'b2', 'c4': 'b2'},
        ('C', 'C'): {'c1': 'c1', 'c2': 'c2', 'c3': 'c3', 'c4': 'c4'},
    }
    restriction = {k: (lambda m: lambda x: m[x])(v) for k, v in color_map.items()}
    return FinitePresheaf(objects, fibers, restriction)


def example_binary_presheaf(n: int):
    """A presheaf on n objects where F(i) = {0, 1}^n (binary strings).

    Restriction r(i, j) is the projection to the j-th coordinate.
    This is the canonical "full measurement" presheaf.
    """
    objects = [str(i) for i in range(n)]
    fibers = {str(i): list(range(2**n)) for i in range(n)}

    def restrict(y, z, x):
        """Project binary representation of x to bit z."""
        return (x >> int(z)) & 1

    restriction = {(str(i), str(j)): (lambda j: lambda x: (x >> j) & 1)(int(j))
                   for i in range(n) for j in range(n)}
    return FinitePresheaf(objects, fibers, restriction)


def example_simple_presheaf():
    """Simplest nontrivial example: 2 objects, small fibers.

    Objects: {0, 1}
    F(0) = {a, b, c}, F(1) = {x, y}
    """
    objects = ['0', '1']
    fibers = {
        '0': ['a', 'b', 'c'],
        '1': ['x', 'y'],
    }
    maps = {
        ('0', '0'): {'a': 'a', 'b': 'b', 'c': 'c'},
        ('0', '1'): {'a': 'x', 'b': 'x', 'c': 'y'},  # a,b merge, c separate
        ('1', '0'): {'x': 'a', 'y': 'b'},
        ('1', '1'): {'x': 'x', 'y': 'y'},
    }
    restriction = {k: (lambda m: lambda x: m[x])(v) for k, v in maps.items()}
    return FinitePresheaf(objects, fibers, restriction)


# =============================================================================
# Demonstrations
# =============================================================================

def demo_monotonicity():
    """Demonstrate monotonicity of the measurement invariant."""
    print("=" * 70)
    print("DEMO 1: Monotonicity Under Probe Enlargement")
    print("=" * 70)

    F = example_simple_presheaf()
    print(f"\nPresheaf on objects {F.objects}")
    print(f"  F(0) = {F.fibers['0']}")
    print(f"  F(1) = {F.fibers['1']}")
    print(f"  r(0,1): a->x, b->x, c->y  (a and b merge)")

    # Test all probe families ordered by inclusion
    all_probes = [set(), {'0'}, {'1'}, {'0', '1'}]

    print("\n  Probe Family P    | meas_inv(P) | signatures at 0        | signatures at 1")
    print("  " + "-" * 80)

    for P in all_probes:
        inv = measurement_invariant(F, P)
        sigs0 = set(probe_signature(F, P, '0', x) for x in F.fibers['0'])
        sigs1 = set(probe_signature(F, P, '1', x) for x in F.fibers['1'])
        print(f"  {str(P):20s}| {inv:11d} | {str(sigs0):23s}| {sigs1}")

    print("\n  Monotonicity verification:")
    for i in range(len(all_probes)):
        for j in range(i + 1, len(all_probes)):
            P, P_prime = all_probes[i], all_probes[j]
            if P.issubset(P_prime):
                inv_P = measurement_invariant(F, P)
                inv_Pp = measurement_invariant(F, P_prime)
                status = "✓" if inv_P <= inv_Pp else "✗"
                print(f"    {status} {P} ⊆ {P_prime}: "
                      f"meas_inv({P}) = {inv_P} ≤ {inv_Pp} = meas_inv({P_prime})")


def demo_equality_characterization():
    """Demonstrate the equality ⟺ no-new-separation characterization."""
    print("\n" + "=" * 70)
    print("DEMO 2: Equality ⟺ No New Separation")
    print("=" * 70)

    F = example_color_presheaf()
    print(f"\nPresheaf on objects {F.objects}")
    for y in F.objects:
        print(f"  F({y}) = {F.fibers[y]}")

    all_probes = []
    for size in range(len(F.objects) + 1):
        for subset in combinations(F.objects, size):
            all_probes.append(set(subset))

    print(f"\n  Testing all {len(all_probes)} probe families...")
    print("\n  P ⊆ P'             | inv(P) | inv(P') | equal? | no_new_sep? | match?")
    print("  " + "-" * 75)

    all_match = True
    count = 0
    for i in range(len(all_probes)):
        for j in range(i + 1, len(all_probes)):
            P = all_probes[i]
            P_prime = all_probes[j]
            if not P.issubset(P_prime):
                continue

            result = algorithm_compare(F, P, P_prime)
            is_eq = result['is_equal']
            nns = result['no_new_sep']
            match = (is_eq == nns)
            if not match:
                all_match = False
            count += 1

            symbol = "✓" if match else "✗"
            print(f"  {str(P):9s}⊆ {str(P_prime):9s}| {result['invariant_P']:6d} | "
                  f"{result['invariant_P_prime']:7d} | {str(is_eq):6s} | {str(nns):11s} | {symbol}")

    print(f"\n  Tested {count} inclusion pairs.")
    print(f"  Theorem verified: equality ⟺ no new separation: {'ALL MATCH ✓' if all_match else 'FAILURE ✗'}")


def demo_strict_monotonicity():
    """Demonstrate strict monotonicity when new separations exist."""
    print("\n" + "=" * 70)
    print("DEMO 3: Strict Monotonicity Under New Separations")
    print("=" * 70)

    F = example_simple_presheaf()
    P = set()       # empty probe family — merges everything
    P_prime = {'1'}  # probe with object 1

    print(f"\n  P = ∅, P' = {{'1'}}")
    print(f"  F(0) = {F.fibers['0']}, r(0,1): a->x, b->x, c->y")

    inv_P = measurement_invariant(F, P)
    inv_Pp = measurement_invariant(F, P_prime)

    print(f"\n  meas_inv(∅) = {inv_P}")
    print(f"  meas_inv({{'1'}}) = {inv_Pp}")

    # Find new separations
    new_seps = []
    for y in F.objects:
        elems = F.fibers[y]
        for i in range(len(elems)):
            for j in range(i + 1, len(elems)):
                x1, x2 = elems[i], elems[j]
                if separates_elements(F, P_prime, y, x1, x2) and \
                   not separates_elements(F, P, y, x1, x2):
                    new_seps.append((y, x1, x2))

    print(f"\n  New separations introduced by P':")
    for y, x1, x2 in new_seps:
        print(f"    At object {y}: {x1} and {x2} are now separated")

    if new_seps:
        print(f"\n  ∃ new separation ⟹ strict increase: {inv_P} < {inv_Pp}? "
              f"{'✓ YES' if inv_P < inv_Pp else '✗ NO'}")


def demo_restriction_map():
    """Demonstrate the restriction map from P'-signatures to P-signatures."""
    print("\n" + "=" * 70)
    print("DEMO 4: Signature Restriction Map")
    print("=" * 70)

    F = example_color_presheaf()
    P = {'A'}
    P_prime = {'A', 'B'}

    print(f"\n  P = {P}, P' = {P_prime}")

    for y in F.objects:
        rest_map = restriction_map(F, P, P_prime, y)
        print(f"\n  Object {y}:")
        print(f"    P-signatures:  {set(probe_signature(F, P, y, x) for x in F.fibers[y])}")
        print(f"    P'-signatures: {set(probe_signature(F, P_prime, y, x) for x in F.fibers[y])}")
        print(f"    Restriction map (P' → P):")
        for sig_prime, sig in sorted(rest_map.items()):
            print(f"      {sig_prime} ↦ {sig}")

    # Verify surjectivity
    print("\n  Restriction map surjectivity check:")
    for y in F.objects:
        rest_map = restriction_map(F, P, P_prime, y)
        p_sigs = set(probe_signature(F, P, y, x) for x in F.fibers[y])
        image = set(rest_map.values())
        is_surj = (image == p_sigs)
        print(f"    Object {y}: surjective = {is_surj} ✓" if is_surj
              else f"    Object {y}: surjective = {is_surj} ✗")


def demo_separating_saturation():
    """Demonstrate that separating families saturate the invariant."""
    print("\n" + "=" * 70)
    print("DEMO 5: Separating Family Saturation")
    print("=" * 70)

    F = example_simple_presheaf()
    P_full = set(F.objects)  # all objects — always separating

    print(f"\n  Full probe family P = {P_full}")
    inv_full = measurement_invariant(F, P_full)
    print(f"  meas_inv(P_full) = {inv_full}")

    # Check that any superset (which is P_full itself, since it's already maximal)
    # has the same invariant — but also check if smaller separating families exist
    print("\n  Checking all probe families for separation:")
    for size in range(len(F.objects) + 1):
        for subset in combinations(F.objects, size):
            P = set(subset)
            inv = measurement_invariant(F, P)
            # Check if P is separating (all signatures injective)
            is_sep = True
            for y in F.objects:
                sigs = [probe_signature(F, P, y, x) for x in F.fibers[y]]
                if len(sigs) != len(set(sigs)):
                    is_sep = False
                    break
            status = "SEP" if is_sep else "   "
            print(f"    [{status}] P = {str(P):20s} meas_inv = {inv}")

    print(f"\n  Theorem: once a family is separating, the invariant equals the total")
    print(f"  objectwise cardinality: ∑_Y |F(Y)| = "
          f"{sum(len(F.fibers[y]) for y in F.objects)}")


def demo_exhaustive_test():
    """Exhaustive test of the conjecture on all probe family pairs for small categories."""
    print("\n" + "=" * 70)
    print("DEMO 6: Exhaustive Verification on Small Categories")
    print("=" * 70)

    F = example_color_presheaf()
    objects = F.objects

    all_probes = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_probes.append(set(subset))

    monotonicity_ok = 0
    monotonicity_fail = 0
    equality_iff_ok = 0
    equality_iff_fail = 0
    strict_ok = 0
    strict_fail = 0
    total_pairs = 0

    for i in range(len(all_probes)):
        for j in range(i + 1, len(all_probes)):
            P = all_probes[i]
            P_prime = all_probes[j]
            if not P.issubset(P_prime):
                continue

            total_pairs += 1
            result = algorithm_compare(F, P, P_prime)

            # Test monotonicity
            if result['is_monotone']:
                monotonicity_ok += 1
            else:
                monotonicity_fail += 1

            # Test equality ⟺ no new separation
            if result['is_equal'] == result['no_new_sep']:
                equality_iff_ok += 1
            else:
                equality_iff_fail += 1

            # Test strict monotonicity under new separation
            if has_new_separation(F, P, P_prime):
                if result['invariant_P'] < result['invariant_P_prime']:
                    strict_ok += 1
                else:
                    strict_fail += 1

    print(f"\n  Total inclusion pairs tested: {total_pairs}")
    print(f"\n  Monotonicity (meas_inv(P) ≤ meas_inv(P')):")
    print(f"    Passed: {monotonicity_ok}, Failed: {monotonicity_fail}")
    print(f"\n  Equality ⟺ No New Separation:")
    print(f"    Passed: {equality_iff_ok}, Failed: {equality_iff_fail}")
    print(f"\n  Strict increase under new separation:")
    print(f"    Passed: {strict_ok}, Failed: {strict_fail}")

    all_ok = (monotonicity_fail == 0 and equality_iff_fail == 0 and strict_fail == 0)
    print(f"\n  {'ALL TESTS PASSED ✓' if all_ok else 'SOME TESTS FAILED ✗'}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Compression Stability Under Probe Enlargement — Demo Suite     ║")
    print("║                                                                    ║")
    print("║  Verifying: enlarging observables refines partitions, weakly       ║")
    print("║  increases measurement complexity, and preserves complexity        ║")
    print("║  exactly when the added observables are informationally redundant. ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_monotonicity()
    demo_equality_characterization()
    demo_strict_monotonicity()
    demo_restriction_map()
    demo_separating_saturation()
    demo_exhaustive_test()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
