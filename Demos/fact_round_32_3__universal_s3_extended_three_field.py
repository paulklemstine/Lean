"""
Three Fields, One Answer — numerical demonstration of the S3 type-channel law.

This script is fully self-contained (standard library only) and demonstrates,
numerically and empirically:

  1. The exact channel values of the Chebotarev model of an S3-cubic:
       I(residue ; splitting type)                = 1                    exactly
       I(residue ; unordered type pair of p*q)    = 1                    exactly
       I(residue ; "has a root mod p")            = (log2 3)/2 - 1/3
       H(splitting type)                          = 2/3 + (log2 3)/2
  2. The coupling-quotient law  I = log2 |D|  on synthetic tables with a
     D-valued balanced coupling invariant.
  3. The separation from a cyclic cubic:
       I(residue ; Frobenius)     = log2 3
       I(residue ; splitting type)= log2 3 - 2/3
  4. The algebraic backbone:
       disc(x^3 + a x + b) = -4a^3 - 27b^2   (via exact root products)
       -3 is a square mod p  <=>  p = 1 (mod 3)
  5. Empirical Chebotarev tallies for the three fields
       x^3 - 3   (disc -243, resolvent Q(sqrt -3),  observable p mod 3)
       x^3 - 2   (disc -108, resolvent Q(sqrt -3),  observable p mod 3)
       x^3 - x-1 (disc  -23, resolvent Q(sqrt -23), observable p mod 23)
     showing convergence of the empirical mutual information to 1 bit.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1.  Exact finite-table information theory
# ----------------------------------------------------------------------------

Table = Dict[Tuple[str, str], int]


def surprisal(x: float) -> float:
    """-x log2 x, with the convention sur(0) = 0."""
    if x <= 0.0:
        return 0.0
    return -x * math.log2(x)


def table_total(table: Table) -> int:
    return sum(table.values())


def marginal_a(table: Table) -> Dict[str, int]:
    out: Dict[str, int] = {}
    for (a, _b), c in table.items():
        out[a] = out.get(a, 0) + c
    return out


def marginal_b(table: Table) -> Dict[str, int]:
    out: Dict[str, int] = {}
    for (_a, b), c in table.items():
        out[b] = out.get(b, 0) + c
    return out


def entropy_of_counts(counts: Iterable[int], total: int) -> float:
    return sum(surprisal(c / total) for c in counts)


def mutual_information(table: Table) -> float:
    """I(X;Y) = H(X) + H(Y) - H(X,Y) in bits, for a nonnegative count table."""
    n = table_total(table)
    if n == 0:
        return 0.0
    h_a = entropy_of_counts(marginal_a(table).values(), n)
    h_b = entropy_of_counts(marginal_b(table).values(), n)
    h_ab = entropy_of_counts(table.values(), n)
    return h_a + h_b - h_ab


# ----------------------------------------------------------------------------
# 2.  The Chebotarev model of an S3-cubic
# ----------------------------------------------------------------------------

SPLIT_TYPES: Tuple[str, str, str] = ("S", "P", "I")   # split, 1+2, inert
TYPE_MULT: Dict[str, int] = {"S": 1, "P": 3, "I": 2}  # sizes of the S3 classes
SIGN_BIT: Dict[str, bool] = {"S": True, "P": False, "I": True}  # even Frobenius?


def residue_type_table(chi: Dict[str, bool]) -> Table:
    """Chebotarev joint table of (residue class, splitting type).

    chi maps each residue class label to the value of the resolvent character.
    Entry = multiplicity of the type when character and sign bit agree, else 0.
    """
    return {
        (a, t): (TYPE_MULT[t] if chi[a] == SIGN_BIT[t] else 0)
        for a in chi
        for t in SPLIT_TYPES
    }


def balanced_character_mod_q(q: int) -> Dict[str, bool]:
    """Quadratic-residue character of (Z/q)^*, as a dict on residue labels."""
    squares = {(x * x) % q for x in range(1, q)}
    return {str(a): (a % q) in squares for a in range(1, q) if math.gcd(a, q) == 1}


# The unordered pair channel for semiprimes n = p*q.
PAIR_KEYS: Tuple[str, ...] = ("SS", "SP", "SI", "PP", "PI", "II")


def pair_key(t: str, u: str) -> str:
    order = {"S": 0, "P": 1, "I": 2}
    first, second = (t, u) if order[t] <= order[u] else (u, t)
    return first + second


def pair_multiplicities() -> Dict[str, int]:
    """Multiplicities of unordered type pairs among the 36 Frobenius pairs."""
    mult: Dict[str, int] = {k: 0 for k in PAIR_KEYS}
    for t, u in product(SPLIT_TYPES, repeat=2):
        mult[pair_key(t, u)] += TYPE_MULT[t] * TYPE_MULT[u]
    return mult


def pair_sign_bit(key: str) -> bool:
    """Product of the two Frobenius signs, as a function of the unordered pair."""
    return SIGN_BIT[key[0]] == SIGN_BIT[key[1]]


def pair_table(chi: Dict[str, bool]) -> Table:
    mult = pair_multiplicities()
    return {
        (a, k): (mult[k] if chi[a] == pair_sign_bit(k) else 0)
        for a in chi
        for k in PAIR_KEYS
    }


def root_count_table() -> Table:
    """(Frobenius sign, 'does f have a root mod p?') over the six elements of S3."""
    has_root = {"S": True, "P": True, "I": False}
    tbl: Table = {}
    for t in SPLIT_TYPES:
        a = "even" if SIGN_BIT[t] else "odd"
        b = "root" if has_root[t] else "noroot"
        tbl[(a, b)] = tbl.get((a, b), 0) + TYPE_MULT[t]
    for a in ("even", "odd"):
        for b in ("root", "noroot"):
            tbl.setdefault((a, b), 0)
    return tbl


# ----------------------------------------------------------------------------
# 3.  The coupling-quotient law on synthetic tables
# ----------------------------------------------------------------------------

def coupling_table(
    a_labels: Sequence[str],
    b_labels: Sequence[str],
    chi: Callable[[str], int],
    g: Callable[[str], int],
    weight: Callable[[str], int],
) -> Table:
    """n(a,b) = weight(b) if chi(a) == g(b) else 0."""
    return {
        (a, b): (weight(b) if chi(a) == g(b) else 0)
        for a in a_labels
        for b in b_labels
    }


def is_balanced_input(a_labels: Sequence[str], chi: Callable[[str], int], d: int) -> bool:
    sizes = [sum(1 for a in a_labels if chi(a) == c) for c in range(d)]
    return len(set(sizes)) == 1 and sizes[0] > 0


def is_balanced_output(
    b_labels: Sequence[str], g: Callable[[str], int], weight: Callable[[str], int], d: int
) -> bool:
    masses = [sum(weight(b) for b in b_labels if g(b) == c) for c in range(d)]
    return len(set(masses)) == 1 and masses[0] > 0


# ----------------------------------------------------------------------------
# 4.  Algebraic backbone
# ----------------------------------------------------------------------------

def depressed_cubic_discriminant(a: int, b: int) -> int:
    """disc(x^3 + a x + b) = -4a^3 - 27b^2."""
    return -4 * a**3 - 27 * b**2


def vandermonde_discriminant_numeric(a: float, b: float) -> float:
    """((r-s)(s-t)(t-r))^2 computed from numerically found roots of x^3+ax+b."""
    roots = complex_cubic_roots(a, b)
    r, s, t = roots
    val = ((r - s) * (s - t) * (t - r)) ** 2
    return val.real


def complex_cubic_roots(a: float, b: float) -> Tuple[complex, complex, complex]:
    """Roots of x^3 + a x + b by the trigonometric/Cardano formula (complex)."""
    disc_term = (b / 2) ** 2 + (a / 3) ** 3
    sq = complex(disc_term) ** 0.5
    u = (-b / 2 + sq) ** (1 / 3) if abs(-b / 2 + sq) > 0 else 0j
    if u == 0:
        u = (-b / 2 - sq) ** (1 / 3)
    omega = complex(-0.5, math.sqrt(3) / 2)
    roots = []
    for k in range(3):
        uk = u * omega**k
        vk = 0j if uk == 0 else -a / (3 * uk)
        roots.append(uk + vk)
    return roots[0], roots[1], roots[2]


def squarefree_kernel(n: int) -> int:
    """Remove square factors from n, keeping the sign."""
    sign = -1 if n < 0 else 1
    m = abs(n)
    kernel = 1
    d = 2
    while d * d <= m:
        e = 0
        while m % d == 0:
            m //= d
            e += 1
        if e % 2 == 1:
            kernel *= d
        d += 1
    kernel *= m
    return sign * kernel


def is_square_mod_p(a: int, p: int) -> bool:
    a %= p
    if a == 0:
        return True
    return pow(a, (p - 1) // 2, p) == 1


# ----------------------------------------------------------------------------
# 5.  Empirical Chebotarev sampling
# ----------------------------------------------------------------------------

def primes_up_to(limit: int) -> List[int]:
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(2, limit + 1) if sieve[i]]


def splitting_type_mod_p(coeffs: Sequence[int], p: int) -> str:
    """Splitting type of a monic cubic x^3 + c2 x^2 + c1 x + c0 modulo p.

    Determined by the number of roots in F_p: 3 -> split, 1 -> 1+2, 0 -> inert.
    """
    c0, c1, c2 = coeffs
    roots = 0
    for x in range(p):
        if (x * x * x + c2 * x * x + c1 * x + c0) % p == 0:
            roots += 1
    if roots >= 3:
        return "S"
    if roots == 1:
        return "P"
    return "I"


def empirical_channel(
    coeffs: Sequence[int], disc: int, modulus: int, limit: int
) -> Tuple[float, int]:
    """Tally (p mod modulus, splitting type) over primes p <= limit; return (I, count)."""
    tally: Table = {}
    count = 0
    for p in primes_up_to(limit):
        if disc % p == 0 or modulus % p == 0:
            continue
        a = str(p % modulus)
        t = splitting_type_mod_p(coeffs, p)
        tally[(a, t)] = tally.get((a, t), 0) + 1
        count += 1
    return mutual_information(tally), count


# ----------------------------------------------------------------------------
# 6.  Report
# ----------------------------------------------------------------------------

LOG2_3 = math.log2(3.0)


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    rule("1.  EXACT CHANNEL VALUES — Chebotarev model of an S3-cubic")

    chi3 = {"1": True, "2": False}                      # p mod 3, resolvent Q(sqrt -3)
    chi23 = balanced_character_mod_q(23)                # p mod 23, resolvent Q(sqrt -23)

    t3 = residue_type_table(chi3)
    t23 = residue_type_table(chi23)
    print("  joint table for the observable p mod 3 (rows: residue, cols: S P I):")
    for a in ("1", "2"):
        print(f"      p = {a} (mod 3):  " + "  ".join(f"{t3[(a, t)]:2d}" for t in SPLIT_TYPES))
    print(f"  I(p mod 3  ; splitting type) = {mutual_information(t3):.12f}   (theory: 1)")
    print(f"  I(p mod 23 ; splitting type) = {mutual_information(t23):.12f}   (theory: 1)")

    n3 = table_total(t3)
    h_type = entropy_of_counts(marginal_b(t3).values(), n3)
    print(f"  H(splitting type)            = {h_type:.12f}   "
          f"(theory: 2/3 + (log2 3)/2 = {2/3 + LOG2_3/2:.12f})")
    print(f"  residual H(T) - I            = {h_type - 1:.12f}   "
          f"(theory: (log2 3)/2 - 1/3 = {LOG2_3/2 - 1/3:.12f})")

    rule("2.  THE SEMIPRIME PAIR CHANNEL (n = p*q, unordered type pair)")
    mult = pair_multiplicities()
    print("  multiplicities among the 36 Frobenius pairs: " +
          ", ".join(f"{k}={mult[k]}" for k in PAIR_KEYS))
    plus = sum(mult[k] for k in PAIR_KEYS if pair_sign_bit(k))
    minus = sum(mult[k] for k in PAIR_KEYS if not pair_sign_bit(k))
    print(f"  product-sign fibre masses: +1 -> {plus},  -1 -> {minus}   (balanced)")
    print(f"  I(n mod 3  ; type pair) = {mutual_information(pair_table(chi3)):.12f}   (theory: 1)")
    print(f"  I(n mod 23 ; type pair) = {mutual_information(pair_table(chi23)):.12f}   (theory: 1)")

    rule("3.  SHARPNESS — a different readout, and a different group")
    rt = root_count_table()
    print("  root-count table (rows: Frobenius sign, cols: root / no root):")
    for a in ("even", "odd"):
        print(f"      {a:>4}:  " + "  ".join(f"{rt[(a, b)]:2d}" for b in ("root", "noroot")))
    print(f"  I(residue ; has-a-root bit) = {mutual_information(rt):.12f}   "
          f"(theory: (log2 3)/2 - 1/3 = {LOG2_3/2 - 1/3:.12f})")

    # cyclic cubic: residue determines Frobenius bijectively
    c3_frob: Table = {(str(i), str(j)): (1 if i == j else 0) for i in range(3) for j in range(3)}
    c3_type: Table = {}
    for i in range(3):
        b = "split" if i == 0 else "inert"
        c3_type[(str(i), b)] = c3_type.get((str(i), b), 0) + 1
    for i in range(3):
        for b in ("split", "inert"):
            c3_type.setdefault((str(i), b), 0)
    print(f"  cyclic cubic, I(residue ; Frobenius)      = {mutual_information(c3_frob):.12f}   "
          f"(theory: log2 3 = {LOG2_3:.12f})")
    print(f"  cyclic cubic, I(residue ; splitting type) = {mutual_information(c3_type):.12f}   "
          f"(theory: log2 3 - 2/3 = {LOG2_3 - 2/3:.12f})")
    print("  separation:  log2 3 - 2/3 < 1 < log2 3   ->  the value 1 fingerprints S3")

    rule("4.  THE COUPLING-QUOTIENT LAW  I = log2 |D|")
    for d in (2, 3, 4, 5, 8):
        a_labels = [f"a{i}" for i in range(4 * d)]     # k = 4 classes per fibre
        b_labels = [f"b{j}" for j in range(3 * d)]     # 3 outputs per fibre
        chi = lambda a: int(a[1:]) % d                  # noqa: E731
        g = lambda b: int(b[1:]) % d                    # noqa: E731
        weight = lambda b: 1 + (int(b[1:]) // d)        # noqa: E731  (unequal weights!)
        tbl = coupling_table(a_labels, b_labels, chi, g, weight)
        ok_in = is_balanced_input(a_labels, chi, d)
        ok_out = is_balanced_output(b_labels, g, weight, d)
        print(f"  |D| = {d}:  balanced in/out = {ok_in}/{ok_out},  "
              f"I = {mutual_information(tbl):.12f}   (theory: {math.log2(d):.12f})")

    rule("5.  ALGEBRAIC BACKBONE — discriminants and the coupling bit")
    for name, (a, b) in (("x^3 - 3", (0, -3)), ("x^3 - 2", (0, -2)), ("x^3 - x - 1", (-1, -1))):
        d_alg = depressed_cubic_discriminant(a, b)
        d_num = vandermonde_discriminant_numeric(float(a), float(b))
        print(f"  {name:<12}  -4a^3-27b^2 = {d_alg:>6}   "
              f"((r-s)(s-t)(t-r))^2 = {d_num:>12.6f}   "
              f"squarefree kernel = {squarefree_kernel(d_alg):>4}")
    print("  => x^3-3 and x^3-2 share the resolvent Q(sqrt -3); x^3-x-1 has Q(sqrt -23)")

    print("\n  check:  -3 is a square mod p  <=>  p = 1 (mod 3)")
    bad = [p for p in primes_up_to(500) if p not in (2, 3)
           and is_square_mod_p(-3, p) != (p % 3 == 1)]
    print(f"     primes p <= 500 with p != 2,3 violating the equivalence: {bad}  (expected: [])")
    print("  check:  -243 and -108 behave identically to -3 modulo squares")
    bad2 = [p for p in primes_up_to(500) if p not in (2, 3)
            and not (is_square_mod_p(-243, p) == is_square_mod_p(-108, p) == (p % 3 == 1))]
    print(f"     violations: {bad2}  (expected: [])")

    rule("6.  EMPIRICAL CHEBOTAREV TALLIES (convergence to 1 bit)")
    fields = (
        ("x^3 - 3    ", (-3, 0, 0), -243, 3),
        ("x^3 - 2    ", (-2, 0, 0), -108, 3),
        ("x^3 - x - 1", (-1, -1, 0), -23, 23),
    )
    print(f"  {'field':<12} {'mod':>4} {'X':>7} {'#primes':>8} {'empirical I':>14} {'|I-1|':>10}")
    for name, coeffs, disc, modulus in fields:
        for limit in (2000, 10000, 40000):
            emp, cnt = empirical_channel(coeffs, disc, modulus, limit)
            print(f"  {name:<12} {modulus:>4} {limit:>7} {cnt:>8} {emp:>14.6f} {abs(emp-1):>10.6f}")

    rule("SUMMARY")
    print("  Three S3 cubics, three discriminants (-243, -108, -23), two residue groups")
    print("  ((Z/3)^* and (Z/23)^*), one answer:  I(residue ; splitting type) = 1 bit exactly.")
    print("  The semiprime pair channel gives 1 as well; the root-count readout gives")
    print(f"  {LOG2_3/2 - 1/3:.5f}; a cyclic cubic gives {LOG2_3 - 2/3:.5f} and {LOG2_3:.5f}.")


if __name__ == "__main__":
    main()
