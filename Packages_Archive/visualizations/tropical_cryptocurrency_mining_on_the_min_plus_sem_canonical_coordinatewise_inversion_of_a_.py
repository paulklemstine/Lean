from typing import Sequence

def tropical_hash(message: Sequence[float], key: Sequence[float]) -> float:
    if not message or len(message) != len(key):
        raise ValueError("nonempty vectors of equal length required")
    return min(x + a for x, a in zip(message, key))

def canonical_preimage(key: Sequence[float], target: float) -> list[float]:
    if not key:
        raise ValueError("key must be nonempty")
    return [target - a for a in key]

