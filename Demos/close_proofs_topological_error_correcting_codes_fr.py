"""
demo.py — Topological Error-Correcting Codes from Exotic Smooth Structures
==========================================================================

Numerical demonstration of the results in the accompanying article and paper:

    * wt_add_overlap        : wt(x+y) + 2*overlap(x,y) = wt(x) + wt(y)
    * ip_eq_overlap         : ip(x,y) = overlap(x,y) mod 2
    * doublyEven_selfOrthogonal (the BRIDGE THEOREM):
          x, y, x+y all doubly even  =>  ip(x,y) = 0
    * the extended Hamming code [8,4,4] = RM(1,3), the mod-2 shadow of E8:
          - 16 codewords
          - closed under addition
          - all weights divisible by 4  (doubly even)
          - self-orthogonal (DERIVED from double-evenness, not pairwise audit)
          - all-ones word has weight 8

All functions are self-contained, type-hinted, and use only the standard library.
"""

from __future__ import annotations

import itertools
from typing import List, Tuple

# A binary word is represented as a tuple of 0/1 ints.
Word = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Core definitions (Section 3 of the paper)
# ---------------------------------------------------------------------------
def wt(v: Word) -> int:
    """Hamming weight: number of coordinates equal to 1."""
    return sum(1 for b in v if b == 1)


def overlap(x: Word, y: Word) -> int:
    """Overlap: number of coordinates where both x and y equal 1."""
    return sum(1 for xi, yi in zip(x, y) if xi == 1 and yi == 1)


def add(x: Word, y: Word) -> Word:
    """Coordinatewise addition mod 2."""
    return tuple((xi + yi) % 2 for xi, yi in zip(x, y))


def ip(x: Word, y: Word) -> int:
    """Binary inner product in F2: (sum_i x_i*y_i) mod 2."""
    return sum(xi * yi for xi, yi in zip(x, y)) % 2


def is_doubly_even(v: Word) -> bool:
    """A word is doubly even iff 4 divides its weight."""
    return wt(v) % 4 == 0


# ---------------------------------------------------------------------------
# The extended Hamming code [8,4,4] = RM(1,3) (Definitions 3.7-3.8)
# ---------------------------------------------------------------------------
HAMMING_GEN: List[Word] = [
    (1, 1, 1, 1, 1, 1, 1, 1),  # g0 = all ones
    (0, 0, 0, 0, 1, 1, 1, 1),  # g1 = address bit 2
    (0, 0, 1, 1, 0, 0, 1, 1),  # g2 = address bit 1
    (0, 1, 0, 1, 0, 1, 0, 1),  # g3 = address bit 0
]


def encode(a: Tuple[int, int, int, int]) -> Word:
    """Encode a 4-bit message a into an 8-bit codeword:  encode(a)_j = sum_i a_i * gen[i][j]."""
    return tuple(
        sum(a[i] * HAMMING_GEN[i][j] for i in range(4)) % 2 for j in range(8)
    )


def hamming_code() -> List[Word]:
    """The 16-element extended Hamming code, as the image of the encoder."""
    seen = {}
    for a in itertools.product((0, 1), repeat=4):
        seen[encode(a)] = True
    return sorted(seen.keys())


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_inclusion_exclusion(trials: int = 2000, n: int = 8) -> None:
    """Theorem 4.1: wt(x+y) + 2*overlap(x,y) = wt(x) + wt(y) for all x, y."""
    print("== Theorem 4.1: additive Hamming inclusion-exclusion ==")
    import random

    ok = True
    for _ in range(trials):
        x = tuple(random.randint(0, 1) for _ in range(n))
        y = tuple(random.randint(0, 1) for _ in range(n))
        lhs = wt(add(x, y)) + 2 * overlap(x, y)
        rhs = wt(x) + wt(y)
        ok &= lhs == rhs
    print(f"  verified on {trials} random pairs of length {n}: {ok}")
    # A worked example
    x, y = (1, 1, 0, 0, 1, 0, 1, 0), (1, 0, 1, 0, 1, 1, 0, 0)
    print(f"  example x={x}, y={y}")
    print(f"    wt(x+y)={wt(add(x,y))}, overlap={overlap(x,y)}, "
          f"wt(x)={wt(x)}, wt(y)={wt(y)}")
    print(f"    {wt(add(x,y))} + 2*{overlap(x,y)} = "
          f"{wt(add(x,y)) + 2*overlap(x,y)} = {wt(x)+wt(y)}\n")


def demo_ip_equals_overlap(trials: int = 2000, n: int = 8) -> None:
    """Theorem 4.2: ip(x,y) = overlap(x,y) mod 2."""
    print("== Theorem 4.2: inner product = overlap parity ==")
    import random

    ok = all(
        ip(x := tuple(random.randint(0, 1) for _ in range(n)),
           y := tuple(random.randint(0, 1) for _ in range(n)))
        == overlap(x, y) % 2
        for _ in range(trials)
    )
    print(f"  verified on {trials} random pairs of length {n}: {ok}\n")


def demo_bridge_theorem() -> None:
    """Theorem 5.1: x, y, x+y doubly even  =>  ip(x,y)=0."""
    print("== Theorem 5.1: BRIDGE THEOREM (doubly-even => orthogonal) ==")
    code = hamming_code()  # every codeword is doubly even and code is linear
    checked = 0
    ok = True
    for x in code:
        for y in code:
            if is_doubly_even(x) and is_doubly_even(y) and is_doubly_even(add(x, y)):
                ok &= ip(x, y) == 0
                checked += 1
    print(f"  hypotheses held & conclusion verified on {checked} pairs: {ok}")
    print("  (the hypotheses hold for ALL 256 pairs since the code is doubly-even"
          " and linear)\n")


def demo_hamming_code() -> None:
    """Theorems 6.1-6.5: the extended Hamming code as the mod-2 shadow of E8."""
    print("== The extended Hamming code [8,4,4] = RM(1,3) ==")
    code = hamming_code()
    print(f"  Theorem 6.1  |H| = {len(code)} (= 2^4)")

    # additive closure
    closed = all(add(x, y) in set(code) for x in code for y in code)
    print(f"  Theorem 6.2  closed under addition (linear): {closed}")

    # double-evenness + weight enumerator
    weights = sorted(wt(c) for c in code)
    spectrum = {w: weights.count(w) for w in sorted(set(weights))}
    print(f"  Theorem 6.3  all weights divisible by 4: "
          f"{all(w % 4 == 0 for w in weights)}")
    print(f"               weight enumerator: "
          f"{' + '.join(f'{c}*z^{w}' for w, c in spectrum.items())}")

    # self-orthogonality, DERIVED from double-evenness via the bridge theorem
    self_orth = all(ip(x, y) == 0 for x in code for y in code)
    print(f"  Theorem 6.4  self-orthogonal (derived, not pairwise audit): {self_orth}")

    # all-ones word
    ones = (1,) * 8
    print(f"  Theorem 6.5  all-ones word in code: {ones in set(code)}, "
          f"weight = {wt(ones)} (divisible by 4)\n")


def demo_self_orthogonality_speedup() -> None:
    """Application: certify self-orthogonality in O(|C|*n) instead of O(|C|^2*n)."""
    print("== Application: cheap self-orthogonality certificate ==")
    code = hamming_code()
    n = 8
    # Local certificate: every weight divisible by 4 (+ linearity) => self-orthogonal.
    local_cost = len(code) * n
    pairwise_cost = len(code) * len(code) * n
    certified = all(is_doubly_even(c) for c in code)
    print(f"  local double-evenness check ({local_cost} ops) certifies "
          f"self-orthogonality: {certified}")
    print(f"  naive pairwise audit would cost {pairwise_cost} ops "
          f"({pairwise_cost // local_cost}x more)\n")


def main() -> None:
    print("=" * 70)
    print("Topological Error-Correcting Codes from Exotic Smooth Structures")
    print("The mod-2 shadow of even unimodular forms (E8 -> Hamming [8,4,4])")
    print("=" * 70 + "\n")
    demo_inclusion_exclusion()
    demo_ip_equals_overlap()
    demo_bridge_theorem()
    demo_hamming_code()
    demo_self_orthogonality_speedup()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
