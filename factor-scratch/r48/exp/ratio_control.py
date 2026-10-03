#!/usr/bin/env python3
"""
V1c: the ratio at matched scale, with the arithmetic control.

Three arms, ALL at 29-bit order scale (band [2^29, 2^30)):
  A  uniform random integers          <- the NULL: no algebraic structure at all
  B  uniform random ODD integers      <- adds ONLY parity (no factor 2)
  C  #E(F_p)                           <- E-7's EC arm
  D  h(-q), q = 3 mod 4 prime         <- E-7's class arm

Class numbers for arm D are supplied from the e7_results run (slow to generate),
so this script computes A, B, C fresh with large n and reuses D's 60 samples.

The question this answers: is D's smoothness rate explained by (i) size alone,
(ii) parity alone, or (iii) genuine class-group structure?
"""
import json, math, random, time
from e7_audit import P, is_smooth, oddpart, fisher_two_sided, wilson

L = 29
LO, HI = 1 << L, 1 << (L + 1)
US = [1.5, 2.0, 2.5, 3.0]

rng = random.Random(4242)

N = 20000
A = [rng.randrange(LO, HI) for _ in range(N)]
B = []
while len(B) < N:
    v = rng.randrange(LO, HI) | 1
    B.append(v + LO if v < LO else v)

C = []
t0 = time.time()
while len(C) < 3000 and time.time() - t0 < 200:
    p = rng.randrange(LO, HI) | 1
    if p < 3 or not P.isprime(p):
        continue
    a = rng.randrange(0, p); b = rng.randrange(0, p)
    if (4 * a * a * a + 27 * b * b) % p == 0:
        continue
    C.append(int(P.ellcard(P.ellinit([0, 0, 0, a, b], p))))

# arm D: reuse the 60 class numbers from the main audit by regenerating
D = []
t0 = time.time()
while len(D) < 60 and time.time() - t0 < 200:
    q = rng.randrange(int(4 * LO * LO) + 11, int(4 * HI * HI) + 11) | 1
    if q % 4 != 3:
        q += 2
    if not P.isprime(q):
        continue
    h = int(P.qfbclassno(-q))
    if LO <= h < HI:
        D.append(h)

print("arms: A(uniform)=%d  B(odd)=%d  C(EC)=%d  D(class)=%d" % (len(A), len(B), len(C), len(D)))
print("parity: C even %d/%d (%.1f%%)   D even %d/%d (%.1f%%)"
      % (sum(1 for x in C if x % 2 == 0), len(C), 100 * sum(1 for x in C if x % 2 == 0) / len(C),
         sum(1 for x in D if x % 2 == 0), len(D), 100 * sum(1 for x in D if x % 2 == 0) / len(D)))
print()

def rate(xs, u):
    k = sum(is_smooth(x, max(2, int(round(math.pow(x, 1.0 / u))))) for x in xs)
    return k, len(xs), (k / len(xs) if xs else 0.0)

hdr = "%4s | %8s %8s %8s %8s | %7s %7s %7s" % (
    "u", "A unif", "B odd", "C EC", "D class", "D/A", "D/B", "D/C")
print(hdr); print("-" * len(hdr))
rows = {}
for u in US:
    ka, na, ra = rate(A, u)
    kb, nb, rb = rate(B, u)
    kc, nc, rc = rate(C, u)
    kd, nd, rd = rate(D, u)
    rows[str(u)] = dict(A=[ka, na, ra], B=[kb, nb, rb], C=[kc, nc, rc], D=[kd, nd, rd])
    print("%4.1f | %8.4f %8.4f %8.4f %8.4f | %7.3f %7.3f %7.3f"
          % (u, ra, rb, rc, rd, rd / ra if ra else 0, rd / rb if rb else 0, rd / rc if rc else 0))

print()
for u in US:
    r = rows[str(u)]
    kd, nd, rd = r['D']
    print("u=%.1f  Wilson D(class) = %s   95%% CI" % (u, tuple(round(x, 4) for x in wilson(kd, nd))))
    print("        Fisher D vs C(EC)  p = %.4f" % fisher_two_sided(kd, nd, r['C'][0], r['C'][1]))
    print("        Fisher D vs A(unif) p = %.4f" % fisher_two_sided(kd, nd, r['A'][0], r['A'][1]))
    print("        Fisher D vs B(odd)  p = %.4f" % fisher_two_sided(kd, nd, r['B'][0], r['B'][1]))
    print("        Fisher B vs A       p = %.4f   <- the parity effect alone"
          % fisher_two_sided(r['B'][0], r['B'][1], r['A'][0], r['A'][1]))

with open("e7_ratio_control.json", "w") as f:
    json.dump({"L": L, "arms": rows}, f, indent=1)
print("\nwrote e7_ratio_control.json")