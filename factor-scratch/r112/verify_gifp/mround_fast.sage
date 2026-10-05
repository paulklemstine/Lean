import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/mround_fast.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15)
S=[7000000+7919*k for k in range(4)]   # 4 seeds (matches R111's 4/point)
P("CLAIM5 causal: alpha=0.10 gamma=0.50, t=round vs t=ceil, 4 seeds")
for M in [3,4,5,6,7,8]:
    for tm in ['round','ceil']:
        t0=time.time(); ok=0; st={}
        for s in S:
            try: B=build(n,a,RR(0.5),b1,b2,M,s,tmode=tm)
            except Exception: st['exc']=st.get('exc',0)+1; continue
            if B["status"]!="ok_build": st[B["status"]]=st.get(B["status"],0)+1; continue
            R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
            st[R["status"]]=st.get(R["status"],0)+1
            if R.get("best"): ok+=1
        P("  m=%d t=%-5s (t=%d) -> %d/%d %s  [%.0fs]"%(M,tm,0,ok,len(S),st,time.time()-t0))
