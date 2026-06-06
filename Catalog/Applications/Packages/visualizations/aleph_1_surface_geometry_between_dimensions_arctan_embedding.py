import math

def arctan_embedding(x: float) -> float:
    return math.atan(x) / math.pi + 0.5

def arctan_embedding_inverse(y: float) -> float:
    if y <= 0 or y >= 1:
        raise ValueError(f'y = {y} must be in (0, 1)')
    return math.tan(math.pi * (y - 0.5))

def coordinate_wise_embed(point: list[float]) -> list[float]:
    return [arctan_embedding(x) for x in point]