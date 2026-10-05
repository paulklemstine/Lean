load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
N, alpha, gamma, beta1, beta2, m = 200, 0.10, 0.70, 0.10, 0.15, 4
(p1,q1,N1),(p2,q2,N2),share,d = gen_instance(N,alpha,gamma,beta1,beta2,5000000)
x,y,z,w = ZZ["x","y","z","w"].gens()
f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
t = int(round((1-sqrt(alpha))*m)); s = int(round(sqrt(alpha)*m))
M = Integer(2**int(N*beta2-N*beta1))
umod = M**m * p1**t; modular = M**m * N1**t
pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
qr = pr.quotient(z*w - N2); N2inv = inverse_mod(N2, modular)
shifts=[]
for ii in range(m+1):
    for jj in range(m-ii+1):
        g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2inv**min(ii+jj,s)
        shifts.append(eliminate_N2(qr(g).lift(), modular))
X = Integer(2**int(beta2*N)); Y = Integer(2**int(N-N*alpha-N*gamma-N*beta1))
Z = Integer(2**int(alpha*N)); W = Integer(2**int(N-N*alpha))
L, monos = build_lattice(pr, shifts, [X,Y,Z,W])
B = L.LLL(0.8)
for MODNAME, MOD in [("umod=M^m*p1^t (original)", umod), ("modular=M^m*N1^t (vcore)", modular)]:
    polys = reconstruct(B, f, MOD, monos, [X,Y,Z,W])
    print("=== %s : npolys=%d" % (MODNAME, len(polys)))
    S = Sequence([z*w - N2] + list(polys), pr.change_ring(QQ, order='lex'))
    lens = []
    while len(S) > 0:
        G = S.groebner_basis(); lens.append(len(G))
        if len(G) == 4: break
        S.pop()
    print("   GB lengths along pop-loop:", lens[:14], "...", "final:", len(G))
    print("   len(polys all vanish at desired):", sum(1 for pp in polys if pp(*d)==0), "/", len(polys))
