P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
Mmax = 2048
N = 40000
# walk u = 1..N, recording u mod Mmax and x(u*G) mod Mmax
cur = EE(0)
rows = []
for u in range(1, N + 1):
    cur = cur + GG
    rows.append((u % Mmax, int(cur[0]) % Mmax))
# is f(u) = x(u*G) mod Mmax a function of u mod Mmax ?
from collections import defaultdict
d = defaultdict(set)
for a, b in rows:
    d[a].add(b)
maxfanout = max(len(v) for v in d.values())
print("distinct u residues seen: %d ; max #distinct f values per residue: %d"
      % (len(d), maxfanout))
print("  -> if maxfanout == 1 then x(u*G) mod Mmax IS a function of u mod Mmax")
# correlations of the low bits of x with u
same = sum(1 for a, b in rows if a == b)
print("P(x mod Mmax == u mod Mmax) = %.4f  (uniform would be %.4f)"
      % (same / float(N), 1.0 / Mmax))
# histogram of x mod Mmax
h = defaultdict(int)
for a, b in rows:
    h[b] += 1
vals = sorted(h.values())
print("x mod Mmax histogram over %d samples: min %d max %d mean %.1f"
      % (N, vals[0], vals[-1], float(sum(vals)) / len(vals)))
# low bits of x: parity
cur = EE(0); par = [0, 0]
for u in range(1, N + 1):
    cur = cur + GG
    par[int(cur[0]) & 1] += 1
print("parity of x over %d points: even %d  odd %d" % (N, par[0], par[1]))
# bit 1 (x mod 4)
cur = EE(0); c4 = [0, 0, 0, 0]
for u in range(1, N + 1):
    cur = cur + GG
    c4[int(cur[0]) & 3] += 1
print("x mod 4 distribution: %s  (uniform would be %d each)" % (c4, N // 4))
