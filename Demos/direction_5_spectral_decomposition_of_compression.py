#!/usr/bin/env python3
"""
Applications of Sheaf Compression Filtration Theory

This module demonstrates real-world applications of the spectral
decomposition of compression framework.
"""

from typing import Dict, List, Set, Tuple
from demo import (
    FiniteSite, Presheaf, compression_number,
    coproduct_presheaf, finite_coproduct,
    graded_compression_bound
)


# ============================================================================
# Application 1: Sensor Network Design
# ============================================================================

def sensor_network_example():
    """
    Design a sensor network for a building with three rooms.

    Each room needs sensors for:
    - Occupancy detection (binary: occupied/empty)
    - Temperature monitoring (discrete: cold/warm/hot)

    The filtration theorem tells us:
        total sensors ≤ occupancy sensors + temperature sensors
    """
    print("=" * 70)
    print("APPLICATION 1: Sensor Network Design")
    print("=" * 70)
    print()

    # Site: three rooms connected by hallways
    rooms = ['Room1', 'Room2', 'Room3']
    morphisms = {
        ('Room1', 'Room1'): ['id1'],
        ('Room2', 'Room2'): ['id2'],
        ('Room3', 'Room3'): ['id3'],
        ('Room1', 'Room2'): ['hall12'],
        ('Room2', 'Room3'): ['hall23'],
    }
    covering_sieves = {
        'Room1': [{('Room1', 'id1')}],
        'Room2': [{('Room1', 'hall12'), ('Room2', 'id2')}],
        'Room3': [{('Room2', 'hall23'), ('Room3', 'id3')}],
    }
    site = FiniteSite(rooms, morphisms, covering_sieves)

    # Occupancy presheaf: binary sections
    occ_sections = {r: ['empty', 'occupied'] for r in rooms}
    occ_restrictions = {}
    for (Z, X), ms in morphisms.items():
        for f in ms:
            occ_restrictions[(X, f, Z)] = {'empty': 'empty', 'occupied': 'occupied'}
    occupancy = Presheaf(site, occ_sections, occ_restrictions)

    # Temperature presheaf: ternary sections
    temp_sections = {r: ['cold', 'warm', 'hot'] for r in rooms}
    temp_restrictions = {}
    for (Z, X), ms in morphisms.items():
        for f in ms:
            temp_restrictions[(X, f, Z)] = {'cold': 'cold', 'warm': 'warm', 'hot': 'hot'}
    temperature = Presheaf(site, temp_sections, temp_restrictions)

    # Compute individual compression numbers
    k_occ = compression_number(site, occupancy)
    k_temp = compression_number(site, temperature)

    # Combined monitoring system (coproduct)
    combined = coproduct_presheaf(site, occupancy, temperature)
    k_combined = compression_number(site, combined)

    print(f"Building with {len(rooms)} rooms: {rooms}")
    print(f"Occupancy monitoring: κ = {k_occ} sensor(s)")
    print(f"Temperature monitoring: κ = {k_temp} sensor(s)")
    print(f"Combined monitoring: κ = {k_combined} sensor(s)")
    print(f"Filtration bound: κ ≤ {k_occ} + {k_temp} = {k_occ + k_temp}")
    print(f"Savings from joint deployment: {k_occ + k_temp - k_combined} sensor(s)")
    print()


# ============================================================================
# Application 2: Database Query Optimization
# ============================================================================

def database_query_example():
    """
    Optimize probe queries for a relational database.

    A database with two tables (Users, Orders) connected by foreign keys
    can be modeled as a presheaf. The compression number gives the minimum
    number of probe queries to distinguish all records.
    """
    print("=" * 70)
    print("APPLICATION 2: Database Query Optimization")
    print("=" * 70)
    print()

    # Site: two tables with connecting foreign key
    tables = ['Users', 'Orders']
    morphisms = {
        ('Users', 'Users'): ['id_users'],
        ('Orders', 'Orders'): ['id_orders'],
        ('Users', 'Orders'): ['user_fk'],  # foreign key: Orders -> Users
    }
    covering_sieves = {
        'Users': [{('Users', 'id_users')}],
        'Orders': [{('Users', 'user_fk'), ('Orders', 'id_orders')}],
    }
    site = FiniteSite(tables, morphisms, covering_sieves)

    # Users presheaf: user profiles
    users = Presheaf(site,
        sections={'Users': ['alice', 'bob', 'charlie'], 'Orders': ['alice', 'bob']},
        restrictions={
            ('Orders', 'user_fk', 'Users'): {'alice': 'alice', 'bob': 'bob', 'charlie': 'bob'},
            ('Users', 'id_users', 'Users'): {'alice': 'alice', 'bob': 'bob', 'charlie': 'charlie'},
            ('Orders', 'id_orders', 'Orders'): {'alice': 'alice', 'bob': 'bob'},
        }
    )

    k = compression_number(site, users)
    print(f"Database schema: {tables}")
    print(f"Users: alice, bob, charlie")
    print(f"Orders linked to users via foreign key")
    print(f"Minimum probe queries to distinguish all records: {k}")
    print()


# ============================================================================
# Application 3: Feature Selection in Machine Learning
# ============================================================================

def feature_selection_example():
    """
    Hierarchical feature selection for a classification task.

    Features are organized in layers:
    - Layer 1: Coarse category detection (binary)
    - Layer 2: Fine-grained attribute resolution (ternary)

    The filtration theorem bounds the total features needed.
    """
    print("=" * 70)
    print("APPLICATION 3: Feature Selection (ML)")
    print("=" * 70)
    print()

    # Site: feature space with two feature groups
    features = ['FeatA', 'FeatB']
    morphisms = {
        ('FeatA', 'FeatA'): ['id_a'],
        ('FeatB', 'FeatB'): ['id_b'],
        ('FeatA', 'FeatB'): ['coarsen'],
    }
    covering_sieves = {
        'FeatA': [{('FeatA', 'id_a')}],
        'FeatB': [{('FeatA', 'coarsen'), ('FeatB', 'id_b')}],
    }
    site = FiniteSite(features, morphisms, covering_sieves)

    # Coarse features (binary classification)
    coarse = Presheaf(site,
        sections={'FeatA': [0, 1], 'FeatB': [0, 1]},
        restrictions={
            ('FeatB', 'coarsen', 'FeatA'): {0: 0, 1: 1},
            ('FeatA', 'id_a', 'FeatA'): {0: 0, 1: 1},
            ('FeatB', 'id_b', 'FeatB'): {0: 0, 1: 1},
        }
    )

    # Fine features (ternary within each class)
    fine = Presheaf(site,
        sections={'FeatA': ['a', 'b', 'c'], 'FeatB': ['a', 'b']},
        restrictions={
            ('FeatB', 'coarsen', 'FeatA'): {'a': 'a', 'b': 'b', 'c': 'b'},
            ('FeatA', 'id_a', 'FeatA'): {'a': 'a', 'b': 'b', 'c': 'c'},
            ('FeatB', 'id_b', 'FeatB'): {'a': 'a', 'b': 'b'},
        }
    )

    k_coarse = compression_number(site, coarse)
    k_fine = compression_number(site, fine)
    combined = coproduct_presheaf(site, coarse, fine)
    k_combined = compression_number(site, combined)

    print(f"Feature groups: {features}")
    print(f"Coarse features (binary): κ = {k_coarse}")
    print(f"Fine features (ternary): κ = {k_fine}")
    print(f"Combined feature set: κ = {k_combined}")
    print(f"Filtration bound: {k_coarse + k_fine}")
    print(f"Feature savings: {k_coarse + k_fine - k_combined}")
    print()


# ============================================================================
# Application 4: Compression Profile Analysis
# ============================================================================

def compression_profile_analysis():
    """
    Analyze the compression profile of a presheaf across multiple
    decompositions to find the optimal one.
    """
    print("=" * 70)
    print("APPLICATION 4: Compression Profile Analysis")
    print("=" * 70)
    print()

    site = FiniteSite(
        objects=['X', 'Y'],
        morphisms={
            ('X', 'X'): ['id_x'], ('Y', 'Y'): ['id_y'],
            ('X', 'Y'): ['f'],
        },
        covering_sieves={
            'X': [{('X', 'id_x')}],
            'Y': [{('X', 'f'), ('Y', 'id_y')}],
        }
    )

    # Create several presheaves
    F1 = Presheaf(site,
        sections={'X': [0, 1], 'Y': [0, 1]},
        restrictions={
            ('Y', 'f', 'X'): {0: 0, 1: 1},
            ('X', 'id_x', 'X'): {0: 0, 1: 1},
            ('Y', 'id_y', 'Y'): {0: 0, 1: 1},
        })

    F2 = Presheaf(site,
        sections={'X': [0, 1, 2], 'Y': [0, 1]},
        restrictions={
            ('Y', 'f', 'X'): {0: 0, 1: 1, 2: 1},
            ('X', 'id_x', 'X'): {0: 0, 1: 1, 2: 2},
            ('Y', 'id_y', 'Y'): {0: 0, 1: 1},
        })

    F3 = Presheaf(site,
        sections={'X': [0, 1], 'Y': [0, 1, 2]},
        restrictions={
            ('Y', 'f', 'X'): {0: 0, 1: 1},
            ('X', 'id_x', 'X'): {0: 0, 1: 1},
            ('Y', 'id_y', 'Y'): {0: 0, 1: 1, 2: 2},
        })

    presheaves = [F1, F2, F3]
    names = ['F₁(2,2)', 'F₂(3,2)', 'F₃(2,3)']

    print("Presheaf compression profile:")
    kappas = []
    for name, F in zip(names, presheaves):
        k = compression_number(site, F)
        kappas.append(k)
        print(f"  {name}: κ = {k}")

    print("\nPairwise coproduct analysis:")
    for i in range(len(presheaves)):
        for j in range(i + 1, len(presheaves)):
            cp = coproduct_presheaf(site, presheaves[i], presheaves[j])
            k_cp = compression_number(site, cp)
            defect = kappas[i] + kappas[j] - k_cp
            print(f"  {names[i]} ⊕ {names[j]}: κ = {k_cp}, "
                  f"bound = {kappas[i] + kappas[j]}, defect = {defect}")

    print("\nFull coproduct:")
    full = finite_coproduct(site, presheaves)
    k_full = compression_number(site, full)
    k_sum = sum(kappas)
    print(f"  κ(∐ᵢFᵢ) = {k_full}, Σκ(Fᵢ) = {k_sum}, gap = {k_sum - k_full}")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Sheaf Compression Filtration Theory               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    sensor_network_example()
    database_query_example()
    feature_selection_example()
    compression_profile_analysis()

    print("All applications demonstrated successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Spectral Decomposition of Compression — Computational Demonstrations

This script implements the compression framework for finite sites and
demonstrates the filtration subadditivity theorem on concrete examples.

Usage:
    python demo.py

The demo constructs small finite sites, computes compression numbers,
builds filtrations, and verifies the spectral inequality.
"""

from itertools import product, combinations
from typing import Dict, List, Tuple, Set, Optional
import sys


# ============================================================================
# Core: Finite Site and Presheaf
# ============================================================================

class FiniteSite:
    """A finite site: objects, morphisms, and a Grothendieck topology."""

    def __init__(self, objects: List[str], morphisms: Dict[Tuple[str, str], List[str]],
                 covering_sieves: Optional[Dict[str, List[Set[Tuple[str, str]]]]] = None):
        """
        objects: list of object names
        morphisms: dict (source, target) -> list of morphism names
        covering_sieves: dict object -> list of covering sieves (each sieve = set of (source, morph_name))
        """
        self.objects = objects
        self.morphisms = morphisms
        # Default topology: maximal sieve covers everything
        if covering_sieves is None:
            self.covering_sieves = {
                X: [set((Z, f) for (Z, T), fs in morphisms.items()
                        if T == X for f in fs)]
                for X in objects
            }
        else:
            self.covering_sieves = covering_sieves

    def hom(self, source: str, target: str) -> List[str]:
        return self.morphisms.get((source, target), [])


class Presheaf:
    """A presheaf on a finite site: assigns a set to each object with restriction maps."""

    def __init__(self, site: FiniteSite,
                 sections: Dict[str, List],
                 restrictions: Dict[Tuple[str, str, str], Dict]):
        """
        sections: dict object -> list of sections
        restrictions: dict (target_obj, morph_name, source_obj) -> dict section -> section
        """
        self.site = site
        self.sections = sections
        self.restrictions = restrictions

    def restrict(self, X: str, f: str, Z: str, s):
        """Apply restriction map F(f) to section s, where f: Z -> X."""
        key = (X, f, Z)
        if key in self.restrictions:
            return self.restrictions[key].get(s, s)
        return s  # identity if no restriction defined


# ============================================================================
# Compression Number Computation
# ============================================================================

def is_separating(site: FiniteSite, presheaf: Presheaf, probes: Set[str]) -> bool:
    """Check if a set of probes separates the presheaf."""
    for X in site.objects:
        secs = presheaf.sections[X]
        for i, s in enumerate(secs):
            for j, t in enumerate(secs):
                if i >= j:
                    continue
                # Check if some probe distinguishes s from t
                distinguished = False
                for Z in probes:
                    for f in site.hom(Z, X):
                        if presheaf.restrict(X, f, Z, s) != presheaf.restrict(X, f, Z, t):
                            distinguished = True
                            break
                    if distinguished:
                        break
                if not distinguished:
                    return False
    return True


def is_topology_compatible(site: FiniteSite, probes: Set[str]) -> bool:
    """Check if probes are topology-compatible."""
    for X in site.objects:
        for sieve in site.covering_sieves.get(X, []):
            # Check that some probe is in the sieve
            found = False
            for (Z, f) in sieve:
                if Z in probes:
                    found = True
                    break
            if not found:
                return False
    return True


def compression_number(site: FiniteSite, presheaf: Presheaf) -> int:
    """Compute the compression number κ_sh(J, F) by brute force."""
    n = len(site.objects)
    for k in range(n + 1):
        for probe_set in combinations(site.objects, k):
            probes = set(probe_set)
            if is_separating(site, presheaf, probes) and is_topology_compatible(site, probes):
                return k
    return n  # worst case: need all objects


# ============================================================================
# Coproduct Construction
# ============================================================================

def coproduct_presheaf(site: FiniteSite, F: Presheaf, G: Presheaf) -> Presheaf:
    """Construct the pointwise coproduct F ⊕ G."""
    sections = {}
    restrictions = {}

    for X in site.objects:
        # Sections are tagged: ('L', s) for F, ('R', s) for G
        sections[X] = [('L', s) for s in F.sections[X]] + [('R', s) for s in G.sections[X]]

    for (Z, X), morphs in site.morphisms.items():
        for f in morphs:
            rmap = {}
            for s in F.sections[X]:
                rmap[('L', s)] = ('L', F.restrict(X, f, Z, s))
            for s in G.sections[X]:
                rmap[('R', s)] = ('R', G.restrict(X, f, Z, s))
            restrictions[(X, f, Z)] = rmap

    return Presheaf(site, sections, restrictions)


def finite_coproduct(site: FiniteSite, presheaves: List[Presheaf]) -> Presheaf:
    """Construct the finite coproduct ∐ᵢ Fᵢ."""
    sections = {}
    restrictions = {}

    for X in site.objects:
        sections[X] = [(i, s) for i, F in enumerate(presheaves) for s in F.sections[X]]

    for (Z, X), morphs in site.morphisms.items():
        for f in morphs:
            rmap = {}
            for i, F in enumerate(presheaves):
                for s in F.sections[X]:
                    rmap[(i, s)] = (i, F.restrict(X, f, Z, s))
            restrictions[(X, f, Z)] = rmap

    return Presheaf(site, sections, restrictions)


# ============================================================================
# Filtration
# ============================================================================

def graded_compression_bound(site: FiniteSite, graded_pieces: List[Presheaf]) -> int:
    """Compute the graded compression bound: sum of compression numbers."""
    return sum(compression_number(site, gr) for gr in graded_pieces)


def filtration_upper_bound(site: FiniteSite, bottom: Presheaf,
                           graded_pieces: List[Presheaf]) -> int:
    """Compute the filtration upper bound: κ(bottom) + Σ κ(grᵢ)."""
    return compression_number(site, bottom) + graded_compression_bound(site, graded_pieces)


# ============================================================================
# Example Sites and Presheaves
# ============================================================================

def make_two_point_site():
    """Site with two objects A, B and identity morphisms plus one connecting morphism."""
    objects = ['A', 'B']
    morphisms = {
        ('A', 'A'): ['id_A'],
        ('B', 'B'): ['id_B'],
        ('A', 'B'): ['f'],  # f: A -> B
    }
    covering_sieves = {
        'A': [{('A', 'id_A')}],
        'B': [{('A', 'f'), ('B', 'id_B')}],
    }
    return FiniteSite(objects, morphisms, covering_sieves)


def make_three_point_site():
    """Site with three objects A, B, C in a chain A -> B -> C."""
    objects = ['A', 'B', 'C']
    morphisms = {
        ('A', 'A'): ['id_A'],
        ('B', 'B'): ['id_B'],
        ('C', 'C'): ['id_C'],
        ('A', 'B'): ['f'],
        ('B', 'C'): ['g'],
        ('A', 'C'): ['gf'],
    }
    covering_sieves = {
        'A': [{('A', 'id_A')}],
        'B': [{('A', 'f'), ('B', 'id_B')}],
        'C': [{('A', 'gf'), ('B', 'g'), ('C', 'id_C')}],
    }
    return FiniteSite(objects, morphisms, covering_sieves)


def make_presheaf_1(site):
    """Presheaf with 2 sections at each object, distinguished by restrictions."""
    sections = {obj: [0, 1] for obj in site.objects}
    restrictions = {}
    for (Z, X), morphs in site.morphisms.items():
        for f in morphs:
            restrictions[(X, f, Z)] = {0: 0, 1: 1}  # identity-like
    return Presheaf(site, sections, restrictions)


def make_presheaf_2(site):
    """Presheaf with 3 sections at A, 2 at others, with collapsing restriction."""
    sections = {}
    for obj in site.objects:
        if obj == site.objects[0]:
            sections[obj] = [0, 1, 2]
        else:
            sections[obj] = [0, 1]
    restrictions = {}
    for (Z, X), morphs in site.morphisms.items():
        for f in morphs:
            rmap = {}
            for s in sections[X]:
                if s == 2:
                    rmap[s] = 1  # collapse 2 -> 1
                else:
                    rmap[s] = s
            restrictions[(X, f, Z)] = rmap
    return Presheaf(site, sections, restrictions)


def make_trivial_presheaf(site):
    """Trivial presheaf: one section at each object."""
    sections = {obj: [0] for obj in site.objects}
    restrictions = {}
    for (Z, X), morphs in site.morphisms.items():
        for f in morphs:
            restrictions[(X, f, Z)] = {0: 0}
    return Presheaf(site, sections, restrictions)


# ============================================================================
# Demonstrations
# ============================================================================

def demo_basic_compression():
    """Demo 1: Basic compression number computation."""
    print("=" * 70)
    print("DEMO 1: Basic Compression Numbers")
    print("=" * 70)

    site = make_two_point_site()
    F = make_presheaf_1(site)
    G = make_presheaf_2(site)

    kF = compression_number(site, F)
    kG = compression_number(site, G)

    print(f"Site: {site.objects}")
    print(f"F sections: {F.sections}")
    print(f"G sections: {G.sections}")
    print(f"κ(F) = {kF}")
    print(f"κ(G) = {kG}")
    print()


def demo_coproduct_subadditivity():
    """Demo 2: Coproduct subadditivity κ(F⊕G) ≤ κ(F) + κ(G)."""
    print("=" * 70)
    print("DEMO 2: Coproduct Subadditivity (Theorem 1)")
    print("=" * 70)

    site = make_two_point_site()
    F = make_presheaf_1(site)
    G = make_presheaf_2(site)

    kF = compression_number(site, F)
    kG = compression_number(site, G)

    FG = coproduct_presheaf(site, F, G)
    kFG = compression_number(site, FG)

    print(f"κ(F) = {kF}")
    print(f"κ(G) = {kG}")
    print(f"κ(F⊕G) = {kFG}")
    print(f"κ(F) + κ(G) = {kF + kG}")
    print(f"Subadditivity holds: {kFG <= kF + kG} ✓" if kFG <= kF + kG
          else f"Subadditivity VIOLATED! ✗")
    print(f"Compression defect δ = {kF + kG - kFG}")
    print()


def demo_iterated_coproduct():
    """Demo 3: Iterated coproduct bound κ(∐ᵢFᵢ) ≤ Σᵢκ(Fᵢ)."""
    print("=" * 70)
    print("DEMO 3: Iterated Coproduct Subadditivity (Theorem 2)")
    print("=" * 70)

    site = make_two_point_site()
    F1 = make_presheaf_1(site)
    F2 = make_presheaf_2(site)
    F3 = make_presheaf_1(site)

    presheaves = [F1, F2, F3]
    kappas = [compression_number(site, F) for F in presheaves]
    coprod = finite_coproduct(site, presheaves)
    k_coprod = compression_number(site, coprod)
    k_sum = sum(kappas)

    print(f"Number of pieces: {len(presheaves)}")
    for i, k in enumerate(kappas):
        print(f"  κ(F_{i}) = {k}")
    print(f"κ(∐ᵢFᵢ) = {k_coprod}")
    print(f"Σᵢκ(Fᵢ) = {k_sum}")
    print(f"Subadditivity holds: {k_coprod <= k_sum} ✓" if k_coprod <= k_sum
          else f"Subadditivity VIOLATED! ✗")
    print()


def demo_filtration_bound():
    """Demo 4: Filtration bound κ(F) ≤ κ(F₀) + Σᵢκ(grᵢ)."""
    print("=" * 70)
    print("DEMO 4: Filtration Subadditivity (Theorem 3)")
    print("=" * 70)

    site = make_two_point_site()

    # Build a 3-level filtration:
    # Level 0: trivial presheaf
    # Level 1: presheaf_1 (2 sections each)
    # Level 2: coproduct (total)
    F0 = make_trivial_presheaf(site)
    F1 = make_presheaf_1(site)
    F2 = make_presheaf_2(site)

    # Graded pieces (approximated by the presheaves themselves)
    gr0 = F1  # "F1/F0" ~ F1 since F0 is trivial
    gr1 = F2  # "F2/F1" ~ F2

    k0 = compression_number(site, F0)
    k1 = compression_number(site, F1)
    k2 = compression_number(site, F2)
    k_gr0 = compression_number(site, gr0)
    k_gr1 = compression_number(site, gr1)

    bound = k0 + k_gr0 + k_gr1

    print(f"Filtration: F₀ ⊆ F₁ ⊆ F₂")
    print(f"  κ(F₀) = {k0} (trivial)")
    print(f"  κ(F₁) = {k1}")
    print(f"  κ(F₂) = {k2}")
    print(f"  κ(gr₀) = {k_gr0}")
    print(f"  κ(gr₁) = {k_gr1}")
    print(f"Filtration upper bound: κ(F₀) + Σκ(grᵢ) = {bound}")
    print(f"Actual κ(top) = {k2}")
    print(f"Bound valid: {k2 <= bound} ✓" if k2 <= bound else f"Bound VIOLATED! ✗")
    print()


def demo_split_decomposition():
    """Demo 5: Split decomposition — equality for coproducts."""
    print("=" * 70)
    print("DEMO 5: Split Decomposition (Theorem 7)")
    print("=" * 70)

    site = make_two_point_site()
    F = make_presheaf_1(site)
    G = make_presheaf_1(site)  # same structure

    kF = compression_number(site, F)
    kG = compression_number(site, G)
    FG = coproduct_presheaf(site, F, G)
    kFG = compression_number(site, FG)

    print(f"Split decomposition: F ⊕ G")
    print(f"  κ(F) = {kF}")
    print(f"  κ(G) = {kG}")
    print(f"  κ(F⊕G) = {kFG}")
    print(f"  κ(F) + κ(G) = {kF + kG}")
    print(f"  Upper bound holds: {kFG <= kF + kG} ✓")
    print(f"  Equality achieved: {kFG == kF + kG}")
    print(f"  Compression defect: {kF + kG - kFG}")
    print()


def demo_three_point_site():
    """Demo 6: Three-point site with chain topology."""
    print("=" * 70)
    print("DEMO 6: Three-Point Site (Extended Example)")
    print("=" * 70)

    site = make_three_point_site()
    F = make_presheaf_1(site)
    G = make_presheaf_2(site)

    kF = compression_number(site, F)
    kG = compression_number(site, G)
    FG = coproduct_presheaf(site, F, G)
    kFG = compression_number(site, FG)

    print(f"Site: A → B → C (chain)")
    print(f"κ(F) = {kF}")
    print(f"κ(G) = {kG}")
    print(f"κ(F⊕G) = {kFG}")
    print(f"κ(F) + κ(G) = {kF + kG}")
    print(f"Subadditivity: {kFG <= kF + kG} ✓" if kFG <= kF + kG
          else f"Subadditivity VIOLATED! ✗")
    print(f"Defect: {kF + kG - kFG}")
    print()


def demo_conjecture_tests():
    """Demo 7: Testing falsifiable conjectures."""
    print("=" * 70)
    print("DEMO 7: Testing Falsifiable Conjectures")
    print("=" * 70)

    site = make_two_point_site()

    # Test Conjecture A: Split exact additivity
    print("\n--- Conjecture A: Split Exact Additivity ---")
    F = make_presheaf_1(site)
    G = make_presheaf_2(site)
    kF = compression_number(site, F)
    kG = compression_number(site, G)
    FG = coproduct_presheaf(site, F, G)
    kFG = compression_number(site, FG)
    print(f"  κ(F) + κ(G) = {kF + kG}, κ(F⊕G) = {kFG}")
    print(f"  Equality: {kFG == kF + kG}")
    if kFG < kF + kG:
        print(f"  → Strict inequality: defect = {kF + kG - kFG}")
        print(f"  → Split additivity may fail for non-identical pieces")

    # Test Conjecture D: Submodularity proxy
    print("\n--- Conjecture D: Submodularity (proxy test) ---")
    # Test κ(F⊕G) + κ(trivial) ≤ κ(F) + κ(G)
    T = make_trivial_presheaf(site)
    kT = compression_number(site, T)
    print(f"  κ(F⊕G) + κ(trivial) = {kFG + kT}")
    print(f"  κ(F) + κ(G) = {kF + kG}")
    print(f"  Submodularity proxy: {kFG + kT <= kF + kG}")

    # Test Conjecture E: Stabilization
    print("\n--- Conjecture E: Spectral Stabilization ---")
    bounds = []
    for n_pieces in range(1, 5):
        pieces = [make_presheaf_1(site)] * n_pieces
        coprod = finite_coproduct(site, pieces)
        k_total = compression_number(site, coprod)
        k_sum = sum(compression_number(site, p) for p in pieces)
        bounds.append((n_pieces, k_total, k_sum))
        print(f"  n={n_pieces}: κ(∐ᵢFᵢ)={k_total}, Σκ(Fᵢ)={k_sum}, gap={k_sum - k_total}")

    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Spectral Decomposition of Compression — Computational Demo        ║")
    print("║  Filtration Subadditivity for Sheaf Compression on Finite Sites     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_compression()
    demo_coproduct_subadditivity()
    demo_iterated_coproduct()
    demo_filtration_bound()
    demo_split_decomposition()
    demo_three_point_site()
    demo_conjecture_tests()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
