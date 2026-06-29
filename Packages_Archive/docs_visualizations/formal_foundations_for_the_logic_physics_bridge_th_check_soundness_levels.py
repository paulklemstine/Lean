from itertools import combinations
from typing import Callable, FrozenSet, Iterable, Sequence, Tuple
Sentence = int
Theory = FrozenSet[Sentence]

def powerset(items: Sequence[Sentence]) -> Iterable[Theory]:
    return (frozenset(c) for r in range(len(items)+1)
            for c in combinations(items, r))

def is_sound(sentences: Tuple[Sentence, ...], bot: Sentence,
             proves: Callable[[Theory, Sentence], bool],
             worlds: Sequence[int],
             sat: Callable[[int, Sentence], bool]) -> bool:
    for g in powerset(sentences):
        for phi in sentences:
            if proves(g, phi):
                for w in worlds:
                    if all(sat(w, p) for p in g) and not sat(w, phi):
                        return False
    return True

def is_falsum_sound(sentences: Tuple[Sentence, ...], bot: Sentence,
                    proves: Callable[[Theory, Sentence], bool],
                    worlds: Sequence[int],
                    sat: Callable[[int, Sentence], bool]) -> bool:
    for g in powerset(sentences):
        if proves(g, bot):
            for w in worlds:
                if all(sat(w, p) for p in g) and not sat(w, bot):
                    return False
    return True
