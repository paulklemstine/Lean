"""Algorithm: Sublevel-Set Image Transport via the Polarity Map.

Given a finite sample of the sublevel set {f <= c} of an RC function f and the
linear polarity map L, produce the dual sublevel set {f_dual <= c} purely by
applying L, exploiting the image identity {f_dual <= c} = L({f <= c}).
"""

from __future__ import annotations

from typing import Callable, List, Tuple

Point = Tuple[float, float]


def transport_sublevel(samples: List[Point],
                       f: Callable[[Point], float],
                       L: Callable[[Point], Point],
                       c: float,
                       tol: float = 1e-9) -> List[Point]:
    """Return L({x in samples : f(x) <= c}), i.e. the dual sublevel set.

    By the image identity this equals {f_dual <= c} restricted to L(samples),
    without ever evaluating f_dual. Complexity O(N) in the number of samples.
    """
    primal: List[Point] = [x for x in samples if f(x) <= c + tol]
    return [L(x) for x in primal]


def verify_transport(samples: List[Point],
                     f: Callable[[Point], float],
                     f_dual: Callable[[Point], float],
                     L: Callable[[Point], Point],
                     c: float,
                     tol: float = 1e-9) -> bool:
    """Check that the transported set actually lies in {f_dual <= c}."""
    for y in transport_sublevel(samples, f, L, c, tol):
        if f_dual(y) > c + tol:
            return False
    return True
