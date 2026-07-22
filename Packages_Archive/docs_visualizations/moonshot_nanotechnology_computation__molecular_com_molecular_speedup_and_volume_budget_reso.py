from __future__ import annotations
from math import ceil, log2
from typing import Dict

def analyze_speedup(work: int, parallelism: int, volume_cap: int) -> Dict[str, float]:
    """Given work W, parallelism p, and volume cap P, return the resource bounds."""
    p_eff = min(parallelism, volume_cap)
    return {
        "parallel_time_lower_bound": ceil(work / p_eff),
        "speedup_cap": min(p_eff, work),
        "sequential_time": work,
        "effective_parallelism": p_eff,
        "log2_work": log2(work) if work > 0 else 0.0,
    }
