load('instrument.sage')

n = 200
b1, b2 = 0.1, 0.15
TRIALS = 3

# What actually discriminates? From the r110 table, the count of reconstructed
# polynomials that vanish at the true root (nz) separates working from failing
# points cleanly. Here we sweep alpha x gamma and record the full diagnostic.
print("alpha gamma | verified  nz/npolys  margin_bits(x,y,z,w)  avg_logrow  logmod  logdet  logrho")
for alpha in [0.05, 0.10, 0.15, 0.20]:
    thr = 4*float(alpha)*(1-sqrt(float(alpha)))
    for mult in [1.4, 1.6, 1.8, 2.0, 2.4]:
        gamma = thr*mult
        if alpha + gamma + b2 >= 1:
            print("  a=%.2f g=%.4f  INFEASIBLE" % (alpha, gamma)); continue
        ok = 0; tot = 0; rows = []
        for k in range(TRIALS):
            seed = 8100000 + 15485863*k + int(alpha*1000)*7919 + int(gamma*1000)*31
            r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), 4, seed)
            if r["status"].startswith("skip"):
                continue
            tot += 1
            if r["fact"]: ok += 1
            rows.append(r)
        if tot == 0:
            print("  a=%.2f g=%.4f  0/0 (all skipped)" % (alpha, gamma)); continue
        r0 = rows[0]
        print("  a=%.2f g=%.4f |  %d/%d    %s   m=%s  rowlog=%s mod=%s det=%s rho=%s" % (
            alpha, gamma, ok, tot,
            ",".join("%s/%s" % (r["nz"], r.get("npolys")) for r in rows),
            r0["margin_vars"],
            round(r0["avg_lograd"]), round(r0["logmod"]),
            round(r0["logdet_geo"]), round(r0["logrho2"])))
    print()