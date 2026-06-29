from typing import Callable

def relu(x: float) -> float:
    """ReLU activation."""
    return x if x > 0.0 else 0.0

def tent(x: float) -> float:
    """One triangle wave on [0,1], realized with width 2: 2*relu(x) - 4*relu(x-1/2)."""
    return 2.0 * relu(x) - 4.0 * relu(x - 0.5)

def deep_sawtooth(d: int) -> Callable[[float], float]:
    """
    Return the depth-d sawtooth s_d = tent o tent o ... o tent (d times).

    s_d has 2^d linear pieces yet is realizable by a depth-(d+1), constant-width
    ReLU network. A shallow (single-hidden-layer) network needs Omega(2^d)
    neurons to realize the same number of pieces: an exponential depth-width
    separation.
    """
    def s(x: float) -> float:
        for _ in range(d):
            x = tent(x)
        return x
    return s
