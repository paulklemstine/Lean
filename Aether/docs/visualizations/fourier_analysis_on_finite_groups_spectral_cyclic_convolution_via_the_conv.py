from __future__ import annotations
from typing import List, Sequence

Complex = complex

def spectral_convolution(N: int, f: Sequence[Complex], g: Sequence[Complex]) -> List[Complex]:
    """Cyclic convolution via the convolution theorem: transform, multiply, invert.

    Uses dft / idft from the DFT algorithm. With an FFT backend this is O(N log N)
    versus O(N^2) for the naive double loop. Correctness is guaranteed by
    dft(conv f g)[k] = dft(f)[k] * dft(g)[k] (the convolution theorem).
    """
    from math import pi
    import cmath

    def e(x: int) -> Complex:
        return cmath.exp(2j * pi * (x % N) / N)

    fhat = [sum(e(-(j * k)) * f[j] for j in range(N)) for k in range(N)]
    ghat = [sum(e(-(j * k)) * g[j] for j in range(N)) for k in range(N)]
    prod = [fhat[k] * ghat[k] for k in range(N)]
    return [sum(e(j * k) * prod[k] for k in range(N)) / N for j in range(N)]
