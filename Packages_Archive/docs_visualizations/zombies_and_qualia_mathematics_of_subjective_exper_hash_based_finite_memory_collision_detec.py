from collections.abc import Callable, Iterable
from typing import Hashable, TypeVar
T = TypeVar("T", bound=Hashable)
S = TypeVar("S", bound=Hashable)

def find_memory_collision(streams: Iterable[tuple[T, ...]], memory: Callable[[tuple[T, ...]], S]) -> tuple[tuple[T, ...], tuple[T, ...], S] | None:
    seen: dict[S, tuple[T, ...]] = {}
    for word in streams:
        state = memory(word)
        if state in seen and seen[state] != word:
            return seen[state], word, state
        seen[state] = word
    return None
