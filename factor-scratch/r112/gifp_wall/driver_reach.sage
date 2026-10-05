load('instrument.sage')
# Does t=3,s=0 rescue alpha=0.15 ACROSS the gamma range, or only at large gamma?
# The proven bound at alpha=0.15 is gamma > 4*0.15*(1-sqrt(0.15)) = 0.3738.
# r111 only ever tested gamma >= 0.6617 (the feasibility cap). If t=3,s=0 also
# works just above the proven threshold, the rescue moves the whole curve down,
# which is a much stronger statement than "one operating point is reachable".
n=200; b1,b2=0.1,0.15; TRIALS=3
thr = 4*0.15*(1-sqrt(0.15))
print("alpha=0.15: proven gamma threshold = %.4f" % thr)
print("%-8s %-6s %-6s | %-9s %-9s %s" % ("gamma","ratio","m","default","t=3,s=0","t=4,s=0"))
for mult in [1.0, 1.1, 1.2, 1.3, 1.4, 1.6]:
    for gamma in [float(ZZ(round(thr*mult*200))/200)]:
        for m in [6]:
            res = {}
            for (t,s) in [(None,None),(3,0),(4,0)]:
                ok=0;tot=0
                for k in range(TRIALS):
                    seed=35700000+15485863*k+int(gamma*1000)*29+m*7+(0 if t is None else t)
                    kw = {} if t is None else dict(t_force=t,s_force=s)
                    r=instrument(n,RR(0.15),RR(gamma),RR(b1),RR(b2),m,seed,**kw)
                    if r["status"].startswith("skip"): continue
                    tot+=1; ok+= 1 if r["fact"] else 0
                res[(t,s)] = "%d/%d"%(ok,tot) if tot else "0/0"
            print("%-8.4f %-6.2f %-6d | %-9s %-9s %s" % (
                gamma, mult, m, res[(None,None)], res[(3,0)], res[(4,0)]))
