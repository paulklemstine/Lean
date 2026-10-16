import time
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

def phi_hi(pt, MM):
    return 1 + ((int(pt[0]) >> 120) % MM)

def phi_vhi(pt, MM):
    return 1 + ((int(pt[0]) >> 200) % MM)

def phi_mid(pt, MM):
    return 1 + ((int(pt[0]) >> 64) % MM)

def phi_low(pt, MM):
    return 1 + (int(pt[0]) % MM)

def phi_mul(pt, MM):
    return 1 + (((int(pt[0]) * 2654435761) >> 17) % MM)

def phi_mul2(pt, MM):
    x = int(pt[0])
    v = (x * 0x9E3779B97F4A7C15) & 0xFFFFFFFFFFFFFFFF
    return 1 + (v % MM)

def trial(bv, MM, phi, nseed=12, kfac=3.0):
    w = 2 ** int(bv)
    bB = w - 1
    meanjump = (MM + 1) // 2
    K = max(2, int(round(kfac * meanjump)))
    cap = int(ceil(w / meanjump)) + K + int(6 * meanjump)
    J = [None] * (MM + 1)
    cur = EE(0)
    for j in range(1, MM + 1):
        cur = cur + GG; J[j] = cur
    ok = 0; steps = []
    for t in range(nseed):
        d = int((t * 86753 + 11) % w)
        Q = GG * d
        cur = GG * bB; dist = 0; traps = {}
        for _ in range(K):
            j = phi(cur, MM); cur = cur + J[j]; dist += j
            traps[int(cur[0])] = dist
        cur = Q; dist = 0; hit = None; ns = 0
        while ns < cap:
            j = phi(cur, MM); cur = cur + J[j]; dist += j; ns += 1
            dt = traps.get(int(cur[0]))
            if dt is not None:
                cand = bB + dt - dist
                if 0 <= cand <= bB:
                    hit = cand
                break
        steps.append(ns)
        if hit is not None and GG * hit == Q:
            ok += 1
    return ok, nseed, sum(steps) / float(nseed), cap

for bv, MM in ((16, 512), (20, 2048), (24, 8192)):
    print("=== b=%d  Mmax=%d (mean jump %d) ===" % (bv, MM, (MM + 1) // 2))
    for name, phi in (("hi  (x>>120)%M", phi_hi),
                      ("vhi (x>>200)%M", phi_vhi),
                      ("mid (x>>64)%M", phi_mid),
                      ("mul (x*2654435761>>17)%M", phi_mul),
                      ("mul2(x*golden&mask)%M", phi_mul2),
                      ("low x%M [KNOWN BAD]", phi_low)):
        ok, n, ms, cap = trial(bv, MM, phi)
        print("   %-24s : recovery %2d/%d   mean wild steps %.0f (cap %d)"
              % (name, ok, n, ms, cap), flush=True)
