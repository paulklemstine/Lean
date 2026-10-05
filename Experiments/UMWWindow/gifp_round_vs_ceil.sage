# Independent test: does "t does not undershoot" predict success, decoupled
# from the m-resonance confound? For each (alpha,m) run BOTH t=round and t=ceil.
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



n=200; TRIALS=4
b1,b2=RR(0.1),RR(0.15)
print("%-6s %-3s %-8s %-6s %-8s %-6s %-8s"%("alpha","m","ideal_t","t=rd","r=round","t=ceil","r=ceil"))
for alpha in [0.05,0.10,0.15]:
  for m in range(3,9):
    gq = 0.50 if alpha<=0.10 else 0.60
    if not (alpha+gq+0.15)<1: continue
    ideal=(1-sqrt(RR(alpha)))*m
    tr=int(round(ideal)); tc=int(ideal)+1
    okr=totr=okc=totc=0
    for k in range(TRIALS):
        sd=19000000+15485863*k+int(alpha*100)*100+m
        st,g=attack(n,RR(alpha),RR(gq),b1,b2,m,sd,None)
        if not st.startswith("skip"):
            totr+=1; okr+= 1 if g else 0
        st,g=attack(n,RR(alpha),RR(gq),b1,b2,m,sd,tc)
        if not st.startswith("skip"):
            totc+=1; okc+= 1 if g else 0
    if totr==0 and totc==0: continue
    print("%-6.2f %-3d %-8.2f %-6d %-8s %-6d %s"%(alpha,m,ideal,tr,
        "%d/%d"%(okr,totr),tc,"%d/%d"%(okc,totc)))
