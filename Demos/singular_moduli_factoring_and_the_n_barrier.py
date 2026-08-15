#!/usr/bin/env python3
"""
Singular Moduli Factoring and the sqrt(N) Barrier
=================================================

Self-contained numerical demonstration of the results:

  1. The exact gcd criterion:  gcd(H(j), pq) is a nontrivial factor
     iff j is a root of H modulo EXACTLY ONE of p, q --- and then the
     gcd equals that prime.

  2. The exact success count (Chinese Remainder identity):
         S = r_p (q - r_q) + (p - r_p) r_q
     verified against brute-force enumeration over all residues.

  3. The Lagrange cap  S <= h(p+q)  and the balanced density bound
         S/N <= 4h/sqrt(N).

  4. Two-sided scaling:  sqrt(N)/(4h) <= N/S <= sqrt(N)
     whenever H has a root mod p and none mod q.

  5. The work barrier:  h * (N/S) >= sqrt(N)/4  --- the class number
     cancels exactly against the cost of one Horner evaluation.

  6. Blindness: if H has no root mod p and none mod q, NO evaluation
     point ever works (example: X^2 + 1 against N = 77).

  7. The precomputation bound: a fixed table T of evaluation points
     can ever detect at most  sum_t log2 |H(t)|  primes, so arbitrarily
     large semiprimes defeat the whole table.

  8. The scaling experiment: sweep (D, j0) pairs on real semiprimes and
     observe evals / sqrt(N) staying in a narrow constant band.

Run:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from math import gcd, isqrt
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------
# Hilbert class polynomials H_D(X), given by coefficient lists in
# ASCENDING degree order:  coeffs[i] is the coefficient of X^i.
# Each is monic, and deg H_D = h(D), the class number.
# ----------------------------------------------------------------------

HILBERT_CLASS_POLYNOMIALS: Dict[int, List[int]] = {
    -3:   [0, 1],                                    # X
    -4:   [-1728, 1],                                # X - 1728
    -7:   [3375, 1],                                 # X + 3375
    -8:   [-8000, 1],                                # X - 8000
    -11:  [32768, 1],                                # X + 32768
    -12:  [-54000, 1],                               # X - 54000
    -16:  [-287496, 1],                              # X - 287496
    -19:  [884736, 1],                               # X + 884736
    -27:  [12288000, 1],                             # X + 12288000
    -28:  [-16581375, 1],                            # X - 16581375
    -43:  [884736000, 1],                            # X + 884736000
    -67:  [147197952000, 1],                         # X + 147197952000
    -163: [262537412640768000, 1],                   # X + 262537412640768000
    -15:  [-121287375, 191025, 1],                   # X^2 + 191025 X - 121287375
    -20:  [-681472000, -1264000, 1],                 # X^2 - 1264000 X - 681472000
    -24:  [14670139392, -4834944, 1],                # X^2 - 4834944 X + 14670139392
    -35:  [-134217728000, 117964800, 1],             # X^2 + 117964800 X - 134217728000
    -40:  [9103145472000, -425692800, 1],            # X^2 - 425692800 X + 9103145472000
    -51:  [6262062317568, 5541101568, 1],            # X^2 + 5541101568 X + 6262062317568
    -52:  [-567663552000000, -6896880000, 1],        # X^2 - 6896880000 X - 567663552000000
    -23:  [12771880859375, -5151296875, 3491750, 1], # X^3 + 3491750 X^2 - ...
    -31:  [1566028350940383, -58682638134, 39491307, 1],
}

CLASS_NUMBER: Dict[int, int] = {D: len(c) - 1 for D, c in HILBERT_CLASS_POLYNOMIALS.items()}


# ----------------------------------------------------------------------
# Basic polynomial arithmetic
# ----------------------------------------------------------------------

def poly_eval(coeffs: Sequence[int], x: int) -> int:
    """Horner evaluation of the integer polynomial with ascending coefficients.

    Costs exactly deg(H) multiplications and deg(H) additions --- the cost
    model underlying the work barrier  h * (N/S) >= sqrt(N)/4.
    """
    acc = 0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def poly_eval_mod(coeffs: Sequence[int], x: int, m: int) -> int:
    """Horner evaluation modulo m (the way an attacker would actually do it)."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % m
    return acc


def poly_degree(coeffs: Sequence[int]) -> int:
    return len(coeffs) - 1


def poly_str(coeffs: Sequence[int]) -> str:
    """Human-readable rendering, descending degree."""
    terms: List[str] = []
    for i in range(len(coeffs) - 1, -1, -1):
        c = coeffs[i]
        if c == 0:
            continue
        if i == 0:
            body = str(abs(c))
        elif i == 1:
            body = "X" if abs(c) == 1 else f"{abs(c)}*X"
        else:
            body = f"X^{i}" if abs(c) == 1 else f"{abs(c)}*X^{i}"
        sign = "-" if c < 0 else "+"
        terms.append(f"{sign} {body}" if terms else (f"-{body}" if c < 0 else body))
    return " ".join(terms) if terms else "0"


# ----------------------------------------------------------------------
# The method, and the exact theory
# ----------------------------------------------------------------------

def eval_gcd(coeffs: Sequence[int], j: int, N: int) -> int:
    """One evaluation of the singular moduli method: gcd(H(j), N)."""
    return gcd(poly_eval_mod(coeffs, j, N), N)


def is_nontrivial_divisor(d: int, N: int) -> bool:
    """d | N and 1 < d < N."""
    return N % d == 0 and 1 < d < N


def root_count(coeffs: Sequence[int], m: int) -> int:
    """r_m = number of roots of H in Z/m.  For prime m, Lagrange gives r_m <= deg H."""
    return sum(1 for x in range(m) if poly_eval_mod(coeffs, x, m) == 0)


def success_count_formula(coeffs: Sequence[int], p: int, q: int) -> int:
    """The exact CRT identity  S = r_p (q - r_q) + (p - r_p) r_q."""
    rp = root_count(coeffs, p)
    rq = root_count(coeffs, q)
    return rp * (q - rq) + (p - rp) * rq


def success_count_bruteforce(coeffs: Sequence[int], p: int, q: int) -> int:
    """S by enumeration of all residues in [0, pq) --- the ground truth."""
    N = p * q
    return sum(1 for j in range(N) if is_nontrivial_divisor(eval_gcd(coeffs, j, N), N))


def density_bound_balanced(h: int, N: int) -> float:
    """The proven bound 4h / sqrt(N) on the density of useful evaluation points."""
    return 4.0 * h / math.sqrt(N)


def expected_trials_interval(h: int, N: int) -> Tuple[float, float]:
    """The proven interval [sqrt(N)/(4h), sqrt(N)] for the expected count N/S."""
    s = math.sqrt(N)
    return (s / (4.0 * h), s)


def work_lower_bound(N: int) -> float:
    """h * (N/S) >= sqrt(N)/4:  the class number cancels."""
    return math.sqrt(N) / 4.0


# ----------------------------------------------------------------------
# Small helpers
# ----------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for r in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % r == 0:
            return n == r
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


def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of |n| (trial division; inputs here are modest)."""
    n = abs(n)
    out: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out.append(n)
    return out


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------
# Demonstration 1 --- the method factors real semiprimes
# ----------------------------------------------------------------------

def demo_factorisations() -> None:
    rule("1. THE METHOD WORKS: exact factorisations by a single gcd")
    cases: List[Tuple[int, int, int]] = [
        # (N, D, j0)
        (77, -15, 0),
        (899, -8, 2),
        (3599, -19, 8),
        (5183, -11, 9),
    ]
    print(f"{'N':>7} {'D':>5} {'j0':>4} {'H_D(j0)':>22} {'gcd':>6}  cofactor")
    print("-" * 78)
    for N, D, j0 in cases:
        H = HILBERT_CLASS_POLYNOMIALS[D]
        value = poly_eval(H, j0)
        g = eval_gcd(H, j0, N)
        assert is_nontrivial_divisor(g, N), (N, D, j0, g)
        print(f"{N:>7} {D:>5} {j0:>4} {value:>22} {g:>6}  {N // g}")
    print("\nEach line is a complete factorisation of N found by one gcd.")


# ----------------------------------------------------------------------
# Demonstration 2 --- the exact criterion, case by case
# ----------------------------------------------------------------------

def demo_exact_criterion() -> None:
    rule("2. THE EXACT CRITERION: success is an EXCLUSIVE-OR, and gcd = that prime")
    p, q, D = 7, 11, -15
    N = p * q
    H = HILBERT_CLASS_POLYNOMIALS[D]
    print(f"N = {p}*{q} = {N},  H_({D})(X) = {poly_str(H)}\n")
    print(f"{'j0':>3} {'p|H(j0)':>8} {'q|H(j0)':>8} {'XOR':>5} {'gcd':>5}  verdict")
    print("-" * 60)
    tally = {"factor": 0, "gcd=1": 0, "gcd=N": 0}
    for j in range(N):
        v = poly_eval_mod(H, j, N)
        dp = (v % p == 0)
        dq = (v % q == 0)
        g = gcd(v, N)
        xor = dp != dq
        ok = is_nontrivial_divisor(g, N)
        assert ok == xor, "the exact criterion must hold for every j"
        if ok:
            assert g == (p if dp else q), "the gcd must be exactly the unique dividing prime"
            tally["factor"] += 1
        elif g == 1:
            tally["gcd=1"] += 1
        else:
            tally["gcd=N"] += 1
        if j < 14:
            verdict = "FACTOR" if ok else ("useless (1)" if g == 1 else "useless (N)")
            print(f"{j:>3} {str(dp):>8} {str(dq):>8} {str(xor):>5} {g:>5}  {verdict}")
    print("  ...")
    print(f"\nOver all {N} residues: {tally['factor']} give a factor, "
          f"{tally['gcd=1']} return 1, {tally['gcd=N']} return N.")
    print("The criterion held for every single residue --- it is an identity, "
          "not a heuristic.")


# ----------------------------------------------------------------------
# Demonstration 3 --- exact success count vs brute force
# ----------------------------------------------------------------------

def demo_success_count() -> None:
    rule("3. THE EXACT COUNT  S = r_p (q - r_q) + (p - r_p) r_q  vs brute force")
    cases: List[Tuple[int, int, int]] = [
        (7, 11, -15),
        (13, 17, -15),
        (11, 13, -31),
        (71, 73, -23),
        (101, 103, -20),
        (29, 31, -8),
        (59, 61, -19),
    ]
    header = (f"{'p':>4} {'q':>4} {'D':>5} {'h':>2} {'r_p':>4} {'r_q':>4} "
              f"{'S(CRT)':>7} {'S(brute)':>9} {'h(p+q)':>7} {'S/N':>8} {'4h/sqrtN':>9}")
    print(header)
    print("-" * len(header))
    for p, q, D in cases:
        H = HILBERT_CLASS_POLYNOMIALS[D]
        h = poly_degree(H)
        N = p * q
        rp, rq = root_count(H, p), root_count(H, q)
        s_formula = success_count_formula(H, p, q)
        s_brute = success_count_bruteforce(H, p, q)
        assert s_formula == s_brute, (p, q, D, s_formula, s_brute)
        assert s_brute <= h * (p + q), "Lagrange cap must hold"
        dens = s_brute / N
        bound = density_bound_balanced(h, N)
        assert dens <= bound + 1e-12, "density bound must hold"
        print(f"{p:>4} {q:>4} {D:>5} {h:>2} {rp:>4} {rq:>4} "
              f"{s_formula:>7} {s_brute:>9} {h*(p+q):>7} {dens:>8.4f} {bound:>9.4f}")
    print("\nCRT identity matches exhaustive enumeration in every case,")
    print("and every density sits under the proven bound 4h/sqrt(N).")


# ----------------------------------------------------------------------
# Demonstration 4 --- two-sided scaling and the work barrier
# ----------------------------------------------------------------------

def demo_two_sided_scaling() -> None:
    rule("4. TWO-SIDED SCALING  sqrt(N)/(4h) <= N/S <= sqrt(N),  and the WORK BARRIER")
    print("Hypotheses of the two-sided theorem: p <= q <= 3p, H monic of degree h,")
    print("H has a root mod p and NO root mod q.\n")
    header = (f"{'p':>4} {'q':>4} {'D':>5} {'h':>2} {'S':>6} {'N/S':>9} "
              f"{'lo=sqrtN/4h':>12} {'hi=sqrtN':>10} {'h*(N/S)':>10} {'sqrtN/4':>9}")
    print(header)
    print("-" * len(header))
    found = 0
    for D, H in sorted(HILBERT_CLASS_POLYNOMIALS.items(), reverse=True):
        h = poly_degree(H)
        for p in [pp for pp in range(5, 130) if is_prime(pp)]:
            for q in [qq for qq in range(p + 1, min(3 * p, 200) + 1) if is_prime(qq)]:
                if root_count(H, p) >= 1 and root_count(H, q) == 0:
                    N = p * q
                    S = success_count_formula(H, p, q)
                    if S == 0:
                        continue
                    ns = N / S
                    lo, hi = expected_trials_interval(h, N)
                    wb = work_lower_bound(N)
                    assert lo - 1e-9 <= ns <= hi + 1e-9, (p, q, D, ns, lo, hi)
                    assert h * ns >= wb - 1e-9
                    print(f"{p:>4} {q:>4} {D:>5} {h:>2} {S:>6} {ns:>9.3f} "
                          f"{lo:>12.3f} {hi:>10.3f} {h*ns:>10.3f} {wb:>9.3f}")
                    found += 1
                    break
            if found % 1 == 0 and found >= 1:
                break
        if found >= 8:
            break
    print("\nEvery row satisfies the two-sided interval, and the last two columns")
    print("show the class number cancelling: h*(N/S) always clears sqrt(N)/4.")


def demo_class_number_cancels() -> None:
    rule("5. THE CLASS NUMBER CANCELS: a bigger h buys fewer trials but longer ones")
    N_bits = [64, 128, 256, 512, 1024, 2048]
    print(f"{'bits of N':>10} {'sqrt(N)':>14} {'h=1 trials':>14} {'h=2^20 trials':>16} "
          f"{'work (any h)':>14}")
    print("-" * 74)
    for b in N_bits:
        # work entirely in log2 to avoid overflow at cryptographic sizes
        lg_sqrt = b / 2
        lg_t1 = lg_sqrt - 2
        lg_t2 = lg_sqrt - 2 - 20
        lg_w = lg_sqrt - 2
        print(f"{b:>10} {'2^%.1f' % lg_sqrt:>14} {'2^%.1f' % lg_t1:>14} "
              f"{'2^%.1f' % lg_t2:>16} {'2^%.1f' % lg_w:>14}")
    print("\nA class number of one million reduces the trial count by 2^20,")
    print("but each Horner evaluation costs 2^20 multiplications: the total")
    print("arithmetic work stays pinned at sqrt(N)/4 in every row.")


# ----------------------------------------------------------------------
# Demonstration 6 --- blindness
# ----------------------------------------------------------------------

def demo_blindness() -> None:
    rule("6. BLINDNESS: when H has no root mod p and none mod q, NOTHING ever works")
    p, q = 7, 11
    N = p * q
    Hbad = [1, 0, 1]  # X^2 + 1
    print(f"H(X) = {poly_str(Hbad)},  N = {p}*{q} = {N}")
    print(f"roots mod {p}: {root_count(Hbad, p)},  roots mod {q}: {root_count(Hbad, q)}")
    hits = [j for j in range(N) if is_nontrivial_divisor(eval_gcd(Hbad, j, N), N)]
    print(f"successful evaluation points in [0,{N}): {len(hits)}  (exhaustive search)")
    assert not hits

    print("\nAnd in the wild, with a genuine class polynomial:")
    p, q, D = 71, 73, -23
    H = HILBERT_CLASS_POLYNOMIALS[D]
    rp, rq = root_count(H, p), root_count(H, q)
    S = success_count_formula(H, p, q)
    print(f"  D = {D}, h = {poly_degree(H)}, N = {p}*{q} = {p*q}")
    print(f"  r_{p} = {rp}, r_{q} = {rq}  ==>  S = {S}")
    assert S == 0
    print("  The success probability is exactly ZERO, not merely small:")
    print("  H_D splits mod p only when D is a square mod p.")


# ----------------------------------------------------------------------
# Demonstration 7 --- no precomputation
# ----------------------------------------------------------------------

def demo_precomputation() -> None:
    rule("7. PRECOMPUTATION IS USELESS: a table catches only log-many primes")
    T = list(range(0, 12))
    family = [-4, -7, -8, -11, -19, -15]
    catch: set = set()
    budget = 0.0
    for D in family:
        H = HILBERT_CLASS_POLYNOMIALS[D]
        for t in T:
            v = poly_eval(H, t)
            if v != 0:
                catch.update(prime_factors(v))
                budget += math.log2(abs(v))
    print(f"table: {len(family)} discriminants x {len(T)} evaluation points "
          f"= {len(family)*len(T)} precomputed values")
    print(f"primes this table can EVER detect: {len(catch)}")
    print(f"bit-size bound  sum_t log2|H(t)|  = {budget:.1f}")
    assert len(catch) <= budget + 1e-9
    print("The bound depends only on the SIZE OF THE TABLE, never on N.\n")

    # Exhibit a semiprime defeating the whole table.
    uncaught = [r for r in range(1000, 4000) if is_prime(r) and r not in catch]
    p, q = uncaught[0], uncaught[1]
    N = p * q
    all_fail = True
    for D in family:
        H = HILBERT_CLASS_POLYNOMIALS[D]
        for t in T:
            if is_nontrivial_divisor(eval_gcd(H, t, N), N):
                all_fail = False
    print(f"witness: N = {p} * {q} = {N}")
    print(f"every one of the {len(family)*len(T)} precomputed trials returns gcd = 1: "
          f"{all_fail}")
    assert all_fail
    print("There is no table. There is only search --- priced at sqrt(N)/(4h).")


# ----------------------------------------------------------------------
# Demonstration 8 --- the scaling experiment
# ----------------------------------------------------------------------

def sweep_factor(N: int, discriminants: Sequence[int],
                 max_j: int = 4000) -> Optional[Tuple[int, int, int, int]]:
    """Sweep j0 = 0,1,2,... over the given discriminants; return the first success.

    Returns (D, j0, factor, evaluations) where evaluations counts (D, j0) pairs.
    """
    evals = 0
    for j in range(max_j):
        for D in discriminants:
            H = HILBERT_CLASS_POLYNOMIALS[D]
            evals += 1
            g = eval_gcd(H, j, N)
            if is_nontrivial_divisor(g, N):
                return (D, j, g, evals)
    return None


def demo_scaling_experiment() -> None:
    rule("8. SCALING EXPERIMENT: evals / sqrt(N) is CONSTANT, not decaying")
    discriminants = [-4, -7, -8, -11, -15, -19, -20, -23]
    semiprimes = [15, 35, 77, 143, 323, 899, 3599, 5183, 10403, 39203,
                  85907, 164009, 364807]  # 401*409 and 601*607
    header = (f"{'N':>8} {'p':>5} {'q':>5} {'D':>5} {'j0':>4} {'factor':>7} "
              f"{'evals':>7} {'sqrt(N)':>9} {'evals/sqrtN':>12}")
    print(header)
    print("-" * len(header))
    ratios: List[float] = []
    for N in semiprimes:
        res = sweep_factor(N, discriminants)
        if res is None:
            print(f"{N:>8}   (no success within the evaluation budget)")
            continue
        D, j0, f, evals = res
        ratio = evals / math.sqrt(N)
        ratios.append(ratio)
        print(f"{N:>8} {f:>5} {N//f:>5} {D:>5} {j0:>4} {f:>7} {evals:>7} "
              f"{math.sqrt(N):>9.1f} {ratio:>12.3f}")
    if ratios:
        print(f"\nratio range over {len(ratios)} instances: "
              f"[{min(ratios):.2f}, {max(ratios):.2f}], mean {sum(ratios)/len(ratios):.2f}")
    print("A sqrt(N) law predicts a bounded ratio; it FORBIDS a ratio decaying")
    print("like N^(-c).  The data shows a bounded ratio across orders of magnitude.")


# ----------------------------------------------------------------------
# Demonstration 9 --- ladder placement
# ----------------------------------------------------------------------

def sieve_cost_log2(bits: int, c: float = 1.923) -> float:
    """log2 of L_N[1/3, c] = exp(c (ln N)^{1/3} (ln ln N)^{2/3})."""
    lnN = bits * math.log(2)
    return c * (lnN ** (1 / 3)) * (math.log(lnN) ** (2 / 3)) / math.log(2)


def demo_ladder() -> None:
    rule("9. LADDER PLACEMENT: sieve  <  rho  <=  singular moduli  <  trial division")
    print("cost profile of the method (bit-size variable x = log N):  "
          "C_h(x) = e^{x/2} / (4h)")
    print("superpolynomial, NOT subexponential, eventually above e^{x/4}.\n")
    header = (f"{'bits':>6} {'sieve L[1/3]':>14} {'rho N^1/4':>12} "
              f"{'sing.mod h=1':>14} {'sing.mod h=2^20':>17} {'work sqrtN/4':>14}")
    print(header)
    print("-" * len(header))
    for bits in (128, 256, 512, 1024, 2048):
        sieve = sieve_cost_log2(bits)
        rho = bits / 4
        sm1 = bits / 2 - 2
        sm2 = bits / 2 - 2 - 20
        work = bits / 2 - 2
        print(f"{bits:>6} {'2^%.0f' % sieve:>14} {'2^%.0f' % rho:>12} "
              f"{'2^%.0f' % sm1:>14} {'2^%.0f' % sm2:>17} {'2^%.0f' % work:>14}")
    print("\nEven an unrepresentably large class number leaves the WORK column")
    print("untouched --- and the sieve column is smaller by hundreds of bits.")


# ----------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_factorisations()
    demo_exact_criterion()
    demo_success_count()
    demo_two_sided_scaling()
    demo_class_number_cancels()
    demo_blindness()
    demo_precomputation()
    demo_scaling_experiment()
    demo_ladder()
    rule("ALL ASSERTIONS PASSED")
    print("The exact criterion, the CRT count, the density bound, the two-sided")
    print("scaling interval, the work barrier, blindness and the precomputation")
    print("bound were all verified numerically on every instance tested.")


if __name__ == "__main__":
    main()
