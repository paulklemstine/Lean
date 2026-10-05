load('instrument.sage')
n=200; b1,b2=0.1,0.15; TRIALS=2
# The raw comparison. If the wall is the MODULUS collapsing (t rounds down),
# logmod drops by a full n=200 bits at alpha=0.15 and the min row norm does not
# compensate. If it is the LATTICE getting worse, logminrow rises.
print("%-5s %-6s %-3s %-3s | %-7s %-8s %-8s %-8s %-8s | %s" % (
    "alpha","gamma","m","t","logmod","logminrow","rho","slackHG","logdet","nz verified"))
for alpha in [0.10, 0.12, 0.14, 0.15, 0.16, 0.20]:
    thr = 4*float(alpha)*(1-sqrt(float(alpha)))
    for mult in [1.8, 2.2]:
        gamma = thr*mult
        if alpha+gamma+b2>=1: continue
        for m in [4]:
            ok=0;tot=0;rows=[]
            for k in range(TRIALS):
                seed = 42420000 + 15485863*k + int(alpha*1000)*101 + int(gamma*1000)
                r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed)
                if r["status"].startswith("skip"): continue
                tot+=1; ok += 1 if r["fact"] else 0; rows.append(r)
            if not tot: continue
            r0=rows[0]
            print("%.2f   %.4f  %-3d %-3d | %-7.0f %-8.0f %-8.1f %-8.1f %-8.0f | %s %d/%d" % (
                alpha, r0["gamma"], m, r0["t"], r0["logmod"], r0["logminrow"],
                r0["logrho2"], r0["slackHG_measured"], r0["logdet_geo"],
                ",".join("%s/%s"%(x["nz"],x.get("npolys")) for x in rows), ok, tot))
    print()
