"""
Instance generation with DELIBERATE STRUCTURAL ASYMMETRY.

The programme's recorded failure mode: an algorithm that "factors N via
structure" but is really Pollard rho in disguise.  So every instance here
comes with a STRUCTURAL TAG, and the tags are built to be adversarial to
the class-group route specifically:

  tag 'smooth-both'   p-1 and q-1 both y-smooth   -> p-1 method trivial
  tag 'smooth-one'    p-1 y-smooth, q-1 has a big factor
  tag 'rough-both'    neither p-1 nor q-1 is y-smooth -> p-1 method useless
  tag 'classgroup-hi' p,q chosen so h(-4N) is LARGE  (L(1,chi_D) large)
  tag 'classgroup-lo' p,q chosen so h(-4N) is SMALL  (L(1,chi_D) small)

The decisive control (see run.py): a class-group method must track
h(D) / the class-group structure.  A rho-in-disguise tracks sqrt(p).

SEED at top of file, RUN TWICE, compare.  Reported below.
"""

import random
import sympy
from sympy import primerange
from cypari2 import Pari

P = Pari()
SEED = 20251004
random.seed(SEED)


def _prime_in(bits):
    return int(sympy.nextprime(random.randrange(1 << (bits - 1), 1 << bits)))


def y_smooth(x, y):
    """y-smoothness by trial division (small y only).  _YFAC is cached --
    the un-cached version called sympy.primefactors(y) on every draw and
    dominated the runtime."""
    m = x
    for pr in _yfac(y):
        while m % pr == 0:
            m //= pr
    return m == 1


_YF = {}


def _yfac(y):
    """
    Primes <= y.  (sympy.primefactors(y) is the prime factors OF y, not
    the primes below it -- using it made p-1 smooth-prime generation
    impossible, since only [2,5] was ever available.)
    """
    if y not in _YF:
        _YF[y] = list(sympy.primerange(2, y + 1))
    return _YF[y]


def _smooth_prime(bits, y):
    """
    Construct a prime p with p-1 y-smooth.  p = m+1 where m is a product
    of primes <= y, so p-1 = m is smooth BY CONSTRUCTION; we only need
    p itself to be prime.  Random p-1 is ~0.05% smooth (measured), so
    plain rejection sampling does not terminate; building it does.
    """
    small = list(sympy.primerange(2, y + 1))
    # SMALL[i] ~ 2^(i/BINS); grow by ONE bin step at a time so the product
    # lands in the target bit window.  (Multiplying by a random small prime
    # overshoots wildly -- a 2^13 factor jumps 13 bits -- and trying to
    # step back with m //= small diverges, because that can strip factors
    # without bound.)
    BINS = 48
    SMALL = []
    for i in range(BINS + 1):
        lo, hi = 2 ** (i * 4.0 / BINS), 2 ** ((i + 1) * 4.0 / BINS)
        cand = [q for q in small if lo <= q < hi]
        if cand:
            SMALL.append((lo, cand))
    tries = 0
    while tries < 200000:
        tries += 1
        m = 1
        k = 0
        while m.bit_length() < bits - 1 and k < 400:
            # choose the bin whose primes are big enough to matter now
            opts = [c for (lo, c) in SMALL if m.bit_length() + 1 < bits]
            if not opts:
                break
            m *= random.choice(random.choice(opts))
            k += 1
        p = m + 1
        if p.bit_length() == bits and sympy.isprime(p):
            return int(p)
    raise RuntimeError(f"no smooth prime at bits={bits} y={y}")


def _rough_prime(bits, y):
    """A prime p whose p-1 has a prime factor > y (so p-1 method fails)."""
    while True:
        p = _prime_in(bits)
        if not y_smooth(p - 1, y):
            return p


def gen_smooth_both(bits=17, y=10000):
    p = _smooth_prime(bits, y)
    q = _smooth_prime(bits, y)
    while q == p:
        q = _smooth_prime(bits, y)
    return p, q, 'smooth-both'


def gen_smooth_one(bits=17, y=10000):
    """p-1 y-smooth (Pollard p-1 trivial); q-1 deliberately NOT y-smooth."""
    p = _smooth_prime(bits, y)
    q = _rough_prime(bits, y)
    while q == p:
        q = _rough_prime(bits, y)
    return p, q, 'smooth-one'


def gen_rough_both(bits=17, y=10000):
    p = _rough_prime(bits, y)
    q = _rough_prime(bits, y)
    while q == p:
        q = _rough_prime(bits, y)
    return p, q, 'rough-both'


def class_number(D):
    return int(P.qfbclassno(D))


def disc_of(N):
    """Fundamental discriminant of Q(sqrt(-N))."""
    return -4 * N if N % 4 == 1 else -N


def gen_classgroup_extreme(bits=19, want='hi', tries=4000):
    """
    p,q such that h is unusually LARGE (hi) or SMALL (lo) among
    same-bit-size balanced instances.  Uses PARI qfbclassno, which is
    validated 18/18 against brute force in validate_pari.py.
    """
    vals = []
    best = None
    for _ in range(tries):
        p, q = _prime_in(bits), _prime_in(bits)
        if p == q or (p + q) % 4:
            continue
        N = p * q
        h = class_number(-4 * N)
        vals.append(h)
        if want == 'hi' and (best is None or h > best[1]):
            best = (p, q, N, h)
        if want == 'lo' and (best is None or h < best[1]):
            best = (p, q, N, h)
    import statistics
    return best, statistics.median(vals), (min(vals), max(vals))


if __name__ == '__main__':
    print("SEED =", SEED)
    print("-- tag sample (bits=19) --")
    for g in (gen_smooth_both, gen_smooth_one, gen_rough_both):
        p, q, t = g()
        print(f"  {t:12s} p={p} q={q} N={p*q} "
              f"({(p*q).bit_length()}b) h(-4N)={class_number(-4*p*q)}")
    for want in ('hi', 'lo'):
        best, med, rng = gen_classgroup_extreme(19, want)
        p, q, N, h = best
        print(f"  classgroup-{want}: p={p} q={q} N={N} h={h} "
              f"(median over {4000} tries={med}, range={rng})")
