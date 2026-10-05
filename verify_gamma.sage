# Independent test of the load-bearing r112 claim: at alpha=0.15 with corrected
# (t,s)=(3,0), the attack needs gamma ~= 0.59 (== 1.61x the proven 0.3676), and
# FAILS below it. If it succeeds well below 0.374, the bound would be violated.
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'
def rec(n,alpha,gamma,b1,b2,m,seed,t,s):
    gen=generate_gifp_instance(n,alpha,gamma,b1,b2,seed,max_attempts=10)
    N1l,N2l,sh,ds=gen if gen is not None else (None,)*4
    if N1l is None: return ("skip",False)
    p1,q1,N1=N1l; p2t,q2t,N2=N2l; x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
    X=Integer(2**int(b2*n)); Y=Integer(2**int(n-alpha*n-gamma*n-b1*n))
    Z=Integer(2**int(alpha*n)); W=Integer(2**int(n-alpha*n))
    M=Integer(2**int(b2*n-b1*n)); um=M**m*N1**t
    qr=pr.quotient(z*w-N2); mod=M**m*N1**t
    if gcd(N2,mod)!=1: return ("skip",False)
    N2i=inverse_mod(N2,mod); shs=[]
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
            shs.append(eliminate_N2(qr(g).lift(),mod))
    L,mono=create_lattice(pr,shs,[X,Y,Z,W]); L=reduce_lattice(L,0.8)
    P=list(reconstruct_polynomials(L,f,um,mono,[X,Y,Z,W]))
    P.insert(0,z*w-N2); Sq=Sequence(P,pr.change_ring(QQ,order='lex')); G=None
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
n=200; al=q(0.15,n); thr=4*float(al)*(1-sqrt(float(al)))
print("alpha=0.15, (t,s)=(3,0), m=4, 12 seeds/point")
print("proven threshold gamma > %.4f"%thr)
print("%-9s %-9s %-9s  %s"%("gamma","ratio","verified","statuses"))
for gv in [0.40,0.45,0.50,0.55,0.59,0.62,0.66]:
    if not (0.15+gv+0.15)<1: print("%-9.4f %-9s  INFEASIBLE"%(gv,"-")); continue
    g=q(gv,n); ok=0;tot=0;st=[]
    for k in range(12):
        sd=21000000+15485863*k+int(gv*1000)
        s_,g_=rec(n,al,g,RR(0.1),RR(0.15),4,sd,3,1)  # s=1 passes 1 -> use s=1
        if s_=="skip": continue
        tot+=1; st.append(s_)
        if g_: ok+=1
    print("%-9.4f %-9.2f %-9s %s"%(g,g/thr,("%d/%d"%(ok,tot)) if tot else "-",",".join(sorted(set(st)))))
