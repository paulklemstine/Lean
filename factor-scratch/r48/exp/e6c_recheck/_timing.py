import cypari2, time, warnings
warnings.filterwarnings('ignore')
from sympy import nextprime
pari = cypari2.Pari()
pari('default(parisize, 64*1024*1024)')
out = []
for bits in (20, 30, 40, 50, 58, 64):
    q = int(nextprime(2**bits))
    while q % 4 != 3:
        q = int(nextprime(q + 1))
    t = time.time(); h = int(pari.qfbclassno(-q)); dt = time.time() - t
    line = f'q_bits={q.bit_length()} h={h} h_bits={h.bit_length()} t={dt:.3f}s'
    out.append(line); print(line, flush=True)
