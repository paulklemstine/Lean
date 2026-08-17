"""
Almost-lossless compression beyond the pigeonhole bound
=======================================================

Numerical demonstrations of every quantitative claim in the accompanying
paper, using only the Python standard library.

Contents
--------
1.  The enumerative epsilon-almost-lossless code: encode, decode, measure.
2.  The epsilon-relaxed counting bound and its exact rate characterisation.
3.  The uniform source: tolerating epsilon saves at most log2(1/(1-eps)) bits.
4.  Birthday bound for random codebooks, and its tightness at q = 2.
5.  Derandomisation: a successful Monte Carlo codebook never beats the
    deterministic enumerative code on rate, and loses badly on time.
6.  Exact decoder step counts: k + 2 versus 2^k (worst case) and
    (2^k + 1)/2 (average case).
7.  Parity checksum: every single-bit corruption is detected.
8.  Block composition: parse-free concatenation, the union bound
    1 - (1 - eps0)^n <= n*eps, and the exact cost n(k+3) + 1.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Bit = int
Word = List[Bit]
Message = str

# ---------------------------------------------------------------------------
# 1. Binary index codec
# ---------------------------------------------------------------------------


def to_bits(k: int, n: int) -> Word:
    """Little-endian k-bit expansion of n (truncating above 2^k)."""
    return [(n >> i) & 1 for i in range(k)]


def from_bits(w: Sequence[Bit]) -> int:
    """Read a little-endian bit list as a natural number."""
    value = 0
    for i, b in enumerate(w):
        value += b << i
    return value


def codec_round_trip_check(k: int) -> bool:
    """fromBits(toBits(k, n)) = n for every n < 2^k."""
    return all(from_bits(to_bits(k, n)) == n for n in range(2 ** k))


# ---------------------------------------------------------------------------
# 2. The enumerative epsilon-almost-lossless code
# ---------------------------------------------------------------------------


class EnumerativeCode:
    """Flag bit + k-bit index inside the typical set S.

    Every codeword has exactly k + 1 bits (fixed rate); messages outside S
    are sent as the explicit failure marker 0 followed by k zero bits, and
    the decoder maps every word beginning with 0 to None ("detected
    failure").  The code is sound: it never returns a wrong message.
    """

    def __init__(self, typical_set: Sequence[Message], k: int) -> None:
        if len(typical_set) > 2 ** k:
            raise ValueError(f"|S| = {len(typical_set)} exceeds 2^k = {2 ** k}")
        self.k = k
        self.table: List[Message] = list(typical_set)
        self.index: Dict[Message, int] = {x: i for i, x in enumerate(self.table)}

    def encode(self, x: Message) -> Word:
        if x in self.index:
            return [1] + to_bits(self.k, self.index[x])
        return [0] + to_bits(self.k, 0)

    def decode(self, w: Sequence[Bit]) -> Optional[Message]:
        if not w or w[0] == 0:
            return None
        idx = from_bits(w[1:])
        if idx < len(self.table):
            return self.table[idx]
        return None

    def decode_instrumented(self, w: Sequence[Bit]) -> Tuple[Optional[Message], int]:
        """Returns (answer, exact step count).

        One step per index bit, one to detect the end of the index, one for
        the flag bit's table access.  Cost on a typical message: k + 2.
        """
        if not w or w[0] == 0:
            return (None, 1)
        rest = w[1:]
        cost = len(rest) + 1 + 1  # read index bits, end marker, table access
        idx = from_bits(rest)
        if idx < len(self.table):
            return (self.table[idx], cost)
        return (None, cost)

    def good_set(self, alphabet: Sequence[Message]) -> List[Message]:
        return [x for x in alphabet if self.decode(self.encode(x)) == x]

    def fail_prob(self, p: Dict[Message, float]) -> float:
        return sum(w for x, w in p.items() if self.decode(self.encode(x)) != x)


# ---------------------------------------------------------------------------
# 3. Typical sets and the design rule
# ---------------------------------------------------------------------------


def typical_set(p: Dict[Message, float], eps: float) -> List[Message]:
    """Shortest prefix of the alphabet sorted by decreasing probability whose
    mass is at least 1 - eps.  This is the (1-eps)-quantile of the source."""
    ordered = sorted(p, key=lambda x: -p[x])
    mass, out = 0.0, []
    for x in ordered:
        if mass >= 1.0 - eps - 1e-15:
            break
        out.append(x)
        mass += p[x]
    return out


def design_rate(p: Dict[Message, float], eps: float) -> Tuple[int, int]:
    """Returns (|S|, k) for the design rule: k = ceil(log2 |S|)."""
    s = typical_set(p, eps)
    k = max(0, math.ceil(math.log2(len(s)))) if s else 0
    return len(s), k


# ---------------------------------------------------------------------------
# 4. Random codebooks: the birthday bound
# ---------------------------------------------------------------------------


def collision_prob_exact(q: int, m: int) -> float:
    """Exact probability that a uniform codebook {1..q} -> {1..m} collides:
    1 - m^{underline q} / m^q."""
    if q > m:
        return 1.0
    injective = 1.0
    for i in range(q):
        injective *= (m - i) / m
    return 1.0 - injective


def collision_prob_bound(q: int, m: int) -> float:
    """Birthday bound q(q-1)/(2m); exact at q = 2."""
    return q * (q - 1) / (2 * m)


def collision_prob_monte_carlo(q: int, m: int, trials: int, seed: int = 0) -> float:
    rng = random.Random(seed)
    bad = 0
    for _ in range(trials):
        f = [rng.randrange(m) for _ in range(q)]
        if len(set(f)) < q:
            bad += 1
    return bad / trials


# ---------------------------------------------------------------------------
# 5. Exhaustive search decoding of an unstructured codebook
# ---------------------------------------------------------------------------


def scan_decode(codebook: Sequence[Tuple[Message, Word]], w: Sequence[Bit]
                ) -> Tuple[Optional[Message], int]:
    """Left-to-right equality probes; returns (answer, number of probes)."""
    probes = 0
    for name, word in codebook:
        probes += 1
        if list(word) == list(w):
            return (name, probes)
    return (None, probes)


def scan_costs(codebook: Sequence[Tuple[Message, Word]]) -> List[int]:
    return [scan_decode(codebook, word)[1] for _, word in codebook]


# ---------------------------------------------------------------------------
# 6. Parity checksum
# ---------------------------------------------------------------------------


def parity(w: Sequence[Bit]) -> Bit:
    acc = 0
    for b in w:
        acc ^= b
    return acc


def with_parity_encode(code: EnumerativeCode, x: Message) -> Word:
    w = code.encode(x)
    return w + [parity(w)]


def with_parity_decode(code: EnumerativeCode, w: Sequence[Bit]) -> Optional[Message]:
    if parity(w) == 1:
        return None
    return code.decode(w[:-1])


def with_parity_cost(code: EnumerativeCode, x: Message) -> int:
    """One step per received bit for the checksum, plus the index decode."""
    w = with_parity_encode(code, x)
    return len(w) + code.decode_instrumented(code.encode(x))[1]


# ---------------------------------------------------------------------------
# 7. Block composition
# ---------------------------------------------------------------------------


def block_encode(code: EnumerativeCode, v: Sequence[Message]) -> Word:
    out: Word = []
    for x in v:
        out.extend(code.encode(x))
    return out


def block_decode_instrumented(code: EnumerativeCode, n: int, w: Sequence[Bit]
                              ) -> Tuple[Optional[List[Message]], int]:
    """Slice into n chunks of k+1 bits and decode each; exact step count."""
    ell = code.k + 1
    out: List[Message] = []
    cost = 0
    rest = list(w)
    for _ in range(n):
        chunk, rest = rest[:ell], rest[ell:]
        answer, c = code.decode_instrumented(chunk)
        cost += c + 1  # one slicing step per block
        if answer is None:
            return (None, cost)
        out.append(answer)
    cost += 1  # final empty-string check
    return (out, cost)


def block_fail_prob(eps0: float, n: int) -> float:
    return 1.0 - (1.0 - eps0) ** n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_codec() -> None:
    rule("1.  Binary index codec is exact below 2^k")
    for k in range(1, 9):
        assert codec_round_trip_check(k)
    print("  fromBits(toBits(k, n)) = n verified for all n < 2^k, k = 1..8.")
    print(f"  Example: toBits(5, 19) = {to_bits(5, 19)}  ->  {from_bits(to_bits(5, 19))}")


def demo_scheme() -> None:
    rule("2.  The enumerative scheme on a skewed source")
    # Zipf-like source on 32 symbols.
    alphabet = [f"m{i:02d}" for i in range(32)]
    raw = {x: 1.0 / (i + 1) ** 1.4 for i, x in enumerate(alphabet)}
    z = sum(raw.values())
    p = {x: v / z for x, v in raw.items()}

    print(f"  alphabet size N = {len(alphabet)}, "
          f"exact code needs ceil(log2 N) = {math.ceil(math.log2(len(alphabet)))} bits")
    print(f"  {'eps':>6} {'|S|':>5} {'k':>3} {'rate(bits)':>11} "
          f"{'fail prob':>11} {'steps':>7}")
    for eps in (0.30, 0.20, 0.10, 0.05, 0.01, 0.0):
        s, k = design_rate(p, eps)
        code = EnumerativeCode(typical_set(p, eps), k)
        fp = code.fail_prob(p)
        steps = code.decode_instrumented(code.encode(code.table[0]))[1]
        print(f"  {eps:6.2f} {s:5d} {k:3d} {k + 1:11d} {fp:11.5f} {steps:7d}")
        assert fp <= eps + 1e-12
        assert steps == k + 2
        assert code.good_set(alphabet) == code.table
        # soundness: an answer is always the true message
        for x in alphabet:
            ans = code.decode(code.encode(x))
            assert ans is None or ans == x
    print("  Verified for every row: fail <= eps, good set = S, decode cost = k+2,")
    print("  and soundness (an answer, when given, is always correct).")


def demo_uniform_bound() -> None:
    rule("3.  Uniform source: error tolerance saves at most log2(1/(1-eps)) bits")
    n_sym = 1024
    print(f"  {'eps':>6} {'saving (bits)':>15} {'(1-eps)N':>12} {'min t+1':>9}")
    for eps in (0.0, 0.01, 0.05, 0.10, 0.25, 0.50):
        saving = math.log2(1.0 / (1.0 - eps))
        needed = math.ceil(math.log2((1 - eps) * n_sym))
        print(f"  {eps:6.2f} {saving:15.4f} {(1 - eps) * n_sym:12.1f} {needed:9d}")
    print("  At eps = 1% the entire benefit of error tolerance is 0.0145 bits:")
    print("  the pigeonhole bound is dented, not broken.  Real gains come from")
    print("  non-uniformity, where the (1-eps)-quantile is exponentially smaller.")


def demo_exact_characterisation() -> None:
    rule("4.  Exact rate characterisation and the one-codeword price of detection")
    print("  A sound code of length <= t with good set S exists iff")
    print("     |S| + 2 <= 2^(t+1)   (S a proper subset), or")
    print("     |S| + 1 <= 2^(t+1)   (S the whole alphabet).")
    print(f"  {'t':>3} {'short strings':>14} {'max |S| (partial)':>19} {'max |S| (total)':>17}")
    for t in range(1, 9):
        strings = 2 ** (t + 1) - 1
        print(f"  {t:3d} {strings:14d} {2 ** (t + 1) - 2:19d} {strings:17d}")
    print("  The gap of exactly one entry is the codeword reserved for saying 'failed'.")


def demo_birthday() -> None:
    rule("5.  Birthday bound for random codebooks (tight at q = 2)")
    print(f"  {'q':>4} {'m':>7} {'exact':>10} {'bound':>10} {'sampled':>10}")
    for q, m in ((2, 16), (2, 256), (4, 256), (8, 256), (16, 1024), (32, 4096)):
        exact = collision_prob_exact(q, m)
        bound = collision_prob_bound(q, m)
        samp = collision_prob_monte_carlo(q, m, trials=40000, seed=q * 7 + m)
        print(f"  {q:4d} {m:7d} {exact:10.5f} {bound:10.5f} {samp:10.5f}")
        assert exact <= bound + 1e-12
    print("  At q = 2 the bound is met with equality: exactly m of the m^2")
    print("  codebooks collide, so the collision probability is exactly 1/m.")


def demo_derandomisation() -> None:
    rule("6.  Derandomisation: random codebooks buy no rate, cost exponential time")
    k = 10
    m = 2 ** k
    rng = random.Random(2026)
    size = 20  # typical-set size; the birthday bound is well below 1 here
    tries = 0
    while tries < 1000:
        tries += 1
        f = [rng.randrange(m) for _ in range(size)]
        if len(set(f)) == size:
            break
    print(f"  rate k = {k}, |S| = {size}: a collision-free random codebook was")
    print(f"  found after {tries} draw(s); the birthday bound predicts collision")
    print(f"  probability <= {collision_prob_bound(size, m):.4f} per draw")
    print(f"  (exact: {collision_prob_exact(size, m):.4f}).")
    print(f"  Success forces |S| <= 2^k = {m}: exactly the counting condition the")
    print("  deterministic enumerative code is designed from -- zero rate advantage.")
    print(f"  Deterministic decode cost: {k + 2} steps, independent of |S|.")
    print(f"  Searching this codebook: up to {size} probes, {(size + 1) / 2:.1f} on")
    print(f"  average.  At full rate (|S| = 2^k = {m}) the search costs up to {m}")
    print(f"  probes and {(m + 1) / 2:.1f} on average: a {m / (k + 2):.0f}x penalty.")


def demo_complexity() -> None:
    rule("7.  Exact decoder step counts: k + 2 versus 2^k")
    print(f"  {'k':>3} {'enum steps':>11} {'search worst':>13} {'search avg':>12} "
          f"{'speed-up':>10}")
    for k in range(1, 13):
        table = [f"x{i}" for i in range(2 ** k)]
        code = EnumerativeCode(table, k)
        enum_cost = code.decode_instrumented(code.encode(table[-1]))[1]
        assert enum_cost == k + 2
        if k <= 9:  # explicit scan only for small k
            codebook = [(x, code.encode(x)) for x in table]
            costs = scan_costs(codebook)
            worst, total = max(costs), sum(costs)
            n = len(costs)
            assert worst == n
            assert 2 * total == n * (n + 1)
            avg = total / n
        else:
            n = 2 ** k
            worst, avg = n, (n + 1) / 2
        print(f"  {k:3d} {enum_cost:11d} {worst:13d} {avg:12.1f} "
              f"{worst / enum_cost:10.1f}x")
    print("  Verified for k <= 9 by explicit scan: worst case = |codebook| probes")
    print("  and the total over all messages is exactly n(n+1)/2.")
    print("  Unbounded speed-up: for every M, k = 4M + 8 gives M(k+3) < 2^k.")
    for mfac in (1, 5, 20, 100):
        k = 4 * mfac + 8
        assert mfac * (k + 3) < 2 ** k
    print("  Checked for M = 1, 5, 20, 100.")


def demo_checksum() -> None:
    rule("8.  Parity checksum: every single-bit corruption is detected")
    table = [f"s{i}" for i in range(16)]
    k = 4
    code = EnumerativeCode(table, k)
    detected = 0
    total = 0
    for x in table:
        w = with_parity_encode(code, x)
        assert parity(w) == 0
        assert with_parity_decode(code, w) == x
        for i in range(len(w)):
            corrupted = list(w)
            corrupted[i] ^= 1
            total += 1
            if with_parity_decode(code, corrupted) is None:
                detected += 1
    print(f"  {total} single-bit corruptions tried, {detected} detected "
          f"({100.0 * detected / total:.1f}%).")
    print(f"  Codeword length with checksum: {k + 2} bits (index, flag, parity).")
    print(f"  Total decode cost: {with_parity_cost(code, table[0])} steps "
          f"= 2k + 4 = {2 * k + 4}.")


def demo_blocks() -> None:
    rule("9.  Block composition: union bound and exact linear-time cost")
    table = [f"b{i}" for i in range(8)]
    k = 3
    code = EnumerativeCode(table, k)
    rng = random.Random(11)
    for n in (1, 2, 5, 10, 25):
        v = [rng.choice(table) for _ in range(n)]
        w = block_encode(code, v)
        out, cost = block_decode_instrumented(code, n, w)
        assert out == v
        assert len(w) == n * (k + 1)
        assert cost == n * (k + 3) + 1
    print(f"  {'n':>4} {'bits sent':>10} {'decode steps':>13} {'= n(k+3)+1':>12}")
    for n in (1, 2, 5, 10, 25):
        print(f"  {n:4d} {n * (k + 1):10d} {n * (k + 3) + 1:13d} "
              f"{n * (k + 3) + 1:12d}")
    print("\n  Union bound  1 - (1 - eps0)^n  <=  n * eps0 :")
    print(f"  {'n':>5} {'eps0=0.01 exact':>17} {'n*eps0':>9} {'eps0=0.001 exact':>18} "
          f"{'n*eps0':>9}")
    for n in (1, 5, 10, 50, 100):
        e1, e2 = 0.01, 0.001
        f1, f2 = block_fail_prob(e1, n), block_fail_prob(e2, n)
        assert f1 <= n * e1 + 1e-12 and f2 <= n * e2 + 1e-12
        print(f"  {n:5d} {f1:17.6f} {n * e1:9.3f} {f2:18.6f} {n * e2:9.4f}")
    print("  The union bound is never violated (Bernoulli), and it is tight to")
    print("  first order in eps0: the loss of block composition is 1-(1-eps0)^n.")


def main() -> None:
    print(__doc__)
    demo_codec()
    demo_scheme()
    demo_uniform_bound()
    demo_exact_characterisation()
    demo_birthday()
    demo_derandomisation()
    demo_complexity()
    demo_checksum()
    demo_blocks()
    rule("All demonstrations completed; every assertion above passed.")


if __name__ == "__main__":
    main()
