from __future__ import annotations


def relu(y: float) -> float:
    """Rectified linear unit."""
    return y if y > 0.0 else 0.0


def tent_block(x: float) -> float:
    """One depth layer: the tent map as a two-neuron ReLU block."""
    return 1.0 - relu(2.0 * x - 1.0) - relu(-2.0 * x + 1.0)


def deep_tent(k: int, x: float) -> float:
    """Evaluate the depth-k deep tent: k stacked two-neuron blocks.

    Realizes tent^[k](x) exactly. Total network size is 2k neurons,
    producing 2^k oscillations -- logarithmic size in oscillation count.
    """
    y = x
    for _ in range(k):
        y = tent_block(y)
    return y
