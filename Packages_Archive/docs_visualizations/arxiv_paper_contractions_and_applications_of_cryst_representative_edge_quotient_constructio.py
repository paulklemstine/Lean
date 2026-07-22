from typing import Hashable, Iterable, TypeVar, Callable
V = TypeVar("V", bound=Hashable)
Q = TypeVar("Q", bound=Hashable)
def contract(edges: Iterable[tuple[V,V]], q: Callable[[V],Q]) -> set[tuple[Q,Q]]:
    return {(q(x), q(y)) for x, y in edges}
