from typing import Sequence

def level_two_certificate(weights: Sequence[float], nodes: Sequence[float]) -> tuple[bool, float]:
    if len(weights) != len(nodes) or any(w < 0 for w in weights):
        raise ValueError("matching nodes and nonnegative weights required")
    p1,p2,p3=(sum(w*x**k for w,x in zip(weights,nodes)) for k in (1,2,3))
    gap=p2*p2-p1*p3
    return gap>0.0,gap
