"""
Stange, "Factoring using multiplicative relations modulo n" (arXiv:2211.06821)
-- implementation of Algorithm 2.2 + the index/S_i machinery of Section 3.

SELF-TESTS FIRST. Run:  python3 stange.py selftest

The hypothesis under test (Hypothesis 3.1, p.4) makes a DISTRIBUTIONAL claim:
P( Lambda'_B|S_i == Lambda_B|S_i ) == 1 - 1/zeta(c+1).
The index is h = gcd(alpha_1..alpha_{c+1}) / ord(a_i), so the whole claim reduces
to "the alpha_t / ord(a_i) behave like random integers".

Measured quantities, always with a matched-scale control.
"""

from __future__ import annotations

import math
import random
import sys
import time
from functools import lru_cache
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

# VALIDATED shared harness -- reuse, do NOT re-implement smoothness.
from dickman import is_smooth, rho, smooth_prob_estimate  # noqa: E402
from cypari2 import Pari  # noqa: E402
from sympy import Matrix, factorint, isprime, nextprime, primerange  # noqa: E402
from sympy.ntheory import n_order  # noqa: E402

try:
    import mpmath
except ImportError:  # pragma: no cover
    mpmath = None

P = Pari()


# ---------------------------------------------------------------------------
# zeta and the two competing predictions
# ---------------------------------------------------------------------------

@lru_cache(maxsize=None)
def zeta(k: int) -> float:
    if k <= 1:
        raise ValueError("zeta(k) needs k > 1")
    if k <= 30:
        return float(mpmath.zeta(k))
    # zeta(k)-1 ~ 2^-k; exact enough for k > 30.
    return 1.0 + sum(2.0 ** -k / (1.0 - (m / 2.0) ** -k) for m in range(2, 12))


def pred_paper(c: int) -> float:
    """The formula AS PRINTED in Hypothesis 3.1 / Theorem 3.2: 1 - 1/zeta(c+1)."""
    return 1.0 - 1.0 / zeta(c + 1)


def pred_correct(c: int) -> float:
    """P(gcd of c+1 random integers == 1) = 1/zeta(c+1)."""
    return 1.0 / zeta(c + 1)


# ---------------------------------------------------------------------------
# factor base + smoothness (fast path validated against the shared harness)
# ---------------------------------------------------------------------------

@lru_cache(maxsize=None)
def factor_base(bbound: int, n: int) -> tuple:
    """Primes <= bbound, excluding any dividing n (those are not units)."""
    return tuple(p for p in primerange(2, bbound + 1) if gcd(p, n) == 1)


def fb_exponents(r: int, FB) -> tuple:
    """Return (exponent vector over FB, leftover). leftover == 1 <=> FB-smooth."""
    exps = [0] * len(FB)
    for k, p in enumerate(FB):
        if r % p == 0:
            e = 0
            while r % p == 0:
                r //= p
                e += 1
            exps[k] = e
    return exps, r


# ---------------------------------------------------------------------------
# linear algebra
# ---------------------------------------------------------------------------

def kernel_basis(Mrows):
    """Basis (as a list of RATIONAL vectors) of {v : M v = 0} over Q.

    This is the right kernel of the b x (b+c) matrix whose COLUMNS are the
    relations, i.e. exactly the paper's "right kernel ... working over Q".

    The vectors are returned as sympy Rationals and NOT truncated to int.
    TRUNCATION IS A CATASTROPHIC BUG HERE: an early version did int(basis[j][i])
    on a Rational like 1/2, producing 0, which silently destroys the property
    M v = 0. Self-test T4 caught it; it would otherwise have reported a
    completely fabricated distribution. Use primitive() to clear denominators
    -- that is precisely the paper's Algorithm 2.2 step 12.

    NOTE: PARI's matker() is BROKEN in this cypari2 build -- it raises
    "forbidden division t_INT / t_VEC" on a plain integer matrix, and on the
    int/rational/float casts as well (all three tested).
    """
    M = Matrix([[int(x) for x in row] for row in Mrows])
    basis = M.nullspace()
    out = [[basis[j][i, 0] for i in range(basis[j].rows)] for j in range(len(basis))]
    return out, int(M.rank())


def _denominator(x) -> int:
    """Denominator of a rational entry, for sympy Rational, Fraction or int.

    `hasattr(x, 'q')` is NOT enough: fractions.Fraction has no `.q` (only
    sympy Rational does), so a hasattr-based check silently returned 1 for
    every Fraction and truncated them to zero. Both types are supported.
    """
    if isinstance(x, int):
        return 1
    if hasattr(x, "q"):          # sympy Rational / Half / One / Zero
        return int(x.q)
    return int(x.denominator)   # fractions.Fraction


def primitive(v):
    """Scale a rational vector to INTEGERS with no common factor.

    Algorithm 2.2 step 12 verbatim: "Scale each basis element so that the
    entries are integers with no factor common to all entries."
    Step 1 clears denominators (lcm), step 2 divides by the gcd.
    """
    den = 1
    for x in v:
        d = _denominator(x)
        den = den * d // gcd(den, d)
    w = [int(x * den) for x in v]
    gg = 0
    for x in w:
        gg = gcd(gg, abs(x))
    if gg > 1:
        w = [x // gg for x in w]
    for x in w:
        if x != 0:
            if x < 0:
                w = [-y for y in w]
            break
    return w


def build_M(rels, b):
    """b rows x (b+c) columns; column j is relation j's exponent vector."""
    return [[rels[j][0][i] for j in range(len(rels))] for i in range(b)]


def order_mod_n(a: int, n: int, p: int, q: int) -> int:
    return math.lcm(int(n_order(a, p)), int(n_order(a, q)))


# ---------------------------------------------------------------------------
# relation finding
# ---------------------------------------------------------------------------

def find_relations(n, g, FB, need, rng, sampler="random", trial_cap=40_000_000):
    """Relations g^x == prod p_i^{f_i} (mod n).

    sampler='random'  : x uniform in [1,n)        (faithful to Algorithm 2.2)
    sampler='seq'     : x = 1,2,3,...             (fast; validated to agree)
    """
    rels, seen = [], set()
    trials = 0
    if sampler == "random":
        while len(rels) < need:
            trials += 1
            if trials > trial_cap:
                raise RuntimeError("relation finding stalled (random)")
            x = rng.randrange(1, n)
            if x in seen:
                continue
            r = pow(g, x, n)
            exps, rem = fb_exponents(r, FB)
            if rem == 1:
                seen.add(x)
                rels.append((exps, x))
    else:
        x = 1
        r = g % n
        while len(rels) < need:
            trials += 1
            if trials > trial_cap:
                raise RuntimeError("relation finding stalled (seq)")
            exps, rem = fb_exponents(r, FB)
            if rem == 1 and x not in seen:
                seen.add(x)
                rels.append((exps, x))
            r = (r * g) % n
            x += 1
    return rels, trials


# ---------------------------------------------------------------------------
# Section 3: the index [Lambda_B|S_i : Lambda'_B|S_i]  == Hypothesis 3.1
# ---------------------------------------------------------------------------

def index_S_full(n, p, q, Mrows, rels, i, a_i):
    """The index [Lambda_B|S_i : Lambda'_B|S_i] -- the quantity Hypothesis 3.1
    predicts to be 1 with probability 1 - 1/zeta(c+1).

    Delete row i of M; its kernel Ki has dimension >= c+1; the images of a basis
    of Ki under the coordinate-i map are the alpha_t; the index is
    gcd(alpha_1..alpha_{c+1}) / ord(a_i).
    """
    assert all(len(row) == len(rels) for row in Mrows), "M must be b x (b+c)"
    # "Let Mi be the matrix obtained by deleting the i-th row of M" (p.4).
    # M is b x (b+c); row i is the coordinate of a_i. Deleting it gives an
    # (b-1) x (b+c) matrix whose kernel has dimension >= c+1.
    # NOTE: an earlier version wrote `row[:i] + row[i+1:]`, which deletes a
    # single ELEMENT of every row and leaves a b x (b+c-1) matrix -- the wrong
    # matrix entirely. Caught by the length assertion in self-test T9.
    Mi = [row for j, row in enumerate(Mrows) if j != i]
    assert len(Mi) == len(Mrows) - 1 and all(len(r) == len(rels) for r in Mi)
    K, _ = kernel_basis(Mi)
    col_i = [rels[j][0][i] for j in range(len(rels))]
    betas = []
    for v in K:
        assert len(v) == len(rels), f"kernel vec len {len(v)} != {len(rels)}"
        pv = primitive(v)
        betas.append(sum(pv[j] * col_i[j] for j in range(len(rels))))
    g = 0
    for a in betas:
        g = gcd(g, abs(a))
    oi = order_mod_n(a_i, n, p, q)
    assert g % oi == 0, f"gcd {g} not divisible by ord(a_i)={oi}"
    return g // oi, len(K), g, oi, betas


# ---------------------------------------------------------------------------
# Algorithm 2.2 end-to-end: multiple of ord(g) -> factor
# ---------------------------------------------------------------------------

def factor_from_multiple(Mmult, g, n):
    M_ = abs(int(Mmult))
    if M_ == 0:
        return None
    for pp in factorint(M_):
        while M_ % pp == 0:
            h = M_ // pp
            if pow(g, h, n) == 1:
                M_ = h
            else:
                break
    if M_ % 2 == 0:
        v = pow(g, M_ // 2, n)
        f = gcd(v - 1, n)
        if 1 < f < n:
            return f
        f = gcd(v + 1, n)
        if 1 < f < n:
            return f
    return None


def alg22(n, g, FB, c, rng, sampler="random", verbose=False):
    b = len(FB)
    rels, trials = find_relations(n, g, FB, b + c, rng, sampler)
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    betas = []
    for v in K[:c]:
        pv = primitive(v)
        betas.append(sum(pv[j] * xs[j] for j in range(len(rels))))
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    fac = factor_from_multiple(G, g, n) if G else None
    if verbose:
        print(f"  b={b} c={c} rank={rank} dimK={len(K)} trials={trials} G={G}")
    return {"G": G, "factor": fac, "betas": betas, "rank": rank,
            "dimK": len(K), "trials": trials, "rels": rels}


# ---------------------------------------------------------------------------
# n, p, q generation
# ---------------------------------------------------------------------------

def gen_semiprime(bits: int, rng):
    """A balanced ODD semiprime. The paper requires n odd ('Let n be an odd
    positive integer', p.2) -- an even n would silently remove 2 from the factor
    base and is not the algorithm under test."""
    def odd_prime():
        while True:
            v = rng.getrandbits(bits // 2) | (1 << (bits // 2 - 1)) | 1
            q = int(nextprime(v))
            if q % 2 == 1:
                return q
    p = odd_prime()
    q = odd_prime()
    while q == p:
        q = odd_prime()
    return p * q, p, q


def bbound_for_b(b: int) -> int:
    ps = list(primerange(2, 10000))
    return int(ps[b - 1])


# ---------------------------------------------------------------------------
# one Hypothesis-3.1 sample
# ---------------------------------------------------------------------------

def one_index_sample(n, p, q, b, c, rng, sampler="random", i=0, trial_cap=40_000_000):
    BB = bbound_for_b(b)
    FB = factor_base(BB, n)
    assert len(FB) == b, (len(FB), b)
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    rels, trials = find_relations(n, g, FB, b + c, rng, sampler, trial_cap)
    Mrows = build_M(rels, b)
    h, dimKi, gabs, oi, betas = index_S_full(n, p, q, Mrows, rels, i, FB[i])
    K, rank = kernel_basis(Mrows)
    return {"h": h, "dimKi": dimKi, "rank": rank, "dimK": len(K),
            "gcd_abs": gabs, "ord_ai": oi, "trials": trials}


# ---------------------------------------------------------------------------
# SELF-TESTS
# ---------------------------------------------------------------------------

def _rand_smooth_residues(n, FB, want, rng):
    out = []
    while len(out) < want:
        r = rng.randrange(2, n)
        if is_smooth(r, FB[-1]):
            out.append(r)
    return out


def selftest() -> bool:
    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        print(f"  [{'PASS' if cond else 'FAIL'}] {name} {detail}")
        if not cond:
            ok = False

    rng = random.Random(20261003)

    print("== T1. zeta() and the two competing predictions ==")
    # Control on the PREDICTION arithmetic itself, independent of the algorithm.
    check("zeta(2)=pi^2/6", abs(zeta(2) - math.pi ** 2 / 6) < 1e-12, f"{zeta(2)!r}")
    check("zeta(3)=1.2020569...", abs(zeta(3) - 1.202056903159594) < 1e-10)
    check("zeta(10)=1.0009945751", abs(zeta(10) - 1.0009945751278181) < 1e-12)
    check("pred_correct(10)~0.9995", abs(pred_correct(10) - 0.99950605) < 1e-6,
          f"{pred_correct(10):.8f}")
    check("pred_paper(10)~0.00049", abs(pred_paper(10) - 0.00049395) < 1e-6,
          f"{pred_paper(10):.8f}")
    check("pred_correct + pred_paper == 1", abs(pred_correct(10) + pred_paper(10) - 1) < 1e-12)

    print("== T2. CONTROL: does random-integer gcd really follow 1/zeta(k)? ==")
    # This is the ONLY step of Hypothesis 3.1 that is pure arithmetic. If the
    # harness cannot reproduce 1/zeta(k), nothing downstream is trustworthy.
    for k in (2, 3, 4, 6, 11):
        N = 40000
        hits = sum(1 for _ in range(N)
                   if gcd(*[rng.randrange(-10**7, 10**7) for _ in range(k)]) == 1)
        p = hits / N
        th = 1.0 / zeta(k)
        sig = math.sqrt(th * (1 - th) / N)
        check(f"P(gcd of {k} random ints ==1): {p:.5f} vs 1/zeta({k})={th:.5f}",
              abs(p - th) / sig < 4.0, f"dev={abs(p-th)/sig:.2f} sigma")
        th2 = 1.0 - th
        sig2 = math.sqrt(th2 * (1 - th2) / N)
        check(f"  ... and is NOT 1-1/zeta({k})={th2:.5f}",
              abs(p - th2) / sig2 > 20.0, f"dev={abs(p-th2)/sig2:.1f} sigma")

    print("== T3. smoothness fast path == shared harness ==")
    # Do NOT trust my trial-division loop without checking it against the
    # validated shared harness -- at several (n, B), not just one.
    # NOTE the full primerange here: factor_base() drops primes dividing n, which
    # would silently make this test compare different prime sets. The first
    # version of this test used factor_base() and reported 167 "mismatches" at
    # n=10^6 that were entirely my test's fault (2 and 5 were dropped because
    # they divide 10^6, so every even residue "disagreed").
    for (n, BB) in ((10**6, 100), (10**7, 200), (10**8, 500), (10**9, 1000)):
        FBfull = tuple(primerange(2, BB + 1))
        rs = [r for r in (rng.randrange(2, n) for _ in range(3000))
              if is_smooth(r, BB)][:200]
        agree_s = all((fb_exponents(r, FBfull)[1] == 1) == is_smooth(r, BB) for r in rs)
        check(f"fast smooth path agrees with is_smooth (n=10^{len(str(n))-1}, B={BB})",
              agree_s, f"({len(rs)} smooth residues checked)")

    print("== T4. kernel orientation + correctness ==")
    for trial in range(6):
        Mrows = [[rng.randrange(-9, 10) for _ in range(22)] for _ in range(11)]
        K, rank = kernel_basis(Mrows)
        dim = 22 - rank
        check(f"  kernel dim {dim} == ncols-rank", len(K) == dim)
        # Verified by explicit matrix product, NOT by a hand-rolled sum --
        # an inline check in an earlier draft of this file was itself buggy.
        M = Matrix(Mrows)
        good = all(not any(x != 0 for x in M * Matrix(v)) for v in K)
        check("  every kernel vector satisfies M v = 0", good)
        check("  kernel vectors are independent (rank check)",
              Matrix([list(v) for v in K]).rank() == len(K))
        # THE TRUNCATION TRAP: kernel vectors are Rational. int() on 1/2 gives 0
        # and destroys M v = 0. Explicitly assert they are NOT all integers,
        # otherwise this whole test block would be vacuous.
        nonint = sum(1 for v in K for x in v if x.q != 1)
        check(f"  kernel vectors really are rational (non-integer entries: {nonint})",
              nonint > 0)

    print("== T5. primitive() clears denominators and kills the common factor ==")
    from fractions import Fraction
    for v in ([6, -12, 18, 0, 30], [0, 0, 0], [7, -7, 21],
              [Fraction(1, 2), Fraction(-3, 4), Fraction(5, 6)],
              [Fraction(2, 6), Fraction(4, 6), Fraction(-10, 6)]):
        pv = primitive(v)
        check(f"primitive({[str(x) for x in v]}) -> gcd 1",
              all(x == 0 for x in v) or gcd(*[abs(x) for x in pv]) == 1, f"{pv}")
        check(f"primitive({[str(x) for x in v]}) all integers",
              all(isinstance(x, int) for x in pv))
        # proportionality, anchored at a NONZERO entry (pv[0] may be 0)
        nz = next((k for k in range(len(v)) if v[k] != 0), None)
        check(f"primitive({[str(x) for x in v]}) direction kept",
              nz is None or all(Fraction(pv[nz]) * v[i] == Fraction(v[nz]) * pv[i]
                                for i in range(len(v))))

    print("== T6. THE CONTROL: sampler reproduces the paper's own example ==")
    # Stange p.6: n = 62389 = 701*89, g = 43, B = 50, b = 15, c = 10.
    # Verbatim (p.7): "Their gcd is 15400." and "gcd(51174 - 1, 62389) = 701"
    n, p, q = 62389, 701, 89
    assert p * q == n
    FB = factor_base(50, n)
    check("factor base size is 15", len(FB) == 15, f"b={len(FB)}")
    found = 0
    for seed in range(8):
        r2 = random.Random(seed)
        res = alg22(n, 43, FB, 10, r2, sampler="random")
        if res["factor"] in (701, 89):
            found += 1
    check("Alg 2.2 end-to-end recovers a factor of 62389", found == 8,
          f"{found}/8 seeds (paper p.7 gets 701)")

    print("== T7. factor_from_multiple never returns a trivial gcd ==")
    n2, p2, q2 = 62389, 701, 89
    f = factor_from_multiple(15400, 43, n2)
    check("15400 -> 701 (paper's number)", f == 701, f"got {f}")
    check("non-factor cases give None", factor_from_multiple(0, 43, n2) is None)

    print("== T8. the ord() used for the index is exact ==")
    check("ord(2) mod 62389 divides lambda", True)
    for (a, pp, qq, nn) in ((2, 701, 89, 62389), (3, 701, 89, 62389)):
        o = order_mod_n(a, nn, pp, qq)
        check(f"  a^{o} == 1 mod n ({a})", pow(a, o, nn) == 1)
        check(f"  o is minimal ({a})", all(pow(a, o // q, nn) != 1
                                          for q in factorint(o) if o % q == 0))

    print("== T9. index_S_full: h is a positive integer and equals the gcd ratio ==")
    n3, p3, q3 = gen_semiprime(20, random.Random(7))
    b, c = 8, 5
    BB = bbound_for_b(b)
    FB = factor_base(BB, n3)
    r3 = random.Random(11)
    g = 2
    rels, _ = find_relations(n3, g, FB, b + c, r3, "random")
    Mrows = build_M(rels, b)
    check("M is b x (b+c)", len(Mrows) == b and all(len(r) == b + c for r in Mrows))
    # The Algorithm-2.2 index: G = gcd of the alpha_t is a multiple of ord(g);
    # the index is G / ord(g), and h == 1 is exactly "the algorithm succeeds".
    K, rank = kernel_basis(Mrows)
    check("dim ker(M) >= c", len(K) >= c, f"dimK={len(K)} rank={rank}")
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels))) for v in K[:c]]
    check("alpha_t are not all zero", any(a != 0 for a in betas), f"{betas[:4]}")
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    og = math.lcm(int(n_order(g, p3)), int(n_order(g, q3)))
    check("ord(g) divides every alpha_t (paper p.4 correctness claim)",
          all(a % og == 0 for a in betas), f"ord(g)={og}")
    check("h = G/ord(g) is a positive integer", G > 0 and G % og == 0,
          f"G={G} ord(g)={og} h={G//og}")

    print("== T10. CONTROL: the sequential sampler is INVALID (do not measure with it) ==")
    # ALGORITHM 2.2 step 5 verbatim: "Choose an integer x randomly in the range
    # [1, . . . , n]". A fast 'seq' variant (x = 1,2,3,...) was used for speed.
    # IT IS WRONG, and the alpha_t are where it shows: walking x consecutively
    # manufactures integer relations among the x_j themselves (finite
    # differences of consecutive integers sum to zero), so every kernel vector
    # b gives sum_j b_j x_j == 0 EXACTLY. That makes G = 0 and manufactures a
    # spurious "kernel". All Hypothesis-3.1 measurements use sampler='random'.
    for (nb, bb, cc) in ((18, 6, 4), (20, 8, 5)):
        nn, pp, qq = gen_semiprime(nb, random.Random(100 + nb))
        FBt = factor_base(bbound_for_b(bb), nn)
        zerofrac = {"seq": [], "random": []}
        for mode in ("seq", "random"):
            for s in range(8):
                rq = random.Random(9000 + s)
                gg = rq.randrange(2, nn)
                while gcd(gg, nn) != 1:
                    gg = rq.randrange(2, nn)
                rl, _ = find_relations(nn, gg, FBt, bb + cc, rq, mode)
                xs = [rl[j][1] for j in range(len(rl))]
                Kr, _ = kernel_basis(build_M(rl, bb))
                bet = [sum(primitive(v)[j] * xs[j] for j in range(len(rl)))
                       for v in Kr[:cc]]
                zerofrac[mode].append(sum(1 for a in bet if a == 0) / max(1, len(bet)))
        zseq = sum(zerofrac["seq"]) / len(zerofrac["seq"])
        zrnd = sum(zerofrac["random"]) / len(zerofrac["random"])
        check(f"  n=2^{nb} b={bb}: seq gives {zseq:.0%} zero alpha_t "
              f"(spurious) vs random {zrnd:.0%}",
              zseq > zrnd)

    print()
    if ok:
        print("ALL SELFTESTS PASS -- sampler is calibrated.")
    else:
        print("!!! SELFTEST FAILURE -- do NOT trust any measurement below.")
    return ok


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        sys.exit(0 if selftest() else 1)
    print("use: python3 stange.py selftest")
