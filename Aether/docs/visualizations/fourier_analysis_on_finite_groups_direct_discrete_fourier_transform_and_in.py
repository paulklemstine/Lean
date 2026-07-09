from __future__ import annotations
import cmath, math
from typing import List

def dft(f: List[complex]) -> List[complex]:
    """Direct O(N^2) discrete Fourier transform on Z/NZ."""
    n = len(f)
    return [sum(f[j]*cmath.exp(-2j*math.pi*j*k/n) for j in range(n)) for k in range(n)]

def idft(fhat: List[complex]) -> List[complex]:
    """Inverse transform via Fourier inversion, f(j)=(1/N)sum_k f_hat(k)e^{+2pi i jk/N}."""
    n = len(fhat)
    return [sum(fhat[k]*cmath.exp(2j*math.pi*j*k/n) for k in range(n))/n for j in range(n)]
