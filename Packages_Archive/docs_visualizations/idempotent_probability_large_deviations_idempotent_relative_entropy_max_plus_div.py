from typing import Sequence

def relative_entropy(wq: Sequence[float], wp: Sequence[float]) -> float:
    """Idempotent relative entropy D(Q||P) = max_x ( w_Q(x) - w_P(x) ).

    For tropical probabilities this is >= 0 (idempotent Gibbs inequality),
    equals 0 iff w_Q(x) <= w_P(x) for all x, and D(P||P) = 0.
    """
    best = float("-inf")
    for q, p in zip(wq, wp):
        diff = q - p
        if diff > best:
            best = diff
    return best
