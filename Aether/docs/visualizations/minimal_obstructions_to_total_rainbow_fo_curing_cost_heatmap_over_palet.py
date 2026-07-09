import random
import matplotlib.pyplot as plt

def components(edges):
    vs = set()
    for e in edges: vs.update(e)
    parent = {v: v for v in vs}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for e in edges:
        u, v = tuple(e); parent[find(u)] = find(v)
    return len({find(v) for v in vs})

def min_deletions(colored):
    by_color = {}
    for e, k in colored.items():
        by_color.setdefault(k, set()).add(e)
    tot = 0
    for c in by_color.values():
        vs = set()
        for e in c: vs.update(e)
        tot += len(c) - len(vs) + components(c)
    return tot

def experiment(n=8, trials=200):
    base = [frozenset((a, b)) for a in range(n) for b in range(a+1, n)]
    xs, ys = [], []
    for ncol in range(1, 13):
        acc = 0
        for _ in range(trials):
            colored = {e: random.randrange(ncol) for e in base}
            acc += min_deletions(colored)
        xs.append(ncol); ys.append(acc / trials)
    return xs, ys

xs, ys = experiment()
plt.figure(figsize=(8, 5))
plt.plot(xs, ys, "o-", color="#4363d8")
plt.xlabel("number of colors in palette")
plt.ylabel("avg. min deletions to remove all mono cycles  (K_8)")
plt.title("More Colors, Fewer Forced Monochromatic Cycles")
plt.grid(alpha=.3); plt.tight_layout(); plt.savefig("curing_cost.png", dpi=150)
print("saved curing_cost.png")
