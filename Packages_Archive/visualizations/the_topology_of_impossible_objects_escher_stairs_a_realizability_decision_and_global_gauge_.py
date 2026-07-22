from typing import List, Optional


def holonomy(t: List[float]) -> float:
    """Sum of local increments around the cycle (the Penrose class)."""
    return sum(t)


def decide_and_reconstruct(t: List[float],
                           tol: float = 1e-12) -> Optional[List[float]]:
    """
    Decide realizability of an additive figure and, if realizable, return an
    explicit global height field h with h[(i+1) mod n] - h[i] = t[i].

    Returns None exactly when the figure is impossible (holonomy != 0).
    Runs in O(n) additions for a figure with n patches.
    """
    if abs(holonomy(t)) > tol:
        return None
    h, running = [0.0] * len(t), 0.0
    for i, ti in enumerate(t):
        h[i] = running
        running += ti
    return h
