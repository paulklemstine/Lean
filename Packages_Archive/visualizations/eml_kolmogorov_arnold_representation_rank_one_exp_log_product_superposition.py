from math import exp, log

def product_rank_one(x: float, y: float) -> float:
    """Rank-one EML product on the open positive quadrant: x*y = exp(log x + log y).
    Requires x > 0 and y > 0."""
    if x <= 0.0 or y <= 0.0:
        raise ValueError("rank-one exp/log product requires x > 0 and y > 0")
    return exp(log(x) + log(y))
