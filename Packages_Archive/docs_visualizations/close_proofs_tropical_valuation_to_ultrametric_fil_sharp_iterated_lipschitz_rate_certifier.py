from typing import Callable


def iterate(f: Callable[[int], int], n: int, x: int) -> int:
    """Apply f n times to x."""
    for _ in range(n):
        x = f(x)
    return x


def iterated_lipschitz_bound(C: int, n: int, base_val: int) -> int:
    """Certified bound: val(f^[n] x) <= C^n * val(x) (sharp, by induction)."""
    return (C ** n) * base_val


def depth_separation(C: int, layers: int, input_val: int) -> int:
    """An L-layer C-Lipschitz network is C^L-Lipschitz."""
    return iterated_lipschitz_bound(C, layers, input_val)
