load("lib.sage")
# The target vector is (d, K_i*S_i, ..., B) with B = 2^256, so |v*|^2 = B^2 + EXCESS where
# EXCESS = d^2 + sum(K_i S_i)^2 ~ 2^512 -- i.e. |v*| = B*sqrt(1+O(1)).  EVERY candidate
# solution has norm within a factor sqrt(2) of B, so the attack's success is decided by the
# EXCESS, not by |v*| itself.  Decisive measurement: does the true solution minimise the
# excess among all lattice vectors with last coordinate = +-B?

def build_lattice(inst, sigma, beta_bits):
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
    return M, S, B

print(f"{'l':>5} {'t*l':>5} | {'EXC v*':>12} {'min EXC':>12} {'v* is min?':>11} {'#points in box':>16} {'attack':>7}", flush=True)
for l in [56, 60, 64, 68, 72, 76, 80]:
    inst = build_instance(256, 4, l, "msb", sd=0)
    M, S, B = build_lattice(inst, l, 256)
    t_ = inst["t"]; n = inst["n"]; m = 256 - l
    # true solution's excess
    vsq = inst["d"]**2 + sum((inst["k"][i] - inst["a"][i])**2 * S[1+i]**2 for i in range(t_))
    # exact SVP (dim 6): minimum excess over vectors with last coordinate +-B
    R = M.BKZ(block_size=6, proof=False)
    best = None
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t_+1] != B and v[t_+1] != -B: continue
        excess = sum(v[j]**2 for j in range(t_+1))
        if best is None or excess < best: best = excess
    # counting: number of lattice points inside the box {d<2^256, K_i<2^m}
    cnt = QQ(2**256 * 2**(t_*m)) / QQ(n**t_)
    is_min = (best is not None and vsq <= best)
    ok = attack(inst, algo="bkz", bkz_block=30)[0] is not None
    print(f"{l:>5} {4*l:>5} | {float(vsq.n(4).log(2).n(4)):>12.1f} "
          f"{float(ZZ(best).n(4).log(2).n(4)):>12.1f} {str(is_min):>11} "
          f"{float(cnt.n(4)):>16.3e} {str(ok):>7}", flush=True)
print()
print("counting bound: #points = 2^256 * 2^(4m) / n^4 < 1  <=>  4l > 256  <=>  l > 64", flush=True)
