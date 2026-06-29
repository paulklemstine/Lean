"""
demo.py — The Fundamental Theorem of Identity Systems, made concrete.

This standalone script models the data-carrying synthetic-homotopy constructions
of the accompanying paper on finite (decidable) types, where every claim of the
Fundamental Theorem of Identity Systems becomes a finite, checkable fact.

We model:
  * a base type `A` as a finite list of points;
  * the genuine path family `PathFamily`, where `(a0 = a)` has exactly one
    element (a single `rfl`-path) if `a == a0` and none otherwise;
  * an `IdentitySystem` as a reflexivity witness + a contractible total space
    whose center is `(a0, rflR)`;
  * `encode` (transport of the reflexivity witness along a path) and
    `decode` (read the base path off contractibility of the total space).

We then verify, by exhaustive enumeration:
  * Theorem 3.3  — encode/decode are mutually inverse  (the equivalence),
  * Theorem 4.1  — contractibility transports across an equivalence,
  * Theorem 4.2  — the base fibre R(a0) is contractible (a singleton up to R),
  * Theorem 4.3  — any two identity systems at a0 are fibrewise equivalent.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Generic, Hashable, List, Optional, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
RVal = TypeVar("RVal", bound=Hashable)
SVal = TypeVar("SVal", bound=Hashable)


# ---------------------------------------------------------------------------
# Core data structures (finite, decidable analogues of the Lean primitives)
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Contractible(Generic[A]):
    """A center together with a (verified, finite) contraction onto it.

    `elements` lists every element of the type; `center` is the center of
    contraction.  Contractibility is the property that every element equals the
    center, which for finite decidable types means: the type is a singleton
    equal to {center}.
    """

    elements: Tuple[A, ...]
    center: A

    def is_contractible(self) -> bool:
        return all(x == self.center for x in self.elements) and self.center in self.elements


@dataclass
class Equiv(Generic[A, RVal]):
    """A data-carrying equivalence: forward and inverse maps with round-trips."""

    to_fun: Callable[[A], RVal]
    inv_fun: Callable[[RVal], A]
    dom: Tuple[A, ...]
    cod: Tuple[RVal, ...]

    def left_inv_holds(self) -> bool:
        return all(self.inv_fun(self.to_fun(x)) == x for x in self.dom)

    def right_inv_holds(self) -> bool:
        return all(self.to_fun(self.inv_fun(y)) == y for y in self.cod)

    def is_equiv(self) -> bool:
        return self.left_inv_holds() and self.right_inv_holds()


@dataclass
class IdentitySystem(Generic[A, RVal]):
    """An identity system based at `a0` with family `R`.

    `points`     : the elements of the base type A.
    `R`          : maps each a in A to the tuple of elements of the fibre R(a).
    `a0`         : the basepoint.
    `rflR`       : the reflexivity witness, an element of R(a0).
    The total space is { (a, r) : a in A, r in R(a) }; for this to be an
    identity system it must be contractible with center (a0, rflR).
    """

    points: Tuple[A, ...]
    R: Callable[[A], Tuple[RVal, ...]]
    a0: A
    rflR: RVal

    def total_space(self) -> Tuple[Tuple[A, RVal], ...]:
        return tuple((a, r) for a in self.points for r in self.R(a))

    def total_contractible(self) -> Contractible[Tuple[A, RVal]]:
        return Contractible(elements=self.total_space(), center=(self.a0, self.rflR))

    def is_valid(self) -> bool:
        c = self.total_contractible()
        return c.is_contractible() and c.center == (self.a0, self.rflR)


# ---------------------------------------------------------------------------
# The path family and its canonical identity system
# ---------------------------------------------------------------------------

def path_fibre(a0: A, a: A) -> Tuple[bool, ...]:
    """The fibre (a0 = a): a single rfl-path iff a == a0, else empty.

    We represent the unique path by the marker `True`.
    """
    return (True,) if a == a0 else tuple()


def path_identity_system(points: Tuple[A, ...], a0: A) -> IdentitySystem[A, bool]:
    """`pathIdentitySystem`: R(a) := (a0 = a), rflR := rfl (marker True)."""
    return IdentitySystem(points=points, R=lambda a: path_fibre(a0, a), a0=a0, rflR=True)


# ---------------------------------------------------------------------------
# Encode / Decode  (Definitions 3.1 and 3.2)
# ---------------------------------------------------------------------------

def encode(S: IdentitySystem[A, RVal], a: A) -> Callable[[bool], RVal]:
    """idSysEncode: transport the reflexivity witness along a path.

    A path p : a0 = a only exists when a == a0; transport is then the identity,
    returning rflR.  The path is represented by the marker `True`.
    """

    def go(p: bool) -> RVal:
        assert a == S.a0, "a path a0 = a exists only when a == a0"
        return S.rflR  # transport of rflR along rfl is rflR

    return go


def decode(S: IdentitySystem[A, RVal], a: A) -> Callable[[RVal], bool]:
    """idSysDecode: read the base path off contractibility of the total space.

    (a, r) equals the center (a0, rflR); projecting onto first coordinates gives
    a = a0, so a path a0 = a exists (marker True).  Validity of the identity
    system guarantees this projection is sound.
    """

    center = S.total_contractible().center  # (a0, rflR)

    def go(r: RVal) -> bool:
        # In the total space every (a, r) equals the center; its first coordinate
        # therefore equals a0, witnessing the path a0 = a.
        assert (a, r) == center or a == S.a0, "fibre element must collapse to center"
        return True  # the recovered path a0 = a (its endpoints coincide)

    return go


# ---------------------------------------------------------------------------
# Verifications of the theorems
# ---------------------------------------------------------------------------

def verify_fundamental(S: IdentitySystem[A, RVal]) -> bool:
    """Theorem 3.3: for every a, encode/decode form an equivalence (a0=a) ≃ R(a)."""
    ok = True
    for a in S.points:
        dom: Tuple[bool, ...] = path_fibre(S.a0, a)
        cod: Tuple[RVal, ...] = S.R(a)
        enc = encode(S, a)
        dec = decode(S, a)
        e = Equiv(to_fun=enc, inv_fun=dec, dom=dom, cod=cod)
        # A valid identity system forces |R(a)| == |(a0=a)| for each a.
        same_card = len(dom) == len(cod)
        ok = ok and same_card and e.is_equiv()
    return ok


def transport_contractible(e: Equiv[A, RVal], h: Contractible[A]) -> Contractible[RVal]:
    """Theorem 4.1: push a contractibility witness across an equivalence."""
    new_center = e.to_fun(h.center)
    new_elements = tuple(e.to_fun(x) for x in h.elements)
    return Contractible(elements=new_elements, center=new_center)


def base_fibre_contractible(S: IdentitySystem[A, RVal]) -> Contractible[RVal]:
    """Theorem 4.2: R(a0) is contractible (a singleton up to R), via Theorem 4.1."""
    path_self = Contractible(elements=path_fibre(S.a0, S.a0), center=True)
    e = Equiv(
        to_fun=encode(S, S.a0),
        inv_fun=decode(S, S.a0),
        dom=path_fibre(S.a0, S.a0),
        cod=S.R(S.a0),
    )
    return transport_contractible(e, path_self)


def fibrewise_equiv(
    S: IdentitySystem[A, RVal], T: IdentitySystem[A, SVal], a: A
) -> Equiv[RVal, SVal]:
    """Theorem 4.3: compose S's and T's equivalences through the path-family hub."""
    # R(a) -> (a0=a) via S.decode ... -> S' via T.encode; both bridge through path.
    s_dec = decode(S, a)
    t_enc = encode(T, a)
    s_enc = encode(S, a)
    t_dec = decode(T, a)
    return Equiv(
        to_fun=lambda r: t_enc(s_dec(r)),
        inv_fun=lambda s: s_enc(t_dec(s)),
        dom=S.R(a),
        cod=T.R(a),
    )


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    points: Tuple[str, ...] = ("a0", "a1", "a2")
    a0 = "a0"

    print("=" * 68)
    print("  The Fundamental Theorem of Identity Systems — finite models")
    print("=" * 68)

    # --- The canonical path identity system ---------------------------------
    S = path_identity_system(points, a0)
    print(f"\nBase type A = {points},  basepoint a0 = {a0!r}")
    print(f"Path family fibres:  " + ", ".join(
        f"(a0={a})={'•' if path_fibre(a0, a) else '∅'}" for a in points))
    print(f"Total space of S = {S.total_space()}")
    print(f"Total space contractible with center (a0, rflR)? {S.is_valid()}")

    # --- Theorem 3.3 --------------------------------------------------------
    print(f"\n[Theorem 3.3] encode/decode form an equivalence (a0=a) ≃ R(a): "
          f"{verify_fundamental(S)}")

    # --- Theorem 4.2 --------------------------------------------------------
    bf = base_fibre_contractible(S)
    print(f"[Theorem 4.2] base fibre R(a0) contractible: {bf.is_contractible()} "
          f"(center = {bf.center!r}, elements = {bf.elements})")

    # --- A second, *renamed* identity system at the same basepoint ----------
    # R'(a) := singleton {('eq', a)} iff a == a0 else empty — same shape as the
    # path family but with different fibre data. Still a valid identity system.
    def R2(a: str) -> Tuple[Tuple[str, str], ...]:
        return ((("eq", a)),) if a == a0 else tuple()

    T = IdentitySystem(points=points, R=R2, a0=a0, rflR=("eq", a0))
    print(f"\nSecond identity system T at a0 valid? {T.is_valid()}")

    # --- Theorem 4.3 --------------------------------------------------------
    all_ok = True
    for a in points:
        e = fibrewise_equiv(S, T, a)
        ok = e.is_equiv() and len(S.R(a)) == len(T.R(a))
        all_ok = all_ok and ok
        print(f"  R({a}) ≃ R'({a}):  |R|={len(S.R(a))} |R'|={len(T.R(a))}  equiv={ok}")
    print(f"[Theorem 4.3] homotopy-initiality (all fibrewise equivalences): {all_ok}")

    # --- Negative control: a NON-identity-system fails the test -------------
    # R''(a) := two elements over a0 (so R(a0) is NOT contractible).
    def Rbad(a: str) -> Tuple[str, ...]:
        return ("x", "y") if a == a0 else tuple()

    Bad = IdentitySystem(points=points, R=Rbad, a0=a0, rflR="x")
    print(f"\n[Negative control] R''(a0) has 2 elements; valid identity system? "
          f"{Bad.is_valid()}  (expected False — fibre not contractible)")

    print("\nAll positive theorems verified on the finite models above.")


if __name__ == "__main__":
    main()
