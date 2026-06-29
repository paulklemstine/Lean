"""
demo.py — Numerical demonstrations for
"Constructive Foundations from Homotopy Type Theory".

Homotopy Type Theory is not, on its face, a numerical subject: its objects are
types and paths, not numbers. But every theorem in the accompanying paper has a
faithful *set-level shadow* — a model in which types are finite sets and a "path"
from a to b exists exactly when a == b. In that shadow:

    * a type is "contractible"            <->  it has exactly one element;
    * a type "is a proposition"           <->  it has at most one element;
    * the "fiber of f over b"             <->  the preimage f^{-1}(b);
    * "f is an equivalence"               <->  every fiber is a singleton
                                               (i.e. f is a bijection);
    * the "based path space at a"          <->  the singleton {a} (one path: refl);
    * the "Fundamental Theorem (<=)"       <->  a family of codes (C x) whose total
                                               size is 1 reproduces identity types.

This file makes all of those statements executable and checks them on concrete
finite data. Everything is self-contained: no imports beyond the standard library,
and every helper is inlined.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


# ---------------------------------------------------------------------------
# 1. The set-level shadow of paths and the groupoid laws
# ---------------------------------------------------------------------------
def path_exists(a: Hashable, b: Hashable) -> bool:
    """A path a ~> b exists iff a == b (the discrete/set-level model of `Path`)."""
    return a == b


def refl(a: A) -> Tuple[A, A]:
    """The trivial path `refl a : Path a a`, represented as the pair (a, a)."""
    return (a, a)


def symm(p: Tuple[A, A]) -> Tuple[A, A]:
    """Path reversal: symm (a ~> b) = (b ~> a)."""
    a, b = p
    return (b, a)


def trans(p: Tuple[A, A], q: Tuple[A, A]) -> Tuple[A, A]:
    """Path concatenation; requires the endpoints to match."""
    a, b = p
    b2, c = q
    assert b == b2, "non-composable paths"
    return (a, c)


def check_groupoid_laws(carrier: Sequence[A]) -> bool:
    """Verify left/right unit, inverse, and associativity laws on `carrier`."""
    ok = True
    for a in carrier:
        p = refl(a)
        # unit laws
        ok &= trans(refl(a), p) == p
        ok &= trans(p, refl(a)) == p
        # inverse laws
        ok &= trans(p, symm(p)) == refl(a)
        ok &= trans(symm(p), p) == refl(a)
    # associativity on composable triples (all loops at a in the discrete model)
    for a in carrier:
        p = q = r = refl(a)
        ok &= trans(trans(p, q), r) == trans(p, trans(q, r))
    return bool(ok)


# ---------------------------------------------------------------------------
# 2. Contractibility, fibers, and the coincidence of equivalences
#    (Theorem: equiv_iff_contr_fibers)
# ---------------------------------------------------------------------------
def fiber(f: Callable[[A], B], domain: Sequence[A], b: B) -> List[A]:
    """The fiber f^{-1}(b) = { a in domain : f a == b }."""
    return [a for a in domain if f(a) == b]


def is_contractible(elements: Sequence[Hashable]) -> bool:
    """A set is contractible (one element up to a path) iff it is a singleton."""
    return len(set(elements)) == 1


def is_proposition(elements: Sequence[Hashable]) -> bool:
    """A set is an h-proposition iff it has at most one element."""
    return len(set(elements)) <= 1


def has_contractible_fibers(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """`IsEquiv f`: every fiber of f is contractible (a singleton)."""
    return all(is_contractible(fiber(f, domain, b)) for b in codomain)


def has_quasi_inverse(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """`QInv f`: f is a bijection between domain and codomain (naive equivalence)."""
    images = [f(a) for a in domain]
    return len(images) == len(set(images)) and set(images) == set(codomain)


def quasi_inverse(
    f: Callable[[A], B], domain: Sequence[A]
) -> Callable[[B], A]:
    """Adjointified inverse: in the set model this is the honest preimage map."""
    table: Dict[B, A] = {f(a): a for a in domain}
    return lambda b: table[b]


# ---------------------------------------------------------------------------
# 3. Fundamental Theorem of Identity Types (manufacturing direction, encode-decode)
# ---------------------------------------------------------------------------
def based_path_space(carrier: Sequence[A], a: A) -> List[Tuple[A, Tuple[A, A]]]:
    """Sigma_x Path(a, x): the based path space at a. Always a singleton {(a, refl a)}."""
    return [(x, refl(a)) for x in carrier if path_exists(a, x)]


def total_space_size(codes: Dict[A, int]) -> int:
    """|Sigma_x C(x)| = sum of code sizes."""
    return sum(codes.values())


def encode_decode_ok(carrier: Sequence[A], a: A, codes: Dict[A, int]) -> bool:
    """
    Fundamental Theorem (<=): if the total space of the code family C is
    contractible (size 1), the codes reproduce the identity types:
        |Path(a, x)| == C(x)   for every x.
    """
    if total_space_size(codes) != 1:
        return False
    return all((1 if path_exists(a, x) else 0) == codes.get(x, 0) for x in carrier)


def identity_codes(carrier: Sequence[A], a: A) -> Dict[A, int]:
    """Canonical codes: C(x) = 1 if x == a else 0 (e.g. for Bool, Fin n)."""
    return {x: (1 if x == a else 0) for x in carrier}


# ---------------------------------------------------------------------------
# 4. Propositional truncation ||A|| and its recursion principle
# ---------------------------------------------------------------------------
def ptrunc_is_inhabited(elements: Sequence[A]) -> bool:
    """||A|| remembers exactly one bit: whether A was inhabited."""
    return len(elements) > 0


def ptrunc_rec(
    elements: Sequence[A], f: Callable[[A], B], target_prop: Sequence[B]
) -> B | None:
    """
    Recursion principle: a map f : A -> P into a proposition P factors uniquely
    through ||A||. Returns the (unique) value, or None for the empty truncation.
    Asserts that f indeed lands in a proposition (so the factorization is valid).
    """
    assert is_proposition(target_prop), "target of ptrunc_rec must be a proposition"
    if not elements:
        return None
    values = {f(a) for a in elements}
    assert len(values) == 1, "image must collapse to a single point in P"
    return next(iter(values))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Constructive Foundations from Homotopy Type Theory — numerical demos")
    print("=" * 70)

    # --- 1. Groupoid laws -------------------------------------------------
    carrier = ["x", "y", "z"]
    print("\n[1] Groupoid laws (unit, inverse, associativity) hold on", carrier)
    print("    verified:", check_groupoid_laws(carrier))

    # --- 2. equiv_iff_contr_fibers ---------------------------------------
    print("\n[2] Coincidence of equivalences: QInv f  <=>  contractible fibers")
    dom = [0, 1, 2]
    cod = ["a", "b", "c"]
    bijection: Callable[[int], str] = lambda n: cod[n]
    collapse: Callable[[int], str] = lambda n: "a"  # not injective
    for name, f in [("bijection", bijection), ("collapse  ", collapse)]:
        q = has_quasi_inverse(f, dom, cod)
        c = has_contractible_fibers(f, dom, cod)
        print(f"    {name}: QInv={q!s:5}  contractible_fibers={c!s:5}  agree={q == c}")
    inv = quasi_inverse(bijection, dom)
    print("    adjointified inverse of bijection sends 'b' ->", inv("b"))

    # --- 3. Fundamental Theorem / encode-decode --------------------------
    print("\n[3] Fundamental Theorem of Identity Types (manufacturing direction)")
    for space_name, space, base in [
        ("Bool ", [False, True], True),
        ("Fin 4", [0, 1, 2, 3], 2),
    ]:
        bp = based_path_space(space, base)
        codes = identity_codes(space, base)
        print(
            f"    {space_name}: based path space size={len(bp)} (contractible="
            f"{is_contractible([p[0] for p in bp])}),"
            f" encode/decode ok={encode_decode_ok(space, base, codes)}"
        )

    # --- 4. Propositional truncation -------------------------------------
    print("\n[4] Propositional truncation ||A|| and recursion into a proposition")
    nonempty = [10, 20, 30]
    empty: List[int] = []
    prop_target = ["exists"]  # a one-element proposition
    f_const: Callable[[int], str] = lambda _: "exists"
    print("    ||{10,20,30}|| inhabited:", ptrunc_is_inhabited(nonempty))
    print("    ||{}|| inhabited:        ", ptrunc_is_inhabited(empty))
    print("    rec into proposition (nonempty):", ptrunc_rec(nonempty, f_const, prop_target))
    print("    rec into proposition (empty):   ", ptrunc_rec(empty, f_const, prop_target))

    # --- 5. Univalence / equivalence induction (transport of a property) -
    print("\n[5] Equivalence induction: transport a property across an equivalence")
    # Property P: 'this set has even cardinality'. Transport across a bijection.
    src = [1, 2, 3, 4]
    f2: Callable[[int], int] = lambda n: n + 10  # bijection onto {11,12,13,14}
    tgt = [f2(n) for n in src]
    p_src = (len(src) % 2 == 0)
    p_tgt = (len(tgt) % 2 == 0)
    print("    bijection preserves 'even cardinality':", p_src == p_tgt, "(both", p_src, ")")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
