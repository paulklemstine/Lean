from typing import Callable, List, Tuple

State = Tuple[int, ...]


def myhill_nerode_quotient(classes: List[List[State]]
                           ) -> Tuple[List[State], Callable[[State], int]]:
    """Form the minimal (compressed) realization from behavior classes.

    Returns (representatives, class_index) where `representatives[i]` is the
    chosen representative of class i and `class_index(x)` returns the index of
    the class containing x. This is observably-lossless compression: the
    representative behaves identically to every state it replaces."""
    reps: List[State] = [cls[0] for cls in classes]
    lookup = {}
    for i, cls in enumerate(classes):
        for x in cls:
            lookup[x] = i

    def class_index(x: State) -> int:
        return lookup[x]

    return reps, class_index
