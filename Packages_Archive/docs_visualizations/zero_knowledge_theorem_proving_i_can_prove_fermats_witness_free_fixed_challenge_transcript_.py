from typing import Tuple

def simulate_transcript(n: int, k: int, y: int, z: int, c: bool) -> Tuple[int, bool, int]:
    if n <= 1:
        raise ValueError("n must exceed one")
    return (((k*z) - (y if c else 0)) % n, c, z % n)
