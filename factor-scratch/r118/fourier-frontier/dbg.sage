# DEBUG: compare the Fourier score against the DIRECT score at the true key, for both DFT
# sign conventions.  Whichever convention reproduces the direct score is the correct one.

import numpy as np

set_random_seed(3)
p, t, nbits = 0.90, 32, 14
n = int(next_prime(2**nbits)); half = 1 << (nbits - 1)
d_true = ZZ(randint(1, n - 1))
rs, ss, zs = [], [], []
for _ in range(t):
    k = ZZ(randint(0, half - 1))
    if random() < (1 - p):
        k += half
    r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
    s = (z + r * d_true) * inverse_mod(k, n) % n
    rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
sinv = [pow(s, -1, n) for s in ss]

# direct score at every d
def direct(d):
    tot = 0
    for i in range(t):
        tot += 1 if (zs[i] + rs[i] * d) * sinv[i] % n < half else -1
    return tot
print("direct score at d_true:", direct(int(d_true)), flush=True)
print("direct score at a random wrong d:", direct((int(d_true) + 12345) % n), flush=True)
print("(expect ~ t(2p-1) =", t * (2 * p - 1), "at the true key, ~0 elsewhere)", flush=True)

f = np.array([1.0 if k < half else -1.0 for k in range(n)])
j = np.arange(n)
for label, fhat, sign in [("ifft coeffs, minus phase", np.fft.ifft(f), -1.0),
                          ("fft  coeffs, plus  phase", np.fft.fft(f), +1.0)]:
    vals = np.zeros(n - 1, dtype=complex)
    for i in range(t):
        si_inv = sinv[i]
        ci = (si_inv * zs[i]) % n
        mi = (si_inv * rs[i]) % n
        Ai = fhat * np.exp(sign * 2j * np.pi * j * ci / n)
        Di = np.fft.fft(Ai)
        vals += Di[(mi * np.arange(1, n)) % n]
    dh = int(np.argmax(vals.real)) + 1
    at_true = vals[int(d_true) - 1].real
    print(f"  {label:>26}: score at d_true = {at_true:12.3f}   argmax = {dh}  "
          f"{'MATCHES' if dh == int(d_true) else 'wrong'}", flush=True)
