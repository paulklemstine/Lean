from typing import List, Sequence

def distinct_mer_growth(seq: Sequence[int], m: int, q: int) -> List[int]:
    """Growth curve: distinct_mer_growth[N] = number of distinct m-mers among
    the first N window positions. Bounded above by min(N, q**m); the plateau
    onset localizes the transition from novelty to forced repetition."""
    seen = set()
    curve: List[int] = [0]
    windows = len(seq) - m + 1
    for i in range(windows):
        seen.add(tuple(seq[i + j] for j in range(m)))
        curve.append(len(seen))
        if len(seen) == q ** m:
            break
    return curve
