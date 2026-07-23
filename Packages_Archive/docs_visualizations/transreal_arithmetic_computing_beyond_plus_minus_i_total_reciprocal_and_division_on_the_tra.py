from __future__ import annotations
from demo import TReal, Kind


def recip(x: TReal) -> TReal:
    if x.kind == Kind.PHI:
        return TReal.phi()
    if x.kind in (Kind.PINF, Kind.NINF):
        return TReal.real(0.0)
    if x.value == 0.0:
        return TReal.pinf()
    return TReal.real(1.0 / x.value)


def divide(x: TReal, y: TReal) -> TReal:
    return x * recip(y)
