"""
The Last Theorem: numerical demonstrations.

Self-contained numerical illustrations of the core results:

  1. Shortlex enumeration of finite strings over a finite alphabet, realizing the
     bijection N -> Sigma* that witnesses countability of the set of theorems.
  2. Collapse of the discoverable fraction: a fixed finite discovered count N,
     divided by the growing enumeration index n, tends to zero.
  3. Bekenstein-Hawking storage: a black hole of mass M stores I(M) ~ M^2 bits.
  4. Quadratic-beats-linear crossover: the area law overtakes a linear budget at
     an explicit crossover mass M* = beta / gamma.

Run with:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import itertools
import math
from typing import Iterator, List, Tuple

# --------------------------------------------------------------------------
# Physical constants (SI units)
# --------------------------------------------------------------------------
G: float = 6.674e-11        # gravitational constant  [m^3 kg^-1 s^-2]
HBAR: float = 1.0546e-34    # reduced Planck constant [J s]
C: float = 2.998e8          # speed of light          [m s^-1]
LN2: float = math.log(2.0)

# Cosmological operation budget before heat death (order-of-magnitude).
N_MAX: float = 1e120

# Solar mass [kg].
M_SUN: float = 1.989e30


# --------------------------------------------------------------------------
# 1. Shortlex enumeration of Sigma* (witness of countability)
# --------------------------------------------------------------------------
def shortlex_enumeration(alphabet: str) -> Iterator[str]:
    """Yield every finite string over `alphabet` exactly once, in shortlex order.

    Shortlex = ordered first by length, then lexicographically within a length.
    This is an explicit bijection N -> Sigma*, so it demonstrates that the set of
    finite strings (hence the set of theorems, a subset) is countable.
    """
    length = 0
    while True:
        for tup in itertools.product(alphabet, repeat=length):
            yield "".join(tup)
        length += 1


def first_n_strings(alphabet: str, n: int) -> List[str]:
    """Return the first `n` strings in shortlex order over `alphabet`."""
    gen = shortlex_enumeration(alphabet)
    return [next(gen) for _ in range(n)]


# --------------------------------------------------------------------------
# 2. Discoverable fraction collapse
# --------------------------------------------------------------------------
def discoverable_fraction(discovered_count: float, enumeration_index: float) -> float:
    """Fraction of the first `enumeration_index` theorems that a process with a
    fixed `discovered_count` budget has exhibited.

    Once the enumeration index exceeds the budget, the fraction is
    discovered_count / enumeration_index, which tends to 0 as the index grows.
    """
    if enumeration_index <= 0:
        return 0.0
    return min(discovered_count, enumeration_index) / enumeration_index


# --------------------------------------------------------------------------
# 3. Bekenstein-Hawking storage law  I(M) = gamma * M^2  (bits)
# --------------------------------------------------------------------------
def gamma_coefficient() -> float:
    """Coefficient gamma in I(M) = gamma * M^2, from Bekenstein-Hawking entropy.

        S_BH = (4 pi k_B G / (hbar c)) M^2 ,   I = S / (k_B ln 2)
     => I(M) = (4 pi G / (hbar c ln 2)) M^2 .
    """
    return 4.0 * math.pi * G / (HBAR * C * LN2)


def black_hole_bits(mass_kg: float) -> float:
    """Number of bits storable on a Schwarzschild black hole of the given mass."""
    return gamma_coefficient() * mass_kg ** 2


# --------------------------------------------------------------------------
# 4. Quadratic-beats-linear crossover mass  M* = beta / gamma
# --------------------------------------------------------------------------
def crossover_mass(beta: float, gamma: float) -> float:
    """Mass at which area law gamma*M^2 overtakes linear budget beta*M."""
    return beta / gamma


def storage_regime(mass_kg: float, beta: float, gamma: float) -> str:
    """Classify which storage law dominates at a given mass."""
    m_star = crossover_mass(beta, gamma)
    if mass_kg > m_star:
        return "enumeration-limited (area law dominates)"
    if math.isclose(mass_kg, m_star):
        return "crossover"
    return "budget-limited (linear budget dominates)"


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("1. Shortlex enumeration of finite strings (countability witness)")
    print("=" * 68)
    alphabet = "01"
    strings = first_n_strings(alphabet, 12)
    for idx, s in enumerate(strings):
        print(f"   t_{idx:<2} = {s!r}")
    print("   ... every finite string appears at some finite index.\n")

    print("=" * 68)
    print("2. Discoverable fraction collapses to zero")
    print("=" * 68)
    budget_exp = 120  # log10 of the fixed budget N_MAX
    for exp in (60, 120, 180, 240, 360):
        # discovered/all = min(budget, n)/n; work with log10 to avoid overflow.
        frac_log10 = min(0, budget_exp - exp)
        print(f"   n = 1e{exp:<3}   discovered/all = 1e{frac_log10}")
    print("   As n -> infinity with fixed budget, the fraction -> 0.\n")

    print("=" * 68)
    print("3. Bekenstein-Hawking storage  I(M) ~ M^2")
    print("=" * 68)
    print(f"   gamma = {gamma_coefficient():.3e} bits / kg^2")
    for label, mass in [
        ("solar-mass BH", M_SUN),
        ("1e6 solar masses", 1e6 * M_SUN),
        ("1e9 solar masses (SMBH)", 1e9 * M_SUN),
    ]:
        print(f"   {label:<26} M = {mass:.3e} kg -> {black_hole_bits(mass):.3e} bits")
    print("   Vast, finite -> still density zero within the countable set T.\n")

    print("=" * 68)
    print("4. Quadratic-beats-linear crossover")
    print("=" * 68)
    gamma = gamma_coefficient()
    beta = 1e60  # illustrative fixed linear budget [bits / kg]
    m_star = crossover_mass(beta, gamma)
    print(f"   linear coefficient beta = {beta:.1e} bits/kg")
    print(f"   crossover mass M* = beta/gamma = {m_star:.3e} kg")
    for mass in (0.1 * m_star, m_star, 10 * m_star):
        print(f"   M = {mass:.3e} kg -> {storage_regime(mass, beta, gamma)}")
    print("\n   Beyond M*, storage grows quadratically -- yet for every finite M")
    print("   the stored set is finite, so the discoverable fraction stays 0.")


if __name__ == "__main__":
    main()
