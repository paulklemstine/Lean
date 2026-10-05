load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
# Does the GB contain p2 in some pairwise gcd's factorization? (r112's scan_gb idea,
# reimplemented here from scratch.) If yes the mechanism works and the ORIGINAL's
# extraction is simply broken; if no, the lattice does not carry the factor.
N, alpha, gamma, beta1, beta2, m = 200, 0.10, 0.70, 0.10, 0.15, 4
(p1,q1,N1),(p2,q2,N2),share,droot = gen_instance(N,alpha,gamma,beta1,beta2,5000000)
x,y,z,w = ZZ["x","y","z","w"].gens()
f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
t = int(round((1-sqrt(alpha))*m)); s = int(round(sqrt(alpha)*m))
M = Integer(2**int(N*beta2-N*beta1)); umod = M**m*p1**t; modular = M**m*N1**t
pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
qr = pr.quotient(z*w-N2); N2inv = inverse_mod(N2, modular)
shifts=[]
for ii in range(m+1):
    for jj in range(m-ii+1):
        g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2inv**min(ii+jj,s)
        shifts.append(eliminate_N2(qr(g).lift(), modular))
X=Integer(2**int(beta2*N)); Y=Integer(2**int(N-N*alpha-N*gamma-N*beta1))
Z=Integer(2**int(alpha*N)); W=Integer(2**int(N-N*alpha))
L,monos = build_lattice(pr, shifts, [X,Y,Z,W]); B=L.LLL(0.8)
polys = reconstruct(B, f, umod, monos, [X,Y,Z,W])
S = Sequence([z*w-N2]+list(polys), pr.change_ring(QQ, order='lex'))
while len(S)>0:
    G=S.groebner_basis()
    if len(G)==4: break
    S.pop()
print("GB len", len(G))
found=set()
for i in range(len(G)):
    for j in range(i+1,len(G)):
        try: gd = G[i].gcd(G[j])
        except Exception: continue
        if gd.is_constant(): continue
        for fac,mult in gd.factor():
            for mono in fac.monomials():
                c = fac.monomial_coefficient(mono)
                if c in (0,1,-1): continue
                if N2 % c == 0 and c != N2 and c != -N2: found.add(ZZ(c))
print("gcd-scan candidate divisors:", len(found))
for c in sorted(found, key=lambda v:-v.nbits())[:6]:
    print("  bits=%3d is_p2=%s is_q2=%s" % (c.nbits(), c==p2, c==q2))
# ALSO: scan the ORIGINAL reconstructed polys AND the shifts for p2
hits2=set()
for coll in (polys, shifts):
    for pp in coll:
        for mono in pp.monomials():
            c = pp.monomial_coefficient(mono)
            if c in (0,1,-1): continue
            if N2 % c == 0 and c != N2 and c != -N2: hits2.add(ZZ(c))
print("poly/shift coefficient scan:", len(hits2), [ (c==p2, c==q2) for c in hits2])
