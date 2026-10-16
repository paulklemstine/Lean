import hashlib, bisect, random
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
BV = 20; Mmax = 2048; K = 3072; L = 10240
w = 2**BV; bB = w - 1
J = [None] * (Mmax + 1)
cur = EE(0)
for j in range(1, Mmax + 1):
    cur = cur + GG; J[j] = cur

def phi_x(pt):
    return 1 + (int(pt[0]) % Mmax)

def phi_hash(pt):
    h = hashlib.sha256(str(int(pt[0])).encode()).digest()
    return 1 + (int.from_bytes(h[:8], 'big') % Mmax)

def run(d, phi):
    Q = GG * d
    cur = GG * bB; dist = 0; ts = []
    for _ in range(K):
        j = phi(cur); cur = cur + J[j]; dist += j; ts.append(int(bB + dist))
    cur = Q; dist = 0; ws = []; wj = []
    for _ in range(L):
        j = phi(cur); wj.append(j); cur = cur + J[j]; dist += j; ws.append(int(d + dist))
    return ts, ws, wj

for name, phi in (("x mod Mmax", phi_x), ("sha256(x) mod Mmax", phi_hash)):
    print("=" * 60)
    print("JUMP FUNCTION: %s" % name)
    nz = 0; tot = 0
    for t in range(8):
        d = (t * 131071) % w
        ts, ws, wj = run(d, phi)
        n = len(set(ts) & set(ws)); tot += n
        if n: nz += 1
    print("  8 plants, real tame + real wild : nonzero intersection in %d/8, total %d" % (nz, tot))
    # joint analysis for one plant
    d = 131071
    ts, ws, wj = run(d, phi)
    ts_sorted = sorted(ts)
    inside = [j for j in range(L) if ts_sorted[0] <= ws[j] <= ts_sorted[-1]]
    eqjump = 0; dists = []
    for j in inside:
        p = bisect.bisect_right(ts_sorted, ws[j])
        nxt = ts_sorted[p] if p < len(ts_sorted) else None
        if nxt is not None:
            r = nxt - ws[j]
            dists.append(r)
    print("  steps inside region: %d ; #times wild jump == dist-to-next-trap: %d"
          % (len(inside), 0))
    # recompute properly: need the jump TAKEN from position ws[j]; use wj[j]
    eqjump = 0; nd = 0
    for j in inside:
        p = bisect.bisect_right(ts_sorted, ws[j])
        if p < len(ts_sorted):
            r = ts_sorted[p] - ws[j]
            nd += 1
            if wj[j] == r:
                eqjump += 1
    print("  (correct count) wild jump == distance to next trap : %d of %d" % (eqjump, nd))
    print("  expected under independence: %.2f" % (nd / float(Mmax)))
    import collections
    h = collections.Counter()
    for j in inside:
        p = bisect.bisect_right(ts_sorted, ws[j])
        if p < len(ts_sorted):
            h[wj[j] - (ts_sorted[p] - ws[j])] += 0
    # distribution of (jump - distance)
    diff = []
    for j in inside:
        p = bisect.bisect_right(ts_sorted, ws[j])
        if p < len(ts_sorted):
            diff.append(wj[j] - (ts_sorted[p] - ws[j]))
    neg = sum(1 for x in diff if x < 0); zero = sum(1 for x in diff if x == 0)
    pos = sum(1 for x in diff if x > 0)
    print("  jump - dist_to_next_trap :  <0: %d   ==0: %d   >0: %d  (of %d)"
          % (neg, zero, pos, len(diff)))
