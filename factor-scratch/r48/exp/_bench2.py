import time, random, cypari2
pari = cypari2.Pari()
random.seed(1)
N = 1
for d in (10,20,30,40,60):
    rows=[[random.getrandbits(1024) for _ in range(d)] for _ in range(d)]
    t=time.time()
    M = pari.Mat(d,d,rows).lll()
    print("pari qflll d=%d 1024bit: %.2fs"%(d,time.time()-t))
