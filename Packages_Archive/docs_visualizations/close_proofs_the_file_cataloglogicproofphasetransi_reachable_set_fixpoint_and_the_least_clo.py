from typing import Callable, FrozenSet, Iterable, List, Set

Theory = Callable[[int, int], bool]

def reachable_set(theory: Theory, universe: Iterable[int], a: int) -> FrozenSet[int]:
    """Least closed set containing `a`: R(a) = Cl(theory, {a})."""
    universe = list(universe)
    frontier: List[int] = [a]
    seen: Set[int] = {a}
    while frontier:
        x = frontier.pop()
        for y in universe:
            if theory(x, y) and y not in seen:
                seen.add(y)
                frontier.append(y)
    return frozenset(seen)
