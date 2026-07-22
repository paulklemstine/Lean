from typing import Tuple

def honest_transcript(n: int, k: int, w: int, r: int, c: bool) -> Tuple[int, bool, int]:
    if n <= 1:
        raise ValueError("n must exceed one")
    return ((k*r) % n, c, (r + (w if c else 0)) % n)
