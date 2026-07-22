from typing import Optional, Sequence

def termination_index(complexities: Sequence[int]) -> Optional[int]:
    for i in range(len(complexities) - 1):
        if complexities[i + 1] > complexities[i]:
            return None  # hypothesis violated
    final = complexities[-1]
    for n, c in enumerate(complexities):
        if c == final:
            return n
    return len(complexities) - 1
