from __future__ import annotations
from typing import Callable
Graph = dict[int, set[int]]

def core_peeling(graph: Graph, target: int,
                 upper_bound: Callable[[set[int]], int]) -> set[int]:
    active = set(graph)
    while True:
        victim = next((v for v in sorted(active)
                       if 1 + upper_bound(active & graph[v]) < target), None)
        if victim is None:
            return active
        active.remove(victim)
