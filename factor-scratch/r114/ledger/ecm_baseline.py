"""Strongest honest generic baseline at the campaign's FRONTIER instance (n=800).

Uses PARI factorint(), whose OWN doc says it includes first-stage ECM
("2: avoid first-stage ECM") -> strongest generic baseline PARI offers.
PARI factor(N,1) is NOT usable: ?factor says arg2 is a DOMAIN D
("using primes < D"), so factor(N,1) = primes<1 = no trial division, returns N.
Ground truth: factor set must equal the true {p,q}.
"""
import time
from cypari2 import Pari
import random, sympy

p = Pari()
alpha, nbits = 0.10, 800
qb = int(round(nbits*alpha)); pb = nbits - qb
print("target n=%d bits, |q|=%d bits, |p|=%d bits" % (nbits, qb, pb), flush=True)

def make(seed):
    rng = random.Random(seed)
    while True:
        Q = sympy.nextprime(rng.randrange(2**(qb-1), 2**qb))
        Pp = sympy.nextprime(rng.randrange(2**(pb-1), 2**pb))
        N2 = Q*Pp
        if N2.bit_length() == nbits:
            return Q, Pp, N2

t_all = time.time()
for seed in (31337, 424242, 987001, 5150):
    Q, Pp, N2 = make(seed)
    t0 = time.time(); f = p.factorint(N2); dt = time.time()-t0
    got = sorted(int(f[i][0]) for i in range(len(f)))
    ok = sorted([Q, Pp]) == got
    print("seed=%-7d |q|=%3d bits  factorint(N2)=%8.2f s  solved=%s  ground-truth-exact=%s"
          % (seed, Q.bit_length(), dt, got != [N2], ok), flush=True)
print("total %.1f s" % (time.time()-t_all), flush=True)
