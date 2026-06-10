#!/usr/bin/env python3
"""
Applications of Generator Complexity Theory

This module demonstrates real-world applications of the categorical
compression framework:

1. Database Normalization — categorical normalization as generator compression
2. Signal Dictionary Learning — presheaf generators as dictionary atoms
3. Sensor Network Optimization — probe families as sensor placement
4. Error-Correcting Code Design — codebook complexity from categorical structure

Each application constructs a concrete finite category and presheaf
modeling the domain, then applies the compression algorithms.
"""

from typing import Dict, List, Tuple, Set
from algorithms import (
    FiniteCategory, Presheaf, full_analysis, naive_generators,
    greedy_compress, is_generating
)


# ──────────────────────────────────────────────────────────────────────
# Application 1: Database Normalization
# ──────────────────────────────────────────────────────────────────────

def database_normalization_demo():
    """
    Model a database schema as a presheaf on a category of tables.

    Objects = tables (schemas)
    Morphisms = foreign key projections
    F(table) = set of records
    F(projection) = the actual projection map

    Generator compression = removing records that are determined by
    foreign key constraints (database normalization).
    """
    print("\n" + "="*60)
    print("APPLICATION 1: Database Normalization")
    print("="*60)

    print("""
Scenario: A company database with three tables:
  - Employees: (emp_id, name, dept_id)
  - Departments: (dept_id, dept_name)
  - Projects: (proj_id, dept_id, budget)

Foreign keys create morphisms:
  - Employees -> Departments (via dept_id)
  - Projects -> Departments (via dept_id)

This forms a "span" category: Emp <- Dept -> Proj
But in the presheaf (contravariant), the arrows reverse.
""")

    # Category: Dept -> Emp, Dept -> Proj (in the category)
    # Presheaf goes backward: F(Dept->Emp) : F(Emp) -> F(Dept)
    cat = FiniteCategory(
        objects=["Emp", "Dept", "Proj"],
        morphisms={
            ("Emp", "Emp"): ["id_Emp"],
            ("Dept", "Dept"): ["id_Dept"],
            ("Proj", "Proj"): ["id_Proj"],
            ("Emp", "Dept"): ["dept_of_emp"],
            ("Proj", "Dept"): ["dept_of_proj"],
        },
        composition={
            ("id_Emp", "id_Emp"): "id_Emp",
            ("id_Dept", "id_Dept"): "id_Dept",
            ("id_Proj", "id_Proj"): "id_Proj",
            ("id_Emp", "dept_of_emp"): "dept_of_emp",
            ("dept_of_emp", "id_Dept"): "dept_of_emp",
            ("id_Proj", "dept_of_proj"): "dept_of_proj",
            ("dept_of_proj", "id_Dept"): "dept_of_proj",
        },
        identities={"Emp": "id_Emp", "Dept": "id_Dept", "Proj": "id_Proj"}
    )

    # Fiber data (records)
    fibers = {
        "Emp": ["alice_eng", "bob_eng", "carol_mkt"],
        "Dept": ["engineering", "marketing"],
        "Proj": ["website_eng", "ads_mkt"],
    }

    # Restriction maps (projections)
    restriction = {
        "id_Emp": {e: e for e in fibers["Emp"]},
        "id_Dept": {d: d for d in fibers["Dept"]},
        "id_Proj": {p: p for p in fibers["Proj"]},
        # dept_of_emp: F(Dept) -> F(Emp) — maps dept to the dept field of emp
        # Actually, F(dept_of_emp): F(Dept) -> F(Emp) doesn't make sense as a function
        # In the presheaf model: F(f): F(target) -> F(source)
        # f: Emp -> Dept, so F(f): F(Dept) -> F(Emp)
        # But this should be: given a dept, which emp records have that dept?
        # Actually for the presheaf to be well-defined, F(f) must be a function.
        # We model it differently: let F be the presheaf where F(X) are "tuples visible at X"
        "dept_of_emp": {
            "engineering": "alice_eng",  # restricting "engineering" to Emp table
            "marketing": "carol_mkt",
        },
        "dept_of_proj": {
            "engineering": "website_eng",
            "marketing": "ads_mkt",
        },
    }

    psh = Presheaf(cat, fibers, restriction)
    report = full_analysis(psh)

    print(f"Fiber sizes: Emp={psh.fiber_size('Emp')}, "
          f"Dept={psh.fiber_size('Dept')}, Proj={psh.fiber_size('Proj')}")
    print(f"Total records (naive): {report.total_fiber_sum}")
    print(f"After normalization:   {report.compressed_count}")
    print(f"Minimum records:       {report.minimum_count}")
    print(f"Compression ratio:     {report.compression_ratio:.1%}")

    if report.has_redundancy:
        print("\nRedundant records found (determined by foreign keys):")
        for r in report.redundancies:
            print(f"  '{r.target_elem}' in {r.target_obj} is determined by "
                  f"'{r.source_elem}' in {r.source_obj} via {r.morphism}")

    print("\nInterpretation: Records determined by foreign key projections")
    print("need not be stored independently — this is categorical normalization.")


# ──────────────────────────────────────────────────────────────────────
# Application 2: Signal Dictionary Learning
# ──────────────────────────────────────────────────────────────────────

def dictionary_learning_demo():
    """
    Model signal dictionary learning as presheaf generator optimization.

    Objects = observation scales/resolutions
    Morphisms = downsampling/coarsening maps
    F(scale) = set of possible signal values at that scale
    Generators = dictionary atoms

    The generator complexity g(F) is the minimum dictionary size.
    """
    print("\n" + "="*60)
    print("APPLICATION 2: Signal Dictionary Learning")
    print("="*60)

    print("""
Scenario: A multi-resolution signal analysis system with 3 scales:
  - Fine: 4 possible signal patterns
  - Medium: 3 possible patterns (some fine patterns merge)
  - Coarse: 2 possible patterns

Downsampling morphisms: Fine -> Medium -> Coarse
A dictionary atom at the fine scale can generate patterns at coarser scales
via downsampling. This is analogous to wavelet atoms generating coefficients
at multiple scales.
""")

    cat = FiniteCategory(
        objects=["Fine", "Medium", "Coarse"],
        morphisms={
            ("Fine", "Fine"): ["id_F"],
            ("Medium", "Medium"): ["id_M"],
            ("Coarse", "Coarse"): ["id_C"],
            ("Fine", "Medium"): ["downsample_FM"],
            ("Medium", "Coarse"): ["downsample_MC"],
            ("Fine", "Coarse"): ["downsample_FC"],
        },
        composition={
            ("id_F", "id_F"): "id_F", ("id_M", "id_M"): "id_M",
            ("id_C", "id_C"): "id_C",
            ("id_F", "downsample_FM"): "downsample_FM",
            ("downsample_FM", "id_M"): "downsample_FM",
            ("id_M", "downsample_MC"): "downsample_MC",
            ("downsample_MC", "id_C"): "downsample_MC",
            ("id_F", "downsample_FC"): "downsample_FC",
            ("downsample_FC", "id_C"): "downsample_FC",
            ("downsample_FM", "downsample_MC"): "downsample_FC",
        },
        identities={"Fine": "id_F", "Medium": "id_M", "Coarse": "id_C"}
    )

    fibers = {
        "Fine": ["f0", "f1", "f2", "f3"],
        "Medium": ["m0", "m1", "m2"],
        "Coarse": ["c0", "c1"],
    }

    restriction = {
        "id_F": {x: x for x in fibers["Fine"]},
        "id_M": {x: x for x in fibers["Medium"]},
        "id_C": {x: x for x in fibers["Coarse"]},
        "downsample_FM": {"m0": "f0", "m1": "f1", "m2": "f2"},
        "downsample_MC": {"c0": "m0", "c1": "m1"},
        "downsample_FC": {"c0": "f0", "c1": "f1"},
    }

    psh = Presheaf(cat, fibers, restriction)
    report = full_analysis(psh)

    print(f"Signal patterns: Fine={psh.fiber_size('Fine')}, "
          f"Medium={psh.fiber_size('Medium')}, Coarse={psh.fiber_size('Coarse')}")
    print(f"Naive dictionary size:     {report.total_fiber_sum}")
    print(f"Compressed dictionary:     {report.compressed_count}")
    print(f"Minimum dictionary:        {report.minimum_count}")
    print(f"Compression ratio:         {report.compression_ratio:.1%}")

    if report.has_redundancy:
        print("\nRedundant atoms (generated by downsampling from finer scales):")
        for r in report.redundancies:
            print(f"  '{r.target_elem}' at {r.target_obj} = "
                  f"downsample({r.source_elem} at {r.source_obj})")

    print("\nInterpretation: Coarse-scale patterns that are downsamplings of")
    print("fine-scale atoms need not be stored separately in the dictionary.")
    print("The compression ratio quantifies multi-resolution redundancy.")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Sensor Network Optimization
# ──────────────────────────────────────────────────────────────────────

def sensor_network_demo():
    """
    Model sensor networks as presheaf generators.

    Objects = regions to monitor
    Morphisms = coverage relationships (region A's sensor covers region B)
    F(region) = set of measurable states
    Generators = deployed sensors

    g(F) = minimum number of sensors needed.
    """
    print("\n" + "="*60)
    print("APPLICATION 3: Sensor Network Optimization")
    print("="*60)

    print("""
Scenario: Monitoring a building with 4 zones, where some sensors
cover multiple adjacent zones:
  - Zone A (entrance): 3 possible states
  - Zone B (hallway): 2 possible states
  - Zone C (office): 2 possible states
  - Zone D (server room): 3 possible states

Coverage morphisms:
  - A covers B (entrance sensor sees hallway)
  - B covers C (hallway sensor sees office)
  - A covers C (entrance sensor transitively sees office)
""")

    cat = FiniteCategory(
        objects=["A", "B", "C", "D"],
        morphisms={
            ("A", "A"): ["id_A"], ("B", "B"): ["id_B"],
            ("C", "C"): ["id_C"], ("D", "D"): ["id_D"],
            ("B", "A"): ["cov_BA"],
            ("C", "B"): ["cov_CB"],
            ("C", "A"): ["cov_CA"],
        },
        composition={
            ("id_A", "id_A"): "id_A", ("id_B", "id_B"): "id_B",
            ("id_C", "id_C"): "id_C", ("id_D", "id_D"): "id_D",
            ("id_B", "cov_BA"): "cov_BA", ("cov_BA", "id_A"): "cov_BA",
            ("id_C", "cov_CB"): "cov_CB", ("cov_CB", "id_B"): "cov_CB",
            ("id_C", "cov_CA"): "cov_CA", ("cov_CA", "id_A"): "cov_CA",
            ("cov_CB", "cov_BA"): "cov_CA",
        },
        identities={"A": "id_A", "B": "id_B", "C": "id_C", "D": "id_D"}
    )

    fibers = {
        "A": ["a_normal", "a_alert", "a_alarm"],
        "B": ["b_normal", "b_alert"],
        "C": ["c_normal", "c_alert"],
        "D": ["d_normal", "d_alert", "d_critical"],
    }

    restriction = {
        "id_A": {x: x for x in fibers["A"]},
        "id_B": {x: x for x in fibers["B"]},
        "id_C": {x: x for x in fibers["C"]},
        "id_D": {x: x for x in fibers["D"]},
        "cov_BA": {"a_normal": "b_normal", "a_alert": "b_alert", "a_alarm": "b_alert"},
        "cov_CB": {"b_normal": "c_normal", "b_alert": "c_alert"},
        "cov_CA": {"a_normal": "c_normal", "a_alert": "c_alert", "a_alarm": "c_alert"},
    }

    psh = Presheaf(cat, fibers, restriction)
    report = full_analysis(psh)

    print(f"Zone states: A={psh.fiber_size('A')}, B={psh.fiber_size('B')}, "
          f"C={psh.fiber_size('C')}, D={psh.fiber_size('D')}")
    print(f"Naive sensors needed:   {report.total_fiber_sum}")
    print(f"Optimized sensors:      {report.compressed_count}")
    print(f"Minimum sensors:        {report.minimum_count}")
    print(f"Compression ratio:      {report.compression_ratio:.1%}")

    if report.has_redundancy:
        print("\nRedundant sensor readings (covered by adjacent sensors):")
        for r in report.redundancies:
            print(f"  '{r.target_elem}' in zone {r.target_obj} is covered by "
                  f"sensor at zone {r.source_obj}")

    print("\nInterpretation: Sensors in well-connected zones can monitor")
    print("adjacent zones, reducing the total number of sensors needed.")
    print("Isolated zones (like D) require their own dedicated sensors.")


# ──────────────────────────────────────────────────────────────────────
# Application 4: Error-Correcting Codes
# ──────────────────────────────────────────────────────────────────────

def coding_theory_demo():
    """
    Model codebook design as presheaf generation.

    Objects = channel inputs/outputs
    Morphisms = channel transmission maps
    F(node) = set of valid codewords at that node
    Generators = codebook entries

    Generator compression = codeword dominance under channel maps.
    """
    print("\n" + "="*60)
    print("APPLICATION 4: Error-Correcting Code Design")
    print("="*60)

    print("""
Scenario: A relay network with encoder -> relay -> decoder.
  - Encoder: 4 possible messages
  - Relay: 3 processed signals (some messages merge)
  - Decoder: 2 decoded outputs

Transmission morphisms map codewords through the channel.
A codebook entry at the encoder determines entries at all downstream nodes.
""")

    cat = FiniteCategory(
        objects=["Encoder", "Relay", "Decoder"],
        morphisms={
            ("Encoder", "Encoder"): ["id_E"],
            ("Relay", "Relay"): ["id_R"],
            ("Decoder", "Decoder"): ["id_D"],
            ("Encoder", "Relay"): ["encode"],
            ("Relay", "Decoder"): ["decode"],
            ("Encoder", "Decoder"): ["endtoend"],
        },
        composition={
            ("id_E", "id_E"): "id_E", ("id_R", "id_R"): "id_R",
            ("id_D", "id_D"): "id_D",
            ("id_E", "encode"): "encode", ("encode", "id_R"): "encode",
            ("id_R", "decode"): "decode", ("decode", "id_D"): "decode",
            ("id_E", "endtoend"): "endtoend", ("endtoend", "id_D"): "endtoend",
            ("encode", "decode"): "endtoend",
        },
        identities={"Encoder": "id_E", "Relay": "id_R", "Decoder": "id_D"}
    )

    fibers = {
        "Encoder": ["msg_00", "msg_01", "msg_10", "msg_11"],
        "Relay": ["sig_0", "sig_1", "sig_2"],
        "Decoder": ["out_0", "out_1"],
    }

    restriction = {
        "id_E": {x: x for x in fibers["Encoder"]},
        "id_R": {x: x for x in fibers["Relay"]},
        "id_D": {x: x for x in fibers["Decoder"]},
        "encode": {"sig_0": "msg_00", "sig_1": "msg_01", "sig_2": "msg_10"},
        "decode": {"out_0": "sig_0", "out_1": "sig_1"},
        "endtoend": {"out_0": "msg_00", "out_1": "msg_01"},
    }

    psh = Presheaf(cat, fibers, restriction)
    report = full_analysis(psh)

    print(f"Codewords: Encoder={psh.fiber_size('Encoder')}, "
          f"Relay={psh.fiber_size('Relay')}, Decoder={psh.fiber_size('Decoder')}")
    print(f"Naive codebook size:     {report.total_fiber_sum}")
    print(f"Compressed codebook:     {report.compressed_count}")
    print(f"Minimum codebook:        {report.minimum_count}")
    print(f"Compression ratio:       {report.compression_ratio:.1%}")

    if report.has_redundancy:
        print("\nDominated codewords (determined by upstream entries):")
        for r in report.redundancies:
            print(f"  '{r.target_elem}' at {r.target_obj} is determined by "
                  f"'{r.source_elem}' at {r.source_obj}")

    print("\nInterpretation: Codewords at downstream nodes that are determined")
    print("by channel transmission from upstream codebook entries are redundant.")
    print("Only the encoder's independent messages form the essential codebook.")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Categorical Generator Complexity Theory   ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    database_normalization_demo()
    dictionary_learning_demo()
    sensor_network_demo()
    coding_theory_demo()

    print("\n" + "="*60)
    print("CONCLUSION")
    print("="*60)
    print("""
All four applications demonstrate the same underlying principle:
categorical structure (morphisms between objects) creates redundancy
in the naive generator family, enabling compression.

The compression ratio measures how much "information flow" exists
in the category:
  - Discrete categories: 100% (no flow, no compression)
  - Rich morphism structure: lower ratios (more compression)

This unifying framework connects database normalization, signal
processing, sensor placement, and coding theory through the single
invariant of generator complexity g(F).
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Generator Complexity of Finite-Valued Presheaves on Finite Categories

This script demonstrates the core theorems about generator complexity:
1. The n*m upper bound on generator family size
2. Discrete categories achieving the exact bound (no compression possible)
3. Restriction redundancy enabling strict compression

Run: python3 demo.py
"""

from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple, Set, Optional


# ──────────────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────────────

class FiniteCategory:
    """A finite category specified by objects, morphisms, and composition."""

    def __init__(self, objects: List[str], morphisms: Dict[Tuple[str, str], List[str]],
                 composition: Dict[Tuple[str, str], str], identities: Dict[str, str]):
        """
        Args:
            objects: list of object names
            morphisms: dict mapping (source, target) -> list of morphism names
            composition: dict mapping (f, g) -> f;g (composable morphisms)
            identities: dict mapping object -> identity morphism name
        """
        self.objects = objects
        self.morphisms = morphisms  # (src, tgt) -> [mor_names]
        self.composition = composition
        self.identities = identities
        self.n = len(objects)

    def hom(self, src: str, tgt: str) -> List[str]:
        return self.morphisms.get((src, tgt), [])

    def compose(self, f: str, g: str) -> Optional[str]:
        return self.composition.get((f, g))


class Presheaf:
    """A finite-valued presheaf F on a finite category C.

    F assigns to each object Y a finite set F(Y),
    and to each morphism f: X -> Y a function F(f): F(Y) -> F(X).
    """

    def __init__(self, category: FiniteCategory,
                 fibers: Dict[str, List[str]],
                 restriction: Dict[Tuple[str, str], Dict[str, str]]):
        """
        Args:
            category: the underlying finite category
            fibers: maps object name -> list of elements
            restriction: maps morphism name -> dict mapping F(target) -> F(source)
        """
        self.cat = category
        self.fibers = fibers
        self.restriction = restriction

    def fiber_size(self, obj: str) -> int:
        return len(self.fibers[obj])

    def total_fiber_sum(self) -> int:
        return sum(self.fiber_size(y) for y in self.cat.objects)

    def restrict(self, mor: str, elem: str) -> str:
        return self.restriction[mor][elem]


# ──────────────────────────────────────────────────────────────────────
# Generator Complexity Algorithm
# ──────────────────────────────────────────────────────────────────────

def naive_generators(presheaf: Presheaf) -> Set[Tuple[str, str]]:
    """The naive generating family: one generator (Y, x) for every Y, x ∈ F(Y)."""
    gens = set()
    for y in presheaf.cat.objects:
        for x in presheaf.fibers[y]:
            gens.add((y, x))
    return gens


def generated_elements(presheaf: Presheaf, generators: Set[Tuple[str, str]]) -> Dict[str, Set[str]]:
    """Compute all elements generated by a set of generators.

    Generator (Y, x) generates at object Z the elements {F(f)(x) | f : Z -> Y}.
    """
    generated = defaultdict(set)
    for y, x in generators:
        for z in presheaf.cat.objects:
            for f in presheaf.cat.hom(z, y):
                generated[z].add(presheaf.restrict(f, x))
    return generated


def is_generating(presheaf: Presheaf, generators: Set[Tuple[str, str]]) -> bool:
    """Check if a set of generators generates the entire presheaf."""
    gen = generated_elements(presheaf, generators)
    for z in presheaf.cat.objects:
        for a in presheaf.fibers[z]:
            if a not in gen[z]:
                return False
    return True


def find_restriction_redundant(presheaf: Presheaf) -> Optional[Tuple[str, str, str, str, str]]:
    """Find a restriction-redundant element: (Y, x, Z, z, f) where
    Z ≠ Y, f : Y -> Z, and F(f)(z) = x."""
    for y in presheaf.cat.objects:
        for x in presheaf.fibers[y]:
            for z_obj in presheaf.cat.objects:
                if z_obj == y:
                    continue
                for f in presheaf.cat.hom(y, z_obj):
                    for z_elem in presheaf.fibers[z_obj]:
                        if presheaf.restrict(f, z_elem) == x:
                            return (y, x, z_obj, z_elem, f)
    return None


def compress_generators(presheaf: Presheaf) -> Set[Tuple[str, str]]:
    """Greedily remove restriction-redundant generators from the naive family."""
    gens = naive_generators(presheaf)
    removed = 0
    for y in presheaf.cat.objects:
        for x in list(presheaf.fibers[y]):
            if (y, x) not in gens:
                continue
            # Check if x is restriction-redundant
            for z_obj in presheaf.cat.objects:
                if z_obj == y:
                    continue
                found = False
                for f in presheaf.cat.hom(y, z_obj):
                    for z_elem in presheaf.fibers[z_obj]:
                        if (z_obj, z_elem) in gens and presheaf.restrict(f, z_elem) == x:
                            # x is generated by (z_obj, z_elem) via f
                            gens.discard((y, x))
                            removed += 1
                            found = True
                            break
                    if found:
                        break
                if found:
                    break
    return gens


def minimal_generator_count(presheaf: Presheaf) -> int:
    """Brute-force search for the minimum generating family size."""
    all_pairs = list(naive_generators(presheaf))
    n = len(all_pairs)
    for k in range(n + 1):
        from itertools import combinations
        for subset in combinations(all_pairs, k):
            if is_generating(presheaf, set(subset)):
                return k
    return n


# ──────────────────────────────────────────────────────────────────────
# Example Categories and Presheaves
# ──────────────────────────────────────────────────────────────────────

def make_discrete_category(n: int) -> FiniteCategory:
    """Create a discrete category with n objects (only identity morphisms)."""
    objects = [f"X{i}" for i in range(n)]
    morphisms = {(x, x): [f"id_{x}"] for x in objects}
    composition = {(f"id_{x}", f"id_{x}"): f"id_{x}" for x in objects}
    identities = {x: f"id_{x}" for x in objects}
    return FiniteCategory(objects, morphisms, composition, identities)


def make_constant_presheaf_on_discrete(n: int, m: int) -> Presheaf:
    """Create a constant presheaf with m elements per fiber on a discrete n-category."""
    cat = make_discrete_category(n)
    fibers = {x: [f"{x}_e{j}" for j in range(m)] for x in cat.objects}
    restriction = {}
    for x in cat.objects:
        restriction[f"id_{x}"] = {e: e for e in fibers[x]}
    return Presheaf(cat, fibers, restriction)


def make_arrow_category() -> FiniteCategory:
    """Create the arrow category: two objects A, B with one non-identity morphism f: A -> B."""
    objects = ["A", "B"]
    morphisms = {
        ("A", "A"): ["id_A"],
        ("B", "B"): ["id_B"],
        ("A", "B"): ["f"],
    }
    composition = {
        ("id_A", "id_A"): "id_A",
        ("id_B", "id_B"): "id_B",
        ("id_A", "f"): "f",
        ("f", "id_B"): "f",
    }
    identities = {"A": "id_A", "B": "id_B"}
    return FiniteCategory(objects, morphisms, composition, identities)


def make_arrow_presheaf_with_redundancy() -> Presheaf:
    """A presheaf on the arrow category where restriction from B generates elements at A.

    F(A) = {a0, a1}, F(B) = {b0, b1}
    F(f): F(B) -> F(A) is b0 -> a0, b1 -> a1
    So both elements of F(A) are restriction-redundant.
    """
    cat = make_arrow_category()
    fibers = {"A": ["a0", "a1"], "B": ["b0", "b1"]}
    restriction = {
        "id_A": {"a0": "a0", "a1": "a1"},
        "id_B": {"b0": "b0", "b1": "b1"},
        "f": {"b0": "a0", "b1": "a1"},  # F(f): F(B) -> F(A)
    }
    return Presheaf(cat, fibers, restriction)


def make_arrow_presheaf_partial_redundancy() -> Presheaf:
    """A presheaf on the arrow category with partial redundancy.

    F(A) = {a0, a1, a2}, F(B) = {b0, b1}
    F(f): b0 -> a0, b1 -> a1
    So a0, a1 are redundant but a2 is not.
    """
    cat = make_arrow_category()
    fibers = {"A": ["a0", "a1", "a2"], "B": ["b0", "b1"]}
    restriction = {
        "id_A": {"a0": "a0", "a1": "a1", "a2": "a2"},
        "id_B": {"b0": "b0", "b1": "b1"},
        "f": {"b0": "a0", "b1": "a1"},
    }
    return Presheaf(cat, fibers, restriction)


def make_triangle_category() -> FiniteCategory:
    """Category with 3 objects and morphisms A->B, B->C, A->C (commutative triangle)."""
    objects = ["A", "B", "C"]
    morphisms = {
        ("A", "A"): ["id_A"], ("B", "B"): ["id_B"], ("C", "C"): ["id_C"],
        ("A", "B"): ["f"], ("B", "C"): ["g"], ("A", "C"): ["h"],
    }
    composition = {
        ("id_A", "id_A"): "id_A", ("id_B", "id_B"): "id_B", ("id_C", "id_C"): "id_C",
        ("id_A", "f"): "f", ("f", "id_B"): "f",
        ("id_B", "g"): "g", ("g", "id_C"): "g",
        ("id_A", "h"): "h", ("h", "id_C"): "h",
        ("f", "g"): "h",  # h = f;g (composition)
    }
    identities = {"A": "id_A", "B": "id_B", "C": "id_C"}
    return FiniteCategory(objects, morphisms, composition, identities)


def make_triangle_presheaf() -> Presheaf:
    """Presheaf on the commutative triangle with full redundancy at A.

    F(A) = {a0}, F(B) = {b0}, F(C) = {c0}
    F(f): b0 -> a0, F(g): c0 -> b0, F(h): c0 -> a0
    Everything is generated from c0 at C.
    """
    cat = make_triangle_category()
    fibers = {"A": ["a0"], "B": ["b0"], "C": ["c0"]}
    restriction = {
        "id_A": {"a0": "a0"}, "id_B": {"b0": "b0"}, "id_C": {"c0": "c0"},
        "f": {"b0": "a0"}, "g": {"c0": "b0"}, "h": {"c0": "a0"},
    }
    return Presheaf(cat, fibers, restriction)


# ──────────────────────────────────────────────────────────────────────
# Demo Runner
# ──────────────────────────────────────────────────────────────────────

def demo_presheaf(name: str, presheaf: Presheaf):
    """Run the full analysis pipeline on a presheaf."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")

    cat = presheaf.cat
    n = cat.n
    max_m = max(presheaf.fiber_size(y) for y in cat.objects)
    total = presheaf.total_fiber_sum()

    print(f"\nCategory: {n} objects, morphisms: ", end="")
    total_mors = sum(len(ms) for ms in cat.morphisms.values())
    non_id_mors = total_mors - n
    print(f"{total_mors} total ({non_id_mors} non-identity)")

    print(f"\nFibers:")
    for y in cat.objects:
        print(f"  F({y}) = {presheaf.fibers[y]}  (size {presheaf.fiber_size(y)})")

    print(f"\nNaive bound (sum): ∑|F(Y)| = {total}")
    print(f"Coarse bound (n·m): {n} × {max_m} = {n * max_m}")

    # Check for restriction redundancy
    red = find_restriction_redundant(presheaf)
    if red:
        y, x, z, z_elem, f = red
        print(f"\n✓ Restriction redundancy found!")
        print(f"  {x} ∈ F({y}) = F({f})({z_elem}),  via {f}: {y} → {z}")
    else:
        print(f"\n✗ No restriction redundancy (discrete-like behavior)")

    # Compress
    compressed = compress_generators(presheaf)
    print(f"\nNaive generators:      {total}")
    print(f"After compression:     {len(compressed)}")

    # Minimal (brute force for small examples)
    if total <= 12:
        minimal = minimal_generator_count(presheaf)
        print(f"Minimum possible:      {minimal}")
        ratio = minimal / total if total > 0 else 1.0
        print(f"Compression ratio:     {ratio:.2%}")
    else:
        print(f"(Skipping brute-force minimum for large example)")

    print(f"\nGenerating family: {sorted(compressed)}")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     Generator Complexity of Finite-Valued Presheaves       ║")
    print("║     ─────────────────────────────────────────────────       ║")
    print("║     Demonstrating the Theory of Categorical Compression    ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # ── Demo 1: Discrete category (no compression) ──
    print("\n\n" + "━"*60)
    print("  PART 1: Discrete Categories — Zero Compression")
    print("━"*60)
    print("\nIn a discrete category, every element needs its own generator.")
    print("This is the analogue of orthogonal coordinates admitting no compression.")

    demo_presheaf(
        "Discrete(3) with 2 elements per fiber",
        make_constant_presheaf_on_discrete(3, 2)
    )

    demo_presheaf(
        "Discrete(4) with 3 elements per fiber",
        make_constant_presheaf_on_discrete(4, 3)
    )

    # ── Demo 2: Arrow category (compression possible) ──
    print("\n\n" + "━"*60)
    print("  PART 2: Arrow Category — Morphisms Enable Compression")
    print("━"*60)
    print("\nWhen morphisms exist, restriction maps can make generators redundant.")

    demo_presheaf(
        "Arrow category with full redundancy at A",
        make_arrow_presheaf_with_redundancy()
    )

    demo_presheaf(
        "Arrow category with partial redundancy",
        make_arrow_presheaf_partial_redundancy()
    )

    # ── Demo 3: Triangle category (transitive compression) ──
    print("\n\n" + "━"*60)
    print("  PART 3: Commutative Triangle — Transitive Compression")
    print("━"*60)
    print("\nComposition of morphisms amplifies compression:")
    print("a single generator at the terminal object can generate everything.")

    demo_presheaf(
        "Commutative triangle with singleton fibers",
        make_triangle_presheaf()
    )

    # ── Summary table ──
    print("\n\n" + "━"*60)
    print("  SUMMARY: Compression Comparison Table")
    print("━"*60)

    examples = [
        ("Discrete(3), m=2", make_constant_presheaf_on_discrete(3, 2)),
        ("Discrete(4), m=3", make_constant_presheaf_on_discrete(4, 3)),
        ("Arrow, full redundancy", make_arrow_presheaf_with_redundancy()),
        ("Arrow, partial redundancy", make_arrow_presheaf_partial_redundancy()),
        ("Triangle, singletons", make_triangle_presheaf()),
    ]

    print(f"\n{'Example':<30} {'n':>3} {'max m':>5} {'∑|F|':>5} {'n·m':>5} "
          f"{'Compressed':>10} {'Minimum':>7} {'Ratio':>7}")
    print("─" * 82)

    for name, psh in examples:
        n = psh.cat.n
        max_m = max(psh.fiber_size(y) for y in psh.cat.objects)
        total = psh.total_fiber_sum()
        compressed = len(compress_generators(psh))
        minimum = minimal_generator_count(psh)
        ratio = f"{minimum/total:.0%}" if total > 0 else "N/A"
        print(f"{name:<30} {n:>3} {max_m:>5} {total:>5} {n*max_m:>5} "
              f"{compressed:>10} {minimum:>7} {ratio:>7}")

    print("\n" + "━"*60)
    print("Key insight: Discrete categories achieve ratio = 100% (no compression).")
    print("Non-trivial morphisms enable compression below the naive bound.")
    print("The compression ratio measures 'how much categorical structure helps.'")
    print("━"*60)


if __name__ == "__main__":
    main()
