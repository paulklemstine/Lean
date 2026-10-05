load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
# G[0..2] involve {x,y,w}; G[3]=z*w-N2. There is NO univariate element, so the
# original's find_roots_groebner (which needs len(vars)==1) can never fire.
# The original's fallback `v = int(f(x0,y0,z0))` also has a 3-vs-4 arg bug.
# CHECK: is z*w-N2 alone + the GB enough to read off p2 = w ?
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
print("desired (x0,y0,z0,w0) =", droot)
for i,g in enumerate(G):
    if g(droot) == 0: print("G[%d] vanishes at desired: YES" % i)
    else: print("G[%d] vanishes at desired: NO  (val bits %s)" % (i, Integer(abs(g(droot))).nbits() if g(droot)!=0 else 0))
print()
print("KEY: does some poly coefficient divide N2? scan all reconstructed polys'")
print("monomial coefficients c with N2 % c == 0 and c nontrivial:")
hits=set()
for pp in polys:
    for mono in pp.monomials():
        c = pp.monomial_coefficient(mono)
        if c in (0,1,-1): continue
        if N2 % c == 0 and c != N2 and c != -N2:
            hits.add(ZZ(c))
print("  candidate divisors found:", len(hits))
for c in hits:
    print("   c bits=%3d  is_true_p2=%s  is_true_q2=%s" % (c.nbits(), c==p2, c==q2))
