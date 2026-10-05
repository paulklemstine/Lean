load('instrument.sage')
# DIRECT MECHANISM CHECK, no Groebner.
# At the true root, evaluate each shift g and record log2|g(root)| and
# log2|g(root) mod modulus|. Two facts decide the attack:
#   (i)  the shifts must vanish mod the modulus  (legitimacy)
#   (ii) the smallest lattice vector, scaled, must evaluate below the modulus
# Measure both, per (t,s), at alpha=0.15, and see which one flips.
n=200;b1,b2=0.1,0.15;alpha,gamma=0.15,0.6617;m=4
alpha,gamma,b1,b2=quantize(alpha,gamma,b1,b2,n)
gen=generate_gifp_instance(n,RR(alpha),RR(gamma),RR(b1),RR(b2),66000000,max_attempts=10)
N1l,N2l,sh,ds=gen;p1,q1,N1=N1l;p2,q2,N2=N2l;x0,y0,z0,w0=ds
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
X=Integer(2**int(b2*n));Y=Integer(2**int(n-alpha*n-gamma*n-b1*n))
Z=Integer(2**int(alpha*n));W=Integer(2**int(n-alpha*n))
M=Integer(2**int(b2*n-b1*n))
print("%-3s %-3s | %-9s %-9s %-9s %-9s %-9s" % ("t","s","log2mod","log2|shift|","min|shift|","log2mod_p1","vanish@root"))
for (t,s) in [(2,2),(2,0),(3,2),(3,0),(4,0),(5,0)]:
    mod=M**m*N1**t; modp1=M**m*p1**t
    if gcd(N2,mod)!=1: print(t,s,"skip"); continue
    N2i=inverse_mod(N2,mod); qr=pr.quotient(z*w-N2)
    shifts=[]; vals=[]; van=0; vanp=0
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(),mod)
            shifts.append(g)
            v=abs(g(x0,y0,z0,w0)); vals.append(ZZ(v).nbits() if v else 0)
            if v % mod == 0: van+=1
            if v % modp1 == 0: vanp+=1
    L,monos=create_lattice(pr,shifts,[X,Y,Z,W])
    Lr=reduce_lattice(L,0.8)
    lrmin=min(ZZ(sum(vv^2 for vv in Lr.row(i))).nbits() for i in range(Lr.nrows()))
    print("%-3d %-3d | %-9d %-9d %-9d %-9d %d/%d,%d/%d" % (
        t,s,ZZ(mod).nbits(),max(vals),min(vals),ZZ(modp1).nbits(),
        van,len(shifts),vanp,len(shifts)))
    print("     log2 min LLL row norm = %d ; root-vs-bound ratio check:" % (lrmin))
