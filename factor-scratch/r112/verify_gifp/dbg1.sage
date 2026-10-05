import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
n=200; a=RR(0.1); b1,b2=RR(0.1),RR(0.15); m=4
B=build(n,a,RR(0.7),b1,b2,m,5000000)
print("build status",B["status"],"npoly",B["npoly"],"nzero-at-root",B["nzero"],"t",B["t"],"s",B["s"])
print("p2t",B["p2t"],"q2t",B["q2t"])
for i,p in enumerate(B["polys"]):
    print("  poly%d deg=%s zeroatroot=%s vars=%s"%(i,p.degree(),p(B["x0"],B["y0"],B["z0"],B["w0"])==0,sorted(str(v) for v in p.variables())))
R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
print("gb status",R["status"],"tries",R["tries"],"popped",R["popped"])
print("n hits",len(R["hits"]))
for h in R["hits"][:20]: print("   ",h)
print("best",R["best"])
G=R["G"]
print("--- G elements ---")
for i,g in enumerate(G): print(" G%d vars=%s deg=%s"%(i,sorted(str(v) for v in g.variables()),g.degree()))
print("authors-example seed check:")
B2=build(n,a,RR(0.7),b1,b2,m,1791165034802635)
R2=scan_gb(B2["polys"],B2["N2"],B2["p2t"],B2["q2t"],n)
print("  status",R2["status"],"best",R2["best"])
print("  nzero",B2["nzero"],"npoly",B2["npoly"])
for h in R2["hits"][:10]: print("   ",h)
