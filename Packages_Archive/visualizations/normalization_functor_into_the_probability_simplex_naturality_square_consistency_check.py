from typing import Callable, List, Sequence


def normalize(v: Sequence[float]) -> List[float]:
    total = sum(v)
    return [0.0 for _ in v] if total == 0.0 else [x / total for x in v]


def pushforward(f: Callable[[int], int], v: Sequence[float], m: int) -> List[float]:
    w = [0.0 for _ in range(m)]
    for i, vi in enumerate(v):
        w[f(i)] += vi
    return w


def naturality_check(f: Callable[[int], int], v: Sequence[float], m: int,
                     tol: float = 1e-9) -> bool:
    """Verify normalize . pushforward == pushforward . normalize for given data."""
    left: List[float] = normalize(pushforward(f, v, m))   # coarsen then normalize
    right: List[float] = pushforward(f, normalize(v), m)  # normalize then coarsen
    return all(abs(a - b) <= tol for a, b in zip(left, right))
