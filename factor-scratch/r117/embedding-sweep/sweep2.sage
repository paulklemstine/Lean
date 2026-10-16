load("lib.sage")
# Embedding family:  S_i = 2^sigma  (the column scaling of the unknown nonce parts)
# and                 B   = 2^beta  (the Kannan weight).
# Round 15/16 used sigma = l and beta = nbits. The Gaussian-heuristic condition for the
# target to be the shortest vector is
#       max(b, nbits-l+sigma)  <~  (t*nbits + t*sigma + beta)/(t+2)
# whose LHS grows in sigma at rate 1 while the RHS grows at rate t/(t+2) < 1, so sigma
# should be as SMALL as possible, and beta should be matched to the max coordinate.
# Prediction: a smaller sigma lowers the threshold from round-16's 1.125*nbits toward
# ~ (t+1)/(t+2)*nbits = 0.83*nbits. That is a direct test of whether the standard
# embedding is optimal.

def attack2(inst, sigma, beta_shift):
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    nbits = inst["nbits"]
    c = [(z[i] - s[i]*a[i]) % n for i in range(t)]
    beta = [(r[i]*inverse_mod(s[i], n)) % n for i in range(t)]
    vp  = [(c[i]*inverse_mod(s[i], n)) % n for i in range(t)]
    S = [ZZ(1)] + [ZZ(1) << sigma for _ in range(t)]
    B = ZZ(1) << (nbits + beta_shift)
    M = matrix(ZZ, t+2, t+2)
    M[0,0] = 1
    for i in range(t): M[0,1+i] = S[1+i]*beta[i]
    for i in range(t): M[1+i,1+i] = n*S[1+i]
    for i in range(t): M[t+1,1+i] = S[1+i]*vp[i]
    M[t+1,t+1] = B
    R = M.LLL()
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t+1] != B and v[t+1] != -B: continue
        x = [v[j] // S[j] for j in range(t+1)]
        dk = x[0] % n
        if dk == inst["d"] % n:
            return True
    return False

NB = 256
print("nbits=256, t=4, b=256 (the round-15/16 slice). Threshold l* for each (sigma,beta_shift):", flush=True)
print(f"{'sigma':>6} {'beta_shift':>11} | {'l*':>5} {'t*l*':>6} {'ratio':>6}", flush=True)
best = None
for sigma in [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96]:
    row = []
    for bshift in [-32, -16, -8, 0, 8, 16, 32]:
        lstar = None
        for l in range(0, NB+1, 8):
            h = sum(attack2(build_instance(NB, 4, l, "msb", sd=sd, dbits=NB), sigma, bshift)
                    for sd in range(12))
            if h >= 10:
                lstar = l
                break
        ratio = (4*lstar)/NB if lstar is not None else None
        row.append((bshift, lstar, ratio))
        if lstar is not None and (best is None or lstar < best[0]):
            best = (lstar, sigma, bshift)
    for bshift, lstar, ratio in row:
        print(f"{sigma:6d} {bshift:11d} | {str(lstar):>5} {str(4*lstar if lstar else None):>6} "
              f"{('%.3f' % ratio) if ratio else '     -':>6}", flush=True)
print("best:", best, "  (round-16 reference: sigma=l -> l*=72, t*l*=288, ratio 1.125)", flush=True)
