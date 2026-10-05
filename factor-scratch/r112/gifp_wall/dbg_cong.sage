load('instrument.sage')
# Validate the congruence checker at a point r110 VERIFIES: alpha=0.10, gamma=0.50,
# m=4, authors' default t=3, s=1. If the checker flags violations HERE it is
# buggy, not the construction.
n=200; b1,b2=0.1,0.15
for (alpha,gamma,m,t,s) in [(0.10,0.50,4,3,1),(0.15,0.6617,4,3,2),(0.15,0.6617,4,4,0)]:
    alpha,gamma,b1q,b2q = quantize(alpha,gamma,b1,b2,n)
    gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1q), RR(b2q), 7010500, max_attempts=10)
    if gen is None: print("skip"); continue
    N1l,N2l,share,ds = gen
    p1,q1,N1=N1l; p2t,q2t,N2=N2l; x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    f = x*z + 2**(int(b2q*n)+int(gamma*n))*y*z + N2
    M = Integer(2**int(b2q*n-b1q*n)); modular = M**m*N1**t
    N2i = inverse_mod(N2, modular)
    print("--- alpha=%s gamma=%s m=%d t=%d s=%d  log2mod=%d" % (alpha,gamma,m,t,s,modular.nbits()))
    print("    f(x0,y0,z0,w0) =", f(x0,y0,z0,w0), " (want exactly 0)")
    print("    x0+2^(b2+g)y0+w0 =", x0 + 2**(int(b2q*n)+int(gamma*n))*y0 + w0, "(want 0)")
    nbad=0; nex=0
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
            val = g(x0,y0,z0,w0)
            bad = val % modular != 0
            if bad: nbad+=1
            if val == 0: nex+=1
            if (ii,jj) in [(0,0),(1,0),(0,1),(2,0)]:
                print("      ii=%d jj=%d val=%s  mod==0:%s  exactly0:%s" % (ii,jj,val,not bad, val==0))
    print("    violations=%d  exactly-zero=%d" % (nbad,nex))
