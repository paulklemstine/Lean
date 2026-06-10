#!/usr/bin/env python3
"""
Algorithms for Probe Complexity and Karoubi Envelope Computation

This module implements:
  1. Exact computation of κ(C) via brute-force search with pruning
  2. Karoubi envelope construction for finite categories
  3. Certified comparison: κ(C) vs κ(Kar(C))
  4. Retract profile computation

Time complexity:
  - κ computation: O(2^n * m^2 * n * H) where n = |Obj(C)|, m = max |Hom|, H = total morphisms
  - Karoubi construction: O(n * E^2) where E = max |End(X)|
  - Retract profile: O(|Kar(C)| * |P| * H)
"""

from typing import Dict, List, Tuple, Set, Optional, FrozenSet
from itertools import combinations
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Morphism:
    """A morphism in a finite category."""
    name: str
    source: str
    target: str


@dataclass
class FiniteCategory:
    """
    A finite category with explicit composition table.

    Attributes:
        name: Human-readable name
        objects: Set of object names
        morphisms: Set of all morphisms
        hom: Maps (source, target) to set of morphisms
        compose: Maps (f, g) to f ≫ g for composable pairs
        identity: Maps object to its identity morphism
    """
    name: str
    objects: FrozenSet[str]
    morphisms: FrozenSet[Morphism]
    hom: Dict[Tuple[str, str], FrozenSet[Morphism]]
    compose: Dict[Tuple[Morphism, Morphism], Morphism]
    identity: Dict[str, Morphism]

    def parallel_pairs(self) -> List[Tuple[Morphism, Morphism]]:
        """Return all pairs of distinct parallel morphisms."""
        pairs = []
        for (s, t), mors in self.hom.items():
            mor_list = sorted(mors, key=lambda m: m.name)
            for i, f in enumerate(mor_list):
                for g in mor_list[i+1:]:
                    pairs.append((f, g))
        return pairs

    def has_nontrivial_hom(self) -> bool:
        """Check if any hom-set has more than one morphism."""
        return any(len(mors) > 1 for mors in self.hom.values())


@dataclass(frozen=True)
class KaroubiObject:
    """An object (X, p) of the Karoubi envelope."""
    X: str
    p: Morphism  # idempotent: p ≫ p = p


def find_idempotents(cat: FiniteCategory) -> Dict[str, List[Morphism]]:
    """
    Find all idempotent endomorphisms in each object.

    Returns:
        Dictionary mapping each object to its list of idempotent endomorphisms.

    Time: O(n * E^2) where E = max |End(X)|
    """
    result: Dict[str, List[Morphism]] = {}
    for X in cat.objects:
        endos = cat.hom.get((X, X), frozenset())
        idemps = []
        for p in endos:
            pp = cat.compose.get((p, p))
            if pp == p:
                idemps.append(p)
        result[X] = idemps
    return result


def build_karoubi_envelope(cat: FiniteCategory) -> FiniteCategory:
    """
    Construct the Karoubi envelope Kar(C).

    Objects: (X, p) where p : X → X is idempotent
    Morphisms (X,p) → (Y,q): f : X → Y with p ≫ f ≫ q = f
    Composition: inherited from C
    Identity on (X,p): p itself

    Time: O(n * E^2 + K^2 * H) where K = |Kar(C)|, H = max hom size

    Returns:
        The Karoubi envelope as a FiniteCategory
    """
    idemps = find_idempotents(cat)

    # Build Karoubi objects
    kar_objs: List[KaroubiObject] = []
    for X in sorted(cat.objects):
        for p in idemps[X]:
            kar_objs.append(KaroubiObject(X, p))

    obj_names = frozenset(repr(o) for o in kar_objs)

    # Build morphisms
    all_morphisms: Set[Morphism] = set()
    hom: Dict[Tuple[str, str], FrozenSet[Morphism]] = {}

    for s_obj in kar_objs:
        for t_obj in kar_objs:
            mors = []
            for f in cat.hom.get((s_obj.X, t_obj.X), frozenset()):
                # Check p ≫ f ≫ q = f
                pf = cat.compose.get((s_obj.p, f))
                if pf is not None:
                    pfq = cat.compose.get((pf, t_obj.p))
                    if pfq == f:
                        kar_mor = Morphism(
                            name=f"[{f.name}:{repr(s_obj)}->{repr(t_obj)}]",
                            source=repr(s_obj),
                            target=repr(t_obj)
                        )
                        mors.append(kar_mor)
                        all_morphisms.add(kar_mor)
            hom[(repr(s_obj), repr(t_obj))] = frozenset(mors)

    # Build composition (using underlying composition)
    compose: Dict[Tuple[Morphism, Morphism], Morphism] = {}
    # We need to track which underlying morphism each Kar morphism corresponds to
    underlying: Dict[Morphism, Morphism] = {}

    for s_obj in kar_objs:
        for t_obj in kar_objs:
            for f in cat.hom.get((s_obj.X, t_obj.X), frozenset()):
                pf = cat.compose.get((s_obj.p, f))
                if pf is not None:
                    pfq = cat.compose.get((pf, t_obj.p))
                    if pfq == f:
                        kar_f = Morphism(
                            name=f"[{f.name}:{repr(s_obj)}->{repr(t_obj)}]",
                            source=repr(s_obj),
                            target=repr(t_obj)
                        )
                        underlying[kar_f] = f

    # Now build composition
    for kar_f, uf in underlying.items():
        for kar_g, ug in underlying.items():
            if kar_f.target == kar_g.source:
                fg = cat.compose.get((uf, ug))
                if fg is not None:
                    # Find the Karoubi morphism corresponding to fg
                    result_name = f"[{fg.name}:{kar_f.source}->{kar_g.target}]"
                    result = Morphism(name=result_name,
                                     source=kar_f.source,
                                     target=kar_g.target)
                    if result in all_morphisms:
                        compose[(kar_f, kar_g)] = result

    # Identities: on (X,p), identity is p
    identity: Dict[str, Morphism] = {}
    for obj in kar_objs:
        kar_id = Morphism(
            name=f"[{obj.p.name}:{repr(obj)}->{repr(obj)}]",
            source=repr(obj),
            target=repr(obj)
        )
        identity[repr(obj)] = kar_id

    return FiniteCategory(
        name=f"Kar({cat.name})",
        objects=obj_names,
        morphisms=frozenset(all_morphisms),
        hom=hom,
        compose=compose,
        identity=identity
    )


def probe_separates_pair(
    cat: FiniteCategory,
    probe: str,
    f: Morphism,
    g: Morphism
) -> bool:
    """Check if a single probe object separates morphisms f and g."""
    for h in cat.hom.get((probe, f.source), frozenset()):
        hf = cat.compose.get((h, f))
        hg = cat.compose.get((h, g))
        if hf != hg:
            return True
    return False


def probe_family_separates(
    cat: FiniteCategory,
    probes: FrozenSet[str]
) -> bool:
    """
    Check if a probe family separates all parallel morphisms.

    Time: O(|probes| * P * H) where P = number of parallel pairs,
          H = max hom-set size
    """
    for f, g in cat.parallel_pairs():
        separated = False
        for Z in probes:
            if probe_separates_pair(cat, Z, f, g):
                separated = True
                break
        if not separated:
            return False
    return True


def compute_kappa(cat: FiniteCategory) -> int:
    """
    Compute κ(C) = minimum cardinality of a separating probe family.

    Algorithm: Exhaustive search over subsets of objects, ordered by cardinality.
    Pruning: skip if no parallel morphisms exist (κ = 0).

    Time: O(2^n * P * n * H) worst case
    Space: O(n + P + H)

    Returns:
        The probe complexity κ(C)
    """
    if not cat.has_nontrivial_hom():
        return 0

    obj_list = sorted(cat.objects)
    n = len(obj_list)

    for size in range(1, n + 1):
        for subset in combinations(obj_list, size):
            if probe_family_separates(cat, frozenset(subset)):
                return size

    return n


def compute_retract_profile(
    cat: FiniteCategory,
    kar: FiniteCategory,
    probes: FrozenSet[str],
    kar_obj: str
) -> Dict[str, int]:
    """
    Compute the retract profile of a Karoubi object relative to probes.

    The retract profile records |Hom((Z, id), (X, p))| for each probe Z.

    Returns:
        Dictionary mapping probe name to hom-set cardinality
    """
    profile = {}
    for Z in sorted(probes):
        # Find the embedded probe (Z, id_Z) in Kar
        embedded = f"KaroubiObject(X='{Z}', p=Morphism(...))"
        # Count morphisms from embedded probe to kar_obj
        count = len(kar.hom.get((Z, kar_obj), frozenset()))
        profile[Z] = count
    return profile


def certified_kappa_comparison(cat: FiniteCategory) -> dict:
    """
    Compute κ(C) and κ(Kar(C)), returning a certificate of comparison.

    Returns:
        Dictionary with keys:
        - 'category': name of C
        - 'kappa_C': κ(C)
        - 'kappa_Kar': κ(Kar(C))
        - 'kar_objects': number of objects in Kar(C)
        - 'kar_morphisms': number of morphisms in Kar(C)
        - 'invariant': boolean, True if κ(C) = κ(Kar(C))
        - 'idempotent_count': number of idempotents per object
    """
    kappa_C = compute_kappa(cat)
    kar = build_karoubi_envelope(cat)
    kappa_Kar = compute_kappa(kar)
    idemps = find_idempotents(cat)

    return {
        'category': cat.name,
        'kappa_C': kappa_C,
        'kappa_Kar': kappa_Kar,
        'objects_C': len(cat.objects),
        'morphisms_C': len(cat.morphisms),
        'kar_objects': len(kar.objects),
        'kar_morphisms': len(kar.morphisms),
        'invariant': kappa_C == kappa_Kar,
        'idempotent_count': {X: len(ps) for X, ps in idemps.items()},
    }


# ─────────────────────────────────────────────────────────────────
# Helper: build categories from simple specifications
# ─────────────────────────────────────────────────────────────────

def category_from_monoid(
    name: str,
    elements: List[str],
    mult: Dict[Tuple[str, str], str],
    identity: str
) -> FiniteCategory:
    """Build a one-object category from a monoid multiplication table."""
    obj = "⋆"
    morphisms = frozenset(
        Morphism(name=e, source=obj, target=obj) for e in elements
    )
    hom = {(obj, obj): morphisms}
    compose = {}
    for a_name in elements:
        for b_name in elements:
            a = Morphism(a_name, obj, obj)
            b = Morphism(b_name, obj, obj)
            ab = Morphism(mult[(a_name, b_name)], obj, obj)
            compose[(a, b)] = ab
    id_mor = Morphism(identity, obj, obj)
    return FiniteCategory(
        name=name,
        objects=frozenset([obj]),
        morphisms=morphisms,
        hom=hom,
        compose=compose,
        identity={obj: id_mor}
    )


if __name__ == "__main__":
    # Quick test
    print("Algorithms module loaded successfully.")
    print("Available functions:")
    print("  - compute_kappa(cat): Compute probe complexity")
    print("  - build_karoubi_envelope(cat): Construct Karoubi envelope")
    print("  - certified_kappa_comparison(cat): Compare κ(C) vs κ(Kar(C))")
    print("  - find_idempotents(cat): Find idempotent endomorphisms")
    print("  - compute_retract_profile(...): Compute observation profile")
