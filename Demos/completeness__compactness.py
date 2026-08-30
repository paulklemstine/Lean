#!/usr/bin/env python3
"""
Numerical demonstrations for:

    Completeness, Compactness and Exact Fibonacci Covering Combinatorics
    of the First-Disagreement Truth Space

The truth space C = {0,1}^N carries the first-disagreement ultrametric

    d(x, y) = 0                  if x == y
            = 2^{-fd(x,y)}       otherwise,   fd(x,y) = min{k : x_k != y_k}.

Closed balls of radius 2^-n are exactly the depth-n prefix classes.  The
golden-mean subshift G is the set of streams with no two consecutive 1s.

This script verifies, numerically and by explicit enumeration:

  1. the ultrametric (strong triangle) inequality,
  2. the ball-prefix dictionary  d(x,y) <= 2^-n  <=>  x, y agree to depth n,
  3. total boundedness of C: the 2^n truncations form an optimal 2^-n net,
  4. completeness: a Cauchy sequence freezes coordinatewise and the
     diagonal read-off is its limit,
  5. the shift is 2-Lipschitz, with the constant attained,
  6. closedness of G via explicit radius certificates,
  7. perfectness of G via truncation / spiked-truncation approximants,
  8. the Fibonacci count |A_n| = F_{n+2} of admissible words,
  9. covering number = packing number = F_{n+2} at scale 2^-n,
 10. convergence of log|A_n| / (n log 2) to log(phi)/log(2) = 0.694242...,
 11. the golden substitution 0 -> 0, 1 -> 10 as a bijection C -> G,
 12. the fixed-point / period-2 obstruction to conjugacy (2 vs 1, 4 vs 3).

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterator, List, Optional, Sequence, Tuple

Stream = Callable[[int], int]  # an infinite binary stream, as a function N -> {0,1}
Word = Tuple[int, ...]  # a finite binary word

PHI: float = (1.0 + math.sqrt(5.0)) / 2.0
DEPTH: int = 64  # coordinates inspected when comparing streams numerically


# ----------------------------------------------------------------------
# 1. The first-disagreement ultrametric
# ----------------------------------------------------------------------


def first_diff(x: Stream, y: Stream, depth: int = DEPTH) -> Optional[int]:
    """Least k < depth with x_k != y_k, or None if they agree that far."""
    for k in range(depth):
        if x(k) != y(k):
            return k
    return None


def cantor_dist(x: Stream, y: Stream, depth: int = DEPTH) -> float:
    """d(x,y) = 2^{-fd(x,y)}, with 0 when no disagreement is found."""
    k = first_diff(x, y, depth)
    return 0.0 if k is None else 2.0 ** (-k)


def agree_to(x: Stream, y: Stream, n: int) -> bool:
    """x ==_n y : the streams give identical answers to queries 0..n-1."""
    return all(x(k) == y(k) for k in range(n))


def from_word(w: Sequence[int]) -> Stream:
    """Zero-padding: the stream that follows w and then answers 0 forever."""
    ww = tuple(w)
    return lambda k: ww[k] if k < len(ww) else 0


def prefix(x: Stream, n: int) -> Word:
    """pi_n(x), the depth-n prefix of x."""
    return tuple(x(k) for k in range(n))


def random_stream(rng: random.Random) -> Stream:
    """A pseudo-random stream, memoised so it is a genuine fixed function."""
    memo: Dict[int, int] = {}

    def s(k: int) -> int:
        if k not in memo:
            memo[k] = rng.randint(0, 1)
        return memo[k]

    return s


def demo_ultrametric(trials: int = 4000, seed: int = 20260830) -> None:
    print("=" * 72)
    print("1. The first-disagreement ultrametric")
    print("=" * 72)
    rng = random.Random(seed)
    worst_ratio = 0.0
    isosceles = 0
    for _ in range(trials):
        x, y, z = (random_stream(rng) for _ in range(3))
        dxy, dyz, dxz = (
            cantor_dist(x, y),
            cantor_dist(y, z),
            cantor_dist(x, z),
        )
        assert dxz <= max(dxy, dyz) + 1e-15, "strong triangle inequality failed"
        if max(dxy, dyz) > 0:
            worst_ratio = max(worst_ratio, dxz / max(dxy, dyz))
        sides = sorted([dxy, dyz, dxz])
        if abs(sides[1] - sides[2]) < 1e-15:
            isosceles += 1
    print(f"  strong triangle inequality d(x,z) <= max(d(x,y),d(y,z)):  OK")
    print(f"  worst observed ratio d(x,z)/max(...) over {trials} triples: {worst_ratio:.3f}")
    print(f"  triangles that are isosceles: {isosceles}/{trials}  (theory: all)")
    print(f"  diameter bound: every distance <= 1                        OK")
    print()


def demo_ball_prefix_dictionary(trials: int = 3000, seed: int = 7) -> None:
    print("=" * 72)
    print("2. Ball-prefix dictionary:  d(x,y) <= 2^-n  <=>  x ==_n y")
    print("=" * 72)
    rng = random.Random(seed)
    for _ in range(trials):
        x, y = random_stream(rng), random_stream(rng)
        n = rng.randint(0, 12)
        lhs = cantor_dist(x, y) <= 2.0 ** (-n) + 1e-15
        rhs = agree_to(x, y, n)
        assert lhs == rhs, "ball-prefix dictionary failed"
    print(f"  verified on {trials} random pairs and depths 0..12:        OK")
    print("  consequence: closed 2^-n-balls are exactly the prefix classes,")
    print("  so balls of equal radius are identical or disjoint (clopen).")
    print()


# ----------------------------------------------------------------------
# 3. Total boundedness
# ----------------------------------------------------------------------


def truncate(x: Stream, n: int) -> Stream:
    """T_n x: keep the first n answers, then answer 0 forever."""
    return from_word(prefix(x, n))


def demo_total_boundedness(max_n: int = 8, samples: int = 500, seed: int = 11) -> None:
    print("=" * 72)
    print("3. Total boundedness: the 2^n truncations form an optimal 2^-n net")
    print("=" * 72)
    rng = random.Random(seed)
    print("    n   |net| = 2^n   max_x d(x, T_n x)   2^-n")
    print("   ---------------------------------------------------")
    for n in range(max_n + 1):
        worst = 0.0
        for _ in range(samples):
            x = random_stream(rng)
            worst = max(worst, cantor_dist(x, truncate(x, n)))
        assert worst <= 2.0 ** (-n) + 1e-15
        print(f"   {n:2d}   {2**n:10d}   {worst:16.6f}   {2.0**(-n):.6f}")
    print("  Lower bound: a closed 2^-n-ball is one prefix class, so no net")
    print("  with fewer than 2^n points can work -- the net above is optimal.")
    print()


# ----------------------------------------------------------------------
# 4. Completeness by coordinatewise stabilisation
# ----------------------------------------------------------------------


def demo_completeness(seed: int = 2024) -> None:
    print("=" * 72)
    print("4. Completeness: Cauchy sequences freeze coordinatewise")
    print("=" * 72)
    rng = random.Random(seed)
    target = random_stream(rng)

    # A Cauchy sequence: u^(i) agrees with `target` up to depth i, then is junk.
    def u(i: int) -> Stream:
        junk = random.Random(1000 + i)
        return lambda k: target(k) if k < i else junk.randint(0, 1)

    # Cauchy modulus: beyond index N(n) all terms agree to depth n.
    def N(n: int) -> int:
        return n

    # Diagonal read-off of the limit, exactly as in the completeness proof.
    def limit(k: int) -> int:
        return u(N(k + 1))(k)

    print("    n   N(n)   d(u^(N(n)), limit)   2^-n     freezing check")
    print("   -------------------------------------------------------")
    for n in range(0, 13, 2):
        d = cantor_dist(u(N(n)), limit)
        ok = d <= 2.0 ** (-n) + 1e-15
        assert ok
        print(f"   {n:2d}   {N(n):4d}   {d:18.8f}   {2.0**(-n):.6f}   {'OK' if ok else 'FAIL'}")
    agree = agree_to(limit, target, 40)
    print(f"  diagonal read-off reproduces the intended limit to depth 40: {agree}")
    print()


# ----------------------------------------------------------------------
# 5. The shift
# ----------------------------------------------------------------------


def shift(x: Stream) -> Stream:
    """sigma(x)_k = x_{k+1}: forget the first answer."""
    return lambda k: x(k + 1)


def demo_shift_lipschitz(trials: int = 3000, seed: int = 5) -> None:
    print("=" * 72)
    print("5. The shift is 2-Lipschitz, and the constant 2 is attained")
    print("=" * 72)
    rng = random.Random(seed)
    worst = 0.0
    for _ in range(trials):
        x, y = random_stream(rng), random_stream(rng)
        dxy = cantor_dist(x, y)
        if dxy == 0.0:
            continue
        ratio = cantor_dist(shift(x), shift(y)) / dxy
        assert ratio <= 2.0 + 1e-12
        worst = max(worst, ratio)
    print(f"  worst observed ratio d(sx,sy)/d(x,y) over {trials} pairs: {worst:.3f}")
    x, y = from_word([0, 1]), from_word([0, 0])
    print(
        f"  extremal pair x=01000..., y=00000...:  d(x,y)={cantor_dist(x,y):.3f}, "
        f"d(sx,sy)={cantor_dist(shift(x), shift(y)):.3f}  -> ratio 2"
    )
    print()


# ----------------------------------------------------------------------
# 6-7. The golden-mean subshift: closedness and perfectness
# ----------------------------------------------------------------------


def in_golden_mean(x: Stream, depth: int = DEPTH) -> bool:
    """Check (to the given depth) that x has no two consecutive 1s."""
    return not any(x(k) == 1 and x(k + 1) == 1 for k in range(depth))


def violation_index(x: Stream, depth: int = DEPTH) -> Optional[int]:
    for k in range(depth):
        if x(k) == 1 and x(k + 1) == 1:
            return k
    return None


def demo_closedness(seed: int = 99, trials: int = 300) -> None:
    print("=" * 72)
    print("6. Closedness of the golden-mean subshift, with radius certificates")
    print("=" * 72)
    rng = random.Random(seed)
    checked = 0
    for _ in range(trials):
        x = random_stream(rng)
        k = violation_index(x, 20)
        if k is None:
            continue
        r = 2.0 ** (-(k + 2))  # the certificate from the closedness proof
        for _ in range(30):  # every y within r of x must also be inadmissible
            y_word = list(prefix(x, k + 2)) + [rng.randint(0, 1) for _ in range(20)]
            y = from_word(y_word)
            assert cantor_dist(x, y) <= r
            assert not in_golden_mean(y, 20), "certificate radius was too large"
        checked += 1
    print(f"  {checked} inadmissible streams tested; every ball B(x, 2^-(k+2))")
    print("  around a violation at index k was found to miss the subshift: OK")
    print()


def spiked_truncate(x: Stream, n: int) -> Stream:
    """S_n x: first n answers of x, then 0, then a single isolated 1, then 0s."""
    return lambda k: x(k) if k < n else (1 if k == n + 1 else 0)


def demo_perfectness(seed: int = 31) -> None:
    print("=" * 72)
    print("7. Perfectness: every admissible stream has distinct admissible")
    print("   neighbours arbitrarily close")
    print("=" * 72)
    rng = random.Random(seed)
    # An admissible stream: 1s never adjacent.
    bits: List[int] = []
    while len(bits) < 40:
        if bits and bits[-1] == 1:
            bits.append(0)
        else:
            bits.append(rng.randint(0, 1))
    x = from_word(bits)
    assert in_golden_mean(x, 30)
    print("    n     witness            admissible   distinct   d(x,y)")
    print("   ---------------------------------------------------------")
    for n in range(1, 9):
        t = truncate(x, n)
        if prefix(t, 30) != prefix(x, 30):
            y, name = t, "truncation"
        else:
            y, name = spiked_truncate(x, n), "trunc + spike"
        adm = in_golden_mean(y, 30)
        distinct = prefix(y, 30) != prefix(x, 30)
        d = cantor_dist(x, y)
        assert adm and distinct and d <= 2.0 ** (-n) + 1e-15
        print(f"   {n:2d}     {name:16s}   {str(adm):10s}   {str(distinct):8s}   {d:.6f}")
    print("  Hence no point of the subshift is isolated: it is perfect, and")
    print("  (being nonempty, compact and totally disconnected) a Cantor set.")
    print()


# ----------------------------------------------------------------------
# 8-9. Fibonacci counting, covering and packing
# ----------------------------------------------------------------------


def admissible_words(n: int) -> List[Word]:
    """Enumerate A_n via W_{n+2} = 0.W_{n+1} + 10.W_n  (no rejection, no dupes)."""
    if n == 0:
        return [()]
    if n == 1:
        return [(0,), (1,)]
    prev2: List[Word] = [()]
    prev1: List[Word] = [(0,), (1,)]
    for _ in range(2, n + 1):
        cur = [(0,) + w for w in prev1] + [(1, 0) + w for w in prev2]
        prev2, prev1 = prev1, cur
    return prev1


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demo_fibonacci_count(max_n: int = 16) -> None:
    print("=" * 72)
    print("8. Admissible words:  |A_n| = F_{n+2}")
    print("=" * 72)
    print("    n   |A_n|   F_{n+2}   2^n     |A_n|/2^n   |A_n|/phi^n")
    print("   ------------------------------------------------------")
    for n in range(max_n + 1):
        words = admissible_words(n)
        # brute-force cross-check for small n
        if n <= 14:
            brute = [
                w
                for w in itertools.product((0, 1), repeat=n)
                if not any(w[i] == 1 and w[i + 1] == 1 for i in range(n - 1))
            ]
            assert sorted(words) == sorted(brute), "enumeration mismatch"
        assert len(words) == fib(n + 2)
        assert len(set(words)) == len(words), "enumeration produced duplicates"
        print(
            f"   {n:2d}   {len(words):5d}   {fib(n+2):7d}   {2**n:6d}   "
            f"{len(words)/2**n:9.5f}   {len(words)/PHI**n:10.5f}"
        )
    print("  The recursion emits every admissible word exactly once.")
    print()


def demo_covering_and_packing(max_n: int = 12) -> None:
    print("=" * 72)
    print("9. Covering number = packing number = F_{n+2} at scale 2^-n")
    print("=" * 72)
    print("    n   F_{n+2}   cover OK   min pairwise distance   2^-n")
    print("   -------------------------------------------------------")
    for n in range(1, max_n + 1):
        words = admissible_words(n)
        centres = [from_word(w) for w in words]

        # (a) COVER: every admissible stream lies within 2^-n of some centre.
        cover_ok = True
        rng = random.Random(500 + n)
        for _ in range(200):
            bits: List[int] = []
            while len(bits) < n + 12:
                bits.append(0 if (bits and bits[-1] == 1) else rng.randint(0, 1))
            x = from_word(bits)
            hit = from_word(prefix(x, n))  # the padded prefix is the right centre
            if cantor_dist(x, hit) > 2.0 ** (-n) + 1e-15:
                cover_ok = False
        # (b) PACK: distinct centres are strictly more than 2^-n apart.
        if n <= 9:
            min_d = min(
                cantor_dist(centres[i], centres[j])
                for i in range(len(centres))
                for j in range(i + 1, len(centres))
            )
        else:
            min_d = float("nan")
        assert cover_ok
        if min_d == min_d:  # not NaN
            assert min_d > 2.0 ** (-n)
        md = "  (skipped)" if min_d != min_d else f"{min_d:.8f}"
        print(f"   {n:2d}   {fib(n+2):7d}   {str(cover_ok):8s}   {md:>21s}   {2.0**(-n):.8f}")
    print("  Covering and packing pinch the count from both sides: the")
    print("  2^-n-covering number of the subshift is exactly F_{n+2}.")
    print()


def demo_dimension(max_n: int = 60) -> None:
    print("=" * 72)
    print("10. Box dimension log(phi)/log(2) and entropy log(phi)")
    print("=" * 72)
    target = math.log(PHI) / math.log(2.0)
    print(f"    exact value  log(phi)/log(2) = {target:.10f}")
    print("     n    log|A_n| / (n log 2)    error       phi^n <= F_{n+2} <= phi^(n+1)")
    print("   ---------------------------------------------------------------------")
    for n in [2, 4, 8, 16, 32, max_n]:
        a = fib(n + 2)
        est = math.log(a) / (n * math.log(2.0))
        sandwich = PHI**n <= a <= PHI ** (n + 1)
        assert sandwich
        print(f"   {n:3d}    {est:18.10f}    {abs(est-target):.3e}   {sandwich}")
    print(f"  topological entropy  h = log(phi) = {math.log(PHI):.10f}  <  log 2 = {math.log(2):.10f}")
    print(f"  channel capacity     = {target:.6f} bits per symbol (vs 1 unconstrained)")
    print(f"  dimension deficit    = {100*(1-target):.2f}% of the ambient dimension")
    print()


# ----------------------------------------------------------------------
# 11-12. Homeomorphism and dynamical rigidity
# ----------------------------------------------------------------------


def golden_substitution(w: Sequence[int]) -> Word:
    """0 -> 0, 1 -> 10.  Maps arbitrary words to admissible ones."""
    out: List[int] = []
    for b in w:
        out.extend([0] if b == 0 else [1, 0])
    return tuple(out)


def golden_decode(w: Sequence[int]) -> Word:
    """Greedy inverse of the substitution on an admissible word."""
    out: List[int] = []
    i = 0
    while i < len(w):
        if w[i] == 0:
            out.append(0)
            i += 1
        else:
            out.append(1)
            i += 2  # the next letter is forced to be 0
    return tuple(out)


def demo_substitution(max_n: int = 10) -> None:
    print("=" * 72)
    print("11. The golden substitution 0 -> 0, 1 -> 10 is injective onto G")
    print("=" * 72)
    print("    n   words   images admissible   images distinct   decode inverts")
    print("   --------------------------------------------------------------------")
    for n in range(1, max_n + 1):
        src = list(itertools.product((0, 1), repeat=n))
        imgs = [golden_substitution(w) for w in src]
        adm = all(
            not any(im[i] == 1 and im[i + 1] == 1 for i in range(len(im) - 1)) for im in imgs
        )
        distinct = len(set(imgs)) == len(imgs)
        inverts = all(golden_decode(im) == w for w, im in zip(src, imgs))
        assert adm and distinct and inverts
        print(f"   {n:2d}   {len(src):5d}   {str(adm):17s}   {str(distinct):15s}   {inverts}")
    print("  Injective, continuous and onto the subshift: the full truth space")
    print("  and the golden-mean subshift are homeomorphic -- the dimension")
    print("  deficit of 30.58% is completely invisible to the topology.")
    print()


def periodic_points(period: int, admissible_only: bool) -> List[Word]:
    """Points x with sigma^p x = x, listed by their repeating block of length p."""
    out: List[Word] = []
    for w in itertools.product((0, 1), repeat=period):
        cyc = w + w  # check the wrap-around constraint too
        if admissible_only and any(cyc[i] == 1 and cyc[i + 1] == 1 for i in range(len(cyc) - 1)):
            continue
        out.append(w)
    return out


def lucas(n: int) -> int:
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demo_rigidity(max_p: int = 8) -> None:
    print("=" * 72)
    print("12. Dynamical rigidity: the shifts are NOT conjugate")
    print("=" * 72)
    print("    p   #{x : s^p x = x} full   golden   Lucas L_p   2^p")
    print("   -----------------------------------------------------")
    for p in range(1, max_p + 1):
        full = len(periodic_points(p, admissible_only=False))
        gold = len(periodic_points(p, admissible_only=True))
        assert full == 2**p
        assert gold == lucas(p), (p, gold, lucas(p))
        print(f"   {p:2d}   {full:20d}   {gold:6d}   {lucas(p):9d}   {2**p:5d}")
    print("  Fixed points: 2 for the full shift (all-0, all-1) versus 1 for the")
    print("  golden-mean shift (all-0 only; all-1 is forbidden).  Fixed-point")
    print("  counts are conjugacy invariants and 1 != 2, so although the two")
    print("  spaces are homeomorphic, the two dynamical systems are not")
    print("  conjugate.  Same shape, different ruler, different motion.")
    print()


# ----------------------------------------------------------------------
# Bonus: the minimax online mistake bound
# ----------------------------------------------------------------------


def demo_mistake_bound(max_n: int = 12) -> None:
    print("=" * 72)
    print("13. Online prediction: minimax mistake rate is exactly 1/2")
    print("=" * 72)
    print("    n   worst mistakes of 'always 0'   ceil(n/2)   adversary forces")
    print("   ----------------------------------------------------------------")
    for n in range(1, max_n + 1):
        worst = max(sum(w) for w in admissible_words(n))
        # Adversary against the deterministic all-0 predictor: answer 1 when legal.
        adversary = 0
        last = 0
        for _ in range(n):
            bit = 0 if last == 1 else 1  # predictor says 0, so answer 1 if allowed
            adversary += 1 if bit == 1 else 0
            last = bit
        assert 2 * worst <= n + 1  # the sharp density bound
        assert worst == math.ceil(n / 2)
        print(f"   {n:2d}   {worst:28d}   {math.ceil(n/2):9d}   {adversary:16d}")
    print("  Sharp density bound 2*#{ones} <= n+1, attained by 1010...")
    print("  Upper and lower bounds meet: the minimax rate is 1/2 per round.")
    print()


def main() -> None:
    print()
    print("#" * 72)
    print("#  THE FIRST-DISAGREEMENT TRUTH SPACE AND THE GOLDEN-MEAN SUBSHIFT")
    print("#  compactness, Fibonacci covering combinatorics, and rigidity")
    print("#" * 72)
    print()
    demo_ultrametric()
    demo_ball_prefix_dictionary()
    demo_total_boundedness()
    demo_completeness()
    demo_shift_lipschitz()
    demo_closedness()
    demo_perfectness()
    demo_fibonacci_count()
    demo_covering_and_packing()
    demo_dimension()
    demo_substitution()
    demo_rigidity()
    demo_mistake_bound()
    print("=" * 72)
    print("All demonstrations completed; every assertion held.")
    print("=" * 72)


if __name__ == "__main__":
    main()
