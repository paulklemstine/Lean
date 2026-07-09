from typing import Dict, List

def classify_mu2(p: int) -> Dict[str, object]:
    """Classify the group scheme mu_2 = Spec k[a]/(a^2-1) over a field of
    characteristic p (use p = 0 for characteristic zero)."""
    length: int = 2  # dim_k k[a]/(a^2 - 1) is always 2
    if p == 2:
        points: List[int] = [1]                 # (a-1)^2 = 0
        return {"points": points, "num_points": 1, "length": length,
                "reduced": False, "type": "infinitesimal", "smooth": False}
    if p == 0:
        points = [1, -1]
    else:
        points = sorted({a for a in range(p) if (a * a) % p == 1})
    return {"points": points, "num_points": len(points), "length": length,
            "reduced": True, "type": "etale", "smooth": True}
