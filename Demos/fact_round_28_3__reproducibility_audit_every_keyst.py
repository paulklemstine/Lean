"""Algorithm A — the Farey certificate for a reproducibility audit.

Decides whether the agreement of a recorded rational a/q with a re-run rational
b/r to within a tolerance eps is a *proof* of exact equality.

Soundness rests on the separation theorem: distinct rationals satisfy
|a/q - b/r| >= 1/(q r).  Hence if eps <= 1/(q r) and the two values agree to
within eps, they are equal.  All comparisons are carried out in exact integer
arithmetic, so the decision itself introduces no floating-point error.

Complexity: O(1) big-integer multiplications, i.e. O(M(log(q r))) bit
operations.  The test is sound but necessarily incomplete: by the sharpness
example |1/100 - 1/101| = 1/10100 < 1e-4, no test at four decimals can certify
denominators beyond 100.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Tuple


def farey_gap(q: int, r: int) -> Fraction:
    """Guaranteed minimum separation 1/(q r) of two distinct rationals with
    denominators q and r."""
    if q <= 0 or r <= 0:
        raise ValueError("denominators must be positive")
    return Fraction(1, q * r)


def certificate_valid(q: int, r: int, eps: Fraction) -> bool:
    """True when the tolerance is inside the guaranteed gap, i.e. eps <= 1/(q r).
    This is decided before any comparison of values."""
    return eps <= farey_gap(q, r)


def audit(recorded: Fraction, rerun: Fraction, eps: Fraction) -> Tuple[str, str]:
    """Return (verdict, explanation).

    verdict is one of
      'CERTIFIED-EQUAL'  : the values provably coincide;
      'CERTIFIED-DISTINCT': the values provably differ (their exact gap exceeds eps);
      'INCONCLUSIVE'     : agreement is compatible with distinct values.
    """
    q, r = recorded.denominator, rerun.denominator
    gap: Fraction = abs(recorded - rerun)
    if gap >= eps:
        return (
            "CERTIFIED-DISTINCT",
            f"exact gap {gap} = {float(gap):.3e} is not below the tolerance "
            f"{float(eps):.3e}: the re-run did not reproduce the record",
        )
    if certificate_valid(q, r, eps):
        return (
            "CERTIFIED-EQUAL",
            f"denominators {q}, {r} give a guaranteed separation "
            f"1/{q*r} = {float(farey_gap(q, r)):.3e} > {float(eps):.3e}; "
            f"agreement within the tolerance therefore forces equality "
            f"(and indeed the exact gap is {gap})",
        )
    return (
        "INCONCLUSIVE",
        f"denominators {q}, {r} give only 1/{q*r} = "
        f"{float(farey_gap(q, r)):.3e} <= {float(eps):.3e}; distinct rationals "
        f"of these denominators can agree to this precision",
    )


def max_certifiable_denominator(eps: Fraction) -> int:
    """Largest Q such that any two rationals of denominator <= Q agreeing within
    eps must coincide: the Farey resolution, the largest Q with 1/Q^2 > eps."""
    q: int = 1
    while Fraction(1, (q + 1) ** 2) > eps:
        q += 1
    return q


if __name__ == "__main__":
    eps = Fraction(1, 10**4)
    print("Farey resolution at 1e-4:", max_certifiable_denominator(eps))
    cases = [
        ("pair capacity at order 8", Fraction(21, 16), Fraction(13125, 10000)),
        ("type entropy at order 4", Fraction(3, 2), Fraction(15000, 10000)),
        ("sharpness example", Fraction(1, 100), Fraction(1, 101)),
        ("a genuine mismatch", Fraction(21, 16), Fraction(4, 3)),
    ]
    for label, rec, run in cases:
        verdict, why = audit(rec, run, eps)
        print(f"\n{label}: recorded {rec}, re-run {run}")
        print(f"  {verdict}: {why}")


"""Algorithm B — evaluation of the splitting-type channel.

Computes, for a given order n:

  * the type histogram of T(a) = n / gcd(n, a) over a in Z/n;
  * the type entropy H_T(n);
  * the pair capacity I_pair(n) = I(K ; N), where K = {T(x), T(y)} is the
    unordered type pair of a uniform pair (x, y) and N = x + y mod n is the
    norm class of the product.

Two evaluation strategies are provided.  The direct one loops over all n^2
pairs: O(n^2) time and O(n * #keys) memory, exact but limited to n of the order
of a few thousand.  The fast one exploits the fact that T depends on x only
through gcd(n, x): group residues into gcd classes and convolve the classes,
giving O(d(n)^2 * n) time where d(n) is the number of divisors of n --- a large
saving whenever n has few divisors.

Both strategies accumulate integer counts and convert to entropies only at the
end, so the result is as accurate as the final logarithms.
"""

from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Dict, List, Tuple


def splitting_type(n: int, a: int) -> int:
    return n // gcd(n, a)


def entropy_of_counts(counts: List[int]) -> float:
    total: int = sum(counts)
    return sum(-(c / total) * log2(c / total) for c in counts if c > 0)


def type_histogram(n: int) -> Dict[int, int]:
    return dict(Counter(splitting_type(n, a) for a in range(n)))


def type_entropy(n: int) -> float:
    return entropy_of_counts(list(type_histogram(n).values()))


def pair_capacity_direct(n: int) -> float:
    """O(n^2) evaluation of I(K ; N) by explicit enumeration of all pairs."""
    joint: Counter = Counter()
    key: Counter = Counter()
    norm: Counter = Counter()
    for x in range(n):
        tx: int = splitting_type(n, x)
        for y in range(n):
            ty: int = splitting_type(n, y)
            k: Tuple[int, int] = (tx, ty) if tx <= ty else (ty, tx)
            c: int = (x + y) % n
            joint[(k, c)] += 1
            key[k] += 1
            norm[c] += 1
    return (
        entropy_of_counts(list(key.values()))
        + entropy_of_counts(list(norm.values()))
        - entropy_of_counts(list(joint.values()))
    )


def pair_capacity_fast(n: int) -> float:
    """O(d(n)^2 * n) evaluation by convolving gcd classes.

    Residues are grouped by g = gcd(n, x); the type is n/g, so the key depends
    only on the pair of classes.  For each ordered pair of classes the
    distribution of x + y is obtained by one convolution of the two indicator
    vectors, computed in O(n) per divisor pair by direct accumulation over the
    smaller class."""
    classes: Dict[int, List[int]] = {}
    for a in range(n):
        classes.setdefault(gcd(n, a), []).append(a)
    joint: Counter = Counter()
    key: Counter = Counter()
    norm: Counter = Counter()
    for g1, xs in classes.items():
        for g2, ys in classes.items():
            t1, t2 = n // g1, n // g2
            k: Tuple[int, int] = (t1, t2) if t1 <= t2 else (t2, t1)
            key[k] += len(xs) * len(ys)
            for x in xs:
                for y in ys:
                    joint[(k, (x + y) % n)] += 1
    for c in range(n):
        norm[c] = n
    return (
        entropy_of_counts(list(key.values()))
        + entropy_of_counts(list(norm.values()))
        - entropy_of_counts(list(joint.values()))
    )


if __name__ == "__main__":
    for n in (4, 6, 8, 12, 16, 32):
        hist = type_histogram(n)
        print(f"n = {n:>3}  histogram {dict(sorted(hist.items()))}")
        print(f"        H_T     = {type_entropy(n):.10f}")
        print(f"        I_pair  = {pair_capacity_direct(n):.10f} "
              f"(fast route: {pair_capacity_fast(n):.10f})")


"""Algorithm C — exact closed-form evaluation on the two-adic tower.

Replaces the O(n^2) enumeration of the channel at n = 2^k by O(k) bit
operations, and returns *exact* rationals rather than floating-point values ---
which is precisely what the Farey certificate consumes.

  H_T(2^k)     = 2 - 2^{1-k} = (2^k - 1) / 2^{k-1}
  I_pair(2^k)  = (4/3)(1 - 4^{-k}) = J_k / 4^{k-1},   J_k = (4^k - 1)/3

The entropy law is proved from the divisor formula
H_T(n) = log2 n - (1/n) sum_{d | n} phi(d) log2 phi(d) together with the
arithmetic-geometric identity sum_{i<k} i 2^i = (k-2) 2^k + 2.  The capacity law
is established for k <= 4 and confirmed by enumeration for k <= 7; its
numerators are the Jacobsthal numbers, which satisfy J_{k+1} = 4 J_k + 1.

The routine also reports the certification radius of each row: rows of the
entropy tower are at least 2^{-j} apart, so a record at precision eps
identifies the row whenever eps <= 2^{-k}, which at four decimals covers
k <= 13 --- far beyond the generic denominator bound of 70.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterator, Tuple


def jacobsthal(k: int) -> int:
    """J_k = (4^k - 1)/3, satisfying J_0 = 0 and J_{k+1} = 4 J_k + 1."""
    return (4**k - 1) // 3


def type_entropy_two_pow(k: int) -> Fraction:
    """H_T(2^k) = (2^k - 1)/2^{k-1} for k >= 1."""
    if k < 1:
        raise ValueError("k must be at least 1")
    return Fraction(2**k - 1, 2 ** (k - 1))


def pair_capacity_two_pow(k: int) -> Fraction:
    """I_pair(2^k) = J_k / 4^{k-1} for k >= 1."""
    if k < 1:
        raise ValueError("k must be at least 1")
    return Fraction(jacobsthal(k), 4 ** (k - 1))


def row_gap(j: int, k: int) -> Fraction:
    """Guaranteed separation of two distinct rows of the entropy tower:
    H_T(2^k) - H_T(2^j) >= 2^{-j} for j < k."""
    if j >= k:
        raise ValueError("require j < k")
    return Fraction(1, 2**j)


def certified_by_gap(k: int, eps: Fraction) -> bool:
    """True when a record at precision eps identifies row k uniquely, i.e.
    eps <= 2^{-k}."""
    return eps <= Fraction(1, 2**k)


def tower(kmax: int) -> Iterator[Tuple[int, Fraction, Fraction, int, bool]]:
    eps = Fraction(1, 10**4)
    for k in range(1, kmax + 1):
        yield (
            k,
            type_entropy_two_pow(k),
            pair_capacity_two_pow(k),
            jacobsthal(k),
            certified_by_gap(k, eps),
        )


if __name__ == "__main__":
    print(f"{'k':>3} {'H_T(2^k)':>14} {'value':>14} {'I_pair(2^k)':>16} "
          f"{'value':>14} {'J_k':>8} {'gap-certified':>14}")
    for k, ht, ip, jk, cert in tower(16):
        print(f"{k:>3} {str(ht):>14} {float(ht):>14.10f} {str(ip):>16} "
              f"{float(ip):>14.10f} {jk:>8} {str(cert):>14}")
    print("\nceilings: H_T -> 2 bits, I_pair -> 4/3 bits, both strictly from below")


"""Algorithm E — rigorous enclosure certificates in the irrational stratum.

In the irrational stratum no decimal record can equal the recorded value, so an
audit must certify an *enclosure* instead.  For values built from log2(3) the
enclosure reduces to integer inequalities: from the continued-fraction
convergents p/q of log2(3),

    2^p < 3^q   implies   log2(3) > p/q,
    3^q < 2^p   implies   log2(3) < p/q,

each verifiable exactly with big integers and no floating-point arithmetic
anywhere in the certificate.  The witnesses used for the four-decimal record are
2^1054 < 3^665 and 3^306 < 2^485, giving 1.58496 < log2(3) < 1.58497 and hence
|I_pair(6) - 1.4738| < 1e-4 for I_pair(6) = log2(3) - 1/9.

Complexity: generating the convergents is O(m) rational steps; each witness
costs a couple of big-integer exponentiations, i.e. O(M(q log 3)) bit
operations.
"""

from __future__ import annotations

from fractions import Fraction
from math import log2
from typing import List, Tuple


def continued_fraction_convergents(x: float, depth: int) -> List[Fraction]:
    """Convergents p/q of the continued fraction expansion of x."""
    a: List[int] = []
    y: float = x
    for _ in range(depth):
        ai: int = int(y // 1)
        a.append(ai)
        frac: float = y - ai
        if frac < 1e-15:
            break
        y = 1.0 / frac
    convs: List[Fraction] = []
    for i in range(1, len(a) + 1):
        f = Fraction(a[i - 1])
        for c in reversed(a[: i - 1]):
            f = c + 1 / f
        convs.append(f)
    return convs


def verify_lower(p: int, q: int) -> bool:
    """Exact witness for log2(3) > p/q."""
    return 2**p < 3**q


def verify_upper(p: int, q: int) -> bool:
    """Exact witness for log2(3) < p/q."""
    return 3**q < 2**p


def enclose_log2_three(target: Fraction) -> Tuple[Fraction, Fraction]:
    """Return certified (lower, upper) bounds for log2(3) of width < target,
    each justified by one exact integer inequality."""
    lower: Fraction = Fraction(1)
    upper: Fraction = Fraction(2)
    for c in continued_fraction_convergents(log2(3.0), 24):
        p, q = c.numerator, c.denominator
        if verify_lower(p, q) and c > lower:
            lower = c
        if verify_upper(p, q) and c < upper:
            upper = c
        if upper - lower < target:
            break
    return lower, upper


def enclose_pair_capacity_six(target: Fraction) -> Tuple[Fraction, Fraction]:
    """Certified enclosure of I_pair(6) = log2(3) - 1/9."""
    lo, hi = enclose_log2_three(target)
    return lo - Fraction(1, 9), hi - Fraction(1, 9)


def record_is_valid(record: Fraction, enclosure: Tuple[Fraction, Fraction],
                    eps: Fraction) -> bool:
    """True when every point of the enclosure is within eps of the record, so the
    record is a correct approximation at that precision."""
    lo, hi = enclosure
    return abs(lo - record) < eps and abs(hi - record) < eps


if __name__ == "__main__":
    target = Fraction(1, 10**5)
    lo, hi = enclose_log2_three(target)
    print(f"certified enclosure of log2 3:")
    print(f"  lower {lo} = {float(lo):.12f}  witness 2^{lo.numerator} < "
          f"3^{lo.denominator}: {verify_lower(lo.numerator, lo.denominator)}")
    print(f"  upper {hi} = {float(hi):.12f}  witness 3^{hi.denominator} < "
          f"2^{hi.numerator}: {verify_upper(hi.numerator, hi.denominator)}")
    plo, phi_ = enclose_pair_capacity_six(target)
    print(f"\nI_pair(6) = log2 3 - 1/9 lies in "
          f"({float(plo):.10f}, {float(phi_):.10f})")
    rec = Fraction(14738, 10000)
    print(f"stored record {float(rec)} valid at 1e-4: "
          f"{record_is_valid(rec, (plo, phi_), Fraction(1, 10**4))}")
    print("the record is a correct enclosure; it is never the value itself, "
          "because the value is irrational")


"""Algorithm D — the stratum classifier.

Decides, for an order n, whether the recorded type entropy H_T(n) can in
principle be certified by a rounded record.

  RATIONAL-CERTIFIABLE        n = 2^k.  Then H_T(n) = 2 - 2^{1-k} is dyadic with
                              denominator 2^{k-1}; a four-decimal record proves
                              exact reproduction whenever 2^{k-1} <= 70.
  IRRATIONAL-NONCERTIFIABLE   every divisor d of n has phi(d) a power of two
                              (equivalently, by Gauss-Wantzel, the regular
                              n-gon is constructible) but n is not a power of
                              two.  Then H_T(n) = log2 n - rational, and log2 n
                              is irrational, so no decimal record equals H_T(n).
  UNDECIDED-BY-THIS-TEST      some divisor has a totient that is not a power of
                              two; the correction term is then itself a
                              combination of logarithms and rationality reduces
                              to Q-linear independence of {log p}.

Complexity: factorisation of n (trial division here, O(sqrt n)) plus O(d(n))
totient evaluations, where d(n) is the number of divisors.
"""

from __future__ import annotations

from math import log2
from typing import List, Tuple


def euler_phi(m: int) -> int:
    result: int = m
    x: int = m
    p: int = 2
    while p * p <= x:
        if x % p == 0:
            while x % p == 0:
                x //= p
            result -= result // p
        p += 1
    if x > 1:
        result -= result // x
    return result


def divisors(n: int) -> List[int]:
    small: List[int] = []
    large: List[int] = []
    d: int = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def is_two_power(n: int) -> bool:
    return n > 0 and n & (n - 1) == 0


def is_constructible_order(n: int) -> bool:
    """All totients in the divisor lattice are powers of two: by Gauss-Wantzel,
    n = 2^a times a product of distinct Fermat primes."""
    return all(is_two_power(euler_phi(d)) for d in divisors(n))


def type_entropy_value(n: int) -> float:
    """H_T(n) = log2 n - (1/n) sum_{d|n} phi(d) log2 phi(d)."""
    return log2(n) - sum(
        euler_phi(d) * log2(euler_phi(d)) for d in divisors(n)
    ) / n


def classify(n: int) -> Tuple[str, str]:
    """Return (stratum, justification)."""
    if n < 1:
        raise ValueError("n must be positive")
    if is_two_power(n):
        k: int = n.bit_length() - 1
        den: int = 2 ** max(k - 1, 0)
        note = (
            f"H_T = 2 - 2^(1-{k}) = ({2**k}-1)/{den}, dyadic; "
            + ("four-decimal record certifies it (denominator <= 70)"
               if den <= 70 else
               f"denominator {den} exceeds 70, but the row gap 2^-{k} still "
               f"certifies for k <= 13")
        )
        return ("RATIONAL-CERTIFIABLE", note)
    if is_constructible_order(n):
        return (
            "IRRATIONAL-NONCERTIFIABLE",
            f"every divisor of {n} has a power-of-two totient, so "
            f"H_T = log2({n}) - rational; log2({n}) is irrational because a "
            f"rational value would force {n}^b = 2^a",
        )
    return (
        "UNDECIDED-BY-THIS-TEST",
        f"{n} has a divisor whose totient is not a power of two; rationality "
        f"reduces to Q-linear independence of logarithms of primes",
    )


if __name__ == "__main__":
    print(f"{'n':>4} {'H_T(n)':>14}  stratum")
    for n in (2, 3, 4, 5, 6, 8, 12, 15, 16, 17, 32, 51, 64, 85, 128, 256):
        stratum, why = classify(n)
        print(f"{n:>4} {type_entropy_value(n):>14.10f}  {stratum}")
        print(f"{'':>20}  {why}")


"""Assemble PACKAGE.json from the delivered documents, demos and assets."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


lean_files: List[str] = [
    "Catalog/Computation/ReproducibilityAudit.lean",
    "Catalog/Computation/ReproducibilityTwoAdicLaw.lean",
    "Catalog/Computation/ReproducibilityLogStrata.lean",
    "Catalog/Computation/ReproducibilityInvariance.lean",
    "Catalog/Computation/ReproducibilityGaloisConverse.lean",
]

lean_proofs = "\n\n".join(
    f"-- ==========================================================================\n"
    f"-- {f}\n"
    f"-- ==========================================================================\n\n"
    + read(ROOT / f)
    for f in lean_files
)

future_directions = """# Future directions — from "the numbers reproduce" to "the numbers are theorems"

This cycle replaced the *audit* reading of reproducibility (re-run the script, compare digits) by a
*structural* one: a recorded number is reproducible when it is either (i) a bounded-denominator
rational, in which case a rounded record provably determines it, or (ii) a closed-form irrational,
in which case only the derivation reproduces it — and the record is invariant under the arbitrary
choices in the pipeline.

Four structural patterns emerged and drive the conjectures below.

1. **Certifiability is a denominator statement.** Four-decimal agreement certifies equality exactly
   when the two rationals have denominators below the Farey threshold; the resolution is `1/Q²`,
   and it is attained.
2. **The dyadic family is a law, not a table.** The four recorded rows of the 2-adic tower are the
   `k ≤ 4` instances of `H(T)(2^k) = 2 − 2^{1−k}`.
3. **Constructibility controls the stratum.** On orders whose divisor lattice has only 2-power
   totients — Gauss–Wantzel's constructible orders — `H(T)` is `log₂ n` minus a rational, hence
   rational iff `n` is a power of two.
4. **Invariance is not just a property of the record, it characterises it.** The orbits of the unit
   action on `ℤ/n` are exactly the `gcd` classes, so the splitting type is the *universal*
   generator-invariant readout: every reproducible observable of a single residue factors
   through it.

## Direction 1 — Jacobsthal capacity law for the 2-adic pair channel

We have `I_pair(2^k) = (4/3)(1 − 4^{−k})` for `1 ≤ k ≤ 4` by evaluation; enumeration confirms it at
`k = 5, 6, 7`, where the numerators are the Jacobsthal numbers `(4^k − 1)/3`. **The key insight is**
that in `ℤ/2^k` the splitting type is a function of the 2-adic valuation alone, and the valuation of
a sum `x + y` is determined by `min(v(x), v(y))` except on the diagonal `v(x) = v(y)`, so the
conditional type-pair distribution given the norm class is a two-branch recursion in `k` — exactly
the recursion that produces the Jacobsthal numbers. **Why now?** The closed form for `H(T)(2^k)`
proved this cycle supplies the marginal half of the computation; only the conditional half is
missing.

## Direction 2 — Rationality dichotomy for every cyclic type entropy

We proved: on constructible orders, `H(T)(n)` is rational iff `n` is a power of two. The general
conjecture drops the constructibility hypothesis. **The key insight is** that
`H(T)(n) = log₂ n − (1/n) Σ_{d∣n} φ(d) log₂ φ(d)` is a ℚ-linear combination of logarithms of
integers, so its rationality is governed by ℚ-linear independence of `{log p : p prime}` — a
consequence of unique factorisation rather than of transcendence theory. **Why now?** The
constructible case shows the mechanism in a setting where the correction term is visibly rational,
so only the independence input is missing.

## Direction 3 — Optimal certificates from separation data

Gap certification of the 2-adic tower outperforms the generic Farey bound: rows are `2^{−k}` apart,
so a four-decimal record identifies a row for every `k ≤ 13`, far past the denominator bound of
`70`. Formulate the general principle: for a recorded family `{v_i}` with known minimum separation
`δ`, a record at precision `ε < δ/2` identifies the member uniquely, whatever the denominators.
Determining `δ` for the pair-capacity family, and for mixed-order families `{H(T)(n) : n ≤ N}`,
would give certificates far beyond what denominator bounds allow.

## Direction 4 — Invariance beyond a single residue

Universality of the splitting type is proved for readouts of a single residue. The semiprime channel
reads out *pairs*, where the relevant group action is the diagonal unit action on `ℤ/n × ℤ/n`.
Characterising the invariants of that action — presumably functions of the pair
`(gcd(n,x), gcd(n,y))` together with the norm class — would extend "reproducible by construction"
from the marginal record to the full conditional table.
"""

package: Dict[str, Any] = {
    "title": "When Does a Rounded Record Certify an Exact Value? "
             "Certifiability, Closed-Form Laws and Invariance for the Cyclic "
             "Splitting-Type Channel",
    "domain": "Computation",
    "description": (
        "Turns the practice of reproducibility auditing into mathematics: distinct "
        "rationals with denominators at most 70 cannot agree to four decimals, so a "
        "rounded record proves exact equality in the dyadic stratum of the cyclic "
        "splitting-type channel, while the closed-form irrational values there — "
        "such as the pair capacity log2(3) − 1/9 — can only ever be enclosed, never "
        "reproduced exactly. The record is further shown to be invariant under every "
        "change of generator, and invariance characterises exactly the observables "
        "that factor through the splitting type."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-22",
    "key_results": [
        "Separation theorem for bounded-denominator rationals: two distinct "
        "fractions a/q and b/r differ by at least 1/(qr), so agreement to four "
        "decimals proves exact equality whenever both denominators are at most 70, "
        "and the threshold is sharp because 1/100 and 1/101 differ by only 1/10100",
        "Two-adic entropy law: the type entropy of the cyclic group of order 2^k "
        "equals 2 − 2^(1−k), strictly increasing to a hard ceiling of two bits, with "
        "consecutive rows at least 2^(−j) apart, which certifies a recorded row from "
        "four decimals for every k up to 13",
        "Jacobsthal capacity law: the pair capacity at order 2^k equals "
        "(4/3)(1 − 4^(−k)), whose numerators are the Jacobsthal numbers (4^k − 1)/3, "
        "verified exactly as rationals for k up to 6",
        "Irrationality obstruction: the pair capacity at order 6 equals log2(3) − 1/9 "
        "and is irrational by unique factorisation, so no decimal record of any "
        "precision can equal it, while the enclosure 1.58496 < log2(3) < 1.58497 — "
        "certified by the integer inequalities 2^1054 < 3^665 and 3^306 < 2^485 — "
        "validates the stored four-decimal value",
        "Rationality dichotomy and universality: on the Gauss–Wantzel constructible "
        "orders the type entropy is rational precisely when the order is a power of "
        "two, and a readout of a residue is invariant under every change of generator "
        "if and only if it factors through the splitting type, whose fibres are the "
        "orbits of the unit action",
    ],
    "keywords": [
        "reproducibility",
        "Farey dissection",
        "splitting type",
        "Shannon entropy",
        "mutual information",
        "Jacobsthal numbers",
        "irrationality",
        "constructible polygons",
        "Galois invariance",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Full Audit Walkthrough: Certificates, Laws, Strata and "
                    "Invariance of the Splitting-Type Channel",
            "description": (
                "A single self-contained script that reproduces every result of the "
                "work numerically. It (1) computes the Farey resolution at four "
                "decimals and applies the separation certificate to the recorded "
                "keystones 5/4, 21/16, 85/64 and 3/2, exhibiting the sharpness "
                "failure at 1/100 versus 1/101; (2) enumerates the channel at orders "
                "2 through 128 and matches the enumerated type entropies and pair "
                "capacities against the closed forms 2 − 2^(1−k) and (4/3)(1 − 4^(−k)) "
                "with the Jacobsthal numerators, exhibiting monotonicity, the two-bit "
                "ceiling and the row gaps; (3) verifies the integer inequalities "
                "2^1054 < 3^665 and 3^306 < 2^485 that enclose log2(3), locating the "
                "irrational capacity log2(3) − 1/9 and confirming the recorded value "
                "1.4738 to within 1e-4; (4) classifies constructible orders into the "
                "certifiable and non-certifiable strata; and (5) checks that every "
                "change of generator reproduces the type histogram exactly, that the "
                "orbits of the unit action coincide with the gcd classes and the "
                "fibres of the type map, and that a readout is invariant exactly when "
                "it factors through the type."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Exact Rational Verification of the Two-Adic Entropy and "
                    "Jacobsthal Capacity Laws",
            "description": (
                "On the orders 2^k every cell count in the channel is a power of two, "
                "so every probability is dyadic and each entropy term −p log2 p is an "
                "exact rational. This demo exploits that to evaluate the enumerated "
                "type entropy and pair capacity in exact fraction arithmetic, with no "
                "rounding anywhere, and compares them to the closed forms as an "
                "equality of rationals rather than an agreement of digits: "
                "H_T(2^k) = (2^k − 1)/2^(k−1) for k up to 7 and "
                "I_pair(2^k) = J_k/4^(k−1) for k up to 6, where J_k = (4^k − 1)/3. It "
                "also exhibits the Jacobsthal recursion J_(k+1) = 4 J_k + 1 in the "
                "numerators. This is the strongest possible form of the audit for this "
                "family: not that the printed digits match, but that the enumerated "
                "rational equals the predicted rational."
            ),
            "code": read(A / "demo_jacobsthal.py"),
        },
    ],
    "algorithms": [
        {
            "name": "The Farey Certificate: Deciding Whether Digit Agreement Proves "
                    "Exact Equality",
            "description": (
                "Given a recorded rational a/q, a re-run rational b/r and a tolerance "
                "eps, this algorithm returns CERTIFIED-EQUAL, CERTIFIED-DISTINCT or "
                "INCONCLUSIVE. Its mathematical foundation is the separation theorem: "
                "distinct rationals satisfy |a/q − b/r| ≥ 1/(qr), because "
                "(a/q − b/r)·qr = ar − bq is a nonzero integer. Hence whenever "
                "eps ≤ 1/(qr), agreement within eps forces equality — a conclusion "
                "available before any comparison is made, and independent of the "
                "software, the seeds and the hardware. Every comparison is performed "
                "in exact integer arithmetic, so the decision procedure itself "
                "introduces no floating-point error. Complexity is O(1) big-integer "
                "multiplications, i.e. O(M(log qr)) bit operations. The test is sound "
                "but necessarily incomplete: since |1/100 − 1/101| = 1/10100 < 1e-4, no "
                "four-decimal test can certify denominators beyond 100, and the exact "
                "break-even denominator bound at that precision is 99. The routine also "
                "computes that Farey resolution for an arbitrary tolerance. Its role in "
                "the pipeline is to be the final arbiter of every audited headline "
                "number in the rational stratum."
            ),
            "pseudocode": (
                "INPUT  recorded a/q, re-run b/r, tolerance eps (all exact rationals)\n"
                "OUTPUT verdict in {CERTIFIED-EQUAL, CERTIFIED-DISTINCT, INCONCLUSIVE}\n"
                "\n"
                "1. assert q > 0 and r > 0\n"
                "2. gap  <- |a*r - b*q| / (q*r)            # exact rational difference\n"
                "3. if gap >= eps then\n"
                "4.     return CERTIFIED-DISTINCT          # the re-run did not match\n"
                "5. sep  <- 1 / (q*r)                      # guaranteed separation\n"
                "6. if eps <= sep then\n"
                "7.     return CERTIFIED-EQUAL             # separation theorem applies\n"
                "8. else\n"
                "9.     return INCONCLUSIVE                # impostors of denominator\n"
                "                                          # <= max(q,r) may exist\n"
                "\n"
                "SUBROUTINE FareyResolution(eps)\n"
                "  Q <- 1\n"
                "  while 1/(Q+1)^2 > eps do Q <- Q + 1\n"
                "  return Q      # any two rationals of denominator <= Q agreeing\n"
                "                # within eps must coincide"
            ),
            "code": read(A / "algo_certificate.py"),
        },
        {
            "name": "Evaluation of the Cyclic Splitting-Type Channel by Enumeration "
                    "and by gcd-Class Convolution",
            "description": (
                "Computes, for an order n, the histogram of the splitting type "
                "T(a) = n/gcd(n,a), the type entropy H_T(n), and the pair capacity "
                "I_pair(n) = I(K;N) where K is the unordered type pair of a uniform "
                "pair (x,y) and N = x + y mod n is the norm class of their product. "
                "Two strategies are given. The direct one accumulates the joint table "
                "over all n^2 pairs: O(n^2) time and O(n · #keys) memory, exact and "
                "feasible up to n of a few thousand. The fast one exploits the fact "
                "that the type depends on x only through gcd(n,x): residues are grouped "
                "into gcd classes and the classes convolved, giving O(d(n)^2 · n) work "
                "where d(n) is the number of divisors — a large saving when n has few "
                "divisors. Both accumulate integer counts and take logarithms only at "
                "the end, so accuracy is limited solely by the final logarithms. This "
                "is the routine that produces the headline numbers the certificate then "
                "audits."
            ),
            "pseudocode": (
                "INPUT  order n\n"
                "OUTPUT type histogram, H_T(n), I_pair(n)\n"
                "\n"
                "1. for a = 0 .. n-1:  T[a] <- n / gcd(n, a)\n"
                "2. hist <- multiset of T[a]                       # counts phi(d)\n"
                "3. H_T  <- Entropy(hist)\n"
                "\n"
                "DIRECT ROUTE\n"
                "4. joint, key, norm <- empty counters\n"
                "5. for x = 0 .. n-1:\n"
                "6.     for y = 0 .. n-1:\n"
                "7.         k <- sorted pair (T[x], T[y]);  c <- (x + y) mod n\n"
                "8.         increment key[k], norm[c], joint[(k, c)]\n"
                "9. I_pair <- Entropy(key) + Entropy(norm) - Entropy(joint)\n"
                "\n"
                "FAST ROUTE\n"
                "4'. partition residues into classes C_g = { x : gcd(n,x) = g }\n"
                "5'. for each ordered pair of classes (C_g1, C_g2):\n"
                "6'.     k <- sorted pair (n/g1, n/g2)\n"
                "7'.     key[k] <- key[k] + |C_g1| * |C_g2|\n"
                "8'.     convolve the indicator vectors of C_g1 and C_g2 to obtain the\n"
                "        distribution of x + y mod n, and add it into joint[(k, .)]\n"
                "9'. norm[c] <- n for every c              # the sum is uniform\n"
                "10'. I_pair <- Entropy(key) + Entropy(norm) - Entropy(joint)\n"
                "\n"
                "SUBROUTINE Entropy(counter)\n"
                "  t <- sum of counts;  return sum over c>0 of -(c/t) log2 (c/t)"
            ),
            "code": read(A / "algo_channel.py"),
        },
        {
            "name": "Closed-Form Evaluation of the Two-Adic Tower with Gap-Based "
                    "Certification",
            "description": (
                "Replaces the quadratic enumeration at n = 2^k by O(k) bit operations, "
                "returning exact rationals rather than floating-point values — which is "
                "precisely what the Farey certificate consumes. The entropy law "
                "H_T(2^k) = (2^k − 1)/2^(k−1) follows from the divisor formula "
                "H_T(n) = log2 n − (1/n) Σ_{d|n} φ(d) log2 φ(d) together with the "
                "arithmetic-geometric identity Σ_{i<k} i·2^i = (k−2)2^k + 2; the "
                "capacity law I_pair(2^k) = J_k/4^(k−1) with J_k = (4^k − 1)/3 the "
                "Jacobsthal numbers is established for small k and confirmed by exact "
                "enumeration. The routine additionally reports the certification radius "
                "of each row: consecutive rows of the entropy tower are at least 2^(−j) "
                "apart, so a record at precision eps identifies a row whenever "
                "eps ≤ 2^(−k), which at four decimals covers every k up to 13 — far "
                "beyond the generic denominator bound of 70. This is the algorithmic "
                "form of the slogan 'structure beats denominator size'."
            ),
            "pseudocode": (
                "INPUT  exponent k >= 1, audit precision eps\n"
                "OUTPUT exact H_T(2^k), exact I_pair(2^k), certification flag\n"
                "\n"
                "1. H   <- (2^k - 1) / 2^(k-1)                 # exact rational\n"
                "2. J   <- (4^k - 1) / 3                       # Jacobsthal number\n"
                "3. I   <- J / 4^(k-1)                         # exact rational\n"
                "4. gap <- 2^(-(k-1))                          # distance to the\n"
                "                                              # nearest lower row\n"
                "5. certified <- (eps <= 2^(-k))               # row isolation bound\n"
                "6. return (H, I, certified)\n"
                "\n"
                "PROPERTIES GUARANTEED\n"
                "  H is strictly increasing in k and H < 2, with H -> 2\n"
                "  I is strictly increasing in k and I < 4/3, with I -> 4/3\n"
                "  for j < k:  H(k) - H(j) >= 2^(-j)\n"
                "  J satisfies the recursion J_(k+1) = 4 J_k + 1"
            ),
            "code": read(A / "algo_closed_form.py"),
        },
        {
            "name": "Stratum Classification of a Recorded Type Entropy via "
                    "Constructibility",
            "description": (
                "Decides in advance whether a recorded type entropy is the sort of "
                "number a rounded record could certify. If n is a power of two the "
                "entropy is the dyadic rational 2 − 2^(1−k) and the answer is "
                "RATIONAL-CERTIFIABLE. If instead every divisor d of n has φ(d) a power "
                "of two — by the Gauss–Wantzel theorem exactly the condition that the "
                "regular n-gon is constructible with straightedge and compass, i.e. n is "
                "a power of two times a product of distinct Fermat primes — but n is not "
                "itself a power of two, then the correction term in the divisor formula "
                "is an integer, so H_T(n) = log2 n − rational; since log2 n is rational "
                "only on powers of two, the entropy is irrational and the answer is "
                "IRRATIONAL-NONCERTIFIABLE. Otherwise the test returns UNDECIDED, the "
                "remaining case reducing to Q-linear independence of the logarithms of "
                "primes. Complexity is dominated by factorisation (trial division, "
                "O(sqrt n) here) plus O(d(n)) totient evaluations. Its role in the "
                "pipeline is triage: it tells the auditor which of the three possible "
                "verdicts is even available before any run takes place."
            ),
            "pseudocode": (
                "INPUT  order n >= 1\n"
                "OUTPUT stratum label with justification\n"
                "\n"
                "1. if n is a power of two then\n"
                "2.     k <- log2 n;  denominator <- 2^(k-1)\n"
                "3.     return RATIONAL-CERTIFIABLE\n"
                "           with note: H_T = (2^k - 1)/2^(k-1); a four-decimal record\n"
                "           certifies it when 2^(k-1) <= 70, and the row gap 2^-k\n"
                "           certifies it for k <= 13\n"
                "4. D <- divisors(n)\n"
                "5. if for every d in D the value phi(d) is a power of two then\n"
                "6.     return IRRATIONAL-NONCERTIFIABLE\n"
                "           with note: H_T = log2 n - rational and log2 n is\n"
                "           irrational, since log2 n = a/b would force n^b = 2^a\n"
                "7. return UNDECIDED-BY-THIS-TEST\n"
                "       with note: rationality reduces to Q-linear independence of\n"
                "       { log p : p prime }"
            ),
            "code": read(A / "algo_stratum.py"),
        },
        {
            "name": "Integer-Witness Enclosure Certificates for the Irrational Stratum",
            "description": (
                "In the irrational stratum no decimal record can equal the recorded "
                "value, so an audit must certify an enclosure instead. For values built "
                "from log2(3) the enclosure reduces to integer inequalities: from a "
                "continued-fraction convergent p/q, the exact inequality 2^p < 3^q "
                "certifies log2(3) > p/q, and 3^q < 2^p certifies log2(3) < p/q. No "
                "floating-point arithmetic enters the certificate at any point; the "
                "convergents are merely a search heuristic, and their validity is "
                "established by big-integer comparison. The algorithm sharpens the "
                "bracket until it is narrower than a target width, returning the two "
                "witnesses; for four-decimal work it finds 2^1054 < 3^665 and "
                "3^306 < 2^485, giving 1.58496 < log2(3) < 1.58497 and hence "
                "|I_pair(6) − 1.4738| < 1e-4 for I_pair(6) = log2(3) − 1/9. Complexity: "
                "O(m) rational steps to generate convergents plus a couple of "
                "big-integer exponentiations per witness, i.e. O(M(q log 3)) bit "
                "operations. Its role is to supply the only rigorous statement an audit "
                "of an irrational record can make."
            ),
            "pseudocode": (
                "INPUT  target width w\n"
                "OUTPUT rationals lo < log2 3 < hi with hi - lo < w, plus witnesses\n"
                "\n"
                "1. lo <- 1;  hi <- 2\n"
                "2. for each convergent p/q of the continued fraction of log2 3:\n"
                "3.     if 2^p < 3^q  and  p/q > lo then lo <- p/q   # exact witness\n"
                "4.     if 3^q < 2^p  and  p/q < hi then hi <- p/q   # exact witness\n"
                "5.     if hi - lo < w then break\n"
                "6. return (lo, hi)\n"
                "\n"
                "APPLICATION to the recorded pair capacity at order 6\n"
                "7. (lo, hi) <- Enclose(w)\n"
                "8. enclosure of I_pair(6) is (lo - 1/9, hi - 1/9)\n"
                "9. the record R is VALID at precision eps iff every point of that\n"
                "   interval lies within eps of R;  it is never EQUAL to the value,\n"
                "   because the value is irrational"
            ),
            "code": read(A / "algo_enclosure.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Farey Scaffold and the Four-Decimal Tolerance Band",
            "description": (
                "Three stacked panels show every fraction with denominator at most Q "
                "in a narrow window around the recorded value 21/16 = 1.3125, plotted "
                "against its denominator on a logarithmic axis, with the four-decimal "
                "tolerance band shaded. At Q = 16 the scaffold is far coarser than the "
                "band; at Q = 70 the certificate is still valid because 1/70^2 exceeds "
                "1e-4; at Q = 400 the band is crowded with impostors and digit "
                "agreement proves nothing. The figure makes visible why certifiability "
                "is a statement about denominators and not about pipelines."
            ),
            "code": read(A / "viz_farey.py"),
        },
        {
            "name": "The Two-Adic Tower: Closed Forms, Ceilings and Row Gaps",
            "description": (
                "The left panel plots the enumerated type entropies and pair capacities "
                "of the orders 2^k against the closed forms 2 − 2^(1−k) and "
                "(4/3)(1 − 4^(−k)), together with their two-bit and four-thirds "
                "ceilings: four recorded rows are revealed as the start of two laws. The "
                "right panel plots the inter-row gap on a logarithmic scale against the "
                "four-decimal tolerance, marking k = 13 as the last row a four-decimal "
                "record can isolate — the visual form of the principle that a sparse "
                "ladder certifies far beyond what denominator bounds allow."
            ),
            "code": read(A / "viz_tower.py"),
        },
        {
            "name": "Certifiable and Non-Certifiable Strata of the Recorded Entropies",
            "description": (
                "The type entropy is plotted for every order up to 130 and coloured by "
                "stratum: blue for the powers of two, where the entropy is dyadic and a "
                "rounded record certifies it exactly; red for the remaining "
                "Gauss–Wantzel constructible orders, where the entropy is log2(n) minus "
                "a rational and hence irrational, so no record of any precision can "
                "equal it; grey for orders outside the reach of the dichotomy. The "
                "Fermat-prime orders 3, 5, 15, 17, 51, 85 and the powers of two are "
                "annotated, exhibiting the straightedge-and-compass condition as the "
                "boundary between the two certifiable regimes."
            ),
            "code": read(A / "viz_strata.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Certificate Lab — Watch Four Decimals Become a Theorem, "
                     "Then Stop Being One",
            "description": (
                "An interactive laboratory for the separation theorem. Choose a recorded "
                "value from the audited keystones (5/4, 21/16, 85/64, 3/2, or the "
                "sharpness example 1/100), then drag two sliders: the denominator bound "
                "of the hypothetical re-run value, and the agreement precision. A live "
                "canvas draws every fraction of denominator at most Q near the record, "
                "plotted against its denominator, with the tolerance band shaded; a "
                "verdict panel states whether agreement within the band is a proof of "
                "exact equality or merely compatible with an impostor, and a table lists "
                "the nearest competing fractions with their exact distances. Pushing the "
                "denominator bound past the Farey resolution makes impostors appear "
                "inside the band before your eyes — the moment the audit ritual loses "
                "its logical force. A collapsible panel contains the full proof of the "
                "separation theorem and of its sharpness."
            ),
            "html": read(A / "widget_certificate_lab.html"),
        },
        {
            "title": "The Splitting-Type Channel Explorer — Change the Generator and "
                     "Watch the Record Refuse to Move",
            "description": (
                "An explorer for the arithmetic channel whose numbers are being audited. "
                "Slide the order n to see the residues tiled and coloured by their "
                "splitting type n/gcd(n,a), with the live type entropy, the live pair "
                "capacity, the type histogram, and the gcd classes that double as orbits "
                "of the relabelling action. A stratum banner classifies the order on the "
                "spot: dyadic and certifiable with its closed form displayed, "
                "constructible and provably irrational, or outside the dichotomy. The "
                "second slider performs a change of generator — multiplication of every "
                "residue by a unit — permuting the tiles while every recorded number "
                "stays pinned to the last decimal, which is invariance made visible. A "
                "collapsible panel gives the orbit computation proving that a readout is "
                "generator-independent precisely when it factors through the splitting "
                "type."
            ),
            "html": read(A / "widget_channel_explorer.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_jacobsthal": read(A / "demo_jacobsthal.py"),
        "algo_certificate": read(A / "algo_certificate.py"),
        "algo_channel": read(A / "algo_channel.py"),
        "algo_closed_form": read(A / "algo_closed_form.py"),
        "algo_stratum": read(A / "algo_stratum.py"),
        "algo_enclosure": read(A / "algo_enclosure.py"),
        "viz_farey": read(A / "viz_farey.py"),
        "viz_tower": read(A / "viz_tower.py"),
        "viz_strata": read(A / "viz_strata.py"),
    },
    "lean_files": lean_files,
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)
print("wrote PACKAGE.json",
      (ROOT / "PACKAGE.json").stat().st_size, "bytes")


"""Exact (rational, not floating-point) verification of the two-adic laws.

On the orders n = 2^k every cell count in the channel is a power of two, so
every probability is dyadic and each entropy term -p log2 p is an exact rational:
if p = c/t with c = 2^i and t = 2^j then -p log2 p = (c/t)(j - i).  Summing with
exact fraction arithmetic therefore evaluates H_T(2^k) and I_pair(2^k) as exact
rationals, with no rounding anywhere, and lets us compare them to the closed
forms as an equality of fractions rather than as an agreement of digits.

This is the strongest form of the audit for this family: not "the printed digits
match" but "the enumerated rational equals the predicted rational".

Verifies:
    H_T(2^k)    = (2^k - 1) / 2^{k-1}          for 1 <= k <= 7
    I_pair(2^k) = J_k / 4^{k-1},  J_k = (4^k-1)/3   for 1 <= k <= 6
and exhibits the Jacobsthal recursion J_{k+1} = 4 J_k + 1 in the numerators.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from math import gcd
from typing import Dict, List, Tuple


def exact_log2(m: int) -> int:
    """log2 of a power of two, as an integer; raises if m is not a power of two."""
    if m <= 0 or m & (m - 1):
        raise ValueError(f"{m} is not a power of two")
    return m.bit_length() - 1


def exact_entropy(counts: List[int]) -> Fraction:
    """Exact Shannon entropy of a distribution whose counts and total are all
    powers of two."""
    total: int = sum(counts)
    j: int = exact_log2(total)
    h: Fraction = Fraction(0)
    for c in counts:
        if c == 0:
            continue
        h += Fraction(c, total) * (j - exact_log2(c))
    return h


def splitting_type(n: int, a: int) -> int:
    return n // gcd(n, a)


def exact_type_entropy(k: int) -> Fraction:
    n: int = 2**k
    hist: Dict[int, int] = dict(Counter(splitting_type(n, a) for a in range(n)))
    return exact_entropy(list(hist.values()))


def exact_pair_capacity(k: int) -> Fraction:
    n: int = 2**k
    joint: Counter = Counter()
    key: Counter = Counter()
    norm: Counter = Counter()
    for x in range(n):
        tx = splitting_type(n, x)
        for y in range(n):
            ty = splitting_type(n, y)
            kk: Tuple[int, int] = (tx, ty) if tx <= ty else (ty, tx)
            c = (x + y) % n
            joint[(kk, c)] += 1
            key[kk] += 1
            norm[c] += 1
    return (
        exact_entropy(list(key.values()))
        + exact_entropy(list(norm.values()))
        - exact_entropy(list(joint.values()))
    )


def jacobsthal(k: int) -> int:
    return (4**k - 1) // 3


def main() -> None:
    print("exact verification of the two-adic entropy law "
          "H_T(2^k) = (2^k - 1)/2^(k-1)\n")
    print(f"{'k':>3} {'enumerated (exact)':>20} {'closed form':>14} {'equal?':>8}")
    for k in range(1, 8):
        enum = exact_type_entropy(k)
        law = Fraction(2**k - 1, 2 ** (k - 1))
        print(f"{k:>3} {str(enum):>20} {str(law):>14} {str(enum == law):>8}")

    print("\nexact verification of the capacity law "
          "I_pair(2^k) = J_k/4^(k-1), J_k the Jacobsthal numbers\n")
    print(f"{'k':>3} {'enumerated (exact)':>22} {'closed form':>22} "
          f"{'J_k':>8} {'equal?':>8}")
    for k in range(1, 7):
        enum = exact_pair_capacity(k)
        law = Fraction(jacobsthal(k), 4 ** (k - 1))
        print(f"{k:>3} {str(enum):>22} {str(law):>22} {jacobsthal(k):>8} "
              f"{str(enum == law):>8}")

    print("\nJacobsthal recursion in the numerators:")
    for k in range(1, 8):
        print(f"  J_{k+1} = 4*J_{k} + 1 = 4*{jacobsthal(k)} + 1 = "
              f"{4*jacobsthal(k)+1}   (and J_{k+1} = {jacobsthal(k+1)}): "
              f"{4*jacobsthal(k)+1 == jacobsthal(k+1)}")

    print("\nboth families increase strictly to their ceilings 2 and 4/3, "
          "never attaining them.")


if __name__ == "__main__":
    main()


"""Visualisation: the Farey scaffold and the four-decimal certificate.

Draws the rationals of denominator at most Q in a window around a recorded
value, together with the tolerance band of width 2e-4 around it.  The picture
makes the separation theorem visible: as long as the scaffold is coarser than
the band, at most one scaffold point can sit inside the band, so a re-run that
lands in the band *must* have landed on the recorded value.  Increasing Q past
the Farey threshold lets two points share the band and the certificate dies.

Produces 'farey_certificate.png'.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Tuple

import matplotlib.pyplot as plt


def farey_points(q_max: int, lo: float, hi: float) -> List[Tuple[Fraction, int]]:
    """All fractions a/q in [lo, hi] with 1 <= q <= q_max, tagged by denominator."""
    pts: List[Tuple[Fraction, int]] = []
    for q in range(1, q_max + 1):
        a_lo: int = int(lo * q) - 1
        a_hi: int = int(hi * q) + 1
        for a in range(a_lo, a_hi + 1):
            f = Fraction(a, q)
            if lo <= float(f) <= hi and f.denominator == q:
                pts.append((f, q))
    return pts


def main() -> None:
    recorded = Fraction(21, 16)          # I_pair(8) = 1.3125
    tol: float = 1e-4
    half_window: float = 8e-4
    lo: float = float(recorded) - half_window
    hi: float = float(recorded) + half_window

    fig, axes = plt.subplots(3, 1, figsize=(11, 7), sharex=True)
    for ax, q_max, title in zip(
        axes,
        (16, 70, 400),
        (
            "denominators <= 16 : scaffold far coarser than the band",
            "denominators <= 70 : certificate still valid (1/70^2 > 1e-4)",
            "denominators <= 400 : band now holds many impostors",
        ),
    ):
        pts = farey_points(q_max, lo, hi)
        xs = [float(f) for f, _ in pts]
        ys = [q for _, q in pts]
        ax.axvspan(
            float(recorded) - tol,
            float(recorded) + tol,
            color="#ffd9b3",
            label="four-decimal tolerance band",
        )
        ax.scatter(xs, ys, s=14, color="#2b6cb0", label=f"fractions, q <= {q_max}")
        ax.axvline(float(recorded), color="#c53030", lw=1.6,
                   label="recorded value 21/16")
        inside = sum(1 for x in xs if abs(x - float(recorded)) < tol)
        ax.set_ylabel("denominator q")
        ax.set_title(f"{title}   [points inside band: {inside}]", fontsize=10)
        ax.set_yscale("log")
        ax.grid(alpha=0.25)
    axes[0].legend(loc="upper right", fontsize=8)
    axes[-1].set_xlabel("value")
    fig.suptitle(
        "Why four decimals certify: granularity of the Farey scaffold", fontsize=13
    )
    fig.tight_layout()
    fig.savefig("farey_certificate.png", dpi=150)
    print("wrote farey_certificate.png")


if __name__ == "__main__":
    main()


"""Visualisation: the certifiable / non-certifiable strata of the record.

For every order n up to a bound, the type entropy H_T(n) is plotted and coloured
by stratum:

  * blue   -- n is a power of two: H_T(n) = 2 - 2^{1-k} is dyadic, so a rounded
              record certifies it exactly;
  * red    -- n is constructible (all divisors have power-of-two totient) but not
              a power of two: H_T(n) = log2(n) - rational is irrational and no
              record of any precision can equal it;
  * grey   -- outside the reach of the dichotomy proved here.

The Fermat-prime orders 3, 5, 15, 17, 51, 85, 255 are annotated: the boundary
between the two certifiable regimes is the classical straightedge-and-compass
condition refined by "is n a power of two?".

Produces 'entropy_strata.png'.
"""

from __future__ import annotations

from math import log2
from typing import List, Tuple

import matplotlib.pyplot as plt


def euler_phi(m: int) -> int:
    result: int = m
    x: int = m
    p: int = 2
    while p * p <= x:
        if x % p == 0:
            while x % p == 0:
                x //= p
            result -= result // p
        p += 1
    if x > 1:
        result -= result // x
    return result


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def type_entropy(n: int) -> float:
    return log2(n) - sum(
        euler_phi(d) * log2(euler_phi(d)) for d in divisors(n)
    ) / n


def is_two_power(n: int) -> bool:
    return n > 0 and n & (n - 1) == 0


def is_constructible(n: int) -> bool:
    return all(is_two_power(euler_phi(d)) for d in divisors(n))


def main() -> None:
    n_max: int = 130
    groups: dict = {"dyadic (certifiable)": ([], [], "#2b6cb0"),
                    "constructible, irrational": ([], [], "#c53030"),
                    "outside the dichotomy": ([], [], "#a0aec0")}
    for n in range(1, n_max + 1):
        h = type_entropy(n)
        if is_two_power(n):
            key = "dyadic (certifiable)"
        elif is_constructible(n):
            key = "constructible, irrational"
        else:
            key = "outside the dichotomy"
        groups[key][0].append(n)
        groups[key][1].append(h)

    fig, ax = plt.subplots(figsize=(12, 5.5))
    for label, (xs, ys, colour) in groups.items():
        ax.scatter(xs, ys, s=26, color=colour, label=label,
                   alpha=0.9 if colour != "#a0aec0" else 0.45)
    for n in (3, 5, 15, 17, 51, 85):
        if n <= n_max:
            ax.annotate(str(n), (n, type_entropy(n)), textcoords="offset points",
                        xytext=(0, 7), fontsize=8, color="#c53030", ha="center")
    for k in range(1, 8):
        n = 2**k
        if n <= n_max:
            ax.annotate(f"$2^{k}$", (n, type_entropy(n)),
                        textcoords="offset points", xytext=(0, -14), fontsize=8,
                        color="#2b6cb0", ha="center")
    ax.axhline(2.0, ls="--", color="#2b6cb0", alpha=0.5)
    ax.text(n_max, 2.02, "two-bit ceiling of the dyadic tower", fontsize=8,
            ha="right", color="#2b6cb0")
    ax.set_xlabel("order n")
    ax.set_ylabel(r"type entropy $H_T(n)$  (bits)")
    ax.set_title("Which recorded entropies can a rounded record certify?")
    ax.grid(alpha=0.25)
    ax.legend(fontsize=9, loc="upper left")
    fig.tight_layout()
    fig.savefig("entropy_strata.png", dpi=150)
    print("wrote entropy_strata.png")


if __name__ == "__main__":
    main()


"""Visualisation: the two-adic tower, its ceilings, and its row gaps.

Left panel  : enumerated type entropy H_T(2^k) against the closed form
              2 - 2^{1-k}, with the two-bit ceiling; and the enumerated pair
              capacity I_pair(2^k) against (4/3)(1 - 4^{-k}) with its 4/3
              ceiling.
Right panel : the inter-row gap H_T(2^k) - H_T(2^{k-1}) on a log scale against
              the four-decimal tolerance, showing that rows stay resolvable up
              to k = 13 and merge below the tolerance thereafter.

Produces 'two_adic_tower.png'.
"""

from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Dict, List

import matplotlib.pyplot as plt


def splitting_type(n: int, a: int) -> int:
    return n // gcd(n, a)


def entropy(counts: List[int]) -> float:
    total: int = sum(counts)
    return sum(-(c / total) * log2(c / total) for c in counts if c > 0)


def type_entropy(n: int) -> float:
    hist: Dict[int, int] = dict(Counter(splitting_type(n, a) for a in range(n)))
    return entropy(list(hist.values()))


def pair_capacity(n: int) -> float:
    joint: Counter = Counter()
    key: Counter = Counter()
    norm: Counter = Counter()
    for x in range(n):
        for y in range(n):
            k = tuple(sorted((splitting_type(n, x), splitting_type(n, y))))
            c = (x + y) % n
            joint[(k, c)] += 1
            key[k] += 1
            norm[c] += 1
    return (
        entropy(list(key.values()))
        + entropy(list(norm.values()))
        - entropy(list(joint.values()))
    )


def main() -> None:
    ks_enum: List[int] = list(range(1, 8))
    ks_law: List[int] = list(range(1, 17))

    ht_enum = [type_entropy(2**k) for k in ks_enum]
    ip_enum = [pair_capacity(2**k) for k in ks_enum]
    ht_law = [2 - 2 ** (1 - k) for k in ks_law]
    ip_law = [(4 / 3) * (1 - 4.0**-k) for k in ks_law]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ks_law, ht_law, "-", color="#2b6cb0", label=r"law $2-2^{1-k}$")
    ax1.scatter(ks_enum, ht_enum, s=45, facecolors="none", edgecolors="#2b6cb0",
                label="enumerated $H_T(2^k)$")
    ax1.axhline(2.0, ls="--", color="#2b6cb0", alpha=0.5, label="two-bit ceiling")
    ax1.plot(ks_law, ip_law, "-", color="#c53030",
             label=r"law $\frac{4}{3}(1-4^{-k})$")
    ax1.scatter(ks_enum, ip_enum, s=45, facecolors="none", edgecolors="#c53030",
                label=r"enumerated $I_{pair}(2^k)$")
    ax1.axhline(4 / 3, ls="--", color="#c53030", alpha=0.5, label="4/3 ceiling")
    ax1.set_xlabel("k")
    ax1.set_ylabel("bits")
    ax1.set_title("Four recorded rows are the start of two laws")
    ax1.grid(alpha=0.25)
    ax1.legend(fontsize=8, loc="lower right")

    gaps = [ht_law[k] - ht_law[k - 1] for k in range(1, len(ks_law))]
    ax2.semilogy(ks_law[1:], gaps, "o-", color="#2f855a", label="row gap")
    ax2.axhline(1e-4, ls="--", color="#c53030", label="four-decimal tolerance")
    ax2.axvline(13, ls=":", color="#4a5568", label="k = 13 (last certified row)")
    ax2.set_xlabel("k")
    ax2.set_ylabel(r"$H_T(2^k)-H_T(2^{k-1})$")
    ax2.set_title("Sparse ladders certify far beyond denominator bounds")
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(fontsize=8)

    fig.tight_layout()
    fig.savefig("two_adic_tower.png", dpi=150)
    print("wrote two_adic_tower.png")


if __name__ == "__main__":
    main()


"""
Reproducibility as a theorem: certifying recorded numbers of the cyclic
splitting-type channel.

This self-contained script demonstrates, numerically, the results of the paper
"When Does a Rounded Record Certify an Exact Value?".

The objects
-----------
Fix an integer n >= 1 and regard Z/n as the Galois group of a cyclic extension.
The *splitting type* of a residue a is

        T(a) = n / gcd(n, a),

the order of a in Z/n (equivalently, the residue degree of a prime whose
Frobenius is a).  Two derived observables are recorded by the pipeline:

  * the type entropy      H_T(n)  = Shannon entropy (in bits) of T(a) for
                                    a uniform in Z/n;
  * the pair capacity     I_pair(n) = mutual information I(K ; N) where, for
                                    (x, y) uniform in (Z/n)^2,
                                    K = { T(x), T(y) } (unordered pair) and
                                    N = x + y mod n (the "norm class").

The theorems demonstrated here
------------------------------
  1. Farey separation: distinct rationals with denominators <= Q differ by more
     than 1/Q^2; hence four-decimal agreement certifies exact equality when
     Q <= 70, and this threshold is sharp (1/100 vs 1/101).
  2. The two-adic entropy law  H_T(2^k) = 2 - 2^{1-k}, its strict monotonicity,
     its two-bit ceiling, and the row gap 1/2^j.
  3. The two-adic capacity law I_pair(2^k) = (4/3)(1 - 4^{-k}), whose numerators
     are the Jacobsthal numbers (4^k - 1)/3.
  4. The irrational stratum: I_pair(6) = log2(3) - 1/9 and H_T(n) for
     constructible non-two-power n are irrational, so no decimal record can ever
     equal them; what the record pins down is an enclosure.
  5. Generator invariance: multiplying every residue by a unit u of Z/n leaves
     every recorded number unchanged, and the orbits of the unit action are
     exactly the gcd classes, i.e. the fibres of T.

Run with:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from math import gcd, log2
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The channel
# ----------------------------------------------------------------------------


def splitting_type(n: int, a: int) -> int:
    """T(a) = n / gcd(n, a), the order of the residue a in Z/n."""
    return n // gcd(n, a)


def shannon_entropy(counts: Iterable[int]) -> float:
    """Entropy in bits of the empirical distribution given by integer counts."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    return sum(-(c / total) * log2(c / total) for c in cs)


def type_histogram(n: int) -> Dict[int, int]:
    """Occupation numbers of the splitting type over Z/n; bin d has phi(d) points."""
    return dict(Counter(splitting_type(n, a) for a in range(n)))


def type_entropy(n: int) -> float:
    """H_T(n): entropy in bits of the splitting type of a uniform residue."""
    return shannon_entropy(type_histogram(n).values())


def pair_capacity(n: int) -> float:
    """I_pair(n) = I(K ; N), K the unordered type pair, N = x + y mod n."""
    joint: Counter = Counter()
    key: Counter = Counter()
    norm: Counter = Counter()
    for x in range(n):
        for y in range(n):
            k: Tuple[int, int] = tuple(
                sorted((splitting_type(n, x), splitting_type(n, y)))
            )
            c: int = (x + y) % n
            joint[(k, c)] += 1
            key[k] += 1
            norm[c] += 1
    return (
        shannon_entropy(key.values())
        + shannon_entropy(norm.values())
        - shannon_entropy(joint.values())
    )


# ----------------------------------------------------------------------------
# 2. Farey separation and the four-decimal certificate
# ----------------------------------------------------------------------------


def farey_separation(a: int, q: int, b: int, r: int) -> Fraction:
    """|a/q - b/r|, exactly.  Equals |a r - b q| / (q r), so it is 0 or >= 1/(q r)."""
    return abs(Fraction(a, q) - Fraction(b, r))


def certifies_equality(a: int, q: int, b: int, r: int, precision: float) -> bool:
    """True when agreement to within `precision` forces a/q == b/r, i.e. when
    precision <= 1/(q r).  This is the exact content of the separation theorem."""
    return precision <= 1.0 / (q * r)


def max_certifiable_denominator(precision: float) -> int:
    """Largest Q with 1/Q^2 > precision: the Farey resolution at that precision."""
    q: int = 1
    while 1.0 / ((q + 1) ** 2) > precision:
        q += 1
    return q


# ----------------------------------------------------------------------------
# 3. Closed forms
# ----------------------------------------------------------------------------


def two_adic_entropy_law(k: int) -> Fraction:
    """H_T(2^k) = 2 - 2^{1-k} = (2^k - 1) / 2^{k-1}."""
    return Fraction(2**k - 1, 2 ** (k - 1))


def two_adic_capacity_law(k: int) -> Fraction:
    """I_pair(2^k) = (4/3)(1 - 4^{-k}) = J_k / 4^{k-1}, J_k = (4^k - 1)/3 Jacobsthal."""
    return Fraction(4, 3) * (1 - Fraction(1, 4**k))


def jacobsthal(k: int) -> int:
    """J_k = (4^k - 1)/3: 1, 5, 21, 85, 341, ..."""
    return (4**k - 1) // 3


def logb2_three_enclosure() -> Tuple[Fraction, Fraction]:
    """Enclosure 1054/665 < log2 3 < 485/306 certified by 2^1054 < 3^665 and
    3^306 < 2^485 (checked here as exact integer inequalities)."""
    assert 2**1054 < 3**665
    assert 3**306 < 2**485
    return Fraction(1054, 665), Fraction(485, 306)


def euler_phi(m: int) -> int:
    """Euler's totient, by trial division."""
    result: int = m
    p: int = 2
    x: int = m
    while p * p <= x:
        if x % p == 0:
            while x % p == 0:
                x //= p
            result -= result // p
        p += 1
    if x > 1:
        result -= result // x
    return result


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def type_entropy_divisor_formula(n: int) -> float:
    """H_T(n) = log2 n - (1/n) * sum_{d | n} phi(d) log2 phi(d)."""
    return log2(n) - sum(
        euler_phi(d) * log2(euler_phi(d)) for d in divisors(n)
    ) / n


def is_two_power(n: int) -> bool:
    return n > 0 and n & (n - 1) == 0


def is_constructible_order(n: int) -> bool:
    """True iff every divisor d of n has phi(d) a power of two: by Gauss-Wantzel,
    n = 2^a times a product of distinct Fermat primes."""
    return all(is_two_power(euler_phi(d)) for d in divisors(n))


# ----------------------------------------------------------------------------
# 4. Generator invariance
# ----------------------------------------------------------------------------


def units(n: int) -> List[int]:
    return [u for u in range(1, n) if gcd(u, n) == 1]


def relabelled_type_histogram(n: int, u: int) -> Dict[int, int]:
    """Histogram of T after the change of generator x -> u x mod n."""
    return dict(Counter(splitting_type(n, (u * a) % n) for a in range(n)))


def gcd_classes(n: int) -> Dict[int, List[int]]:
    return {
        g: [a for a in range(n) if gcd(n, a) == g]
        for g in sorted({gcd(n, a) for a in range(n)})
    }


def unit_orbits(n: int) -> List[List[int]]:
    seen: set = set()
    orbits: List[List[int]] = []
    for a in range(n):
        if a in seen:
            continue
        orbit: List[int] = sorted({(u * a) % n for u in units(n)} | {a})
        seen |= set(orbit)
        orbits.append(orbit)
    return orbits


# ----------------------------------------------------------------------------
# 5. Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_separation() -> None:
    banner("1. Farey separation: four decimals certify equality up to Q = 70")
    print(f"largest denominator bound Q with 1/Q^2 > 1e-4 : Q = "
          f"{max_certifiable_denominator(1e-4)}")
    print(f"  the stated working bound is Q = 70:  70 * 70 = {70*70} < 10000,")
    print(f"  so 1/70^2 > 1e-4 with room to spare  ->  certificate holds")
    print(f" at the other end 101 * 100 = {101*100} > 10000: the bound fails there")
    gap: Fraction = farey_separation(1, 100, 1, 101)
    print(f"\ncounterexample beyond the threshold: |1/100 - 1/101| = {gap} "
          f"= {float(gap):.3e} < 1e-4, yet 1/100 != 1/101")
    print("so a four-decimal record cannot separate denominators 100 and 101.")
    print("\nworked certificates (recorded value vs a hypothetical re-run value):")
    rows: Sequence[Tuple[str, Tuple[int, int], Tuple[int, int]]] = (
        ("I_pair(4)  = 5/4",   (5, 4),   (12500, 10000)),
        ("I_pair(8)  = 21/16", (21, 16), (13125, 10000)),
        ("I_pair(16) = 85/64", (85, 64), (1328125, 1000000)),
        ("H_T(4)     = 3/2",   (3, 2),   (15000, 10000)),
    )
    for label, (a, q), (b, r) in rows:
        exact: Fraction = Fraction(a, q)
        rerun: Fraction = Fraction(b, r)
        print(f"  {label:22s} re-run {float(rerun):.6f}  "
              f"|diff| = {float(abs(exact - rerun)):.2e}  "
              f"certified: {exact == rerun}")


def demo_two_adic_laws() -> None:
    banner("2. The two-adic tower: four recorded rows are a law, not a table")
    print(f"{'k':>2} {'n=2^k':>6} {'H_T (enumerated)':>18} {'2 - 2^(1-k)':>14} "
          f"{'I_pair (enum.)':>16} {'(4/3)(1-4^-k)':>16} {'Jacobsthal':>11}")
    for k in range(1, 8):
        n: int = 2**k
        ht: float = type_entropy(n)
        ip: float = pair_capacity(n)
        print(f"{k:>2} {n:>6} {ht:>18.10f} {float(two_adic_entropy_law(k)):>14.10f} "
              f"{ip:>16.10f} {float(two_adic_capacity_law(k)):>16.10f} "
              f"{jacobsthal(k):>11}")
    print("\nstrict monotonicity and the two-bit ceiling:")
    for k in range(1, 7):
        print(f"  H_T(2^{k}) = {float(two_adic_entropy_law(k)):.6f} < "
              f"H_T(2^{k+1}) = {float(two_adic_entropy_law(k+1)):.6f} < 2   "
              f"row gap >= 1/2^{k} = {2.0**-k:.6f}")
    print("\ncapacity ceiling: I_pair(2^k) -> 4/3 = 1.3333333333 from below")


def demo_irrational_stratum() -> None:
    banner("3. The irrational stratum: records enclose, they never certify")
    lo, hi = logb2_three_enclosure()
    print(f"convergent bounds verified as integer inequalities:")
    print(f"  2^1054 < 3^665   gives log2 3 > 1054/665 = {float(lo):.10f}")
    print(f"  3^306  < 2^485   gives log2 3 < 485/306  = {float(hi):.10f}")
    print(f"  hence 1.58496 < log2 3 < 1.58497   (true value {log2(3):.10f})")
    exact_low: float = float(lo) - 1 / 9
    exact_high: float = float(hi) - 1 / 9
    print(f"\nI_pair(6) = log2 3 - 1/9 lies in "
          f"({exact_low:.8f}, {exact_high:.8f})")
    print(f"  enumerated I_pair(6) = {pair_capacity(6):.10f}")
    print(f"  recorded four-decimal value 1.4738, |value - record| = "
          f"{abs(pair_capacity(6) - 1.4738):.2e} < 1e-4")
    print("  but the value is irrational, so no decimal record equals it.")
    print("\nrationality dichotomy on constructible orders "
          "(all phi(d) powers of two):")
    print(f"{'n':>4} {'constructible':>14} {'2-power':>9} {'H_T(n)':>14} {'stratum':>14}")
    for n in (2, 3, 4, 5, 8, 15, 16, 17, 32, 51):
        c: bool = is_constructible_order(n)
        t: bool = is_two_power(n)
        stratum: str = (
            "rational" if t else ("irrational" if c else "undecided here")
        )
        print(f"{n:>4} {str(c):>14} {str(t):>9} "
              f"{type_entropy_divisor_formula(n):>14.10f} {stratum:>14}")


def demo_generator_invariance() -> None:
    banner("4. Generator invariance: the record is coordinate-free")
    for n in (12, 15):
        print(f"\nn = {n}:  units mod n = {units(n)}")
        base: Dict[int, int] = type_histogram(n)
        print(f"  type histogram            {dict(sorted(base.items()))}")
        print(f"  H_T                       {type_entropy(n):.10f}")
        for u in units(n):
            hu: Dict[int, int] = relabelled_type_histogram(n, u)
            assert hu == base, "histogram changed under a change of generator"
        print(f"  all {len(units(n))} changes of generator reproduce the "
              f"histogram exactly")
        classes = gcd_classes(n)
        orbits = unit_orbits(n)
        print(f"  gcd classes               "
              f"{[sorted(v) for v in classes.values()]}")
        print(f"  unit-action orbits        {orbits}")
        assert sorted(orbits) == sorted(sorted(v) for v in classes.values())
        print("  orbits == gcd classes == fibres of T  (universality of the type)")


def demo_invariant_readouts() -> None:
    banner("5. Every invariant readout factors through the splitting type")
    n: int = 12
    readouts = {
        "T itself                 ": lambda a: splitting_type(n, a),
        "gcd(n, a)                ": lambda a: gcd(n, a),
        "1 if T(a) = n else 0     ": lambda a: 1 if splitting_type(n, a) == n else 0,
        "parity of a              ": lambda a: a % 2,
        "a itself                 ": lambda a: a,
        "a mod 5                  ": lambda a: a % 5,
    }
    for name, f in readouts.items():
        invariant: bool = all(
            f((u * a) % n) == f(a) for u in units(n) for a in range(n)
        )
        factors: bool = all(
            f(a) == f(b)
            for a in range(n)
            for b in range(n)
            if splitting_type(n, a) == splitting_type(n, b)
        )
        print(f"  {name} invariant: {str(invariant):>5}   "
              f"factors through T: {str(factors):>5}")
    print("\n  invariance and factorisation agree on every row: the two properties "
          "are equivalent.")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_separation()
    demo_two_adic_laws()
    demo_irrational_stratum()
    demo_generator_invariance()
    demo_invariant_readouts()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
