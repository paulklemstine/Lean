# EXPANDING THE FOURIER ATTACK: a general threshold law, tested at larger n and with
# multi-bit biases.
#
# Round 18 measured and implemented the binary (top-bit) bias, with
#       t* = ln(n) / (2 (p - 1/2)^2),      A = p - 1/2  (the bias advantage)
# leaving two open caveats: the law was fitted at n <= 2^14, and only ONE bias function was
# ever used.
#
# HYPOTHESIS (general): for any bias function f applied to a nonce quantity,
#       t* = ln(n) / (2 A^2),     A = E_biased[f] - E_uniform[f]
# i.e. the threshold depends on the bias only through its ADVANTAGE, not its shape.
#
# FALSIFIER: a bias with the same advantage but a different shape that needs a very
# different number of signatures.  In particular the shape should not matter at all.
#
# TEST MATRIX: n = 2^18 (log n = 12.4, so t* roughly doubles from the 2^14 measurement --
# a direct check on the extrapolation caveat), with
#   (a) top-bit bias, p = 0.70, 0.85      -> A = p - 1/2
#   (b) top-2-bit bias, p = 0.70, 0.85    -> A = p - 1/4
#   (c) top-3-bit bias, p = 0.85          -> A = p - 1/8
# Prediction from the law: t*(a) = ln n/(2*0.20^2) = 155, t*(b,0.85) = ln n/(2*0.60^2) = 17,
# t*(c) = ln n/(2*0.725^2) = 12.  The multi-bit biases should be dramatically cheaper.

import numpy as np, math, time

def make_instance(p, t, nbits, bits, seed):
    """nonces whose top `bits` bits are all zero with probability p, else uniform."""
    set_random_seed(seed)
    n = int(next_prime(2**nbits))
    span = 1 << (nbits - bits)          # size of the biased block
    d_true = ZZ(randint(1, n - 1))
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))    # top `bits` bits zero
        if random() < (1 - p):
            k = ZZ(randint(0, n - 1))    # fully uniform instead
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return int(n), span, d_true, rs, ss, zs

def fourier(n, span, t, rs, ss, zs):
    """score(d) = sum_i f(s_i^-1(z_i + r_i d)),  f(k) = +1 if k < span else -1."""
    j = np.arange(n)
    f = np.where(np.arange(n) < span, 1.0, -1.0)
    fhat = np.fft.ifft(f)
    ds = np.arange(1, n)
    vals = np.zeros(n - 1, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n)
        ci = (si * zs[i]) % n
        mi = (si * rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j * np.pi * j * ci / n))[(mi * ds) % n]
    return vals

def brute(n, span, t, rs, ss, zs):
    sinv = [pow(s, -1, n) for s in ss]
    ds = np.arange(1, n)
    tot = np.zeros(n - 1)
    for i in range(t):
        k = ((zs[i] + rs[i] * ds) * sinv[i]) % n
        tot += np.where(k < span, 1.0, -1.0)
    return tot

NB = 18
n_float = float(next_prime(2**NB))
ln_n = math.log(n_float)
print(f"n ~ 2^{NB} (ln n = {ln_n:.2f});  law: t* = ln n / (2 A^2)", flush=True)
print(f"{'bias':>26} {'p':>5} {'A':>6} {'pred t*':>8} | {'measured t*':>11} {'wins':>14} {'fft s':>7}", flush=True)
for bits, punif, label in [(1, 0.5, "top bit"), (2, 0.25, "top 2 bits"), (3, 0.125, "top 3 bits")]:
    for p in [0.70, 0.85]:
        A = p - punif
        pred = ln_n / (2 * A * A)
        ts = [8, 16, 32, 64, 96, 128, 192, 256, 384, 512, 768]
        found = None; wins = ""
        for t in ts:
            w = 0
            for seed in (3, 4):
                nn, span, dt, rs, ss, zs = make_instance(p, t, NB, bits, seed)
                v = fourier(nn, span, t, rs, ss, zs)
                w += (int(np.argmax(v.real)) + 1 == int(dt))
            wins += f"{w}"
            if w >= 3 and found is None:
                found = t
                break
        print(f"{label:>26} {p:>5.2f} {A:>6.3f} {pred:>8.0f} | {str(found):>11} {wins:>14}", flush=True)
print()
print("(wins string is per-t wins out of 2 seeds, scanned upward; first t with 2/2 is t*)", flush=True)
print("the law is confirmed if measured t* / predicted t* is roughly constant across biases", flush=True)
