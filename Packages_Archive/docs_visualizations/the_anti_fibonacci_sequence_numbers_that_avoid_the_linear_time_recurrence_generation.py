from typing import List

def anti_fib_recurrence(count: int) -> List[int]:
    """Generate A(0..count-1) via A(0)=1, A(n+1)=A(n)+n in O(count) additions."""
    seq: List[int] = []
    a: int = 1
    for n in range(count):
        seq.append(a)
        a += n
    return seq
