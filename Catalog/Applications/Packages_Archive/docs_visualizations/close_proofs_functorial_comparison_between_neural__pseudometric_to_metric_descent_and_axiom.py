from typing import Callable, List, Tuple

State = Tuple[int, ...]


def quot_obs_dist(class_index: Callable[[State], int]
                  ) -> Callable[[State, State], int]:
    """The descended metric quotObsDist on the behavioral quotient.

    Returns a function d(x, y) = 0 if x, y lie in the same behavior class
    (i.e. [x] = [y]) and 1 otherwise. On classes this is a genuine metric:
    it satisfies the triangle inequality and full SEPARATION
    (d = 0  <=>  same class), unlike the pseudometric on raw states."""
    def d(x: State, y: State) -> int:
        return 0 if class_index(x) == class_index(y) else 1
    return d


def verify_metric_axioms(states: List[State],
                         d: Callable[[State, State], int]) -> bool:
    """Check non-negativity, self-zero, symmetry, triangle, separation."""
    ok = True
    for x in states:
        ok = ok and d(x, x) == 0
        for y in states:
            ok = ok and d(x, y) >= 0 and d(x, y) == d(y, x)
            for z in states:
                ok = ok and d(x, z) <= d(x, y) + d(y, z)
    return ok
