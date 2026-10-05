load('instrument.sage')
# Fill the one hole: is alpha=0.18 solvable with t=3,s=0, or is it a wall?
# nz proxy, m=6, gamma at the feasibility cap. 2 seeds/cell.
n=200;b1,b2=0.1,0.15
print("%-6s %-7s | %-12s %-12s" % ("alpha","gamma","t=3,s=0","default"))
for alpha in [0.15,0.16,0.17,0.18,0.19,0.20]:
    cap=1-alpha-0.15-3.0/n
    g=float(ZZ(int(min(cap,4*alpha*(1-sqrt(float(alpha)))*2.5)*200))/200)
    o=[]
    for (t,s) in [(3,0),(int(round((1-sqrt(RR(alpha)))*6)),int(round(sqrt(RR(alpha))*6)))]:
        acc=[]
        for sd in [999000,1111000]:
            r=instrument(n,RR(alpha),RR(g),RR(b1),RR(b2),6,sd,t_force=t,s_force=s)
            acc.append("skip" if r["status"].startswith("skip") else "%s/%s"%(r["nz"],r.get("npolys")))
        o.append(" ".join(acc))
    print("%-6.2f %-7.3f | %-12s %-12s" % (alpha,g,o[0],o[1]))
