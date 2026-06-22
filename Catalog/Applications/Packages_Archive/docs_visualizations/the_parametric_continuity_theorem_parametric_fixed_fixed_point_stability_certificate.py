from typing import Callable

def stability_certificate(
    f: Callable[[float], float],
    g: Callable[[float], float],
    K: float,
    x_f: float,
    x_g: float,
) -> dict:
    """Certified bound on the distance between fixed points of f and g.

    f must be a K-contraction with fixed point x_f; g is ARBITRARY with fixed
    point x_g. Returns the actual distance, the certified upper bound
    d(f(x_g), g(x_g)) / (1 - K), and whether the bound holds.
    """
    assert 0.0 <= K < 1.0
    actual = abs(x_f - x_g)
    bound = abs(f(x_g) - g(x_g)) / (1.0 - K)
    return {"actual": actual, "bound": bound, "valid": actual <= bound + 1e-9}
