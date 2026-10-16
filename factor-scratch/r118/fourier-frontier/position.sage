# HYPOTHESIS: the Fourier/intersection attack is POSITION-INVARIANT.
#
# Round 15 established position-invariance for KNOWN bits in the *lattice* attack.  Nothing
# implies it for a different algorithm.  For a b-bit block at bit position j the bias
# function is f_j(k) = 1 iff bits j..j+b-1 of k are all zero, |S_j| = n / 2^b for every j,
# and the candidate sets are the affine preimages D_i^j.
#
# PREDICTION: identical survivor counts and identification thresholds for the LOW block
# (j = 0), the MIDDLE block (j = nbits/2) and the HIGH block (j = nbits - b).
# FALSIFIER: any position dependence, in either direction.

import numpy as np, math

def make(t, nbits, j, bits, p, seed):
    """nonces whose block at bit position j is reliably zero with probability p"""
    set_random_seed(seed)
    n = int(next_prime(2**nbits))                 # PYTHON int from here on
    block = ((1 << bits) - 1) << j
    # NB: in Sage '^' is EXPONENTIATION and '^^' is XOR -- clearing the block by
    # subtraction avoids the operator entirely.
    notblock = None
    d_true = ZZ(randint(1, n - 1)) % n
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = int(ZZ(randint(0, n - 1)))
        if random() < p:
            k = k - (k & block)                   # clear the leaked block
        r = int(ZZ(randint(1, n - 1))); z = int(ZZ(randint(0, n - 1)))
        s = (z + r * d_true) * pow(k, -1, n) % n
        rs.append(r); ss.append(s); zs.append(z)
    return n, block, int(d_true), rs, ss, zs

def survivors(n, block, t, rs, ss, zs):
    """S = {k in [0,n) : k & block == 0};  D_i = {(s_i k - z_i) r_i^-1 : k in S}"""
    allk = np.arange(n, dtype=np.int64)
    S = allk[(allk & block) == 0]
    out = []
    cur = None
    for i in range(t):
        Di = ((int(ss[i]) * S - zs[i]) % n) * pow(rs[i], -1, n) % n
        cur = set(Di.tolist()) if cur is None else (cur & set(Di.tolist()))
        out.append(len(cur))
    return out

NB = 18
print(f"n ~ 2^{NB}: is the threshold position-invariant?  (b = leaked block width, p = 1)", flush=True)
print(f"{'block pos':>16} {'bits':>5} {'pred t*':>8} | {'survivor counts by t':>42} {'first<=64':>10}", flush=True)
for bits in [4, 8]:
    for jname, j in [("LOW  (j=0)", 0), ("MID  (j=n/2)", NB // 2), ("HIGH (j=n-b)", NB - bits)]:
        pred = int(math.ceil(NB / bits))
        nn, blk, dt, rs, ss, zs = make(pred + 4, NB, j, bits, 1.0, 3)
        counts = survivors(nn, blk, pred + 4, rs, ss, zs)
        got = next((i + 1 for i, c in enumerate(counts) if c <= 64), None)
        print(f"{jname:>16} {bits:>5} {pred:>8} | {' '.join(str(c) for c in counts):>42} {str(got):>10}", flush=True)
print()
print("prediction: identical survivor counts and thresholds across the three positions.", flush=True)
