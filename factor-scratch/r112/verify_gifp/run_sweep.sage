import time,sys,json
LOGF=sys.argv[-2] if sys.argv[-2].endswith('.log') else None
_p=print
def print(*a,**k):
    _p(*a,**k)
    if LOGF:
        f=open(LOGF,'a'); f.write(' '.join(str(x) for x in a)+'\n'); f.close()
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
n=200; b1,b2=RR(0.1),RR(0.15)
def snap(g):  # snap gamma to the 1/n grid (brief: else generator returns None / crashes)
    return ZZ(round(float(g)*n))/n

def run(gamma,a,m,seeds,tmode='round'):
    ok=0; st={}; deg=set()
    gamma=RR(float(snap(gamma)))
    for s in seeds:
        try:
            B=build(n,a,gamma,b1,b2,m,s,tmode=tmode)
        except (ValueError,ZeroDivisionError,OverflowError) as e:
            st["skip_infeasible"]=st.get("skip_infeasible",0)+1; continue
        if B["status"]!="ok_build": st[B["status"]]=st.get(B["status"],0)+1; continue
        R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        st[R["status"]]=st.get(R["status"],0)+1
        if R.get("best"): ok+=1
        if LOGF:
            f=open(LOGF,'a'); f.write("    [seed %s -> %s ok=%d]\n"%(s,R["status"],ok)); f.close()
    return ok,len(seeds),st

MODE=sys.argv[1] if len(sys.argv)>1 else "c12"
S1=[5000000+15485863*k for k in range(20)]
S10=[3000000+104729*k for k in range(10)]
S8=[7000000+7919*k for k in range(8)]
if MODE=="c12":
    print("### CLAIM1/2 alpha=0.10 m=4 n=200")
    for g,seeds,lbl in [(RR(0.2),S10,"below"),(RR(0.3),S10,"below"),(RR(0.7),S1,"ABOVE")]:
        ok,tot,st=run(g,RR(0.1),4,seeds); print("  gamma=%.2f [%s] %d/%d %s"%(g,lbl,ok,tot,st))
elif MODE=="shape":
    print("### CLAIM3 shape: ratio gamma/[4a(1-sqrt a)]  n=200 m=4, 8 seeds")
    for A in [0.05,0.10,0.15,0.20]:
        thr=4*float(A)*(1-sqrt(float(A)))
        for rat in [1.0,1.2,1.4,1.6,1.8,2.0]:
            g=RR(float(ZZ(round(thr*rat*n))/n))
            ok,tot,st=run(g,RR(A),4,S8)
            print("  a=%.2f thr=%.5f ratio=%.1f gamma=%.5f -> %d/%d %s"%(A,thr,rat,g,ok,tot,st))
elif MODE=="alpha":
    print("### CLAIM4 alpha>=0.15 wall, n=200 m=4")
    for A in [0.15,0.20,0.25]:
        for g in [0.50,0.60,0.65,0.68]:
            if A+g+0.15>=1.0: continue
            ok,tot,st=run(g,RR(A),4,S8)
            print("  a=%.2f gamma=%.2f -> %d/%d %s"%(A,g,ok,tot,st))
elif MODE=="mround":
    print("### CLAIM5 m-resonance vs t rounding, alpha=0.10 gamma=0.50")
    for M in [2,3,4,5,6,7,8]:
        for tm in ['round','ceil']:
            ok,tot,st=run(RR(0.5),RR(0.1),M,S8,tmode=tm)
            print("  m=%d t=%-5s -> %d/%d %s"%(M,tm,ok,tot,st))
