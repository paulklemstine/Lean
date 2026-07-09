from typing import Callable, List, Optional, TypeVar

V = TypeVar("V")


def discrete_ivt_witness(
    walk: List[V],
    label: Callable[[V], int],
    c: int,
) -> Optional[V]:
    """
    Discrete intermediate value theorem along a walk.

    Given a walk (sequence of vertices) and an integer labelling `label` that
    changes by at most 1 across each consecutive pair, with
    label(walk[0]) <= c <= label(walk[-1]), return the first vertex whose label
    equals c (guaranteed to exist under the hypotheses). The level set
    {x : label(x) = c} is therefore a separator for any such monotone-Lipschitz
    labelling. Time: O(len(walk)).
    """
    for v in walk:
        if label(v) == c:
            return v
    return None
