from __future__ import annotations
from dataclasses import dataclass
from functools import total_ordering
from typing import List, Tuple


@total_ordering
@dataclass(frozen=True)
class Ord:
    """An ordinal < epsilon_0 in Cantor Normal Form (base omega).

    Stored as a tuple of (exponent, coefficient) terms in strictly
    decreasing exponent order.  0 is the empty tuple.
    """
    terms: Tuple[Tuple["Ord", int], ...]

    @staticmethod
    def zero() -> "Ord":
        return Ord(())

    @staticmethod
    def nat(n: int) -> "Ord":
        return Ord(()) if n == 0 else Ord(((Ord.zero(), n),))

    def is_zero(self) -> bool:
        return len(self.terms) == 0

    def __lt__(self, other: "Ord") -> bool:
        for (ea, ca), (eb, cb) in zip(self.terms, other.terms):
            if ea != eb:
                return ea < eb
            if ca != cb:
                return ca < cb
        return len(self.terms) < len(other.terms)

    def __add__(self, other: "Ord") -> "Ord":
        if other.is_zero():
            return self
        if self.is_zero():
            return other
        head_exp = other.terms[0][0]
        kept: List[Tuple["Ord", int]] = [
            (e, c) for (e, c) in self.terms if e > head_exp
        ]
        for (e, c) in self.terms:
            if e == head_exp:
                eb, cb = other.terms[0]
                kept.append((eb, c + cb))
                kept.extend(other.terms[1:])
                return Ord(tuple(kept))
        kept.extend(other.terms)
        return Ord(tuple(kept))

    def omega_pow(self) -> "Ord":
        """Return w ^ self."""
        return Ord.nat(1) if self.is_zero() else Ord(((self, 1),))
