load('instrument.sage')

# RIGOROUS CHECK of the rescue claim.
# For the Coppersmith argument to be legitimate, EVERY shift must vanish mod the
# modulus at the true root:
#        g(x0,y0,z0,w0) == 0  (mod  M^m * N1^t)
# If that congruence fails, the "success" is an artifact: the reduced vectors are
# not vanishing polynomials mod the claimed modulus, and the Groebner solve has no
# right to return the true point.
# So: check the congruence, AND check the recovered factor against ground truth.
n = 200; b1, b2 = 0.1, 0.15; alpha = 0.15; gamma = 0.6617

def full_check(n, alpha, gamma, b1, b2, m, seed, t, s, do_gb=True):
    b1, b2 = min(b1, b2), max(b1, b2)
    alpha, gamma, b1, b2 = quantize(alpha, gamma, b1, b2, n)
    gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1), RR(b2), seed, max_attempts=10)
    if gen is None: return ("skip_gen", None)
    N1_list, N2_list, share_bit, ds = gen
    p1, q1, N1 = N1_list
    p2t, q2t, N2 = N2_list
    x0, y0, z0, w0 = ds

    pr = ZZ["x","y","z","w"]; x, y, z, w = pr.gens()
    f = x*z + 2**(int(b2*n)+int(gamma*n))*y*z + N2
    X = Integer(2**int(b2*n)); Y = Integer(2**int(n-alpha*n-gamma*n-b1*n))
    Z = Integer(2**int(alpha*n));     W = Integer(2**int(n-alpha*n))
    M = Integer(2**int(b2*n-b1*n))
    modular = M**m * N1**t
    if gcd(N2, modular) != 1: return ("skip_noninv", None)
    N2i = inverse_mod(N2, modular)
    qr = pr.quotient(z*w - N2)

    # (1) the defining congruence, checked on the UNREDUCED shift
    bad = 0
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2i**min(ii+jj, s)
            if g(x0, y0, z0, w0) % modular != 0:
                bad += 1
    if bad > 0:
        return ("CONGRUENCE_VIOLATED_%d" % bad, None)

    # (2) the reduced shift, as actually fed to create_lattice
    shifts = [eliminate_N2(qr((y*z)**jj * w**s * f**ii * M**(m-ii)
                              * N1**max(t-ii,0) * N2i**min(ii+jj, s)).lift(), modular)
              for ii in range(m+1) for jj in range(m-ii+1)]
    bad2 = sum(1 for g in shifts if g(x0, y0, z0, w0) % modular != 0)
    if bad2 > 0:
        return ("REDUCED_CONGRUENCE_VIOLATED_%d" % bad2, None)

    L, monos = create_lattice(pr, shifts, [X, Y, Z, W])
    Lr = reduce_lattice(L, 0.8)
    polys = reconstruct_polynomials(Lr, f, modular, monos, [X, Y, Z, W])
    nz = sum(1 for p in polys if p(x0, y0, z0, w0) == 0)

    rec = None
    if do_gb:
        pl = list(polys); pl.insert(0, z*w - N2)
        Sq = Sequence(pl, pr.change_ring(QQ, order='lex'))
        G = None
        while len(Sq) > 0:
            G = Sq.groebner_basis()
            if len(G) == pr.ngens(): break
            Sq.pop()
        if G is not None and len(G) == pr.ngens():
            for fac_ir, mult in G[1].gcd(G[2]).factor():
                if set(fac_ir.variables()) == {y, w}:
                    a = 0
                    for mo in fac_ir.monomials():
                        if [int(e) for e in mo.exponents()[0]] == [0,1,0,0]:
                            a = fac_ir.monomial_coefficient(mo)
                    if a != 0 and N2 % a == 0 and 1 < a < N2:
                        cand = N2 // a
                        rec = dict(a=int(a), cand=int(cand),
                                   mulback=(int(a)*int(cand) == int(N2)),
                                   is_true=(int(a) in (int(p2t), int(q2t))),
                                   nontrivial=(1 < a < N2))
    return ("ok", dict(nz=nz, npolys=len(polys), rec=rec, logmod=float(modular.nbits())))

print("=== alpha=0.15, gamma=0.6617: congruence validity + ground-truth factor check ===")
print("%-3s %-3s %-3s | %-28s %-12s %s" % ("m","t","s","status","nz/npolys","recovered a"))
for (m, t, s) in [(4,2,0),(4,3,0),(4,4,0),(4,5,0),(5,3,0),(6,3,0),(7,4,0),(8,4,0)]:
    for k in range(2):
        seed = 60600000 + 15485863*k + m*1009 + t*101
        st, info = full_check(n, alpha, gamma, b1, b2, m, seed, t, s)
        if info is None:
            print("%-3d %-3d %-3d | %-28s" % (m, t, s, st)); continue
        r = info["rec"]
        rs = "-" if r is None else ("a=%s mulback=%s true=%s" % (r["a"], r["mulback"], r["is_true"]))
        print("%-3d %-3d %-3d | %-28s %-12s %s" % (m, t, s, "ok", "%d/%d" % (info["nz"], info["npolys"]), rs))