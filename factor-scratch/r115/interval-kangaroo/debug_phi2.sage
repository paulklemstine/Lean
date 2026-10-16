import time
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
MM = int(2048)
J = [None] * (MM + 1)
cur = EE(0)
for j in range(1, MM + 1):
    cur = cur + GG; J[j] = cur

def phi_low(pt):
    return 1 + (int(pt[0]) % MM)

def phi_hi(pt):
    return 1 + ((int(pt[0]) >> 120) % MM)

def phi_mul(pt):
    return 1 + (((int(pt[0]) * 2654435761) >> 17) % MM)

BV = 20
w = 2**BV; bB = w - 1
K = 3072; L = 10240
NPL = 40

for name, phi in (("low  x % Mmax", phi_low),
                  ("high (x>>120) % Mmax", phi_hi),
                  ("mul  (x*2654435761)>>17 % Mmax", phi_mul)):
    hit = 0; tot = 0; jsum = [0, 0]
    t0 = time.time()
    for t in range(NPL):
        d = int((t * 86753 + 11) % w)
        Q = GG * d
        cur = GG * bB; dist = 0; ts = []; jc = [0] * (MM + 1)
        for _ in range(K):
            j = phi(cur); jc[j] += 1; cur = cur + J[j]; dist += j; ts.append(bB + dist)
        cur = Q; dist = 0; ws = []
        for _ in range(L):
            j = phi(cur); cur = cur + J[j]; dist += j; ws.append(d + dist)
        n = len(set(ts) & set(ws)); tot += n
        if n: hit += 1
        jsum[0] += min(jc); jsum[1] += max(jc)
    print("  %-30s : collide %2d/%d plants, total|A&B|=%6d, jump-hist min/max avg %d/%d (%.0fs)"
          % (name, hit, NPL, tot, jsum[0] // NPL, jsum[1] // NPL, time.time() - t0), flush=True)
