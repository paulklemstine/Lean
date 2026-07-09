from typing import List, Optional, Tuple

def T(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def find_cycle(n: int) -> Tuple[List[int], Optional[int]]:
    """Floyd tortoise-hare cycle detection; returns (cycle, odd witness)."""
    slow, fast = T(n), T(T(n))
    while slow != fast:
        slow = T(slow); fast = T(T(fast))
    mu, slow = 0, n
    while slow != fast:
        slow = T(slow); fast = T(fast); mu += 1
    cycle: List[int] = [slow]
    odd_witness: Optional[int] = slow if slow % 2 == 1 else None
    x = T(slow)
    while x != slow:
        if x % 2 == 1 and odd_witness is None:
            odd_witness = x
        cycle.append(x); x = T(x)
    return cycle, odd_witness  # odd_witness exists by periodic_has_odd
