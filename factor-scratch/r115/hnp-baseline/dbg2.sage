load("hnp_baseline_lib.sage")

inst = build_instance(64, 4, 32, "msb", sd=0)
n, t, l = inst["n"], inst["t"], inst["l"]
r, s, z, a, k = inst["r"], inst["s"], inst["z"], inst["a"], inst["k"]
d = inst["d"]
m = 64 - l
c = [(z[i] - s[i]*a[i]) % n for i in range(t)]
beta, vp = [], []
for i in range(t):
    si_inv = inverse_mod(s[i], n)
    beta.append((r[i]*si_inv) % n)
    vp.append((c[i]*si_inv) % n)
K = [k[i] - a[i] for i in range(t)]
print("K bounds ok:", all(0 <= K[i] < (1<<m) for i in range(t)))
print("relation s*K - r*d = c (mod n):", all((s[i]*K[i] - r[i]*d - c[i]) % n == 0 for i in range(t)))
print("K = beta*d + vp (mod n):", all((beta[i]*d + vp[i] - K[i]) % n == 0 for i in range(t)))
print("true d =", d)

S = [ZZ(1)] + [ZZ(1) << l for _ in range(t)]
Bm = matrix(ZZ, t+1, t+1)
Bm[0,0] = 1
for i in range(t): Bm[0,1+i] = S[1+i]*beta[i]
for i in range(t): Bm[1+i,1+i] = n*S[1+i]
print("det(Bm) =", Bm.det(), " n^t =", n**t)

# true lambda = v_true - v_p  (scaled coords), v_true = (d, K_i*S_i)
vtrue = vector(ZZ, [d] + [S[1+i]*K[i] for i in range(t)])
vpvec = vector(ZZ, [ZZ(0)] + [S[1+i]*vp[i] for i in range(t)])
lam_true = vtrue - vpvec
print("lam_true =", lam_true)
coeffs = Bm.solve_left(lam_true)
print("lam_true = integer combination of basis rows:", all(x in ZZ for x in coeffs), coeffs)

R = Bm.LLL()
tau = vector(QQ, t+1)
tau[0] = QQ(n//2)
for i in range(t): tau[1+i] = QQ((1<<m)//2)
lam = babai_nearest_plane(R, tau)
print("babai lam* =", lam)
print("dist(lam*, tau) =", (vector(QQ, lam) - tau).norm().n(20))
print("dist(lam_true, tau) =", (vector(QQ, lam_true) - tau).norm().n(20))
print("lam* == lam_true:", lam == lam_true)
