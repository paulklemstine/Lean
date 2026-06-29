from typing import Dict, List, Tuple

BinVec = Tuple[int, ...]


def wt(v: BinVec) -> int:
    return sum(1 for b in v if b == 1)


def ip(x: BinVec, y: BinVec) -> int:
    return sum(a * b for a, b in zip(x, y)) % 2


def code_invariants(code: List[BinVec]) -> Dict[str, object]:
    """Compute cardinality, weight enumerator, minimum distance and the
    self-orthogonality certificate of a binary code."""
    distinct = set(code)
    hist: Dict[int, int] = {}
    for v in code:
        hist[wt(v)] = hist.get(wt(v), 0) + 1
    nonzero = [wt(v) for v in code if wt(v) > 0]
    d_min = min(nonzero) if nonzero else 0
    self_orth = all(ip(x, y) == 0 for x in code for y in code)
    return {
        "cardinality": len(distinct),
        "weight_enumerator": dict(sorted(hist.items())),
        "minimum_distance": d_min,
        "self_orthogonal": self_orth,
    }
