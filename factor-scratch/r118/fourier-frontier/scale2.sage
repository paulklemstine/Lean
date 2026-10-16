# SCALE MILESTONE: the intersection attack at a 40-bit modulus.
#
# The intersection variant costs n / 2^b elements (|S| = n / 2^b), so a reliable leak of b
# bits makes a (b + 2^b)-bit modulus feasible in principle.  Test at |S| = 2^24, which is
# ~10^7 elements -- comfortably handled -- at
#       n ~ 2^40, b = 16   (predicted t* = ceil(40/16) + 1 = 4)
#       n ~ 2^44, b = 20   (predicted t* = ceil(44/20) + 1 = 4)
#       n ~ 2^48, b = 24   (predicted t* = ceil(48/24) + 1 = 3)
# This is a 2^22-times larger modulus than the first implementation test, and it exercises
# the exact same law with no new machinery.

import numpy as np, math, time

def make(t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits))
    block = ((1 << bits) - 1) << (nbits - bits)
    d_true = ZZ(randint(1, n - 1)); rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, ((1 << (nbits - bits)) - 1)))     # top b bits reliably zero
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, 1 << (nbits - bits), int(d_true), rs, ss, zs

def survivors(n, span, t, rs, ss, zs):
    # S = {k : k < span} (top b bits zero).  dtype=object gives exact Python-int
    # arithmetic -- int64 would overflow on s*S for n > 2^32.
    S = np.arange(span, dtype=object)
    out = []; cur = None
    for i in range(t):
        Di = ((int(ss[i]) * S - zs[i]) % n) * pow(rs[i], -1, n) % n
        cur = set(Di.tolist()) if cur is None else (cur & set(Di.tolist()))
        out.append(len(cur))
        if len(cur) == 0:
            break
    return out

print("intersection attack at large moduli (|S| ~ 2^24, the practical memory ceiling)", flush=True)
print(f"{'nbits':>6} {'b':>4} {'|S|':>12} {'pred t*':>8} | {'measured t* (first <=64)':>26} "
      f"{'survivors':>34} {'secs':>7}", flush=True)
for nbits, bits in [(40, 16), (44, 20), (48, 24)]:
    pred = int(math.ceil(nbits / bits)) + 1
    t0 = time.time()
    got = None; counts = None
    for t in range(2, pred + 3):
        nn, span, dt, rs, ss, zs = make(t, nbits, bits, 3)
        counts = survivors(nn, span, t, rs, ss, zs)
        if counts and counts[-1] <= 64:
            got = t
            break
    el = time.time() - t0
    print(f"{nbits:>6} {bits:>4} {span:>12} {pred:>8} | {str(got):>26} "
          f"{' '.join(str(c) for c in (counts or [])):>34} {el:>7.1f}", flush=True)
print()
print("law: t* = ceil(log2 n / b) + O(1) -- measured here at 40-48-bit moduli,", flush=True)
print("a 2^22-times larger scale than the first implementation test.", flush=True)
