from typing import Set

def spread(config: Set[int]) -> Set[int]:
    """One step of the spreading rule: spread(S) = {0} union {n+1 : n in S}."""
    return {0} | {n + 1 for n in config}

def finite_stage(k: int) -> Set[int]:
    """Return the configuration spread^[k]({}) after k successor steps.

    Complexity: O(k * w) set operations where w is the width of the live
    region (here w = k), giving O(k^2) overall; O(k) if configurations are
    represented by their length (the live region is always an initial segment).
    """
    config: Set[int] = set()
    for _ in range(k):
        config = spread(config)
    return config
