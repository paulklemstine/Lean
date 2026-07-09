from __future__ import annotations
from typing import List


def terminal_parity(start_rank: int, num_steps: int) -> int:
    """O(1) terminal parity of a +/-1 rank walk, independent of directions.

    By parity rigidity, w(n) == w(0) + n (mod 2), so the terminal parity of
    a walk of length num_steps starting at start_rank is fully determined.
    """
    return (start_rank + num_steps) % 2


def returns_possible(start_rank: int, num_steps: int) -> bool:
    """A walk can return to its start only if num_steps is even (even-loop)."""
    return num_steps % 2 == 0
