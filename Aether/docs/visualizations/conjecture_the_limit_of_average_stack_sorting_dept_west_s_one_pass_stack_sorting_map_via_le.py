from __future__ import annotations
from typing import List, Tuple


def pop_less(x: int, stack: List[int]) -> Tuple[List[int], List[int]]:
    """Pop every top entry strictly smaller than x (head = top of stack)."""
    i = 0
    while i < len(stack) and stack[i] < x:
        i += 1
    return stack[:i], stack[i:]


def stack_sort(seq: List[int]) -> List[int]:
    """One pass of West's stack-sorting map s. O(n) time, O(n) space."""
    stack: List[int] = []
    out: List[int] = []
    for x in seq:
        popped, rest = pop_less(x, stack)
        out.extend(popped)
        stack = [x] + rest
    out.extend(stack)
    return out
