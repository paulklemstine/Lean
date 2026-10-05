load('instrument.sage')

# ITEM 2: is the alpha>=0.15 wall an artefact of the PARAMETERIZATION
# (beta1=0.1, beta2=0.15, n=200) or fundamental?
# Two knobs matter analytically:
#   log2(modulus) = m*(beta2-beta1)*n + t*n   <- bigger (beta2-beta1) HELPS
#   X = 2^(beta2*n) is the bound on x0         <- bigger beta2 HURTS (root is bigger)
#   feasibility: alpha + gamma + beta2 < 1     <- bigger beta2 HURTS
# So beta2 is a genuine trade-off, not a monotone knob; sweep it properly.
TRIALS = 3

def run(alpha, gamma, b1, b2, n, m, seeds):
    ok = 0; tot = 0; rows = []
    for seed in seeds:
        r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed)
        if r["status"].startswith("skip"):
            continue
        tot += 1
        if r["fact"]: ok += 1
        rows.append(r)
    return ok, tot, rows

def seeds_for(tag, k):
    h = abs(hash(tag)) % 100000
    return [h*7919 + 15485863*i for i in range(k)]

print("=== (1) beta2 sweep at alpha=0.15, gamma at max feasible, m=4, n=200 ===")
print("%-6s %-6s %-6s | %-7s %-8s %-7s %-9s" % ("b1","b2","gamma","verified","logmod","t","nz/npolys"))
for (b1, b2) in [(0.05,0.10), (0.05,0.15), (0.05,0.20), (0.10,0.15), (0.02,0.20), (0.02,0.30), (0.15,0.25)]:
    for mult in [2.0, 3.0, 5.0]:
        gamma = 4*0.15*(1-sqrt(0.15))*mult
        if 0.15 + gamma + max(b1,b2) >= 1: continue
        ok, tot, rows = run(0.15, gamma, b1, b2, 200, 4,
                            seeds_for("b%s_%s_%s" % (b1,b2,mult), TRIALS))
        if not tot:
            print("%-6.2f %-6.2f %-6.3f | 0/0" % (b1, b2, gamma)); continue
        r0 = rows[0]
        print("%-6.2f %-6.2f %-6.3f | %-7s %-8.0f %-7d %-9s" % (
            b1, b2, r0["gamma"], "%d/%d" % (ok, tot), r0["logmod"], r0["t"],
            ",".join("%s/%s" % (x["nz"], x.get("npolys")) for x in rows)))

print()
print("=== (2) n sweep at alpha=0.15 (larger n -> fewer integer-rounding artefacts) ===")
print("%-5s %-6s | %-7s %-8s %-7s %-9s" % ("n","gamma","verified","logmod","t","nz/npolys"))
for n in [200, 300, 400, 600]:
    for gamma in [0.45, 0.55, 0.60, 0.65, 0.68]:
        if 0.15 + gamma + 0.15 >= 1: continue
        ok, tot, rows = run(0.15, gamma, 0.1, 0.15, n, 4,
                            seeds_for("n%s_%s" % (n, gamma), TRIALS))
        if not tot:
            print("%-5d %-6.2f | 0/0" % (n, gamma)); continue
        r0 = rows[0]
        print("%-5d %-6.2f | %-7s %-8.0f %-7d %-9s" % (
            n, r0["gamma"], "%d/%d" % (ok, tot), r0["logmod"], r0["t"],
            ",".join("%s/%s" % (x["nz"], x.get("npolys")) for x in rows)))