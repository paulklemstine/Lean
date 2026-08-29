#!/usr/bin/env python3
"""
Numerical demonstration of the filter cap law.

    cost(s, theta)    = 1 - s + s * theta          (unfiltered sweep normalised to 1)
    speedup(s, theta) = 1 / cost(s, theta)

Results demonstrated here:

  1.  Exchangeable dials (s = theta) never exceed a speedup of 4/3, and attain it
      exactly at theta = 1/2.
  2.  The sharp cap-breaking criterion:  speedup > 4/3  <=>  s * (1 - theta) > 1/4.
  3.  The quantitative escape cost:  s - theta > (1 - 2 theta)^2 / (4 (1 - theta)).
  4.  Deterministic dials (s = 1) have speedup 1/theta; the parity skip reads 2.
  5.  The Berggren tree of Pythagorean triples has the universal congruence invariant
      a odd, 4 | b, c = 1 (mod 4), so its revealed residue table mod 4 is the fixed
      two-element set {(1,0,1), (3,0,1)} at every depth -- zero instance information.
  6.  Mutual information: the constant (orbit) dial carries exactly 0 bits; an ordinary
      residue dial carries 1 bit.  The 0-bit dial is nonetheless the faster one.
  7.  Prior vs information: a fixed dial has soundness = retention against a uniform
      prior (hence capped), and soundness 1 against a prior supported in its kept set.
  8.  Wheel dials of squarefree modulus M have blind speedup M / phi(M), which is
      unbounded because sum 1/p diverges.
  9.  A live trial-division simulation on random semiprimes, reproducing the measured
      readings ~1.33 (matched-random arm) and 2.00 (orbit / parity arm).

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

Triple = Tuple[int, int, int]

CAP: float = 4.0 / 3.0


# ----------------------------------------------------------------------------------
# 1. The cost model
# ----------------------------------------------------------------------------------


def dial_cost(s: float, theta: float) -> float:
    """Expected cost of a dial with soundness s and retention theta."""
    return 1.0 - s + s * theta


def dial_speedup(s: float, theta: float) -> float:
    """Speedup over the unfiltered sweep."""
    return 1.0 / dial_cost(s, theta)


def escape_margin(theta: float) -> float:
    """Required soundness excess (1 - 2 theta)^2 / (4 (1 - theta)) to beat the cap."""
    if theta >= 1.0:
        return math.inf
    return (1.0 - 2.0 * theta) ** 2 / (4.0 * (1.0 - theta))


def demo_cap_law() -> None:
    print("=" * 78)
    print("1.  THE CAP LAW:  exchangeable dials (s = theta) never exceed 4/3")
    print("=" * 78)
    print(f"{'theta':>8} {'cost':>10} {'speedup':>10} {'<= 4/3?':>9}")
    best_theta, best_speed = 0.0, 0.0
    for i in range(1, 21):
        theta = i / 20.0
        sp = dial_speedup(theta, theta)
        if sp > best_speed:
            best_theta, best_speed = theta, sp
        print(f"{theta:8.2f} {dial_cost(theta, theta):10.6f} {sp:10.6f}"
              f" {'yes' if sp <= CAP + 1e-12 else 'NO':>9}")
    print(f"\n  maximum {best_speed:.6f} attained at theta = {best_theta:.2f}"
          f"   (theory: 4/3 = {CAP:.6f} at theta = 0.50)")

    # a fine sweep confirming the bound never breaks
    worst = max(dial_speedup(t / 100000.0, t / 100000.0) for t in range(1, 100001))
    print(f"  fine sweep over 100000 retentions: max speedup = {worst:.10f} <= {CAP:.10f}")
    print()


def demo_sharp_criterion() -> None:
    print("=" * 78)
    print("2.  SHARP CRITERION:  speedup > 4/3  <=>  s (1 - theta) > 1/4")
    print("=" * 78)
    mismatches = 0
    for i in range(0, 101):
        for j in range(1, 101):
            s, theta = i / 100.0, j / 100.0
            lhs = dial_speedup(s, theta) > CAP + 1e-15
            rhs = s * (1.0 - theta) > 0.25 + 1e-15
            if lhs != rhs:
                mismatches += 1
    print(f"  checked 101 x 100 = {101 * 100} parameter pairs; mismatches = {mismatches}")

    print(f"\n{'theta':>8} {'s*(1-th)>1/4 needs s >':>24} {'escape margin':>15}"
          f" {'s-theta needed':>16}")
    for theta in (0.05, 0.10, 0.25, 0.50, 0.60, 0.75, 0.90):
        s_needed = 0.25 / (1.0 - theta)
        margin = escape_margin(theta)
        feasible = "feasible" if s_needed < 1.0 else "IMPOSSIBLE (s<=1)"
        print(f"{theta:8.2f} {s_needed:24.4f} {margin:15.4f} {feasible:>16}")
    print("\n  note: for theta > 3/4 even a perfectly sound dial cannot beat the cap,")
    print("        since s(1-theta) <= 1 - theta < 1/4.")
    print()


def demo_escape_cost() -> None:
    print("=" * 78)
    print("3.  QUANTITATIVE ESCAPE COST:  s - theta > (1-2 theta)^2 / (4 (1 - theta))")
    print("=" * 78)
    violations = 0
    for j in range(1, 100):
        theta = j / 100.0
        for i in range(0, 101):
            s = i / 100.0
            if dial_speedup(s, theta) > CAP + 1e-12:
                if s - theta <= escape_margin(theta) - 1e-12:
                    violations += 1
    print(f"  every cap-beating pair satisfies the margin bound; violations = {violations}")
    print("  the margin vanishes exactly at theta = 1/2:"
          f" margin(0.5) = {escape_margin(0.5):.12f}")
    print()


# ----------------------------------------------------------------------------------
# 4. Deterministic dials and wheels
# ----------------------------------------------------------------------------------


def totient(n: int) -> int:
    """Euler's totient by trial factorisation."""
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def wheel_speedup(modulus: int) -> float:
    """Blind (zero-information) speedup M / phi(M) of the wheel of modulus M."""
    return modulus / totient(modulus)


def primorial(primes: Sequence[int]) -> int:
    product = 1
    for p in primes:
        product *= p
    return product


def demo_structural_regime() -> None:
    print("=" * 78)
    print("4.  DETERMINISTIC AND WHEEL DIALS:  speedup 1/theta, unbounded family")
    print("=" * 78)
    print(f"  parity skip  (s = 1, theta = 1/2):  speedup = {dial_speedup(1.0, 0.5):.4f}")
    print(f"  exchangeable (s = theta = 1/2):     speedup = {dial_speedup(0.5, 0.5):.4f}")
    print(f"  ratio                              = "
          f"{dial_speedup(1.0, 0.5) / dial_speedup(0.5, 0.5):.4f}   (theory 3/2)")

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    print(f"\n{'wheel primes':>34} {'M':>12} {'phi(M)':>12} {'M/phi(M)':>10} {'log':>8}")
    for k in range(1, len(primes) + 1):
        subset = primes[:k]
        M = primorial(subset)
        w = wheel_speedup(M)
        print(f"{str(subset):>34} {M:12d} {totient(M):12d} {w:10.4f} {math.log(w):8.4f}")
    print("\n  M/phi(M) >= 1 + sum 1/p over p | M, and sum 1/p diverges,")
    print("  so blind structural speedups are unbounded -- the 4/3 cap does not")
    print("  bound speedups, only information-bearing ones.")
    print(f"  exchangeable window in log coordinates: [0, log(4/3)] = "
          f"[0, {math.log(CAP):.4f}]")
    print(f"  parity skip weight log 2 = {math.log(2.0):.4f}  (already outside)")
    print()


# ----------------------------------------------------------------------------------
# 5. The Berggren tree
# ----------------------------------------------------------------------------------


def b1(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def b2(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def b3(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


def berggren_layer(depth: int, root: Triple = (3, 4, 5)) -> List[Triple]:
    """All nodes of the Berggren tree down to the given depth (breadth-first)."""
    layer: List[Triple] = [root]
    seen: List[Triple] = [root]
    for _ in range(depth):
        nxt: List[Triple] = []
        for t in layer:
            nxt.extend((b1(t), b2(t), b3(t)))
        seen.extend(nxt)
        layer = nxt
    return seen


def revealed_residue_set(nodes: Iterable[Triple], modulus: int) -> List[Triple]:
    return sorted({(a % modulus, b % modulus, c % modulus) for a, b, c in nodes})


def demo_berggren() -> None:
    print("=" * 78)
    print("5.  BERGGREN ORBIT:  the revealed residue table is a universal constant")
    print("=" * 78)
    for depth in range(0, 8):
        nodes = berggren_layer(depth)
        assert all(a * a + b * b == c * c for a, b, c in nodes), "not Pythagorean"
        assert all(a % 2 == 1 and b % 4 == 0 and c % 4 == 1 for a, b, c in nodes)
        assert all((a * b) % 3 == 0 for a, b, c in nodes)
        table = revealed_residue_set(nodes, 4)
        print(f"  depth {depth}: {len(nodes):6d} nodes   revealed set mod 4 = {table}")
    print("\n  from depth 1 onward the table is exactly {(1,0,1), (3,0,1)}, at every")
    print("  depth and for every target:")
    print("  a is odd, 4 | b, c = 1 (mod 4) is an invariant of all three moves.")
    print("  (bonus invariant verified above: 3 | a*b in every Pythagorean triple.)")
    print()


# ----------------------------------------------------------------------------------
# 6. Mutual information
# ----------------------------------------------------------------------------------


def mutual_information_bits(joint: Sequence[Sequence[float]]) -> float:
    """Mutual information of a finite joint law, in bits."""
    rows = len(joint)
    cols = len(joint[0])
    px = [sum(joint[x][y] for y in range(cols)) for x in range(rows)]
    py = [sum(joint[x][y] for x in range(rows)) for y in range(cols)]
    total = 0.0
    for x in range(rows):
        for y in range(cols):
            p = joint[x][y]
            if p > 0.0:
                total += p * math.log(p / (px[x] * py[y]))
    return total / math.log(2.0)


def demo_information() -> None:
    print("=" * 78)
    print("6.  INFORMATION:  0 bits for the orbit dial, 1 bit for a residue dial")
    print("=" * 78)
    orbit = [[0.5, 0.0], [0.5, 0.0]]          # dial always emits symbol 0
    residue = [[0.5, 0.0], [0.0, 0.5]]        # dial output tracks the instance
    noisy = [[0.4, 0.1], [0.1, 0.4]]          # a partially informative dial
    for name, law, speed in (
        ("orbit / constant dial", orbit, dial_speedup(1.0, 0.5)),
        ("ordinary residue dial", residue, dial_speedup(0.5, 0.5)),
        ("noisy residue dial", noisy, dial_speedup(0.5, 0.5)),
    ):
        info = mutual_information_bits(law)
        print(f"  {name:<24} I = {info:7.4f} bits    speedup = {speed:.4f}")
    print("\n  the ZERO-bit dial is the FAST one.  Information does not order speedup:")
    print("  the orbit dial is sound (s = 1), not informative.")
    print("  mutual information is nonnegative (Gibbs), so 0 bits is the absolute floor.")
    print()


# ----------------------------------------------------------------------------------
# 7. Prior versus information
# ----------------------------------------------------------------------------------


def soundness_against_prior(kept: Sequence[int], prior: Dict[int, float]) -> float:
    return sum(prior.get(a, 0.0) for a in kept)


def demo_prior_dichotomy() -> None:
    print("=" * 78)
    print("7.  PRIOR, NOT INFORMATION:  where the escape actually comes from")
    print("=" * 78)
    pool = list(range(2, 202))
    kept = [a for a in pool if a % 2 == 1]
    theta = len(kept) / len(pool)

    uniform = {a: 1.0 / len(pool) for a in pool}
    s_uniform = soundness_against_prior(kept, uniform)
    print(f"  pool size {len(pool)}, kept (odd) {len(kept)}, retention theta = {theta:.4f}")
    print(f"  uniform prior:   soundness = {s_uniform:.4f}  (= retention: exchangeable)")
    print(f"                   speedup   = {dial_speedup(s_uniform, theta):.4f}  <= 4/3")

    # the true prior for an odd N: all mass on the odd divisors
    N = 3 * 5 * 7 * 11 * 13
    divisors = [d for d in pool if N % d == 0]
    supported = {d: 1.0 / len(divisors) for d in divisors}
    s_supported = soundness_against_prior(kept, supported)
    print(f"\n  odd target N = {N}, divisors in pool: {divisors}")
    print(f"  supported prior: soundness = {s_supported:.4f}  (every divisor is odd)")
    print(f"                   speedup   = {dial_speedup(s_supported, theta):.4f}  > 4/3")
    print("\n  identical dial, identical retention, no information consulted:")
    print("  the gap is created entirely by the prior.")
    print()


# ----------------------------------------------------------------------------------
# 9. Live trial-division simulation
# ----------------------------------------------------------------------------------


def is_probable_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def random_prime(bits: int, rng: random.Random) -> int:
    while True:
        cand = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_probable_prime(cand):
            return cand


def sweep_cost(N: int, keep_even: bool, keep_prob: float, rng: random.Random) -> float:
    """
    Descending sqrt trial division under the model's exhaustive-sweep accounting.

    The unfiltered baseline is a full sweep of all candidates in [2, sqrt(N)], of cost 1.
    The dial performs a full pass over the retained candidates; if the factor was
    retained the search stops there, otherwise the complement must be swept as well, for
    total cost 1.  keep_even=False is the parity (structural) dial, keep_prob < 1 an
    exchangeable random dial.  The returned value is the cost as a fraction of the
    baseline.
    """
    limit = math.isqrt(N)
    total = limit - 1 if limit >= 2 else 0
    if total <= 0:
        return 1.0
    kept = 0
    factor_kept = False
    for d in range(limit, 1, -1):
        if not keep_even and d % 2 == 0:
            continue
        if keep_prob < 1.0 and rng.random() >= keep_prob:
            continue
        kept += 1
        if N % d == 0:
            factor_kept = True
    if not factor_kept:
        return 1.0
    return kept / total


def demo_simulation(trials: int = 200, bits: int = 11, seed: int = 20260824) -> None:
    print("=" * 78)
    print("9.  LIVE SIMULATION on random semiprimes (descending sqrt trial division)")
    print("=" * 78)
    rng = random.Random(seed)
    rand_costs: List[float] = []
    parity_costs: List[float] = []
    parity_failures = 0

    for _ in range(trials):
        p = random_prime(bits, rng)
        q = random_prime(bits, rng)
        N = p * q
        rand_costs.append(sweep_cost(N, keep_even=True, keep_prob=0.5, rng=rng))
        c = sweep_cost(N, keep_even=False, keep_prob=1.0, rng=rng)
        parity_costs.append(c)
        if c == 1.0:
            parity_failures += 1

    def mean(xs: Sequence[float]) -> float:
        return sum(xs) / len(xs)

    print(f"  trials = {trials}, semiprimes of ~{2 * bits} bits")
    print("  unfiltered baseline cost     : 1.0000  (full sweep, by normalisation)")
    print(f"  matched-random arm speedup   : "
          f"{1.0 / mean(rand_costs):.4f}   (theory <= 4/3 = 1.3333)")
    print(f"  parity / orbit arm speedup   : "
          f"{1.0 / mean(parity_costs):.4f}   (theory 2.0000)")
    print(f"  parity arm failure rate      : {parity_failures / trials:.4f}"
          f"   (theory 0.0000)")
    print("\n  the parity arm never fails: divisors of an odd N are odd.")
    print("  the random arm fails half the time and is capped accordingly.")
    print()


# ----------------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE FILTER CAP LAW: 4/3 for exchangeable dials, 1/theta for structural")
    print("#" * 78)
    print()
    demo_cap_law()
    demo_sharp_criterion()
    demo_escape_cost()
    demo_structural_regime()
    demo_berggren()
    demo_information()
    demo_prior_dichotomy()
    demo_simulation()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  * exchangeable dials  : speedup <= 4/3, equality at theta = 1/2")
    print("  * cap breaks exactly when s(1-theta) > 1/4")
    print("  * deterministic dials : speedup 1/theta, unbounded over wheels")
    print("  * the orbit dial      : 0 bits of instance information, speedup 2")
    print("  * the escape is the prior (divisors of an odd N are odd), not information")
    print()


if __name__ == "__main__":
    main()
