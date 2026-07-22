from __future__ import annotations
from typing import List, Sequence

def observed_born(amplitudes: Sequence[float], tolerance: float = 0.0) -> List[float]:
    norm_sq = sum(a * a for a in amplitudes)
    if norm_sq == 0.0:
        raise ValueError("zero state")
    exact = [a * a / norm_sq for a in amplitudes]
    return [0.0 if abs(w) <= tolerance else w for w in exact]
