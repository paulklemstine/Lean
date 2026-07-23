from typing import List, Sequence

def natural_gradient_step(p: Sequence[float], grad: Sequence[float],
                          lr: float, eps: float = 1e-12) -> List[float]:
    """One natural-gradient step on the categorical simplex (diagonal Fisher metric)."""
    nat: List[float] = [pi * gi for pi, gi in zip(p, grad)]
    p_new: List[float] = [max(pi - lr * ni, eps) for pi, ni in zip(p, nat)]
    z = sum(p_new)
    return [x / z for x in p_new]
