"""
jcore.py -- core primitives for the Jacobi-symbol Cayley-graph (degree) attack.

Everything here is factored-free by construction: the Jacobi symbol is computed
by quadratic reciprocity, which never needs the factorization of the modulus.

Design rule obeyed throughout: every routine here can return the NULL answer.
There is no function that is hard-wired to succeed.
"""
from __future__ import annotations
import math
from fractions import Fraction

# ---------------------------------------------------------------- Jacobi


def jacobi_free(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for ODD positive n, by quadratic reciprocity.

    FACTORIZATION-FREE: uses only division, mod, and parity. No factorization
    of n (or of any intermediate) is ever performed or required.
    Returns -1, 0, or +1.

    n MUST be odd. For even n the Jacobi symbol is NOT a character of
    Z/nZ -- it depends on a mod 8, not on a mod n -- so the connection set
    S = {x mod n : (x/n)=+1} and hence Cay(Z/nZ,S) are undefined. We refuse
    rather than silently extending (see ST2.3).
    """
    assert n > 0 and n % 2 == 1, "n must be positive and odd"
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0
    r = 1
    while a:
        # strip 2s: (2/n) = (-1)^((n^2-1)/8)
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                r = -r
        # reciprocity: (a/n) = (n mod a / a) * (-1)^((a-1)(n-1)/4)
        if (a % 4) == 3 and (n % 4) == 3:
            r = -r
        a, n = n % a, a
    return r if n == 1 else 0


def _factor_small(n: int) -> list[tuple[int, int]]:
    """Trial-division factorization of n. Cached: this is a TEST ORACLE only,
    never used by the attack path."""
    global _FACT_CACHE
    if n in _FACT_CACHE:
        return _FACT_CACHE[n]
    out, m, d = [], n, 2
    while d * d <= m:
        if m % d == 0:
            e = 0
            while m % d == 0:
                m //= d
                e += 1
            out.append((d, e))
        d += 1 if d == 2 else 2
    if m > 1:
        out.append((m, 1))
    _FACT_CACHE[n] = out
    return out


_FACT_CACHE: dict[int, list[tuple[int, int]]] = {}


def jacobi_brute(a: int, n: int) -> int:
    """Independent brute-force Jacobi symbol: (a/n) = prod_{p^e || n} (a/p)^e,
    via trial division of n and Euler's criterion. Deliberately uses a
    completely different algorithm from jacobi_free (which uses reciprocity),
    so that agreement is a real cross-check. TEST ORACLE ONLY."""
    if n == 1:
        return 1
    res = 1
    for p, e in _factor_small(n):
        res *= legendre(a % p, p) ** e
    return res


def kronecker_2(a: int) -> int:
    """(a/2) in the standard convention: +1 if a = +-1 mod 8, -1 if a = +-3 mod 8."""
    return -1 if (a % 8) in (3, 5) else 1


def legendre(a: int, p: int) -> int:
    """Legendre symbol via Euler's criterion (independent of jacobi_free)."""
    if a % p == 0:
        return 0
    return 1 if pow(a % p, (p - 1) // 2, p) == 1 else -1


def deg_brute_all_residues(n: int) -> int:
    """deg = |S| = #{ x in Z/nZ : (x/n) = +1 }  -- counted over ALL residues,
    including x = 0 and every non-coprime residue. No residue is excluded."""
    return sum(1 for x in range(n) if jacobi_free(x, n) == 1)


def deg_brute_all_residues_legendre(n: int, fac: tuple[int, ...]) -> int:
    """Same count, computed by an independent route: Legendre symbols on the
    factors. Used as a control on jacobi_free."""
    return sum(
        1 for x in range(n)
        if jacobi_brute(x, n) == 1
    )


def deg_from_factorization(n: int, p: int, q: int) -> int:
    """deg under the hypothesis n = p*q: predicted (p-1)(q-1)/2."""
    assert p * q == n
    return (p - 1) * (q - 1) // 2


# ------------------------------------------------------- graph / spectrum


def degree_is_zero_mode(n: int) -> tuple[int, list]:
    """Build the circulant adjacency matrix of Cay(Z/nZ, S) with
    S = {x : (x/n)=+1} and return (deg, sorted eigenvalues).

    Uses an FFT-free explicit DFT (n is small in tests) so the eigenvalues are
    computed by an INDEPENDENT route from the adjacency matrix, giving a
    cross-check that deg really is the k=0 Fourier coefficient.
    """
    import numpy as np
    c = np.array([1 if jacobi_free(x, n) == 1 else 0 for x in range(n)], dtype=float)
    deg = int(c.sum())
    F = np.fft.fft(c)
    ev = np.sort(np.real(F))[::-1]
    return deg, list(ev)


# ------------------------------------------------ precision-bound recovery


def recover_factors_from_s(n: int, s_est):
    """Given n and an ESTIMATE s of p+q (int or float), try to recover (p, q).

    Returns (p, q) on exact success, or None. This is the honest recovery
    step: it rounds the two real roots to the nearest integers and CHECKS
    p*q == n. It is NOT hard-wired to succeed.

    Accepts a real-valued s_est, because the estimate deg~ is real-valued.
    """
    if s_est <= 0:
        return None
    D = float(s_est) ** 2 - 4 * n
    if D < 0:
        return None
    r = math.sqrt(D)
    # the two roots of X^2 - s X + n
    for q_f, p_f in (((s_est + r) / 2.0, (s_est - r) / 2.0),
                     ((s_est - r) / 2.0, (s_est + r) / 2.0)):
        q, p = round(q_f), round(p_f)
        if p < 2 or q < 2:
            continue
        if p * q == n:
            return (min(p, q), max(p, q))
    return None


def kronecker_even(a: int, n: int) -> int:
    """Kronecker symbol for EVEN n: n = 2^k*m (m odd), (a/n) = (2/m)^k * (a/m),
    with (2/m) = (-1)^((m^2-1)/8).

    NOTE: the STANDARD Jacobi symbol is defined only for odd n. This is an
    explicitly stated extension, needed only because even RSA moduli
    (n = 2q) are a real deployment target.

    Well-defined on Z/nZ ONLY when n = 2m with m odd (n = 2 mod 4): the factor
    (a/2) depends on a mod 8, which is not determined by a mod 4 or a mod 2^k.
    We therefore REFUSE n divisible by 4 rather than invent a value."""
    if n <= 0:
        return 0
    if n % 2 == 1:
        return jacobi_free(a, n)
    assert n % 4 == 2, "Kronecker extension is only well-defined for n = 2 mod 4"
    m = n // 2
    if math.gcd(a, n) > 1:
        return 0
    base = -1 if (m % 8) in (3, 5) else 1
    return base * jacobi_free(a, m)


def deg_kronecker_all_residues(n: int) -> int:
    """deg = |S| counted over ALL residues, using the Kronecker extension when
    n is even. For odd n this is identical to deg_brute_all_residues."""
    f = jacobi_free if n % 2 == 1 else kronecker_even
    return sum(1 for x in range(n) if f(x, n) == 1)


def bound_task(p: int, q: int) -> float:
    """The bound quoted in the task brief: eps < (p-q)^2 / 8."""
    return (p - q) ** 2 / 8


def bound_true(p: int, q: int, n: int) -> float:
    """The bound derived by differentiating sqrt(s^2-4n) at s = p+q:
        |delta_s| * (s / sqrt(s^2-4n)) < 1   <=>   |delta_s| < (p-q)/(p+q).
    With delta_s = 2*eps:
        eps < |p-q| / (2*(p+q)).
    """
    return abs(p - q) / (2.0 * (p + q))


# ---------------------------------------------------------------- Fermat


def fermat_steps(n: int, p: int, q: int) -> int:
    """Number of a-increments Fermat's difference-of-squares needs:
    start at a = ceil(sqrt(n)), succeed at a = (p+q)/2."""
    a = math.isqrt(n)
    if a * a < n:
        a += 1
    return (p + q) // 2 - a


# ------------------------------------------------------------- sampling


def sample_deg_mean(n: int, k: int, seed: int = 0) -> float:
    """Monte-Carlo estimate of deg by drawing k uniform residues x mod n and
    averaging the indicator [(x/n) = +1]. Returns n * (successes/k).

    NOTE this uses a GENERATOR-ORACLE for the population only in the sense
    that it samples x; each (x/n) is a factorization-free Jacobi symbol."""
    import random
    rng = random.Random(seed)
    hits = 0
    for _ in range(k):
        if jacobi_free(rng.randrange(n), n) == 1:
            hits += 1
    return n * hits / k


def sampling_steps(n: int, eps: float, rho: float = 0.5) -> float:
    """k such that the standard deviation of n * (sample mean) equals eps.
    Var(I) = rho(1-rho), std of deg-hat = n sqrt(rho(1-rho)/k)."""
    var = rho * (1.0 - rho)
    if eps <= 0:
        return float("inf")
    return (n * math.sqrt(var) / eps) ** 2


# ------------------------------------------------------------- utilities


def is_prime(n: int) -> bool:
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


def random_prime_pair(bits: int, rng) -> tuple[int, int]:
    while True:
        p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(p):
            return p


def close_prime_pair(bits: int, rng, max_off: int) -> tuple[int, int]:
    """Two primes of the same bit-length whose gap is < max_off."""
    while True:
        p = random_prime_pair(bits, rng)
        for off in range(0, max_off, 2):
            c = p + off
            if is_prime(c):
                return p, c


def closest_pair(bits: int, rng, tries: int = 4000) -> tuple[int, int]:
    """Scan a window of primes around 2^(bits-1) and return the closest pair."""
    import random as _r
    lo = 1 << (bits - 1)
    win = set()
    st = _r.Random(0)
    st.seed(rng.randrange(1 << 30))
    base = lo + st.randrange(1 << 12) * 2
    for x in range(base, base + 6 * tries, 2):
        if is_prime(x):
            win.add(x)
    win = sorted(win)
    best = None
    for i in range(len(win) - 1):
        if best is None or win[i + 1] - win[i] < best[1] - best[0]:
            best = (win[i], win[i + 1])
    return best