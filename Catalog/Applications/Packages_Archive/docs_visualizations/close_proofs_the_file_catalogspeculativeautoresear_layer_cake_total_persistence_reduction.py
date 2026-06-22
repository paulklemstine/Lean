from typing import List

def total_persistence_layercake(deaths: List[int], horizon: int) -> int:
    """Total H0 persistence via the layer-cake identity: sum_d min(d, T)."""
    return sum(min(d, horizon) for d in deaths)
