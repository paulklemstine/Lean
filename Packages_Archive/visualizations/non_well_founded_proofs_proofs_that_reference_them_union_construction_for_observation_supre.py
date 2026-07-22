from typing import Hashable, Iterable, Set, TypeVar
T = TypeVar("T", bound=Hashable)

def observation_supremum(stages: Iterable[Set[T]]) -> Set[T]:
    supremum: Set[T] = set()
    for stage in stages:
        supremum |= stage
    return supremum
