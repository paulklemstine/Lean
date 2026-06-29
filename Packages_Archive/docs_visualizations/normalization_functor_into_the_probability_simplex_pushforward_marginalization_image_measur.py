from typing import Callable, List, Sequence


def pushforward(f: Callable[[int], int], v: Sequence[float], m: int) -> List[float]:
    """Marginalize weights `v` (length n) along `f : {0..n-1} -> {0..m-1}`.

    Returns w of length m with w[k] = sum_{i : f(i) = k} v[i].
    Complexity: O(n + m) time, O(m) space.
    """
    w: List[float] = [0.0 for _ in range(m)]
    for i, vi in enumerate(v):
        w[f(i)] += vi
    return w
