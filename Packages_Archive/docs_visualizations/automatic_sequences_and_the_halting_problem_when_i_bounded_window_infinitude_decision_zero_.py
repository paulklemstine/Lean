from itertools import product
from typing import Callable, Hashable, Iterable, Optional, Tuple

State = Hashable
Symbol = Hashable

def decide_infinite(
    num_states: int,
    alphabet: Tuple[Symbol, ...],
    step: Callable[[State, Symbol], State],
    start: State,
    accept: frozenset,
) -> Tuple[bool, Optional[Tuple[Symbol, ...]]]:
    """Bounded-window [s, 2s) decision of language infinitude."""
    def ev(word: Iterable[Symbol]) -> State:
        s = start
        for a in word:
            s = step(s, a)
        return s
    for length in range(num_states, 2 * num_states):
        for w in product(alphabet, repeat=length):
            if ev(w) in accept:
                return True, w
    return False, None
