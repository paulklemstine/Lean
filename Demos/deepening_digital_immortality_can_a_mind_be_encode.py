"""
Numerical demonstrations of the information cost of a connectome.

Core result: the minimum lossless worst-case description length of the wiring
diagram (connectome) of ``n`` neurons is exactly ``C(n, 2) = n(n-1)/2`` bits.
This module illustrates:

  * the exact quadratic bit cost and its growth,
  * the optimal adjacency encode/decode achieving the bound,
  * the pigeonhole / short-string counting behind incompressibility,
  * the Bekenstein-bound realizability constraint on physical minds.

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from itertools import combinations
from math import comb, isqrt, log
from typing import Dict, Iterable, List, Tuple

# --------------------------------------------------------------------------- #
# 1. Exact quadratic bit cost                                                 #
# --------------------------------------------------------------------------- #


def connectome_bits(n: int) -> int:
    """Minimum worst-case lossless description length, in bits, of a
    connectome on ``n`` neurons. Equals C(n, 2) = n(n-1)/2."""
    if n < 0:
        raise ValueError("n must be non-negative")
    return comb(n, 2)


def num_connectomes(n: int) -> int:
    """Number of distinct labeled connectomes on ``n`` neurons: 2^{C(n,2)}."""
    return 1 << connectome_bits(n)


# --------------------------------------------------------------------------- #
# 2. Optimal adjacency encode / decode (achieves the bound exactly)           #
# --------------------------------------------------------------------------- #

Edge = Tuple[int, int]


def pair_order(n: int) -> List[Edge]:
    """Fixed linear order on the C(n, 2) unordered pairs of neurons."""
    return list(combinations(range(n), 2))


def encode_connectome(n: int, edges: Iterable[Edge]) -> str:
    """Encode a connectome (given by its edge set) as a bit string of length
    exactly C(n, 2). This is the provably optimal worst-case code."""
    present = {tuple(sorted(e)) for e in edges}
    bits = ["1" if p in present else "0" for p in pair_order(n)]
    return "".join(bits)


def decode_connectome(n: int, code: str) -> List[Edge]:
    """Inverse of ``encode_connectome``; recovers the edge set losslessly."""
    order = pair_order(n)
    if len(code) != len(order):
        raise ValueError(f"expected {len(order)} bits, got {len(code)}")
    return [p for p, b in zip(order, code) if b == "1"]


# --------------------------------------------------------------------------- #
# 3. Counting behind incompressibility                                         #
# --------------------------------------------------------------------------- #


def num_strings_shorter_than(k: int) -> int:
    """Number of binary strings of length strictly less than k: 2^k - 1."""
    return (1 << k) - 1


def compressible_fraction_upper_bound(n: int, budget_bits: int) -> float:
    """Upper bound on the fraction of connectomes on n neurons that any single
    lossless code can map to a codeword of length <= budget_bits."""
    return num_strings_shorter_than(budget_bits + 1) / num_connectomes(n)


# --------------------------------------------------------------------------- #
# 4. Bekenstein realizability constraint                                       #
# --------------------------------------------------------------------------- #

HBAR = 1.054_571_817e-34  # reduced Planck constant, J*s
C_LIGHT = 2.997_924_58e8   # speed of light, m/s
LN2 = log(2.0)


def bekenstein_bits(radius_m: float, energy_j: float) -> float:
    """Maximum information (in bits) storable in a spherical region of the
    given radius (m) and total energy (J), per the Bekenstein bound."""
    return 2.0 * 3.141_592_653_589_793 * radius_m * energy_j / (HBAR * C_LIGHT * LN2)


def max_neurons_for_budget(budget_bits: float) -> int:
    """Largest n whose worst-case connectome (C(n,2) bits) fits in a physical
    information budget; grows like sqrt(budget)."""
    if budget_bits < 1:
        return 0
    # solve n(n-1)/2 <= B  ->  n <= (1 + sqrt(1 + 8B)) / 2
    return (1 + isqrt(1 + 8 * int(budget_bits))) // 2


# --------------------------------------------------------------------------- #
# Demonstration driver                                                         #
# --------------------------------------------------------------------------- #


def _demo() -> None:
    print("=" * 64)
    print("Exact quadratic bit cost  C(n,2)  and connectome count 2^C(n,2)")
    print("=" * 64)
    print(f"{'n':>4} | {'bits = C(n,2)':>14} | {'# connectomes':>20}")
    for n in range(2, 11):
        print(f"{n:>4} | {connectome_bits(n):>14} | {num_connectomes(n):>20}")

    print("\nDoubling n from 4 to 8: bits go", connectome_bits(4),
          "->", connectome_bits(8), "(~4x, the quadratic signature)")

    print("\n" + "=" * 64)
    print("Optimal adjacency encode / decode (round-trip is lossless)")
    print("=" * 64)
    n = 5
    triangle = [(0, 1), (1, 2), (0, 2)]  # a 3-cycle among neurons 0,1,2
    code = encode_connectome(n, triangle)
    recovered = decode_connectome(n, code)
    print(f"n = {n}, edges = {triangle}")
    print(f"code = {code}  (length {len(code)} = C({n},2) = {connectome_bits(n)})")
    print(f"decoded edges = {recovered}  -> lossless: {set(recovered) == set(triangle)}")

    print("\n" + "=" * 64)
    print("Incompressibility: fewer short strings than connectomes")
    print("=" * 64)
    for n in range(2, 7):
        k = connectome_bits(n)
        short = num_strings_shorter_than(k)
        total = num_connectomes(n)
        print(f"n={n}: strings shorter than {k} bits = {short}, "
              f"connectomes = {total}, deficit = {total - short}")

    print("\nFraction any code can compress below the threshold (<= b bits):")
    n = 6
    for g in range(0, 5):
        b = connectome_bits(n) - g
        frac = compressible_fraction_upper_bound(n, b - 1)
        print(f"  n={n}, budget b={b-1} bits (threshold - {g+1}): "
              f"<= {frac:.4f} of connectomes")

    print("\n" + "=" * 64)
    print("Bekenstein realizability constraint")
    print("=" * 64)
    # Rough parameters of a human brain: radius ~0.08 m, energy = m c^2 with m ~ 1.4 kg
    radius = 0.08
    mass = 1.4
    energy = mass * C_LIGHT ** 2
    budget = bekenstein_bits(radius, energy)
    print(f"Brain-scale region: R={radius} m, E={energy:.3e} J")
    print(f"Bekenstein capacity ~ {budget:.3e} bits")
    print(f"Max neurons whose worst-case wiring fits: ~ {max_neurons_for_budget(budget):.3e}")
    print("(Neuron count scales as the square root of the information budget.)")


if __name__ == "__main__":
    _demo()
