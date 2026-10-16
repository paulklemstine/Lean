load("lib.sage")
def attack2(inst, sigma, beta_bits):
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    c = [(z[i] - s[i]*a[i]) % n for i in range(t)]
    beta = [(r[i]*inverse_mod(s[i], n)) % n for i in range(t)]
    vp  = [(c[i]*inverse_mod(s[i], n)) % n for i in range(t)]
    S = [ZZ(1)] + [ZZ(1) << sigma for _ in range(t)]
    B = ZZ(1) << beta_bits
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
        if (v[0] % n) == inst["d"] % n: return True
    return False

NB, T = 256, 4
print("KEY TEST: for the BEST embeddings, does small key entropy b lower the threshold?", flush=True)
print(f"  (round-16 reference: sigma=l gives l*=72 for every b; counting bound says l*>b/t)", flush=True)
for (sigma, beta_bits) in [(72, 256), (128, 320), (256, 384), (160, 352)]:
    out = []
    for b in [64, 96, 128, 192, 256]:
        lstar = None
        for l in range(0, NB+1, 8):
            h = sum(attack2(build_instance(NB, T, l, "msb", sd=sd, dbits=b), sigma, beta_bits)
                    for sd in range(12))
            if h >= 10: lstar = l; break
        out.append(f"b={b}:l*={lstar}")
    print(f"  sigma={sigma:3d} beta={beta_bits:3d} | " + "  ".join(out), flush=True)
print()
print("counting bound l* > b/t, i.e. b=64 -> 16, b=128 -> 32, b=192 -> 48, b=256 -> 64", flush=True)
