# EXPANDING THE FOURIER ATTACK -- the threshold is not governed by the bias ADVANTAGE.
#
# Hypothesis tested in expand.sage: t* = 2 ln n / A^2 with A = E_biased[f] - E_uniform[f].
# FALSIFIED: for block indicators with span = n/2^bits (bits >= 2) the attack is up to 7x
# CHEAPER than that predicts (measured/predicted ratios 0.14 ... 0.39), while for the
# half-space (bits=1) it is 1.25-1.86x more expensive.  So the SHAPE of the bias matters,
# not just its mean advantage.
#
# Refined hypothesis: the threshold is governed by the DOMINANT FOURIER COEFFICIENT of the
# bias function, not by its mean.  For a block indicator f = +1 on [0,span), -1 outside,
#     |fhat_j| = 2|sin(pi j span/n)| / (pi j),  so |fhat_1| ~ 2 span/n for span << n.
# For span = n/2 that is 2/pi = 0.636, and the measured threshold for a deterministic
# half-space bias corresponds to an effective coefficient of about 1 -- i.e. the relevant
# object is max_j |fhat_j| scaled by the probability mass on the biased event.
#
# This experiment: gather t* for a (bits, p) matrix, and correlate the measured threshold
# against the candidate predictors, to find which one collapses the data.

import numpy as np, math

def make(p, t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits))
    span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1))
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))
        if random() < (1 - p):
            k = ZZ(randint(0, n - 1))
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs

def fourier_argmax(n, span, t, rs, ss, zs):
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n)
    vals = np.zeros(n - 1, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n)
        ci = (si * zs[i]) % n; mi = (si * rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j * np.pi * j * ci / n))[(mi * ds) % n]
    return int(np.argmax(vals.real)) + 1

NB = 18
n_ref = float(next_prime(2**NB))
ln_n = math.log(n_ref)
print(f"n ~ 2^{NB}, ln n = {ln_n:.2f}", flush=True)
print(f"{'bits':>4} {'p':>5} {'A':>6} {'|fhat_1|':>9} {'pred(2ln n/A^2)':>17} | {'t*':>5} "
      f"{'t*A^2':>8} {'t*|fhat_1|^2':>13}", flush=True)
rows = []
for bits in [1, 2, 3, 4]:
    for p in [0.85, 0.70]:
        span_frac = 2.0**-bits
        A = 2*p - 1 + (1 - p) * 2.0**(1 - bits)
        fhat1 = 2 * abs(math.sin(math.pi * span_frac)) / math.pi
        pred = 2 * ln_n / (A * A)
        found = None
        for t in [8, 16, 24, 32, 48, 64, 96, 128, 192, 256, 384]:
            w = 0
            for sd in (3, 4):
                nn, span, dt, rs, ss, zs = make(p, t, NB, bits, sd)
                w += (fourier_argmax(nn, span, t, rs, ss, zs) == dt)
            if w >= 2:
                found = t
                break
        rows.append((bits, p, A, fhat1, pred, found))
        if found:
            print(f"{bits:>4} {p:>5.2f} {A:>6.3f} {fhat1:>9.4f} {pred:>17.0f} | {found:>5} "
                  f"{found*A*A:>8.1f} {found*fhat1*fhat1:>13.1f}", flush=True)
        else:
            print(f"{bits:>4} {p:>5.2f} {A:>6.3f} {fhat1:>9.4f} {pred:>17.0f} |  >256", flush=True)
print()
print("collapsing predictor: the one whose product with t* is (near-)CONSTANT across rows", flush=True)
