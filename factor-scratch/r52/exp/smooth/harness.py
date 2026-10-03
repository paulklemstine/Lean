"""
BB: SMOOTH-POWER SEARCH -- harness for the one measured bottleneck of Stange's method.

Read-only shared code is IMPORTED, never modified:
    /home/raver1975/lean/factor-scratch/r48/_shared/dickman.py   (is_smooth, rho)
    /home/raver1975/lean/factor-scratch/r48/exp/stange/stange.py  (factor_base,
        fb_exponents, kernel_basis, primitive, build_M, factor_from_multiple,
        order_mod_n, bbound_for_b, gen_semiprime)

THE QUANTITY THIS ROUND CLAIMS. The cost of Stange's relation finder is
    (multiplications to generate a candidate) + (operations to test it FB-smooth).
A sampler is only an improvement if it cuts the FIRST term without changing the
POPULATION the candidates are drawn from. "Changing the population" is the
failure mode round 48 walked into three times, so it gets an explicit test.

THE DISCRIMINATOR (preregistered, used for every rate reported here):

    A sampler whose candidates are FB-smooth at rate  1/alpha  where alpha is the
    measured rate and  rho(u) is the Dickman prediction is DEGENERATE if and only
    if  alpha * (1/rho(u))  is significantly > 1, i.e.  trials/rel < (1/rho(u)).

Equivalently define the SKEW  S = (trials/rel) * rho(u).   Sound sampler: S ~ 1.
Degenerate sampler: S << 1 (finds smooth values faster than the population allows).

TWO independent degeneracy axes are measured, because round 48 only found one:

  AXIS 1 (smoothness):  S = (trials/rel) * rho(u).  The seq sampler has S ~ 0.36.
  AXIS 2 (algebraic):   the exponent vectors of the collected relations must
                        (a) SPAN -- rank(M) = b, and
                        (b) generate alpha_t that are NOT all zero.
                        A sampler whose candidates lie in a low-dimensional slice
                        of the exponent lattice produces a spurious kernel.

A harness that checks only AXIS 1 is blind to AXIS 2, and vice versa. The
self-test below is REQUIRED to flag the known-bad `seq` sampler on BOTH axes;
if it cannot, it is refused.
"""

from __future__ import annotations

import math
import random
import sys
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

from dickman import is_smooth, rho                      # noqa: E402  (shared)
from stange import (factor_base, fb_exponents, kernel_basis, primitive,  # noqa: E402
                    build_M, bbound_for_b, gen_semiprime, order_mod_n)

PARSERANGE = slice(0, 0)


# ---------------------------------------------------------------------------
# MULTIPLICATION COUNTING -- a trial is not a multiplication.
# ---------------------------------------------------------------------------
#
# A `pow(g, x, n)` is O(log x) MODULAR MULTIPLICATIONS.  A strided step
# r <- r * g^s mod n is ONE.  Reporting "trials/rel" without saying which is
# which is not a result (round-48 lesson).  So every sampler returns an explicit
# mult count, obtained from an instrumented pow rather than a formula.

def pow_counted(g: int, x: int, n: int):
    """Left-to-right square-and-multiply mod n. Returns (g^x mod n, nmults).

    CPython's built-in pow uses a sliding window for long exponents, so it is
    NOT the cost model used here; we count the plain binary chain, which is
    what a hand-written sampler would do and is a LOWER bound on the built-in.
    Both are reported separately in the notes.
    """
    if x == 0:
        return 1 % n, 0
    r = 1
    mults = 0
    for bit in bin(x)[2:]:
        if bit == "1":
            r = (r * r) % n
            mults += 1
            r = (r * g) % n
            mults += 1
        else:
            r = (r * r) % n
            mults += 1
    return r % n, mults


def _selftest_pow_counter():
    """The mult counter must be exact, or every cost ratio downstream is fiction."""
    ok = True
    rng = random.Random(5)
    for _ in range(40):
        n = rng.getrandbits(64) | 1
        if n < 3:
            continue
        g = rng.randrange(2, n - 1)
        x = rng.randrange(1, 10**18)
        r, m = pow_counted(g, x, n)
        if r != pow(g, x, n):
            print(f"  [FAIL] pow_counted wrong at x={x}")
            ok = False
            break
    # Explicit small-case count, by hand.
    r, m = pow_counted(3, 1, 10**6 + 7)
    if (r, m) != (3, 2):
        print(f"  [FAIL] pow_counted(3,1,n) -> {(r, m)}, expected (3, 2)")
        ok = False
    r, m = pow_counted(3, 2, 10**6 + 7)   # 2 = 10b -> sqr,mul,sqr = 3 mults
    if (r, m) != (9, 3):
        print(f"  [FAIL] pow_counted(3,2,n) -> {(r, m)}, expected (9, 3)")
        ok = False
    r, m = pow_counted(3, 5, 10**6 + 7)   # 5 = 101b -> sqr,mul,sqr,sqr,mul = 5 mults
    if (r, m) != (243, 5):
        print(f"  [FAIL] pow_counted(3,5,n) -> {(r, m)}, expected (243, 5)")
        ok = False
    print(f"  [{'PASS' if ok else 'FAIL'}] pow_counted matches pow() and hand counts")
    return ok


# ---------------------------------------------------------------------------
# FAST FB-smoothness.  |FB| is small in the realistic Stange regime (b = 6..40),
# so plain trial division over FB is both exact and fast.  The shared is_smooth
# is used as the independent check.
# ---------------------------------------------------------------------------

class FbTest:
    """Exponent-vector + smoothness test for a fixed factor base.

    ops counts the modular reductions actually performed, so the smoothness
    term of the cost model is MEASURED and not guessed.

    The cache is OFF by default: for the random/stride samplers every residue is
    distinct, so a cache is pure memory burn, and a cache would make `ops` count
    a repeat as free.  `squares` turns it on because it re-tests the same
    residue family by construction.
    """

    def __init__(self, FB, cache=False):
        self.FB = list(FB)
        self.nFB = len(self.FB)
        self.B = self.FB[-1] if self.FB else 1
        self._cache = {} if cache else None

    def __call__(self, r: int):
        """Return (exponent tuple, leftover, n_reductions). leftover == 1 <=> smooth."""
        if self._cache is not None:
            hit = self._cache.get(r)
            if hit is not None:
                return hit
        x, exps, ops = r, [], 0
        for p in self.FB:
            ops += 1
            if x % p == 0:
                e = 0
                while x % p == 0:
                    x //= p
                    e += 1
                    ops += 1
                exps.append(e)
            else:
                exps.append(0)
            if x == 1:
                # ⚠️ MUST pad to full length.  A smooth residue (1, 2, 4, ...) hits
                # the early break after ONE prime, so without padding the exponent
                # vector is SHORTER than |FB| and build_M() raises IndexError --
                # or, worse, silently truncates the relation and corrupts the
                # rank.  Found by the `squares` sampler, which produces many
                # small smooth residues.
                while len(exps) < len(self.FB):
                    exps.append(0)
                break
        out = (tuple(exps), x, ops)
        if self._cache is not None:
            if len(self._cache) > 1_000_000:
                self._cache.clear()
            self._cache[r] = out
        return out


# ---------------------------------------------------------------------------
# SAMPLERS
# ---------------------------------------------------------------------------
#
# Every sampler yields (x, candidate, nmults_for_this_candidate) and records
# trials / mults / smoothness-ops.  `ops` is the only comparable currency.

def sampler_random(n, g, rng, x0=None, stride=None, cap=None):
    """x uniform in [1,n); candidate pow(g,x,n); ~2*log2(x) multiplications."""
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    while True:
        state["trials"] += 1
        x = rng.randrange(1, n)
        r, m = pow_counted(g, x, n)
        state["mults"] += m
        yield x, r, m, state
        if cap and state["trials"] > cap:
            return


def sampler_seq(n, g, rng, x0=None, stride=None, cap=None):
    """x = 1,2,3,... ; r <- r*g ; ONE multiplication.  KNOWN-DEGENERATE CONTROL.

    (AA_stride_sampler.md found the cause: g^x mod n is a TINY INTEGER for small
    x -- g^1 = 2 is 2-smooth, g^2 = 4, ... -- so seq harvests a corner of the
    candidate space, not the population.  Kept here as the required negative
    control for the self-test.)
    """
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    x, r = 1, g % n
    while True:
        state["trials"] += 1
        state["mults"] += 1
        yield x, r, 1, state
        r = (r * g) % n
        x += 1
        if cap and state["trials"] > cap:
            return


def sampler_stride(n, g, rng, x0=None, stride=None, cap=None):
    """x = x0, x0+s, x0+2s, ... ; r <- r * g^s ; ONE multiplication per candidate.

    x0 defaults to n//4 (full-size exponents: g^x mod n is a full-length
    integer, so no small-x corner).  s defaults to a fresh ODD random value in
    [n/4, n/2) so that the progression visits full-size x throughout.

    ⚠️ THE BUG THIS FUNCTION HAD, AND WHY IT WAS INVISIBLE FOR A LONG TIME.
    The original version wrote `x = (x + stride) % n`.  That is WRONG: the
    exponent label is only meaningful modulo ord(g), and ord(g) does NOT divide
    n.  Indeed ord(g) | lcm(p-1, q-1) | (p-1)(q-1) and gcd((p-1)(q-1), pq) = 1,
    so g^n is NOT 1 mod n in general.  After the first wrap (which happens after
    1-3 steps, since x0 = n/4 and s is up to n/2) the recorded label x no longer
    satisfied  g^x == r  (mod n).

    The damage was selective and therefore hard to see:
      * the SMOOTHNESS RATE was unaffected -- it depends only on the residue r,
        which is always a genuine group element;
      * rank(M) was fine -- the exponent vectors are still valid relations;
      * but every alpha_t = sum_j v_j x_j was built from FALSE exponents, so
        ord(g) no longer divided them, and G = gcd(alpha_t) was garbage.
    Result: stride factored 0/60 instances while `random` factored 47/60, with
    every smoothness diagnostic passing.  `hunt()` now asserts the invariant
    g^x == prod p_i^{e_i} (mod n) for EVERY relation it returns, for EVERY
    sampler, which turns this from a silent 100% failure into an immediate
    exception.  `x` is now allowed to grow without bound.
    """
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    if x0 is None:
        x0 = n // 4
    if stride is None:
        stride = rng.randrange(n // 4, n // 2) | 1
    gs, setup = pow_counted(g, stride, n)
    state["mults"] += setup          # one-time setup, reported separately
    state["setup"] = setup
    x, r = x0 % n, pow_counted(g, x0, n)[0]
    state["mults"] += 1              # one-time g^x0
    state["setup"] += 1
    while True:
        state["trials"] += 1
        state["mults"] += 1
        yield x, r, 1, state
        r = (r * gs) % n
        x = x + stride               # NOT reduced: the label must stay exact
        if cap and state["trials"] > cap:
            return


def sampler_squares(n, g, rng, x0=None, stride=None, cap=None):
    """Pollard-rho style: x = 1,2,4,8,... ; r <- r*r ; ONE multiplication.

    NOTE the trap this creates, which the notes report: if r_k is FB-smooth
    then r_{k+1} = r_k^2 is too, so one hit yields 2^(|FB|) 'relations' that are
    ALL PROPORTIONAL -- rank(M) collapses.  Cheap in multiplications and
    catastrophic for the linear algebra.  Measured, not asserted.
    """
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    x, r = 1, g % n
    while True:
        state["trials"] += 1
        state["mults"] += 1
        yield x, r, 1, state
        r = (r * r) % n
        x *= 2
        if cap and state["trials"] > cap:
            return


def sampler_tiny(n, g, rng, x0=None, stride=None, cap=None):
    """DELIBERATELY DEGENERATE CONTROL, for the self-test only.

    Yields uniformly random integers from [2, 100) as if they were residues.
    Every one of them is FB-smooth for any B >= 100, so the hit rate is 1 by
    construction.  It is NOT a sampler anyone would ship; it exists so that the
    discriminator has to reject a sampler whose degeneracy has a DIFFERENT
    signature from `seq` (this one is i.i.d.-uniform, not a walk).  A
    discriminator that only happens to catch `seq` would pass this one.
    """
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    while True:
        state["trials"] += 1
        r = rng.randrange(2, 100)
        yield int(r), r, 0, state
        if cap and state["trials"] > cap:
            return


def sampler_smooth_index(n, g, rng, x0=None, stride=None, cap=None,
                         y=None, max_len=24):
    """S2: choose x to be a y-SMOOTH INTEGER, candidate pow(g,x,n).

    Q: does forcing x smooth force g^x mod n FB-smooth?
    Implemented by walking the semigroup: keep a heap of smooth integers below a
    cap, take them in increasing order (so the exponent is never small either --
    the x must still be ~n-sized to avoid the small-x corner, which is only
    possible if y is large).  Returns candidates via a real pow.
    """
    state = {"trials": 0, "mults": 0, "smoothops": 0}
    if y is None:
        y = max(4, int(round(math.log2(n)) // 3))
    import heapq
    h = [1]
    seen = {1}
    cap_x = n
    while True:
        m = heapq.heappop(h)
        if m >= cap_x:
            break
        state["trials"] += 1
        r, mm = pow_counted(g, m, n)
        state["mults"] += mm
        yield m, r, mm, state
        for py in range(2, y + 1):
            v = m * py
            if v < cap_x and v not in seen:
                seen.add(v)
                heapq.heappush(h, v)
        if cap and state["trials"] > cap:
            return


SAMPLERS = {
    "random": sampler_random,
    "seq": sampler_seq,
    "stride": sampler_stride,
    "squares": sampler_squares,
    "smoothidx": sampler_smooth_index,
    "TINY_CONTROL": sampler_tiny,
}


# ---------------------------------------------------------------------------
# HUNT: collect `need` FB-smooth relations, returning counts + the relation list
# ---------------------------------------------------------------------------

def hunt(n, g, FB, need, rng, sampler="random", cap=4_000_000, verify=True, **kw):
    """Return dict with rels [(exps, x)], trials, mults, setup_mults, smoothops.

    ⚠️ INVARIANT, now enforced (this is the test that would have caught the
    `x %= n` bug that made stride factor 0/60 while every rate diagnostic
    passed).  For EVERY relation returned, for EVERY sampler:

        g^x  ==  prod_i p_i^{e_i}   (mod n)

    The exponent label x is what the linear algebra multiplies by; if it is not
    a true exponent then alpha_t = sum_j v_j x_j need not be divisible by
    ord(g), G = gcd(alpha_t) is meaningless, and the method silently returns
    nothing while every smoothness statistic looks perfect.
    """
    fb = FB if isinstance(FB, FbTest) else FbTest(FB)
    gen = SAMPLERS[sampler](n, g, rng, **kw)
    rels, seen = [], set()
    smoothops = 0
    for x, r, m, st in gen:
        exps, rem, ops = fb(r)
        smoothops += ops
        if rem == 1 and x not in seen:
            seen.add(x)
            rels.append((exps, x))
            if verify:
                prod = 1
                for pp, e in zip(fb.FB, exps):
                    if e:
                        prod = prod * pow(pp, e) % n
                if pow(g, x, n) != prod:
                    raise AssertionError(
                        f"RELATION INVARIANT VIOLATED by sampler {sname_of(sampler)!r}: "
                        f"g^x != prod p^e (mod n) at x={x}. The exponent label is "
                        f"not a true exponent; every alpha_t built from it is wrong.")
            if len(rels) >= need:
                break
        if st["trials"] > cap:
            break
    return {"rels": rels, "trials": st["trials"], "mults": st["mults"],
            "setup": st.get("setup", 0), "smoothops": smoothops,
            "FbTest": fb}


def sname_of(s):
    return s


# ---------------------------------------------------------------------------
# DEGENERACY PANEL -- the two axes
# ---------------------------------------------------------------------------

def kernel_diagnostics(rels, b, c, n=None, p=None, q=None):
    """Rank, alpha_t zero-fraction, all-zero flag, dimension of ker.

    AXIS 2.  A relation set is DEGENERATE here if rank(M) < b (the exponent
    vectors fail to span -- the kernel is an artifact) or if every one of the
    c selected alpha_t is exactly zero (no multiple of ord(g) can be formed).
    """
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    cc = min(c, len(K))
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels)))
             for v in K[:cc]]
    nz = [bb for bb in betas if bb != 0]
    G = 0
    for bb in betas:
        G = gcd(G, abs(bb))
    return {"rank": rank, "rank_full": rank == b, "dimK": len(K),
            "betas": betas, "zero_frac": (1 - len(nz) / cc) if cc else 1.0,
            "all_zero": (len(nz) == 0), "G": G}


# ---------------------------------------------------------------------------
# THE DICKMAN PREDICTION
# ---------------------------------------------------------------------------

def predicted(n, B):
    """rho(u) with u = log n / log B  -- the ASYMPTOTIC uniform-integer density.

    ⚠️ VALIDITY DOMAIN, and it is narrow.  rho(u) is a limit as n -> infinity
    at FIXED u.  Stange's own regime has b = 6..40, so B = bbound_for_b(b) is
    13..173, and at n ~ 2^30..2^40 the parameter u = log n / log B is 4.9..8.1.
    rho(6) ~ 4e-5 and the EXACT density of B-smooth integers at these sizes is
    orders of magnitude larger (see notes, "the null is wrong, not the sampler").
    So rho(u) is reported for reference and is NOT used as the pass/fail null;
    the matched MEASURED null below is.
    """
    return rho(math.log(n) / math.log(B))


def null_rate(n, B, fb, trials=20000, rng=None):
    """MEASURED density of FB-smooth integers among uniform integers in [2,n).

    This is the matched-scale null every sampler rate is compared against.  It
    is measured with the SAME FbTest that tests the candidates, so the two
    numbers cannot disagree for a bookkeeping reason.

    Why not rho(u): Dickman's theorem is an asymptotic limit at fixed u, and the
    Stange regime sits at u ~ 5-8 with B ~ 20-200, where the asymptotic value is
    far below the true finite-size density.  The self-test asserts both facts.
    """
    rng = rng or random.Random(0)
    hits = 0
    for _ in range(trials):
        if fb(rng.randrange(2, n))[1] == 1:
            hits += 1
    return hits / trials


def skew(trials_per_rel, prob):
    """S = (trials/rel) * density.  S ~ 1 sound; S << 1 degenerate.

    Applies to ANY density null -- rho(u) where it is valid, the measured
    uniform density everywhere else.
    """
    return (trials_per_rel) * prob


def _selftest_shared():
    """The shared harness must be calibrated before we measure anything with it."""
    ok = True
    for u, want in ((1.0, 1.0), (2.0, 0.3068528), (3.0, 0.0486084),
                    (4.0, 0.0049109)):
        got = rho(u)
        if abs(got - want) > 1e-5:
            print(f"  [FAIL] rho({u}) = {got:.7f}, expected {want}")
            ok = False
    if not is_smooth(2**60, 2):
        print("  [FAIL] is_smooth(2^60, 2) is False")
        ok = False
    if is_smooth(2 * 1009, 1000):
        print("  [FAIL] is_smooth(2*1009, 1000) is True")
        ok = False
    print(f"  [{'PASS' if ok else 'FAIL'}] shared dickman harness calibrated")
    return ok


def _selftest_fbtest():
    """FbTest must agree with the shared is_smooth at the bound, exactly."""
    ok = True
    B = 1000
    fb = FbTest([p for p in range(2, B + 1) if all(p % k for k in range(2, int(p**0.5) + 1))])
    probes = [1, 2, 997, 997 * 991, 1009, 1009 * 991, 2**60, 3 * 5 * 7 * 11 * 997,
              10**18, (2**31 - 1), 997**3, 1009**3]
    rng = random.Random(3)
    probes += [rng.randrange(2, 10**18) for _ in range(400)]
    for m in probes:
        exps, rem, _ = fb(m)
        fast = (rem == 1)
        ref = is_smooth(m, B)
        if fast != ref:
            print(f"  [FAIL] FbTest({m}) = {fast}, is_smooth = {ref}")
            ok = False
            break
        # exponent vector must reconstruct the number exactly when smooth
        if fast:
            v = 1
            for p, e in zip(fb.FB, exps):
                v *= p ** e
            if v != m:
                print(f"  [FAIL] FbTest exponent vector for {m} gives {v}")
                ok = False
                break
    print(f"  [{'PASS' if ok else 'FAIL'}] FbTest agrees with shared is_smooth "
          f"({len(probes)} probes) and exponent vectors reconstruct exactly")
    return ok


# ---------------------------------------------------------------------------
# THE SELFTEST THAT MATTERS: it must FAIL on a deliberately degenerate sampler.
# ---------------------------------------------------------------------------

def selftest(verbose=True) -> bool:
    """
    Requirement (round 48, three times earned): the first test must fail on a
    deliberately degenerate sampler.  We therefore build a sampler that is
    KNOWN-BAD in a way we control exactly --

        DEGENERATE-BY-CONSTRUCTION: return residues that are literally small
        integers (g^x is small because x is small), i.e. force c and rem==1 by
        sampling from the FB-smooth numbers themselves.

    That is the exact population `seq` was harvesting (g^1 = 2, g^2 = 4, ...),
    so it must be flagged.  If this harness cannot flag a sampler that is
    sampling from the smooth numbers BY DEFINITION, no measurement it makes
    afterwards can be trusted.
    """
    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        if not cond:
            ok = False
        if verbose:
            print(f"  [{'PASS' if cond else 'FAIL'}] {name} {detail}")

    if verbose:
        print("== ST0. shared harness calibration ==")
    ok &= _selftest_shared()
    if verbose:
        print("== ST1. multiplication counter ==")
    ok &= _selftest_pow_counter()
    if verbose:
        print("== ST2. FbTest vs shared is_smooth ==")
    ok &= _selftest_fbtest()

    # ------------------------------------------------------------------
    # ST3 -- the discriminator must flag TWO samplers that are degenerate by
    #       construction, with different signatures, and must NOT flag a sound
    #       one.  Null = the MEASURED uniform FB-smooth density (rho(u) is
    #       invalid in the Stange regime; ST3b proves that below).
    # ------------------------------------------------------------------
    if verbose:
        print("== ST3. the discriminator flags degenerate samplers and passes sound ones ==")
    bits, b, c = 34, 12, 6
    rng = random.Random(1)
    n, p, q = gen_semiprime(bits, rng)
    BB = bbound_for_b(b)
    FB = factor_base(BB, n)
    assert len(FB) == b
    g = 2
    fb = FbTest(FB)
    rho_u = predicted(n, BB)
    u = math.log(n) / math.log(BB)
    nu = null_rate(n, BB, fb, trials=20000, rng=random.Random(2026))
    print(f"  (n=2^{n.bit_length()}, B={BB}, |FB|={b}, u={u:.2f})")
    print(f"  null density: rho(u)={rho_u:.3e}  MEASURED={nu:.3e}  "
          f"ratio measured/rho = {nu / rho_u:.3g}")

    hr = hunt(n, g, FB, 40, random.Random(99), "random", cap=2_000_000)
    tpr_rand = hr["trials"] / len(hr["rels"])
    S_rand = skew(tpr_rand, nu)
    check(f"sound `random` sampler: S={S_rand:.2f} within [0.3, 3.0] (NOT flagged)",
          0.3 <= S_rand <= 3.0, f"(trials/rel {tpr_rand:.1f})")

    # degenerate #1: i.i.d. uniform from [2,100) -- every value FB-smooth.
    # TINY_CONTROL is not a group sampler (it yields arbitrary small integers),
    # so the relation invariant does not apply to it by construction.
    ht = hunt(n, g, FB, 40, random.Random(99), "TINY_CONTROL", cap=100000,
              verify=False)
    S_tiny = skew(ht["trials"] / len(ht["rels"]), nu)
    check(f"degenerate #1 (i.i.d. tiny, different signature) S={S_tiny:.4f} < 0.5 FLAGGED",
          S_tiny < 0.5)

    # degenerate #2: the real `seq` walk.
    hs = hunt(n, g, FB, 40, random.Random(99), "seq", cap=2_000_000)
    tpr_seq = hs["trials"] / len(hs["rels"])
    S_seq = skew(tpr_seq, nu)
    check(f"degenerate #2 (`seq` walk) S={S_seq:.3f} < 0.7 FLAGGED", S_seq < 0.7,
          f"(trials/rel {tpr_seq:.2f})")

    # ------------------------------------------------------------------
    # ST3b -- document the null failure.  rho(u) must DISAGREE with the exact
    #        density in the Stange regime, or using it as a null is a bug.
    #        rho(u) is the wrong null at u ~ 5-8; this test FAILS if someone
    #        later "fixes" the regime to a large B and removes the caveat.
    # ------------------------------------------------------------------
    if verbose:
        print("== ST3b. rho(u) is NOT a valid null in the Stange regime ==")
    check(f"at u={u:.2f}, measured density exceeds rho(u) by > 5x "
          f"({nu / rho_u:.3g}x)", nu / rho_u > 5)
    # ... and at a LARGE B (u ~ 2), rho(u) must become valid again.
    B2, bits2 = 1 << 17, 34
    n2, _, _ = gen_semiprime(bits2, random.Random(1))
    fb2 = FbTest(factor_base(B2, n2))
    nu2 = null_rate(n2, B2, fb2, trials=4000, rng=random.Random(7))
    rho2 = predicted(n2, B2)
    check(f"at B=2^17, n=2^{n2.bit_length()} (u={math.log(n2)/math.log(B2):.2f}), "
          f"rho(u)={rho2:.4f} vs measured {nu2:.4f} -- ratio {nu2/rho2:.2f} in [0.8,1.25]",
          0.8 <= nu2 / rho2 <= 1.25)

    # ------------------------------------------------------------------
    # ST4 -- the repair must NOT be flagged (this is the claim under test).
    # ------------------------------------------------------------------
    if verbose:
        print("== ST4. stride at full-size x0 is NOT flagged; stride at x0=1 IS ==")
    hd = hunt(n, g, FB, 40, random.Random(99), "stride", x0=n // 4,
              stride=random.Random(5).randrange(n // 4, n // 2) | 1, cap=2_000_000)
    S_full = skew(hd["trials"] / len(hd["rels"]), nu)
    hbad = hunt(n, g, FB, 40, random.Random(99), "stride", x0=1, stride=7,
                cap=2_000_000)
    S_bad = skew(hbad["trials"] / len(hbad["rels"]), nu)
    check(f"stride x0=1 (small-x corner) S={S_bad:.3f} FLAGGED vs sound {S_rand:.2f}",
          S_bad < S_rand * 0.7)
    check(f"stride x0=n/4 (the repair) S={S_full:.2f} NOT flagged", S_full >= S_rand * 0.5)

    # ------------------------------------------------------------------
    # ST5 -- AXIS 2: the panel must flag a rank-collapsed relation set.
    #        Built by CONSTRUCTION.  Columns e, 2e, 3e, ... with exponents
    #        x_j = j+1: this is EXACTLY the `squares` sampler's relation set
    #        (r_{k+1} = r_k^2 => e -> 2e, x -> 2x... here x_j = j+1 gives the
    #        simplest instance: beta = sum v_j (j+1) = 0 for every kernel v).
    # ------------------------------------------------------------------
    if verbose:
        print("== ST5. the axis-2 panel flags a rank-collapsed relation set ==")
    ex = [0] * b
    ex[0], ex[1] = 3, 1
    fake = [(tuple(v * (k + 1) for v in ex), k + 1) for k in range(b + c)]
    dg = kernel_diagnostics(fake, b, c)
    check(f"proportional columns -> rank {dg['rank']} < b={b} FLAGGED",
          not dg["rank_full"])
    check(f"  and all selected alpha_t are zero (zero_frac={dg['zero_frac']:.2f})",
          dg["all_zero"])

    # a genuine (random-exponent) relation set must NOT be flagged
    rnd = [(tuple(rng.randrange(0, 6) for _ in range(b)), rng.randrange(10**18, 10**19))
           for _ in range(b + c)]
    dg2 = kernel_diagnostics(rnd, b, c)
    check(f"generic columns -> rank {dg2['rank']} == b (not flagged)", dg2["rank_full"])
    check("  and not all alpha_t zero", not dg2["all_zero"])

    # ------------------------------------------------------------------
    # ST6 -- THE RELATION INVARIANT.  Every sampler must return relations with
    #        g^x == prod p_i^{e_i} (mod n).  This is checked by hunt() itself,
    #        and here it is checked against a DELIBERATELY BROKEN sampler that
    #        reduces its exponent label mod n -- the exact bug that made stride
    #        factor 0/60 with every rate diagnostic passing.  If the invariant
    #        does not REJECT the broken sampler it cannot certify the real ones.
    # ------------------------------------------------------------------
    if verbose:
        print("== ST6. the relation invariant g^x == prod p^e (mod n) ==")
    n6, _, _ = gen_semiprime(30, random.Random(42))
    FB6 = factor_base(bbound_for_b(10), n6)
    # 1) the real stride sampler must PASS
    try:
        h6 = hunt(n6, 2, FB6, 6, random.Random(43), "stride",
                  x0=n6 // 4, stride=random.Random(44).randrange(n6 // 4, n6 // 2) | 1,
                  cap=500000)
        check(f"real `stride` sampler satisfies the invariant ({len(h6['rels'])} rels)",
              len(h6["rels"]) >= 6)
    except AssertionError as e:
        check(f"real `stride` sampler satisfies the invariant -- {e}", False)
    # 2) a sampler with the mod-n wrap must be REJECTED
    def _broken_stride(n, g, rng, x0=None, stride=None, cap=None):
        st = {"trials": 0, "mults": 0, "smoothops": 0}
        x0 = n // 4 if x0 is None else x0
        stride = rng.randrange(n // 4, n // 2) | 1 if stride is None else stride
        gs = pow(g, stride, n)
        x, r = x0 % n, pow(g, x0, n)
        while True:
            st["trials"] += 1
            yield x, r, 1, st
            r = (r * gs) % n
            x = (x + stride) % n          # <-- THE BUG, reinstated on purpose
            if cap and st["trials"] > cap:
                return
    SAMPLERS["_BROKEN_modn"] = _broken_stride
    try:
        hunt(n6, 2, FB6, 8, random.Random(45), "_BROKEN_modn",
             x0=n6 // 4, stride=random.Random(46).randrange(n6 // 4, n6 // 2) | 1,
             cap=500000)
        check("the mod-n-wrapped sampler is REJECTED by the invariant", False,
              " -- harness accepted a broken sampler; it cannot certify a good one")
    except AssertionError:
        check("the mod-n-wrapped sampler is REJECTED by the invariant", True)

    if verbose:
        print()
        print("ALL SELFTESTS PASS -- the harness can see both degeneracy axes and "
              "can reject a broken exponent label."
              if ok else
              "!!! SELFTEST FAILURE -- this harness is BLIND; do not trust any "
              "measurement made with it.")
    return ok


if __name__ == "__main__":
    sys.exit(0 if selftest() else 1)
