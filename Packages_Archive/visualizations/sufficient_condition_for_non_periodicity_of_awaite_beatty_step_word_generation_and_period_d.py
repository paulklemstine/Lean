from __future__ import annotations
import math
from typing import List, Optional

def beatty_step_word(alpha: float, length: int) -> List[int]:
    """d_alpha(n) = floor((n+1)*alpha) - floor(n*alpha) for n in [0, length)."""
    return [math.floor((n + 1) * alpha) - math.floor(n * alpha) for n in range(length)]

def smallest_period(word: List[int]) -> Optional[int]:
    """Smallest detected period p of the prefix, or None (evidence of aperiodicity)."""
    n = len(word)
    for p in range(1, n // 2 + 1):
        if all(word[i] == word[i + p] for i in range(n - p)):
            return p
    return None
