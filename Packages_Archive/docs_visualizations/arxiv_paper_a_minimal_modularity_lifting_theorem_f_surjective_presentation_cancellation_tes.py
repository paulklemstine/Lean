from typing import Callable, Iterable, TypeVar
R = TypeVar("R"); T = TypeVar("T"); A = TypeVar("A")
def cancel_surjection(source: Iterable[R], target: Iterable[T], q: Callable[[R], T], phi: Callable[[T], A], psi: Callable[[T], A]) -> bool:
    xs, ys = list(source), list(target)
    return {q(x) for x in xs} == set(ys) and all(phi(q(x)) == psi(q(x)) for x in xs) and all(phi(y) == psi(y) for y in ys)
