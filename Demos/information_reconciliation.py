#!/usr/bin/env python3
"""
Information Reconciliation: transcripts, corrected keys, and exact leakage.
===========================================================================

A self-contained numerical demonstration of the theory of syndrome-based
information reconciliation over the two-element field F_2.

Setting
-------
Alice holds a key  a in F_2^n,  Bob holds  b in F_2^n,  and they are promised
that the error pattern  e = a - b = a + b  has Hamming weight at most t.
A public parity-check matrix  H  of size  m x n  is fixed in advance and known
to everyone, including the eavesdropper Eve.

Protocol.  Alice broadcasts the syndrome  s = H a  (m bits: the whole public
transcript).  Bob computes  s - H b = H(a - b) = H e,  decodes to recover e,
and outputs  b + e.

What this script verifies numerically
-------------------------------------
1.  CORRECTNESS.  If every nonzero kernel vector of H has weight > 2t
    ("separating"), Bob's corrected key equals Alice's key exactly, for every
    admissible input pair.
2.  EXACT LEAKAGE.  Every transcript leaves exactly 2^(n - r) keys consistent,
    where r = rank(H); so  2^n = 2^r * 2^(n-r)  and the transcript leaks
    exactly r bits.
3.  CHAIN RULE.  n = H(transcript) + H_inf(key | transcript) = r + (n - r).
4.  GUESSING BOUND.  Any transcript-only guessing strategy is correct on at
    most 2^r of the 2^n keys.
5.  UNIVERSAL CONVERSE.  Any correct protocol needs at least
    V(n,t) = sum_{i<=t} C(n,i)  distinguishable transcripts;  V(n,t) <= 2^m.
6.  PERFECTION.  When 2^m = V(n,t) the scheme has a total decoder, full rank
    r = m, and meets the bound with equality:  V(n,t) * 2^(n-m) = 2^n.
7.  COMPOSITION.  Stacking rounds: rank(H1;H2) <= rank(H1) + rank(H2), and
    correctness is preserved.
8.  A NON-SEPARATING COUNTEREXAMPLE, exhibiting an explicit decoding collision.

No third-party libraries are required.
"""

from __future__ import annotations

from itertools import product
from math import comb, log2
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

Vec = Tuple[int, ...]     # a vector over F_2, entries 0/1
Mat = List[List[int]]     # a matrix over F_2, row-major


# ---------------------------------------------------------------------------
# Basic F_2 linear algebra
# ---------------------------------------------------------------------------

def all_vectors(n: int) -> Iterator[Vec]:
    """Enumerate all 2^n vectors of F_2^n."""
    return product((0, 1), repeat=n)


def hamming_weight(x: Sequence[int]) -> int:
    """Number of nonzero coordinates of x."""
    return sum(1 for xi in x if xi % 2 != 0)


def vec_add(x: Sequence[int], y: Sequence[int]) -> Vec:
    """Coordinatewise sum over F_2 (which is also the difference)."""
    return tuple((xi + yi) % 2 for xi, yi in zip(x, y))


def syndrome(H: Mat, x: Sequence[int]) -> Vec:
    """The syndrome H x over F_2."""
    return tuple(sum(row[j] * x[j] for j in range(len(x))) % 2 for row in H)


def rank_f2(H: Mat) -> int:
    """Rank of H over F_2 by Gaussian elimination.  O(m^2 n) bit operations."""
    rows = [row[:] for row in H]
    m = len(rows)
    n = len(rows[0]) if m else 0
    r = 0
    for col in range(n):
        pivot: Optional[int] = None
        for i in range(r, m):
            if rows[i][col]:
                pivot = i
                break
        if pivot is None:
            continue
        rows[r], rows[pivot] = rows[pivot], rows[r]
        for i in range(m):
            if i != r and rows[i][col]:
                rows[i] = [(a + b) % 2 for a, b in zip(rows[i], rows[r])]
        r += 1
        if r == m:
            break
    return r


def ball_volume(n: int, t: int) -> int:
    """V(n,t) = sum_{i<=t} C(n,i), the Hamming ball volume."""
    return sum(comb(n, i) for i in range(t + 1))


# ---------------------------------------------------------------------------
# The reconciliation scheme
# ---------------------------------------------------------------------------

class Scheme:
    """A syndrome-based reconciliation scheme (H, t) over F_2."""

    def __init__(self, H: Mat, t: int, name: str = "") -> None:
        self.H: Mat = [row[:] for row in H]
        self.t: int = t
        self.name: str = name
        self.m: int = len(H)
        self.n: int = len(H[0]) if H else 0

    # --- basic maps -------------------------------------------------------

    def syndrome(self, x: Sequence[int]) -> Vec:
        return syndrome(self.H, x)

    def transcript(self, a: Sequence[int]) -> Vec:
        """The public transcript of a run in which Alice holds a."""
        return self.syndrome(a)

    def rank(self) -> int:
        """r = rank(H): the exact number of bits the transcript leaks."""
        return rank_f2(self.H)

    # --- structural properties -------------------------------------------

    def kernel(self) -> List[Vec]:
        """All codewords: vectors c with H c = 0."""
        zero = tuple([0] * self.m)
        return [c for c in all_vectors(self.n) if self.syndrome(c) == zero]

    def min_distance(self) -> Optional[int]:
        """Minimum weight of a nonzero codeword (None if the code is trivial)."""
        weights = [hamming_weight(c) for c in self.kernel() if any(c)]
        return min(weights) if weights else None

    def is_separating(self) -> bool:
        """Every nonzero kernel vector has weight > 2t (unique decoding)."""
        d = self.min_distance()
        return d is None or d > 2 * self.t

    def is_perfect(self) -> bool:
        """2^m = V(n,t): the transcript length meets the universal bound."""
        return 2 ** self.m == ball_volume(self.n, self.t)

    # --- decoding and correction -----------------------------------------

    def syndrome_table(self) -> Dict[Vec, Vec]:
        """Map each achievable syndrome to a weight-<=t preimage, if any."""
        table: Dict[Vec, Vec] = {}
        for e in all_vectors(self.n):
            if hamming_weight(e) <= self.t:
                table.setdefault(self.syndrome(e), e)
        return table

    def decode(self, s: Vec, table: Optional[Dict[Vec, Vec]] = None) -> Vec:
        """Return a weight-<=t error pattern with syndrome s (0 if none)."""
        tab = table if table is not None else self.syndrome_table()
        return tab.get(s, tuple([0] * self.n))

    def correct(self, b: Sequence[int], s: Vec,
                table: Optional[Dict[Vec, Vec]] = None) -> Vec:
        """Bob's correction: b + decode(s - H b)."""
        diff = vec_add(s, self.syndrome(b))          # subtraction = addition
        return vec_add(b, self.decode(diff, table))

    # --- leakage ----------------------------------------------------------

    def consistent(self, s: Vec) -> List[Vec]:
        """All keys still consistent with the public transcript s."""
        return [x for x in all_vectors(self.n) if self.syndrome(x) == s]

    def achievable_transcripts(self) -> List[Vec]:
        return sorted({self.syndrome(x) for x in all_vectors(self.n)})


# ---------------------------------------------------------------------------
# Verification routines
# ---------------------------------------------------------------------------

def check_correctness(S: Scheme) -> Tuple[int, int]:
    """Exhaustively verify correctness over all pairs (a,b) with |a-b| <= t.

    Returns (number of pairs tested, number of failures).
    """
    table = S.syndrome_table()
    tested = 0
    failed = 0
    for a in all_vectors(S.n):
        for b in all_vectors(S.n):
            if hamming_weight(vec_add(a, b)) <= S.t:
                tested += 1
                if S.correct(b, S.transcript(a), table) != a:
                    failed += 1
    return tested, failed


def check_leakage(S: Scheme) -> Tuple[int, int, bool]:
    """Verify that every transcript leaves exactly 2^(n-r) consistent keys.

    Returns (rank r, common fiber size, whether all fibers had that size).
    """
    r = S.rank()
    expected = 2 ** (S.n - r)
    ok = True
    for s in S.achievable_transcripts():
        if len(S.consistent(s)) != expected:
            ok = False
    return r, expected, ok


def best_guessing_strategy(S: Scheme) -> int:
    """The optimal transcript-only adversary: how many keys can she get right?

    Given the transcript she outputs one key from its fiber; she is right on
    exactly one key per achievable transcript.  Theory says this is 2^r.
    """
    return len(S.achievable_transcripts())


def stack(S1: Scheme, S2: Scheme, t: int, name: str = "") -> Scheme:
    """Compose two rounds by stacking the parity-check matrices."""
    assert S1.n == S2.n, "rounds must act on keys of the same length"
    return Scheme(S1.H + S2.H, t, name)


# ---------------------------------------------------------------------------
# The named schemes
# ---------------------------------------------------------------------------

REPETITION = Scheme([[1, 1, 0],
                     [0, 1, 1]], t=1, name="[3,1] repetition")

HAMMING74 = Scheme([[1, 0, 1, 0, 1, 0, 1],
                    [0, 1, 1, 0, 0, 1, 1],
                    [0, 0, 0, 1, 1, 1, 1]], t=1, name="[7,4] Hamming")

# Not separating: the weight-1 patterns 1000 and 0100 collide.
BAD_PAIRING = Scheme([[1, 1, 0, 0],
                      [0, 0, 1, 1]], t=1, name="paired-parity (NOT separating)")

# A separating but *imperfect* scheme: an extra, redundant parity check appended
# to the Hamming matrix.  Rank stays 3, so leakage stays 3 bits even though 4
# bits are published --- the dependent row is free.
HAMMING_REDUNDANT = Scheme([[1, 0, 1, 0, 1, 0, 1],
                            [0, 1, 1, 0, 0, 1, 1],
                            [0, 0, 0, 1, 1, 1, 1],
                            [1, 1, 0, 0, 1, 1, 0]],  # = row1 + row2
                           t=1, name="[7,4] Hamming + redundant check")


# ---------------------------------------------------------------------------
# Reports
# ---------------------------------------------------------------------------

def rule(title: str = "") -> None:
    print()
    print("=" * 74)
    if title:
        print(title)
        print("=" * 74)


def report_scheme(S: Scheme) -> None:
    """A full audit of one scheme: correctness, leakage, entropy, optimality."""
    rule(f"SCHEME: {S.name}     (n = {S.n}, m = {S.m}, t = {S.t})")

    for row in S.H:
        print("    H = " if row is S.H[0] else "        ", row)

    d = S.min_distance()
    sep = S.is_separating()
    V = ball_volume(S.n, S.t)
    print(f"\n  minimum codeword weight d      = {d}"
          f"   (separating requires d > 2t = {2 * S.t})")
    print(f"  separating                     = {sep}")
    print(f"  ball volume V(n,t)             = {V}")
    print(f"  published bits 2^m             = {2 ** S.m}"
          f"   (universal bound: V(n,t) <= 2^m is {V <= 2 ** S.m})")
    print(f"  perfect (2^m == V(n,t))        = {S.is_perfect()}")

    # --- correctness ---
    tested, failed = check_correctness(S)
    print(f"\n  [1] CORRECTNESS  tested {tested} admissible pairs (a,b): "
          f"{failed} failures")
    if sep:
        assert failed == 0, "separating scheme must be correct"
    else:
        print("      (scheme is NOT separating, so failures are expected)")

    # --- leakage ---
    r, fiber, uniform = check_leakage(S)
    print(f"\n  [2] EXACT LEAKAGE  rank r = {r}")
    print(f"      every transcript leaves exactly 2^(n-r) = {fiber} keys: "
          f"{uniform}")
    print(f"      2^n = 2^r * 2^(n-r):  {2 ** S.n} = {2 ** r} * {fiber} = "
          f"{2 ** r * fiber}")
    assert 2 ** S.n == 2 ** r * fiber
    print(f"      leakage r = {r} bits, published m = {S.m} bits"
          + ("   <-- a published bit was FREE (dependent row)"
             if r < S.m else ""))

    # --- entropy chain rule ---
    n_ach = len(S.achievable_transcripts())
    h_tr = log2(n_ach)                       # uniform on 2^r transcripts
    h_res = log2(fiber)                      # uniform on the fiber
    print(f"\n  [3] CHAIN RULE   H(transcript) = {h_tr:.4f} bits,"
          f"  H_inf(key|transcript) = {h_res:.4f} bits")
    print(f"      sum = {h_tr + h_res:.4f}  =  n = {S.n}")
    assert abs(h_tr + h_res - S.n) < 1e-9

    # --- guessing bound ---
    best = best_guessing_strategy(S)
    print(f"\n  [4] GUESSING BOUND  best transcript-only adversary is right on "
          f"{best} of {2 ** S.n} keys")
    print(f"      bound 2^r = {2 ** r};  success probability "
          f"{best / 2 ** S.n:.6f} <= 2^(r-n) = {2 ** (r - S.n):.6f}")
    assert best <= 2 ** r

    # --- perfection ---
    if sep and S.is_perfect():
        print(f"\n  [6] PERFECT SCHEME: decoding is total, r = m = {S.m}, and")
        print(f"      V(n,t) * |consistent| = {V} * {fiber} = {V * fiber}"
              f" = 2^n = {2 ** S.n}")
        assert V * fiber == 2 ** S.n
        assert r == S.m
        table = S.syndrome_table()
        print(f"      every one of the {2 ** S.m} syndromes has a weight-<=t "
              f"explanation: {len(table) == 2 ** S.m}")


def demo_walkthrough() -> None:
    """A single concrete run of the protocol, bit by bit."""
    rule("A CONCRETE RUN OF THE PROTOCOL  ([7,4] Hamming, t = 1)")
    S = HAMMING74
    table = S.syndrome_table()

    a = (1, 0, 1, 1, 0, 0, 1)
    b = (1, 0, 1, 0, 0, 0, 1)          # Bob's bit 3 is flipped
    e_true = vec_add(a, b)

    s = S.transcript(a)
    diff = vec_add(s, S.syndrome(b))
    e_hat = S.decode(diff, table)
    out = S.correct(b, s, table)

    print(f"\n  Alice's key   a  = {a}")
    print(f"  Bob's key     b  = {b}")
    print(f"  true error    e  = {e_true}   (weight {hamming_weight(e_true)})")
    print(f"\n  Alice broadcasts  s = H a = {s}      <-- the ENTIRE transcript "
          f"({S.m} bits)")
    print(f"  Bob computes      H b   = {S.syndrome(b)}")
    print(f"  error syndrome  s - H b = {diff}")
    print(f"  Bob decodes       e^    = {e_hat}")
    print(f"  Bob outputs     b + e^  = {out}")
    print(f"\n  Bob's output equals Alice's key: {out == a}")

    fiber = S.consistent(s)
    print(f"\n  Eve sees only s = {s}.  Keys still consistent with it: "
          f"{len(fiber)} = 2^{S.n - S.rank()}")
    print("  A sample of Eve's remaining candidates:")
    for x in fiber[:6]:
        print(f"      {x}")
    print(f"      ... ({len(fiber) - 6} more)")
    print(f"\n  She has learned exactly {S.rank()} bits; "
          f"{S.n - S.rank()} bits of the key remain perfectly secret.")


def demo_collision() -> None:
    """Exhibit the decoding collision of a non-separating scheme."""
    rule("[8] FAILURE OF UNIQUE DECODING WHEN SEPARATION FAILS")
    S = BAD_PAIRING
    print(f"\n  Scheme {S.name}:  n = {S.n}, m = {S.m}, t = {S.t}")
    print(f"  nonzero codeword weights = "
          f"{sorted({hamming_weight(c) for c in S.kernel() if any(c)})}")
    print(f"  minimum distance d = {S.min_distance()}, but separation needs "
          f"d > 2t = {2 * S.t}.")

    seen: Dict[Vec, List[Vec]] = {}
    for e in all_vectors(S.n):
        if hamming_weight(e) <= S.t:
            seen.setdefault(S.syndrome(e), []).append(e)
    print("\n  Weight-<=t patterns grouped by syndrome:")
    for s, es in sorted(seen.items()):
        mark = "   <-- COLLISION" if len(es) > 1 else ""
        print(f"      syndrome {s}: {es}{mark}")

    tested, failed = check_correctness(S)
    print(f"\n  Exhaustive test: {failed} of {tested} admissible pairs are "
          f"reconciled INCORRECTLY.")
    print("  Bob cannot tell which of two single-bit flips occurred.")


def demo_universal_bound() -> None:
    """Tabulate the universal lower bound on transcript length."""
    rule("[5] THE UNIVERSAL CONVERSE:  every correct protocol needs "
         "log2 V(n,t) bits")
    print("\n  No protocol -- interactive, adaptive, nonlinear, randomised --")
    print("  can reconcile t discrepancies in n bits while publishing fewer")
    print("  than log2 V(n,t) bits.\n")
    print(f"  {'n':>6} {'t':>4} {'V(n,t)':>18} {'log2 V (bits)':>15} "
          f"{'bits needed':>12}")
    print("  " + "-" * 58)
    for n, t in [(3, 1), (7, 1), (15, 1), (255, 1), (23, 3), (63, 2),
                 (1000, 5), (10000, 50)]:
        V = ball_volume(n, t)
        shown = str(V) if V < 10 ** 12 else f"{float(V):.6e}"
        print(f"  {n:>6} {t:>4} {shown:>18} {log2(V):>15.3f} "
              f"{int(-(-log2(V) // 1)):>12}")
    print("\n  For t = 1 this is exactly log2(n+1): you must at minimum name")
    print("  the flipped position, or announce that there is none.")
    print("\n  Perfect schemes attain the bound:")
    for S in (REPETITION, HAMMING74):
        V = ball_volume(S.n, S.t)
        print(f"      {S.name:<18} 2^m = {2 ** S.m:>3} = V({S.n},{S.t}) "
              f"= {V:>3}   -> optimal")


def demo_composition() -> None:
    """Subadditivity of leakage and monotonicity of correctness."""
    rule("[7] COMPOSING ROUNDS:  leakage is subadditive, correctness monotone")

    S1 = Scheme([[1, 1, 0, 0, 0, 0, 0],
                 [0, 0, 1, 1, 0, 0, 0]], t=1, name="round 1")
    S2 = Scheme([[0, 0, 0, 0, 1, 1, 0],
                 [1, 0, 1, 0, 1, 0, 1]], t=1, name="round 2")
    S3 = Scheme([[1, 1, 0, 0, 0, 0, 0]], t=1, name="round 2' (repeats round 1)")

    for A, B in ((S1, S2), (S1, S3)):
        C = stack(A, B, t=1, name=f"{A.name} || {B.name}")
        r1, r2, r12 = A.rank(), B.rank(), C.rank()
        print(f"\n  {A.name} (rank {r1})  stacked with  {B.name} (rank {r2}):")
        print(f"      composite rank r12 = {r12}   <=   r1 + r2 = {r1 + r2}"
              f"   [subadditivity holds: {r12 <= r1 + r2}]")
        print(f"      deficiency r1 + r2 - r12 = {r1 + r2 - r12}"
              " (= dimension of the row-space overlap)")
        assert r12 <= r1 + r2

    print("\n  Monotonicity of correctness: stack the separating [7,4] Hamming")
    print("  scheme with an arbitrary extra round and re-test correctness.")
    C = stack(HAMMING74, S1, t=1, name="Hamming || round 1")
    print(f"      composite separating = {C.is_separating()}  "
          f"(Hamming alone: {HAMMING74.is_separating()})")
    tested, failed = check_correctness(C)
    print(f"      exhaustive test: {failed} failures over {tested} pairs")
    print(f"      but leakage rose from r = {HAMMING74.rank()} to "
          f"r = {C.rank()} bits: extra rounds cost privacy, never correctness.")
    assert failed == 0


def demo_free_bits() -> None:
    """Rank, not transcript length, is the leakage."""
    rule("REDUNDANT CHECKS ARE FREE:  leakage is the RANK, not the length")
    S = HAMMING_REDUNDANT
    print(f"\n  {S.name}: m = {S.m} bits published, but rank r = {S.rank()}.")
    print("  The fourth row is the sum of the first two, so it says nothing new.")
    r, fiber, uniform = check_leakage(S)
    print(f"  Keys consistent with any transcript: {fiber} = 2^(n-r) "
          f"= 2^{S.n - r}   (uniform across transcripts: {uniform})")
    print(f"  Residual min-entropy is {S.n - r} bits, not {S.n - S.m} bits:")
    print(f"      the crude bound n - m = {S.n - S.m} understates the surviving")
    print(f"      secrecy by {S.m - r} bit(s).  Privacy amplification should")
    print(f"      subtract r = {r}, not m = {S.m}.")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print(__doc__)

    report_scheme(REPETITION)
    report_scheme(HAMMING74)
    report_scheme(BAD_PAIRING)
    report_scheme(HAMMING_REDUNDANT)

    demo_walkthrough()
    demo_collision()
    demo_universal_bound()
    demo_composition()
    demo_free_bits()

    rule("SUMMARY")
    print("""
  * Correctness holds exactly, with no failure probability, precisely when
    every nonzero codeword has weight greater than 2t.
  * The transcript leaks exactly rank(H) bits -- not the number of bits
    published.  Dependent parity checks are free.
  * n = H(transcript) + H_inf(key | transcript):  every bit of the raw key
    either becomes public or stays secret.
  * No correct protocol whatsoever can publish fewer than log2 V(n,t) bits.
  * The [3,1] repetition and [7,4] Hamming schemes attain that floor exactly,
    leaving 1 and 4 secret bits respectively.
  * Stacking rounds is subadditive in leakage and safe for correctness.
""")


if __name__ == "__main__":
    main()
