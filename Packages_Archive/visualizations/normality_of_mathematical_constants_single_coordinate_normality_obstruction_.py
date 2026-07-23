from typing import Callable, Optional

DigitStream = Callable[[int], int]

def detect_obstruction(s: DigitStream, b: int, n: int, tol: float = 1e-3
                       ) -> Optional[int]:
    """
    Single-coordinate obstruction detector.  By the conservation law the
    frequencies sum to 1 at every n; if any digit's frequency is far from 1/b,
    the stream cannot be simply normal.  Returns an offending digit, or None.
    Complexity O(b * n).
    """
    target = 1.0 / b
    for d in range(b):
        f = sum(1 for k in range(n) if s(k) == d) / n
        if abs(f - target) > tol:
            return d
    return None
