load('instrument.sage')

# FINAL CONFIRMATION. FANOUT_BRIEF 1.1: every count must be checked against
# ground truth, and 1.3: run every count twice.
# The claim: at alpha=0.15 the reference default t=round((1-sqrt(0.15))*m)=2,
# s=round(sqrt(0.15)*m)=2 gives 0/3, but nearby (t,s) give 3/3 with the
# recovered factor EQUAL to the true p2 or q2 and multiplying back to N2.
n = 200; b1, b2 = 0.1, 0.15; alpha = 0.15; gamma = 0.6617

# Independent re-verification of the recovered factor against GROUND TRUTH,
# done outside instrument() so nothing is inherited from it.
def attack(n, alpha, gamma, b1, b2, m, seed, t, s, mod_sem="N1"):
    b1, b2 = min(b1, b2), max(b1, b2)
    alpha, gamma, b1, b2 = quantize(alpha, gamma, b1, b2, n)
    kmin = n - alpha*n - gamma*n - max(b1, b2)*n
    if kmin < 3: return ("skip_infeasible", None)
    try:
        gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1), RR(b2), seed, max_attempts=10)
    except ValueError:
        return ("skip_infeasible", None)
    if gen is None: return ("skip_gen", None)
    N1l, N2l, share, ds = gen
    p1, q1, N1 = N1l; p2t, q2t, N2 = N2l
    x0, y0, z0, w0 = ds

    pr = ZZ["x","y","z","w"]; x, y, z, w = pr.gens()
    f = x*z + 2**(int(b2*n)+int(gamma*n))*y*z + N2
    X = Integer(2**int(b2*n)); Y = Integer(2**int(n-alpha*n-gamma*n-b1*n))
    Z = Integer(2**int(alpha*n));     W = Integer(2**int(n-alpha*n))
    M = Integer(2**int(b2*n-b1*n))
    mod_shift = M**m * N1**t
    unk = M**m*p1**t if mod_sem == "p1" else mod_shift
    if gcd(N2, mod_shift) != 1: return ("skip_noninv", None)
    N2i = inverse_mod(N2, mod_shift)
    qr = pr.quotient(z*w - N2)
    shifts = [eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)
                              *N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(), mod_shift)
              for ii in range(m+1) for jj in range(m-ii+1)]
    L, monos = create_lattice(pr, shifts, [X, Y, Z, W])
    Lr = reduce_lattice(L, 0.8)
    polys = reconstruct_polynomials(Lr, f, unk, monos, [X, Y, Z, W])
    nz = sum(1 for p in polys if p(x0, y0, z0, w0) == 0)
    pl = list(polys); pl.insert(0, z*w - N2)
    Sq = Sequence(pl, pr.change_ring(QQ, order='lex'))
    G = None
    while len(Sq) > 0:
        G = Sq.groebner_basis()
        if len(G) == pr.ngens(): break
        Sq.pop()
    if G is None or len(G) != pr.ngens(): return ("no_gb", dict(nz=nz, np=len(polys)))
    for fac_ir, mult in G[1].gcd(G[2]).factor():
        if set(fac_ir.variables()) == {y, w}:
            a = 0
            for mo in fac_ir.monomials():
                if [int(e) for e in mo.exponents()[0]] == [0,1,0,0]:
                    a = fac_ir.monomial_coefficient(mo)
            if a != 0 and N2 % a == 0 and 1 < a < N2:
                c = N2 // a
                # GROUND TRUTH, checked here and nowhere else:
                good = (int(a)*int(c) == int(N2)) and (int(a) in (int(p2t), int(q2t)))
                return ("ok" if good else "WRONG",
                        dict(nz=nz, np=len(polys), a=int(a), c=int(c),
                             mulback=(int(a)*int(c) == int(N2)),
                             is_true=(int(a) in (int(p2t), int(q2t)))))
    return ("no_factor", dict(nz=nz, np=len(polys)))

def sweep(m, t, s, tag, ntrials):
    ok = tot = 0; details = []
    for k in range(ntrials):
        seed = 55000000 + 2654435761*k + m*100003 + t*1009 + s*101 + (0 if tag=="A" else 77777)
        st, info = attack(n, alpha, gamma, b1, b2, m, seed, t, s)
        if info is None: continue
        tot += 1
        if st == "ok": ok += 1
        details.append("%s(nz=%s/%s%s)" % (st, info.get("nz"), info.get("np"),
                      ",TRUE-FACTOR" if info.get("is_true") else ""))
    return ok, tot, details

import sys
CASES = eval(sys.argv[1]) if len(sys.argv)>1 else [
    (4,2,2,"reference default"), (4,5,0,"t=5,s=0")]
ALPHA = float(sys.argv[2]) if len(sys.argv)>2 else 0.15
GAMMA = float(sys.argv[3]) if len(sys.argv)>3 else 0.6617
alpha = ALPHA
gamma = GAMMA

print("=== RUN A ===")
resA = {}
for (m,t,s,lab) in CASES:
    ok, tot, d = sweep(m, t, s, "A", 3)
    resA[(m,t,s)] = (ok,tot)
    print("  m=%d t=%d s=%d  %-24s %d/%d   %s" % (m,t,s,lab,ok,tot,"; ".join(d)))
print("=== RUN B (fresh seeds) ===")
resB = {}
for (m,t,s,lab) in CASES:
    ok, tot, d = sweep(m, t, s, "B", 3)
    resB[(m,t,s)] = (ok,tot)
    print("  m=%d t=%d s=%d  %-24s %d/%d   %s" % (m,t,s,lab,ok,tot,"; ".join(d)))
print()
print("=== agreement A vs B ===")
for k in resA:
    a, b = resA[k], resB[k]
    print("  m=%d t=%d s=%d : A=%d/%d  B=%d/%d  %s" % (k[0],k[1],k[2],a[0],a[1],b[0],b[1],
          "AGREE" if a==b else "*** DISAGREE ***"))