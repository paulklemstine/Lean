from typing import Callable

def tent(x: float) -> float:
    """The width-2 ReLU tent block: tent(x) = 1 - |2x - 1|."""
    return 1.0 - abs(2.0 * x - 1.0)

def tent_iterate(k: int, x: float) -> float:
    """Evaluate the depth-k constant-width tent network tent^[k](x) in O(k)."""
    for _ in range(k):
        x = tent(x)
    return x

def tent_network(k: int) -> Callable[[float], float]:
    """Return the depth-k tent map as a callable (a depth-k ReLU network)."""
    return lambda x: tent_iterate(k, x)
