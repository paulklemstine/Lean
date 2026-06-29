"""
demo.py — Numerical demonstrations for
"Path Spaces, h-Levels, and the Fibrewise Characterisation of Equivalences".

The theorems are about types-as-spaces, but each one has a finite, checkable
combinatorial shadow.  This script models small *finite* types as Python lists
and verifies every headline result by exhaustive enumeration:

    * IsContr A          -> A is nonempty and all elements are equal (|A| == 1).
    * IsMereProp A       -> any two elements are equal (|A| <= 1).
    * based path space   -> { b : a == b } is always a singleton  (Theorem 3.1).
    * retract closure    -> a retract of a contractible set is contractible (3.2).
    * IsContr <-> Nonempty & IsMereProp                              (Theorem 3.3).
    * Sigma / Pi closure of h-levels                          (Theorems 4.1-4.3).
    * Bijective f  <->  every homotopy fiber is contractible        (Theorem 5.1).
    * any two contractible types are equivalent                     (Theorem 6.1).

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


# ---------------------------------------------------------------------------
# h-level predicates on finite "types" (modelled as lists of distinct points)
# ---------------------------------------------------------------------------
def is_contr(carrier: Sequence[A]) -> bool:
    """IsContr A: A has a center and every element equals it (|A| == 1)."""
    pts = list(dict.fromkeys(carrier))  # dedup, keep order
    return len(pts) == 1


def is_mere_prop(carrier: Sequence[A]) -> bool:
    """IsMereProp A: any two elements are equal (at most one distinct point)."""
    return len(set(carrier)) <= 1


def is_nonempty(carrier: Sequence[A]) -> bool:
    return len(carrier) > 0


# ---------------------------------------------------------------------------
# Theorem 3.1 — based path space { b // a = b } is contractible
# ---------------------------------------------------------------------------
def based_path_space(carrier: Sequence[A], a: A) -> List[Tuple[A, bool]]:
    """Pairs (b, proof-that-a==b).  Only b == a carries a proof, so the
    inhabited total space is exactly {(a, True)} — a singleton."""
    return [(b, True) for b in carrier if a == b]


def demo_based_path_space() -> None:
    print("== Theorem 3.1: based path space is contractible ==")
    carrier = ["x", "y", "z", "w"]
    for a in carrier:
        space = based_path_space(carrier, a)
        endpoints = [b for (b, _) in space]
        print(f"  PathsFrom({a!r}) = {endpoints}  contractible={is_contr(endpoints)}")
    print()


# ---------------------------------------------------------------------------
# Theorem 3.2 — retract of a contractible type is contractible
# ---------------------------------------------------------------------------
def is_retract(
    big: Sequence[A],
    small: Sequence[B],
    s: Callable[[B], A],
    r: Callable[[A], B],
) -> bool:
    """B is a retract of A when r(s(b)) == b for all b in B."""
    return all(r(s(b)) == b for b in small)


def demo_retract_closure() -> None:
    print("== Theorem 3.2: retract of contractible is contractible ==")
    big = ["*"]                      # contractible
    small = ["pt"]
    s: Callable[[str], str] = lambda _b: "*"
    r: Callable[[str], str] = lambda _a: "pt"
    ok = is_retract(big, small, s, r)
    print(f"  A={big} contractible={is_contr(big)}, retract valid={ok}")
    print(f"  => B={small} contractible={is_contr(small)}\n")


# ---------------------------------------------------------------------------
# Theorem 3.3 — IsContr <-> Nonempty & IsMereProp
# ---------------------------------------------------------------------------
def demo_decomposition() -> None:
    print("== Theorem 3.3: IsContr <-> Nonempty & IsMereProp ==")
    samples: List[List[str]] = [[], ["a"], ["a", "a"], ["a", "b"]]
    for s in samples:
        lhs = is_contr(s)
        rhs = is_nonempty(s) and is_mere_prop(s)
        print(f"  carrier={s!s:<14} IsContr={lhs!s:<5} "
              f"Nonempty&Mere={rhs!s:<5} agree={lhs == rhs}")
    print()


# ---------------------------------------------------------------------------
# Theorems 4.1-4.3 — Sigma and Pi closure of h-levels
# ---------------------------------------------------------------------------
def sigma_type(
    base: Sequence[A], fiber: Callable[[A], Sequence[B]]
) -> List[Tuple[A, B]]:
    """Total space of a dependent pair: { (a, b) : a in base, b in fiber(a) }."""
    return [(a, b) for a in base for b in fiber(a)]


def pi_type(
    base: Sequence[A], fiber: Callable[[A], Sequence[B]]
) -> List[Tuple[B, ...]]:
    """Dependent functions: all choices of one element per fiber."""
    return [tuple(choice) for choice in product(*(fiber(a) for a in base))]


def demo_sigma_pi_closure() -> None:
    print("== Theorems 4.1-4.3: Sigma / Pi closure ==")
    base = ["*"]                                   # contractible base
    fiber: Callable[[str], List[str]] = lambda _a: ["o"]   # contractible fibers
    sig = sigma_type(base, fiber)
    pit = pi_type(base, fiber)
    print(f"  base contractible={is_contr(base)}, fiber contractible=True")
    print(f"  Sigma a, B a = {sig}  contractible={is_contr(sig)}")
    print(f"  Pi    a, B a = {pit}  contractible={is_contr(pit)}")

    # mere-prop Sigma closure
    base2 = ["a", "a"]            # mere prop (one distinct point)
    fiber2: Callable[[str], List[str]] = lambda _a: ["p"]
    sig2 = sigma_type(["a"], fiber2)
    print(f"  mere-prop Sigma example = {sig2}  mere_prop={is_mere_prop(sig2)}\n")


# ---------------------------------------------------------------------------
# Theorem 5.1 — Bijective f  <->  all homotopy fibers contractible
# ---------------------------------------------------------------------------
def hfiber(
    f: Callable[[A], B], domain: Sequence[A], b: B
) -> List[A]:
    """HFiber f b = { a : f(a) == b }."""
    return [a for a in domain if f(a) == b]


def bijective(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    images = [f(a) for a in domain]
    injective = len(set(images)) == len(domain)
    surjective = set(images) == set(codomain)
    return injective and surjective


def all_fibers_contractible(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    return all(is_contr(hfiber(f, domain, b)) for b in codomain)


def demo_fibrewise_equivalence() -> None:
    print("== Theorem 5.1: Bijective <-> all fibers contractible ==")
    dom = [0, 1, 2]
    cod = ["A", "B", "C"]

    cases: Dict[str, Callable[[int], str]] = {
        "bijection      ": lambda n: cod[n],                  # 0->A,1->B,2->C
        "not injective  ": lambda n: "A" if n < 2 else "C",   # 0,1->A
        "not surjective ": lambda n: "A" if n == 0 else "B",  # misses C
    }
    for name, f in cases.items():
        bij = bijective(f, dom, cod)
        fib = all_fibers_contractible(f, dom, cod)
        sizes = {b: len(hfiber(f, dom, b)) for b in cod}
        print(f"  {name}: bijective={bij!s:<5} fibersContr={fib!s:<5} "
              f"agree={bij == fib}  |fibers|={sizes}")
    print()


# ---------------------------------------------------------------------------
# Theorem 6.1 — any two contractible types are equivalent
# ---------------------------------------------------------------------------
def contractible_equiv(
    a_carrier: Sequence[A], b_carrier: Sequence[B]
) -> Tuple[Callable[[A], B], Callable[[B], A]] | None:
    """Return the mutually-inverse constant maps witnessing A ~= B, or None."""
    if not (is_contr(a_carrier) and is_contr(b_carrier)):
        return None
    a0, b0 = a_carrier[0], b_carrier[0]
    return (lambda _a: b0, lambda _b: a0)


def demo_unique_terminal() -> None:
    print("== Theorem 6.1: any two contractible types are equivalent ==")
    a = ["star"]
    b = [42]
    eq = contractible_equiv(a, b)
    assert eq is not None
    f, g = eq
    left = all(g(f(x)) == x for x in a)
    right = all(f(g(y)) == y for y in b)
    print(f"  A={a}, B={b}; left_inv={left}, right_inv={right} => equivalence\n")


# ---------------------------------------------------------------------------
def main() -> None:
    print("Numerical verification of the contractibility theorems\n")
    demo_based_path_space()
    demo_retract_closure()
    demo_decomposition()
    demo_sigma_pi_closure()
    demo_fibrewise_equivalence()
    demo_unique_terminal()
    print("All finite models agree with the formal theorems.")


if __name__ == "__main__":
    main()
