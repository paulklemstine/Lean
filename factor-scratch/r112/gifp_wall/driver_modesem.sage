load('instrument.sage')

# THE DECISIVE MODULUS TEST.
#
# Two independent alpha-dependences are in play, and the r110/r111 harness
# conflates them:
#
#  (1) t = round((1-sqrt(alpha))*m) STEPS DOWN as alpha grows. log2(modulus)
#      = m*(beta2-beta1)*n + t*n loses a FULL n = 200 bits at the step. gamma
#      does not appear in the modulus at all, which is exactly why pushing
#      gamma to the feasibility limit could never rescue alpha>=0.15.
#
#  (2) The sweeps use unknown_modular = M^m * N1^t, but gifp.sage:341 uses
#      M^m * p1^t, and the shifts provably vanish only mod the latter
#      (verified: 0/15 violations mod M^m*p1^t, 10/15 mod M^m*N1^t).
#      Overstating the modulus by q1^t = 2^(alpha*n) makes the "too large"
#      filter in reconstruct_polynomials DISCARGE fewer rows -- it lets
#      through rows that do not vanish over Z.
#
# Test both modulus semantics at each alpha, holding everything else fixed.
n = 200; b1, b2 = 0.1, 0.15; TRIALS = 3

def max_gamma(alpha, b1, b2, n):
    """Largest gamma keeping alpha+gamma+beta2 <= 1 with >=6 bits of MSB headroom."""
    cap = 1 - alpha - max(b1, b2) - 6.0/n
    g = min(cap, 4*alpha*(1-sqrt(float(alpha)))*2.5)
    return float(ZZ(int(g*n))/n)

print("=== mod_sem: does using the CORRECT modulus (p1^t) rescue alpha>=0.15? ===")
print("  default t/s throughout (the reference's own choice, no forcing)")
for alpha in [0.05, 0.10, 0.14, 0.15, 0.20, 0.25, 0.30]:
    gamma = max_gamma(alpha, b1, b2, n)
    for m in [4, 6]:
        line = "  a=%.2f g=%.3f m=%d |" % (alpha, gamma, m)
        parts = []
        for sem in ["N1", "p1"]:
            ok = 0; tot = 0; zs = []
            for k in range(TRIALS):
                seed = 13100000 + 15485863*k + int(alpha*1000)*401 + m*17
                r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed,
                               mod_sem=sem)
                if r["status"].startswith("skip"): continue
                tot += 1; ok += 1 if r["fact"] else 0
                zs.append("%s/%s" % (r["nz"], r.get("npolys")))
            parts.append("mod=%-3s %-5s nz=%-12s" % (sem, "%d/%d" % (ok, tot),
                                                     ",".join(zs) if zs else "-"))
        print(line + " " + " | ".join(parts))
    print()