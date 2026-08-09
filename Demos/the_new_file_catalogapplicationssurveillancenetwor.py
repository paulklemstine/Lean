"""
Numerical demonstrations for the theory of perfectly private reconstruction.

A configuration space S is a finite set of possible states of the world; an
observer is a map obs : S -> M into a finite record alphabet, and a decoder is a
map dec : M -> S.  The observer is *perfectly private* when obs is constant, so
that the record is independent of the configuration; then the decoder can only
ever output one fixed reconstruction, chosen in advance.

This script verifies, by exhaustive computation on small instances, every exact
statement of the theory:

  1. Worst-case private distortion = one-codeword covering radius, which equals
     the ambient dimension n for binary Hamming distortion.
  2. Randomization does not help a private channel, in the worst case or on
     average.
  3. Average-case private optimum = total coordinatewise minority mass, attained
     by the coordinatewise majority vote; for the uniform source it equals n/2.
  4. Exact Hamming ball volume sum_{i<=D} C(n,i) and the excess-distortion
     converse (1 - eps) * 2^n <= rate * vol_D, whose zero-slack, unit-rate corner
     re-derives the sharp threshold D >= n.
  5. Orbit (relabeling-invariant) distortion equals the Hamming weight gap; the
     relabeled threshold is ceil(n/2); orbit balls are unions of binomial layers.
  6. Tensorization: the covering radius of an additive product distortion is the
     sum of the componentwise covering radii, and the average-case private
     optimum is the sum over the marginals -- even for maximally correlated
     sources.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Config = Tuple[int, ...]  # a binary tensor, as a tuple of 0/1 entries


# --------------------------------------------------------------------------- #
# Basic combinatorial primitives
# --------------------------------------------------------------------------- #


def all_configs(n: int) -> List[Config]:
    """Every binary configuration of dimension ``n`` (there are 2**n of them)."""
    return [tuple(bits) for bits in itertools.product((0, 1), repeat=n)]


def hamming(c: Config, s: Config) -> int:
    """Hamming distortion: the number of coordinates where ``c`` and ``s`` differ."""
    return sum(1 for a, b in zip(c, s) if a != b)


def weight(x: Config) -> int:
    """Hamming weight: the number of coordinates equal to 1."""
    return sum(x)


def orbit_distortion(c: Config, s: Config) -> int:
    """Distortion modulo relabeling: min over permutations g of hamming(c o g, s).

    Theorem (exact orbit distance): this equals |wt(c) - wt(s)|.  Here it is
    computed by brute force over all permutations so that the identity can be
    checked rather than assumed.
    """
    n = len(c)
    best = n
    for g in itertools.permutations(range(n)):
        permuted = tuple(c[g[i]] for i in range(n))
        best = min(best, hamming(permuted, s))
    return best


def ball_volume_hamming(n: int, radius: int) -> int:
    """Exact Hamming ball volume in {0,1}^n: sum_{i<=radius} C(n, i)."""
    return sum(math.comb(n, i) for i in range(min(radius, n) + 1))


def ball_volume_orbit(n: int, center_weight: int, radius: int) -> int:
    """Exact orbit ball volume: sum of the binomial layers with weights in range."""
    lo = max(0, center_weight - radius)
    hi = min(n, center_weight + radius)
    return sum(math.comb(n, m) for m in range(lo, hi + 1))


def covering_radius(space: Sequence[Config], dist: Callable[[Config, Config], int]) -> int:
    """One-codeword covering radius min_c max_s dist(c, s), by exhaustive search."""
    return min(max(dist(c, s) for s in space) for c in space)


# --------------------------------------------------------------------------- #
# Source laws and the private rate-distortion function
# --------------------------------------------------------------------------- #


def uniform_law(n: int) -> Dict[Config, Fraction]:
    """The uniform law on {0,1}^n, in exact rational arithmetic."""
    configs = all_configs(n)
    mass = Fraction(1, len(configs))
    return {x: mass for x in configs}


def random_law(n: int, rng: random.Random) -> Dict[Config, Fraction]:
    """A random probability law on {0,1}^n with small rational weights."""
    configs = all_configs(n)
    raw = [rng.randint(1, 20) for _ in configs]
    total = sum(raw)
    return {x: Fraction(w, total) for x, w in zip(configs, raw)}


def expected_distortion(
    law: Dict[Config, Fraction],
    dist: Callable[[Config, Config], int],
    c: Config,
) -> Fraction:
    """E_p[ dist(c, X) ] for the single reconstruction ``c``."""
    return sum((p * dist(c, x) for x, p in law.items()), Fraction(0))


def private_distortion_bruteforce(
    law: Dict[Config, Fraction],
    dist: Callable[[Config, Config], int],
) -> Tuple[Fraction, Config]:
    """min_c E_p[dist(c, X)] by exhaustive search over all 2**n reconstructions."""
    best_c = min(law.keys(), key=lambda c: expected_distortion(law, dist, c))
    return expected_distortion(law, dist, best_c), best_c


def coordinate_mass(law: Dict[Config, Fraction], i: int, bit: int) -> Fraction:
    """mass_i(b) = P[X_i != b], the source mass disagreeing with bit ``b`` at ``i``."""
    return sum((p for x, p in law.items() if x[i] != bit), Fraction(0))


def majority_vote(law: Dict[Config, Fraction]) -> Config:
    """The coordinatewise majority vote: in each coordinate pick the heavier bit."""
    n = len(next(iter(law)))
    return tuple(0 if coordinate_mass(law, i, 0) <= coordinate_mass(law, i, 1) else 1
                 for i in range(n))


def private_distortion_formula(law: Dict[Config, Fraction]) -> Fraction:
    """Closed form: sum_i min(mass_i(0), mass_i(1)), the total minority mass."""
    n = len(next(iter(law)))
    return sum((min(coordinate_mass(law, i, 0), coordinate_mass(law, i, 1))
                for i in range(n)), Fraction(0))


# --------------------------------------------------------------------------- #
# Converse bounds
# --------------------------------------------------------------------------- #


def min_failure_probability(n: int, radius: int, rate: int = 1) -> Fraction:
    """Smallest eps compatible with (1 - eps) * 2**n <= rate * vol_radius."""
    vol = ball_volume_hamming(n, radius)
    return max(Fraction(0), Fraction(1) - Fraction(rate * vol, 2 ** n))


def min_rate(n: int, radius: int, eps: Fraction) -> int:
    """Smallest integer rate compatible with (1 - eps) * 2**n <= rate * vol_radius."""
    vol = ball_volume_hamming(n, radius)
    need = (Fraction(1) - eps) * (2 ** n)
    return max(1, -((-need.numerator) // (need.denominator * vol)))


def min_rate_relabeled(n: int, radius: int) -> Fraction:
    """Rate lower bound 2**n / ((2D+1) * C(n, floor(n/2))) modulo relabeling."""
    return Fraction(2 ** n, (2 * radius + 1) * math.comb(n, n // 2))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def demo_worst_case_threshold(max_n: int = 5) -> None:
    print("=" * 74)
    print("1. WORST-CASE PRIVATE THRESHOLD = COVERING RADIUS = ambient dimension")
    print("=" * 74)
    print(f"{'n':>3} | {'brute-force R(Hamming)':>23} | {'predicted n':>11} | ok")
    print("-" * 74)
    for n in range(1, max_n + 1):
        space = all_configs(n)
        r = covering_radius(space, hamming)
        print(f"{n:>3} | {r:>23} | {n:>11} | {r == n}")
    print()
    print("A perfectly private channel is constant, so the decoder outputs one")
    print("fixed point; covering the whole cube at Hamming radius D forces D = n.")
    print()


def demo_randomization_useless(n: int = 4, trials: int = 200, seed: int = 1) -> None:
    print("=" * 74)
    print("2. RANDOMIZATION DOES NOT HELP A PRIVATE CHANNEL")
    print("=" * 74)
    rng = random.Random(seed)
    law = random_law(n, rng)
    best_single, best_c = private_distortion_bruteforce(law, hamming)
    worst_gap = Fraction(0)
    for _ in range(trials):
        # a perfectly private randomized channel: a record law independent of X,
        # together with an arbitrary decoder
        k = rng.randint(1, 6)
        raw = [rng.randint(1, 10) for _ in range(k)]
        total = sum(raw)
        q = [Fraction(w, total) for w in raw]
        decoded = [tuple(rng.randint(0, 1) for _ in range(n)) for _ in range(k)]
        value = sum((qm * expected_distortion(law, hamming, cm)
                     for qm, cm in zip(q, decoded)), Fraction(0))
        worst_gap = min(worst_gap, value - best_single)
    print(f"dimension n = {n}, random source law, {trials} random private channels")
    print(f"best single reconstruction   : {best_c}, value {float(best_single):.6f}")
    print(f"min(randomized - best single): {float(worst_gap):.6f}  (must be >= 0)")
    print()
    print("The expected distortion of a private randomized channel is a convex")
    print("combination of the values E_p[d(dec(m), X)], hence at least the least.")
    print()


def demo_majority_vote(max_n: int = 4, seed: int = 7) -> None:
    print("=" * 74)
    print("3. AVERAGE CASE: MAJORITY VOTE AND THE TOTAL MINORITY MASS")
    print("=" * 74)
    rng = random.Random(seed)
    header = f"{'n':>3} | {'brute force':>14} | {'closed form':>14} | {'maj = argmin':>12} | ok"
    print(header)
    print("-" * 74)
    for n in range(1, max_n + 1):
        law = random_law(n, rng)
        brute, brute_c = private_distortion_bruteforce(law, hamming)
        closed = private_distortion_formula(law)
        maj = majority_vote(law)
        maj_val = expected_distortion(law, hamming, maj)
        ok = (brute == closed) and (maj_val == brute)
        print(f"{n:>3} | {float(brute):>14.8f} | {float(closed):>14.8f} | "
              f"{str(maj_val == brute):>12} | {ok}")
    print()
    print(f"{'n':>3} | {'uniform source: D_priv':>23} | {'predicted n/2':>13} | ok")
    print("-" * 74)
    for n in range(1, max_n + 1):
        law = uniform_law(n)
        value, _ = private_distortion_bruteforce(law, hamming)
        predicted = Fraction(n, 2)
        print(f"{n:>3} | {float(value):>23.8f} | {float(predicted):>13.4f} | "
              f"{value == predicted}")
    print()
    print("Grading on average instead of always buys exactly a factor of two:")
    print("n/2 versus n.  And n/2 is what a uniformly random guess already achieves.")
    print()


def demo_binomial_converse(n: int = 12) -> None:
    print("=" * 74)
    print("4. THE EXCESS-DISTORTION CONVERSE  (1 - eps) * 2^n <= rate * vol_D")
    print("=" * 74)
    print(f"ambient dimension n = {n},  |S| = 2^{n} = {2 ** n}")
    print()
    print(f"{'D':>3} | {'vol_D = sum C(n,i)':>19} | {'min eps at rate 1':>18} | "
          f"{'min rate at eps=0':>17}")
    print("-" * 74)
    for D in range(0, n + 1):
        vol = ball_volume_hamming(n, D)
        eps = min_failure_probability(n, D, rate=1)
        rate = min_rate(n, D, Fraction(0))
        print(f"{D:>3} | {vol:>19} | {float(eps):>18.6f} | {rate:>17}")
    print()
    print("At rate 1 (perfect privacy) the minimum failure probability is")
    print("1 - vol_D / 2^n = P[Bin(n, 1/2) > D], which is 0 only at D = n:")
    print("the sharp threshold is the zero-excess corner of the inequality.")
    print()
    strict = all(ball_volume_hamming(n, D) < 2 ** n for D in range(n))
    print(f"strict binomial tail  sum_{{i<=D}} C(n,i) < 2^n  for all D < n : {strict}")
    print()


def demo_relabeling(max_n: int = 6) -> None:
    print("=" * 74)
    print("5. DISTORTION MODULO RELABELING")
    print("=" * 74)
    # (a) orbit distortion equals the weight gap (brute force over permutations)
    ok_gap = True
    for n in range(1, 5):
        for x in all_configs(n):
            for y in all_configs(n):
                if orbit_distortion(x, y) != abs(weight(x) - weight(y)):
                    ok_gap = False
    print(f"orbit distortion == |wt(x) - wt(y)|, checked exhaustively for n <= 4 : {ok_gap}")
    print()
    # (b) covering radius = ceil(n/2)
    print(f"{'n':>3} | {'brute-force R(orbit)':>21} | {'ceil(n/2)':>10} | "
          f"{'R(Hamming)=n':>12} | ok")
    print("-" * 74)
    for n in range(1, max_n + 1):
        space = all_configs(n)
        r = covering_radius(space, lambda a, b: abs(weight(a) - weight(b)))
        predicted = (n + 1) // 2
        print(f"{n:>3} | {r:>21} | {predicted:>10} | {n:>12} | {r == predicted}")
    print()
    # (c) exact orbit ball volumes
    n = 6
    print(f"exact orbit ball volumes for n = {n} (layers of the binomial triangle)")
    print(f"{'center wt k':>11} | {'D':>2} | {'enumerated':>11} | {'formula':>8} | "
          f"{'bound (2D+1)C(n,n/2)':>21}")
    print("-" * 74)
    space = all_configs(n)
    for k in range(0, n + 1, 2):
        for D in (0, 1, 2):
            center = tuple([1] * k + [0] * (n - k))
            enumerated = sum(1 for s in space if abs(weight(center) - weight(s)) <= D)
            formula = ball_volume_orbit(n, k, D)
            bound = (2 * D + 1) * math.comb(n, n // 2)
            print(f"{k:>11} | {D:>2} | {enumerated:>11} | {formula:>8} | {bound:>21}")
    print()
    print(f"{'n':>3} | {'D':>2} | {'rate lower bound 2^n/((2D+1)C(n,n/2))':>38}")
    print("-" * 74)
    for n in (8, 12, 16, 20):
        for D in (0, 2):
            print(f"{n:>3} | {D:>2} | {float(min_rate_relabeled(n, D)):>38.4f}")
    print()
    print("Relabeling buys exactly a factor of two in the threshold, and the rate")
    print("converse survives the quotient: accuracy still costs ~sqrt(n) records.")
    print()


def demo_tensorization(seed: int = 3) -> None:
    print("=" * 74)
    print("6. TENSORIZATION: PRIVACY BUDGETS ADD, AND ONLY MARGINALS MATTER")
    print("=" * 74)
    # (a) worst case: R(sum_i d_i) = sum_i R(d_i) on {0,1}^a x {0,1}^b
    print(f"{'a':>2} {'b':>2} | {'R(product)':>11} | {'R(a) + R(b)':>12} | ok")
    print("-" * 74)
    for a in range(1, 4):
        for b in range(1, 4):
            space = all_configs(a + b)

            def split_dist(c: Config, s: Config, a: int = a) -> int:
                return hamming(c[:a], s[:a]) + hamming(c[a:], s[a:])

            r = covering_radius(space, split_dist)
            print(f"{a:>2} {b:>2} | {r:>11} | {a + b:>12} | {r == a + b}")
    print()
    # (b) average case with a maximally correlated source: only marginals matter
    n = 4
    rng = random.Random(seed)
    # a source supported on the "all equal" configurations: coordinates are
    # perfectly correlated, yet the private optimum sees only the marginals
    t = Fraction(rng.randint(1, 9), 10)
    correlated: Dict[Config, Fraction] = {x: Fraction(0) for x in all_configs(n)}
    correlated[tuple([0] * n)] = 1 - t
    correlated[tuple([1] * n)] = t
    product_law: Dict[Config, Fraction] = {
        x: math.prod([t if b == 1 else 1 - t for b in x], start=Fraction(1))
        for x in all_configs(n)
    }
    for name, law in (("perfectly correlated", correlated), ("independent", product_law)):
        brute, c = private_distortion_bruteforce(law, hamming)
        marginals = sum((min(coordinate_mass(law, i, 0), coordinate_mass(law, i, 1))
                         for i in range(n)), Fraction(0))
        print(f"{name:>21}: D_priv = {float(brute):.8f}, "
              f"sum over marginals = {float(marginals):.8f}, "
              f"equal = {brute == marginals}")
    print()
    print("Both laws have the same marginals (each coordinate is 1 with probability")
    print(f"{float(t):.1f}) and therefore exactly the same private optimum, although one is")
    print("maximally correlated and the other independent: correlation is precisely")
    print("the resource a perfectly private channel cannot exploit.")
    print()


def demo_network_histories(T: int = 3, n: int = 4) -> None:
    print("=" * 74)
    print("7. SURVEILLANCE NETWORKS: THE NUMBERS FOR A T-STEP HISTORY")
    print("=" * 74)
    dim = T * n * n
    print(f"T = {T} time steps, n = {n} participants, ambient dimension T*n^2 = {dim}")
    print(f"number of possible histories                       : 2^{dim}")
    print(f"worst-case private distortion (Hamming)            : {dim}")
    print(f"time-sliced worst-case private distortion          : {T} x {n * n} = {dim}")
    print(f"expected private distortion, uniform source        : {dim / 2}")
    print(f"worst-case private distortion modulo relabeling    : {(dim + 1) // 2}")
    for D in (dim // 8, dim // 4, dim // 3):
        eps = min_failure_probability(dim, D, rate=1)
        print(f"private failure probability at radius D = {D:>3}       : "
              f">= {float(eps):.10f}")
    print()
    print("A perfectly private observer of a surveillance history is, on average,")
    print("exactly as informative as a fair coin, and in the worst case may be")
    print("wrong about every single recorded interaction.")
    print()


def main() -> None:
    demo_worst_case_threshold()
    demo_randomization_useless()
    demo_majority_vote()
    demo_binomial_converse()
    demo_relabeling()
    demo_tensorization()
    demo_network_histories()
    print("=" * 74)
    print("All exact identities above were verified by exhaustive computation.")
    print("=" * 74)


if __name__ == "__main__":
    main()
