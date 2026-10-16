# HONEST CRITERION: the attack IDENTIFIES the key when the survivor set is small enough to
# check against the public key (each survivor costs one scalar multiplication).  Report the
# survivor count at each t and the first t with <= 64 survivors, against the prediction
# t* = ceil(log2 n / bits).
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
def survivor_counts(n, span, t, rs, ss, zs, dt=None):
    S = np.arange(span, dtype=np.int64); out = []; cur = None
    for i in range(t):
        Di = ((int(ss[i]) * S - zs[i]) % n) * pow(rs[i], -1, n) % n
        cur = set(Di.tolist()) if cur is None else (cur & set(Di.tolist()))
        out.append(len(cur))
    return out
NB = 22
print(f"n ~ 2^{NB}  (prediction: t* = ceil(log2 n / bits))", flush=True)
print(f"{'bits':>5} {'pred t*':>8} | {'survivor counts by t':>34} | {'first t with <=64':>18} {'agree?':>7}", flush=True)
for bits in [3, 4, 6, 8, 11]:
    pred = int(math.ceil(NB / bits))
    nn, span, dt, rs, ss, zs = make(pred + 4, NB, bits, 3)
    counts = survivor_counts(nn, span, pred + 4, rs, ss, zs)
    got = next((i + 1 for i, c in enumerate(counts) if c <= 64), None)
    print(f"{bits:>5} {pred:>8} | {' '.join(str(c) for c in counts):>34} | {str(got):>18} "
          f"{'yes' if got is not None and got <= pred + 1 else 'no':>7}", flush=True)
print()
print("survivor count is EXACT (the true key is always a survivor); the attack identifies it", flush=True)
print("when the set is small enough to check.  Note the intersections are tighter than the", flush=True)
print("random-set bound, because the D_i are structured affine preimages, not random sets.", flush=True)
