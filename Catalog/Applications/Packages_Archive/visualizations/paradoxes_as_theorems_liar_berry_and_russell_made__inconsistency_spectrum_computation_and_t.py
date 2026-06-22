from dataclasses import dataclass
from enum import Enum
from typing import Dict

class Belnap(Enum):
    T = 'T'; F = 'F'; B = 'B'; N = 'N'

def is_true(v: Belnap) -> bool:
    return v in (Belnap.T, Belnap.B)

@dataclass
class Spectrum:
    nT: int; nF: int; nB: int; nN: int
    @property
    def inconsistency_degree(self) -> int:
        return self.nB
    @property
    def total(self) -> int:
        return self.nT + self.nF + self.nB + self.nN

def compute_spectrum(truth: Dict[int, Belnap]) -> Spectrum:
    c = {v: 0 for v in Belnap}
    for val in truth.values():
        c[val] += 1
    return Spectrum(c[Belnap.T], c[Belnap.F], c[Belnap.B], c[Belnap.N])

def has_explosion(truth: Dict[int, Belnap]) -> bool:
    glut = any(v == Belnap.B for v in truth.values())
    return glut and all(is_true(v) for v in truth.values())