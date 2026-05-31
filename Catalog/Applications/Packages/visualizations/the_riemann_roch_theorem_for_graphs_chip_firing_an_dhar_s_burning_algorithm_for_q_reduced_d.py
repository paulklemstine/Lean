def q_reduce(G, D, q=0):
    D_vals = list(D.values)
    for _ in range(10000):
        for __ in range(10000):
            worst_v = -1; worst_val = 0
            for v in range(G.n):
                if v == q: continue
                if D_vals[v] < worst_val: worst_v = v; worst_val = D_vals[v]
            if worst_v == -1: break
            v = worst_v
            times = (-D_vals[v] + G.degree(v) - 1) // G.degree(v)
            D_vals[v] += times * G.degree(v)
            for w in G.adj[v]: D_vals[w] -= times
        burnt = {q}; changed = True
        while changed:
            changed = False
            for v in range(G.n):
                if v in burnt: continue
                etb = sum(1 for w in G.adj[v] if w in burnt)
                if etb > D_vals[v]: burnt.add(v); changed = True
        if len(burnt) == G.n: break
        for v in range(G.n):
            if v not in burnt:
                D_vals[v] -= G.degree(v)
                for w in G.adj[v]: D_vals[w] += 1
    return D_vals