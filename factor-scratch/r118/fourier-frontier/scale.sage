# SCALE-UP: test the two frontier laws at larger n, closing the extrapolation caveat.
#
# Both laws are measured at n ~ 2^18 and quoted at 2^256 by extrapolation.  The predictions
# at n = 2^20 (ln n = 13.9) and n = 2^24 (ln n = 16.6) are sharp:
#
#   reliable leak (p=1):  t* = ceil(log2 n / bits)
#        n=2^20: bits=4 -> 5,  bits=6 -> 4,  bits=8 -> 3
#        n=2^24: bits=4 -> 6,  bits=6 -> 4,  bits=8 -> 3
#   noisy leak, advantage A:  t* = 2 ln n / A^2,  A = p(2 - 2^{1-bits})
#        bits=1, p=0.85 (A=0.85):  n=2^20 -> 38,  n=2^24 -> 46
#
# FALSIFIER: if t* does not shift with log2 n as predicted, the laws are local to 2^18 and
# the 2^256 figures are unsupported.
#
# CONTROL at this n (a brute-force argmax over n keys is infeasible): verify that the
# Fourier score AT THE TRUE KEY equals the DIRECT score at the true key -- an O(t) check
# that validates the implementation at this scale, and that the argmax lands on d_true.

import numpy as np, math, time

def make(t, nbits, bits, p, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits)); span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1)); rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))
        if random() < (1 - p):
            k = ZZ(randint(0, n - 1))
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs

def score_vector(n, span, t, rs, ss, zs):
    """the full score vector by t FFTs -- O(t n log n)"""
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n)
    vals = np.zeros(n - 1, dtype=complex)
    acc = np.zeros(n, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n); ci = (si * zs[i]) % n; mi = (si * rs[i]) % n
        Di = np.fft.fft(fhat * np.exp(-2j * np.pi * j * ci / n))
        vals += Di[(mi * ds) % n]
        acc += Di
    return vals, acc

def direct_at(n, span, t, rs, ss, zs, d):
    sinv = [pow(s, -1, n) for s in ss]
    tot = 0
    for i in range(t):
        tot += 1 if (zs[i] + rs[i] * d) * sinv[i] % n < span else -1
    return tot

for NB in [20, 24]:
    ln_n = math.log(float(next_prime(2**NB)))
    print(f"=== n ~ 2^{NB} (ln n = {ln_n:.2f}) ===", flush=True)
    # --- REGIME 1: reliable leak, p = 1
    print(f"{'regime':>10} {'bits':>5} {'p':>5} {'A':>6} {'pred t*':>8} | {'control ok':>10} "
          f"{'measured t*':>12} {'fft time':>9}", flush=True)
    for bits in [4, 6, 8]:
        pred = int(math.ceil(NB / bits))
        found = None; ctrl = ""
        for t in range(1, pred + 6):
            nn, span, dt, rs, ss, zs = make(t, NB, bits, 1.0, 3)
            t0 = time.time()
            vals, acc = score_vector(nn, span, t, rs, ss, zs)
            el = time.time() - t0
            # control: Fourier score at d_true must equal the direct score at d_true
            ok_ctrl = abs(vals[dt - 1].real - direct_at(nn, span, t, rs, ss, zs, dt)) < 1e-6
            ctrl = "yes" if ok_ctrl else "NO"
            if int(np.argmax(vals.real)) + 1 == dt:
                found = t
                print(f"{'reliable':>10} {bits:>5} {1.0:>5.2f} {'--':>6} {pred:>8} | {ctrl:>10} "
                      f"{found:>12} {el:>8.1f}s", flush=True)
                break
        if found is None:
            print(f"{'reliable':>10} {bits:>5} {1.0:>5.2f} {'--':>6} {pred:>8} | {ctrl:>10} "
                  f"{'>' + str(pred + 5):>12}", flush=True)
    # --- REGIME 2: noisy leak
    for bits, p in [(1, 0.85), (2, 0.90)]:
        A = p * (2 - 2.0**(1 - bits))
        pred = 2 * ln_n / (A * A)
        found = None
        for t in [8, 16, 24, 32, 48, 64, 96]:
            nn, span, dt, rs, ss, zs = make(t, NB, bits, p, 3)
            vals, acc = score_vector(nn, span, t, rs, ss, zs)
            if int(np.argmax(vals.real)) + 1 == dt:
                found = t
                break
        print(f"{'noisy':>10} {bits:>5} {p:>5.2f} {A:>6.3f} {pred:>8.0f} | {'--':>10} "
              f"{str(found):>12}", flush=True)
    print(flush=True)
