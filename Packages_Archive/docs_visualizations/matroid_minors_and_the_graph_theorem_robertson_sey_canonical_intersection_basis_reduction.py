from typing import Callable, TypeVar
T = TypeVar("T")
def minimize_candidates(candidates: list[T], outside: Callable[[T], bool], leq: Callable[[T,T], bool]) -> list[T]:
    active = [x for x in candidates if outside(x)]
    return [x for x in active if not any(y != x and leq(y, x) for y in active)]

if __name__ == "__main__":
    candidates = [frozenset(x) for x in [{1,2},{1,2,3},{1,2,4},{1,3,4},{2,3,4}]]
    answer = minimize_candidates(candidates, lambda s: len(s)>2 or {1,2} <= s, lambda a,b: a <= b)
    print([sorted(x) for x in answer])
