load('instrument.sage')
# Why does s>0 kill it? The shift carries w^s and W=2^((1-alpha)n), so s adds
# s*(1-alpha)*n bits. Meanwhile (yz)^jj with Y=2^((1-alpha-gamma-beta1)n) and
# Z=2^(alpha*n): jj contributes jj*(1-gamma-beta1)*n -- INDEPENDENT of alpha.
# But the w^s term is s*(1-alpha)*n, which SHRINKS as alpha grows. So larger
# alpha should make s CHEAPER, not dearer.
#
# The real cost of s: it multiplies by w^s and the modulus only grows as
# M^m * N1^t. The relevant balance is s*(1-alpha) vs t  -- but ALSO the lattice
# gains s extra powers of w, so the number of monomials (and hence the lattice
# dimension) jumps.
n=200;b1,b2=0.1,0.15
print("lattice dimensions (rows x cols) vs s, at alpha=0.15 m=4:")
alpha,gamma=0.15,0.6617
for s in [0,1,2,3]:
    alphaq,gammaq,b1q,b2q=quantize(alpha,gamma,b1,b2,n)
    gen=generate_gifp_instance(n,RR(alphaq),RR(gammaq),RR(b1q),RR(b2q),66000000,max_attempts=10)
    if gen is None: continue
    N1l,N2l,sh,ds=gen;p1,q1,N1=N1l;p2,q2,N2=N2l;x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
    f=x*z+2**(int(b2q*n)+int(gammaq*n))*y*z+N2
    X=Integer(2**int(b2q*n));Y=Integer(2**int(n-alphaq*n-gammaq*n-b1q*n))
    Z=Integer(2**int(alphaq*n));W=Integer(2**int(n-alphaq*n))
    M=Integer(2**int(b2q*n-b1q*n)); m,t=4,3
    mod=M**m*N1**t
    if gcd(N2,mod)!=1: continue
    N2i=inverse_mod(N2,mod);qr=pr.quotient(z*w-N2)
    shifts=[eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(),mod)
            for ii in range(m+1) for jj in range(m-ii+1)]
    L,monos=create_lattice(pr,shifts,[X,Y,Z,W])
    print("  s=%d : L = %d x %d  (#shifts=%d)  log2mod=%d" % (s,L.nrows(),L.ncols(),len(shifts),ZZ(mod).nbits()))
