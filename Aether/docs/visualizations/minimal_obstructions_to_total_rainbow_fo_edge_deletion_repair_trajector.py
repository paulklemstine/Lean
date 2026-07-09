import math
import matplotlib.pyplot as plt

def has_cycle(edges):
    parent = {}
    def find(x):
        parent.setdefault(x, x)
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for e in edges:
        u, v = tuple(e); ru, rv = find(u), find(v)
        if ru == rv: return True
        parent[ru] = rv
    return False

n = 6
edges = [frozenset((i, (i+1) % n)) for i in range(n)]
remaining = list(edges)
steps, mono = [], []
for step in range(len(edges) + 1):
    steps.append(step)
    mono.append(1 if has_cycle(remaining) else 0)  # single color -> mono cycle iff cycle
    if remaining:
        remaining = remaining[1:]  # delete one edge

plt.figure(figsize=(8, 4))
plt.step(steps, mono, where="post", color="#e6194B", lw=2)
plt.yticks([0, 1], ["no mono cycle\n(admits TRF)", "has mono cycle"])
plt.xlabel("number of edges deleted from monochromatic C_6")
plt.title("A Single Deletion Repairs a Minimal Obstruction")
plt.grid(alpha=.3); plt.tight_layout(); plt.savefig("repair_trajectory.png", dpi=150)
print("saved repair_trajectory.png")
