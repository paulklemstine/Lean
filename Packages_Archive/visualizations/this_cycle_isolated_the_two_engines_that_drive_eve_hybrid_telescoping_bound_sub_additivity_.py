from typing import List, Sequence, Tuple


def per_step_advantages(d: Sequence[float]) -> List[float]:
    """Per-step advantages |d_i - d_{i+1}| of a game chain."""
    return [abs(d[i] - d[i + 1]) for i in range(len(d) - 1)]


def hybrid_telescope_bound(d: Sequence[float]) -> Tuple[float, float]:
    """
    Telescoping hybrid bound.

    Returns (end_to_end, upper_bound) where
      end_to_end = |d_0 - d_n|
      upper_bound = sum_i |d_i - d_{i+1}|   (>= end_to_end, always).
    """
    n = len(d) - 1
    end_to_end = abs(d[0] - d[n])
    upper_bound = sum(per_step_advantages(d))
    return end_to_end, upper_bound
