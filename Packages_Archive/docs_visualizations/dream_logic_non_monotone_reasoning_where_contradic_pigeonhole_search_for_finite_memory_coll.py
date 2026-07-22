from itertools import product
from typing import Callable, Dict, Iterator, Sequence, Tuple, TypeVar
T = TypeVar("T")
def words(alphabet: Sequence[T], maximum: int) -> Iterator[Tuple[T, ...]]:
    for n in range(maximum + 1):
        yield from product(alphabet, repeat=n)
def collision(alphabet: Sequence[T], maximum: int, memory: Callable[[Tuple[T, ...]], int]) -> tuple[Tuple[T, ...], Tuple[T, ...], int]:
    seen: Dict[int, Tuple[T, ...]] = {}
    for word in words(alphabet, maximum):
        value = memory(word)
        if value in seen:
            return seen[value], word, value
        seen[value] = word
    raise ValueError("No collision in search region")
