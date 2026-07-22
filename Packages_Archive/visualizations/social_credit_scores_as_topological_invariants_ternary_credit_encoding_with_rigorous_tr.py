from __future__ import annotations
from typing import Sequence, Tuple

def encode_with_error(verdicts: Sequence[bool]) -> Tuple[float, float]:
    """Truncated ternary credit score and rigorous absolute error bound.

    Returns (score, error) where the exact infinite score lies in
    [score, score + error] and error = 3^-N for N verdicts, since the tail
    sum_{n>=N} 2/3^(n+1) equals 3^-N.
    """
    score = 0.0
    for n, a in enumerate(verdicts):
        if a:
            score += 2.0 / 3.0 ** (n + 1)
    return score, 3.0 ** (-len(verdicts))
