from typing import Dict, FrozenSet

Weight = Dict[FrozenSet[int], float]


def lerp(F: Weight, G: Weight, t: float) -> Weight:
    """Constant-speed geodesic (1 - t) * F + t * G, valid for t in [0, 1]."""
    assert -1e-9 <= t <= 1.0 + 1e-9
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def nested_param(r: float, s: float, t: float) -> float:
    """Gluing law: lerp(lerp s, lerp t, r) = lerp(F, G, (1-r)*s + r*t)."""
    return (1.0 - r) * s + r * t
