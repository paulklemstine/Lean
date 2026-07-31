#!/usr/bin/env python3
"""Numerical exploration of universal Witten-zeta leading residues.

Only the Python standard library is required.  The script evaluates the
universal gamma product, normalization scaling, representation-counting
constant, and proper-parabolic defect for several classical examples.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, factorial, gamma, lgamma, log, pi, sqrt
from typing import Iterable, Sequence


@dataclass(frozen=True)
class RootData:
    """Numerical root-system invariants used by the residue formula."""

    name: str
    rank: int
    coxeter: int
    proper_degrees: tuple[int, ...]
    weyl_order: int
    cartan_det: int

    def validate(self) -> None:
        if self.rank < 1 or self.coxeter <= 1:
            raise ValueError("rank must be positive and Coxeter number must exceed one")
        if len(self.proper_degrees) != self.rank - 1:
            raise ValueError("exactly rank - 1 proper invariant degrees are required")
        if any(not 0 < degree < self.coxeter for degree in self.proper_degrees):
            raise ValueError("proper degrees must lie strictly between zero and h")
        if self.weyl_order <= 0 or self.cartan_det <= 0:
            raise ValueError("Weyl order and Cartan determinant must be positive")


def critical_exponent(data: RootData) -> float:
    """Return the critical exponent 2/h."""
    data.validate()
    return 2.0 / data.coxeter


def gamma_quotient(data: RootData) -> float:
    """Evaluate the positive gamma quotient using log-gamma arithmetic."""
    data.validate()
    h = float(data.coxeter)
    log_value = sum(lgamma(1.0 - degree / h) for degree in data.proper_degrees)
    log_value -= data.rank * lgamma(1.0 - 1.0 / h)
    return exp(log_value)


def normalized_residue(data: RootData) -> float:
    """Evaluate the universal normalized leading residue."""
    prefactor = (
        2.0
        * (2.0 * pi) ** (data.rank / 2.0)
        * sqrt(data.cartan_det)
        / (data.coxeter * data.weyl_order)
    )
    return prefactor * gamma_quotient(data)


def ordinary_residue(data: RootData, normalization: float = 1.0) -> float:
    """Return the residue after the change zeta(s) = normalization**s xi(s)."""
    if normalization <= 0.0:
        raise ValueError("normalization must be positive")
    return normalization ** critical_exponent(data) * normalized_residue(data)


def counting_constant(data: RootData, normalization: float = 1.0) -> float:
    """Return A in the asymptotic N(X) ~ A X**(2/h)."""
    return data.coxeter / 2.0 * ordinary_residue(data, normalization)


def parabolic_defect(
    ambient_coxeter: float, components: Iterable[tuple[float, float]]
) -> float:
    """Compute sum r_a(1-h_a/h) for parabolic component pairs (r_a, h_a)."""
    if ambient_coxeter <= 0.0:
        raise ValueError("ambient Coxeter number must be positive")
    pairs = tuple(components)
    if not pairs:
        raise ValueError("at least one component is required")
    if any(rank <= 0.0 for rank, _ in pairs):
        raise ValueError("component ranks must be positive")
    return sum(rank * (1.0 - component_h / ambient_coxeter)
               for rank, component_h in pairs)


def type_a(rank: int) -> RootData:
    """Construct the invariants of the root system A_rank."""
    if rank < 1:
        raise ValueError("type A rank must be positive")
    h = rank + 1
    return RootData(
        name=f"A_{rank}",
        rank=rank,
        coxeter=h,
        proper_degrees=tuple(range(2, h)),
        weyl_order=factorial(h),
        cartan_det=h,
    )


def print_table(data_sets: Sequence[RootData], normalization: float = 1.0) -> None:
    """Print critical exponents, residues, and counting constants."""
    header = f"{'type':>6} {'2/h':>10} {'Q':>14} {'R_xi':>14} {'A':>14}"
    print(header)
    print("-" * len(header))
    for data in data_sets:
        print(
            f"{data.name:>6} {critical_exponent(data):10.6f} "
            f"{gamma_quotient(data):14.8g} {normalized_residue(data):14.8g} "
            f"{counting_constant(data, normalization):14.8g}"
        )


def main() -> None:
    examples = [type_a(rank) for rank in range(1, 6)]
    print("Universal residue data for type A (normalization K = 1):")
    print_table(examples)

    a4 = type_a(4)
    k = 2.5
    r_normalized = normalized_residue(a4)
    r_ordinary = ordinary_residue(a4, k)
    expected_ratio = k ** critical_exponent(a4)
    print("\nNormalization check for A_4:")
    print(f"  R_xi = {r_normalized:.12g}")
    print(f"  R_zeta = {r_ordinary:.12g}")
    print(f"  observed ratio = {r_ordinary / r_normalized:.12g}")
    print(f"  predicted K^(2/h) = {expected_ratio:.12g}")

    components = ((2.0, 3.0), (1.0, 2.0))
    defect = parabolic_defect(5.0, components)
    print("\nProper-parabolic defect example:")
    print(f"  h = 5, components = {components}, defect = {defect:.12g}")
    print(f"  strictly subcritical: {defect > 0.0}")

    # The rank-one formula simplifies exactly to one; floating arithmetic
    # should reproduce this identity to near machine precision.
    print("\nRank-one consistency check:")
    print(f"  R_A1 = {normalized_residue(type_a(1)):.16f}")


if __name__ == "__main__":
    main()
