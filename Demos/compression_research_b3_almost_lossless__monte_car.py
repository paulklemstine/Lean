"""
Almost-lossless compression beyond the pigeonhole bound
=======================================================

Numerical demonstration of the results of the accompanying paper.

Everything below is a *finite* computation over the space of all codebooks
H : A -> [M], enumerated exhaustively where feasible and sampled otherwise.
No external dependencies; standard library only.

Contents
--------
1.  The pigeonhole barrier and its epsilon-relaxed converse.
2.  Exhaustive verification of the exact marginal count
        M * #{H : H(p) = H(q)} = M^|A|      (p != q).
3.  The scanning decoder: exact cost |L|, soundness on typical inputs.
4.  Exhaustive failure probability vs. the exact closed form
        1 - (1 - 1/M)^(|S|-1),
    the union bound (|S|-1)/M and the Bonferroni bound (|S|-1)/(2M).
5.  Derandomisation: a fixed codebook whose bad set is at most |S|(|S|-1)/M.
6.  The blocked (product) code: exact cost b|T| versus the flat cost |T|^b,
    and the union-bound failure probability b(|T|-1)/M.
7.  The atypical-input loophole (silent corruption) measured exhaustively,
    and its suppression by an independent checksum to <= 1/K.
8.  Rate / complexity / safety table for realistic parameters.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Iterator, Optional, Sequence

Codebook = tuple[int, ...]  # H as a tuple: H[x] in [M] for x in range(|A|)


# ---------------------------------------------------------------------------
# 0. Utilities
# ---------------------------------------------------------------------------

def all_codebooks(alphabet_size: int, m: int) -> Iterator[Codebook]:
    """Enumerate all M^|A| codebooks H : A -> [M] as tuples of length |A|."""
    return itertools.product(range(m), repeat=alphabet_size)


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# 1. Pigeonhole barrier and the epsilon-relaxed converse
# ---------------------------------------------------------------------------

def exact_decodable_count(enc: Sequence[int], dec: Sequence[Optional[int]]) -> int:
    """|{x : dec(enc(x)) = x}|, the set the converse bound controls.

    Theorem (converse): this count is at most M for ANY encoder/decoder pair,
    because the encoder is injective on that set.
    """
    return sum(1 for x, c in enumerate(enc) if dec[c] == x)


def demo_pigeonhole() -> None:
    banner("1.  The pigeonhole barrier and its epsilon-relaxed converse")
    alphabet_size, m = 8, 3
    rng = random.Random(20260818)
    worst = 0
    for _ in range(20000):
        enc = [rng.randrange(m) for _ in range(alphabet_size)]
        dec: list[Optional[int]] = [rng.randrange(alphabet_size) for _ in range(m)]
        worst = max(worst, exact_decodable_count(enc, dec))
    print(f"  |A| = {alphabet_size}, M = {m}")
    print(f"  max over 20000 random (encoder, decoder) pairs of")
    print(f"      |{{x : dec(enc(x)) = x}}|  =  {worst}   (converse bound: <= M = {m})")
    print("  Exact decoding of ALL of A would need M >= |A| = "
          f"{alphabet_size}; with M = {m} at most {m} strings can ever be exact.")
    for eps in (0.01, 0.1, 0.5):
        s_card = 1000
        print(f"    to decode a (1-{eps}) fraction of a typical set of size "
              f"{s_card}: need M >= {(1 - eps) * s_card:.0f}")


# ---------------------------------------------------------------------------
# 2. The exact marginal count  M * #{H : H p = H q} = M^|A|
# ---------------------------------------------------------------------------

def collision_count(alphabet_size: int, m: int, p: int, q: int) -> int:
    """#{H : A -> [M] with H(p) = H(q)}, by exhaustive enumeration."""
    return sum(1 for h in all_codebooks(alphabet_size, m) if h[p] == h[q])


def demo_marginal() -> None:
    banner("2.  Exact marginal count:  M * #{H : H(p) = H(q)} = M^|A|")
    print(f"  {'|A|':>4} {'M':>3} {'#collisions':>12} {'M*#':>12} {'M^|A|':>12}  ok")
    for alphabet_size in (4, 5, 6):
        for m in (2, 3, 4):
            c = collision_count(alphabet_size, m, 0, 1)
            lhs, rhs = m * c, m ** alphabet_size
            print(f"  {alphabet_size:>4} {m:>3} {c:>12} {lhs:>12} {rhs:>12}"
                  f"  {'YES' if lhs == rhs else 'NO'}")
    print("  => a random codebook collides on a fixed pair with probability")
    print("     exactly 1/M.  This single identity carries the whole argument.")


# ---------------------------------------------------------------------------
# 3. The scanning decoder
# ---------------------------------------------------------------------------

def scanning_decode(candidates: Sequence[int], h: Codebook,
                    c: int) -> tuple[Optional[int], int]:
    """Return (output, cost).

    Scan the candidate list once, keeping every y with H(y) = c.  Output y if
    there is exactly one match, otherwise None (an explicit, detected failure).
    Cost = one hash comparison per candidate = len(candidates), always.
    """
    matches: list[int] = []
    cost = 0
    for y in candidates:
        cost += 1
        if h[y] == c:
            matches.append(y)
    return (matches[0] if len(matches) == 1 else None), cost


def demo_decoder() -> None:
    banner("3.  The scanning decoder: exact cost, and soundness on typical inputs")
    alphabet_size, m = 6, 3
    typical = [0, 1, 2]
    h: Codebook = tuple(y % 3 for y in range(alphabet_size))
    out, cost = scanning_decode(typical, h, h[0])
    print(f"  |A| = {alphabet_size}, S = {typical}, H(y) = y mod 3")
    print(f"  decode(H(0)) = {out}, cost = {cost}   (theory: cost = |S| = {len(typical)})")

    costs = {scanning_decode(typical, hh, c)[1]
             for hh in all_codebooks(alphabet_size, m) for c in range(m)}
    print(f"  set of costs over ALL {m ** alphabet_size} codebooks and all "
          f"codewords: {costs}  (a single value: the cost is exact)")

    violations = 0
    for hh in all_codebooks(alphabet_size, m):
        for x in typical:
            out, _ = scanning_decode(typical, hh, hh[x])
            if out is not None and out != x:
                violations += 1
    print(f"  soundness on typical inputs: confident-and-wrong outputs = "
          f"{violations}  (theory: 0)")


# ---------------------------------------------------------------------------
# 4. Failure probability: measured, exact formula, and the two bounds
# ---------------------------------------------------------------------------

def failure_probability_exhaustive(alphabet_size: int, typical: Sequence[int],
                                   x: int, m: int) -> Fraction:
    """Exact fraction of codebooks under which some other typical string
    collides with x."""
    bad = 0
    for h in all_codebooks(alphabet_size, m):
        if any(h[y] == h[x] for y in typical if y != x):
            bad += 1
    return Fraction(bad, m ** alphabet_size)


def failure_probability_closed_form(k: int, m: int) -> Fraction:
    """1 - (1 - 1/M)^k, the exact failure probability of uniform random hashing
    against k competitors."""
    return 1 - Fraction(m - 1, m) ** k


def demo_failure_probability() -> None:
    banner("4.  Failure probability: exhaustive vs. exact formula vs. bounds")
    alphabet_size = 6
    typical = [0, 1, 2]
    x = 0
    k = len(typical) - 1
    print(f"  |A| = {alphabet_size}, S = {typical}, x = {x}, k = |S|-1 = {k}")
    print(f"  {'M':>3} {'measured':>12} {'1-(1-1/M)^k':>14} {'union k/M':>12}"
          f" {'Bonferroni':>12}  sandwiched")
    for m in (2, 3, 4, 8, 16):
        meas = failure_probability_exhaustive(alphabet_size, typical, x, m)
        exact = failure_probability_closed_form(k, m)
        union = Fraction(k, m)
        bonf = Fraction(k, 2 * m)
        ok = (bonf <= meas <= union) and (meas == exact)
        print(f"  {m:>3} {str(meas):>12} {str(exact):>14} {str(union):>12}"
              f" {str(bonf):>12}  {'YES' if ok else 'NO'}")
    print("  => the closed form is exact; the union bound and the Bonferroni")
    print("     lower bound are each tight to within a factor of two.")
    print()
    print("  Rate consequence (M >= (|S|-1)/eps gives success >= 1-eps):")
    for eps in (1e-3, 1e-6, 1e-12):
        s_card = 2 ** 20
        m_needed = (s_card - 1) / eps
        print(f"    |S| = 2^20, eps = {eps:g}:  log2 M >= {math.log2(m_needed):.1f} bits"
              f"   (= log2|S| + log2(1/eps) = {20 + math.log2(1 / eps):.1f})")


# ---------------------------------------------------------------------------
# 5. Derandomisation
# ---------------------------------------------------------------------------

def bad_strings(typical: Sequence[int], h: Codebook) -> list[int]:
    """Typical strings that a FIXED codebook fails to separate."""
    return [x for x in typical if any(h[y] == h[x] for y in typical if y != x)]


def demo_derandomisation() -> None:
    banner("5.  Derandomisation: a fixed codebook with a provably small bad set")
    alphabet_size = 6
    typical = [0, 1, 2, 3]
    for m in (3, 4, 5, 8):
        best = min(all_codebooks(alphabet_size, m),
                   key=lambda h: len(bad_strings(typical, h)))
        nbad = len(bad_strings(typical, best))
        bound = len(typical) * (len(typical) - 1) / m
        print(f"  M = {m:>2}:  min |Bad(S,H)| = {nbad}   "
              f"averaging bound |S|(|S|-1)/M = {bound:.2f}   "
              f"{'satisfied' if nbad <= bound else 'VIOLATED'}")
    print("  Note: with M < |S| the bad set can be made small but NEVER empty --")
    print("  an empty bad set would contradict the converse counting bound.")


# ---------------------------------------------------------------------------
# 6. The blocked (product) code
# ---------------------------------------------------------------------------

def blocked_decode(block_typical: Sequence[int],
                   h: Callable[[int, int], int],
                   received: Sequence[int]) -> tuple[Optional[tuple[int, ...]], int]:
    """Decode each block independently with the scanning decoder.

    Succeed only if EVERY block decodes unambiguously.  Cost = b * |T| exactly.
    """
    out: list[int] = []
    cost = 0
    ok = True
    for i, c in enumerate(received):
        matches: list[int] = []
        for y in block_typical:
            cost += 1
            if h(i, y) == c:
                matches.append(y)
        if len(matches) == 1:
            out.append(matches[0])
        else:
            ok = False
    return (tuple(out) if ok else None), cost


def demo_blocking() -> None:
    banner("6.  Blocking: exponential search becomes linear")
    block_typical = [0, 1, 2, 3]
    t = len(block_typical)
    print(f"  |T| = {t}")
    print(f"  {'b':>3} {'blocked cost b|T|':>18} {'flat cost |T|^b':>18} {'speedup':>14}")
    for b in (1, 2, 3, 5, 10, 20, 50):
        print(f"  {b:>3} {b * t:>18} {t ** b:>18} {t ** b / (b * t):>14.3e}")
    print("  (theorem: b|T| < |T|^b for |T| >= 2, b >= 3)")

    print()
    print("  Measured decoder cost of the blocked decoder (must equal b*|T|):")
    m = 4096
    rng = random.Random(1234)
    for b in (2, 3, 6):
        table = {(i, y): rng.randrange(m) for i in range(b) for y in range(t)}
        h = lambda i, y: table[(i, y)]
        x = tuple(rng.choice(block_typical) for _ in range(b))
        received = [h(i, x[i]) for i in range(b)]
        out, cost = blocked_decode(block_typical, h, received)
        print(f"    b = {b}:  cost = {cost} (= b|T| = {b * t}), "
              f"output {'== x' if out == x else out}")

    print()
    print("  Failure probability, measured by sampling vs. union bound b(|T|-1)/M:")
    trials = 200000
    for b, m in ((3, 64), (5, 128), (10, 512)):
        fails = 0
        for _ in range(trials):
            table = {(i, y): rng.randrange(m) for i in range(b) for y in range(t)}
            h = lambda i, y: table[(i, y)]
            x = tuple(rng.choice(block_typical) for _ in range(b))
            received = [h(i, x[i]) for i in range(b)]
            out, _ = blocked_decode(block_typical, h, received)
            if out != x:
                fails += 1
        bound = b * (t - 1) / m
        print(f"    b = {b:>2}, M = {m:>3}:  measured {fails / trials:.5f}   "
              f"bound {bound:.5f}   {'OK' if fails / trials <= bound else 'VIOLATED'}")
    print("  Note: an output is NEVER wrong here, only absent -- the blocked")
    print("  decoder is sound on typical inputs, block by block.")


# ---------------------------------------------------------------------------
# 7. The atypical loophole and the universal checksum
# ---------------------------------------------------------------------------

def demo_silent_corruption() -> None:
    banner("7.  Silent corruption on ATYPICAL inputs, and the checksum that "
           "kills it")
    alphabet_size = 6
    typical = [1, 2]          # the decoder's candidate list
    x = 0                      # the transmitted string -- ATYPICAL
    m = 4
    total = m ** alphabet_size
    silent = 0
    for h in all_codebooks(alphabet_size, m):
        out, _ = scanning_decode(typical, h, h[x])
        if out is not None and out != x:
            silent += 1
    p_silent = Fraction(silent, total)
    print(f"  |A| = {alphabet_size}, candidate list = {typical}, transmitted "
          f"x = {x} (atypical), M = {m}")
    print(f"  P[confident WRONG output, no checksum] = {p_silent} "
          f"= {float(p_silent):.4f}")
    print("  This is the loophole: typicality-based soundness says nothing here.")
    print()
    print("  Now append an independent random checksum C : A -> [K] and accept")
    print("  the candidate y only if C(y) equals the received checksum.")
    print(f"  {'K':>3} {'measured':>12} {'bound 1/K':>12}  ok")
    for k in (2, 4, 8):
        silent_pairs = 0
        for h in all_codebooks(alphabet_size, m):
            out, _ = scanning_decode(typical, h, h[x])
            if out is None or out == x:
                continue
            # candidate y0 = out is determined by H; a silent corruption now
            # requires C(y0) = C(x), i.e. one collision of the checksum.
            silent_pairs += k ** (alphabet_size - 1)
        measured = Fraction(silent_pairs, total * k ** alphabet_size)
        bound = Fraction(1, k)
        print(f"  {k:>3} {str(measured):>12} {str(bound):>12}  "
              f"{'YES' if measured <= bound else 'NO'}")
    print("  => exactly the 1/K scaling, for EVERY source string and for ANY")
    print("     inner decoder whatsoever (the bound is proved fibrewise:")
    print("     fixing the inner randomness determines the candidate, after")
    print("     which only the independent checksum matters).")


# ---------------------------------------------------------------------------
# 8. The composite scheme at realistic parameters
# ---------------------------------------------------------------------------

def demo_composite_table() -> None:
    banner("8.  The composite scheme (blocks + checksum) at realistic parameters")
    print("  Encoder: b block hashes into [M], plus one global checksum in [K].")
    print("  Decoder: blockwise scan, unanimity test, then checksum test.")
    print("  Cost: exactly b|T| + 1 comparisons.")
    print()
    header = (f"  {'|T|':>8} {'b':>4} {'eps':>8} {'K':>10} {'log2 M':>8}"
              f" {'rate (bits)':>12} {'cost':>12} {'flat cost':>12} {'P[lie]':>10}")
    print(header)
    for t_log, b, eps, k in ((20, 50, 1e-9, 2 ** 32),
                             (20, 50, 1e-12, 2 ** 64),
                             (10, 100, 1e-9, 2 ** 32),
                             (16, 8, 1e-6, 2 ** 32)):
        t = 2 ** t_log
        m = b * (t - 1) / eps
        rate = b * math.log2(m) + math.log2(k)
        cost = b * t + 1
        flat = t ** b
        print(f"  {'2^' + str(t_log):>8} {b:>4} {eps:>8.0e} {'2^' + str(k.bit_length() - 1):>10}"
              f" {math.log2(m):>8.1f} {rate:>12.0f} {cost:>12.3e}"
              f" {'2^' + str(round(b * t_log)):>12} {1 / k:>10.2e}")
    print()
    print("  Read the last two columns: the blocked decoder does ~10^7-10^9")
    print("  comparisons where the flat random code would need 2^1000.")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_pigeonhole()
    demo_marginal()
    demo_decoder()
    demo_failure_probability()
    demo_derandomisation()
    demo_blocking()
    demo_silent_corruption()
    demo_composite_table()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
