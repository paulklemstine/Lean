load("lib.sage")
# DECISIVE: at the threshold, is the true solution the SHORTEST vector of the embedded
# lattice?  Dimension here is t+2 = 6, so BKZ with block >= 6 is EXACT SVP.  If exact SVP
# still returns a shorter vector, the threshold is a geometric property of the instance,
# not of the reduction algorithm -- which is what the round-117 embedding sweep plus this
# BKZ sweep jointly suggest.

def build_lattice(inst, sigma, beta_bits):
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
    return M, S, B

def true_vector(inst, sigma, beta_bits):
    """The true solution embedded: (d, K_i*S_i, ..., B)."""
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    nbits = inst["nbits"]; m = nbits - l
    S = [ZZ(1)] + [ZZ(1) << sigma for _ in range(t)]
    B = ZZ(1) << beta_bits
    v = vector(ZZ, t+2)
    v[0] = inst["d"]
    for i in range(t):
        v[1+i] = (inst["k"][i] - a[i]) * S[1+i]
    v[t+1] = B
    return v

print("nbits=256, t=4 (embedding dim 6), sigma=l, beta=256", flush=True)
print(f"{'l':>5} {'t*l':>5} | {'|v*| bits':>11} {'lambda_1 bits':>13} {'v* shortest?':>14} {'attack ok':>10}", flush=True)
for l in [56, 60, 64, 68, 70, 72, 76, 80]:
    inst = build_instance(256, 4, l, "msb", sd=0)
    M, S, B = build_lattice(inst, l, 256)
    vstar = true_vector(inst, l, 256)
    nb_vs = vstar.norm(2).n(4).log(2).n(4)
    R = M.BKZ(block_size=6, proof=False)     # exact SVP in dimension 6
    lam = min(R.row(i).norm(2).n(4) for i in range(R.nrows()))
    nb_lam = lam.log(2).n(4)
    is_short = (lam >= vstar.norm(2))
    ok = attack(inst, algo="bkz", bkz_block=30)[0] is not None
    print(f"{l:>5} {4*l:>5} | {float(nb_vs):>11.2f} {float(nb_lam):>13.2f} "
          f"{str(is_short):>14} {str(ok):>10}", flush=True)
