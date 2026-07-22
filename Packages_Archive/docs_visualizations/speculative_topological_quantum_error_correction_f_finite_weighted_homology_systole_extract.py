from __future__ import annotations
from typing import Hashable, Mapping

def weighted_systole(weights: Mapping[Hashable, int], zero: Hashable) -> tuple[int, Hashable]:
    candidates = [(w, x) for x, w in weights.items() if x != zero]
    if not candidates:
        raise ValueError("the model is trivial")
    return min(candidates, key=lambda pair: pair[0])

if __name__ == "__main__":
    weights = {"0": 0, "a": 8, "b": 5, "a+b": 11}
    value, witness = weighted_systole(weights, "0")
    print(f"systole={value}, witness={witness}")
