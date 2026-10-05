# Does the alpha-wall move with n? -- CORRECTED for the t-rounding confound.
#
# My first n-scan used m=8 at n=400, but m=8 is a KNOWN FAILING m (the
# t = round((1-sqrt(alpha))*m) undershoot documented in r111c). So that run was
# measuring the rounding artefact again, not the n-scaling. Classic self-inflicted
# confound.
#
# Fix: force t = ceil((1-sqrt(alpha))*m) and s = ceil(sqrt(alpha)*m) so the
# rounding artefact cannot mask the scaling question. Also compare t=round vs
# t=ceil at each point so the effect of the fix is visible.
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def recover(n, alpha, gamma, beta1, beta2, m, seed, t_ceil=False):
    gen = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    N1_list, N2_list, share, ds = gen if gen is not None else (None,)*4
    if N1_list is None:
        return ("skip_gen", False)
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
    it, is_ = (1 - sqrt(alpha))*m, sqrt(alpha)*m
    if t_ceil:
        t, s = int(it) + 1, int(is_) + 1
    else:
        t, s = int(round(it)), int(round(is_))
    unknown_modular = M**m * N1**t
    qr = pr.quotient(z*w - N2)
    modular = M^m*N1**t
    if gcd(N2, modular) != 1:
        return ("skip_noninv", False)
    N2inv = inverse_mod(N2, modular)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii, 0) * N2inv**min(ii+jj, s)
            shifts.append(eliminate_N2(qr(g).lift(), modular))
    L, monomials = create_lattice(pr, shifts, [X, Y, Z, W])
    L = reduce_lattice(L, 0.8)
    polys = list(reconstruct_polynomials(L, f, unknown_modular, monomials, [X, Y, Z, W]))
    polys.insert(0, z*w - N2)
    S = Sequence(polys, pr.change_ring(QQ, order='lex'))
    G = None
    while len(S) > 0:
        G = S.groebner_basis()
        if len(G) == pr.ngens():
            break
        S.pop()
    if G is None or len(G) != pr.ngens():
        return ("no_gb", False)
    for fi, _ in G[1].gcd(G[2]).factor():
        if set(fi.variables()) == {y, w}:
            a = 0
            for mono in fi.monomials():
                if [int(e) for e in mono.exponents()[0]] == [0, 1, 0, 0]:
                    a = fi.monomial_coefficient(mono)
            if a != 0 and N2 % a == 0 and 1 < a < N2:
                cand = N2 // a
                good = (a*cand == N2) and (a in (p2t, q2t))
                return ("ok" if good else "WRONG", good)
    return ("no_factor", False)


def q(v, n):
    return RR(ZZ(round(v*n))/n)


b1, b2 = RR(0.1), RR(0.15)
TRIALS = 3
print("n-scaling with t=CEIL (removes the r111c rounding artefact). gamma=0.50.\n")
print("%-5s %-6s %-4s %-9s %-9s %-9s  %s" % ("n", "alpha", "m", "round", "ceil", "t_ceil_s", "note"))
for n in [200, 400]:
    for alpha_v in [0.10, 0.15]:
        alpha = q(alpha_v, n)
        m = int(round(n/50))
        res = {}
        for tag, tc in [("round", False), ("ceil", True)]:
            ok = 0; tot = 0
            for k in range(TRIALS):
                seed = 8800000 + 15485863*k + n + int(alpha_v*100)
                s, g = recover(n, alpha, q(0.50, n), b1, b2, m, seed, tc)
                if s.startswith("skip"):
                    continue
                tot += 1
                if g:
                    ok += 1
            res[tag] = (ok, tot)
        rr, rc = res["round"], res["ceil"]
        fmt = lambda z: ("%d/%d" % z) if z[1] else "-"
        print("%-5d %-6.2f %-4d %-9s %-9s  %s" % (
            n, alpha_v, m, fmt(rr), fmt(rc),
            "wall persists" if rc[1] and rc[0] == 0 else
            ("recovered with ceil" if rc[0] else "")))