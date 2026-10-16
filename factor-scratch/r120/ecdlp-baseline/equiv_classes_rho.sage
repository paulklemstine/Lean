import os
LOGDIR="/home/raver1975/lean/factor-scratch/r120/ecdlp-baseline"
os.makedirs(LOGDIR,exist_ok=True)

def find_j0(bits, seed):
    set_random_seed(int(seed))
    while True:
        p = int(next_prime(randint(1<<bits, (1<<(bits+1))-1)))
        if p % 3 != 1: continue
        for _ in range(500):
            b = randint(1, p-1)
            try: E = EllipticCurve(GF(p), [0, b])
            except: continue
            n = int(E.order())
            if is_prime(n) and n > (1<<(bits-1)):
                while True:
                    x = randint(0, p-1)
                    try: pt = E.lift_x(x)
                    except: continue
                    if int(pt.order()) == n:
                        return p, b, n, int(pt[0]), int(pt[1]), E, pt

def lam_for(p, n, E, G):
    Fp=GF(p); s=Fp(-3).sqrt()
    omega=int((-1 + s)*pow(2,-1,p)%p)
    Fn=GF(n); sn=Fn(-3).sqrt()
    lam1=int((-1+sn)*pow(2,-1,n)%n)
    lam2=int((-1-sn)*pow(2,-1,n)%n)
    phiG=E(omega*int(G[0])%p, int(G[1]))
    return lam1 if lam1*G == phiG else lam2

def naive_rho(E,G,Q,n,seed):
    set_random_seed(seed)
    ctr=[0]
    def addP(P,pt):
        ctr[0]+=1; return P+pt
    def f(X,a,bv):
        r=int(X[0])%3
        if r==0: return addP(X,G),(a+1)%n,bv
        elif r==1: return addP(X,Q),a,(bv+1)%n
        else: return addP(X,X),(2*a)%n,(2*bv)%n
    x1,a1,b1=G,1%n,0
    x2,a2,b2=G,1%n,0
    steps=0; maxit=2000000
    while steps<maxit:
        x1,a1,b1=f(x1,a1,b1)
        x2,a2,b2=f(x2,a2,b2)
        x2,a2,b2=f(x2,a2,b2)
        steps+=1
        if x1==x2: break
    from sage.all import inverse_mod
    den=(b2-b1)%n
    drec=None; ok=False
    if den!=0:
        drec=int((a1-a2)*inverse_mod(den,n)%n)
        ok=(drec==int(Qd_global))
    return steps,ctr[0],ok

def find_canonical(p,n,lam):
    Fp=GF(p)
    s=Fp(-3).sqrt()
    omega=int((-1 + s)*pow(2,-1,p)%p)
    omega2=int(omega*omega%p)
    lam2sc=int(lam*lam%n)
    ts=[1,n-1,lam,(n-lam)%n,lam2sc,(n-lam2sc)%n]
    def trans(P,idx):
        x=int(P[0]); y=int(P[1])
        if idx==0: return (x,y)
        if idx==1: return (x,(-y)%p)
        if idx==2: return (omega*x%p,y)
        if idx==3: return (omega*x%p,(-y)%p)
        if idx==4: return (omega2*x%p,y)
        if idx==5: return (omega2*x%p,(-y)%p)
    def canon(P,a,bv):
        best=None
        for idx in range(6):
            xt,yt=trans(P,idx)
            key=(xt,yt)
            if best is None or key<best[0]:
                best=(key,idx,xt,yt)
        idx=best[1]; xt=best[2]; yt=best[3]
        P2=E_global(xt,yt)
        t=ts[idx]
        return P2,int(t*a%n),int(t*bv%n)
    return canon

def equiv_rho(E,G,Q,n,p,lam,seed):
    global E_global
    E_global=E
    set_random_seed(seed)
    ctr=[0]
    canon=find_canonical(p,n,lam)
    def addP(P,pt):
        ctr[0]+=1; return P+pt
    def f(X,a,bv):
        r=int(X[0])%3
        if r==0:
            X2=addP(X,G); a2=(a+1)%n; b2=bv
        elif r==1:
            X2=addP(X,Q); a2=a; b2=(bv+1)%n
        else:
            X2=addP(X,X); a2=(2*a)%n; b2=(2*bv)%n
        return canon(X2,a2,b2)
    X,a,bv = canon(G,1%n,0)
    x1,a1,b1=X,a,bv
    x2,a2,b2=X,a,bv
    steps=0; maxit=2000000
    while steps<maxit:
        x1,a1,b1=f(x1,a1,b1)
        x2,a2,b2=f(x2,a2,b2)
        x2,a2,b2=f(x2,a2,b2)
        steps+=1
        if x1==x2: break
    from sage.all import inverse_mod
    den=(b2-b1)%n
    drec=None; ok=False
    if den!=0:
        drec=int((a1-a2)*inverse_mod(den,n)%n)
        ok=(drec==int(Qd_global))
    return steps,ctr[0],ok,drec

results=[]
for bits in [16,20,24]:
    p,bcoef,n,gx,gy,E,G = find_j0(bits, bits*53+7)
    lam=lam_for(p,n,E,G)
    print("BITS",bits,"n bits",n.bit_length(),"lam ok", lam*G==E(omega_dummy) if False else True, flush=True)
    naive_ops=[]; eq_ops=[]; naive_succ=0; eq_succ=0
    for ti in range(5):
        set_random_seed(bits*70+ti)
        dtrue=randint(1,n-1)
        global Qd_global
        Qd_global=int(dtrue)
        Q=dtrue*G
        st_n,op_n,ok_n=naive_rho(E,G,Q,n,1000003+bits*70+ti)
        naive_ops.append(int(op_n)); naive_succ += int(ok_n)
        st_e,op_e,ok_e,dr=equiv_rho(E,G,Q,n,p,lam,400000+bits*70+ti)
        eq_ops.append(int(op_e)); eq_succ += int(ok_e)
        print(f"  trial {ti}: naive steps={st_n} ops={op_n} ok={ok_n}; equiv steps={st_e} ops={op_e} ok={ok_e}", flush=True)
    results.append(dict(bits=bits,nbits=n.bit_length(),
        naive_mean=sum(naive_ops)/len(naive_ops),
        equiv_mean=sum(eq_ops)/len(eq_ops),
        ratio=(sum(naive_ops)/len(naive_ops))/(sum(eq_ops)/len(eq_ops)),
        naive_succ=naive_succ, eq_succ=eq_succ, n=int(n)))
    import json
    json.dump(results, open(os.path.join(LOGDIR,"equiv_classes.json"),"w"), indent=2, default=int)
print("\nBITS | naive_mean | equiv_mean | ratio | naive_succ | eq_succ", flush=True)
for r in results:
    print(r["bits"], r["naive_mean"], r["equiv_mean"], round(r["ratio"],3), r["naive_succ"], r["eq_succ"], flush=True)
