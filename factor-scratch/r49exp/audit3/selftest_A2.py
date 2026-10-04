# SELF-TEST: my ratio() enumerator must return the NULL (1.000) where null is correct.
# Negative controls: a deliberately WRONG enumerator must be flagged.
def ratio(p,k,mode="correct"):
    n=p**k; c=0
    for a in range(n):
        a2=(a*a)%n
        for b in range(n):
            if (a2-b*b*b)%n==0: c+=1
    if mode=="drop_zero_zero":   # the bug the paper warns about (s5)
        n2=0
        for a in range(n):
            for b in range(n):
                if a%p==0 and b%p==0: continue
                if (a*a-b**3)%n==0: n2+=1
        c=n2
    if mode=="wrong_norm":        # normalise by p^k^2 instead of (p^k)^2
        return c/(p**k)/p**(-k)
    return c/(n*n)/p**(-k)

print("POSITIVE: k=1 must be EXACTLY 1.000 for every prime (the law's null case)")
for p in [3,5,7]:
    r=ratio(p,1); print(f"  p={p} k=1 ratio={r:.6f}  {'PASS' if abs(r-1)<1e-12 else 'FAIL'}")
print()
print("NEGATIVE CONTROL 1: drop_zero_zero must NOT give 1.000 at k=2 (paper s5 bug)")
for p in [3,5]:
    good=ratio(p,2); bad=ratio(p,2,"drop_zero_zero")
    print(f"  p={p} k=2 correct={good:.4f} buggy={bad:.4f}  buggy-detected={abs(bad-good)>0.1}")
print()
print("NEGATIVE CONTROL 2: wrong_norm must be caught")
for p in [3]:
    print(f"  p={p} k=2 correct={ratio(p,2):.4f} wrong_norm={ratio(p,2,'wrong_norm'):.4f}  caught={abs(ratio(p,2,'wrong_norm')-ratio(p,2))>0.1}")
print()
print("NEGATIVE CONTROL 3: float cube-root trap -- the k>5 integer check")
import math
for k in [8,27,125,216]:
    bad=int(round(k**(1/3)))**3==k
    good=int(math.isqrt(0))or sum(1 for _ in []) # placeholder
    exact=next((i for i in range(k+1) if i**3>=k),None)
    print(f"  k={k}: int(k**(1/3))={int(k**(1/3))} exact ceil-cuberoot={exact} floor_cuberoot={exact-1 if exact**3>k else exact} equal={int(k**(1/3))==exact-1}")
