# Does the alpha>=0.15 GIFP wall depend on n?
#
# All r110/r111 results are at n=200, where the lattice is only 15x15. If the
# wall is a small-dimension / finite-size artefact, then at larger n with the
# same (alpha, gamma) ratio the attack should either recover or the wall should
# move. This is a scaling question the other subagents are not covering, and it
# is cheap.
#
# Uses the VERIFIED recovery path (README gcd method) from gifp_verify_sage.
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def recover(n, alpha, gamma, beta1, beta2, m, seed):
    """Returns (status, verified). Verified = recovered divisor is a nontrivial
    EXACT factor of the true N2 equal to true p2 or q2."""
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
    t = round((1 - sqrt(alpha))*m)
    s = round(sqrt(alpha)*m)
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
                return (("ok" if ((a*cand == N2) and (a in (p2t, q2t))) else "WRONG"),
                        (a*cand == N2) and (a in (p2t, q2t)))
    return ("no_factor", False)


def q(v, n):
    return RR(ZZ(round(v*n))/n)


b1, b2 = RR(0.1), RR(0.15)
TRIALS = 3
print("Scaling: does the alpha-wall move with n?  (m scaled with n)")
print("gamma held at 0.50, well above every threshold\n")
print("%-5s %-6s %-4s %-8s %-10s  %s" % ("n", "alpha", "m", "thr", "verified", "statuses"))
for n in [200, 400]:
    for alpha_v in [0.10, 0.15]:
        alpha = q(alpha_v, n)
        thr = 4*float(alpha)*(1-sqrt(float(alpha)))
        # scale m with n so the lattice dimension is comparable
        m = int(round(n/50))
        ok = 0; tot = 0; st = []
        for k in range(TRIALS):
            seed = 7700000 + 15485863*k + n + int(alpha_v*100)
            s, g = recover(n, alpha, q(0.50, n), b1, b2, m, seed)
            if s.startswith("skip"):
                continue
            tot += 1; st.append(s)
            if g:
                ok += 1
        if tot == 0:
            print("%-5d %-6.2f %-4d %-8.4f %-10s all skipped" % (n, alpha_v, m, thr, "-"))
        else:
            print("%-5d %-6.2f %-4d %-8.4f %-10s %s" % (n, alpha_v, m, thr,
                  "%d/%d" % (ok, tot), ",".join(sorted(set(st)))))