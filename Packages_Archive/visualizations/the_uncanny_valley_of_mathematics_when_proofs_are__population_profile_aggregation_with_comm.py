from typing import Sequence

def aggregate_and_certify(profiles: Sequence[Sequence[float]], v: int) -> tuple[list[float], bool, float]:
    if not profiles or not profiles[0] or any(len(p) != len(profiles[0]) for p in profiles):
        raise ValueError("profiles must form a nonempty rectangle")
    total = [sum(p[i] for p in profiles) for i in range(len(profiles[0]))]
    shape = (all(total[k+1] < total[k] for k in range(v)) and
             all(total[k] < total[k+1] for k in range(v, len(total)-1)))
    delta = min(x-total[v] for i,x in enumerate(total) if i != v)
    return total, shape, delta
