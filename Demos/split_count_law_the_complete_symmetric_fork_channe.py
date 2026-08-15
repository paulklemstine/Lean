#!/usr/bin/env python3
"""
The Split-Count Law — numerical demonstration.
==============================================

A semiprime N = p*q is a "character-pinned fork": fix a modulus f and a
surjective homomorphism chi from the units mod f onto an abelian group of order
n, call a prime "split" when chi(p) = 1, and observe only chi(N) = chi(p)chi(q).
The complete symmetric statistic of the fork is the split-count

    s = [chi(p) = 1] + [chi(q) = 1]  in  {0, 1, 2},   s ~ Bin(2, 1/n),

and the information the residue of N carries about it is the order-universal

    Is(n) = H(Bin(2,1/n))
            - (1/n) H((n-1)/n, 0, 1/n)
            - ((n-1)/n) H((n-2)/n, 2/n, 0)     bits.

This script demonstrates, with no dependencies beyond the standard library:

  1. the closed form and its exact values (Is(2) = 1, Is(3) = log2(3) - 10/9);
  2. the binomial marginal of the split-count;
  3. the Boolean faces OR / AND / XOR, the universal "AND beats OR", and the
     failure of the naive hierarchy from n = 8;
  4. the one-bit cap, attained only at n = 2;
  5. the asymptotic law Is(n) = (log n + 2 - 1/(2n) + O(1/n^2)) / (n^2 log 2);
  6. higher arity: binomial marginals, the exact chi^2 divergence (n-1)^(1-r),
     the no-amplification bound and the arity constant r;
  7. an arithmetic experiment on real semiprimes, matching the theory;
  8. the which-factor wall: exactly zero bits about *which* factor splits.

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from math import comb, log, log2
from typing import Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Finite information theory
# ---------------------------------------------------------------------------


def entropy_bits(weights: Sequence[float]) -> float:
    """Shannon entropy (bits) of a nonnegative weight vector summing to one."""
    return -sum(w * log2(w) for w in weights if w > 0.0)


def mutual_information_bits(table: Sequence[Sequence[float]]) -> float:
    """Mutual information (bits) of a normalised joint table."""
    rows = [sum(row) for row in table]
    cols = [sum(table[a][b] for a in range(len(table))) for b in range(len(table[0]))]
    total = 0.0
    for a, row in enumerate(table):
        for b, cell in enumerate(row):
            if cell > 0.0 and rows[a] > 0.0 and cols[b] > 0.0:
                total += cell * log2(cell / (rows[a] * cols[b]))
    return total


def chi_square_divergence(table: Sequence[Sequence[float]]) -> float:
    """chi^2 divergence between a joint table and the product of its marginals."""
    rows = [sum(row) for row in table]
    cols = [sum(table[a][b] for a in range(len(table))) for b in range(len(table[0]))]
    total = 0.0
    for a, row in enumerate(table):
        for b, cell in enumerate(row):
            q = rows[a] * cols[b]
            if q > 0.0:
                total += (cell - q) ** 2 / q
    return total


def pushforward(table: Sequence[Sequence[float]], g: Sequence[int], out: int
                ) -> List[List[float]]:
    """Relabel the output alphabet by the map g, merging fibres."""
    new = [[0.0] * out for _ in table]
    for a, row in enumerate(table):
        for b, cell in enumerate(row):
            new[a][g[b]] += cell
    return new


# ---------------------------------------------------------------------------
# 2. The fork table and the split-count law
# ---------------------------------------------------------------------------


def fork_table(n: float) -> List[List[float]]:
    """Joint law of (class of chi(N), split-count) for a fork of arity two.

    Row 0 is the event chi(N) = 1 (probability 1/n); row 1 its complement.
    """
    prior = [1.0 / n, (n - 1.0) / n]
    cond = [[(n - 1.0) / n, 0.0, 1.0 / n],
            [(n - 2.0) / n, 2.0 / n, 0.0]]
    return [[prior[a] * cond[a][s] for s in range(3)] for a in range(2)]


def split_count_information(n: float) -> float:
    """Is(n): the complete information (bits) carried by a fork of order n."""
    return mutual_information_bits(fork_table(n))


def split_count_closed_form(n: float) -> float:
    """The closed form H(Bin(2,1/n)) - (1/n)H(row0) - ((n-1)/n)H(row1)."""
    binom2 = [((n - 1.0) / n) ** 2, 2.0 * (n - 1.0) / n ** 2, 1.0 / n ** 2]
    row0 = [(n - 1.0) / n, 0.0, 1.0 / n]
    row1 = [(n - 2.0) / n, 2.0 / n, 0.0]
    return (entropy_bits(binom2)
            - (1.0 / n) * entropy_bits(row0)
            - ((n - 1.0) / n) * entropy_bits(row1))


OR_MAP: Tuple[int, int, int] = (0, 1, 1)
AND_MAP: Tuple[int, int, int] = (0, 0, 1)
XOR_MAP: Tuple[int, int, int] = (0, 1, 0)


def face_information(n: float, g: Sequence[int]) -> float:
    """Information carried by a Boolean projection g(s) of the split-count."""
    return mutual_information_bits(pushforward(fork_table(n), g, 2))


# ---------------------------------------------------------------------------
# 3. Higher arity
# ---------------------------------------------------------------------------


def alt_count(n: float, m: int) -> float:
    """Number of m-tuples of non-identity classes whose product is the identity."""
    return ((n - 1.0) ** m + (n - 1.0) * (-1.0) ** m) / n


def fork_table_arity(r: int, n: float) -> List[List[float]]:
    """Joint law of (class of chi(N), split-count) for a fork of arity r."""
    row0 = [comb(r, k) * alt_count(n, r - k) / n ** r for k in range(r + 1)]
    row1 = [comb(r, k) * ((n - 1.0) ** (r - k) - alt_count(n, r - k)) / n ** r
            for k in range(r + 1)]
    return [row0, row1]


def arity_information(r: int, n: float) -> float:
    """I^(r)(n): information carried by an arity-r fork of order n."""
    return mutual_information_bits(fork_table_arity(r, n))


def arity_information_exact(r: int, n: int, digits: int = 60) -> Decimal:
    """I^(r)(n) in bits, computed in high precision from the exact rational table.

    For large n the information is of size O(log n / n^r), so double precision
    loses all significant digits once n^r exceeds 10^16; the arity constant is
    therefore evaluated from exact rationals with `digits` decimal places.
    """
    getcontext().prec = digits
    cells: List[List[Fraction]] = []
    for row_index in range(2):
        row: List[Fraction] = []
        for k in range(r + 1):
            m = r - k
            zero_sum = Fraction((n - 1) ** m + (n - 1) * (-1) ** m, n)
            weight = zero_sum if row_index == 0 else Fraction((n - 1) ** m) - zero_sum
            row.append(Fraction(comb(r, k)) * weight / Fraction(n ** r))
        cells.append(row)
    rows = [sum(row) for row in cells]
    cols = [cells[0][k] + cells[1][k] for k in range(r + 1)]
    ln2 = Decimal(2).ln()
    total = Decimal(0)
    for a in range(2):
        for k in range(r + 1):
            p = cells[a][k]
            if p > 0:
                ratio = p / (rows[a] * cols[k])
                value = Decimal(ratio.numerator) / Decimal(ratio.denominator)
                weight = Decimal(p.numerator) / Decimal(p.denominator)
                total += weight * value.ln() / ln2
    return total


# ---------------------------------------------------------------------------
# 4. An arithmetic experiment on real semiprimes
# ---------------------------------------------------------------------------


def primes_up_to(bound: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (bound + 1)
    sieve[0:2] = b"\x00\x00"
    i = 2
    while i * i <= bound:
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
        i += 1
    return [i for i in range(bound + 1) if sieve[i]]


def multiplicative_order(a: int, f: int) -> int:
    """Order of a in the unit group modulo f."""
    order, value = 1, a % f
    while value != 1:
        value = (value * a) % f
        order += 1
    return order


def power_residue_character(f: int, n: int) -> Dict[int, int]:
    """A surjective character of order n on the units mod f, as a lookup table.

    If the unit group mod f is cyclic of order divisible by n, then writing each
    unit as g^e for a fixed generator g and sending g^e to (e mod n) is a
    surjective homomorphism onto Z/nZ.  A unit is "split" when its label is 0,
    i.e. when it is an n-th power residue.
    """
    units = [u for u in range(1, f) if _gcd(u, f) == 1]
    order = len(units)
    if order % n != 0:
        raise ValueError(f"no character of order {n} modulo {f}")
    generator = None
    for g in units:
        if multiplicative_order(g, f) == order:
            generator = g
            break
    if generator is None:
        raise ValueError(f"unit group mod {f} is not cyclic")
    label: Dict[int, int] = {}
    value = 1
    for exponent in range(order):
        label[value] = exponent % n
        value = (value * generator) % f
    return label


def _gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return a


def empirical_channel(f: int, n: int, bound: int, max_samples: int
                      ) -> Tuple[float, List[float], float]:
    """Measure the fork channel on actual semiprimes N = p*q below `bound`.

    Returns (empirical Is in bits, empirical split-count distribution,
    empirical which-factor information in bits).
    """
    label = power_residue_character(f, n)
    small = [p for p in primes_up_to(int(bound ** 0.5) + 1) if _gcd(p, f) == 1]
    counts = [[0, 0, 0], [0, 0, 0]]          # class of N  x  split-count
    which = [[0, 0], [0, 0]]                 # class of N  x  [first factor splits]
    samples = 0
    for i, p in enumerate(small):
        for q in small[i:]:
            if p * q > bound:
                break
            if _gcd(p * q, f) != 1:
                continue
            sp, sq = int(label[p % f] == 0), int(label[q % f] == 0)
            cls = 0 if label[(p * q) % f] == 0 else 1
            counts[cls][sp + sq] += 1
            which[cls][sp] += 1
            samples += 1
            if samples >= max_samples:
                break
        if samples >= max_samples:
            break
    table = [[c / samples for c in row] for row in counts]
    which_table = [[c / samples for c in row] for row in which]
    marginal = [sum(table[a][s] for a in range(2)) for s in range(3)]
    return mutual_information_bits(table), marginal, mutual_information_bits(which_table)


# ---------------------------------------------------------------------------
# 5. Demonstrations
# ---------------------------------------------------------------------------


def demo_closed_form() -> None:
    print("=" * 74)
    print("1. THE SPLIT-COUNT LAW: direct table vs closed form")
    print("=" * 74)
    print(f"{'n':>4} {'Is (table)':>14} {'Is (closed form)':>18} {'difference':>14}")
    for n in range(2, 13):
        a, b = split_count_information(n), split_count_closed_form(n)
        print(f"{n:>4} {a:>14.9f} {b:>18.9f} {abs(a - b):>14.2e}")
    print()
    print(f"  Is(2) = {split_count_information(2):.12f}   (exactly 1 bit)")
    print(f"  Is(3) = {split_count_information(3):.12f}   "
          f"= log2(3) - 10/9 = {log2(3) - 10 / 9:.12f}")
    print(f"  Is(8) = {split_count_information(8):.12f}   "
          f"= 117/32 + (21/32)log2 3 - (105/64)log2 7 = "
          f"{117 / 32 + 21 / 32 * log2(3) - 105 / 64 * log2(7):.12f}")
    print()


def demo_binomial_marginal() -> None:
    print("=" * 74)
    print("2. THE SPLIT-COUNT MARGINAL IS Bin(2, 1/n)")
    print("=" * 74)
    print(f"{'n':>4} {'P(s=0)':>12} {'P(s=1)':>12} {'P(s=2)':>12}   max |error|")
    for n in range(2, 8):
        table = fork_table(n)
        emp = [sum(table[a][s] for a in range(2)) for s in range(3)]
        binomial = [comb(2, k) * (1 / n) ** k * ((n - 1) / n) ** (2 - k) for k in range(3)]
        err = max(abs(e - b) for e, b in zip(emp, binomial))
        print(f"{n:>4} {emp[0]:>12.8f} {emp[1]:>12.8f} {emp[2]:>12.8f}   {err:.2e}")
    print()


def demo_faces() -> None:
    print("=" * 74)
    print("3. BOOLEAN FACES: OR, AND, XOR — and the hierarchy correction")
    print("=" * 74)
    print(f"{'n':>4} {'Is':>11} {'XOR':>11} {'AND':>11} {'OR':>11}   "
          f"{'AND>=OR':>8} {'XOR>=AND':>9}")
    for n in range(2, 13):
        i_s = split_count_information(n)
        i_x = face_information(n, XOR_MAP)
        i_a = face_information(n, AND_MAP)
        i_o = face_information(n, OR_MAP)
        print(f"{n:>4} {i_s:>11.6f} {i_x:>11.6f} {i_a:>11.6f} {i_o:>11.6f}   "
              f"{str(i_a >= i_o - 1e-12):>8} {str(i_x >= i_a - 1e-12):>9}")
    print()
    print("  AND >= OR at every order (mirror principle), equality only at n = 2.")
    print("  XOR >= AND fails from n = 8: the naive chain Is >= XOR >= AND >= OR")
    print("  is NOT universal.  At n = 8 the true order is OR < XOR < AND < Is.")
    print()


def demo_cap() -> None:
    print("=" * 74)
    print("4. THE ONE-BIT CAP, ATTAINED ONLY AT THE QUADRATIC CHARACTERS")
    print("=" * 74)
    for n in [2, 3, 4, 10, 100, 1000]:
        i_s = split_count_information(n)
        print(f"  n = {n:>5}:  Is = {i_s:.9f} bits   prior = "
              f"(1/{n}, {n - 1}/{n})  balanced: {abs(1 / n - 0.5) < 1e-12}")
    print()
    print("  A binary-input channel carries at most 1 bit, and attains it only")
    print("  with a balanced prior.  The fork's prior is (1/n, (n-1)/n), which is")
    print("  balanced iff n = 2.  Hence Is(n) = 1 <=> n = 2.")
    print()


def demo_asymptotics() -> None:
    print("=" * 74)
    print("5. THE EXACT ASYMPTOTIC LAW")
    print("=" * 74)
    print("   Is(n) = (log n + 2 - 1/(2n) + O(1/n^2)) / (n^2 log 2)")
    print()
    print(f"{'n':>7} {'n^2 Is log2 - log n':>22} {'2 - 1/(2n)':>14} "
          f"{'|error| * n^2':>15} {'bound 12':>9}")
    ln2 = Decimal(2).ln()
    for n in [3, 10, 100, 1000, 10000]:
        lhs = float(Decimal(n) ** 2 * arity_information_exact(2, n) * ln2
                    - Decimal(n).ln())
        rhs = 2 - 1 / (2 * n)
        print(f"{n:>7} {lhs:>22.9f} {rhs:>14.9f} {abs(lhs - rhs) * n ** 2:>15.6f} "
              f"{12:>9}")
    print()
    print(f"{'n':>7} {'n^2 Is / log2 n':>18}   (-> 1, sharp rate)")
    for n in [10, 100, 1000, 10000, 100000]:
        print(f"{n:>7} {n ** 2 * split_count_information(n) / log2(n):>18.9f}")
    print()
    print("  Refutations: n*Is(n) -> 0, so there is no c/n lower bound; and")
    print("  n*Is(n)/log2(n) -> 0, not 1 — the correct normalisation is n^2:")
    for n in [100, 10000, 1000000]:
        print(f"    n = {n:>8}: n*Is(n) = {n * split_count_information(n):.3e},"
              f"  n*Is(n)/log2 n = {n * split_count_information(n) / log2(n):.3e}")
    print()


def demo_arity() -> None:
    print("=" * 74)
    print("6. HIGHER ARITY: NO AMPLIFICATION")
    print("=" * 74)
    print(f"{'r':>3} {'n=2':>10} {'n=3':>10} {'n=4':>10} {'n=5':>10}"
          f"   {'chi2(n=3)':>11} {'exact':>11} {'bound(n=3)':>11}")
    for r in range(2, 8):
        vals = [arity_information(r, n) for n in (2, 3, 4, 5)]
        chi2 = chi_square_divergence(fork_table_arity(r, 3))
        exact = (3 - 1) ** (1 - r)
        bound = exact / log(2)
        print(f"{r:>3} {vals[0]:>10.6f} {vals[1]:>10.6f} {vals[2]:>10.6f} "
              f"{vals[3]:>10.6f}   {chi2:>11.6f} {exact:>11.6f} {bound:>11.6f}")
    print()
    print("  I^(r)(2) = 1 for every arity (parity never degrades), while for")
    print("  n >= 3 the information decays geometrically: I^(r)(n) <= (n-1)^(1-r)/log 2.")
    print()
    print("  The arity constant:  n^r I^(r)(n) log 2 - log n  ->  r")
    print("  (evaluated in high precision from the exact rational table)")
    print(f"{'r':>3} {'n=100':>14} {'n=1000':>14} {'n=10000':>14} {'limit':>7}")
    ln2 = Decimal(2).ln()
    for r in (2, 3, 4):
        row = [Decimal(n) ** r * arity_information_exact(r, n) * ln2
               - Decimal(n).ln() for n in (100, 1000, 10000)]
        print(f"{r:>3} {float(row[0]):>14.6f} {float(row[1]):>14.6f} "
              f"{float(row[2]):>14.6f} {r:>7}")
    print()


def demo_zero_sum_counts() -> None:
    print("=" * 74)
    print("7. THE ARITHMETIC ANCHOR: zero-sum tuples of non-identity classes")
    print("=" * 74)
    print("   #{m-tuples of nonzero classes mod n summing to 0} "
          "= ((n-1)^m + (n-1)(-1)^m)/n")
    print(f"{'n':>4} {'m':>3} {'brute force':>13} {'formula':>11}"
          f"   {'nonzero target':>15} {'formula':>11}")
    for n in (4, 5, 6):
        for m in (2, 3, 4):
            brute_zero = _count_tuples(n, m, 0)
            brute_one = _count_tuples(n, m, 1)
            f_zero = ((n - 1) ** m + (n - 1) * (-1) ** m) / n
            f_one = ((n - 1) ** m - (-1) ** m) / n
            print(f"{n:>4} {m:>3} {brute_zero:>13} {f_zero:>11.1f}"
                  f"   {brute_one:>15} {f_one:>11.1f}")
    print()
    print("  The count for a nonzero target is the SAME for every target, even")
    print("  when n is composite: a consequence of the recursion A' = (n-1)B,")
    print("  B' = A + (n-2)B, not of a symmetry of the group.")
    print()


def _count_tuples(n: int, m: int, target: int) -> int:
    """Brute-force count of m-tuples of nonzero classes mod n with a given sum."""
    counts = [0] * n
    counts[0] = 1
    for _ in range(m):
        new = [0] * n
        for value, c in enumerate(counts):
            if c:
                for y in range(1, n):
                    new[(value + y) % n] += c
        counts = new
    return counts[target % n]


def demo_arithmetic() -> None:
    print("=" * 74)
    print("8. REAL SEMIPRIMES: the theory measured in the wild")
    print("=" * 74)
    experiments: Iterable[Tuple[int, int]] = [(5, 2), (7, 3), (9, 3), (11, 5), (13, 3)]
    bound, max_samples = 2 ** 20, 10 ** 9
    print(f"{'modulus f':>10} {'order n':>8} {'measured Is':>13} {'predicted':>11}"
          f"   {'which-factor':>13}")
    for f, n in experiments:
        try:
            measured, marginal, wall = empirical_channel(f, n, bound, max_samples)
        except ValueError as exc:                      # pragma: no cover
            print(f"{f:>10} {n:>8}   skipped: {exc}")
            continue
        print(f"{f:>10} {n:>8} {measured:>13.6f} "
              f"{split_count_information(n):>11.6f}   {wall:>13.6f}")
        binomial = [comb(2, k) * (1 / n) ** k * ((n - 1) / n) ** (2 - k) for k in range(3)]
        print(f"{'':>10} split-count distribution "
              f"{[round(x, 4) for x in marginal]} vs Bin(2,1/{n}) "
              f"{[round(x, 4) for x in binomial]}")
    print()
    print("  The which-factor column is the information the residue of N carries")
    print("  about whether the FIRST factor splits.  It is zero — exactly, in")
    print("  theory, and to sampling noise in practice.")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE SPLIT-COUNT LAW — the complete content of a character-pinned fork")
    print("#" * 74)
    print()
    demo_closed_form()
    demo_binomial_marginal()
    demo_faces()
    demo_cap()
    demo_asymptotics()
    demo_arity()
    demo_zero_sum_counts()
    demo_arithmetic()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  * The split-count s = [chi(p)=1] + [chi(q)=1] is the complete")
    print("    symmetric statistic of a fork, marginally Bin(2, 1/n).")
    print("  * Is(2) = 1 bit exactly — 3.21x the 0.3113 bits its OR projection")
    print("    reports; the OR ceiling is an artifact of the projection.")
    print("  * Is(n) <= 1 always, with equality iff n = 2.")
    print("  * AND beats OR at every order; XOR beats AND only for n <= 7.")
    print("  * Is(n) = (log n + 2 - 1/(2n) + O(1/n^2)) / (n^2 log 2).")
    print("  * More factors do not help: I^(r)(n) <= (n-1)^(1-r)/log 2.")
    print("  * The channel is symmetric in the factors and a function of")
    print("    N mod f alone — it is quantified classical reciprocity, and")
    print("    carries no factoring advantage.")
    print()


if __name__ == "__main__":
    main()
