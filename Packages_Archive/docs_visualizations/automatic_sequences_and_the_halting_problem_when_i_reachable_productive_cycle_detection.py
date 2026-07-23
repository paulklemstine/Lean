from typing import Hashable, Mapping, Set, TypeVar
Q = TypeVar("Q", bound=Hashable)
def productive_cycle(adjacency: Mapping[Q, Set[Q]], start: Q, targets: Set[Q]) -> bool:
    reachable: Set[Q] = set(); stack = [start]
    while stack:
        q = stack.pop()
        if q not in reachable: reachable.add(q); stack.extend(adjacency[q] - reachable)
    reverse = {q: set() for q in adjacency}
    for q, nexts in adjacency.items():
        for r in nexts: reverse[r].add(q)
    useful_to_target: Set[Q] = set(); stack = list(targets)
    while stack:
        q = stack.pop()
        if q not in useful_to_target: useful_to_target.add(q); stack.extend(reverse[q] - useful_to_target)
    useful = reachable & useful_to_target; color = {q: 0 for q in useful}
    def visit(q: Q) -> bool:
        color[q] = 1
        for r in adjacency[q] & useful:
            if color[r] == 1 or (color[r] == 0 and visit(r)): return True
        color[q] = 2; return False
    return any(color[q] == 0 and visit(q) for q in useful)
