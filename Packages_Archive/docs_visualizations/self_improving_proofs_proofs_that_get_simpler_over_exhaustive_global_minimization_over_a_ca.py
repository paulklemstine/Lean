from typing import Callable, Hashable, Iterable, Optional

def global_minimize(
    candidates: Iterable[Hashable],
    valid: Callable[[Hashable], bool],
    complexity: Callable[[Hashable], int],
) -> Optional[Hashable]:
    best: Optional[Hashable] = None
    for c in candidates:
        if valid(c) and (best is None or complexity(c) < complexity(best)):
            best = c
    return best
