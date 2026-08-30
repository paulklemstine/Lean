"""
Numerical demonstration of the analysis of the modular Berggren descent.

The Berggren tree enumerates every primitive Pythagorean triple exactly once,
starting from (3, 4, 5), via three fixed integer matrices whose entries all lie
in {-2, -1, 1, 2, 3}.  Reducing the tree modulo N gives a multiplication-free,
deterministic, non-repeating residue stream, and hence a candidate factoring
heuristic: walk the tree and test gcd(hypotenuse, N).

This script verifies, numerically, the four pillars of the analysis.

  1. Hit count.        The residues x < N with 1 < gcd(x, N) < N number exactly
                       N - 1 - phi(N), and exactly p + q - 2 when N = p*q.
                       Hence the per-node hit density is ~ 1 / p_min.

  2. Congruence law.   Every prime divisor of the hypotenuse of a primitive
                       Pythagorean triple is congruent to 1 modulo 4.  Therefore
                       the hypotenuse dive is identically blind on Blum integers
                       N = p*q with p = q = 3 (mod 4), and when only p = 3 (mod 4)
                       it can reach only p - 1 of the p + q - 2 revealing classes.

  3. Guidance null.    The exact number of successful t-node streams is
                       (N^s - (N - r)^s) * N^(t - s) with s = |S|, r the number of
                       revealing residues.  It depends on the inspection schedule
                       only through its cardinality, so no ordering or selection
                       rule can help at matched node budget.

  4. Trial-division    Any schedule with 4|S| < p succeeds on fewer than half of
     scaling.          all streams, so constant success costs Omega(p_min) nodes:
                       the scaling exponent is alpha = 1.  A pair (birthday) test
                       on the same budget t ~ 2*sqrt(p) succeeds at least 30% of
                       the time -- an unconditional quadratic separation.

Run with:  python3 demo.py
Standard library only.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Dict, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]

# ---------------------------------------------------------------------------
# 1. The Berggren tree
# ---------------------------------------------------------------------------

BERGGREN_MATRICES: Tuple[Tuple[Tuple[int, int, int], ...], ...] = (
    ((1, -2, 2), (2, -1, 2), (2, -2, 3)),   # B1
    ((1, 2, 2), (2, 1, 2), (2, 2, 3)),      # B2
    ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),   # B3
)

ROOT: Triple = (3, 4, 5)


def apply_matrix(matrix: Sequence[Sequence[int]], triple: Triple) -> Triple:
    """Apply a 3x3 integer matrix to a triple.  Only +-1, +-2, 3 coefficients
    occur, so this is multiplication-free in practice (adds and doublings)."""
    a, b, c = triple
    out = tuple(row[0] * a + row[1] * b + row[2] * c for row in matrix)
    return (out[0], out[1], out[2])


def berggren_bfs(limit: int) -> Iterator[Tuple[str, Triple]]:
    """Breadth-first traversal of the Berggren tree, yielding (address, triple).

    The address is the word of moves ('1', '2', '3') applied to the root.
    """
    frontier: List[Tuple[str, Triple]] = [("", ROOT)]
    emitted = 0
    while frontier and emitted < limit:
        next_frontier: List[Tuple[str, Triple]] = []
        for address, triple in frontier:
            yield address, triple
            emitted += 1
            if emitted >= limit:
                return
            for index, matrix in enumerate(BERGGREN_MATRICES, start=1):
                next_frontier.append((address + str(index), apply_matrix(matrix, triple)))
        frontier = next_frontier


def is_primitive_pythagorean(triple: Triple) -> bool:
    a, b, c = triple
    return a * a + b * b == c * c and math.gcd(math.gcd(a, b), c) == 1


# ---------------------------------------------------------------------------
# 2. Revealing residues and the exact dive count
# ---------------------------------------------------------------------------

def euler_phi(n: int) -> int:
    """Euler's totient by trial factorisation (n is small in this demo)."""
    result = n
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            result -= result // d
        d += 1
    if m > 1:
        result -= result // m
    return result


def reveal_set(n: int) -> List[int]:
    """The residues x < n with 1 < gcd(x, n) < n."""
    return [x for x in range(n) if 1 < math.gcd(x, n) < n]


def hit_density(p: int, q: int) -> Fraction:
    """Per-node probability that a uniform residue reveals a factor of p*q."""
    return Fraction(p + q - 2, p * q)


def exact_hit_count(n: int, t: int, s: int) -> int:
    """Number of t-node streams over Z/n on which a schedule of size s succeeds.

    Theorem (exact success count):  (n^s - (n - r)^s) * n^(t - s),
    where r = |reveal_set(n)| = n - 1 - phi(n).
    """
    r = n - 1 - euler_phi(n)
    return (n ** s - (n - r) ** s) * n ** (t - s)


def brute_force_hit_count(n: int, t: int, schedule: Sequence[int]) -> int:
    """Direct enumeration of successful streams (exponential; tiny cases only)."""
    revealing = set(reveal_set(n))
    total = 0
    for code in range(n ** t):
        stream = []
        rest = code
        for _ in range(t):
            stream.append(rest % n)
            rest //= n
        if any(stream[i] in revealing for i in schedule):
            total += 1
    return total


# ---------------------------------------------------------------------------
# 3. Dives, pair tests, and empirical scaling
# ---------------------------------------------------------------------------

def hypotenuse_dive(n: int, budget: int) -> Tuple[int, int]:
    """Walk the mod-n Berggren tree, gcd-testing every hypotenuse.

    Returns (nodes_used, factor_found), with factor_found == 0 on failure.
    """
    for index, (_, triple) in enumerate(berggren_bfs(budget), start=1):
        c = triple[2] % n
        g = math.gcd(c, n)
        if 1 < g < n:
            return index, g
    return budget, 0


def random_value_dive(n: int, p_min_hint: int, budget: int, rng: random.Random) -> Tuple[int, int]:
    """The idealised dive: uniform residues mod n, gcd-tested one by one."""
    del p_min_hint
    for step in range(1, budget + 1):
        x = rng.randrange(n)
        g = math.gcd(x, n)
        if 1 < g < n:
            return step, g
    return budget, 0


def pair_test(n: int, p: int, budget: int, rng: random.Random) -> Tuple[int, int]:
    """The rho-style pair test: look for two distinct values congruent mod p.

    A distinct congruent pair x < y gives gcd(y - x, n) = p exactly.
    """
    seen: Dict[int, int] = {}
    for step in range(1, budget + 1):
        x = rng.randrange(n)
        key = x % p
        if key in seen and seen[key] != x:
            g = math.gcd(abs(x - seen[key]), n)
            if 1 < g < n:
                return step, g
        seen[key] = x
    return budget, 0


def fit_exponent(sizes: Sequence[int], costs: Sequence[float]) -> float:
    """Least-squares slope of log(cost) against log(size): the exponent alpha."""
    xs = [math.log(s) for s in sizes]
    ys = [math.log(c) for c in costs]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_tree() -> None:
    print("=" * 74)
    print("1. THE BERGGREN TREE: every node is a primitive Pythagorean triple")
    print("=" * 74)
    nodes = list(berggren_bfs(13))
    for address, triple in nodes:
        label = address if address else "(root)"
        assert is_primitive_pythagorean(triple), triple
        print(f"   {label:>5s}  {str(triple):>16s}   hypotenuse {triple[2]:>5d}")
    checked = list(berggren_bfs(4000))
    assert all(is_primitive_pythagorean(t) for _, t in checked)
    assert len({t for _, t in checked}) == len(checked)
    print(f"\n   verified: all {len(checked)} nodes primitive and pairwise distinct")


def demo_congruence_law() -> None:
    print()
    print("=" * 74)
    print("2. CONGRUENCE LAW: every prime factor of a hypotenuse is 1 mod 4")
    print("=" * 74)

    def prime_factors(m: int) -> List[int]:
        factors: List[int] = []
        d = 2
        while d * d <= m:
            while m % d == 0:
                factors.append(d)
                m //= d
            d += 1
        if m > 1:
            factors.append(m)
        return factors

    bad = 0
    residues: Dict[int, int] = {1: 0, 3: 0}
    for _, triple in berggren_bfs(4000):
        for r in prime_factors(triple[2]):
            residues[r % 4] = residues.get(r % 4, 0) + 1
            if r % 4 != 1:
                bad += 1
    print(f"   prime factors of hypotenuses over 4000 nodes:")
    print(f"     congruent to 1 mod 4 : {residues[1]}")
    print(f"     congruent to 3 mod 4 : {residues[3]}   <-- must be zero")
    assert bad == 0

    print("\n   consequence -- Blum immunity (p = q = 3 mod 4):")
    for n in (21, 33, 77, 3 * 7 * 11):
        gcds = {math.gcd(t[2] % n, n) for _, t in berggren_bfs(3000)}
        print(f"     N = {n:>4d}: gcd values ever seen = {sorted(gcds)}")
        assert gcds == {1}

    print("\n   consequence -- one bad prime (p = 3 mod 4, q = 1 mod 4):")
    for p, q in ((3, 5), (7, 13), (11, 17)):
        n = p * q
        gcds = {math.gcd(t[2] % n, n) for _, t in berggren_bfs(3000)}
        print(f"     N = {p}*{q} = {n:>4d}: gcds seen = {sorted(gcds)}  (p={p} unreachable)")
        assert p not in gcds

    print("\n   contrast -- both primes 1 mod 4, the dive works:")
    for p, q in ((5, 13), (13, 17), (5, 29)):
        n = p * q
        used, found = hypotenuse_dive(n, 3000)
        print(f"     N = {p}*{q} = {n:>4d}: found {found} after {used} nodes")
        assert found in (p, q)


def demo_hit_count() -> None:
    print()
    print("=" * 74)
    print("3. HIT COUNT: |reveal_set(N)| = N - 1 - phi(N) = p + q - 2")
    print("=" * 74)
    print(f"   reveal_set(15) = {reveal_set(15)}   (3 + 5 - 2 = 6 elements)")
    print()
    print(f"   {'p':>4s} {'q':>5s} {'N':>7s} {'|R(N)|':>8s} {'p+q-2':>7s} {'density':>12s} {'1/p_min':>10s}")
    for p, q in ((3, 5), (5, 13), (7, 11), (11, 23), (13, 37), (17, 61)):
        n = p * q
        r = len(reveal_set(n))
        d = hit_density(p, q)
        assert r == p + q - 2 == n - 1 - euler_phi(n)
        print(f"   {p:>4d} {q:>5d} {n:>7d} {r:>8d} {p + q - 2:>7d} "
              f"{float(d):>12.6f} {1.0 / min(p, q):>10.6f}")
    print("\n   reachable classes when p = 3 mod 4 (only nonzero multiples of q):")
    for p, q in ((3, 5), (7, 13), (11, 17)):
        n = p * q
        reachable = [x for x in reveal_set(n) if x % p != 0]
        print(f"     N = {n:>4d}: reachable {len(reachable):>3d} of {p + q - 2:>3d} "
              f"(predicted p - 1 = {p - 1})")
        assert len(reachable) == p - 1


def demo_guidance_null() -> None:
    print()
    print("=" * 74)
    print("4. GUIDANCE NULL: the success count depends only on |S|")
    print("=" * 74)
    n, t = 15, 4
    schedules = [(0,), (3,), (0, 1), (1, 3), (0, 2), (0, 1, 2), (1, 2, 3)]
    print(f"   N = {n}, budget t = {t}, all {n ** t} streams enumerated\n")
    print(f"   {'schedule':>14s} {'|S|':>4s} {'brute force':>13s} {'closed form':>13s} {'rate':>9s}")
    by_size: Dict[int, set] = {}
    for schedule in schedules:
        brute = brute_force_hit_count(n, t, schedule)
        exact = exact_hit_count(n, t, len(schedule))
        assert brute == exact, (schedule, brute, exact)
        by_size.setdefault(len(schedule), set()).add(brute)
        print(f"   {str(schedule):>14s} {len(schedule):>4d} {brute:>13d} {exact:>13d} "
              f"{brute / n ** t:>9.4f}")
    for size, values in sorted(by_size.items()):
        assert len(values) == 1
    print("\n   all schedules of equal size give IDENTICAL counts: guidance is null.")
    print("   any measured 'improvement' at matched node budget is an artefact.")


def demo_trial_division_scaling() -> None:
    print()
    print("=" * 74)
    print("5. TRIAL-DIVISION SCALING (alpha = 1) AND THE HALF THRESHOLD")
    print("=" * 74)
    print("   threshold theorem: 4|S| < p  ==>  success rate < 1/2\n")
    print(f"   {'p':>4s} {'q':>5s} {'N':>7s} {'|S| = floor((p-1)/4)':>22s} {'success rate':>14s}")
    for p, q in ((11, 23), (13, 37), (17, 61), (23, 101), (29, 113)):
        n = p * q
        s = (p - 1) // 4
        r = n - 1 - euler_phi(n)
        rate = 1.0 - (1.0 - r / n) ** s
        assert 4 * s < p
        assert rate < 0.5
        print(f"   {p:>4d} {q:>5d} {n:>7d} {s:>22d} {rate:>14.5f}")

    print("\n   empirical exponent: nodes to first success versus p_min")
    rng = random.Random(20260826)
    # the large prime is kept far above p_min so that the density (p+q-2)/pq
    # is dominated by the 1/p_min term, isolating the exponent in p_min
    pairs = ((11, 100003), (23, 100003), (47, 100003), (101, 100003),
             (211, 100003), (401, 100003))
    sizes: List[int] = []
    costs: List[float] = []
    trials = 400
    print(f"\n   {'p_min':>7s} {'N':>9s} {'mean nodes':>12s} {'p_min ratio':>13s}")
    for p, q in pairs:
        n = p * q
        total = 0
        for _ in range(trials):
            used, _found = random_value_dive(n, p, 40 * p, rng)
            total += used
        mean = total / trials
        sizes.append(p)
        costs.append(mean)
        print(f"   {p:>7d} {n:>9d} {mean:>12.1f} {mean / p:>13.3f}")
    alpha = fit_exponent(sizes, costs)
    print(f"\n   fitted exponent alpha = {alpha:.3f}   (theory: 1;  reported: 1.007 +- 0.088)")
    print("   mean nodes / p_min is a constant near 1 (reported v* ~ 0.89 * p_min)")


def demo_rho_separation() -> None:
    print()
    print("=" * 74)
    print("6. THE PAIR TEST DOMINATES: value dive ~ p, pair test ~ sqrt(p)")
    print("=" * 74)
    p, q, t = 101, 487, 22
    n = p * q
    m = t // 2
    assert p <= m * m and t * t <= q and 4 * t < p
    print(f"   concrete instance: N = {p} * {q} = {n}, budget t = {t}")
    print(f"   hypotheses: p <= m^2 ({p} <= {m * m}), t^2 <= q ({t * t} <= {q}), "
          f"4t < p ({4 * t} < {p})")
    bound_dive = 1.0 - (1.0 - (p + q - 2) / n) ** t
    print(f"\n   value dive, any schedule : success  <  0.5   (model bound {bound_dive:.4f})")

    rng = random.Random(20260826)
    trials = 20000
    dive_wins = 0
    pair_wins = 0
    for _ in range(trials):
        _u, f1 = random_value_dive(n, p, t, rng)
        _v, f2 = pair_test(n, p, t, rng)
        dive_wins += 1 if f1 else 0
        pair_wins += 1 if f2 else 0
    print(f"   measured value-dive success rate : {dive_wins / trials:.4f}")
    print(f"   measured pair-test success rate  : {pair_wins / trials:.4f}   "
          f"(theorem: >= 0.30)")

    print("\n   a distinct congruent pair yields the factor EXACTLY:")
    for x, y in ((7, 7 + p), (2, 2 + 3 * p), (55, 55 + 2 * p)):
        g = math.gcd(y - x, n)
        print(f"     x = {x:>4d}, y = {y:>5d}, y - x = {y - x:>5d}: gcd(y - x, N) = {g}")
        assert g == p

    print("\n   budget comparison at constant success probability:")
    print(f"   {'p':>7s} {'dive ~ p':>12s} {'pair ~ 2 sqrt(p)':>18s} {'speedup':>10s}")
    for pp in (101, 1009, 10007, 100003, 1000003):
        dive = pp
        pair = 2 * math.isqrt(pp)
        print(f"   {pp:>7d} {dive:>12d} {pair:>18d} {dive / pair:>10.1f}x")


def main() -> None:
    print()
    print("MODULAR BERGGREN DESCENT: a complete numerical audit of a null result")
    demo_tree()
    demo_congruence_law()
    demo_hit_count()
    demo_guidance_null()
    demo_trial_division_scaling()
    demo_rho_separation()
    print()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("   * hit density modulo p*q is exactly (p + q - 2)/pq  ~  1/p_min")
    print("   * success count depends on the schedule only through its size")
    print("   * 4|S| < p forces success below one half: alpha = 1, not 1/2")
    print("   * every prime factor of a hypotenuse is 1 mod 4")
    print("   * hence gcd = 1 forever on Blum integers p = q = 3 (mod 4)")
    print("   * the pair test wins unconditionally at matched compute")
    print()


if __name__ == "__main__":
    main()
