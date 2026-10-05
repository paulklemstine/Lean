import time
a = next_prime(2^120); b = next_prime(2^118); N = a*b
P = pari(N)
print("--- raw repr of factor(1) ---")
r = P.factor(1)
print(repr(r)[:200])
print("--- as matrix ---")
try:
    M = matrix(ZZ, r)
    print(M)
except Exception as e:
    print("matrix failed:", e)
print("--- is it the trivial answer? ---")
print("matrix[0][0] == N ?", ZZ(r[0][0]) == N)
print("--- try factorint via cypari2 style ---")
t0=time.time(); g = pari(N).factorint(); print("factorint %.3f s -> %s" % (time.time()-t0, str(g)[:120]))
print("--- control: does pari have ECM? check version + flags ---")
print("pari version:", repr(pari.n().version() if False else cypari2.pariversion()))
