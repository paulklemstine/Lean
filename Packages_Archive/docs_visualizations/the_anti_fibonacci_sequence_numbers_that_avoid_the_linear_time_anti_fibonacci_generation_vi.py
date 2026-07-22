from __future__ import annotations

def anti_fib_sequence(n_max: int) -> list[int]:
    """Return [A(0), ..., A(n_max)] where A(0)=1 and A(n+1)=A(n)+n.
    Runs in O(n_max) integer additions and O(n_max) space."""
    seq: list[int] = [1]
    for n in range(n_max):
        seq.append(seq[-1] + n)
    return seq
