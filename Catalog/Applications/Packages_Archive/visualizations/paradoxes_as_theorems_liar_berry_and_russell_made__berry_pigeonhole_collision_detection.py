from typing import Callable, Dict, List, Tuple

def berry_collision(objects: List[int],
                    descriptions: List[int],
                    definability: Callable[[int], int]) -> Tuple[int, int]:
    """Find two distinct objects sharing a description (Berry's paradox)."""
    if len(objects) <= len(descriptions):
        raise ValueError('no Berry overflow: collision not guaranteed')
    seen: Dict[int, int] = {}
    for o in objects:
        d = definability(o)
        if d not in descriptions:
            raise ValueError(f'object {o} mapped outside descriptions')
        if d in seen:
            return (seen[d], o)
        seen[d] = o
    raise RuntimeError('unreachable by pigeonhole')