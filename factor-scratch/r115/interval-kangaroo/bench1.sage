# benchmark: Sage native point arithmetic rate on secp256k1
import time
p = 2**256 - 2**32 - 977
F = GF(p)
E = EllipticCurve(F, [0, 7])
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
G = E(Gx, Gy)
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
print("order of G =", G.order() == n, "curve ok", E.is_smooth())

# random point
import random as _pyrand_check
pts = [G * (i * 1000003 + 7) for i in range(2000)]

N = 20000
t0 = time.time()
acc = pts[0]
for i in range(N):
    acc = acc + pts[1 + (i % 1999)]
t1 = time.time()
print("point additions: %d in %.3f s -> %.0f ops/s" % (N, t1 - t0, N / (t1 - t0)))

M = 20000
t0 = time.time()
s = 0
for i in range(M):
    x = int(acc[0])
    s += x
t1 = time.time()
print("int(x) + add: %d in %.3f s -> %.0f ops/s" % (M, t1 - t0, M / (t1 - t0)))

t0 = time.time()
for i in range(200):
    q = G * (12345678901234567 + i)
t1 = time.time()
print("scalar mult G*k: 200 in %.3f s -> %.1f us each" % (t1 - t0, (t1 - t0) / 200 * 1e6))
