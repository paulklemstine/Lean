# Independent verifier core. Written from gifp.sage only; does NOT import prior harness.
import time
_g = globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'

def build(n, alpha, gamma, beta1, beta2, m, seed, tmode='round', s=None, t=None):
    """Return dict with instance + lattice artefacts. tmode in {'round','ceil','fixed'}"""
    gen = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed, max_attempts=10)
    if gen is None: return {"status":"skip_gen"}
    (p1,q1,N1),(p2t,q2t,N2),share,ds = gen
    x0,y0,z0,w0 = ds
    pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
    f = x*z + 2**(int(beta2*n)+int(gamma*n))*y*z + N2
    X = Integer(2**int(beta2*n)); Y = Integer(2**int(n-alpha*n-gamma*n-beta1*n))
    Z = Integer(2**int(alpha*n));     W = Integer(2**int(n-alpha*n))
    M = Integer(2**int(beta2*n-beta1*n))
    if tmode=='ceil':
        # exact ceil of the ideal (no float truncation): floor(x)+1 unless x integral
        def ce(x):
            f = Integer(RR(x).floor())
            return f if f==RR(x) else f+1
        t = ce((1-sqrt(alpha))*m)
        if s is None: s = ce(sqrt(alpha)*m)
    elif tmode=='round':
        t = round((1-sqrt(alpha))*m); s = round(sqrt(alpha)*m) if s is None else s
    else:
        t = t; s = round(sqrt(alpha)*m) if s is None else s
    t = int(t); s = int(s)
    modular = M**m*N1**t
    try:
        N2inv = inverse_mod(N2, modular)
    except ZeroDivisionError:
        return {"status":"skip_incoprime"}
    qr = pr.quotient(z*w-N2)
    shifts=[]
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2inv**min(ii+jj,s)
            shifts.append(eliminate_N2(qr(g).lift(), modular))
    try:
        L,monoms = create_lattice(pr,shifts,[X,Y,Z,W])
        L = L.LLL(0.8)
    except Exception as e:
        return {"status":"lattice_fail:%s"%e}
    polys = reconstruct_polynomials(L, f, modular, monoms, [X,Y,Z,W])
    nz = sum(1 for pp in polys if pp(x0,y0,z0,w0)==0)
    return dict(status="ok_build", N1=N1,N2=N2,p1=p1,q1=q1,p2t=p2t,q2t=q2t,
                x0=x0,y0=y0,z0=z0,w0=w0,polys=polys,nzero=nz,npoly=len(polys),
                t=t,s=s,m=m,L=L,monoms=monoms)

def scan_gb(B, N2, p2t, q2t, n):
    """Groebner basis + EXHAUSTIVE factor scan over ALL pairs/indices (not just G[1],G[2])."""
    pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
    B = list(B); B.insert(0, z*w - N2)   # REQUIRED: the z*w-N2 constraint (authors' step)
    S = Sequence(B, pr.change_ring(QQ, order='lex'))
    tries=0; popped=0
    while len(S)>0:
        tries+=1
        G = S.groebner_basis()
        if len(G)==pr.ngens(): break
        S.pop(); popped+=1
    else:
        return dict(status="no_gb", tries=tries, popped=popped)
    hits=[]; degenerate=[]
    for i in range(len(G)):
        for j in range(i+1,len(G)):
            try: gd = G[i].gcd(G[j])
            except Exception: continue
            if gd.is_constant(): continue
            for fac,mult in gd.factor():
                vs = set(str(v) for v in fac.variables())
                # scan EVERY monomial/coefficient, not just [0,1,0,0]
                for mono in fac.monomials():
                    c = fac.monomial_coefficient(mono)
                    if c in (0,1,-1): continue
                    if N2 % c == 0:
                        cand = N2//c
                        rec = dict(pair=(i,j),vars=sorted(vs),coef=int(c),
                                   deg=fac.degree(), is_trivial=(c in (1,-1,N2,-N2)),
                                   equals_p2=(int(c)==p2t), equals_q2=(int(c)==q2t),
                                   mult=mult)
                        hits.append(rec)
                        if rec["is_trivial"]: degenerate.append(rec)
    best = None
    for h in hits:
        if h["equals_p2"] or h["equals_q2"]:
            if not h["is_trivial"]:
                if best is None: best=h
    return dict(status="gb_len%d"%len(G), G=G, hits=hits, best=best, tries=tries, popped=popped)
