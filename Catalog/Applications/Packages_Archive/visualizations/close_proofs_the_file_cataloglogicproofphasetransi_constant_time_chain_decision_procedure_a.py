from typing import List

def chain_decide(a: int, b: int) -> bool:
    """Decidability of chain derivability: a derives b iff a <= b."""
    return a <= b

def chain_seg(a: int, n: int) -> List[int]:
    """Constructive witness [a, a+1, ..., a+n] of length n+1."""
    return [i + a for i in range(n + 1)]
