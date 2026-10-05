import time, sys
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits = int(sys.argv[1]); alpha = float(sys.argv[2]); seed = int(sys.argv[3])
mode = sys.argv[4] if len(sys.argv)>4 else 'ecm'
set_random_seed(seed)
qb = int(round(nbits*alpha)); pb = nbits - qb
for _ in range(300):
    q = blum(2**(qb-1) + randint(0, 2**(qb-1)))
    c = blum(2**(pb-1) + randint(0, 2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N = c,q,c*q; break
print("TRUE factors: |p|=%d bits |q|=%d bits  N=%d bits" % (p.nbits(), q.nbits(), N.nbits()))
pari_N = pari(N)
t0=time.time(); f = pari_N.factor(1); dt=time.time()-t0
rows = list(f)
print("rows:", [[str(r[0])[:24], (str(r[1]) if len(list(r))>1 else '1')] for r in rows])
got = [ZZ(list(r)[0]) for r in rows]
print("TIMING (flag=1 ECM): %.4f s" % dt)
print("each returned factor divides N exactly:", [N % g == 0 for g in got])
print("set equality {p,q} == returned set:", sorted([str(g) for g in got]) == sorted([str(p),str(q)]))
# control: does the SAME call return instantly because it is a no-op? try a big prime
t0=time.time(); f2 = pari(p).factor(1); dt2=time.time()-t0
print("CONTROL factor(p) where p is %d-bit PRIME: %.4f s, rows=%d (should be 1 row, slower)" % (p.nbits(), dt2, len(list(f2))))
