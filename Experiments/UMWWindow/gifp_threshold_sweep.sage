import sys, time
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/gifp_run/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'

def recover_verified(n, alpha, gamma, beta1, beta2, m, seed):
    """Full GIFP pipeline + README gcd recovery.
    Returns (status, verified) where verified means the recovered divisor was
    checked INDEPENDENTLY against the true N2 (nontrivial, exact, and equal to
    the true p2 or q2)."""
    gen = generate_gifp_instance(
        n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    N1_list, N2_list, share_bit, ds = gen if gen is not None else (None, None, None, None)
    if N1_list is None:
        # generator exhausted max_attempts for this seed -> not a usable
        # instance at these parameters; report as skipped, NOT as a failure.
        return ("skip_gen", False), 0, 0
    p1, q1, N1 = N1_list
    p2t, q2t, N2 = N2_list
    x0, y0, z0, w0 = ds

    pr = ZZ["x", "y", "z", "w"]
    x, y, z, w = pr.gens()
    f = x*z + 2**(int(beta2*n)+int(gamma*n))*y*z + N2
    X = Integer(2 ** int(beta2*n))
    Y = Integer(2 ** int(n-alpha*n-gamma*n-beta1*n))
    Z = Integer(2 ** int(alpha*n))
    W = Integer(2 ** int(n-alpha*n))
    M = Integer(2 ** int(beta2*n-beta1*n))
    t = round((1 - sqrt(alpha))*m)
    s = round(sqrt(alpha)*m)
    unknown_modular = M**m * N1**t

    qr = pr.quotient(z*w - N2)
    modular = M^m*N1^t
    N2_inverse = inverse_mod(N2, modular)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2_inverse**min(ii+jj,s)
            g = qr(g).lift()
            shifts.append(eliminate_N2(g, modular))

    L, monomials = create_lattice(pr, shifts, [X, Y, Z, W])
    L = reduce_lattice(L, 0.8)
    polys = reconstruct_polynomials(L, f, unknown_modular, monomials, [X, Y, Z, W])
    nzero = sum(1 for pp in polys if pp(x0, y0, z0, w0) == 0)

    polys = list(polys)
    polys.insert(0, z*w - N2)
    S = Sequence(polys, pr.change_ring(QQ, order='lex'))
    G = None
    while len(S) > 0:
        G = S.groebner_basis()
        if len(G) == pr.ngens():
            break
        S.pop()
    if G is None or len(G) != pr.ngens():
        return ("no_gb", False), nzero, len(polys)

    g23 = G[1].gcd(G[2])
    for fac_ir, mult in g23.factor():
        if set(fac_ir.variables()) == {y, w}:
            a = 0
            for mono in fac_ir.monomials():
                exps = [int(e) for e in mono.exponents()[0]]
                c = fac_ir.monomial_coefficient(mono)
                if exps == [0, 1, 0, 0]:
                    a = c
            if a != 0 and N2 % a == 0:
                cand = N2 // a
                if 1 < a < N2:
                    genuine = (a * cand == N2) and (a in (p2t, q2t))
                    return (("ok" if genuine else "ok_WRONG"), genuine), nzero, len(polys)
    return ("no_factor", False), nzero, len(polys)

n = 200
alpha = RR(0.1)
beta1, beta2 = RR(0.1), RR(0.15)
m = 4
thr = 4*float(alpha)*(1-sqrt(float(alpha)))
print("alpha=0.1  threshold gamma > %.5f   (n=%d, m=%d)\n" % (thr, n, m))
print("%-7s %-9s %-6s %-9s %-7s  %s" % ("gamma", "margin", "seeds", "VERIFIED", "z-polys", "statuses"))
TRIALS = 10
rates = {}
for gamma in [0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.70]:
    ver = 0
    st = []
    zp = []
    skipped = 0
    for k in range(TRIALS):
        seed = 2000000 + 104729*k + int(gamma*10000)
        (s, g), nz, npoly = recover_verified(n, alpha, RR(gamma), beta1, beta2, m, seed)
        if s == "skip_gen":
            skipped += 1
            continue
        st.append(s)
        zp.append("%d/%d" % (nz, npoly))
        if g:
            ver += 1
    rates[gamma] = (ver, TRIALS - skipped)
    print("%-7s %-+9.4f %-6d %-9s %-7s  %s" % (
        float(gamma), float(gamma)-thr, TRIALS - skipped,
        "%d/%d" % (ver, TRIALS-skipped), ",".join(sorted(set(zp))[:3]), ",".join(sorted(set(st)))))

print("\nVERIFIED RATE (each = independently confirmed true factor of N2)")
for g in sorted(rates):
    ver, tot = rates[g]
    print("  gamma=%.2f (margin %+.4f)  %2d/%d  %s" % (g, g-thr, ver, tot, "#"*ver))