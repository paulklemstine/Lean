def tent(t: float) -> float:
    """Width-2 ReLU block: 1 - |2t - 1| = 1 - relu(2t-1) - relu(1-2t)."""
    return 1.0 - abs(2.0 * t - 1.0)


def tent_iterate(k: int, x: float) -> float:
    """Depth-k tent network tent^[k](x); O(k) ops, range in [0,1], Lipschitz 2^k."""
    t: float = x
    for _ in range(k):
        t = tent(t)
    return t