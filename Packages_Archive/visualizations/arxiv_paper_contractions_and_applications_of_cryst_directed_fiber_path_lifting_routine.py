from collections import deque
from typing import Hashable, Mapping, TypeVar
V = TypeVar("V", bound=Hashable)
def route(graph: Mapping[V, set[V]], start: V, goal: V) -> list[V] | None:
    todo = deque([start]); parent: dict[V, V | None] = {start: None}
    while todo:
        x = todo.popleft()
        if x == goal:
            out: list[V] = []
            while x is not None:
                out.append(x); x = parent[x]  # type: ignore[assignment]
            return out[::-1]
        for y in graph.get(x, set()):
            if y not in parent: parent[y] = x; todo.append(y)
    return None
