"""
Numerical / computational demonstration of the Fundamental Theorem of
Identity Systems and its companions.

The Lean development is type-theoretic, but every result has a concrete
finite-model shadow that we can *execute* and check. We model:

  * a "type" as a finite list of elements;
  * the identity type  (a0 = a)  as the singleton {()} when a == a0, else {};
  * a family R as a dict  a -> list of "certificates";
  * an IdentitySystem as a family whose total space  Sigma a, R a  collapses
    (is contractible) to a single centre sitting at the reflexivity witness.

We then build encode/decode, verify they are mutually inverse (the
Fundamental Theorem), verify the converse, the base-fibre contractibility,
homotopy-initiality (uniqueness), the induced eliminator and its computation
rule, and closure under products.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Generic, Hashable, Iterable, Optional, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
T = TypeVar("T", bound=Hashable)
S = TypeVar("S", bound=Hashable)


# ---------------------------------------------------------------------------
# Core structures: Contractible and Equiv'
# ---------------------------------------------------------------------------
@dataclass
class Contractible(Generic[T]):
    """A finite type (its elements) with a distinguished centre.

    Models  `structure Contractible X := (center : X) (contr : forall y, y = center)`.
    The data is valid iff every element actually equals the centre.
    """

    elements: list[T]
    center: T

    def is_valid(self) -> bool:
        return all(y == self.center for y in self.elements) and self.center in self.elements


@dataclass
class Equiv(Generic[T, S]):
    """A bespoke equivalence with full computational content (models `Equiv'`)."""

    domain: list[T]
    codomain: list[S]
    to_fun: Callable[[T], S]
    inv_fun: Callable[[S], T]

    def left_inv_holds(self) -> bool:
        return all(self.inv_fun(self.to_fun(x)) == x for x in self.domain)

    def right_inv_holds(self) -> bool:
        return all(self.to_fun(self.inv_fun(y)) == y for y in self.codomain)

    def is_valid(self) -> bool:
        return self.left_inv_holds() and self.right_inv_holds()

    def symm(self) -> "Equiv[S, T]":
        return Equiv(self.codomain, self.domain, self.inv_fun, self.to_fun)

    def trans(self, other: "Equiv[S, B]") -> "Equiv[T, B]":
        return Equiv(
            self.domain,
            other.codomain,
            lambda x: other.to_fun(self.to_fun(x)),
            lambda z: self.inv_fun(other.inv_fun(z)),
        )


# Lemma 3.1: contractibility transports across an equivalence.
def equiv_contractible(e: Equiv[T, S], h: Contractible[T]) -> Contractible[S]:
    """Push a contractibility witness across `e` (models `Equiv'.contractible`)."""
    return Contractible(
        elements=[e.to_fun(x) for x in h.elements],
        center=e.to_fun(h.center),
    )


# ---------------------------------------------------------------------------
# Identity types and identity systems
# ---------------------------------------------------------------------------
# We represent a path  (a0 = a)  by the marker () when a == a0 and nothing
# otherwise, so the "path space" R0 a is a singleton iff a == a0.
PATH = ()  # the unique reflexivity marker


def path_space(a0: A, a: A) -> list[tuple]:
    return [PATH] if a == a0 else []


@dataclass
class IdentitySystem(Generic[A, T]):
    """Models `IdentitySystem A a0 R`.

    `R[a]` is the list of certificates at `a`; `rflR` is the reflexivity
    witness in `R[a0]`. Validity demands the total space be contractible with
    centre at `(a0, rflR)`.
    """

    carrier: list[A]
    a0: A
    R: dict[A, list[T]]
    rflR: T

    def total_space(self) -> list[tuple[A, T]]:
        return [(a, r) for a in self.carrier for r in self.R[a]]

    def is_valid(self) -> bool:
        ts = self.total_space()
        center = (self.a0, self.rflR)
        return center in ts and all(p == center for p in ts)


# ---------------------------------------------------------------------------
# Encode / decode and the Fundamental Theorem (Theorem 4.3)
# ---------------------------------------------------------------------------
def encode(S_: IdentitySystem[A, T], a: A) -> Callable[[tuple], T]:
    """Transport the reflexivity witness along a path (models `idSysEncode`)."""
    # Only PATH lives in (a0 = a) when a == a0; transport of rflR is rflR there.
    return lambda _p: S_.rflR


def decode(S_: IdentitySystem[A, T], a: A) -> Callable[[T], tuple]:
    """Read off the base path from contractibility of the total space."""
    # By contractibility (a, r) == (a0, rflR), forcing a == a0, so the path is PATH.
    return lambda _r: PATH


def fundamental_identity_system(S_: IdentitySystem[A, T], a: A) -> Equiv[tuple, T]:
    """Assemble encode/decode into an equivalence  (a0 = a) ~ R a."""
    return Equiv(
        domain=path_space(S_.a0, a),
        codomain=S_.R[a],
        to_fun=encode(S_, a),
        inv_fun=decode(S_, a),
    )


# ---------------------------------------------------------------------------
# The converse (Theorem 6.2)
# ---------------------------------------------------------------------------
def psigma_congr(
    carrier: list[A],
    P: dict[A, list[T]],
    Q: dict[A, list[S]],
    e: dict[A, Equiv[T, S]],
) -> Equiv[tuple[A, T], tuple[A, S]]:
    """Assemble fibrewise equivalences into one equiv of total spaces (Lemma 6.1)."""
    dom = [(a, x) for a in carrier for x in P[a]]
    cod = [(a, y) for a in carrier for y in Q[a]]
    return Equiv(
        dom,
        cod,
        lambda s: (s[0], e[s[0]].to_fun(s[1])),
        lambda s: (s[0], e[s[0]].inv_fun(s[1])),
    )


def idsys_of_fiber_equiv(
    carrier: list[A], a0: A, R: dict[A, list[T]], e: dict[A, Equiv[tuple, T]]
) -> IdentitySystem[A, T]:
    """A family fibrewise equivalent to the path family IS an identity system."""
    return IdentitySystem(carrier, a0, R, rflR=e[a0].to_fun(PATH))


# ---------------------------------------------------------------------------
# Induced eliminator and its computation rule (Section 7)
# ---------------------------------------------------------------------------
def idsys_elim(
    S_: IdentitySystem[A, T],
    D: Callable[[A, T], object],  # motive returning a value (the section's output)
    d: object,  # base case at (a0, rflR)
) -> Callable[[A, T], object]:
    """Define a section by giving its value on the reflexivity witness only.

    In the finite model every (a, r) collapses to (a0, rflR), so the section is
    constantly `d` — exactly the content of transporting the base case along the
    contractibility witness, with the computation rule holding on the nose.
    """
    return lambda _a, _r: d


# ---------------------------------------------------------------------------
# Closure under products (Theorem 8.3)
# ---------------------------------------------------------------------------
def contractible_prod(hx: Contractible[T], hy: Contractible[S]) -> Contractible[tuple[T, S]]:
    return Contractible(
        elements=[(x, y) for x in hx.elements for y in hy.elements],
        center=(hx.center, hy.center),
    )


def idsys_prod(
    S1: IdentitySystem[A, T], S2: IdentitySystem[B, S]
) -> IdentitySystem[tuple[A, B], tuple[T, S]]:
    carrier = list(product(S1.carrier, S2.carrier))
    R: dict[tuple[A, B], list[tuple[T, S]]] = {
        (a, b): [(r, s) for r in S1.R[a] for s in S2.R[b]] for (a, b) in carrier
    }
    return IdentitySystem(carrier, (S1.a0, S2.a0), R, rflR=(S1.rflR, S2.rflR))


# ---------------------------------------------------------------------------
# Example builders
# ---------------------------------------------------------------------------
def based_path_identity_system(carrier: list[A], a0: A) -> IdentitySystem[A, tuple]:
    """The canonical identity system: R a = (a0 = a)."""
    R = {a: path_space(a0, a) for a in carrier}
    return IdentitySystem(carrier, a0, R, rflR=PATH)


def fingerprint_identity_system(
    carrier: list[A], a0: A, fingerprint: Callable[[A], Hashable]
) -> IdentitySystem[A, tuple]:
    """An *exotic* relation:  R a := { proof that fingerprint(a) == fingerprint(a0) }.

    This is an identity system precisely when `fingerprint` is injective on the
    carrier (so the only a with the same fingerprint as a0 is a0 itself).
    """
    R = {a: ([PATH] if fingerprint(a) == fingerprint(a0) else []) for a in carrier}
    return IdentitySystem(carrier, a0, R, rflR=PATH)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_fundamental_theorem() -> None:
    banner("1. The Fundamental Theorem of Identity Systems")
    carrier = ["a0", "a1", "a2"]
    # exotic family: fingerprint = string length-as-char; injective here.
    fp = {"a0": 10, "a1": 20, "a2": 30}
    S_ = fingerprint_identity_system(carrier, "a0", lambda a: fp[a])
    print("Identity system valid (total space contractible at rflR)?", S_.is_valid())
    for a in carrier:
        e = fundamental_identity_system(S_, a)
        print(
            f"  a={a:>3}:  (a0=a) has {len(e.domain)} elt(s), R a has "
            f"{len(e.codomain)} elt(s);  equivalence valid? {e.is_valid()}"
        )


def demo_converse() -> None:
    banner("2. The Converse: fibrewise equivalence => identity system")
    carrier = [0, 1, 2, 3]
    a0 = 0
    base = based_path_identity_system(carrier, a0)
    # Build an arbitrary family R fibrewise equivalent to the path family.
    R = {a: (["YES"] if a == a0 else []) for a in carrier}
    e = {
        a: Equiv(path_space(a0, a), R[a],
                 (lambda p: "YES"), (lambda r: PATH))
        for a in carrier
    }
    S_ = idsys_of_fiber_equiv(carrier, a0, R, e)
    print("Reconstructed reflexivity witness:", S_.rflR)
    print("Reconstructed identity system valid?", S_.is_valid())
    print("(matches base path system fibre sizes?",
          all(len(R[a]) == len(base.R[a]) for a in carrier), ")")


def demo_base_fiber_and_uniqueness() -> None:
    banner("3. Base-fibre contractibility and homotopy-initiality")
    carrier = ["x", "y", "z"]
    a0 = "x"
    S1 = based_path_identity_system(carrier, a0)
    S2 = fingerprint_identity_system(carrier, a0, lambda a: {"x": 1, "y": 2, "z": 3}[a])
    # Base fibre R a0 contractible:
    e0 = fundamental_identity_system(S1, a0)
    self_paths = Contractible(elements=path_space(a0, a0), center=PATH)
    fibre = equiv_contractible(e0, self_paths)
    print("Base fibre R(a0) contractible?", fibre.is_valid(), " centre =", fibre.center)
    # Uniqueness: R1 a ~ R2 a for all a
    for a in carrier:
        u = fundamental_identity_system(S1, a).symm().trans(
            fundamental_identity_system(S2, a)
        )
        print(f"  a={a}: R1 a ~ R2 a valid? {u.is_valid()}")


def demo_eliminator() -> None:
    banner("4. The induced eliminator and its computation rule")
    carrier = [True, False]
    a0 = True
    S_ = based_path_identity_system(carrier, a0)
    # Define a section that returns the string "base!" using only the base case.
    elim = idsys_elim(S_, D=lambda a, r: str, d="base!")
    print("elim at reflexivity witness:", elim(a0, S_.rflR), " (computation rule: == base case)")
    print("computation rule holds?", elim(a0, S_.rflR) == "base!")


def demo_products() -> None:
    banner("5. Closure under products")
    c1, c2 = [0, 1], ["p", "q"]
    S1 = based_path_identity_system(c1, 0)
    S2 = based_path_identity_system(c2, "p")
    P = idsys_prod(S1, S2)
    print("Product identity system base point:", P.a0)
    print("Product total space:", P.total_space())
    print("Product identity system valid?", P.is_valid())


def main() -> None:
    demo_fundamental_theorem()
    demo_converse()
    demo_base_fiber_and_uniqueness()
    demo_eliminator()
    demo_products()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
