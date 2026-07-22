from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction

@dataclass(frozen=True)
class Profile:
    period: int
    free: frozenset[int]
    @property
    def dimension(self) -> Fraction:
        return Fraction(len(self.free), self.period)

def synthesize(p: int, q: int) -> Profile:
    if q < 1 or p < 0 or p > q:
        raise ValueError("require 0 <= p <= q and q >= 1")
    return Profile(q, frozenset(range(p)))

if __name__ == "__main__":
    print(synthesize(3, 5), synthesize(3, 5).dimension)
