from typing import Callable, TypeVar
R = TypeVar("R"); T = TypeVar("T"); A = TypeVar("A")
def transport_point(rho: Callable[[R], A], inverse_comparison: Callable[[T], R]) -> Callable[[T], A]:
    return lambda t: rho(inverse_comparison(t))
