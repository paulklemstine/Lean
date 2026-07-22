from typing import List, Sequence

Vector = Sequence[float]

def stereo_attention_forward(
    q: Vector,
    keys: Sequence[Vector],
    values: Sequence[Vector],
) -> List[float]:
    """Single stereographic attention head: Cauchy-kernel weighted sum of values."""
    scores: List[float] = [
        1.0 / (1.0 + sum((qi - ki) ** 2 for qi, ki in zip(q, k)))
        for k in keys
    ]
    z: float = sum(scores)
    dim: int = len(values[0])
    out: List[float] = [0.0] * dim
    for s, v in zip(scores, values):
        w = s / z
        for j in range(dim):
            out[j] += w * v[j]
    return out
