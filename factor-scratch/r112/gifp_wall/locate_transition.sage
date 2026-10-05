# Locate the alpha transition where the lattice stops producing vanishing
# polynomials. Bracketed to (0.15, 0.17]; this narrows it. Uses (t,s)=(3,0),
# m=4, gamma kept feasible, and MULTIPLE SEEDS per cell because nz near the
# transition is a rate, not a 0/1 (the r112 seed lesson).
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'
def nz_of(n,alpha,gamma,b1,b2,m,seed,t,s):
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
    return (sum(1 for pp in P if pp(x0,y0,z0,w0)==0), len(P))
def q(v,n): return RR(ZZ(round(v*n))/n)
n=200; b1,b2=RR(0.1),RR(0.15); m=4
T=8
print("Locating the alpha transition (nz = vanishing polys). (t,s)=(3,0), m=4, %d seeds/cell"%T)
print("%-7s %-7s %-14s %-10s %s"%("alpha","gamma","mean nz","cells nz>0","note"))
for av in [0.15,0.155,0.16,0.165,0.17,0.18]:
    al=q(av,n); thr=4*float(al)*(1-sqrt(float(al)))
    cap=1-av-0.15-0.02
    gv=q(min(max(thr*1.9,0.66),cap),n)
    if not (av+float(gv)+0.15)<1:
        print("%-7.3f %-7s INFEASIBLE"%(av,"-")); continue
    vals=[]; live=0; tot=0
    for k in range(T):
        r=nz_of(n,al,gv,b1,b2,m,41000000+15485863*k+int(av*10000),3,1)
        if r is None: continue
        tot+=1; vals.append(r[0])
        if r[0]>0: live+=1
    if tot==0: print("%-7.3f %-7.3f all skipped"%(av,float(gv))); continue
    mn=sum(vals)/float(len(vals))
    print("%-7.3f %-7.3f %-14.2f %-10s %s"%(av,float(gv),mn,"%d/%d"%(live,tot),
        "healthy" if live==tot else ("DEAD" if live==0 else "MARGINAL")))
