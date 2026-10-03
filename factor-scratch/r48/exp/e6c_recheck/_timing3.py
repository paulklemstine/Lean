import cypari2, random, time, warnings, sympy
warnings.filterwarnings('ignore')
pari = cypari2.Pari()
rng = random.Random(3)
from sympy import nextprime, isprime
for pb in (30, 45, 60, 75):
    p = int(nextprime(2**pb))
    t = time.time(); n = 0; nc = 0; np_ = 0
    while time.time() - t < 4.0:
        a4, a6 = rng.randrange(1, p), rng.randrange(1, p)
        if (4*a4**3 + 27*a6**2) % p == 0: continue
        el = pari.ellinit([a4, a6], p)
        nc += 1; n += 1
        for x in range(2, 40):
            r = (x*x*x + a4*x + a6) % p
            if r == 0 or pow(r, (p-1)//2, p) != 1: continue
            y = int(sympy.sqrt_mod(r, p, all_roots=True)[0])
            pari.ellorder(el, pari([x, y])); np_ += 1
            break
        if n >= 300: break
    print(f'p_bits={pb} cards={nc} orders={np_} in {time.time()-t:.2f}s', flush=True)
