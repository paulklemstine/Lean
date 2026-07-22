from typing import Sequence

def robustness_audit(reference: Sequence[float], observed: Sequence[float], v: int) -> dict[str, float | bool]:
    if len(reference) != len(observed) or len(reference) < 2:
        raise ValueError("profiles must have equal length at least two")
    delta = min(x-reference[v] for i,x in enumerate(reference) if i != v)
    epsilon = max(abs(x-y) for x,y in zip(reference, observed))
    return {"margin": delta, "max_error": epsilon, "certified": 2*epsilon < delta}
