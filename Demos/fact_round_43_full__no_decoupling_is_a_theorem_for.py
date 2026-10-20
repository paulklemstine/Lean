#!/usr/bin/env python3
"""
No-decoupling for quadratic-form sieving: numerical demonstrations.

Self-contained (standard library only).  Every section illustrates one theorem:

  1. Discriminant identity and "columns = split set" for x^2 - N.
  2. Silverman multi-polynomial forms share the discriminant 4N, hence the
     SAME column set (about 1/2 of the primes), while two UNRELATED
     discriminants intersect in about 1/4.
  3. Large primes of partial relations are split; an LP-pair adds no new
     odd-exponent column.
  4. The row-side lever: with T forms sharing one discriminant,
     |split set| + 1 smooth values always contain a square sub-product,
     whatever T is.
  5. The complete-cost rule: the elasticity of S + L is the cost-share
     weighted average of the elasticities, so sieve-only pricing can invert
     the sign.
  6. The Silverman minimax M*sqrt(N/2) and the failure of the gate
     B^2 * M <~ sqrt(N/2) at 42 bits.
  7. The boundary: a cubic value x^3 - N has non-split prime divisors.
"""
from __future__ import annotations

import math
import random
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# Elementary number theory
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_p = bytearray([1]) * (n + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, math.isqrt(n) + 1):
        if is_p[i]:
            is_p[i * i:: i] = bytearray(len(is_p[i * i:: i]))
    return [i for i in range(n + 1) if is_p[i]]


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3e24."""
    if n < 2:
        return False
    small = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
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


def is_square_mod(D: int, p: int) -> bool:
    """Is D a square in Z/pZ?  (0 counts as a square, as in the theorems.)"""
    D %= p
    if D == 0 or p == 2:
        return True
    return pow(D, (p - 1) // 2, p) == 1


def sqrt_mod(a: int, p: int) -> int:
    """Tonelli-Shanks square root of a quadratic residue a modulo an odd prime p."""
    a %= p
    if a == 0:
        return 0
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(a, q, p), pow(a, (q + 1) // 2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2 * t2 % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c, t, r = i, b * b % p, t * b * b % p, r * b % p
    return r


def split_set(D: int, B: int) -> List[int]:
    """Admissible ('split') primes p <= B: those at which D is a square mod p."""
    return [p for p in primes_up_to(B) if is_square_mod(D, p)]


def factor_over(v: int, base: Sequence[int]) -> Optional[Dict[int, int]]:
    """Factor |v| over the base; return exponents, or None if not smooth."""
    v = abs(v)
    if v == 0:
        return None
    exps: Dict[int, int] = {}
    for p in base:
        if v % p == 0:
            e = 0
            while v % p == 0:
                v //= p
                e += 1
            exps[p] = e
        if v == 1:
            break
    return exps if v == 1 else None


# ---------------------------------------------------------------------------
# Quadratic forms
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class QForm:
    A: int
    B: int
    C: int

    def eval(self, x: int) -> int:
        return self.A * x * x + self.B * x + self.C

    @property
    def disc(self) -> int:
        return self.B * self.B - 4 * self.A * self.C


def silverman_forms(N: int, B: int, T: int, M: int) -> List[QForm]:
    """
    T Silverman forms f(x) = A x^2 + 2 b x + c with A = q^2, b^2 - N = A c.
    Every one has discriminant (2b)^2 - 4Ac = 4N.  q is a prime > B with
    (N/q) = 1, chosen near the ideal size sqrt(sqrt(2N)/M).
    """
    forms: List[QForm] = []
    q = max(B + 1, math.isqrt(math.isqrt(2 * N) // M))
    while len(forms) < T:
        q += 1
        if not is_prime(q) or q % 2 == 0 or N % q == 0 or not is_square_mod(N, q):
            continue
        r = sqrt_mod(N, q)
        # Hensel lift r to a root modulo q^2.
        A = q * q
        k = ((N - r * r) // q) * pow(2 * r, -1, q) % q
        b = (r + k * q) % A
        assert (b * b - N) % A == 0
        c = (b * b - N) // A
        forms.append(QForm(A, 2 * b, c))
    return forms


def observed_columns(f: QForm, base: Sequence[int], xs: range) -> Set[int]:
    """Primes of the base that divide at least one value f(x), x in xs."""
    cols: Set[int] = set()
    for p in base:
        for x in range(min(len(xs), 2 * p + 2)):
            if f.eval(xs[x]) % p == 0:
                cols.add(p)
                break
    return cols


# ---------------------------------------------------------------------------
# GF(2) linear algebra
# ---------------------------------------------------------------------------

def gf2_dependency(vectors: List[int]) -> Optional[List[int]]:
    """
    Given bit-vectors (ints), return indices of a nonempty subset XOR-ing to 0,
    or None.  Gaussian elimination with combination tracking.
    """
    pivots: Dict[int, Tuple[int, int]] = {}  # leading bit -> (vector, combination mask)
    for i, v in enumerate(vectors):
        comb = 1 << i
        while v:
            lead = v.bit_length() - 1
            if lead not in pivots:
                pivots[lead] = (v, comb)
                break
            pv, pc = pivots[lead]
            v ^= pv
            comb ^= pc
        if v == 0:
            return [j for j in range(len(vectors)) if comb >> j & 1]
    return None


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 78 + "\n" + title + "\n" + "=" * 78)


def demo_columns_equal_split(N: int, B: int) -> None:
    banner("1. Discriminant identity and columns = split set  (f(x) = x^2 - N)")
    f = QForm(1, 0, -N)
    for x in (3, 17, 12345):
        lhs = 4 * f.A * f.eval(x)
        rhs = (2 * f.A * x + f.B) ** 2 - f.disc
        print(f"  x = {x:>6}:  4A f(x) = {lhs}   (2Ax+B)^2 - disc = {rhs}   equal: {lhs == rhs}")
    base = primes_up_to(B)
    split = set(split_set(N, B))
    x0 = math.isqrt(N) + 1
    cols = observed_columns(f, base, range(x0, x0 + 4 * B))
    print(f"  N = {N},  B = {B},  pi(B) = {len(base)}")
    print(f"  primes dividing some value x^2 - N : {len(cols)}")
    print(f"  primes p <= B with N a square mod p: {len(split)}")
    print(f"  the two sets are identical: {cols == split}   (fraction {len(split)/len(base):.3f} of pi(B))")


def demo_shared_vs_unrelated(N: int, B: int, T: int, M: int) -> None:
    banner("2. Multi-polynomial: shared discriminant = ONE constraint")
    forms = silverman_forms(N, B, T, M)
    base = primes_up_to(B)
    odd_base = [p for p in base if p != 2]
    col_sets = []
    for t, f in enumerate(forms):
        cols = observed_columns(f, odd_base, range(-M, M))
        col_sets.append(cols)
        print(f"  form {t}: A = {f.A:>10}  disc = {f.disc}  (= 4N? {f.disc == 4 * N})  #odd columns = {len(cols)}")
    inter = set.intersection(*col_sets)
    union = set.union(*col_sets)
    split_odd = set(split_set(N, B)) - {2}
    print(f"  intersection == union == odd split set of N: {inter == union == split_odd}")
    print(f"  shared-discriminant column fraction: {len(inter)/len(odd_base):.3f}")
    rng = random.Random(1)
    fracs = []
    for _ in range(20):
        D1 = rng.randrange(10 ** 11, 10 ** 12) | 1
        D2 = rng.randrange(10 ** 11, 10 ** 12) | 1
        both = [p for p in odd_base if is_square_mod(D1, p) and is_square_mod(D2, p)]
        fracs.append(len(both) / len(odd_base))
    print(f"  two UNRELATED discriminants (20 random pairs): intersection fraction "
          f"min {min(fracs):.3f}, mean {sum(fracs)/len(fracs):.3f}, max {max(fracs):.3f}  (~1/4)")
    s = 7
    same = all(is_square_mod(N * s * s, p) == is_square_mod(N, p) for p in odd_base if p != s)
    print(f"  D and D*s^2 (s = {s}) have the same split set off s: {same}")


def demo_large_primes(N: int, B: int, M: int) -> None:
    banner("3. Large primes: a monotonicity identity, not a new column")
    base = primes_up_to(B)
    split_small = set(split_set(N, B))
    x0 = math.isqrt(N) + 1
    L = 50 * B
    partials: Dict[int, List[Tuple[int, int]]] = {}
    nonsplit_found = 0
    for x in range(x0, x0 + M):
        v = x * x - N
        w = v
        for p in base:
            while w % p == 0:
                w //= p
        if 1 < w <= L and is_prime(w):
            if not is_square_mod(N, w):
                nonsplit_found += 1
            partials.setdefault(w, []).append((x, v // w))
    print(f"  partial relations with one large prime r in ({B}, {L}]: {sum(map(len, partials.values()))}")
    print(f"  large primes r with N NOT a square mod r: {nonsplit_found}   (theorem: always 0)")
    pairs = [(r, lst[0], lst[1]) for r, lst in partials.items() if len(lst) >= 2]
    print(f"  LP-pairs (two partials sharing r): {len(pairs)}")
    ok = True
    for r, (x1, s1), (x2, s2) in pairs:
        prod = (s1 * r) * (s2 * r)
        e = factor_over(prod // (r * r), base)
        assert e is not None
        odd = {p for p, k in e.items() if k % 2 == 1}
        ok &= odd <= split_small
    print(f"  every LP-pair's odd-exponent support lies in the small split set: {ok}")


def demo_row_side_lever(N: int, B: int, M: int) -> None:
    banner("4. Row-side lever: the square bound |split set| + 1 does not depend on T")
    split = split_set(N, B)
    idx = {p: i for i, p in enumerate(split)}
    k = len(split)
    print(f"  columns: |split set of N up to {B}| = {k}, so {k + 1} smooth values always suffice")
    for T in (1, 2, 4, 8):
        forms = silverman_forms(N, B, T, M)
        rows: List[Tuple[int, int, int]] = []  # (|value|, form, x)
        cols_used: Set[int] = set()
        for t, f in enumerate(forms):
            for x in range(-M, M):
                v = f.eval(x)
                e = factor_over(v, split) if v != 0 else None
                if e is not None:
                    rows.append((abs(v), t, x))
                    cols_used |= set(e)
        line = (f"  T = {T}: sieve interval [-{M},{M}) per form -> {len(rows):>3} smooth rows; "
                f"columns touched {len(cols_used):>2} <= {k}")
        if len(rows) <= k:
            print(line + "   (row-starved: not yet a guaranteed square)")
            continue
        rows = rows[: k + 1]
        vecs = []
        for v, _, _ in rows:
            e = factor_over(v, split)
            assert e is not None
            vec = 0
            for p, ex in e.items():
                if ex % 2:
                    vec |= 1 << idx[p]
            vecs.append(vec)
        dep = gf2_dependency(vecs)
        assert dep is not None
        prod = 1
        for i in dep:
            prod *= rows[i][0]
        r = math.isqrt(prod)
        forms_in_dep = sorted({rows[i][1] for i in dep})
        print(line + f"\n         first {k + 1} rows -> GF(2) dependency of size {len(dep)} "
              f"using forms {forms_in_dep}; product is a perfect square: {r * r == prod}")


def demo_complete_cost() -> None:
    banner("5. Complete-cost rule: sieve-only pricing inverts the sign")
    # Toy model in u = log Q: sieve cost decays mildly, GF(2) cost grows.
    S: Callable[[float], float] = lambda u: 1000.0 * math.exp(-0.15 * u)
    L: Callable[[float], float] = lambda u: 2.0 * math.exp(0.9 * u)
    h = 1e-6
    for u in (2.0, 4.0, 5.0, 6.0, 8.0):
        s, l = S(u), L(u)
        sp = (S(u + h) - S(u - h)) / (2 * h)
        lp = (L(u + h) - L(u - h)) / (2 * h)
        e_sieve = sp / s
        e_total_numeric = (math.log(S(u + h) + L(u + h)) - math.log(S(u - h) + L(u - h))) / (2 * h)
        e_total_formula = s / (s + l) * (sp / s) + l / (s + l) * (lp / l)
        sign_rule = lp > -sp
        print(f"  u = {u:.1f}: dlogS = {e_sieve:+.4f}   dlog(S+L) = {e_total_numeric:+.4f} "
              f"(weighted avg {e_total_formula:+.4f})   l' > -s'? {sign_rule!s:5}  "
              f"total>0? {e_total_numeric > 0}")


def demo_gate() -> None:
    banner("6. Silverman minimax M*sqrt(N/2) and the 42-bit gate")
    N, M = 2.0 ** 41, 10_000.0
    best = M * math.sqrt(N / 2)
    A_star = math.sqrt(2 * N) / M
    worst = lambda A: max(N / A, A * M * M - N / A)
    for A in (A_star / 4, A_star / 2, A_star, 2 * A_star, 4 * A_star):
        print(f"  A = {A:12.4f}: max(N/A, A M^2 - N/A) = {worst(A):.4e}   (minimax {best:.4e})")
    for bits in (40, 41, 42):
        N = 2.0 ** bits - 1
        for B, M in ((1000, 1000), (2400, 30_000), (9600, 100_000)):
            ratio = B * B * M / math.sqrt(N / 2)
            print(f"  N ~ 2^{bits}, B = {B:>5}, M = {M:>6}:  B^2 M / sqrt(N/2) = {ratio:10.1f}  (>600? {ratio > 600})")


def demo_cubic() -> None:
    banner("7. Leaving differences of squares: cubic values break the split constraint")
    N, x, p = 2, 3, 5
    print(f"  x^3 - N = {x**3 - N},  divisible by {p}: {(x**3 - N) % p == 0},  "
          f"N = {N} a square mod {p}: {is_square_mod(N, p)}")
    N = 1099515822059
    base = primes_up_to(200)
    nonsplit = set()
    x0 = round(N ** (1 / 3)) + 1
    for x in range(x0, x0 + 2000):
        v = x ** 3 - N
        for q in base:
            if v % q == 0 and not is_square_mod(N, q):
                nonsplit.add(q)
    print(f"  for N = {N}: {len(nonsplit)} non-split primes <= 200 divide some x^3 - N, e.g. {sorted(nonsplit)[:8]}")


def main() -> None:
    N = 1099515822059  # = 1048573 * 1048583  (41 bits)
    B = 400
    demo_columns_equal_split(N, B)
    demo_shared_vs_unrelated(N, B, T=4, M=3000)
    demo_large_primes(N, B=300, M=60_000)
    demo_row_side_lever(N, B=120, M=20_000)
    demo_complete_cost()
    demo_gate()
    demo_cubic()


if __name__ == "__main__":
    main()
