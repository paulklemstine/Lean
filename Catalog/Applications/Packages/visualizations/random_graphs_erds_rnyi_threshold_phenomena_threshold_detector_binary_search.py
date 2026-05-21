import random
from collections import defaultdict

def threshold_detector(n, test_fn, trials=200, tol=1e-3):
    lo, hi = 0.0, 1.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        count = sum(1 for _ in range(trials) if test_fn(n, mid))
        if count / trials < 0.5: lo = mid
        else: hi = mid
    return (lo + hi) / 2

def test_connected(n, p):
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i+1, n):
            if random.random() < p:
                adj[i].add(j); adj[j].add(i)
    visited = set(); stack = [0]
    while stack:
        u = stack.pop()
        if u not in visited:
            visited.add(u); stack.extend(adj[u] - visited)
    return len(visited) == n

random.seed(42)
import math
n = 100
p_est = threshold_detector(n, test_connected)
print(f"Detected: {p_est:.4f}, Theory: {math.log(n)/n:.4f}")