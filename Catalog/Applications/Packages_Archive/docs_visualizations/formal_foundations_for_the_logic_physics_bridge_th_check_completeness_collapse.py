from itertools import combinations
from typing import Callable, FrozenSet, Iterable, Sequence, Tuple
Sentence = int
Theory = FrozenSet[Sentence]

def powerset(items: Sequence[Sentence]) -> Iterable[Theory]:
    return (frozenset(c) for r in range(len(items)+1)
            for c in combinations(items, r))

def completeness_collapse_holds(
        sentences: Tuple[Sentence, ...], bot: Sentence,
        proves: Callable[[Theory, Sentence], bool],
        worlds: Sequence[int],
        sat: Callable[[int, Sentence], bool],
        is_sound: Callable[..., bool]) -> bool:
    cons = lambda t: not proves(t, bot)
    model = lambda t: any(all(sat(w, p) for p in t) for w in worlds)
    complete = all(model(t) for t in powerset(sentences) if cons(t))
    if not (is_sound(sentences, bot, proves, worlds, sat) and complete):
        return True
    return all(cons(t) == model(t) for t in powerset(sentences))
