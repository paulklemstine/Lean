load('instrument.sage')
# The PAPER-RELEVANT question: how low can gamma go at alpha=0.15 with the
# right (t,s)? Proven bound is gamma > 4a(1-sqrt(a)) = 0.3738.
# nz is the cheap decisive proxy (nz=0 => nothing vanishes => no recovery).
# 2 seeds/cell, t=3,s=0, m=6.
n=200; b1,b2=0.1,0.15; m,t,s=6,3,0
thr=4*0.15*(1-sqrt(0.15))
print("alpha=0.15, m=6, t=3, s=0.  proven threshold gamma > %.4f"%thr)
print("%-8s %-7s | %-14s" % ("gamma","ratio","nz (2 seeds)"))
for mult in [1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.77]:
    gamma=float(ZZ(round(thr*mult*200))/200)
    if 0.15+gamma+0.15 >= 1-3.0/n: continue
    out=[]
    for sd in [777000,888000]:
        r=instrument(n,RR(0.15),RR(gamma),RR(b1),RR(b2),m,sd,t_force=t,s_force=s)
        if r["status"].startswith("skip"): out.append("skip"); continue
        out.append("%s/%s"%(r["nz"],r.get("npolys")))
    print("%-8.4f %-7.2f | %s" % (gamma,mult," ".join(out)))
