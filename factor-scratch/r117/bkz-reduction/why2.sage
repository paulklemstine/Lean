load("lib.sage")
def build_lattice(inst, sigma, beta_bits):
    n, t, l = inst["n"], inst["t"], inst["l"]
    c = [(inst["z"][i] - inst["s"][i]*inst["a"][i]) % n for i in range(t)]
    beta = [(inst["r"][i]*inverse_mod(inst["s"][i], n)) % n for i in range(t)]
    vp  = [(c[i]*inverse_mod(inst["s"][i], n)) % n for i in range(t)]
    S = [ZZ(1)] + [ZZ(1) << sigma for _ in range(t)]
    B = ZZ(1) << beta_bits
    M = matrix(ZZ, t+2, t+2)
    M[0,0] = 1
    for i in range(t): M[0,1+i] = S[1+i]*beta[i]
    for i in range(t): M[1+i,1+i] = n*S[1+i]
    for i in range(t): M[t+1,1+i] = S[1+i]*vp[i]
    M[t+1,t+1] = B
    return M, S, B

print("Is the SHORTEST +-B lattice vector a VALID solution (d in [0,n), K_i in [0,2^m))?", flush=True)
print(f"{'l':>5} {'t*l':>5} | {'log2(EXC_min)':>13} {'log2(EXC_true)':>14} {'gap(bits)':>9} | "
      f"{'shortest valid?':>16} {'attack':>7}", flush=True)
for l in [56, 60, 64, 68, 72, 76, 80]:
    inst = build_instance(256, 4, l, "msb", sd=0)
    t_, n, m = inst["t"], inst["n"], 256 - l
    M, S, B = build_lattice(inst, l, 256)
    truex = inst["d"]**2 + sum((inst["k"][i]-inst["a"][i])**2 * S[1+i]**2 for i in range(t_))
    R = M.BKZ(block_size=6, proof=False)          # exact SVP, dim 6
    rows = []
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t_+1] != B and v[t_+1] != -B: continue
        exc = sum(v[j]**2 for j in range(t_+1))
        x = [v[j] // S[j] for j in range(t_+1)]
        d, K = x[0] % n, [x[1+i] % n for i in range(t_)]
        valid = (0 <= x[0] < n) and all(0 <= x[1+i] // S[1+i] < (ZZ(1) << m) for i in range(t_))
        # a valid solution also needs the congruence: sK - rd = c (mod n)
        valid = valid and all((inst["s"][i]*((x[1+i]//S[1+i])) - inst["r"][i]*x[0] -
                               ((inst["z"][i] - inst["s"][i]*inst["a"][i]) % n)) % n == 0
                              for i in range(t_))
        rows.append((exc, x[0] % n, valid))
    rows.sort()
    exmin, dmin, validmin = rows[0]
    gap = QQ(exmin).n(20).log(2).n(6) - QQ(truex).n(20).log(2).n(6)
    ok = attack(inst, algo="bkz", bkz_block=30)[0] is not None
    print(f"{l:>5} {4*l:>5} | {float(ZZ(exmin).n(4).log(2).n(4)):>13.1f} "
          f"{float(ZZ(truex).n(4).log(2).n(4)):>14.1f} {float(gap):>9.2f} | "
          f"{str(validmin):>16} {str(ok):>7}", flush=True)
print()
print("A negative gap means some OTHER solution is shorter than the true one.", flush=True)
print("If that shorter one is INVALID (outside the box), the true key is hidden behind a", flush=True)
print("shorter invalid solution -- which is the real reason for the threshold.", flush=True)
