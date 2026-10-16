load("lib.sage")
def attack2(inst, sigma, beta_bits):
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    nbits = inst["nbits"]
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
        x = [v[j] // S[j] for j in range(t+1)]
        if (x[0] % n) == inst["d"] % n: return True
    return False

NB = 256
print("success RATE (x/12) at nbits=256, t=4, b=256, for each (sigma, beta) and l", flush=True)
print(f"{'sigma':>5} {'beta':>5} | " + " ".join(f"l={l:<4d}" for l in [256,192,160,128,96,72,64]), flush=True)
for sigma in [0, 32, 64, 128, 256]:
    for beta_bits in [192, 256, 320, 384]:
        row = []
        for l in [256, 192, 160, 128, 96, 72, 64]:
            h = sum(attack2(build_instance(NB, 4, l, "msb", sd=sd, dbits=NB), sigma, beta_bits)
                    for sd in range(12))
            row.append(h)
        print(f"{sigma:5d} {beta_bits:5d} | " + " ".join(f"{h:>5d}" for h in row), flush=True)
