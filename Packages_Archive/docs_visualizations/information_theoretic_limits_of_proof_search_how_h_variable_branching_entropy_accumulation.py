from __future__ import annotations
from math import log2
from typing import Sequence

def analyze_variable_tree(branching: Sequence[int]) -> tuple[int, float | None]:
    if any(value < 0 for value in branching):
        raise ValueError("branching factors must be nonnegative")
    population = 1
    for value in branching:
        population *= value
    information = sum(log2(value) for value in branching) if population else None
    return population, information
