"""
Algorithms for Probe Complexity and Representable Dimension Theory

This module implements the core algorithms for computing measurement invariants,
representable dimensions, and constructing representable covers for finite
discrete categories with probe families.

All algorithms are proved correct in the companion Lean 4 formalization.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, FrozenSet, Callable, Optional
import itertools


@dataclass
class DiscreteCategory:
    """A finite discrete category, specified by its set of objects.
    
    In a discrete category, the only morphisms are identities,
    so a presheaf is simply a family of finite sets indexed by objects.
    """
    objects: List[str]
    
    def __post_init__(self):
        assert len(self.objects) == len(set(self.objects)), "Objects must be distinct"
    
    @property
    def num_objects(self) -> int:
        return len(self.objects)


@dataclass
class Presheaf:
    """A finite-valued presheaf on a discrete category.
    
    Represented as a dictionary mapping each object to a finite set of elements.
    """
    fibers: Dict[str, List[str]]
    
    def fiber_card(self, obj: str) -> int:
        """Cardinality of the fiber at object `obj`."""
        return len(self.fibers.get(obj, []))
    
    def objectwise_total_card(self) -> int:
        """Total objectwise cardinality: sum of |F(Y)| over all objects.
        
        This equals the representable dimension for discrete categories.
        
        Complexity: O(|Ob|)
        """
        return sum(len(v) for v in self.fibers.values())
    
    @property
    def representable_dimension(self) -> int:
        """The representable dimension = objectwise total cardinality.
        
        Theorem (grand_challenge_discrete): Under probe separation,
        this equals the measurement invariant.
        """
        return self.objectwise_total_card()


@dataclass
class ProbeFamily:
    """A probe family: a finite subset of objects used for measurement.
    
    The probe family induces measurement signatures via restriction maps.
    """
    probes: List[str]
    
    @property
    def size(self) -> int:
        return len(self.probes)


@dataclass 
class RestrictionMap:
    """A restriction map r(Y, Z) mapping elements of F(Y) to elements of F(Z).
    
    For discrete categories with identity-only morphisms, the natural restriction
    is: r(Y, Y)(x) = x (identity) and r(Y, Z)(x) is some fixed element for Y ≠ Z.
    
    For more interesting examples, we allow arbitrary restriction functions.
    """
    mapping: Dict[Tuple[str, str], Dict[str, str]]
    
    def restrict(self, from_obj: str, to_obj: str, element: str) -> str:
        """Apply restriction r(from_obj, to_obj)(element)."""
        key = (from_obj, to_obj)
        if key in self.mapping and element in self.mapping[key]:
            return self.mapping[key][element]
        return element  # default: identity-like


def compute_probe_signature(
    presheaf: Presheaf,
    probe_family: ProbeFamily, 
    restriction: RestrictionMap,
    obj: str,
    element: str
) -> Tuple[str, ...]:
    """Compute the probe signature of an element x ∈ F(Y).
    
    The signature is the tuple (r(Y, Z₁)(x), r(Y, Z₂)(x), ...) for all Z_i ∈ P.
    
    Args:
        presheaf: The presheaf F
        probe_family: The probe family P
        restriction: The restriction map r
        obj: The object Y
        element: The element x ∈ F(Y)
    
    Returns:
        Tuple of restricted values, one per probe object.
    
    Complexity: O(|P|) per element.
    """
    return tuple(
        restriction.restrict(obj, probe, element)
        for probe in probe_family.probes
    )


def compute_measurement_space(
    presheaf: Presheaf,
    probe_family: ProbeFamily,
    restriction: RestrictionMap,
    obj: str
) -> Set[Tuple[str, ...]]:
    """Compute the measurement space at object Y.
    
    This is the image of the probe signature map: the set of all
    distinct signatures realized by elements of F(Y).
    
    Args:
        presheaf: The presheaf F
        probe_family: The probe family P  
        restriction: The restriction map r
        obj: The object Y
    
    Returns:
        Set of distinct probe signatures at Y.
    
    Complexity: O(|F(Y)| · |P|)
    """
    signatures = set()
    for element in presheaf.fibers.get(obj, []):
        sig = compute_probe_signature(presheaf, probe_family, restriction, obj, element)
        signatures.add(sig)
    return signatures


def compute_measurement_space_card(
    presheaf: Presheaf,
    probe_family: ProbeFamily,
    restriction: RestrictionMap,
    obj: str
) -> int:
    """Compute |MeasurementSpace(P, Y)|.
    
    Complexity: O(|F(Y)| · |P|)
    """
    return len(compute_measurement_space(presheaf, probe_family, restriction, obj))


def compute_measurement_invariant(
    category: DiscreteCategory,
    presheaf: Presheaf,
    probe_family: ProbeFamily,
    restriction: RestrictionMap
) -> int:
    """Compute the measurement invariant: Σ_Y |MeasurementSpace(P, Y)|.
    
    This is the total information budget of the probe family.
    
    Theorem (representableDimension_le_measurementInvariant):
        representable_dimension(F) ≤ measurement_invariant(P)
        when P separates F.
    
    Theorem (grand_challenge_discrete):
        representable_dimension(F) = measurement_invariant(P)
        when P separates F (discrete case).
    
    Args:
        category: The discrete category C
        presheaf: The presheaf F
        probe_family: The probe family P
        restriction: The restriction map r
    
    Returns:
        The measurement invariant.
    
    Complexity: O(|Ob| · max|F(Y)| · |P|)
    """
    total = 0
    for obj in category.objects:
        total += compute_measurement_space_card(presheaf, probe_family, restriction, obj)
    return total


def check_probe_separation(
    category: DiscreteCategory,
    presheaf: Presheaf,
    probe_family: ProbeFamily,
    restriction: RestrictionMap
) -> Tuple[bool, Optional[Tuple[str, str, str]]]:
    """Check whether the probe family separates the presheaf.
    
    Separation means: for each object Y, the probe signature map
    F(Y) → Π_{Z∈P} F(Z) is injective.
    
    Returns:
        (True, None) if separated.
        (False, (obj, elem1, elem2)) if elem1 ≠ elem2 in F(obj) have same signature.
    
    Complexity: O(|Ob| · |F(Y)|² · |P|) worst case,
                O(|Ob| · |F(Y)| · |P|) with hashing.
    """
    for obj in category.objects:
        seen: Dict[Tuple[str, ...], str] = {}
        for element in presheaf.fibers.get(obj, []):
            sig = compute_probe_signature(presheaf, probe_family, restriction, obj, element)
            if sig in seen:
                return False, (obj, seen[sig], element)
            seen[sig] = element
    return True, None


def construct_representable_cover(
    category: DiscreteCategory,
    presheaf: Presheaf,
    probe_family: ProbeFamily,
    restriction: RestrictionMap
) -> List[Tuple[str, str]]:
    """Construct a representable cover from measurement signatures.
    
    For each object Y and each element x ∈ F(Y), we produce a generator
    (Y, x). The cover size equals representable_dimension(F).
    
    When signatures are injective, each generator corresponds to a unique
    measurement signature, giving a bijection between generators and
    the measurement space.
    
    Returns:
        List of (object, element) pairs forming the cover.
    
    Complexity: O(|Ob| · max|F(Y)|)
    """
    cover = []
    for obj in category.objects:
        for element in presheaf.fibers.get(obj, []):
            cover.append((obj, element))
    return cover


def compute_observable_sections_count(
    category: DiscreteCategory,
    presheaf: Presheaf
) -> int:
    """Compute the number of observable sections: Π_Y |F(Y)|.
    
    Theorem (observable_sections_card):
        |sections| = Π_Y |F(Y)|
    
    Theorem (observable_sections_eq_prod_measurementSpace):
        Under separation, |sections| = Π_Y |MeasurementSpace(P,Y)|
    
    Complexity: O(|Ob|)
    """
    product = 1
    for obj in category.objects:
        product *= presheaf.fiber_card(obj)
    return product


def brute_force_max_representable_dimension(
    category: DiscreteCategory,
    probe_family: ProbeFamily,
    restriction: RestrictionMap,
    max_fiber_size: int = 4
) -> Tuple[int, Optional[Presheaf]]:
    """Brute-force search for the maximum representable dimension
    among all separated presheaves with bounded fiber sizes.
    
    This implements the supremum computation:
        sup_F repDim(F) over F separated by P
    
    Args:
        category: The discrete category
        probe_family: The probe family
        restriction: The restriction map
        max_fiber_size: Maximum allowed fiber size at each object
    
    Returns:
        (max_dim, witness_presheaf) achieving the maximum.
    
    Complexity: Exponential in |Ob| · max_fiber_size (exhaustive search).
    """
    best_dim = 0
    best_presheaf = None
    
    # For each object, try all possible fiber sizes
    # Elements are named "e0", "e1", ..., "e_{k-1}" 
    all_element_pools = {}
    for obj in category.objects:
        all_element_pools[obj] = [f"{obj}_e{i}" for i in range(max_fiber_size)]
    
    # Enumerate all possible fiber size combinations
    size_ranges = [range(max_fiber_size + 1) for _ in category.objects]
    
    for sizes in itertools.product(*size_ranges):
        fibers = {}
        for obj, size in zip(category.objects, sizes):
            fibers[obj] = all_element_pools[obj][:size]
        
        presheaf = Presheaf(fibers=fibers)
        is_sep, _ = check_probe_separation(category, presheaf, probe_family, restriction)
        
        if is_sep:
            dim = presheaf.representable_dimension
            if dim > best_dim:
                best_dim = dim
                best_presheaf = presheaf
    
    return best_dim, best_presheaf


def identity_restriction(category: DiscreteCategory) -> RestrictionMap:
    """Create the identity restriction map: r(Y, Y)(x) = x, r(Y, Z)(x) = default for Y≠Z.
    
    For discrete categories, this is the most natural restriction map.
    It makes probe separation trivially satisfied (every signature is injective
    since r(Y,Y) is the identity and Y ∈ P for any reasonable probe family).
    """
    mapping: Dict[Tuple[str, str], Dict[str, str]] = {}
    return RestrictionMap(mapping=mapping)


if __name__ == "__main__":
    # Example: 3-object discrete category
    cat = DiscreteCategory(objects=["A", "B", "C"])
    
    # Presheaf with fibers of sizes 2, 3, 1
    F = Presheaf(fibers={
        "A": ["a1", "a2"],
        "B": ["b1", "b2", "b3"],
        "C": ["c1"]
    })
    
    # Full probe family
    P = ProbeFamily(probes=["A", "B", "C"])
    r = identity_restriction(cat)
    
    print(f"Category: {cat.objects}")
    print(f"Fiber sizes: { {obj: F.fiber_card(obj) for obj in cat.objects} }")
    print(f"Representable dimension: {F.representable_dimension}")
    print(f"Measurement invariant: {compute_measurement_invariant(cat, F, P, r)}")
    print(f"Observable sections: {compute_observable_sections_count(cat, F)}")
    
    is_sep, witness = check_probe_separation(cat, F, P, r)
    print(f"Probe separates: {is_sep}")
    
    cover = construct_representable_cover(cat, F, P, r)
    print(f"Cover size: {len(cover)}")
    print(f"Cover: {cover}")
