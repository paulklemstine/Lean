from __future__ import annotations
import math

BOLTZMANN_K: float = 1.380649e-23

def landauer_normalization_heat(n: int, k: float = BOLTZMANN_K, T: float = 300.0) -> float:
    """Exact heat dissipated by collapsing all 2^n length-n proofs to one normal form.

    Implements proof_erasure_landauer_cost:  cost = k * T * n * ln 2.
    Complexity: O(1).
    """
    if n < 0:
        raise ValueError("proof length must be nonnegative")
    return k * T * n * math.log(2)

def bits_erased(n: int) -> int:
    """Information erased by normalizing length-n proofs: log2(2^n) = n bits."""
    return n
