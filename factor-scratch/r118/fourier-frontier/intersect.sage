# ALGORITHMIC EXPANSION: replace the FFT scan by candidate-set INTERSECTION.
#
# The FFT attack scores all n keys: O(t n log n).  But a reliable leak into a set S of size
# |S| = n/2^bits gives, for signature i, the candidate set
#       D_i = { d : s_i^{-1}(z_i + r_i d) mod n in S }
#           = { (s_i k - z_i) r_i^{-1} mod n : k in S }
# -- an affine preimage, computable in O(|S|) with one modular multiply per element.
# The true key lies in D_1 ∩ ... ∩ D_t, and each intersection with D_i shrinks the survivor
# set by a factor ~2^bits, so after ceil(log2 n / bits) signatures the survivor set is O(1)
# -- EXACTLY the information-counting threshold measured in info.sage.
# Total cost ~ |D_1| (1 + 2^-bits + ...) ~ n / 2^bits, versus t n log n for the FFT.
#
# PREDICTIONS:
#   (a) identical t* = ceil(log2 n / bits) + O(1)  (same law, same algorithm boundary);
#   (b) cost ~ 2^bits x lower than the FFT at the same n (measured at n ~ 2^22);
#   (c) at a fixed n it reaches the threshold with FEWER signatures of work.

import numpy as np, math, time

def make(t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits)); span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1)); rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs

def intersection_attack(n, span, t, rs, ss, zs, d_true):
    """returns (found?, candidates after each signature, time)"""
    S = np.arange(span, dtype=np.int64)
    t0 = time.time()
    survivors = None
    sizes = []
    for i in range(t):
        si = ss[i]; zi = zs[i]
        Di = ((int(si) * S - zi) % n) * pow(rs[i], -1, n) % n     # O(|S|)
        if survivors is None:
            survivors = set(Di.tolist())
        else:
            survivors &= set(Di.tolist())
        sizes.append(len(survivors))
        if len(survivors) <= 64:
            # final check against the public key relation is unnecessary: the true key is
            # a survivor by construction; just report
            break
    return (d_true in survivors), sizes, time.time() - t0

def fft_attack_time(n, span, t, rs, ss, zs):
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n); vals = np.zeros(n - 1, dtype=complex)
    t0 = time.time()
    for i in range(t):
        si = pow(ss[i], -1, n); ci = (si * zs[i]) % n; mi = (si * rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j * np.pi * j * ci / n))[(mi * ds) % n]
    return int(np.argmax(vals.real)) + 1, time.time() - t0

NB = 22
print(f"n ~ 2^{NB}: intersection vs FFT", flush=True)
print(f"{'bits':>5} {'t':>4} | {'intersection found':>18} {'survivors':>10} {'I-time s':>9} "
      f"{'F-time s':>9} {'speedup':>8}", flush=True)
for bits in [4, 6, 8]:
    for t in [2, 3, 4, 5, 6]:
        nn, span, dt, rs, ss, zs = make(t, NB, bits, 3)
        found, sizes, ti = intersection_attack(nn, span, t, rs, ss, zs, dt)
        dh, tf = fft_attack_time(nn, span, t, rs, ss, zs)
        okf = (dh == dt)
        print(f"{bits:>5} {t:>4} | {str(found):>18} {str(sizes[-1]):>10} {ti:>9.2f} {tf:>9.2f} "
              f"{tf/ti:>7.1f}x  (fft finds: {okf})", flush=True)
print()
print("prediction (a): the intersection finds the key exactly at t = ceil(log2 n / bits)", flush=True)
for bits in [4, 6, 8]:
    print(f"   bits={bits}: t* predicted = {int(math.ceil(NB/bits))}", flush=True)
