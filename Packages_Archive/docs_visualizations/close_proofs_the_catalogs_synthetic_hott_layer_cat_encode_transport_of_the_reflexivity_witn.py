from typing import Callable, Hashable, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
RVal = TypeVar("RVal", bound=Hashable)

def idsys_encode(a0: A, a: A, rflR: RVal) -> RVal:
    """Encode: transport the reflexivity witness rflR : R(a0) along a path
    p : a0 = a to obtain an element of R(a).

    On a discrete model a path a0 = a exists only when a == a0, and transport
    along the trivial path rfl is the identity, so the result is rflR itself.
    """
    if a != a0:
        raise ValueError("no path a0 = a exists when a != a0")
    return rflR  # transport of rflR along rfl
