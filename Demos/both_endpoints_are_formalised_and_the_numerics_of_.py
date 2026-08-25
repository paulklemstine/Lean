"""
Converses to the union bound for universal hashing: numerical demonstrations.

Everything here is computed in EXACT rational arithmetic (``fractions.Fraction``),
because the whole point of the theory is the difference between

    Pr[h(x) = h(y)] <= 1/m        (Carter-Wegman, inequality form)

and

    Pr[h(x) = h(y)]  = 1/m        (exact 2-universality),

a difference that floating point cannot see and that changes the extremal
answer from 0 to 1/m.

Results demonstrated
--------------------
1.  Union bound endpoint:  Pr[collision] <= C(n,2)/m for 2-universal families.
2.  Converse endpoint:     Pr[collision] >= 1/m for exactly 2-universal
                           families, independently of the number of keys n.
3.  Affine sharpness:      the family x -> a*x + b over Z_p attains 1/p, is
                           pairwise independent, and its collision counter is
                           {0, n(n-1)}-valued (the equality case of reverse
                           Markov).
4.  Prime-free attainment: the bijection-constant mixture attains 1/m for
                           every m.
5.  Necessity of exactness: a single injective map is 2-universal in the
                           inequality sense with collision probability 0.
6.  First-moment optimality: every single function collides on at least
                           n^2/m - n ordered pairs; exact 2-universality
                           overshoots by exactly n(1 - 1/m).
7.  Pigeonhole degeneration: n > m forces collision probability 1.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from math import comb, factorial
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core objects: a finite family of hash functions with rational weights
# ---------------------------------------------------------------------------

# A family is a list of (weight, hash function) pairs, where a hash function is
# represented concretely as a tuple giving the bucket of key 0, 1, ..., n-1.
HashFunction = Tuple[int, ...]
Family = List[Tuple[Fraction, HashFunction]]


def collides(h: HashFunction) -> bool:
    """True iff the hash function is not injective on its key set."""
    return len(set(h)) < len(h)


def collision_probability(family: Family) -> Fraction:
    """Pr[h is not injective on the key set].  Complexity O(|Omega| * n)."""
    return sum((w for w, h in family if collides(h)), Fraction(0))


def pair_collision_probability(family: Family, x: int, y: int) -> Fraction:
    """Pr[h(x) = h(y)] for two distinct keys."""
    return sum((w for w, h in family if h[x] == h[y]), Fraction(0))


def collision_counter_distribution(family: Family) -> Dict[int, Fraction]:
    """Law of X = number of ORDERED pairs of distinct keys that collide."""
    dist: Dict[int, Fraction] = {}
    for w, h in family:
        n = len(h)
        count = sum(1 for x in range(n) for y in range(n) if x != y and h[x] == h[y])
        dist[count] = dist.get(count, Fraction(0)) + w
    return dist


def expectation(dist: Dict[int, Fraction], power: int = 1) -> Fraction:
    """E[X^power] from the law of X."""
    return sum((w * Fraction(value) ** power for value, w in dist.items()), Fraction(0))


def is_exactly_2_universal(family: Family, m: int) -> bool:
    """Check Pr[h(x) = h(y)] = 1/m for every pair of distinct keys, exactly."""
    n = len(family[0][1])
    target = Fraction(1, m)
    return all(
        pair_collision_probability(family, x, y) == target
        for x in range(n)
        for y in range(x + 1, n)
    )


def is_sub_2_universal(family: Family, m: int) -> bool:
    """Check the inequality-only Carter-Wegman axiom Pr[h(x)=h(y)] <= 1/m."""
    n = len(family[0][1])
    target = Fraction(1, m)
    return all(
        pair_collision_probability(family, x, y) <= target
        for x in range(n)
        for y in range(x + 1, n)
    )


def is_pairwise_independent(family: Family, m: int) -> bool:
    """Check Pr[h(x) = u and h(y) = v] = 1/m^2 for all distinct x,y and all u,v."""
    n = len(family[0][1])
    target = Fraction(1, m * m)
    for x in range(n):
        for y in range(n):
            if x == y:
                continue
            for u in range(m):
                for v in range(m):
                    mass = sum(
                        (w for w, h in family if h[x] == u and h[y] == v), Fraction(0)
                    )
                    if mass != target:
                        return False
    return True


# ---------------------------------------------------------------------------
# Family constructors
# ---------------------------------------------------------------------------


def affine_family(p: int, n: int) -> Family:
    """The Carter-Wegman affine family h_{a,b}(x) = a*x + b over Z_p,
    restricted to the keys 0, 1, ..., n-1 (needs n <= p for injectivity of the
    key encoding).  Uniform over all p^2 index pairs (a, b)."""
    if not 2 <= n <= p:
        raise ValueError("need 2 <= n <= p")
    weight = Fraction(1, p * p)
    return [
        (weight, tuple((a * x + b) % p for x in range(n)))
        for a in range(p)
        for b in range(p)
    ]


def mixture_family(m: int, n: int) -> Family:
    """The bijection-constant mixture on m buckets, read on n <= m keys.

    Bijection branch:  each of the m! permutations, total mass 1 - 1/m.
    Constant branch:   each of the m constants,     total mass 1/m.
    """
    if not 2 <= n <= m:
        raise ValueError("need 2 <= n <= m")
    perm_weight = Fraction(m - 1, m) / factorial(m)
    const_weight = Fraction(1, m * m)
    family: Family = [
        (perm_weight, tuple(sigma[:n])) for sigma in permutations(range(m))
    ]
    family += [(const_weight, tuple([c] * n)) for c in range(m)]
    return family


def injective_deterministic_family(m: int, n: int) -> Family:
    """One injective map, with probability 1.  Satisfies the inequality-only
    axiom (pair probabilities are 0) and never collides."""
    if not 2 <= n <= m:
        raise ValueError("need 2 <= n <= m")
    return [(Fraction(1), tuple(range(n)))]


def all_functions_family(m: int, n: int) -> Family:
    """A uniformly random function from n keys to m buckets: the benchmark
    'truly random' family.  Pairwise independent, hence exactly 2-universal."""
    total = m ** n
    weight = Fraction(1, total)
    return [(weight, h) for h in product(range(m), repeat=n)]


# ---------------------------------------------------------------------------
# Theoretical values
# ---------------------------------------------------------------------------


def union_bound(m: int, n: int) -> Fraction:
    """The classical upper bound C(n,2)/m.  Note it may exceed 1."""
    return Fraction(comb(n, 2), m)


def extremal_collision_value(m: int, n: int) -> Fraction:
    """The exact minimum of Pr[collision] over exactly 2-universal families:
    1/m for 2 <= n <= m, and 1 for n > m."""
    if n < 2:
        raise ValueError("need n >= 2")
    return Fraction(1, m) if n <= m else Fraction(1)


def absolute_pigeonhole_collision_count(m: int, n: int) -> Fraction:
    """Every single hash function collides on at least n^2/m - n ordered
    pairs (Cauchy-Schwarz on the fibre sizes)."""
    return Fraction(n * n, m) - n


def min_collision_count_bruteforce(m: int, n: int) -> int:
    """Brute force minimum, over ALL functions from n keys into m buckets, of
    the number of ordered colliding pairs.  Used to check the bound above."""
    best = n * (n - 1)
    for h in product(range(m), repeat=n):
        count = sum(1 for x in range(n) for y in range(n) if x != y and h[x] == h[y])
        best = min(best, count)
    return best


def fmt(q: Fraction) -> str:
    return f"{str(q):>7s} = {float(q):.6f}"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_affine_numerics() -> None:
    print("=" * 78)
    print("1. THE AFFINE FAMILY OVER Z_p: EXACT COLLISION PROBABILITIES")
    print("=" * 78)
    print("h_{a,b}(x) = a*x + b mod p, uniform over the p^2 pairs (a,b).")
    print("It collides exactly when a = 0 (then it is constant), so p of p^2 indices.\n")
    header = f"{'p':>3} {'colliding':>10} {'total':>7} {'Pr[coll]':>20} {'union bound':>14}"
    print(header)
    print("-" * len(header))
    for p in (2, 3, 5, 7):
        family = affine_family(p, p)
        colliding = sum(1 for _, h in family if collides(h))
        prob = collision_probability(family)
        assert prob == Fraction(1, p), "affine family must attain 1/p"
        assert colliding == p
        print(
            f"{p:>3} {colliding:>10} {p * p:>7} {fmt(prob):>20} "
            f"{str(union_bound(p, p)):>14}"
        )
    print()
    print("At p = 7 with all seven keys the union bound permits the value 3 -- a")
    print("vacuous statement about a probability -- while the truth is 1/7.")
    print()


def demo_key_independence() -> None:
    print("=" * 78)
    print("2. THE EXTREMAL VALUE DOES NOT DEPEND ON THE NUMBER OF KEYS")
    print("=" * 78)
    p = 7
    header = f"{'n':>3} {'Pr[coll] (affine)':>20} {'union bound C(n,2)/p':>22}"
    print(header)
    print("-" * len(header))
    for n in range(2, p + 1):
        prob = collision_probability(affine_family(p, n))
        assert prob == Fraction(1, p)
        print(f"{n:>3} {fmt(prob):>20} {str(union_bound(p, n)):>22}")
    print()
    print("The left column is constant; the right column grows quadratically and")
    print("passes 1 (becoming vacuous) already at n = 4.")
    print()


def demo_all_or_nothing() -> None:
    print("=" * 78)
    print("3. WHY IT IS TIGHT: THE COLLISION COUNTER IS ALL-OR-NOTHING")
    print("=" * 78)
    p, n = 5, 5
    family = affine_family(p, n)
    dist = collision_counter_distribution(family)
    mean = expectation(dist, 1)
    second = expectation(dist, 2)
    print(f"p = {p}, n = {n}.  X = number of ordered colliding pairs.")
    print("Law of X: " + ", ".join(f"P(X={v}) = {w}" for v, w in sorted(dist.items())))
    print(f"E[X]          = {fmt(mean)}   (theory n(n-1)/m = {Fraction(n*(n-1), p)})")
    print(f"max X         = {n * (n - 1)}   (all ordered pairs)")
    print(f"E[X]/max X    = {fmt(mean / (n * (n - 1)))}   <- reverse Markov floor 1/m")
    print(f"E[X]^2/E[X^2] = {fmt(mean * mean / second)}   <- Chung-Erdos bound")
    print(f"Pr[collision] = {fmt(collision_probability(family))}")
    print()
    print("X takes only the values 0 and n(n-1): the equality case of the reverse")
    print("Markov inequality, so both lower bounds coincide with the truth.")
    print()


def demo_pairwise_independence() -> None:
    print("=" * 78)
    print("4. THE EXTREMAL FAMILY IS THE TEXTBOOK ONE (PAIRWISE INDEPENDENT)")
    print("=" * 78)
    for p in (3, 5):
        family = affine_family(p, p)
        exact = is_exactly_2_universal(family, p)
        strong = is_pairwise_independent(family, p)
        print(
            f"p = {p}: exactly 2-universal = {exact}; "
            f"pairwise independent = {strong}"
        )
        assert exact and strong
    print()
    print("So the value 1/p is attained already inside the class of strongly")
    print("2-universal families -- the class actually used in practice.")
    print()


def demo_mixture() -> None:
    print("=" * 78)
    print("5. PRIME-FREE ATTAINMENT: THE BIJECTION-CONSTANT MIXTURE")
    print("=" * 78)
    print("Random bijection with mass 1 - 1/m (never collides) mixed with a random")
    print("constant with mass 1/m (always collides).\n")
    header = f"{'m':>3} {'n':>3} {'exactly 2-univ':>16} {'Pr[coll]':>20} {'1/m':>10}"
    print(header)
    print("-" * len(header))
    for m in (4, 6):  # composite: no field structure available
        for n in (2, 3, m):
            family = mixture_family(m, n)
            exact = is_exactly_2_universal(family, m)
            prob = collision_probability(family)
            assert exact and prob == Fraction(1, m)
            print(
                f"{m:>3} {n:>3} {str(exact):>16} {fmt(prob):>20} "
                f"{str(Fraction(1, m)):>10}"
            )
    print()
    print("No primality is used: the extremal value 1/m is attained for every m.")
    print()


def demo_exactness_matters() -> None:
    print("=" * 78)
    print("6. EXACTNESS IS INDISPENSABLE: THE CARTER-WEGMAN DICHOTOMY")
    print("=" * 78)
    m, n = 6, 4
    inj = injective_deterministic_family(m, n)
    print(f"m = {m}, n = {n}.  A single injective map, taken with probability 1:")
    print(f"  satisfies Pr[h(x)=h(y)] <= 1/m for all pairs : {is_sub_2_universal(inj, m)}")
    print(f"  is exactly 2-universal                       : {is_exactly_2_universal(inj, m)}")
    print(f"  Pr[collision]                                : {collision_probability(inj)}")
    assert is_sub_2_universal(inj, m)
    assert not is_exactly_2_universal(inj, m)
    assert collision_probability(inj) == 0
    print()
    print("Under the inequality-only axiom the extremal value is 0 for n <= m and")
    print("1 for n > m -- nothing in between.  The floor 1/m is a phenomenon of")
    print("EXACT 2-universality, not of the union bound's hypothesis.")
    print()


def demo_first_moment() -> None:
    print("=" * 78)
    print("7. FIRST MOMENTS: 2-UNIVERSALITY IS NEARLY OPTIMAL")
    print("=" * 78)
    print("Absolute bound: every single function collides on >= n^2/m - n ordered")
    print("pairs.  Exact 2-universality gives E[X] = n(n-1)/m.\n")
    header = (
        f"{'m':>3} {'n':>3} {'n^2/m - n':>12} {'brute min':>11} "
        f"{'E[X] exact 2-u':>16} {'gap':>10} {'n(1-1/m)':>10}"
    )
    print(header)
    print("-" * len(header))
    for m, n in [(3, 3), (4, 3), (4, 4), (5, 4), (5, 5)]:
        lower = absolute_pigeonhole_collision_count(m, n)
        brute = min_collision_count_bruteforce(m, n)
        mean = Fraction(n * (n - 1), m)
        gap = mean - lower
        theory_gap = Fraction(n) * (1 - Fraction(1, m))
        assert Fraction(brute) >= lower
        assert gap == theory_gap
        print(
            f"{m:>3} {n:>3} {str(lower):>12} {brute:>11} {str(mean):>16} "
            f"{str(gap):>10} {str(theory_gap):>10}"
        )
    print()
    print("The overshoot is exactly n(1 - 1/m) < n: at the level of expected")
    print("collision counts the Carter-Wegman axiom costs almost nothing.")
    print()


def demo_random_function_benchmark() -> None:
    print("=" * 78)
    print("8. THE TRULY RANDOM FAMILY IS NOT EXTREMAL")
    print("=" * 78)
    print("A uniformly random function is pairwise independent, hence exactly")
    print("2-universal, but its collision probability sits strictly inside the")
    print("sandwich 1/m <= Pr[coll] <= C(n,2)/m.\n")
    header = (
        f"{'m':>3} {'n':>3} {'floor 1/m':>12} {'random function':>20} "
        f"{'union bound':>13}"
    )
    print(header)
    print("-" * len(header))
    for m, n in [(4, 2), (4, 3), (5, 3), (5, 4), (6, 3)]:
        family = all_functions_family(m, n)
        assert is_exactly_2_universal(family, m)
        prob = collision_probability(family)
        floor = Fraction(1, m)
        ub = union_bound(m, n)
        assert floor <= prob <= ub
        print(f"{m:>3} {n:>3} {str(floor):>12} {fmt(prob):>20} {str(ub):>13}")
    print()
    print("The extremal families beat the truly random one: concentrating all the")
    print("collision mass on a single catastrophic branch minimises the PROBABILITY")
    print("of a collision, at the cost of maximising its severity.")
    print()


def demo_pigeonhole() -> None:
    print("=" * 78)
    print("9. PIGEONHOLE DEGENERATION AND THE FULL VALUE FUNCTION")
    print("=" * 78)
    m = 5
    header = f"{'n':>3} {'extremal value':>16} {'union bound':>13}"
    print(header)
    print("-" * len(header))
    for n in range(2, 9):
        print(
            f"{n:>3} {str(extremal_collision_value(m, n)):>16} "
            f"{str(union_bound(m, n)):>13}"
        )
    print()
    print(f"With m = {m} buckets the value is 1/{m} for 2 <= n <= {m} and jumps to 1")
    print("at n = 6: with more keys than buckets every function collides.")
    print()
    # sanity check of the jump on a concrete family
    n = 8
    family = [
        (Fraction(1, 49), tuple((a * (x % 7) + b) % 7 for x in range(n)))
        for a in range(7)
        for b in range(7)
    ]
    assert collision_probability(family) == 1
    print("Concrete check: the affine family over Z_7 read on 8 keys (through")
    print("reduction mod 7) has collision probability exactly 1.")
    print()


def main() -> None:
    print()
    print("CONVERSES TO THE UNION BOUND FOR UNIVERSAL HASHING")
    print("Exact rational arithmetic throughout.")
    print()
    demo_affine_numerics()
    demo_key_independence()
    demo_all_or_nothing()
    demo_pairwise_independence()
    demo_mixture()
    demo_exactness_matters()
    demo_first_moment()
    demo_random_function_benchmark()
    demo_pigeonhole()
    print("=" * 78)
    print("All assertions passed: every printed value agrees with the theory.")
    print("=" * 78)


if __name__ == "__main__":
    main()
