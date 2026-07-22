from __future__ import annotations
from collections.abc import Callable, Iterator
from typing import TypeVar
T = TypeVar("T")

def dovetail(left: Callable[[int, int], bool], right: Callable[[int, int], bool], item: int) -> tuple[str, int]:
    """Illustrate parallel recognition; assumes exactly one side eventually accepts."""
    stage = 0
    while True:
        if left(item, stage):
            return ("left", stage)
        if right(item, stage):
            return ("right", stage)
        stage += 1

def finite_example(item: int, stage: int) -> bool:
    return stage >= item

if __name__ == "__main__":
    never = lambda item, stage: False
    print(dovetail(finite_example, never, 8))
