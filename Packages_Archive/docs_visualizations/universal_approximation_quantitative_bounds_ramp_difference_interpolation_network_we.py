from typing import Callable, List, Tuple

Func = Callable[[float], float]

def assemble_network(f: Func, n: int) -> Tuple[float, List[Tuple[float, float]]]:
    """Return (bias, [(offset, coeff), ...]) for the 2n-neuron network."""
    bias: float = f(0.0)
    neurons: List[Tuple[float, float]] = []
    for k in range(n):
        s: float = n * (f((k + 1) / n) - f(k / n))
        neurons.append((k / n, s))
        neurons.append(((k + 1) / n, -s))
    return bias, neurons

def evaluate(bias: float, neurons: List[Tuple[float, float]], x: float) -> float:
    total: float = bias
    for offset, coeff in neurons:
        total += coeff * max(x - offset, 0.0)
    return total
