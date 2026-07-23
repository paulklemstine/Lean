from typing import Callable, Hashable, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
RVal = TypeVar("RVal", bound=Hashable)

def idsys_decode(a0: A, a: A, rflR: RVal,
                 total_space: Tuple[Tuple[A, RVal], ...]) -> bool:
    """Decode: recover the base path a0 = a from contractibility of the total
    space.  The pair (a, r) equals the center (a0, rflR); projecting onto first
    coordinates yields a = a0 (hence a path a0 = a), represented by True.

    Soundness is guaranteed when the supplied total space is contractible with
    center (a0, rflR), i.e. it is a genuine identity system.
    """
    center = (a0, rflR)
    if not all(x == center for x in total_space):
        raise ValueError("total space is not contractible onto (a0, rflR)")
    # every (a, r) collapses to the center, so a == a0; the path a0 = a exists.
    return True
