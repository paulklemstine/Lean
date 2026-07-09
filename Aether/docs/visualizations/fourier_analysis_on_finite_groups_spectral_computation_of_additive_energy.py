from __future__ import annotations
import cmath, math
from typing import List, Set

Complex = complex

def spectral_additive_energy(N: int, A: Set[int]) -> float:
    """Compute the additive energy E[A] of A subset Z/NZ via the spectral formula

        E[A] = (1/N) * sum_k |1A_hat[k]|^4.

    This costs one DFT (O(N log N) with an FFT) plus an O(N) fourth-moment sum,
    versus O(N^2) for the representation-count method and O(|A|^4) for brute force.
    Correctness is guaranteed by the theorem addEnergy_eq_dft.
    """
    ind: List[Complex] = [1.0 + 0j if (x % N) in A else 0j for x in range(N)]
    ahat: List[Complex] = [
        sum(cmath.exp(-2j * math.pi * (j * k % N) / N) * ind[j] for j in range(N))
        for k in range(N)
    ]
    return sum(abs(z) ** 4 for z in ahat) / N

def energy_lower_bound(N: int, A: Set[int]) -> float:
    """The certified lower bound |A|^4 / N (card_pow_four_div_le_addEnergy)."""
    return len(A) ** 4 / N
