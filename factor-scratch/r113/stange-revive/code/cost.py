"""
r113/stange-revive -- COST MODEL for Stange Algorithm 2.2, built from the
paper's OWN runtime formula (Stange arXiv:2211.06821v2, Section 4, p.5-6).

Paper, verbatim (p.5-6):

  "The relation finding phase is exactly as for the index calculus itself.
   If we use the standard notation uu for the number of trials to find one
   smooth integer, where u = log n/ log b, then the runtime is
   uu (b + c)bpi(b) = uu O(b3 / log b) with trial division.  Thus, balancing
   the runtimes we obtain a heuristic runtime of Ln(1/2, beta)"

  Reading of "uu (b+c) b pi(b)":  u^u * (b+c) * b * pi(b), where pi(b) is the
  number of primes < b, i.e. the trial-division cost of ONE smoothness test.
  Check: (b+c) ~ 2b, times b, times pi(b) ~ b/log b  =  2 b^3 / log b.  That is
  exactly the "uu O(b3/log b)" the paper prints on the same line, so this
  reading is forced by the paper's own next token.  (Not a guess: the two
  expressions have to agree.)

  Notation overload in the paper: b is used BOTH for the factor-base SIZE
  (#primes) and, in "u = log n / log b", for the SMOOTHNESS BOUND B.  We keep
  them distinct: b = #primes in the base, B = the bound, B = p_b.
  u = log n / log B.

The LINEAR ALGEBRA + GCD phase is paper Theorem 3.2 (p.5), verbatim:

  "the runtime is O(b4 log b) poly(log n)"

and the abstract (p.1) states the bottom line, verbatim:

  "The algorithm is certainly slower than the best known factoring
   algorithms"

Baselines modelled:
  rho (Pollard, Brent):   N^(1/4)  group operations   [heuristic]
  ECM:                    exp(sqrt(2 ln p ln ln p))  for a factor p  [heuristic]
  NFS/GNFS:               L_n(1/3, (64/9)^(1/3))
"""
from __future__ import annotations

import math

# --------------------------------------------------------------------------
# Dickman rho, by numerical integration of u rho'(u) = -rho(u-1), rho=1 on
# [0,1].  Selftested against the standard table in cost_selftest.py.
# --------------------------------------------------------------------------
_D_RHO: dict[float, float] = {}


def _rho_table(umax: float = 2000.0, du: float = 1e-4):
    """
    Dickman rho as y(u) = log rho(u), by RK4 on

        y'(u) = -(1/u) * exp( y(u-1) - y(u) )          [from u rho' = -rho(u-1)]

    Marching in LOG space is unconditionally stable: y stays O(-u log u) and
    the RHS is a ratio of exponentials, so there is no `1 - cum` cancellation.
    Two earlier schemes were discarded because they fail EXACTLY where this
    axis needs them, and both failures were in the direction that would have
    made Stange look cheap:
      * RK4 on rho directly in the variable u -> rho(6) underflowed to 0;
      * the log-space Volterra march in log-u -> rho stuck at ~2e-15 past
        u ~ 11 (and clamping at rho(10) then destroyed the cost model's
        dependence on u entirely, making b=3 look optimal everywhere).

    Grid is uniform in u; y(u-1) is linearly interpolated.  Returns
    (us, ys, du).
    """
    n = int(umax / du) + 2
    us = [i * du for i in range(n)]
    Y = [0.0] * n                # Y[i] = y(u_i); y(1) = log 1 = 0
    inv = 1.0 / du

    def yat(uu):
        if uu <= 1.0:
            return 0.0
        if uu >= umax:
            return Y[n - 1]
        f = uu * inv
        i = int(f)
        if i >= n - 1:
            i = n - 2
        t = f - i
        return Y[i] * (1.0 - t) + Y[i + 1] * t

    def slope(uu, yhere):
        if uu <= 1.0:
            return 0.0
        return -math.exp(yat(uu - 1.0) - yhere) / uu

    for i in range(1, n):
        u = us[i]
        y0 = Y[i - 1]
        k1 = slope(u, y0)
        k2 = slope(u + 0.5 * du, y0 + 0.5 * du * k1)
        k3 = slope(u + 0.5 * du, y0 + 0.5 * du * k2)
        k4 = slope(u + du, y0 + du * k3)
        Y[i] = y0 + (du / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
    return us, Y, du


_TAB: list = [None]


def log_rho(u: float) -> float:
    """log of the Dickman rho(u)."""
    if u <= 1:
        return 0.0
    if _TAB[0] is None:
        _TAB[0] = _rho_table(2000.0, 1e-4)
    us, Y, du = _TAB[0]
    if u >= us[-1]:
        return _rho_debruijn_log(u)
    i = int(u / du)
    if i >= len(Y) - 1:
        i = len(Y) - 2
    t = (u - us[i]) / du
    return Y[i] * (1.0 - t) + Y[i + 1] * t


def _rho_debruijn_log(u: float) -> float:
    """log of the Hildebrand/de Bruijn asymptotic; used only past u = 2000."""
    lu = math.log(u)
    llu = math.log(lu)
    return -u * (lu + llu - 1.0 + (llu - 1.0) / lu
                 - (llu * llu - 2 * llu - 1.0) / (2 * lu * lu)
                 + (llu ** 3 - 6 * llu ** 2 + 11 * llu - 6.0) / (6 * lu ** 3))


def rho(u: float) -> float:
    """Dickman rho(u)."""
    if u <= 1:
        return 1.0
    return math.exp(log_rho(u))


def _rho_debruijn(u: float) -> float:
    """
    de Bruijn asymptotic for rho(u), used only for u > 60 where rho is
    astronomically small anyway:
        log rho(u) ~ -u (log u + log log u - 1 + (log log u - 1)/log u)
    Selftested for continuity against the grid at u = 60.
    """
    lu = math.log(u)
    llu = math.log(lu)
    return math.exp(-u * (lu + llu - 1.0 + (llu - 1.0) / lu))


def log_trial_div_cost(u: float) -> float:
    """log of the paper's u^u = number of trials to find one B-smooth integer.
    For u >= 1, rho(u) ~ exp(-u(log u + log log u - 1)), which is the standard
    estimate; for small u we use the exact grid.  Returns log(1/rho(u)).
    """
    if u <= 1.0:
        return 0.0
    return -math.log(rho(u))


# --------------------------------------------------------------------------
# factor base sizing
# --------------------------------------------------------------------------
_pi_cache: dict[int, int] = {}


def primepi(x: int) -> int:
    import sympy
    if x not in _pi_cache:
        _pi_cache[x] = int(sympy.primepi(x))
    return _pi_cache[x]


def nth_prime(k: int) -> int:
    import sympy
    return int(sympy.prime(k))


# --------------------------------------------------------------------------
# Stange's cost in "trial divisions" (the paper's unit: cost per smoothness
# test is pi(b) trial divisions + O(log n) multiplications)
# --------------------------------------------------------------------------
def stange_cost(nbits: int, b: int, c: int = 10,
                include_linalg: bool = True) -> dict:
    """
    Cost of Algorithm 2.2 at modulus size `nbits` bits with a factor base of
    `b` primes, in natural log of TRIAL DIVISIONS (the paper's unit).
    """
    B = nth_prime(b)              # smoothness bound
    ln_n = nbits * math.log(2.0)
    u = ln_n / math.log(B)
    # relation finding (paper p.5): u^u (b+c) b pi(b)
    ln_relfind = log_trial_div_cost(u) + math.log(b + c) + math.log(b) \
        + math.log(primepi(B))
    # linear algebra + gcd (paper Thm 3.2): O(b^4 log b) poly(log n)
    ln_linalg = 0.0
    if include_linalg:
        ln_linalg = 4.0 * math.log(b) + math.log(max(b, 2)) \
            + 4.0 * math.log(ln_n)
    return {
        "nbits": nbits, "b": b, "c": c, "B": B, "u": u,
        "log_relfind": ln_relfind,
        "log_linalg": ln_linalg,
        "log_cost": ln_relfind + ln_linalg,
    }


def stange_best(nbits: int, c: int = 10, bmax: int = 20000) -> dict:
    """Minimise the paper's cost over the factor-base size b."""
    best = None
    b = 2
    while b <= bmax:
        r = stange_cost(nbits, b, c)
        if best is None or r["log_cost"] < best["log_cost"]:
            best = r
        # walk up faster than 1 at a time
        b = int(b * 1.03) + 1
    return best


# --------------------------------------------------------------------------
# baselines
# --------------------------------------------------------------------------
def log_rho_baseline(nbits: int) -> float:
    """log of N^(1/4) group operations."""
    return 0.25 * nbits * math.log(2.0)


def log_ecm_baseline(nbits: int) -> float:
    """log of exp(sqrt(2 ln p ln ln p)) for p the smaller factor (~N/2 bits)."""
    lp = (nbits / 2.0) * math.log(2.0)
    return math.sqrt(2.0 * lp * math.log(lp))


def log_nfs_baseline(nbits: int) -> float:
    """log of L_N(1/3, (64/9)^(1/3)) -- the GNFS asymptotic."""
    c = (64.0 / 9.0) ** (1.0 / 3.0)
    L = nbits * math.log(2.0)
    return c * (L ** (1.0 / 3.0)) * (math.log(L) ** (2.0 / 3.0))