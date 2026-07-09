import matplotlib.pyplot as plt
from collections import Counter
def M(n): return Counter(str(n))
def count_vampires(half_len):
    lo, hi = 10**(half_len-1), 10**half_len - 1; seen=set()
    for x in range(lo, hi+1):
        for y in range(x, hi+1):
            if x%10==0 and y%10==0: continue
            if ((x-1)*(y-1))%9 != 1%9: continue
            if x%3==1 or y%3==1: continue
            v=x*y
            if len(str(v))==2*half_len and M(v)==M(x)+M(y): seen.add(v)
    return len(seen)
hl=[1,2,3]; counts=[count_vampires(h) for h in hl]
plt.bar([2*h for h in hl], counts, color='crimson')
plt.xlabel('digit length of v'); plt.ylabel('# vampires')
plt.title('Vampire count by digit length'); plt.tight_layout()
plt.savefig('vampire_density.png', dpi=150)
