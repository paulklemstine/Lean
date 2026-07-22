from typing import Sequence
def audit(scores: Sequence[float]) -> tuple[float,float,float]:
    gaps=[abs(a-b) for a,b in zip(scores,scores[1:])]
    endpoint=abs(scores[0]-scores[-1]); total=sum(gaps); uniform=len(gaps)*max(gaps)
    assert endpoint <= total+1e-12 <= uniform+1e-12
    return endpoint,total,uniform
print(audit([0.12,0.15,0.19,0.18,0.22]))
