from itertools import product
from typing import Callable, Iterable, TypeVar
A = TypeVar("A")
def bounded_infinitude_witness(alphabet: Iterable[A], state_count: int, accepts: Callable[[tuple[A, ...]], bool]) -> tuple[A, ...] | None:
    symbols = tuple(alphabet)
    for length in range(state_count, 2 * state_count):
        for word in product(symbols, repeat=length):
            if accepts(word): return word
    return None
