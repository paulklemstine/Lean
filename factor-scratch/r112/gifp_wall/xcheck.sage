load('instrument.sage')
# Independent-Sage cross-check (r110 established exact L.LLL(0.8) is stable
# across 10.7 and 10.9; re-confirm the headline rescue on the OTHER install).
n=200
print("%-4s %-4s %-4s | %-9s %s" % ("m","t","s","verified","statuses"))
for (m,t,s) in [(4,2,2),(4,5,0),(6,3,0),(9,3,0)]:
    ok=0;tot=0;sts=[]
    for k in range(3):
        seed=55500000+15485863*k+m*7919+t*101+s*13
        r=instrument(n,RR(0.15),RR(0.6617),RR(0.1),RR(0.15),m,seed,t_force=t,s_force=s)
        if r["status"].startswith("skip"): continue
        tot+=1; ok+= 1 if r["fact"] else 0; sts.append(r["status"])
    print("%-4d %-4d %-4d | %-9s %s" % (m,t,s,"%d/%d"%(ok,tot),",".join(sorted(set(sts)))))
