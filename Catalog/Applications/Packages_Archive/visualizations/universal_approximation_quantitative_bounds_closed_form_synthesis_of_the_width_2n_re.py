from typing import Callable, List, Tuple

def relu(x: float) -> float:
    """ReLU activation sigma(x) = max(0, x)."""
    return x if x > 0.0 else 0.0

def synthesize_relu_interp_net(
    f: Callable[[float], float], n: int
) -> Tuple[float, List[Tuple[float, float, float]]]:
    """
    Synthesize the explicit width-2n ReLU interpolation network from n+1 samples.

    Returns (bias, units) where units = [(a_k, t_k, w_k)] and
        N(x) = bias + sum_k w_k * (relu(x - a_k) - relu(x - t_k)).

    If f is L-Lipschitz on [0,1], the result is certified to satisfy
        sup_{x in [0,1]} |f(x) - N(x)| <= L / n.
    """
    y: List[float] = [f(k / n) for k in range(n + 1)]
    bias: float = y[0]
    units: List[Tuple[float, float, float]] = []
    for k in range(n):
        a_k: float = k / n
        t_k: float = (k + 1) / n
        w_k: float = n * (y[k + 1] - y[k])   # cellSlope(f, n, k)
        units.append((a_k, t_k, w_k))
    return bias, units

def evaluate(network: Tuple[float, List[Tuple[float, float, float]]], x: float) -> float:
    """Evaluate the synthesized network at x in O(n)."""
    bias, units = network
    acc: float = bias
    for a_k, t_k, w_k in units:
        acc += w_k * (relu(x - a_k) - relu(x - t_k))
    return acc
