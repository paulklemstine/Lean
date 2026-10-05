load('instrument.sage')
# Is s (the w-exponent) the binding constraint at alpha=0.15?
# The shift carries w^s, and W = 2^((1-alpha)n), so s adds s*(1-alpha)*n bits
# to every shift's size while t adds t*n bits to the modulus. The balance the
# reference intends is s ~ sqrt(alpha)*m, t ~ (1-sqrt(alpha))*m.
# Prediction: at alpha=0.15 the DEFAULT s=round(sqrt(0.15)*m) is TOO LARGE
# (because sqrt(0.15)*m rounds up faster than (1-sqrt(0.15))*m), and the wall
# is really "s overshoots", not "t undershoots".
n=200; b1,b2=0.1,0.15; TRIALS=3
def cell(alpha,gamma,m,t,s):
    ok=0;tot=0;zs=[]
    for k in range(TRIALS):
        seed=60600000+15485863*k+m*7919+t*101+s*13+int(alpha*1000)*3
        r=instrument(n,RR(alpha),RR(gamma),RR(b1),RR(b2),m,seed,t_force=t,s_force=s)
        if r["status"].startswith("skip"): continue
        tot+=1; ok+= 1 if r["fact"] else 0
        zs.append("%s/%s"%(r["nz"],r.get("npolys")))
    return ok,tot,zs

for (alpha,gamma) in [(0.10,0.680),(0.15,0.6617),(0.20,0.620)]:
    print("=== alpha=%.2f gamma=%.3f : s=0 column vs default s, at t=3 ===" % (alpha,gamma))
    for m in [4,5,6,7,8]:
        sdef=int(round(sqrt(RR(alpha))*m)); tdef=int(round((1-sqrt(RR(alpha)))*m))
        a=cell(alpha,gamma,m,3,0)
        b=cell(alpha,gamma,m,tdef,sdef)
        c=cell(alpha,gamma,m,3,sdef)
        print("  m=%d default(t=%d,s=%d) | forced t=3,s=0: %d/%d | default: %d/%d | t=3,s=s_default=%d: %d/%d" % (
            m,tdef,sdef,a[0],a[1],b[0],b[1],sdef,c[0],c[1]))
    print()
