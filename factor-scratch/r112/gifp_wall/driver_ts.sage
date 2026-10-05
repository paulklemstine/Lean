load('instrument.sage')

n = 200; b1, b2 = 0.1, 0.15; TRIALS = 3

# DECISIVE TEST for the "t rounds down" mechanism.
# log2(modulus) = m*(b2-b1)*n + t*n. At alpha=0.10,m=4: t=3 -> 640 bits.
# At alpha=0.15,m=4: t=round(2.45)=2 -> 440 bits, i.e. a full n=200-bit
# collapse. Force t back to 3 (and higher) at alpha=0.15 and see if it rescues.
# r111 tested t=ceil (which IS 3 at alpha=0.15,m=4) but only at gamma=0.60;
# here we go to the largest feasible gamma and over t.
print("=== alpha=0.15, gamma=0.6617: forced (t,s) grid, m=4..8 ===")
print("%-4s %-3s | %-9s %-12s %-9s %-8s" % ("m","t","s","verified","nz/npolys","status"))
for m in [4,5,6,7,8]:
    for t in [2,3,4,5,6]:
        s = max(0, t - m)  # t + s = m is the intended balance; allow variants
        ok = 0; tot = 0; zs = []; sts = []
        for k in range(TRIALS):
            seed = 31337000 + 15485863*k + t*1000 + m*17
            r = instrument(n, RR(0.15), RR(0.6617), RR(b1), RR(b2), m, seed,
                           t_force=t, s_force=s)
            if r["status"].startswith("skip"):
                sts.append(r["status"][:6]); continue
            tot += 1
            if r["fact"]: ok += 1
            zs.append("%s/%s" % (r["nz"], r.get("npolys"))); sts.append(r["status"][:4])
        if tot:
            print("%-4d %-3d | %-9s %-12s %-9s" % (
                m, t, "%d/%d" % (ok, tot), ",".join(zs), ",".join(sorted(set(sts)))))
    print()