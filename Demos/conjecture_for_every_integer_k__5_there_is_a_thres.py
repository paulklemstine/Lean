import itertools, sys
from functools import lru_cache

def dists(n, adj, q):
    import collections
    d = {q:0}; dq = collections.deque([q])
    while dq:
        v = dq.popleft()
        for u in adj[v]:
            if u not in d:
                d[u] = d[v]+1; dq.append(u)
    return [d[i] for i in range(n)]

def fire(D, S, adj):
    D = list(D)
    for v in S:
        for u in adj[v]:
            if u not in S:
                D[v] -= 1; D[u] += 1
    return D

def reduce_div(D, n, adj, q, dist):
    D = list(D)
    maxd = max(dist)
    # phase 1: make nonneg off q, from farthest level inward
    for i in range(maxd, 0, -1):
        level = [v for v in range(n) if dist[v]==i]
        ball = [v for v in range(n) if dist[v] <= i-1]
        while any(D[v] < 0 for v in level):
            D = fire(D, set(ball), adj)
    # phase 2: Dhar
    while True:
        burnt = {q}
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if v not in burnt:
                    c = sum(1 for u in adj[v] if u in burnt)
                    if c > D[v]:
                        burnt.add(v); changed = True
        if len(burnt) == n:
            return D
        S = set(range(n)) - burnt
        D = fire(D, S, adj)

def equiv_effective(D, n, adj, q, dist):
    R = reduce_div(D, n, adj, q, dist)
    return R[q] >= 0

def effective_divs(n, d):
    # compositions of d into n nonneg parts
    for c in itertools.combinations(range(d+n-1), n-1):
        prev = -1; out = []
        for x in c:
            out.append(x-prev-1); prev = x
        out.append(d+n-1-prev-1)
        yield out

def rank_at_least(D, r, n, adj, q, dist):
    if r == 0:
        return equiv_effective(D, n, adj, q, dist)
    for E in effective_divs(n, r):
        if not equiv_effective([D[i]-E[i] for i in range(n)], n, adj, q, dist):
            return False
    return True

def rank(D, n, adj, q, dist):
    r = -1
    while True:
        if rank_at_least(D, r+1, n, adj, q, dist):
            r += 1
        else:
            return r

def complete(n):
    return [[u for u in range(n) if u!=v] for v in range(n)]

def graph_from_edges(n, edges):
    adj = [[] for _ in range(n)]
    for a,b in edges:
        adj[a].append(b); adj[b].append(a)
    return adj


from bn_rank import *
def circ(n, S):
    edges=set()
    for v in range(n):
        for s in S:
            u=(v+s)%n
            if u!=v: edges.add(tuple(sorted((v,u))))
    return graph_from_edges(n,sorted(edges))
def info(name, n, adj, cand=None):
    q=0;dist=dists(n,adj,q)
    degs=[len(a) for a in adj]; k=degs[0]; assert all(d==k for d in degs), degs
    E=sum(degs)//2; g=E-n+1; d=g-1
    m=(k-2)//2
    if cand is None:
        base=[m]*n; extra=d-m*n
        i=0
        while extra>0:
            base[i%n]+=1; extra-=1; i+=1
        cand=base
    assert sum(cand)==d,(cand,d)
    r=rank(cand,n,adj,q,dist)
    print(f"{name}: n={n} k={k} g={g} deg=g-1={d}  D={cand}  rank={r}   ourbound={2*m if m>=1 else m}  target k-1={k-1}")
if __name__=="__main__":
    info("K6", 6, complete(6))
    info("C8(1,2,4)", 8, circ(8,[1,2,4]))
    info("K55", 10, graph_from_edges(10,[(i,5+j) for i in range(5) for j in range(5)]))
    info("C10(1,2,5)", 10, circ(10,[1,2,5]))
    info("K7", 7, complete(7))
    info("C8(1,2,3)", 8, circ(8,[1,2,3]))
    info("C9(1,2,3)", 9, circ(9,[1,2,3]))
    info("K8", 8, complete(8))
