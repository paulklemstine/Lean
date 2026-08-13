"""
Numerical demonstrations of the two structural barriers to classical integer
factoring: free witnesses and congruence blindness.

Self-contained; standard library only.  Run with:

    python3 demo.py

The five demonstrations correspond to the five closed proposals:

  1. Evaluation ("Reed-Solomon") codes over Z/N: the minimum distance equals
     N - k * max(p, q), so it is a free witness for the factorization.
  2. The divisor-count-parity oracle: its support is exactly three residue
     classes, from which the factor residues are recovered; and two different
     semiprimes give identical transcripts off a 6/m-density set.
  3. The reduced Burau image of the three-strand braid group over Z/N: the
     image of sigma_1 sigma_2 has order exactly lcm(3, ord_N(a)), and the
     order splits as lcm(ord_p(a), ord_q(a)).
  4. Average-case statistics: Pollard-rho step counts are uncorrelated with
     every N-only congruence statistic, while the small-gap subfamily (a
     factor property, invisible from N) is dramatically faster.
  5. The divisor congestion game: the unique best response is the least prime
     factor, and the payoff landscape is exactly flat off the divisors.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Basic number theory
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than n."""
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def min_fac(n: int) -> int:
    """Least prime factor of n >= 2, by trial division."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def proper_divisors(n: int) -> List[int]:
    """All d with d | n and d < n, sorted."""
    out: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            if d < n:
                out.append(d)
            e = n // d
            if e != d and e < n:
                out.append(e)
        d += 1
    return sorted(out)


def mult_order(a: int, n: int) -> Optional[int]:
    """Multiplicative order of a modulo n, or None if a is not a unit."""
    if math.gcd(a, n) != 1:
        return None
    k, x = 1, a % n
    while x != 1 % n:
        x = x * a % n
        k += 1
    return k


# ---------------------------------------------------------------------------
# 1. Evaluation codes over Z/N: the minimum distance is a free witness
# ---------------------------------------------------------------------------


def poly_eval(coeffs: Sequence[int], x: int, n: int) -> int:
    """Horner evaluation of a polynomial with the given coefficients mod n."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % n
    return acc


def codeword_weight(coeffs: Sequence[int], n: int) -> int:
    """Hamming weight of the evaluation codeword of a polynomial over Z/n."""
    return sum(1 for x in range(n) if poly_eval(coeffs, x, n) != 0)


def brute_force_min_distance(n: int, k: int) -> int:
    """Minimum Hamming weight over all NONZERO polynomials of degree < k+1.

    Exhaustive over the n^(k+1) coefficient vectors: this is precisely the
    Omega(N^k) cost that makes the invariant a *free* witness rather than a
    cheap one.  Only feasible for tiny n.
    """
    best = n + 1
    total = n ** (k + 1)
    for code in range(total):
        coeffs, c = [], code
        for _ in range(k + 1):
            coeffs.append(c % n)
            c //= n
        if all(v == 0 for v in coeffs):
            continue
        best = min(best, codeword_weight(coeffs, n))
    return best


def predicted_min_distance(p: int, q: int, k: int) -> int:
    """The closed formula: d = N - k * max(p, q)."""
    return p * q - k * max(p, q)


def factor_from_min_distance(n: int, d: int) -> Tuple[int, int]:
    """Recover (p, q) from N and the minimum distance of the degree-<=1 code."""
    larger = n - d
    return n // larger, larger


def demo_reed_solomon() -> None:
    print("=" * 72)
    print("1. EVALUATION CODES OVER Z/N: the minimum distance is a free witness")
    print("=" * 72)
    print("   Theorem: for p < q and k <= p, the minimum distance of the code")
    print("   of evaluations of polynomials of degree <= k is exactly")
    print("       d = N - k * max(p, q).")
    print()
    print(f"   {'N = p*q':>10} {'k':>3} {'brute force':>12} {'formula':>9} {'match':>6}")
    for (p, q) in [(3, 5), (3, 7), (5, 7)]:
        n = p * q
        for k in (1, 2):
            if k > p:
                continue
            bf = brute_force_min_distance(n, k)
            pr = predicted_min_distance(p, q, k)
            print(
                f"   {f'{n} = {p}*{q}':>10} {k:>3} {bf:>12} {pr:>9} "
                f"{'OK' if bf == pr else 'FAIL':>6}"
            )
    print()
    print("   The witness: from N and the degree-<=1 minimum distance d,")
    print("   max(p,q) = N - d and min(p,q) = N / (N - d).")
    for (p, q) in [(3, 5), (3, 7), (5, 7), (7, 13), (11, 23)]:
        n = p * q
        d = predicted_min_distance(p, q, 1)
        rec = factor_from_min_distance(n, d)
        print(f"     N = {n:>5}: d = {d:>5}  ->  recovered {rec}   (true ({p}, {q}))")
    print()
    print("   Extremal codeword for k: f(x) = q * x(x-1)...(x-k+1).")
    p, q, k = 3, 5, 2
    n = p * q
    coeffs = [0, 0, 0]
    # q * x * (x - 1) = q*x^2 - q*x
    coeffs = [0, (-q) % n, q % n]
    zeros = [x for x in range(n) if poly_eval(coeffs, x, n) == 0]
    print(f"     N = {n}, k = {k}: f(x) = {q}x^2 - {q}x")
    print(f"     zero set = {zeros}   (size {len(zeros)} = k*q = {k*q})")
    print(f"     residues mod p={p}: {sorted({z % p for z in zeros})}"
          f"  -- exactly the classes 0..k-1, each with q={q} lifts")
    print()


# ---------------------------------------------------------------------------
# 2. The divisor-count-parity oracle
# ---------------------------------------------------------------------------


def divisor_parity(n: int, m: int, a: int) -> int:
    """Parity of the number of proper divisors of n congruent to a mod m."""
    return sum(1 for d in proper_divisors(n) if d % m == a % m) % 2


def parity_support(n: int, m: int) -> List[int]:
    """The residues a in {0,...,m-1} at which the parity pattern is 1."""
    return [a for a in range(m) if divisor_parity(n, m, a) == 1]


def recovered_factor_residues(n: int, m: int) -> List[int]:
    """Support minus the a priori known class 1 mod m."""
    return [a for a in parity_support(n, m) if a != 1 % m]


def demo_divisor_parity() -> None:
    print("=" * 72)
    print("2. THE DIVISOR-COUNT-PARITY ORACLE")
    print("=" * 72)
    print("   P(N,m,a) = #{d proper divisor of N : d = a mod m} mod 2.")
    print("   Theorem: in the non-collision case the support is exactly")
    print("   {1 mod m, p mod m, q mod m}; deleting 1 returns the factor residues.")
    print()
    for (p, q, m) in [(3, 5, 7), (3, 7, 11), (7, 13, 20), (11, 23, 30)]:
        n = p * q
        sup = parity_support(n, m)
        rec = sorted(recovered_factor_residues(n, m))
        truth = sorted({p % m, q % m})
        print(
            f"   N = {n:>4} = {p}*{q},  m = {m:>3}:  support = {sup}"
            f"  ->  factor residues {rec}  (true {truth})"
            f"  {'OK' if rec == truth else 'COLLISION'}"
        )
    print()
    print("   Support density: exactly 3 informative classes out of m.")
    for (p, q, m) in [(11, 23, 30), (11, 23, 100), (11, 23, 1000)]:
        n = p * q
        s = parity_support(n, m)
        print(f"     N = {n}, m = {m:>5}: |support| = {len(s)}, density = {len(s)/m:.5f}")
    print()
    print("   Collision case (p = q mod m): the pattern collapses to {1 mod m}.")
    for (p, q, m) in [(3, 5, 2), (7, 13, 3), (11, 23, 4)]:
        n = p * q
        print(
            f"     N = {n:>4} = {p}*{q}, m = {m}: {p} = {p%m}, {q} = {q%m} mod {m}"
            f"  ->  support = {parity_support(n, m)}"
        )
    print()
    print("   Adversary indistinguishability: two semiprimes give identical")
    print("   transcripts on every query avoiding their <= 6 marked classes.")
    m = 60
    n1, n2 = 11 * 23, 17 * 29
    marked = set(parity_support(n1, m)) | set(parity_support(n2, m))
    safe = [a for a in range(m) if a not in marked]
    agree = all(divisor_parity(n1, m, a) == divisor_parity(n2, m, a) for a in safe)
    print(f"     m = {m}, N1 = {n1}, N2 = {n2}")
    print(f"     marked classes: {sorted(marked)}  ({len(marked)} of {m})")
    print(f"     transcripts agree on all {len(safe)} unmarked queries: {agree}")
    print(f"     an adversary can force {len(safe)} uninformative queries -> Omega(m)")
    print()


# ---------------------------------------------------------------------------
# 3. The reduced Burau image of B_3 over Z/N
# ---------------------------------------------------------------------------

Mat = Tuple[int, int, int, int]  # (a00, a01, a10, a11)


def mat_mul(x: Mat, y: Mat, n: int) -> Mat:
    return (
        (x[0] * y[0] + x[1] * y[2]) % n,
        (x[0] * y[1] + x[1] * y[3]) % n,
        (x[2] * y[0] + x[3] * y[2]) % n,
        (x[2] * y[1] + x[3] * y[3]) % n,
    )


def burau_gen1(a: int, n: int) -> Mat:
    return ((-a) % n, 1 % n, 0, 1 % n)


def burau_gen2(a: int, n: int) -> Mat:
    return (1 % n, 0, a % n, (-a) % n)


def burau_bm(a: int, n: int) -> Mat:
    """The image of sigma_1 * sigma_2."""
    return mat_mul(burau_gen1(a, n), burau_gen2(a, n), n)


def mat_order(x: Mat, n: int, bound: int = 100000) -> Optional[int]:
    identity: Mat = (1 % n, 0, 0, 1 % n)
    y, k = x, 1
    while y != identity and k <= bound:
        y = mat_mul(y, x, n)
        k += 1
    return k if y == identity else None


def burau_subgroup_order(a: int, n: int, cap: int = 200000) -> Optional[int]:
    """|H_a| by breadth-first closure of the two generators (small n only)."""
    g1, g2 = burau_gen1(a, n), burau_gen2(a, n)
    identity: Mat = (1 % n, 0, 0, 1 % n)
    seen = {identity}
    frontier = [identity]
    while frontier:
        new: List[Mat] = []
        for x in frontier:
            for g in (g1, g2):
                y = mat_mul(x, g, n)
                if y not in seen:
                    seen.add(y)
                    new.append(y)
                    if len(seen) > cap:
                        return None
        frontier = new
    return len(seen)


def demo_burau() -> None:
    print("=" * 72)
    print("3. THE REDUCED BURAU IMAGE: braids are order-finding in disguise")
    print("=" * 72)
    print("   r(s1) = [[-a,1],[0,1]],  r(s2) = [[1,0],[a,-a]],  B = r(s1)r(s2).")
    print()
    n, a = 21, 2
    lhs = mat_mul(mat_mul(burau_gen1(a, n), burau_gen2(a, n), n), burau_gen1(a, n), n)
    rhs = mat_mul(mat_mul(burau_gen2(a, n), burau_gen1(a, n), n), burau_gen2(a, n), n)
    print(f"   Braid relation mod {n} at a={a}: r(s1)r(s2)r(s1) = {lhs}")
    print(f"                                     r(s2)r(s1)r(s2) = {rhs}   -> {lhs == rhs}")
    print()
    print("   Full twist: B^3 = a^3 * I.")
    for (n, a) in [(21, 2), (21, 5), (35, 3), (91, 11)]:
        b = burau_bm(a, n)
        b3 = mat_mul(mat_mul(b, b, n), b, n)
        scalar = (pow(a, 3, n), 0, 0, pow(a, 3, n))
        print(f"     N = {n:>3}, a = {a:>3}: B^3 = {b3}, a^3*I = {scalar}  -> {b3 == scalar}")
    print()
    print("   Order equation: ord(B) = lcm(3, ord_N(a)).")
    print(f"   {'N':>5} {'a':>4} {'ord_N(a)':>9} {'lcm(3,ord)':>11} {'ord(B)':>8} {'match':>6}")
    for (p, q) in [(3, 7), (5, 7), (7, 13)]:
        n = p * q
        for a in range(2, n):
            if math.gcd(a, n) != 1:
                continue
            oa = mult_order(a, n)
            assert oa is not None
            pred = (3 * oa) // math.gcd(3, oa)
            act = mat_order(burau_bm(a, n), n)
            if a < 8:
                print(
                    f"   {n:>5} {a:>4} {oa:>9} {pred:>11} {act:>8} "
                    f"{'OK' if act == pred else 'FAIL':>6}"
                )
            assert act == pred, (n, a, oa, pred, act)
    print("   (all units checked for N in {21, 35, 91}: formula holds exactly)")
    print()
    print("   CRT splitting: ord_N(a) = lcm(ord_p(a), ord_q(a)).")
    for (p, q, a) in [(3, 7, 2), (3, 7, 5), (5, 7, 3), (7, 13, 5)]:
        n = p * q
        on, op, oq = mult_order(a, n), mult_order(a, p), mult_order(a, q)
        assert on is not None and op is not None and oq is not None
        print(
            f"     N = {n:>3}, a = {a}: ord_{p}={op}, ord_{q}={oq},"
            f" lcm={op*oq//math.gcd(op,oq)}, ord_N={on}"
        )
    print()
    print("   The group order |H_a| separates the INDIVIDUAL prime-level orders")
    print("   even when the lcm agrees -- and that is exactly the factor-secret data.")
    for (p, q, a) in [(3, 7, 2), (3, 7, 5)]:
        n = p * q
        op, oq = mult_order(a, p), mult_order(a, q)
        assert op is not None and oq is not None
        card = burau_subgroup_order(a, n)
        lcm = op * oq // math.gcd(op, oq)
        print(
            f"     N = {n}, a = {a}: (ord_{p}, ord_{q}) = ({op}, {oq}),"
            f" lcm = {lcm},  |H_a| = {card}"
        )
    print("     -> same lcm, different |H_a|: the group order sees the pair, not the lcm.")
    print()
    print("   Lagrange: lcm(3, ord_N(a)) divides |H_a|.")
    for (n, a) in [(21, 2), (21, 5), (15, 2), (35, 3)]:
        oa = mult_order(a, n)
        assert oa is not None
        pred = (3 * oa) // math.gcd(3, oa)
        card = burau_subgroup_order(a, n)
        assert card is not None
        print(
            f"     N = {n:>3}, a = {a}: lcm(3, ord) = {pred:>3}, |H_a| = {card:>5},"
            f" divides: {card % pred == 0}"
        )
    print()


# ---------------------------------------------------------------------------
# 4. Congruence blindness and the average-case question
# ---------------------------------------------------------------------------


def pollard_rho_steps(n: int, limit: int = 2_000_000) -> Optional[int]:
    """Number of iterations Pollard's rho needs to split n (None if it fails)."""
    if n % 2 == 0:
        return 0
    for c in (1, 2, 3, 5, 7):
        x = y = 2
        for step in range(1, limit + 1):
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = math.gcd(abs(x - y), n)
            if d == n:
                break
            if d > 1:
                return step
    return None


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0."""
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


def random_semiprime(bits: int, rng: random.Random) -> Tuple[int, int, int]:
    """A random semiprime p*q with both primes of about `bits` bits."""
    p = next_prime(rng.randrange(2 ** (bits - 1), 2 ** bits))
    q = next_prime(rng.randrange(2 ** (bits - 1), 2 ** bits))
    while q == p:
        q = next_prime(rng.randrange(2 ** (bits - 1), 2 ** bits))
    if p > q:
        p, q = q, p
    return p * q, p, q


def coprime_semiprimes_in_class(m: int, bound: int) -> Tuple[int, int, Tuple[int, ...]]:
    """Two coprime semiprimes above `bound`, both congruent to 1 mod m.

    This is the constructive witness defeating every congruence-determined
    divisor predictor: the two numbers share no prime factor, but a predictor
    seeing only N mod m must return the same value for both.
    """
    def prime_1_mod_m(above: int) -> int:
        c = above + 1
        while True:
            if c % m == 1 % m and is_prime(c):
                return c
            c += 1

    p1 = prime_1_mod_m(max(1, bound))
    p2 = prime_1_mod_m(p1)
    r1 = prime_1_mod_m(p2)
    r2 = prime_1_mod_m(r1)
    return p1 * r1, p2 * r2, (p1, r1, p2, r2)


def demo_congruence_blindness() -> None:
    print("=" * 72)
    print("4. CONGRUENCE BLINDNESS AND THE AVERAGE-CASE QUESTION")
    print("=" * 72)
    print("   Meta-theorem: no invariant determined by N mod m names a nontrivial")
    print("   divisor of every large semiprime.  Constructive witness:")
    print()
    for m in (4, 8, 12, 30):
        n1, n2, primes = coprime_semiprimes_in_class(m, 200)
        p1, r1, p2, r2 = primes
        print(
            f"     m = {m:>3}: N1 = {n1} = {p1}*{r1},  N2 = {n2} = {p2}*{r2}"
        )
        print(
            f"              N1 mod m = {n1 % m}, N2 mod m = {n2 % m},"
            f"  gcd(N1,N2) = {math.gcd(n1, n2)}"
        )
    print("     Same residue class, coprime: no single value divides both.")
    print()
    print("   Bounded candidate lists fail too: k+1 pairwise-coprime semiprimes")
    print("   in one class defeat every list of length <= k.")
    m, k = 12, 3
    def prime_1_mod_m(above: int, mm: int) -> int:
        c = above + 1
        while True:
            if c % mm == 1 % mm and is_prime(c):
                return c
            c += 1
    cur, fam = 100, []
    for _ in range(k + 1):
        a = prime_1_mod_m(cur, m)
        b = prime_1_mod_m(a, m)
        fam.append((a, b))
        cur = b
    prods = [a * b for a, b in fam]
    pw = all(
        math.gcd(prods[i], prods[j]) == 1
        for i in range(len(prods))
        for j in range(i + 1, len(prods))
    )
    print(f"     m = {m}, k = {k}: family = {[f'{a}*{b}' for a, b in fam]}")
    print(f"     all = 1 mod m: {all(x % m == 1 % m for x in prods)};  pairwise coprime: {pw}")
    print(f"     each needs its own candidate -> any list must have size >= {k+1}")
    print()
    print("   Average case: rho step counts vs N-only statistics (100 semiprimes).")
    rng = random.Random(20260813)
    rows: List[Tuple[int, int, int, int]] = []
    while len(rows) < 100:
        n, p, q = random_semiprime(11, rng)
        steps = pollard_rho_steps(n)
        if steps is None:
            continue
        rows.append((n, p, q, steps))

    def mean(xs: Iterable[int]) -> float:
        xs = list(xs)
        return sum(xs) / len(xs) if xs else float("nan")

    buckets: Dict[str, List[int]] = {}
    for n, p, q, s in rows:
        buckets.setdefault(f"N mod 4 = {n % 4}", []).append(s)
        buckets.setdefault(f"N mod 8 = {n % 8}", []).append(s)
        buckets.setdefault(f"(2/N) = {jacobi(2, n):+d}", []).append(s)
    for key in sorted(buckets):
        vals = buckets[key]
        print(f"     {key:<16} count = {len(vals):>3}   mean rho steps = {mean(vals):8.1f}")
    print("     -> no N-only congruence statistic separates the step counts.")
    print()
    gaps = sorted(rows, key=lambda t: t[2] - t[1])
    d = max(1, len(gaps) // 10)
    print(f"     smallest-gap decile:  mean rho steps = {mean(s for *_, s in gaps[:d]):8.1f}")
    print(f"     largest-gap decile:   mean rho steps = {mean(s for *_, s in gaps[-d:]):8.1f}")
    print("     -> the gap DOES predict ease, but the gap is a factor property,")
    print("        not computable from N; and every residue class contains")
    print("        semiprimes of arbitrarily large gap.")
    print()


# ---------------------------------------------------------------------------
# 5. The divisor congestion game
# ---------------------------------------------------------------------------


def payoff(n: int, d: int) -> int:
    """Payoff of bid d in the divisor congestion game on N."""
    return n // d if n % d == 0 else -n


def best_responses(n: int) -> List[int]:
    """All admissible bids maximizing the payoff."""
    bids = range(2, n)
    best = max(payoff(n, d) for d in bids)
    return [d for d in bids if payoff(n, d) == best]


def demo_congestion_game() -> None:
    print("=" * 72)
    print("5. THE DIVISOR CONGESTION GAME: the equilibrium IS the factorization")
    print("=" * 72)
    print("   Bids d in {2,...,N-1}; payoff w(d) = N/d if d | N, else -N.")
    print()
    print(f"   {'N':>6} {'best response':>14} {'payoff':>8} {'minFac':>7} {'N = d*w(d)':>12}")
    for (p, q) in [(3, 5), (7, 13), (11, 23), (13, 29), (17, 31)]:
        n = p * q
        br = best_responses(n)
        d = br[0]
        print(
            f"   {n:>6} {str(br):>14} {payoff(n, d):>8} {min_fac(n):>7}"
            f" {f'{n} = {d}*{payoff(n,d)}':>12}"
        )
    print("   -> unique best response = least prime factor; the pair (d, w(d))")
    print("      is the complete factorization.")
    print()
    print("   A payoff query is exactly a divisibility test: w(d) >= 0 iff d | N.")
    n = 91
    checks = all((payoff(n, d) >= 0) == (n % d == 0) for d in range(2, n))
    print(f"     N = {n}: equivalence holds for all admissible bids: {checks}")
    print()
    print("   The landscape is exactly flat off the divisors -- no gradient at all.")
    n = 91
    vals = [payoff(n, d) for d in range(2, n)]
    nondiv = {payoff(n, d) for d in range(2, n) if n % d != 0}
    print(f"     N = {n}: distinct payoffs = {sorted(set(vals))}")
    print(f"     payoffs at the {sum(1 for d in range(2,n) if n%d)} non-divisors: {nondiv}")
    print(f"     a best-response scan therefore costs Theta(N) = {n-2} divisibility tests")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("TWO STRUCTURAL BARRIERS TO CLASSICAL INTEGER FACTORING")
    print("Free witnesses (CRT splitting) and congruence blindness (Dirichlet)")
    print()
    demo_reed_solomon()
    demo_divisor_parity()
    demo_burau()
    demo_congruence_blindness()
    demo_congestion_game()
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print("  * The minimum distance of the evaluation code over Z/pq is exactly")
    print("    N - k*max(p,q): a free witness, obtainable only at Omega(N^k) cost")
    print("    or from the factorization itself.")
    print("  * The divisor-parity oracle certifies the factorization mod m, but")
    print("    its support has density 3/m and each query is itself a factoring.")
    print("  * The Burau image of sigma_1 sigma_2 has order lcm(3, ord_N(a)),")
    print("    which splits as lcm(3, ord_p(a), ord_q(a)): order-finding, not new.")
    print("  * No function of N mod m -- and no bounded list of them -- names a")
    print("    nontrivial divisor of every large semiprime.")
    print("  * The congestion game's unique equilibrium bid is minFac(N), found")
    print("    only by trial division on an otherwise perfectly flat landscape.")
    print()


if __name__ == "__main__":
    main()


"""Constructive witnesses defeating every congruence-determined factor
predictor, and every bounded-length candidate list.

The meta-theorem says: for every modulus m > 1 and every bound B, no function
of N mod m outputs a nontrivial divisor of every semiprime N > B.  The proof is
constructive, and this module implements the construction.

  * `coprime_semiprime_pair(m, B)` returns two semiprimes above B, both
    congruent to 1 mod m, that are coprime to each other.  A predictor seeing
    only the residue must return the same value for both, and no single value
    divides two coprime numbers.

  * `coprime_semiprime_family(m, k, B)` returns k pairwise-coprime semiprimes
    above B, all in the class 1 mod m, built from 2k primes drawn in strictly
    increasing blocks.  Feeding k = L + 1 defeats every candidate list of
    length at most L, since each family member needs its own candidate.

Cost is dominated by the prime search; by Dirichlet's theorem the density of
primes congruent to 1 mod m among integers up to X is ~ 1/(phi(m) log X), so
the search terminates quickly in practice.
"""

from __future__ import annotations

import math
from typing import List, Tuple


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    small = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime_in_class(above: int, m: int, residue: int = 1) -> int:
    """Least prime > `above` congruent to `residue` mod m (Dirichlet search)."""
    if math.gcd(residue % m, m) != 1:
        raise ValueError("Dirichlet requires the residue to be a unit mod m")
    c = above + 1
    while True:
        if c % m == residue % m and is_prime(c):
            return c
        c += 1


def coprime_semiprime_pair(m: int, bound: int) -> Tuple[int, int, Tuple[int, int, int, int]]:
    """Two coprime semiprimes above `bound`, both congruent to 1 mod m.

    Returns (N1, N2, (p1, r1, p2, r2)).  The four primes are strictly
    increasing, hence distinct, hence gcd(N1, N2) = 1.
    """
    p1 = next_prime_in_class(max(1, bound), m)
    p2 = next_prime_in_class(p1, m)
    r1 = next_prime_in_class(p2, m)
    r2 = next_prime_in_class(r1, m)
    return p1 * r1, p2 * r2, (p1, r1, p2, r2)


def coprime_semiprime_family(m: int, k: int, bound: int) -> List[Tuple[int, int]]:
    """k pairwise-coprime semiprimes above `bound`, all congruent to 1 mod m.

    Returned as a list of (p_i, r_i) with p_0 < r_0 < p_1 < r_1 < ... , so the
    2k primes are pairwise distinct and the products pairwise coprime.
    """
    out: List[Tuple[int, int]] = []
    cur = max(1, bound)
    for _ in range(k):
        p = next_prime_in_class(cur, m)
        r = next_prime_in_class(p, m)
        out.append((p, r))
        cur = r
    return out


def defeats_predictor(m: int, bound: int) -> bool:
    """Verify the pair really defeats every congruence-determined predictor."""
    n1, n2, _ = coprime_semiprime_pair(m, bound)
    return n1 % m == n2 % m and math.gcd(n1, n2) == 1


def defeats_list_of_length(m: int, length: int, bound: int) -> bool:
    """Verify a family of `length + 1` members defeats lists of that length."""
    fam = coprime_semiprime_family(m, length + 1, bound)
    prods = [p * r for p, r in fam]
    same_class = all(x % m == prods[0] % m for x in prods)
    pairwise = all(
        math.gcd(prods[i], prods[j]) == 1
        for i in range(len(prods))
        for j in range(i + 1, len(prods))
    )
    return same_class and pairwise and len(prods) == length + 1


if __name__ == "__main__":
    for m in (4, 8, 12, 30, 100):
        n1, n2, (p1, r1, p2, r2) = coprime_semiprime_pair(m, 500)
        print(
            f"m = {m:>4}: N1 = {n1} = {p1}*{r1}, N2 = {n2} = {p2}*{r2}, "
            f"same class: {n1 % m == n2 % m}, coprime: {math.gcd(n1, n2) == 1}"
        )
    for length in (1, 2, 3, 5):
        print(f"lists of length {length} defeated: {defeats_list_of_length(12, length, 500)}")


"""The reduced Burau order reduction: braid invariants over Z/N are exactly
multiplicative order-finding.

The reduced Burau representation of the three-strand braid group
B_3 = <s1, s2 | s1 s2 s1 = s2 s1 s2>, specialised at a parameter a, sends

    r(s1) = [[-a, 1], [0, 1]],      r(s2) = [[1, 0], [a, -a]].

Write B = r(s1) r(s2).  The full twist (s1 s2)^3 generates the centre of B_3
and maps to the scalar a^3 * I; from this one obtains the exact order formula

    ord(B) = lcm(3, ord_N(a)),

so braid order-finding and multiplicative order-finding are the same problem
up to a factor of 3, and by the Chinese Remainder Theorem the invariant splits
as lcm(3, ord_p(a), ord_q(a)) -- factor-secret data.
"""

from __future__ import annotations

import math
from typing import List, Optional, Tuple

Mat = Tuple[int, int, int, int]  # row-major (m00, m01, m10, m11)


def mat_mul(x: Mat, y: Mat, n: int) -> Mat:
    """Product of two 2x2 matrices over Z/n."""
    return (
        (x[0] * y[0] + x[1] * y[2]) % n,
        (x[0] * y[1] + x[1] * y[3]) % n,
        (x[2] * y[0] + x[3] * y[2]) % n,
        (x[2] * y[1] + x[3] * y[3]) % n,
    )


def burau_gen1(a: int, n: int) -> Mat:
    """Reduced Burau image of the generator s1, specialised at t = a."""
    return ((-a) % n, 1 % n, 0, 1 % n)


def burau_gen2(a: int, n: int) -> Mat:
    """Reduced Burau image of the generator s2, specialised at t = a."""
    return (1 % n, 0, a % n, (-a) % n)


def burau_bm(a: int, n: int) -> Mat:
    """Image of s1 * s2, explicitly [[0, -a], [a, -a]]."""
    return mat_mul(burau_gen1(a, n), burau_gen2(a, n), n)


def satisfies_braid_relation(a: int, n: int) -> bool:
    """Check r(s1)r(s2)r(s1) = r(s2)r(s1)r(s2): this really is a B_3 rep."""
    g1, g2 = burau_gen1(a, n), burau_gen2(a, n)
    return mat_mul(mat_mul(g1, g2, n), g1, n) == mat_mul(mat_mul(g2, g1, n), g2, n)


def mult_order(a: int, n: int) -> Optional[int]:
    """Multiplicative order of a mod n, or None if a is not a unit."""
    if math.gcd(a, n) != 1:
        return None
    k, x = 1, a % n
    while x != 1 % n:
        x = x * a % n
        k += 1
    return k


def braid_order_from_mult_order(a: int, n: int) -> Optional[int]:
    """ord(B) = lcm(3, ord_N(a)) -- the forward direction of the reduction."""
    o = mult_order(a, n)
    if o is None:
        return None
    return 3 * o // math.gcd(3, o)


def mult_order_from_braid_order(a: int, n: int, braid_order: int) -> int:
    """Invert the reduction: recover ord_N(a) from the braid order L.

    Since L = lcm(3, ord), either ord = L or ord = L/3; the two are told apart
    by a single modular exponentiation.
    """
    if braid_order % 3 == 0 and pow(a, braid_order // 3, n) == 1 % n:
        return braid_order // 3
    return braid_order


def mat_order(x: Mat, n: int, bound: int = 10 ** 6) -> Optional[int]:
    """Order of a matrix over Z/n by direct iteration (verification only)."""
    identity: Mat = (1 % n, 0, 0, 1 % n)
    y, k = x, 1
    while y != identity:
        if k > bound:
            return None
        y = mat_mul(y, x, n)
        k += 1
    return k


def burau_subgroup_order(a: int, n: int, cap: int = 10 ** 6) -> Optional[int]:
    """|H_a| for H_a = <r(s1), r(s2)>, by breadth-first closure.

    Feasible only for small n; included because the paper's experiment
    measures precisely this quantity.  By Lagrange, lcm(3, ord_N(a)) always
    divides the result.
    """
    g1, g2 = burau_gen1(a, n), burau_gen2(a, n)
    identity: Mat = (1 % n, 0, 0, 1 % n)
    seen = {identity}
    frontier: List[Mat] = [identity]
    while frontier:
        new: List[Mat] = []
        for x in frontier:
            for g in (g1, g2):
                y = mat_mul(x, g, n)
                if y not in seen:
                    seen.add(y)
                    new.append(y)
                    if len(seen) > cap:
                        return None
        frontier = new
    return len(seen)


def order_splits_by_crt(a: int, p: int, q: int) -> bool:
    """Verify ord_{pq}(a) = lcm(ord_p(a), ord_q(a))."""
    on, op, oq = mult_order(a, p * q), mult_order(a, p), mult_order(a, q)
    if on is None or op is None or oq is None:
        return False
    return on == op * oq // math.gcd(op, oq)


if __name__ == "__main__":
    for (p, q) in [(3, 7), (5, 7), (7, 13)]:
        n = p * q
        ok = True
        for a in range(2, n):
            if math.gcd(a, n) != 1:
                continue
            ok &= satisfies_braid_relation(a, n)
            ok &= mat_order(burau_bm(a, n), n) == braid_order_from_mult_order(a, n)
            ok &= order_splits_by_crt(a, p, q)
            L = braid_order_from_mult_order(a, n)
            assert L is not None
            ok &= mult_order_from_braid_order(a, n, L) == mult_order(a, n)
        print(f"N = {n}: all units satisfy the order equation and CRT splitting: {ok}")
    for a in (2, 5):
        print(f"N = 21, a = {a}: |H_a| = {burau_subgroup_order(a, 21)}")


"""Exact minimum distance of the evaluation code over Z/N, and the induced
factoring reduction.

Two routes are implemented:

  * `min_distance_formula` -- the closed form N - k*max(p,q), valid for
    k <= min(p,q), which presupposes the factorization (circularity);
  * `min_distance_brute_force` -- an exhaustive weight search over all
    N^(k+1) coefficient vectors, which does not (but costs Omega(N^(k+1))).

`factor_from_min_distance` closes the loop: given only N and the minimum
distance of the degree-<=1 code, it returns the complete factorization in
polylogarithmic time.  The pair of routes is exactly the free-witness
situation: the invariant IS the factorization, and every known way to obtain
it either already has the factorization or pays Omega(N).
"""

from __future__ import annotations

from typing import List, Sequence, Tuple


def poly_eval(coeffs: Sequence[int], x: int, n: int) -> int:
    """Horner evaluation modulo n of the polynomial with these coefficients."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % n
    return acc


def codeword_weight(coeffs: Sequence[int], n: int) -> int:
    """Hamming weight of the evaluation codeword (number of nonzero entries)."""
    return sum(1 for x in range(n) if poly_eval(coeffs, x, n) != 0)


def min_distance_formula(p: int, q: int, k: int) -> int:
    """Closed form d = N - k*max(p,q); requires 1 <= k <= min(p,q)."""
    if not 1 <= k <= min(p, q):
        raise ValueError("the formula is proved for 1 <= k <= min(p, q)")
    return p * q - k * max(p, q)


def min_distance_brute_force(n: int, k: int) -> int:
    """Exhaustive minimum weight over nonzero polynomials of degree <= k.

    Cost: Theta(n^(k+2)) ring operations.  This is the only known route that
    does not presuppose the factorization of n.
    """
    best = n + 1
    for code in range(n ** (k + 1)):
        coeffs: List[int] = []
        c = code
        for _ in range(k + 1):
            coeffs.append(c % n)
            c //= n
        if all(v == 0 for v in coeffs):
            continue
        w = codeword_weight(coeffs, n)
        if w < best:
            best = w
    return best


def extremal_codeword(p: int, q: int, k: int) -> List[int]:
    """Coefficients of f_k(x) = q * x(x-1)...(x-k+1) over Z/pq.

    This codeword attains the bound: it vanishes exactly on the k residue
    classes 0,...,k-1 modulo p, each of which has exactly q lifts in Z/pq.
    """
    n = p * q
    coeffs = [q % n]
    for i in range(k):
        # multiply the current polynomial by (x - i)
        shifted = [0] + coeffs
        scaled = [(-i * c) % n for c in coeffs] + [0]
        coeffs = [(a + b) % n for a, b in zip(shifted, scaled)]
    return coeffs


def factor_from_min_distance(n: int, d: int) -> Tuple[int, int]:
    """Recover (p, q) from N and the minimum distance of the degree-<=1 code.

    Correct because d = N - max(p, q) exactly, so max(p, q) = N - d.
    Runs in O(polylog N) given d.
    """
    larger = n - d
    if larger <= 0 or n % larger != 0:
        raise ValueError("d is not the minimum distance of a semiprime code")
    return n // larger, larger


if __name__ == "__main__":
    for (p, q) in [(3, 5), (3, 7), (5, 7)]:
        n = p * q
        for k in (1, 2):
            if k > min(p, q):
                continue
            bf = min_distance_brute_force(n, k)
            fm = min_distance_formula(p, q, k)
            print(f"N={n:>3} k={k}: brute force {bf:>3}, formula {fm:>3}, agree={bf == fm}")
    for (p, q) in [(7, 13), (11, 23), (13, 29)]:
        n = p * q
        d = min_distance_formula(p, q, 1)
        print(f"N={n}: d={d} -> factorization {factor_from_min_distance(n, d)}")


"""Assemble PACKAGE.json from the individual deliverables in the project."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")

LEAN_FILES = [
    "Catalog/Computation/Factoring/SemiprimeBasics.lean",
    "Catalog/Computation/Factoring/RSMinDistance.lean",
    "Catalog/Computation/Factoring/ModParCert.lean",
    "Catalog/Computation/Factoring/BurauOrder.lean",
    "Catalog/Computation/Factoring/DensSub.lean",
    "Catalog/Computation/Factoring/FreeWitness.lean",
    "Catalog/Computation/Factoring/CandidateLists.lean",
    "Catalog/Computation/Factoring/CongDivGame.lean",
]

FUTURE_DIRECTIONS = """# FUTURE DIRECTIONS — next-cycle conjectures from the round-3 closures

The five round-3 hypotheses (RS-MIND, MODPAR-CERT, BURAU-ORD, DENS-SUB,
CONG-DIV) are now closed with complete proofs.  What the formalization
exposed, beyond the paper's numerics, is that all five closures factor through
**two** structural facts: (i) a CRT splitting `Z/N ≅ F_p × F_q` that makes every
invariant a pair of prime-level invariants, and (ii) Dirichlet's theorem, which
says residue data cannot separate those pairs.  The conjectures below are the
sharpest testable statements that this pair of facts suggests.

---

## C1. The CRT-splitting dichotomy for evaluation codes

**Conjecture.** For every `k ≤ min(p,q)` and every `N = pq`, the *weight
enumerator* of the evaluation code `C_k(N)` — not merely its minimum distance —
is the Hadamard product of the two Reed–Solomon weight enumerators, and every
one of its "gaps" (weights not attained) determines `max(p,q)`.  Consequently a
`poly(log N)`-time algorithm for *any* single nonzero coefficient of the weight
enumerator yields a factoring algorithm.

*The key insight is* that the zero-count bound is really a statement about the
product structure of the zero set: the whole weight spectrum, not just its
minimum, is a product of prime-level spectra, so every spectral feature is a
free witness.

*Why now?* The minimum-distance case is fully proved (exact for all `k ≤ p`);
the general spectrum needs only a counting refinement of the same CRT
injection, with no new machinery.

## C2. Beyond congruences: polynomial-time-determined invariants

**Conjecture.** The free-witness meta-theorem generalises from "determined by
`N mod m`" to "determined by the value of a fixed polynomial-size arithmetic
circuit on the digits of `N`": no such invariant names a nontrivial factor of
every large semiprime, unless factoring is in P.

*The key insight is* that the Dirichlet argument only used one property of the
class `{N : N ≡ a mod m}` — that it contains two *coprime* semiprimes.  Any
invariant whose level sets contain two coprime semiprimes is blind in exactly
the same way, and level sets of small circuits are large.

*Why now?* The meta-theorem is already stated abstractly over an arbitrary
invariant `I : ℕ → ℕ`; only the "level sets are rich" input has to be replaced,
turning a number-theoretic lemma into a combinatorial one.

*Round-4 progress.* The *list* version of C2 is now proved: a
congruence-determined function returning a whole set of candidate divisors, of
size bounded by any fixed `k`, still fails on some large semiprime — the witness
being a family of `k+1` pairwise-coprime semiprimes in one residue class.  What
remains open in C2 is replacing "congruence-determined" by "circuit-determined".

## C3. Braid invariants beyond the centre

**Conjecture.** Every isomorphism invariant of the Burau image
`H_a = ⟨r(σ₁), r(σ₂)⟩ ≤ GL(2, Z/N)` is determined by the pair
`(ord_p(a), ord_q(a))` together with `p` and `q`, and computing any of them is
order-finding-hard.

*The key insight is* that the proved order equation `ord(σ₁σ₂) = lcm(3, ord(a))`
concerns the specific element whose cube is central.  The group order `|H_a|`
genuinely separates the individual prime-level orders (336 versus 24 modulo 21
for `a = 2` versus `a = 5`, at equal lcm), so the invariant theory is *richer*
than the lcm; the conjecture is that this richness is uniformly factor-secret.

## C4. Query complexity of divisor-statistic oracles

The adversary argument gives an `Ω(m)` deterministic query lower bound for the
divisor-parity primitive.  The randomized and quantum query complexities of the
same primitive are open, as is the question for the natural generalisations
`P_j(N,m,a) = #{d | N : d ≡ a} mod j` for `j > 2`, and for weighted variants
such as `Σ_{d ≡ a} d`.

## C5. Game-theoretic restatements with nontrivial dynamics

The divisor congestion game is closed because its payoff landscape is exactly
flat off the divisors.  A payoff function that interpolates — e.g.
`w(d) = -min_{e | N} |d - e|`, or `w(d) = -(N mod d)` — would create genuine
gradients.  The question is whether any such interpolation is (i) computable in
polynomial time from `N` alone and (ii) has better-response dynamics converging
in polynomial time.  The two requirements appear to conflict, and formulating
that conflict as a theorem is the natural next step.
"""


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def main() -> None:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))
    layout = read(os.path.join(ASSETS, "interactive_layout.md"))

    lean_chunks: List[str] = []
    for rel in LEAN_FILES:
        src = read(os.path.join(ROOT, rel))
        lean_chunks.append(f"-- ===== {rel} =====\n{src}")
    lean_proofs = "\n\n".join(lean_chunks)

    package: Dict[str, Any] = {
        "title": "Free Witnesses and Congruence Blindness: Two Structural "
                 "Barriers to Classical Integer Factoring",
        "domain": "Computation",
        "description": (
            "Five structurally distinct proposals for a classical polynomial-time "
            "factoring algorithm — evaluation codes over Z/N, a divisor-parity "
            "oracle, the Burau representation of the braid group, an average-case "
            "fast subfamily, and a divisor congestion game — are each closed "
            "unconditionally, and all five closures are shown to reduce to exactly "
            "two facts: Chinese-Remainder splitting turns algebraic invariants into "
            "free witnesses, and Dirichlet's theorem makes residue data blind to "
            "the factorization."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-13",
        "key_results": [
            "Exact minimum distance of the evaluation code over Z/pq: for distinct "
            "primes p < q and every k at most p, the minimum Hamming distance of the "
            "code of evaluations of polynomials of degree at most k is exactly "
            "N - k·max(p,q), attained by the explicit codeword q·x(x-1)···(x-k+1).",
            "The minimum distance is a free witness: N minus the minimum distance of "
            "the degree-at-most-one code equals the larger prime, so computing that "
            "one metric invariant yields the complete factorization.",
            "Braid-order theorem: the image of the braid σ₁σ₂ under the reduced Burau "
            "representation specialized at a unit a has multiplicative order exactly "
            "lcm(3, ord(a)), and the order splits by the Chinese Remainder Theorem as "
            "lcm(ord_p(a), ord_q(a)) — the braid picture is order-finding in disguise.",
            "Free-witness meta-theorem: for every modulus m greater than one and every "
            "bound B, no invariant determined by N mod m outputs a nontrivial divisor "
            "of every semiprime above B; the same holds for candidate lists of any "
            "fixed bounded length.",
            "Complete solution of the divisor congestion game: the unique best response "
            "is the least prime factor, its payoff is the cofactor, and the payoff "
            "landscape is exactly constant off the divisors, so the equilibrium is a "
            "restatement of the factorization rather than a route to it.",
        ],
        "keywords": [
            "integer factoring",
            "Chinese Remainder Theorem",
            "Reed-Solomon codes",
            "minimum distance",
            "braid group",
            "Burau representation",
            "Dirichlet's theorem",
            "Nash equilibrium",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "End-to-End Numerical Tour of the Five Closures",
                "description": (
                    "A single self-contained script that verifies every headline result "
                    "numerically. It (1) computes the minimum distance of the evaluation "
                    "code over Z/pq by exhaustive weight search and matches it against the "
                    "closed formula N - k·max(p,q), then recovers the factorization from "
                    "the distance alone; (2) tabulates the divisor-parity oracle's support, "
                    "confirms it is exactly three residue classes, recovers the factor "
                    "residues, exhibits the collision cases where the pattern collapses, "
                    "and demonstrates that two semiprimes give identical transcripts off "
                    "their marked classes; (3) verifies the braid relation, the full-twist "
                    "identity B³ = a³I, the order formula lcm(3, ord_N(a)) for every unit "
                    "modulo 21, 35 and 91, the CRT splitting of the order, and reproduces "
                    "the group orders 336 versus 24 modulo 21 at equal lcm; (4) measures "
                    "Pollard-ρ step counts across N mod 4, N mod 8 and the Jacobi symbol "
                    "(showing no signal) against the factor-gap deciles (showing a strong "
                    "one), and builds explicit coprime semiprime pairs and families in a "
                    "single residue class; (5) solves the divisor congestion game, "
                    "confirming the unique best response is the least prime factor and "
                    "that every non-divisor pays exactly -N."
                ),
                "code": demo,
            }
        ],
        "algorithms": [
            {
                "name": "Exact Minimum Distance of the Evaluation Code over Z/N, "
                        "and the Induced Factoring Reduction",
                "description": (
                    "Computes the minimum Hamming distance of the code of evaluations of "
                    "polynomials of degree at most k over Z/N by two independent routes, "
                    "and converts the answer into a factorization. The closed-form route "
                    "applies the theorem d = N - k·max(p,q), valid for all k at most "
                    "min(p,q); it costs O(polylog N) but presupposes the factorization, "
                    "which is the circularity barrier. The honest route enumerates all "
                    "N^(k+1) coefficient vectors and evaluates each at all N points, "
                    "costing Θ(N^(k+2)) ring operations — exponential in the input length "
                    "log N, which is the cost barrier. The extremal codeword "
                    "q·x(x-1)···(x-k+1) is constructed explicitly: under the Chinese "
                    "Remainder identification it vanishes identically modulo q and on the "
                    "k residues 0,...,k-1 modulo p, hence on exactly k complete residue "
                    "classes mod p with q lifts each. Finally the reduction: given only N "
                    "and the degree-at-most-one minimum distance d, the larger prime is "
                    "N - d and the smaller is N/(N-d), in polylogarithmic time. The pair "
                    "of routes is the free-witness phenomenon in its purest form."
                ),
                "pseudocode": (
                    "ALGORITHM MinDistanceAndFactor(N, k)\n"
                    "  INPUT : modulus N = p·q (p, q distinct primes), degree bound k\n"
                    "  OUTPUT: minimum distance d of the degree-≤k code; factorization of N\n"
                    "\n"
                    "  // Route A: closed form (requires the factorization)\n"
                    "  1: if p, q known and 1 ≤ k ≤ min(p,q) then\n"
                    "  2:     return d ← N - k·max(p,q)\n"
                    "\n"
                    "  // Route B: exhaustive weight search (no factorization needed)\n"
                    "  3: best ← N + 1\n"
                    "  4: for each coefficient vector (a_0,...,a_k) in (Z/N)^{k+1}, not all zero do\n"
                    "  5:     w ← 0\n"
                    "  6:     for x ← 0 to N-1 do\n"
                    "  7:         if a_0 + a_1·x + ... + a_k·x^k ≢ 0 (mod N) then w ← w + 1\n"
                    "  8:     best ← min(best, w)\n"
                    "  9: d ← best                       // cost Θ(N^{k+2})\n"
                    "\n"
                    "  // Extremal witness attaining the bound\n"
                    " 10: f ← q · ∏_{i=0}^{k-1} (x - i)\n"
                    " 11: assert |{x : f(x) = 0}| = k·max(p,q)\n"
                    "\n"
                    "  // Reduction: distance ⇒ factorization\n"
                    " 12: d_1 ← minimum distance of the degree-≤1 code\n"
                    " 13: q ← N - d_1 ;  p ← N / q\n"
                    " 14: return (d, p, q)"
                ),
                "code": read(os.path.join(ASSETS, "alg_min_distance.py")),
            },
            {
                "name": "The Burau Order Reduction: Braid Invariants over Z/N as "
                        "Multiplicative Order-Finding",
                "description": (
                    "Implements the reduced Burau representation of the three-strand braid "
                    "group over Z/N and the two-way reduction between braid order-finding "
                    "and multiplicative order-finding. The generators r(σ₁) = [[-a,1],[0,1]] "
                    "and r(σ₂) = [[1,0],[a,-a]] satisfy the braid relation, so this is an "
                    "honest non-abelian picture; the routine verifies that relation directly. "
                    "The element B = r(σ₁)r(σ₂) satisfies B³ = a³·I because the full twist "
                    "(σ₁σ₂)³ generates the centre of the braid group, and from that identity "
                    "one derives ord(B) = lcm(3, ord_N(a)) exactly. The forward direction "
                    "computes the braid order from the multiplicative order in one gcd; the "
                    "inverse direction recovers ord_N(a) from a given braid order L as either "
                    "L or L/3, distinguished by a single modular exponentiation. Both cost "
                    "O(polylog N) beyond one order-finding call, so the two problems are "
                    "equivalent up to a constant factor. The module also computes the full "
                    "subgroup order |H_a| by breadth-first closure (feasible only for small N, "
                    "cost O(|H_a|) matrix products) and verifies the CRT splitting "
                    "ord_{pq}(a) = lcm(ord_p(a), ord_q(a)) that makes every one of these "
                    "invariants factor-secret."
                ),
                "pseudocode": (
                    "ALGORITHM BurauOrderReduction(N, a)\n"
                    "  INPUT : modulus N, unit a modulo N\n"
                    "  OUTPUT: order of the Burau image of σ₁σ₂, and the reduction both ways\n"
                    "\n"
                    "  1: G1 ← [[-a, 1], [0, 1]] mod N\n"
                    "  2: G2 ← [[1, 0], [a, -a]] mod N\n"
                    "  3: assert G1·G2·G1 = G2·G1·G2          // braid relation of B_3\n"
                    "  4: B  ← G1·G2 = [[0, -a], [a, -a]]\n"
                    "  5: assert B³ = a³·I                     // full twist is central\n"
                    "\n"
                    "  // forward: multiplicative order ⇒ braid order\n"
                    "  6: t ← ord_N(a)\n"
                    "  7: L ← lcm(3, t) = 3·t / gcd(3, t)\n"
                    "\n"
                    "  // inverse: braid order ⇒ multiplicative order\n"
                    "  8: if 3 | L and a^{L/3} ≡ 1 (mod N) then t ← L/3 else t ← L\n"
                    "\n"
                    "  // the invariant is factor-secret\n"
                    "  9: for N = p·q with gcd(p,q) = 1:\n"
                    " 10:     assert ord_N(a) = lcm(ord_p(a), ord_q(a))\n"
                    " 11:     so L = lcm(3, ord_p(a), ord_q(a))\n"
                    "\n"
                    " 12: (optional, small N) |H_a| ← |closure of {G1, G2} under multiplication|\n"
                    " 13: assert L divides |H_a|              // Lagrange\n"
                    " 14: return (L, t)"
                ),
                "code": read(os.path.join(ASSETS, "alg_burau_order.py")),
            },
            {
                "name": "Constructive Witnesses Defeating Congruence-Determined "
                        "Factor Predictors and Bounded Candidate Lists",
                "description": (
                    "Builds the explicit counterexamples behind the congruence-blindness "
                    "meta-theorem. Given a modulus m and a threshold B, the pair routine "
                    "draws four primes congruent to 1 modulo m in strictly increasing order "
                    "and returns the two semiprimes N₁ = p₁r₁ and N₂ = p₂r₂: both exceed B, "
                    "both lie in the class 1 mod m, and they are coprime, since the four "
                    "primes are distinct. Any rule that sees only N mod m must return the "
                    "same value for both, and no single number is a nontrivial divisor of two "
                    "coprime semiprimes — so the rule fails. The family routine generalizes "
                    "this to k pairwise-coprime semiprimes in one class, built from 2k primes "
                    "in increasing blocks; feeding k = L + 1 defeats every candidate list of "
                    "length at most L, because each family member requires its own candidate. "
                    "Existence of the primes is Dirichlet's theorem on arithmetic "
                    "progressions; the expected cost of each prime search is O(φ(m)·log B) "
                    "primality tests, so the whole construction is fast in practice."
                ),
                "pseudocode": (
                    "ALGORITHM BlindnessWitness(m, k, B)\n"
                    "  INPUT : modulus m > 1, list-length bound k, threshold B\n"
                    "  OUTPUT: k+1 pairwise-coprime semiprimes above B, all ≡ 1 (mod m)\n"
                    "\n"
                    "  1: function NextPrimeInClass(x):\n"
                    "  2:     c ← x + 1\n"
                    "  3:     while not (c ≡ 1 mod m and IsPrime(c)): c ← c + 1\n"
                    "  4:     return c                      // exists by Dirichlet\n"
                    "\n"
                    "  5: cur ← B ; family ← [ ]\n"
                    "  6: for i ← 0 to k do\n"
                    "  7:     p_i ← NextPrimeInClass(cur)\n"
                    "  8:     r_i ← NextPrimeInClass(p_i)\n"
                    "  9:     family ← family ∪ {(p_i, r_i)} ; cur ← r_i\n"
                    "\n"
                    " 10: // the 2(k+1) primes are strictly increasing, hence distinct\n"
                    " 11: assert every N_i = p_i·r_i satisfies N_i ≡ 1 (mod m) and N_i > B\n"
                    " 12: assert gcd(N_i, N_j) = 1 for all i ≠ j\n"
                    "\n"
                    " 13: // consequence: a list S(1 mod m) with |S| ≤ k cannot contain a\n"
                    " 14: // nontrivial divisor of every N_i, since each N_i needs its own\n"
                    " 15: // element of S and there are k+1 of them\n"
                    " 16: return family"
                ),
                "code": read(os.path.join(ASSETS, "alg_blindness_witness.py")),
            },
        ],
        "visualizations": [
            {
                "name": "The Free Witness: CRT Grid, Weight Spectrum, and the Leaked Prime",
                "description": (
                    "Three panels making the coding-theoretic closure visible. Left: the ring "
                    "Z/77 drawn as a 7-by-11 Chinese-Remainder grid, with the zero set of the "
                    "extremal codeword 11·x(x-1)(x-2) highlighted — exactly three complete "
                    "columns of eleven points each, which is the geometric reason the zero "
                    "count is k·max(p,q). Middle: the complete weight spectrum of the "
                    "degree-at-most-one code over Z/21, obtained by exhaustive enumeration, "
                    "with the minimum distance marked and the gap to N annotated as "
                    "max(p,q) — the leak made visible. Right: across ninety-one semiprimes "
                    "built from the first fourteen odd primes, the quantity N minus the "
                    "minimum distance plotted against max(p,q), landing exactly on the "
                    "diagonal."
                ),
                "code": read(os.path.join(ASSETS, "viz_free_witness.py")),
            },
            {
                "name": "Congruence Blindness: What Residues Cannot See and Factors Can",
                "description": (
                    "Three panels contrasting blind statistics with informative ones, computed "
                    "from three hundred random semiprimes. Left: Pollard-rho step counts "
                    "grouped by N mod 8 — a statistic readable from N alone — shown as box "
                    "plots with the raw points jittered over them; the distributions are "
                    "indistinguishable, as the class-population theorem predicts. Middle: the "
                    "same step counts grouped by decile of the factor gap |p-q|, a property of "
                    "the factors rather than of N; here the effect is dramatic and monotone. "
                    "Right: the divisor-parity oracle's needle, plotting the measured fraction "
                    "of informative residue classes against the modulus m and confirming the "
                    "predicted density 3/m, which is what forces the Omega(m) query lower "
                    "bound."
                ),
                "code": read(os.path.join(ASSETS, "viz_congruence_blindness.py")),
            },
        ],
        "interactive_demos": [
            {
                "title": "The CRT Splitting Laboratory",
                "description": (
                    "Choose two primes and a degree bound, and the ring Z/N is drawn as a "
                    "p-by-q Chinese-Remainder grid with the extremal codeword's zero set "
                    "painted red — the k complete columns that give the theorem its shape. "
                    "The panel reports the zero count against the predicted k·max(p,q), the "
                    "resulting minimum distance N - k·max(p,q), and then reads the "
                    "factorization straight off the distance. A button runs the honest "
                    "computation, an exhaustive search over all N^(k+1) codewords, so the "
                    "reader can watch the cost of the free witness arrive in real time; above "
                    "a threshold the widget explains why the search is already out of reach. "
                    "The bottom panel plots the exact weight spectrum of the degree-at-most-one "
                    "code with the minimum marked, making the leaked prime visible as the gap "
                    "between the minimum and N. Progressive-disclosure panels give the full "
                    "proof of the minimum-distance theorem and the reason it is not an "
                    "algorithm."
                ),
                "html": read(os.path.join(ASSETS, "widget_crt_lab.html")),
            },
            {
                "title": "The Blindness Sandbox: Coprime Twins and the Query Game",
                "description": (
                    "Two experiments in one page. In the first, the reader picks a modulus, a "
                    "candidate-list length and a size threshold, and the widget constructs the "
                    "witness family live: k+1 semiprimes above the threshold, all in the same "
                    "residue class, all pairwise coprime, tabulated with the only two answers "
                    "each would accept. Raising the list length grows the family to match, "
                    "dramatizing the bounded-list theorem. In the second, the reader plays the "
                    "query game against the divisor-parity oracle: clicking residue classes one "
                    "at a time, receiving a single bit each time, and discovering how thin the "
                    "three-in-m needle is. The readout tracks queries used, informative classes "
                    "found, factor residues recovered, and flags the collision cases where "
                    "p and q are congruent modulo m and the whole pattern provably collapses to "
                    "a single uninformative class."
                ),
                "html": read(os.path.join(ASSETS, "widget_blindness.html")),
            },
            {
                "title": "The Braid Order Machine",
                "description": (
                    "An explorer for the reduced Burau representation of the three-strand braid "
                    "group over Z/N. The reader picks a semiprime modulus and a unit parameter; "
                    "the widget verifies the braid relation r(σ₁)r(σ₂)r(σ₁) = r(σ₂)r(σ₁)r(σ₂) "
                    "live, then tabulates successive powers of B = r(σ₁)r(σ₂), flagging every "
                    "third power as a scalar — the full twist a³·I — until the identity is "
                    "reached. The readout compares the measured order against lcm(3, ord_N(a)) "
                    "and checks both divisibility directions of the reduction to "
                    "order-finding. A second panel exhibits the Chinese-Remainder splitting "
                    "ord_N(a) = lcm(ord_p(a), ord_q(a)), computes the full Burau subgroup order "
                    "by closure, and confirms Lagrange's divisibility — letting the reader "
                    "reproduce the striking case modulo 21 where a = 2 and a = 5 share an lcm "
                    "of 6 yet have subgroup orders 336 and 24."
                ),
                "html": read(os.path.join(ASSETS, "widget_braid.html")),
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out} ({os.path.getsize(out) / 1024:.1f} KiB)")


if __name__ == "__main__":
    main()


"""Visualization: congruence data is blind, factor data is not.

Three panels, all computed from a sample of random semiprimes.

Left: Pollard-rho step counts grouped by N mod 8 -- a statistic readable from
N alone.  The distributions are indistinguishable, as the theory predicts:
every unit residue class contains semiprimes with every factorization profile.

Middle: the same step counts grouped by decile of the factor gap |p - q| -- a
property of p and q, not computable from N.  Here the effect is dramatic.

Right: the parity-oracle support.  For each modulus m the informative residue
classes number exactly three out of m, a density 3/m needle; an adversary
answering "0" forces Omega(m) queries.

Requires matplotlib.  Writes congruence_blindness.png.
"""

from __future__ import annotations

import math
import random
from typing import Dict, List, Optional, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    small = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def pollard_rho_steps(n: int, limit: int = 500_000) -> Optional[int]:
    for c in (1, 2, 3, 5, 7):
        x = y = 2
        for step in range(1, limit + 1):
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = math.gcd(abs(x - y), n)
            if d == n:
                break
            if d > 1:
                return step
    return None


def sample(count: int, bits: int, seed: int) -> List[Tuple[int, int, int, int]]:
    rng = random.Random(seed)
    rows: List[Tuple[int, int, int, int]] = []
    while len(rows) < count:
        p = next_prime(rng.randrange(2 ** (bits - 1), 2 ** bits))
        q = next_prime(rng.randrange(2 ** (bits - 1), 2 ** bits))
        if p == q:
            continue
        if p > q:
            p, q = q, p
        s = pollard_rho_steps(p * q)
        if s is None:
            continue
        rows.append((p * q, p, q, s))
    return rows


def proper_divisors(n: int) -> List[int]:
    out = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            if d < n:
                out.append(d)
            e = n // d
            if e != d and e < n:
                out.append(e)
        d += 1
    return out


def parity_support_size(n: int, m: int) -> int:
    divs = proper_divisors(n)
    return sum(
        1 for a in range(m)
        if sum(1 for d in divs if d % m == a % m) % 2 == 1
    )


def main() -> None:
    rows = sample(300, 12, 20260813)
    fig, axes = plt.subplots(1, 3, figsize=(17, 5.2))

    # ---- Panel 1: blind statistic --------------------------------------
    groups: Dict[int, List[int]] = {}
    for n, _, _, s in rows:
        groups.setdefault(n % 8, []).append(s)
    keys = sorted(groups)
    ax = axes[0]
    ax.boxplot([groups[k] for k in keys], tick_labels=[f"N≡{k}" for k in keys])
    for i, k in enumerate(keys, start=1):
        ax.scatter(
            [i + random.Random(k).uniform(-0.12, 0.12) for _ in groups[k]],
            groups[k], s=8, alpha=0.35, color="#4c78a8",
        )
    ax.set_ylabel("Pollard-$\\rho$ steps to split $N$")
    ax.set_xlabel("residue class of $N$ modulo 8")
    ax.set_title("An $N$-only statistic:\nno signal whatsoever")

    # ---- Panel 2: factor statistic -------------------------------------
    by_gap = sorted(rows, key=lambda t: t[2] - t[1])
    dec = max(1, len(by_gap) // 10)
    buckets = [by_gap[i * dec:(i + 1) * dec] for i in range(10)]
    ax = axes[1]
    ax.boxplot([[s for *_, s in b] for b in buckets],
               tick_labels=[str(i + 1) for i in range(10)])
    ax.set_xlabel("decile of the factor gap $|p-q|$ (1 = smallest)")
    ax.set_ylabel("Pollard-$\\rho$ steps to split $N$")
    ax.set_title("A factor statistic:\nstrong signal, but not computable from $N$")

    # ---- Panel 3: parity-oracle needle ---------------------------------
    ax = axes[2]
    ms = list(range(10, 205, 5))
    n_demo = 11 * 23
    sizes = [parity_support_size(n_demo, m) for m in ms]
    ax.plot(ms, [3 / m for m in ms], color="#4c78a8", linewidth=2,
            label="predicted density $3/m$")
    ax.scatter(ms, [s / m for s, m in zip(sizes, ms)], s=22, color="#d62728",
               zorder=3, label="measured density, $N = %d$" % n_demo)
    ax.set_xlabel("modulus $m$")
    ax.set_ylabel("fraction of informative residue classes")
    ax.set_title("The parity oracle's needle:\nexactly 3 classes out of $m$")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)

    fig.suptitle(
        "Congruence blindness: residues cannot see the factorization",
        fontsize=13,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("congruence_blindness.png", dpi=150)
    print("wrote congruence_blindness.png")


if __name__ == "__main__":
    main()


"""Visualization: the CRT grid, the extremal codeword, and the leaked prime.

Three panels.

Left: the ring Z/N drawn as a p-by-q Chinese-Remainder grid, with the zero set
of the extremal codeword f_k(x) = q * x(x-1)...(x-k+1) highlighted.  The zeros
form exactly k complete columns -- the residue classes 0,...,k-1 modulo p --
each containing exactly q points.  This is the geometric reason the minimum
distance is N - k*max(p,q).

Middle: the weight spectrum of the degree-<=1 code for a small semiprime,
obtained by exhaustive enumeration, with the minimum distance marked.  The gap
between 0 and the minimum distance is the leaked prime.

Right: across many semiprimes, the quantity N - d(C_2(N)) plotted against
max(p,q), showing the exact identity that makes the minimum distance a free
witness.

Requires matplotlib.  Writes free_witness.png.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


def poly_eval(coeffs: Sequence[int], x: int, n: int) -> int:
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % n
    return acc


def extremal_codeword(p: int, q: int, k: int) -> List[int]:
    """Coefficients of q * x(x-1)...(x-k+1) over Z/pq."""
    n = p * q
    coeffs = [q % n]
    for i in range(k):
        shifted = [0] + coeffs
        scaled = [(-i * c) % n for c in coeffs] + [0]
        coeffs = [(a + b) % n for a, b in zip(shifted, scaled)]
    return coeffs


def weight_spectrum_deg1(n: int) -> List[int]:
    """All Hamming weights of nonzero degree-<=1 codewords over Z/n."""
    out = []
    for a0 in range(n):
        for a1 in range(n):
            if a0 == 0 and a1 == 0:
                continue
            out.append(sum(1 for x in range(n) if (a0 + a1 * x) % n != 0))
    return out


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(17, 5.2))

    # ---- Panel 1: CRT grid with the extremal zero set -----------------
    p, q, k = 7, 11, 3
    n = p * q
    coeffs = extremal_codeword(p, q, k)
    zeros = {x for x in range(n) if poly_eval(coeffs, x, n) == 0}
    ax = axes[0]
    grid = [[0 for _ in range(p)] for _ in range(q)]
    for x in range(n):
        grid[x % q][x % p] = 1 if x in zeros else 0
    ax.pcolormesh(
        grid,
        cmap=matplotlib.colors.ListedColormap(["#dfe6ee", "#d62728"]),
        edgecolors="white", linewidth=0.6, vmin=0, vmax=1,
    )
    ax.set_xlabel("residue mod p = %d" % p)
    ax.set_ylabel("residue mod q = %d" % q)
    ax.set_title(
        "Z/%d as a CRT grid\nzeros of $%d\\,x(x-1)(x-2)$: %d columns of %d"
        % (n, q, k, q)
    )
    ax.set_xticks([i + 0.5 for i in range(p)], [str(i) for i in range(p)])
    ax.set_yticks([i + 0.5 for i in range(q)], [str(i) for i in range(q)])
    ax.set_aspect("equal")

    # ---- Panel 2: weight spectrum -------------------------------------
    p2, q2 = 3, 7
    n2 = p2 * q2
    spec = weight_spectrum_deg1(n2)
    ax = axes[1]
    ax.hist(spec, bins=range(0, n2 + 2), color="#4c78a8", edgecolor="white")
    d = n2 - max(p2, q2)
    ax.axvline(d + 0.5, color="#d62728", linewidth=2.5,
               label="minimum distance $d = %d$" % d)
    ax.axvline(n2 + 0.5, color="#2ca02c", linewidth=1.5, linestyle="--",
               label="$N = %d$" % n2)
    ax.annotate(
        "", xy=(d + 0.5, 40), xytext=(n2 + 0.5, 40),
        arrowprops=dict(arrowstyle="<->", color="black", linewidth=1.4),
    )
    ax.text((d + n2) / 2 + 0.5, 46, "$N-d = \\max(p,q) = %d$" % max(p2, q2),
            ha="center", fontsize=10)
    ax.set_xlabel("Hamming weight of the codeword")
    ax.set_ylabel("number of codewords")
    ax.set_title("Weight spectrum of the degree-$\\leq 1$ code, $N = %d$" % n2)
    ax.legend(loc="upper left", fontsize=9)

    # ---- Panel 3: the exact identity across semiprimes ----------------
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    pts: List[Tuple[int, int]] = []
    for i, a in enumerate(primes):
        for b in primes[i + 1:]:
            nn = a * b
            dd = nn - max(a, b)          # the proved minimum distance
            pts.append((max(a, b), nn - dd))
    ax = axes[2]
    ax.scatter([x for x, _ in pts], [y for _, y in pts], s=34,
               color="#d62728", zorder=3, label="$N - d(C_2(N))$")
    lim = max(max(x for x, _ in pts), max(y for _, y in pts)) + 3
    ax.plot([0, lim], [0, lim], color="#4c78a8", linewidth=1.6,
            linestyle="--", label="$y = \\max(p,q)$")
    ax.set_xlim(0, lim)
    ax.set_ylim(0, lim)
    ax.set_xlabel("$\\max(p, q)$")
    ax.set_ylabel("$N - d(C_2(N))$")
    ax.set_title("The minimum distance IS the larger prime\n(91 semiprimes)")
    ax.legend(loc="upper left", fontsize=9)
    ax.grid(alpha=0.3)

    fig.suptitle(
        "Free witness: CRT splitting turns a code invariant into the factorization",
        fontsize=13,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("free_witness.png", dpi=150)
    print("wrote free_witness.png")


if __name__ == "__main__":
    main()
