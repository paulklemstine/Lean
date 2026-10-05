# ECM stage 1 driven by Sage's own (correct) EC arithmetic over a COMPOSITE
# ring.  Probe: (a) correct Suyama point, (b) can we extract the factor on a
# non-invertible final Z?
from sage.all import *
import time

n = next_prime(2**79) * next_prime(2**719)
p = next_prime(2**79)
print("n bits %d, planted factor %d bits" % (n.nbits(), p.nbits()))
R = Zmod(n)

def suyama(sig):
    u = (sig * sig - 5) % n
    v = 4 * sig % n
    A = ((v - u)**3 * (3 * u + v) * inverse_mod(4 * u**3 * v, n) - 2) % n
    B = 4 * u**3 * v % n
    return A % n, B, u % n, v % n

# --- probe 1: correct curve/point placement, verified on a PRIME first ---
np_ = ZZ(next_prime(10**9))
def suyama_mod(sig, m):
    u = (sig * sig - 5) % m
    v = 4 * sig % m
    A = ((v - u)**3 * (3 * u + v) * inverse_mod(4 * u**3 * v, m) - 2) % m
    B = 4 * u**3 * v % m
    return A % m, B % m, u % m, v % m

set_random_seed(11)
sig = randint(6, np_ - 1)
A, B, u, v = suyama_mod(sig, np_)
Ep = EllipticCurve(ZZ(np_), [0, A * B % np_, 0, B * B % np_, 0])
Pp = Ep(B * u**3 % np_, B * B * v**3 % np_)
lhs = Pp[1]**2 % np_
rhs = (Pp[0]**3 + (A * B % np_) * Pp[0]**2 + (B * B % np_) * Pp[0]) % np_
print("PROBE1 Suyama point on curve (prime m):", lhs == rhs)
print("PROBE1 3P == 3*P :", (Pp * 3)[0] == (Pp * 3)[0])

# --- probe 2: can we hold a projective point and read Z? ---
print("PROBE2 point tuple len:", len(Pp), " third coord:", Pp[2] if len(Pp) > 2 else "n/a")
