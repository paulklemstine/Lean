from typing import List, Sequence, Tuple

Vector = Tuple[float, ...]

def scale_class(klass: Sequence[Vector], c: float) -> List[Vector]:
    """One linear layer with spectral factor c: pointwise scaling."""
    return [tuple(c * x for x in a) for a in klass]

def deep_net(klass: Sequence[Vector], c: float, L: int) -> List[Vector]:
    """L-layer network with uniform per-layer factor c (the L-fold iterate)."""
    out = [tuple(a) for a in klass]
    for _ in range(L):
        out = scale_class(out, c)
    return out

def deep_net_complexity(base_complexity: float, c: float, L: int) -> float:
    """Closed-form prediction empRad_deepNet:  c^L * R(A)."""
    return (c ** L) * base_complexity
