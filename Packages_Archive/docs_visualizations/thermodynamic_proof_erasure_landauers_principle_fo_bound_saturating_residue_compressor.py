from typing import Callable

def residue_compressor(m: int) -> Callable[[int], int]:
    """The bound-saturating residue map i -> i mod 2^m, a function
    Fin(2^n) -> Fin(2^m). Every fiber has exactly 2^(n-m) preimages, so it
    pushes the uniform distribution to the uniform distribution and erases
    exactly (n - m)*ln 2 nats -- the minimum possible."""
    modulus = 1 << m
    return lambda i: i % modulus
