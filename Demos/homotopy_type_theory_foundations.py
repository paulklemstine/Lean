"""
Homotopy Type Theory Foundations -- finite-model demonstrations.

This script exercises the three main results of the development on concrete,
*finite* models, where the type-theoretic notions become decidable computations:

  * Theorem (singleton_isContr / fundamental_identity): a pointed family B over
    (A, a) has B's transport map `encode_x : (a = x) -> B(x)` a fiberwise
    equivalence  <=>  the total space  Sum_x B(x)  is contractible.
  * Theorem (Trunc.prod_equiv): propositional truncation commutes with products,
    i.e. ||A x B||  is inhabited  <=>  ||A|| and ||B|| are both inhabited.
  * Theorem (UnivalenceData.not_inhabited / propUnivalence): in a
    proof-irrelevant setting univalence fails exactly when a type has more than
    one self-equivalence; Bool (|Aut| = 2) is the minimal obstruction, while
    propositions (|Aut| <= 1) are safe.

Everything is self-contained: no third-party imports.

In these finite models we adopt the *proof-irrelevant* convention of the Lean
development: the identity type `a == b` is a mere proposition, so it has exactly
one element when a == b and none otherwise.  A "family" B assigns to each base
point x a finite set B(x) (here, a set of integer labels).
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Callable, Dict, Hashable, List, Sequence, Set, Tuple

# A base point is any hashable value; a family assigns a finite fiber-set to it.
Point = Hashable
Family = Dict[Point, Set[int]]


# --------------------------------------------------------------------------- #
# Identity-type / contractibility primitives (proof-irrelevant finite model)   #
# --------------------------------------------------------------------------- #

def id_type_card(a: Point, x: Point) -> int:
    """|a == x| in a proof-irrelevant identity type: 1 if equal else 0."""
    return 1 if a == x else 0


def is_contractible(elements: Sequence[Hashable]) -> bool:
    """A finite type is contractible iff it has exactly one element."""
    return len(set(elements)) == 1


def total_space(B: Family) -> List[Tuple[Point, int]]:
    """Enumerate the dependent total space  Sum_x B(x)  as pairs (x, u)."""
    return [(x, u) for x, fiber in B.items() for u in sorted(fiber)]


def encode_fiber(a: Point, B: Family, b: int, x: Point) -> List[Tuple[int, int]]:
    """
    Fiber of the transport map  encode_x : (a == x) -> B(x), p |-> p_*(b),
    over a target u.  We return, for each u in B(x), the list of (path, u)
    witnesses.  Since identity is proof-irrelevant, there is at most one path
    p : a == x; transport then carries b to (the image of) b in B(x).

    Model of transport: when a == x, p_*(b) = b; the fiber over u is inhabited
    iff u == b.  When a != x there is no path, so every fiber is empty.
    """
    witnesses: List[Tuple[int, int]] = []
    if id_type_card(a, x) == 1:           # exactly one path p : a == x
        for u in sorted(B[x]):
            if u == b:                     # encode_x(p) = b lands in fiber over u
                witnesses.append((0, u))   # 0 = the unique reflexivity path
    return witnesses


def encode_is_fiberwise_equiv(a: Point, B: Family, b: int) -> bool:
    """
    encode_x is an equivalence for every x  <=>  every fiber over every target
    u in B(x) is contractible (exactly one witness).
    """
    for x, fiber in B.items():
        for u in sorted(fiber):
            wit = [w for w in encode_fiber(a, B, b, x) if w[1] == u]
            # the fiber over u must be contractible: exactly one witness
            if len(wit) != 1 or not is_contractible([w[0] for w in wit]):
                return False
    return True


def total_space_is_contractible(B: Family) -> bool:
    """Contractibility of  Sum_x B(x): exactly one element overall."""
    return is_contractible(total_space(B))


# --------------------------------------------------------------------------- #
# Propositional truncation (the (-1)-truncation)                               #
# --------------------------------------------------------------------------- #

def trunc_inhabited(elements: Sequence[Hashable]) -> bool:
    """||A|| is inhabited iff A is inhabited (truncation keeps only that bit)."""
    return len(list(elements)) > 0


def trunc_prod_equiv_holds(A: Sequence[Hashable], B: Sequence[Hashable]) -> bool:
    """
    Theorem Trunc.prod_equiv:  ||A x B|| ~ ||A|| x ||B||.
    On inhabitation: A x B inhabited  <=>  A inhabited and B inhabited.
    """
    lhs = trunc_inhabited(list(product(A, B)))
    rhs = trunc_inhabited(A) and trunc_inhabited(B)
    return lhs == rhs


# --------------------------------------------------------------------------- #
# Univalence obstruction                                                       #
# --------------------------------------------------------------------------- #

def automorphisms(n: int) -> List[Tuple[int, ...]]:
    """All self-equivalences (bijections) of an n-element type."""
    return list(permutations(range(n)))


def univalence_obstructed(n: int) -> bool:
    """
    In a proof-irrelevant setting |A == A| = 1, but |Aut(A)| = n!.
    Univalence (idToEquiv an equivalence) requires these to match; the
    obstruction (UnivalenceData.not_inhabited) is present iff |Aut(A)| > 1.
    """
    return len(automorphisms(n)) > 1


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_fundamental_theorem() -> None:
    print("=" * 70)
    print("Theorem: encode fiberwise-equivalence  <=>  contractible total space")
    print("=" * 70)

    # Base type A = {0, 1, 2}, base point a = 0, base witness b = 10.
    a, b = 0, 10

    # Case 1: the BASED PATH family  B(x) = (a == x)  modeled as {b} only at a.
    # Total space = {(0, 10)} -> contractible; encode should be an equivalence.
    B_path: Family = {0: {10}, 1: set(), 2: set()}
    lhs = encode_is_fiberwise_equiv(a, B_path, b)
    rhs = total_space_is_contractible(B_path)
    print(f"\nBased path family  B(x) = [x == a]:")
    print(f"  total space            = {total_space(B_path)}")
    print(f"  encode equivalence?    = {lhs}")
    print(f"  total contractible?    = {rhs}")
    print(f"  iff holds (== )        = {lhs == rhs}   (expected True/True)")

    # Case 2: a NON-contractible family: extra unreachable witness at x = 1.
    B_big: Family = {0: {10}, 1: {7}, 2: set()}
    lhs2 = encode_is_fiberwise_equiv(a, B_big, b)
    rhs2 = total_space_is_contractible(B_big)
    print(f"\nFamily with an extra fiber  B(1) = {{7}}:")
    print(f"  total space            = {total_space(B_big)}")
    print(f"  encode equivalence?    = {lhs2}")
    print(f"  total contractible?    = {rhs2}")
    print(f"  iff holds (== )        = {lhs2 == rhs2}   (both False -> iff True)")

    # Case 3: family where a has two witnesses -> non-contractible fiber at a.
    B_fat: Family = {0: {10, 11}, 1: set(), 2: set()}
    lhs3 = encode_is_fiberwise_equiv(a, B_fat, b)
    rhs3 = total_space_is_contractible(B_fat)
    print(f"\nFamily with a doubled base fiber  B(0) = {{10, 11}}:")
    print(f"  total space            = {total_space(B_fat)}")
    print(f"  encode equivalence?    = {lhs3}")
    print(f"  total contractible?    = {rhs3}")
    print(f"  iff holds (== )        = {lhs3 == rhs3}")


def demo_truncation_products() -> None:
    print("\n" + "=" * 70)
    print("Theorem Trunc.prod_equiv:  ||A x B|| ~ ||A|| x ||B||")
    print("=" * 70)
    examples: List[Tuple[List[int], List[int]]] = [
        ([1, 2, 3], ["x", "y"]),   # both inhabited
        ([], ["x", "y"]),          # A empty
        ([1, 2], []),              # B empty
        ([], []),                  # both empty
    ]
    for A, B in examples:
        holds = trunc_prod_equiv_holds(A, B)
        lhs = trunc_inhabited(list(product(A, B)))
        rhs = trunc_inhabited(A) and trunc_inhabited(B)
        print(f"  |A|={len(A)}, |B|={len(B)} : ||AxB||={lhs}, ||A||x||B||={rhs}"
              f"  -> equivalence holds: {holds}")


def demo_univalence_obstruction() -> None:
    print("\n" + "=" * 70)
    print("Theorem: univalence fails iff |Aut(A)| > 1; Bool is the minimal case")
    print("=" * 70)
    for n, name in [(1, "Unit / a proposition"), (2, "Bool"), (3, "Fin 3")]:
        auts = automorphisms(n)
        obstructed = univalence_obstructed(n)
        print(f"  type with {n} element(s) [{name:20s}]: "
              f"|Aut| = {len(auts):2d}, |A==A| = 1, "
              f"univalence obstructed: {obstructed}")
    print("\n  Minimal obstruction is Bool: the two self-equivalences are")
    print("    id  = (0, 1)   and   not = (1, 0)   -- negEquiv != Equiv.refl.")
    print("  Propositions (|Aut| <= 1) are exactly where univalence survives.")


def main() -> None:
    demo_fundamental_theorem()
    demo_truncation_products()
    demo_univalence_obstruction()
    print("\nAll finite-model checks completed.")


if __name__ == "__main__":
    main()
