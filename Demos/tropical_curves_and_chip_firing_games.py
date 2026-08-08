import itertools
from collections import deque

def complete(n): return [[j for j in range(n) if j!=i] for i in range(n)]
def cycle(n): return [[(i-1)%n,(i+1)%n] for i in range(n)]
def path(n): return [[j for j in [i-1,i+1] if 0<=j<n] for i in range(n)]
def star(n): return [[j for j in range(1,n)] if i==0 else [0] for i in range(n)]
def theta():  # two vertices joined by 3 paths of length 2 -> genus 2
    # vertices: 0,1 hubs; 2,3,4 midpoints
    return [[2,3,4],[2,3,4],[0,1],[0,1],[0,1]]
def petersen():
    outer=[(i,(i+1)%5) for i in range(5)]
    spokes=[(i,i+5) for i in range(5)]
    inner=[(5+i,5+(i+2)%5) for i in range(5)]
    adj=[[] for _ in range(10)]
    for a,b in outer+spokes+inner: adj[a].append(b); adj[b].append(a)
    return adj

def edges(adj): return sum(len(a) for a in adj)//2
def genus(adj): return edges(adj)-len(adj)+1
def canonical(adj): return [len(a)-2 for a in adj]

def dists(adj,q):
    n=len(adj); d=[-1]*n; d[q]=0; Q=deque([q])
    while Q:
        v=Q.popleft()
        for w in adj[v]:
            if d[w]<0: d[w]=d[v]+1; Q.append(w)
    return d

def qreduce(adj,D,q):
    n=len(adj); D=list(D); d=dists(adj,q)
    for i in range(max(d),0,-1):
        S=set(v for v in range(n) if d[v]>=i)
        guard=0
        while any(D[v]<0 for v in range(n) if d[v]==i):
            guard+=1
            if guard>10**6: raise Exception("stage1 diverged")
            for v in list(S):
                gain=sum(1 for w in adj[v] if w not in S)
                D[v]+=gain
            for v in range(n):
                if v not in S:
                    D[v]-=sum(1 for w in adj[v] if w in S)
    while True:
        burnt={q}; changed=True
        while changed:
            changed=False
            for v in range(n):
                if v in burnt: continue
                if D[v] < sum(1 for w in adj[v] if w in burnt):
                    burnt.add(v); changed=True
        S=set(v for v in range(n) if v not in burnt)
        if not S: break
        for v in list(S):
            D[v]-=sum(1 for w in adj[v] if w not in S)
        for v in range(n):
            if v not in S:
                D[v]+=sum(1 for w in adj[v] if w in S)
    return D

def winnable(adj,D,q=0):
    return qreduce(adj,D,q)[0 if q==0 else q][0] if False else qreduce(adj,D,q)[q]>=0

def effectives(n,k):
    if n==1: yield [k]; return
    for first in range(k+1):
        for rest in effectives(n-1,k-first): yield [first]+rest

def rank(adj,D):
    n=len(adj)
    if not winnable(adj,list(D)): return -1
    k=0
    while True:
        k+=1
        if all(winnable(adj,[D[i]-E[i] for i in range(n)]) for E in effectives(n,k)):
            continue
        return k-1

names={}
for n in [2,3,4,5,6]: names[f"K_{n}"]=complete(n)
for n in [3,4,5,6]: names[f"C_{n}"]=cycle(n)
for n in [2,3,4,5]: names[f"P_{n}"]=path(n)
names["Star_5"]=star(5); names["Theta_3"]=theta(); names["Petersen"]=petersen()

print("== Table 1: genus, canonical degree, and rank of K ==")
print(f"{'graph':10}{'|V|':>4}{'|E|':>4}{'g':>4}{'degK':>6}{'r(K)':>6}{'g-1':>5}")
for nm,adj in names.items():
    K=canonical(adj); g=genus(adj)
    rk = rank(adj,K) if len(adj)<=6 else "-"
    print(f"{nm:10}{len(adj):>4}{edges(adj):>4}{g:>4}{sum(K):>6}{str(rk):>6}{g-1:>5}")

print()
print("== Table 2: exhaustive Riemann-Roch check  r(D)-r(K-D) = deg D - g + 1 ==")
for nm in ["K_3","K_4","C_3","C_4","P_3","P_4","Theta_3"]:
    adj=names[nm]; g=genus(adj); K=canonical(adj); n=len(adj); bad=0; tot=0
    rng=range(-2,4)
    for D in itertools.product(rng,repeat=n):
        tot+=1
        if rank(adj,list(D))-rank(adj,[K[i]-D[i] for i in range(n)]) != sum(D)-g+1: bad+=1
    print(f"  {nm:9} divisors tested {tot:6d}   RR violations = {bad}")

print()
print("== Table 3: nu_t on K_n for the standard ordering t(i)=i  (nu(i)=i-1) ==")
for n in [2,3,4,5,6]:
    adj=complete(n); nu=[i-1 for i in range(n)]
    print(f"  K_{n}: nu = {str(nu):20} deg(nu) = {sum(nu):3}  g-1 = {genus(adj)-1:3}  rank = {rank(adj,nu):3}  winnable = {winnable(adj,nu)}")

print()
print("== Table 4: Clifford  2 r(D) <= deg D  on special divisors ==")
for nm in ["K_4","C_5","Theta_3"]:
    adj=names[nm]; K=canonical(adj); n=len(adj); bad=0; best=None
    for D in itertools.product(range(-1,4),repeat=n):
        rD=rank(adj,list(D)); rKD=rank(adj,[K[i]-D[i] for i in range(n)])
        if rD>=0 and rKD>=0:
            if 2*rD>sum(D): bad+=1
            if best is None or 2*rD-sum(D)>best[0]: best=(2*rD-sum(D),list(D),rD,sum(D))
    print(f"  {nm:9} violations = {bad}, extremal 2r-deg = {best[0]} at D={best[1]} (r={best[2]}, deg={best[3]})")

print()
print("== Table 5: number of degree-(g-1) non-winnable classes vs spanning trees ==")
from fractions import Fraction
def spanning_trees(adj):
    n=len(adj)
    M=[[ (len(adj[i]) if i==j else -sum(1 for w in adj[i] if w==j)) for j in range(1,n)] for i in range(1,n)]
    M=[[Fraction(x) for x in r] for r in M]; det=Fraction(1)
    for i in range(len(M)):
        p=next((r for r in range(i,len(M)) if M[r][i]!=0),None)
        if p is None: return 0
        if p!=i: M[i],M[p]=M[p],M[i]; det=-det
        det*=M[i][i]; piv=M[i][i]
        for r in range(i+1,len(M)):
            f=M[r][i]/piv
            for c in range(i,len(M)): M[r][c]-=f*M[i][c]
    return int(det)
names["K_6"]=complete(6)
for nm in ["K_3","K_4","K_5","K_6","C_4","C_5","Theta_3"]:
    adj=names[nm]; n=len(adj); g=genus(adj)
    # count q-reduced divisors of degree g-1 that are non-winnable, q=0
    cnt=0
    if g-1>=0 and n<=6:
        # enumerate q-reduced reps: D(v)>=0 for v!=0, and D(0) determined by degree
        # non-winnable iff D(0) < 0 after reduction; enumerate all D with D(v) in [0, deg v] for v != 0
        for tail in itertools.product(*[range(0,n) for v in range(1,n)]):
            D=[g-1-sum(tail)]+list(tail)
            R=qreduce(adj,D,0)
            if R[0]<0 and R[1:]==list(tail): cnt+=1
    print(f"  {nm:9} g = {g:2}, spanning trees = {spanning_trees(adj):4}, non-winnable 0-reduced deg-(g-1) reps = {cnt}")


print()
print("== Table 6 (control): Riemann-Roch FAILS on a disconnected graph ==")
def components(adj):
    n=len(adj); seen=[False]*n; comps=[]
    for v in range(n):
        if seen[v]: continue
        c=[]; st=[v]; seen[v]=True
        while st:
            x=st.pop(); c.append(x)
            for w in adj[x]:
                if not seen[w]: seen[w]=True; st.append(w)
        comps.append(sorted(c))
    return comps

def winnable_gen(adj,D):
    for c in components(adj):
        idx={v:i for i,v in enumerate(c)}
        sub=[[idx[w] for w in adj[v]] for v in c]
        if not winnable(sub,[D[v] for v in c]): return False
    return True

def rank_gen(adj,D):
    n=len(adj)
    if not winnable_gen(adj,list(D)): return -1
    k=0
    while True:
        k+=1
        if all(winnable_gen(adj,[D[i]-E[i] for i in range(n)]) for E in effectives(n,k)):
            continue
        return k-1

adj=[[1],[0],[3],[2]]   # two disjoint edges 2K_2
g=genus(adj); K=canonical(adj); n=4; bad=0; tot=0
for D in itertools.product(range(-2,3),repeat=n):
    tot+=1
    if rank_gen(adj,list(D))-rank_gen(adj,[K[i]-D[i] for i in range(n)]) != sum(D)-g+1: bad+=1
print(f"  2K_2 (disconnected): |V|=4 |E|=2 g={g}; divisors tested {tot}, RR violations = {bad}")

print()
print("== Table 7: gonality  gon(G) = min { deg D : r(D) >= 1 }  (brute force over effective D) ==")
def gonality(adj):
    n=len(adj)
    d=0
    while d<=4*n:
        for D in effectives(n,d):
            if rank(adj,list(D))>=1: return d
        d+=1
    return None
print(f"{'graph':10}{'|V|':>4}{'g':>4}{'gon':>5}{'g+1':>5}{'floor((g+3)/2)':>16}")
for nm in ["K_2","K_3","K_4","K_5","C_3","C_4","C_5","C_6","P_2","P_3","P_4","P_5","Star_5","Theta_3"]:
    adj=names[nm]; g=genus(adj)
    print(f"{nm:10}{len(adj):>4}{g:>4}{gonality(adj):>5}{g+1:>5}{(g+3)//2:>16}")

print()
print("== Table 8: |Jac(G)| (0-reduced divisors of degree 0) vs spanning trees and the proved bound ==")
def jacobian_order(adj):
    n=len(adj)
    cnt=0
    for tail in itertools.product(*[range(0,len(adj[v])) for v in range(1,n)]):
        D=[-sum(tail)]+list(tail)
        if qreduce(adj,list(D),0)==D: cnt+=1
    return cnt
def degree_bound(adj):
    b=1
    for v in range(1,len(adj)): b*=len(adj[v])
    return b
print(f"{'graph':10}{'|V|':>4}{'g':>4}{'|Jac|':>7}{'tau(G)':>8}{'prod deg':>10}{'hyperelliptic':>15}")
for nm in ["K_2","K_3","K_4","K_5","C_3","C_4","C_5","C_6","P_3","P_4","Star_5","Theta_3"]:
    adj=names[nm]; g=genus(adj); j=jacobian_order(adj); t=spanning_trees(adj)
    hyp = "yes" if (g>=1 and gonality(adj)==2) else "no"
    print(f"{nm:10}{len(adj):>4}{g:>4}{j:>7}{t:>8}{degree_bound(adj):>10}{hyp:>15}")
