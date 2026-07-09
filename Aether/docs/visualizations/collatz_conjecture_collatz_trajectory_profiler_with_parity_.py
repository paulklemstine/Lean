from typing import List, Tuple

def T(n: int) -> int:
    """Collatz step map: n/2 if even, else 3n+1."""
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_trajectory(n: int, max_steps: int = 100_000) -> Tuple[List[int], str, int, int]:
    """Return (orbit, parity word, stopping time, peak altitude) for the orbit of n."""
    assert n > 0
    orbit: List[int] = [n]
    word: List[str] = []
    steps = 0
    while n != 1 and steps < max_steps:
        if n % 2 == 0:
            word.append("E"); n //= 2
        else:
            word.append("O"); n = 3 * n + 1
        orbit.append(n); steps += 1
    return orbit, "".join(word), steps, max(orbit)
