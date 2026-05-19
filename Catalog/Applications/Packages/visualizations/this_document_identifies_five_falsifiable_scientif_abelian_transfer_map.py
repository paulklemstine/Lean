#!/usr/bin/env python3
"""
algorithms.py — Algorithms for ray class groups, transfer maps, and capitulation.

Implements the computational backbone of the formal class field theory framework:
1. Finite abelian group operations (quotients, subgroups, homomorphisms)
2. Abelian transfer map computation
3. Ray class group approximation for imaginary quadratic fields
4. Capitulation kernel detection
"""

from typing import List, Tuple, Dict, Set, Optional
from math import gcd, prod
from functools import reduce
from itertools import product


# ============================================================
# 1. Finite Abelian Group Infrastructure
# ============================================================

class FiniteAbelianGroup:
    """
    Represents a finite abelian group as a product of cyclic groups Z/n1 × ... × Z/nk.

    Attributes:
        invariants: tuple of positive integers (n1, ..., nk) with ni | ni+1
        order: the group order n1 * ... * nk

    Example:
        >>> G = FiniteAbelianGroup((2, 6))  # Z/2 × Z/6
        >>> G.order
        12
    """

    def __init__(self, invariants: Tuple[int, ...]):
        self.invariants = invariants
        self.order = prod(invariants) if invariants else 1

    def elements(self) -> List[Tuple[int, ...]]:
        """Return all elements as tuples."""
        if not self.invariants:
            return [()]
        return list(product(*(range(n) for n in self.invariants)))

    def add(self, a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        """Group operation (additive notation)."""
        return tuple((x + y) % n for x, y, n in zip(a, b, self.invariants))

    def neg(self, a: Tuple[int, ...]) -> Tuple[int, ...]:
        """Inverse."""
        return tuple((-x) % n for x, n in zip(a, self.invariants))

    def scalar_mul(self, k: int, a: Tuple[int, ...]) -> Tuple[int, ...]:
        """Scalar multiplication: k * a."""
        return tuple((k * x) % n for x, n in zip(a, self.invariants))

    def identity(self) -> Tuple[int, ...]:
        """Identity element."""
        return tuple(0 for _ in self.invariants)

    def element_order(self, a: Tuple[int, ...]) -> int:
        """Order of an element."""
        from math import lcm
        if all(x == 0 for x in a):
            return 1
        return reduce(lcm, (n // gcd(x, n) if x != 0 else 1
                            for x, n in zip(a, self.invariants)))

    def __repr__(self):
        if not self.invariants:
            return "Trivial"
        return " × ".join(f"Z/{n}Z" for n in self.invariants)


class Subgroup:
    """
    A subgroup of a finite abelian group, specified by generators.

    Example:
        >>> G = FiniteAbelianGroup((12,))
        >>> U = Subgroup(G, [(4,)])  # {0, 4, 8}
    """

    def __init__(self, parent: FiniteAbelianGroup, generators: List[Tuple[int, ...]]):
        self.parent = parent
        self.generators = generators
        self._elements: Optional[Set[Tuple[int, ...]]] = None

    @property
    def elements(self) -> Set[Tuple[int, ...]]:
        """Compute all elements by closure under the group operation."""
        if self._elements is not None:
            return self._elements

        elts = {self.parent.identity()}
        queue = list(self.generators)

        while queue:
            g = queue.pop()
            if g in elts:
                continue
            new_elts = set()
            for h in elts:
                s = self.parent.add(g, h)
                if s not in elts:
                    new_elts.add(s)
            elts.update(new_elts)
            elts.add(g)
            # Generate all multiples
            current = g
            for _ in range(self.parent.order):
                current = self.parent.add(current, g)
                if current not in elts:
                    elts.add(current)
                    queue.append(current)

        self._elements = elts
        return self._elements

    @property
    def order(self) -> int:
        return len(self.elements)

    @property
    def index(self) -> int:
        """Index [G:U]."""
        return self.parent.order // self.order

    def contains(self, x: Tuple[int, ...]) -> bool:
        return x in self.elements

    def __repr__(self):
        return f"Subgroup(order={self.order}, index={self.index})"


# ============================================================
# 2. Abelian Transfer Map
# ============================================================

def abelian_transfer(G: FiniteAbelianGroup, U: Subgroup,
                     g: Tuple[int, ...]) -> Tuple[int, ...]:
    """
    Compute the abelian transfer map Ver(g) = g^[G:U] = [G:U] · g.

    In the abelian case, the transfer is simply the [G:U]-th power map.
    This is the content of our formal theorem `abelianTransfer_apply`.

    Args:
        G: the ambient abelian group
        U: a subgroup of finite index
        g: an element of G

    Returns:
        Ver(g) = [G:U] · g

    Example:
        >>> G = FiniteAbelianGroup((12,))
        >>> U = Subgroup(G, [(4,)])  # index 3
        >>> abelian_transfer(G, U, (1,))  # 3·1 = 3
        (3,)
    """
    n = U.index
    return G.scalar_mul(n, g)


def transfer_kernel(G: FiniteAbelianGroup,
                    U: Subgroup) -> List[Tuple[int, ...]]:
    """
    Compute the kernel of the abelian transfer: {g ∈ G : [G:U]·g = 0}.

    These are the elements of order dividing [G:U].

    Args:
        G: the ambient abelian group
        U: a subgroup of finite index

    Returns:
        List of kernel elements

    Example:
        >>> G = FiniteAbelianGroup((12,))
        >>> U = Subgroup(G, [(4,)])  # index 3
        >>> transfer_kernel(G, U)
        [(0,), (4,), (8,)]
    """
    identity = G.identity()
    n = U.index
    return [g for g in G.elements() if G.scalar_mul(n, g) == identity]


def transfer_image(G: FiniteAbelianGroup,
                   U: Subgroup) -> List[Tuple[int, ...]]:
    """
    Compute the image of the abelian transfer: {[G:U]·g : g ∈ G}.

    Args:
        G: the ambient abelian group
        U: a subgroup of finite index

    Returns:
        List of image elements (deduplicated)
    """
    images = set()
    for g in G.elements():
        images.add(abelian_transfer(G, U, g))
    return sorted(images)


def verify_transfer_lands_in_subgroup(G: FiniteAbelianGroup,
                                      U: Subgroup) -> bool:
    """
    Verify that Ver(g) ∈ U for all g ∈ G.

    This is the content of our formal theorem `abelianTransfer_mem_subgroup`.

    Complexity: O(|G| · |U|) time, O(|U|) space.
    """
    for g in G.elements():
        vg = abelian_transfer(G, U, g)
        if not U.contains(vg):
            return False
    return True


# ============================================================
# 3. Quotient Refinement (Ray Class Group Precursor)
# ============================================================

def quotient_refinement_map(G: FiniteAbelianGroup,
                            H: Subgroup, N: Subgroup,
                            g: Tuple[int, ...]) -> int:
    """
    Compute the quotient refinement map G/H → G/N.

    Given H ≤ N ≤ G, sends the H-coset of g to the N-coset of g.

    Returns the index of the N-coset in a canonical enumeration.

    Complexity: O(|N|) per call.
    """
    # Find which N-coset g belongs to
    for i, n_elt in enumerate(sorted(N.elements)):
        diff = G.add(g, G.neg(n_elt))
        if diff in N.elements:
            return i
    return -1  # should not happen


def verify_quotient_refinement_surjective(
        G: FiniteAbelianGroup,
        H: Subgroup, N: Subgroup) -> bool:
    """
    Verify that the quotient refinement map G/H → G/N is surjective.

    This is the content of our formal theorem `quotientRefinementMap_surjective`.
    """
    # Compute all N-coset labels
    n_cosets = set()
    for g in G.elements():
        n_cosets.add(quotient_refinement_map(G, H, N, g))

    expected = G.order // N.order
    return len(n_cosets) == expected


# ============================================================
# 4. Ray Class Group Computation (Imaginary Quadratic)
# ============================================================

def compute_ray_class_group_iq(discriminant: int,
                                modulus_norm: int) -> Dict:
    """
    Approximate ray class group computation for imaginary quadratic fields.

    For an imaginary quadratic field K = Q(√d) with discriminant Δ and
    modulus m of norm N(m), the ray class number is approximately:

        h_m ≈ h(K) · φ(m) / [O_K* : O_{K,1,m}*]

    where φ(m) is the norm of the Euler totient and the denominator
    accounts for units congruent to 1 mod m.

    This is a simplified computation suitable for small cases.

    Args:
        discriminant: discriminant of the imaginary quadratic field
        modulus_norm: norm of the modulus ideal

    Returns:
        Dictionary with ray class group data

    Example:
        >>> compute_ray_class_group_iq(-20, 4)  # Q(√-5), m = (2), N(m) = 4
    """
    # Class numbers of imaginary quadratic fields (small discriminants)
    class_numbers = {
        -3: 1, -4: 1, -7: 1, -8: 1, -11: 1, -19: 1, -43: 1, -67: 1, -163: 1,
        -15: 2, -20: 2, -24: 2, -35: 2, -40: 2,
        -23: 3, -31: 3, -59: 3,
        -56: 4, -68: 4,
        -47: 5,
    }

    # Units: for d < -4, O_K* = {±1}, |O_K*| = 2
    # For d = -3, |O_K*| = 6; for d = -4, |O_K*| = 4
    unit_orders = {-3: 6, -4: 4}
    w = unit_orders.get(discriminant, 2)

    h = class_numbers.get(discriminant, None)
    if h is None:
        return {"error": f"Class number not tabulated for discriminant {discriminant}"}

    # Euler totient of the modulus norm (simplified for prime power norms)
    phi_m = modulus_norm
    for p in range(2, modulus_norm + 1):
        if modulus_norm % p == 0:
            phi_m = phi_m * (p - 1) // p
            while modulus_norm % p == 0:
                modulus_norm //= p

    # Units mod m: for imaginary quadratic with w = 2, all units ≡ ±1
    # The number that are ≡ 1 mod m depends on the modulus
    units_cong_1 = max(1, w // 2)  # simplified

    ray_class_number = h * phi_m // units_cong_1

    return {
        "discriminant": discriminant,
        "class_number": h,
        "unit_order": w,
        "euler_phi_modulus": phi_m,
        "units_cong_1_mod_m": units_cong_1,
        "ray_class_number": ray_class_number,
        "inequality_holds": h <= ray_class_number,
    }


# ============================================================
# 5. Capitulation Kernel Detection
# ============================================================

def detect_capitulation_kernel(
    class_group: FiniteAbelianGroup,
    extension_map: Dict[Tuple[int, ...], Tuple[int, ...]]
) -> List[Tuple[int, ...]]:
    """
    Detect the capitulation kernel: ideal classes that become principal
    in the extension.

    Args:
        class_group: the class group Cl(O_K)
        extension_map: dictionary mapping classes to their images in Cl(O_L)

    Returns:
        List of classes in the capitulation kernel

    Complexity: O(|Cl(K)|) time.
    """
    identity = class_group.identity()
    kernel = []
    for cls in class_group.elements():
        if extension_map.get(cls, None) == identity:
            kernel.append(cls)
    return kernel


def verify_capitulation_divides_class_number(
    class_group: FiniteAbelianGroup,
    kernel: List[Tuple[int, ...]]
) -> bool:
    """
    Verify that |ker| divides |Cl(K)|.

    This is the content of our formal theorem `capitulationKernel_card_dvd`.
    """
    return class_group.order % len(kernel) == 0


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # 1. Transfer map in Z/12Z
    print("\n--- Abelian Transfer in Z/12Z ---")
    G = FiniteAbelianGroup((12,))
    U = Subgroup(G, [(4,)])
    print(f"G = {G}, U = {U}")
    print(f"Transfer lands in U: {verify_transfer_lands_in_subgroup(G, U)} ✓")
    print(f"Transfer kernel: {transfer_kernel(G, U)}")
    print(f"Transfer image: {transfer_image(G, U)}")

    # 2. Transfer map in Z/2 × Z/6
    print("\n--- Abelian Transfer in Z/2 × Z/6 ---")
    G2 = FiniteAbelianGroup((2, 6))
    U2 = Subgroup(G2, [(0, 2)])  # subgroup of order 3, index 4
    print(f"G = {G2}, U = {U2}")
    print(f"Transfer lands in U: {verify_transfer_lands_in_subgroup(G2, U2)} ✓")
    print(f"Transfer kernel: {transfer_kernel(G2, U2)}")

    # 3. Ray class group approximation
    print("\n--- Ray Class Group of Q(√-5) mod (2) ---")
    rcg = compute_ray_class_group_iq(-20, 4)
    for k, v in rcg.items():
        print(f"  {k}: {v}")

    # 4. Capitulation example
    print("\n--- Capitulation in Q(√-5) → Q(√-5, i) ---")
    Cl_K = FiniteAbelianGroup((2,))
    # All classes capitulate
    ext_map = {(0,): (0,), (1,): (0,)}
    kernel = detect_capitulation_kernel(Cl_K, ext_map)
    print(f"Class group: {Cl_K}")
    print(f"Capitulation kernel: {kernel}")
    print(f"|ker| divides |Cl|: {verify_capitulation_divides_class_number(Cl_K, kernel)} ✓")
    print(f"Complete capitulation: {len(kernel) == Cl_K.order}")
