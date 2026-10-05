load('instrument.sage')
# CLAIM UNDER TEST (r111 Q1 / my RESULT.md 1.1): gamma cannot help because
# gamma does not appear in log2(modulus). Verify by holding t=3,s=0 FIXED and
# sweeping gamma at alpha=0.15 -- if success is gamma-independent, the claim holds.
n=200;b1,b2=0.1,0.15
print("%-6s %-9s | %-9s %-6s" % ("alpha","gamma","verified","t,s"))
for alpha in [0.15, 0.18, 0.20]:
    for gamma in [0.40, 0.50, 0.60, 0.66]:
        if alpha+gamma+b2 >= 1-3.0/n: continue
        ok=0;tot=0
        for k in range(3):
            seed=24680000+15485863*k+int(alpha*1000)*97+int(gamma*1000)*13
            r=instrument(n,RR(alpha),RR(gamma),RR(b1),RR(b2),6,seed,t_force=3,s_force=0)
            if r["status"].startswith("skip"): continue
            tot+=1; ok+= 1 if r["fact"] else 0
        print("%-6.2f %-9.3f | %-9s t=3,s=0" % (alpha,gamma,"%d/%d"%(ok,tot) if tot else "0/0"))
    print()
