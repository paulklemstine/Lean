"""
demo.py — The Code-Size Sandwich: Sphere-Packing and Gilbert–Varshamov Bounds.

This self-contained script demonstrates, with concrete numerical examples, the
elementary two-sided bounds on the size of a block error-correcting code over a
q-symbol alphabet of length n, using the Hamming metric.

Core objects
------------
  * Hamming distance:   number of coordinates in which two words differ.
  * Hamming ball V(t):  number of words within distance t of a fixed centre,
                        V(t) = sum_{i=0}^{t} C(n, i) * (q - 1)^i.

Bounds
------
  * Sphere-packing (Hamming) upper bound:  |C| * V(t) <= q^n      (min dist >= 2t+1)
  * Gilbert-Varshamov lower bound:         q^n <= |C| * V(d-1)    (C maximal d-code)
  * Code-size sandwich:                    |C|*V(t) <= q^n <= |C|*V(2t)
                                           (C maximal (2t+1)-code)

All functions are inlined and pure-Python (only the standard library is used).
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import Iterable, List, Tuple


# --------------------------------------------------------------------------- #
#  Core combinatorics                                                         #
# --------------------------------------------------------------------------- #
def hamming_distance(x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    """Number of coordinates at which the two equal-length words differ."""
    return sum(1 for a, b in zip(x, y) if a != b)


def sphere_count(n: int, q: int, k: int) -> int:
    """
    Number of words at Hamming distance EXACTLY k from a fixed centre:
        C(n, k) * (q - 1)^k.
    (Theorem: hammingWeight_count / sphere_card.)
    """
    if k < 0 or k > n:
        return 0
    return comb(n, k) * (q - 1) ** k


def ball_volume(n: int, q: int, t: int) -> int:
    """
    Volume V(t) of a Hamming ball of radius t over a q-ary length-n space:
        V(t) = sum_{i=0}^{t} C(n, i) * (q - 1)^i.
    (Theorem: hammingBall_card_formula / ball_card_eq.)
    """
    t = min(t, n)
    return sum(sphere_count(n, q, i) for i in range(t + 1))


def total_words(n: int, q: int) -> int:
    """Size of the whole word space: q^n."""
    return q ** n


# --------------------------------------------------------------------------- #
#  Brute-force verification helpers (small parameters only)                   #
# --------------------------------------------------------------------------- #
def all_words(n: int, q: int) -> List[Tuple[int, ...]]:
    """Every word of length n over alphabet {0, ..., q-1}."""
    return list(product(range(q), repeat=n))


def brute_force_sphere_count(n: int, q: int, k: int) -> int:
    """Count words at distance exactly k from the origin by enumeration."""
    origin = tuple(0 for _ in range(n))
    return sum(1 for w in all_words(n, q) if hamming_distance(origin, w) == k)


def brute_force_ball_volume(n: int, q: int, t: int) -> int:
    """Count words within distance t of the origin by enumeration."""
    origin = tuple(0 for _ in range(n))
    return sum(1 for w in all_words(n, q) if hamming_distance(origin, w) <= t)


def min_distance(code: Iterable[Tuple[int, ...]]) -> int:
    """Minimum pairwise Hamming distance of a code (inf -> 0 for <2 words)."""
    words = list(code)
    best = None
    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            d = hamming_distance(words[i], words[j])
            best = d if best is None else min(best, d)
    return 0 if best is None else best


def greedy_maximal_code(n: int, q: int, d: int) -> List[Tuple[int, ...]]:
    """
    Algorithm C: greedily build a d-separated MAXIMAL code (Gilbert-Varshamov
    construction). Enumerate words in lexicographic order, accepting each word
    that is at distance >= d from all already-accepted codewords.
    """
    code: List[Tuple[int, ...]] = []
    for w in all_words(n, q):
        if all(hamming_distance(w, c) >= d for c in code):
            code.append(w)
    return code


def is_maximal(code: List[Tuple[int, ...]], n: int, q: int, d: int) -> bool:
    """Check the maximality predicate: code is d-separated and no word can be added."""
    if min_distance(code) < d and len(code) >= 2:
        return False
    code_set = set(code)
    for w in all_words(n, q):
        if w in code_set:
            continue
        if all(hamming_distance(w, c) >= d for c in code):
            return False  # w could be added -> not maximal
    return True


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_volume_formula() -> None:
    print("=" * 70)
    print("DEMO 1 — Exact ball-volume formula  V(t) = sum C(n,i)(q-1)^i")
    print("=" * 70)
    for (n, q) in [(4, 2), (5, 3), (3, 4)]:
        print(f"\n  Alphabet q={q}, length n={n}, total words q^n = {total_words(n, q)}")
        for t in range(0, n + 1):
            formula = ball_volume(n, q, t)
            brute = brute_force_ball_volume(n, q, t)
            tag = "OK" if formula == brute else "MISMATCH!"
            print(f"    V({t}) = {formula:6d}   (brute force {brute:6d})  [{tag}]")


def demo_sphere_count() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2 — Exact sphere count  |{y : d(0,y)=k}| = C(n,k)(q-1)^k")
    print("=" * 70)
    for (n, q) in [(4, 2), (4, 3)]:
        print(f"\n  q={q}, n={n}")
        for k in range(0, n + 1):
            f = sphere_count(n, q, k)
            b = brute_force_sphere_count(n, q, k)
            tag = "OK" if f == b else "MISMATCH!"
            print(f"    |sphere({k})| = {f:5d}   (brute {b:5d})  [{tag}]")


def demo_packing_bound() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3 — Sphere-packing (Hamming) upper bound  |C|*V(t) <= q^n")
    print("=" * 70)
    # Binary repetition code of length 3: {000, 111}, min distance 3 = 2*1+1.
    code = [(0, 0, 0), (1, 1, 1)]
    n, q, t = 3, 2, 1
    lhs = len(code) * ball_volume(n, q, t)
    rhs = total_words(n, q)
    print(f"\n  Binary repetition code C = {code}")
    print(f"  min distance = {min_distance(code)}  (corrects t={t} error)")
    print(f"  |C|*V(t) = {len(code)} * {ball_volume(n,q,t)} = {lhs}")
    print(f"  q^n      = {rhs}")
    print(f"  Hamming bound  |C|*V(t) <= q^n :  {lhs} <= {rhs}  -> {lhs <= rhs}")
    print(f"  PERFECT CODE (equality)?  {lhs == rhs}")


def demo_gilbert_varshamov() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4 — Gilbert-Varshamov lower bound  q^n <= |C|*V(d-1)  (C maximal)")
    print("=" * 70)
    for (n, q, d) in [(4, 2, 3), (5, 2, 3), (4, 3, 2)]:
        code = greedy_maximal_code(n, q, d)
        maximal = is_maximal(code, n, q, d)
        lhs = total_words(n, q)
        rhs = len(code) * ball_volume(n, q, d - 1)
        print(f"\n  q={q}, n={n}, d={d}")
        print(f"  greedy maximal code size |C| = {len(code)}  (maximal? {maximal})")
        print(f"  q^n = {lhs}")
        print(f"  |C|*V(d-1) = {len(code)} * {ball_volume(n,q,d-1)} = {rhs}")
        print(f"  GV bound  q^n <= |C|*V(d-1) :  {lhs} <= {rhs}  -> {lhs <= rhs}")


def demo_sandwich() -> None:
    print("\n" + "=" * 70)
    print("DEMO 5 — The code-size sandwich  |C|*V(t) <= q^n <= |C|*V(2t)")
    print("=" * 70)
    # Maximal (2t+1)-codes obtained greedily.
    for (n, q, t) in [(4, 2, 1), (6, 2, 1), (5, 3, 1)]:
        d = 2 * t + 1
        code = greedy_maximal_code(n, q, d)
        m = len(code)
        left = m * ball_volume(n, q, t)
        mid = total_words(n, q)
        right = m * ball_volume(n, q, 2 * t)
        print(f"\n  q={q}, n={n}, t={t}  (minimum distance d=2t+1={d})")
        print(f"  greedy maximal code size |C| = {m}")
        print(f"  |C|*V(t)  = {left}")
        print(f"  q^n       = {mid}")
        print(f"  |C|*V(2t) = {right}")
        ok = left <= mid <= right
        print(f"  sandwich  {left} <= {mid} <= {right}  -> {ok}")
        print(f"  size estimate:  q^n/V(2t) <= |C| <= q^n/V(t)")
        print(f"      {mid/ball_volume(n,q,2*t):.3f} <= {m} <= {mid/ball_volume(n,q,t):.3f}")


def demo_perfect_hamming_code() -> None:
    print("\n" + "=" * 70)
    print("DEMO 6 — A perfect code: the [7,4] binary Hamming code, |C|*V(t)=q^n")
    print("=" * 70)
    # The 16 codewords of the [7,4,3] Hamming code (systematic generator).
    gen = [
        (1, 0, 0, 0, 0, 1, 1),
        (0, 1, 0, 0, 1, 0, 1),
        (0, 0, 1, 0, 1, 1, 0),
        (0, 0, 0, 1, 1, 1, 1),
    ]
    code = []
    for bits in product((0, 1), repeat=4):
        word = [0] * 7
        for b, g in zip(bits, gen):
            if b:
                word = [(wi + gi) % 2 for wi, gi in zip(word, g)]
        code.append(tuple(word))
    n, q, t = 7, 2, 1
    print(f"\n  |C| = {len(code)}, min distance = {min_distance(code)} (corrects t={t})")
    lhs = len(code) * ball_volume(n, q, t)
    rhs = total_words(n, q)
    print(f"  |C|*V(t) = {len(code)} * {ball_volume(n,q,t)} = {lhs}")
    print(f"  q^n      = {rhs}")
    print(f"  PERFECT (equality)?  {lhs == rhs}  -> the radius-1 balls TILE the cube")


def main() -> None:
    demo_volume_formula()
    demo_sphere_count()
    demo_packing_bound()
    demo_gilbert_varshamov()
    demo_sandwich()
    demo_perfect_hamming_code()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
