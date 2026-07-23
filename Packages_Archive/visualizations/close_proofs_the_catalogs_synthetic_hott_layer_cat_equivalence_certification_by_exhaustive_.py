from typing import Callable, Hashable, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
RVal = TypeVar("RVal", bound=Hashable)

def is_equivalence(to_fun: Callable[[A], RVal],
                   inv_fun: Callable[[RVal], A],
                   dom: Tuple[A, ...],
                   cod: Tuple[RVal, ...]) -> bool:
    """Check that (to_fun, inv_fun) is an equivalence by exhaustive enumeration:
    inv_fun . to_fun = id on dom (left_inv) and to_fun . inv_fun = id on cod
    (right_inv).  A finite witness of the Fundamental Theorem fibre by fibre.
    """
    left = all(inv_fun(to_fun(x)) == x for x in dom)
    right = all(to_fun(inv_fun(y)) == y for y in cod)
    return left and right
