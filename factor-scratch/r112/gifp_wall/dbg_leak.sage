load('instrument.sage')
# SANITY: does the attack ever see a factor of N2? If it did, "verified" would
# be circular. The pipeline receives only N1, N2, M, the bounds and (t,s);
# p2/q2 appear ONLY in the verification comparison.
n=200; b1,b2=0.1,0.15; alpha,gamma,m,t,s=0.15,0.6617,6,3,0
aq,gq,b1q,b2q=quantize(alpha,gamma,b1,b2,n)
gen=generate_gifp_instance(n,RR(aq),RR(gq),RR(b1q),RR(b2q),55000000,max_attempts=10)
N1l,N2l,sh,ds=gen; p1,q1,N1=N1l; p2t,q2t,N2=N2l; x0,y0,z0,w0=ds
pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
f=x*z+2**(int(b2q*n)+int(gq*n))*y*z+N2
X=Integer(2**int(b2q*n)); Y=Integer(2**int(n-aq*n-gq*n-b1q*n))
Z=Integer(2**int(aq*n)); W=Integer(2**int(n-aq*n)); M=Integer(2**int(b2q*n-b1q*n))
mod=M**m*N1**t
N2i=inverse_mod(N2,mod); qr=pr.quotient(z*w-N2)
shifts=[eliminate_N2(qr((y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)).lift(),mod)
        for ii in range(m+1) for jj in range(m-ii+1)]
L,monos=create_lattice(pr,shifts,[X,Y,Z,W]); Lr=reduce_lattice(L,0.8)
polys=reconstruct_polynomials(Lr,f,mod,monos,[X,Y,Z,W])
print("Inputs the attack actually uses: N1, N2, M=2^%d, X,Y,Z,W, m,t,s" % int((b2q-b1q)*n))
print("  any shift divisible by p2 or q2?  ", any(g(x0,y0,z0,w0)==0 for g in shifts))
print("  p2 in shift coefficients?          ", any(int(ZZ(g(x0,y0,z0,w0)))%int(p2t)==0 for g in shifts))
print("  polynomials returned: %d, of which vanish at root: %d" % (
    len(polys), sum(1 for p in polys if p(x0,y0,z0,w0)==0)))
# THE decisive anti-leak test: recover the factor using ONLY (N1,N2,M,X,Y,Z,W,m,t,s)
# in a fresh computation with p2/q2 never referenced, then verify.
pl=list(polys); pl.insert(0,z*w-N2)
Sq=Sequence(pl,pr.change_ring(QQ,order='lex')); G=None
while len(Sq)>0:
    G=Sq.groebner_basis()
    if len(G)==pr.ngens(): break
    Sq.pop()
rec=None
for fi,mu in G[1].gcd(G[2]).factor():
    if set(fi.variables())=={y,w}:
        a=0
        for mo in fi.monomials():
            if [int(e) for e in mo.exponents()[0]]==[0,1,0,0]: a=fi.monomial_coefficient(mo)
        if a!=0 and N2%a==0 and 1<a<N2: rec=int(N2//a)
print()
print("recovered factor (computed without ever touching p2/q2):", rec)
print("  nontrivial:", 1<rec<N2, " divides N2:", N2%rec==0)
print("  == true p2 or q2:", rec in (int(p2t), int(q2t)))
