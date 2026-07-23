from itertools import product as iproduct
from typing import Callable, List, Sequence, Tuple, TypeVar

S = TypeVar("S")
Law = Callable[[S], bool]
Theory = List[Law]


def is_model(theory: Theory, s: S) -> bool:
    """s is a model of T iff it satisfies every law."""
    return all(law(s) for law in theory)


def decide_realizable_consistent(
    theory: Theory, space: Sequence[S]
) -> Tuple[bool, bool, bool]:
    """Decide Realizable T and Consistent T by exhaustive search over a finite
    state space, and verify they coincide (the logic-physics bridge).

    Returns (realizable, consistent, agree)."""
    realizable: bool = any(is_model(theory, s) for s in space)
    # Consistent := not (for all models s, False) := not (there are no models)
    entails_false: bool = all(False for s in space if is_model(theory, s))
    consistent: bool = not entails_false
    return realizable, consistent, (realizable == consistent)
