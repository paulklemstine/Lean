from typing import List

def generate_repeated_127(count: int) -> List[int]:
    if count < 0: raise ValueError("count must be nonnegative")
    out: List[int] = []
    value = 127
    for _ in range(count):
        out.append(value)
        value = 1000 * value + 127
    return out
