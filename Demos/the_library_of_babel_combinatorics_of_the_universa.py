"""
The Library of Babel: numerical demonstrations of the main theorems.

Self-contained (standard library only). Each function is inlined and type-hinted.
The demos exercise the *main theorems*, not trivial special cases:

  * card_volume / card_library      -> b^L count
  * universalCatalog                -> base-b encode/decode bijection
  * prob_singleton                  -> b^(-L)
  * expected_substring_count        -> (L-k+1) * b^(-k)
  * prob_contains_substring_bound   -> P(contains) <= (L-k+1) * b^(-k)
  * window_bijective / every_address_once / catalog_complete / catalog_no_repeats
                                    -> the explicit de Bruijn B(4,2) catalog
  * no_single_complete_catalog      -> b^L < 2^(b^L)
  * distributed_catalog_iff         -> 2^(b^L) <= (b^L)^N
  * single_volume_below_threshold   -> N=1 never satisfies the threshold
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import log, log2
from typing import Iterator


# ---------------------------------------------------------------------------
# Enumeration: card_volume / card_library and the universal catalog bijection
# ---------------------------------------------------------------------------

def library_size(b: int, length: int) -> int:
    """Number of volumes of given length over a b-symbol alphabet: b^length."""
    return b ** length


def encode_volume(volume: tuple[int, ...], b: int) -> int:
    """universalCatalog: read a volume as a base-b numeral (address)."""
    address = 0
    for i, symbol in enumerate(volume):
        address += symbol * (b ** i)
    return address


def decode_address(address: int, b: int, length: int) -> tuple[int, ...]:
    """Inverse of encode_volume: expand an address into a length-`length` volume."""
    digits: list[int] = []
    for _ in range(length):
        digits.append(address % b)
        address //= b
    return tuple(digits)


def demo_enumeration_and_catalog() -> None:
    print("=" * 70)
    print("ENUMERATION + UNIVERSAL CATALOG (Thm 1, Thm 2)")
    print("=" * 70)
    b, length = 4, 3
    n = library_size(b, length)
    print(f"alphabet b={b}, length L={length}  ->  b^L = {n} volumes")

    # Verify the encode/decode round trip is a genuine bijection on ALL volumes.
    seen: set[int] = set()
    ok = True
    for volume in product(range(b), repeat=length):
        a = encode_volume(volume, b)
        if decode_address(a, b, length) != volume:
            ok = False
        seen.add(a)
    print(f"encode/decode round-trip exact for all {n} volumes: {ok}")
    print(f"addresses hit = {len(seen)} (== b^L means bijection): {len(seen) == n}")

    # Borges' real numbers.
    B, L = 25, 1_312_000
    print(f"\nBorges' library: 25^1312000 has ~{int(L * log10_25())} digits")
    print("=" * 70 + "\n")


def log10_25() -> float:
    from math import log10
    return log10(25)


# ---------------------------------------------------------------------------
# Probability: prob_singleton, expected_substring_count, containment bound
# ---------------------------------------------------------------------------

def prob_singleton(b: int, length: int) -> Fraction:
    """Probability of one fixed target volume: 1 / b^L = b^(-L)."""
    return Fraction(1, b ** length)


def expected_occurrences(b: int, length: int, k: int) -> Fraction:
    """Exact expected count of a fixed length-k pattern: (L-k+1) * b^(-k)."""
    if k > length:
        return Fraction(0)
    return Fraction(length - k + 1, b ** k)


def empirical_containment_probability(b: int, length: int,
                                      pattern: tuple[int, ...]) -> Fraction:
    """Brute-force exact P(random volume contains pattern) over all b^L volumes."""
    k = len(pattern)
    count = 0
    total = 0
    for volume in product(range(b), repeat=length):
        total += 1
        contains = any(volume[i:i + k] == pattern
                       for i in range(length - k + 1))
        if contains:
            count += 1
    return Fraction(count, total)


def demo_probability() -> None:
    print("=" * 70)
    print("PROBABILITY (Thm 3, 3a expected count, 3b containment bound)")
    print("=" * 70)
    b, length = 3, 6
    print(f"alphabet b={b}, length L={length}")
    print(f"prob_singleton = 1/b^L = {prob_singleton(b, length)} "
          f"= {float(prob_singleton(b, length)):.3e}")

    pattern = (1, 2)
    k = len(pattern)
    expected = expected_occurrences(b, length, k)
    empirical = empirical_containment_probability(b, length, pattern)
    print(f"\npattern {pattern}, k={k}")
    print(f"expected occurrences (exact) = (L-k+1)/b^k = {expected} "
          f"= {float(expected):.4f}")
    print(f"empirical P(contains)        = {empirical} = {float(empirical):.4f}")
    print(f"union-bound (L-k+1)/b^k      = {expected} = {float(expected):.4f}")
    print(f"bound holds  P(contains) <= bound : {empirical <= expected}")
    print("=" * 70 + "\n")


# ---------------------------------------------------------------------------
# Constructive cataloging: the explicit de Bruijn B(4,2) catalog volume
# ---------------------------------------------------------------------------

CAT: tuple[int, ...] = (0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3)


def window(i: int) -> tuple[int, int]:
    """The length-2 address read at cyclic position i of the catalog volume."""
    return (CAT[i % 16], CAT[(i + 1) % 16])


def demo_debruijn_catalog() -> None:
    print("=" * 70)
    print("de BRUIJN MINI-CATALOG B(4,2)  (Thm 6, Cor 7-9)")
    print("=" * 70)
    print(f"catalog volume (length {len(CAT)}): {CAT}")

    windows = [window(i) for i in range(16)]
    distinct = set(windows)
    all_addresses = set(product(range(4), repeat=2))

    print(f"\n  i  -> window(i)")
    for i in range(16):
        print(f" {i:2d}  -> {window(i)}")

    print(f"\ncatalog_no_repeats (injective): {len(distinct) == 16}")
    print(f"catalog_complete (surjective): {distinct == all_addresses}")
    print(f"window_bijective: {len(distinct) == 16 and distinct == all_addresses}")
    print(f"every_address_once: each of the {len(all_addresses)} addresses "
          f"appears exactly once: "
          f"{all(windows.count(a) == 1 for a in all_addresses)}")
    print("=" * 70 + "\n")


# ---------------------------------------------------------------------------
# Diagonal impossibility & distributed threshold
# ---------------------------------------------------------------------------

def single_volume_can_catalog_subcollections(b: int, length: int) -> bool:
    """no_single_complete_catalog: True iff b^L >= 2^(b^L) (always False)."""
    v = b ** length
    return v >= 2 ** v


def distributed_catalog_feasible(b: int, length: int, n_volumes: int) -> bool:
    """distributed_catalog_iff: an injective distributed catalog exists iff
    2^(b^L) <= (b^L)^N. Uses the overflow-safe logarithmic form for large inputs.
    """
    v = b ** length
    # 2^v <= v^N  <=>  v*log2 <= N*log(v)  (for v >= 2)
    if v < 2:
        return True
    return v * log(2) <= n_volumes * log(v)


def threshold_volumes(b: int, length: int) -> float:
    """Minimal N (real-valued) from N >= b^L / (L * log2(b))."""
    return (b ** length) / (length * log2(b))


def demo_diagonal_and_threshold() -> None:
    print("=" * 70)
    print("DIAGONAL WALL + DISTRIBUTED THRESHOLD (Thm 10, 11, Cor 12)")
    print("=" * 70)
    b, length = 2, 3
    v = b ** length
    print(f"alphabet b={b}, length L={length}: b^L = {v} volumes")
    print(f"sub-collections = 2^(b^L) = {2 ** v}")
    print(f"no_single_complete_catalog (b^L < 2^(b^L)): {v < 2 ** v}")
    print(f"single_volume_below_threshold (N=1 fails): "
          f"{not distributed_catalog_feasible(b, length, 1)}")

    print("\nDistributed feasibility 2^(b^L) <= (b^L)^N :")
    for n_volumes in range(1, 8):
        feas = distributed_catalog_feasible(b, length, n_volumes)
        # exact check for small numbers:
        exact = (2 ** v) <= (v ** n_volumes)
        print(f"  N={n_volumes}: feasible={feas}  (exact check={exact})")

    print(f"\nthreshold N >= b^L/(L*log2 b) = {threshold_volumes(b, length):.3f}")

    # Borges' figure (logarithmic, since b^L is astronomically large).
    B, L = 25, 1_312_000
    log10_threshold = L * log2(B) * 0.301029995  # ~ log10(25^L) minus tiny terms
    print(f"\nBorges b=25, L=1312000: a complete sub-collection catalog needs")
    print(f"  N >= 25^1312000 / (1312000 * log2 25), i.e. ~10^{int(L*log10_25()):d} volumes")
    print("=" * 70 + "\n")


def main() -> None:
    demo_enumeration_and_catalog()
    demo_probability()
    demo_debruijn_catalog()
    demo_diagonal_and_threshold()


if __name__ == "__main__":
    main()


"""Visualization: the de Bruijn graph B(4,2) and its Eulerian-circuit catalog.

Renders the 4-node de Bruijn graph (nodes 0..3, one directed edge per length-2
address) and overlays the catalog volume's Eulerian circuit, illustrating that
the single catalog word visits every address (edge) exactly once.
"""
from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

CAT: Tuple[int, ...] = (0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3)


def window(i: int) -> Tuple[int, int]:
    return (CAT[i % 16], CAT[(i + 1) % 16])


def node_pos(k: int) -> Tuple[float, float]:
    angle = math.pi / 2 - 2 * math.pi * k / 4
    return (math.cos(angle), math.sin(angle))


def main() -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    edges: List[Tuple[int, int]] = [window(i) for i in range(16)]

    for k in range(4):
        x, y = node_pos(k)
        ax.scatter([x], [y], s=1400, c="#1f3b73", zorder=3)
        ax.text(x, y, str(k), color="white", ha="center", va="center",
                fontsize=18, fontweight="bold", zorder=4)

    for step, (a, b) in enumerate(edges):
        xa, ya = node_pos(a)
        xb, yb = node_pos(b)
        color = plt.cm.viridis(step / 16)
        if a == b:  # self-loop
            ax.annotate("", xy=(xa * 1.18, ya * 1.18), xytext=(xa * 1.02, ya * 1.02),
                        arrowprops=dict(arrowstyle="->", color=color, lw=2,
                                        connectionstyle="arc3,rad=0.9"))
        else:
            arrow = FancyArrowPatch((xa, ya), (xb, yb), color=color, lw=2,
                                    arrowstyle="->", mutation_scale=18,
                                    connectionstyle="arc3,rad=0.18", zorder=2)
            ax.add_patch(arrow)

    ax.set_title("de Bruijn graph B(4,2): the catalog word walks every "
                 "address (edge) exactly once", fontsize=12)
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("debruijn_catalog.png", dpi=150)
    print("saved debruijn_catalog.png")


if __name__ == "__main__":
    main()
