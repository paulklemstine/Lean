# Why does Groebner fail at alpha~0.17-0.18 when the LATTICE is healthy?
#
# The wall agent reports: at alpha=0.17-0.18 the lattice still produces 27/28
# polynomials vanishing over Z at the true root, but find_roots_groebner never
# reaches len(G)==ngens, so no factor comes out.
#
# Two candidate explanations, both cheap to test:
#  (H1) The pop-loop STARVES the system. It starts with all N polynomials and
#       pops the LAST one whenever len(G) != ngens. If the surviving set is
#       degenerate in a specific variable, the GB can never be 4 short polys.
#       Test: does the GB reach ngens with a DIFFERENT subset (not just prefix)?
#  (H2) The GB reaches ngens but the basis is not in "triangular" form -- the
#       univariate elements needed for root extraction are absent.
#
# Note the script's own success test is len(G)==ngens; but root extraction also
# needs len(vars)==1 elements. So len(G)==4 with no univariate piece is still
# a failure to READ the answer -- the same bug class as r110.
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'

def pipeline(n,alpha,gamma,b1,b2,m,seed,t,s):
    gen=generate_gifp_instance(n,alpha,gamma,b1,b2,seed,max_attempts=10)
    N1l,N2l,sh,ds=gen if gen is not None else (None,)*4
    if N1l is None: return None
    p1,q1,N1=N1l; p2t,q2t,N2=N2l; x0,y0,z0,w0=ds
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
    X=Integer(2**int(b2*n)); Y=Integer(2**int(n-alpha*n-gamma*n-b1*n))
    Z=Integer(2**int(alpha*n)); W=Integer(2**int(n-alpha*n))
    M=Integer(2**int(b2*n-b1*n)); um=M**m*N1**t
    qr=pr.quotient(z*w-N2); mod=M**m*N1**t
    if gcd(N2,mod)!=1: return None
    N2i=inverse_mod(N2,mod); shs=[]
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
            shs.append(eliminate_N2(qr(g).lift(),mod))
    L,mono=create_lattice(pr,shs,[X,Y,Z,W]); L=reduce_lattice(L,0.8)
    P=list(reconstruct_polynomials(L,f,um,mono,[X,Y,Z,W]))
    nz=sum(1 for pp in P if pp(x0,y0,z0,w0)==0)
    return dict(N2=N2,p2t=p2t,q2t=q2t,pr=pr,x=x,y=y,z=z,w=w,P=P,nz=nz,x0=x0,y0=y0,z0=z0,w0=w0)

def analyse(tag, data):
    if data is None: print("%-22s  SKIP"%tag); return
    pr=data["pr"]; P=list(data["P"]); nz=data["nz"]
    P.insert(0, data["z"]*data["w"] - data["N2"])
    R=pr.change_ring(QQ,order='lex')
    S=Sequence(P,R)
    best=99; bestk=None
    # replicate the pop-loop, recording the GB length at each prefix length
    trace=[]
    for k in range(len(S),3,-1):
        Sq=Sequence(S[:k],R)
        G=Sq.groebner_basis()
        trace.append((k,len(G)))
        if len(G)<best: best=len(G); bestk=k
    univ_at_best=None
    if bestk is not None:
        Sq=Sequence(S[:bestk],R); G=Sq.groebner_basis()
        univ_at_best=sum(1 for g in G if len(g.variables())==1)
    print("%-22s nz=%2d/%2d  min|G| over prefixes=%d  (at k=%s)  univariate-in-G=%s"%(
        tag,nz,len(P)-1,best,bestk,univ_at_best))
    print("%-22s   len|G| trace (k,|G|): %s"%("",trace[:12]))

def q(v,n): return RR(ZZ(round(v*n))/n)
n=200; b1,b2=RR(0.1),RR(0.15); m=4
print("Groebner-closure gap: lattice healthy but no factor. (t,s)=(3,0), m=4\n")
for av in [0.10,0.15,0.17,0.18,0.20]:
    al=q(av,n); thr=4*float(al)*(1-sqrt(float(al)))
    # keep gamma FEASIBLE for this alpha: just under the budget cap
    cap = 1 - av - 0.15 - 0.02
    gv = q(min(max(thr*1.9, 0.66), cap), n)
    if not (av+gv+0.15)<1:
        print("alpha=%.2f  INFEASIBLE"%av); continue
    d=pipeline(n,al,gv,b1,b2,m,31000000+15485863*int(av*100),3,1)
    analyse("alpha=%.2f gamma=%.3f"%(av,float(gv)), d)
