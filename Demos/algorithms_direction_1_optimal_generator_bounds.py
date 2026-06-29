#!/usr/bin/env python3
"""
Algorithms for Generator Complexity of Finite-Valued Presheaves

This module implements the core algorithms from the research paper:
1. Naive generator construction (brute-force)
2. Restriction-redundancy detection
3. Greedy compression via redundancy elimination
4. Exhaustive minimum generator search

All algorithms are formally justified by the theorems in
GeneratorComplexity.lean.
"""

from typing import Dict, List, Tuple, Set, Optional, NamedTuple
from itertools import combinations, product
from collections import defaultdict
import time


# ──────────────────────────────────────────────────────────────────────
# Data Structures
# ──────────────────────────────────────────────────────────────────────

class FiniteCategory:
    """A finite category represented by explicit morphism and composition data.

    Attributes:
        objects: List of object names
        morphisms: Dict mapping (source, target) -> list of morphism names
        composition: Dict mapping (f, g) -> composite morphism name
        identities: Dict mapping object -> identity morphism name
    """

    def __init__(self, objects: List[str],
                 morphisms: Dict[Tuple[str, str], List[str]],
                 composition: Dict[Tuple[str, str], str],
                 identities: Dict[str, str]):
        self.objects = objects
        self.morphisms = morphisms
        self.composition = composition
        self.identities = identities

    @property
    def n(self) -> int:
        """Number of objects."""
        return len(self.objects)

    def hom(self, src: str, tgt: str) -> List[str]:
        """Morphisms from src to tgt."""
        return self.morphisms.get((src, tgt), [])

    def non_identity_morphism_count(self) -> int:
        """Count of non-identity morphisms."""
        return sum(len(ms) for ms in self.morphisms.values()) - self.n

    @staticmethod
    def discrete(n: int) -> 'FiniteCategory':
        """Create a discrete category on n objects.

        Time: O(n)
        Space: O(n)
        """
        objects = [f"X{i}" for i in range(n)]
        morphisms = {(x, x): [f"id_{x}"] for x in objects}
        composition = {(f"id_{x}", f"id_{x}"): f"id_{x}" for x in objects}
        identities = {x: f"id_{x}" for x in objects}
        return FiniteCategory(objects, morphisms, composition, identities)

    @staticmethod
    def arrow() -> 'FiniteCategory':
        """The arrow category (two objects, one non-identity morphism)."""
        return FiniteCategory(
            objects=["A", "B"],
            morphisms={("A", "A"): ["id_A"], ("B", "B"): ["id_B"], ("A", "B"): ["f"]},
            composition={("id_A", "id_A"): "id_A", ("id_B", "id_B"): "id_B",
                        ("id_A", "f"): "f", ("f", "id_B"): "f"},
            identities={"A": "id_A", "B": "id_B"}
        )

    @staticmethod
    def total_order(n: int) -> 'FiniteCategory':
        """A linear order (total order) on n objects: 0 -> 1 -> ... -> n-1.

        Time: O(n^3) for composition table
        Space: O(n^2)
        """
        objects = [f"X{i}" for i in range(n)]
        morphisms: Dict[Tuple[str, str], List[str]] = {}
        composition: Dict[Tuple[str, str], str] = {}
        identities = {f"X{i}": f"id_X{i}" for i in range(n)}

        for i in range(n):
            for j in range(i, n):
                if i == j:
                    morphisms[(f"X{i}", f"X{j}")] = [f"id_X{i}"]
                else:
                    morphisms[(f"X{i}", f"X{j}")] = [f"f_{i}_{j}"]

        # Composition
        for i in range(n):
            composition[(f"id_X{i}", f"id_X{i}")] = f"id_X{i}"

        for i in range(n):
            for j in range(i, n):
                m_ij = f"f_{i}_{j}" if i != j else f"id_X{i}"
                composition[(f"id_X{i}", m_ij)] = m_ij
                composition[(m_ij, f"id_X{j}")] = m_ij
                for k in range(j, n):
                    m_jk = f"f_{j}_{k}" if j != k else f"id_X{j}"
                    m_ik = f"f_{i}_{k}" if i != k else f"id_X{i}"
                    composition[(m_ij, m_jk)] = m_ik

        return FiniteCategory(objects, morphisms, composition, identities)


class Presheaf:
    """A finite-valued presheaf on a finite category.

    Attributes:
        cat: The underlying finite category
        fibers: Dict mapping object -> list of elements
        restriction: Dict mapping morphism_name -> dict (elem -> elem)
    """

    def __init__(self, category: FiniteCategory,
                 fibers: Dict[str, List[str]],
                 restriction: Dict[str, Dict[str, str]]):
        self.cat = category
        self.fibers = fibers
        self.restriction = restriction

    def fiber_size(self, obj: str) -> int:
        return len(self.fibers[obj])

    def total_fiber_sum(self) -> int:
        return sum(self.fiber_size(y) for y in self.cat.objects)

    def max_fiber_size(self) -> int:
        return max(self.fiber_size(y) for y in self.cat.objects)

    def restrict(self, mor: str, elem: str) -> str:
        return self.restriction[mor][elem]


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Naive Generator Construction
# ──────────────────────────────────────────────────────────────────────

def naive_generators(psh: Presheaf) -> Set[Tuple[str, str]]:
    """Construct the naive generating family: one generator per fiber element.

    Time: O(∑ |F(Y)|)
    Space: O(∑ |F(Y)|)

    This corresponds to the catalog construction `naiveGenerators F` in Lean.
    The resulting family has size exactly ∑_Y |F(op Y)|.

    Returns:
        Set of (object, element) pairs forming the generating family.
    """
    return {(y, x) for y in psh.cat.objects for x in psh.fibers[y]}


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Restriction Redundancy Detection
# ──────────────────────────────────────────────────────────────────────

class RedundancyWitness(NamedTuple):
    """Witness that an element is restriction-redundant."""
    target_obj: str      # Y: the object where the redundant element lives
    target_elem: str     # x: the redundant element in F(Y)
    source_obj: str      # Z: the object providing the generator
    source_elem: str     # z: the generator element in F(Z)
    morphism: str        # f: morphism Y -> Z such that F(f)(z) = x


def find_all_redundancies(psh: Presheaf) -> List[RedundancyWitness]:
    """Find all restriction-redundant elements.

    Time: O(n^2 · M · m) where n = |Ob(C)|, M = max morphisms, m = max fiber size
    Space: O(n · m)

    An element x ∈ F(Y) is restriction-redundant if there exists Z ≠ Y,
    z ∈ F(Z), and f : Y → Z such that F(f)(z) = x.
    """
    redundancies = []
    for y in psh.cat.objects:
        for x in psh.fibers[y]:
            for z in psh.cat.objects:
                if z == y:
                    continue
                for f in psh.cat.hom(y, z):
                    for z_elem in psh.fibers[z]:
                        if psh.restrict(f, z_elem) == x:
                            redundancies.append(
                                RedundancyWitness(y, x, z, z_elem, f))
    return redundancies


def has_restriction_redundancy(psh: Presheaf) -> bool:
    """Check if the presheaf has any restriction redundancy.

    Time: O(n^2 · M · m), early exit on first redundancy found
    """
    for y in psh.cat.objects:
        for x in psh.fibers[y]:
            for z in psh.cat.objects:
                if z == y:
                    continue
                for f in psh.cat.hom(y, z):
                    for z_elem in psh.fibers[z]:
                        if psh.restrict(f, z_elem) == x:
                            return True
    return False


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Greedy Compression
# ──────────────────────────────────────────────────────────────────────

def generated_elements(psh: Presheaf,
                       generators: Set[Tuple[str, str]]) -> Dict[str, Set[str]]:
    """Compute all fiber elements generated by a set of generators.

    Generator (Y, x) generates at object Z the elements {F(f)(x) | f : Z -> Y}.

    Time: O(|S| · n · M) where |S| = generator count, M = max morphisms
    Space: O(∑ |F(Y)|)
    """
    generated = defaultdict(set)
    for y, x in generators:
        for z in psh.cat.objects:
            for f in psh.cat.hom(z, y):
                generated[z].add(psh.restrict(f, x))
    return generated


def is_generating(psh: Presheaf, generators: Set[Tuple[str, str]]) -> bool:
    """Check if a set of generators generates the entire presheaf.

    Time: O(|S| · n · M + ∑ |F(Y)|)
    """
    gen = generated_elements(psh, generators)
    return all(a in gen[z] for z in psh.cat.objects for a in psh.fibers[z])


def greedy_compress(psh: Presheaf) -> Tuple[Set[Tuple[str, str]], List[RedundancyWitness]]:
    """Greedily remove restriction-redundant generators.

    Algorithm:
    1. Start with the naive generating family S = {(Y, x) | Y, x ∈ F(Y)}.
    2. For each (Y, x) ∈ S, check if x = F(f)(z) for some (Z, z) ∈ S with Z ≠ Y.
    3. If so, remove (Y, x) from S (it's generated by (Z, z) via f).
    4. Repeat until no more removals are possible.

    The correctness is justified by Theorem 3 (exists_smaller_cover_of_restriction_redundancy):
    removing a restriction-redundant generator preserves the generating property.

    Time: O(∑|F(Y)| · n · M · m) per pass, at most ∑|F(Y)| passes
    Space: O(∑|F(Y)|)

    Returns:
        Tuple of (compressed generator set, list of removed redundancies)
    """
    gens = naive_generators(psh)
    removals = []
    changed = True

    while changed:
        changed = False
        for y in psh.cat.objects:
            for x in list(psh.fibers[y]):
                if (y, x) not in gens:
                    continue
                for z in psh.cat.objects:
                    if z == y:
                        continue
                    found = False
                    for f in psh.cat.hom(y, z):
                        for z_elem in psh.fibers[z]:
                            if (z, z_elem) in gens and psh.restrict(f, z_elem) == x:
                                gens.discard((y, x))
                                removals.append(RedundancyWitness(y, x, z, z_elem, f))
                                changed = True
                                found = True
                                break
                        if found:
                            break
                    if found:
                        break

    return gens, removals


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Exact Minimum Generator Search
# ──────────────────────────────────────────────────────────────────────

def minimum_generators(psh: Presheaf) -> Tuple[int, Set[Tuple[str, str]]]:
    """Find the minimum generating family by exhaustive search.

    Time: O(2^(∑|F(Y)|) · n · M) — exponential, only for small examples
    Space: O(∑|F(Y)|)

    Returns:
        Tuple of (minimum size, a minimum generating family)
    """
    all_pairs = list(naive_generators(psh))
    n = len(all_pairs)

    for k in range(n + 1):
        for subset in combinations(all_pairs, k):
            s = set(subset)
            if is_generating(psh, s):
                return k, s

    return n, set(all_pairs)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Compression Analysis
# ──────────────────────────────────────────────────────────────────────

class CompressionReport(NamedTuple):
    """Report on the compression analysis of a presheaf."""
    n_objects: int
    max_fiber: int
    total_fiber_sum: int
    coarse_bound: int      # n * max_fiber
    naive_count: int       # = total_fiber_sum
    compressed_count: int
    minimum_count: int     # -1 if not computed
    has_redundancy: bool
    redundancies: List[RedundancyWitness]
    compression_ratio: float  # minimum / total


def full_analysis(psh: Presheaf, compute_minimum: bool = True) -> CompressionReport:
    """Perform full compression analysis on a presheaf.

    Args:
        psh: The presheaf to analyze
        compute_minimum: If True, compute exact minimum (exponential time)

    Returns:
        CompressionReport with all metrics
    """
    n = psh.cat.n
    max_m = psh.max_fiber_size()
    total = psh.total_fiber_sum()
    coarse = n * max_m

    compressed, removals = greedy_compress(psh)
    compressed_count = len(compressed)

    if compute_minimum and total <= 15:
        min_count, _ = minimum_generators(psh)
    else:
        min_count = -1

    ratio = (min_count if min_count >= 0 else compressed_count) / total if total > 0 else 1.0

    return CompressionReport(
        n_objects=n,
        max_fiber=max_m,
        total_fiber_sum=total,
        coarse_bound=coarse,
        naive_count=total,
        compressed_count=compressed_count,
        minimum_count=min_count,
        has_redundancy=len(removals) > 0,
        redundancies=removals,
        compression_ratio=ratio,
    )


# ──────────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generator Complexity Algorithms — Example Usage")
    print("=" * 50)

    # Example: Arrow category with surjective restriction
    cat = FiniteCategory.arrow()
    psh = Presheaf(
        category=cat,
        fibers={"A": ["a0", "a1"], "B": ["b0", "b1"]},
        restriction={
            "id_A": {"a0": "a0", "a1": "a1"},
            "id_B": {"b0": "b0", "b1": "b1"},
            "f": {"b0": "a0", "b1": "a1"},
        }
    )

    report = full_analysis(psh)
    print(f"\nArrow category presheaf:")
    print(f"  Objects: {cat.n}")
    print(f"  Total fiber sum: {report.total_fiber_sum}")
    print(f"  Coarse bound (n·m): {report.coarse_bound}")
    print(f"  After compression: {report.compressed_count}")
    print(f"  Exact minimum: {report.minimum_count}")
    print(f"  Compression ratio: {report.compression_ratio:.1%}")
    print(f"  Redundancies found: {len(report.redundancies)}")
    for r in report.redundancies:
        print(f"    {r.target_elem} ∈ F({r.target_obj}) = "
              f"F({r.morphism})({r.source_elem})")

    # Example: Discrete category (no compression)
    cat2 = FiniteCategory.discrete(3)
    psh2 = Presheaf(
        category=cat2,
        fibers={f"X{i}": [f"X{i}_e{j}" for j in range(2)] for i in range(3)},
        restriction={f"id_X{i}": {f"X{i}_e{j}": f"X{i}_e{j}" for j in range(2)}
                     for i in range(3)}
    )

    report2 = full_analysis(psh2)
    print(f"\nDiscrete(3) presheaf:")
    print(f"  Total fiber sum: {report2.total_fiber_sum}")
    print(f"  After compression: {report2.compressed_count}")
    print(f"  Exact minimum: {report2.minimum_count}")
    print(f"  Compression ratio: {report2.compression_ratio:.1%}")
    print(f"  Has redundancy: {report2.has_redundancy}")

    # Example: Total order category
    cat3 = FiniteCategory.total_order(4)
    psh3 = Presheaf(
        category=cat3,
        fibers={f"X{i}": [f"X{i}_e0"] for i in range(4)},
        restriction={}
    )
    # Build restriction maps: every morphism maps the unique element to the unique element
    for (src, tgt), mors in cat3.morphisms.items():
        for m in mors:
            psh3.restriction[m] = {f"{tgt}_e0": f"{src}_e0"}

    report3 = full_analysis(psh3)
    print(f"\nTotal order(4) with singleton fibers:")
    print(f"  Total fiber sum: {report3.total_fiber_sum}")
    print(f"  After compression: {report3.compressed_count}")
    print(f"  Exact minimum: {report3.minimum_count}")
    print(f"  Compression ratio: {report3.compression_ratio:.1%}")
