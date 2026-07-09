from __future__ import annotations
import cmath, math
from typing import List, Sequence

Complex = complex

def std_add_char(N: int, x: int) -> Complex:
    """Standard additive character e(x) = exp(2*pi*i*x/N) on Z/NZ."""
    return cmath.exp(2j * math.pi * (x % N) / N)

def dft(N: int, f: Sequence[Complex]) -> List[Complex]:
    """Forward DFT with convention f_hat[k] = sum_j e(-j*k) * f[j]. O(N^2)."""
    return [sum(std_add_char(N, -(j * k)) * f[j] for j in range(N)) for k in range(N)]

def idft(N: int, fhat: Sequence[Complex]) -> List[Complex]:
    """Inverse DFT: f[j] = (1/N) sum_k e(j*k) * f_hat[k] (normalizer on inverse)."""
    return [sum(std_add_char(N, j * k) * fhat[k] for k in range(N)) / N for j in range(N)]
