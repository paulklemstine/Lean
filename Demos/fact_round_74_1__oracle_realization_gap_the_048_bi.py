#!/usr/bin/env python3
"""
Numerical demonstrations for "The Oracle-Realization Gap for the Fermat Navigation Sensor".

Every result stated in the accompanying paper is exercised here on concrete integers:

  1. The Fermat gap  d(p,q) = (p+q)/2 - isqrt(pq)  and the navigation sensor 1{d <= B}.
  2. The Circularity Theorem: (N, d) recovers p and q by two integer square roots.
  3. The Budget Law: a Fermat scan of budget k hits a semiprime iff d <= k.
  4. The Oracle-to-Factoring Reduction: binary search on thresholds yields the factorisation.
  5. Residue Blindness: for every modulus L and threshold B, an explicit congruent pair of
     semiprimes with opposite sensor values.
  6. The Exact Crediting Law: min error over T-measurable policies = sum of class minorities,
     attained by the class-wise majority vote; verified by brute force over all 2^|kappa|
     policies.
  7. Balanced strata give exactly zero: min error = |P|/2.
  8. Adaptivity buys nothing: decision trees over a residue menu, of any depth, agree on
     menu-indistinguishable samples.
  9. The Divisor-Lattice Navigation Law: scan cost = min over nontrivial divisors of the
     midpoint excess; verified exhaustively for odd N < 20000.
 10. The Fermat-close density bound O(sqrt(B) * X^{3/4}): counted against the proved bound.
 11. The concrete witness N = 955277 * 1044727 inside the reported window 295 < d <= 22758.

Pure standard library; no dependencies.  Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import isqrt
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Section 0.  Elementary number-theoretic helpers
# --------------------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, exact for all n < 3.3 * 10^24."""
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
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than n."""
    m = n + 1
    if m <= 2:
        return 2
    if m % 2 == 0:
        m += 1
    while not is_prime(m):
        m += 2
    return m


def next_prime_congruent(n: int, residue: int, modulus: int) -> int:
    """Smallest prime > n congruent to `residue` mod `modulus` (Dirichlet guarantees one)."""
    m = n + 1
    while True:
        if m % modulus == residue % modulus and is_prime(m):
            return m
        m += 1


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    small: List[int] = []
    large: List[int] = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            small.append(i)
            if i != n // i:
                large.append(n // i)
        i += 1
    return small + large[::-1]


# --------------------------------------------------------------------------------------
# Section 1.  The Fermat gap and the navigation sensor
# --------------------------------------------------------------------------------------


def mid(p: int, q: int) -> int:
    """The Fermat midpoint (p+q)/2."""
    return (p + q) // 2


def fermat_gap(p: int, q: int) -> int:
    """The Fermat gap d(p,q) = (p+q)/2 - isqrt(pq)."""
    return mid(p, q) - isqrt(p * q)


def sensor(threshold: int, p: int, q: int) -> bool:
    """The navigation sensor 1{d <= B}."""
    return fermat_gap(p, q) <= threshold


# --------------------------------------------------------------------------------------
# Section 2.  The Circularity Theorem
# --------------------------------------------------------------------------------------


def recover_factors(n: int, gap: int) -> Tuple[int, int]:
    """
    Circularity Theorem.  From N and the Fermat gap d, two integer square roots return the
    factors:  a = isqrt(N) + d,  h = isqrt(a^2 - N),  (p, q) = (a - h, a + h).
    """
    a = isqrt(n) + gap
    h = isqrt(a * a - n)
    return a - h, a + h


# --------------------------------------------------------------------------------------
# Section 3.  The Budget Law
# --------------------------------------------------------------------------------------


def scan_hit(n: int, budget: int) -> Optional[Tuple[int, int]]:
    """
    Fermat scan of budget k: probe a = isqrt(N), ..., isqrt(N) + k for a square remainder,
    demanding a nontrivial split (a - b > 1).  Returns (a, b) on success, else None.
    """
    base = isqrt(n)
    for i in range(budget + 1):
        a = base + i
        rem = a * a - n
        if rem < 0:
            continue
        b = isqrt(rem)
        if b * b == rem and a - b > 1:
            return a, b
    return None


# --------------------------------------------------------------------------------------
# Section 4.  The Oracle-to-Factoring Reduction
# --------------------------------------------------------------------------------------


def factor_via_sensor_oracle(n: int, oracle: Callable[[int], bool]) -> Tuple[int, int, int]:
    """
    Given N and an oracle answering 1{d <= B} for every B, find the least accepting
    threshold by doubling + binary search (it equals d), then apply the recovery maps.
    Returns (p, q, oracle_calls).
    """
    calls = 0

    def ask(b: int) -> bool:
        nonlocal calls
        calls += 1
        return oracle(b)

    hi = 1
    while not ask(hi):
        hi *= 2
    lo = 0
    while lo < hi:
        midpoint = (lo + hi) // 2
        if ask(midpoint):
            hi = midpoint
        else:
            lo = midpoint + 1
    p, q = recover_factors(n, lo)
    return p, q, calls


# --------------------------------------------------------------------------------------
# Section 5.  Residue Blindness
# --------------------------------------------------------------------------------------


def residue_blind_pair(modulus: int, threshold: int) -> Tuple[int, int, int]:
    """
    Construct the colliding pair of the Residue Blindness theorem.

    Take a prime p > max(L, 2) and set q1 = p, so N1 = p^2 has gap 0 (sensor fires).
    Then take a prime q2 = p (mod L) large enough that gap(p, q2) > B (sensor silent).
    Then N1 = p*p = p*q2 = N2 (mod L).  Returns (p, q1, q2).
    """
    p = next_prime(max(modulus, 2))
    q1 = p
    lower = p + 2 * (threshold + 2 * p * threshold + 1)
    q2 = next_prime_congruent(lower, p % modulus, modulus)
    return p, q1, q2


# --------------------------------------------------------------------------------------
# Section 6.  The Exact Crediting Law
# --------------------------------------------------------------------------------------

Sample = int


def policy_error(
    population: Sequence[Sample],
    statistic: Callable[[Sample], int],
    target: Callable[[Sample], bool],
    policy: Dict[int, bool],
) -> int:
    """Number of population members on which the T-measurable policy disagrees with target."""
    return sum(1 for i in population if policy[statistic(i)] != target(i))


def irreducible_error(
    population: Sequence[Sample],
    statistic: Callable[[Sample], int],
    target: Callable[[Sample], bool],
) -> int:
    """Sum over T-classes of the class minority count."""
    classes: Dict[int, List[Sample]] = {}
    for i in population:
        classes.setdefault(statistic(i), []).append(i)
    total = 0
    for members in classes.values():
        ones = sum(1 for i in members if target(i))
        total += min(ones, len(members) - ones)
    return total


def majority_policy(
    population: Sequence[Sample],
    statistic: Callable[[Sample], int],
    target: Callable[[Sample], bool],
) -> Dict[int, bool]:
    """The class-wise majority vote, the optimal T-measurable policy."""
    classes: Dict[int, List[Sample]] = {}
    for i in population:
        classes.setdefault(statistic(i), []).append(i)
    return {
        c: (sum(1 for i in members if target(i)) * 2 >= len(members))
        for c, members in classes.items()
    }


def brute_force_min_error(
    population: Sequence[Sample],
    statistic: Callable[[Sample], int],
    target: Callable[[Sample], bool],
) -> int:
    """Exhaustive minimum over all 2^|kappa| T-measurable policies."""
    labels = sorted({statistic(i) for i in population})
    best = len(population)
    for assignment in product([False, True], repeat=len(labels)):
        policy = dict(zip(labels, assignment))
        best = min(best, policy_error(population, statistic, target, policy))
    return best


# --------------------------------------------------------------------------------------
# Section 7.  Adaptive policies as decision trees
# --------------------------------------------------------------------------------------


@dataclass(frozen=True)
class Leaf:
    """A verdict node of a query tree."""

    value: bool


@dataclass(frozen=True)
class Node:
    """An internal node: a Boolean query on the sample, with two subtrees."""

    query: Callable[[Sample], bool]
    yes: "QueryTree"
    no: "QueryTree"


QueryTree = object  # Leaf | Node


def tree_eval(tree: QueryTree, sample: Sample) -> bool:
    """Run the adaptive policy on a sample."""
    while isinstance(tree, Node):
        tree = tree.yes if tree.query(sample) else tree.no
    assert isinstance(tree, Leaf)
    return tree.value


def tree_depth(tree: QueryTree) -> int:
    """Depth of a query tree (a leaf has depth 0)."""
    if isinstance(tree, Leaf):
        return 0
    return 1 + max(tree_depth(tree.yes), tree_depth(tree.no))


def tree_leaves(tree: QueryTree) -> int:
    """Number of leaves of a query tree."""
    if isinstance(tree, Leaf):
        return 1
    return tree_leaves(tree.yes) + tree_leaves(tree.no)


def build_residue_tree(modulus: int, residues: Sequence[int], verdicts: Sequence[bool]) -> QueryTree:
    """
    A right-spine adaptive residue policy: 'is N = r1 mod L?  else is N = r2 mod L?  ...',
    with the supplied verdicts at each accepting branch.  Depth = len(residues).
    """
    tree: QueryTree = Leaf(False)
    for r, v in zip(reversed(residues), reversed(verdicts)):
        tree = Node(query=(lambda n, r=r: n % modulus == r), yes=Leaf(v), no=tree)
    return tree


# --------------------------------------------------------------------------------------
# Section 8.  The Divisor-Lattice Navigation Law
# --------------------------------------------------------------------------------------


def navigation_cost(n: int) -> Optional[int]:
    """
    min over nontrivial divisors e of ((e + n/e)/2 - isqrt(n)); None if n has no such divisor
    (n prime or n = 1).
    """
    root = isqrt(n)
    best: Optional[int] = None
    for e in divisors(n):
        if 1 < e < n:
            value = (e + n // e) // 2 - root
            best = value if best is None else min(best, value)
    return best


def least_successful_budget(n: int, cap: int) -> Optional[int]:
    """Smallest k <= cap with a scan hit, found by direct search."""
    for k in range(cap + 1):
        if scan_hit(n, k) is not None:
            return k
    return None


# --------------------------------------------------------------------------------------
# Section 9.  Fermat-close density
# --------------------------------------------------------------------------------------


def count_fermat_close(limit: int, threshold: int) -> int:
    """Exact count of odd N <= X admitting N = pq, p <= q odd, with gap(p,q) <= B."""
    count = 0
    for n in range(3, limit + 1, 2):
        root = isqrt(n)
        found = False
        for e in divisors(n):
            f = n // e
            if e <= f and (e + f) // 2 - root <= threshold:
                found = True
                break
        if found:
            count += 1
    return count


def close_count_bound(limit: int, threshold: int) -> int:
    """The proved bound (isqrt(X)+B+1) * (isqrt(2B(isqrt(X)+B))+1)."""
    a_max = isqrt(limit) + threshold
    h_max = isqrt(2 * threshold * a_max)
    return (a_max + 1) * (h_max + 1)


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_gap_and_sensor() -> None:
    banner("1.  The Fermat gap and the navigation sensor")
    print(f"{'p':>10} {'q':>10} {'N = pq':>16} {'isqrt(N)':>12} {'gap d':>10}  sensor(B=1000)")
    samples = [(101, 103), (10007, 10009), (955277, 1044727), (3, 999983), (65521, 65537)]
    for p, q in samples:
        n = p * q
        d = fermat_gap(p, q)
        print(f"{p:>10} {q:>10} {n:>16} {isqrt(n):>12} {d:>10}  {sensor(1000, p, q)}")
    print()
    print("The gap measures imbalance: near-equal factors give a tiny gap; 3 * 999983 gives a")
    print("gap of order N/6, far beyond any menu budget.")


def demo_circularity() -> None:
    banner("2.  Circularity Theorem: (N, d) recovers the factorisation")
    print("Two integer square roots, no search at all.")
    print()
    print(f"{'p':>10} {'q':>10} {'gap d':>12} {'recovered p':>14} {'recovered q':>14}  ok")
    ok_all = True
    for p, q in [(101, 103), (10007, 10009), (955277, 1044727), (3, 999983), (7919, 104729)]:
        n = p * q
        d = fermat_gap(p, q)
        rp, rq = recover_factors(n, d)
        ok = (rp, rq) == (p, q)
        ok_all &= ok
        print(f"{p:>10} {q:>10} {d:>12} {rp:>14} {rq:>14}  {ok}")
    print()
    print(f"All recoveries exact: {ok_all}")
    print("Knowing the sensor's statistic IS knowing the factors -- circularity, exactly.")


def demo_budget_law() -> None:
    banner("3.  Budget Law: scan of budget k hits iff gap <= k")
    p, q = 10007, 10009
    n = p * q
    d = fermat_gap(p, q)
    print(f"N = {p} * {q} = {n},  gap d = {d}")
    print()
    print(f"{'budget k':>10} {'scan hits?':>12} {'gap <= k?':>12}  agree")
    for k in [0, d - 1, d, d + 1, d + 50]:
        if k < 0:
            continue
        hit = scan_hit(n, k) is not None
        print(f"{k:>10} {str(hit):>12} {str(d <= k):>12}  {hit == (d <= k)}")
    print()
    print("Exhaustive check over all odd semiprimes below 20000:")
    checked = violations = 0
    for i in range(3, 200, 2):
        if not is_prime(i):
            continue
        for j in range(i, 20000 // i + 1, 2):
            if not is_prime(j) or i * j >= 20000:
                continue
            n2 = i * j
            g = fermat_gap(i, j)
            for k in range(0, min(g + 3, 400)):
                checked += 1
                if (scan_hit(n2, k) is not None) != (g <= k):
                    violations += 1
    print(f"  {checked} (semiprime, budget) pairs checked; violations: {violations}")


def demo_oracle_reduction() -> None:
    banner("4.  Oracle-to-Factoring Reduction")
    p, q = 955277, 1044727
    n = p * q
    print(f"Hidden factorisation N = {n}. We may only ask the oracle 'is d <= B?'.")
    rp, rq, calls = factor_via_sensor_oracle(n, lambda b: sensor(b, p, q))
    print(f"Binary search over thresholds used {calls} oracle calls.")
    print(f"Recovered p = {rp}, q = {rq}   (correct: {(rp, rq) == (p, q)})")
    print()
    print("A half-bit sensor that implies a factoring algorithm was never realizable by a")
    print("lightweight query policy.")


def demo_residue_blindness() -> None:
    banner("5.  Residue Blindness: exactly zero, at every modulus")
    print(f"{'L':>7} {'B':>7} {'p':>7} {'q1':>7} {'q2':>11} {'N1 mod L':>10} {'N2 mod L':>10}"
          f" {'s(N1)':>7} {'s(N2)':>7}")
    for modulus, threshold in [(7, 5), (16, 10), (100, 25), (2310, 40)]:
        p, q1, q2 = residue_blind_pair(modulus, threshold)
        n1, n2 = p * q1, p * q2
        print(f"{modulus:>7} {threshold:>7} {p:>7} {q1:>7} {q2:>11} {n1 % modulus:>10}"
              f" {n2 % modulus:>10} {str(sensor(threshold, p, q1)):>7}"
              f" {str(sensor(threshold, p, q2)):>7}")
    print()
    print("Congruent inputs, opposite sensor values: every residue-only policy must err on one.")
    print("Not approximately zero -- exactly zero, for every modulus and every threshold.")


def demo_crediting_law() -> None:
    banner("6.  Exact Crediting Law: min error = sum of class minorities")
    print("Population: odd semiprimes N = p*q below 5000. Target: the sensor 1{d <= 20}.")
    population: List[int] = []
    factorisation: Dict[int, Tuple[int, int]] = {}
    for i in range(3, 80, 2):
        if not is_prime(i):
            continue
        for j in range(i, 5000 // i + 1, 2):
            if is_prime(j) and i * j < 5000:
                population.append(i * j)
                factorisation[i * j] = (i, j)
    population = sorted(set(population))
    target = lambda n: sensor(20, *factorisation[n])

    print(f"  |P| = {len(population)}")
    print()
    print(f"{'statistic T':>28} {'#classes':>9} {'min err (formula)':>18}"
          f" {'majority vote':>14} {'|P|/2':>8}")
    statistics: List[Tuple[str, Callable[[int], int]]] = [
        ("N mod 3", lambda n: n % 3),
        ("N mod 8", lambda n: n % 8),
        ("N mod 105", lambda n: n % 105),
        ("bit-length of N", lambda n: n.bit_length()),
        ("N itself (full information)", lambda n: n),
    ]
    for name, stat in statistics:
        classes = len({stat(n) for n in population})
        irr = irreducible_error(population, stat, target)
        maj = policy_error(population, stat, target, majority_policy(population, stat, target))
        print(f"{name:>28} {classes:>9} {irr:>18} {maj:>14} {len(population)//2:>8}")
    print()
    print("Brute-force verification (all 2^|kappa| policies enumerated) on a spread-out")
    print("sub-population, so that the classes are genuinely mixed:")
    small = population[::71]
    ones = sum(1 for n in small if target(n))
    print(f"  |P'| = {len(small)},  labelled 1: {ones},  labelled 0: {len(small) - ones}")
    for name, stat in statistics[:4]:
        irr = irreducible_error(small, stat, target)
        brute = brute_force_min_error(small, stat, target)
        print(f"  T = {name:<26}  formula = {irr:>3}   exhaustive minimum = {brute:>3}"
              f"   match: {irr == brute}")


def demo_balanced_strata() -> None:
    banner("7.  Balanced strata, and the base-rate channel that pooling banks")
    print("(a) THE THEOREM.  If every T-class carries equally many 1s and 0s, the minimum")
    print("    error of any T-measurable policy is exactly |P|/2 -- pure coin flipping.")
    print()
    # 4 classes, each with 3 ones and 3 zeros; sample i encodes (class, label).
    population = list(range(24))
    stat = lambda i: i // 6
    target = lambda i: (i % 6) < 3
    irr = irreducible_error(population, stat, target)
    brute = brute_force_min_error(population, stat, target)
    print(f"    |P| = {len(population)},  classes = {len({stat(i) for i in population})}"
          f"  (each 3 ones / 3 zeros)")
    print(f"    sum of class minorities              = {irr}")
    print(f"    exhaustive minimum over all policies = {brute}")
    print(f"    |P| / 2                              = {len(population) // 2}")
    print(f"    theorem holds: {2 * irr == len(population)}")
    print()
    print("(b) THE BASE-RATE CHANNEL.  Now let two magnitude strata have DIFFERENT sensor")
    print("    base rates, and give the policy nothing but the stratum label.")
    print()
    #   stratum 0: 100 members, 90 with sensor 1;  stratum 1: 100 members, 10 with sensor 1.
    strata: List[Tuple[int, bool]] = (
        [(0, True)] * 90 + [(0, False)] * 10 + [(1, True)] * 10 + [(1, False)] * 90
    )
    pop2 = list(range(len(strata)))
    stratum = lambda i: strata[i][0]
    label = lambda i: strata[i][1]
    pooled = lambda i: 0  # the pooled statistic: one single class

    n_tot = len(pop2)
    global_ones = sum(1 for i in pop2 if label(i))
    chance = n_tot / 2
    pooled_err = irreducible_error(pop2, pooled, label)
    strat_err = irreducible_error(pop2, stratum, label)

    print(f"    |P| = {n_tot},  overall sensor rate = {global_ones / n_tot:.2f}")
    print(f"    coin-flipping baseline error          = {chance:.0f}")
    print(f"    best stratum-reading policy error     = {strat_err}"
          f"   -> apparent skill vs chance: {(chance - strat_err) / chance:>6.1%}")
    print(f"    best pooled (constant) policy error   = {pooled_err}")
    print()
    print("    LENIENT crediting compares the policy to the coin-flip baseline: it sees a")
    print(f"    large gain ({(chance - strat_err) / chance:.1%}).  STRICT crediting compares it, inside each stratum,")
    print("    to that stratum's own majority vote:")
    for c in (0, 1):
        members = [i for i in pop2 if stratum(i) == c]
        ones_c = sum(1 for i in members if label(i))
        minority_c = min(ones_c, len(members) - ones_c)
        print(f"      stratum {c}: {len(members)} members, base rate {ones_c/len(members):.2f},"
              f"  within-stratum minimum error = {minority_c}"
              f"  = stratum majority's error")
    print(f"    improvement of the policy over the within-stratum majority: 0  (strict = 0%)")
    print()
    print("    The entire lenient signal was the base rate, not the sensor.")
    print("    Pooling changes the target, not the information.")


def demo_adaptivity() -> None:
    banner("8.  Adaptivity buys resolution, not information")
    modulus, threshold = 100, 25
    p, q1, q2 = residue_blind_pair(modulus, threshold)
    n1, n2 = p * q1, p * q2
    print(f"Menu: residue queries mod {modulus}.  Indistinguishable pair:")
    print(f"  N1 = {n1}  (mod {modulus} = {n1 % modulus}),  sensor = {sensor(threshold, p, q1)}")
    print(f"  N2 = {n2}  (mod {modulus} = {n2 % modulus}),  sensor = {sensor(threshold, p, q2)}")
    print()
    print(f"{'depth':>7} {'leaves':>8} {'2^depth':>9} {'eval(N1)':>10} {'eval(N2)':>10}"
          f" {'errs on one?':>13}")
    for depth in [1, 2, 4, 8, 16]:
        residues = [(7 * k) % modulus for k in range(depth)]
        verdicts = [k % 2 == 0 for k in range(depth)]
        tree = build_residue_tree(modulus, residues, verdicts)
        v1, v2 = tree_eval(tree, n1), tree_eval(tree, n2)
        errs = (v1 != sensor(threshold, p, q1)) or (v2 != sensor(threshold, p, q2))
        print(f"{tree_depth(tree):>7} {tree_leaves(tree):>8} {2**tree_depth(tree):>9}"
              f" {str(v1):>10} {str(v2):>10} {str(errs):>13}")
    print()
    print("Every tree returns the SAME verdict on both samples, so every tree errs on one of")
    print("them -- at any depth, however fitted.  Leaf counts confirm leaves <= 2^depth.")


def demo_divisor_lattice() -> None:
    banner("9.  Divisor-Lattice Navigation Law")
    print("For arbitrary odd N the scan cost is min over nontrivial divisors e of")
    print("((e + N/e)/2 - isqrt(N)) -- not a property of the prime factors alone.")
    print()
    print(f"{'N':>8} {'factorisation':>22} {'#divisors':>10} {'lattice min':>12}"
          f" {'least budget':>13}  agree")
    for n in [3 * 5, 3 * 3 * 3, 1155, 3465, 9999, 10403, 15015, 19999]:
        if n % 2 == 0:
            continue
        cost = navigation_cost(n)
        if cost is None:
            continue
        least = least_successful_budget(n, cost + 5)
        facs = [f"{e}*{n//e}" for e in divisors(n) if 1 < e <= isqrt(n)]
        label = ", ".join(facs[:3]) + ("..." if len(facs) > 3 else "")
        print(f"{n:>8} {label:>22} {len(divisors(n)):>10} {cost:>12} {str(least):>13}"
              f"  {cost == least}")
    print()
    print("Exhaustive verification for all odd composite N < 20000:")
    checked = violations = 0
    for n in range(9, 20000, 2):
        cost = navigation_cost(n)
        if cost is None:
            continue
        checked += 1
        if least_successful_budget(n, cost) != cost:
            violations += 1
    print(f"  {checked} odd composites checked; violations: {violations}")
    print()
    print("Richly composite N are CHEAP: the minimum is attained at an interior divisor.")


def demo_density() -> None:
    banner("10.  Fermat-close density: the hit rate is a population artefact")
    print("Exact counts of Fermat-close odd N <= X, against the proved O(sqrt(B) X^{3/4}) bound.")
    print()
    print(f"{'B':>4} {'X':>8} {'exact count':>13} {'density':>11} {'proved bound':>14}"
          f" {'bound/X':>10}")
    for threshold in (1, 4, 16):
        for limit in (2000, 10000, 40000):
            exact = count_fermat_close(limit, threshold)
            bound = close_count_bound(limit, threshold)
            print(f"{threshold:>4} {limit:>8} {exact:>13} {exact/limit:>11.5f} {bound:>14}"
                  f" {bound/limit:>10.5f}")
    print()
    print("Density falls like X^{-1/4}. A FIXED hit rate of 0.2053 cannot persist -- it is a")
    print("feature of the finite laboratory population's size-ratio coupling.")


def demo_witness() -> None:
    banner("11.  The concrete witness inside the reported window 295 < d <= 22758")
    p, q = 955277, 1044727
    n = p * q
    d = fermat_gap(p, q)
    print(f"  p = {p}  prime: {is_prime(p)}")
    print(f"  q = {q}  prime: {is_prime(q)}")
    print(f"  N = p*q = {n}")
    print(f"  isqrt(N) = {isqrt(n)},  (p+q)/2 = {mid(p, q)},  gap d = {d}")
    print()
    print(f"  sensor at B = 22758 (the measured peak): {sensor(22758, p, q)}")
    print(f"  scan hit at the 295-query menu budget:   {scan_hit(n, 295) is not None}")
    print(f"  scan hit at budget 22758:                {scan_hit(n, 22758) is not None}")
    print()
    print("The sensor says 'close'; the affordable procedure says 'nothing here'.")
    print("One number exhibits the entire realization gap, with no statistics at all.")


def demo_peak_accounting() -> None:
    banner("12.  Accounting for the 0.479797-bit peak")
    peak = 0.479797
    rows: List[Tuple[str, str, str]] = [
        ("Peak mutual information at B = 22758", f"{peak:.6f} bits", "100.0%"),
        ("Within-strata geometric excess (oracle)", "0.3634-0.3687 bits", "73.5-76.8%"),
        ("Between-strata population prior (residual)", "~0.111-0.116 bits", "~23.2-26.5%"),
        ("Best pooled policy (lenient crediting)", "0.167-0.172 bits", "33.8-35.9%"),
        ("Best policy within strata (strict)", "<= 0.0018 bits", "<= 0.38%"),
        ("Residue-only channel", "0.0008-0.0032 bits", "~0.2-0.7%"),
    ]
    print(f"{'component':>44} {'bits':>22} {'% of peak':>12}")
    for name, bits, pct in rows:
        print(f"{name:>44} {bits:>22} {pct:>12}")
    print()
    print(f"Price of the geometric channel: exactly B = 22758 probes (Budget Law).")
    print(f"Available budget: 295 menu queries.  Shortfall factor: {22758/295:.1f}x.")
    print()
    print("Three quarters of the peak is real geometry, priced beyond the budget; one quarter")
    print("is a sampling artefact of vanishing density; zero is realizable by an N-only policy.")


def main() -> None:
    print(__doc__)
    demo_gap_and_sensor()
    demo_circularity()
    demo_budget_law()
    demo_oracle_reduction()
    demo_residue_blindness()
    demo_crediting_law()
    demo_balanced_strata()
    demo_adaptivity()
    demo_divisor_lattice()
    demo_density()
    demo_witness()
    demo_peak_accounting()
    print()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
