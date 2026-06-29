#!/usr/bin/env python3
"""
Algorithms for Selberg Class Census

Type-hinted implementations of the core algorithms from the formal framework:
1. Selberg datum encoding and decoding
2. Spectral complexity and entropy computation
3. Conductor counting function
4. Primitive datum detection
5. Factorization enumeration
"""

from fractions import Fraction
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Iterator, Set
from math import gcd
from itertools import product as iterproduct


@dataclass(frozen=True)
class SelbergDatum:
    """Immutable Selberg datum for hashing and comparison."""
    degree: int
    conductor: int
    spectral_shifts: Tuple[Fraction, ...]

    def __post_init__(self):
        assert self.conductor >= 1, "Conductor must be positive"

    @property
    def num_gamma_factors(self) -> int:
        return len(self.spectral_shifts)

    @property
    def is_well_formed(self) -> bool:
        return self.num_gamma_factors == self.degree


def spectral_complexity(S: SelbergDatum) -> Fraction:
    """Compute κ(S) = d·q + Σ|μᵢ|."""
    return Fraction(S.degree * S.conductor) + sum(abs(s) for s in S.spectral_shifts)


def coarse_complexity(S: SelbergDatum) -> int:
    """Compute κ̃(S) = d + q + r."""
    return S.degree + S.conductor + S.num_gamma_factors


def spectral_entropy(S: SelbergDatum) -> Fraction:
    """Compute η(S) = Σ(|μᵢ.num| + μᵢ.den)."""
    total = Fraction(0)
    for s in S.spectral_shifts:
        total += Fraction(abs(s.numerator) + s.denominator)
    return total


def datum_product(S1: SelbergDatum, S2: SelbergDatum) -> SelbergDatum:
    """Compute the Rankin-Selberg product datum S1 · S2."""
    return SelbergDatum(
        degree=S1.degree + S2.degree,
        conductor=S1.conductor * S2.conductor,
        spectral_shifts=S1.spectral_shifts + S2.spectral_shifts
    )


def encode_datum(S: SelbergDatum) -> Tuple[int, int, int, Tuple[Tuple[int, int], ...]]:
    """Encode a SelbergDatum as a tuple of natural numbers for countability."""
    shifts = tuple((s.numerator, s.denominator) for s in S.spectral_shifts)
    return (S.degree, S.conductor, S.num_gamma_factors, shifts)


def decode_datum(code: Tuple[int, int, int, Tuple[Tuple[int, int], ...]]) -> SelbergDatum:
    """Decode a tuple back to a SelbergDatum."""
    d, q, r, shifts_raw = code
    shifts = tuple(Fraction(n, d) for n, d in shifts_raw)
    assert len(shifts) == r
    return SelbergDatum(degree=d, conductor=q, spectral_shifts=shifts)


def enumerate_data(
    degree: int,
    max_conductor: int,
    allowed_shifts: List[Fraction],
    well_formed_only: bool = True
) -> List[SelbergDatum]:
    """
    Enumerate all Selberg data with given degree, conductor ≤ max_conductor,
    and spectral shifts drawn from allowed_shifts.

    If well_formed_only, require num_gamma_factors == degree.
    """
    results: List[SelbergDatum] = []
    r = degree if well_formed_only else degree  # For well-formed, r = d
    for q in range(1, max_conductor + 1):
        for shifts in iterproduct(allowed_shifts, repeat=r):
            S = SelbergDatum(degree=degree, conductor=q, spectral_shifts=tuple(shifts))
            results.append(S)
    return results


def count_selberg_data(degree: int, max_Q: int, r: int, B: int) -> int:
    """
    Count the number of discretized Selberg data: |Fin(Q+1) × (Fin r → Fin(2B+1))|
    filtered by q+1 > 0 (always true).

    This matches the Lean definition countSelbergData.
    """
    return (max_Q + 1) * ((2 * B + 1) ** r)


def is_primitive(S: SelbergDatum, known_data: Optional[List[SelbergDatum]] = None) -> bool:
    """
    Check if S is primitive: degree ≥ 1 and not expressible as a product
    of two data with degree ≥ 1.

    If known_data is provided, checks against all pairs in that list.
    Otherwise uses a simple degree-based check.
    """
    if S.degree < 1:
        return False
    if known_data is None:
        # Without a database, we can't check exhaustively
        # A degree-1 datum is always primitive (can't split degree 1 into two ≥ 1)
        return S.degree == 1
    # Check all pairs
    for S1 in known_data:
        if S1.degree < 1 or S1.degree >= S.degree:
            continue
        for S2 in known_data:
            if S2.degree < 1 or S2.degree >= S.degree:
                continue
            if S1.degree + S2.degree != S.degree:
                continue
            prod = datum_product(S1, S2)
            if (prod.degree == S.degree and
                prod.conductor == S.conductor and
                prod.spectral_shifts == S.spectral_shifts):
                return False
    return True


def factorizations(
    S: SelbergDatum,
    primitives: List[SelbergDatum]
) -> List[List[SelbergDatum]]:
    """
    Find all factorizations of S into products of primitives.

    Uses the fact that degree strictly decreases under factorization,
    so this terminates.
    """
    if S.degree == 0:
        return [[]]  # Empty product
    if S in primitives:
        return [[S]]

    results: List[List[SelbergDatum]] = []
    for P in primitives:
        if P.degree > S.degree:
            continue
        if S.conductor % P.conductor != 0:
            continue
        # Try to "divide" S by P
        remaining_degree = S.degree - P.degree
        remaining_conductor = S.conductor // P.conductor
        if remaining_degree < 0:
            continue
        # Check if remaining shifts match
        remaining_shifts = list(S.spectral_shifts)
        valid = True
        for s in P.spectral_shifts:
            if s in remaining_shifts:
                remaining_shifts.remove(s)
            else:
                valid = False
                break
        if not valid:
            continue

        remainder = SelbergDatum(
            degree=remaining_degree,
            conductor=remaining_conductor,
            spectral_shifts=tuple(remaining_shifts)
        )
        if remainder.degree == 0 and remainder.conductor == 1 and len(remainder.spectral_shifts) == 0:
            results.append([P])
        else:
            for sub_fact in factorizations(remainder, primitives):
                results.append([P] + sub_fact)

    return results


def conductor_counting_table(
    degree: int,
    max_Q: int,
    allowed_shifts: List[Fraction]
) -> List[Tuple[int, int]]:
    """
    Compute the conductor counting function N_d(Q) for Q = 1, ..., max_Q.
    Returns list of (Q, N_d(Q)) pairs.
    """
    table: List[Tuple[int, int]] = []
    for Q in range(1, max_Q + 1):
        data = enumerate_data(degree, Q, allowed_shifts, well_formed_only=True)
        # Filter to primitive only (for degree 1, all are primitive)
        prims = [S for S in data if is_primitive(S)]
        table.append((Q, len(prims)))
    return table


# === Demo ===

if __name__ == "__main__":
    print("Selberg Class Census — Algorithm Demonstrations\n")

    # Basic data
    zeta = SelbergDatum(1, 1, (Fraction(0),))
    chi4 = SelbergDatum(1, 4, (Fraction(1, 2),))

    print(f"ζ(s) datum: {zeta}")
    print(f"  κ = {spectral_complexity(zeta)}")
    print(f"  η = {spectral_entropy(zeta)}")
    print(f"  Well-formed: {zeta.is_well_formed}")
    print()

    # Product
    prod = datum_product(zeta, chi4)
    print(f"ζ × χ₋₄ = {prod}")
    print(f"  η(ζ) + η(χ₋₄) = {spectral_entropy(zeta)} + {spectral_entropy(chi4)} = {spectral_entropy(zeta) + spectral_entropy(chi4)}")
    print(f"  η(product) = {spectral_entropy(prod)}")
    print(f"  Additive: {spectral_entropy(prod) == spectral_entropy(zeta) + spectral_entropy(chi4)}")
    print()

    # Counting
    shifts = [Fraction(0), Fraction(1, 2)]
    table = conductor_counting_table(1, 10, shifts)
    print("Conductor counting N₁(Q) for degree 1:")
    for Q, N in table:
        print(f"  Q={Q:2d}: N₁(Q) = {N}")
    print()

    # Encoding
    print(f"Encoding of ζ: {encode_datum(zeta)}")
    print(f"Roundtrip: {decode_datum(encode_datum(zeta)) == zeta}")
