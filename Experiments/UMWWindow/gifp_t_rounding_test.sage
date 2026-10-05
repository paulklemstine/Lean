# Does the t-rounding really explain the m-resonance?
#
# r111 found: working m are exactly those where t = round((1-sqrt(a))*m) does not
# undershoot the ideal, i.e. t >= ceil(ideal). I flagged the converse as UNTESTED:
# that forcing t up (or picking t by the true balance instead of round()) rescues
# the failing m. This tests it directly, by overriding t and s explicitly.
#
# Self-contained and preparsed on purpose (see memory sage-exec-skips-preparser).
import sys
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/gifp_run/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def attack(n, alpha, gamma, beta1, beta2, m, seed, t_override=None, s_override=None):
    """Full pipeline with EXPLICIT control of t and s (the script derives them
    as t=round((1-sqrt(a))m), s=round(sqrt(a)m); here we can override)."""
    gen = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    N1_list, N2_list, share_bit, ds = gen if gen is not None else (None,)*4
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
    ideal_t = (1 - sqrt(alpha))*m
    ideal_s = sqrt(alpha)*m
    t = int(round(ideal_t)) if t_override is None else int(t_override)
    s = int(round(ideal_s)) if s_override is None else int(s_override)
    unknown_modular = M**m * N1**t

    qr = pr.quotient(z*w - N2)
    modular = M^m*N1^t
    if gcd(N2, modular) != 1:
        return ("skip_noninvertible", False)
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
    nz = sum(1 for pp in polys if pp(x0, y0, z0, w0) == 0)

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
        return ("no_gb(t=%d,s=%d,z=%d)" % (t, s, nz), False)
    for fac_ir, mult in G[1].gcd(G[2]).factor():
        if set(fac_ir.variables()) == {y, w}:
            a = 0
            for mono in fac_ir.monomials():
                if [int(e) for e in mono.exponents()[0]] == [0, 1, 0, 0]:
                    a = fac_ir.monomial_coefficient(mono)
            if a != 0 and N2 % a == 0 and 1 < a < N2:
                cand = N2 // a
                good = (a*cand == N2) and (a in (p2t, q2t))
                return (("ok(t=%d,s=%d,z=%d)" % (t, s, nz)) if good else "ok_WRONG", good)
    return ("no_factor(t=%d,s=%d)" % (t, s), False)


n = 200
alpha, gamma = RR(0.10), RR(0.50)
b1, b2 = RR(0.1), RR(0.15)
TRIALS = 4
print("alpha=0.10 gamma=0.50 -- does forcing t rescue the failing m?\n")
print("%-4s %-8s %-8s %-8s %-8s %-6s %-6s  %s" % ("m", "ideal_t", "t=round", "t=ceil", "t=ideal+1", "round", "ceil", "note"))
for m in [3, 4, 5, 6, 8]:
    ideal_t = (1 - sqrt(alpha))*m
    tr = int(round(ideal_t))
    tc = int(ideal_t) + 1          # smallest int >= ideal (no undershoot)
    def rate(tov, s=None):
        ok = 0; tot = 0
        for k in range(TRIALS):
            st, g = attack(n, alpha, gamma, b1, b2, m, 17000000+15485863*k+m, tov, s)
            if st.startswith("skip"):
                continue
            tot += 1
            if g:
                ok += 1
        return ok, tot
    r_ok, r_tot = rate(None)
    c_ok, c_tot = rate(tc)
    print("%-4d %-8.2f %-8d %-8d %-8s %-6s %-6s" % (
        m, ideal_t, tr, tc, "-", "%d/%d" % (r_ok, r_tot), "%d/%d" % (c_ok, c_tot)))
print("\nIf t=ceil rescues m that t=round fails, the rounding is the whole story.")