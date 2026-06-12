from typing import Callable, FrozenSet, Sequence
Sentence = int
Theory = FrozenSet[Sentence]

def decide_physical_consistency(worlds: Sequence[int],
                                sat: Callable[[int, Sentence], bool],
                                theory: Theory) -> bool:
    """HasModel(T): some world satisfies every sentence of T."""
    return any(all(sat(w, phi) for phi in theory) for w in worlds)
