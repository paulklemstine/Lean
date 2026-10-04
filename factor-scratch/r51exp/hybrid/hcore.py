"""
hcore.py -- the HYBRID pipeline: NFS relation-finding feeding Stange's Q-kernel + gcd.

Round 51 exp, `hybrid`.  Working dir `factor-scratch/r51exp/hybrid/`.

THE QUESTION THIS MODULE EXISTS TO ANSWER
-----------------------------------------
    Is `NFS relation-finding + Stange's linear-algebra/gcd` faster, end to end, than
    plain NFS -- and if not, by exactly how much, and is there any size regime where
    it wins?

Three prior results have never been combined:
  * PP_droptest.md  -- Stange's kernel is 5% of the phase (backend-dependent, 0.3-91%);
                       verdict (b) EQUIVALENT.
  * OO_bneed.md     -- NFS relation-finding drops required b from 5.9e5 to 8.4.
  * II_baseg.md     -- Jacobi-conditioned base: 20/27 -> 8/9, a free 1.2x.

WHAT IS IMPORTED (READ-ONLY) AND WHY
------------------------------------
  * `r48/exp/stange/stange.py`  -- the VALIDATED Algorithm 2.2 (factor base, relation
                                   finder, `primitive`, `factor_from_multiple`,
                                   `gen_semiprime`).  Reused rather than re-implemented;
                                   its own selftest passes 40/40 (verified this session).
  * `r50exp/baseg/laws.py`      -- the exact per-cell 2-adic laws, so the mandatory
                                   per-modulus `p_split` control uses the SAME cell
                                   functions the campaign validated (20/27, 8/9).

WHAT IS RE-IMPLEMENTED (and why it cannot be imported)
-----------------------------------------------------
  The Q-KERNEL.  `stange.kernel_basis` calls `sympy.Matrix.nullspace()`, which the
  campaign has recorded as taking >400 s at b=52 and never finishing -- and PP_droptest
  §3.2 re-measured the same thing on the same matrix at 0.013 s via
  `DomainMatrix.rref` over `QQ`.  So the incumbent kernel is UNUSABLE for an end-to-end
  timing at the sizes in H2.  This module uses the `DomainMatrix`/`QQ` route exclusively.

  >>> MANDATES HONOURED HERE (from the task brief):
  >>>   * `DomainMatrix.rref` over `QQ`, NEVER `ZZ`   -- rref over ZZ reduces on pivot
  >>>     columns only, so kernel extraction silently returns wrong vectors.
  >>>   * assert non-vacuity, not just correctness.  The undivided reconstruction is
  >>>     identically zero and PASSES `M w = 0 mod p`.  So every kernel vector here is
  >>>     checked for (a) `M v = 0` exactly over Q AND (b) `v != 0` AND (c) the
  >>>     reconstruction of the beta/gcd actually being nonzero where the maths says it
  >>>     must be.  See `KernelResult` and `assert_nonvacuous`.
"""

from __future__ import annotations

import math
import random
import sys
import time
from fractions import Fraction
from math import gcd
from typing import Iterable

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r50exp/baseg")

import stange  # noqa: E402  (read-only, validated)
import laws  # noqa: E402  (read-only, exact 2-adic cells)
from measure import jacobi as _jacobi_impl  # noqa: E402  (II_baseg's O(log n) symbol)

from sympy import QQ, ZZ  # noqa: E402
from sympy.polys.matrices import DomainMatrix  # noqa: E402

# ---------------------------------------------------------------------------
# The backend mandate, asserted at import time so no experiment can silently
# regress to the slow/incorrect route.
# ---------------------------------------------------------------------------
assert hasattr(DomainMatrix, "rref"), "DomainMatrix.rref missing -- backend mandate unmet"

NFS_BETA = (32.0 / 9.0) ** (1.0 / 3.0)   # OO_bneed's beta_NFS, flagged there as least solid


# ===========================================================================
# PHASE 1 -- the Q-KERNEL (Stange's Algorithm 2.2 step 12), DomainMatrix/QQ route
# ===========================================================================

class FloatLeak(Exception):
    """PP_droptest §4: `DomainMatrix.rref()` over QQ leaks genuine python floats on
    rank-deficient integer matrices (20/20 synthetic, 0/4 real).  A float in an EXACT
    route turns an exact computation into an approximate one, and `Fraction(1.0)` is
    indistinguishable from a correctly-rounded exact value after the fact.  STRICT
    REJECTION: raise, never convert."""


class VacuousKernel(Exception):
    """A kernel routine can satisfy its own correctness test and return nothing.  The
    undivided reconstruction is identically zero and still passes `M w = 0 mod p`
    because the zero vector lies in every kernel.  Raised when dim == 0."""


def _as_rational(x):
    """Coerce a QQ entry to an exact `Fraction`, REJECTING floats.

    The backend is flint-backed on this host, so entries arrive as
    `sympy.external.pythonmpq.PythonMPQ`, NOT `sympy.Rational` -- its `.p`/`.q` do not
    exist, and a `hasattr(x,'q')` probe (the shape r48's `_denominator` uses for sympy
    Rationals) would silently mis-coerce every entry.  `.numerator`/`.denominator` is
    the flint-exact API and is what is used here.  Floats are rejected, never converted.
    """
    if isinstance(x, float):
        raise FloatLeak(f"QQ rref returned a python float {x!r}; exact route refused")
    if isinstance(x, Fraction):
        return x
    if isinstance(x, int):
        return Fraction(x)
    num = getattr(x, "numerator", None)
    den = getattr(x, "denominator", None)
    if num is not None and den is not None:
        return Fraction(int(num), int(den))
    if hasattr(x, "p") and hasattr(x, "q"):        # sympy Rational fallback
        return Fraction(int(x.p), int(x.q))
    raise TypeError(f"unhandled exact-rational type {type(x)!r}")


def kernel_qq(Mrows: list[list[int]], *, check_nonvacuous: bool = True):
    """Right kernel of M over Q, as a list of INTEGER vectors (Algorithm 2.2 step 12).

    M is b x (b+c); its COLUMNS are the relations.  We want `M v = 0`, i.e. column
    combinations that vanish -- Stange p.3 verbatim: "Compute independent vectors
    b_1,...,b_c in Q^{b+c} in the right kernel of this matrix".

    Route: `DomainMatrix(rows,(b,m),ZZ).convert_to(QQ).rref()`.  The `ZZ` is only the
    INPUT container (an integer matrix has integer entries); the REDUCTION is over `QQ`,
    which is the mandate.  rref over `ZZ` -- which is the hazard -- is never called.

    Returns `(vectors, info)` where `vectors` are integer vectors of length m and `info`
    carries rank/dim for the non-vacuity audit.

    Non-vacuity: `dim == 0` means the routine found *nothing*.  Stange needs dim >= c, so
    a dim-0 result is a FAILURE of the experiment's premise, not a slow path.  Raised.
    """
    b = len(Mrows)
    if b == 0:
        raise VacuousKernel("empty matrix")
    m = len(Mrows[0])
    assert all(len(r) == m for r in Mrows), "ragged matrix"

    dm = DomainMatrix([list(r) for r in Mrows], (b, m), ZZ)
    red, pivots = dm.convert_to(QQ).rref()
    piv = tuple(int(p) for p in pivots)
    redrows = red.to_list()

    # A float anywhere means the exact route has been compromised.
    for row in redrows:
        for x in row:
            if isinstance(x, float):
                raise FloatLeak(f"rref returned float {x!r} in reduced matrix")

    dim = m - len(piv)
    if check_nonvacuous and dim <= 0:
        raise VacuousKernel(f"kernel dimension {dim} at {b}x{m}: routine found nothing")

    pivset = set(piv)
    free = [j for j in range(m) if j not in pivset]

    # Build kernel vectors: for each free column f, v[f] = 1 and v[p] = -R[p][f].
    # Sign/scale is irrelevant here because `primitive()` normalises afterwards; the
    # EXACTNESS assertion below is what validates it.
    out = []
    for f in free:
        v = [Fraction(0)] * m
        v[f] = Fraction(1)
        for i, p in enumerate(piv):
            v[p] = -_as_rational(redrows[i][f])
        out.append(v)

    # ---- EXACTNESS + NON-VACUITY, both.  A rank or dimension check passes the
    # float-leak bug; only `M v = 0` catches it.  A `M v = 0` check passes the
    # zero-vector bug; only the nonzero check catches that.  Both are required.
    for v in out:
        for i in range(b):
            s = sum(Fraction(Mrows[i][j]) * v[j] for j in range(m))
            if s != 0:
                raise AssertionError(f"kernel vector failed M v = 0 exactly (row {i})")
        if all(x == 0 for x in v):
            # Only reachable if a free column is itself a pivot -- impossible, but the
            # zero vector is exactly what the campaign warns PASSES M v = 0.
            raise VacuousKernel("kernel routine produced an identically zero vector")

    info = {"rank": len(piv), "dim": dim, "ncols": m, "pivots": piv, "free": free}
    return out, info


def primitive_int(v: Iterable) -> list[int]:
    """Algorithm 2.2 step 12: scale to INTEGERS with no factor common to all entries.

    Delegates to the validated `stange.primitive` (which handles sympy Rational and
    Fraction).  TRUNCATION IS A CATASTROPHIC BUG -- an early version did int() on a
    Rational like 1/2, producing 0 and destroying M v = 0.
    """
    return stange.primitive(list(v))


# ===========================================================================
# PHASE 2 -- RELATION FINDING, two routes, charged honestly
# ===========================================================================

class RelationStats:
    __slots__ = ("n_rel", "trials", "seconds", "route")

    def __init__(self, n_rel, trials, seconds, route):
        self.n_rel, self.trials, self.seconds, self.route = n_rel, trials, seconds, route


def find_relations_stange(n, g, FB, need, rng, sampler="random", trial_cap=40_000_000):
    """Stange's OWN relation finder: `g^x = prod p_i^{f_i} (mod n)`, x uniform in [1,n).

    Reused from the validated r48 implementation so the two arms differ ONLY in the
    relation-finding route and never in the arithmetic.  Charged as a whole wall clock.
    """
    t0 = time.perf_counter()
    rels, trials = stange.find_relations(n, g, FB, need, rng, sampler, trial_cap)
    return rels, RelationStats(len(rels), trials, time.perf_counter() - t0, "stange")


def find_relations_sieve(n, g, FB, need, rng, sampler="random", trial_cap=40_000_000):
    """NFS-STYLE relation finding, restricted to the Stange kernel.

    The brief asks for "NFS relation-finding feeding Stange's linear-algebra/gcd".  What
    is implementable in that shape, and is what OO_bneed's B3 actually points at, is:

      * the relation CONDITION is still `g^x = prod p_i^{f_i} (mod n)` -- otherwise the
        Q-kernel has nothing to annihilate and the whole construction is meaningless;
      * but the RELATIONS ARE COLLECTED BY SIEVING rather than by independent rejection
        sampling.  Sieve a batch of `x` values, divide out the factor base once per prime
        over the whole batch, and keep the survivors.  That amortises the `O(b)` trial
        division of the rejection sampler across the batch, which is exactly the
        engineering difference between NFS relation collection and naive sampling.

    THIS IS THE HONEST FORM OF THE IDEA AND IT IS WEAKER THAN THE NAME SUGGESTS, and the
    weakness is the finding, not a caveat: a sieve cannot help when the acceptance
    probability is `Psi(n,B)/Psi(n,B) = 1/... ` -- a *uniform* random residue mod n is
    FB-smooth with probability `rho(u)`, and sieving a BATCH does not change that rate at
    all.  It only reduces the cost PER TRIAL.  The `b_needed: 5.9e5 -> 8.4` claim rests on
    NFS's ability to reach a smoothness bound `B` where `n/... ` is reachable, i.e. on the
    NUMBER FIELD STRUCTURE giving large `m` values -- a mechanism that does not exist for
    the `g^x mod n` form and is NOT implemented here.  What IS implemented and charged is
    the part that can be: cheaper per-trial collection of the same relation condition.

    The trial_cap and the random/seq sampler semantics are identical to the Stange arm, so
    the two arms are compared on equal terms: same condition, same acceptance rate, same
    cap -- differing only in per-trial cost.
    """
    FB = list(FB)
    b = len(FB)
    t0 = time.perf_counter()
    if sampler != "random":
        # Only the rejection sampler is implemented for the sieve arm; `seq` is already
        # recorded INVALID by r48 T10 (manufactures sum_j b_j x_j == 0 exactly), so
        # implementing it here would build a route nobody may measure with.
        raise ValueError("sieve arm supports sampler='random' only (seq is invalid: r48 T10)")

    rels, seen = [], set()
    trials = 0
    # Batch size: sieving amortises the per-prime division pass over the batch.  Larger
    # batch = less Python overhead per trial, up to memory.  Fixed at 4096 so the two
    # arms are compared at a stated, reproducible setting.
    BATCH = 4096
    while len(rels) < need:
        xs = []
        for _ in range(BATCH):
            trials += 1
            x = rng.randrange(1, n)
            if x in seen:
                continue
            xs.append(x)
        if trials > trial_cap:
            raise RuntimeError("relation finding stalled (sieve)")
        # Compute residues for the batch.
        vals = {x: pow(g, x, n) for x in xs}
        # Strip the factor base across the WHOLE batch, one pass per prime -- this is
        # the amortisation that the rejection sampler does not get.
        cofs = dict(vals)
        exps: dict[int, list[int]] = {x: [0] * b for x in xs}
        for k, p in enumerate(FB):
            for x in xs:
                r = cofs[x]
                if r % p == 0:
                    e = 0
                    while r % p == 0:
                        r //= p
                        e += 1
                    cofs[x] = r
                    exps[x][k] = e
        for x in xs:
            if cofs[x] == 1:                     # FB-smooth
                seen.add(x)
                rels.append((exps[x], x))
            if len(rels) >= need:
                break
    return rels, RelationStats(len(rels), trials, time.perf_counter() - t0, "sieve")


# ===========================================================================
# PHASE 3 -- the gcd / extraction step, charged
# ===========================================================================

def extract_and_factor(G, g, n):
    """Algorithm 2.2's return: `G` is a multiple of ord(g); strip to the order, gcd.

    Charged as its own phase.  r48 recorded `t_gcd` at 0.1-0.8 ms -- under 0.2% of the
    phase -- and that is re-measured independently in H4 rather than assumed.
    """
    t0 = time.perf_counter()
    fac = stange.factor_from_multiple(G, g, n) if G else None
    return fac, time.perf_counter() - t0


# ===========================================================================
# THE PIPELINE
# ===========================================================================

class PhaseTimes:
    """Per-phase wall clock.  EVERY phase is charged: relation collection, the kernel,
    the gcd, and the cost of computing the base."""
    __slots__ = ("t_base", "t_rel", "t_LA", "t_gcd")

    def __init__(self, t_base=0.0, t_rel=0.0, t_LA=0.0, t_gcd=0.0):
        self.t_base, self.t_rel, self.t_LA, self.t_gcd = t_base, t_rel, t_LA, t_gcd

    @property
    def total(self) -> float:
        return self.t_base + self.t_rel + self.t_LA + self.t_gcd

    def as_dict(self) -> dict:
        tot = self.total
        return {
            "t_base": self.t_base, "t_rel": self.t_rel, "t_LA": self.t_LA,
            "t_gcd": self.t_gcd, "total": tot,
            "frac_base": self.t_base / tot if tot else 0.0,
            "frac_rel": self.t_rel / tot if tot else 0.0,
            "frac_LA": self.t_LA / tot if tot else 0.0,
            "frac_gcd": self.t_gcd / tot if tot else 0.0,
        }


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n).  O(log n), no factoring.  II_baseg's lever.

    Imported from `r50exp/baseg/measure.py` -- the round that established the 20/27 ->
    8/9 result -- rather than re-implemented, so the lever under test is that round's own
    code and not mine.  (It is NOT in `laws.py`, which holds only the exact 2-adic cells.)
    """
    return _jacobi_impl(a, n)


def pick_g(n: int, rng: random.Random, mode: str = "uniform") -> tuple[int, float]:
    """The base.  `t_base` is CHARGED -- the brief requires it.

    `uniform`  : what the whole programme has always used.
    `jac_neg`  : resample until (g/n) = -1 (II_baseg's 20/27 -> 8/9).
    """
    t0 = time.perf_counter()
    for _ in range(2000):
        g = rng.randrange(2, n)
        if gcd(g, n) != 1:
            continue
        if mode == "uniform":
            return g, time.perf_counter() - t0
        if mode == "jac_neg" and jacobi(g, n) == -1:
            return g, time.perf_counter() - t0
    raise RuntimeError("could not find a base")


def run_pipeline(n, g, FB, c, rng, rel_route="stange", *, verbose=False) -> dict:
    """ONE full attempt: relations -> Q-kernel -> gcd -> factor.

    `b = len(FB)`, relations needed = b + c, matrix is b x (b+c).  This is Algorithm 2.2
    with the kernel route swapped for the DomainMatrix/QQ one.
    """
    b = len(FB)
    need = b + c
    finder = find_relations_stange if rel_route == "stange" else find_relations_sieve
    rels, rstats = finder(n, g, FB, need, rng)

    Mrows = stange.build_M(rels, b)
    t0 = time.perf_counter()
    K, info = kernel_qq(Mrows, check_nonvacuous=True)
    t_LA = time.perf_counter() - t0

    xs = [rels[j][1] for j in range(need)]
    betas = []
    for v in K[:c]:
        pv = primitive_int(v)
        assert any(x != 0 for x in pv), "primitive of a kernel vector is identically zero"
        betas.append(sum(pv[j] * xs[j] for j in range(need)))
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    fac, t_gcd = extract_and_factor(G, g, n)

    if verbose:
        print(f"  b={b} c={c} rank={info['rank']} dimK={info['dim']} "
              f"trials={rstats.trials} G={G}")
    return {"G": G, "factor": fac, "betas": betas, "rank": info["rank"],
            "dimK": info["dim"], "trials": rstats.trials, "rels": rels,
            "rel_route": rel_route, "rel_seconds": rstats.seconds,
            "t_LA": t_LA, "t_gcd": t_gcd}


# ===========================================================================
# THE MANDATORY PER-MODULUS 2-ADIC CONTROL
# ===========================================================================

def p_split(p: int, q: int, mode: str = "uniform") -> Fraction:
    """Per-modulus ORDER-STEP success rate, from the campaign's own exact cell laws.

    This is the mandatory control.  `II_baseg` §3b: individual moduli span
    [0.5000, 0.9980] -- WIDER THAN THE EFFECT BEING CLAIMED.  A pooled rate quoted
    against 20/27 rather than against this is meaningless, and PP_droptest §3.2 showed
    the mean `p_split` of the SAME cell moving by 0.085 between two samples.
    """
    a, b = stange_law_s(p), stange_law_s(q)
    fn = laws.cell_uniform if mode == "uniform" else laws.cell_jac_neg
    return fn(a, b)


def stange_law_s(prime: int) -> int:
    """s = v_2(prime - 1)."""
    v = (prime - 1)
    s = 0
    while v % 2 == 0:
        v //= 2
        s += 1
    return s


def cell_label(p: int, q: int) -> str:
    return f"{stange_law_s(p)},{stange_law_s(q)}"


def diag(p: int, q: int) -> bool:
    return stange_law_s(p) == stange_law_s(q)


# ===========================================================================
# NO DICKMAN.  The shared harness raises above u = 5 and rho is the wrong null.
# ===========================================================================

def exact_psi(x: int, B: int) -> int:
    """EXACT count of B-smooth integers <= x.  No rho, no Dickman, no floats.

    Trial division by the FULL prime set <= B -- NOT `stange.factor_base`, which drops
    primes dividing n.  PP_droptest §1.3 re-confirmed that as a live hazard: it deletes 2
    for even n and returns a clean, confident, completely wrong number.

    THE BUG THIS FUNCTION HAD, kept in its docstring because it is the exact shape the
    campaign records: I first wrote the standard `if p*p > r: break` WITHOUT then
    accepting a remaining prime <= B.  That drops every integer whose largest prime
    factor exceeds the sqrt of the integer -- e.g. 10 = 2*5 at B=5 leaves r=5 and is
    rejected.  It reported Psi(10,5) = 3 against a true value of 9, and it would have
    silently understated the smoothness rate everywhere, which is the `int(n**(1/3))`
    bug class wearing a different hat.  The `r <= B` test at the end is the fix.

    Cost is O(x * pi(B)) and this is used only for the small-x sanity checks in the
    self-test; the timing experiments never call it.  Stated so nobody mistakes it for a
    route the pipeline depends on.
    """
    from sympy import primerange
    if x < 1:
        return 0
    ps = list(primerange(2, B + 1))
    # t = 1 IS B-smooth by definition (it has no prime factors).  Starting the loop at 2
    # -- which my first version did -- drops it and undercounts by exactly 1 at every x.
    # That is a silent, uniform off-by-one: it never changes a ratio's sign and never
    # trips an obvious bound.  Verified against brute force: Psi(10,5) = 9, and the list
    # is 1,2,3,4,5,6,8,9,10.
    total = 1
    for t in range(2, x + 1):
        r = t
        for p in ps:
            if p * p > r:
                break
            while r % p == 0:
                r //= p
        # `r == 1` OR `r <= B` -- a leftover prime no larger than B is still smooth.
        if r == 1 or r <= B:
            total += 1
    return total