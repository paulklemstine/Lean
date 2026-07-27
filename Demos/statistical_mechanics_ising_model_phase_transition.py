#!/usr/bin/env python3
"""Numerical demonstrations for finite Ising symmetry and related exact formulas.

The script uses only the Python standard library.  It demonstrates:
1. exact cancellation of signed magnetization on a finite periodic Ising ring;
2. agreement between direct enumeration and the transfer-matrix formula;
3. the square-lattice self-dual identities; and
4. decay of the geometric Peierls contour majorant.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import cosh, exp, log, sinh, sqrt, tanh
from typing import Iterable, Sequence

SpinConfiguration = tuple[int, ...]


@dataclass(frozen=True)
class EnsembleStatistics:
    """Thermodynamic statistics returned by direct finite enumeration."""

    partition: float
    mean_magnetization: float
    mean_absolute_magnetization: float
    mean_square_magnetization: float


def configurations(n: int) -> Iterable[SpinConfiguration]:
    """Generate all length-n configurations with spins in {-1,+1}."""
    if n <= 0:
        raise ValueError("n must be positive")
    return product((-1, 1), repeat=n)


def periodic_chain_energy(spins: Sequence[int]) -> int:
    """Return H=-sum_i s_i s_(i+1) for a periodic one-dimensional chain."""
    if not spins:
        raise ValueError("a spin configuration must be nonempty")
    if any(spin not in (-1, 1) for spin in spins):
        raise ValueError("every spin must be -1 or +1")
    return -sum(spins[i] * spins[(i + 1) % len(spins)] for i in range(len(spins)))


def magnetization(spins: Sequence[int]) -> int:
    """Return the total signed magnetization."""
    return sum(spins)


def enumerate_chain(n: int, beta: float, field: float = 0.0) -> EnsembleStatistics:
    """Enumerate a periodic chain using stable rescaled Boltzmann weights.

    The Hamiltonian with field is H=-sum s_i s_(i+1)-field*sum s_i.
    Runtime is O(n*2**n); auxiliary storage is O(2**n) in this transparent demo.
    """
    rows: list[tuple[float, int]] = []
    for spins in configurations(n):
        mag = magnetization(spins)
        energy = periodic_chain_energy(spins) - field * mag
        rows.append((-beta * energy, mag))

    shift = max(log_weight for log_weight, _ in rows)
    weighted = [(exp(log_weight - shift), mag) for log_weight, mag in rows]
    scaled_z = sum(weight for weight, _ in weighted)
    scale = exp(shift)
    mean_m = sum(weight * mag for weight, mag in weighted) / scaled_z
    mean_abs = sum(weight * abs(mag) for weight, mag in weighted) / scaled_z
    mean_sq = sum(weight * mag * mag for weight, mag in weighted) / scaled_z
    return EnsembleStatistics(scale * scaled_z, mean_m, mean_abs, mean_sq)


def transfer_partition(n: int, beta: float) -> float:
    """Evaluate Z_n=(2 cosh beta)^n+(2 sinh beta)^n for a periodic chain."""
    if n <= 0:
        raise ValueError("n must be positive")
    return (2.0 * cosh(beta)) ** n + (2.0 * sinh(beta)) ** n


def critical_parameters() -> tuple[float, float]:
    """Return the positive self-dual inverse temperature and its reciprocal."""
    beta_c = log(1.0 + sqrt(2.0)) / 2.0
    return beta_c, 1.0 / beta_c


def peierls_majorant(beta: float, minimum_length: int = 4) -> float:
    """Return sum_{L>=minimum_length} (3 exp(-2 beta))^L.

    Raises ValueError when the geometric series does not converge.
    """
    if minimum_length <= 0:
        raise ValueError("minimum_length must be positive")
    q = 3.0 * exp(-2.0 * beta)
    if q >= 1.0:
        raise ValueError("the contour majorant diverges because 3*exp(-2*beta) >= 1")
    return q**minimum_length / (1.0 - q)


def first_peierls_threshold(
    minimum_length: int = 4, target: float = 0.5, tolerance: float = 1e-12
) -> float:
    """Find the boundary beta where the geometric majorant equals target.

    Bisection is used on the monotone majorant.  The returned value is an
    approximate threshold; every larger beta makes the majorant smaller.
    """
    if target <= 0.0:
        raise ValueError("target must be positive")
    low = log(3.0) / 2.0
    high = max(1.0, low + 1.0)
    while peierls_majorant(high, minimum_length) >= target:
        high *= 2.0
    while high - low > tolerance:
        mid = (low + high) / 2.0
        if peierls_majorant(mid, minimum_length) < target:
            high = mid
        else:
            low = mid
    return high


def main() -> None:
    """Print a reproducible collection of numerical examples."""
    print("FINITE ZERO-FIELD SYMMETRY AND TRANSFER MATRIX")
    print("n  beta   <M>                  <|M|>       Z enum / Z transfer")
    for n in (4, 6, 8, 10):
        for beta in (0.2, 0.7, 1.4):
            stats = enumerate_chain(n, beta)
            closed = transfer_partition(n, beta)
            print(
                f"{n:2d} {beta:4.1f}  {stats.mean_magnetization:+.3e}  "
                f"{stats.mean_absolute_magnetization:10.6f}  "
                f"{stats.partition / closed:.12f}"
            )
    print("\nThe signed mean cancels, while the absolute mean grows at low temperature.")

    beta_c, temperature_c = critical_parameters()
    print("\nSELF-DUAL IDENTITIES")
    print(f"beta_c = {beta_c:.12f}")
    print(f"T_c    = {temperature_c:.12f} (between 2 and 3)")
    print(f"sinh(2 beta_c)       = {sinh(2.0 * beta_c):.12f}")
    print(f"tanh(beta_c)         = {tanh(beta_c):.12f}")
    print(f"exp(-2 beta_c)       = {exp(-2.0 * beta_c):.12f}")
    print(f"sqrt(2)-1            = {sqrt(2.0) - 1.0:.12f}")

    print("\nPEIERLS GEOMETRIC MAJORANT (minimum contour length 4)")
    threshold = first_peierls_threshold()
    print(f"Approximate beta where the majorant falls below 1/2: {threshold:.12f}")
    for beta in (0.8, 1.0, 1.2, 1.5, 2.0):
        bound = peierls_majorant(beta)
        implication = "positive if it bounds p" if bound < 0.5 else "criterion not met"
        print(f"beta={beta:3.1f}: bound={bound:.8f} — {implication}")

    print("\nSMALL SYMMETRY-BREAKING FIELD")
    for field in (0.0, 0.01, 0.05):
        stats = enumerate_chain(10, beta=1.2, field=field)
        print(f"field={field:4.2f}: <M>={stats.mean_magnetization: .8f}")


if __name__ == "__main__":
    main()
