import time
a = next_prime(2^120); b = next_prime(2^118)
print("a prime?", a.is_prime(), "b prime?", b.is_prime())
N = a*b
print("N bits:", N.nbits(), "N == a*b", N == a*b)
t0=time.time(); f = pari(N).factor(1); dt=time.time()-t0
rows = list(f)
print("flag=1 %.4f s rows=%d" % (dt, len(rows)))
got = [ZZ(r[0]) for r in rows]
print("returned:", [g.nbits() for g in got])
print("GROUND TRUTH: each returned divides N exactly:", [N % g == 0 for g in got])
print("product of returned == N:", prod(got) == N)
