load("hnp_baseline_lib.sage")

def attack_w(inst, w_shift):
    """SVP-Kannan embedding with weight B = 2^(nbits + w_shift). Returns (hit, wrong)."""
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    nbits = inst["nbits"]
    c = [(z[i] - s[i]*a[i]) % n for i in range(t)]
    beta, vp = [], []
    for i in range(t):
        si = inverse_mod(s[i], n)
        beta.append((r[i]*si) % n); vp.append((c[i]*si) % n)
    S = [ZZ(1)] + [ZZ(1) << l for _ in range(t)]
    B = ZZ(1) << (nbits + w_shift)
    M = matrix(ZZ, t+2, t+2)
    M[0,0] = 1
    for i in range(t): M[0,1+i] = S[1+i]*beta[i]
    for i in range(t): M[1+i,1+i] = n*S[1+i]
    for i in range(t): M[t+1,1+i] = S[1+i]*vp[i]
    M[t+1,t+1] = B
    R = M.LLL()
    best = None; wrong = 0
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t+1] != B and v[t+1] != -B: continue
        x = [v[j] // S[j] for j in range(t+1)]
        dk = x[0] % n
        ok = all((s[j]*(x[1+j] % n) - r[j]*dk - c[j]) % n == 0 for j in range(t))
        if not ok: continue
        if dk == inst["d"] % n: best = dk
        else: wrong += 1
    return (best is not None), wrong

for (nb, t, l) in [(96,4,64),(64,4,32),(96,4,32),(128,4,32)]:
    inst = build_instance(nb, t, l, "msb", sd=0)
    line = f"nbits={nb} t={t} l={l} (t*l={t*l} vs floor {nb}): "
    for w in (-4,-2,-1,0,1,2,4,8):
        hit, wrong = attack_w(inst, w)
        line += f" w={w:+d}:{'HIT' if hit else '.'}"
    print(line, flush=True)
