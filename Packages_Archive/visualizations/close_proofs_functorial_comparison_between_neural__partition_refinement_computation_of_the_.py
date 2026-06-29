from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple

State = Tuple[int, ...]
Word = Tuple[str, ...]


def behavior(step: Callable[[State, str], State],
             observe: Callable[[State], Tuple[int, ...]],
             x: State, word: Sequence[str]) -> Tuple[int, ...]:
    """behavior(x, w) = observe(foldl(step, x, w))."""
    s = x
    for a in word:
        s = step(s, a)
    return observe(s)


def behavior_congruence(states: List[State],
                        alphabet: List[str],
                        step: Callable[[State, str], State],
                        observe: Callable[[State], Tuple[int, ...]],
                        max_depth: int) -> List[List[State]]:
    """Compute the behavior congruence by partition refinement.

    Returns the list of behavior classes (each a list of states). Two states
    land in the same class iff they agree on all input contexts of length
    <= max_depth (which equals full behavioral equivalence once max_depth
    reaches the Myhill-Nerode bound |states|)."""
    # signature of a state = tuple of read-outs over all words up to max_depth
    words: List[Word] = [()]
    for length in range(1, max_depth + 1):
        words.extend(product(alphabet, repeat=length))
    buckets: Dict[Tuple, List[State]] = {}
    for x in states:
        sig = tuple(behavior(step, observe, x, w) for w in words)
        buckets.setdefault(sig, []).append(x)
    return list(buckets.values())
