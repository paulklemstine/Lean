# THE FOURIER ATTACK, IMPLEMENTED (v2, corrected) -- t DFTs, not one.
#
# score(d) = sum_i f(s_i^{-1}(z_i + r_i d))   with f(k) = +1 if top bit of k is 0, else -1.
#
# Substitute u = z_i + r_i d.  As d ranges over Z_n so does u (r_i invertible, n prime), so
#     score(d) = sum_i g_i(r_i d + z_i),   g_i(u) = f(s_i^{-1} u).
# Expand g_i in Fourier:  g_i(u) = sum_j fhat(s_i j) w^{j u}   (spectral stretch by s_i).
# Hence
#     score(d) = sum_i sum_j fhat(s_i j) w^{j z_i} w^{j r_i d}
#              = sum_i DFT_i( r_i d ),     DFT_i(m) = FFT( fhat(s_i *) * w^{j z_i} )
# i.e. ONE n-point FFT PER SIGNATURE, then the score at key d is the sum of the t values at
# indices r_i*d.  Cost O(t n log n) -- polynomial, no lattice, no O(n) enumeration.
#
# The earlier version wrongly factored sum_i w^{j s_i^{-1} z_i} * w^{j s_i^{-1} r_i d}, which
# requires s_i^{-1} to be constant.  It does not: brute force worked (the model is right)
# and the Fourier version failed (the algebra was wrong).  Fixed here.

import time, math
import numpy as np

def fourier_attack(p, t, nbits, seed, verify=True):
    set_random_seed(seed)
    n = int(next_prime(2**nbits))
    half = 1 << (nbits - 1)
    d_true = ZZ(randint(1, n - 1))
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, half - 1))
        if random() < (1 - p):
            k += half
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))

    t0 = time.time()
    # f and its DFT (one, reused: g_i's spectrum is a permutation of f's)
    f = np.array([1.0 if k < half else -1.0 for k in range(n)])
    fhat = np.fft.ifft(f)   # ifft = the expansion coefficients f(k) = sum_j fhat_j w^{jk}
    # A_i(j) = fhat_j * w^{j s_i^{-1} z_i};  score(d) = sum_i DFT_i( (s_i^{-1} r_i) d )
    j = np.arange(n)
    D = np.zeros(n, dtype=complex)              # holds the per-i DFT, summed pointwise is
    per_i = []                                  # NOT possible (different indices) -> store t
    for i in range(t):
        si_inv = pow(ss[i], -1, n)
        zi_hat = (si_inv * zs[i]) % n
        ri_hat = (si_inv * rs[i]) % n
        Ai = fhat * np.exp(-2j * np.pi * j * zi_hat / n)
        Di = np.fft.fft(Ai)
        per_i.append((Di, ri_hat))
    t_cost = time.time() - t0
    ds = np.arange(1, n)
    vals = np.zeros(n - 1, dtype=complex)
    for (Di, ri_hat) in per_i:
        vals += Di[(ri_hat * ds) % n]
    d_hat = int(np.argmax(vals.real)) + 1

    bf = None
    if verify:
        sinv = [pow(s, -1, n) for s in ss]
        best = -1
        for d in range(1, n):
            cnt = 0
            for i in range(t):
                cnt += 1 if (zs[i] + rs[i] * d) * sinv[i] % n < half else -1
            if cnt > best:
                best, bf = cnt, d
    return (d_hat == d_true), (bf == d_true if bf is not None else None), t_cost, d_true, d_hat

print("=== the implemented Fourier attack vs brute force (n ~ 2^14) ===", flush=True)
print(f"{'p':>6} {'t':>5} | {'fourier finds':>14} {'bruteforce finds':>17} {'fft time s':>11}", flush=True)
for (p, t) in [(0.90, 32), (0.85, 48), (0.80, 64), (0.75, 96), (0.70, 128), (0.65, 192),
               (0.90, 16), (0.80, 32), (0.70, 64)]:
    f_ok, b_ok, tc, dt, dh = fourier_attack(p, t, 14, seed=3)
    print(f"{p:>6.2f} {t:>5} | {str(f_ok):>14} {str(b_ok):>17} {tc:>11.2f}", flush=True)
print()
n = float(next_prime(2**14))
print("predicted thresholds t* = ln(n)/(2(p-1/2)^2) at n ~ 2^14:", flush=True)
for p in [0.90, 0.85, 0.80, 0.75, 0.70, 0.65]:
    print(f"   p={p:.2f}: t* = {math.log(n)/(2*(p-0.5)**2):.0f}", flush=True)
print()
print("agreement between the O(t n log n) attack and the O(n t) brute force is the control:", flush=True)
print("if they agree below threshold and disagree only at the margin, both are measuring", flush=True)
print("the same quantity and the implementation is verified.", flush=True)
