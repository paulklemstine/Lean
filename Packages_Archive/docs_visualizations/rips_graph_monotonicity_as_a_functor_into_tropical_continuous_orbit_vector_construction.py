from typing import Callable, List, TypeVar

T = TypeVar("T")


def orbit_vector(f: Callable[[T], T], x: T, horizon: int) -> List[T]:
    """Constructive content of the orbit map x ↦ (x, f(x), ..., f^[N-1](x)).
    Continuity of this map (Theorem 6.2) makes a nonlinear dynamical process into a
    single feature map into a finite product space. Complexity: O(N · cost(f))."""
    out: List[T] = []
    cur: T = x
    for _ in range(horizon):
        out.append(cur)
        cur = f(cur)
    return out
