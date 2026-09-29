"""
DECISIVE test.  By Lemma 6.2, b = (-W) mod U and V_i = 1 (mod U_i), so
    b = -i_p (mod p)   for the block index i_p of each prime p.
Hence the map (partition of the primes into l blocks) -> b mod U is INJECTIVE
(b recovers every i_p), and the covering AP is just {b+1,...,b+l}.
Enumerate ALL partitions (no sampling) and get the TRUE minimum b, then compare
with the (alpha,beta)=(1/3,1/3) target b <= exp(n/3).
"""
import math, time
from sympy import primerange

def all_partitions(items, k):
    if k == 1:
        yield [list(items)]; return
    if len(items) < k: return
    # first block contains items[0]
    first = items[0]; rest = items[1:]
    from itertools import combinations
    for r in range(0, len(rest)+1):
        for combo in combinations(rest, r):
            sel = set(combo)
            blk1 = [first] + list(combo)
            blk2 = [x for x in rest if x not in sel]
            for tail in all_partitions(blk2, k-1):
                yield [blk1] + tail

def run(n):
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    best, best_part, count, images = U, None, 0, set()
    t0 = time.time()
    for part in all_partitions(primes, l):
        count += 1
        W = 0
        for idx, blk in enumerate(part, start=1):
            Ui = 1
            for p in blk: Ui *= p
            if Ui == 1: continue
            M = U // Ui
            W += idx * M * pow(M, -1, Ui)
        b = (-W) % U
        images.add(b)
        if b < best:
            best = b; best_part = part
    target = math.exp(n/3)
    ph = U / (l ** len(primes))
    covers = all(any((best+i) % p == 0 for i in range(1, l+1)) for p in primes)
    print(f"n={n:3d} l={l:2d} pi(n)={len(primes):2d} |U|={len(str(U)):3d}d  "
          f"#partitions={count:9d}  #distinct b={len(images):9d}  "
          f"TRUE min b={best:6d} ({len(str(best))}d)  "
          f"[U/l^pi={ph:8.1f}]  [e^(n/3)={target:12.1f}]  "
          f"{'HIT' if best<=target else 'MISS'}  covers_primes={covers}  ({time.time()-t0:.1f}s)",
          flush=True)
    return best, target, U, l**len(primes), len(images), count

for n in [16, 18, 20, 21, 22, 24, 26, 28, 30]:
    run(n)
