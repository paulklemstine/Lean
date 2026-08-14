"""
CM-ECM-GENERAL — numerical companion
====================================

Numerical demonstrations of the results on the CM curves

    E_0    : y^2 = x^3 + 1      (j = 0,    CM by Z[omega],  omega = e^{2 pi i / 3})
    E_1728 : y^2 = x^3 + x      (j = 1728, CM by Z[i])

reduced modulo primes p, and of the information-theoretic laws that govern how
much a residue class of p can reveal about the order #E(F_p).

Everything is self-contained: only the Python standard library is used.

Contents
--------
 1. Point counting on E_0 and E_1728 over F_p (naive but exact).
 2. Rational-torsion degeneracy: 6 | #E_0(F_p) for every prime p > 3.
 3. Silent-set classification: l | #E_0(F_p) for all good p  <=>  l | 6.
 4. Inert collapse: p = 2 (mod 3) => #E_0(F_p) = p + 1 exactly, a_p = 0.
 5. Atomic trace law: a_p = 0 exactly on the inert class, for both curves.
 6. The residue dial l | #E_0 <=> p = -1 (mod l) on the inert half, and its
    failure on the split half (p = 13 versus p = 31, both 4 mod 9).
 7. Empirical mutual information: the l = 3 channel is exactly 0 bits, the
    l = 5 channel is not.
 8. The union-dilution law and its exact factor mu_A(1-mu_A)/mu_U(1-mu_U).
"""

from __future__ import annotations

import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# 0. Small prime utilities
# --------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (n small)."""
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


def primes_up_to(bound: int) -> List[int]:
    """All primes < bound, by a simple sieve."""
    sieve = [True] * bound
    sieve[0:2] = [False, False]
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


# --------------------------------------------------------------------------
# 1. Point counting
# --------------------------------------------------------------------------


def curve_card(a: int, b: int, p: int) -> int:
    """
    #E(F_p) for E : y^2 = x^3 + a x + b, including the point at infinity.

    Counted by summing 1 + chi(x^3 + a x + b) over x in F_p, where chi is the
    Legendre symbol; complexity O(p log p).
    """
    total = 1  # point at infinity
    for x in range(p):
        rhs = (x * x % p * x + a * x + b) % p
        if rhs == 0:
            total += 1
        else:
            total += 2 if pow(rhs, (p - 1) // 2, p) == 1 else 0
    return total


def card_j0(p: int) -> int:
    """#E_0(F_p) for E_0 : y^2 = x^3 + 1."""
    return curve_card(0, 1, p)


def card_j1728(p: int) -> int:
    """#E_1728(F_p) for E_1728 : y^2 = x^3 + x."""
    return curve_card(1, 0, p)


def trace(card: int, p: int) -> int:
    """Trace of Frobenius a_p = p + 1 - #E(F_p)."""
    return p + 1 - card


# --------------------------------------------------------------------------
# 2. Rational-torsion degeneracy
# --------------------------------------------------------------------------


def check_six_torsion_degeneracy(bound: int = 500) -> Tuple[int, int]:
    """
    Verify 6 | #E_0(F_p) for every prime 3 < p < bound.

    Returns (number of primes tested, number of failures).
    """
    good = [p for p in primes_up_to(bound) if p > 3]
    failures = sum(1 for p in good if card_j0(p) % 6 != 0)
    return len(good), failures


def torsion_translation_orbit(p: int, point: Tuple[int, int]) -> List[Tuple[int, int]]:
    """
    The orbit of an affine point (x, y) with x != 0 under translation by the
    rational 3-torsion point T = (0, 1) on y^2 = x^3 + 1, computed via the
    explicit rational maps

        x  |->  2 (1 - y) / x^2 ,        y  |->  (y - 3) / (y + 1).

    The orbit always has length exactly 3: the map is fixed-point free of
    order 3, which is precisely why 3 divides the point count.
    """
    orbit = [point]
    x, y = point
    for _ in range(2):
        inv_x2 = pow(x * x % p, p - 2, p)
        inv_yp1 = pow((y + 1) % p, p - 2, p)
        x, y = (2 * (1 - y) % p) * inv_x2 % p, (y - 3) % p * inv_yp1 % p
        orbit.append((x, y))
    return orbit


# --------------------------------------------------------------------------
# 3. Silent-set classification
# --------------------------------------------------------------------------


def silent_levels(bound: int = 200, max_level: int = 40) -> List[int]:
    """
    All l <= max_level such that l | #E_0(F_p) for every prime 3 < p < bound.
    Theory predicts exactly the divisors of 6, i.e. {1, 2, 3, 6}.
    """
    good = [p for p in primes_up_to(bound) if p > 3]
    cards = [card_j0(p) for p in good]
    return [l for l in range(1, max_level + 1) if all(c % l == 0 for c in cards)]


# --------------------------------------------------------------------------
# 4-5. Inert collapse and the atomic trace law
# --------------------------------------------------------------------------


def inert_collapse_report(bound: int = 400) -> Dict[str, int]:
    """
    For E_0 check #E = p + 1 exactly on p = 2 (mod 3), and for E_1728 check
    #E = p + 1 exactly on p = 3 (mod 4).  Also check the converse direction of
    the trace dichotomy: a_p = 0 only on the inert class.
    """
    good = [p for p in primes_up_to(bound) if p > 3]
    j0_inert = [p for p in good if p % 3 == 2]
    j0_split = [p for p in good if p % 3 == 1]
    g_inert = [p for p in good if p % 4 == 3]
    g_split = [p for p in good if p % 4 == 1]
    return {
        "j0_inert_tested": len(j0_inert),
        "j0_inert_collapse_failures": sum(1 for p in j0_inert if card_j0(p) != p + 1),
        "j0_split_with_zero_trace": sum(1 for p in j0_split if trace(card_j0(p), p) == 0),
        "g_inert_tested": len(g_inert),
        "g_inert_collapse_failures": sum(1 for p in g_inert if card_j1728(p) != p + 1),
        "g_split_with_zero_trace": sum(
            1 for p in g_split if trace(card_j1728(p), p) == 0
        ),
    }


def atomic_trace_law(bound: int = 400) -> Tuple[int, int, float]:
    """
    Count the primes with a_p = 0 for E_0 and compare with the count of inert
    primes p = 2 (mod 3).  The two counts are equal, and the frequency tends to
    1/2 by Dirichlet.
    """
    good = [p for p in primes_up_to(bound) if p > 3]
    zeros = sum(1 for p in good if trace(card_j0(p), p) == 0)
    inert = sum(1 for p in good if p % 3 == 2)
    return zeros, inert, zeros / len(good)


# --------------------------------------------------------------------------
# 6. The residue dial, and its failure on the split half
# --------------------------------------------------------------------------


def inert_dial_check(level: int, bound: int = 600) -> Tuple[int, int]:
    """
    On the inert half, l | #E_0(F_p) <=> p = l - 1 (mod l).
    Returns (primes tested, mismatches).
    """
    inert = [p for p in primes_up_to(bound) if p > 3 and p % 3 == 2]
    bad = sum(
        1
        for p in inert
        if (card_j0(p) % level == 0) != (p % level == level - 1)
    )
    return len(inert), bad


def split_half_dial_failure() -> Dict[str, int]:
    """
    p = 13 and p = 31 are both 1 mod 3 (split) and both 4 mod 9, yet
    #E_0(F_13) = 12 (not divisible by 9) while #E_0(F_31) = 36 (divisible by 9);
    the traces 2 and -4 are also incongruent mod 9.
    """
    return {
        "card_13": card_j0(13),
        "card_31": card_j0(31),
        "trace_13": trace(card_j0(13), 13),
        "trace_31": trace(card_j0(31), 31),
    }


# --------------------------------------------------------------------------
# 7. Empirical mutual information
# --------------------------------------------------------------------------


def empirical_mutual_information(
    classes: Sequence[int], events: Sequence[bool]
) -> float:
    """
    Plug-in mutual information I(class ; event) in nats for a finite sample,
    with the convention 0 log 0 = 0.
    """
    n = len(classes)
    labels = sorted(set(classes))
    total = 0.0
    for k in labels:
        pk = sum(1 for c in classes if c == k) / n
        for b in (True, False):
            pb = sum(1 for e in events if e == b) / n
            pkb = sum(1 for c, e in zip(classes, events) if c == k and e == b) / n
            if pkb > 0 and pk > 0 and pb > 0:
                total += pkb * math.log(pkb / (pk * pb))
    return total


def channel_information(level: int, modulus: int, bound: int = 2000) -> float:
    """
    Empirical mutual information (in nats) between the class p mod `modulus`
    and the ECM-order event  level | #E_0(F_p),  over all good primes < bound.
    """
    good = [p for p in primes_up_to(bound) if p > 3]
    classes = [p % modulus for p in good]
    events = [card_j0(p) % level == 0 for p in good]
    return empirical_mutual_information(classes, events)


# --------------------------------------------------------------------------
# 8. The union-dilution law
# --------------------------------------------------------------------------


def eta_squared(weights: Sequence[float], probs: Sequence[float]) -> float:
    """
    Normalised conditional variation (squared correlation ratio) of a binary
    channel with class weights `weights` and conditional probabilities `probs`:

        eta^2 = sum_k w_k (a_k - mu)^2 / (mu (1 - mu)),   mu = sum_k w_k a_k.
    """
    mu = sum(w * a for w, a in zip(weights, probs))
    var = sum(w * (a - mu) ** 2 for w, a in zip(weights, probs))
    return var / (mu * (1.0 - mu))


def dilution_factor(
    weights: Sequence[float], probs: Sequence[float], blind_mass: float
) -> Tuple[float, float, float]:
    """
    Add a class-blind event of probability `blind_mass`, disjoint from the
    conditional event, and report

        (eta^2 of the class channel,
         eta^2 of the union channel,
         exact predicted factor mu_A(1-mu_A) / mu_U(1-mu_U)).
    """
    mu_a = sum(w * a for w, a in zip(weights, probs))
    mu_u = mu_a + blind_mass
    base = eta_squared(weights, probs)
    union = eta_squared(weights, [a + blind_mass for a in probs])
    factor = (mu_a * (1 - mu_a)) / (mu_u * (1 - mu_u))
    return base, union, factor


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------


def main() -> None:
    line = "-" * 72

    print(line)
    print("1. Rational-torsion degeneracy:  6 | #E_0(F_p) for every prime p > 3")
    print(line)
    tested, failures = check_six_torsion_degeneracy(500)
    print(f"   primes tested (3 < p < 500): {tested}")
    print(f"   failures of 6 | #E_0(F_p)  : {failures}")
    sample = [(p, card_j0(p)) for p in (5, 7, 11, 13, 17, 19, 23, 29, 31)]
    print("   #E_0(F_p) for small p      :", ", ".join(f"{p}:{c}" for p, c in sample))
    print("   orbit of (2,3) under translation by the 3-torsion point, p = 11:")
    print("     ", torsion_translation_orbit(11, (2, 3)))

    print()
    print(line)
    print("2. Silent set: l | #E_0(F_p) for ALL good p  <=>  l | 6")
    print(line)
    print("   silent levels l <= 40 found:", silent_levels(200, 40))
    print("   divisors of 6              :", [l for l in range(1, 41) if 6 % l == 0])

    print()
    print(line)
    print("3. Inert collapse #E = p + 1, for both CM curves")
    print(line)
    for key, value in inert_collapse_report(400).items():
        print(f"   {key:32s}: {value}")

    print()
    print(line)
    print("4. Atomic trace law: #{a_p = 0} = #{p inert}")
    print(line)
    zeros, inert, freq = atomic_trace_law(400)
    print(f"   primes with a_p = 0 : {zeros}")
    print(f"   inert primes        : {inert}")
    print(f"   frequency of a_p = 0: {freq:.4f}   (Dirichlet limit 0.5)")

    print()
    print(line)
    print("5. The residue dial on the inert half, and its split-half failure")
    print(line)
    for level in (5, 9, 27):
        tested, bad = inert_dial_check(level, 600)
        print(f"   l = {level:3d}:  inert primes tested {tested:4d},  mismatches {bad}")
    info = split_half_dial_failure()
    print("   split-half counterexample at l = 9 (13 and 31 are both 4 mod 9):")
    print(
        f"     #E_0(F_13) = {info['card_13']} (9 divides: {info['card_13'] % 9 == 0}), "
        f"a_13 = {info['trace_13']}"
    )
    print(
        f"     #E_0(F_31) = {info['card_31']} (9 divides: {info['card_31'] % 9 == 0}), "
        f"a_31 = {info['trace_31']}"
    )

    print()
    print(line)
    print("6. Information carried by the ECM-order channels (nats)")
    print(line)
    for level, modulus in ((3, 3), (3, 9), (6, 9), (5, 5), (9, 9), (7, 7)):
        val = channel_information(level, modulus, 2000)
        tag = "  <-- silent (exactly 0)" if level in (1, 2, 3, 6) else ""
        print(f"   l = {level:2d}, class p mod {modulus:2d}: I = {val:.6f}{tag}")
    print("   perfectly correlated two-point sample:", end=" ")
    print(f"{empirical_mutual_information([0, 1], [False, True]):.6f} = log 2")

    print()
    print(line)
    print("7. Union dilution: mixing in a class-blind half can only shrink eta^2")
    print(line)
    weights = [0.5, 0.5]
    probs = [0.10, 0.02]
    for blind in (0.0, 0.05, 0.15, 0.30):
        base, union, factor = dilution_factor(weights, probs, blind)
        print(
            f"   b = {blind:4.2f}:  eta^2(A) = {base:.6f}, "
            f"eta^2(A u B) = {union:.6f}, ratio = {union / base:.6f}, "
            f"predicted = {factor:.6f}"
        )


if __name__ == "__main__":
    main()


"""
Algorithm: union-dilution correction and the sharpness construction.

Measuring a union event A u B, where B is class-blind (independent of the class
statistic) and disjoint from A, systematically understates the conditional
effect: the weighted conditional variance is unchanged while the normaliser
mu(1-mu) grows, so the squared correlation ratio is multiplied by exactly

    mu_A (1 - mu_A) / mu_U (1 - mu_U),   mu_U = mu_A + P(B).

This module inverts the distortion, and constructs, for any target factor
c in (0, 1), an honest two-class channel realising it exactly -- so no universal
constant below 1 can improve the bound.
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


def weighted_mean(weights: Sequence[float], probs: Sequence[float]) -> float:
    return sum(w * a for w, a in zip(weights, probs))


def weighted_variance(weights: Sequence[float], probs: Sequence[float]) -> float:
    mu = weighted_mean(weights, probs)
    return sum(w * (a - mu) ** 2 for w, a in zip(weights, probs))


def eta_squared(weights: Sequence[float], probs: Sequence[float]) -> float:
    """Normalised conditional variation (squared correlation ratio)."""
    mu = weighted_mean(weights, probs)
    return weighted_variance(weights, probs) / (mu * (1.0 - mu))


def dilution_factor(mu_a: float, mu_u: float) -> float:
    """Exact factor by which a class-blind admixture scales eta^2."""
    return (mu_a * (1 - mu_a)) / (mu_u * (1 - mu_u))


def undilute(eta_union: float, mu_a: float, mu_u: float) -> float:
    """
    Recover the conditional effect size from a measured union effect size.
    This should be applied before comparing against a null threshold that was
    calibrated on a pure conditional channel.
    """
    return eta_union / dilution_factor(mu_a, mu_u)


def realise_factor(c: float) -> Tuple[List[float], float, float, float]:
    """
    Construct a two-class channel with equal weights whose eta^2 is diluted by
    exactly the factor c in (0, 1).

    Take r = sqrt(1 - c), mu = (1 - r) / 2, conditional probabilities
    (mu + mu/2, mu - mu/2) and class-blind mass b = 1/2 - mu.  Then the union
    base rate is exactly 1/2, so the union normaliser is 1/4 and the factor is
    4 mu (1 - mu) = 1 - r^2 = c.
    """
    if not 0.0 < c < 1.0:
        raise ValueError("c must lie strictly between 0 and 1")
    r = math.sqrt(1.0 - c)
    mu = (1.0 - r) / 2.0
    probs = [mu + mu / 2.0, mu - mu / 2.0]
    b = 0.5 - mu
    weights = [0.5, 0.5]
    achieved = eta_squared(weights, [a + b for a in probs]) / eta_squared(weights, probs)
    return probs, b, achieved, c


if __name__ == "__main__":
    weights = [0.5, 0.5]
    probs = [0.10, 0.02]
    b = 0.18
    mu_a = weighted_mean(weights, probs)
    mu_u = mu_a + b
    eU = eta_squared(weights, [a + b for a in probs])
    print("conditional profile      :", probs)
    print("class-blind mass b       :", b)
    print("measured union eta^2     : %.6f" % eU)
    print("recovered conditional    : %.6f" % undilute(eU, mu_a, mu_u))
    print("true conditional eta^2   : %.6f" % eta_squared(weights, probs))
    print()
    for c in (0.9, 0.5, 0.25, 0.05):
        probs_c, b_c, achieved, target = realise_factor(c)
        print(
            f"target factor {target:5.2f} realised by a = "
            f"({probs_c[0]:.4f}, {probs_c[1]:.4f}), b = {b_c:.4f}  ->  "
            f"achieved {achieved:.6f}"
        )


"""
Algorithm: CM order oracle with inert short-circuit.

Computes #E(F_p) for the two CM curves y^2 = x^3 + b (j = 0) and y^2 = x^3 + x
(j = 1728).  On the inert half of the CM field the answer is returned in O(1)
because the order is provably p + 1; otherwise character summation is used.
"""

from __future__ import annotations

from typing import Literal, Tuple


def legendre(c: int, p: int) -> int:
    """Legendre symbol (c | p) by Euler's criterion, O(log p)."""
    c %= p
    if c == 0:
        return 0
    return 1 if pow(c, (p - 1) // 2, p) == 1 else -1


def order_j0(p: int, b: int = 1) -> Tuple[int, str]:
    """
    #E_b(F_p) for E_b : y^2 = x^3 + b, together with the reason.

    If p = 2 (mod 3) the cubing map is a bijection of F_p, so for each y there
    is exactly one x with x^3 = y^2 - b: the order is p + 1 for every b, in O(1).
    Otherwise character summation costs O(p log p).
    """
    if p % 3 == 2:
        return p + 1, "inert: cubing is bijective, order = p + 1 for every b"
    total = 1 + sum(1 + legendre((x * x % p) * x + b, p) for x in range(p))
    return total, "split: character summation"


def order_j1728(p: int) -> Tuple[int, str]:
    """
    #E(F_p) for y^2 = x^3 + x.

    If p = 3 (mod 4) then -1 is a non-residue and the odd cubic pairs the fibres
    over c and -c, giving exactly two points per pair: the order is p + 1, O(1).
    """
    if p % 4 == 3:
        return p + 1, "inert: sign pairing, order = p + 1"
    total = 1 + sum(1 + legendre((x * x % p) * x + x, p) for x in range(p))
    return total, "split: character summation"


def trace(order: int, p: int) -> int:
    """Trace of Frobenius a_p = p + 1 - #E(F_p)."""
    return p + 1 - order


def divides_order(p: int, level: int, curve: Literal["j0", "j1728"] = "j0") -> bool:
    """
    Decide whether `level` divides the elliptic order, using the residue dial
    when it applies: on the inert half the question is purely congruential,
    level | #E  <=>  p = level - 1 (mod level), answered without counting.
    """
    if curve == "j0" and p % 3 == 2:
        return p % level == level - 1
    if curve == "j1728" and p % 4 == 3:
        return p % level == level - 1
    order = order_j0(p)[0] if curve == "j0" else order_j1728(p)[0]
    return order % level == 0


if __name__ == "__main__":
    for p in (11, 13, 17, 19, 23, 29, 31):
        o0, why0 = order_j0(p)
        o1, why1 = order_j1728(p)
        print(
            f"p = {p:3d}   #E_0 = {o0:4d} (a_p = {trace(o0, p):4d})  [{why0}]"
            f"   |   #E_1728 = {o1:4d} (a_p = {trace(o1, p):4d})  [{why1}]"
        )
    print()
    print("9 divides #E_0(F_17)?", divides_order(17, 9), " (17 = 8 mod 9, inert)")
    print("9 divides #E_0(F_31)?", divides_order(31, 9), " (31 split: counted)")


"""
Algorithm: silent-set classification for a divisibility channel.

A level `l` is *silent* for a curve if l divides #E(F_p) for every good prime p;
a silent channel carries exactly zero information about any statistic of p,
because its event never varies.  The silent set is the divisor set of
g = gcd over good primes of #E(F_p), and for the j = 0 curve y^2 = x^3 + 1 the
gcd equals 6 -- the order of the rational torsion subgroup -- and stabilises
after a single prime (p = 5 already gives #E = 6).
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Tuple


def primes_up_to(bound: int) -> List[int]:
    sieve = [True] * (bound + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def curve_card(a: int, b: int, p: int) -> int:
    """#E(F_p) for y^2 = x^3 + a x + b, by character summation."""
    total = 1
    for x in range(p):
        rhs = ((x * x % p) * x + a * x + b) % p
        if rhs == 0:
            total += 1
        else:
            total += 2 if pow(rhs, (p - 1) // 2, p) == 1 else 0
    return total


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def silent_set(
    a: int, b: int, bad_primes: Tuple[int, ...], bound: int = 200
) -> Dict[str, object]:
    """
    Compute the silent set of the curve y^2 = x^3 + a x + b.

    Returns the running gcd of the orders, the prime at which it stabilises,
    and the resulting silent set (the divisors of the stable gcd).
    Complexity: O(sum over sampled p of p log p) for the counts, plus O(log)
    per gcd update.
    """
    running = 0
    stabilised_at = None
    history: List[Tuple[int, int, int]] = []
    for p in primes_up_to(bound):
        if p in bad_primes:
            continue
        card = curve_card(a, b, p)
        new = gcd(running, card) if running else card
        history.append((p, card, new))
        if running and new == running and stabilised_at is None:
            stabilised_at = p
        running = new
    return {
        "gcd": running,
        "silent_set": divisors(running),
        "stabilised_at": stabilised_at,
        "history": history[:6],
    }


if __name__ == "__main__":
    for name, (a, b, bad) in {
        "E_0 : y^2 = x^3 + 1   (j = 0)": (0, 1, (2, 3)),
        "E_1728 : y^2 = x^3 + x (j = 1728)": (1, 0, (2,)),
        "a generic curve y^2 = x^3 + x + 1": (1, 1, (2, 31)),
    }.items():
        info = silent_set(a, b, bad, 150)
        print(name)
        print(f"    gcd of the orders        : {info['gcd']}")
        print(f"    silent set (zero-bit set): {info['silent_set']}")
        print(f"    stabilised at prime      : {info['stabilised_at']}")
        print(f"    first counts (p, #E, gcd): {info['history']}")
        print()


"""
Algorithm: torsion-orbit certificate for a divisibility law.

Instead of *observing* that 3 divides #E_0(F_p) for many p, this routine
produces a certificate: it exhibits the translation by the rational 3-torsion
point T = (0, 1) of E_0 : y^2 = x^3 + 1 as an explicit self-map of the point set
over F_p,

        tau(x, y) = ( 2 (1 - y) / x^2 ,  (y - 3) / (y + 1) )   for x != 0,
        infinity -> (0, 1) -> (0, -1) -> infinity,

verifies that it is well defined, of order three, and fixed-point free, and then
partitions the point set into its orbits.  Every orbit has size exactly three,
which *proves* the divisibility for that prime: no counting argument beyond the
orbit decomposition is needed.

Complexity: O(p^2) to enumerate the affine points naively (or O(p log p) with
character sums), then O(#E) for the orbit walk.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

Point = Tuple[int, int]


def inverse(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def affine_points(p: int) -> List[Point]:
    """All (x, y) in F_p^2 with y^2 = x^3 + 1."""
    squares: Dict[int, List[int]] = {}
    for y in range(p):
        squares.setdefault(y * y % p, []).append(y)
    pts: List[Point] = []
    for x in range(p):
        rhs = ((x * x % p) * x + 1) % p
        for y in squares.get(rhs, []):
            pts.append((x, y))
    return pts


def tau(point: Point, p: int) -> Point:
    """Translation by the 3-torsion point (0, 1), on the locus x != 0."""
    x, y = point
    nx = (2 * (1 - y)) % p * inverse(x * x % p, p) % p
    ny = (y - 3) % p * inverse((y + 1) % p, p) % p
    return (nx, ny)


def certificate(p: int) -> Dict[str, object]:
    """
    Build the orbit certificate for the prime p > 3.

    Returns the orbit sizes, whether the map was fixed-point free and of order
    three on every point, and the resulting divisibility conclusion.
    """
    pts = affine_points(p)
    total = len(pts) + 1  # the point at infinity
    seen = set()
    orbits: List[List[str]] = []
    free = True
    order_three = True

    # the orbit containing the point at infinity: infinity -> (0,1) -> (0,-1)
    orbits.append(["infinity", "(0, 1)", f"(0, {p - 1})"])
    seen.update({(0, 1 % p), (0, (p - 1) % p)})

    for pt in pts:
        if pt in seen or pt[0] == 0:
            continue
        orbit = []
        cur = pt
        for _ in range(3):
            orbit.append(f"({cur[0]}, {cur[1]})")
            seen.add(cur)
            nxt = tau(cur, p)
            if nxt == cur:
                free = False
            cur = nxt
        if cur != pt:
            order_three = False
        orbits.append(orbit)

    return {
        "prime": p,
        "order": total,
        "orbit_count": len(orbits),
        "all_orbits_size_three": all(len(o) == 3 for o in orbits),
        "fixed_point_free": free,
        "order_three_on_every_point": order_three,
        "conclusion": f"3 divides #E_0(F_{p}) = {total}: "
                      f"{len(orbits)} orbits of size 3",
        "sample_orbits": orbits[:4],
    }


if __name__ == "__main__":
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43):
        info = certificate(p)
        ok = (
            info["all_orbits_size_three"]
            and info["fixed_point_free"]
            and info["order_three_on_every_point"]
            and info["order"] % 3 == 0
        )
        print(f"p = {p:3d}  #E = {info['order']:3d}  orbits = {info['orbit_count']:3d}"
              f"   certificate valid: {ok}")
    print()
    print("sample orbits for p = 13:")
    for orbit in certificate(13)["sample_orbits"]:
        print("   ", " -> ".join(orbit), "-> (back to start)")


"""Assemble PACKAGE.json from the deliverables and supporting assets."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Probability/CMECMGeneralJ0.lean",
    "Catalog/Probability/CMECMGeneralInformation.lean",
    "Catalog/Probability/CMECMGeneralTorsionSix.lean",
    "Catalog/Probability/CMECMGeneralConditionality.lean",
    "Catalog/Probability/CMECMGeneralGaussian.lean",
    "Catalog/Probability/CMECMGeneralSupersingular.lean",
    "Catalog/Probability/CMECMGeneralSilentSet.lean",
    "Catalog/Probability/CMECMGeneralTorsionUniform.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {name} =====\n\n{read(ROOT / name)}" for name in LEAN_FILES
)

INTERACTIVE_LAYOUT = r"""
# The Curve That Knows Nothing
### A guided tour of torsion silence, the inert dial, and union dilution

Factoring a large integer $N$ is, in every classical method of the
"one-prime-at-a-time" family, a bet on luck. You build a group attached to a
hidden prime divisor $p$ and hope its order is **smooth** — a product of small
primes only.

* Pollard's $p-1$ method bets on the order $p-1$.
* Williams' $p+1$ method bets on the order $p+1$.
* The elliptic curve method bets on $\#E(\mathbb{F}_p) = p + 1 - a_p$, where
  $|a_p| \le 2\sqrt{p}$ — and, crucially, *you may change the curve and re-roll
  the dice*.

That last freedom is the whole point of the elliptic method. So a natural
question presents itself, and it is the question this page is about:

> **Can a residue class of $p$ tell you anything about the divisibility of
> $\#E(\mathbb{F}_p)$ by a small number $\ell$?**

If it could, you would aim the dice instead of rolling them. The most promising
place to look is the curves with **complex multiplication**, whose arithmetic is
governed by explicit abelian reciprocity laws — the kind of structure that
classical number theory makes visible in residue classes. There are two such
curves over the rationals, famous since Gauss and Eisenstein:

$$E_0 : y^2 = x^3 + 1 \qquad\text{and}\qquad E_{1728} : y^2 = x^3 + x .$$

Let us go looking.

---

## 1 · Play with the curve first

Before any theory, get your hands on the object. The laboratory below computes
the exact point count $\#E_0(\mathbb{F}_p)$ for you, shows where the order sits
inside the Hasse interval, and lets you watch the divisibility patterns appear.

Three things to try, in order:

1. **Slide through the primes and watch the green marker.** For about half of
   them the order sits *exactly* at the centre of the Hasse interval. Look at
   which primes those are.
2. **Look at the row of ℓ's.** The columns $2$, $3$ and $6$ are ticked for
   *every single prime*. No exceptions, ever.
3. **Compare the two rows of the table.** On the inert primes they agree for all
   $\ell$; on the split primes they diverge.

{{interactive_demo:0}}

<details>
<summary><b>What am I looking at?</b> — the Hasse interval, the trace, and the two halves</summary>

The number of points of an elliptic curve over $\mathbb{F}_p$ is
$\#E(\mathbb{F}_p) = p + 1 - a_p$ with $|a_p| \le 2\sqrt{p}$ (Hasse's theorem):
the order lives in a window of width about $4\sqrt{p}$ centred at $p+1$. The
integer $a_p$ is the **trace of Frobenius**.

For $E_0$, the prime $p$ is called **inert** when $p \equiv 2 \pmod 3$ and
**split** when $p \equiv 1 \pmod 3$ — the two ways a prime can behave in the
field $\mathbb{Q}(\sqrt{-3})$ that governs this curve's extra symmetries. You
have just discovered experimentally that the trace vanishes on exactly one of
the two halves. That is a theorem, and we prove it below.

Further reading: [Hasse's theorem on elliptic curves](https://en.wikipedia.org/wiki/Hasse%27s_theorem_on_elliptic_curves),
[complex multiplication](https://en.wikipedia.org/wiki/Complex_multiplication).
</details>

---

## 2 · The pattern that is always true

Notice the point $T = (0,1)$ on $E_0$: indeed $1^2 = 0^3 + 1$. It has order
three in the group law, and — this is the crucial part — it is defined over the
rationals, so it survives reduction modulo every good prime.

**Theorem (rational-torsion degeneracy).** *For every prime $p > 3$,
$\#E_0(\mathbb{F}_p)$ is divisible by $6$; consequently
$a_p \equiv p+1 \pmod 6$.*

You can see the divisibility by $3$ with your eyes, no group law required.
Translation by $T$ acts on the affine points with $x \ne 0$ by the explicit map

$$(x,y) \ \longmapsto \ \left( \frac{2(1-y)}{x^{2}}, \ \frac{y-3}{y+1} \right),$$

and this map is of order three and has **no fixed point at all**. So the point
set breaks into orbits of size exactly three. Watch it happen:

↑ *Scroll back to panel 2 of the laboratory above — "the torsion orbit picture" — and
change the prime: however you choose it, the colours always come in threes.*

<details>
<summary><b>Click for the full proof that the map is free of order three</b></summary>

*Well-defined.* If $y^2 = x^3+1$ and $x \ne 0$, then $y \ne \pm 1$: if $y = \pm 1$
then $x^3 = y^2-1 = 0$. So neither denominator vanishes.

*Lands back on the curve.* Writing $X = 2(1-y)/x^2$ and $Y = (y-3)/(y+1)$ and
clearing denominators, the expression $Y^2 - X^3 - 1$ becomes a polynomial
multiple of the curve relation $y^2 - x^3 - 1$, hence vanishes.

*Order three.* The second coordinate iterates by the Möbius map
$y \mapsto (y-3)/(y+1)$, whose cube is the identity; the first coordinate
returns to $x$ after three steps, using the curve relation once at each stage.
Explicitly the second iterate is $\bigl(2x/(y-1), -(y+3)/(y-1)\bigr)$.

*Fixed-point free.* A fixed point would need $2(1-y) = x^3 = y^2-1$, i.e.
$(y+3)(y-1) = 0$, forcing $y = -3$; and it would need $y^2 = -3$. Together
$9 = -3$, i.e. $12 = 0$ — impossible for $p > 3$.

Extend the map by the three-cycle $\infty \mapsto (0,1) \mapsto (0,-1) \mapsto \infty$
and you have a fixed-point-free self-map of order three of the *entire* point
set. A finite set carrying such a map has cardinality divisible by three, since
its orbits all have size three. Divisibility by $2$ is easier: $(-1,0)$ is a
rational point of order two.
</details>

The algorithm below turns the picture into a *certificate*: for a given prime it
verifies freeness and order three point by point and prints the orbit
decomposition, so the divisibility is proved rather than observed.

{{algorithm:0}}

---

## 3 · Why a perfect pattern is a worthless pattern

Here is the twist, and it is the heart of the matter.

Suppose you hoped to predict "$3$ divides $\#E_0(\mathbb{F}_p)$" from the residue
class of $p$. Measure the predictive power with **mutual information** — the
standard measure of how much learning one variable tells you about another.

**Theorem (zero-bit law).** *A Boolean event that is constant on a sample has
empirical mutual information exactly $0$ with every classifying statistic
whatsoever. Hence, for every $\ell$ dividing $6$, the channel
"$\ell$ divides $\#E_0(\mathbb{F}_p)$" carries exactly zero information about
anything, on every sample.*

Not "approximately zero". Not "below the noise floor". **Zero**, by an identity.
Information lives in variation, and an event that always fires has none.

Turn the meter on it yourself. Set $\ell = 3$ and try every modulus you like;
then set $\ell = 5$, $\ell = 7$, $\ell = 9$:

↑ *Use panel 3 of the laboratory above — "how many bits does a divisibility channel
carry?" — and try to make the meter move at $\ell = 3$. You cannot.*

A null result is only as trustworthy as the instrument producing it, so two
sanity checks are built into the theory:

* the same functional attains $\log 2$ — one full bit — on a perfectly
  correlated two-point sample;
* the level-$5$ channel on this very curve is *not* constant:
  $\#E_0(\mathbb{F}_{29}) = 30$ is divisible by $5$, while
  $\#E_0(\mathbb{F}_5) = 6$ is not; on the two-prime sample $\{29, 5\}$ it
  carries exactly $\log 2$.

So the null at $\ell = 3$ is a property of the **event**, not of the
measurement. And exactly how far does it extend?

**Theorem (silent-set classification).** *For a positive integer $\ell$, the
divisibility $\ell \mid \#E_0(\mathbb{F}_p)$ holds for every prime $p > 3$ **if
and only if** $\ell$ divides $6$. The silent set is exactly $\{1,2,3,6\}$.*

One direction is the torsion theorem; the other needs one prime, since
$\#E_0(\mathbb{F}_5) = 6$. The consequence is an all-or-nothing dichotomy: a
level either carries zero bits everywhere, or already carries a **full bit** on
a suitable two-prime sample. There is no "weakly informative" middle.

{{algorithm:1}}

{{visualization:1}}

<details>
<summary><b>Deeper: silence is about torsion, not about complex multiplication</b></summary>

The counting principle behind the theorem is completely general: if a finite set
carries a self-map $f$ with $f^{[n]} = \mathrm{id}$ and no point of period
smaller than $n$, then $n$ divides the size of the set — the counting shadow of
a free $\mathbb{Z}/n$-action, valid for every $n$, prime or not.

Consequently **any** curve with a rational point of order $n$ has a dead channel
at level $n$, whatever its endomorphism ring. Complex multiplication plays no
role in the silence at all. Run the silent-set algorithm above on a generic
curve such as $y^2 = x^3 + x + 1$ and you will find the silent set collapses to
$\{1\}$: no rational torsion, no silence.
</details>

---

## 4 · Where the signal actually hides — and why it is worthless too

So where *does* a residue class genuinely determine divisibility? The answer is
sharp, and slightly deflating.

**Theorem (inert collapse).** *If $p \equiv 2 \pmod 3$, then
$\#E_0(\mathbb{F}_p) = p+1$ exactly, so $a_p = 0$. If $p \equiv 3 \pmod 4$, then
$\#E_{1728}(\mathbb{F}_p) = p+1$ exactly.*

**Theorem (inert dial).** *For $p \equiv 2 \pmod 3$ and every $\ell \ge 1$:*
$$\ell \mid \#E_0(\mathbb{F}_p) \iff p \equiv -1 \pmod{\ell}.$$
*In particular $9 \mid \#E_0(\mathbb{F}_p) \iff p \equiv 8 \pmod 9$ and
$27 \mid \#E_0(\mathbb{F}_p) \iff p \equiv 26 \pmod{27}$.*

<details>
<summary><b>Proof of the collapse — two lines each, and rather pretty</b></summary>

**Eisenstein case.** When $p \equiv 2 \pmod 3$ the cubing map $u \mapsto u^3$ is
a *bijection* of $\mathbb{F}_p$: its inverse is $u \mapsto u^{e}$ with
$e = (2p-1)/3$, because $3e = 2(p-1)+1$ and Fermat gives $u^{3e} = u$. So for
each $y$ the equation $x^3 = y^2-1$ has exactly one solution: the affine points
are in bijection with the $y$-axis, giving $p$ of them, plus infinity.

**Gaussian case.** When $p \equiv 3 \pmod 4$, $-1$ is a non-residue, so of $c$
and $-c$ exactly one is a square: the two fibres contribute exactly two points
in total. Since $x^3+x$ is an odd function, re-indexing $x \mapsto -x$ pairs the
fibres and the affine count is again exactly $p$.
</details>

Now read the consequence carefully. On the inert half, $\#E_0(\mathbb{F}_p)$ is
$p+1$ **on the nose**, for every curve of the family $y^2 = x^3 + b$. So:

> On the inert half, running the elliptic curve method on the most symmetric
> curve in the world is *literally* running Williams' $p+1$ method from 1982 —
> and changing the curve does not move the target by even one unit.

That is not a metaphor; you can watch it in an actual factoring run:

{{demo:1}}

And here is the exact trace dichotomy behind it all, visible in one picture: the
inert primes form a perfectly flat line at $a_p = 0$, with no scatter and no
error term, while the split primes fill the Hasse band.

{{visualization:0}}

**Theorem (atomic trace law).** *For $p > 3$, $a_p(E_0) = 0$ if and only if
$p \equiv 2 \pmod 3$; for odd $p$, $a_p(E_{1728}) = 0$ if and only if
$p \equiv 3 \pmod 4$. Hence on any finite sample the number of primes with
vanishing trace equals exactly the number of inert primes.*

<details>
<summary><b>Why the converse directions hold</b></summary>

For $E_0$: we know $a_p \equiv p+1 \pmod 3$ always (rational $3$-torsion), so
$a_p = 0$ forces $3 \mid p+1$, i.e. $p \equiv 2 \pmod 3$.

For $E_{1728}$: if $p \equiv 1 \pmod 4$ then $-1$ is a square, so
$x^3+x = x(x-i)(x+i)$ splits completely, the curve has full rational
$2$-torsion, and $4 \mid \#E$. But $a_p = 0$ would give
$\#E = p+1 \equiv 2 \pmod 4$. Contradiction.
</details>

What about the split half, where the arithmetic is genuinely rich? There the
visibility fails, and two small numbers prove it: $13$ and $31$ are both split
and both congruent to $4$ modulo $9$, yet $\#E_0(\mathbb{F}_{13}) = 12$ is not
divisible by $9$ while $\#E_0(\mathbb{F}_{31}) = 36$ is; their traces $2$ and
$-4$ are incongruent modulo $9$. So the dial is a phenomenon of the **ramified**
prime $3$ on the inert half, not a global congruence.

{{algorithm:2}}

---

## 5 · The law that travels: union dilution

One more result, and it is the one with the widest reach beyond elliptic curves.

Real experiments rarely test a single condition; they test a **union**: the run
succeeds if the order is divisible by $\ell$ *or* some other, class-independent
thing happens. Suppose a channel has conditional probabilities $a_k$ across
classes of weight $w_k$, measured by the squared correlation ratio

$$\eta^2(a) = \frac{\sum_k w_k (a_k - \mu)^2}{\mu(1-\mu)}, \qquad \mu = \sum_k w_k a_k,$$

and now mix in a class-blind event of probability $b$, disjoint from $A$.

**Theorem (union dilution).** *The numerator is unchanged, but the normaliser
$\mu(1-\mu)$ grows as long as the base rate stays below $1/2$. Hence
$\eta^2(a+b) \le \eta^2(a)$, strictly when $b > 0$ on a non-degenerate channel,
with the exact factor*
$$\frac{\eta^2(a+b)}{\eta^2(a)} = \frac{\mu_A(1-\mu_A)}{\mu_U(1-\mu_U)}, \qquad \mu_U = \mu_A + b.$$
*The dilution deepens monotonically in $b$, and every factor in $(0,1]$ is
attained by an honest two-class channel — so no universal constant below $1$
improves the bound.*

Drag the sliders and watch a real effect get buried:

↑ *Panel 4 of the laboratory above lets you do exactly this: raise the class-blind mass
and watch the measured effect collapse along the predicted curve.*

{{visualization:2}}

The moral is uncomfortable and precise: **a union channel is never stronger than
the conditional channel inside it**, and if you compare a diluted measurement
against a threshold calibrated for the pure channel, you will call real signals
noise. The correction is exact and costs nothing:

$$\eta^2_A = \eta^2_U \cdot \frac{\mu_U(1-\mu_U)}{\mu_A(1-\mu_A)} .$$

{{algorithm:3}}

---

## 6 · The verdict

Put the pieces together and the picture closes.

| Where you look | What you find | Value to a factorer |
|---|---|---|
| Inert half | order $= p+1$ exactly | the $p+1$ method of 1982 — nothing new |
| Levels $1,2,3,6$ | unconditional divisibility | exactly zero bits |
| Split half, modulus 9 | trace not a function of $p$ | no dial exists |
| Union of channels | provably diluted | measurement weaker, not stronger |

So: no shortcut. Complex multiplication hands the factoring practitioner no
usable bias, and correspondingly costs factoring-based cryptography nothing.

That is a null result, and null results have a reputation they do not deserve.
This one arrives with a classification (which levels can *ever* speak: exactly
the divisors of the rational torsion), an identity (trace vanishing $\iff$
inertness, with no error term), and a sharp quantitative law about how unions
hide effects — the last of which applies to every experimental science that
measures a union and normalises by a base rate.

Run the full numerical companion to see every claim on this page verified
against explicit computations:

{{demo:0}}

<details>
<summary><b>Where to read more</b></summary>

* [Lenstra elliptic-curve factorization](https://en.wikipedia.org/wiki/Lenstra_elliptic-curve_factorization) — the algorithm whose luck we were trying to bias.
* [Williams' p+1 algorithm](https://en.wikipedia.org/wiki/Williams%27s_p_%2B_1_algorithm) — what the inert half collapses to.
* [Supersingular elliptic curves](https://en.wikipedia.org/wiki/Supersingular_elliptic_curve) — the trace-zero condition, here a pure residue condition.
* [Mutual information](https://en.wikipedia.org/wiki/Mutual_information) and the [correlation ratio](https://en.wikipedia.org/wiki/Correlation_ratio) — the two statistics used throughout.
</details>

Sometimes the most useful thing a beautiful symmetry can teach you is precisely
how it manages to say nothing at all.
"""

package = {
    "title": "The Curve That Knows Nothing: Torsion Silence, the Inert Dial, "
             "and the Union-Dilution Law for CM Elliptic Curves",
    "domain": "Probability",
    "description": (
        "For the complex-multiplication curves y^2 = x^3 + 1 and y^2 = x^3 + x we "
        "prove that residue classes of a prime p carry exactly zero information about "
        "divisibility of the elliptic order at every level dividing the rational "
        "torsion, that the order collapses to exactly p + 1 on the inert half (where "
        "divisibility becomes a pure congruence and the elliptic method degenerates to "
        "the p+1 method), and that mixing a class-blind event into a conditional "
        "channel dilutes its measured effect by an exact, sharp factor."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-14",
    "key_results": [
        "Rational-torsion degeneracy: 6 divides the number of points of y^2 = x^3 + 1 "
        "over F_p for every prime p > 3, proved by exhibiting translation by the "
        "rational 3-torsion point (0,1) as an explicit fixed-point-free self-map of "
        "order three of the point set; consequently the trace of Frobenius satisfies "
        "a_p = p + 1 modulo 6.",
        "Zero-bit law and silent-set classification: a constant Boolean event has "
        "empirical mutual information exactly zero against every class statistic, and "
        "the divisibility of the elliptic order by a level is unconditional precisely "
        "when that level divides 6 — so the zero-bit locus of the curve is exactly "
        "{1, 2, 3, 6}, with an all-or-nothing dichotomy between zero bits and a full bit.",
        "Exact inert collapse and residue dial: for p congruent to 2 modulo 3 the order "
        "is exactly p + 1, hence for every level the divisibility is the pure congruence "
        "p congruent to -1 modulo that level; the same collapse holds for y^2 = x^3 + x "
        "on p congruent to 3 modulo 4, so on the inert half elliptic-curve factorisation "
        "on a CM curve is literally Williams' p+1 method.",
        "Atomic trace law: the trace of Frobenius vanishes exactly on the inert class for "
        "both CM curves, so in any finite sample the number of primes with vanishing "
        "trace equals the number of inert primes identically, with no error term; on the "
        "split half the divisibility is not a function of the residue class of p modulo 9, "
        "as witnessed by the primes 13 and 31.",
        "Union-dilution law with sharpness: mixing a disjoint class-blind event of "
        "probability b into a conditional channel leaves the weighted conditional variance "
        "unchanged and multiplies the squared correlation ratio by exactly "
        "mu_A(1-mu_A)/mu_U(1-mu_U), monotonically in b, and every factor in the "
        "half-open interval (0,1] is attained — so a union channel is never stronger "
        "than the conditional channel it contains and no smaller universal constant holds.",
    ],
    "keywords": [
        "complex multiplication",
        "elliptic curve factorisation",
        "trace of Frobenius",
        "rational torsion",
        "mutual information",
        "correlation ratio",
        "supersingular reduction",
        "Eisenstein integers",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Numerical Companion: Torsion Degeneracy, Inert Collapse, "
                    "Channel Information and Union Dilution",
            "description": (
                "A single self-contained script that verifies every quantitative claim of "
                "the work. It counts points on y^2 = x^3 + 1 over F_p by character "
                "summation; checks that 6 divides the order for all 93 good primes below "
                "500; determines empirically that the levels dividing the order for all "
                "sampled primes are exactly 1, 2, 3 and 6; verifies the exact collapse "
                "#E = p + 1 on the inert halves of both CM curves and the absence of "
                "vanishing traces on the split halves; confirms the residue dial "
                "'level divides the order iff p = -1 mod level' at levels 5, 9 and 27 over "
                "all inert primes below 600, together with its explicit failure on the "
                "split half at 13 and 31; computes the empirical mutual information "
                "between p mod m and the divisibility event, obtaining a hard zero at "
                "every level dividing 6 and positive values elsewhere; and tabulates the "
                "union-dilution factor against the exact prediction "
                "mu_A(1-mu_A)/mu_U(1-mu_U)."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Order Rigidity and the Torsion Trap: an Actual Factoring Run on the "
                    "j = 0 Family",
            "description": (
                "An operational demonstration that re-randomising the curve — the source "
                "of the elliptic curve method's power — buys nothing on the inert half. "
                "The script (i) computes #E_b(F_p) for several random b in the family "
                "y^2 = x^3 + b, showing zero spread for an inert prime and genuine spread "
                "for a split one; (ii) exhibits the torsion trap, in which the rational "
                "6-torsion point (2,3) of y^2 = x^3 + 1 becomes the identity modulo every "
                "prime simultaneously so that the gcd trap never springs; and (iii) runs a "
                "real stage-one elliptic curve method modulo a semiprime N = p q with the "
                "affine group law over Z/NZ, recovering the hidden inert prime at exactly "
                "the stage-one bound dictated by the largest prime factor of p + 1, "
                "identically for every curve of the family, and failing one prime below it."
            ),
            "code": read(ASSETS / "demo_ecm_collapse.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Orbit Certificate for the Rational-Torsion Divisibility Law",
            "description": (
                "Rather than observing that 3 divides the order for many primes, this "
                "algorithm certifies it. It enumerates the affine points of y^2 = x^3 + 1 "
                "over F_p, realises translation by the rational 3-torsion point (0,1) as "
                "the explicit rational map (x,y) -> (2(1-y)/x^2, (y-3)/(y+1)) on the locus "
                "x != 0, extends it by the three-cycle through the point at infinity and "
                "the two points (0, +-1), and then walks the orbits, checking at every "
                "point that the map has no fixed point and returns after exactly three "
                "steps. The resulting partition into orbits of size three is a proof, for "
                "that prime, that 3 divides the point count. Complexity: O(p log p) to "
                "collect the points via a table of squares, then O(#E) modular inversions "
                "for the orbit walk, each O(log p) by Fermat's little theorem."
            ),
            "pseudocode": (
                "INPUT: prime p > 3\n"
                "OUTPUT: orbit decomposition certifying 3 | #E_0(F_p)\n"
                "\n"
                "1. squares <- table mapping c to the list of y with y^2 = c (mod p)\n"
                "2. pts <- [ (x, y) : x in F_p, y in squares[x^3 + 1] ]\n"
                "3. total <- |pts| + 1                       // include the point at infinity\n"
                "4. seen <- { (0, 1), (0, -1) }              // orbit of infinity\n"
                "5. orbits <- [ [infinity, (0,1), (0,-1)] ]\n"
                "6. for each P = (x, y) in pts with x != 0 and P not in seen:\n"
                "7.     orbit <- [], Q <- P\n"
                "8.     repeat three times:\n"
                "9.         append Q to orbit; insert Q into seen\n"
                "10.        Q' <- ( 2(1-Q.y) * inverse(Q.x^2), (Q.y-3) * inverse(Q.y+1) )\n"
                "11.        assert Q' != Q                    // freeness\n"
                "12.        Q <- Q'\n"
                "13.    assert Q = P                          // order exactly three\n"
                "14.    append orbit to orbits\n"
                "15. assert every orbit has size 3 and 3 * |orbits| = total\n"
                "16. return orbits"
            ),
            "code": read(ASSETS / "algo_torsion_certificate.py"),
        },
        {
            "name": "Silent-Set Classification of a Divisibility Channel",
            "description": (
                "A level is silent for a curve when the divisibility of the order by that "
                "level holds for every good prime; a silent channel carries exactly zero "
                "information about any statistic of the prime, because its event never "
                "varies. The algorithm computes the running greatest common divisor of the "
                "orders over a sample of good primes; the silent set is exactly the divisor "
                "set of the stable gcd. For y^2 = x^3 + 1 the gcd is 6 and stabilises after "
                "two primes, matching the theorem that silence is equivalent to divisibility "
                "of the level by 6; for y^2 = x^3 + x the answer is 4; for a curve without "
                "rational torsion the silent set collapses to the trivial {1}. Complexity: "
                "the point counts dominate at O(sum of p log p) over the sample, with a "
                "single O(log) gcd update per prime; convergence is immediate in practice "
                "because the gcd is the order of the rational torsion subgroup."
            ),
            "pseudocode": (
                "INPUT: curve coefficients (a, b), bad primes, sampling bound B\n"
                "OUTPUT: gcd of the orders, the silent set, and the stabilisation prime\n"
                "\n"
                "1. g <- 0, stabilised <- none\n"
                "2. for each prime p <= B not dividing the conductor:\n"
                "3.     card <- 1 + sum over x in F_p of (1 + legendre(x^3 + a x + b, p))\n"
                "4.     g_new <- gcd(g, card)   (or card, if g = 0)\n"
                "5.     if g != 0 and g_new = g and stabilised = none: stabilised <- p\n"
                "6.     g <- g_new\n"
                "7. return g, divisors(g), stabilised\n"
                "\n"
                "GUARANTEE: every level dividing g is silent on the sample; by the\n"
                "classification theorem, for the j = 0 curve the silent set is exactly\n"
                "{1, 2, 3, 6} and any other level already carries a full bit of\n"
                "information on a suitable two-prime sample."
            ),
            "code": read(ASSETS / "algo_silent_set.py"),
        },
        {
            "name": "Complex-Multiplication Order Oracle with Inert Short-Circuit",
            "description": (
                "Computes the number of points of the CM curves y^2 = x^3 + b (any b) and "
                "y^2 = x^3 + x over F_p, exploiting the exact inert collapse. When p = 2 "
                "mod 3 the cubing map is a bijection of F_p, so the first curve has exactly "
                "p + 1 points for every b and the answer is returned in O(1); when p = 3 "
                "mod 4 the sign pairing over the odd cubic gives the same conclusion for the "
                "second curve. Otherwise the order is obtained by character summation in "
                "O(p log p). The same short-circuit answers divisibility questions without "
                "any counting at all: on the inert half, a level divides the order precisely "
                "when p is congruent to minus one modulo that level — the residue dial. This "
                "is the computational face of the statement that on the inert half "
                "elliptic-curve factorisation on a CM curve is the p+1 method."
            ),
            "pseudocode": (
                "INPUT: prime p, curve selector, optional level l\n"
                "OUTPUT: #E(F_p), or the decision 'l divides #E(F_p)'\n"
                "\n"
                "1. if curve = j0 and p mod 3 = 2:      return p + 1        // O(1)\n"
                "2. if curve = j1728 and p mod 4 = 3:   return p + 1        // O(1)\n"
                "3. total <- 1\n"
                "4. for x in F_p:\n"
                "5.     total <- total + 1 + legendre(cubic(x), p)\n"
                "6. return total\n"
                "\n"
                "DIVISIBILITY QUERY:\n"
                "7. if the prime is inert for the chosen curve:\n"
                "8.     return (p mod l = l - 1)                            // residue dial\n"
                "9. else return (order(p) mod l = 0)"
            ),
            "code": read(ASSETS / "algo_order_oracle.py"),
        },
        {
            "name": "Union-Dilution Correction and the Sharpness Construction",
            "description": (
                "Inverts the systematic distortion introduced by measuring a union event. "
                "If a class-blind event of probability b, disjoint from the conditional "
                "event A, is folded into the measurement, the weighted conditional variance "
                "is untouched while the normaliser mu(1-mu) grows, so the squared "
                "correlation ratio is multiplied by exactly mu_A(1-mu_A)/mu_U(1-mu_U) with "
                "mu_U = mu_A + b. The routine recovers the conditional effect from the "
                "measured union effect and the two base rates, in O(1); it also realises any "
                "prescribed dilution factor c in (0,1) by an explicit two-class channel — "
                "take r = sqrt(1-c), mu = (1-r)/2, conditional probabilities "
                "(mu + mu/2, mu - mu/2) and admixture b = 1/2 - mu, whose union base rate is "
                "exactly one half — proving that the achievable factor set is precisely the "
                "half-open interval (0,1] and that no smaller universal constant exists."
            ),
            "pseudocode": (
                "CORRECTION\n"
                "INPUT: measured union effect eta2_U, base rates mu_A and mu_U\n"
                "1. factor <- (mu_A (1 - mu_A)) / (mu_U (1 - mu_U))\n"
                "2. return eta2_A <- eta2_U / factor\n"
                "\n"
                "SHARPNESS CONSTRUCTION\n"
                "INPUT: target factor c in (0, 1)\n"
                "3. r <- sqrt(1 - c);  mu <- (1 - r) / 2\n"
                "4. a <- ( mu + mu/2, mu - mu/2 )   with class weights (1/2, 1/2)\n"
                "5. b <- 1/2 - mu                    // union base rate is exactly 1/2\n"
                "6. assert eta2(a + b) / eta2(a) = 4 mu (1 - mu) = 1 - r^2 = c\n"
                "7. return (a, b)"
            ),
            "code": read(ASSETS / "algo_dilution.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Exact Trace Dichotomy of the Two CM Curves",
            "description": (
                "Scatter plot of the normalised trace of Frobenius a_p / (2 sqrt p), which "
                "by Hasse's bound lives in [-1, 1], against p for all good primes below "
                "1500, for y^2 = x^3 + 1 (left) and y^2 = x^3 + x (right). Inert primes are "
                "highlighted: they form a perfectly flat line at height zero, with no "
                "scatter and no error term, while the split primes fill the Hasse band. The "
                "picture is the visual form of the atomic trace law — vanishing of the trace "
                "is exactly a residue condition on p."
            ),
            "code": read(ASSETS / "viz_trace_dichotomy.py"),
        },
        {
            "name": "Information Heatmap: Which Divisibility Channels Can Speak?",
            "description": (
                "Heatmap of the empirical mutual information, in nats, between the class "
                "statistic p mod m and the event 'level divides the order' for the j = 0 "
                "curve, over all good primes below 3000, for levels 2 to 14 and a range of "
                "moduli. Every row whose level divides 6 is exactly zero across all moduli — "
                "the rational-torsion degeneracy — while every other row lights up. The "
                "companion bar panel shows the best information available at each level, "
                "vanishing precisely on the divisors of 6."
            ),
            "code": read(ASSETS / "viz_channel_information.py"),
        },
        {
            "name": "The Union-Dilution Law and Its Mechanism",
            "description": (
                "Left panel: the dilution factor of the squared correlation ratio as a "
                "function of the class-blind mass b, for three conditional channels, with "
                "the exact prediction mu_A(1-mu_A)/mu_U(1-mu_U) overlaid as a dashed curve "
                "— the two coincide identically. Right panel: the normaliser mu(1-mu), whose "
                "growth on the interval from zero to one half is the entire mechanism, since "
                "the numerator of the statistic is invariant under the admixture."
            ),
            "code": read(ASSETS / "viz_union_dilution.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The CM Curve Laboratory: Orders, Orbits, Bits and Dilution",
            "description": (
                "A four-panel exploratory laboratory, computed live in the browser with no "
                "dependencies. Panel 1 slides through the primes, counting the points of "
                "y^2 = x^3 + 1 over F_p exactly, placing the order inside the Hasse interval, "
                "and tabulating for each level both the divisibility of the order and the "
                "congruence p = -1 mod level, so the reader discovers the inert dial and the "
                "always-ticked levels 2, 3 and 6 personally. Panel 2 draws the point set of "
                "the curve over a small field and colours it by the orbits of translation by "
                "the rational 3-torsion point, making visible why every orbit has size three "
                "and hence why 3 always divides the order. Panel 3 is a live information "
                "meter: choose a level, a class modulus and a sample of primes, and watch the "
                "empirical mutual information read a hard zero at every level dividing 6 and "
                "light up elsewhere, against a scale marked at log 2 — one full bit. Panel 4 "
                "lets the reader bury a real conditional effect under a class-blind "
                "admixture, comparing the measured dilution against the exact predicted "
                "factor and plotting the whole dilution curve."
            ),
            "html": read(ASSETS / "widget.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": read(ASSETS / "future_directions.md"),
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Re-randomisation is useless on the inert half: ECM on the j = 0 family
======================================================================

Every curve of the family

        E_b : y^2 = x^3 + b        (b nonzero)

has j-invariant 0 and complex multiplication by the Eisenstein integers.  The
elliptic curve method gains its power from re-randomising the curve, because
that re-randomises the order #E(F_p) inside the Hasse interval.  On the inert
half of the CM field of this family -- the primes p = 2 mod 3 -- that power
evaporates completely:

        p = 2 (mod 3)   ==>   #E_b(F_p) = p + 1   for EVERY b,

because cubing is a bijection of F_p, so the equation x^3 = y^2 - b has exactly
one solution for each y.  Re-randomising b cannot move the order at all, and the
factorisation attempt is the p+1 method of Williams.  On the split half
(p = 1 mod 3) the trace is generically nonzero and the order does move with b.

The script demonstrates both facts and then runs a genuine stage-one elliptic
curve method modulo a semiprime N = p q, using the affine group law over Z/NZ
and detecting p through a failed modular inversion (the "gcd trap").  It also
exhibits the torsion trap: the rational 6-torsion of y^2 = x^3 + 1 dies modulo
every prime simultaneously, so the point (2, 3) on that particular curve can
never reveal a factor -- an operational face of the rational-torsion degeneracy.

Only the Python standard library is used.
"""

from __future__ import annotations

import random
from math import gcd
from typing import List, Optional, Tuple

Point = Optional[Tuple[int, int]]  # None is the point at infinity


# ---------------------------------------------------------------------------
# Basic number theory
# ---------------------------------------------------------------------------


def primes_up_to(bound: int) -> List[int]:
    """All primes <= bound by a simple sieve."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def largest_prime_factor(m: int) -> int:
    """Largest prime factor of m >= 2."""
    largest = 1
    d = 2
    while d * d <= m:
        while m % d == 0:
            largest = d
            m //= d
        d += 1
    return max(largest, m)


def curve_card(b: int, p: int) -> int:
    """#E_b(F_p) for E_b : y^2 = x^3 + b, by character summation, O(p log p)."""
    total = 1
    b %= p
    for x in range(p):
        rhs = (x * x % p * x + b) % p
        if rhs == 0:
            total += 1
        else:
            total += 2 if pow(rhs, (p - 1) // 2, p) == 1 else 0
    return total


# ---------------------------------------------------------------------------
# Affine group law modulo N, with gcd trapping
# ---------------------------------------------------------------------------


class FactorFound(Exception):
    """Raised when a modular inversion fails and exposes a divisor of N."""

    def __init__(self, factor: int) -> None:
        super().__init__(f"factor found: {factor}")
        self.factor = factor


def inverse_mod(a: int, n: int) -> int:
    """Modular inverse mod n; raises FactorFound when gcd(a, n) > 1."""
    g = gcd(a % n, n)
    if g != 1:
        raise FactorFound(g)
    return pow(a % n, -1, n)


def add_points(p1: Point, p2: Point, n: int) -> Point:
    """Group law on y^2 = x^3 + b over Z/nZ (the coefficient b is not needed)."""
    if p1 is None:
        return p2
    if p2 is None:
        return p1
    x1, y1 = p1
    x2, y2 = p2
    if (x1 - x2) % n == 0:
        if (y1 + y2) % n == 0:
            return None
        lam = (3 * x1 * x1) % n * inverse_mod(2 * y1, n) % n
    else:
        lam = (y2 - y1) % n * inverse_mod(x2 - x1, n) % n
    x3 = (lam * lam - x1 - x2) % n
    y3 = (lam * (x1 - x3) - y1) % n
    return (x3, y3)


def multiply_point(point: Point, k: int, n: int) -> Point:
    """Scalar multiple k * point by double-and-add over Z/nZ."""
    result: Point = None
    addend = point
    while k > 0:
        if k & 1:
            result = add_points(result, addend, n)
        addend = add_points(addend, addend, n)
        k >>= 1
    return result


def ecm_stage_one(n: int, bound: int, base: Point) -> Optional[int]:
    """
    Stage one of the elliptic curve method modulo n on the curve of the j = 0
    family through `base`.  Multiplies the base point by every prime power up to
    `bound`; returns a nontrivial divisor of n as soon as an inversion fails.
    """
    point = base
    for q in primes_up_to(bound):
        e = 1
        while q ** (e + 1) <= bound:
            e += 1
        try:
            point = multiply_point(point, q ** e, n)
        except FactorFound as exc:
            if 1 < exc.factor < n:
                return exc.factor
            return None
        if point is None:
            return None
    return None


def random_curve_point(n: int, rng: random.Random) -> Tuple[int, Point]:
    """Random b and a point on y^2 = x^3 + b over Z/nZ, by choosing the point."""
    x0 = rng.randrange(2, n - 1)
    y0 = rng.randrange(2, n - 1)
    b = (y0 * y0 - x0 * x0 % n * x0) % n
    return b, (x0, y0)


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


def show_order_rigidity(p: int, label: str, rng: random.Random) -> None:
    """Print #E_b(F_p) for several random b: constant iff p is inert."""
    bs = [rng.randrange(1, p) for _ in range(6)]
    orders = [curve_card(b, p) for b in bs]
    print(f"  p = {p} [{label}]  (p + 1 = {p + 1})")
    print("    random b      :", ", ".join(f"{b:6d}" for b in bs))
    print("    #E_b(F_p)     :", ", ".join(f"{o:6d}" for o in orders))
    print("    traces a_p    :", ", ".join(f"{p + 1 - o:6d}" for o in orders))
    spread = max(orders) - min(orders)
    print(f"    spread of the order over the family: {spread}"
          f"{'   <-- rigid: re-randomisation is useless' if spread == 0 else ''}")


def main() -> None:
    rng = random.Random(20260814)
    line = "=" * 74

    print(line)
    print("1. Order rigidity on the inert half of the j = 0 family")
    print(line)
    show_order_rigidity(100049, "inert, p = 2 mod 3", rng)
    print()
    show_order_rigidity(100003, "split, p = 1 mod 3", rng)

    print()
    print(line)
    print("2. The torsion trap on y^2 = x^3 + 1")
    print(line)
    p, q = 100049, 1000003
    n = p * q
    print(f"  N = {p} * {q} = {n}")
    print("  the point (2, 3) generates the rational 6-torsion of y^2 = x^3 + 1;")
    print("  6 * (2,3) is the identity modulo EVERY prime at once, so the gcd trap")
    print("  never springs -- rational torsion is invisible to factorisation:")
    print("    6 * (2,3) mod N =", multiply_point((2, 3), 6, n))
    print("    stage one with B1 = 200 on that point ->",
          ecm_stage_one(n, 200, (2, 3)))

    print()
    print(line)
    print("3. Stage-one ECM modulo N with random curves of the j = 0 family")
    print(line)
    bound = largest_prime_factor(p + 1)
    print(f"  hidden prime p = {p} is inert, so #E_b(F_p) = p + 1 = {p + 1}")
    print(f"  = 2 * 3 * 5^2 * 23 * 29, whose largest prime factor is {bound};")
    print(f"  every curve of the family therefore yields p at stage-one bound {bound}.")
    for trial in range(1, 6):
        b, base = random_curve_point(n, rng)
        found = ecm_stage_one(n, bound, base)
        status = "found p" if found == p else f"returned {found}"
        print(f"    trial {trial}: random curve b = {b % 1000000:6d}...  -> {status}")
    print()
    print(f"  with a bound one below the largest prime factor ({bound - 1}):")
    for trial in range(1, 4):
        b, base = random_curve_point(n, rng)
        found = ecm_stage_one(n, bound - 1, base)
        print(f"    trial {trial}: -> {found}")
    print()
    print("  Reading: the successful bound is dictated by the factorisation of")
    print("  p + 1 alone, identically for every curve in the family.  On the")
    print("  inert half, elliptic-curve factorisation on a CM curve IS the p+1")
    print("  method, and choosing a different CM curve changes nothing.")


if __name__ == "__main__":
    main()


"""
Visualisation: which divisibility channels can carry information?
=================================================================

For the curve E_0 : y^2 = x^3 + 1 and a sample of good primes we compute, for
each level l and each class modulus m, the empirical mutual information (in
nats) between the residue class p mod m and the event  l | #E_0(F_p).

The resulting heatmap has an exactly-zero row at every level dividing 6 -- the
rational-torsion degeneracy: the event is unconditionally true, so it carries no
information about anything.  Every other level lights up.  A companion panel
shows the smallest sample-level information available at each level, which is
zero precisely on the divisors of 6.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np


def primes_up_to(bound: int) -> List[int]:
    sieve = [True] * bound
    sieve[0:2] = [False, False]
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def card_j0(p: int) -> int:
    total = 1
    for x in range(p):
        rhs = (x * x % p * x + 1) % p
        if rhs == 0:
            total += 1
        else:
            total += 2 if pow(rhs, (p - 1) // 2, p) == 1 else 0
    return total


def empirical_mutual_information(
    classes: Sequence[int], events: Sequence[bool]
) -> float:
    """Plug-in mutual information in nats, with 0 log 0 = 0."""
    n = len(classes)
    total = 0.0
    for k in sorted(set(classes)):
        pk = sum(1 for c in classes if c == k) / n
        for b in (True, False):
            pb = sum(1 for e in events if e == b) / n
            pkb = sum(1 for c, e in zip(classes, events) if c == k and e == b) / n
            if pkb > 0 and pk > 0 and pb > 0:
                total += pkb * math.log(pkb / (pk * pb))
    return total


def main() -> None:
    primes = [p for p in primes_up_to(3000) if p > 3]
    cards = {p: card_j0(p) for p in primes}

    levels = list(range(2, 15))
    moduli = [3, 4, 5, 7, 8, 9, 11, 12, 27]

    grid = np.zeros((len(levels), len(moduli)))
    for i, level in enumerate(levels):
        events = [cards[p] % level == 0 for p in primes]
        for j, m in enumerate(moduli):
            classes = [p % m for p in primes]
            grid[i, j] = empirical_mutual_information(classes, events)

    fig, (ax, ax2) = plt.subplots(
        1, 2, figsize=(13, 6), gridspec_kw={"width_ratios": [3, 1.5]}
    )

    im = ax.imshow(grid, aspect="auto", cmap="magma", origin="lower")
    ax.set_xticks(range(len(moduli)), [str(m) for m in moduli])
    ax.set_yticks(range(len(levels)), [str(l) for l in levels])
    ax.set_xlabel("class modulus $m$  (statistic $p \\,\\mathrm{mod}\\, m$)")
    ax.set_ylabel("level $\\ell$  (event: $\\ell$ divides the order)")
    ax.set_title("Empirical mutual information (nats)")
    for i, level in enumerate(levels):
        if 6 % level == 0:
            ax.text(
                len(moduli) - 0.4,
                i,
                "silent",
                color="cyan",
                va="center",
                ha="left",
                fontsize=9,
            )
    fig.colorbar(im, ax=ax, label="nats")

    maxima = grid.max(axis=1)
    colours = ["crimson" if 6 % l == 0 else "steelblue" for l in levels]
    ax2.barh(range(len(levels)), maxima, color=colours)
    ax2.set_yticks(range(len(levels)), [str(l) for l in levels])
    ax2.set_xlabel("best information over all moduli (nats)")
    ax2.set_title("Silent levels are exactly the divisors of 6")

    fig.suptitle(
        "Rational-torsion degeneracy: the levels 2, 3 and 6 carry exactly zero bits",
        fontsize=12,
    )
    fig.tight_layout()
    fig.savefig("channel_information.png", dpi=160)
    print("wrote channel_information.png")


if __name__ == "__main__":
    main()


"""
Visualisation: the exact trace dichotomy of the two CM curves
=============================================================

For E_0 : y^2 = x^3 + 1 (CM by the Eisenstein integers) the trace of Frobenius
a_p = p + 1 - #E_0(F_p) vanishes exactly on the inert class p = 2 (mod 3); for
E_1728 : y^2 = x^3 + x (CM by the Gaussian integers) it vanishes exactly on
p = 3 (mod 4).  The plot shows the normalised trace a_p / (2 sqrt p), which by
Hasse's bound lives in [-1, 1], against p, with inert primes marked separately.
The inert primes form a perfectly flat line at height 0 -- no scatter, no error
term -- while the split primes fill the Hasse band.

Requires matplotlib.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt


def primes_up_to(bound: int) -> List[int]:
    sieve = [True] * bound
    sieve[0:2] = [False, False]
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def curve_card(a: int, b: int, p: int) -> int:
    """#E(F_p) for y^2 = x^3 + a x + b, including the point at infinity."""
    total = 1
    for x in range(p):
        rhs = (x * x % p * x + a * x + b) % p
        if rhs == 0:
            total += 1
        else:
            total += 2 if pow(rhs, (p - 1) // 2, p) == 1 else 0
    return total


def traces(a: int, b: int, primes: List[int]) -> List[int]:
    return [p + 1 - curve_card(a, b, p) for p in primes]


def main() -> None:
    primes = [p for p in primes_up_to(1500) if p > 3]
    t0 = traces(0, 1, primes)
    t1728 = traces(1, 0, primes)

    fig, axes = plt.subplots(1, 2, figsize=(13, 5), sharey=True)

    for ax, tr, modulus, inert_class, title in (
        (axes[0], t0, 3, 2, r"$E_0:\ y^2=x^3+1$,  CM by $\mathbb{Z}[\omega]$"),
        (axes[1], t1728, 4, 3, r"$E_{1728}:\ y^2=x^3+x$,  CM by $\mathbb{Z}[i]$"),
    ):
        inert_x = [p for p in primes if p % modulus == inert_class]
        inert_y = [
            t / (2 * math.sqrt(p))
            for p, t in zip(primes, tr)
            if p % modulus == inert_class
        ]
        split_x = [p for p in primes if p % modulus != inert_class]
        split_y = [
            t / (2 * math.sqrt(p))
            for p, t in zip(primes, tr)
            if p % modulus != inert_class
        ]
        ax.axhline(0.0, color="0.85", lw=1)
        ax.scatter(split_x, split_y, s=9, alpha=0.65, label="split primes")
        ax.scatter(
            inert_x, inert_y, s=16, color="crimson", label=f"inert primes ($a_p=0$)"
        )
        ax.set_xlabel("$p$")
        ax.set_title(title)
        ax.set_ylim(-1.15, 1.15)
        ax.legend(loc="upper right", framealpha=0.95)

    axes[0].set_ylabel(r"normalised trace $a_p / 2\sqrt{p}$")
    fig.suptitle(
        "Trace of Frobenius vanishes exactly on the inert class "
        "(no error term, at every prime)",
        fontsize=12,
    )
    fig.tight_layout()
    fig.savefig("trace_dichotomy.png", dpi=160)
    print("wrote trace_dichotomy.png")


if __name__ == "__main__":
    main()


"""
Visualisation: the union-dilution law
=====================================

A binary channel with class weights w_k and conditional probabilities a_k has
normalised conditional variation (squared correlation ratio)

    eta^2(a) = sum_k w_k (a_k - mu)^2 / (mu (1 - mu)),   mu = sum_k w_k a_k.

Mixing in a class-blind event of probability b, disjoint from the conditional
event, replaces a_k by a_k + b.  The numerator is untouched, but the normaliser
mu(1-mu) grows below base rate 1/2, so the measured effect can only shrink, by
the exact factor mu_A(1-mu_A) / mu_U(1-mu_U).

Left panel: the dilution factor as a function of the class-blind mass b, for
several conditional channels.  Right panel: the normaliser mu(1-mu), whose
growth is the entire mechanism.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np


def eta_squared(weights: Sequence[float], probs: Sequence[float]) -> float:
    mu = sum(w * a for w, a in zip(weights, probs))
    var = sum(w * (a - mu) ** 2 for w, a in zip(weights, probs))
    return var / (mu * (1.0 - mu))


def dilution_curve(
    weights: Sequence[float], probs: Sequence[float], masses: np.ndarray
) -> np.ndarray:
    base = eta_squared(weights, probs)
    return np.array(
        [eta_squared(weights, [a + b for a in probs]) / base for b in masses]
    )


def main() -> None:
    weights = [0.5, 0.5]
    channels = [
        ([0.10, 0.02], "conditional profile (0.10, 0.02)"),
        ([0.20, 0.08], "conditional profile (0.20, 0.08)"),
        ([0.30, 0.24], "conditional profile (0.30, 0.24)"),
    ]

    fig, (ax, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for probs, label in channels:
        mu_a = sum(w * a for w, a in zip(weights, probs))
        masses = np.linspace(0.0, 0.5 - mu_a, 220)
        ax.plot(masses, dilution_curve(weights, probs, masses), lw=2, label=label)
        predicted = np.array(
            [
                (mu_a * (1 - mu_a)) / ((mu_a + b) * (1 - mu_a - b))
                for b in masses
            ]
        )
        ax.plot(masses, predicted, ls="--", lw=1, color="k", alpha=0.5)

    ax.set_xlabel("class-blind mass $b$")
    ax.set_ylabel(r"$\eta^2(a+b)\,/\,\eta^2(a)$")
    ax.set_title(
        "Dilution factor (dashed: exact formula "
        r"$\mu_A(1-\mu_A)/\mu_U(1-\mu_U)$)"
    )
    ax.set_ylim(0.0, 1.05)
    ax.legend()
    ax.grid(alpha=0.25)

    t = np.linspace(0.0, 1.0, 400)
    ax2.plot(t, t * (1 - t), lw=2)
    ax2.axvline(0.5, color="crimson", ls=":", label="base rate $1/2$")
    ax2.fill_between(t, 0, t * (1 - t), where=(t <= 0.5), alpha=0.15)
    ax2.set_xlabel(r"base rate $\mu$")
    ax2.set_ylabel(r"normaliser $\mu(1-\mu)$")
    ax2.set_title("The normaliser grows on $[0, 1/2]$ — the whole mechanism")
    ax2.legend()
    ax2.grid(alpha=0.25)

    fig.suptitle(
        "A union channel is never stronger than the conditional channel inside it",
        fontsize=12,
    )
    fig.tight_layout()
    fig.savefig("union_dilution.png", dpi=160)
    print("wrote union_dilution.png")


if __name__ == "__main__":
    main()
