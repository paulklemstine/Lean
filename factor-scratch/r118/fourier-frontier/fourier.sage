# THE FOURIER/MAXIMUM-LIKELIHOOD FRONTIER — the attack family the round-17 invariance
# results never touched.
#
# Round 17 established that the PLAIN HNP lattice's threshold is invariant to embedding,
# reduction strength and leakage *position*. That says nothing about attacks that are not
# lattices. Bleichenbacher's Fourier analysis (and LadderLeak) exploit a *probabilistic*
# bias rather than known bits, by a maximum-likelihood test over all candidate keys.
#
# Model: each nonce's top bit is 0 with probability p > 1/2 (the "bias"), the rest uniform.
# Information per signature: 1 - H(p) bits, which can be ARBITRARILY SMALL.
# ML test: for each candidate d, count how many k_i(d) = s_i^{-1}(z_i + r_i d) mod n have
# their top bit 0; the true key is the argmax.
#
# PREDICTION (the whole point): the true key wins when
#         t * (p - 1/2) >> sqrt(t)/2    i.e.   t >> 1 / (4 (p-1/2)^2)
# which is INDEPENDENT OF n.  Contrast the plain lattice: ~10 KNOWN bits per signature.
# So with enough signatures, an arbitrarily small bias is exploitable, and the threshold in
# total information is ~ n bits + O(1) -- the information-theoretic floor, not the lattice's
# 10-bits-per-signature overhead.

def run(p, t, nbits, seed):
    """returns (did the ML test find the true key?, margin over the runner-up)"""
    set_random_seed(seed)
    n = ZZ(next_prime(2**nbits))
    d_true = ZZ(randint(1, n - 1))
    rs, ss, zs = [], [], []
    for _ in range(t):
        # nonce with a BIASED top bit: 0 with prob p, else uniform
        k = ZZ(randint(0, (ZZ(1) << (nbits - 1)) - 1))          # top bit 0
        if random() < (1 - p):
            k += ZZ(1) << (nbits - 1)                            # top bit 1
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(r); ss.append(s); zs.append(z)
    half = ZZ(1) << (nbits - 1)
    # ML score for every candidate d: count of top-bit-0 nonces
    best, bestd, second, secondcnt = None, None, None, None
    sinv = [inverse_mod(ss[i], n) for i in range(t)]
    for d in range(1, n):
        cnt = 0
        for i in range(t):
            k = (zs[i] + rs[i] * d) * sinv[i] % n
            if k < half:
                cnt += 1
        if best is None or cnt > best:
            second, best = best, cnt
            bestd = d
        elif second is None or cnt > second:
            second = cnt
    found = (bestd == d_true)
    margin = (best - second) if second is not None else None
    return found, margin, best

print("n-independence test: threshold t* for each bias p, at two sizes", flush=True)
print(f"{'p':>6} {'bias':>7} {'pred t*':>8} | {'nbits=12':>22} | {'nbits=16':>22}", flush=True)
import math
for p in [0.55, 0.60, 0.70, 0.80, 0.90]:
    pred = int(1 / (4 * (p - 0.5)**2))
    out = []
    for nbits in [12, 16]:
        found_t = None; margins = []
        for t in [8, 16, 32, 64, 128, 256]:
            wins = 0; marg = []
            for seed in range(3):
                f, m, b = run(p, t, nbits, seed)
                wins += f; marg.append(m if f else 0)
            if wins >= 2 and found_t is None:
                found_t = t
            margins.append((t, wins))
        out.append(f"{found_t if found_t else '>256':>7} ({'/'.join(str(w) for _, w in margins)})")
    print(f"{p:>6.2f} {p-0.5:>7.2f} {pred:>8} | {out[0]:>22} | {out[1]:>22}", flush=True)
print()
print("pred t* = 1/(4(p-1/2)^2), the statistical prediction; it contains no n.", flush=True)
print("The parenthesised triple is wins/3 at t = 8,16,32,64,128,256.", flush=True)
