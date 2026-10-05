load('instrument.sage')
# FAST boundary probe: single seed per cell, no Grobner timeouts.
# nz==0 is a lattice-level failure and is decisive on its own (nothing can
# vanish), so nz is a valid cheap proxy for the no_gb cells.
n=200; b1,b2=0.1,0.15
def nz_of(alpha,gamma,b1,b2,n,m,t,s,seed):
    b1,b2=min(b1,b2),max(b1,b2)
    aq,gq,b1q,b2q=quantize(alpha,gamma,b1,b2,n)
    if n-aq*n-gq*n-max(b1q,b2q)*n < 3: return None
    try: gen=generate_gifp_instance(n,RR(aq),RR(gq),RR(b1q),RR(b2q),seed,max_attempts=10)
    except ValueError: return None
    if gen is None: return None
    N1l,N2l,sh,ds=gen; p1,q1,N1=N1l; p2,q2,N2=N2l; x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    f=x*z+2**(int(b2q*n)+int(gq*n))*y*z+N2
    X=Integer(2**int(b2q*n));Y=Integer(2**int(n-aq*n-gq*n-b1q*n))
    Z=Integer(2**int(aq*n));W=Integer(2**int(n-aq*n));M=Integer(2**int(b2q*n-b1q*n))
    mod=M**m*N1**t
    if gcd(N2,mod)!=1: return None
    N2i=inverse_mod(N2,mod); qr=pr.quotient(z*w-N2)
    sh=[eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(),mod)
        for ii in range(m+1) for jj in range(m-ii+1)]
    L,mo=create_lattice(pr,sh,[X,Y,Z,W]); Lr=reduce_lattice(L,0.8)
    po=reconstruct_polynomials(Lr,f,mod,mo,[X,Y,Z,W])
    return (sum(1 for p in po if p(x0,y0,z0,w0)==0), len(po))

print("=== beta2 / n dependence of the alpha=0.15 rescue, via nz (cheap proxy) ===")
print("%-5s %-5s %-5s %-4s | %-9s %-8s %s" % ("a","b1","b2","n","log2mod","t=3,s=0","t=default,s=default"))
for (alpha,bb1,bb2,nn) in [(0.15,0.10,0.15,200),(0.15,0.05,0.20,200),(0.15,0.02,0.30,200),
                          (0.15,0.10,0.15,400),(0.15,0.10,0.15,600),
                          (0.20,0.10,0.15,200),(0.20,0.05,0.30,200),(0.20,0.10,0.15,600)]:
    cap=1-alpha-max(bb1,bb2)-6.0/nn
    g=float(ZZ(int(min(cap,4*alpha*(1-sqrt(float(alpha)))*2.5)*nn))/nn)
    m=6; t=3; s=0
    lm = m*int((max(bb1,bb2)-min(bb1,bb2))*nn)+t*nn
    r1=r2=None
    for sd in [11100000,22200000]:
        if r1 is None: r1=nz_of(alpha,g,bb1,bb2,nn,m,t,s,sd)
        if r2 is None: r2=nz_of(alpha,g,bb1,bb2,nn,m,int(round((1-sqrt(RR(alpha)))*m)),int(round(sqrt(RR(alpha))*m)),sd)
    print("%-5.2f %-5.2f %-5.2f %-4d | %-9d %-8s default=%s" % (
        alpha,bb1,bb2,nn,lm, ("%d/%d"%r1 if r1 else "-"), ("%d/%d"%r2 if r2 else "-")))
