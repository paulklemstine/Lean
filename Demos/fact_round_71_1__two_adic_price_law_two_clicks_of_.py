from math import gcd
def valid(m,n): return 0<n<m and gcd(m,n)==1 and (m+n)%2==1
def letter(m,n):
    if n%2==0: return 'A'
    return 'B' if 2*n<m else 'C'
def parent(m,n):
    if n%2==0: return (m-n//2, n//2)
    if 2*n<m: return (m//2, m//2-n)
    return (m//2, n-m//2)
def depth(m,n):
    d=0
    while (m,n)!=(2,1):
        m,n=parent(m,n); d+=1
        if d>200: raise Exception("loop")
    return d
def letterAt(m,n,t):
    for _ in range(t): m,n=parent(m,n)
    return letter(m,n)
def v2(x):
    k=0
    while x%2==0: x//=2; k+=1
    return k
def oddleg(m,n): return m*m-n*n

nodes=[(m,n) for m in range(2,400) for n in range(1,m) if valid(m,n)]
print("nodes:",len(nodes))
# first-A / A-run laws
bad=0
for (m,n) in nodes:
    d=depth(m,n)
    if n%2==1:
        k=v2(m)
        if k>d: continue
        if letterAt(m,n,k)!='A' or any(letterAt(m,n,t)=='A' for t in range(min(k,d))): bad+=1
    else:
        k=v2(n)
        if k>d: continue
        if letterAt(m,n,k)=='A' or any(letterAt(m,n,t)!='A' for t in range(min(k,d))): bad+=1
print("run-law exceptions:",bad)
# pos2Pred
def pos2pred(m,n):
    if n%4==0: return n%8==0
    if n%2==0: return (m-n//2)%4==2
    if m%4==2: return (m//2)%4==n%4
    return m%8==4
bad2=0
for (m,n) in nodes:
    if m+n>27 and depth(m,n)>=3:
        if (letterAt(m,n,2)=='A') != pos2pred(m,n): bad2+=1
print("pos2 exceptions:",bad2)
# twin family
badt=0; cnt=0
for y in range(9,3000):
    if y%3==0: continue
    X=(3*y+5,3*y+4); Y=(y+3,y)
    if not(valid(*X) and valid(*Y)): badt+=1; continue
    if oddleg(*X)!=oddleg(*Y) or oddleg(*X)!=6*y+9: badt+=1; continue
    if (letterAt(*X,2)=='A')==(letterAt(*Y,2)=='A'): badt+=1
    cnt+=1
print("twin family checked",cnt,"exceptions",badt)
# big family
for s in range(0,10):
    W=10*2**s-3; V=12*2**s-1
    X=(2**(s+2)*W+1, 2**(s+2)*W); Y=(V, 2**(s+3))
    ok = valid(*X) and valid(*Y) and oddleg(*X)==oddleg(*Y)
    agree = all((letterAt(*X,u)=='A')==(letterAt(*Y,u)=='A') for u in range(s+2))
    split = (letterAt(*X,s+2)=='A')!=(letterAt(*Y,s+2)=='A')
    print("s=",s,"t=",s+2,"N=",oddleg(*X),"valid",ok,"agree",agree,"split",split,"depths",depth(*X),depth(*Y))
# smallest same-odd-leg pos2 split
from collections import defaultdict
d=defaultdict(list)
for (m,n) in nodes:
    if depth(m,n)>=3: d[oddleg(m,n)].append((m,n))
pairs=0; smallest=None
for N,ns in d.items():
    for i in range(len(ns)):
        for j in range(i+1,len(ns)):
            if (letterAt(*ns[i],2)=='A')!=(letterAt(*ns[j],2)=='A'):
                pairs+=1
                if smallest is None or N<smallest[0]: smallest=(N,ns[i],ns[j])
print("split pairs (m<400):",pairs,"smallest:",smallest)
# mod-8 bijection
bad8=0
for (m,n) in nodes:
    if depth(m,n)<3: continue
    N=oddleg(m,n)%8
    tab={1:(True,True),5:(True,False),3:(False,True),7:(False,False)}
    if tab[N]!=(letterAt(m,n,0)=='A',letterAt(m,n,1)=='A'): bad8+=1
print("mod8 bijection exceptions:",bad8)
# B rarity
from collections import Counter
c=Counter(letter(m,n) for (m,n) in nodes)
print("letter counts m<400:",c)


#!/usr/bin/env python3
"""Checks behind `Catalog/Probability/PriceTwoAdicDepthSealing.lean`.

Three checks, all reported with an exception count:

1.  The family `dsX s = (2^(s+4)+1, 2^(s+3))`, `dsY s = (dsM s + 1, dsM s)` with
    `dsM s = 2^(s+4)*(3*2^(s+1)+1)` consists of valid Price nodes with equal odd legs,
    equal depth `2s+6`, addresses `A^(s+2) B A^(s+3)` and `C A^s C A^(s+4)`, and it splits
    at position `t = s+3` (all `A` below `t`, `B` versus `A` at `t`).

2.  The smallest odd leg carrying an equal-odd-leg, equal-depth splitting pair at
    position `t`, for `t = 2, ..., 7`, by exhaustive enumeration of coprime factorisations.

3.  Counts of equal-depth splitting pairs at positions `t = 3, 4, 5` among odd legs
    below a bound (evidence for the open infinitude/density conjecture).

Usage:  python3 price_two_adic_depth_family_check.py [bound]
"""

import sys


def parent(m, n):
    if n % 2 == 0:
        return (m - n // 2, n // 2)
    if 2 * n < m:
        return (m // 2, m // 2 - n)
    return (m // 2, n - m // 2)


def address(m, n):
    """Price address of (m, n), read from the root."""
    w = []
    while (m, n) != (2, 1):
        if n % 2 == 0:
            w.append('A')
        elif 2 * n < m:
            w.append('B')
        else:
            w.append('C')
        m, n = parent(m, n)
    return ''.join(reversed(w))


def letter_at(m, n, t):
    """The letter at position t counted from the leaf."""
    for _ in range(t):
        m, n = parent(m, n)
    if n % 2 == 0:
        return 'A'
    return 'B' if 2 * n < m else 'C'


def v2(x):
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


def gcd(a, b):
    while b:
        a, b = b, a % b
    return a


def check_family(smax=30):
    bad = 0
    for s in range(smax + 1):
        t = s + 3
        dsM = 2 ** (s + 4) * (3 * 2 ** (s + 1) + 1)
        X = (2 ** (s + 4) + 1, 2 ** (s + 3))
        Y = (dsM + 1, dsM)
        aX, aY = address(*X), address(*Y)
        ok = (X[0] ** 2 - X[1] ** 2 == Y[0] ** 2 - Y[1] ** 2
              and len(aX) == len(aY) == 2 * s + 6
              and aX == 'A' * (s + 2) + 'B' + 'A' * (s + 3)
              and aY == 'C' + 'A' * s + 'C' + 'A' * (s + 4)
              and all(letter_at(*X, u) == 'A' == letter_at(*Y, u) for u in range(t))
              and letter_at(*X, t) != 'A' and letter_at(*Y, t) == 'A')
        if not ok:
            bad += 1
            print("  EXCEPTION at s =", s)
    print("family check: s = 0 ..", smax, "-> exceptions:", bad)


def nodes_of(N):
    out = []
    a = 1
    while a * a < N:
        if N % a == 0:
            b = N // a
            if gcd(a, b) == 1:
                out.append(((a + b) // 2, (b - a) // 2))
        a += 2
    return out


def scan(bound):
    smallest = {}
    counts = {3: 0, 4: 0, 5: 0}
    for N in range(3, bound, 2):
        info = [(m, n, v2(n), len(address(m, n))) for (m, n) in nodes_of(N)]
        for (m1, n1, t1, d1) in info:
            for (m2, n2, t2, d2) in info:
                if t2 > t1 >= 2 and d1 == d2:
                    if t1 not in smallest:
                        smallest[t1] = (N, (m1, n1), (m2, n2), d1)
                    if t1 in counts:
                        counts[t1] += 1
    print("smallest equal-depth splitting pair per position (odd legs <", bound, "):")
    for t in sorted(smallest):
        print("  t =", t, "->", smallest[t])
    print("counts of equal-depth splitting pairs:", counts)


def check_pos2_family(jmax=30):
    """The position-2 family C A^j C A^2 versus B A^(j+3)."""
    bad = 0
    for j in range(jmax + 1):
        c = 3 * 2 ** (j + 1) + 1
        X = (4 * c + 1, 4 * c)
        Y = (2 ** (j + 3) + 3, 2 ** (j + 3))
        aX, aY = address(*X), address(*Y)
        ok = (X[0] ** 2 - X[1] ** 2 == Y[0] ** 2 - Y[1] ** 2 == 3 * 2 ** (j + 4) + 9
              and aX == 'C' + 'A' * j + 'C' + 'AA' and aY == 'B' + 'A' * (j + 3)
              and len(aX) == len(aY) == j + 4
              and all(letter_at(*X, u) == 'A' == letter_at(*Y, u) for u in range(2))
              and letter_at(*X, 2) != 'A' and letter_at(*Y, 2) == 'A')
        if not ok:
            bad += 1
            print("  EXCEPTION at j =", j)
    print("position-2 family check: j = 0 ..", jmax, "-> exceptions:", bad)


if __name__ == '__main__':
    bound = int(sys.argv[1]) if len(sys.argv) > 1 else 100001
    check_family()
    check_pos2_family()
    scan(bound)


"""Counts of same-odd-leg splitting pairs, and of those with equal depth.

For each position t = 2..5 we group all valid Euclid pairs (m,n) with m < 600 by their odd
leg N = m^2 - n^2 and count the pairs of distinct nodes of depth > t whose addresses agree
(in A-ness) at every position u < t and disagree at position t; among those we count the
ones whose depths coincide.  The smallest equal-depth instance is the witness used in
Probability/PriceTwoAdicSealingDensity.lean (pos2_split_equal_depth).
"""
from math import gcd
from collections import defaultdict

def valid(m, n): return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1
def letter(m, n):
    if n % 2 == 0: return 'A'
    return 'B' if 2 * n < m else 'C'
def parent(m, n):
    if n % 2 == 0: return (m - n // 2, n // 2)
    if 2 * n < m: return (m // 2, m // 2 - n)
    return (m // 2, n - m // 2)
def depth(m, n):
    d = 0
    while (m, n) != (2, 1):
        m, n = parent(m, n); d += 1
    return d
def letterAt(m, n, t):
    for _ in range(t): m, n = parent(m, n)
    return letter(m, n)

nodes = [(m, n) for m in range(2, 600) for n in range(1, m) if valid(m, n)]
by = defaultdict(list)
for (m, n) in nodes:
    by[m * m - n * n].append((m, n))

for t in range(2, 6):
    total = eq = 0
    example = None
    for N, lst in by.items():
        for i in range(len(lst)):
            for j in range(i + 1, len(lst)):
                p, q = lst[i], lst[j]
                if depth(*p) > t and depth(*q) > t \
                   and all((letterAt(*p, u) == 'A') == (letterAt(*q, u) == 'A') for u in range(t)) \
                   and (letterAt(*p, t) == 'A') != (letterAt(*q, t) == 'A'):
                    total += 1
                    if depth(*p) == depth(*q):
                        eq += 1
                        if example is None:
                            example = (N, p, q, depth(*p))
    print(f"t={t}: splitting pairs {total}, equal depth {eq}, smallest equal-depth {example}")


"""Check of the two-parameter twin family famX/famY (Probability/PriceTwoAdicSealingDensity.lean).

For s = 0..7 (position t = s+2) and v = 0..30 we verify:
  * famX s v and famY s v are valid Euclid parameter pairs,
  * they have the same odd leg N = famN s v = 2^(s+3)*K + 1,
  * both have depth > t in the Price tree,
  * their addresses are all-A at every position u < t and disagree at position t,
  * famN s v is strictly increasing in v.
"""
from math import gcd

def valid(m, n): return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1
def letter(m, n):
    if n % 2 == 0: return 'A'
    return 'B' if 2 * n < m else 'C'
def parent(m, n):
    if n % 2 == 0: return (m - n // 2, n // 2)
    if 2 * n < m: return (m // 2, m // 2 - n)
    return (m // 2, n - m // 2)
def depth(m, n):
    d = 0
    while (m, n) != (2, 1):
        m, n = parent(m, n); d += 1
        if d > 500: raise Exception("loop")
    return d
def letterAt(m, n, t):
    for _ in range(t): m, n = parent(m, n)
    return letter(m, n)
def oddleg(m, n): return m * m - n * n

def famK(s, v): return 2 ** (s + 1) * (4 * v * v + 12 * v + 5) + (2 * v + 3)
def famN(s, v): return 2 ** (s + 3) * famK(s, v) + 1
def famX(s, v): return (2 ** (s + 2) * famK(s, v) + 1, 2 ** (s + 2) * famK(s, v))
def famY(s, v): return (2 ** (s + 2) * (2 * v + 3) + 1, 2 ** (s + 3))

bad = 0
checked = 0
for s in range(8):
    t = s + 2
    prev = -1
    for v in range(31):
        X, Y = famX(s, v), famY(s, v)
        N = famN(s, v)
        ok = (valid(*X) and valid(*Y) and oddleg(*X) == N and oddleg(*Y) == N
              and depth(*X) > t and depth(*Y) > t
              and all((letterAt(*X, u) == 'A') == (letterAt(*Y, u) == 'A') for u in range(t))
              and (letterAt(*X, t) == 'A') != (letterAt(*Y, t) == 'A')
              and N > prev)
        prev = N
        checked += 1
        if not ok:
            bad += 1
            print("FAIL", s, v, X, Y, N)
print("family instances checked:", checked, "exceptions:", bad)
print("sample odd legs (t=2):", [famN(0, v) for v in range(6)])
