"""
demo.py -- Numerical demonstrations of the stratified cycle readout of the
multiplication permutation on Z/NZ.

The object of study is the permutation

    sigma_a : Z/NZ -> Z/NZ,     sigma_a(x) = a * x   (mod N),   gcd(a, N) = 1,

of the *whole ring* Z/NZ (not merely of its unit group).  The results
demonstrated here are:

  1. Stratification law.  For every divisor d | N the stratum
         S_d = { x in Z/NZ : gcd(x, N) = d }
     is invariant, has exactly phi(N/d) elements, and every one of its points
     lies on a cycle of length exactly ord_{N/d}(a).  Hence
         #cycles(sigma_a) = sum_{d | N} phi(N/d) / ord_{N/d}(a).

  2. Semiprime readout.  For N = p*q the cycle lengths are exactly
         { ord_N(a), ord_p(a), ord_q(a), 1 }
     on strata of sizes { phi(N), q-1, p-1, 1 }: the individual orders are
     separated, so the readout is strictly finer than the symmetric datum
     ord_N(a) = lcm(ord_p(a), ord_q(a)).

  3. Factoring.  If a is primitive modulo q, the cycle through the point p has
     length q-1, so q = length + 1 is a nontrivial factor of N.

  4. lcm-blindness of the free stratum.  Two multipliers with equal ord_N(a)
     have identical cycle data on the unit stratum -- the only stratum an
     attacker can enter without already knowing a factor.

  5. Burnside identity.  ord_N(a) * #cycles = sum_{k < ord_N(a)} gcd(N, a^k - 1):
     the cycle count is the aggregate of the classical Pollard (p-1) probes.

  6. Excess formula.  #cycles(pq) = #cycles(p) * #cycles(q)
                       + (gcd(ord_p a, ord_q a) - 1) * i_p * i_q,
     where i_r = (r-1)/ord_r(a).

  7. Sign law.  For odd N the permutation sigma_a is even iff the Jacobi symbol
     J(a|N) equals 1; for even N the sign sees only the 2-part of N.

  8. Affine and power readouts.  The shift b in x -> a*x + b changes the cycle
     count only through gcd(gcd(N, a-1), b); the power map x -> x^k on Z/pZ has
     #cycles(x -> k*x on Z/(p-1)Z) + 1 cycles.

  9. Cost barriers.  Enumerating the permutation touches ~N points; the
     "informative" points (those revealing a factor) have density <= 6/sqrt(N)
     for balanced semiprimes.

Pure standard library; no dependencies.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Tuple


# ----------------------------------------------------------------------
# elementary number theory
# ----------------------------------------------------------------------

def euler_phi(n: int) -> int:
    """Euler's totient phi(n), by trial-division factorisation."""
    result, m, d = n, n, 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            result -= result // d
        d += 1
    if m > 1:
        result -= result // m
    return result


def divisors(n: int) -> List[int]:
    """All positive divisors of n, in increasing order."""
    small = [d for d in range(1, isqrt(n) + 1) if n % d == 0]
    large = [n // d for d in reversed(small) if n // d != d]
    return small + large


def multiplicative_order(a: int, n: int) -> int:
    """ord_n(a): least k >= 1 with a^k = 1 (mod n).  Requires gcd(a, n) = 1."""
    if n == 1:
        return 1
    assert gcd(a, n) == 1, "multiplier must be invertible"
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n >= 1, computed by reciprocity."""
    assert n % 2 == 1 and n >= 1
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


# ----------------------------------------------------------------------
# the permutation and its cycle structure
# ----------------------------------------------------------------------

def cycle_structure(a: int, n: int) -> Dict[int, int]:
    """Brute-force cycle-length multiset of x -> a*x on Z/nZ.

    Returns a dict {cycle length: number of cycles of that length}.
    Cost: O(n) -- exactly the enumeration barrier the theory predicts.
    """
    assert gcd(a, n) == 1
    seen = [False] * n
    counts: Dict[int, int] = {}
    for start in range(n):
        if seen[start]:
            continue
        length, x = 0, start
        while not seen[x]:
            seen[x] = True
            x = (a * x) % n
            length += 1
        counts[length] = counts.get(length, 0) + 1
    return counts


def cycle_count_bruteforce(a: int, n: int) -> int:
    return sum(cycle_structure(a, n).values())


def cycle_count_formula(a: int, n: int) -> int:
    """Stratification law: #cycles = sum_{d | n} phi(n/d) / ord_{n/d}(a)."""
    total = 0
    for d in divisors(n):
        m = n // d
        total += euler_phi(m) // multiplicative_order(a % m if m > 1 else 0, m)
    return total


def stratum(n: int, d: int) -> List[int]:
    """S_d = { x in Z/nZ : gcd(x, n) = d }."""
    return [x for x in range(n) if gcd(x, n) == d]


def cycle_length_of_point(a: int, n: int, x: int) -> int:
    """Period of x: theory says it equals ord_{n/gcd(n,x)}(a)."""
    length, y = 0, x
    while True:
        y = (a * y) % n
        length += 1
        if y == x:
            return length


# ----------------------------------------------------------------------
# 1. stratification law
# ----------------------------------------------------------------------

def demo_stratification(n: int, a: int) -> None:
    print(f"\n=== Stratification law for N = {n}, a = {a} ===")
    print(f"{'d':>6} {'|S_d| (obs)':>12} {'phi(N/d)':>10} "
          f"{'cycle len (obs)':>16} {'ord_(N/d)(a)':>14}")
    for d in divisors(n):
        s = stratum(n, d)
        m = n // d
        predicted_len = multiplicative_order(a % m, m) if m > 1 else 1
        observed_len = {cycle_length_of_point(a, n, x) for x in s} or {1}
        assert len(observed_len) == 1, "all points of a stratum share one length"
        assert len(s) == euler_phi(m)
        assert observed_len.pop() == predicted_len
        print(f"{d:>6} {len(s):>12} {euler_phi(m):>10} "
              f"{predicted_len:>16} {predicted_len:>14}")
    assert cycle_count_bruteforce(a, n) == cycle_count_formula(a, n)
    print(f"total cycles: {cycle_count_bruteforce(a, n)} "
          f"(formula agrees: {cycle_count_formula(a, n)})")


# ----------------------------------------------------------------------
# 2 & 3. semiprime readout and factoring
# ----------------------------------------------------------------------

def semiprime_readout(p: int, q: int, a: int) -> Dict[str, int]:
    """The four data of the readout for N = p*q."""
    n = p * q
    return {
        "ord_N": multiplicative_order(a % n, n),
        "ord_p": multiplicative_order(a % p, p),
        "ord_q": multiplicative_order(a % q, q),
        "cycles": cycle_count_formula(a, n),
    }


def demo_semiprime(p: int, q: int, a: int) -> None:
    n = p * q
    r = semiprime_readout(p, q, a)
    predicted = (1
                 + euler_phi(n) // r["ord_N"]
                 + (q - 1) // r["ord_q"]
                 + (p - 1) // r["ord_p"])
    observed = cycle_count_bruteforce(a, n)
    print(f"\n=== Semiprime readout: N = {p}*{q} = {n}, a = {a} ===")
    print(f"  ord_N(a) = {r['ord_N']} = lcm({r['ord_p']}, {r['ord_q']})   "
          f"(the only datum the unit group exposes)")
    print(f"  cycle lengths by stratum: "
          f"{{S_1: {r['ord_N']}, S_p: {r['ord_q']}, S_q: {r['ord_p']}, S_N: 1}}")
    print(f"  stratum sizes:            "
          f"{{phi(N) = {euler_phi(n)}, q-1 = {q-1}, p-1 = {p-1}, 1}}")
    print(f"  #cycles = 1 + {euler_phi(n)}/{r['ord_N']} + {q-1}/{r['ord_q']}"
          f" + {p-1}/{r['ord_p']} = {predicted}  (brute force: {observed})")
    assert predicted == observed


def factor_via_readout(n: int, p_hint: int, a: int) -> Tuple[int, int]:
    """Given a point x = p of a nontrivial stratum, the cycle through it has
    length ord_q(a); if a is primitive mod q this is q-1, so q = length + 1.
    (The 'circular entry' barrier: producing such an x already factors N.)
    """
    length = cycle_length_of_point(a, n, p_hint)
    q = length + 1
    return q, n // q


def demo_factoring() -> None:
    print("\n=== Factor recovery from a nontrivial cycle length ===")
    cases = [(143, 11, 2), (221, 13, 7), (899, 29, 3), (3127, 53, 2)]
    for n, p, a in cases:
        q, other = factor_via_readout(n, p, a)
        print(f"  N = {n:>5}, a = {a}: cycle through {p} has length {q-1}"
              f"  =>  {{p, q}} = {{{other}, {q}}}   check: {other * q == n}")
        assert other * q == n


# ----------------------------------------------------------------------
# 4. lcm-blindness of the free stratum
# ----------------------------------------------------------------------

def demo_lcm_blindness(n: int, a: int, b: int) -> None:
    print(f"\n=== lcm-blindness of the free (unit) stratum: N = {n} ===")
    print(f"  ord_{n}({a}) = {multiplicative_order(a, n)}, "
          f"ord_{n}({b}) = {multiplicative_order(b, n)}  -- equal")
    units = stratum(n, 1)
    la = {cycle_length_of_point(a, n, x) for x in units}
    lb = {cycle_length_of_point(b, n, x) for x in units}
    print(f"  unit-stratum cycle lengths: {la} vs {lb}  -- identical")
    ca, cb = cycle_count_bruteforce(a, n), cycle_count_bruteforce(b, n)
    print(f"  BUT full cycle counts differ: {ca} vs {cb}")
    p, q = 5, 13
    print(f"  cycle length on the stratum of {q}: "
          f"{cycle_length_of_point(a, n, q)} vs {cycle_length_of_point(b, n, q)}")
    assert la == lb and ca != cb


# ----------------------------------------------------------------------
# 5. Burnside identity and Pollard probes
# ----------------------------------------------------------------------

def demo_burnside(n: int, a: int) -> None:
    L = multiplicative_order(a, n)
    lhs = L * cycle_count_formula(a, n)
    probes = [gcd(n, pow(a, k, n) - 1 if pow(a, k, n) != 0 else n) for k in range(L)]
    probes[0] = n  # k = 0 gives gcd(N, 0) = N
    rhs = sum(probes)
    print(f"\n=== Burnside identity for N = {n}, a = {a} ===")
    print(f"  ord_N(a) = {L}, #cycles = {cycle_count_formula(a, n)}")
    print(f"  ord_N(a) * #cycles = {lhs}")
    print(f"  sum_k gcd(N, a^k - 1) = {rhs}   (Pollard probes: {probes})")
    nontrivial = [k for k in range(1, L) if 1 < probes[k] < n]
    print(f"  probes that already factor N: k = {nontrivial}")
    assert lhs == rhs


# ----------------------------------------------------------------------
# 6. excess formula
# ----------------------------------------------------------------------

def demo_excess(p: int, q: int, a: int) -> None:
    n = p * q
    op, oq = multiplicative_order(a % p, p), multiplicative_order(a % q, q)
    ip, iq = (p - 1) // op, (q - 1) // oq
    cp = 1 + ip
    cq = 1 + iq
    predicted = cp * cq + (gcd(op, oq) - 1) * ip * iq
    observed = cycle_count_formula(a, n)
    print(f"\n=== Excess formula: N = {p}*{q}, a = {a} ===")
    print(f"  #cycles(p) = {cp}, #cycles(q) = {cq}, "
          f"gcd(ord_p, ord_q) = {gcd(op, oq)}, i_p = {ip}, i_q = {iq}")
    print(f"  {cp}*{cq} + ({gcd(op, oq)}-1)*{ip}*{iq} = {predicted}  "
          f"(actual {observed})")
    assert predicted == observed


# ----------------------------------------------------------------------
# 7. sign law
# ----------------------------------------------------------------------

def sign_is_even(a: int, n: int) -> bool:
    return (n - cycle_count_formula(a, n)) % 2 == 0


def demo_sign_law() -> None:
    print("\n=== Sign law: the coarsest readout bit is factorisation-free ===")
    print("  odd moduli: even permutation  <=>  Jacobi symbol J(a|N) = +1")
    for n in [15, 21, 65, 143, 231, 1155]:
        for a in [2, 7, 11, 13]:
            if gcd(a, n) != 1:
                continue
            assert sign_is_even(a, n) == (jacobi_symbol(a, n) == 1)
        print(f"    N = {n:>5}: verified for all tested multipliers")
    print("  even moduli: sign depends only on the 2-part of N")
    for n in [6, 10, 14, 22]:  # N = 2 (mod 4): always even
        for a in range(1, n, 2):
            if gcd(a, n) == 1:
                assert sign_is_even(a, n)
        print(f"    N = {n:>3} = 2 (mod 4): permutation always even")
    for n in [12, 20, 28, 40]:  # 4 | N: odd exactly when a = 3 (mod 4)
        for a in range(1, n):
            if gcd(a, n) == 1:
                assert sign_is_even(a, n) == (a % 4 == 1)
        print(f"    N = {n:>3}, 4 | N: even  <=>  a = 1 (mod 4)")


# ----------------------------------------------------------------------
# 8. affine and power readouts
# ----------------------------------------------------------------------

def cycle_count_map(f, n: int) -> int:
    """Number of cycles of an arbitrary permutation f of {0,...,n-1}."""
    seen = [False] * n
    count = 0
    for start in range(n):
        if seen[start]:
            continue
        count += 1
        x = start
        while not seen[x]:
            seen[x] = True
            x = f(x)
    return count


def demo_affine(n: int, a: int) -> None:
    g = gcd(n, a - 1)
    print(f"\n=== Affine readout for N = {n}, a = {a}  (g = gcd(N, a-1) = {g}) ===")
    base = cycle_count_formula(a, n)
    print(f"  multiplicative count #cycles(x -> a*x) = {base}")
    table: Dict[int, set] = {}
    for b in range(n):
        c = cycle_count_map(lambda x: (a * x + b) % n, n)
        table.setdefault(gcd(g, b), set()).add(c)
    for key in sorted(table):
        assert len(table[key]) == 1, "count depends on b only through gcd(g,b)"
        print(f"  gcd(g, b) = {key:>3}  ->  #cycles = {table[key].pop()}")
    if g == 1:
        print("  1 - a invertible: the shift is completely invisible")
    print("  pure translation x -> x + b has exactly gcd(N, b) cycles: "
          + ", ".join(f"b={b}:{cycle_count_map(lambda x, b=b: (x + b) % n, n)}"
                      f"(gcd={gcd(n, b)})" for b in range(1, min(n, 6))))
    # affine sign law
    for b in range(n):
        lhs = (n - cycle_count_map(lambda x: (a * x + b) % n, n)) % 2
        rhs = ((n - base) + (n - gcd(n, b))) % 2
        assert lhs == rhs
    print("  affine sign law verified: sign(a*x+b) = sign(a*x) * sign(x+b)")


def demo_power_map(p: int) -> None:
    print(f"\n=== Power readout at the prime p = {p} ===")
    for k in range(1, p - 1):
        if gcd(k, p - 1) != 1:
            continue
        observed = cycle_count_map(lambda x: pow(x, k, p), p)
        predicted = cycle_count_formula(k % (p - 1) or 1, p - 1) + 1
        even = (p - observed) % 2 == 0
        law = (not (p - 1) % 4 == 0) or (k % 4 == 1)
        print(f"  k = {k:>3}: #cycles(x -> x^k) = {observed} "
              f"= #cycles(k*x on Z/{p-1}Z) + 1 = {predicted}; "
              f"even permutation: {even} (law: {law})")
        assert observed == predicted and even == law


# ----------------------------------------------------------------------
# 9. cost barriers
# ----------------------------------------------------------------------

def demo_barriers() -> None:
    print("\n=== Cost barriers ===")
    print(f"{'N':>8} {'phi(N)':>8} {'points touched':>16} {'sqrt(N)':>9} "
          f"{'informative':>12} {'density':>10}")
    for p, q in [(53, 59), (79, 89), (101, 103), (181, 191)]:
        n = p * q
        touched = n  # every element must be visited to close all cycles
        informative = p + q - 1  # multiples of p or q, excluding 0
        print(f"{n:>8} {euler_phi(n):>8} {touched:>16} {isqrt(n):>9} "
              f"{informative:>12} {informative / n:>10.5f}")
        assert (p + q - 1) * isqrt(n) <= 6 * n  # density <= 6/sqrt(N)
        assert isqrt(n) < euler_phi(n)          # enumeration beats no bound
    print("  informative density <= 6/sqrt(N) for balanced semiprimes:  verified")
    print("  sqrt(N) < phi(N): the free stratum alone is larger than "
          "the trial-division search space")


# ----------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("The stratified cycle readout of x -> a*x on Z/NZ")
    print("=" * 72)
    demo_stratification(143, 2)
    demo_stratification(60, 7)
    demo_semiprime(11, 13, 2)
    demo_semiprime(13, 17, 7)
    demo_factoring()
    demo_lcm_blindness(65, 57, 31)
    demo_burnside(143, 2)
    demo_burnside(65, 57)
    demo_excess(11, 13, 2)
    demo_excess(13, 17, 7)
    demo_sign_law()
    demo_affine(15, 4)
    demo_affine(15, 2)
    demo_power_map(13)
    demo_barriers()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
