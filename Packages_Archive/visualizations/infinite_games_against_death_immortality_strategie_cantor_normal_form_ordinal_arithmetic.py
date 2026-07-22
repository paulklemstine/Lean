from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple


@dataclass(frozen=True)
class Ordinal:
    """An ordinal < omega^omega in Cantor Normal Form: a strictly decreasing
    list of (exponent, coefficient) terms."""
    terms: Tuple[Tuple[int, int], ...]

    @staticmethod
    def zero() -> "Ordinal":
        return Ordinal(())

    @staticmethod
    def finite(n: int) -> "Ordinal":
        return Ordinal(((0, n),)) if n > 0 else Ordinal(())

    @staticmethod
    def omega_pow(e: int, coeff: int = 1) -> "Ordinal":
        return Ordinal(((e, coeff),))

    def __lt__(self, other: "Ordinal") -> bool:
        for (ea, ca), (eb, cb) in zip(self.terms, other.terms):
            if ea != eb:
                return ea < eb
            if ca != cb:
                return ca < cb
        return len(self.terms) < len(other.terms)

    def __le__(self, other: "Ordinal") -> bool:
        return self.terms == other.terms or self < other

    def __add__(self, other: "Ordinal") -> "Ordinal":
        if not other.terms:
            return self
        if not self.terms:
            return other
        lead = other.terms[0][0]
        kept: List[Tuple[int, int]] = [(e, c) for e, c in self.terms if e > lead]
        merged = list(other.terms)
        for e, c in self.terms:
            if e == lead:
                fe, fc = merged[0]
                merged[0] = (fe, fc + c)
                break
        return Ordinal(tuple(kept + merged))

    def __mul__(self, other: "Ordinal") -> "Ordinal":
        if not self.terms or not other.terms:
            return Ordinal.zero()
        le, lc = self.terms[0]
        res = Ordinal.zero()
        for eb, cb in other.terms:
            if eb == 0:
                res = res + Ordinal(tuple([(le, lc * cb)] + list(self.terms[1:])))
            else:
                res = res + Ordinal.omega_pow(le + eb, cb)
        return res


def survival_value_finite() -> Ordinal:
    """Order type of (N, <) is omega."""
    return Ordinal.omega_pow(1)


def survival_value_lex(major: Ordinal, minor: Ordinal) -> Ordinal:
    """Order type of the lexicographic product = minor * major."""
    return minor * major
