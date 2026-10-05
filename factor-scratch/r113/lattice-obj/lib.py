# r113/lattice-obj harness. PLAIN PYTHON (no Sage preparser): all arithmetic is
# native int, and we borrow Sage's gmp-backed Integer for the heavy loops.
# Why plain .py: the Sage preparser rebinds int() -> Integer, which silently
# breaks random.Random(seed) and cost 3 debug cycles.
import sys, time
from random import Random as PyRandom
from sage.all import Integer, next_prime, gcd as ZZgcd, factor as pari_factor

def _prime_with_bits(rng, bits):
    """A prime with EXACTLY `bits` bits."""
    lo = 1 << (bits-1); hi = 1 << bits; span = hi - lo
    while True:
        c = lo + rng.randrange(span)
        p = int(next_prime(Integer(c)))
        if lo <= p < hi: return p

def gen_N(bits, seed, bits2=None):
    """Seeded semiprime; p has `bits` bits, q has `bits2`. Returns (N,p,q)."""
    if bits2 is None: bits2 = bits
    rng = PyRandom(seed*1000003 + bits*101 + bits2*7)
    p = _prime_with_bits(rng, bits)
    q = _prime_with_bits(rng, bits2)
    while q == p: q = _prime_with_bits(rng, bits2)
    return p*q, p, q

def rho(n, seed=12345):
    """Brent rho, gmp-backed via Sage Integer. Returns (g, iters)."""
    N = Integer(n)
    if N % 2 == 0: return 2, 0
    c = Integer(1); y = Integer(seed) % N
    r = 1; q = 1; g = 1; x = 0; ys = 0; iters = 0
    while g == 1:
        x = y
        for _ in range(r): y = (y*y + c) % N
        k = 0
        while k < r and g == 1:
            ys = y
            for _ in range(min(128, r-k)):
                y = (y*y+c) % N
                q = q*abs(x-y) % N
            iters += 128
            g = ZZgcd(q, N); k += 128
        r *= 2
    if g == N:
        while True:
            ys = (ys*ys+c) % N
            g = ZZgcd(abs(x-ys), N)
            if g > 1: break
    return int(g), iters

def ok(g, p, q, N):
    """Ground truth by MULTIPLICATION BACK. Never trust a library."""
    return (g == p or g == q) and (g*(N//g) == N)

def pari_time(N):
    """Trivial baseline: PARI factor(). Returns (seconds, first_factor)."""
    t = time.time(); f = pari_factor(N); return time.time()-t, int(f[0][0])
