from dataclasses import dataclass
from typing import List, Tuple


@dataclass(frozen=True)
class CNF:
    """Ordinal < epsilon_0 in Cantor Normal Form: a tuple of
    (exponent: CNF, coefficient: int) terms in strictly decreasing
    exponent order.  The empty tuple is 0."""
    terms: Tuple[Tuple["CNF", int], ...]

    @staticmethod
    def zero() -> "CNF":
        return CNF(())

    @staticmethod
    def from_nat(n: int) -> "CNF":
        return CNF(()) if n == 0 else CNF(((CNF.zero(), n),))

    @staticmethod
    def omega_pow(exp: "CNF") -> "CNF":
        return CNF(((exp, 1),))

    def compare(self, other: "CNF") -> int:
        """Lexicographic comparison of CNF terms = ordinal order."""
        a, b = self.terms, other.terms
        i = 0
        while i < len(a) and i < len(b):
            ea, ca = a[i]
            eb, cb = b[i]
            c = ea.compare(eb)
            if c != 0:
                return c
            if ca != cb:
                return -1 if ca < cb else 1
            i += 1
        if len(a) == len(b):
            return 0
        return -1 if len(a) < len(b) else 1

    def __lt__(self, other: "CNF") -> bool:
        return self.compare(other) < 0

    def __eq__(self, other: object) -> bool:
        return isinstance(other, CNF) and self.compare(other) == 0

    def __hash__(self) -> int:
        return hash(tuple((e, c) for e, c in self.terms))

    def __add__(self, other: "CNF") -> "CNF":
        """Non-commutative ordinal addition: absorb self-terms with
        exponent below the leading exponent of other."""
        if not other.terms:
            return self
        if not self.terms:
            return other
        lead = other.terms[0][0]
        kept: List[Tuple[CNF, int]] = []
        for exp, coef in self.terms:
            cmp = exp.compare(lead)
            if cmp > 0:
                kept.append((exp, coef))
            elif cmp == 0:
                kept.append((exp, coef + other.terms[0][1]))
                kept.extend(other.terms[1:])
                return CNF(tuple(kept))
            else:
                break
        kept.extend(other.terms)
        return CNF(tuple(kept))


def tower(n: int) -> CNF:
    """Finite stage of the epsilon_0 fundamental sequence:
    tower(0)=0, tower(n+1)=omega^tower(n); sup = epsilon_0."""
    result = CNF.zero()
    for _ in range(n):
        result = CNF.omega_pow(result)
    return result
