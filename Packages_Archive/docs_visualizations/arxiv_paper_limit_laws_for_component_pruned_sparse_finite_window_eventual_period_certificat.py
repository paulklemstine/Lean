from __future__ import annotations
from typing import Callable

def periodicity_failures(member: Callable[[int], bool], threshold: int, period: int, endpoint: int) -> list[int]:
    if threshold < 0 or period <= 0 or endpoint < threshold:
        raise ValueError("invalid interval or period")
    return [n for n in range(threshold, endpoint + 1) if member(n) != member(n + period)]
