"""Computational evidence for the classification of ternary Pythagorean trees.

Node set N = {(m,n) : 1 <= n < m, gcd(m,n)=1, m+n odd}, root (2,1).
A map M = (a,b,c,d) acts by (m,n) |-> (a m + b n, c m + d n).
"""
from math import gcd
from itertools import product, combinations

LIM = 600
nodes = [(m, n) for m in range(2, LIM + 1) for n in range(1, m)
         if gcd(m, n) == 1 and (m + n) % 2 == 1]
nodeset = set(nodes)


def isnode(m, n):
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def is_pow2(x):
    x = abs(x)
    return x != 0 and (x & (x - 1)) == 0


def predicted(M):
    """The formal characterisation `Admissible` proved in Basic.lean."""
    a, b, c, d = M
    return ((a + c) % 2 == 1 and (b + d) % 2 == 1 and is_pow2(a * d - b * c)
            and c >= 0 and c + d >= 0 and (c, d) != (0, 0)
            and a - c >= 0 and (a - c) + (b - d) >= 0 and (a - c, b - d) != (0, 0))


def brute_preserves(M, bound=120):
    a, b, c, d = M
    for (m, n) in nodes:
        if m > bound:
            break
        if not isnode(a * m + b * n, c * m + d * n):
            return False
    return True


print("=== Table 1: admissible matrices with |entries| <= R ===")
print("R  #admissible  det multiset (|det| values)")
for R in range(1, 9):
    cs = [M for M in product(range(-R, R + 1), repeat=4) if predicted(M)]
    dets = sorted({abs(M[0] * M[3] - M[1] * M[2]) for M in cs})
    print("%d  %5d        %s" % (R, len(cs), dets))

print()
print("=== Table 2: characterisation vs brute force (|entries| <= 6) ===")
R = 6
mismatch = 0
tested = 0
for M in product(range(-R, R + 1), repeat=4):
    p = predicted(M)
    b = brute_preserves(M)
    tested += 1
    if p != b:
        mismatch += 1
        print("MISMATCH", M, p, b)
print("tested %d matrices, mismatches: %d" % (tested, mismatch))

print()
print("=== Table 3: odd-prime obstruction ===")
print("smallest node killed by a map of determinant 3*k (sample)")
for M in [(3, 0, 1, 1), (1, 3, 0, 3), (3, 3, 1, 2), (5, 0, 1, 1)]:
    a, b, c, d = M
    det = a * d - b * c
    bad = None
    for (m, n) in nodes[:4000]:
        if not isnode(a * m + b * n, c * m + d * n):
            bad = (m, n)
            break
    print("M=%s det=%d  first killed node: %s" % (str(M), det, bad))

print()
print("=== Table 4: exhaustive tree search ===")
R = 8
cands = [M for M in product(range(-R, R + 1), repeat=4) if predicted(M)]
B = 200
target = set((m, n) for (m, n) in nodes if m <= B and (m, n) != (2, 1))


def image(M, B):
    a, b, c, d = M
    s = set()
    for (m, n) in nodes:
        if m > B:
            break
        if a * m + b * n <= B:
            s.add((a * m + b * n, c * m + d * n))
    return s


imgs = {M: image(M, B) for M in cands}
cands = [M for M in cands if imgs[M] <= target]
print("candidates with |entries| <= %d: %d; surviving the image test: %d"
      % (R, len([M for M in product(range(-R, R + 1), repeat=4) if predicted(M)]), len(cands)))
found = []
for T in combinations(cands, 3):
    s1, s2, s3 = (imgs[M] for M in T)
    if len(s1) + len(s2) + len(s3) != len(target):
        continue
    if s1 | s2 | s3 == target:
        found.append(T)
for T in found:
    dets = [M[0] * M[3] - M[1] * M[2] for M in T]
    areas = [1 / (M[0] * (M[0] + M[1])) for M in T]
    print("TREE", T, "dets", dets, "sum 1/(a(a+b)) =", sum(areas))
print("number of trees:", len(found))

print()
print("=== Table 5: first generations of each tree (first coordinate m) ===")
trees = {"Berggren": ((2, -1, 1, 0), (2, 1, 1, 0), (1, 2, 0, 1)),
         "Price": ((1, 1, 0, 2), (2, 0, 1, -1), (2, 0, 1, 1)),
         "Mixed": ((1, 3, 0, 2), (2, -1, 1, 0), (2, 0, 1, -1))}
for name, T in trees.items():
    gen = [(2, 1)]
    sizes = []
    allnodes = set(gen)
    for g in range(4):
        nxt = []
        for (m, n) in gen:
            for (a, b, c, d) in T:
                nxt.append((a * m + b * n, c * m + d * n))
        gen = nxt
        sizes.append(len(gen))
        allnodes |= set(gen)
    ok = all(isnode(m, n) for (m, n) in allnodes)
    print("%-9s generation sizes %s  all nodes: %s  distinct: %s"
          % (name, sizes, ok, len(allnodes) == 1 + 3 + 9 + 27 + 81))


from math import gcd
from itertools import product

LIM = 400
nodes = [(m,n) for m in range(2, LIM+1) for n in range(1, m) if gcd(m,n)==1 and (m+n)%2==1]
nodeset = set(nodes)

def preserves(M, bound=200):
    a,b,c,d = M
    for (m,n) in nodes:
        if m > bound: break
        mm, nn = a*m+b*n, c*m+d*n
        if not (1 <= nn < mm and gcd(mm,nn)==1 and (mm+nn)%2==1):
            return False
    return True

R = 4
cands = []
for M in product(range(-R,R+1), repeat=4):
    a,b,c,d = M
    det = a*d-b*c
    if det == 0: continue
    if preserves(M):
        cands.append((M, det))
print("num candidates entries<=%d:"%R, len(cands))
for M,det in cands:
    print(M, "det", det)


from math import gcd
from itertools import product, combinations

LIM = 400
nodes = [(m,n) for m in range(2, LIM+1) for n in range(1, m) if gcd(m,n)==1 and (m+n)%2==1]
nodeset = set(nodes)

def preserves(M, bound=200):
    a,b,c,d = M
    for (m,n) in nodes:
        if m > bound: break
        mm, nn = a*m+b*n, c*m+d*n
        if not (1 <= nn < mm and gcd(mm,nn)==1 and (mm+nn)%2==1):
            return False
    return True

def is_pow2(x):
    x = abs(x)
    return x != 0 and (x & (x-1)) == 0

def predicted(M):
    a,b,c,d = M
    return ((a+c)%2==1 and (b+d)%2==1 and is_pow2(a*d-b*c)
            and c>=0 and c+d>=0 and (c,d)!=(0,0)
            and a-c>=0 and (a-c)+(b-d)>=0 and (a-c,b-d)!=(0,0))

R = 4
cands = []
mismatch = []
for M in product(range(-R,R+1), repeat=4):
    p = preserves(M)
    q = predicted(M)
    if p != q: mismatch.append((M,p,q))
    if p: cands.append(M)
print("characterization mismatches:", mismatch)
print("candidates:", len(cands))

# tree search: images of nodes with m <= B must partition nodes\{(2,1)} restricted to m<=B
B = 120
target = set((m,n) for (m,n) in nodes if m <= B and (m,n)!=(2,1))
def image(M, B):
    a,b,c,d = M
    s = set()
    for (m,n) in nodes:
        mm,nn = a*m+b*n, c*m+d*n
        if mm <= B: s.add((mm,nn))
        if m > B: break
    return s

imgs = {M: image(M,B) for M in cands}
found = []
for T in combinations(cands, 3):
    s1,s2,s3 = (imgs[M] for M in T)
    if s1 & s2 or s1 & s3 or s2 & s3: continue
    if s1|s2|s3 == target:
        found.append(T)
for T in found:
    print("TREE:", T, [M[0]*M[3]-M[1]*M[2] for M in T])
print("num trees:", len(found))


from math import gcd
from itertools import product, combinations

LIM = 600
nodes = [(m,n) for m in range(2, LIM+1) for n in range(1, m) if gcd(m,n)==1 and (m+n)%2==1]

def is_pow2(x):
    x = abs(x)
    return x != 0 and (x & (x-1)) == 0

def predicted(M):
    a,b,c,d = M
    return ((a+c)%2==1 and (b+d)%2==1 and is_pow2(a*d-b*c)
            and c>=0 and c+d>=0 and (c,d)!=(0,0)
            and a-c>=0 and (a-c)+(b-d)>=0 and (a-c,b-d)!=(0,0))

R = 8
cands = [M for M in product(range(-R,R+1), repeat=4) if predicted(M)]
print("candidates entries<=%d:"%R, len(cands))

B = 200
target = set((m,n) for (m,n) in nodes if m <= B and (m,n)!=(2,1))
def image(M, B):
    a,b,c,d = M
    s = set()
    for (m,n) in nodes:
        if a*m+b*n <= B: s.add((a*m+b*n, c*m+d*n))
        if m > B: break
    return s
imgs = {M: image(M,B) for M in cands}
# prune: only maps whose image is a subset of target
cands = [M for M in cands if imgs[M] <= target]
print("after prune:", len(cands))
found = []
for T in combinations(cands, 3):
    s1,s2,s3 = (imgs[M] for M in T)
    if len(s1)+len(s2)+len(s3) != len(target): continue
    if s1|s2|s3 == target:
        found.append(T)
for T in found:
    print("TREE:", T, [M[0]*M[3]-M[1]*M[2] for M in T],
          ["1/(a(a+b))=%s"%(1/(M[0]*(M[0]+M[1]))) for M in T])
print("num trees:", len(found))
