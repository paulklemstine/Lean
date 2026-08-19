"""
Almost-lossless compression beyond the pigeonhole bound: numerical demonstrations.

This self-contained script demonstrates, with exact rational arithmetic wherever
a theorem asserts an identity, the following results.

  1. The counting lemma and the epsilon-relaxed pigeonhole principle:
     an alphabet C admits an eps-reliable code iff some set of at most |C|
     source words carries probability at least 1 - eps.

  2. Randomness buys nothing on a uniform source: every seeded ensemble has
     average failure probability at least 1 - |C|/|S|.

  3. The Monte Carlo scheme over F_p with the inner-product hash
     h_a(x) = <a, x>:  honest for every seed (no silent corruption),
     decoding cost exactly |T| for the linear scan, and average failure
     probability at most eps + t(t-1)/p.

  4. Exact expected decoder cost of the bucketed decoder:
     E[cost] = 1 + (t-1)/m1  exactly, for a pairwise independent bucket hash.

  5. The universal rate-time hyperbola:  sum of costs over T >= t^2/|M|,
     hence average cost per typical word >= t/|M|, for EVERY scheme and seed.

  6. Exact planar failure probability:  1 + d(p-1) bad seeds out of p^2, where
     d is the number of distinct projective directions of the difference set,
     verified against brute-force enumeration, and compared with the union
     bound.

  7. Derandomisation: for |M| > t(t-1) a perfect (collision-free) seed exists;
     we find one, and confirm the resulting deterministic scheme decodes every
     typical word correctly.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Set, Tuple

Vector = Tuple[int, ...]


# ----------------------------------------------------------------------------
# 1. Codes, honesty, failure probability, and the relaxed pigeonhole principle
# ----------------------------------------------------------------------------


def failure_probability(
    weights: Dict[int, Fraction],
    enc: Callable[[int], object],
    dec: Callable[[object], Optional[int]],
) -> Fraction:
    """Probability that dec(enc(s)) != s, over the source given by `weights`."""
    return sum((w for s, w in weights.items() if dec(enc(s)) != s), Fraction(0))


def is_honest(
    source: Sequence[int],
    enc: Callable[[int], object],
    dec: Callable[[object], Optional[int]],
) -> bool:
    """True iff the decoder never returns a wrong word (only the truth or None)."""
    return all(dec(enc(s)) in (s, None) for s in source)


def table_code(typical: Sequence[int]) -> Tuple[
    Callable[[int], Optional[int]], Callable[[Optional[int]], Optional[int]]
]:
    """The optimal-rate table code: index into T, or the explicit failure symbol.

    Alphabet size |T| + 1; decoding is a single table lookup (cost 1).
    """
    index = {s: i for i, s in enumerate(typical)}

    def enc(s: int) -> Optional[int]:
        return index.get(s)

    def dec(c: Optional[int]) -> Optional[int]:
        return None if c is None else typical[c]

    return enc, dec


def smallest_typical_set(
    weights: Dict[int, Fraction], eps: Fraction
) -> List[int]:
    """The smallest set of probability >= 1 - eps: take the heaviest words first.

    By the epsilon-relaxed pigeonhole principle its size is exactly the minimum
    number of codewords needed for an eps-reliable code.
    """
    order = sorted(weights, key=lambda s: -weights[s])
    acc, out = Fraction(0), []
    for s in order:
        if acc >= 1 - eps:
            break
        acc += weights[s]
        out.append(s)
    return out


def demo_relaxed_pigeonhole() -> None:
    print("=" * 78)
    print("1. The epsilon-relaxed pigeonhole principle")
    print("=" * 78)

    # A concentrated source on 64 words: geometric-like weights.
    raw = {s: Fraction(1, 2 ** min(s, 10) + 1) for s in range(64)}
    total = sum(raw.values())
    weights = {s: w / total for s, w in raw.items()}

    print(f"{'eps':>10} {'min |C|':>10} {'P_fail(table)':>16} {'cost':>6}")
    for eps in [Fraction(1, 2), Fraction(1, 10), Fraction(1, 100), Fraction(0)]:
        T = smallest_typical_set(weights, eps)
        enc, dec = table_code(T)
        pf = failure_probability(weights, enc, dec)
        assert pf <= eps, "table code must be eps-reliable"
        assert is_honest(list(weights), enc, dec), "table code must be honest"
        print(f"{str(eps):>10} {len(T) + 1:>10} {float(pf):>16.8f} {1:>6}")

    # Uniform source: the bound is 1 - |C|/|S| and NOTHING relaxes it.
    n = 64
    unif = {s: Fraction(1, n) for s in range(n)}
    print("\nUniform source on 64 words -- the counting bound bites:")
    for csize in [8, 32, 63, 64]:
        T = list(range(csize - 1))  # |C| = csize including the failure symbol
        enc, dec = table_code(T)
        pf = failure_probability(unif, enc, dec)
        bound = 1 - Fraction(csize, n)
        print(
            f"  |C| = {csize:>3}:  P_fail = {float(pf):.6f}"
            f"   lower bound 1 - |C|/|S| = {float(bound):.6f}"
        )
        assert pf >= bound


def demo_randomness_is_useless() -> None:
    print()
    print("=" * 78)
    print("2. A random number generator buys nothing on a uniform source")
    print("=" * 78)

    n, csize = 32, 8
    unif = {s: Fraction(1, n) for s in range(n)}
    bound = 1 - Fraction(csize, n)

    # An ensemble of 200 'random codebooks': each seed picks which csize-1
    # words are decodable.  Average failure probability can never beat `bound`.
    import random

    random.seed(20260818)
    total = Fraction(0)
    best = Fraction(1)
    trials = 200
    for _ in range(trials):
        T = random.sample(range(n), csize - 1)
        enc, dec = table_code(T)
        pf = failure_probability(unif, enc, dec)
        total += pf
        best = min(best, pf)
    avg = total / trials
    print(f"  ensemble size            : {trials}")
    print(f"  average failure prob.    : {float(avg):.6f}")
    print(f"  best single seed         : {float(best):.6f}")
    print(f"  lower bound 1 - |C|/|S|  : {float(bound):.6f}")
    assert avg >= bound and best >= bound
    print("  => no seed, and no average over seeds, beats the deterministic bound.")


# ----------------------------------------------------------------------------
# 3-4. The inner-product hash family over F_p and the scan schemes
# ----------------------------------------------------------------------------


def dot_hash(a: Vector, x: Vector, p: int) -> int:
    """The pairwise independent inner-product hash h_a(x) = <a, x> mod p."""
    return sum(ai * xi for ai, xi in zip(a, x)) % p


def all_vectors(k: int, p: int) -> List[Vector]:
    """Every vector of F_p^k, in lexicographic order."""
    return [tuple(v) for v in product(range(p), repeat=k)]


def seed_is_bad(a: Vector, typical: Sequence[Vector], p: int) -> bool:
    """True iff the seed confuses two distinct typical words."""
    seen: Set[int] = set()
    for x in typical:
        h = dot_hash(a, x, p)
        if h in seen:
            return True
        seen.add(h)
    return False


def linear_scan_decode(
    m: Optional[int], a: Vector, typical: Sequence[Vector], p: int
) -> Tuple[Optional[Vector], int]:
    """Uniqueness scan over the whole typical set; returns (answer, cost).

    The answer is returned only if exactly one candidate matches, so the
    decoder is honest for EVERY seed: it never returns a wrong word.
    """
    if m is None:
        return None, 0
    matches = [x for x in typical if dot_hash(a, x, p) == m]
    cost = len(typical)  # every typical word is tested: cost is exactly |T|
    return (matches[0] if len(matches) == 1 else None), cost


def demo_monte_carlo_scheme() -> None:
    print()
    print("=" * 78)
    print("3. The Monte Carlo compressor over F_p: honesty, cost, failure bound")
    print("=" * 78)

    p, k = 53, 3
    typical: List[Vector] = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1), (2, 5, 7)]
    t = len(typical)
    seeds = all_vectors(k, p)

    bad = [a for a in seeds if seed_is_bad(a, typical, p)]
    exact_collision_prob = Fraction(len(bad), len(seeds))
    union_bound = Fraction(t * (t - 1), p)

    # Honesty check over every seed and every transmitted typical word.
    honest_everywhere = True
    for a in seeds:
        for x in typical:
            ans, cost = linear_scan_decode(dot_hash(a, x, p), a, typical, p)
            assert cost == t, "linear scan cost is exactly |T|"
            if ans not in (x, None):
                honest_everywhere = False
    print(f"  source alphabet          : F_{p}^{k}  ({p ** k} words)")
    print(f"  codeword alphabet        : {p + 1} symbols (p field values + failure flag)")
    print(f"  typical set size t       : {t}")
    print(f"  decoding cost            : exactly {t} candidate tests (linear scan)")
    print(f"  honest for every seed    : {honest_everywhere}")
    assert honest_everywhere, "no silent corruption is allowed"
    print(f"  measured P(bad seed)     : {exact_collision_prob} "
          f"= {float(exact_collision_prob):.6f}")
    print(f"  union bound t(t-1)/p     : {union_bound} = {float(union_bound):.6f}")
    assert exact_collision_prob <= union_bound

    # With atypicality loss eps the total average failure is <= eps + t(t-1)/p.
    eps = Fraction(1, 50)
    print(f"  average failure bound    : eps + t(t-1)/p = "
          f"{float(eps + union_bound):.6f}   (eps = {eps})")


def bucketed_cost(
    a1: Vector, x: Vector, typical: Sequence[Vector], p1: int
) -> int:
    """Cost of the bucketed decoder on x: the size of x's bucket."""
    hx = dot_hash(a1, x, p1)
    return sum(1 for y in typical if dot_hash(a1, y, p1) == hx)


def demo_exact_expected_cost() -> None:
    print()
    print("=" * 78)
    print("4. Exact expected decoder cost of the bucketed decoder: 1 + (t-1)/m1")
    print("=" * 78)

    k, t = 3, 7
    print(f"  typical set size t = {t}")
    print(f"{'m1 = p1':>9} {'measured E[cost]':>20} {'1 + (t-1)/m1':>16} {'match':>7}")
    for p1 in [2, 3, 5, 7, 11, 13]:
        seeds = all_vectors(k, p1)
        # t distinct words of the domain F_{p1}^k, so pairwise independence applies
        typical: List[Vector] = seeds[1 : t + 1]
        for x in typical:
            total = sum(bucketed_cost(a1, x, typical, p1) for a1 in seeds)
            measured = Fraction(total, len(seeds))
            predicted = 1 + Fraction(t - 1, p1)
            assert measured == predicted, (x, p1, measured, predicted)
        print(f"{p1:>9} {str(measured):>20} {str(predicted):>16} {'exact':>7}")
    print("  => an identity, not a bound: for m1 >= t the cost is below 2 probes.")


def demo_rate_time_hyperbola() -> None:
    print()
    print("=" * 78)
    print("5. The universal rate-time hyperbola:  sum of costs >= t^2/|M|")
    print("=" * 78)

    k, t = 3, 7
    print(f"{'m = p1':>7} {'min total work':>16} {'t^2/m':>10} "
          f"{'min avg cost':>13} {'t/m':>8} {'1 + (t-1)/m':>13}")
    for p1 in [2, 3, 5, 7, 11]:
        seeds = all_vectors(k, p1)
        typical: List[Vector] = seeds[1 : t + 1]
        worst = None
        for a1 in seeds:
            total = sum(bucketed_cost(a1, x, typical, p1) for x in typical)
            worst = total if worst is None else min(worst, total)
        lower = Fraction(t * t, p1)
        assert worst >= lower, "Cauchy-Schwarz converse must hold for every seed"
        print(f"{p1:>7} {worst:>16} {float(lower):>10.3f} "
              f"{float(Fraction(worst, t)):>13.3f} {float(Fraction(t, p1)):>8.3f} "
              f"{float(1 + Fraction(t - 1, p1)):>13.3f}")
    print("  => achievable cost and the universal lower bound differ by < 1 probe.")


# ----------------------------------------------------------------------------
# 6. Exact planar failure probability via projective directions
# ----------------------------------------------------------------------------


def projective_directions(typical: Sequence[Vector], p: int) -> int:
    """Number of distinct projective directions among the differences of T.

    Two nonzero vectors z, w in F_p^2 give the same direction iff
    z0*w1 - z1*w0 = 0.  We normalise each direction to a canonical
    representative and count the distinct ones.
    """
    reps: Set[Vector] = set()
    for x in typical:
        for y in typical:
            if x == y:
                continue
            z = ((x[0] - y[0]) % p, (x[1] - y[1]) % p)
            if z == (0, 0):
                continue
            # canonical representative: scale so that the first nonzero entry is 1
            pivot = z[0] if z[0] != 0 else z[1]
            inv = pow(pivot, p - 2, p)
            reps.add(((z[0] * inv) % p, (z[1] * inv) % p))
    return len(reps)


def demo_exact_planar_count() -> None:
    print()
    print("=" * 78)
    print("6. Exact planar failure probability:  (1 + d(p-1)) / p^2")
    print("=" * 78)

    examples: List[Tuple[int, List[Vector]]] = [
        (11, [(1, 0), (0, 1), (2, 3)]),
        (11, [(0, 0), (1, 0), (2, 0), (3, 0)]),  # collinear: d collapses to 1
        (13, [(1, 0), (0, 1), (1, 1), (2, 5)]),
        (17, [(0, 0), (1, 2), (3, 4), (5, 9), (7, 1)]),
    ]
    print(f"{'p':>4} {'t':>3} {'d':>3} {'brute force':>12} {'1+d(p-1)':>10} "
          f"{'exact P':>10} {'union bd':>10}")
    for p, typical in examples:
        seeds = all_vectors(2, p)
        brute = sum(1 for a in seeds if seed_is_bad(a, typical, p))
        d = projective_directions(typical, p)
        predicted = 1 + d * (p - 1)
        assert brute == predicted, (p, typical, brute, predicted)
        t = len(typical)
        exact = Fraction(predicted, p * p)
        union = min(Fraction(t * (t - 1), p), Fraction(1))
        print(f"{p:>4} {t:>3} {d:>3} {brute:>12} {predicted:>10} "
              f"{float(exact):>10.5f} {float(union):>10.5f}")
    print("  => the theorem matches exhaustive enumeration in every case;")
    print("     the union bound is loose whenever differences share a direction.")


# ----------------------------------------------------------------------------
# 7. Derandomisation: an explicit perfect seed
# ----------------------------------------------------------------------------


def find_perfect_seed(
    typical: Sequence[Vector], p: int, k: int
) -> Optional[Vector]:
    """Search for a seed that hashes T injectively.  One exists if p > t(t-1)."""
    for a in all_vectors(k, p):
        if not seed_is_bad(a, typical, p):
            return a
    return None


def next_prime(n: int) -> int:
    """The least prime strictly greater than n (Bertrand guarantees p <= 2n)."""
    def is_prime(m: int) -> bool:
        if m < 2:
            return False
        i = 2
        while i * i <= m:
            if m % i == 0:
                return False
            i += 1
        return True

    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def demo_derandomisation() -> None:
    print()
    print("=" * 78)
    print("7. Derandomisation: an explicit deterministic scheme at quadratic rate")
    print("=" * 78)

    k = 2
    typical: List[Vector] = [(1, 0), (0, 1), (2, 3), (4, 5), (6, 1)]
    t = len(typical)
    p = next_prime(t * t)  # t^2 < p <= 2t^2 by Bertrand's postulate
    assert t * t < p <= 2 * t * t
    a = find_perfect_seed(typical, p, k)
    assert a is not None, "a perfect seed must exist once p > t(t-1)"

    # Verify: zero failure on the typical set, honest, cost exactly t.
    ok = True
    for x in typical:
        ans, cost = linear_scan_decode(dot_hash(a, x, p), a, typical, p)
        ok = ok and (ans == x) and (cost == t)
    print(f"  t = {t},  prime p = {p}  (t^2 = {t * t} < p <= 2t^2 = {2 * t * t})")
    print(f"  perfect seed found       : {a}")
    print(f"  decodes all of T exactly : {ok}")
    print(f"  deterministic P_fail on T: 0")
    print(f"  codeword alphabet        : {p + 1} symbols  "
          f"(optimum would be {t + 1}: the birthday/squaring penalty)")
    print(f"  decoding cost            : exactly {t} candidate tests")
    assert ok


def main() -> None:
    demo_relaxed_pigeonhole()
    demo_randomness_is_useless()
    demo_monte_carlo_scheme()
    demo_exact_expected_cost()
    demo_rate_time_hyperbola()
    demo_exact_planar_count()
    demo_derandomisation()
    print()
    print("All demonstrations completed: every asserted identity was verified.")


if __name__ == "__main__":
    main()
