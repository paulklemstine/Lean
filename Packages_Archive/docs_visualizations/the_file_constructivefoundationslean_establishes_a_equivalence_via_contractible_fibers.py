from typing import Callable, Hashable, List, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def fiber(f: Callable[[A], B], domain: Sequence[A], b: B) -> List[A]:
    """Compute the fiber f^{-1}(b)."""
    return [a for a in domain if f(a) == b]


def is_equivalence(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """`f` is an equivalence iff every fiber is contractible (a singleton).

    This is the structural ('good') definition. By the theorem
    `equiv_iff_contr_fibers` it coincides with admitting a quasi-inverse.
    """
    return all(len(set(fiber(f, domain, b))) == 1 for b in codomain)


def adjointified_inverse(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> Callable[[B], A]:
    """Return the (coherent) inverse, having first verified `f` is an equivalence.

    Mirrors qinv_to_ishae: only a genuine equivalence yields a well-defined,
    coherent inverse (each fiber is a singleton, so the preimage is canonical).
    """
    assert is_equivalence(f, domain, codomain), "f is not an equivalence"
    table = {f(a): a for a in domain}
    return lambda b: table[b]
