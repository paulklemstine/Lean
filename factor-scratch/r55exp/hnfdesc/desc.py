"""
Derivation (not recall): enumerating reduced forms of disc D = -4N.

For D = -4N, reduction forces b even (b = 2y). Then
    b^2 - D = 4ac   <=>   4y^2 + 4N = 4ac   <=>   y^2 + N = a*c.
So: reduced forms of disc -4N are in bijection with pairs (a, y) such that
    a | (y^2 + N),   a > 0,   c = (y^2+N)/a,
    and  -a < 2y <= a <= c,   with 2y >= 0 if a == c.

This turns "find reduced forms" into "for each a, solve y^2 = -N (mod a)"
-- a per-a modular square root, done by CRT over prime powers.  That is
O(a_max * polylog), not O(|D|).

No part of this depends on a remembered algorithm; every step is checked
against two independent oracles:
  * brute_forms()   (O(|D|) exhaustive)   -- small D
  * PARI qfbclassno  (validated 18/18 above) -- counts at any size
"""

from math import gcd, isqrt
from functools import lru_cache


def _tonelli(n, p):
    """sqrt(n) mod odd prime p, or None. n must be a QR mod p."""
    n %= p
    if n == 0:
        return 0
    if p == 2:
        return n
    if pow(n, (p - 1) // 2, p) != 1:
        return None
    if p % 4 == 3:
        return pow(n, (p + 1) // 4, p)
    # p % 4 == 1
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(n, q, p), pow(n, (q + 1) // 2, p)
    while True:
        if t == 1:
            return r
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2 * t2 % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c = i, b * b % p
        t = t * c % p
        r = r * b % p


def _roots_mod_pp(n, ell, e):
    """Roots of x^2 = n (mod ell^e), e >= 1, ell prime. Returns list."""
    if e == 1:
        r = _tonelli(n, ell)
        if r is None:
            return []
        if r == 0:
            return [0]
        return sorted({r % ell, (-r) % ell})
    pe = ell ** e
    r1 = _tonelli(n, ell)
    if r1 is None:
        return []
    # Hensel: lift to ell^e.  Roots are 2 unless ell | 2r1, i.e. ell=2 or n=0 mod ell^2.
    if ell == 2:
        return _roots_mod_2e(n, e)
    if n % (ell * ell) == 0:
        # double roots; handle by brute lift (rare, small e)
        out = []
        base = r1
        for x in range(pe):
            if x % ell == base % ell and (x * x - n) % pe == 0:
                out.append(x)
        return out
    # distinct root mod ell: lift uniquely to each e, and there are 2 roots mod ell
    out = []
    for b0 in ({r1, (-r1) % ell}):
        x = b0
        for k in range(1, e):
            mod = ell ** (k + 1)
            # solve x + t*ell^k : f(x) + 2x*t*ell^k = 0 mod ell^{k+1}
            f = (x * x - n) % mod
            t = (-(f // (ell ** k)) * pow(2 * x, -1, ell)) % ell
            x = x + t * ell ** k
        out.append(x % pe)
    return out


def _roots_mod_2e(n, e):
    """
    Roots of x^2 = n (mod 2^e).  Correct by construction: brute-force the
    roots at a small exponent, then LIFT one level at a time, testing each
    candidate explicitly.  (My first attempt did the lift analytically and
    silently dropped 2 of the 4 roots; brute-force seeding + verified lift
    is the version I trust.)
    """
    if e <= 0:
        return [0]
    n %= (1 << e)
    # seed at exponent k0 = min(e, 10)
    k0 = min(e, 10)
    m0 = 1 << k0
    roots = [x for x in range(m0) if (x * x - n) % m0 == 0]
    if not roots:
        return []
    for k in range(k0, e):
        mk = 1 << k
        mk2 = 1 << (k + 1)
        nxt = []
        for r in roots:
            for cand in (r, r + mk):
                if (cand * cand - n) % mk2 == 0:
                    nxt.append(cand)
        roots = sorted(set(nxt))
        if not roots:
            return []
    pe = 1 << e
    return sorted({r % pe for r in roots})


def _crt2(r1, m1, r2, m2):
    g = gcd(m1, m2)
    if (r2 - r1) % g:
        return None
    lcm = m1 // g * m2
    a, b = m1 // g, m2 // g
    t = ((r2 - r1) // g * pow(a, -1, b)) % b if b > 1 else 0
    return ((r1 + m1 * t) % lcm, lcm)


def spf_table(n):
    """Smallest prime factor sieve up to n."""
    spf = list(range(n + 1))
    spf[0] = 0
    if n >= 1:
        spf[1] = 1
    i = 2
    while i * i <= n:
        if spf[i] == i:
            for j in range(i * i, n + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


class Descender:
    """
    Enumerates reduced forms of disc D = -4N in increasing leading
    coefficient.  Stops as soon as a form is found whose leading
    coefficient divides D (and is not 1 or 4) -- that form reveals a factor.
    """

    def __init__(self, N, a_max=None):
        self.N = N
        self.D = -4 * N
        self.a_max = a_max if a_max is not None else isqrt(4 * N // 3) + 2
        self._spf = None

    def _factor(self, a):
        # self._spf may be a plain list (spf_table) or a SegSPF
        if isinstance(self._spf, SegSPF):
            return self._spf.factor(a)
        f = {}
        while a > 1:
            p = self._spf[a]
            e = 0
            while a % p == 0:
                a //= p
                e += 1
            f[p] = e
        return f

    def roots(self, a):
        if self._spf is None:
            self._spf = spf_table(max(self.a_max, a + 1000))
        f = self._factor(a)
        res = [0]
        m = 1
        for ell, e in sorted(f.items()):
            rr = _roots_mod_pp((-self.N) % (ell ** e), ell, e)
            if not rr:
                return []
            me = ell ** e
            new = []
            for r0 in res:
                for r1 in rr:
                    t = _crt2(r0, m, r1, me)
                    if t is None:
                        continue
                    new.append(t[0])
                    m_new = m * me // gcd(m, me)
            m = m * me // gcd(m, me)
            res = new
        return sorted(set(x % a for x in res)) if a > 1 else [0]

    def forms_upto(self, a_cap, stop_on_factor=True, trivial=(1, 4)):
        """
        Yield (index, a, b, c) for every reduced form with a <= a_cap.
        If stop_on_factor, return early on the first a | D, a not in trivial.
        Returns (hits, total_visited, hit_list).
        """
        self.a_max = max(self.a_max, a_cap + 16)
        self._spf = spf_table(self.a_max)
        m = abs(self.D)
        idx = 0
        hits = []
        for a in range(1, a_cap + 1):
            if a == 1:
                b = 0
                c = self.N
                yield_list = [(0, 1, 0, c)]
            else:
                yield_list = []
                for y in self.roots(a):
                    # y is determined mod a; the reduction window -a < b <= a
                    # needs BOTH integer representatives y and y-a.
                    for yy in (y, y - a):
                        b = 2 * yy
                        if not (-a < b <= a):
                            continue
                        t = yy * yy + self.N
                        if t % a:
                            continue
                        c = t // a
                        if a > c:
                            continue
                        if a == c and b < 0:
                            continue
                        # PRIMITIVITY: only primitive forms are classes of
                        # the order of disc D.  Without this the walk also
                        # emits IMPRIMITIVE forms and overcounts h(D) --
                        # measured exactly 2x on D=-4pq (validated against
                        # qfbclassno, 4/4 exact once primitive is imposed).
                        if gcd(gcd(a, b), c) != 1:
                            continue
                        yield_list.append((b, a, b, c))
            for (b, aa, bb, cc) in sorted(yield_list, key=lambda z: z[0]):
                idx += 1
                if aa > 1 and aa not in trivial and m % aa == 0:
                    hits.append((idx, aa, bb, cc))
                    if stop_on_factor:
                        return hits, idx, True
        return hits, idx, False


class SegSPF:
    """
    Segmented smallest-prime-factor sieve.  The plain spf_table() is a
    Python list of size a_max and blows memory once a_max ~ 10^7 (which
    an unbounded a_cap reaches).  This streams in blocks.
    """

    def __init__(self, n, block=None):
        self.n = n
        self.block = block or 1 << 20
        self._base = spf_table(min(self.block + 1024, n + 1024))
        self._cache = {}

    def _block_of(self, a):
        lo = (a // self.block) * self.block
        hi = min(lo + self.block, self.n + 1)
        arr = self._cache.get(lo)
        if arr is None:
            arr = self._cur = [0] * (hi - lo)
            for i in range(lo, hi):
                x = i
                r = 0
                while x > 1:
                    d = self._base[x] if x < len(self._base) else x
                    if r == 0 or d < r:
                        r = d
                    while x % d == 0:
                        x //= d
                arr[i - lo] = r if r else i
            if len(self._cache) > 4:
                self._cache.clear()      # keep memory flat
            self._cache[lo] = arr
        return lo, arr

    def spf(self, a):
        if a < 2:
            return a
        lo, arr = self._block_of(a)
        return arr[a - lo]

    def factor(self, a):
        f = {}
        while a > 1:
            p = self.spf(a)
            e = 0
            while a % p == 0:
                a //= p
                e += 1
            f[p] = e
        return f
