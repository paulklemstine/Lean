import networkx as nx
import numpy as np

def simulate_hitting_time(G, start, targets, max_steps=10000, trials=2000, seed=42):
    """Estimate expected hitting time via Monte Carlo simulation."""
    rng = np.random.RandomState(seed)
    times = []
    for _ in range(trials):
        v = start
        steps = 0
        while v not in targets and steps < max_steps:
            nbrs = list(G.neighbors(v))
            if not nbrs: break
            v = nbrs[rng.randint(len(nbrs))]
            steps += 1
        times.append(steps)
    return np.mean(times)

# Lollipop graph demo
def lollipop(m, n):
    G = nx.Graph()
    for i in range(m):
        G.add_edge(i, (i+1) % m)
    if n > 0:
        G.add_edge(0, m)
        for i in range(m, m+n-1):
            G.add_edge(i, i+1)
    return G

for m in [3, 5, 8, 12]:
    G = lollipop(m, 3)
    target = {m + 2}
    ht_cycle = simulate_hitting_time(G, m//2, target)
    ht_tail = simulate_hitting_time(G, m, target)
    print(f"C{m}+P3: cycle_ht={ht_cycle:.1f}, tail_ht={ht_tail:.1f}, ratio={ht_cycle/ht_tail:.2f}")
