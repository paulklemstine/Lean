from typing import Callable, Iterable, TypeVar
T = TypeVar("T")
def avoids(x: T, basis: Iterable[T], leq: Callable[[T,T], bool]) -> bool:
    return all(not leq(b, x) for b in basis)

if __name__ == "__main__":
    basis = [6, 10]
    for n in range(1, 31):
        assert avoids(n, basis, lambda a,b: b % a == 0) == (n % 6 != 0 and n % 10 != 0)
    print("Avoidance equivalence checked through 30.")
