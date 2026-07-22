from typing import List, Optional

def collatz(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def orbit_and_stopping_time(n: int, max_steps: int = 10**7) -> Optional[List[int]]:
    """Return the orbit [n,...,1], or None if 1 is not reached within max_steps.

    Complexity: O(sigma(n)) map applications; sigma(n) has no known bound in n."""
    seq: List[int] = [n]
    while seq[-1] != 1:
        if len(seq) > max_steps:
            return None
        seq.append(collatz(seq[-1]))
    return seq
