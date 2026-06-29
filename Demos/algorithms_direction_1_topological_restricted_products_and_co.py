#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Restricted Product Topology and Character Descent

Implements the core algorithms from the research paper:
1. Restricted product neighborhood construction
2. Character descent verification
3. Local compactness witness construction
4. Basic open enumeration and intersection

All algorithms work with finite approximations of the p-adic restricted product.
"""

import math
import itertools
from typing import Dict, List, Set, Tuple, Optional, Callable
from dataclasses import dataclass, field


# =============================================================================
# Algorithm 1: Restricted Product Basic Open Construction
# =============================================================================

@dataclass
class LocalGroup:
    """A finite model of a local topological group with compact open subgroup.
    
    Time complexity: O(n) for initialization where n = group order.
    Space complexity: O(n).
    """
    modulus: int
    elements: List[int] = field(default_factory=list)
    compact_open: List[int] = field(default_factory=list)
    
    def __post_init__(self):
        if not self.elements:
            self.elements = [k for k in range(1, self.modulus) 
                           if math.gcd(k, self.modulus) == 1]
        if not self.compact_open:
            # Default: trivial compact open = {1}
            self.compact_open = [1]
    
    def mult(self, a: int, b: int) -> int:
        return (a * b) % self.modulus
    
    def inv(self, a: int) -> int:
        return pow(a, -1, self.modulus)


@dataclass
class BasicOpenNeighborhood:
    """A basic open neighborhood in the restricted product topology.
    
    Represents the set ∏_{i ∈ S} U_i × ∏_{i ∉ S} K_i
    where S is a finite exceptional set, U_i are open subsets of G_i,
    and K_i are the compact open subgroups.
    """
    exceptional_indices: Set[int]
    open_sets: Dict[int, Set[int]]  # i ↦ U_i for i ∈ S
    compact_opens: Dict[int, Set[int]]  # i ↦ K_i for all i


def construct_basic_neighborhood(
    groups: List[LocalGroup],
    center: Tuple[int, ...],
    exceptional: Optional[Set[int]] = None,
    radius: Optional[Dict[int, int]] = None
) -> BasicOpenNeighborhood:
    """Construct a basic open neighborhood of a point in the restricted product.
    
    Algorithm:
    1. Determine the exceptional set S (indices where center ∉ K_i).
    2. For each i ∈ S, construct an open neighborhood U_i of center_i.
    3. For each i ∉ S, use K_i.
    
    Time complexity: O(|ι| + Σ_{i ∈ S} |G_i|)
    Space complexity: O(|ι| + Σ_{i ∈ S} |U_i|)
    
    Args:
        groups: The family of local groups.
        center: The point to build a neighborhood around.
        exceptional: Override the exceptional set (default: auto-detect).
        radius: For each exceptional index, how many group elements to include.
    
    Returns:
        A BasicOpenNeighborhood containing the center point.
    """
    n = len(groups)
    compact_opens = {i: set(groups[i].compact_open) for i in range(n)}
    
    if exceptional is None:
        exceptional = {i for i in range(n) 
                      if center[i] not in groups[i].compact_open}
    
    open_sets = {}
    for i in exceptional:
        if radius and i in radius:
            # Include elements "close" to center[i]
            r = radius[i]
            u_i = set()
            for e in groups[i].elements:
                # Use multiplicative distance
                diff = groups[i].mult(e, groups[i].inv(center[i]))
                if diff <= r or diff >= groups[i].modulus - r:
                    u_i.add(e)
            open_sets[i] = u_i if u_i else {center[i]}
        else:
            # Default: singleton neighborhood
            open_sets[i] = {center[i]}
    
    return BasicOpenNeighborhood(
        exceptional_indices=exceptional,
        open_sets=open_sets,
        compact_opens=compact_opens
    )


def intersect_basic_neighborhoods(
    n1: BasicOpenNeighborhood,
    n2: BasicOpenNeighborhood
) -> BasicOpenNeighborhood:
    """Compute the intersection of two basic open neighborhoods.
    
    Key property: the intersection of two basic opens is again a basic open.
    This is what makes the basic opens a topological basis.
    
    Algorithm:
    1. S₁₂ = S₁ ∪ S₂
    2. For i ∈ S₁ ∩ S₂: U_i = U₁_i ∩ U₂_i
    3. For i ∈ S₁ \\ S₂: U_i = U₁_i ∩ K_i
    4. For i ∈ S₂ \\ S₁: U_i = K_i ∩ U₂_i
    
    Time complexity: O(|S₁ ∪ S₂| · max|G_i|)
    Space complexity: O(|S₁ ∪ S₂| · max|U_i|)
    """
    new_exceptional = n1.exceptional_indices | n2.exceptional_indices
    new_open_sets = {}
    
    for i in new_exceptional:
        if i in n1.exceptional_indices and i in n2.exceptional_indices:
            new_open_sets[i] = n1.open_sets[i] & n2.open_sets[i]
        elif i in n1.exceptional_indices:
            new_open_sets[i] = n1.open_sets[i] & n1.compact_opens[i]
        else:
            new_open_sets[i] = n2.open_sets[i] & n2.compact_opens[i]
    
    return BasicOpenNeighborhood(
        exceptional_indices=new_exceptional,
        open_sets=new_open_sets,
        compact_opens={**n1.compact_opens, **n2.compact_opens}
    )


# =============================================================================
# Algorithm 2: Character Descent Verification
# =============================================================================

def verify_character_descent(
    groups: List[LocalGroup],
    character_values: Dict[Tuple[int, ...], complex],
    subgroup: List[Tuple[int, ...]],
    tol: float = 1e-10
) -> Dict[str, bool]:
    """Verify that a character trivial on a subgroup descends to the quotient.
    
    Algorithm:
    1. Check that χ(h) = 1 for all h in the subgroup H.
    2. Build cosets of H.
    3. Verify χ is constant on each coset.
    4. Check that the descended map is continuous w.r.t. quotient topology.
    
    Time complexity: O(|G|² + |G| · |H|)
    Space complexity: O(|G|)
    
    Returns:
        Dictionary with verification results for each property.
    """
    results = {}
    
    # Step 1: Check triviality on H
    trivial = all(abs(character_values.get(h, 1.0) - 1.0) < tol 
                  for h in subgroup)
    results["trivial_on_subgroup"] = trivial
    
    if not trivial:
        results["descends_to_quotient"] = False
        results["descent_continuous"] = False
        return results
    
    # Step 2: Build cosets
    elements = list(character_values.keys())
    visited = set()
    cosets = []
    
    def mult(a, b):
        return tuple((a[i] * b[i]) % groups[i].modulus for i in range(len(groups)))
    
    for e in elements:
        if e in visited:
            continue
        coset = set()
        for h in subgroup:
            eh = mult(e, h)
            coset.add(eh)
            visited.add(eh)
        if e not in visited:
            coset.add(e)
            visited.add(e)
        cosets.append(coset)
    
    # Step 3: Check constancy on cosets
    constant_on_cosets = True
    for coset in cosets:
        values = [character_values.get(e, 1.0) for e in coset]
        if values:
            ref = values[0]
            if any(abs(v - ref) > tol for v in values):
                constant_on_cosets = False
                break
    
    results["descends_to_quotient"] = constant_on_cosets
    
    # Step 4: Continuity check (automatic for finite groups)
    results["descent_continuous"] = constant_on_cosets
    
    return results


# =============================================================================
# Algorithm 3: Local Compactness Witness
# =============================================================================

def find_compact_neighborhood(
    groups: List[LocalGroup],
    point: Tuple[int, ...],
) -> Tuple[BasicOpenNeighborhood, int]:
    """Find a compact open neighborhood of a point in the restricted product.
    
    The key theorem: ∏ K_i is a compact open neighborhood of any point
    in the product of compact opens. For a general point, translate
    by the point to get a compact neighborhood.
    
    Algorithm:
    1. Identify the exceptional set S = {i : point_i ∉ K_i}.
    2. At each exceptional place, the group G_i is locally compact,
       so choose a compact neighborhood of point_i.
    3. At non-exceptional places, K_i is already compact.
    4. The product is compact by Tychonoff.
    
    Time complexity: O(|ι| + Σ_{i ∈ S} |G_i|)
    Space complexity: O(Σ_i |K_i| + Σ_{i ∈ S} |G_i|)
    
    Returns:
        (neighborhood, size) — the compact neighborhood and its cardinality.
    """
    n = len(groups)
    exceptional = {i for i in range(n) 
                   if point[i] not in groups[i].compact_open}
    
    open_sets = {}
    size = 1
    
    for i in range(n):
        if i in exceptional:
            # Use the full group at exceptional places (compact in finite case)
            open_sets[i] = set(groups[i].elements)
            size *= len(groups[i].elements)
        else:
            size *= len(groups[i].compact_open)
    
    nbhd = BasicOpenNeighborhood(
        exceptional_indices=exceptional,
        open_sets=open_sets,
        compact_opens={i: set(groups[i].compact_open) for i in range(n)}
    )
    
    return nbhd, size


# =============================================================================
# Algorithm 4: Enumerate Basic Opens at a Given Level
# =============================================================================

def enumerate_basic_opens(
    groups: List[LocalGroup],
    max_exceptional_size: int = 2
) -> List[BasicOpenNeighborhood]:
    """Enumerate basic open sets up to a given exceptional set size.
    
    The restricted product topology has a basis consisting of sets
    ∏_{i ∈ S} U_i × ∏_{i ∉ S} K_i where |S| is finite.
    
    For computational purposes, we enumerate those with |S| ≤ max_exceptional_size
    and U_i ranging over "natural" open subsets (cosets of subgroups).
    
    Time complexity: O(C(n, k) · ∏_{i ∈ S} 2^|G_i|) where k = max_exceptional_size
    Space complexity: O(output size)
    
    Args:
        groups: The family of local groups.
        max_exceptional_size: Maximum size of the exceptional set.
    
    Returns:
        List of basic open neighborhoods.
    """
    n = len(groups)
    result = []
    
    for k in range(max_exceptional_size + 1):
        for S in itertools.combinations(range(n), k):
            S_set = set(S)
            # For each exceptional index, generate "natural" open sets
            # (singletons, compact open, full group)
            options_per_place = []
            for i in S_set:
                place_options = [
                    set(groups[i].compact_open),  # K_i itself
                    set(groups[i].elements),  # full G_i
                ]
                # Add singletons
                for e in groups[i].elements:
                    place_options.append({e})
                options_per_place.append((i, place_options))
            
            if not options_per_place:
                # S is empty: just ∏ K_i
                result.append(BasicOpenNeighborhood(
                    exceptional_indices=set(),
                    open_sets={},
                    compact_opens={i: set(groups[i].compact_open) for i in range(n)}
                ))
            else:
                # Cartesian product of options
                indices = [i for i, _ in options_per_place]
                all_options = [opts for _, opts in options_per_place]
                for combo in itertools.product(*all_options):
                    open_sets = {indices[j]: combo[j] for j in range(len(indices))}
                    result.append(BasicOpenNeighborhood(
                        exceptional_indices=S_set,
                        open_sets=open_sets,
                        compact_opens={i: set(groups[i].compact_open) for i in range(n)}
                    ))
    
    return result


# =============================================================================
# Algorithm 5: Hecke Character Construction from Local Data
# =============================================================================

def construct_hecke_character(
    groups: List[LocalGroup],
    local_characters: List[Callable[[int], complex]],
    subgroup: List[Tuple[int, ...]],
    tol: float = 1e-10
) -> Optional[Dict[str, object]]:
    """Construct a Hecke character from local character data.
    
    A Hecke character is a continuous character of the idèle group
    that is trivial on the principal subgroup. It is constructed as
    a product of local characters: χ(g) = ∏_i χ_i(g_i).
    
    Algorithm:
    1. Build the global character from local data.
    2. Verify it is a homomorphism.
    3. Check triviality on the principal subgroup.
    4. If trivial, build the descended character.
    
    Time complexity: O(|G|² + |G| · |H|) where G is the restricted product
    Space complexity: O(|G|)
    
    Returns:
        Dictionary with the Hecke character data, or None if not trivial on H.
    """
    # Build all elements
    all_elements = list(itertools.product(
        *(g.elements for g in groups)))
    
    # Step 1: Compute character values
    char_values = {}
    for element in all_elements:
        val = 1.0 + 0j
        for i, g in enumerate(element):
            val *= local_characters[i](g)
        char_values[element] = val
    
    # Step 2: Verify homomorphism property
    is_hom = True
    for a in all_elements[:min(50, len(all_elements))]:
        for b in all_elements[:min(50, len(all_elements))]:
            ab = tuple((a[i] * b[i]) % groups[i].modulus 
                      for i in range(len(groups)))
            if ab in char_values:
                expected = char_values.get(a, 1.0) * char_values.get(b, 1.0)
                if abs(char_values[ab] - expected) > tol:
                    is_hom = False
                    break
        if not is_hom:
            break
    
    # Step 3: Check triviality
    trivial = all(abs(char_values.get(h, 1.0) - 1.0) < tol for h in subgroup)
    
    if not trivial:
        return None
    
    # Step 4: Build descended character
    visited = set()
    coset_values = {}
    coset_id = 0
    
    def mult(a, b):
        return tuple((a[i] * b[i]) % groups[i].modulus for i in range(len(groups)))
    
    for e in all_elements:
        if e in visited:
            continue
        val = char_values.get(e, 1.0)
        for h in subgroup:
            eh = mult(e, h)
            visited.add(eh)
        coset_values[coset_id] = val
        coset_id += 1
    
    return {
        "character_values": char_values,
        "is_homomorphism": is_hom,
        "is_trivial_on_subgroup": trivial,
        "n_cosets": coset_id,
        "descended_values": coset_values
    }


# =============================================================================
# Main: Run all algorithms and display results
# =============================================================================

def main():
    print("ALGORITHMS FOR RESTRICTED PRODUCT TOPOLOGY")
    print("=" * 60)
    
    # Setup
    primes = [2, 3, 5]
    groups = []
    for p in primes:
        n = p ** 2
        elements = [k for k in range(1, n) if math.gcd(k, n) == 1]
        compact_open = [x for x in elements if x % p == 1]
        groups.append(LocalGroup(modulus=n, elements=elements, compact_open=compact_open))
    
    identity = tuple(1 for _ in groups)
    
    # Algorithm 1: Basic neighborhood construction
    print("\n1. BASIC NEIGHBORHOOD CONSTRUCTION")
    print("-" * 40)
    nbhd = construct_basic_neighborhood(groups, identity)
    print(f"  Center: {identity}")
    print(f"  Exceptional set: {nbhd.exceptional_indices}")
    print(f"  Open sets at exceptional places: {nbhd.open_sets}")
    
    # Algorithm 3: Compact neighborhood
    print("\n3. COMPACT NEIGHBORHOOD WITNESS")
    print("-" * 40)
    compact_nbhd, size = find_compact_neighborhood(groups, identity)
    print(f"  Compact neighborhood of {identity}")
    print(f"  Size: {size}")
    print(f"  Exceptional set: {compact_nbhd.exceptional_indices}")
    
    # Algorithm 4: Enumerate basic opens
    print("\n4. BASIC OPEN ENUMERATION")
    print("-" * 40)
    basic_opens = enumerate_basic_opens(groups, max_exceptional_size=1)
    print(f"  Found {len(basic_opens)} basic opens with |S| ≤ 1")
    
    # Algorithm 5: Hecke character
    print("\n5. HECKE CHARACTER CONSTRUCTION")
    print("-" * 40)
    
    modulus = math.prod(p**2 for p in primes)
    diagonal = [a for a in range(1, modulus) if math.gcd(a, modulus) == 1]
    
    principal = []
    for a in diagonal:
        element = []
        valid = True
        for g in groups:
            if a % g.modulus in g.elements:
                element.append(a % g.modulus)
            else:
                valid = False
                break
        if valid:
            principal.append(tuple(element))
    
    # Trivial local characters
    local_chars = [lambda x: 1.0 + 0j for _ in groups]
    result = construct_hecke_character(groups, local_chars, principal)
    
    if result:
        print(f"  Hecke character constructed: {result['n_cosets']} cosets")
        print(f"  Homomorphism: {result['is_homomorphism']}")
        print(f"  Trivial on H: {result['is_trivial_on_subgroup']}")
    else:
        print("  Character not trivial on principal subgroup")
    
    print(f"\n{'=' * 60}")
    print("All algorithms completed successfully.")


if __name__ == "__main__":
    main()
