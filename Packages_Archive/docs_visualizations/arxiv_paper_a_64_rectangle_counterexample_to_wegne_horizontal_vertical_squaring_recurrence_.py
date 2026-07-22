from __future__ import annotations
from collections.abc import Sequence

def recursive_scales(max_level: int) -> Sequence[int]:
    if max_level < 0: raise ValueError("max_level must be nonnegative")
    values = [4]
    for _ in range(max_level): values.append(values[-1] ** 2)
    return values

if __name__ == "__main__": print(list(recursive_scales(3)))
