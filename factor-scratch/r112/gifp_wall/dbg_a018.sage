load('instrument.sage')
# At alpha=0.18, t=3,s=0 gives nz=27/28 vanishing polynomials but 0/3 verified.
# So the LATTICE is fine and the GROEBNER step fails. Is that a real distinction
# from alpha=0.15 (nz=27/28 AND 3/3 verified)?
n=200
for (alpha,gamma) in [(0.15,0.685),(0.17,0.660),(0.18,0.655),(0.19,0.645),(0.20,0.635)]:
    for (m,t,s) in [(6,3,0)]:
        r=instrument(n,RR(alpha),RR(gamma),RR(0.1),RR(0.15),m,999000,t_force=t,s_force=s)
        print("a=%.2f m=%d t=%d s=%d -> %-8s fact=%-5s nz=%s/%s" % (
            alpha,m,t,s,r["status"],r["fact"],r["nz"],r.get("npolys")))
