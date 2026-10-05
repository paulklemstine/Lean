import time, sys
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
n=200; a=RR(0.1); b1,b2=RR(0.1),RR(0.15); m=4
def run(gamma, seeds, tmode='round', tag=""):
    ok=0; st={}
    for s in seeds:
        B=build(n,a,gamma,b1,b2,m,s,tmode=tmode)
        if B["status"]!="ok_build":
            st[B["status"]]=st.get(B["status"],0)+1; continue
        R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        st[R["status"]]=st.get(R["status"],0)+1
        if R.get("best"): ok+=1
    print("%s g=%.2f t=%s : %d/%d   %s"%(tag,gamma,tmode,ok,len(seeds),st)); return ok

print("=== CLAIM 1: gamma=0.70 above threshold 0.27351 ===")
S1=[5000000+15485863*k for k in range(20)]
run(RR(0.7),S1)
print("=== CLAIM 2: below threshold ===")
run(RR(0.2),[3000000+104729*k for k in range(10)],"")
run(RR(0.3),[3000000+104729*k for k in range(10)])
