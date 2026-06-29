"""Numerical demonstrations of the Equivalence Calculus.

This script makes the abstract theorems concrete on finite types, where a
"homotopy fibre" of ``f`` over ``b`` is simply the preimage ``f^{-1}(b)`` and
"contractible" means "has exactly one element."  We demonstrate, with explicit
finite examples:

  * Theorem 4.2 (Representation dictionary):
        f is a bijection  <=>  every fibre is a singleton (contractible).
  * Theorem 4.6 (Two-out-of-three law), all three legs.
  * Theorem 4.9 (Univalence-lite): transport of commutativity / associativity
        of a binary operation across an operation-preserving bijection.
  * Theorems 3.7 / 3.8 (Contractibility as a universal property):
        all maps from any X into a one-point (contractible) Y coincide.

The code is self-contained: only the Python standard library is used, and
every helper is inlined.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
C = TypeVar("C", bound=Hashable)


# ---------------------------------------------------------------------------
# Fibres and the fibrewise characterisation of equivalences (Theorems 3.6, 4.2)
# ---------------------------------------------------------------------------
def fibres(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> Dict[B, List[A]]:
    """Return the homotopy fibre f^{-1}(b) for every b in the codomain."""
    table: Dict[B, List[A]] = {b: [] for b in codomain}
    for a in domain:
        table[f(a)].append(a)
    return table


def is_contractible_fibrewise(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """f is an equivalence  <=>  every fibre is a singleton (contractible)."""
    return all(len(fib) == 1 for fib in fibres(f, domain, codomain).values())


def is_bijective(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """Direct check: injective and surjective."""
    images = [f(a) for a in domain]
    injective = len(set(images)) == len(images)
    surjective = set(images) == set(codomain)
    return injective and surjective


def representation_dictionary_demo() -> None:
    print("=" * 70)
    print("Theorem 4.2 - Representation dictionary: bijective <=> contractible fibres")
    print("=" * 70)
    dom = [0, 1, 2]
    cod = ["x", "y", "z"]

    good: Callable[[int], str] = lambda a: {0: "x", 1: "y", 2: "z"}[a]
    bad: Callable[[int], str] = lambda a: {0: "x", 1: "x", 2: "z"}[a]  # 1,0 collide

    for name, f in (("bijection ", good), ("collision ", bad)):
        fib = fibres(f, dom, cod)
        contr = is_contractible_fibrewise(f, dom, cod)
        bij = is_bijective(f, dom, cod)
        print(f"\n  map [{name}]  fibres = {fib}")
        print(f"     all fibres contractible (singletons)? {contr}")
        print(f"     bijective (direct check)?            {bij}")
        assert contr == bij, "dictionary must agree on both sides"
    print("\n  --> The two notions coincide on every example.\n")


# ---------------------------------------------------------------------------
# The two-out-of-three law (Theorem 4.6)
# ---------------------------------------------------------------------------
def compose(g: Callable[[B], C], f: Callable[[A], B]) -> Callable[[A], C]:
    return lambda a: g(f(a))


def two_out_of_three_demo() -> None:
    print("=" * 70)
    print("Theorem 4.6 - Two-out-of-three law (all three legs)")
    print("=" * 70)
    A_set = [0, 1, 2]
    B_set = ["p", "q", "r"]
    C_set = ["P", "Q", "R"]

    f: Callable[[int], str] = lambda a: {0: "p", 1: "q", 2: "r"}[a]
    g: Callable[[str], str] = lambda b: {"p": "P", "q": "Q", "r": "R"}[b]
    gf = compose(g, f)

    bf = is_bijective(f, A_set, B_set)
    bg = is_bijective(g, B_set, C_set)
    bgf = is_bijective(gf, A_set, C_set)

    print(f"\n  f bijective?      {bf}")
    print(f"  g bijective?      {bg}")
    print(f"  g.f bijective?    {bgf}")
    print("\n  Leg 1 (f,g => g.f):   ", bf and bg, "implies", bgf)
    print("  Leg 2 (g,g.f => f):   ", bg and bgf, "implies", bf)
    print("  Leg 3 (f,g.f => g):   ", bf and bgf, "implies", bg)
    assert (bf and bg) <= bgf
    assert (bg and bgf) <= bf
    assert (bf and bgf) <= bg
    print("\n  --> Any two of {f, g, g.f} being equivalences forces the third.\n")


# ---------------------------------------------------------------------------
# Univalence-lite: transport of structure along an equivalence (Theorem 4.9)
# ---------------------------------------------------------------------------
def transport_operation(
    op_M: Callable[[A, A], A],
    phi: Callable[[A], B],
    psi: Callable[[B], A],
) -> Callable[[B, B], B]:
    """Induced operation on N: x *_N y := phi( psi(x) *_M psi(y) )."""
    return lambda x, y: phi(op_M(psi(x), psi(y)))


def is_commutative(op: Callable[[A, A], A], carrier: Sequence[A]) -> bool:
    return all(op(a, b) == op(b, a) for a in carrier for b in carrier)


def is_associative(op: Callable[[A, A], A], carrier: Sequence[A]) -> bool:
    return all(
        op(op(a, b), c) == op(a, op(b, c))
        for a, b, c in product(carrier, repeat=3)
    )


def univalence_lite_demo() -> None:
    print("=" * 70)
    print("Theorem 4.9 - Univalence-lite: laws transport across an equivalence")
    print("=" * 70)
    # M = (Z/3, +)  : commutative AND associative.
    M = [0, 1, 2]
    op_M: Callable[[int, int], int] = lambda a, b: (a + b) % 3

    # An equivalence phi : M -> N relabelling 0,1,2 as 'a','b','c'.
    label = {0: "a", 1: "b", 2: "c"}
    unlabel = {v: k for k, v in label.items()}
    phi: Callable[[int], str] = lambda a: label[a]
    psi: Callable[[str], int] = lambda x: unlabel[x]
    N = ["a", "b", "c"]

    op_N = transport_operation(op_M, phi, psi)

    print(f"\n  M = (Z/3, +).  commutative? {is_commutative(op_M, M)}"
          f"   associative? {is_associative(op_M, M)}")
    print("  Transported operation table on N:")
    header = "      *  | " + "  ".join(N)
    print(header)
    print("      " + "-" * (len(header) - 6))
    for x in N:
        row = "  ".join(op_N(x, y) for y in N)
        print(f"      {x}  | {row}")
    print(f"\n  N commutative? {is_commutative(op_N, N)}"
          f"   associative? {is_associative(op_N, N)}")
    assert is_commutative(op_N, N) and is_associative(op_N, N)
    print("\n  --> Both equational laws survived transport across the bijection.\n")


# ---------------------------------------------------------------------------
# Contractibility as a universal property (Theorems 3.7, 3.8)
# ---------------------------------------------------------------------------
def all_maps(
    domain: Sequence[A], codomain: Sequence[B]
) -> List[Tuple[Tuple[A, B], ...]]:
    """Enumerate all functions domain -> codomain as tuples of (input, output)."""
    maps: List[Tuple[Tuple[A, B], ...]] = []
    for outputs in product(codomain, repeat=len(domain)):
        maps.append(tuple(zip(domain, outputs)))
    return maps


def universal_property_demo() -> None:
    print("=" * 70)
    print("Theorems 3.7 / 3.8 - Contractible target is terminal: maps into it coincide")
    print("=" * 70)
    for size in (1, 2, 3):
        X = list(range(size))
        Y_contractible = ["*"]          # one-point space = contractible
        maps = all_maps(X, Y_contractible)
        print(f"  |X| = {size}:  number of maps X -> (one-point Y) = {len(maps)}")
        assert len(maps) == 1
    print("\n  --> From any X there is exactly ONE map into a one-point space:")
    print("      a contractible target is the terminal object of the category.\n")


def main() -> None:
    representation_dictionary_demo()
    two_out_of_three_demo()
    univalence_lite_demo()
    universal_property_demo()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
