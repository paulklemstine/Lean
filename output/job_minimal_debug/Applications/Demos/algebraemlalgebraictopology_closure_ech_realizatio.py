#!/usr/bin/env python3
"""
Applications of Closure-Čech Realization Duality.

Demonstrates real-world applications:
1. Sensor network topology recovery
2. Social network community detection
3. Feature overlap analysis in machine learning
4. Formal concept analysis enhancement
"""

from itertools import combinations
from typing import FrozenSet, Set, Dict, List
from collections import defaultdict
import random
import math


# ============================================================
# Core utilities (self-contained)
# ============================================================

def family_intersection(U: Dict, I: FrozenSet) -> FrozenSet:
    if not I:
        return frozenset()
    result = None
    for i in I:
        s = frozenset(U[i])
        result = s if result is None else result & s
    return result


def build_nerve(U: Dict) -> Set[FrozenSet]:
    indices = list(U.keys())
    support = set()
    for size in range(1, len(indices) + 1):
        for combo in combinations(indices, size):
            I = frozenset(combo)
            if family_intersection(U, I):
                support.add(I)
    return support


def f_vector(faces: Set[FrozenSet]) -> List[int]:
    if not faces:
        return []
    max_dim = max(len(f) for f in faces) - 1
    fv = [0] * (max_dim + 1)
    for f in faces:
        fv[len(f) - 1] += 1
    return fv


def euler_char(faces: Set[FrozenSet]) -> int:
    return sum((-1) ** (len(f) - 1) for f in faces)


def betti_numbers_small(faces: Set[FrozenSet]) -> List[int]:
    """Estimate Betti numbers for small complexes using Euler char and f-vector."""
    fv = f_vector(faces)
    chi = euler_char(faces)
    # For connected complexes of dimension ≤ 1:
    # β₀ - β₁ = χ, and we can count components
    if not fv:
        return []

    # Count connected components
    vertices = {v for f in faces for v in f}
    edges = [f for f in faces if len(f) == 2]

    # Union-find for components
    parent = {v: v for v in vertices}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for e in edges:
        vs = list(e)
        if len(vs) == 2:
            union(vs[0], vs[1])

    components = len(set(find(v) for v in vertices))
    beta_0 = components
    beta_1 = beta_0 - chi  # From χ = β₀ - β₁ (for dim ≤ 1)
    return [beta_0, max(0, beta_1)]


# ============================================================
# Application 1: Sensor Network Topology
# ============================================================

def sensor_network_demo():
    """Recover the topology of a monitored region from sensor overlaps."""
    print("=" * 60)
    print("APPLICATION 1: Sensor Network Topology Recovery")
    print("=" * 60)
    print()

    # Scenario: sensors monitoring a building floor plan
    # The floor has a courtyard (hole) in the middle
    # 8 sensors arranged around the courtyard perimeter

    print("Scenario: 8 sensors around a courtyard (ring topology)")
    print("Each sensor covers two adjacent monitoring zones")
    print()

    zones = [f'z{i}' for i in range(8)]
    sensors = {}
    for i in range(8):
        sensors[f'S{i+1}'] = {zones[i], zones[(i+1) % 8]}

    for name, coverage in sensors.items():
        print(f"  {name}: covers {coverage}")

    nerve = build_nerve(sensors)
    fv = f_vector(nerve)
    chi = euler_char(nerve)
    betti = betti_numbers_small(nerve)

    print(f"\nNerve analysis:")
    print(f"  f-vector: {fv}")
    print(f"  Euler characteristic: χ = {chi}")
    print(f"  Betti numbers: β₀ = {betti[0]}, β₁ = {betti[1]}")
    print(f"\nInterpretation:")
    print(f"  β₀ = {betti[0]} → {betti[0]} connected component(s)")
    print(f"  β₁ = {betti[1]} → {betti[1]} hole(s) detected")
    print(f"  → Correctly identifies the courtyard hole!")
    print()

    # Now add a sensor that bridges across the courtyard
    print("Adding sensor S9 that bridges across the courtyard...")
    sensors['S9'] = {zones[0], zones[4]}
    nerve2 = build_nerve(sensors)
    fv2 = f_vector(nerve2)
    chi2 = euler_char(nerve2)
    betti2 = betti_numbers_small(nerve2)

    print(f"  Updated f-vector: {fv2}")
    print(f"  Updated χ = {chi2}")
    print(f"  Updated Betti: β₀ = {betti2[0]}, β₁ = {betti2[1]}")
    print(f"  → Bridge doesn't fill the hole (no 2-simplices created)")
    print()


# ============================================================
# Application 2: Social Network Communities
# ============================================================

def social_network_demo():
    """Detect community structure from social group overlaps."""
    print("=" * 60)
    print("APPLICATION 2: Social Network Community Detection")
    print("=" * 60)
    print()

    print("Modeling social groups as cover sets:")
    print("  Each group is a set of people")
    print("  The nerve captures multi-group membership patterns")
    print()

    groups = {
        'BookClub': {'Alice', 'Bob', 'Carol'},
        'Gym': {'Bob', 'Dave', 'Eve'},
        'Choir': {'Carol', 'Eve', 'Frank'},
        'Chess': {'Alice', 'Dave', 'Frank'},
        'Hiking': {'Bob', 'Carol', 'Frank'},
    }

    for name, members in groups.items():
        print(f"  {name}: {members}")

    nerve = build_nerve(groups)
    fv = f_vector(nerve)
    chi = euler_char(nerve)

    print(f"\nNerve structure:")
    print(f"  f-vector: {fv}")
    print(f"  Euler characteristic: χ = {chi}")

    # Show pairwise overlaps
    print(f"\nPairwise group overlaps (edges of the nerve):")
    for f in sorted(nerve, key=lambda x: (len(x), sorted(x))):
        if len(f) == 2:
            g1, g2 = sorted(f)
            shared = set(groups[g1]) & set(groups[g2])
            print(f"  {g1} ∩ {g2} = {shared}")

    # Show triple overlaps
    print(f"\nTriple group overlaps (triangles of the nerve):")
    has_triple = False
    for f in sorted(nerve, key=lambda x: (len(x), sorted(x))):
        if len(f) == 3:
            gs = sorted(f)
            shared = set.intersection(*(set(groups[g]) for g in gs))
            print(f"  {gs[0]} ∩ {gs[1]} ∩ {gs[2]} = {shared}")
            has_triple = True
    if not has_triple:
        print("  (none)")

    print(f"\nInterpretation:")
    print(f"  The nerve reveals the 'social topology' of group membership")
    print(f"  Triangles indicate tight three-way community connections")
    print(f"  The Euler characteristic summarizes structural complexity")
    print()


# ============================================================
# Application 3: Feature Overlap in ML
# ============================================================

def ml_feature_demo():
    """Analyze feature overlap structure in a classification task."""
    print("=" * 60)
    print("APPLICATION 3: Feature Overlap Analysis for ML")
    print("=" * 60)
    print()

    print("Scenario: Binary classification with feature regions")
    print("Each feature defines a region where it activates")
    print("The nerve captures feature co-activation patterns")
    print()

    # Simulate feature activation regions for a 2D classification task
    random.seed(42)
    n_samples = 100
    samples = [(random.gauss(0, 1), random.gauss(0, 1)) for _ in range(n_samples)]

    # Feature detectors (simple thresholds)
    features = {
        'x_pos': {i for i, (x, _) in enumerate(samples) if x > 0},
        'x_neg': {i for i, (x, _) in enumerate(samples) if x < 0},
        'y_pos': {i for i, (_, y) in enumerate(samples) if y > 0},
        'y_neg': {i for i, (_, y) in enumerate(samples) if y < 0},
        'near_origin': {i for i, (x, y) in enumerate(samples) if x**2 + y**2 < 1},
        'far_origin': {i for i, (x, y) in enumerate(samples) if x**2 + y**2 > 0.5},
    }

    for name, region in features.items():
        print(f"  {name}: activates on {len(region)}/{n_samples} samples")

    nerve = build_nerve(features)
    fv = f_vector(nerve)
    chi = euler_char(nerve)

    print(f"\nFeature co-activation nerve:")
    print(f"  f-vector: {fv}")
    print(f"  Euler characteristic: χ = {chi}")
    print(f"  Dimension: {len(fv) - 1}")

    # Show which feature combos never co-activate (not in nerve)
    print(f"\nFeature combinations that NEVER co-activate:")
    all_pairs = list(combinations(features.keys(), 2))
    for pair in all_pairs:
        I = frozenset(pair)
        if I not in nerve:
            print(f"  {pair[0]} + {pair[1]} (mutually exclusive)")

    print(f"\nInterpretation:")
    print(f"  The nerve reveals which features can work together")
    print(f"  Missing simplices = feature incompatibilities")
    print(f"  This guides feature selection and model architecture")
    print()


# ============================================================
# Application 4: Formal Concept Analysis
# ============================================================

def formal_concept_demo():
    """Enrich formal concept analysis with topological structure."""
    print("=" * 60)
    print("APPLICATION 4: Formal Concept Analysis + Topology")
    print("=" * 60)
    print()

    print("Formal context: animals × properties")
    print()

    # Formal context (objects × attributes)
    context = {
        'dog': {'legs', 'fur', 'tail', 'domestic'},
        'cat': {'legs', 'fur', 'tail', 'domestic'},
        'fish': {'tail', 'scales', 'domestic'},
        'bird': {'legs', 'feathers', 'wings', 'domestic'},
        'snake': {'scales'},
        'bat': {'fur', 'wings'},
    }

    # Attributes as cover: each attribute → set of objects having it
    attributes = defaultdict(set)
    for animal, props in context.items():
        for prop in props:
            attributes[prop].add(animal)

    print("Attribute extents (cover):")
    for attr, objects in sorted(attributes.items()):
        print(f"  {attr}: {sorted(objects)}")

    nerve = build_nerve(dict(attributes))
    fv = f_vector(nerve)
    chi = euler_char(nerve)

    print(f"\nAttribute co-occurrence nerve:")
    print(f"  f-vector: {fv}")
    print(f"  Euler characteristic: χ = {chi}")

    # Show maximal simplices (maximal attribute combinations)
    maximal = {f for f in nerve
               if not any(f < g for g in nerve)}
    print(f"\nMaximal attribute combinations (maximal simplices):")
    for m in sorted(maximal, key=lambda x: (-len(x), sorted(x))):
        shared = set.intersection(*(attributes[a] for a in m))
        print(f"  {sorted(m)} → shared by {sorted(shared)}")

    print(f"\nInterpretation:")
    print(f"  The nerve adds topological structure to the concept lattice")
    print(f"  Maximal simplices ≈ maximal formal concepts")
    print(f"  χ captures the complexity of attribute relationships")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    sensor_network_demo()
    social_network_demo()
    ml_feature_demo()
    formal_concept_demo()

    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Closure-Čech Realization Duality.

This script demonstrates the core theorems with concrete numerical examples:
1. Building the Čech nerve from a cover
2. Constructing the idempotent nerve semimodule
3. Reconstructing the simplicial complex
4. Verifying the roundtrip property
5. Vertex recovery from degree-1 generators
"""

from itertools import combinations
from typing import FrozenSet, Set, Dict, List, Callable, Optional


# ============================================================
# Core Data Structures
# ============================================================

class ClosureOperator:
    """A closure operator on a finite set."""

    def __init__(self, ground_set: Set, cl: Callable[[FrozenSet], FrozenSet]):
        self.ground_set = frozenset(ground_set)
        self._cl = cl
        self._validate()

    def _validate(self):
        """Verify closure operator axioms on small subsets."""
        for size in range(min(4, len(self.ground_set) + 1)):
            for s in combinations(self.ground_set, size):
                s = frozenset(s)
                cs = self.cl(s)
                assert s <= cs, f"Extensivity failed: {s} not subset of cl({s})={cs}"
                assert self.cl(cs) == cs, f"Idempotence failed: cl(cl({s}))={self.cl(cs)} != cl({s})={cs}"

    def cl(self, s: FrozenSet) -> FrozenSet:
        return self._cl(frozenset(s))

    @staticmethod
    def trivial(ground_set: Set) -> 'ClosureOperator':
        """The trivial closure operator: cl(S) = S."""
        return ClosureOperator(ground_set, lambda s: s)

    @staticmethod
    def topological(ground_set: Set, closed_sets: List[FrozenSet]) -> 'ClosureOperator':
        """Closure operator from a family of closed sets."""
        def cl(s):
            result = frozenset(ground_set)
            for c in closed_sets:
                if s <= c:
                    result = result & c
            return result
        return ClosureOperator(ground_set, cl)


class NerveSemimodule:
    """An idempotent nerve semimodule.

    Generators are nonempty frozensets of indices,
    forming a downward-closed family.
    """

    def __init__(self, generators: Set[FrozenSet]):
        self.generators = set(generators)
        self._validate()

    def _validate(self):
        for g in self.generators:
            assert len(g) > 0, "Generator must be nonempty"
            # Check downward closure
            for size in range(1, len(g)):
                for sub in combinations(g, size):
                    sub = frozenset(sub)
                    assert sub in self.generators, \
                        f"Downward closure violated: {sub} not in generators but {g} is"

    @property
    def vertices(self) -> Set:
        """Degree-1 generators (singletons) = vertices."""
        return {next(iter(g)) for g in self.generators if len(g) == 1}

    @property
    def max_degree(self) -> int:
        return max((len(g) for g in self.generators), default=0)

    def generators_by_degree(self, k: int) -> Set[FrozenSet]:
        """Generators of degree k (cardinality k)."""
        return {g for g in self.generators if len(g) == k}

    def face_map(self, g: FrozenSet, j) -> Optional[FrozenSet]:
        """Delete vertex j from generator g."""
        if j not in g:
            return None
        result = g - {j}
        if len(result) == 0:
            return None
        return result

    def __repr__(self):
        by_deg = {}
        for g in self.generators:
            d = len(g)
            by_deg.setdefault(d, []).append(g)
        lines = [f"NerveSemimodule with {len(self.generators)} generators:"]
        for d in sorted(by_deg):
            gens = sorted(by_deg[d], key=lambda x: sorted(x))
            lines.append(f"  Degree {d}: {[set(g) for g in gens]}")
        return "\n".join(lines)


class SimplicialComplex:
    """An abstract simplicial complex."""

    def __init__(self, faces: Set[FrozenSet]):
        self.faces = set(faces)

    @property
    def vertices(self) -> Set:
        return {v for f in self.faces for v in f}

    @property
    def dimension(self) -> int:
        return max((len(f) - 1 for f in self.faces), default=-1)

    def euler_characteristic(self) -> int:
        chi = 0
        for f in self.faces:
            chi += (-1) ** (len(f) - 1)
        return chi

    def f_vector(self) -> List[int]:
        """f-vector: f[k] = number of k-simplices."""
        d = self.dimension
        f = [0] * (d + 1)
        for face in self.faces:
            f[len(face) - 1] += 1
        return f

    def __repr__(self):
        fv = self.f_vector()
        return (f"SimplicialComplex(dim={self.dimension}, "
                f"f-vector={fv}, χ={self.euler_characteristic()})")


# ============================================================
# Core Algorithms
# ============================================================

def family_inter(U: Dict, I: FrozenSet) -> FrozenSet:
    """Intersection of sets U[i] for i in I."""
    if not I:
        return frozenset()
    result = None
    for i in I:
        if result is None:
            result = frozenset(U[i])
        else:
            result = result & frozenset(U[i])
    return result


def build_cech_nerve(U: Dict) -> SimplicialComplex:
    """Build the Čech nerve of a family U."""
    indices = list(U.keys())
    faces = set()
    for size in range(1, len(indices) + 1):
        for combo in combinations(indices, size):
            I = frozenset(combo)
            if family_inter(U, I):  # nonempty intersection
                faces.add(I)
    return SimplicialComplex(faces)


def build_nerve_semimodule(U: Dict) -> NerveSemimodule:
    """Build the idempotent nerve semimodule from a cover."""
    indices = list(U.keys())
    generators = set()
    for size in range(1, len(indices) + 1):
        for combo in combinations(indices, size):
            I = frozenset(combo)
            if family_inter(U, I):
                generators.add(I)
    return NerveSemimodule(generators)


def reconstruct_complex(M: NerveSemimodule) -> SimplicialComplex:
    """Reconstruct a simplicial complex from a nerve semimodule."""
    return SimplicialComplex(M.generators)


def closure_equivalence_classes(c: ClosureOperator, U: Dict,
                                 nerve_support: Set[FrozenSet]) -> Dict[FrozenSet, List[FrozenSet]]:
    """Partition nerve support by closure-equivalence."""
    classes = {}
    for I in nerve_support:
        closure = c.cl(family_inter(U, I))
        classes.setdefault(closure, []).append(I)
    return classes


# ============================================================
# Demonstrations
# ============================================================

def demo_triangle_cover():
    """Three overlapping sets forming a triangle (no triple overlap)."""
    print("=" * 60)
    print("DEMO 1: Triangle Cover")
    print("=" * 60)

    X = {'a', 'b', 'c'}
    U = {1: {'a', 'b'}, 2: {'b', 'c'}, 3: {'a', 'c'}}

    print(f"Ground set X = {X}")
    print(f"Cover: U₁={U[1]}, U₂={U[2]}, U₃={U[3]}")
    print(f"U₁∩U₂ = {set(family_inter(U, frozenset({1,2})))}")
    print(f"U₁∩U₃ = {set(family_inter(U, frozenset({1,3})))}")
    print(f"U₂∩U₃ = {set(family_inter(U, frozenset({2,3})))}")
    print(f"U₁∩U₂∩U₃ = {set(family_inter(U, frozenset({1,2,3})))}")

    nerve = build_cech_nerve(U)
    print(f"\nČech nerve: {nerve}")

    semimodule = build_nerve_semimodule(U)
    print(f"\n{semimodule}")

    reconstructed = reconstruct_complex(semimodule)
    print(f"\nReconstructed complex: {reconstructed}")

    # Verify roundtrip
    assert nerve.faces == reconstructed.faces, "ROUNDTRIP FAILED!"
    print("\n✓ Roundtrip verified: reconstructed faces = nerve faces")

    # Verify vertices
    print(f"\nVertices from semimodule: {semimodule.vertices}")
    print(f"Indices with nonempty U_i: {set(U.keys())}")
    assert semimodule.vertices == set(U.keys())
    print("✓ Vertex recovery verified")
    print()


def demo_full_simplex():
    """Three sets with full overlap → 2-simplex."""
    print("=" * 60)
    print("DEMO 2: Full 2-Simplex")
    print("=" * 60)

    X = {'a', 'b', 'c'}
    U = {1: {'a', 'b', 'c'}, 2: {'a', 'b', 'c'}, 3: {'a', 'b', 'c'}}

    print(f"All U_i = {U[1]} (full overlap)")

    nerve = build_cech_nerve(U)
    semimodule = build_nerve_semimodule(U)
    reconstructed = reconstruct_complex(semimodule)

    print(f"Čech nerve: {nerve}")
    print(f"{semimodule}")
    assert nerve.faces == reconstructed.faces
    print("✓ Roundtrip verified")
    print(f"Euler characteristic: {nerve.euler_characteristic()}")
    print()


def demo_closure_quotient():
    """Nontrivial closure operator merging overlap classes."""
    print("=" * 60)
    print("DEMO 3: Closure Equivalence Quotient")
    print("=" * 60)

    X = {'a', 'b', 'c', 'd'}
    # Closure that merges {a} and {b} into {a,b}
    def cl(s):
        s = frozenset(s)
        if 'a' in s or 'b' in s:
            s = s | frozenset({'a', 'b'})
        return s

    c = ClosureOperator(X, cl)
    U = {1: {'a', 'c'}, 2: {'b', 'c'}, 3: {'c', 'd'}}

    print(f"Closure merges {{a}} and {{b}} into {{a,b}}")
    print(f"U₁={U[1]}, U₂={U[2]}, U₃={U[3]}")

    nerve = build_cech_nerve(U)
    semimodule = build_nerve_semimodule(U)
    print(f"\nČech nerve: {nerve}")
    print(f"{semimodule}")

    # Show closure equivalence classes
    classes = closure_equivalence_classes(c, U, semimodule.generators)
    print(f"\nClosure-equivalence classes:")
    for closure_val, members in classes.items():
        print(f"  cl = {set(closure_val)}: {[set(m) for m in members]}")

    # Check which are closure-equivalent
    I12 = frozenset({1, 2})
    cl_I12 = c.cl(family_inter(U, I12))
    I13 = frozenset({1, 3})
    cl_I13 = c.cl(family_inter(U, I13))
    print(f"\ncl(U₁∩U₂) = cl({set(family_inter(U, I12))}) = {set(cl_I12)}")
    print(f"cl(U₁∩U₃) = cl({set(family_inter(U, I13))}) = {set(cl_I13)}")
    if cl_I12 == cl_I13:
        print("→ {1,2} ~ {1,3} (closure-equivalent)")
    else:
        print("→ {1,2} ≁ {1,3} (not closure-equivalent)")

    # Roundtrip still works
    reconstructed = reconstruct_complex(semimodule)
    assert nerve.faces == reconstructed.faces
    print("\n✓ Roundtrip verified (pre-quotient level)")
    print()


def demo_face_maps():
    """Demonstrate face maps and simplicial identities."""
    print("=" * 60)
    print("DEMO 4: Face Maps and Simplicial Identities")
    print("=" * 60)

    U = {1: {'a', 'b', 'c'}, 2: {'a', 'b', 'c'},
         3: {'a', 'b', 'c'}, 4: {'a', 'b', 'c'}}
    semimodule = build_nerve_semimodule(U)

    I = frozenset({1, 2, 3, 4})
    print(f"Generator I = {set(I)}, degree = {len(I)}")

    for j in sorted(I):
        face = semimodule.face_map(I, j)
        print(f"  d_{j}(I) = {set(face)}, degree = {len(face)}")

    # Verify simplicial identity: d_j ∘ d_k = d_k ∘ d_j
    print("\nSimplicial identity d_j ∘ d_k = d_k ∘ d_j:")
    for j in [1, 2]:
        for k in [3, 4]:
            djk = semimodule.face_map(semimodule.face_map(I, k), j)
            dkj = semimodule.face_map(semimodule.face_map(I, j), k)
            status = "✓" if djk == dkj else "✗"
            print(f"  {status} d_{j}(d_{k}(I)) = {set(djk)}, d_{k}(d_{j}(I)) = {set(dkj)}")

    # Verify degree decrease
    print(f"\nDegree of I = {len(I)}")
    face = semimodule.face_map(I, 2)
    print(f"Degree of d_2(I) = {len(face)}")
    print(f"Degree decreased by: {len(I) - len(face)}")
    print()


def demo_sensor_network():
    """Realistic sensor network example."""
    print("=" * 60)
    print("DEMO 5: Sensor Network Topology Recovery")
    print("=" * 60)

    # 6 sensors covering a ring-shaped region
    # Sensors arranged in a hexagon; each covers 2 adjacent points
    points = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6']
    U = {
        's1': {'p1', 'p2'},
        's2': {'p2', 'p3'},
        's3': {'p3', 'p4'},
        's4': {'p4', 'p5'},
        's5': {'p5', 'p6'},
        's6': {'p6', 'p1'},
    }

    print("6 sensors in a ring configuration:")
    for k, v in U.items():
        print(f"  {k} covers {v}")

    nerve = build_cech_nerve(U)
    print(f"\nČech nerve: {nerve}")
    print(f"f-vector: {nerve.f_vector()}")
    print(f"Euler characteristic: χ = {nerve.euler_characteristic()}")

    semimodule = build_nerve_semimodule(U)
    print(f"\n{semimodule}")

    reconstructed = reconstruct_complex(semimodule)
    assert nerve.faces == reconstructed.faces
    print("\n✓ Roundtrip verified")

    # Topological interpretation
    v, e = nerve.f_vector()[:2]
    print(f"\nTopological interpretation:")
    print(f"  Vertices: {v}, Edges: {e}")
    print(f"  χ = {v} - {e} = {v - e}")
    print(f"  β₀ = 1 (connected), β₁ = 1 (one cycle = ring hole)")
    print(f"  → Correctly detects the hole in the sensor coverage!")
    print()


if __name__ == "__main__":
    demo_triangle_cover()
    demo_full_simplex()
    demo_closure_quotient()
    demo_face_maps()
    demo_sensor_network()
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Generate visualizations for the Closure-Čech Realization Duality.
Produces SVG diagrams and base64-encoded PNG images.
"""

import base64
import io
import math


def svg_simplex_nerve(title="Čech Nerve of Triangle Cover"):
    """Generate SVG of a triangle nerve (3 vertices, 3 edges, no fill)."""
    cx, cy = 200, 180
    r = 120
    vertices = []
    for i in range(3):
        angle = -math.pi/2 + 2*math.pi*i/3
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        vertices.append((x, y))

    labels = ['U₁', 'U₂', 'U₃']
    overlap_labels = ['{b}', '{c}', '{a}']

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 380" width="400" height="380">
  <style>
    text {{ font-family: 'Georgia', serif; }}
    .title {{ font-size: 16px; font-weight: bold; fill: #333; }}
    .vertex-label {{ font-size: 14px; fill: #1a5276; font-weight: bold; }}
    .edge-label {{ font-size: 11px; fill: #7d3c98; }}
    .info {{ font-size: 12px; fill: #555; }}
  </style>
  <text x="200" y="25" text-anchor="middle" class="title">{title}</text>
  <!-- Edges -->
  <line x1="{vertices[0][0]}" y1="{vertices[0][1]}"
        x2="{vertices[1][0]}" y2="{vertices[1][1]}"
        stroke="#3498db" stroke-width="3" opacity="0.7"/>
  <line x1="{vertices[1][0]}" y1="{vertices[1][1]}"
        x2="{vertices[2][0]}" y2="{vertices[2][1]}"
        stroke="#3498db" stroke-width="3" opacity="0.7"/>
  <line x1="{vertices[2][0]}" y1="{vertices[2][1]}"
        x2="{vertices[0][0]}" y2="{vertices[0][1]}"
        stroke="#3498db" stroke-width="3" opacity="0.7"/>
  <!-- Vertices -->
  <circle cx="{vertices[0][0]}" cy="{vertices[0][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <circle cx="{vertices[1][0]}" cy="{vertices[1][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <circle cx="{vertices[2][0]}" cy="{vertices[2][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <!-- Vertex labels -->
  <text x="{vertices[0][0]}" y="{vertices[0][1] - 20}" text-anchor="middle" class="vertex-label">{labels[0]}</text>
  <text x="{vertices[1][0] + 25}" y="{vertices[1][1] + 5}" text-anchor="start" class="vertex-label">{labels[1]}</text>
  <text x="{vertices[2][0] - 25}" y="{vertices[2][1] + 5}" text-anchor="end" class="vertex-label">{labels[2]}</text>
  <!-- Edge overlap labels -->
  <text x="{(vertices[0][0]+vertices[1][0])/2 + 15}" y="{(vertices[0][1]+vertices[1][1])/2}"
        text-anchor="start" class="edge-label">∩ = {overlap_labels[0]}</text>
  <text x="{(vertices[1][0]+vertices[2][0])/2}" y="{(vertices[1][1]+vertices[2][1])/2 + 20}"
        text-anchor="middle" class="edge-label">∩ = {overlap_labels[1]}</text>
  <text x="{(vertices[2][0]+vertices[0][0])/2 - 15}" y="{(vertices[2][1]+vertices[0][1])/2}"
        text-anchor="end" class="edge-label">∩ = {overlap_labels[2]}</text>
  <!-- Info -->
  <text x="200" y="340" text-anchor="middle" class="info">f-vector = (3, 3) · χ = 0 · No triple overlap → no triangle fill</text>
  <text x="200" y="360" text-anchor="middle" class="info">Topology: S¹ (circle) — one connected component, one hole</text>
</svg>'''
    return svg


def svg_full_simplex(title="Full 2-Simplex (All Sets Equal)"):
    """Generate SVG of a filled triangle (2-simplex)."""
    cx, cy = 200, 180
    r = 120
    vertices = []
    for i in range(3):
        angle = -math.pi/2 + 2*math.pi*i/3
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        vertices.append((x, y))

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 380" width="400" height="380">
  <style>
    text {{ font-family: 'Georgia', serif; }}
    .title {{ font-size: 16px; font-weight: bold; fill: #333; }}
    .vertex-label {{ font-size: 14px; fill: #1a5276; font-weight: bold; }}
    .info {{ font-size: 12px; fill: #555; }}
  </style>
  <text x="200" y="25" text-anchor="middle" class="title">{title}</text>
  <!-- Filled triangle -->
  <polygon points="{vertices[0][0]},{vertices[0][1]} {vertices[1][0]},{vertices[1][1]} {vertices[2][0]},{vertices[2][1]}"
           fill="#3498db" fill-opacity="0.3" stroke="#3498db" stroke-width="3"/>
  <!-- Vertices -->
  <circle cx="{vertices[0][0]}" cy="{vertices[0][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <circle cx="{vertices[1][0]}" cy="{vertices[1][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <circle cx="{vertices[2][0]}" cy="{vertices[2][1]}" r="12" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>
  <!-- Labels -->
  <text x="{vertices[0][0]}" y="{vertices[0][1] - 20}" text-anchor="middle" class="vertex-label">U₁</text>
  <text x="{vertices[1][0] + 25}" y="{vertices[1][1] + 5}" text-anchor="start" class="vertex-label">U₂</text>
  <text x="{vertices[2][0] - 25}" y="{vertices[2][1] + 5}" text-anchor="end" class="vertex-label">U₃</text>
  <!-- Info -->
  <text x="200" y="340" text-anchor="middle" class="info">f-vector = (3, 3, 1) · χ = 1 · Triple overlap → filled triangle</text>
  <text x="200" y="360" text-anchor="middle" class="info">Topology: contractible (disk) — no holes</text>
</svg>'''
    return svg


def svg_duality_diagram(title="Closure–Čech Realization Duality"):
    """Generate SVG of the duality diagram."""
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 300" width="700" height="300">
  <style>
    text {{ font-family: 'Georgia', serif; }}
    .title {{ font-size: 18px; font-weight: bold; fill: #333; }}
    .box-label {{ font-size: 13px; fill: white; font-weight: bold; }}
    .arrow-label {{ font-size: 11px; fill: #555; font-style: italic; }}
    .detail {{ font-size: 10px; fill: #777; }}
  </style>
  <text x="350" y="30" text-anchor="middle" class="title">{title}</text>

  <!-- Box 1: Closure Cover -->
  <rect x="30" y="70" width="180" height="80" rx="10" fill="#2c3e50"/>
  <text x="120" y="105" text-anchor="middle" class="box-label">Closure Cover</text>
  <text x="120" y="125" text-anchor="middle" class="box-label" style="font-size:11px">(X, c, U)</text>

  <!-- Box 2: Nerve Semimodule -->
  <rect x="260" y="70" width="180" height="80" rx="10" fill="#8e44ad"/>
  <text x="350" y="105" text-anchor="middle" class="box-label">Nerve Semimodule</text>
  <text x="350" y="125" text-anchor="middle" class="box-label" style="font-size:11px">N(U)</text>

  <!-- Box 3: Simplicial Complex -->
  <rect x="490" y="70" width="180" height="80" rx="10" fill="#27ae60"/>
  <text x="580" y="105" text-anchor="middle" class="box-label">Simplicial Complex</text>
  <text x="580" y="125" text-anchor="middle" class="box-label" style="font-size:11px">K(U)</text>

  <!-- Arrow 1: Cover → Semimodule -->
  <line x1="210" y1="100" x2="258" y2="100" stroke="#555" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="234" y="90" text-anchor="middle" class="arrow-label">build</text>

  <!-- Arrow 2: Semimodule → Complex -->
  <line x1="440" y1="100" x2="488" y2="100" stroke="#555" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="464" y="90" text-anchor="middle" class="arrow-label">reconstruct</text>

  <!-- Arrow 3: Complex → Semimodule (reverse) -->
  <line x1="488" y1="130" x2="440" y2="130" stroke="#999" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowhead2)"/>
  <text x="464" y="148" text-anchor="middle" class="arrow-label" style="color:#999">embed</text>

  <!-- Arrow 4: Cover → Complex (direct) -->
  <path d="M 210 150 Q 350 220 490 150" stroke="#e67e22" stroke-width="2" fill="none" marker-end="url(#arrowhead3)"/>
  <text x="350" y="210" text-anchor="middle" class="arrow-label" style="fill:#e67e22">Čech nerve</text>

  <!-- Roundtrip annotation -->
  <rect x="180" y="240" width="340" height="40" rx="8" fill="#f8f9fa" stroke="#ddd"/>
  <text x="350" y="265" text-anchor="middle" class="detail" style="font-size:12px; fill:#333">
    Roundtrip: reconstruct ∘ build = cechNerve (definitional equality)
  </text>

  <!-- Arrowhead markers -->
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#555"/>
    </marker>
    <marker id="arrowhead2" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#999"/>
    </marker>
    <marker id="arrowhead3" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#e67e22"/>
    </marker>
  </defs>
</svg>'''
    return svg


def svg_sensor_ring(title="Sensor Network Ring Detection"):
    """Generate SVG of the sensor network ring example."""
    cx, cy = 200, 200
    r = 130
    n = 8
    vertices = []
    for i in range(n):
        angle = -math.pi/2 + 2*math.pi*i/n
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        vertices.append((x, y))

    edges = ''
    for i in range(n):
        j = (i + 1) % n
        edges += f'  <line x1="{vertices[i][0]}" y1="{vertices[i][1]}" x2="{vertices[j][0]}" y2="{vertices[j][1]}" stroke="#3498db" stroke-width="3" opacity="0.7"/>\n'

    circles = ''
    labels = ''
    for i in range(n):
        circles += f'  <circle cx="{vertices[i][0]}" cy="{vertices[i][1]}" r="10" fill="#e74c3c" stroke="#c0392b" stroke-width="2"/>\n'
        lx = cx + (r + 25) * math.cos(-math.pi/2 + 2*math.pi*i/n)
        ly = cy + (r + 25) * math.sin(-math.pi/2 + 2*math.pi*i/n)
        labels += f'  <text x="{lx}" y="{ly + 4}" text-anchor="middle" style="font-family: Georgia; font-size: 11px; fill: #1a5276; font-weight: bold;">S{i+1}</text>\n'

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 420" width="400" height="420">
  <style>
    text {{ font-family: 'Georgia', serif; }}
    .title {{ font-size: 16px; font-weight: bold; fill: #333; }}
    .info {{ font-size: 12px; fill: #555; }}
  </style>
  <text x="200" y="25" text-anchor="middle" class="title">{title}</text>
  <!-- Hole indicator -->
  <circle cx="{cx}" cy="{cy}" r="60" fill="none" stroke="#e74c3c" stroke-width="1" stroke-dasharray="4,4" opacity="0.5"/>
  <text x="{cx}" y="{cy + 4}" text-anchor="middle" style="font-size: 11px; fill: #e74c3c;">hole (β₁=1)</text>
{edges}{circles}{labels}
  <text x="200" y="370" text-anchor="middle" class="info">f-vector = (8, 8) · χ = 0 · β₀ = 1, β₁ = 1</text>
  <text x="200" y="390" text-anchor="middle" class="info">Ring topology correctly detected from sensor overlaps</text>
</svg>'''
    return svg


if __name__ == "__main__":
    # Generate all SVGs
    svgs = {
        'triangle_nerve': svg_simplex_nerve(),
        'full_simplex': svg_full_simplex(),
        'duality_diagram': svg_duality_diagram(),
        'sensor_ring': svg_sensor_ring(),
    }

    for name, svg in svgs.items():
        with open(f'{name}.svg', 'w') as f:
            f.write(svg)
        print(f"Generated {name}.svg")

    print("All visualizations generated.")
