from typing import List, Tuple

def anti_fib_closed(n: int) -> int:
    return (n * n - n + 2) // 2

def avoidance_certificate(upto: int) -> List[Tuple[int, int, int, str]]:
    """For 2 <= n < upto return (n, excess, (n-2)(n-5)/2, status) where
    excess = (A(n-1)+A(n-2)) - A(n).  status classifies sign / equality."""
    out: List[Tuple[int, int, int, str]] = []
    for n in range(2, upto):
        excess = anti_fib_closed(n - 1) + anti_fib_closed(n - 2) - anti_fib_closed(n)
        formula = (n - 2) * (n - 5) // 2
        assert excess == formula
        if excess < 0:
            status = "term exceeds sum"
        elif excess == 0:
            status = "equality" if n == 5 else "boundary"
        else:
            status = "strict avoidance"
        out.append((n, excess, formula, status))
    return out
