load('instrument.sage')
# (b) Is the true solution a SMALL root at the bound scale the construction uses?
# Compare the actual bit-lengths of |x0|,|y0|,|z0|,|w0| against X,Y,Z,W.
n=200; b1,b2=0.1,0.15
print("%-6s %-7s %-6s | %-28s | %-28s" % ("alpha","gamma","m","root bits (x,y,z,w)","bound bits (X,Y,Z,W)"))
for alpha in [0.05,0.10,0.15,0.20]:
    for gamma in [0.20,0.40,0.60,0.68]:
        if alpha+gamma+b2>=1: continue
        r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), 4, 5150000+int(alpha*1000)*13+int(gamma*1000), do_gb=False)
        if r["status"].startswith("skip"):
            print("  a=%.2f g=%.2f  %s" % (alpha,gamma,r["status"])); continue
        print("  %.2f   %.2f    4   | %s | %s  margin=%s" % (
            alpha, gamma,
            ",".join("%.1f"%v for v in r["root_bits"]),
            ",".join("%.1f"%v for v in r["bound_bits"]),
            r["margin_vars"]))
