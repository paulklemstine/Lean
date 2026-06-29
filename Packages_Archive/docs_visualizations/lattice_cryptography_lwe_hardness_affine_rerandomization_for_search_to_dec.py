from typing import Callable, List

def affine_rerandomize(p: int, a: int, b: int) -> Callable[[int], int]:
    """Build the measure-preserving affine map x -> (a*x + b) mod p used to
    rerandomize an LWE sample coordinate. For prime p and a != 0 this is a
    bijection of Z_p (ZMod.affine_bijective), so it preserves the uniform
    distribution; a wrong secret guess therefore yields uniform output."""
    assert a % p != 0, "multiplier must be a unit (a != 0) over the prime field"
    return lambda x: (a * x + b) % p

def rerandomized_distribution(p: int, a: int, b: int, samples: List[int]) -> List[int]:
    f = affine_rerandomize(p, a, b)
    return [f(x % p) for x in samples]
