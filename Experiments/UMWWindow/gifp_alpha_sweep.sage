# Does the EMPIRICAL threshold track 4*alpha*(1-sqrt(alpha)) across alpha?
#
# At alpha=0.1 the bound holds but is ~1.6x loose. The sharp question is whether
# the LOOSENESS is constant: if gamma_crit(alpha) / [4*alpha*(1-sqrt(alpha))]
# is roughly alpha-independent, the paper's functional form is right and only the
# constant is slack. If it drifts with alpha, the bound's alpha-dependence itself
# is wrong -- a real finding about the theorem.
#
# Self-contained and fully preparsed on purpose: exec()ing a .sage fragment skips
# the preparser and silently computes the wrong thing (see memory
# sage-exec-skips-preparser). Do not refactor the body below into an exec.
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/gifp_run/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def recover_verified(n, alpha, gamma, beta1, beta2, m, seed):
    """Returns ((status, independently_verified), n_zero_polys, n_polys).

    'independently_verified' means the recovered divisor was checked against the
    TRUE N2: nontrivial, exact, and equal to the true p2 or q2. Not merely that
    the pipeline ran.
    """
    gen = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    N1_list, N2_list, share_bit, ds = gen if gen is not None else (None,)*4
    if N1_list is None:
        return ("skip_gen", False), 0, 0          # unseedable: SKIP, not a failure
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
    # N2^{-1} mod `modular` exists iff gcd(N2, modular)=1. It can fail at some
    # parameter points; that is an inapplicable construction, NOT a refutation.
    if gcd(N2, modular) != 1:
        return ("skip_noninvertible", False), 0, 0
    N2_inverse = inverse_mod(N2, modular)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii, 0) * N2_inverse**min(ii+jj, s)
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

    for fac_ir, mult in G[1].gcd(G[2]).factor():
        if set(fac_ir.variables()) == {y, w}:
            a = 0
            for mono in fac_ir.monomials():
                if [int(e) for e in mono.exponents()[0]] == [0, 1, 0, 0]:
                    a = fac_ir.monomial_coefficient(mono)
            if a != 0 and N2 % a == 0:
                cand = N2 // a
                if 1 < a < N2:
                    good = (a*cand == N2) and (a in (p2t, q2t))
                    return (("ok" if good else "ok_WRONG"), good), nzero, len(polys)
    return ("no_factor", False), nzero, len(polys)


def quantize(alpha, gamma, beta1, beta2, n):
    """The authors' generator needs EVERY bit budget to land on an exact
    integer, else int() truncation costs a bit and N never reaches exactly n
    bits (generate_gifp_instance then returns None for every seed).
    Returns (alpha_q, gamma_q, beta1_q, beta2_q) snapped to the 1/n grid."""
    q = lambda v: float(ZZ(round(v*n))/n)
    return q(alpha), q(gamma), q(beta1), q(beta2)


def feasible(alpha, gamma, beta1, beta2):
    """A GIFP instance needs alpha+gamma+beta < 1 for the bit budget to close."""
    return (alpha + gamma + max(beta1, beta2)) < 1


n = 200
b1, b2 = RR(0.1), RR(0.15)
m = 4
TRIALS = 8
MULTS = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0]

print("n=%d  beta1=%s beta2=%s  m=%d  trials/point=%d" % (n, b1, b2, m, TRIALS))
print("ratio = gamma / [4*alpha*(1-sqrt(alpha))]  -- the proven threshold\n")

alphas = [0.05, 0.10, 0.15, 0.20]
summary = {}
for alpha in alphas:
    thr = 4*float(alpha)*(1-sqrt(float(alpha)))
    print("=== alpha = %.2f   proven threshold gamma > %.5f ===" % (alpha, thr))
    print("  %-7s %-9s %-9s %-8s  %s" % ("ratio", "gamma", "verified", "zero-poly", "statuses"))
    for mult in MULTS:
        gamma = thr*mult
        aq, gq, b1q, b2q = quantize(alpha, gamma, b1, b2, n)
        if not feasible(alpha, gamma, b1, b2):
            print("  %-7.1f %-9s %-9s %-8s  INFEASIBLE (alpha+gamma+beta >= 1)"
                  % (mult, "%.4f" % gamma, "-", "-"))
            continue
        ok = 0; tot = 0; st = []; zp = []
        for k in range(TRIALS):
            seed = 7000000 + 15485863*k + int(aq*1000)*100 + int(gq*1000)
            (s, g), nz, npoly = recover_verified(n, RR(aq), RR(gq), RR(b1q), RR(b2q), m, seed)
            if s in ("skip_gen", "skip_noninvertible"):
                continue
            tot += 1
            st.append(s)
            zp.append("%d/%d" % (nz, npoly))
            if g:
                ok += 1
        summary[(alpha, mult)] = (ok, tot)
        print("  %-7.1f %-9s %-9s %-8s  %s" % (
            mult, "%.4f" % gq, "%d/%d" % (ok, tot),
            ",".join(sorted(set(zp))[:2]), ",".join(sorted(set(st)))))
    print()

print("VERIFIED RATE TABLE (rows=alpha, cols=ratio to proven threshold)")
print("  %-8s %s" % ("alpha", "  ".join("%5.1fx" % mu for mu in MULTS)))
for alpha in alphas:
    cells = []
    for mult in MULTS:
        if (alpha, mult) in summary:
            ok, tot = summary[(alpha, mult)]
            cells.append("%2d/%-2d" % (ok, tot) if tot else "  -  ")
        else:
            cells.append("  --  ")
    print("  %-8.2f %s" % (alpha, "  ".join(cells)))