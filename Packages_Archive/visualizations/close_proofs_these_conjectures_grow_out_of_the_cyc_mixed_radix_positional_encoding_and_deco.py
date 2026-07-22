from typing import Callable, List

def radix_prod(b: Callable[[int], int], k: int) -> int:
    """Running product P_b(k) = prod_{i<k} b(i)."""
    p = 1
    for i in range(k):
        p *= b(i)
    return p

def encode(b: Callable[[int], int], digits: List[int]) -> int:
    """Mixed-radix value of a digit string: sum_{i<k} c_i * P_b(i)."""
    return sum(c * radix_prod(b, i) for i, c in enumerate(digits))

def decode(b: Callable[[int], int], n: int, k: int) -> List[int]:
    """Length-k mixed-radix digits of n: c_i = (n // P_b(i)) % b(i)."""
    return [(n // radix_prod(b, i)) % b(i) for i in range(k)]
