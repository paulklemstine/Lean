"""
The cyclic splitting-type channel: numerical demonstrations.
============================================================

Setting
-------
Let f be an odd prime and Q(zeta_f) the f-th cyclotomic field.  Its Galois group is
the cyclic group C_n = (Z/f)^x of order n = f - 1.  For a prime p not dividing f the
*splitting type* is

        T(p) = ord_f(p)   (the residue degree; p splits into n/T primes of degree T).

Taking discrete logarithms turns the multiplicative group (Z/f)^x into the additive
group Z/n, the type into the additive order

        T(x) = n / gcd(n, x),

and the norm N = p*q of a semiprime into the additive norm class x + y (mod n).

This script demonstrates, with no external dependencies:

  1. the Euler-phi type law   P[T = d] = phi(d)/n   for every divisor d of n;
  2. the closed form          H(T) = log2 n - (1/n) sum_{d|n} phi(d) log2 phi(d);
  3. the exactness of the residue -> type channel, I(x ; T) = H(T);
  4. thickening zero: refining the modulus adds no information;
  5. strict lossiness of the binary "splits completely?" readout for composite n;
  6. the semiprime type-pair channel  I_pair = H(Pi) - (1/n) sum_c H(Pi_c),
     its exact closed forms, and the fact that it exceeds the classical 1-bit cap
     for every even cyclic order n >= 4 while staying below it for every odd n >= 3;
  7. the structure laws: coprime additivity, doubling, and I(2^k) = (4/3)(1 - 4^-k);
  8. an arithmetic check against genuine primes in Q(zeta_f).

Run:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Dict, Iterable, List, Tuple

Key = Tuple[int, int]


# ----------------------------------------------------------------------------- #
# Basic arithmetic helpers
# ----------------------------------------------------------------------------- #
def totient(m: int) -> int:
    """Euler's totient phi(m), by trial division."""
    result, k, mm = m, 2, m
    while k * k <= mm:
        if mm % k == 0:
            while mm % k == 0:
                mm //= k
            result -= result // k
        k += 1
    if mm > 1:
        result -= result // mm
    return result


def divisors(m: int) -> List[int]:
    """Sorted list of positive divisors of m."""
    return sorted(d for d in range(1, m + 1) if m % d == 0)


def entropy(counts: Iterable[int], total: int) -> float:
    """Shannon entropy in bits of the distribution given by occupation numbers."""
    return -sum(c / total * log2(c / total) for c in counts if c > 0)


def splitting_type(n: int, x: int) -> int:
    """T(x) = n / gcd(n, x): the additive order of x in Z/n, i.e. the residue degree."""
    return n // gcd(n, x)


# ----------------------------------------------------------------------------- #
# 1-2.  The Euler-phi type law and the entropy closed form
# ----------------------------------------------------------------------------- #
def type_distribution(n: int) -> Dict[int, int]:
    """Occupation numbers of the splitting type over Z/n."""
    return dict(Counter(splitting_type(n, x) for x in range(n)))


def type_entropy(n: int) -> float:
    """H(T), computed directly from the enumerated distribution."""
    return entropy(type_distribution(n).values(), n)


def type_entropy_closed_form(n: int) -> float:
    """H(T) = log2 n - (1/n) sum_{d|n} phi(d) log2 phi(d)."""
    s = sum(totient(d) * log2(totient(d)) for d in divisors(n))
    return log2(n) - s / n


# ----------------------------------------------------------------------------- #
# 3-4.  Exactness and thickening zero
# ----------------------------------------------------------------------------- #
def residue_type_mutual_information(n: int) -> float:
    """I(x ; T(x)) = H(x) + H(T) - H(x, T) for x uniform on Z/n."""
    h_x = log2(n)
    joint = Counter((x, splitting_type(n, x)) for x in range(n))
    h_joint = entropy(joint.values(), n)
    return h_x + type_entropy(n) - h_joint


def thickening_is_zero(n: int, thickness: int = 4) -> bool:
    """Check T(a mod n*m) == T(a mod n) for all a below n*m: finer moduli add nothing."""
    return all(
        splitting_type(n, a % (n * thickness)) == splitting_type(n, a % n)
        for a in range(n * thickness)
    )


# ----------------------------------------------------------------------------- #
# 5.  The binary root-count readout
# ----------------------------------------------------------------------------- #
def root_count_entropy(n: int) -> float:
    """H(nr) for the binary 'splits completely?' readout; equals H_2(1/n)."""
    ones = sum(1 for x in range(n) if splitting_type(n, x) == 1)
    return entropy([ones, n - ones], n)


def binary_entropy_of_reciprocal(n: int) -> float:
    """H_2(1/n) = log2 n - ((n-1)/n) log2 (n-1)."""
    if n == 1:
        return 0.0
    return log2(n) - (n - 1) / n * log2(n - 1)


# ----------------------------------------------------------------------------- #
# 6.  The semiprime type-pair channel
# ----------------------------------------------------------------------------- #
def pair_tables(n: int) -> Tuple[Counter, List[Counter]]:
    """Global and per-norm-class occupation tables of the unordered type pair."""
    glob: Counter = Counter()
    fibres: List[Counter] = [Counter() for _ in range(n)]
    for x in range(n):
        tx = splitting_type(n, x)
        for y in range(n):
            ty = splitting_type(n, y)
            key: Key = (min(tx, ty), max(tx, ty))
            glob[key] += 1
            fibres[(x + y) % n][key] += 1
    return glob, fibres


def pair_channel(n: int) -> Tuple[float, float, float]:
    """Return (H(Pi), H(Pi | norm class), I_pair) for the cyclic order n."""
    glob, fibres = pair_tables(n)
    h_pair = entropy(glob.values(), n * n)
    h_cond = sum(entropy(f.values(), n) for f in fibres) / n
    return h_pair, h_cond, h_pair - h_cond


def split_count_projection(n: int) -> float:
    """I_pair for the coarsened (binary split-count) hidden variable."""
    glob: Counter = Counter()
    fibres: List[Counter] = [Counter() for _ in range(n)]
    for x in range(n):
        sx = int(splitting_type(n, x) == 1)
        for y in range(n):
            sy = int(splitting_type(n, y) == 1)
            key = (min(sx, sy), max(sx, sy))
            glob[key] += 1
            fibres[(x + y) % n][key] += 1
    return entropy(glob.values(), n * n) - sum(entropy(f.values(), n) for f in fibres) / n


# Exact closed forms proved for the cyclic orders below, as (rational, {prime: coeff}).
EXACT_IPAIR: Dict[int, Tuple[float, Dict[int, float]]] = {
    2: (1.0, {}),
    3: (-10 / 9, {3: 1.0}),
    4: (5 / 4, {}),
    5: (-72 / 25, {3: 12 / 25, 5: 1.0}),
    6: (-1 / 9, {3: 1.0}),
    7: (-78 / 49, {3: -78 / 49, 5: 30 / 49, 7: 1.0}),
    8: (21 / 16, {}),
    9: (-100 / 81, {3: 10 / 9}),
    10: (-47 / 25, {3: 12 / 25, 5: 1.0}),
    11: (-210 / 121, {3: 180 / 121, 5: -210 / 121, 11: 1.0}),
    12: (5 / 36, {3: 1.0}),
    13: (-600 / 169, {3: -300 / 169, 11: 132 / 169, 13: 1.0}),
    14: (-29 / 49, {3: -78 / 49, 5: 30 / 49, 7: 1.0}),
    15: (-898 / 225, {3: 37 / 25, 5: 1.0}),
    16: (85 / 64, {}),
    18: (-19 / 81, {3: 10 / 9}),
    20: (-163 / 100, {3: 12 / 25, 5: 1.0}),
}


def exact_value(n: int) -> float:
    """Evaluate the proved closed form of I_pair(n)."""
    rational, logs = EXACT_IPAIR[n]
    return rational + sum(c * log2(p) for p, c in logs.items())


# ----------------------------------------------------------------------------- #
# 8.  Arithmetic check with genuine primes
# ----------------------------------------------------------------------------- #
def primes_up_to(limit: int) -> List[int]:
    """Simple sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(limit + 1) if sieve[i]]


def multiplicative_order(a: int, f: int) -> int:
    """ord_f(a) for gcd(a, f) = 1."""
    k, cur = 1, a % f
    while cur != 1:
        cur = (cur * a) % f
        k += 1
    return k


def empirical_type_law(f: int, limit: int) -> Dict[int, float]:
    """Empirical distribution of T(p) = ord_f(p) over primes p < limit, p != f."""
    counts = Counter(multiplicative_order(p, f) for p in primes_up_to(limit) if p % f)
    total = sum(counts.values())
    return {d: counts[d] / total for d in sorted(counts)}


# ----------------------------------------------------------------------------- #
# Demonstration driver
# ----------------------------------------------------------------------------- #
def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def main() -> None:
    orders = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20]

    rule("1.  The Euler-phi type law:  #{x in Z/n : T(x) = d} = phi(d)")
    for n in [4, 6, 12, 16]:
        dist = type_distribution(n)
        cells = ", ".join(f"T={d}: {dist[d]} (phi={totient(d)})" for d in sorted(dist))
        print(f"  n={n:2d}  {cells}")
        assert all(dist[d] == totient(d) for d in dist)
    print("  -> counts match Euler's totient exactly for every divisor.")

    rule("2.  Closed form  H(T) = log2 n - (1/n) sum_{d|n} phi(d) log2 phi(d)")
    print(f"  {'n':>3} {'states':>7} {'H(T) enumerated':>17} {'H(T) closed form':>18}")
    for n in orders:
        direct, closed = type_entropy(n), type_entropy_closed_form(n)
        assert abs(direct - closed) < 1e-12
        print(f"  {n:>3} {len(divisors(n)):>7} {direct:>17.6f} {closed:>18.6f}")

    rule("3.  Exactness of the residue -> type channel:  I(x ; T) = H(T)")
    for n in [4, 6, 12]:
        i_res, h_t = residue_type_mutual_information(n), type_entropy(n)
        assert abs(i_res - h_t) < 1e-12
        print(f"  n={n:2d}   I(x ; T) = {i_res:.6f}   H(T) = {h_t:.6f}   (identical)")

    rule("4.  Thickening zero: a finer modulus adds no information")
    for n in [4, 6, 12]:
        print(f"  n={n:2d}   T(a mod n*m) = T(a mod n) for all a, m<=4 : "
              f"{thickening_is_zero(n)}")

    rule("5.  The binary root-count readout is strictly lossy for composite n")
    print(f"  {'n':>3} {'H(nr)':>10} {'H_2(1/n)':>10} {'H(T)':>10}  verdict")
    for n in orders:
        h_nr, h_t = root_count_entropy(n), type_entropy(n)
        assert abs(h_nr - binary_entropy_of_reciprocal(n)) < 1e-12
        verdict = "lossless (n prime)" if abs(h_nr - h_t) < 1e-12 else "LOSSY"
        print(f"  {n:>3} {h_nr:>10.4f} {binary_entropy_of_reciprocal(n):>10.4f} "
              f"{h_t:>10.4f}  {verdict}")

    rule("6.  The semiprime type-pair channel and the 1-bit binary-fork cap")
    print(f"  {'n':>3} {'H(Pi)':>9} {'H(Pi|N)':>9} {'I_pair':>9} {'exact form':>11}  cap")
    for n in orders:
        h_pair, h_cond, i_pair = pair_channel(n)
        exact = exact_value(n)
        assert abs(i_pair - exact) < 1e-10
        flag = "AT CAP" if abs(i_pair - 1) < 1e-12 else ("ABOVE" if i_pair > 1 else "below")
        print(f"  {n:>3} {h_pair:>9.4f} {h_cond:>9.4f} {i_pair:>9.4f} {exact:>11.4f}  {flag}")
    print("\n  Exact closed forms (proved):")
    print("    I_pair(2)  = 1                 I_pair(4)  = 5/4")
    print("    I_pair(6)  = log2 3 - 1/9      I_pair(8)  = 21/16")
    print("    I_pair(12) = log2 3 + 5/36     I_pair(16) = 85/64")

    rule("7.  The split-count projection: one face of the richer type channel")
    for n in [4, 6, 12]:
        print(f"  n={n:2d}   projected (split-count) channel = {split_count_projection(n):.4f} bits"
              f"   vs. full type channel = {pair_channel(n)[2]:.4f} bits")

    rule("8.  Structure laws")
    print("  Coprime additivity  I(mk) = I(m) + I(k):")
    for m, k in [(4, 3), (2, 5), (3, 5), (2, 7), (4, 5), (2, 9)]:
        lhs = pair_channel(m * k)[2]
        rhs = pair_channel(m)[2] + pair_channel(k)[2]
        assert abs(lhs - rhs) < 1e-10
        print(f"    I({m*k:2d}) = {lhs:.6f} = I({m}) + I({k}) = {rhs:.6f}")
    print("  Doubling law  I(2m) = I(m) + 1 for odd m:")
    for m in [3, 5, 7, 9]:
        lhs, rhs = pair_channel(2 * m)[2], pair_channel(m)[2] + 1
        assert abs(lhs - rhs) < 1e-10
        print(f"    I({2*m:2d}) = {lhs:.6f} = I({m}) + 1 = {rhs:.6f}")
    print("  2-adic growth law  I(2^k) = (4/3)(1 - 4^-k), supremum 4/3:")
    for k in range(1, 7):
        val, law = pair_channel(2 ** k)[2], 4 / 3 * (1 - 4.0 ** (-k))
        assert abs(val - law) < 1e-10
        print(f"    k={k}:  I({2**k:2d}) = {val:.8f}   (4/3)(1-4^-{k}) = {law:.8f}")

    rule("9.  Even/odd dichotomy of the cap, cyclic orders 2..40")
    above = [n for n in range(2, 41) if pair_channel(n)[2] > 1 + 1e-12]
    below = [n for n in range(2, 41) if pair_channel(n)[2] < 1 - 1e-12]
    print(f"  strictly above 1 bit: {above}")
    print(f"  strictly below 1 bit: {below}")
    print(f"  exactly at 1 bit    : {[n for n in range(2, 41) if abs(pair_channel(n)[2]-1) < 1e-12]}")
    assert all(n % 2 == 0 for n in above) and all(n % 2 == 1 for n in below)
    print("  -> above the cap exactly for even n >= 4; below for every odd n >= 3.")

    rule("10.  Arithmetic check: genuine primes in Q(zeta_f)")
    for f in [5, 7, 13]:
        n = f - 1
        emp = empirical_type_law(f, 200000)
        print(f"  f={f:2d}  (n={n}, field Q(zeta_{f})):")
        for d in divisors(n):
            print(f"      T={d:2d}   empirical {emp.get(d, 0.0):.4f}   "
                  f"Euler law phi({d})/{n} = {totient(d)/n:.4f}")
        h_emp = entropy([int(round(v * 10 ** 6)) for v in emp.values()], 10 ** 6)
        print(f"      H(T) empirical = {h_emp:.4f}   model = {type_entropy(n):.4f}")

    print("\nAll assertions passed: enumerated values agree with the proved closed forms.")


if __name__ == "__main__":
    main()
