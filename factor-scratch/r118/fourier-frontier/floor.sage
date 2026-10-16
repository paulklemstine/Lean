# THE ABSOLUTE FLOOR: as the biased block narrows (bits -> inf) with a perfect leak (p=1),
# A_max -> 2, so t* -> 2 ln n / 4 = ln n / 2.  Nothing can beat this: not a stronger leak,
# not a narrower bias.  Prediction at n ~ 2^18: floor = ln n / 2 = 6.24, i.e. t* = 6-7.
import numpy as np, math
def make(t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits)); span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1)); rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))               # p = 1: ALWAYS biased
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs
def argmax_f(n, span, t, rs, ss, zs):
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n); vals = np.zeros(n - 1, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n); ci = (si*zs[i]) % n; mi = (si*rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j*np.pi*j*ci/n))[(mi*ds) % n]
    return int(np.argmax(vals.real)) + 1
NB = 18; ln_n = math.log(float(next_prime(2**NB)))
print(f"n ~ 2^{NB}, ln n / 2 = {ln_n/2:.2f}  <-- the predicted absolute floor", flush=True)
print(f"{'bits':>5} {'span':>10} {'A_max':>7} {'pred t*':>8} | {'first all-win':>13} {'first majority':>15}", flush=True)
for bits in [4, 6, 8, 11]:
    Amax = 2 - 2.0**(1-bits)
    pred = 2*ln_n/(Amax*Amax)
    curve = []
    for t in range(1, 15):
        w = 0
        for sd in [3,4,5,6]:
            nn, span, dt, rs, ss, zs = make(t, NB, bits, sd)
            w += (argmax_f(nn, span, t, rs, ss, zs) == dt)
        curve.append(w)
    full = next((i+1 for i,w in enumerate(curve) if w == 4), None)
    maj  = next((i+1 for i,w in enumerate(curve) if w >= 3), None)
    print(f"{bits:>5} {1<<(NB-bits):>10} {Amax:>7.4f} {pred:>8.2f} | {str(full):>13} {str(maj):>15}   "
          f"{''.join(str(w) for w in curve)}", flush=True)
