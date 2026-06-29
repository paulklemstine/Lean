from typing import Callable, Hashable, List, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)


def is_contractible(carrier: Sequence[A]) -> bool:
    """Decide IsContr for a finite type modelled as a list of points.

    Returns True iff the carrier has exactly one distinct element (a center to
    which all elements are equal).  Runs in O(n) over the carrier size.
    """
    pts = list(dict.fromkeys(carrier))
    return len(pts) == 1


def center(carrier: Sequence[A]) -> A:
    """Return the unique center of a contractible carrier (precondition:
    is_contractible(carrier) is True)."""
    if not is_contractible(carrier):
        raise ValueError("carrier is not contractible")
    return carrier[0]
