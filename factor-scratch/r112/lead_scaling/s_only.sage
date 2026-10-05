# Decouple: does the s=ceil change (not t) explain the n=200/m=4 regression?
# At alpha=0.10,m=4: t_round==t_ceil==3, only s differs (1 vs 2).
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'
import sys
def rec(n,alpha,gamma,b1,b2,m,seed,t,s):
    gen=generate_gifp_instance(n,alpha,gamma,b1,b2,seed,max_attempts=10)
    N1l,N2l,sh,ds=gen if gen is not None else (None,)*4
    if N1l is None: return ("skip",False)
    p1,q1,N1=N1l; p2t,q2t,N2=N2l; x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
    X=Integer(2**int(b2*n)); Y=Integer(2**int(n-alpha*n-gamma*n-b1*n))
    Z=Integer(2**int(alpha*n)); W=Integer(2**int(n-alpha*n))
    M=Integer(2**int(b2*n-b1*n))
    um=M**m*N1**t
    qr=pr.quotient(z*w-N2); mod=M**m*N1**t
    if gcd(N2,mod)!=1: return ("skip",False)
    N2i=inverse_mod(N2,mod)
    shs=[]
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
            shs.append(eliminate_N2(qr(g).lift(),mod))
    L,mono=create_lattice(pr,shs,[X,Y,Z,W]); L=reduce_lattice(L,0.8)
    P=list(reconstruct_polynomials(L,f,um,mono,[X,Y,Z,W])); P.insert(0,z*w-N2)
    Sq=Sequence(P,pr.change_ring(QQ,order='lex')); G=None
    while len(Sq)>0:
        G=Sq.groebner_basis()
        if len(G)==pr.ngens(): break
        Sq.pop()
    if G is None or len(G)!=pr.ngens(): return ("no_gb",False)
    for fi,_ in G[1].gcd(G[2]).factor():
        if set(fi.variables())=={y,w}:
            a=0
            for mo in fi.monomials():
                if [int(e) for e in mo.exponents()[0]]==[0,1,0,0]: a=fi.monomial_coefficient(mo)
            if a!=0 and N2%a==0 and 1<a<N2:
                cd=N2//a; ok=(a*cd==N2) and (a in (p2t,q2t))
                return ("ok" if ok else "WRONG",ok)
    return ("no_factor",False)
def q(v,n): return RR(ZZ(round(v*n))/n)
n=200; al=q(0.10,n); g=q(0.50,n); m=4
print("n=200 alpha=0.10 m=4, gamma=0.50 -- vary s with t fixed at 3")
for s in [1,2,3]:
    ok=0;tot=0
    for k in range(4):
        st,gv=rec(n,al,g,RR(0.1),RR(0.15),m,8800000+15485863*k+200*10+s,3,s)
        if st=="skip": continue
        tot+=1; ok+= 1 if gv else 0
    print("  s=%d -> %d/%d"%(s,ok,tot))
