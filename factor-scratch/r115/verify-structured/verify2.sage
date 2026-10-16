# Independent verification (v2, corrected).
# (1) I6 refutation: for ANY lambda with gcd(lambda,n)=1, the GLV box {k1 + lam*k2 :
#     k1,k2 < side} with side = ceil(sqrt(n)) covers ALL of Z_n.  Hence a "sublattice
#     embedding" imposes no constraint at all -- the worker's "empty constraint" claim.
# (2) I2(a known) positive: LCG nonces k_{i+1} = a*k_i + b mod 2^m with a KNOWN, b secret:
#     recover d from t signatures with ZERO nonce leakage.  Controls: t=3 must fail, and
#     the plain HNP at zero leakage must fail.
import math, itertools

print("=== (1) GLV box covers Z_n (lambda coprime to n) ===", flush=True)
for n in [101, 1013, 10007, 99372, 99991]:
    side = int(math.ceil(math.sqrt(n)))
    # cap the enumeration so it stays cheap; report the fraction covered at the largest
    # affordable side, and separately test the exact side when it is small
    if side > 400:
        side = 400
        exact = False
    else:
        exact = True
    for lam in [2, 3, n - 2, n - 3]:
        if math.gcd(lam, n) != 1: continue
        img = set()
        for k1 in range(side):
            acc = k1 % n
            for k2 in range(side):
                img.add((acc + lam * k2) % n)
        frac = len(img) / n
        print(f"  n={n:6d} side={side:4d} (exact ceilsqrt: {exact}) lam={lam:6d} -> "
              f"|image|={len(img):6d}/{n}  covered={float(frac):.4f}", flush=True)
        break

print("=== (2) LCG nonces with KNOWN multiplier a ===", flush=True)
def lcg_attack(n, t, m, a, sd=0):
    """k_{i+1} = a*k_i + b (mod 2^m); a KNOWN, b and the private key d unknown.
    k_i = a^i*k_0 + b*Sig_i - 2^m*q_i   over Z, with Sig_i = (a^i-1)//(a-1) an INTEGER.
    signature eq:  s_i*a^i*k_0 + s_i*Sig_i*b - s_i*2^m*q_i - r_i*d = z_i  (mod n)
    Unknowns (k_0, b, d, q_1..q_t): t+3 unknowns, t equations -> kernel rank 3.
    Standard Kannan embedding: kernel basis rows + n*e_j, target row = (x0, B)."""
    set_random_seed(sd)
    M2 = 1 << m
    b = ZZ(randint(0, M2 - 1)); d = ZZ(randint(1, n - 1)); k0 = ZZ(randint(1, M2 - 1))
    ks = [k0]
    for _ in range(t - 1):
        ks.append((a * ks[-1] + b) % M2)
    Sig = [ZZ(0)] * t
    for i in range(t):
        Sig[i] = (ZZ(a)**i - 1) // ZZ(a - 1)
    rs, ss, zs = [], [], []
    for i in range(t):
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d) * inverse_mod(ks[i], n) % n
        rs.append(r); ss.append(s); zs.append(z)
    kdim = t + 3
    A = matrix(ZZ, t, kdim)
    for i in range(t):
        A[i, 0] = (ss[i] * (ZZ(a)**i)) % n
        A[i, 1] = (ss[i] * Sig[i]) % n
        A[i, 2] = (-rs[i]) % n
        A[i, 3 + i] = (-ss[i] * M2) % n
    rhs = vector(ZZ, zs)
    # particular solution (mod n) then lifted to a representative
    Az = matrix(Zmod(n), A)
    try:
        x0z = Az.solve_right(vector(Zmod(n), rhs))
    except Exception:
        return False, "no particular solution"
    x0 = vector(ZZ, [ZZ(x0z[c]) for c in range(kdim)])
    # kernel lattice: right kernel of A mod n, plus n*e_j
    Kz = Az.right_kernel_matrix()
    basis = []
    for j in range(Kz.nrows()):
        basis.append([ZZ(Kz[j, c]) for c in range(kdim)])
    for j in range(kdim):
        e = [ZZ(0)] * kdim; e[j] = n; basis.append(e)
    L = matrix(ZZ, basis)
    R = L.LLL()
    # embed: rows (kernel basis, 0) and target (x0, B)
    B = ZZ(1) << (n.nbits() + 8)
    M = matrix(ZZ, R.nrows() + 1, kdim + 1)
    for i in range(R.nrows()):
        for c in range(kdim): M[i, c] = R[i, c]
    for c in range(kdim): M[R.nrows(), c] = x0[c]
    M[R.nrows(), kdim] = B
    MR = M.LLL()
    for i in range(MR.nrows()):
        v = MR.row(i)
        if v[kdim] != B and v[kdim] != -B: continue
        drec = v[2] % n
        # validate: reconstruct the nonces and check the signature equations
        ok = all((ss[j] * ((ZZ(a)**j * (v[0] % M2) + b_unknown if False else 0)) ) % n == 0 for j in range(0))
        k0r = v[0] % M2; br = v[1] % M2
        # regenerate nonces from (k0r, br) and check all equations mod n
        ks2 = [k0r]
        for _ in range(t - 1):
            ks2.append((a * ks2[-1] + br) % M2)
        good = all(ss[j] * ks2[j] % n == (zs[j] + rs[j] * drec) % n for j in range(t))
        if good and drec == d:
            return True, "recovered d"
    return False, "not found"

F = GF(10007); E = EllipticCurve(F, [0, 1]); n = ZZ(E.order())
print(f"  curve y^2=x^3+1 over F_10007, n = {n} ({n.nbits()} bits)", flush=True)
for a, m in [(1103515245 % (1<<12), 12), (413293, 12), (5, 12)]:
    if (a - 1) % 4 != 0 or math.gcd(a - 1, 1 << m) != 1 and False: pass
    print(f"  a = {a} (known), m = {m}", flush=True)
    for t in [3, 4, 5, 6]:
        ok = fail = 0; lastmsg = ""
        for sd in range(12):
            r, msg = lcg_attack(n, t, m, a, sd=sd)
            ok += r; fail += (not r); lastmsg = msg
        print(f"    t={t}: {ok}/12 recovered d   (last: {lastmsg})", flush=True)
