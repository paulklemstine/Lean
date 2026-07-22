"""Algorithm 3: Fibonacci-coincidence and undershoot scan."""
from __future__ import annotations
from typing import Dict, List


def anti_fibonacci_closed(n: int) -> int:
    """A(n) = 1 + n(n-1)//2."""
    return 1 + n * (n - 1) // 2


def coincidence_scan(n_max: int) -> Dict[str, List[int]]:
    """Scan n in [0, n_max] and classify A(n+2) vs A(n+1)+A(n).

    Uses the O(1) closed form, so the scan is O(n_max) total. Returns the
    coincidence set (provably {0, 3}) and the first undershoot index (4).
    """
    equal: List[int] = []
    undershoot: List[int] = []
    for n in range(n_max + 1):
        lhs = anti_fibonacci_closed(n + 2)
        rhs = anti_fibonacci_closed(n + 1) + anti_fibonacci_closed(n)
        if lhs == rhs:
            equal.append(n)
        elif lhs < rhs:
            undershoot.append(n)
    return {"equal": equal, "first_undershoot": undershoot[:1]}


if __name__ == "__main__":
    print(coincidence_scan(1000))
