"""Direct measurement at the CLAIMED cell: h(-q) ~ 29 bits, B=1000.
The original claimed class_smooth=0.720 there."""
import cypari2, math, random, sys, warnings
warnings.filterwarnings('ignore')
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r48/_shared')
from sympy import nextprime, isprime
from dickman import is_smooth, rho, largest_prime_factor

pari = cypari2.Pari(); pari('default(parisize, 256*1024*1024)')
rng = random.Random(4242)
B = 1000

# h ~ 29 bits needs q ~ 2^60-62
hs = []
while len(hs) < 3000:
    q = int(nextprime(rng.randrange(2**59, 2**63)))
    while q % 4 != 3:
        q = int(nextprime(q+1))
    h = int(pari.qfbclassno(-q))
    if 29 <= h.bit_length() <= 30:
        hs.append(h)
print(f'n={len(hs)} class numbers with h in [29,30] bits at B={B}')
k = sum(1 for h in hs if is_smooth(h, B))
r = k/len(hs)
rho29 = rho(29/math.log2(B))
print(f'  MEASURED class_smooth = {k}/{len(hs)} = {r:.4f}')
print(f'  Dickman rho(29 bits)  = {rho29:.4f}')
print(f'  ratio measured/rho    = {r/rho29:.3f}x   (original claimed 0.720 = 12.3x)')
lp = sorted(largest_prime_factor(h) for h in hs)
print(f'  largest prime factor: min={lp[0]} p25={lp[len(lp)//4]} median={lp[len(lp)//2]} p90={lp[int(.9*len(lp))]} max={lp[-1]}')
print(f'  count with lpf <= 1000 (i.e. the smooth ones): {k}')
print(f'  count with lpf <= 10^6: {sum(1 for x in lp if x <= 10**6)}')
