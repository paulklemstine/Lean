"""
demo.py -- Numerical demonstration of the OR-Collapse Law.

The law
------
Let K/Q be an abelian number field whose complete-splitting event is pinned by a
Dirichlet character chi of order n and conductor f:

        p splits completely in K   <=>   chi(p) = 1          (p not dividing f).

For a semiprime N = p*q coprime to f, the observer sees only chi(N) = chi(p)chi(q),
and asks about the Boolean OR = [p splits] or [q splits].  Then

        P(OR | chi(N) = 1)    = 1/n
        P(OR | chi(N) != 1)   = 2/n
        P(OR)                 = (2n-1)/n^2
        I(N mod f ; OR)       = g(n)
                              = H((2n-1)/n^2) - (1/n)H(1/n) - ((n-1)/n)H(2/n) bits,

with H the binary entropy in bits.  Moreover

        0 < g(n) <= g(2) = 3/2 - (3/4)log2(3) = 0.3112781...
        0.08/n^2 <= g(n) <= 2/n^2,     g(n) <= 1/(ln2 (n-1)(2n-1))
        n^2 g(n) -> 1/ln2 - 1 = 0.4426950408889634...

Everything below is self-contained: only the standard library is used.

Sections
--------
    1.  The collapse function g(n) and its closed forms.
    2.  Brute-force verification of the group-theoretic fibre counts.
    3.  Exact-rational Monte-Carlo-free verification of the law in a cyclic group.
    4.  Genuine number theory: splitting of primes, real semiprimes, measured bits.
    5.  Bounds, the chi^2 bound, and the sharp asymptotic constant.
    6.  The Boolean face hierarchy OR / XOR / AND / split count.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# 1.  Entropy, the collapse function, closed forms
# --------------------------------------------------------------------------


def entropy_bits(probabilities: Iterable[float]) -> float:
    """Shannon entropy, in bits, of a probability vector (zeros allowed)."""
    total = 0.0
    for p in probabilities:
        if p > 0.0:
            total -= p * math.log2(p)
    return total


def binary_entropy(x: float) -> float:
    """H(x) = -x log2 x - (1-x) log2 (1-x), with H(0) = H(1) = 0."""
    return entropy_bits((x, 1.0 - x))


def g_or(n: float) -> float:
    """The OR-collapse function g(n), in bits, for real n >= 2."""
    return (
        binary_entropy((2.0 * n - 1.0) / n ** 2)
        - (1.0 / n) * binary_entropy(1.0 / n)
        - ((n - 1.0) / n) * binary_entropy(2.0 / n)
    )


def g_or_closed_form(n: int) -> float:
    """Closed forms of g(n) for n in {2,3,4,5,8}, evaluated numerically."""
    lg = math.log2
    table = {
        2: 3 / 2 - 3 / 4 * lg(3),
        3: lg(3) - 5 / 9 * lg(5) - 2 / 9,
        4: 11 / 4 - 15 / 16 * lg(3) - 7 / 16 * lg(7),
        5: lg(5) - 6 / 25 * lg(3) - 48 / 25,
        8: 31 / 8 + 27 / 64 * lg(3) - 15 / 64 * lg(5) - 91 / 64 * lg(7),
    }
    return table[n]


def section_one() -> None:
    print("=" * 78)
    print("1.  THE COLLAPSE FUNCTION g(n)")
    print("=" * 78)
    print(f"{'n':>3} {'g(n) [bits]':>14} {'closed form':>14} {'n^2 g(n)':>12}")
    for n in range(2, 13):
        closed = f"{g_or_closed_form(n):14.10f}" if n in (2, 3, 4, 5, 8) else " " * 14
        print(f"{n:3d} {g_or(n):14.10f} {closed} {n ** 2 * g_or(n):12.6f}")
    print()
    print("Closed forms:")
    print("  g(2) = 3/2 - (3/4)log2 3")
    print("  g(3) = log2 3 - (5/9)log2 5 - 2/9")
    print("  g(4) = 11/4 - (15/16)log2 3 - (7/16)log2 7")
    print("  g(5) = log2 5 - (6/25)log2 3 - 48/25")
    print("  g(8) = 31/8 + (27/64)log2 3 - (15/64)log2 5 - (91/64)log2 7")
    for n in (2, 3, 4, 5, 8):
        assert abs(g_or(n) - g_or_closed_form(n)) < 1e-12
    print("  [all closed forms agree with the definition to 1e-12]")
    print()


# --------------------------------------------------------------------------
# 2.  The group-theoretic core: fibre counts
# --------------------------------------------------------------------------


def fibre_counts(n: int) -> Dict[int, Tuple[int, int]]:
    """For the cyclic group Z/n (written additively, identity 0) return, for each
    class c, the pair (|fibre|, |OR-part of fibre|), i.e. the number of pairs
    (x, y) with x + y = c and the number of those with x = 0 or y = 0."""
    out: Dict[int, Tuple[int, int]] = {}
    for c in range(n):
        fibre = [(x, (c - x) % n) for x in range(n)]
        or_part = [z for z in fibre if z[0] == 0 or z[1] == 0]
        out[c] = (len(fibre), len(or_part))
    return out


def section_two() -> None:
    print("=" * 78)
    print("2.  FIBRE COUNTS:  n per class, 1 in the trivial class and 2 elsewhere")
    print("=" * 78)
    for n in (2, 3, 4, 5, 6, 7):
        counts = fibre_counts(n)
        sizes = {c: counts[c][0] for c in counts}
        ors = {c: counts[c][1] for c in counts}
        assert set(sizes.values()) == {n}
        assert ors[0] == 1 and all(ors[c] == 2 for c in range(1, n))
        assert sum(ors.values()) == 2 * n - 1
        print(
            f"  n = {n}:  every fibre has {n} pairs; "
            f"OR-part = 1 (trivial class) / 2 (others); total OR event = {2*n-1}"
        )
    print("  [Lemma: |F(c)| = n, |F^or(c)| = 1 if c = 1 else 2, |E^or| = 2n-1]")
    print()


# --------------------------------------------------------------------------
# 3.  Exhaustive verification of the law inside the character value group
# --------------------------------------------------------------------------


def exhaustive_channel(n: int) -> Tuple[float, float, float, float]:
    """Enumerate all n^2 pairs of character values in Z/n and return
    (rate | trivial class, rate | nontrivial class, unconditional rate,
     mutual information in bits between [class is trivial] and OR)."""
    joint = Counter()  # (class-is-trivial, OR) -> count
    for x, y in itertools.product(range(n), repeat=2):
        c = (x + y) % n
        joint[(c == 0, x == 0 or y == 0)] += 1
    total = float(n * n)
    p = {k: v / total for k, v in joint.items()}
    row = {a: sum(p.get((a, t), 0.0) for t in (False, True)) for a in (False, True)}
    col = {t: sum(p.get((a, t), 0.0) for a in (False, True)) for t in (False, True)}
    info = 0.0
    for (a, t), value in p.items():
        if value > 0.0:
            info += value * math.log2(value / (row[a] * col[t]))
    return (
        p.get((True, True), 0.0) / row[True],
        p.get((False, True), 0.0) / row[False],
        col[True],
        info,
    )


def section_three() -> None:
    print("=" * 78)
    print("3.  THE LAW, VERIFIED BY EXHAUSTIVE ENUMERATION IN THE VALUE GROUP")
    print("=" * 78)
    header = f"{'n':>3} {'P(OR|c=1)':>10} {'1/n':>8} {'P(OR|c!=1)':>11} {'2/n':>8}"
    header += f" {'P(OR)':>9} {'(2n-1)/n^2':>11} {'I [bits]':>11} {'g(n)':>11}"
    print(header)
    for n in range(2, 10):
        r1, r2, marg, info = exhaustive_channel(n)
        print(
            f"{n:3d} {r1:10.6f} {1/n:8.6f} {r2:11.6f} {2/n:8.6f}"
            f" {marg:9.6f} {(2*n-1)/n**2:11.6f} {info:11.7f} {g_or(n):11.7f}"
        )
        assert abs(r1 - 1 / n) < 1e-12
        assert abs(r2 - 2 / n) < 1e-12
        assert abs(marg - (2 * n - 1) / n ** 2) < 1e-12
        assert abs(info - g_or(n)) < 1e-12
    print("  [exact agreement with the law to 1e-12 for every n]")
    print()


# --------------------------------------------------------------------------
# 4.  Real number theory: split primes, real semiprimes, measured bits
# --------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(limit + 1) if sieve[i]]


def count_roots_mod_p(coeffs: Sequence[int], p: int) -> int:
    """Number of distinct roots in Z/p of the polynomial with the given integer
    coefficients (constant term first).  Brute force: O(p * deg)."""
    roots = 0
    for x in range(p):
        value = 0
        power = 1
        for c in coeffs:
            value = (value + c * power) % p
            power = power * x % p
        if value == 0:
            roots += 1
    return roots


def splits_completely(coeffs: Sequence[int], p: int) -> bool:
    """True iff the polynomial splits into distinct linear factors mod p, i.e.
    iff the number of roots equals the degree (the complete-splitting test)."""
    return count_roots_mod_p(coeffs, p) == len(coeffs) - 1


def measure_or_leak(
    coeffs: Sequence[int],
    conductor: int,
    prime_bound: int,
    samples: int,
    seed: int = 20260817,
) -> Tuple[float, float, float, float, int]:
    """Empirically measure the OR leak for the field defined by `coeffs`.

    Returns (measured bits, P(OR | chi(N)=1), P(OR | chi(N)!=1), split density,
             number of usable primes).

    The character class of a prime p is identified with the coset of p mod f
    inside the subgroup of classes whose primes split; the observable event
    'chi(N) = 1' is then 'N mod f lies in that subgroup'."""
    primes = [p for p in primes_up_to(prime_bound) if conductor % p != 0]
    split_flag = {p: splits_completely(coeffs, p) for p in primes}
    split_classes = {p % conductor for p in primes if split_flag[p]}
    density = sum(split_flag.values()) / len(primes)

    rng = random.Random(seed)
    joint = Counter()
    for _ in range(samples):
        p = rng.choice(primes)
        q = rng.choice(primes)
        trivial = (p * q) % conductor in split_classes
        disjunction = split_flag[p] or split_flag[q]
        joint[(trivial, disjunction)] += 1

    total = float(samples)
    prob = {k: v / total for k, v in joint.items()}
    row = {a: sum(prob.get((a, t), 0.0) for t in (False, True)) for a in (False, True)}
    col = {t: sum(prob.get((a, t), 0.0) for a in (False, True)) for t in (False, True)}
    info = 0.0
    for (a, t), value in prob.items():
        if value > 0.0 and row[a] > 0.0 and col[t] > 0.0:
            info += value * math.log2(value / (row[a] * col[t]))
    r1 = prob.get((True, True), 0.0) / row[True] if row[True] > 0 else float("nan")
    r2 = prob.get((False, True), 0.0) / row[False] if row[False] > 0 else float("nan")
    return info, r1, r2, density, len(primes)


def section_four() -> None:
    print("=" * 78)
    print("4.  REAL FIELDS, REAL SEMIPRIMES")
    print("=" * 78)
    fields = [
        ("x^2 - x - 1        Q(sqrt 5)", [-1, -1, 1], 5, 2),
        ("x^3 + x^2 - 2x - 1 cyclic cubic", [-1, -2, 1, 1], 7, 3),
        ("x^3 - 3x + 1       cyclic cubic", [1, -3, 0, 1], 9, 3),
        ("x^4 - 4x^2 + 2     Q(zeta_16)^+", [2, 0, -4, 0, 1], 16, 4),
        ("x^2 + x + 1        Q(sqrt -3)", [1, 1, 1], 3, 2),
    ]
    prime_bound, samples = 20000, 60000
    print(
        f"{'field':34} {'n':>2} {'f':>3} {'density':>8} {'1/n':>7}"
        f" {'meas.':>8} {'g(n)':>8} {'r|c=1':>7} {'r|c!=1':>7}"
    )
    for name, coeffs, conductor, order in fields:
        info, r1, r2, density, _ = measure_or_leak(
            coeffs, conductor, prime_bound, samples
        )
        print(
            f"{name:34} {order:2d} {conductor:3d} {density:8.4f} {1/order:7.4f}"
            f" {info:8.4f} {g_or(order):8.4f} {r1:7.4f} {r2:7.4f}"
        )
    print()
    print("  The measured split densities match 1/n, the per-class OR rates match")
    print("  1/n and 2/n, and the measured leak matches g(n).  Note the n = 2 field")
    print("  Q(sqrt -3):  '3 divides p-1' is complete splitting there, and the rate")
    print("  in the nontrivial class is exactly 1 -- if chi(N) != 1 then exactly one")
    print("  factor splits, so the OR is certain.")
    print()
    print("  Control: a modulus coprime to the conductor should leak nothing.")
    info, _, _, _, _ = measure_or_leak([-1, -1, 1], 5, prime_bound, samples)
    primes = [p for p in primes_up_to(prime_bound) if p != 5]
    flag = {p: splits_completely([-1, -1, 1], p) for p in primes}
    rng = random.Random(7)
    joint = Counter()
    for _ in range(samples):
        p, q = rng.choice(primes), rng.choice(primes)
        joint[((p * q) % 7, flag[p] or flag[q])] += 1
    total = float(samples)
    prob = {k: v / total for k, v in joint.items()}
    rows = {a for (a, _) in prob}
    row = {a: sum(prob.get((a, t), 0.0) for t in (False, True)) for a in rows}
    col = {t: sum(prob.get((a, t), 0.0) for a in rows) for t in (False, True)}
    flat = sum(
        v * math.log2(v / (row[a] * col[t])) for (a, t), v in prob.items() if v > 0
    )
    print(f"    Q(sqrt 5), conditioning on N mod 5 : {info:.4f} bits  (g(2) = 0.3113)")
    print(f"    Q(sqrt 5), conditioning on N mod 7 : {flat:.4f} bits  (flat, as predicted)")
    print()


# --------------------------------------------------------------------------
# 5.  Bounds and the sharp asymptotic constant
# --------------------------------------------------------------------------


def chi_square_bound(n: float) -> float:
    """g(n) <= 1/(ln 2 (n-1)(2n-1))."""
    return 1.0 / (math.log(2.0) * (n - 1.0) * (2.0 * n - 1.0))


def kl_decomposition(n: float) -> Tuple[float, float, float, float]:
    """The four natural-logarithm terms whose sum, divided by ln 2, is n^2 g(n)."""
    return (
        (n - 1.0) * math.log(n / (n - 1.0)),
        math.log(n / (2.0 * n - 1.0)),
        (n - 1.0) * (n - 2.0) * math.log(n * (n - 2.0) / (n - 1.0) ** 2),
        2.0 * (n - 1.0) * math.log(2.0 * n / (2.0 * n - 1.0)),
    )


def section_five() -> None:
    print("=" * 78)
    print("5.  BOUNDS AND THE SHARP CONSTANT  n^2 g(n) -> 1/ln2 - 1")
    print("=" * 78)
    print(f"{'n':>3} {'0.08/n^2':>11} {'g(n)':>12} {'chi^2 bound':>13} {'2/n^2':>11}")
    for n in (2, 3, 4, 5, 8, 16, 32):
        assert 0.08 / n ** 2 <= g_or(n) <= 2.0 / n ** 2
        assert g_or(n) <= chi_square_bound(n) + 1e-15
        print(
            f"{n:3d} {0.08/n**2:11.7f} {g_or(n):12.8f}"
            f" {chi_square_bound(n):13.8f} {2.0/n**2:11.7f}"
        )
    print("  [two-sided rate and chi^2 bound hold at every tested n]")
    print()
    limit = 1.0 / math.log(2.0) - 1.0
    print(f"  Limit constant 1/ln2 - 1 = {limit:.12f}")
    print(f"{'n':>8} {'term1':>9} {'term2':>9} {'term3':>9} {'term4':>9} {'n^2 g(n)':>12}")
    for n in (4.0, 8.0, 32.0, 256.0, 4096.0, 65536.0):
        t1, t2, t3, t4 = kl_decomposition(n)
        recomposed = (t1 + t2 + t3 + t4) / math.log(2.0)
        print(f"{n:8.0f} {t1:9.5f} {t2:9.5f} {t3:9.5f} {t4:9.5f} {recomposed:12.8f}")
    print("  term limits:  1,  -ln2 = -0.69315,  -1,  1")
    print("  class chi(N)=1 contributes 1 - ln2;  the classes chi(N)!=1 cancel to 0.")
    print()
    print("  Second-order behaviour:  n(n^2 g(n) - (1/ln2 - 1)) -> 1/(4 ln 2)")
    print(f"  predicted 1/(4 ln 2) = {1.0/(4.0*math.log(2.0)):.9f}")
    for n in (1e2, 1e3, 1e4):
        t = sum(kl_decomposition(n)) / math.log(2.0)
        print(f"    n = {n:9.0f}:  {(t - limit) * n:.9f}")
    print()


# --------------------------------------------------------------------------
# 6.  The Boolean face hierarchy
# --------------------------------------------------------------------------


def face_informations(n: float) -> Tuple[float, float, float, float]:
    """(I_OR, I_XOR, I_AND, I_S) as functions of the order n alone."""
    prior = (1.0 / n, (n - 1.0) / n)
    row_trivial = ((n - 1.0) / n, 0.0, 1.0 / n)  # S = 0, 1, 2 given chi(N) = 1
    row_other = ((n - 2.0) / n, 2.0 / n, 0.0)  # S = 0, 1, 2 given chi(N) != 1
    split = tuple(
        prior[0] * row_trivial[i] + prior[1] * row_other[i] for i in range(3)
    )
    i_s = (
        entropy_bits(split)
        - prior[0] * entropy_bits(row_trivial)
        - prior[1] * entropy_bits(row_other)
    )
    i_and = binary_entropy(1.0 / n ** 2) - prior[0] * binary_entropy(1.0 / n)
    i_xor = binary_entropy(2.0 * (n - 1.0) / n ** 2) - prior[1] * binary_entropy(2.0 / n)
    return g_or(n), i_xor, i_and, i_s


def section_six() -> None:
    print("=" * 78)
    print("6.  THE FACE HIERARCHY:  OR vs XOR vs AND vs the split count")
    print("=" * 78)
    print(f"{'n':>3} {'I_OR':>10} {'I_XOR':>10} {'I_AND':>10} {'I_S':>10}  ordering")
    for n in (2, 3, 4, 5, 6, 7, 8, 9, 12, 20):
        i_or, i_xor, i_and, i_s = face_informations(float(n))
        ordered = "OR < XOR < AND < S" if i_or < i_xor < i_and < i_s else "-"
        print(f"{n:3d} {i_or:10.6f} {i_xor:10.6f} {i_and:10.6f} {i_s:10.6f}  {ordered}")
    print("  The OR is the smallest face for every n >= 3: merging the two smallest")
    print("  fibre cells is exactly what destroys the information.  The AND/XOR order")
    print("  flips between n = 7 and n = 9, and the full chain is conjectured for all")
    print("  n >= 8.")
    print()


# --------------------------------------------------------------------------
# 7.  k-factor generalisation (elementary fibre count)
# --------------------------------------------------------------------------


def k_factor_rate(n: int, k: int, trivial_class: bool) -> float:
    """P(OR_k | chi(N) = c) for a k-almost prime, c trivial or not:
    1 - (1 - 1/n)^k + (-1)^(k-1) ( [c = 1]/n^(k-1) - 1/n^k )."""
    sign = -1.0 if k % 2 == 0 else 1.0
    correction = (1.0 / n ** (k - 1) if trivial_class else 0.0) - 1.0 / n ** k
    return 1.0 - (1.0 - 1.0 / n) ** k + sign * correction


def k_factor_leak(n: int, k: int) -> float:
    """Mutual information in bits between [chi(N) = 1] and OR_k."""
    prior = (1.0 / n, (n - 1.0) / n)
    rates = (k_factor_rate(n, k, True), k_factor_rate(n, k, False))
    marginal = prior[0] * rates[0] + prior[1] * rates[1]
    return (
        binary_entropy(marginal)
        - prior[0] * binary_entropy(rates[0])
        - prior[1] * binary_entropy(rates[1])
    )


def section_seven() -> None:
    print("=" * 78)
    print("7.  MORE THAN TWO FACTORS:  the collapse accelerates")
    print("=" * 78)
    for k in (2, 3, 4):
        print(f"  k = {k} factors")
        print(f"{'n':>8} {'P(OR|c=1)':>11} {'P(OR|c!=1)':>11} {'leak [bits]':>13}"
              f" {'n^(2k-2) leak':>14}")
        for n in (5, 10, 20, 40):
            r1 = k_factor_rate(n, k, True)
            r2 = k_factor_rate(n, k, False)
            leak = k_factor_leak(n, k)
            print(f"{n:8d} {r1:11.7f} {r2:11.7f} {leak:13.3e}"
                  f" {leak * n ** (2 * k - 2):14.6f}")
        # brute-force check of the rate formula
        for n in (2, 3, 4):
            counts = Counter()
            hits = Counter()
            for tup in itertools.product(range(n), repeat=k):
                c = sum(tup) % n
                counts[c] += 1
                if any(x == 0 for x in tup):
                    hits[c] += 1
            for c in range(n):
                predicted = k_factor_rate(n, k, c == 0)
                assert abs(hits[c] / counts[c] - predicted) < 1e-12
    print("  [the k-fold rate formula is confirmed by brute force for n <= 4, k <= 4]")
    print("  The two class rates differ by n^-(k-1), so the leak decays like")
    print("  n^-(2k-2) up to a slowly converging k-dependent constant:  more factors")
    print("  do not dilute the leak, they annihilate it.")
    print()


def main() -> None:
    print()
    print("THE OR-COLLAPSE LAW -- numerical demonstration")
    print()
    section_one()
    section_two()
    section_three()
    section_four()
    section_five()
    section_six()
    section_seven()
    print("=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
