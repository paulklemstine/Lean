import math
print("=== (1) GLV box density with a GENUINE GLV eigenvalue lam^2+lam+1 = 0 mod n ===", flush=True)
print("(a GLV lambda is ~n/2, not small: multiplication by lam permutes Z_n, so the box", flush=True)
print(" image is a union of sqrt(n) intervals of length sqrt(n) -- it can cover everything.)", flush=True)
for p in [1009, 1013, 2003, 3001, 4001, 5003]:
    if (p - 1) % 3 != 0: continue
    R = Integers(p); x = R.gen()
    roots = solve_mod(x**2 + x + 1, p) if False else None
    lams = [c for c in range(p) if (c*c + c + 1) % p == 0]
    if not lams:
        print(f"  p={p}: no cube root of unity (3 ∤ p-1?)", flush=True); continue
    lam = lams[0]
    side = int(math.ceil(math.sqrt(p)))
    img = set()
    lamvals = [(lam * k2) % p for k2 in range(side)]
    for k1 in range(side):
        for lv in lamvals:
            img.add((k1 + lv) % p)
    print(f"  p={p:6d} lam={lam:6d} (lam^2+lam+1=0: {(lam*lam+lam+1)%p==0}) side=ceilsqrt={side:3d} "
          f"pairs={side*side:7d} -> |image|={len(img):6d}/{p}  covered={float(len(img))/p:.4f}", flush=True)

print()
print("=== (2) LCG nonces, KNOWN multiplier: recover d with ZERO nonce leakage ===", flush=True)
def lcg_attack(p, t, m, a, sd=0):
    set_random_seed(sd)
    M2 = 1 << m
    b = ZZ(randint(0, M2 - 1)); d = ZZ(randint(1, p - 1)); k0 = ZZ(randint(1, M2 - 1))
    ks = [k0]
    for _ in range(t - 1):
        ks.append((a * ks[-1] + b) % M2)
    Sig = [(ZZ(a)**i - 1) // ZZ(a - 1) for i in range(t)]
    rs, ss, zs = [], [], []
    for i in range(t):
        r = ZZ(randint(1, p - 1)); z = ZZ(randint(0, p - 1))
        s = (z + r * d) * inverse_mod(ks[i] % p, p) % p
        rs.append(r); ss.append(s); zs.append(z)
    kdim = t + 3
    A = matrix(ZZ, t, kdim)
    for i in range(t):
        A[i, 0] = (ss[i] * (ZZ(a)**i)) % p
        A[i, 1] = (ss[i] * Sig[i]) % p
        A[i, 2] = (-rs[i]) % p
        A[i, 3 + i] = (-ss[i] * M2) % p
    Az = matrix(Zmod(p), A); rhs = vector(Zmod(p), zs)
    try: x0z = Az.solve_right(rhs)
    except Exception: return False
    x0 = vector(ZZ, [ZZ(x0z[c]) for c in range(kdim)])
    Kz = Az.right_kernel_matrix()
    basis = [[ZZ(Kz[j, c]) for c in range(kdim)] for j in range(Kz.nrows())]
    for j in range(kdim):
        e = [ZZ(0)] * kdim; e[j] = p; basis.append(e)
    R = matrix(ZZ, basis).LLL()
    B = ZZ(1) << (p.nbits() + 8)
    M = matrix(ZZ, R.nrows() + 1, kdim + 1)
    for i in range(R.nrows()):
        for c in range(kdim): M[i, c] = R[i, c]
    for c in range(kdim): M[R.nrows(), c] = x0[c]
    M[R.nrows(), kdim] = B
    MR = M.LLL()
    for i in range(MR.nrows()):
        v = MR.row(i)
        if v[kdim] not in (B, -B): continue
        drec = v[2] % p
        if drec != d: continue
        k0r, br = v[0] % M2, v[1] % M2
        ks2 = [k0r]
        for _ in range(t - 1): ks2.append((a * ks2[-1] + br) % M2)
        if all(ss[j] * ks2[j] % p == (zs[j] + rs[j] * drec) % p for j in range(t)):
            return True
    return False

p = 1009          # prime, 1009 bits ~ 10; use a bigger prime for realism
p = ZZ(next_prime(2**30))
print(f"  signature modulus p = {p} (prime, {p.nbits()} bits)", flush=True)
for a, m in [(1103515245 % (1<<30), 30), (1103515245, 30), (214013, 30), (1103515245, 20)]:
    if (a * (1<<30)) % (1<<m) == 0: continue
    aa = a % (1 << m)
    if (aa - 1) % 4 != 0 or math.gcd(aa - 1, 1 << m) != 1 and m < 4:
        pass
    print(f"  a = {aa} (KNOWN), LCG modulus 2^{m}", flush=True)
    for t in [3, 4, 5, 6]:
        ok = 0
        for sd in range(12): ok += lcg_attack(p, t, m, aa, sd=sd)
        print(f"    t={t}: {ok}/12 recovered d with ZERO nonce leakage", flush=True)
