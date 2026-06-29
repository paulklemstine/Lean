"""
Numerical demonstrations for:

    "Path Spaces, h-Levels, and Contractibility as a Universal Property"

We model the synthetic homotopy-type-theoretic results on FINITE types, where
contractibility, mere-propositionality, homotopy fibers, equivalences, and
homotopy classes all become decidable. Each demonstration corresponds to a
theorem from the paper:

  * Theorem 3.1  - based path space {b // a = b} is contractible.
  * Theorem 4.1  - Sigma-closure of contractibility.
  * Theorem 4.4  - IsContr A  <->  Nonempty A  /\  IsMereProp A.
  * Theorem 5.1  - bijection  <->  all homotopy fibers contractible.
  * Theorem 5.4  - the 2-out-of-3 law for equivalences.
  * Theorem 5.6  - transport of commutativity/associativity along equivalences.
  * Theorem 6.6  - [X, Y] is contractible (a point) when Y is contractible.

Everything is self-contained: no third-party imports.

In the finite model, a "type" is a Python list of distinct elements, and the
ambient equality is ordinary Python equality. Then:
  * a type is CONTRACTIBLE  iff it has exactly one element;
  * a type is a MERE PROPOSITION iff it has at most one element.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


# ---------------------------------------------------------------------------
# h-levels in the finite model
# ---------------------------------------------------------------------------
def is_contr(carrier: List[A]) -> bool:
    """IsContr: a finite type is contractible iff it is a singleton."""
    return len(carrier) == 1


def is_mere_prop(carrier: List[A]) -> bool:
    """IsMereProp: a finite type is a mere proposition iff |A| <= 1."""
    return len(carrier) <= 1


def is_nonempty(carrier: List[A]) -> bool:
    """Nonempty A."""
    return len(carrier) > 0


# ---------------------------------------------------------------------------
# Theorem 3.1 : based path space is contractible
# ---------------------------------------------------------------------------
def based_path_space(carrier: List[A], a: A) -> List[Tuple[A, str]]:
    """
    The based path space { b // a = b }: pairs (b, proof) of a destination b
    reachable from a. In the discrete model the only reachable destination is
    a itself, with the trivial proof 'rfl'.
    """
    return [(b, "rfl") for b in carrier if a == b]


# ---------------------------------------------------------------------------
# Homotopy fibers and the fibrewise characterisation of equivalences
# ---------------------------------------------------------------------------
def hfiber(f: Callable[[A], B], source: List[A], b: B) -> List[A]:
    """HFiber f b = { a // f a = b }: the preimage of b under f."""
    return [a for a in source if f(a) == b]


def is_bijective(f: Callable[[A], B], source: List[A], target: List[B]) -> bool:
    images = [f(a) for a in source]
    injective = len(set(images)) == len(images)
    surjective = set(images) == set(target)
    return injective and surjective


def all_fibers_contractible(
    f: Callable[[A], B], source: List[A], target: List[B]
) -> bool:
    """Theorem 5.1 (RHS): every homotopy fiber of f is contractible."""
    return all(is_contr(hfiber(f, source, b)) for b in target)


# ---------------------------------------------------------------------------
# Theorem 5.4 : the 2-out-of-3 law
# ---------------------------------------------------------------------------
def compose(g: Callable[[B], A], f: Callable[[A], B]) -> Callable[[A], A]:
    return lambda x: g(f(x))


# ---------------------------------------------------------------------------
# Theorem 5.6 : transport of algebraic structure along an equivalence
# ---------------------------------------------------------------------------
def transport_operation(
    phi: Callable[[A], B],
    phi_inv: Callable[[B], A],
    op_M: Callable[[A, A], A],
    carrier_N: List[B],
) -> Callable[[B, B], B]:
    """
    Push a binary operation on M forward to N along the equivalence phi:
        op_N(x, y) = phi( op_M( phi_inv x, phi_inv y ) ).
    """
    return lambda x, y: phi(op_M(phi_inv(x), phi_inv(y)))


def is_commutative(op: Callable[[A, A], A], carrier: List[A]) -> bool:
    return all(op(x, y) == op(y, x) for x in carrier for y in carrier)


def is_associative(op: Callable[[A, A], A], carrier: List[A]) -> bool:
    return all(
        op(op(x, y), z) == op(x, op(y, z))
        for x, y, z in product(carrier, repeat=3)
    )


# ---------------------------------------------------------------------------
# Theorem 6.6 : homotopy classes into a contractible space
# ---------------------------------------------------------------------------
def homotopy_classes_to_point(source: List[A]) -> List[Dict[A, str]]:
    """
    Model [X, Y] when Y = {*} is a one-point (contractible) space. Every
    continuous map X -> {*} sends everything to *, so there is exactly ONE
    map and hence exactly ONE homotopy class. The returned list therefore has
    length 1, witnessing IsContr([X, Y]).
    """
    star = "*"
    the_only_map = {x: star for x in source}
    return [the_only_map]


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    line = "=" * 70

    print(line)
    print("Theorem 3.1 : the based path space { b // a = b } is contractible")
    print(line)
    carrier = ["a", "b", "c", "d"]
    for a in carrier:
        bps = based_path_space(carrier, a)
        print(f"  base {a!r}: path space = {bps}, contractible = {is_contr(bps)}")
    print()

    print(line)
    print("Theorem 4.4 : IsContr  <->  Nonempty  /\\  IsMereProp")
    print(line)
    for name, c in [("empty", []), ("point", ["*"]), ("pair", ["x", "y"])]:
        lhs = is_contr(c)
        rhs = is_nonempty(c) and is_mere_prop(c)
        print(f"  {name:6s}: IsContr={lhs!s:5}  (Nonempty /\\ MereProp)={rhs!s:5}"
              f"  agree={lhs == rhs}")
    print()

    print(line)
    print("Theorem 4.1 : Sigma-closure of contractibility")
    print(line)
    base = ["*"]                       # contractible base
    fiber = {"*": ["only"]}            # contractible fiber over the point
    sigma = [(a, x) for a in base for x in fiber[a]]
    print(f"  Sigma a, B a = {sigma}, contractible = {is_contr(sigma)}")
    print()

    print(line)
    print("Theorem 5.1 : bijection  <->  all homotopy fibers contractible")
    print(line)
    src, tgt = [0, 1, 2], ["x", "y", "z"]
    bij = {0: "x", 1: "y", 2: "z"}
    non = {0: "x", 1: "x", 2: "y"}     # not injective, not surjective
    for label, table in [("bijection", bij), ("non-bijection", non)]:
        f = lambda a, t=table: t[a]
        fibers = {b: hfiber(f, src, b) for b in tgt}
        print(f"  {label}: fibers = {fibers}")
        print(f"    bijective                 = {is_bijective(f, src, tgt)}")
        print(f"    all fibers contractible   = {all_fibers_contractible(f, src, tgt)}")
        assert is_bijective(f, src, tgt) == all_fibers_contractible(f, src, tgt)
    print()

    print(line)
    print("Theorem 5.4 : the 2-out-of-3 law")
    print(line)
    Z = [0, 1, 2]
    f = lambda x: (x + 1) % 3          # equivalence (cyclic shift)
    g = lambda x: (2 * x) % 3          # equivalence (multiply by 2 mod 3)
    gf = compose(g, f)
    ef = all_fibers_contractible(f, Z, Z)
    eg = all_fibers_contractible(g, Z, Z)
    egf = all_fibers_contractible(gf, Z, Z)
    print(f"  IsEquiv f={ef}, IsEquiv g={eg}, IsEquiv (g.f)={egf}")
    print(f"  composition leg : f & g equiv => g.f equiv : {(ef and eg) <= egf}")
    print(f"  left-cancel leg : g & g.f equiv => f equiv : {(eg and egf) <= ef}")
    print(f"  right-cancel leg: f & g.f equiv => g equiv : {(ef and egf) <= eg}")
    print()

    print(line)
    print("Theorem 5.6 : transport of commutativity & associativity")
    print(line)
    M = [0, 1, 2]                      # (Z/3, +) : commutative AND associative
    op_M = lambda x, y: (x + y) % 3
    N = ["A", "B", "C"]
    phi = lambda x: N[x]               # equivalence M -> N
    phi_inv = lambda s: N.index(s)
    op_N = transport_operation(phi, phi_inv, op_M, N)
    print(f"  M commutative = {is_commutative(op_M, M)}, "
          f"associative = {is_associative(op_M, M)}")
    print(f"  N commutative = {is_commutative(op_N, N)}, "
          f"associative = {is_associative(op_N, N)}  (transported)")
    print()

    print(line)
    print("Theorem 6.6 : [X, *] is contractible (terminal object)")
    print(line)
    for X in (["a"], ["a", "b"], ["a", "b", "c", "d"]):
        classes = homotopy_classes_to_point(X)
        print(f"  |X|={len(X)}: #homotopy classes into a point = {len(classes)}"
              f"  contractible = {is_contr(classes)}")
    print()
    print("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
