from __future__ import annotations
from typing import Hashable, Mapping, Sequence, TypeVar
A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
def relabel_prefix(prefix: Sequence[A], relabelling: Mapping[A, B]) -> tuple[B, ...]:
    return tuple(relabelling[x] for x in prefix)
