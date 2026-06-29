"""
Algorithms for Finite Probe Representability.

Implements the core algorithms from the research paper:
1. Probe separation verification
2. Probe restriction (measurement) map computation
3. Finite representable cover construction
4. Greedy minimal cover optimization

All algorithms operate on finite categories represented as:
- objects: list of hashable identifiers
- morphisms: dict mapping (source, target) to list of morphism identifiers
- composition: dict mapping (f, g) to f∘g (where g : A→B, f : B→C gives f∘g : A→C)
- identity: dict mapping object to its identity morphism

Presheaves are represented as:
- values: dict mapping object to a finite set of elements
- restriction: dict mapping morphism to a function (dict) from target values to source values
"""

from typing import Any, Callable
from itertools import product as cartesian_product


class FiniteCategory:
    """A finite category with explicit objects, morphisms, and composition."""

    def __init__(
        self,
        objects: list,
        hom: dict[tuple, list],
        compose: dict[tuple, Any],
        identity: dict,
    ):
        """
        Args:
            objects: List of objects.
            hom: Maps (source, target) to list of morphisms.
            compose: Maps (f, g) to f∘g where g:A→B, f:B→C.
            identity: Maps object to its identity morphism.
        """
        self.objects = objects
        self.hom = hom
        self.compose = compose
        self.identity = identity

    def morphisms_from(self, source: Any, target: Any) -> list:
        """All morphisms from source to target."""
        return self.hom.get((source, target), [])

    def all_morphisms(self) -> list[tuple]:
        """All (source, target, morphism) triples."""
        result = []
        for (s, t), morphs in self.hom.items():
            for m in morphs:
                result.append((s, t, m))
        return result

    @staticmethod
    def discrete(n: int) -> "FiniteCategory":
        """Discrete category on n objects (only identity morphisms)."""
        objects = list(range(n))
        hom = {(i, i): [f"id_{i}"] for i in objects}
        compose = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
        identity = {i: f"id_{i}" for i in objects}
        return FiniteCategory(objects, hom, compose, identity)

    @staticmethod
    def linear(n: int) -> "FiniteCategory":
        """Linear order category 0 → 1 → ... → n-1 with all composites."""
        objects = list(range(n))
        hom: dict[tuple, list] = {}
        compose: dict[tuple, Any] = {}
        identity = {}

        # Create morphisms f_{i,j} : i → j for i ≤ j
        for i in objects:
            for j in objects:
                if i <= j:
                    name = f"f_{i}_{j}"
                    hom.setdefault((i, j), []).append(name)

        # Identities
        for i in objects:
            identity[i] = f"f_{i}_{i}"

        # Composition: f_{j,k} ∘ f_{i,j} = f_{i,k}
        for i in objects:
            for j in objects:
                for k in objects:
                    if i <= j <= k:
                        compose[(f"f_{j}_{k}", f"f_{i}_{j}")] = f"f_{i}_{k}"

        return FiniteCategory(objects, hom, compose, identity)

    @staticmethod
    def complete(n: int) -> "FiniteCategory":
        """Complete category on n objects: one morphism between each pair plus identities."""
        objects = list(range(n))
        hom: dict[tuple, list] = {}
        compose: dict[tuple, Any] = {}
        identity = {}

        for i in objects:
            for j in objects:
                name = f"f_{i}_{j}"
                hom.setdefault((i, j), []).append(name)

        for i in objects:
            identity[i] = f"f_{i}_{i}"

        # Composition: f_{j,k} ∘ f_{i,j} = f_{i,k}
        for i in objects:
            for j in objects:
                for k in objects:
                    compose[(f"f_{j}_{k}", f"f_{i}_{j}")] = f"f_{i}_{k}"

        return FiniteCategory(objects, hom, compose, identity)


class Presheaf:
    """A presheaf F : C^op → Set on a finite category."""

    def __init__(
        self,
        cat: FiniteCategory,
        values: dict[Any, list],
        action: dict[Any, dict],
    ):
        """
        Args:
            cat: The underlying category.
            values: Maps object Y to list of elements of F(op Y).
            action: Maps morphism f:Z→Y to dict from F(op Y) elements to F(op Z) elements.
                    This is the presheaf action F.map(f.op).
        """
        self.cat = cat
        self.values = values
        self.action = action

    def restrict(self, morphism: Any, element: Any) -> Any:
        """Apply F.map(f.op) to an element. morphism f : Z → Y, element ∈ F(op Y)."""
        return self.action[morphism][element]


def verify_probe_separation(
    cat: FiniteCategory, probe_family: list, presheaf: Presheaf
) -> tuple[bool, str]:
    """
    Verify that a probe family separates elements of a presheaf.

    Algorithm: For each object Y and each distinct pair (x, y) in F(op Y),
    check if there exists Z ∈ P and f : Z → Y such that F.map(f.op)(x) ≠ F.map(f.op)(y).

    Returns:
        (True, message) if separation holds.
        (False, counterexample_description) if separation fails.
    """
    for Y in cat.objects:
        elements = presheaf.values[Y]
        for i, x in enumerate(elements):
            for j, y in enumerate(elements):
                if i >= j:
                    continue
                separated = False
                for Z in probe_family:
                    for f in cat.morphisms_from(Z, Y):
                        if presheaf.restrict(f, x) != presheaf.restrict(f, y):
                            separated = True
                            break
                    if separated:
                        break
                if not separated:
                    return (
                        False,
                        f"Elements {x} and {y} at object {Y} are not separated by probes",
                    )
    return (True, "All elements separated")


def compute_probe_restriction_map(
    cat: FiniteCategory, probe_family: list, presheaf: Presheaf, Y: Any
) -> dict:
    """
    Compute the probe restriction map Φ_{P,F,Y} for each element of F(op Y).

    Returns dict mapping element → measurement signature.
    The measurement signature is a tuple of tuples recording all restrictions.
    """
    result = {}
    for x in presheaf.values[Y]:
        signature = []
        for Z in sorted(probe_family):
            for f in cat.morphisms_from(Z, Y):
                signature.append((Z, f, presheaf.restrict(f, x)))
        result[x] = tuple(signature)
    return result


def finite_representable_cover(
    cat: FiniteCategory, presheaf: Presheaf
) -> list[tuple]:
    """
    Construct a finite representable cover (naive algorithm).

    For each object Y and each element z ∈ F(op Y), create generator (Y, z).
    The generator (Y, z) covers element z' at object Y' via morphism f : Y' → Y
    whenever F.map(f.op)(z) = z'.

    Returns list of (object, element) pairs.
    """
    generators = []
    for Y in cat.objects:
        for z in presheaf.values[Y]:
            generators.append((Y, z))
    return generators


def compute_coverage(
    cat: FiniteCategory, presheaf: Presheaf, generator: tuple
) -> set[tuple]:
    """
    Compute all elements covered by a generator (X, x).

    Element (Y, z) is covered if there exists f : Y → X with F.map(f.op)(x) = z.
    """
    X, x = generator
    covered = set()
    for Y in cat.objects:
        for f in cat.morphisms_from(Y, X):
            z = presheaf.restrict(f, x)
            covered.add((Y, z))
    return covered


def greedy_minimal_cover(
    cat: FiniteCategory, presheaf: Presheaf
) -> list[tuple]:
    """
    Compute a greedy approximation to the minimal representable cover.

    At each step, select the generator covering the most uncovered elements.

    Returns list of (object, element) generators.
    """
    all_generators = finite_representable_cover(cat, presheaf)

    # Precompute coverage for each generator
    coverage = {g: compute_coverage(cat, presheaf, g) for g in all_generators}

    uncovered = set()
    for Y in cat.objects:
        for z in presheaf.values[Y]:
            uncovered.add((Y, z))

    selected = []
    while uncovered:
        # Find generator covering most uncovered elements
        best_gen = max(all_generators, key=lambda g: len(coverage[g] & uncovered))
        selected.append(best_gen)
        uncovered -= coverage[best_gen]

    return selected


def verify_cover(
    cat: FiniteCategory, presheaf: Presheaf, generators: list[tuple]
) -> tuple[bool, str]:
    """
    Verify that a set of generators forms a valid representable cover.

    For each (Y, z) in the presheaf, check that some generator (X, x) covers it.

    Returns:
        (True, message) if cover is valid.
        (False, counterexample) if some element is not covered.
    """
    for Y in cat.objects:
        for z in presheaf.values[Y]:
            covered = False
            for X, x in generators:
                for f in cat.morphisms_from(Y, X):
                    if presheaf.restrict(f, x) == z:
                        covered = True
                        break
                if covered:
                    break
            if not covered:
                return (False, f"Element {z} at object {Y} not covered")
    return (True, "All elements covered")


if __name__ == "__main__":
    # Example: Linear category 0 → 1 → 2
    cat = FiniteCategory.linear(3)
    print("=== Linear Category (0 → 1 → 2) ===")
    print(f"Objects: {cat.objects}")
    print(f"Morphisms: {cat.hom}")

    # Define a presheaf: F(0) = {a,b}, F(1) = {c,d}, F(2) = {e}
    # with F(f_{0,1}): {c,d} → {a,b} mapping c→a, d→b
    # and F(f_{1,2}): {e} → {c,d} mapping e→c
    # and F(f_{0,2}): {e} → {a,b} mapping e→a (= F(f_{0,1}) ∘ F(f_{1,2}))
    values = {0: ["a", "b"], 1: ["c", "d"], 2: ["e"]}
    action = {
        "f_0_0": {"a": "a", "b": "b"},
        "f_1_1": {"c": "c", "d": "d"},
        "f_2_2": {"e": "e"},
        "f_0_1": {"c": "a", "d": "b"},
        "f_1_2": {"e": "c"},
        "f_0_2": {"e": "a"},
    }
    F = Presheaf(cat, values, action)

    # Test probe separation with P = {0}
    print("\n--- Probe Separation (P = {0}) ---")
    sep, msg = verify_probe_separation(cat, [0], F)
    print(f"Separated: {sep} — {msg}")

    # Test probe separation with P = {0, 1}
    print("\n--- Probe Separation (P = {0, 1}) ---")
    sep, msg = verify_probe_separation(cat, [0, 1], F)
    print(f"Separated: {sep} — {msg}")

    # Measurement map
    print("\n--- Measurement Map at object 1 (P = {0}) ---")
    mmap = compute_probe_restriction_map(cat, [0], F, 1)
    for elem, sig in mmap.items():
        print(f"  {elem} → {sig}")

    # Representable cover
    print("\n--- Naive Representable Cover ---")
    cover = finite_representable_cover(cat, F)
    print(f"Generators ({len(cover)}): {cover}")
    valid, msg = verify_cover(cat, F, cover)
    print(f"Valid: {valid} — {msg}")

    # Greedy minimal cover
    print("\n--- Greedy Minimal Cover ---")
    min_cover = greedy_minimal_cover(cat, F)
    print(f"Generators ({len(min_cover)}): {min_cover}")
    valid, msg = verify_cover(cat, F, min_cover)
    print(f"Valid: {valid} — {msg}")
