load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
import time
# Where does the time go at n>=600? LLL or Groebner? Coefficients are large.
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
    t0=time.time(); L,monos=build_lattice(pr,shifts,[X,Y,Z,W]); t_b=time.time()-t0
    t0=time.time(); B=L.LLL(0.8); t_l=time.time()-t0
    t0=time.time(); polys=reconstruct(B,f,umod,monos,[X,Y,Z,W]); t_r=time.time()-t0
    # bit sizes
    maxshift = 0
    for pp in shifts:
        for mono in pp.monomials():
            maxshift = max(maxshift, abs(Integer(pp.monomial_coefficient(mono))))
    t0=time.time()
    S=Sequence([z*w-N2]+list(polys), pr.change_ring(QQ, order='lex'))
    G=S.groebner_basis(); t_g=time.time()-t0
    print("N=%3d lat=%dx%d shifts_bits=%d build=%.2f LLL=%.2f recon=%.2f GB1st=%.2f len(G)=%d"
          % (N,L.nrows(),L.ncols(),Integer(maxshift).nbits(),t_b,t_l,t_r,t_g,len(G)), flush=True)
