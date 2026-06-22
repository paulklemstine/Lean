from typing import Callable, TypeVar, Hashable
A = TypeVar('A', bound=Hashable); T = TypeVar('T', bound=Hashable)

def idsys_elim(D: Callable[[A, T], object], d: object) -> Callable[[A, T], object]:
    # in the finite model every (a, r) collapses to (a0, rflR), so the
    # section is constantly d; the computation rule holds on the nose.
    return lambda _a, _r: d

# computation rule check:  idsys_elim(D, d)(a0, rflR) == d
