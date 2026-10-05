load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
N, alpha, gamma, beta1, beta2, m = 200, 0.10, 0.70, 0.10, 0.15, 4
seed = 5000000
r = gen_instance(N, alpha, gamma, beta1, beta2, seed)
(p1,q1,N1),(p2,q2,N2),share,desired = r
print("nbits N1,N2:", N1.nbits(), N2.nbits(), " q2 bits:", q2.nbits(), " p2 bits:", p2.nbits())
x,y,z,w = ZZ["x","y","z","w"].gens()
f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
t = int(round((1-sqrt(alpha))*m)); s = int(round(sqrt(alpha)*m))
print("t =",t," s =",s)
M = Integer(2**int(N*beta2-N*beta1)); print("M =", M)
umod = M**m * p1**t; modular = M**m * N1**t
print("f(desired) mod umod == 0 ?", f(desired) % umod == 0)
print("umod bits:", umod.nbits())
pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
qr = pr.quotient(z*w - N2); N2inv = inverse_mod(N2, modular)
shifts=[]
for ii in range(m+1):
    for jj in range(m-ii+1):
        g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2inv**min(ii+jj,s)
        shifts.append(eliminate_N2(qr(g).lift(), modular))
print("n shifts:", len(shifts))
print("each shift vanishes at desired mod umod?",
      [ (g(*desired) % umod == 0) for g in shifts ])
X = Integer(2**int(beta2*N)); Y = Integer(2**int(N-N*alpha-N*gamma-N*beta1))
Z = Integer(2**int(alpha*N)); W = Integer(2**int(N-N*alpha))
print("bounds bits X,Y,Z,W:", X.nbits(), Y.nbits(), Z.nbits(), W.nbits())
print("desired root bits x0,y0,z0,w0:", [Integer(desired[i]).nbits() for i in range(4)])
print("bounds ok (root<bnd):", [desired[i] < [X,Y,Z,W][i] for i in range(4)])
L, monos = build_lattice(pr, shifts, [X,Y,Z,W])
B = L.LLL(0.8)
polys = reconstruct(B, f, umod, monos, [X,Y,Z,W])
print("npolys:", len(polys), " (seq with z*w-N2 =", len(polys)+1, ")")
print("polys vanish at desired over Z?", [ (g(*desired) == 0) for g in polys ])
sq = Sequence([z*w-N2] + list(polys), pr.change_ring(QQ, order='lex'))
G = sq.groebner_basis()
print("GB length:", len(G))
