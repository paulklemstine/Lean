"""
Tropical weight enumerator profiles for binary linear codes.

This self-contained script demonstrates the main results of the package:

  1. The tropical weight enumerator  twe_C(t) = min_{c in C} wt(c) * t.
  2. Tropical additivity under direct sum:  twe_{C(+)D} = twe_C + twe_D.
  3. The minimum distance as a tropical-min invariant:
        d(C (+) D) = min(d(C), d(D)).
  4. The information-loss phenomenon on the extended Hamming [8,4,4] code:
        twe_Hamming(t) = min(0, 8t)  --  the weight-4 stratum is erased
        because 4 is not a vertex of the convex hull of the spectrum {0,4,8}.

All codes are represented as lists of binary tuples; everything is inlined.
Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

Codeword = Tuple[int, ...]
Code = List[Codeword]


# --------------------------------------------------------------------------
# Core combinatorial primitives (mirrors of the Lean definitions)
# --------------------------------------------------------------------------

def weight(c: Codeword) -> int:
    """Hamming weight: number of nonzero (== 1) coordinates of a binary vector."""
    return sum(1 for x in c if x % 2 == 1)


def append_codewords(a: Codeword, b: Codeword) -> Codeword:
    """Concatenation a ++ b used in the direct sum of codes."""
    return tuple(a) + tuple(b)


def direct_sum(C: Code, D: Code) -> Code:
    """Direct sum (coordinate concatenation):  C (+) D = { a ++ b : a in C, b in D }."""
    return [append_codewords(a, b) for a in C for b in D]


def twe(C: Code, t: float) -> float:
    """Tropical weight enumerator  twe_C(t) = min_{c in C} wt(c) * t."""
    return min(weight(c) * t for c in C)


def weight_spectrum(C: Code) -> List[int]:
    """The sorted set of weights actually occurring in the code."""
    return sorted({weight(c) for c in C})


def min_distance(C: Code) -> int:
    """Minimum distance: least weight of a nonzero codeword."""
    nonzero = [weight(c) for c in C if any(x % 2 == 1 for x in c)]
    if not nonzero:
        raise ValueError("code has no nonzero codeword")
    return min(nonzero)


def hull_vertices(spectrum: List[int]) -> List[int]:
    """
    Slopes that actually survive in twe: for lines through the origin the only
    surviving slopes are the extreme weights (vertices of the 1-D convex hull).
    """
    if not spectrum:
        return []
    return sorted({min(spectrum), max(spectrum)})


# --------------------------------------------------------------------------
# The extended Hamming [8,4,4] code (RM(1,3))
# --------------------------------------------------------------------------

HAMMING_GEN: List[Codeword] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def encode(a: Tuple[int, int, int, int]) -> Codeword:
    """Encoder a |-> sum_i a_i * gen_i  (mod 2)."""
    return tuple(
        sum(a[i] * HAMMING_GEN[i][j] for i in range(4)) % 2 for j in range(8)
    )


def hamming_code() -> Code:
    """The 16-codeword extended Hamming code as the image of the encoder."""
    return [encode(a) for a in product((0, 1), repeat=4)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_weight_enumerator(C: Code, name: str) -> None:
    print(f"--- Weight enumerator of {name} ---")
    counts = {}
    for c in C:
        counts[weight(c)] = counts.get(weight(c), 0) + 1
    terms = " + ".join(
        (f"{m}*y^{w}" if w else f"{m}") for w, m in sorted(counts.items())
    )
    print(f"  |C| = {len(C)}")
    print(f"  spectrum   = {weight_spectrum(C)}")
    print(f"  W_C        = {terms}")
    print(f"  d(C)       = {min_distance(C)}")
    print()


def demo_tropical_additivity(C: Code, D: Code) -> None:
    print("--- Tropical additivity:  twe_{C(+)D}(t) = twe_C(t) + twe_D(t) ---")
    S = direct_sum(C, D)
    print(f"  |C| = {len(C)}, |D| = {len(D)}, |C(+)D| = {len(S)} (= {len(C)}*{len(D)})")
    print(f"  {'t':>6} | {'twe_C':>8} {'twe_D':>8} {'sum':>8} | {'twe_(C+D)':>10} match")
    ok = True
    for t in (-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0):
        lhs = twe(S, t)
        rhs = twe(C, t) + twe(D, t)
        match = abs(lhs - rhs) < 1e-9
        ok = ok and match
        print(f"  {t:6.1f} | {twe(C,t):8.2f} {twe(D,t):8.2f} {rhs:8.2f} "
              f"| {lhs:10.2f} {'OK' if match else 'FAIL'}")
    print(f"  ==> additivity holds for all tested slopes: {ok}\n")


def demo_min_distance_tropical(C: Code, D: Code) -> None:
    print("--- Minimum distance is tropical-min:  d(C(+)D) = min(d(C), d(D)) ---")
    S = direct_sum(C, D)
    dc, dd, ds = min_distance(C), min_distance(D), min_distance(S)
    print(f"  d(C) = {dc}, d(D) = {dd}, min = {min(dc, dd)}")
    print(f"  d(C(+)D) = {ds}   match: {ds == min(dc, dd)}\n")


def demo_information_loss(C: Code, name: str) -> None:
    print(f"--- Information loss on {name} ---")
    spec = weight_spectrum(C)
    verts = hull_vertices(spec)
    erased = [w for w in spec if w not in verts and w != 0]
    print(f"  full spectrum (classical W_C sees): {spec}")
    print(f"  surviving slopes (twe sees)       : {verts}")
    print(f"  ERASED interior weights           : {erased}")
    print("  twe profile: twe(t) = min over surviving slopes of (slope * t)")
    print(f"    for {name}: twe(t) = min(0, {max(spec)}*t)")
    print(f"  minimum distance d = {min_distance(C)} is "
          f"{'INVISIBLE to twe' if min_distance(C) in erased else 'a hull vertex'}\n")


def main() -> None:
    print("=" * 70)
    print("Tropical weight enumerator profiles for binary linear codes")
    print("=" * 70 + "\n")

    H = hamming_code()
    rep = [(0, 0, 0), (1, 1, 1)]  # length-3 repetition code, spectrum {0,3}

    demo_weight_enumerator(H, "extended Hamming [8,4,4]")
    demo_weight_enumerator(rep, "repetition code [3,1,3]")

    demo_tropical_additivity(H, H)
    demo_tropical_additivity(H, rep)

    demo_min_distance_tropical(H, H)

    demo_information_loss(H, "Hamming [8,4,4]")
    demo_information_loss(rep, "repetition [3,1,3]")

    # Hamming (+) Hamming = mod-2 shadow of E8 + E8
    HH = direct_sum(H, H)
    print("--- Headline: Hamming (+) Hamming (mod-2 shadow of E8 + E8) ---")
    print(f"  |HH| = {len(HH)} (= 256), length 16")
    print(f"  d(HH) = {min_distance(HH)} (stays 4 under gluing)")
    print(f"  twe_HH(1) = {twe(HH, 1.0)}, twe_HH(-1) = {twe(HH, -1.0)}")
    print("  profile: twe_HH(t) = min(0, 16*t) = 2 * min(0, 8*t)")


if __name__ == "__main__":
    main()
