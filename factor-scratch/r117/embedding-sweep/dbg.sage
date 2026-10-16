load("lib.sage")
def attack2(inst, sigma, beta_shift, verbose=False):
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
    if verbose:
        print("   rows with |last| == B:", sum(1 for i in range(R.nrows())
              if abs(R.row(i)[t+1]) == B), " of ", R.nrows())
        for i in range(R.nrows()):
            v = R.row(i)
            if abs(v[t+1]) == B:
                x = [v[j] // S[j] for j in range(t+1)]
                print("     candidate d =", x[0] % n, " true d =", inst["d"])
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t+1] != B and v[t+1] != -B: continue
        x = [v[j] // S[j] for j in range(t+1)]
        dk = x[0] % n
        if dk == inst["d"] % n: return True
    return False

NB = 256
# sanity: does the LIB's own attack still work at l=72 (round-16 threshold)?
inst = build_instance(NB, 4, 72, "msb", sd=0, dbits=NB)
print("lib attack (sigma=l) at l=72:", attack(inst), flush=True)
print("attack2 (sigma=72) at l=72:", attack2(inst, 72, 0), flush=True)
# full leakage: must trivially recover
inst2 = build_instance(NB, 4, 256, "msb", sd=0, dbits=NB)
print("attack2 (sigma=64) at l=256:", attack2(inst2, 64, 0, verbose=True), flush=True)
print("attack2 (sigma=0)  at l=256:", attack2(inst2, 0, 0, verbose=True), flush=True)
