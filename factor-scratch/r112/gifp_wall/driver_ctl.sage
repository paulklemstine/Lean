load('instrument.sage')

# DECISIVE EXPERIMENT for the mechanism.
#
# Hypothesis: the alpha>=0.15 wall is entirely the collapse of
#       log2(modulus) = m*(beta2-beta1)*n + t*n
# because the reference implementation picks t = round((1-sqrt(alpha))*m),
# which STEPS DOWN by 1 as alpha grows, losing a full n bits each time.
# gamma does not appear in log2(modulus) at all -- which is exactly why r111
# could push gamma to the feasibility limit with no rescue.
#
# PREDICTION: if we hold (m, t, s) FIXED and sweep alpha, success should be
# INDEPENDENT of alpha (for the alpha values where the generator still works),
# because log2(modulus) is then fixed. If instead success still dies at
# alpha=0.15 with a large t, the wall has a second cause.
#
# Uses the largest feasible gamma at each alpha, so feasibility is never the
# binding constraint.
n = 200; b1, b2 = 0.1, 0.15; TRIALS = 3

def max_gamma(alpha, b1, b2, n, mult=3.0):
    """Largest gamma with alpha+gamma+beta2<1, snapped to the 1/n grid."""
    cap = 1 - alpha - max(b1, b2)
    g = min(cap - 0.005, 4*alpha*(1-sqrt(float(alpha)))*mult)
    return float(ZZ(int(g*n))/n)

for m, t, s in [(4,3,0),(4,4,0),(5,3,0),(6,3,0),(6,4,0),(4,3,2),(4,2,2),(5,3,2)]:
    logmod = m*int((b2-b1)*n) + t*n
    print("=== m=%d t=%d s=%d  -> log2(modulus)=%d bits, DEFAULT t=round((1-sqrt(a))m) would be: ==="
          % (m, t, s, logmod))
    print("     alpha | gamma | verified | note")
    for alpha in [0.05, 0.10, 0.14, 0.15, 0.18, 0.20, 0.25, 0.30]:
        gamma = max_gamma(alpha, b1, b2, n)
        ok = 0; tot = 0
        for k in range(TRIALS):
            seed = 99000000 + 15485863*k + int(alpha*1000)*577 + m*31 + t*3 + s
            r = instrument(n, RR(alpha), RR(gamma), RR(b1), RR(b2), m, seed,
                           t_force=t, s_force=s)
            if r["status"].startswith("skip"): continue
            tot += 1; ok += 1 if r["fact"] else 0
        tdef = int(round((1-sqrt(RR(alpha)))*m))
        note = "default t=%d %s" % (tdef, "(forced t is LARGER)" if t > tdef
                                    else "(forced t is SMALLER)" if t < tdef else "")
        print("     %.2f  | %.3f | %-8s | %s" % (alpha, gamma,
              "%d/%d" % (ok, tot) if tot else "0/0", note))
    print()