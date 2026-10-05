load('instrument.sage')

# ITEM 2: is the alpha>=0.15 wall an artefact of the PARAMETERIZATION
# (beta1=0.1, beta2=0.15, n=200)?
#
# Mechanism predicts a single scalar decides everything:
#        log2(modulus) = m*(beta2-beta1)*n + t*n
# and the reference default t = round((1-sqrt(alpha))*m) steps DOWN as alpha
# grows, losing a full n bits at each step. So the question is: at alpha=0.15,
# how much log2(modulus) do we need, and can beta2/n supply it?
#   - larger (beta2-beta1)  => more bits per unit m, but costs feasibility
#   - larger n              => more bits per unit t
TRIALS = 3

def probe(alpha, b1, b2, n, m, t, s, gamma=None, tag=""):
    b1, b2 = min(b1, b2), max(b1, b2)
    if gamma is None:
        cap = 1 - alpha - b2 - 6.0/n
        g = min(cap, 4*alpha*(1-sqrt(float(alpha)))*2.5)
        gamma = float(ZZ(int(g*n))/n)
    if alpha + gamma + b2 >= 1 - 3.0/n:
        return None, None
    ok = 0; tot = 0; zs = []
    for k in range(TRIALS):
        seed = 88800000 + 15485863*k + int(alpha*1000)*911 + int(gamma*1000)*7 + m*31 + t*3
        r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed,
                       t_force=t, s_force=s)
        if r["status"].startswith("skip"): continue
        tot += 1; ok += 1 if r["fact"] else 0
        zs.append("%s/%s" % (r["nz"], r.get("npolys")))
    return (ok, tot), (gamma, zs)

print("=== (A) beta2 sweep at alpha=0.15, m=4, s=0: is the wall beta-dependent? ===")
print("%-6s %-6s %-7s %-6s | %-9s %-7s %s" % ("b1","b2","delta*n","t","verified","gamma","nz"))
for (b1, b2) in [(0.05,0.10), (0.05,0.15), (0.10,0.15), (0.05,0.20), (0.02,0.20), (0.02,0.30)]:
    for t in [2, 3, 4]:
        res, info = probe(0.15, b1, b2, 200, 4, t, 0)
        if res is None:
            print("%-6.2f %-6.2f %-7d %-6d | INFEASIBLE" % (b1, b2, int((b2-b1)*200), t)); continue
        print("%-6.2f %-6.2f %-7d %-6d | %-9s %-7.3f %s" % (
            b1, b2, int((b2-b1)*200), t, "%d/%d" % res, info[0], ",".join(info[1])))

print()
print("=== (B) n sweep at alpha=0.15, m=4, s=0, beta1=0.1 beta2=0.15 ===")
print("%-5s %-6s | %-9s %-7s %s" % ("n","t","verified","gamma","nz"))
for n in [200, 400, 600]:
    for t in [2, 3, 4]:
        res, info = probe(0.15, 0.1, 0.15, n, 4, t, 0)
        if res is None:
            print("%-5d %-6d | INFEASIBLE" % (n, t)); continue
        print("%-5d %-6d | %-9s %-7.3f %s" % (n, t, "%d/%d" % res, info[0], ",".join(info[1])))

print()
print("=== (C) the SAME total log2(modulus) at different alpha ===")
print("  If the wall is purely the modulus, matching log2(modulus) across")
print("  different alpha should match the outcome. delta*n + t*n is held ~equal.")
for (alpha, b1, b2, n, m, t, s) in [
    (0.05, 0.10, 0.15, 200, 4, 2, 0),
    (0.15, 0.10, 0.15, 200, 4, 2, 0),
    (0.20, 0.10, 0.15, 200, 4, 2, 0),
    (0.05, 0.02, 0.30, 200, 4, 2, 0),
    (0.15, 0.02, 0.30, 200, 4, 3, 0),
    (0.15, 0.10, 0.15, 600, 4, 2, 0),
]:
    logmod = m*int((b2-b1)*n) + t*n
    res, info = probe(alpha, b1, b2, n, m, t, s)
    print("  a=%.2f b=(%.2f,%.2f) n=%d m=%d t=%d  log2mod=%d | %s" % (
        alpha, b1, b2, n, m, t, logmod,
        ("%d/%d" % res) if res else "INFEASIBLE"))