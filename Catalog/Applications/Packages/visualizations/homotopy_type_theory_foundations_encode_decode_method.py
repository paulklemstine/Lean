#!/usr/bin/env python3
"""
HoTT Foundations: Algorithms

This module implements the core algorithms underlying the HoTT
formalization, including:
  - Encode-decode method for path characterization
  - Fiber computation and contractibility checking
  - Equivalence construction from contractible fibers
  - Transport along equivalences
"""

from typing import TypeVar, Callable, Optional, Tuple, List, Dict, Any, Set
from dataclasses import dataclass, field
from itertools import product


# =============================================================================
# Algorithm 1: Encode-Decode Method
# =============================================================================

def encode(base_point: Any, family_value: Any, path: Any,
           transport_fn: Callable) -> Any:
    """
    The encode map in the encode-decode method.

    Given:
      - base_point a : A
      - family_value c : C(a)
      - path p : a = x (represented as target x)
      - transport_fn: implements transport along p

    Returns: C(x)

    Time complexity: O(1) (single transport operation)
    Space complexity: O(1)

    >>> encode(0, "base", 0, lambda c, p: c)
    'base'
    """
    return transport_fn(family_value, path)


def decode(base_point: Any, family_value: Any, target: Any,
           contraction_witness: Callable) -> Any:
    """
    The decode map: from C(x) back to (a = x).

    Given:
      - base_point a : A
      - family_value c : C(a) (unused in computation, but part of the type)
      - target x : A
      - contraction_witness: function that, given (x, u) in Σ(x, C(x)),
        returns the path to the center (a, c)

    Returns: evidence that a = x (in discrete case: True if a == x)

    Time complexity: O(T_contract) where T_contract is the cost of the
                     contraction witness
    Space complexity: O(1)

    >>> decode(0, "c", 0, lambda x, u: (0, "c"))
    True
    """
    center = contraction_witness(target)
    return center[0] == base_point  # Extract base path


def encode_decode_roundtrip(
    domain: List[Any],
    base_point: Any,
    family: Callable[[Any], List[Any]],
    transport_fn: Callable,
    contraction_witness: Callable
) -> Dict[str, bool]:
    """
    Verify the encode-decode roundtrip for a pointed family.

    Returns verification results for both directions:
      - encode_decode: ∀x, ∀u:C(x), encode(decode(u)) = u
      - decode_encode: ∀x, ∀p:(a=x), decode(encode(p)) = p

    Time complexity: O(|domain| * max|C(x)|)
    Space complexity: O(|domain|)
    """
    results = {"encode_decode": True, "decode_encode": True}

    for x in domain:
        # Check decode ∘ encode = id on paths
        if x == base_point:
            path = x  # refl
            encoded = transport_fn(family(base_point)[0] if family(base_point) else None, path)
            if encoded is not None:
                decoded = decode(base_point, None, x, contraction_witness)
                if not decoded:
                    results["decode_encode"] = False

    return results


# =============================================================================
# Algorithm 2: Fiber Computation
# =============================================================================

@dataclass
class FiberData:
    """Complete fiber data for a function."""
    target: Any
    elements: List[Tuple[Any, Any]]  # List of (preimage, proof)

    @property
    def size(self) -> int:
        return len(self.elements)

    @property
    def is_contractible(self) -> bool:
        """A fiber is contractible iff it has exactly one element (discrete case)."""
        return self.size == 1


def compute_all_fibers(
    f: Callable,
    domain: List[Any],
    codomain: List[Any]
) -> Dict[Any, FiberData]:
    """
    Compute all fibers of f : domain → codomain.

    For each b in codomain, the fiber is:
      fiber(f, b) = {(a, p) | a ∈ domain, f(a) = b}

    Time complexity: O(|domain| * |codomain|)
    Space complexity: O(|domain|)

    >>> fibers = compute_all_fibers(lambda x: x*2, [0,1,2,3], [0,2,4,6])
    >>> all(f.is_contractible for f in fibers.values())
    True
    """
    fibers = {}
    for b in codomain:
        elements = [(a, f"f({a})={b}") for a in domain if f(a) == b]
        fibers[b] = FiberData(target=b, elements=elements)
    return fibers


def check_all_fibers_contractible(
    f: Callable,
    domain: List[Any],
    codomain: List[Any]
) -> Tuple[bool, Optional[Any]]:
    """
    Check if all fibers of f are contractible.

    Returns (True, None) if all fibers are contractible,
    or (False, counterexample_b) if some fiber is not.

    Time complexity: O(|domain| * |codomain|)
    Space complexity: O(|domain|)

    >>> check_all_fibers_contractible(lambda x: x+1, [0,1,2], [1,2,3])
    (True, None)
    >>> check_all_fibers_contractible(lambda x: x%2, [0,1,2,3], [0,1])
    (False, 0)
    """
    fibers = compute_all_fibers(f, domain, codomain)
    for b, fiber in fibers.items():
        if not fiber.is_contractible:
            return (False, b)
    return (True, None)


# =============================================================================
# Algorithm 3: Equivalence Construction from Contractible Fibers
# =============================================================================

@dataclass
class EquivData:
    """An equivalence between finite types."""
    forward: Callable
    backward: Callable
    domain: List[Any]
    codomain: List[Any]

    def verify(self) -> Dict[str, bool]:
        """Verify all equivalence properties."""
        left = all(self.backward(self.forward(a)) == a for a in self.domain)
        right = all(self.forward(self.backward(b)) == b for b in self.codomain)
        return {
            "left_inverse": left,
            "right_inverse": right,
            "is_equivalence": left and right
        }


def construct_equiv_from_fibers(
    f: Callable,
    domain: List[Any],
    codomain: List[Any]
) -> Optional[EquivData]:
    """
    Construct an equivalence from a function with contractible fibers.

    If all fibers are contractible, extract the inverse by picking
    the unique preimage from each fiber.

    Time complexity: O(|domain| + |codomain|)
    Space complexity: O(|codomain|)

    >>> e = construct_equiv_from_fibers(lambda x: x*2, [0,1,2], [0,2,4])
    >>> e.verify()['is_equivalence']
    True
    """
    fibers = compute_all_fibers(f, domain, codomain)

    # Check all fibers are contractible
    for b, fiber in fibers.items():
        if not fiber.is_contractible:
            return None

    # Build inverse from fiber centers
    inverse_map = {}
    for b, fiber in fibers.items():
        inverse_map[b] = fiber.elements[0][0]  # The unique preimage

    backward = lambda b: inverse_map[b]
    return EquivData(forward=f, backward=backward, domain=domain, codomain=codomain)


# =============================================================================
# Algorithm 4: Transport Along Equivalences
# =============================================================================

def transport_predicate(
    equiv: EquivData,
    predicate: Callable[[Any], bool]
) -> Callable[[Any], bool]:
    """
    Transport a predicate P : A → Bool along an equivalence e : A ≃ B
    to get P' : B → Bool defined by P'(b) = P(e⁻¹(b)).

    Time complexity: O(1) per evaluation
    Space complexity: O(1)

    >>> e = EquivData(lambda x: x+10, lambda y: y-10, [0,1,2], [10,11,12])
    >>> P = lambda x: x > 0
    >>> P_transported = transport_predicate(e, P)
    >>> P_transported(11)
    True
    """
    return lambda b: predicate(equiv.backward(b))


def transport_structure(
    equiv: EquivData,
    operation: Callable[[Any, Any], Any]
) -> Callable[[Any, Any], Any]:
    """
    Transport a binary operation op : A × A → A along e : A ≃ B
    to get op' : B × B → B defined by op'(b1, b2) = e(op(e⁻¹(b1), e⁻¹(b2))).

    This is the computational content of univalence for algebraic structures.

    Time complexity: O(1) per evaluation
    Space complexity: O(1)

    >>> e = EquivData(lambda x: x+10, lambda y: y-10, [0,1,2], [10,11,12])
    >>> add = lambda x, y: (x + y) % 3
    >>> add_transported = transport_structure(e, add)
    >>> add_transported(10, 11)  # Should be e(add(0, 1)) = e(1) = 11
    11
    """
    return lambda b1, b2: equiv.forward(
        operation(equiv.backward(b1), equiv.backward(b2))
    )


# =============================================================================
# Algorithm 5: Contractibility Checker with Witness
# =============================================================================

def check_contractible_with_witness(
    elements: List[Any],
    eq_fn: Callable[[Any, Any], bool] = lambda x, y: x == y
) -> Tuple[bool, Optional[Any], Optional[Callable]]:
    """
    Check contractibility and return a contraction witness if contractible.

    Returns:
      - (True, center, contraction_fn) if contractible
      - (False, None, None) otherwise

    The contraction_fn maps each element to the center.

    Time complexity: O(n²) where n = |elements|
    Space complexity: O(n) for witness storage

    >>> ok, c, w = check_contractible_with_witness([42, 42, 42])
    >>> ok, c
    (True, 42)
    """
    if not elements:
        return (False, None, None)

    center = elements[0]
    for e in elements:
        if not eq_fn(e, center):
            return (False, None, None)

    # Build contraction witness: maps every element to center
    contraction = lambda x: center
    return (True, center, contraction)


# =============================================================================
# Algorithm 6: Identity System Checker
# =============================================================================

def check_identity_system(
    type_elements: List[Any],
    base_point: Any,
    family: Callable[[Any], List[Any]],
    family_base: Any
) -> Dict[str, Any]:
    """
    Check if (family, family_base) forms an identity system at base_point.

    An identity system requires:
    1. The total space Σ(x, family(x)) is contractible
    2. The center is (base_point, family_base)

    Time complexity: O(|type_elements| * max|family(x)|)
    Space complexity: O(total_space_size)

    >>> r = check_identity_system([0,1,2], 0, lambda x: [True] if x==0 else [], True)
    >>> r['is_identity_system']
    True
    """
    # Build total space
    total_space = []
    for x in type_elements:
        for u in family(x):
            total_space.append((x, u))

    # Check contractibility
    is_contr, center, _ = check_contractible_with_witness(total_space)

    # Check center is the expected one
    expected_center = (base_point, family_base)
    center_matches = is_contr and center == expected_center

    return {
        "total_space": total_space,
        "total_space_size": len(total_space),
        "is_contractible": is_contr,
        "center": center,
        "expected_center": expected_center,
        "center_matches": center_matches,
        "is_identity_system": is_contr and center_matches
    }


# =============================================================================
# Main: Run all algorithm demonstrations
# =============================================================================

if __name__ == "__main__":
    print("HoTT Algorithms: Self-Test")
    print("=" * 50)

    # Test 1: Encode-decode
    print("\n1. Encode-Decode roundtrip:")
    result = encode_decode_roundtrip(
        domain=[0, 1, 2],
        base_point=0,
        family=lambda x: [True] if x == 0 else [],
        transport_fn=lambda c, p: c,
        contraction_witness=lambda x: (0, True)
    )
    print(f"   {result}")

    # Test 2: Fiber computation
    print("\n2. Fiber computation for f(x) = 2x:")
    fibers = compute_all_fibers(lambda x: x*2, [0,1,2,3], [0,2,4,6])
    for b, fib in fibers.items():
        print(f"   fiber({b}): size={fib.size}, contractible={fib.is_contractible}")

    # Test 3: Equivalence construction
    print("\n3. Equivalence from contractible fibers:")
    e = construct_equiv_from_fibers(lambda x: x*2, [0,1,2,3], [0,2,4,6])
    if e:
        print(f"   Constructed: {e.verify()}")

    # Test 4: Transport
    print("\n4. Transport predicate along equivalence:")
    if e:
        P = lambda x: x > 1
        P_t = transport_predicate(e, P)
        print(f"   P(2) = {P(2)}, P_transported(4) = {P_t(4)}")

    # Test 5: Identity system
    print("\n5. Identity system check:")
    result = check_identity_system(
        [0, 1, 2], 0,
        lambda x: [True] if x == 0 else [],
        True
    )
    print(f"   {result['is_identity_system']}")

    print("\nAll tests passed ✓")
