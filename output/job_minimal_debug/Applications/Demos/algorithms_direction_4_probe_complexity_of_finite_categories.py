#!/usr/bin/env python3
"""
Algorithms for Probe Complexity of Finite Categories

This module implements algorithms for computing probe complexity,
finding optimal separating probe families, and verifying the
information-theoretic bounds from the formalized theory.

Key algorithms:
  1. ExhaustiveProbeSearch — brute-force minimum separating family
  2. GreedyProbeSearch — greedy approximation for larger categories
  3. ProfileCapacityChecker — verify information-theoretic bounds
  4. DistinguishingSetAnalysis — compute pairwise distinguishing data
"""

from typing import Dict, List, Tuple, Set, Optional, FrozenSet
import itertools
import math


class FiniteCategory:
    """
    A finite category represented explicitly.

    Attributes:
        objects: List of objects
        hom_sets: Dict mapping (src, tgt) to list of morphisms
        comp: Dict mapping (f, g) to the composition f∘g (g first, then f)
        identity: Dict mapping each object to its identity morphism
    """

    def __init__(
        self,
        objects: list,
        hom_sets: Dict[Tuple, list],
        comp: Dict[Tuple, object],
        identity: Dict[object, object],
    ):
        self.objects = list(objects)
        self.hom_sets = hom_sets
        self.comp = comp
        self.identity = identity

    def hom(self, src, tgt) -> list:
        return self.hom_sets.get((src, tgt), [])

    def compose(self, f, g):
        return self.comp[(f, g)]

    @property
    def n_objects(self) -> int:
        return len(self.objects)

    @property
    def n_morphisms(self) -> int:
        return sum(len(v) for v in self.hom_sets.values())

    def max_hom_size(self) -> int:
        """Maximum cardinality of any hom-set."""
        return max((len(v) for v in self.hom_sets.values()), default=0)

    def has_distinct_parallel_morphisms(self) -> bool:
        """Whether there exist distinct parallel morphisms (PC > 0)."""
        return any(len(v) > 1 for v in self.hom_sets.values())


def distinguishing_set(
    cat: FiniteCategory, src, tgt, f, g
) -> Set:
    """
    Compute the set of probe objects that distinguish morphisms f and g.
    Z distinguishes f from g if ∃ h : Z → src s.t. h∘f ≠ h∘g.
    """
    result = set()
    for z in cat.objects:
        for h in cat.hom(z, src):
            if cat.compose(f, h) != cat.compose(g, h):
                result.add(z)
                break
    return result


def all_morphism_pairs(cat: FiniteCategory) -> List[Tuple]:
    """
    Return all pairs of distinct parallel morphisms (src, tgt, f, g).
    """
    pairs = []
    for (src, tgt), morphs in cat.hom_sets.items():
        for i, f in enumerate(morphs):
            for g in morphs[i + 1:]:
                pairs.append((src, tgt, f, g))
    return pairs


class ExhaustiveProbeSearch:
    """
    Compute probe complexity by exhaustive search over all subsets of objects.

    Partial correctness theorem (formalized in Lean):
    - If search returns k, there exists a separating family of size k
    - The search returns the minimum such k

    Time complexity: O(2^n * P * M^2) where n = |Ob|, P = pairs, M = morphisms
    Space complexity: O(n + P)
    """

    def __init__(self, cat: FiniteCategory):
        self.cat = cat
        self.pairs = all_morphism_pairs(cat)
        self._distinguishing_sets = {}

    def _get_distinguishing_set(self, pair_idx: int) -> Set:
        """Cached computation of distinguishing sets."""
        if pair_idx not in self._distinguishing_sets:
            src, tgt, f, g = self.pairs[pair_idx]
            self._distinguishing_sets[pair_idx] = distinguishing_set(
                self.cat, src, tgt, f, g
            )
        return self._distinguishing_sets[pair_idx]

    def is_separating(self, probe_set: Set) -> bool:
        """Check if probe_set separates all morphism pairs."""
        for i in range(len(self.pairs)):
            dist = self._get_distinguishing_set(i)
            if not dist.intersection(probe_set):
                return False
        return True

    def search(self) -> Tuple[int, Optional[Set]]:
        """
        Find the minimum separating probe family.

        Returns:
            (probe_complexity, optimal_probe_set)
        """
        if not self.pairs:
            return 0, set()

        n = self.cat.n_objects
        for k in range(1, n + 1):
            for subset in itertools.combinations(self.cat.objects, k):
                probe_set = set(subset)
                if self.is_separating(probe_set):
                    return k, probe_set
        return n, set(self.cat.objects)


class GreedyProbeSearch:
    """
    Greedy approximation algorithm for probe complexity.

    At each step, add the probe object that covers the most
    uncovered morphism pairs. This is equivalent to the greedy
    set cover algorithm.

    Approximation ratio: O(log P) where P = number of morphism pairs.
    Time complexity: O(n * P * M) per step, O(n^2 * P * M) total.
    """

    def __init__(self, cat: FiniteCategory):
        self.cat = cat
        self.pairs = all_morphism_pairs(cat)

    def search(self) -> Tuple[int, Set]:
        """
        Find an approximately minimum separating probe family.

        Returns:
            (family_size, probe_set)
        """
        if not self.pairs:
            return 0, set()

        # Precompute distinguishing sets
        dist_sets = []
        for src, tgt, f, g in self.pairs:
            dist_sets.append(distinguishing_set(self.cat, src, tgt, f, g))

        uncovered = set(range(len(self.pairs)))
        probes = set()

        while uncovered:
            # Find the object that covers the most uncovered pairs
            best_obj = None
            best_coverage = -1

            for obj in self.cat.objects:
                if obj in probes:
                    continue
                coverage = sum(1 for i in uncovered if obj in dist_sets[i])
                if coverage > best_coverage:
                    best_coverage = coverage
                    best_obj = obj

            if best_obj is None or best_coverage == 0:
                # Some pairs are not distinguishable — shouldn't happen
                # if the category is well-formed
                probes.update(self.cat.objects)
                break

            probes.add(best_obj)
            uncovered = {i for i in uncovered if best_obj not in dist_sets[i]}

        return len(probes), probes


class ProfileCapacityChecker:
    """
    Verify the information-theoretic bound (Theorem 2):
    For a separating family P and any X, Y:
      |Hom(X,Y)| ≤ ∏_{Z∈P} |Hom(Z,Y)|^|Hom(Z,X)|
    """

    def __init__(self, cat: FiniteCategory):
        self.cat = cat

    def profile_capacity(self, probe_set: Set, src, tgt) -> int:
        """Compute ∏_{Z∈P} |Hom(Z,tgt)|^|Hom(Z,src)|."""
        capacity = 1
        for z in probe_set:
            hom_z_src = len(self.cat.hom(z, src))
            hom_z_tgt = len(self.cat.hom(z, tgt))
            if hom_z_src == 0:
                capacity *= 1
            else:
                capacity *= hom_z_tgt ** hom_z_src
        return capacity

    def check_bound(self, probe_set: Set) -> Tuple[bool, List[dict]]:
        """
        Verify the bound for all hom-sets.

        Returns:
            (all_satisfied, details)
        """
        details = []
        all_ok = True
        for (src, tgt), morphs in self.cat.hom_sets.items():
            hom_size = len(morphs)
            cap = self.profile_capacity(probe_set, src, tgt)
            ok = hom_size <= cap
            if not ok:
                all_ok = False
            details.append({
                "src": src, "tgt": tgt,
                "hom_size": hom_size, "capacity": cap,
                "satisfied": ok
            })
        return all_ok, details

    def information_content(self, probe_set: Set, src, tgt) -> float:
        """
        Compute log2 of the profile capacity.
        This represents the 'information budget' in bits.
        """
        cap = self.profile_capacity(probe_set, src, tgt)
        return math.log2(cap) if cap > 0 else 0.0

    def required_bits(self, src, tgt) -> float:
        """
        Compute log2(|Hom(src,tgt)|) — the information needed to
        identify a morphism.
        """
        hom_size = len(self.cat.hom(src, tgt))
        return math.log2(hom_size) if hom_size > 1 else 0.0


class DistinguishingSetAnalysis:
    """
    Analyze the structure of pairwise distinguishing sets.
    This relates to the hitting-set / set-cover structure of
    the probe complexity problem.
    """

    def __init__(self, cat: FiniteCategory):
        self.cat = cat
        self.pairs = all_morphism_pairs(cat)
        self.dist_sets = [
            distinguishing_set(cat, s, t, f, g)
            for s, t, f, g in self.pairs
        ]

    def min_distinguishing_multiplicity(self) -> int:
        """
        Minimum number of objects that distinguish any pair.
        This is the 'k' in profile-sparsity.
        """
        if not self.dist_sets:
            return len(self.cat.objects)
        return min(len(s) for s in self.dist_sets)

    def max_distinguishing_multiplicity(self) -> int:
        """Maximum number of objects that distinguish any pair."""
        if not self.dist_sets:
            return len(self.cat.objects)
        return max(len(s) for s in self.dist_sets)

    def hitting_set_lower_bound(self) -> int:
        """
        LP relaxation lower bound on probe complexity:
        the maximum over objects of how many pairs require that object.
        """
        if not self.dist_sets:
            return 0

        # Find pairs where only one object distinguishes them
        forced_objects = set()
        for ds in self.dist_sets:
            if len(ds) == 1:
                forced_objects.update(ds)
        return len(forced_objects)

    def summary(self) -> dict:
        """Return a summary of the distinguishing set structure."""
        return {
            "n_pairs": len(self.pairs),
            "min_multiplicity": self.min_distinguishing_multiplicity(),
            "max_multiplicity": self.max_distinguishing_multiplicity(),
            "hitting_set_lb": self.hitting_set_lower_bound(),
            "n_objects": self.cat.n_objects,
        }


# --- Factory functions for common categories ---

def make_discrete(n: int) -> FiniteCategory:
    """Discrete category on n objects."""
    objects = list(range(n))
    hom_sets = {(i, i): [f"id_{i}"] for i in objects}
    comp = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
    identity = {i: f"id_{i}" for i in objects}
    return FiniteCategory(objects, hom_sets, comp, identity)


def make_parallel_arrows(k: int) -> FiniteCategory:
    """Two objects with k parallel arrows from 0 to 1."""
    objects = [0, 1]
    arrows = [f"f_{i}" for i in range(k)]
    hom_sets = {(0, 0): ["id_0"], (1, 1): ["id_1"], (0, 1): arrows}
    comp = {("id_0", "id_0"): "id_0", ("id_1", "id_1"): "id_1"}
    for f in arrows:
        comp[(f, "id_0")] = f
        comp[("id_1", f)] = f
    identity = {0: "id_0", 1: "id_1"}
    return FiniteCategory(objects, hom_sets, comp, identity)


def make_cyclic_monoid(n: int) -> FiniteCategory:
    """Cyclic group Z/nZ as single-object category."""
    elements = [f"g{i}" for i in range(n)]
    hom_sets = {(0, 0): elements}
    comp = {(f"g{i}", f"g{j}"): f"g{(i+j)%n}" for i in range(n) for j in range(n)}
    return FiniteCategory([0], hom_sets, comp, {0: "g0"})


def make_disjoint_union(cats: list) -> FiniteCategory:
    """Disjoint union of categories."""
    objects = []
    hom_sets = {}
    comp = {}
    identity = {}
    for idx, cat in enumerate(cats):
        for obj in cat.objects:
            new_obj = (idx, obj)
            objects.append(new_obj)
            identity[new_obj] = (idx, cat.identity[obj])
        for (s, t), morphs in cat.hom_sets.items():
            new_morphs = [(idx, m) for m in morphs]
            hom_sets[((idx, s), (idx, t))] = new_morphs
        for (f, g), r in cat.comp.items():
            comp[((idx, f), (idx, g))] = (idx, r)
    return FiniteCategory(objects, hom_sets, comp, identity)


if __name__ == "__main__":
    print("Probe Complexity Algorithms — Test Suite")
    print("=" * 50)

    # Test exhaustive search
    cat = make_parallel_arrows(4)
    searcher = ExhaustiveProbeSearch(cat)
    pc, probes = searcher.search()
    print(f"\nParallelArrows(4): PC = {pc}, probes = {probes}")

    # Test greedy search
    cat2 = make_disjoint_union([make_cyclic_monoid(3)] * 4)
    greedy = GreedyProbeSearch(cat2)
    gpc, gprobes = greedy.search()
    exact = ExhaustiveProbeSearch(cat2)
    epc, eprobes = exact.search()
    print(f"\n4×Z/3Z:")
    print(f"  Exact:  PC = {epc}, probes = {eprobes}")
    print(f"  Greedy: size = {gpc}, probes = {gprobes}")

    # Test information-theoretic bound
    checker = ProfileCapacityChecker(cat)
    ok, details = checker.check_bound(probes)
    print(f"\nInfo-theoretic bound for ParallelArrows(4): {'PASS' if ok else 'FAIL'}")

    # Test distinguishing set analysis
    analyzer = DistinguishingSetAnalysis(cat2)
    print(f"\nDistinguishing set analysis for 4×Z/3Z:")
    print(f"  {analyzer.summary()}")
