from typing import Callable, Tuple


def fs_prove(x: int, r: int, g: int, p: int,
             H: Callable[[int], int]) -> Tuple[int, int]:
    t: int = (r * g) % p
    c: int = H(t)
    s: int = (r + c * x) % p
    return (t, s)


def fs_verify(Y: int, proof: Tuple[int, int], g: int, p: int,
              H: Callable[[int], int]) -> bool:
    t, s = proof
    return (s * g) % p == (t + H(t) * Y) % p
