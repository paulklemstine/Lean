from __future__ import annotations
from typing import List


def stack_sort(seq: List[int]) -> List[int]:
    stack: List[int] = []
    out: List[int] = []
    for x in seq:
        i = 0
        while i < len(stack) and stack[i] < x:
            i += 1
        out.extend(stack[:i])
        stack = [x] + stack[i:]
    out.extend(stack)
    return out


def depth(seq: List[int]) -> int:
    """Least number of stack_sort passes reaching the ascending sort.
    Bounded by len(seq); worst case O(n^2) overall."""
    target = sorted(seq)
    cur = list(seq)
    count = 0
    for _ in range(len(seq) + 1):
        if cur == target:
            return count
        cur = stack_sort(cur)
        count += 1
    return count
