load('instrument.sage')
# Why does alpha=0.20 fail even at t=3, s=0 while alpha=0.15 works?
# Hypothesis: the modulus bits are m*(b2-b1)*n + t*n, but the ROOT ALSO SHRINKS.
# y0 has (1-alpha-gamma-beta1)*n bits and W = 2^((1-alpha)n). As alpha grows,
# both the modulus AND the lattice's target shrink, but the ratio that decides
# the attack is:
#     the shift's leading size  vs  the modulus.
# Measure, at s=0, t fixed: log2 of the biggest shift vs log2 modulus.
n=200;b1,b2=0.1,0.15;m=6
print("%-5s %-6s %-3s | %-9s %-9s %-9s | %s" % ("alpha","gamma","t","log2mod","max|shift|","min|shift|","ratio max/mod"))
for alpha,gamma in [(0.10,0.680),(0.15,0.6617),(0.18,0.650),(0.20,0.630)]:
    aq,gq,b1q,b2q=quantize(alpha,gamma,b1,b2,n)
    gen=generate_gifp_instance(n,RR(aq),RR(gq),RR(b1q),RR(b2q),66000000,max_attempts=10)
    if gen is None: print(alpha,"skip"); continue
    N1l,N2l,sh,ds=gen;p1,q1,N1=N1l;p2,q2,N2=N2l;x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
    f=x*z+2**(int(b2q*n)+int(gq*n))*y*z+N2
    X=Integer(2**int(b2q*n));Y=Integer(2**int(n-aq*n-gq*n-b1q*n))
    Z=Integer(2**int(aq*n));W=Integer(2**int(n-aq*n))
    M=Integer(2**int(b2q*n-b1q*n))
    for t in [3]:
        s=0; mod=M**m*N1**t
        if gcd(N2,mod)!=1: continue
        N2i=inverse_mod(N2,mod);qr=pr.quotient(z*w-N2)
        vals=[]
        for ii in range(m+1):
            for jj in range(m-ii+1):
                g=eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(),mod)
                v=abs(g(x0,y0,z0,w0)); vals.append(ZZ(v).nbits() if v else 0)
        lm=ZZ(mod).nbits()
        print("%.2f   %.3f  %-3d | %-9d %-9d %-9d | %.3f" % (alpha,gamma,t,lm,max(vals),min(vals),max(vals)/lm))
