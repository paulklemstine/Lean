from typing import Callable, Hashable, List, Sequence

def maximal_chain(
    candidates: Sequence[Hashable],
    refines: Callable[[Hashable, Hashable], bool],
    complexity: Callable[[Hashable], int],
    start: Hashable,
) -> List[Hashable]:
    chain: List[Hashable] = [start]
    current: Hashable = start
    while True:
        simpler = [c for c in candidates if refines(c, current)]
        if not simpler:
            return chain
        current = max(simpler, key=complexity)
        chain.append(current)
