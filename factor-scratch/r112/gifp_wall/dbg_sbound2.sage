load('instrument.sage')
# Cheap version of driver_sbound: does the DEFAULT s overshoot at large alpha,
# and does forcing s=0 rescue even when t is left at its default?
# t=round((1-sqrt(a))m), s=round(sqrt(a)m).
n=200; b1,b2=0.1,0.15
print("%-5s %-4s | %-9s %-9s %-9s %s" % ("alpha","m","t_def","s_def","t=3,s=0","verdict"))
for alpha,gamma in [(0.10,0.680),(0.15,0.6617),(0.20,0.630)]:
    for m in [4,6]:
        td=int(round((1-sqrt(RR(alpha)))*m)); sd=int(round(sqrt(RR(alpha))*m))
        a=instrument(n,RR(alpha),RR(gamma),RR(b1),RR(b2),m,55500000+15485863*m)
        b=instrument(n,RR(alpha),RR(gamma),RR(b1),RR(b2),m,55500000+15485863*m+7777,
                     t_force=3,s_force=0,do_gb=True)
        print("%-5.2f %-4d | %-9d %-9d %-9s default=%s  t3s0=%s" % (
            alpha,m,td,sd,
            "%s(%s/%s)"%(b["status"][:4],b["nz"],b.get("npolys")),
            a["status"][:4], b["status"][:4]))
