# Instrumented GIFP: measure WHY the attack dies, not just whether it does.
#
# For each (alpha, gamma, m) we record the things a Coppersmith-style small-root
# argument actually depends on:
#   (R) is the true solution inside the declared bounds X,Y,Z,W?
#   (A) how big are the shift polynomials AT the bounds  (avg log2 row norm)
#   (B) how big is the modulus  M^m * N1^t               (log2)
#   (C) the Howgrave-Graham slack  log2( det(L)^{1/D} * rho2  /  modulus )
#       rho2 = sqrt( sum over columns of ( monomial(root)/monomial(bounds) )^2 )
#       attack can only produce p(root)=0 over Z when this is < 0.
#   (D) measured outcome: how many reconstructed polys actually vanish at root,
#       whether Groebner completes, whether a factor is recovered+verified.
#
# Self-contained and FULLY PREPARSED on purpose. Never refactor this body into
# an exec'd fragment (see FANOUT_BRIEF section 3: exec() skips the preparser and
# silently computes the wrong thing).
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),
             'gifp.sage', 'exec'), _g)
_g['__name__'] = 'wall_instrument'
import logging as _lg
_lg.getLogger().setLevel(_lg.WARNING)   # gifp.sage turns on DEBUG-to-file logging


def quantize(alpha, gamma, beta1, beta2, n):
    """Snap to the 1/n grid: the authors' generator returns None for EVERY seed
    unless n*param is an exact integer (int() truncation costs a bit and N then
    never reaches exactly n bits). Applied inside instrument() so no caller
    can forget it."""
    q = lambda v: float(ZZ(round(v*n))/n)
    return q(alpha), q(gamma), q(beta1), q(beta2)


def log2i(v):
    """log2 of an exact integer, WITHOUT the RDF overflow that makes
    log(ZZ(2^25661), 2) return +inf. nbits() is within 1 bit, which is
    negligible against a slack measured in tens of bits."""
    v = abs(ZZ(v))
    if v == 0:
        return float('-inf')
    return float(ZZ(v).nbits())


def instrument(n, alpha, gamma, beta1, beta2, m, seed, tspec="round", do_gb=True,
               t_force=None, s_force=None, mod_sem="N1"):
    """mod_sem selects the modulus used INSIDE reconstruct_polynomials:
         "N1" : M^m * N1^t   -- what gifp_alpha_sweep.sage (r110/r111) uses
         "p1" : M^m * p1^t   -- what gifp.sage:341 actually uses (N1_list[0]=p1)
    The shift-construction modulus stays M^m*N1^t in both, as in the reference.
    The shifts provably vanish mod M^m*p1^t (0/15 violations) and NOT mod
    M^m*N1^t (10/15), so the two are genuinely different objects."""
    """Returns a dict of diagnostics. Self-contained; no reliance on module state."""
    out = dict(status="?", nz=None, nrows=None, ncols=None, logrho2=None,
               logdet_geo=None, logmod=None, slackHG=None, fact=False,
               root_ok=None, margin=None, logN1=None)
    b1, b2 = min(beta1, beta2), max(beta1, beta2)
    # Snap to the 1/n grid INSIDE instrument so no caller can skip it. The
    # authors' generator returns None for EVERY seed unless n*param is an exact
    # integer (int() truncation loses a bit, N never reaches exactly n bits).
    alpha, gamma, b1, b2 = quantize(alpha, gamma, b1, b2, n)
    out["alpha"], out["gamma"], out["b1"], out["b2"] = alpha, gamma, b1, b2

    # gifp.sage's MSB4p range is randint(2^(k-1)+1, 2^k-1) with
    # k = n - alpha*n - gamma*n - beta1*n; k<=2 makes that an EMPTY range and
    # the generator RAISES ValueError instead of returning None. That is the
    # feasibility boundary, not a refutation. Guard before calling.
    # gifp.sage builds MSB4p2 with randint(2^(k2-1)+1, 2^k2-1),
    # k2 = n - alpha*n - gamma*n - beta2*n, and beta2 is the LARGER of the two,
    # so the BINDING constraint is the one with max(b1,b2). Using min() lets
    # infeasible points through and the generator then raises instead of
    # returning None.
    kmin = n - alpha*n - gamma*n - max(b1, b2)*n
    if kmin < 3:
        out["status"] = "skip_infeasible"
        return out

    try:
        gen = generate_gifp_instance(n, alpha, gamma, b1, b2, seed, max_attempts=10)
    except ValueError:
        out["status"] = "skip_infeasible"
        return out
    if gen is None:
        out["status"] = "skip_gen"
        return out
    N1_list, N2_list, share_bit, ds = gen
    p1, q1, N1 = N1_list
    p2t, q2t, N2 = N2_list
    x0, y0, z0, w0 = ds
    out["logN1"] = float(log(abs(N1), 2))

    pr = ZZ["x", "y", "z", "w"]
    x, y, z, w = pr.gens()
    f = x*z + 2**(int(b2*n)+int(gamma*n))*y*z + N2
    X = Integer(2 ** int(b2*n))
    Y = Integer(2 ** int(n - alpha*n - gamma*n - b1*n))
    Z = Integer(2 ** int(alpha*n))
    W = Integer(2 ** int(n - alpha*n))
    M = Integer(2 ** int(b2*n - b1*n))

    s_ideal = sqrt(float(alpha))*m
    t_ideal = (1 - sqrt(float(alpha)))*m
    if t_force is not None:
        t = int(t_force)
    elif tspec == "round":
        t = int(round(t_ideal))
    else:
        t = int(ceil(t_ideal))
    if s_force is not None:
        s = int(s_force)
    else:
        s = int(round(s_ideal))
    out["t"], out["s"] = t, s
    out["t_ideal"], out["s_ideal"] = float(t_ideal), float(s_ideal)
    if mod_sem == "p1":
        unknown_modular = M**m * p1**t
    else:
        unknown_modular = M**m * N1**t
    modular = M**m * N1**t          # shift modulus, unchanged from the reference
    out["logmod"] = log2i(modular)

    # ---- (R) is the true root inside the declared bounds? -------------------
    mags = [abs(ZZ(x0)), abs(ZZ(y0)), abs(ZZ(z0)), abs(ZZ(w0))]
    bnds = [X, Y, Z, W]
    out["root_ok"] = all(mm < bb for mm, bb in zip(mags, bnds))
    out["root_bits"] = [log2i(mm) for mm in mags]
    out["bound_bits"] = [log2i(bb) for bb in bnds]
    # margin in bits: how close the tightest coordinate runs to its bound.
    # < 0 would mean the root is NOT small and no lattice argument can work.
    out["margin"] = min(log2i(bb) - log2i(max(mm, 1))
                        for mm, bb in zip(mags, bnds))
    out["margin_vars"] = {v: log2i(bb) - log2i(max(mm, 1))
                          for v, mm, bb in zip("xyzw", mags, bnds)}

    # ---- gcd(N2, modular) guard: an inapplicable construction, not a refutation
    if gcd(N2, modular) != 1:
        out["status"] = "skip_noninvertible"
        return out
    N2_inverse = inverse_mod(N2, modular)

    # ---- build shifts exactly as gifp.sage:modular_gifp does ----------------
    qr = pr.quotient(z*w - N2)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii, 0) * N2_inverse**min(ii+jj, s)
            g = qr(g).lift()
            shifts.append(eliminate_N2(g, modular))

    L, monomials = create_lattice(pr, shifts, [X, Y, Z, W])
    out["nrows"] = L.nrows(); out["ncols"] = L.ncols()

    # ---- (A) average log2 row norm BEFORE reduction (the lattice scale) -----
    rn = [log2i(sum(ZZ(vv)**2 for vv in L.row(i))) for i in range(L.nrows())]
    out["avg_lograd"] = float(sum(rn)/len(rn))
    out["min_lograd"] = float(min(rn))
    out["max_lograd"] = float(max(rn))

    # ---- (C) rho2 at the true root + exact geometric-mean determinant --------
    # L has entries up to 2^~800, so L.singular_values() (numeric) overflows to
    # inf. Use the EXACT Gram determinant instead: vol(L)^2 = det(L * L^T).
    rho2sq = RDF(0)
    for mono in monomials:
        mv = mono(x0, y0, z0, w0)
        bd = mono(X, Y, Z, W)
        if bd != 0 and mv != 0:
            rho2sq += RDF(mv)/RDF(bd)
        elif mv != 0:
            rho2sq += RDF(2)^1000
    out["logrho2"] = float(log(max(float(rho2sq), 2.0), 2)/2)

    Gm = L * L.transpose()
    detG = Gm.det()
    if detG == 0:
        out["status"] = "rank0"; return out
    # geometric-mean singular value = (vol)^{1/nrows}; log2 of it:
    out["logdet_geo"] = log2i(detG)/(2*L.nrows())
    out["slackHG"] = out["logdet_geo"] + out["logrho2"] - out["logmod"]

    Lr = reduce_lattice(L, 0.8)
    polys = reconstruct_polynomials(Lr, f, unknown_modular, monomials, [X, Y, Z, W])
    out["npolys"] = len(polys)
    out["nz"] = sum(1 for pp in polys if pp(x0, y0, z0, w0) == 0)

    # ---- measured HG slack on the ACTUAL reduced rows ------------------------
    # p(root) <= ||row||_2 * rho2  (row already carries the monomial scaling)
    # Howgrave-Graham, correct sign: |p(root)| <= ||v||_2 * rho, and p(root) is
    # already 0 mod `modulus`, so p(root) == 0 over Z as soon as
    #     log2(modulus) - log2||v||_2 - log2(rho)  >  0.
    # Positive = guaranteed small root; negative = this row cannot work.
    best = None
    for i in range(Lr.nrows()):
        nr = log2i(sum(ZZ(vv)**2 for vv in Lr.row(i)))
        val = out["logmod"] - nr - out["logrho2"]
        if best is None or val > best:
            best = val
    out["slackHG_measured"] = best
    out["slackHG_det"] = out["logmod"] - out["logdet_geo"] - out["logrho2"]
    # Raw comparison: the smallest LLL vector vs the modulus the shifts vanish
    # mod. |p(root)| <= ||v||*rho and p(root) is a multiple of `modulus`, so
    # p(root)=0 over Z needs ||v||*rho < modulus. Report both terms raw so the
    # two effects (rows shrink / modulus collapses) can be told apart.
    lrs = sorted(log2i(sum(ZZ(vv)**2 for vv in Lr.row(i))) for i in range(Lr.nrows()))
    out["logminrow"] = lrs[0]; out["logmaxrow"] = lrs[-1]
    out["logrow_median"] = lrs[len(lrs)//2]

    if not do_gb:
        out["status"] = "no_gb_skipped"
        return out

    # ---- Groebner + gcd recovery (the r110/r111 path) ------------------------
    pl = list(polys)
    pl.insert(0, z*w - N2)
    S = Sequence(pl, pr.change_ring(QQ, order='lex'))
    G = None
    while len(S) > 0:
        G = S.groebner_basis()
        if len(G) == pr.ngens():
            break
        S.pop()
    if G is None or len(G) != pr.ngens():
        out["status"] = "no_gb"
        return out
    out["status"] = "gb"
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
                    out["fact"] = bool(good)
                    out["status"] = "ok" if good else "ok_WRONG"
                    return out
    out["status"] = "no_factor"
    return out