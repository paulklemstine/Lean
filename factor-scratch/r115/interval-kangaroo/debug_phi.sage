import hashlib, time, sys
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
MM = int(2048)

def make_table(Mmax):
    J = [None] * (Mmax + 1)
    cur = EE(0)
    for j in range(1, Mmax + 1):
        cur = cur + GG; J[j] = cur
    return J

def phi_low(pt):
    return 1 + (int(pt[0]) % MM)

def phi_hi(pt):
    return 1 + ((int(pt[0]) >> 120) % MM)

def phi_mul(pt):
    return 1 + (((int(pt[0]) * 2654435761) >> 17) % MM)

def phi_sha(pt):
    h = hashlib.sha256(repr(int(pt[0])).encode()).digest()
    return 1 + (int.from_bytes(h[:8], 'big') % MM)

def phi_xor(pt):
    x = int(pt[0])
    return 1 + (((x ^ (x >> 64)) & 0xFFFFFFFF) % MM)

BV = 20
w = 2**BV; bB = w - 1
K = 3072; L = 10240
J = make_table(MM)

for name, phi in (("low  x % Mmax", phi_low),
                  ("high (x>>120) % Mmax", phi_hi),
                  ("mul  (x*2654435761)>>17 % Mmax", phi_mul),
                  ("xor  (x^(x>>64)) % Mmax", phi_xor),
                  ("sha256(x) % Mmax", phi_sha)):
    t0 = time.time()
    hit = 0; tot_inter = 0
    for t in range(12):
        d = int((t * 86753 + 11) % w)
        Q = GG * d
        cur = GG * bB; dist = 0; ts = []
        for _ in range(K):
            j = phi(cur); cur = cur + J[j]; dist += j; ts.append(bB + dist)
        cur = Q; dist = 0; ws = []
        for _ in range(L):
            j = phi(cur); cur = cur + J[j]; dist += j; ws.append(d + dist)
        n = len(set(ts) & set(ws)); tot_inter += n
        if n: hit += 1
    print("  %-30s : plants collided %2d/12   total |A&B| = %5d   (%.1fs)"
          % (name, hit, tot_inter, time.time() - t0), flush=True)
