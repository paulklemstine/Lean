import math
"""
Verify the bridge:  b achievable with c=1  <=>  exists a factorization U=U_1..U_l (UMW Lemma 6.2)
such that p | U_i  =>  p | (b+i).
Equivalently V_i = 1 (mod U_i) forces W = sum_i i*V_i = i (mod U_i), so b = -W (mod U) has
b = -i (mod U_i).  Check both directions numerically on random factorizations.
"""
import random
from sympy import primerange

rng = random.Random(1)
bad = 0
for n in [20, 30, 40, 50, 60, 80, 100]:
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    for trial in range(300):
        perm = list(primes); rng.shuffle(perm)
        cuts = sorted(rng.sample(range(1, len(perm)), l-1)) if l-1 <= len(perm)-1 else []
        blocks, prev = [], 0
        for c in cuts: blocks.append(perm[prev:c]); prev = c
        blocks.append(perm[prev:])
        W = 0
        for idx, blk in enumerate(blocks, start=1):
            Ui = 1
            for p in blk: Ui *= p
            if Ui == 1: continue
            t = U // Ui
            W += idx * t * pow(t, -1, Ui)
        b = (-W) % U
        # direction 1: b = -i (mod U_i)
        for idx, blk in enumerate(blocks, start=1):
            Ui = 1
            for p in blk: Ui *= p
            if Ui > 1 and (b + idx) % Ui != 0: bad += 1
        # direction 2: every prime covered
        for p in primes:
            if not any((b + i) % p == 0 for i in range(1, l+1)): bad += 1
print("violations:", bad, "-> Lemma 6.2 bridge HOLDS" if bad == 0 else "-> BRIDGE FAILS")

# The dual direction: given b covering all primes, b = -j_p (mod p) defines a valid
# factorization by putting p in block j_p.  Confirm the block sizes are <= l and
# that blocks are non-empty-or-dropped (UMW allows U_i = 1 => i irrelevant).
print()
print("Structure of an achievable b: b mod p in {-1,...,-l}. For p <= l this is ALL")
print("residues except 0; for p > l it is l of the p residues. Fraction of residues kept")
print("per prime = l/p (p>l), 1 (p<=l).  Independent => density = prod_{p>l} l/p")
for n in [100, 1000, 10000]:
    ps = list(primerange(1, n+1)); l = round(n ** (2/3))
    dens = 1.0
    for p in ps:
        if p > l: dens *= l / p
    print(f"  n={n:6d} l={l:5d}  density = exp({math.log(dens):8.2f})  "
          f"#achievable = exp({math.log(dens)+ (n if False else 0):8.2f})  "
          f"expected first b ~ U*density = exp({n + math.log(dens):8.2f})  [target n^(1/3)={n**(1/3):.1f}]")
