"""
demo.py — Numerical demonstrations for
"Frankl's Union-Closed Conjecture: Partial Results"

This script is fully self-contained (standard library only) and illustrates the
mathematical content of the formalized results:

  1. IsUnionClosed / FranklProperty    -- the basic definitions.
  2. frankl_singleton                  -- a family containing a singleton {a}
                                          always makes 'a' abundant, witnessed by
                                          the injection  A |-> A u {a}.
  3. sup_id_isGreatest / sup_mem       -- a nonempty union-closed family contains
                                          its own union (its greatest element).
  4. frankl_fin_three                  -- Frankl's conjecture holds for every
                                          union-closed family on a 3-element
                                          universe (verified by exhaustive search,
                                          mirroring frankl_fin3_no_singleton).
  5. reimer_tight_cube                 -- 2 * sum_{A in P(n)} |A| = n * 2^n, the
                                          equality case of Reimer's average-size
                                          bound, attained by the Boolean cube.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import FrozenSet, Iterable, List, Optional, Set, Tuple


# ----------------------------------------------------------------------------
# Basic combinatorial machinery
# ----------------------------------------------------------------------------

Family = Set[FrozenSet[int]]


def powerset(ground: Iterable[int]) -> List[FrozenSet[int]]:
    """All subsets of a finite ground set, as frozensets."""
    elems = list(ground)
    return [
        frozenset(c)
        for r in range(len(elems) + 1)
        for c in combinations(elems, r)
    ]


def is_union_closed(family: Family) -> bool:
    """A family is union-closed iff A u B in family for all A, B in family."""
    return all((a | b) in family for a in family for b in family)


def is_abundant(family: Family, x: int) -> bool:
    """x is abundant iff it lies in at least half of the members of family."""
    in_count = sum(1 for a in family if x in a)
    return 2 * in_count >= len(family)


def frankl_property(family: Family) -> Optional[int]:
    """Return an abundant element belonging to some member, or None if none.

    Frankl's conjecture asserts this is never None for a union-closed family
    with a nonempty member.
    """
    elements = set(chain.from_iterable(family))
    for x in sorted(elements):
        if is_abundant(family, x):
            return x
    return None


# ----------------------------------------------------------------------------
# 1-2.  The singleton injection  (frankl_singleton)
# ----------------------------------------------------------------------------

def singleton_injection_witness(family: Family, a: int) -> List[Tuple[FrozenSet[int], FrozenSet[int]]]:
    """For a union-closed family containing {a}, exhibit the injection
       phi : {A in F : a not in A}  ->  {A in F : a in A},   phi(A) = A u {a}.

    Returns the list of (A, A u {a}) pairs.  This injection proves
    |{A : a not in A}| <= |{A : a in A}|, hence 'a' is abundant.
    """
    assert frozenset({a}) in family, "family must contain the singleton {a}"
    avoid = [A for A in family if a not in A]
    pairs = [(A, A | {a}) for A in avoid]
    images = [img for _, img in pairs]
    assert len(set(images)) == len(images), "phi must be injective"
    assert all(img in family for img in images), "phi must land inside F"
    return pairs


# ----------------------------------------------------------------------------
# 3.  Greatest element  (sup_id_isGreatest, sup_mem)
# ----------------------------------------------------------------------------

def greatest_element(family: Family) -> FrozenSet[int]:
    """The union of all members; for a union-closed family it lies in the family
       and contains every member (its top / greatest element)."""
    top: FrozenSet[int] = frozenset()
    for A in family:
        top = top | A
    return top


# ----------------------------------------------------------------------------
# 4.  Exhaustive verification of Frankl for a 3-element universe
#     (mirrors frankl_fin_three / frankl_fin3_no_singleton)
# ----------------------------------------------------------------------------

def verify_frankl_fin_n(n: int) -> Tuple[int, int]:
    """Exhaustively check Frankl's conjecture for every union-closed family on
       the universe {0, ..., n-1} that contains a nonempty set.

    Returns (number_of_families_checked, number_of_counterexamples).
    For n = 3 the second component must be 0 (this is frankl_fin_three).
    """
    ground = range(n)
    all_sets = powerset(ground)
    index = {A: i for i, A in enumerate(all_sets)}
    checked = 0
    counterexamples = 0
    # Enumerate every subfamily of P({0,...,n-1}) by a bitmask.
    for mask in range(1 << len(all_sets)):
        family: Family = {all_sets[i] for i in range(len(all_sets)) if mask & (1 << i)}
        if not family:
            continue
        if not any(len(A) > 0 for A in family):
            continue
        if not is_union_closed(family):
            continue
        checked += 1
        if frankl_property(family) is None:
            counterexamples += 1
    return checked, counterexamples


# ----------------------------------------------------------------------------
# 5.  Reimer tightness on the Boolean cube  (reimer_tight_cube)
# ----------------------------------------------------------------------------

def reimer_cube_identity(n: int) -> Tuple[int, int, int, int]:
    """Compute, for the full power set of an n-element set:

         total_size = sum_{A subset} |A|
         num_sets   = 2^n
         lhs        = 2 * total_size
         rhs        = n * num_sets

    The theorem reimer_tight_cube asserts lhs == rhs (= n * 2^n).
    Equivalently the average member size is exactly n/2 = (1/2) log2(2^n).
    """
    sets = powerset(range(n))
    total_size = sum(len(A) for A in sets)
    num_sets = len(sets)
    return 2 * total_size, n * num_sets, total_size, num_sets


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Frankl's Union-Closed Conjecture: Partial Results — numerical demo")
    print("=" * 70)

    # --- Singleton injection -------------------------------------------------
    print("\n[1] Singleton injection (frankl_singleton)")
    F: Family = {frozenset(), frozenset({1}), frozenset({1, 2}), frozenset({2})}
    # Make it union-closed by adding any missing unions:
    F = set(F)
    changed = True
    while changed:
        changed = False
        for a in list(F):
            for b in list(F):
                if (a | b) not in F:
                    F.add(a | b)
                    changed = True
    print(f"    Union-closed family F = {{ {', '.join(sorted(str(set(s)) for s in F))} }}")
    print(f"    Contains singleton {{1}}: {frozenset({1}) in F}")
    pairs = singleton_injection_witness(F, 1)
    print(f"    Injection A |-> A u {{1}} on the {len(pairs)} sets avoiding 1:")
    for A, img in pairs:
        label = str(set(A)) if A else "{}"
        print(f"        {label:<12} ->  {set(img)}")
    print(f"    => 1 is abundant: {is_abundant(F, 1)}")

    # --- Greatest element ----------------------------------------------------
    print("\n[2] Greatest element (sup_id_isGreatest)")
    top = greatest_element(F)
    print(f"    Union of all members = {set(top)}")
    print(f"    It belongs to F:        {top in F}")
    print(f"    It contains every A:    {all(A <= top for A in F)}")

    # --- Frankl for small universes -----------------------------------------
    print("\n[3] Exhaustive verification (frankl_fin_three and neighbours)")
    for n in range(0, 4):
        checked, cex = verify_frankl_fin_n(n)
        status = "OK" if cex == 0 else f"!! {cex} COUNTEREXAMPLES"
        print(f"    Fin {n}: {checked:>6} union-closed families checked, "
              f"counterexamples = {cex}  [{status}]")

    # --- Reimer tightness ----------------------------------------------------
    print("\n[4] Reimer tightness on the Boolean cube (reimer_tight_cube)")
    print("    n |   2*sum|A|  |   n*2^n   |  avg size  |  n/2")
    print("   ---+-------------+-----------+------------+------")
    for n in range(0, 8):
        lhs, rhs, total, num = reimer_cube_identity(n)
        avg = total / num
        print(f"    {n} | {lhs:>10}  | {rhs:>8}  |  {avg:>8.3f}  | {n/2:>4.1f}"
              f"   {'==' if lhs == rhs else '!='}")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
