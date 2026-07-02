"""
Combinatorics of the Universal Library --- numerical demonstrations.

This self-contained script demonstrates the four exact combinatorial facts
about the universal library L(A, L), the set of all strings of length L over
an alphabet of size A:

  1. Population count:          |L(A, L)| = A^L
  2. Meaning-density bound:     P(w) <= (L - m + 1) * A^{-m}
  3. Self-cataloging limit:     A^L < 2^{A^L}  (no single volume catalogs all)
  4. Distributed threshold:     minimum complete catalog size = A^L
  5. Optimal code tour:         de Bruijn length = A^k + k - 1

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. Population count:  |L(A, L)| = A^L
# ---------------------------------------------------------------------------
def population(alphabet_size: int, book_length: int) -> int:
    """Return the exact number of volumes in the universal library L(A, L)."""
    return alphabet_size ** book_length


def num_decimal_digits_of_power(alphabet_size: int, book_length: int) -> int:
    """Return the number of decimal digits of A^L without materializing it,
    via digits = floor(L * log10(A)) + 1."""
    from math import log10, floor
    return floor(book_length * log10(alphabet_size)) + 1


# ---------------------------------------------------------------------------
# 2. Meaning-density bound:  P(w) <= (L - m + 1) * A^{-m}
# ---------------------------------------------------------------------------
def meaning_density_bound(
    alphabet_size: int, book_length: int, passage_length: int
) -> Fraction:
    """Exact union-bound fraction (L - m + 1) * A^{-m} of volumes containing
    a fixed passage of length m. The prefactor is the placement count."""
    placements = book_length - passage_length + 1
    return Fraction(placements, alphabet_size ** passage_length)


def exact_meaning_density(
    alphabet_size: int, book_length: int, passage: Tuple[int, ...]
) -> Fraction:
    """Brute-force the TRUE fraction of volumes of length `book_length` over
    an alphabet {0, ..., A-1} that contain `passage` as a contiguous block.
    Feasible only for tiny parameters; validates the union bound."""
    m = len(passage)
    total = alphabet_size ** book_length
    count = 0
    for volume in product(range(alphabet_size), repeat=book_length):
        for i in range(book_length - m + 1):
            if volume[i : i + m] == passage:
                count += 1
                break
    return Fraction(count, total)


# ---------------------------------------------------------------------------
# 3 & 4. Cataloging: A^L < 2^{A^L}; minimum distributed catalog = A^L
# ---------------------------------------------------------------------------
def catalog_report(alphabet_size: int, book_length: int) -> Dict[str, int]:
    """Report population, whether A^L < 2^{A^L} holds, and the minimum
    complete distributed-catalog size (which equals the population)."""
    pop = population(alphabet_size, book_length)
    # The number of catalogs is 2^pop; the strict inequality pop < 2^pop holds
    # for every pop >= 1 (n < 2^n by induction), so we assert it without ever
    # materializing the astronomically large 2^pop.
    return {
        "population": pop,
        "num_catalogs_is_larger": pop >= 1,  # equivalent to pop < 2^pop
        "min_distributed_catalog_size": pop,
    }


# ---------------------------------------------------------------------------
# 5. Optimal single-volume code tour: de Bruijn length A^k + k - 1
# ---------------------------------------------------------------------------
def de_bruijn_length(alphabet_size: int, order: int) -> int:
    """Length of the linear expansion of an order-k de Bruijn sequence:
    the shortest volume exhibiting every length-k code exactly once."""
    return alphabet_size ** order + order - 1


def de_bruijn_sequence(alphabet_size: int, order: int) -> List[int]:
    """Construct a de Bruijn sequence B(A, k) over the alphabet
    {0, ..., A-1} via an Eulerian circuit (Hierholzer) on the de Bruijn
    graph, returned as its length-(A^k + k - 1) linear expansion."""
    a, k = alphabet_size, order
    # Edges are k-codes; walk an Eulerian circuit on (k-1)-code vertices.
    graph: Dict[Tuple[int, ...], List[int]] = {}
    for vertex in product(range(a), repeat=k - 1):
        graph[vertex] = list(range(a))  # out-edges labelled by next symbol

    circuit: List[int] = []
    stack: List[Tuple[int, ...]] = [tuple([0] * (k - 1))]
    path: List[int] = []
    while stack:
        v = stack[-1]
        if graph[v]:
            symbol = graph[v].pop()
            stack.append(v[1:] + (symbol,))
            path.append(symbol)
        else:
            stack.pop()
            if path:
                circuit.append(path.pop())

    circuit.reverse()
    # circuit has length A^k (cyclic); linearize by appending first k-1 symbols.
    seq = circuit + circuit[: k - 1]
    return seq


def verify_de_bruijn(seq: List[int], alphabet_size: int, order: int) -> bool:
    """Check that `seq` exhibits every length-`order` code exactly once."""
    a, k = alphabet_size, order
    seen = {}
    for i in range(len(seq) - k + 1):
        block = tuple(seq[i : i + k])
        seen[block] = seen.get(block, 0) + 1
    all_codes = set(product(range(a), repeat=k))
    return set(seen.keys()) == all_codes and all(v == 1 for v in seen.values())


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("THE LIBRARY OF BABEL --- Combinatorics of the Universal Library")
    print("=" * 70)

    # --- Fact 1: population -------------------------------------------------
    print("\n[1] Population count |L(A, L)| = A^L")
    A_toy, L_toy = 4, 16
    print(f"    Toy library (A={A_toy}, L={L_toy}): "
          f"{population(A_toy, L_toy):,} volumes  (= 2^32)")
    A_b, L_b = 25, 1_312_000
    print(f"    Borges library (A={A_b}, L={L_b:,}): "
          f"a number with {num_decimal_digits_of_power(A_b, L_b):,} "
          f"decimal digits")

    # --- Fact 2: meaning density -------------------------------------------
    print("\n[2] Meaning-density bound  P(w) <= (L - m + 1) * A^{-m}")
    # Brute-force validation on a small enumerable sub-library (A=4, L=8).
    A_enum, L_enum, m = 4, 8, 2
    bound = meaning_density_bound(A_enum, L_enum, m)
    passage = (1, 2)
    true_frac = exact_meaning_density(A_enum, L_enum, passage)
    print(f"    A={A_enum}, L={L_enum}, passage length m={m} "
          f"(enumerable sub-library)")
    print(f"    Union bound        : {bound}  (~{float(bound):.6f})")
    print(f"    True fraction (enum): {true_frac}  (~{float(true_frac):.6f})")
    print(f"    Bound holds and is tight up to overlap: "
          f"{true_frac <= bound}")
    # Borges-scale illustration for a 50-char sentence.
    b50 = meaning_density_bound(25, 1_312_000, 50)
    print(f"    Borges: fixed 50-char sentence appears in <= "
          f"{float(b50):.3e} of all volumes")

    # --- Facts 3 & 4: cataloging ------------------------------------------
    print("\n[3,4] Cataloging limits")
    rep = catalog_report(A_toy, L_toy)
    print(f"    Toy population A^L = {rep['population']:,}")
    print(f"    A^L < 2^(A^L) (no self-cataloging volume): "
          f"{rep['num_catalogs_is_larger']}")
    print(f"    Minimum complete distributed catalog size = A^L = "
          f"{rep['min_distributed_catalog_size']:,}")

    # --- Fact 5: de Bruijn tour -------------------------------------------
    print("\n[5] Optimal code tour  (de Bruijn length A^k + k - 1)")
    for A, k in [(4, 2), (2, 3), (3, 2)]:
        seq = de_bruijn_sequence(A, k)
        ok = verify_de_bruijn(seq, A, k)
        print(f"    A={A}, k={k}: length {len(seq)} "
              f"(formula {de_bruijn_length(A, k)}), "
              f"every {A**k} codes once: {ok}")
    print("    Example (A=4, k=2):",
          " ".join(map(str, de_bruijn_sequence(4, 2))))

    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
