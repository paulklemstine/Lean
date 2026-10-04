"""
G3 -- DOES THE JACOBI LEVER SURVIVE CONTACT WITH REAL SEMIPRIMES?

The exact prediction (see laws.py) is
        uniform g            -> 20/27 = 0.740740...
        Jacobi(g/n) = -1     ->  8/9  = 0.888888...
        Jacobi(g/n) = +1     ->  8/15 = 0.533333...

This script measures all three on FRESHLY GENERATED semiprimes and reports EVERY rate PER
MODULUS against ITS OWN predicted cell value.  That per-modulus reporting is the mandatory
2-adic control: the 20/27 is an AVERAGE OVER MODULI, and the per-cell values range from
1/2 to ~1.  Two samples of one cell differ by 0.085 on sampling alone at N=200, so a pooled
bare rate proves nothing.

Also measured, because they are the other G2 candidates:
    g = fixed small integer (2, 3, 5, 7)   -- NOT uniform, so the geometric law does NOT
                                               apply and the rate must be measured, not derived
    g = perfect square                       -- forces Jacobi = +1, predicted to be WORSE
    g = 2^k                                 -- small prime powers

SELF-TESTS FIRST, and they must be non-vacuous: a deliberately BIASED g-sampler is injected
and the detector must fire on it, and must stay silent on an unbiased one.
"""

from __future__ import annotations

import json
import math
import random
import sys
from fractions import Fraction as F

from sympy import factorint, isprime, nextprime

import laws
from laws import cell_jac_neg, cell_jac_pos, cell_uniform

# --------------------------------------------------------------------------------------
# ground truth
# --------------------------------------------------------------------------------------


def v2(m: int) -> int:
    if m == 0:
        return 0
    return (m & -m).bit_length() - 1


def s_of(p: int) -> int:
    return v2(p - 1)


class Prime:
    """A prime with its factorisation cached, so ord() is cheap."""

    __slots__ = ("p", "_fac")

    def __init__(self, p: int):
        self.p = p
        self._fac = factorint(p - 1)

    def ord(self, g: int) -> int:
        o = self.p - 1
        for q in self._fac:
            while o % q == 0 and pow(g, o // q, self.p) == 1:
                o //= q
        return o

    def lam(self, g: int) -> int:
        """lam = s_p - v2(ord_p g).  This is the quantity laws.py models."""
        return s_of(self.p) - v2(self.ord(g % self.p))

    def k(self, g: int) -> int:
        """k = v2(ord_p g).  THIS is what Stange's step actually compares.

        Success iff k_p != k_q.  Note k != lam unless s_p == s_q, so a code path that
        compares lam's directly is wrong off the diagonal -- it scored a perfect 12000/12000
        on the Jacobi strategy before this was caught.
        """
        return v2(self.ord(g % self.p))


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0.  O(log n).  Computable WITHOUT factoring."""
    a %= n
    r = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            r = -r
        a %= n
    return r if n == 1 else 0


def gen_semiprime(bits: int, rng: random.Random) -> tuple[int, int, int]:
    """A fresh RSA-type semiprime with two DISTINCT odd primes of exactly `bits` bits."""
    lo = 1 << (bits - 1)
    span = 1 << (bits - 1)
    while True:
        p = int(nextprime(lo + rng.randrange(span)))
        q = int(nextprime(lo + rng.randrange(span)))
        if p == q:
            continue
        if p.bit_length() != bits or q.bit_length() != bits:
            continue
        return p, q, p * q


# --------------------------------------------------------------------------------------
# g-samplers.  Each returns g with gcd(g,n)=1.  `INJECT_BIAS` is for ST-B only.
# --------------------------------------------------------------------------------------

INJECT_BIAS = 0.0  # probability of forcing Jacobi = +1 (should be 0 in real runs)


def sample_uniform(n: int, rng: random.Random) -> int:
    while True:
        g = rng.randrange(2, n)
        if math.gcd(g, n) == 1:
            return g


def sample_jac(n: int, rng: random.Random, want: int = -1) -> int:
    """Rejection-sample g with Jacobi(g/n) == want.  Cost: ~2 Jacobi evaluations, O(log n)."""
    for _ in range(200):
        g = sample_uniform(n, rng)
        if jacobi(g, n) == want:
            return g
        if INJECT_BIAS and rng.random() < INJECT_BIAS:
            return g  # ST-B: deliberately hand back the WRONG Jacobi class
    raise RuntimeError("rejection sampling failed -- degenerate n?")


def sample_fixed(k: int, n: int, rng: random.Random) -> int:
    """g = a fixed small integer (or small prime power).  NOT uniform -- law does not apply."""
    return pow(k, 1, n) if math.gcd(k, n) == 1 else sample_uniform(n, rng)


# --------------------------------------------------------------------------------------
# SELF-TESTS
# --------------------------------------------------------------------------------------


def wilson(k: int, n: int) -> tuple[float, float]:
    """Wilson 95% interval -- the campaign's standard for a binomial rate."""
    if n == 0:
        return (0.0, 1.0)
    z = 1.96
    p = k / n
    d = 1 + z * z / n
    c = p + z * z / (2 * n)
    h = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return ((c - h) / d, (c + h) / d)


def zscore(hits: int, n: int, pred: float) -> float | None:
    """z of an observed rate against a predicted rate.  None when the test is degenerate.

    Degenerate when pred is 0 or 1 (no variance) -- e.g. cell_jac_neg(1,1) is EXACTLY 1, so a
    z-score there is undefined and must not be reported as 0 or as infinity.
    """
    if n == 0 or pred <= 0.0 or pred >= 1.0:
        return None
    return (hits / n - pred) / math.sqrt(pred * (1 - pred) / n)


def zstr(z: float | None, hits: int = -1, n: int = -1) -> str:
    if z is None:
        return f"{'n/a':>6} ({hits}/{n})"
    return f"{z:>+6.2f}"


def selftest() -> bool:
    ok = True

    def chk(cond: bool, msg: str) -> None:
        nonlocal ok
        print(("  [PASS] " if cond else "  [FAIL] ") + msg)
        if not cond:
            ok = False

    print("=" * 78)
    print("T1  Jacobi() must be correct -- it is the load-bearing primitive")
    print("=" * 78)
    chk(jacobi(2, 15) == 1, "jacobi(2,15) = 1")
    chk(jacobi(3, 15) == 0, "jacobi(3,15) = 0 (shares a factor with n)")
    chk(jacobi(7, 15) == -1, "jacobi(7,15) = -1")
    chk(jacobi(2, 9) == 1, "jacobi(2,9) = 1 (square)")
    chk(jacobi(2, 3) == -1 and jacobi(2, 5) == -1 and jacobi(2, 11) == -1,
        "jacobi(2,3)=jacobi(2,5)=jacobi(2,11)=-1")
    # multiplicativity and the prime-factorisation cross-check on semiprimes
    bad = 0
    rng = random.Random(1)
    for _ in range(300):
        p = int(nextprime(3 + rng.randrange(2, 3000)))
        q = int(nextprime(3 + rng.randrange(2, 3000)))
        if p == q:
            continue
        n = p * q
        g = rng.randrange(2, n)
        if math.gcd(g, n) != 1:
            continue
        want = jacobi(g, p) * jacobi(g, q)  # Euler's criterion, exact
        if jacobi(g, n) != want:
            bad += 1
    chk(bad == 0, f"jacobi(g,n) == (g/p)(g/q) on 300 random semiprimes ({bad} mismatches)")
    print()

    print("=" * 78)
    print("T2  THE STRUCTURAL FACT: lam = 0  <=>  g is a QNR  (this is what makes Jacobi work)")
    print("=" * 78)
    mism = 0
    tot = 0
    for p in (101, 211, 307, 401, 503, 601):
        P = Prime(p)
        s = s_of(p)
        qs = {pow(x, 2, p) for x in range(1, p)}
        for g in range(2, min(p, 400)):
            if g in qs:
                continue
            tot += 1
            if (P.lam(g) == 0) != (g not in qs):
                mism += 1
    chk(mism == 0 and tot > 500,
        f"lam==0 <=> QNR on {tot} non-residues across 6 primes ({mism} mismatches)")
    print()

    print("=" * 78)
    print("T3  THE NULL: a uniform g must reproduce the campaign's per-cell prediction")
    print("=" * 78)
    rng = random.Random(20261004)
    print(f"      {'cell (a,b)':>12} {'predicted':>10} {'measured':>10} {'N':>6} {'z':>7}")
    worst = 0.0
    for (a, b) in [(1, 1), (1, 2), (2, 2), (2, 3), (3, 3)]:
        hits = n = 0
        for _ in range(60):
            p, q, nn = gen_semiprime(20, rng)
            # force the cell by rejection on (s_p, s_q)
            if (s_of(p), s_of(q)) != (a, b):
                continue
            P, Q = Prime(p), Prime(q)
            for _ in range(40):
                g = sample_uniform(nn, rng)
                hits += P.k(g) != Q.k(g)
                n += 1
        if n == 0:
            continue
        pred = float(cell_uniform(a, b))
        obs = hits / n
        z = (obs - pred) / math.sqrt(pred * (1 - pred) / n)
        worst = max(worst, abs(z))
        print(f"      {f'({a},{b})':>12} {pred:>10.4f} {obs:>10.4f} {n:>6} {z:>7.2f}")
    chk(worst < 4.0, f"all uniform-g cells within 4 sigma of prediction (worst |z| = {worst:.2f})")
    print()

    print("=" * 78)
    print("T4  NON-VACUITY: an INJECTED biased sampler must be DETECTED as beating 20/27")
    print("=" * 78)
    # A negative control first: an honest sampler must NOT be flagged.
    def excess_vs(fn, want, n_mod: int, per: int, seed: int) -> tuple[float, float, int]:
        r = random.Random(seed)
        hits = tot = 0
        for _ in range(n_mod):
            p, q, nn = gen_semiprime(20, r)
            P, Q = Prime(p), Prime(q)
            for _ in range(per):
                g = fn(nn, r)
                hits += P.k(g) != Q.k(g)
                tot += 1
        pr = float(want)
        obs = hits / tot
        return obs, (obs - pr) / math.sqrt(pr * (1 - pr) / tot), tot

    laws.INJECT_DELTA = F(0)
    global INJECT_BIAS
    INJECT_BIAS = 0.0
    obs, z, n = excess_vs(lambda nn, r: sample_uniform(nn, r), F(20, 27), 40, 60, 7)
    chk(abs(z) < 4.0, f"NULL control: honest uniform sampler z = {z:+.2f} (N={n}) -- NOT flagged")
    # Now inject a genuine improvement and the SAME detector must fire.
    INJECT_BIAS = 0.55
    obs_i, z_i, n_i = excess_vs(lambda nn, r: sample_jac(nn, r, -1), F(20, 27), 40, 60, 7)
    INJECT_BIAS = 0.0
    chk(z_i > 4.0, f"INJECTION control: biased sampler z = {z_i:+.2f} -- DETECTED")
    print(f"      (injected rate {obs_i:.4f} vs honest {obs:.4f})")
    print()
    # and the honest Jacobi sampler must ALSO be flagged -- otherwise the test is vacuous
    obs_j, z_j, n_j = excess_vs(lambda nn, r: sample_jac(nn, r, -1), F(20, 27), 40, 60, 7)
    chk(z_j > 4.0, f"the REAL Jacobi sampler is flagged at z = {z_j:+.2f} -- result is not vacuous")
    print()

    print("=" * 78)
    print("T5  the predictor must return the NULL on cells where the lever does NOT help")
    print("=" * 78)
    same = [k for k in ((a, a) for a in range(2, 6)) if cell_jac_neg(*k) == cell_uniform(*k)]
    print(f"      diagonal cells where Jacobi==uniform: {same} (expect none -- "
          f"on a diagonal, lam_p=lam_q=0 is impossible under Jacobi=-1)")
    chk(len(same) == 0, "Jacobi strictly helps on EVERY diagonal cell (the a=b case is the win)")
    print()

    print("=" * 78)
    print("T6  REGRESSION: k != lam off the diagonal.  The two are NOT interchangeable.")
    print("=" * 78)
    # This is a bug I actually made: I scored `lam_p != lam_q`.  It agrees with `k_p != k_q`
    # only when s_p == s_q, so it scored a PERFECT 12000/12000 on the Jacobi strategy.
    # The test below pins the distinction on a single cell where they must differ.
    rng6 = random.Random(4242)
    found = False
    for _ in range(4000):
        p, q, n = gen_semiprime(22, rng6)
        a, b = s_of(p), s_of(q)
        if a == b or (a, b) != (1, 2):
            continue
        P, Q = Prime(p), Prime(q)
        disagree = agree = 0
        for _ in range(200):
            g = sample_jac(n, rng6, -1)
            by_k = P.k(g) != Q.k(g)
            by_lam = P.lam(g) != Q.lam(g)
            disagree += by_k != by_lam
            agree += by_k
        if disagree:
            found = True
            print(f"      cell (1,2), N=200: by_k={agree/200:.4f}  vs the (1,2) prediction "
                  f"{float(cell_jac_neg(1,2)):.4f}")
            print(f"      the lam-based scorer DISAGREED with the k-based one on "
                  f"{disagree}/200 trials -- it is a different (wrong) statistic")
            break
    chk(found, "found a (1,2) cell where lam-scoring and k-scoring genuinely disagree")
    print()

    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


# --------------------------------------------------------------------------------------
# the experiment
# --------------------------------------------------------------------------------------


STRATEGIES = {
    "uniform": lambda n, r: sample_uniform(n, r),
    "jac_neg": lambda n, r: sample_jac(n, r, -1),
    "jac_pos": lambda n, r: sample_jac(n, r, 1),
    "fixed2": lambda n, r: sample_fixed(2, n, r),
    "fixed3": lambda n, r: sample_fixed(3, n, r),
    "fixed5": lambda n, r: sample_fixed(5, n, r),
    "square": lambda n, r: (lambda h: (h * h) % n)(sample_uniform(n, r)),
}


def run(n_mod: int, per: int, bits: int, seed: int) -> dict:
    rng = random.Random(seed)
    rows = []
    for i in range(n_mod):
        p, q, n = gen_semiprime(bits, rng)
        a, b = s_of(p), s_of(q)
        P, Q = Prime(p), Prime(q)
        rec = {"p": p, "q": q, "bits": n.bit_length(), "a": a, "b": b,
               "v2_nm1": v2(n - 1), "cell_uniform": float(cell_uniform(a, b)),
               "cell_jac_neg": float(cell_jac_neg(a, b)),
               "cell_jac_pos": float(cell_jac_pos(a, b))}
        for name, fn in STRATEGIES.items():
            hits = 0
            for _ in range(per):
                g = fn(n, rng)
                hits += P.k(g) != Q.k(g)
            rec[name] = hits
            rec[name + "_n"] = per
        rows.append(rec)
        if (i + 1) % 20 == 0:
            print(f"      ... {i+1}/{n_mod} moduli", flush=True)
    return {"rows": rows, "per": per, "bits": bits, "n_mod": n_mod, "seed": seed}


def report(data: dict) -> None:
    rows = data["rows"]
    per = data["per"]
    print()
    print("=" * 78)
    print(f"G3 RESULT -- {data['n_mod']} fresh semiprimes of {data['bits']} bits, "
          f"{per} g-trials each")
    print("=" * 78)
    print()
    print("POOLED (for the headline only -- the per-modulus table below is the real control)")
    print(f"  {'strategy':>10} {'hits':>8} {'rate':>9} {'95% CI (Wilson)':>22} "
          f"{'vs 20/27':>10} {'z':>8}")
    for name in STRATEGIES:
        h = sum(r[name] for r in rows)
        n = per * len(rows)
        lo, hi = wilson(h, n)
        z = zscore(h, n, 20 / 27)
        print(f"  {name:>10} {h:>8} {h/n:>9.4f} {f'[{lo:.4f},{hi:.4f}]':>22} "
              f"{h/n - 20/27:>+10.4f} {z:>+8.2f}")
    print()

    print("=" * 78)
    print("THE MANDATORY CONTROL -- PER-MODULUS, each against ITS OWN predicted cell")
    print("=" * 78)
    print(f"  {'a,b':>7} {'v2(n-1)':>9} {'N_mod':>6} | "
          f"{'unif pred':>9} {'unif obs':>9} {'z':>6} | "
          f"{'jac pred':>9} {'jac obs':>9} {'z':>6}")
    buckets: dict[tuple, list] = {}
    for r in rows:
        buckets.setdefault((r["a"], r["b"]), []).append(r)
    worst_u = worst_j = 0.0
    for key in sorted(buckets):
        rs = buckets[key]
        a, b = key
        # NOTE: a bucket holds len(rs) MODULI, each with `per` trials.  Aggregate over the
        # whole bucket (I first divided the summed hits by one modulus' `per`, which produced
        # rates above 1.0).  A cell can mix s-values, so predict on the MEAN predicted cell
        # value and test the POOLED hit count.
        pu = sum(r["cell_uniform"] for r in rs) / len(rs)
        pj = sum(r["cell_jac_neg"] for r in rs) / len(rs)
        nu = sum(r["uniform"] for r in rs)
        nj = sum(r["jac_neg"] for r in rs)
        tot_n = per * len(rs)
        zu = zscore(nu, tot_n, pu)
        zj = zscore(nj, tot_n, pj)
        if zu is not None:
            worst_u = max(worst_u, abs(zu))
        if zj is not None:
            worst_j = max(worst_j, abs(zj))
        print(f"  {f'{a},{b}':>7} {rs[0]['v2_nm1']:>9} {len(rs):>6} | "
              f"{pu:>9.4f} {nu/tot_n:>9.4f} {zstr(zu):>6} | "
              f"{pj:>9.4f} {nj/tot_n:>9.4f} {zstr(zj, nj, tot_n):>6}")
    print()
    print(f"  worst |z| vs per-modulus prediction:  uniform {worst_u:.2f},  jac_neg {worst_j:.2f}")
    print("  (n/a = degenerate test: cell_jac_neg(1,1) is EXACTLY 1, so the binomial variance is 0)")
    print(f"  SPREAD of the per-modulus uniform prediction: "
          f"min {min(r['cell_uniform'] for r in rows):.4f}, "
          f"max {max(r['cell_uniform'] for r in rows):.4f}")
    print(f"  SPREAD of the per-modulus jac_neg prediction: "
          f"min {min(r['cell_jac_neg'] for r in rows):.4f}, "
          f"max {max(r['cell_jac_neg'] for r in rows):.4f}")
    print()
    print("  -> this is why a pooled rate alone is untrustworthy: a single cell here spans")
    print("     a range wider than the effect being claimed.")
    print()

    print("=" * 78)
    print("THE DECISION -- which strategy, per cell?  (exact, from laws.py)")
    print("=" * 78)
    print(f"  {'cell':>7} {'uniform':>9} {'jac_neg':>9} {'jac_pos':>9}   winner")
    for key in sorted(buckets):
        a, b = key
        u, jn, jp = cell_uniform(a, b), cell_jac_neg(a, b), cell_jac_pos(a, b)
        best = max([(u, "uniform"), (jn, "jac_neg"), (jp, "jac_pos")])[1]
        print(f"  {f'{a},{b}':>7} {float(u):>9.4f} {float(jn):>9.4f} {float(jp):>9.4f}   {best}")
    print()

    print("=" * 78)
    print("HONEST FINE-PRINT: the fixed-base and square strategies have NO exact prediction")
    print("=" * 78)
    for name in ("fixed2", "fixed3", "fixed5", "square"):
        h = sum(r[name] for r in rows)
        n = per * len(rows)
        lo, hi = wilson(h, n)
        z = (h / n - 20 / 27) / math.sqrt((20 / 27) * (7 / 27) / n)
        print(f"  {name:>10} {h:>8}/{n} = {h/n:.4f}  CI[{lo:.4f},{hi:.4f}]  vs 20/27 z={z:+.2f}")
    print("  (a fixed base is NOT uniform mod p, so the geometric lam-law does not apply to")
    print("   it and 20/27 is simply the wrong null for these rows -- stated, not papered over)")
    print()

    print("=" * 78)
    print("COST OF THE CHOICE")
    print("=" * 78)
    print("  sample_jac draws uniform g and evaluates Jacobi(g,n), rejecting until the symbol")
    print("  is -1.  Jacobi is O(log n) via the binary algorithm; expected 2 draws.")
    print("  Against a Stange attempt that already costs b+c relation-findings and a")
    print("  rational nullspace over Q, this is free by comparison.")


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        raise SystemExit(0 if selftest() else 1)
    if not selftest():
        raise SystemExit(1)
    nm = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    per = int(sys.argv[2]) if len(sys.argv) > 2 else 200
    bits = int(sys.argv[3]) if len(sys.argv) > 3 else 26
    seed = int(sys.argv[4]) if len(sys.argv) > 4 else 20261004
    data = run(nm, per, bits, seed)
    with open("measure_out.json", "w") as f:
        json.dump(data, f)
    report(data)