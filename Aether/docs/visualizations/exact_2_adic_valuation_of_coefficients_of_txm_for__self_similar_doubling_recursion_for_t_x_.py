from typing import List

def coefficients_of_T5(length: int) -> List[int]:
    """Return t_5(0..length-1) via the doubling recursion derived from
    T(x)^5 = (1-x)^5 * T(x^2)^5. Complexity O(length) big-integer operations."""
    t: List[int] = [0] * length
    if length:
        t[0] = 1
    def g(k: int) -> int:
        return t[k] if 0 <= k < length else 0
    for n in range(1, length):
        s = n // 2
        if n % 2 == 0:
            t[n] = g(s) + 10 * g(s - 1) + 5 * g(s - 2)
        else:
            t[n] = -(5 * g(s) + 10 * g(s - 1) + g(s - 2))
    return t
