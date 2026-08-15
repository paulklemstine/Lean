"""
demo.py -- The cyclic splitting-type channel: numerical demonstrations.

Self-contained (standard library only).  Run with:  python3 demo.py

What this script demonstrates
-----------------------------
1.  The Euler-totient law of the splitting type T(x) = n / gcd(n, x) on a cyclic
    Galois order n, and its entropy H_T(n).
2.  The binary "root count" readout nr = 1[T = 1], its entropy h2(1/n), the
    data-processing inequality H_nr <= H_T, and the lossiness dichotomy
    (equality exactly at prime orders).
3.  The semiprime type-pair channel
        I_pair(n) = H(Pi) - (1/n) sum_c H(Pi_c),
    the mutual information between the product class N = x + y and the unordered
    type pair {T(x), T(y)}, by exhaustive enumeration over the group.
4.  The exact closed form at prime cyclic order,
        I_pair(p) = log2 p
                    - ((p-1)(2p-1)/p^2) log2(p-1)
                    + ((p-1)(p-2)/p^2) log2(p-2),
    validated against enumeration, together with the sub-cap theorem
    I_pair(p) < 1 for odd p (equality exactly at p = 2) and the quadratic
    two-sided envelope 1/(p^2 ln 2) <= I_pair(p) <= (log2 p + 5)/p^2.
5.  The breaking of the one-bit binary-fork cap at composite even orders.
6.  Coprime additivity of H_T (a theorem) and of I_pair (observed exactly).
7.  The 2-adic laws H_T(2^k) = 2 - 2^{1-k} (a theorem) and
    I_pair(2^k) = (4/3)(1 - 4^{-k}) (observed).
8.  The divisor-lattice sandwich H_nr <= H_T <= log2 d(n).
9.  The arithmetic realisation: real primes in the cyclotomic field Q(zeta_f),
    with T(p) = ord_f(p), reproducing the model densities and the pair channel.
10. The incompatibility between coprime additivity of the pair channel and the
    naive claim that every odd order stays below one bit.
"""

from __future__ import annotations

from collections import Counter
from itertools import product
from math import gcd, log, log2
from typing import Dict, Iterable, List, Tuple

Key = Tuple[int, int]


# ----------------------------------------------------------------------------
# Entropy helpers
# ----------------------------------------------------------------------------

def entropy_from_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of the empirical law given by occupation numbers."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    if total == 0:
        return 0.0
    return -sum((c / total) * log2(c / total) for c in cs)


def binary_entropy(q: float) -> float:
    """Binary entropy h2(q) in bits."""
    if q <= 0.0 or q >= 1.0:
        return 0.0
    return -q * log2(q) - (1.0 - q) * log2(1.0 - q)


# ----------------------------------------------------------------------------
# The splitting type and its single-prime channel
# ----------------------------------------------------------------------------

def splitting_type(n: int, x: int) -> int:
    """T_n(x) = n / gcd(n, x): the order of x in C_n, i.e. the residue degree."""
    return n // gcd(n, x)


def type_law(n: int) -> Dict[int, int]:
    """Occupation numbers of T_n over the whole group (the Euler-totient law)."""
    return Counter(splitting_type(n, x) for x in range(n))


def H_type(n: int) -> float:
    """H_T(n): entropy of the splitting type."""
    return entropy_from_counts(type_law(n).values())


def H_rootcount(n: int) -> float:
    """H_nr(n): entropy of the binary 'splits completely or not' readout."""
    return entropy_from_counts([1, n - 1])


def divisor_count(n: int) -> int:
    return sum(1 for d in range(1, n + 1) if n % d == 0)


def totient(n: int) -> int:
    return sum(1 for a in range(1, n + 1) if gcd(a, n) == 1)


def H_type_totient_formula(n: int) -> float:
    """H_T(n) = log2 n - (1/n) sum_{d | n} phi(d) log2 phi(d)."""
    s = 0.0
    for d in range(1, n + 1):
        if n % d == 0:
            t = totient(d)
            s += t * log2(t) if t > 1 else 0.0
    return log2(n) - s / n


def H_type_sylow(n: int) -> float:
    """H_T(n) via the Sylow decomposition H_T(n) = sum_p H_T(p^{v_p(n)})."""
    total = 0.0
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            q = 1
            while m % p == 0:
                m //= p
                q *= p
            total += H_type(q)
        p += 1
    if m > 1:
        total += H_type(m)
    return total


# ----------------------------------------------------------------------------
# The semiprime type-pair channel
# ----------------------------------------------------------------------------

def pair_tables(n: int) -> Tuple[Counter, List[Counter]]:
    """Global table Pi and the n conditional tables Pi_c of the unordered type pair."""
    global_table: Counter = Counter()
    conditional: List[Counter] = [Counter() for _ in range(n)]
    types: List[int] = [splitting_type(n, x) for x in range(n)]
    for x, y in product(range(n), repeat=2):
        a, b = types[x], types[y]
        key: Key = (a, b) if a <= b else (b, a)
        global_table[key] += 1
        conditional[(x + y) % n][key] += 1
    return global_table, conditional


def I_pair(n: int) -> float:
    """I_pair(n) = H(Pi) - (1/n) sum_c H(Pi_c), by exhaustive enumeration."""
    global_table, conditional = pair_tables(n)
    h_global = entropy_from_counts(global_table.values())
    h_cond = sum(entropy_from_counts(t.values()) for t in conditional) / n
    return h_global - h_cond


def I_pair_prime_closed_form(p: int) -> float:
    """Exact closed form of the pair channel at prime cyclic order p."""
    if p == 2:
        return 1.0
    a = (p - 1) * (2 * p - 1) / p ** 2
    b = (p - 1) * (p - 2) / p ** 2
    return log2(p) - a * log2(p - 1) + b * log2(p - 2)


def I_pair_bounds(p: int) -> Tuple[float, float]:
    """Proved two-sided envelope for odd primes: (lower, upper)."""
    return 1.0 / (p ** 2 * log(2.0)), (log2(p) + 5.0) / p ** 2


def I_rootcount_pair(n: int) -> float:
    """The split-count face: the same channel built from the binary readout."""
    global_table: Counter = Counter()
    conditional: List[Counter] = [Counter() for _ in range(n)]
    nr: List[int] = [1 if splitting_type(n, x) == 1 else 0 for x in range(n)]
    for x, y in product(range(n), repeat=2):
        key = (min(nr[x], nr[y]), max(nr[x], nr[y]))
        global_table[key] += 1
        conditional[(x + y) % n][key] += 1
    return entropy_from_counts(global_table.values()) - sum(
        entropy_from_counts(t.values()) for t in conditional
    ) / n


# ----------------------------------------------------------------------------
# Arithmetic realisation: real primes in Q(zeta_f)
# ----------------------------------------------------------------------------

def primes_up_to(limit: int) -> List[int]:
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    i = 2
    while i * i <= limit:
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
        i += 1
    return [i for i in range(2, limit + 1) if sieve[i]]


def multiplicative_order(a: int, f: int) -> int:
    """ord_f(a): the residue degree of a prime p == a (mod f) in Q(zeta_f)."""
    a %= f
    k, cur = 1, a
    while cur != 1:
        cur = (cur * a) % f
        k += 1
    return k


def empirical_type_law(f: int, limit: int) -> Counter:
    """Empirical frequencies of the splitting type over the primes p < limit."""
    return Counter(
        multiplicative_order(p, f) for p in primes_up_to(limit) if p % f != 0
    )


def empirical_pair_channel(f: int, limit: int, sample: int) -> float:
    """Plug-in estimate of I_pair from genuine semiprimes N = p*q."""
    ps = [p for p in primes_up_to(limit) if p % f != 0]
    types = {p: multiplicative_order(p, f) for p in ps}
    global_table: Counter = Counter()
    conditional: Dict[int, Counter] = {}
    seed = 1234567891
    for _ in range(sample):
        seed = (1103515245 * seed + 12345) % (1 << 31)
        p = ps[seed % len(ps)]
        seed = (1103515245 * seed + 12345) % (1 << 31)
        q = ps[seed % len(ps)]
        a, b = types[p], types[q]
        key: Key = (a, b) if a <= b else (b, a)
        c = (p * q) % f
        global_table[key] += 1
        conditional.setdefault(c, Counter())[key] += 1
    total = sum(global_table.values())
    h_cond = sum(
        (sum(t.values()) / total) * entropy_from_counts(t.values())
        for t in conditional.values()
    )
    return entropy_from_counts(global_table.values()) - h_cond


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_type_law() -> None:
    print("=" * 78)
    print("1. THE SPLITTING TYPE AND ITS ENTROPY  (Euler-totient law)")
    print("=" * 78)
    print(f"{'n':>4} {'type law (d: count)':<34} {'H_T':>8} {'H_nr':>8} "
          f"{'log2 d(n)':>10}")
    for n in [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 16]:
        law = dict(sorted(type_law(n).items()))
        print(f"{n:>4} {str(law):<34} {H_type(n):>8.4f} {H_rootcount(n):>8.4f} "
              f"{log2(divisor_count(n)):>10.4f}")
    print("\nThe divisor-lattice sandwich  H_nr <= H_T <= log2 d(n) holds above,")
    print("strictly whenever n >= 3 is composite.  Cross-check of the closed")
    print("formula H_T(n) = log2 n - (1/n) sum_{d|n} phi(d) log2 phi(d):")
    worst = max(abs(H_type(n) - H_type_totient_formula(n)) for n in range(1, 40))
    print(f"  max |enumeration - formula| over n <= 40 : {worst:.2e}")


def demo_lossiness() -> None:
    print()
    print("=" * 78)
    print("2. ROOT-COUNT LOSSINESS:  H_nr < H_T  EXACTLY AT COMPOSITE ORDERS")
    print("=" * 78)
    print(f"{'n':>4} {'prime?':>7} {'H_T':>9} {'H_nr':>9} {'loss':>9}")
    for n in range(2, 19):
        is_prime = all(n % d for d in range(2, int(n ** 0.5) + 1))
        loss = H_type(n) - H_rootcount(n)
        print(f"{n:>4} {str(is_prime):>7} {H_type(n):>9.4f} "
              f"{H_rootcount(n):>9.4f} {loss:>9.4f}")
    print("\n2-adic tower: H_T(2^k) = 2 - 2^(1-k) (theorem), while H_nr -> 0,")
    print("so the loss converges to the full two bits.")
    print(f"{'k':>3} {'H_T(2^k)':>10} {'2-2^(1-k)':>11} {'H_nr':>9} {'loss':>9}")
    for k in range(1, 8):
        n = 2 ** k
        print(f"{k:>3} {H_type(n):>10.6f} {2 - 2.0 ** (1 - k):>11.6f} "
              f"{H_rootcount(n):>9.6f} {H_type(n) - H_rootcount(n):>9.6f}")


def demo_pair_channel() -> None:
    print()
    print("=" * 78)
    print("3. THE SEMIPRIME TYPE-PAIR CHANNEL AND THE ONE-BIT CAP")
    print("=" * 78)
    print(f"{'n':>4} {'#types':>7} {'H(Pi)':>9} {'H(Pi|N)':>9} {'I_pair':>9} "
          f"{'split-count face':>17} {'above 1 bit?':>13}")
    for n in [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16]:
        table, cond = pair_tables(n)
        h_global = entropy_from_counts(table.values())
        h_cond = sum(entropy_from_counts(t.values()) for t in cond) / n
        ip = h_global - h_cond
        flag = "YES" if ip > 1.0 + 1e-12 else ("at cap" if abs(ip - 1) < 1e-12
                                               else "no")
        print(f"{n:>4} {len(type_law(n)):>7} {h_global:>9.4f} {h_cond:>9.4f} "
              f"{ip:>9.4f} {I_rootcount_pair(n):>17.4f} {flag:>13}")
    print("\nThe quadratic order n = 2 reproduces the binary-fork cap exactly.")
    print("Every even composite order tested strictly exceeds one bit, while the")
    print("split-count face of the same channel stays far below it.")


def demo_closed_form() -> None:
    print()
    print("=" * 78)
    print("4. THE EXACT PRIME-ORDER CLOSED FORM AND THE SUB-CAP THEOREM")
    print("=" * 78)
    print("   I_pair(p) = log2 p - ((p-1)(2p-1)/p^2) log2(p-1)")
    print("                       + ((p-1)(p-2)/p^2) log2(p-2)")
    print()
    print(f"{'p':>4} {'enumerated':>13} {'closed form':>13} {'|diff|':>10} "
          f"{'lower bd':>10} {'upper bd':>10}")
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        enum = I_pair(p)
        cf = I_pair_prime_closed_form(p)
        lo, hi = I_pair_bounds(p)
        print(f"{p:>4} {enum:>13.9f} {cf:>13.9f} {abs(enum - cf):>10.2e} "
              f"{lo:>10.6f} {hi:>10.6f}")
    print("\nEvery odd prime satisfies 0 < I_pair(p) < 1 (indeed I_pair(p) < 3/(p-1)),")
    print("and p = 2 is the unique prime attaining the cap exactly.")


def demo_multiplicativity() -> None:
    print()
    print("=" * 78)
    print("5. MULTIPLICATIVE STRUCTURE:  CRT, ADDITIVITY, SYLOW DECOMPOSITION")
    print("=" * 78)
    print("Type map:  T_{mn}(a) = T_m(a) * T_n(a) = lcm(T_m(a), T_n(a))  (coprime m,n)")
    ok = all(
        splitting_type(m * n, a) == splitting_type(m, a) * splitting_type(n, a)
        for m in range(1, 13) for n in range(1, 13) if gcd(m, n) == 1
        for a in range(m * n)
    )
    print(f"  verified for all coprime m,n <= 12 and all a : {ok}")
    print("\nEntropy additivity H_T(mn) = H_T(m) + H_T(n) (theorem), and the")
    print("observed additivity of the pair channel I_pair(mn) = I_pair(m)+I_pair(n):")
    print(f"{'m':>4} {'n':>4} {'H_T(mn)':>10} {'sum':>10} "
          f"{'I_pair(mn)':>12} {'sum':>12} {'|diff|':>10}")
    for m, n in [(3, 4), (2, 5), (3, 5), (4, 5), (3, 8), (5, 7), (9, 5), (3, 7),
                 (2, 9), (4, 7)]:
        a, b = I_pair(m * n), I_pair(m) + I_pair(n)
        print(f"{m:>4} {n:>4} {H_type(m * n):>10.6f} "
              f"{H_type(m) + H_type(n):>10.6f} {a:>12.6f} {b:>12.6f} "
              f"{abs(a - b):>10.2e}")
    print("\nSylow evaluation of H_T (factor first, never enumerate the group):")
    print(f"{'n':>5} {'enumerated':>12} {'Sylow sum':>12}")
    for n in [12, 24, 36, 60, 105, 210]:
        print(f"{n:>5} {H_type(n):>12.6f} {H_type_sylow(n):>12.6f}")
    print("\n2-adic pair law, observed:  I_pair(2^k) = (4/3)(1 - 4^(-k))")
    print(f"{'k':>3} {'I_pair(2^k)':>13} {'(4/3)(1-4^-k)':>15}")
    for k in range(1, 6):
        print(f"{k:>3} {I_pair(2 ** k):>13.9f} "
              f"{(4.0 / 3.0) * (1 - 4.0 ** (-k)):>15.9f}")


def demo_arithmetic() -> None:
    print()
    print("=" * 78)
    print("6. THE ARITHMETIC REALISATION:  REAL PRIMES IN Q(zeta_f)")
    print("=" * 78)
    limit = 200000
    for f in [5, 7, 11, 13]:
        n = f - 1
        law = empirical_type_law(f, limit)
        total = sum(law.values())
        emp = {d: round(law[d] / total, 4) for d in sorted(law)}
        model = {d: round(c / n, 4) for d, c in sorted(type_law(n).items())}
        print(f"\nQ(zeta_{f}):  Galois order n = {n}")
        print(f"  model type densities      : {model}")
        print(f"  empirical over primes<{limit} : {emp}")
        print(f"  H_T model = {H_type(n):.4f}   "
              f"H_T empirical = {entropy_from_counts(law.values()):.4f}")
    print("\nPair channel from genuine semiprimes N = p*q (plug-in estimate):")
    print(f"{'f':>4} {'n':>4} {'I_pair model':>14} {'I_pair sampled':>16}")
    for f in [3, 5, 7, 11, 13]:
        est = empirical_pair_channel(f, 20000, 60000)
        print(f"{f:>4} {f - 1:>4} {I_pair(f - 1):>14.4f} {est:>16.4f}")


def demo_incompatibility() -> None:
    print()
    print("=" * 78)
    print("7. ADDITIVITY vs. THE NAIVE 'ODD ORDERS STAY BELOW THE CAP' CLAIM")
    print("=" * 78)
    print("Under coprime additivity, a squarefree odd order n = p1...pk carries")
    print("I_pair(n) = sum_i I_pair(p_i), each term given by the exact closed form.")
    running = 0.0
    crossing = None
    odd_primes = [p for p in primes_up_to(20000) if p > 2]
    for p in odd_primes:
        running += I_pair_prime_closed_form(p)
        if crossing is None and running > 1.0:
            crossing = p
    partial = 0.0
    print(f"\n{'p':>6} {'I_pair(p)':>13} {'running sum':>14}")
    for p in odd_primes:
        partial += I_pair_prime_closed_form(p)
        if p <= 19 or p in (139, 149, 1000, 9973):
            print(f"{p:>6} {I_pair_prime_closed_form(p):>13.9f} {partial:>14.9f}")
        if p > 9973:
            break
    print(f"\nThe running sum first exceeds one bit at p = {crossing}.")
    print(f"Total over all odd primes below 20000 : {running:.6f} > 1.")
    print("Hence additivity forces the ODD squarefree order")
    print("  n = 3 * 5 * 7 * ... * 139")
    print("to break the one-bit cap: the naive parity dichotomy and coprime")
    print("additivity cannot both hold.")


def main() -> None:
    demo_type_law()
    demo_lossiness()
    demo_pair_channel()
    demo_closed_form()
    demo_multiplicativity()
    demo_arithmetic()
    demo_incompatibility()
    print()
    print("=" * 78)
    print("Done.  The type, not the root count, is the complete object.")
    print("=" * 78)


if __name__ == "__main__":
    main()
