"""
Almost-Lossless Compression Beyond the Pigeonhole Bound
=======================================================

Self-contained numerical demonstrations of the results of the accompanying
paper.  Nothing is imported beyond the Python standard library.

The demonstrations, in order:

  1.  The relaxed pigeonhole converse   Pr[success] <= |Code| * p_max
      and its exact attainment  Pr[success] = M / n  on the uniform source.

  2.  2-universality of the inner-product family  h_k(x1,x2) = x1 + k*x2
      over F_p, verified by exhaustive collision counting.

  3.  Derandomized achievability: search the key space for a key whose
      failure mass is at most  delta + |l|/M, and compare with the bound.

  4.  Silent corruption: exhaustive check that a codebook symbol is never
      silently corrupted, and measurement of the off-codebook silent mass
      against the sharp bound  2*delta*|l|/M.

  5.  Sorted codebook + binary search: a cost-instrumented decoder whose
      measured worst-case cost is compared with the proved bound
      log2(n) + 3, and with the decision-tree converse log2(n).

  6.  Checksum amplification: pairing two universal families multiplies the
      collision parameter, so silent corruption falls to |l|/(M*C).

  7.  List decoding: linear gain  delta + |l|/(T*M)  from 2-universality
      versus exponential gain  delta + (|l|/M)^T  from the degree-T
      polynomial family over F_p.

  8.  Key-space lower bound: exhaustive confirmation that a compressing
      2-universal family needs at least M keys.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Symbol = Tuple[int, int]


# ---------------------------------------------------------------------------
# Section 0.  Distributions and min-entropy
# ---------------------------------------------------------------------------


def normalise(weights: Dict[object, float]) -> Dict[object, float]:
    """Normalise a weight table into a probability distribution."""
    total = sum(weights.values())
    return {x: w / total for x, w in weights.items()}


def p_max(mu: Dict[object, float]) -> float:
    """Largest single-symbol probability."""
    return max(mu.values())


def min_entropy(mu: Dict[object, float]) -> float:
    """H_inf(mu) = -log2 p_max(mu)."""
    return -math.log2(p_max(mu))


def set_mass(mu: Dict[object, float], subset: Sequence[object]) -> float:
    """Total probability mass of a set of symbols."""
    s = set(subset)
    return sum(p for x, p in mu.items() if x in s)


# ---------------------------------------------------------------------------
# Section 1.  The relaxed pigeonhole bound and its tightness
# ---------------------------------------------------------------------------


def prefix_scheme_success(n: int, m: int) -> float:
    """
    The tightness construction.  Source = uniform on {0,...,n-1}, code space
    of size m <= n.  Encode  x -> x  when x < m, else  x -> 0;  decode
    i -> i.  The success set is exactly {0,...,m-1}, of mass m/n.
    """
    def enc(x: int) -> int:
        return x if x < m else 0

    def dec(i: int) -> Optional[int]:
        return i

    success = [x for x in range(n) if dec(enc(x)) == x]
    return len(success) / n


def demo_converse_and_tightness() -> None:
    print("=" * 74)
    print("1.  The relaxed pigeonhole bound, and that it is attained")
    print("=" * 74)
    n = 64
    mu_uniform = normalise({x: 1.0 for x in range(n)})
    print(f"    uniform source on n = {n} symbols,  p_max = {p_max(mu_uniform):.6f},"
          f"  H_inf = {min_entropy(mu_uniform):.3f} bits")
    print()
    print("      M   converse |C|*p_max   achieved M/n   equal?")
    for m in (1, 2, 8, 16, 48, 64):
        bound = m * p_max(mu_uniform)
        achieved = prefix_scheme_success(n, m)
        print(f"    {m:3d}   {bound:16.6f}   {achieved:12.6f}   "
              f"{'yes' if abs(bound - achieved) < 1e-12 else 'NO'}")
    print()
    print("    Converse in entropy form:  log|C| >= H_inf + log(1-eps).")
    for eps in (0.0, 0.01, 0.1, 0.5):
        need = min_entropy(mu_uniform) + math.log2(1 - eps)
        print(f"      eps = {eps:4.2f}:  log|C| >= {need:7.4f} bits"
              f"   (cost of the relaxation: {math.log2(1 - eps):+7.4f} bits)")
    print()


# ---------------------------------------------------------------------------
# Section 2.  The inner-product family over F_p
# ---------------------------------------------------------------------------


def lin_hash(p: int, k: int) -> Callable[[Symbol], int]:
    """h_k(x1, x2) = x1 + k*x2  mod p, on the source F_p x F_p."""
    def h(x: Symbol) -> int:
        return (x[0] + k * x[1]) % p
    return h


def check_universal2(p: int) -> Tuple[int, float]:
    """
    Exhaustively count, over all unordered pairs of distinct source symbols,
    the largest number of keys under which they collide.  2-universality
    requires  (that number) * M <= K,  here  count * p <= p, i.e. count <= 1.
    """
    domain = [(a, b) for a in range(p) for b in range(p)]
    worst = 0
    for x, y in itertools.combinations(domain, 2):
        colliding = sum(1 for k in range(p) if lin_hash(p, k)(x) == lin_hash(p, k)(y))
        worst = max(worst, colliding)
    return worst, worst * p / p


def demo_universal_family() -> None:
    print("=" * 74)
    print("2.  The inner-product family  h_k(x1,x2) = x1 + k*x2  over F_p")
    print("=" * 74)
    for p in (5, 7, 11):
        worst, ratio = check_universal2(p)
        print(f"    p = {p:2d}:  source {p*p:4d} symbols -> {p:2d} codewords "
              f"({math.log2(p*p):.2f} bits -> {math.log2(p):.2f} bits);  "
              f"worst-case colliding keys = {worst}  (need <= K/M = 1)  "
              f"{'OK' if worst * p <= p else 'FAIL'}")
    print()


# ---------------------------------------------------------------------------
# Section 3-4.  Achievability, derandomization, and silent corruption
# ---------------------------------------------------------------------------


def unique_match_decode(
    h: Callable[[Symbol], int], codebook: Sequence[Symbol], received: int
) -> Tuple[Optional[Symbol], int]:
    """
    The linear unique-match decoder.  Returns (answer, cost) where cost is the
    exact number of key evaluations, namely len(codebook).  The answer is the
    unique codebook entry hashing to `received`, or None if the match is not
    unique.
    """
    found: Optional[Symbol] = None
    count = 0
    cost = 0
    for y in codebook:
        cost += 1
        if h(y) == received:
            count += 1
            found = y
    return (found if count == 1 else None), cost


def scheme_statistics(
    p: int,
    k: int,
    mu: Dict[Symbol, float],
    codebook: Sequence[Symbol],
) -> Dict[str, float]:
    """Exact failure / silent-corruption masses and decoding cost for one key."""
    h = lin_hash(p, k)
    fail = 0.0
    silent = 0.0
    cost = 0
    for x, prob in mu.items():
        answer, c = unique_match_decode(h, codebook, h(x))
        cost = max(cost, c)
        if answer != x:
            fail += prob
            if answer is not None:
                silent += prob
    return {"failure": fail, "silent": silent, "cost": float(cost)}


def demo_achievability(seed: int = 20260818) -> None:
    print("=" * 74)
    print("3-4.  Derandomized achievability, and the silent-error guarantee")
    print("=" * 74)
    rng = random.Random(seed)
    p = 23
    domain = [(a, b) for a in range(p) for b in range(p)]
    codebook = rng.sample(domain, 8)

    # A source concentrated on the codebook: mass delta escapes it.
    delta = 0.05
    weights: Dict[Symbol, float] = {}
    for x in domain:
        weights[x] = 1.0 if x in codebook else 0.0
    inside = sum(weights.values())
    for x in domain:
        if x in codebook:
            weights[x] = weights[x] / inside * (1 - delta)
        else:
            weights[x] = delta / (len(domain) - len(codebook))
    mu = normalise(weights)

    m = p
    n_l = len(codebook)
    bound_fail = delta + n_l / m
    bound_silent = n_l / m
    bound_silent_sharp = 2 * delta * n_l / m
    bound_fail_sharp = delta + 2 * n_l / m

    print(f"    p = {p}, source {len(domain)} symbols, codebook |l| = {n_l},"
          f" M = {m}, delta = {delta}")
    print(f"    first-moment bounds:  failure <= {bound_fail:.5f},"
          f"  silent <= {bound_silent:.5f}")
    print(f"    sharp bounds:         failure <= {bound_fail_sharp:.5f},"
          f"  silent <= {bound_silent_sharp:.5f}")
    print()

    stats = [(k, scheme_statistics(p, k, mu, codebook)) for k in range(p)]
    good = [(k, s) for k, s in stats if s["failure"] <= bound_fail]
    sharp = [(k, s) for k, s in stats
             if s["failure"] <= bound_fail_sharp and s["silent"] <= bound_silent_sharp]

    print(f"    keys meeting the first-moment failure bound: {len(good)}/{p}"
          f"   (the theory guarantees at least one)")
    print(f"    keys meeting BOTH sharp bounds simultaneously: {len(sharp)}/{p}"
          f"   (the theory guarantees at least one)")
    best_k, best = min(stats, key=lambda kv: kv[1]["failure"])
    print(f"    best key k = {best_k}:  failure = {best['failure']:.5f},"
          f"  silent = {best['silent']:.5f},  cost = {int(best['cost'])} evaluations")
    print()

    # Silent corruption on the codebook is impossible for EVERY key.
    violations = 0
    for k in range(p):
        h = lin_hash(p, k)
        for x in codebook:
            answer, _ = unique_match_decode(h, codebook, h(x))
            if answer is not None and answer != x:
                violations += 1
    print(f"    exhaustive check over all {p} keys and all {n_l} codebook symbols:")
    print(f"      silent corruptions of a codebook symbol = {violations}"
          f"   (theory: always 0, unconditionally)")
    print()


# ---------------------------------------------------------------------------
# Section 5.  Sorted codebook and the logarithmic decoder
# ---------------------------------------------------------------------------


def bsearch(key: Callable[[int], int], t: int, lo: int, length: int
            ) -> Tuple[Optional[int], int]:
    """
    Cost-instrumented binary search over the index range [lo, lo+length).
    Returns (index or None, number of key evaluations).  The proved bound is
    cost <= floor(log2(length)) + 1.
    """
    if length == 0:
        return None, 0
    half = length // 2
    m = lo + half
    if key(m) == t:
        return m, 1
    if key(m) < t:
        idx, c = bsearch(key, t, m + 1, length - half - 1)
        return idx, c + 1
    idx, c = bsearch(key, t, lo, half)
    return idx, c + 1


def bs_decode(key: Callable[[int], int], arr: Sequence[Symbol], n: int, t: int
              ) -> Tuple[Optional[Symbol], int]:
    """
    The logarithmic decoder: binary search plus a two-neighbour uniqueness
    test.  Abstains (returns None) whenever the hash value found is repeated
    at a neighbour, so a duplicate hash can never produce a confident answer.
    Proved cost bound: floor(log2(n)) + 3.
    """
    idx, cost = bsearch(key, t, 0, n)
    if idx is None:
        return None, cost
    if idx > 0:
        cost += 1
        if key(idx - 1) == t:
            return None, cost
    if idx + 1 < n:
        cost += 1
        if key(idx + 1) == t:
            return None, cost
    return arr[idx], cost


def demo_logarithmic_decoder(seed: int = 4242) -> None:
    print("=" * 74)
    print("5.  Sorting the codebook turns the scan into a binary search")
    print("=" * 74)
    rng = random.Random(seed)
    p = 1009
    domain = [(a, b) for a in range(p) for b in range(p)]

    print("       |l|   linear cost   measured bs cost   proved log2|l|+3"
          "   converse log2|l|")
    for n_l in (8, 16, 64, 256, 1024):
        codebook = rng.sample(domain, n_l)
        k = rng.randrange(p)
        h = lin_hash(p, k)
        # Sort AFTER the key is chosen: a permutation, invisible to the analysis.
        order = sorted(range(n_l), key=lambda i: h(codebook[i]))
        arr = [codebook[i] for i in order]
        keys = [h(y) for y in arr]

        def key_fn(i: int) -> int:
            return keys[i]

        worst = 0
        for x in arr:
            _, c = bs_decode(key_fn, arr, n_l, h(x))
            worst = max(worst, c)
        proved = int(math.log2(n_l)) + 3
        converse = int(math.log2(n_l))
        print(f"    {n_l:6d}   {n_l:11d}   {worst:16d}   {proved:16d}"
              f"   {converse:16d}")

    print()
    print("    Speedup log2(n)+3 < n holds for every n >= 6:")
    for n in (5, 6, 7, 10, 100, 10000):
        lhs = int(math.log2(n)) + 3
        print(f"      n = {n:6d}:  log2(n)+3 = {lhs:3d}  {'<' if lhs < n else '>='} "
              f" n = {n}   {'(speedup)' if lhs < n else '(no speedup, n < 6)'}")
    print()

    # Soundness holds even for a deliberately non-monotone key function: any
    # index the decoder returns really does carry the received value, so the
    # decoder can be made to abstain but never to answer off-target.
    bad_keys = [rng.randrange(50) for _ in range(64)]
    arr64 = [(i, 0) for i in range(64)]
    unsound = 0
    answered = 0
    for t in range(50):
        ans, _ = bs_decode(lambda i: bad_keys[i], arr64, 64, t)
        if ans is not None:
            answered += 1
            if bad_keys[arr64.index(ans)] != t:
                unsound += 1
    print("    adversarial (non-monotone, duplicate-heavy) key function:")
    print(f"      confident answers = {answered}, of which off-target = {unsound}")
    print("      (theory: off-target answers are always 0, with no hypothesis on")
    print("       the hash; monotonicity is only needed for the decoder to find")
    print("       a match at all, and it is supplied for free by sorting)")
    print()


# ---------------------------------------------------------------------------
# Section 6.  Checksums
# ---------------------------------------------------------------------------


def demo_checksum() -> None:
    print("=" * 74)
    print("6.  Checksums: universality is multiplicative under pairing")
    print("=" * 74)
    n_l, m = 16, 64
    delta = 0.02
    print(f"    |l| = {n_l}, M = {m}, delta = {delta}")
    print("        C   extra bits   silent bound |l|/(M*C)")
    for c in (1, 4, 16, 256, 1024):
        print(f"    {c:5d}   {math.log2(c):10.1f}   {n_l / (m * c):22.8f}")
    print()
    print("    Tunable derandomization: silent <= (1+eta)*delta*|l|/M,"
          " failure <= delta + (1+1/eta)*|l|/M")
    print("        eta     silent bound     failure bound")
    for eta in (0.1, 0.5, 1.0, 2.0, 10.0):
        s = (1 + eta) * delta * n_l / m
        f = delta + (1 + 1 / eta) * n_l / m
        print(f"    {eta:7.2f}   {s:14.6f}   {f:15.6f}")
    print("    (eta -> 0 drives the silent constant to 1, the first-moment optimum)")
    print()


# ---------------------------------------------------------------------------
# Section 7.  List decoding, linear versus exponential gain
# ---------------------------------------------------------------------------


def poly_hash(p: int, coeffs: Sequence[int]) -> Callable[[int], int]:
    """h_c(x) = c0 + c1*x + ... + cT*x^T  mod p."""
    def h(x: int) -> int:
        acc = 0
        for c in reversed(coeffs):
            acc = (acc * x + c) % p
        return acc
    return h


def demo_list_decoding() -> None:
    print("=" * 74)
    print("7.  List decoding: linear gain vs exponential gain")
    print("=" * 74)
    n_l, m, delta = 10, 101, 0.01
    print(f"    |l| = {n_l}, M = {m}, delta = {delta}")
    print("        T   2-universal: delta+|l|/(T*M)   Indep_T: delta+C(|l|,T)/M^T"
          "   readable (|l|/M)^T")
    for t in (1, 2, 3, 4):
        linear = delta + n_l / (t * m)
        exact = delta + math.comb(n_l, t) / m ** t
        readable = delta + (n_l / m) ** t
        print(f"    {t:5d}   {linear:28.8f}   {exact:28.8f}   {readable:19.8f}")
    print()
    print("    Rate cost of a list of length T is exactly log2(T) bits:")
    for t in (1, 2, 4, 8):
        print(f"      T = {t}:  {math.log2(t):.2f} bits")
    print()

    # Key length: polynomial family vs the family of all functions.
    p, t = 101, 3
    poly_keys = p ** (t + 1)
    full_keys_log2 = p * math.log2(p)
    print(f"    key length over F_{p} with T = {t}:")
    print(f"      degree-T polynomial family: {poly_keys} keys = "
          f"{math.log2(poly_keys):.1f} bits of advice")
    print(f"      family of all functions:    {p}^{p} keys = "
          f"{full_keys_log2:.1f} bits of advice")
    print(f"      separation factor in bits:  {full_keys_log2 / math.log2(poly_keys):.0f}x")
    print()

    # Small exhaustive verification that the polynomial family is Indep_T.
    p_small, t_small = 5, 2
    domain = list(range(p_small))
    all_coeffs = list(itertools.product(range(p_small), repeat=t_small + 1))
    worst_frac = 0.0
    for x in domain:
        others = [y for y in domain if y != x]
        for subset in itertools.combinations(others, t_small):
            hits = 0
            for c in all_coeffs:
                h = poly_hash(p_small, c)
                if all(h(y) == h(x) for y in subset):
                    hits += 1
            worst_frac = max(worst_frac, hits / len(all_coeffs))
    print(f"    exhaustive Indep_T check, p = {p_small}, T = {t_small}:")
    print(f"      worst key fraction making T symbols collide with x = {worst_frac:.6f}")
    print(f"      required bound M^-T = {p_small ** -t_small:.6f}   "
          f"{'OK' if worst_frac <= p_small ** -t_small + 1e-12 else 'FAIL'}")
    print()


# ---------------------------------------------------------------------------
# Section 8.  The key-space lower bound  K >= M
# ---------------------------------------------------------------------------


def demo_key_bound() -> None:
    print("=" * 74)
    print("8.  A compressing 2-universal family needs at least M keys")
    print("=" * 74)
    print("    Exhaustive search over all families H : [K] x [n] -> [M] with")
    print("    n = 3, M = 2 (so M < n: the family really compresses).")
    n, m = 3, 2
    for k in (1, 2, 3):
        found = None
        for family in itertools.product(
            list(itertools.product(range(m), repeat=n)), repeat=k
        ):
            ok = True
            for x, y in itertools.combinations(range(n), 2):
                colliding = sum(1 for j in range(k) if family[j][x] == family[j][y])
                if colliding * m > k:
                    ok = False
                    break
            if ok:
                found = family
                break
        status = "exists" if found else "impossible"
        expect = "allowed (K >= M)" if k >= m else "forbidden (K < M)"
        print(f"      K = {k}:  2-universal family {status:11s}   -- theory says {expect}")
    print()
    print("    The bound is attained: the inner-product family over F_p has")
    print("    K = M = p on a source of p^2 symbols, so the encoder's advice is")
    print("    exactly one codeword long.")
    for p in (7, 101, 65537):
        print(f"      p = {p:6d}:  source {p*p} symbols, K = M = {p},"
              f"  advice {math.log2(p):.1f} bits, message {2*math.log2(p):.1f} bits")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("ALMOST-LOSSLESS COMPRESSION BEYOND THE PIGEONHOLE BOUND")
    print("Numerical demonstrations")
    print()
    demo_converse_and_tightness()
    demo_universal_family()
    demo_achievability()
    demo_logarithmic_decoder()
    demo_checksum()
    demo_list_decoding()
    demo_key_bound()
    print("=" * 74)
    print("Summary")
    print("=" * 74)
    print("  * Allowing failure eps relaxes the counting bound by exactly")
    print("    log2(1-eps) bits, and the relaxed bound is attained.")
    print("  * A 2-universal hash with a unique-match rule never lies about a")
    print("    codebook symbol, for every key, with no probabilistic hypothesis.")
    print("  * Sorting the codebook after the key is chosen costs nothing in the")
    print("    analysis and reduces decoding from |l| to at most log2|l|+3")
    print("    key evaluations -- within an additive 3 of the log2|l| converse.")
    print("  * Lists cost exactly log2(T) bits of rate and buy a factor T with")
    print("    2-universality, or a factor (M/|l|)^T with (T+1)-wise independence.")
    print("  * The encoder's key must be at least as long as one codeword,")
    print("    and one codeword's worth of advice suffices.")
    print()


if __name__ == "__main__":
    main()
