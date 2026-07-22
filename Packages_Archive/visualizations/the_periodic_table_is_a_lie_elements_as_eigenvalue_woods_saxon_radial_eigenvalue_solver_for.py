from typing import List, Tuple
import math

def woods_saxon_shells(V0: float, R: float, a: float, rmax: float,
                       P: int, lmax: int) -> List[Tuple[float, int]]:
    # Units with hbar^2/(2m) = 1 for illustration.
    h = rmax / P
    def V(r: float) -> float:
        return -V0 / (1.0 + math.exp((r - R) / a))
    levels: List[Tuple[float, int]] = []
    for l in range(lmax + 1):
        diag: List[float] = []
        for i in range(1, P + 1):
            r = i * h
            diag.append(2.0 / h**2 + V(r) + l * (l + 1) / r**2)
        off = -1.0 / h**2
        eig = _tridiag_eigs(diag, off)
        for e in eig:
            if e < 0.0:
                levels.append((e, 2 * (2 * l + 1)))
    levels.sort(key=lambda t: t[0])
    return levels

def _tridiag_eigs(diag: List[float], off: float) -> List[float]:
    # Placeholder: use numpy.linalg.eigh(tridiagonal) in practice.
    # Returned unchanged diagonal as a stand-in for the demo.
    return sorted(diag)
