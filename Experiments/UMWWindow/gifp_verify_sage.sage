# Self-contained (preparsed) confirmation of the GIFP threshold.
# NOTE: do NOT refactor the body below into an exec()'d .sage fragment -- exec
# skips the Sage preparser and silently changes semantics (it reported 0/20 on
# a seed that recipe.sage solves). Everything here is preparsed normally.
import sys
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/gifp_run/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'


def recover_verified(n, alpha, gamma, beta1, beta2, m, seed):
    gen = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    N1_list, N2_list, share_bit, ds = gen if gen is not None else (None, None, None, None)
    if N1_list is None:
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

    g23 = G[1].gcd(G[2])
    for fac_ir, mult in g23.factor():
        if set(fac_ir.variables()) == {y, w}:
            a = 0
            for mono in fac_ir.monomials():
                if [int(e) for e in mono.exponents()[0]] == [0, 1, 0, 0]:
                    a = fac_ir.monomial_coefficient(mono)
            if a != 0 and N2 % a == 0:
                cand = N2 // a
                if 1 < a < N2:
                    genuine = (a*cand == N2) and (a in (p2t, q2t))
                    return (("ok" if genuine else "ok_WRONG"), genuine), nzero, len(polys)
    return ("no_factor", False), nzero, len(polys)


n = 200
alpha = RR(0.1)
b1, b2 = RR(0.1), RR(0.15)
m = 4
thr = 4*float(alpha)*(1-sqrt(float(alpha)))
print("threshold gamma > %.5f\n" % thr)

# (1) the authors' own documented seed, must reproduce
(s, g), nz, npoly = recover_verified(n, alpha, RR(0.7), b1, b2, m, 1791165034802635)
print("authors' example seed=1791165034802635 -> %s verified=%s (zero-polys %d/%d)" % (s, g, nz, npoly))

# (2) below threshold
for gamma in [0.20, 0.30]:
    ok = 0; T = 10
    for k in range(T):
        (s2, g2), _, _ = recover_verified(n, alpha, RR(gamma), b1, b2, m, 3000000+104729*k)
        if g2:
            ok += 1
    print("gamma=%.2f (margin %+.4f, BELOW threshold): %d/%d verified" % (gamma, gamma-thr, ok, T))

# (3) comfortably above threshold, 20 fresh seeds
ok = 0; T = 20
for k in range(T):
    (s3, g3), _, _ = recover_verified(n, alpha, RR(0.70), b1, b2, m, 5000000+15485863*k)
    if g3:
        ok += 1
print("gamma=0.70 (margin %+.4f, ABOVE threshold): %d/%d verified" % (0.70-thr, ok, T))