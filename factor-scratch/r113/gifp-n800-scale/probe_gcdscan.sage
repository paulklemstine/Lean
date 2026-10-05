load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/sweep_core.sage')
import time
# Is the bottleneck gcd_scan (factoring large-degree polynomials)?
for N in [400, 600, 800]:
    res = gen_instance(N,0.10,0.70,0.10,0.15,7000000)
    (p1,q1,N1),(p2,q2,N2),share,droot = res
    x,y,z,w = ZZ["x","y","z","w"].gens()
    f = x*z + 2**(int(0.15*N)+int(0.70*N))*y*z + N2
    X=Integer(2**int(0.15*N)); Y=Integer(2**int(N-int(N*0.10)-int(N*0.70)-int(N*0.10)))
    Z=Integer(2**int(0.10*N)); W=Integer(2**int(N-int(N*0.10)))
    M=Integer(2**int(N*0.15-N*0.10)); t=3; s=1
    umod=M**4*p1**t; modular=M**4*N1**t
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    qr=pr.quotient(z*w-N2); N2inv=inverse_mod(N2,modular)
    shifts=[]
    for ii in range(5):
        for jj in range(5-ii):
            g=(y*z)**jj*w**s*f**ii*M**(4-ii)*N1**max(t-ii,0)*N2inv**min(ii+jj,s)
            shifts.append(eliminate_N2(qr(g).lift(), modular))
    L,monos=build_lattice(pr,shifts,[X,Y,Z,W]); B=L.LLL(0.8)
    polys=reconstruct(B,f,umod,monos,[X,Y,Z,W])
    S=Sequence([z*w-N2]+list(polys), pr.change_ring(QQ, order='lex'))
    while len(S)>0:
        G=S.groebner_basis()
        if len(G)==4: break
        S.pop()
    degs=[g.total_degree() for g in G]
    t0=time.time(); cands=gcd_scan(G,N2,4); dt=time.time()-t0
    print("N=%3d GB total_degree=%s  gcd_scan=%.2fs  ncand=%d  p2_found=%s"
          % (N,degs,dt,len(cands),p2 in cands), flush=True)
