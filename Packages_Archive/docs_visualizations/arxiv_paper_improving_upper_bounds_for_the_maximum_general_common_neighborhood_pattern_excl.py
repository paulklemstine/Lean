from __future__ import annotations
from typing import Callable, Iterable
Graph = dict[int, set[int]]

def excluded_patterns(graph: Graph, active: set[int], target: int,
                      patterns: Iterable[frozenset[int]],
                      upper_bound: Callable[[set[int]], int]) -> list[frozenset[int]]:
    rejected: list[frozenset[int]] = []
    for pattern in patterns:
        common = set(active)
        for v in pattern:
            common &= graph[v]
        if len(pattern) + upper_bound(common) < target:
            rejected.append(pattern)
    return rejected
