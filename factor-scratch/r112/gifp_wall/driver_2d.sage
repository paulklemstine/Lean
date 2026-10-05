load('instrument.sage')

# DISENTANGLE t from s. Every success in driver_ts had s=0, because I set
# s = max(0, t-m). The authors' default is t=round((1-sqrt(a))m), s=round(sqrt(a)m),
# which always satisfies t+s=m. So "forcing t" and "forcing s=0" are
# CONFOUNDED in that run. This is a proper 2-D grid.
n = 200; b1, b2 = 0.1, 0.15; TRIALS = 3
alpha, gamma = 0.15, 0.6617

print("=== alpha=0.15 gamma=0.6617 n=200: full (t,s) grid, VERIFIED (ground-truth) ===")
print("authors' default: t=round((1-sqrt(0.15))*m)=2, s=round(sqrt(0.15)*m)=2 at m=4")
for m in [4, 5, 6]:
    print("--- m=%d   (log2 modulus = %d + %d*t ; t_default=round((1-sqrt(a))*m)=%d, s_default=round(sqrt(a)*m)=%d) ---"
          % (m, m*int((b2-b1)*n), n, int(round((1-sqrt(RR(alpha)))*m)), int(round(sqrt(RR(alpha))*m))))
    print("      s=0     s=1     s=2     s=3     s=4     s=5")
    for t in range(1, m+3):
        cells = []
        for s in range(0, 6):
            ok = 0; tot = 0
            for k in range(TRIALS):
                seed = 77000000 + 15485863*k + m*10007 + t*101 + s*7
                r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed,
                               t_force=t, s_force=s)
                if r["status"].startswith("skip"): continue
                tot += 1; ok += 1 if r["fact"] else 0
            cells.append("%d/%-2d" % (ok, tot) if tot else " --  ")
        print("  t=%d %s" % (t, " ".join(cells)))
    print()