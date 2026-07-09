import math


def maslov_dequantize(x: float, y: float, t: float) -> float:
    """
    Maslov dequantization (max-convention):
        x (+)_t y = (1/t) * log(e^{t x} + e^{t y}).

    As t -> infinity this converges to max(x, y); the overshoot above max(x, y)
    is bounded by log(2) / t (two-sided sandwich).  Numerically stable.
    """
    m = max(x, y)
    return m + math.log(math.exp(t * (x - m)) + math.exp(t * (y - m))) / t
