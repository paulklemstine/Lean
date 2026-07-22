from typing import Dict, List, Tuple

def embed(n: int) -> Tuple[float, float]:
    """Proposed integer embedding n -> (1/2 + 1/(2n), |n|), n != 0."""
    if n == 0:
        raise ValueError("nonzero integers only")
    return (0.5 + 1.0 / (2.0 * n), float(abs(n)))

def value(x: float, y: float) -> float:
    return y * (2.0 * x - 1.0)

def collapse_scan(nmax: int) -> Dict[str, object]:
    """Scan integers in [-nmax, nmax] \\ {0}, computing value(embed(n)).

    Returns the sorted image set and whether the map is injective.
    """
    seen: Dict[float, List[int]] = {}
    for n in range(-nmax, nmax + 1):
        if n == 0:
            continue
        v = round(value(*embed(n)), 9)
        seen.setdefault(v, []).append(n)
    injective = all(len(v) == 1 for v in seen.values())
    return {"image": sorted(seen.keys()), "injective": injective,
            "classes": {k: len(v) for k, v in seen.items()}}
