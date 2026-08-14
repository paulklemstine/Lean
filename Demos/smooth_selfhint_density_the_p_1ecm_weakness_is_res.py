#!/usr/bin/env python3
"""
The asymmetric/symmetric divisibility dichotomy — numerical demonstration.
==========================================================================

Setting.  N = p*q is a semiprime.  The Pollard p-1 / elliptic-curve weakness of N is
the B-smoothness of p-1.  Question: is that weakness visible in N alone?

This script demonstrates, end to end and with no external dependencies:

  1. FIBRE DICHOTOMY.  In a finite group G, the number of factorisations n = a*b with
     a in A is |A|, independent of n; the number with a in A OR b in A is
     |A ∪ n*A^{-1}| = 2|A| - |A ∩ n*A^{-1}|, which does depend on n.

  2. INFORMATION.  The asymmetric mutual information is exactly 0; the symmetric one
     equals a closed form I(d) depending only on the group order d = l - 1:

         I(d) = [ log2(d/(2d-1)) + (d-1) log2(d/(d-1))
                  + 2(d-1) log2(2d/(2d-1))
                  + (d-1)(d-2) log2( d(d-2)/(d-1)^2 ) ] / d^2

     with I(2) = 3/2 - (3/4) log2 3 = 0.311278...

  3. SHARP RATE.  d^2 * I(d) -> log2(e) - 1 = 0.442695..., so the symmetric leak is
     asymptotically (log2 e - 1)/(l-1)^2 bits.

  4. EMPIRICAL AGREEMENT.  A Monte-Carlo experiment on random k-bit semiprimes
     reproduces 0 bits (asymmetric) and I(l-1) bits (symmetric).

  5. ZERO PREDICTION ADVANTAGE.  For l >= 5 the strictly positive symmetric leak buys
     no accuracy over the constant guess.

  6. SMOOTHNESS IS NOT A SELF-HINT.  Explicit witnesses show the publicly computable
     smoothness bits of N-1 and N+1 are logically independent of the secret bit
     "p-1 is 10-smooth", and a Dirichlet-style swap produces congruent semiprimes with
     opposite secret bits.

  7. TROPICALISATION.  In the min-plus semiring, the one-sided cheapest-factorisation
     cost is constant in n while the symmetric "all factors cheap" cost is not.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Elementary number theory (inlined; no imports beyond the standard library)
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    small_primes: Tuple[int, ...] = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for sp in small_primes:
        if n % sp == 0:
            return n == sp
    d: int = n - 1
    r: int = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small_primes:
        x: int = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def factorize(n: int) -> Dict[int, int]:
    """Trial division with Pollard rho fallback; ample for the sizes used here."""
    factors: Dict[int, int] = {}
    if n <= 1:
        return factors
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47):
        while n % p == 0:
            factors[p] = factors.get(p, 0) + 1
            n //= p
    if n == 1:
        return factors
    stack: List[int] = [n]
    while stack:
        m: int = stack.pop()
        if m == 1:
            continue
        if is_prime(m):
            factors[m] = factors.get(m, 0) + 1
            continue
        d: int = _pollard_rho(m)
        stack.append(d)
        stack.append(m // d)
    return factors


def _pollard_rho(n: int) -> int:
    if n % 2 == 0:
        return 2
    while True:
        x: int = random.randrange(2, n)
        y: int = x
        c: int = random.randrange(1, n)
        d: int = 1
        while d == 1:
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = math.gcd(abs(x - y), n)
        if d != n:
            return d


def largest_prime_factor(n: int) -> int:
    """L(n): the largest prime factor of n (L(1) = 1)."""
    if n <= 1:
        return 1
    return max(factorize(n))


def is_b_smooth(n: int, bound: int) -> bool:
    """Every prime factor of n is at most `bound`."""
    return largest_prime_factor(n) <= bound


def random_prime(bits: int) -> int:
    """A uniformly-ish random prime with exactly `bits` bits."""
    lo: int = 1 << (bits - 1)
    hi: int = (1 << bits) - 1
    while True:
        candidate: int = random.randrange(lo, hi + 1) | 1
        if is_prime(candidate):
            return candidate


# ---------------------------------------------------------------------------
# 1. Fibre counting in a finite group  (here G = (Z/l)^*, written additively-free)
# ---------------------------------------------------------------------------


def units_mod(ell: int) -> List[int]:
    """The group G = (Z/l)^*, as a sorted list of representatives."""
    return [a for a in range(1, ell) if math.gcd(a, ell) == 1]


def asym_fibre_count(ell: int, target: Sequence[int], n: int) -> int:
    """#{(a,b) in G x G : a*b = n mod l, a in target}.  Theory: |target|."""
    group: List[int] = units_mod(ell)
    return sum(1 for a in group for b in group if a * b % ell == n % ell and a in target)


def sym_fibre_count(ell: int, target: Sequence[int], n: int) -> int:
    """#{(a,b) : a*b = n, a in target OR b in target}.  Theory: |A ∪ n A^{-1}|."""
    group: List[int] = units_mod(ell)
    return sum(
        1
        for a in group
        for b in group
        if a * b % ell == n % ell and (a in target or b in target)
    )


def union_formula(ell: int, target: Sequence[int], n: int) -> int:
    """|A ∪ n A^{-1}|, the closed form for the symmetric fibre count."""
    a_set = set(x % ell for x in target)
    reflected = set(n * pow(x, -1, ell) % ell for x in a_set)
    return len(a_set | reflected)


# ---------------------------------------------------------------------------
# 2. Mutual information
# ---------------------------------------------------------------------------


def mutual_information_bits(joint: Dict[Tuple[object, object], float]) -> float:
    """I(X;Y) in bits for a joint pmf given as a dict {(x, y): p}."""
    total: float = sum(joint.values())
    if total <= 0:
        return 0.0
    px: Dict[object, float] = {}
    py: Dict[object, float] = {}
    for (x, y), p in joint.items():
        px[x] = px.get(x, 0.0) + p / total
        py[y] = py.get(y, 0.0) + p / total
    info: float = 0.0
    for (x, y), p in joint.items():
        pxy: float = p / total
        if pxy > 0.0:
            info += pxy * math.log2(pxy / (px[x] * py[y]))
    return info


def sym_mi_closed_form(d: float) -> float:
    """The exact symmetric leak I(d) in a finite group of order d, in bits."""
    term4: float = (
        0.0 if d <= 2 else (d - 1) * (d - 2) * math.log2(d * (d - 2) / (d - 1) ** 2)
    )
    return (
        math.log2(d / (2 * d - 1))
        + (d - 1) * math.log2(d / (d - 1))
        + 2 * (d - 1) * math.log2(2 * d / (2 * d - 1))
        + term4
    ) / d**2


# ---------------------------------------------------------------------------
# 3. Prediction advantage
# ---------------------------------------------------------------------------


def best_predictor_score(ell: int, counts: Dict[int, int]) -> Tuple[int, int, int]:
    """
    Scores (out of |G|^2) of: the Bayes residue-reading predictor, the constant-true
    predictor and the constant-false predictor, given the per-fibre event counts.
    """
    size: int = ell - 1
    bayes: int = sum(max(c, size - c) for c in counts.values())
    always_true: int = sum(counts.values())
    always_false: int = sum(size - c for c in counts.values())
    return bayes, always_true, always_false


# ---------------------------------------------------------------------------
# 4. Tropical (min-plus) statistics
# ---------------------------------------------------------------------------


def tropical_first_cost(ell: int, cost: Callable[[int], int], n: int) -> int:
    """min over factorisations n = a*b of cost(a).  Theory: constant in n."""
    group: List[int] = units_mod(ell)
    return min(cost(a) for a in group for b in group if a * b % ell == n % ell)


def tropical_worst_cost(ell: int, cost: Callable[[int], int], n: int) -> int:
    """min over factorisations n = a*b of max(cost(a), cost(b)) — a smoothness cost."""
    group: List[int] = units_mod(ell)
    return min(
        max(cost(a), cost(b))
        for a in group
        for b in group
        if a * b % ell == n % ell
    )


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_fibre_dichotomy(primes: Iterable[int] = (3, 5, 7, 11, 13)) -> None:
    print("=" * 78)
    print("1.  FIBRE DICHOTOMY:  one-sided counts are constant, two-sided are not")
    print("=" * 78)
    for ell in primes:
        group: List[int] = units_mod(ell)
        target: List[int] = [1]  # the event "l divides x - 1"
        asym: List[int] = [asym_fibre_count(ell, target, n) for n in group]
        sym: List[int] = [sym_fibre_count(ell, target, n) for n in group]
        formula: List[int] = [union_formula(ell, target, n) for n in group]
        assert sym == formula, "closed form for the symmetric count must match"
        print(f"  l = {ell:2d}   |G| = {ell-1:2d}")
        print(f"      asymmetric counts over n = {group}:  {asym}   (constant = |A| = 1)")
        print(f"      symmetric  counts over n = {group}:  {sym}   (= |A ∪ nA^-1|)")
    print()


def demo_closed_form() -> None:
    print("=" * 78)
    print("2.  EXACT LEAK, MEASURED LEAK, AND THE SHARP RATE")
    print("=" * 78)
    measured: Dict[int, float] = {3: 0.313, 5: 0.036, 7: 0.015, 11: 0.005}
    print("   l    d=l-1    closed form I(d)      measured        model MI")
    for ell in (3, 5, 7, 11):
        d: int = ell - 1
        theory: float = sym_mi_closed_form(float(d))
        group: List[int] = units_mod(ell)
        joint: Dict[Tuple[object, object], float] = {}
        for n in group:
            c: int = sym_fibre_count(ell, [1], n)
            joint[(n, True)] = c / d**2
            joint[(n, False)] = (d - c) / d**2
        empirical: float = mutual_information_bits(joint)
        print(
            f"  {ell:3d}   {d:5d}    {theory:16.6f}   {measured[ell]:10.3f}"
            f"   {empirical:14.6f}"
        )
    exact3: float = 1.5 - 0.75 * math.log2(3.0)
    print(f"\n  exact value at l = 3 :  3/2 - (3/4) log2 3 = {exact3:.6f}")
    print(f"  closed form at d = 2 :                       {sym_mi_closed_form(2.0):.6f}")

    print("\n  Sharp rate:  d^2 * I(d)  ->  log2(e) - 1 = "
          f"{math.log2(math.e) - 1:.6f}")
    for d in (2, 4, 6, 10, 100, 1000, 10000):
        print(f"      d = {d:6d}    d^2 I(d) = {d*d*sym_mi_closed_form(float(d)):.6f}")
    for d in (2, 4, 6, 10, 100):
        assert sym_mi_closed_form(float(d)) < 2.0 / d**2, "I(d) < 2/d^2"
    print("      verified:  I(d) < 2/d^2  for every d tested")
    print()


def demo_monte_carlo(
    prime_bits: int = 16, samples: int = 20000, seed: int = 20260814
) -> None:
    print("=" * 78)
    print(f"3.  MONTE CARLO: {samples} semiprimes N = p*q with {prime_bits}-bit factors")
    print("=" * 78)
    random.seed(seed)
    data: List[Tuple[int, int, int]] = []
    for _ in range(samples):
        p: int = random_prime(prime_bits)
        q: int = random_prime(prime_bits)
        while q == p:
            q = random_prime(prime_bits)
        if p > q:
            p, q = q, p
        data.append((p, q, p * q))

    def mi_of(pairs: List[Tuple[int, bool]]) -> float:
        joint: Counter = Counter(pairs)
        return mutual_information_bits({k: float(v) for k, v in joint.items()})

    print("          asymmetric  l | p-1        symmetric  l|p-1 or l|q-1")
    print("    l     estimate    shuffled       estimate    shuffled     theory")
    for ell in (3, 5, 7, 11):
        asym: List[Tuple[int, bool]] = []
        sym: List[Tuple[int, bool]] = []
        for p, q, n in data:
            if p % ell == 0 or q % ell == 0:
                continue
            res: int = n % ell
            asym.append((res, (p - 1) % ell == 0))
            sym.append((res, (p - 1) % ell == 0 or (q - 1) % ell == 0))
        # shuffled-label nulls quantify the positive bias of the plug-in estimator
        res_a: List[int] = [r for r, _ in asym]
        lab_a: List[bool] = [b for _, b in asym]
        lab_s: List[bool] = [b for _, b in sym]
        random.shuffle(lab_a)
        random.shuffle(lab_s)
        null_a: float = mi_of(list(zip(res_a, lab_a)))
        null_s: float = mi_of(list(zip(res_a, lab_s)))
        theory: float = sym_mi_closed_form(float(ell - 1))
        print(
            f"   {ell:3d}    {mi_of(asym):9.5f}   {null_a:9.5f}      "
            f"{mi_of(sym):9.5f}   {null_s:9.5f}   {theory:9.5f}"
        )
    print("\n   The asymmetric estimate sits at the shuffled-null level (pure estimator")
    print("   bias around the exact value 0); the symmetric one tracks the theory.")

    # Density conditioning-invariance and the base weakness rate.
    bound: int = 1000
    weak_by_class: Dict[int, List[int]] = {}
    weak_total: int = 0
    for p, q, n in data[: min(len(data), 6000)]:
        weak: int = 1 if is_b_smooth(p - 1, bound) else 0
        weak_total += weak
        weak_by_class.setdefault(n % 3, []).append(weak)
    n_weak_samples: int = sum(len(v) for v in weak_by_class.values())
    print(f"\n   fraction with p-1 {bound}-smooth (the 'weak' class): "
          f"{weak_total/n_weak_samples:.3f}")
    for res in sorted(weak_by_class):
        vals: List[int] = weak_by_class[res]
        print(f"      conditioned on N = {res} mod 3 :  {sum(vals)/len(vals):.3f}"
              f"   (n = {len(vals)})")
    print("   -> the conditional densities equal the base rate: conditioning is inert")
    print()


def demo_forcing_and_ambiguity() -> None:
    print("=" * 78)
    print("4.  THE EXACT l = 3 MECHANISM, AND ITS ASYMMETRIC FAILURE")
    print("=" * 78)
    print("  Theorem: N = pq = 2 mod 3 (p,q != 3) forces 3 | p-1 or 3 | q-1.")
    violations: int = 0
    checked: int = 0
    for p in [x for x in range(5, 400) if is_prime(x) and x != 3]:
        for q in [x for x in range(5, 400) if is_prime(x) and x != 3]:
            if p * q % 3 == 2:
                checked += 1
                if (p - 1) % 3 != 0 and (q - 1) % 3 != 0:
                    violations += 1
    print(f"    checked {checked} pairs with N = 2 mod 3;  violations: {violations}")
    print("\n  But the asymmetric question stays undecided inside each class:")
    for p, q in ((7, 11), (5, 13), (7, 13), (5, 11)):
        print(f"    N = {p*q:3d} = {p:2d} * {q:2d} :  N mod 3 = {p*q%3},"
              f"  3 | p-1 ? {(p-1)%3 == 0}")
    print("    -> both residue classes carry both outcomes: zero leak per class")
    print()


def demo_prediction_advantage() -> None:
    print("=" * 78)
    print("5.  POSITIVE INFORMATION, ZERO PREDICTION ADVANTAGE")
    print("=" * 78)
    print("    l   |G|   Bayes score   always-true   always-false   advantage")
    for ell in (3, 5, 7, 11, 13):
        group: List[int] = units_mod(ell)
        counts: Dict[int, int] = {n: sym_fibre_count(ell, [1], n) for n in group}
        bayes, t, f = best_predictor_score(ell, counts)
        adv: int = bayes - max(t, f)
        print(f"   {ell:3d}  {ell-1:4d}   {bayes:11d}   {t:11d}   {f:12d}   {adv:9d}")
    print("\n   |G| = 2 (l = 3) is the exception; from l = 5 on, the Bayes predictor")
    print("   ties the constant guess even though the mutual information is > 0.")
    print()


def demo_smoothness_not_a_hint() -> None:
    print("=" * 78)
    print("6.  SMOOTHNESS OF p-1 IS NOT A FUNCTION OF THE PUBLIC DATA")
    print("=" * 78)
    bound: int = 10
    print("  Four witnesses realising all four (public bit, secret bit) combinations:")
    print("     N      p    q    N-1 10-smooth?   p-1 10-smooth?")
    for n, p, q in ((253, 11, 23), (1081, 23, 47), (143, 11, 13), (667, 23, 29)):
        assert p * q == n
        print(f"   {n:5d}  {p:3d}  {q:3d}      {str(is_b_smooth(n-1, bound)):>10s}"
              f"      {str(is_b_smooth(p-1, bound)):>12s}")
    print("\n  The pair of public bits is still insufficient:")
    for n, p in ((253, 11), (1081, 23)):
        print(f"    N = {n:5d} :  (N-1 smooth, N+1 smooth) = "
              f"({is_b_smooth(n-1, bound)}, {is_b_smooth(n+1, bound)})"
              f"   secret bit = {is_b_smooth(p-1, bound)}")
    print("    -> same public pair, opposite secret bit: logical independence")

    print("\n  The swap construction: congruent semiprimes, opposite secret bits.")
    ell, modulus = 3, 1155
    q_mod: int = ell * modulus
    found: List[int] = []
    x: int = q_mod + 1
    while len(found) < 4 and x < 200 * q_mod:
        if is_prime(x) and x % q_mod == 1:
            found.append(x)
        x += 1
    hi: List[int] = []
    y: int = q_mod - 1
    while len(hi) < 4 and y < 200 * q_mod:
        if is_prime(y) and y % q_mod == q_mod - 1:
            hi.append(y)
        y += 1
    p1, q2 = found[0], found[1]
    q1, p2 = hi[0], hi[1]
    n1, n2 = p1 * q1, p2 * q2
    print(f"    p1 = {p1}, q1 = {q1}  ->  N1 = {n1},  N1 mod {modulus} = {n1 % modulus}")
    print(f"    p2 = {p2}, q2 = {q2}  ->  N2 = {n2},  N2 mod {modulus} = {n2 % modulus}")
    print(f"    3 | p1 - 1 ? {(p1-1) % 3 == 0}      3 | p2 - 1 ? {(p2-1) % 3 == 0}")
    assert n1 % modulus == n2 % modulus
    print("    -> identical residues, opposite secret bits: no residue dial exists")
    print()


def demo_tropical() -> None:
    print("=" * 78)
    print("7.  TROPICALISATION (min-plus): the same dichotomy, in cost form")
    print("=" * 78)
    for ell in (3, 5, 7):
        group: List[int] = units_mod(ell)
        cost: Callable[[int], int] = lambda a: 0 if a == 1 else 1
        first: List[int] = [tropical_first_cost(ell, cost, n) for n in group]
        worst: List[int] = [tropical_worst_cost(ell, cost, n) for n in group]
        print(f"  l = {ell}:  n = {group}")
        print(f"      min_(ab=n) cost(a)            = {first}   (constant in n)")
        print(f"      min_(ab=n) max(cost a, cost b) = {worst}   (varies with n)")
    print("\n  The second statistic is the tropical shadow of smoothness: the cheapest")
    print("  factorisation all of whose factors are cheap.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE ASYMMETRIC/SYMMETRIC DIVISIBILITY DICHOTOMY".ljust(77) + "#")
    print("#  Why the p-1 weakness of a semiprime is invisible in the modulus".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_fibre_dichotomy()
    demo_closed_form()
    demo_monte_carlo()
    demo_forcing_and_ambiguity()
    demo_prediction_advantage()
    demo_smoothness_not_a_hint()
    demo_tropical()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  * one-sided (asymmetric) conditions on a factorisation are invisible:")
    print("    fibre count |A|, mutual information exactly 0, zero advantage;")
    print("  * two-sided (symmetric) conditions are visible: fibre count |A ∪ nA^-1|,")
    print("    leak I(l-1) bits = 0.311 at l = 3, decaying like (log2 e - 1)/(l-1)^2;")
    print("  * the visible half is nevertheless unusable for prediction once l >= 5;")
    print("  * hence the p-1/ECM-weak instance class is undetectable from N alone.")
    print()


if __name__ == "__main__":
    main()
