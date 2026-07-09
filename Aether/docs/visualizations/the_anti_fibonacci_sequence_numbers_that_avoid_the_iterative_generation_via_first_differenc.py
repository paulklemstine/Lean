from __future__ import annotations


def anti_fib_sequence(n: int) -> list[int]:
    """Return [A(0), ..., A(n-1)] via A(k+1)=A(k)+k in O(n) time."""
    seq: list[int] = []
    a: int = 1
    for k in range(n):
        seq.append(a)
        a += k
    return seq
