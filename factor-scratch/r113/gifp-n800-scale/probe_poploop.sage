load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/sweep_core.sage')
import time
# The pop-loop recomputes a GB per pop. How many pops, and how long each?
for N in [400, 600, 800]:
    alpha,gamma,b1,b2,m = 0.10,0.70,0.10,0.15,4
    res = gen_instance(N,alpha,gamma,b1,b2,7000000)
    (p1,q1,N1),(p2,q2,N2),share,droot = res
    x,y,z,w = ZZ["x","y","z","w"].gens()
    f = x*z + 2**(int(b2*N)+int(gamma*N))*y*z + N2
    X=Integer(2**int(b2*N)); Y=Integer(2**int(N-N*alpha-N*gamma-N*b1))
    Z=Integer(2**int(alpha*N)); W=Integer(2**int(N-N*alpha))
    M=Integer(2**int(N*b2-N*b1)); t=int(round((1-sqrt(alpha))*m)); s=int(round(sqrt(alpha)*m))
    umod=M**m*p1**t; modular=M**m*N1**t
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    qr=pr.quotient(z*w-N2); N2inv=inverse_mod(N2,modular)
    shifts=[]
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2inv**min(ii+jj,s)
            shifts.append(eliminate_N2(qr(g).lift(), modular))
    L,monos=build_lattice(pr,shifts,[X,Y,Z,W]); B=L.LLL(0.8)
    polys=reconstruct(B,f,umod,monos,[X,Y,Z,W])
    S=Sequence([z*w-N2]+list(polys), pr.change_ring(QQ, order='lex'))
    pops=0; times=[]
    while len(S)>0:
        t0=time.time(); G=S.groebner_basis(); times.append(time.time()-t0)
        if len(G)==4: break
        S.pop(); pops+=1
    print("N=%3d npolys=%2d pops=%2d  GB times: %s  TOTAL=%.1fs len(G)=%d"
          % (N,len(polys),pops,[round(v,2) for v in times],sum(times),len(G)), flush=True)
