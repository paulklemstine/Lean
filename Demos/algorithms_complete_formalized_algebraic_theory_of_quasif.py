#!/usr/bin/env python3
"""
Algorithms for Quasifield Nucleus Defect Theory

Type-hinted implementations of the key algorithms:
1. Nucleus computation (left, middle, right)
2. Defect calculation
3. Spread construction
4. Collineation group order bounds
5. Knuth orbit enumeration
"""

from typing import List, Set, Tuple, Callable, Dict, Optional
from itertools import permutations
import numpy as np


# Type aliases
Element = int  # Elements represented as integers 0..n-1
MulTable = Callable[[Element, Element], Element]
AddTable = Callable[[Element, Element], Element]


def compute_left_nucleus(
    n: int,
    mul: MulTable
) -> Set[Element]:
    """Compute the left nucleus N_ℓ(Q) = {a | ∀b,c: a(bc) = (ab)c}.

    Algorithm: For each candidate a, check associativity with all (b,c) pairs.
    Time complexity: O(n³) where n = |Q|.

    Args:
        n: Order of the quasifield
        mul: Multiplication function

    Returns:
        Set of elements in the left nucleus
    """
    nucleus: Set[Element] = set()
    for a in range(n):
        is_nuclear = True
        for b in range(n):
            if not is_nuclear:
                break
            for c in range(n):
                if mul(a, mul(b, c)) != mul(mul(a, b), c):
                    is_nuclear = False
                    break
        if is_nuclear:
            nucleus.add(a)
    return nucleus


def compute_middle_nucleus(
    n: int,
    mul: MulTable
) -> Set[Element]:
    """Compute the middle nucleus N_m(Q) = {b | ∀a,c: a(bc) = (ab)c}.

    Time complexity: O(n³).
    """
    nucleus: Set[Element] = set()
    for b in range(n):
        is_nuclear = True
        for a in range(n):
            if not is_nuclear:
                break
            for c in range(n):
                if mul(a, mul(b, c)) != mul(mul(a, b), c):
                    is_nuclear = False
                    break
        if is_nuclear:
            nucleus.add(b)
    return nucleus


def compute_right_nucleus(
    n: int,
    mul: MulTable
) -> Set[Element]:
    """Compute the right nucleus N_r(Q) = {c | ∀a,b: a(bc) = (ab)c}.

    Time complexity: O(n³).
    """
    nucleus: Set[Element] = set()
    for c in range(n):
        is_nuclear = True
        for a in range(n):
            if not is_nuclear:
                break
            for b in range(n):
                if mul(a, mul(b, c)) != mul(mul(a, b), c):
                    is_nuclear = False
                    break
        if is_nuclear:
            nucleus.add(c)
    return nucleus


def compute_full_nucleus(
    n: int,
    mul: MulTable
) -> Set[Element]:
    """Compute N(Q) = N_ℓ ∩ N_m ∩ N_r.

    Time complexity: O(n³).
    """
    nl = compute_left_nucleus(n, mul)
    nm = compute_middle_nucleus(n, mul)
    nr = compute_right_nucleus(n, mul)
    return nl & nm & nr


def compute_center(
    n: int,
    mul: MulTable
) -> Set[Element]:
    """Compute Z(Q) = {a ∈ N(Q) | ∀b: ab = ba}.

    Time complexity: O(n³) (dominated by nucleus computation).
    """
    full_nuc = compute_full_nucleus(n, mul)
    center: Set[Element] = set()
    for a in full_nuc:
        commutes = all(mul(a, b) == mul(b, a) for b in range(n))
        if commutes:
            center.add(a)
    return center


def compute_defect(
    n: int,
    mul: MulTable
) -> int:
    """Compute the defect δ(Q) = |Q| - |N_ℓ(Q)|.

    The defect measures distance from being a division ring.
    δ = 0 iff Q is associative (hence a division ring).

    Time complexity: O(n³).
    """
    nl = compute_left_nucleus(n, mul)
    return n - len(nl)


def compute_nucleus_triple(
    n: int,
    mul: MulTable
) -> Tuple[int, int, int]:
    """Compute the nucleus triple (|N_ℓ|, |N_m|, |N_r|).

    This triple is a key invariant of the quasifield.

    Time complexity: O(n³).
    """
    nl = compute_left_nucleus(n, mul)
    nm = compute_middle_nucleus(n, mul)
    nr = compute_right_nucleus(n, mul)
    return (len(nl), len(nm), len(nr))


def compute_associator_count(
    n: int,
    mul: MulTable
) -> int:
    """Count the number of (a,b,c) triples where a(bc) ≠ (ab)c.

    This measures the "total non-associativity" of the quasifield.

    Time complexity: O(n³).
    """
    count = 0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if mul(a, mul(b, c)) != mul(mul(a, b), c):
                    count += 1
    return count


def verify_right_distributivity(
    n: int,
    add: AddTable,
    mul: MulTable
) -> bool:
    """Verify (a+b)c = ac + bc for all a, b, c.

    Time complexity: O(n³).
    """
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if mul(add(a, b), c) != add(mul(a, c), mul(b, c)):
                    return False
    return True


def verify_left_distributivity(
    n: int,
    add: AddTable,
    mul: MulTable
) -> bool:
    """Verify a(b+c) = ab + ac for all a, b, c.

    Time complexity: O(n³).
    """
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if mul(a, add(b, c)) != add(mul(a, b), mul(a, c)):
                    return False
    return True


def pgl_order(q: int) -> int:
    """Order of PGL(3, q) = q³(q³-1)(q²-1).

    This is the collineation group order for the Desarguesian plane of order q.
    """
    return q**3 * (q**3 - 1) * (q**2 - 1)


def hall_collineation_bound(q: int) -> int:
    """Upper bound on collineation group order for Hall plane of order q².

    The Hall plane of order q² has collineation group of order
    at most q²(q²-1)·q·(q-1).
    """
    return q**2 * (q**2 - 1) * q * (q - 1)


def symmetry_loss_ratio(q: int) -> float:
    """Ratio PGL(3,q²)/Hall_collineation(q).

    Measures how much symmetry is lost by breaking Desargues' theorem.
    This ratio grows as q⁴.
    """
    hall = hall_collineation_bound(q)
    if hall == 0:
        return float('inf')
    return pgl_order(q**2) / hall


def spread_parameters(q: int, n: int) -> Dict[str, int]:
    """Compute spread parameters for a quasifield of order q^n.

    Returns:
        Dictionary with:
        - num_components: q^n + 1
        - component_size: q^n (including zero vector)
        - nonzero_per_component: q^n - 1
        - total_nonzero: q^(2n) - 1
    """
    qn = q**n
    return {
        'num_components': qn + 1,
        'component_size': qn,
        'nonzero_per_component': qn - 1,
        'total_nonzero': qn**2 - 1,
        'partition_check': (qn - 1) * (qn + 1) == qn**2 - 1
    }


def knuth_orbit(
    nl: int, nm: int, nr: int
) -> Set[Tuple[int, int, int]]:
    """Compute the Knuth S₃ orbit of a nucleus triple.

    The symmetric group S₃ acts on semifields by permuting the
    roles of the three nuclei. The orbit consists of all distinct
    triples obtainable by permutation.

    Args:
        nl, nm, nr: Left, middle, right nucleus orders

    Returns:
        Set of distinct nucleus triples in the orbit
    """
    triple = (nl, nm, nr)
    orbit: Set[Tuple[int, int, int]] = set()
    for perm in permutations(triple):
        orbit.add(perm)
    return orbit


def knuth_orbit_size(nl: int, nm: int, nr: int) -> int:
    """Compute the Knuth orbit size (divides 6)."""
    return len(knuth_orbit(nl, nm, nr))


def hall_defect(q: int) -> int:
    """Compute the defect for a Hall quasifield of order q².

    The left nucleus of Hall(q²) is GF(q), so defect = q² - q = q(q-1).
    """
    return q * (q - 1)


def classify_by_defect(q: int) -> str:
    """Classify a quasifield by its defect relative to order.

    Returns a human-readable classification.
    """
    defect = hall_defect(q)
    order = q**2
    ratio = defect / order

    if ratio == 0:
        return "Field (Desarguesian)"
    elif ratio < 0.25:
        return "Near-field (mildly non-associative)"
    elif ratio < 0.5:
        return "Moderately non-associative"
    else:
        return "Strongly non-associative"


def test_defect_squared_conjecture(q_max: int = 20) -> List[Tuple[int, bool]]:
    """Test the (falsified) conjecture δ² < q³ for Hall quasifields.

    Returns list of (q, conjecture_holds) pairs.
    """
    results = []
    for q in range(2, q_max + 1):
        defect = hall_defect(q)
        holds = defect**2 < q**3
        results.append((q, holds))
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Spread parameters for q=3, n=2:", spread_parameters(3, 2))
    print("Knuth orbit of (2,4,8):", knuth_orbit(2, 4, 8))
    print("Knuth orbit size of (3,3,3):", knuth_orbit_size(3, 3, 3))
    print("Hall defect for q=3:", hall_defect(3))
    print("Symmetry loss ratio for q=3:", symmetry_loss_ratio(3))

    print("\nDefect-squared conjecture test:")
    for q, holds in test_defect_squared_conjecture(10):
        print(f"  q={q}: {'holds' if holds else 'FAILS'}")
