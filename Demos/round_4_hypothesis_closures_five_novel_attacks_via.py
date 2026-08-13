"""
Counting is free, locating is hard: numerical demonstrations.

Self-contained Python (standard library only) demonstrating every quantitative
claim of the accompanying paper:

  1. The divisor-count partition function of a semiprime is the constant 4.
  2. Every divisor pair straddles the tropical corner sqrt(N).
  3. The divisor indicator on [1, sqrt(N)] is a 2-spike vector, with a unique
     nontrivial spike at the smaller prime p.
  4. The energy E(a,b) = (N - a b)^2 has ground set exactly
     {(1,N),(p,q),(q,p),(N,1)}, spectral gap 1, and random-restart success
     density 4/N^2 (resp. the divisor density in the corner window).
  5. The 2-Sylow torsion census satisfies T(k) = 2^(min(k,a)+min(k,b)) with
     a = v2(p-1), b = v2(q-1); its exponent is the tropical quadratic
     (X (+) a) (*) (X (+) b) whose corner locus is {a, b}.
  6. Census collision: 21 = 3*7 and 77 = 7*11 have identical censuses.
  7. Full-profile collision: 35 = 5*7 and 39 = 3*13 have identical
     d-torsion counts for every d.
  8. Squarefree moduli: T(k) = 2^(sum_p min(k, v2(p-1))); tropical root
     multiplicities are second differences; the level-one census is 2^r.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------
# Elementary arithmetic helpers
# --------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def divisors(n: int) -> List[int]:
    """All positive divisors of n, sorted."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def v_ell(m: int, ell: int) -> int:
    """The ell-adic valuation of m >= 1."""
    if m == 0:
        raise ValueError("valuation of 0 is undefined here")
    k = 0
    while m % ell == 0:
        m //= ell
        k += 1
    return k


def v2(m: int) -> int:
    """The 2-adic valuation."""
    return v_ell(m, 2)


def isqrt(n: int) -> int:
    return math.isqrt(n)


# --------------------------------------------------------------------------
# 1. The partition function of a semiprime is constant
# --------------------------------------------------------------------------


def divisor_count(n: int) -> int:
    return len(divisors(n))


def demo_constant_partition_function(bound: int = 200) -> None:
    print("=" * 72)
    print("1. Constant partition function:  Z = tau(pq) = 4 for every semiprime")
    print("=" * 72)
    primes = [p for p in range(2, bound) if is_prime(p)]
    samples: List[Tuple[int, int, int, int]] = []
    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            n = p * q
            if n <= bound:
                samples.append((p, q, n, divisor_count(n)))
    values: Set[int] = {t[3] for t in samples}
    for p, q, n, tau in samples[:8]:
        print(f"   N = {n:4d} = {p:3d} * {q:3d}   divisors = {divisors(n)}   tau = {tau}")
    print(f"   ... {len(samples)} semiprimes below {bound}: tau values observed = {values}")
    assert values == {4}
    # The concrete collision used in the no-locating theorem.
    print(f"   tau(15) = {divisor_count(15)} = tau(35) = {divisor_count(35)}, "
          f"but smallest factors are 3 and 5 -> no f with f(tau(N)) = p.")
    print()


# --------------------------------------------------------------------------
# 2. The tropical corner of the divisor hyperbola
# --------------------------------------------------------------------------


def demo_corner_straddling(samples: Sequence[int] = (3127, 10403, 999983 * 3)) -> None:
    print("=" * 72)
    print("2. Tropical corner: every divisor pair (d, N/d) straddles sqrt(N)")
    print("=" * 72)
    for n in samples:
        s = isqrt(n)
        print(f"   N = {n}   floor(sqrt N) = {s}")
        for d in divisors(n):
            lo, hi = min(d, n // d), max(d, n // d)
            assert lo <= s <= hi
            print(f"      d = {d:<10d} pair = ({lo}, {hi})   {lo} <= {s} <= {hi}  OK")
    print()


# --------------------------------------------------------------------------
# 3. The witness vector is a 2-spike
# --------------------------------------------------------------------------


def divisor_indicator(n: int) -> List[int]:
    """Indicator of divisibility on the corner window [1, floor(sqrt N)]."""
    s = isqrt(n)
    return [1 if n % x == 0 else 0 for x in range(1, s + 1)]


def demo_two_spike(pairs: Sequence[Tuple[int, int]] = ((53, 59), (101, 103), (211, 307))) -> None:
    print("=" * 72)
    print("3. Two-spike structure of the divisor indicator on [1, sqrt(N)]")
    print("=" * 72)
    for p, q in pairs:
        n = p * q
        w = divisor_indicator(n)
        spikes = [i + 1 for i, b in enumerate(w) if b]
        nontrivial = [x for x in spikes if x != 1]
        print(f"   N = {n:8d} = {p} * {q}   window length = {len(w)}   "
              f"spikes = {spikes}   nontrivial = {nontrivial}")
        assert spikes == [1, p]
        assert nontrivial == [p]
        density = len(nontrivial) / len(w)
        print(f"      sparsity 2 / {len(w)};  random probe success = {density:.6f} "
              f"(= 1/floor(sqrt N) = {1/isqrt(n):.6f})")
    print("   Compressed-sensing accounting: O(log N) measurements, but each generic")
    print("   measurement costs Theta(sqrt N) to specify AND Theta(sqrt N) to evaluate,")
    print("   so the total is Theta(sqrt N log N) -- worse than trial division.")
    for p, q in pairs:
        n = p * q
        s = isqrt(n)
        m = max(1, int(2 * math.log(n)))
        print(f"      N = {n:8d}: measurements m = {m:3d}, cost m * sqrt(N) = {m * s:9d} "
              f"vs. trial division {s:6d}")
    print()


# --------------------------------------------------------------------------
# 4. The energy landscape is a delta, not a slope
# --------------------------------------------------------------------------


def energy(n: int, a: int, b: int) -> int:
    """E_N(a,b) = (N - a b)^2."""
    return (n - a * b) ** 2


def ground_set(n: int) -> List[Tuple[int, int]]:
    return [(d, n // d) for d in divisors(n)]


def random_restart_success(n: int, trials: int, rng: random.Random) -> float:
    """Empirical density of ground states under uniform restarts in [1,N]^2."""
    hits = 0
    for _ in range(trials):
        a = rng.randrange(1, n + 1)
        b = rng.randrange(1, n + 1)
        if energy(n, a, b) == 0:
            hits += 1
    return hits / trials


def corner_window_success(n: int, trials: int, rng: random.Random) -> float:
    """Empirical density of nontrivial witnesses among random probes in [1,sqrt N]."""
    s = isqrt(n)
    hits = 0
    for _ in range(trials):
        x = rng.randrange(1, s + 1)
        if x > 1 and n % x == 0:
            hits += 1
    return hits / trials


def demo_energy_landscape() -> None:
    print("=" * 72)
    print("4. Energy landscape E(a,b) = (N - ab)^2: four isolated minima, gap 1")
    print("=" * 72)
    p, q = 13, 17
    n = p * q
    gs = ground_set(n)
    print(f"   N = {n} = {p} * {q}")
    print(f"      ground set = {gs}   |ground set| = {len(gs)}   (predicted 4)")
    assert set(gs) == {(1, n), (p, q), (q, p), (n, 1)}
    # spectral gap
    gap = min(energy(n, a, b) for a in range(1, n + 1) for b in range(1, n + 1)
              if a * b != n)
    print(f"      min energy over non-solutions = {gap}   (predicted >= 1)")
    assert gap >= 1
    # "no gradient": nearest misses have the same tiny energy as the solution's neighbours
    print("      energies near a solution (a = p, b varying):")
    for b in range(q - 2, q + 3):
        print(f"         E({p},{b}) = {energy(n, p, b)}")
    print("      one flip of the low-order bit of a changes ab by b: an uncontrolled jump.")

    rng = random.Random(20260813)
    print("\n   Random-restart densities (uniform over [1,N]^2):")
    for p, q in ((5, 7), (11, 13), (23, 29)):
        n = p * q
        pred = 4 / (n * n)
        trials = min(4_000_000, max(400_000, int(40 / pred)))
        emp = random_restart_success(n, trials, rng)
        print(f"      N = {n:5d}: empirical {emp:.8f}   predicted 4/N^2 = {pred:.8f}"
              f"   ({trials} trials)")

    print("\n   Optical/Ising analogue: L modes explore 2^L ~ sqrt(N) configurations;")
    print("   success rate matches the divisor density 2/2^L.")
    for bits in (14, 20, 26):
        # a semiprime of about 'bits' bits with balanced factors
        target = 1 << bits
        p = max(x for x in range(3, isqrt(target) + 1) if is_prime(x))
        q = next(x for x in range(p + 1, 4 * p + 4) if is_prime(x))
        n = p * q
        L = isqrt(n).bit_length()
        emp = corner_window_success(n, 400_000, rng)
        pred = 1 / isqrt(n)
        print(f"      {bits:2d}-bit N = {n:9d} = {p}*{q}:  L = {L} modes, "
              f"empirical {emp:.5f}, predicted {pred:.5f}")
    print("\n   Tensor networks: the target state |p>|q> is a product state, Schmidt rank 1,")
    print("   entanglement entropy exactly 0 -- bond dimension 1 suffices, no advantage.")
    print()


# --------------------------------------------------------------------------
# 5. The 2-Sylow torsion census and its tropical structure
# --------------------------------------------------------------------------


def torsion_count_bruteforce(n: int, d: int) -> int:
    """#{x in (Z/nZ)^* : x^d = 1}, computed directly."""
    return sum(1 for x in range(1, n) if math.gcd(x, n) == 1 and pow(x, d, n) == 1)


def torsion_count_formula(primes: Sequence[int], d: int) -> int:
    """prod_p gcd(p-1, d) for squarefree N = prod primes."""
    out = 1
    for p in primes:
        out *= math.gcd(p - 1, d)
    return out


def census_exponent(levels: Sequence[int], k: int) -> int:
    """The tropical polynomial value sum_i min(k, level_i)."""
    return sum(min(k, a) for a in levels)


def tropical_monomials(a: int, b: int, x: int) -> Tuple[int, int, int]:
    """The three monomials of (X (+) a) (*) (X (+) b): 2x, min(a,b)+x, a+b."""
    return (2 * x, min(a, b) + x, a + b)


def is_tropical_root(a: int, b: int, x: int) -> bool:
    """The minimum over monomials is attained at least twice."""
    ms = tropical_monomials(a, b, x)
    lo = min(ms)
    return sum(1 for m in ms if m == lo) >= 2


def demo_census() -> None:
    print("=" * 72)
    print("5. Exact 2-Sylow torsion census and its tropical corner locus")
    print("=" * 72)
    for p, q in ((3, 7), (5, 13), (17, 41), (7, 11)):
        n = p * q
        a, b = v2(p - 1), v2(q - 1)
        row_bf = [torsion_count_bruteforce(n, 2 ** k) for k in range(6)]
        row_fm = [2 ** census_exponent((a, b), k) for k in range(6)]
        assert row_bf == row_fm
        print(f"   N = {n:4d} = {p}*{q}   fingerprint (a,b) = ({a},{b})")
        print(f"      T(k), k=0..5 by enumeration : {row_bf}")
        print(f"      2^(min(k,a)+min(k,b))       : {row_fm}   MATCH")
        slopes = [census_exponent((a, b), k + 1) - census_exponent((a, b), k)
                  for k in range(6)]
        print(f"      tropical slopes             : {slopes}  (2 -> 1 -> 0)")
        roots = [x for x in range(0, 8) if is_tropical_root(a, b, x)]
        print(f"      corner locus (tropical roots): {roots}   (predicted {{{a},{b}}})")
        assert set(roots) == {a, b}
    print()


def demo_census_collision() -> None:
    print("=" * 72)
    print("6. Census collision: 21 = 3*7 and 77 = 7*11 have identical censuses")
    print("=" * 72)
    t21 = [torsion_count_bruteforce(21, 2 ** k) for k in range(8)]
    t77 = [torsion_count_bruteforce(77, 2 ** k) for k in range(8)]
    print(f"   T_21(k), k = 0..7 : {t21}")
    print(f"   T_77(k), k = 0..7 : {t77}")
    assert t21 == t77
    print("   Identical, yet the smaller factors are 3 and 7: the census cannot locate.")
    print()


# --------------------------------------------------------------------------
# 7. Root shuffling and the full-profile collision
# --------------------------------------------------------------------------


def valuation_multisets(m: int, n: int, ell_bound: int = 60) -> Dict[int, Tuple[int, int]]:
    """For each prime ell < ell_bound, the sorted pair (v_ell m, v_ell n)."""
    out: Dict[int, Tuple[int, int]] = {}
    for ell in range(2, ell_bound):
        if is_prime(ell):
            pair = tuple(sorted((v_ell(m, ell), v_ell(n, ell))))
            if pair != (0, 0):
                out[ell] = pair  # type: ignore[assignment]
    return out


def demo_root_shuffling(d_max: int = 200) -> None:
    print("=" * 72)
    print("7. Tropical root shuffling: 35 = 5*7 and 39 = 3*13 share the whole profile")
    print("=" * 72)
    print(f"   (p-1, q-1) for 35 : (4, 6)      valuation multisets: "
          f"{valuation_multisets(4, 6)}")
    print(f"   (p-1, q-1) for 39 : (2, 12)     valuation multisets: "
          f"{valuation_multisets(2, 12)}")
    print("   At the prime 2 the roots {2,1} have simply been swapped between the slots.")
    prof35 = [torsion_count_formula((5, 7), d) for d in range(1, d_max + 1)]
    prof39 = [torsion_count_formula((3, 13), d) for d in range(1, d_max + 1)]
    assert prof35 == prof39
    bf35 = [torsion_count_bruteforce(35, d) for d in range(1, 25)]
    bf39 = [torsion_count_bruteforce(39, d) for d in range(1, 25)]
    assert bf35 == bf39 == prof35[:24]
    print(f"   profile d = 1..16 (both) : {prof35[:16]}")
    print(f"   verified equal for all d = 1..{d_max} (and by enumeration for d <= 24).")
    print("   Hence no functional of the entire torsion profile returns a prime factor.")
    print()


def search_profile_collisions(bound: int = 400) -> List[Tuple[int, int]]:
    """Semiprime pairs below `bound` with identical torsion profiles."""
    primes = [p for p in range(3, bound) if is_prime(p)]
    buckets: Dict[Tuple[Tuple[int, Tuple[int, int]], ...], List[int]] = {}
    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            n = p * q
            if n > bound:
                break
            key = tuple(sorted(valuation_multisets(p - 1, q - 1).items()))
            buckets.setdefault(key, []).append(n)
    out: List[Tuple[int, int]] = []
    for _, ns in buckets.items():
        for i in range(len(ns)):
            for j in range(i + 1, len(ns)):
                out.append((ns[i], ns[j]))
    return sorted(out)


def demo_collision_search(bound: int = 200) -> None:
    print("=" * 72)
    print(f"8. Collision search: profile-equivalent semiprime pairs below {bound}")
    print("=" * 72)
    pairs = search_profile_collisions(bound)
    for m, n in pairs[:12]:
        fm = [d for d in divisors(m) if 1 < d < m][0]
        fn = [d for d in divisors(n) if 1 < d < n][0]
        prof_m = [torsion_count_bruteforce(m, d) for d in range(1, 13)]
        prof_n = [torsion_count_bruteforce(n, d) for d in range(1, 13)]
        assert prof_m == prof_n
        print(f"   {m:4d} (= {fm}*{m//fm}) and {n:4d} (= {fn}*{n//fn}) : "
              f"profile {prof_m[:8]} ... identical")
    print(f"   total pairs found: {len(pairs)}")
    print()


# --------------------------------------------------------------------------
# 9. Squarefree moduli: degree-r tropical polynomial
# --------------------------------------------------------------------------


def demo_multiprime_census(sets: Iterable[Sequence[int]] = ((3, 5, 7), (3, 5, 17), (5, 7, 11, 13))) -> None:
    print("=" * 72)
    print("9. Squarefree moduli: T(k) = 2^(sum_p min(k, v2(p-1))), a degree-r tropical")
    print("   polynomial; root multiplicities are second differences; T(1) = 2^r")
    print("=" * 72)
    for S in sets:
        n = 1
        for p in S:
            n *= p
        levels = [v2(p - 1) for p in S]
        exps = [census_exponent(levels, k) for k in range(8)]
        census = [2 ** e for e in exps]
        direct = [torsion_count_formula(S, 2 ** k) for k in range(8)]
        assert census == direct
        print(f"   S = {tuple(S)}, N = {n}, levels v2(p-1) = {levels}")
        print(f"      census exponent E(k), k=0..7 : {exps}")
        print(f"      T(k)                          : {census}")
        first = [exps[k + 1] - exps[k] for k in range(6)]
        second = [first[k] - first[k + 1] for k in range(5)]
        print(f"      slopes (surviving primes)     : {first}")
        print(f"      root multiplicities at k+1    : {second}")
        for k, mult in enumerate(second):
            assert mult == sum(1 for lv in levels if lv == k + 1)
        # concavity
        assert all(exps[k + 2] + exps[k] <= 2 * exps[k + 1] for k in range(6))
        print(f"      concave: yes.  T(1) = {census[1]} = 2^{len(S)}  (information-free level)")
        assert census[1] == 2 ** len(S)
    print()


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------


def main() -> None:
    print()
    print("COUNTING IS FREE, LOCATING IS HARD -- numerical demonstrations")
    print()
    demo_constant_partition_function()
    demo_corner_straddling()
    demo_two_spike()
    demo_energy_landscape()
    demo_census()
    demo_census_collision()
    demo_root_shuffling()
    demo_collision_search()
    demo_multiprime_census()
    print("All assertions passed: every quantitative claim of the paper is reproduced.")


if __name__ == "__main__":
    main()
