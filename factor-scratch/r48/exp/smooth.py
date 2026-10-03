"""
r48 / AXIS-B : THE ONE smoothness + Dickman module.

EVERY family in this experiment (EC baseline included) calls is_B_smooth
defined HERE.  There is no second implementation used for comparison.
Two independent cross-checks live in selftest.py; if either disagrees with
this function on a shared set, the whole axis is void (see EARNED RULES).

Numerical policy (earned rule: test the TIGHTEST case):
  * B = floor(n**(1/u)) is NEVER computed with a float.  Floats understate
    floor(n**(1/3)) at every perfect cube (memory: float-cuberoot-floor-trap).
    Here B is produced by exact integer nth-root.
  * The perfect-power boundary cases are the tightest: n = B**k exactly,
    n = B**k * spf(B+1), n = (B+1)**2.  selftest.py enumerates them.
"""
from __future__ import annotations

import math
from functools import lru_cache

# ---------------------------------------------------------------- exact roots


def iroot(n: int, k: int) -> int:
    """EXACT floor(n ** (1/k)) for n >= 0, k >= 1.  No floating point."""
    if n < 0:
        raise ValueError("iroot of negative")
    if n == 0:
        return 0
    if k == 1:
        return n
    if k == 2:
        return math.isqrt(n)
    # exact via Newton on integers, with integer-only iteration
    x = 1 << ((n.bit_length() + k - 1) // k)
    while True:
        y = ((k - 1) * x + n // x ** (k - 1)) // k
        if y >= x:
            break
        x = y
    # x is now floor(n^(1/k)) or one too big; walk down/up to certify
    while x ** k > n:
        x -= 1
    while (x + 1) ** k <= n:
        x += 1
    return x


def B_for_u(n: int, u: float) -> int:
    """ECM stage-1 smoothness bound: largest B with B**u <= n, exactly."""
    # u is given as a ratio of logs; convert to an exact integer exponent when
    # it is the canonical ECM value 2, else use a scaled integer root.
    if u == 2:
        return iroot(n, 2)
    # general u = ln n / ln B  ->  B = floor(n ** (1/u))
    return iroot(n, max(1, int(round(1.0 / u))))


# ---------------------------------------------------------------- smoothness

_PARI = None


def _pari():
    global _PARI
    if _PARI is None:
        from cypari2 import Pari
        _PARI = Pari()
        # MUST be allocatemem, NOT default(parisize,...): the latter is a
        # no-op after PARI is initialised and we overflow at 8 MB (observed).
        try:
            _PARI.allocatemem(1536 * 1024 * 1024)
        except Exception:
            pass
    return _PARI


def factorint_pari(n: int) -> dict:
    """Prime factorisation via PARI.  Exact.

    NOTE: PARI's ``factor`` returns a 2-COLUMN MATRIX.  Iterating a cypari2
    Gen over a matrix yields the COLUMNS, so ``list(M)`` is
    ([p_1..p_k], [e_1..e_k]) and a naive ``for p, e in M`` mis-pairs them.
    """
    M = _pari()(f"factor(%d)" % n)
    cols = [[int(v) for v in c] for c in list(M)]
    if not cols:
        return {}
    return dict(zip(cols[0], cols[1]))


def is_B_smooth(n: int, B: int) -> bool:
    """n is B-smooth  <=>  every prime factor of n is <= B.

    THIS IS THE SINGLE SHARED DEFINITION USED BY EVERY FAMILY.
    Proof-by-construction of the guarantee: selftest.py runs it on a shared
    set together with two independent implementations (sympy factorint, and a
    pure trial-division oracle) and asserts all three agree.
    """
    if n < 2:
        return True
    if B < 2:
        return False
    if B >= n:
        return True
    for p in factorint_pari(n):
        if p > B:
            return False
    return True


def largest_prime_factor(n: int) -> int:
    if n < 2:
        return 0
    return max(factorint_pari(n))


# ---------------------------------------------------------------- Dickman rho


_RHO_GRID = None
_RHO_H = 1e-5      # grid step; the delay ODE is scale-equivariant, so the
_RHO_MAX = 25.0    # RELATIVE error is validated by SELF-CONVERGENCE (T2b),
                   # never against a table recalled from memory.


def _build_rho_grid(h=_RHO_H, umax=_RHO_MAX):
    """Tabulate rho on [0, umax] with step h by integrating the delay ODE
        u rho'(u) = -rho(u-1),   rho(u) = 1 for 0 <= u <= 1.

    rho(u_i) uses the linear interpolation of rho at u_i - h/2 - 1, which
    lands exactly halfway between grid nodes i-O-1 and i-O with
    O = round(1/h).  Every dependency is therefore in an EARLIER block of
    size O, so the whole thing vectorises block by block.
    """
    import numpy as np
    O = int(round(1.0 / h))
    n = int(umax / h) + 2
    g = np.empty(n + 2)
    g[: O + 1] = 1.0                      # rho = 1 on [0,1]
    for start in range(O + 1, n + 1, O):
        stop = min(start + O, n + 1)
        idx = np.arange(start, stop)
        # rho(u_mid - 1) = 0.5*g[i-O-1] + 0.5*g[i-O]   (exact node placement)
        lag = 0.5 * (g[idx - O - 1] + g[idx - O])
        umid = (idx - 0.5) * h
        step = h * lag / umid              # rho(u_i) = rho(u_{i-1}) - step
        # running subtraction is a cumulative sum
        g[start:stop] = g[start - 1] - np.cumsum(step)
    return g


_RHO_GRID = None


def _install(h, umax):
    global _RHO_GRID, _RHO_H, _RHO_MAX
    _RHO_GRID = _build_rho_grid(h, umax)
    _RHO_H, _RHO_MAX = h, umax
    return _RHO_GRID


def rho(u: float) -> float:
    """Dickman function.

    rho(u) = 1 for 0 <= u <= 1;  u rho'(u) = -rho(u-1) for u > 1.
    Equivalently rho(u) = 1 - int_1^u rho(t-1)/t dt.
    The two closed forms rho(1)=1 and rho(2)=1-ln2 are EXACT and are checked
    in selftest T2; beyond them accuracy is certified by halving h until the
    value stops moving (selftest T2b), not by trusting a recalled table.
    """
    if u <= 1.0:
        return 1.0
    if u <= 0.0:
        return 0.0
    g = _RHO_GRID if _RHO_GRID is not None else _install(_RHO_H, _RHO_MAX)
    h = _RHO_H
    if u >= len(g) * h:
        return float(g[-1])
    i = int(u / h)
    f = u / h - i
    val = float(g[i] * (1 - f) + g[i + 1] * f)
    return 0.0 if val < 0.0 else val


def _simpson(f, a, b, depth=0):
    fa, fb = f(a), f(b)
    m = 0.5 * (a + b)
    fm = f(m)
    s = (b - a) / 6.0 * (fa + 4.0 * fm + fb)
    if depth < 18:
        s2 = _simpson(f, a, m, depth + 1) + _simpson(f, m, b, depth + 1)
        if abs(s2 - s) < 1e-16 * max(1.0, abs(s2)):
            return s2
        return s2
    return s


RHO2 = 1.0 - math.log(2.0)  # 0.30685281944005...