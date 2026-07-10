"""
Numerical demonstrations of forced structure in symbolic sequences.

Two forcing phenomena are illustrated:

1. Linear forcing (pigeonhole block-repetition threshold): over a q-symbol
   alphabet there are only q**m distinct length-m blocks, so once more than
   q**m sliding windows are examined two must coincide. The threshold is sharp:
   de Bruijn sequences expose exactly q**m distinct windows before repeating.

2. Relational forcing (Ramsey R(3,3) <= 6): every symmetric two-coloring of the
   pairs among six objects contains a monochromatic triangle.

All functions are self-contained with type hints.
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# 1. Linear forcing: repeated m-mers along a sequence                          #
# --------------------------------------------------------------------------- #

DNA: str = "ACGT"


def mer(seq: Sequence[int], m: int, i: int) -> Tuple[int, ...]:
    """The length-m contiguous block (m-mer) of `seq` starting at position i."""
    return tuple(seq[i + j] for j in range(m))


def first_repeated_mer(
    seq: Sequence[int], m: int
) -> Optional[Tuple[int, int, Tuple[int, ...]]]:
    """Return (i, j, block) for the first repeated m-mer, or None if none exists.

    By the pigeonhole threshold, if the number of windows exceeds q**m a repeat
    is guaranteed; this loop returns it as early as it appears.
    """
    seen: Dict[Tuple[int, ...], int] = {}
    windows = len(seq) - m + 1
    for i in range(windows):
        block = mer(seq, m, i)
        if block in seen:
            return seen[block], i, block
        seen[block] = i
    return None


def distinct_mer_count(seq: Sequence[int], m: int, n_windows: int) -> int:
    """Number of distinct m-mers among the first `n_windows` window positions."""
    blocks = {mer(seq, m, i) for i in range(min(n_windows, len(seq) - m + 1))}
    return len(blocks)


def repeat_free_windows(seq: Sequence[int], m: int) -> int:
    """Largest prefix length of windows that are all distinct (repeat-free run)."""
    seen: Dict[Tuple[int, ...], int] = {}
    windows = len(seq) - m + 1
    for i in range(windows):
        block = mer(seq, m, i)
        if block in seen:
            return i  # windows 0..i-1 were distinct
        seen[block] = i
    return windows


def de_bruijn(q: int, m: int) -> List[int]:
    """A de Bruijn sequence B(q, m): a cyclic q-ary word of length q**m in which
    every length-m block occurs exactly once (Prefer-largest / FKM algorithm)."""
    a: List[int] = [0] * (q * m)
    out: List[int] = []

    def db(t: int, p: int) -> None:
        if t > m:
            if m % p == 0:
                out.extend(a[1 : p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for c in range(a[t - p] + 1, q):
                a[t] = c
                db(t + 1, t)

    db(1, 1)
    return out


def random_dna(length: int, seed: int = 0) -> List[int]:
    """A uniformly random nucleotide sequence of the given length."""
    rng = random.Random(seed)
    return [rng.randrange(4) for _ in range(length)]


# --------------------------------------------------------------------------- #
# 2. Relational forcing: Ramsey R(3,3) <= 6                                    #
# --------------------------------------------------------------------------- #

def monochromatic_triangle(
    color: List[List[bool]],
) -> Optional[Tuple[int, int, int, bool]]:
    """Given a symmetric 6x6 Boolean color matrix, return (a, b, d, x) for a
    monochromatic triangle of color x, following the fixed-vertex pigeonhole
    proof of R(3,3) <= 6. Never returns None for a valid 6-vertex coloring."""
    n = len(color)
    v = 0
    # Bucket v's neighbors by edge color.
    buckets: Dict[bool, List[int]] = {True: [], False: []}
    for k in range(n):
        if k != v:
            buckets[color[v][k]].append(k)
    for x, nbrs in buckets.items():
        if len(nbrs) >= 3:
            a, b, d = nbrs[0], nbrs[1], nbrs[2]
            # If any inner edge is color x, it closes an x-triangle with v.
            if color[a][b] == x:
                return (v, a, b, x)
            if color[a][d] == x:
                return (v, a, d, x)
            if color[b][d] == x:
                return (v, b, d, x)
            # Otherwise all inner edges are the opposite color -> {a,b,d} mono.
            return (a, b, d, not x)
    return None


def verify_ramsey_R33_exhaustive() -> bool:
    """Check ALL 2**15 symmetric two-colorings of K_6: each has a mono triangle."""
    pairs = list(itertools.combinations(range(6), 2))
    for bits in range(1 << len(pairs)):
        color = [[False] * 6 for _ in range(6)]
        for idx, (i, j) in enumerate(pairs):
            c = bool((bits >> idx) & 1)
            color[i][j] = c
            color[j][i] = c
        if monochromatic_triangle(color) is None:
            return False
    return True


def pentagon_coloring_on_five() -> List[List[bool]]:
    """The triangle-free two-coloring of K_5 witnessing R(3,3) > 5:
    color edge {i,j} True iff j - i is +/-1 mod 5 (the pentagon)."""
    color = [[False] * 5 for _ in range(5)]
    for i in range(5):
        for j in range(5):
            if i != j:
                d = (j - i) % 5
                color[i][j] = d in (1, 4)
    return color


def has_mono_triangle_general(color: List[List[bool]]) -> bool:
    """Brute-force: does the coloring have any monochromatic triangle?"""
    n = len(color)
    for a, b, d in itertools.combinations(range(n), 3):
        if color[a][b] == color[a][d] == color[b][d]:
            return True
    return False


# --------------------------------------------------------------------------- #
# Demonstration driver                                                         #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("1. LINEAR FORCING: repeated m-mers (q = 4, DNA)")
    print("=" * 70)

    # Tetramer threshold: 4**4 = 256, so 257 windows force a repeat.
    print(f"Number of possible tetramers 4^4 = {4 ** 4}")
    print("Threshold: any 257 consecutive windows contain a repeated tetramer.")
    seq = random_dna(257 + 3, seed=1)  # 257 full 4-mer windows
    rep = first_repeated_mer(seq, 4)
    assert rep is not None, "pigeonhole guarantees a repeat"
    i, j, block = rep
    letters = "".join(DNA[b] for b in block)
    print(f"  First repeated tetramer '{letters}' at positions {i} and {j}\n")

    # Hexamer corrected constant: 4**6 = 4096, need L >= 4102 raw bases.
    print(f"Number of possible hexamers 4^6 = {4 ** 6}")
    print("Threshold: 4097 windows force a repeated hexamer -> L >= 4102 bases.")
    seq6 = random_dna(4102, seed=2)
    rep6 = first_repeated_mer(seq6, 6)
    assert rep6 is not None
    print(f"  Repeated hexamer found (positions {rep6[0]}, {rep6[1]}).\n")

    print("=" * 70)
    print("2. SHARPNESS: de Bruijn sequences saturate the bound N <= q^m")
    print("=" * 70)
    for q, m in [(2, 3), (4, 2), (4, 3)]:
        db = de_bruijn(q, m)
        cyclic = db + db[: m - 1]  # unwrap the cycle to expose all q^m windows
        rf = repeat_free_windows(cyclic, m)
        print(f"  B({q},{m}): length {len(db)} = q^m = {q ** m}; "
              f"repeat-free windows = {rf} (= q^m).")
    print()

    print("=" * 70)
    print("3. RANDOM vs FORCED repetition")
    print("=" * 70)
    rand_seq = random_dna(4000, seed=7)
    rf_rand = repeat_free_windows(rand_seq, 4)
    print(f"  Random genome: first tetramer repeat after {rf_rand} windows "
          f"(upper limit {4 ** 4}).")
    # A low-complexity 'microsatellite' region repeats almost immediately.
    micro = ([0, 1] * 2000)  # 'ACACAC...' -> tetramer ACAC repeats at once
    rf_micro = repeat_free_windows(micro, 4)
    print(f"  Microsatellite (ACAC...): first tetramer repeat after "
          f"{rf_micro} windows -> heavily forced by biology.\n")

    print("=" * 70)
    print("4. RELATIONAL FORCING: Ramsey R(3,3) <= 6")
    print("=" * 70)
    ok = verify_ramsey_R33_exhaustive()
    print(f"  All 2^15 = 32768 symmetric two-colorings of K_6 checked: "
          f"every one has a monochromatic triangle -> {ok}")
    # Show the R(3,3) > 5 witness: the pentagon coloring of K_5 is triangle-free.
    penta = pentagon_coloring_on_five()
    print(f"  Pentagon two-coloring of K_5 has a monochromatic triangle? "
          f"{has_mono_triangle_general(penta)}  (False => R(3,3) > 5)")
    # A concrete K_6 example.
    example = [[bool((i + j) % 2) for j in range(6)] for i in range(6)]
    for i in range(6):
        example[i][i] = False
    tri = monochromatic_triangle(example)
    print(f"  Example K_6 coloring -> monochromatic triangle {tri}")


if __name__ == "__main__":
    main()
