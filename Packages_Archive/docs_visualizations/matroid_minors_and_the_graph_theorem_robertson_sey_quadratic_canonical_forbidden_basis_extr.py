from typing import Callable, TypeVar
T = TypeVar("T")
def minimal_forbidden(universe: list[T], belongs: Callable[[T], bool], leq: Callable[[T,T], bool]) -> list[T]:
    outside = [x for x in universe if not belongs(x)]
    return [x for x in outside if not any(y != x and leq(y, x) for y in outside)]

if __name__ == "__main__":
    universe = list(range(1, 61))
    basis = minimal_forbidden(universe, lambda n: n % 6 != 0 and n % 10 != 0, lambda a,b: b % a == 0)
    print(basis)
