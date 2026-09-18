import itertools, math, random
from collections import Counter

def H(seq):
    n=len(seq); c=Counter(seq)
    return -sum(v/n*math.log2(v/n) for v in c.values())
def MI(L,F):
    return H(L)+H(F)-H(list(zip(L,F)))

print("=== parity battery on the cube: exact plug-in MI over the whole population ===")
for k in range(2,6):
    pop=list(itertools.product([0,1],repeat=k))
    L=[sum(x)%2 for x in pop]
    rows=[]
    for r in range(1,k+1):
        vals=[MI(L,[tuple(x[i] for i in S) for x in pop]) for S in itertools.combinations(range(k),r)]
        rows.append((r,min(vals),max(vals)))
    print(f" k={k}: H(label)={H(L):.4f}", " ".join(f"order{r}:[{a:.4f},{b:.4f}]" for r,a,b in rows))

print()
print("=== order decomposition (total synergy per order), parity battery k=4 ===")
k=4; pop=list(itertools.product([0,1],repeat=k)); L=[sum(x)%2 for x in pop]
def info(S): return MI(L,[tuple(x[i] for i in S) for x in pop])
marg={i:info((i,)) for i in range(k)}
for r in range(2,k+1):
    tot=sum(info(S)-sum(marg[i] for i in S) for S in itertools.combinations(range(k),r))
    print(f"  order {r}: total synergy {tot:+.4f}")

print()
print("=== CRT dial battery on a semiprime population (plug-in estimates) ===")
random.seed(7)
def primes(a,b):
    return [n for n in range(a,b) if all(n%d for d in range(2,int(n**.5)+1)) and n>1]
P=primes(1000,20000)
N=30000
samples=[]
for _ in range(N):
    p=random.choice(P); q=random.choice(P)
    samples.append((p,q))
mods=[31,23,9,8]
label=[( (p%4), (q%4) ) for p,q in samples]          # a symmetric pair label
readings=[[ (p*q)%m for p,q in samples] for m in mods]
marg=[MI(label,r) for r in readings]
joint=MI(label,[tuple(r[i] for r in readings) for i in range(N)])
print("  per-dial (mod 31,23,9,8):", " ".join(f"{m:.4f}" for m in marg))
print(f"  sum of marginals = {sum(marg):.4f}")
print(f"  joint (CRT 51336) = {joint:.4f}   synergy = {joint-sum(marg):+.4f}")
print(f"  joint label entropy ceiling = {H(label):.4f}")
for r in range(2,5):
    tot=0.0
    for S in itertools.combinations(range(4),r):
        j=MI(label,[tuple(readings[i][t] for i in S) for t in range(N)])
        tot+=j-sum(marg[i] for i in S)
    print(f"  order {r}: total synergy {tot:+.4f}")
