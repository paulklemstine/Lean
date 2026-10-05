# RE-MEASURE the r111 alpha-dependence claim at a NON-COLLAPSING t.
#
# r111 claimed "the bound's shape is wrong: the success ratio gamma/[4a(1-sqrt a)]
# differs by alpha". r112 retracted that as measured THROUGH the t-collapse.
# Fair correction: redo it holding t at the value that keeps the modulus large
# (t = 3 where the staircase allows), so alpha is genuinely the variable.
#
# For each alpha, gamma is swept on a grid relative to its own proven threshold.
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def rec(n, alpha, gamma, b1, b2, m, seed, t, s):
    gen = generate_gifp_instance(n, alpha, gamma, b1, b2, seed, max_attempts=10)
    N1l, N2l, sh, ds = gen if gen is not None else (None,)*4
    if N1l is None:
        return ("skip", False)
    p1, q1, N1 = N1l
    p2t, q2t, N2 = N2l
    x0, y0, z0, w0 = ds
    pr = ZZ["x", "y", "z", "w"]
    x, y, z, w = pr.gens()
    f = x*z + 2**(int(b2*n)+int(gamma*n))*y*z + N2
    X = Integer(2 ** int(b2*n))
    Y = Integer(2 ** int(n-alpha*n-gamma*n-b1*n))
    Z = Integer(2 ** int(alpha*n))
    W = Integer(2 ** int(n-alpha*n))
    M = Integer(2 ** int(b2*n-b1*n))
    um = M**m * N1**t
    qr = pr.quotient(z*w - N2)
    mod = M**m * N1**t
    if gcd(N2, mod) != 1:
        return ("skip", False)
    N2i = inverse_mod(N2, mod)
    shs = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii, 0) * N2i**min(ii+jj, s)
            shs.append(eliminate_N2(qr(g).lift(), mod))
    L, mono = create_lattice(pr, shs, [X, Y, Z, W])
    L = reduce_lattice(L, 0.8)
    P = list(reconstruct_polynomials(L, f, um, mono, [X, Y, Z, W]))
    P.insert(0, z*w - N2)
    Sq = Sequence(P, pr.change_ring(QQ, order='lex'))
    G = None
    while len(Sq) > 0:
        G = Sq.groebner_basis()
        if len(G) == pr.ngens():
            break
        Sq.pop()
    if G is None or len(G) != pr.ngens():
        return ("no_gb", False)
    for fi, _ in G[1].gcd(G[2]).factor():
        if set(fi.variables()) == {y, w}:
            a = 0
            for mo in fi.monomials():
                if [int(e) for e in mo.exponents()[0]] == [0, 1, 0, 0]:
                    a = fi.monomial_coefficient(mo)
            if a != 0 and N2 % a == 0 and 1 < a < N2:
                cd = N2 // a
                ok = (a*cd == N2) and (a in (p2t, q2t))
                return ("ok" if ok else "WRONG", ok)
    return ("no_factor", False)


def q(v, n):
    return RR(ZZ(round(v*n))/n)


n = 200
b1, b2 = RR(0.1), RR(0.15)
m = 4
T = 4
# Hold t=3 (no collapse) wherever the bit budget allows it.
T_HOLD, S_HOLD = 3, 0
print("Re-measuring alpha-dependence with t held FIXED at %d (no staircase collapse)." % T_HOLD)
print("ratio = gamma / [4*alpha*(1-sqrt(alpha))]\n")
print("%-6s %-8s %-8s %-9s %-8s  %s" % ("alpha", "thr", "ratio", "gamma", "verified", "statuses"))
res = {}
for alpha_v in [0.05, 0.10, 0.15, 0.20]:
    alpha = q(alpha_v, n)
    thr = 4*float(alpha)*(1-sqrt(float(alpha)))
    for mult in [1.4, 1.6, 1.8]:
        gamma = thr * mult
        if not (alpha_v + gamma + 0.15) < 1:
            print("%-6.2f %-8.4f %-8.1f %-9.4f %-8s  INFEASIBLE" % (alpha_v, thr, mult, gamma, "-"))
            continue
        gq = q(gamma, n)
        ok = 0; tot = 0; st = []
        for k in range(T):
            seed = 12000000 + 15485863*k + int(alpha_v*100)*100 + int(mult*10)
            s_, g_ = rec(n, alpha, gq, b1, b2, m, seed, T_HOLD, S_HOLD)
            if s_ == "skip":
                continue
            tot += 1; st.append(s_)
            if g_:
                ok += 1
        res[(alpha_v, mult)] = (ok, tot)
        print("%-6.2f %-8.4f %-8.1f %-9.4f %-8s  %s" % (
            alpha_v, thr, mult, gq, ("%d/%d" % (ok, tot)) if tot else "-",
            ",".join(sorted(set(st)))))

print("\nVERIFIED RATE (rows alpha, cols ratio to proven threshold), t=3 fixed")
print("  %-7s %s" % ("alpha", "  ".join("%5.1fx" % mu for mu in [1.4, 1.6, 1.8])))
for alpha_v in [0.05, 0.10, 0.15, 0.20]:
    cells = []
    for mult in [1.4, 1.6, 1.8]:
        if (alpha_v, mult) in res:
            ok, tot = res[(alpha_v, mult)]
            cells.append("%2d/%-2d" % (ok, tot) if tot else "  -  ")
        else:
            cells.append("  --  ")
    print("  %-7.2f %s" % (alpha_v, "  ".join(cells)))