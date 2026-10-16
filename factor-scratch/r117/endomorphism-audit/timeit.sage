import time
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
E = EllipticCurve(GF(p), [0, 7])
t0 = time.time()
n = E.cardinality()
print("secp256k1 #E computed in", round(time.time()-t0,1), "s")
spec = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
print("matches spec n:", n == spec, " (n=", hex(n), ")")
t = p + 1 - n
print("trace t =", t, " t bitlength =", t.nbits())
print("d = t^2 - 4p, |d| bits =", (t^2 - 4*p).nbits(), " vs 4p bits =", (4*p).nbits())
