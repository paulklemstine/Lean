import time, sympy
from cypari2 import Pari
p = Pari()
a = sympy.nextprime(2**40); b = sympy.nextprime(2**38); N = int(a)*int(b)
print("N bits", N.bit_length(), "prime factors:", sympy.isprime(a), sympy.isprime(b))
for label, f in [("pari(N).factor()", lambda: p(N).factor()),
                 ("pari(N).factor(1)", lambda: p(N).factor(1)),
                 ("pari.factorint(N)", lambda: p.factorint(N)),
                 ("pari.factor(N,1)", lambda: p.factor(N, 1))]:
    t0=time.time()
    try:
        r = f(); dt=time.time()-t0
        s = str(r)
        trivial = (len(s) > 30 and s.lstrip('[').split()[0].isdigit() and int(s.lstrip('[').split()[0]) == N)
        print("%-22s %.4f s -> %s%s" % (label, dt, s[:100], "   <<< TRIVIAL: returned N itself" if trivial else ""))
    except Exception as e:
        print("%-22s ERROR: %s" % (label, type(e).__name__), str(e)[:120])
