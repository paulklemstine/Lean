import cypari2, time, warnings, random
warnings.filterwarnings('ignore')
from sympy import nextprime, isprime
pari = cypari2.Pari()
pari('default(parisize, 256*1024*1024)')
rng = random.Random(5)
for qb in (61, 71, 81, 91):
    qs = []
    q = int(nextprime(2**qb))
    while len(qs) < 5:
        while q % 4 != 3 or not isprime(q):
            q = int(nextprime(q+1))
        qs.append(q); q += 2
    t = time.time()
    hs = [int(pari.qfbclassno(-q)) for q in qs]
    dt = (time.time()-t)/len(qs)
    print(f'q_bits={qb} h_bits={[h.bit_length() for h in hs]} per_call={dt:.3f}s', flush=True)
