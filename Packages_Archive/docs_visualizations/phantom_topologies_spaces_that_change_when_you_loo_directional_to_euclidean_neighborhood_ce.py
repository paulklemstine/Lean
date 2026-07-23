from dataclasses import dataclass
@dataclass(frozen=True)
class Certificate:
    center: float
    radius: float
def consensus_ball(a: float, x: float, b: float) -> Certificate:
    if not a < x < b: raise ValueError("require a < x < b")
    return Certificate(x, min(x-a, b-x))
print(consensus_ball(-0.7, 0.2, 1.4))
