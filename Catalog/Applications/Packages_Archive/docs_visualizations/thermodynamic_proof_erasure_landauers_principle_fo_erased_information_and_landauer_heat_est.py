import math
from typing import Callable, Sequence

def shannon_entropy(p: Sequence[float]) -> float:
    """Shannon entropy in nats with the convention 0*log 0 = 0."""
    return -sum(x * math.log(x) for x in p if x > 0.0)

def erased_information(
    f: Callable[[int], int], n: int, m: int, p: Sequence[float] | None = None
) -> tuple[float, float]:
    """Return (erased nats, Landauer heat in units of k*T) for compressing
    2^n proofs to 2^m via f. By the theory, for uniform p the erased value is
    >= (n - m)*ln 2, with equality iff every nonempty fiber has equal weight."""
    src = list(p) if p is not None else [1.0 / (1 << n)] * (1 << n)
    img = [0.0] * (1 << m)
    for x, prob in enumerate(src):
        img[f(x)] += prob
    erased = shannon_entropy(src) - shannon_entropy(img)
    return erased, erased  # second value is heat / (k*T)
