import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from itertools import combinations

def generated_closure(rules, seed):
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)

universe = ["A", "B", "C", "D"]
rules = [
    (frozenset({"A", "B"}), "C"),
    (frozenset({"C"}), "D"),
]

closed_sets = set()
for size in range(len(universe) + 1):
    for combo in combinations(universe, size):
        s = frozenset(combo)
        cl_s = generated_closure(rules, s)
        closed_sets.add(cl_s)

closed_list = sorted(closed_sets, key=lambda s: (len(s), sorted(s)))
levels = {}
for s in closed_list:
    k = len(s)
    if k not in levels:
        levels[k] = []
    levels[k].append(s)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))
positions = {}
for k, sets_at_k in levels.items():
    n = len(sets_at_k)
    for i, s in enumerate(sets_at_k):
        x = (i - (n - 1) / 2) * 2.5
        y = k * 2
        positions[s] = (x, y)

for s in closed_list:
    for t in closed_list:
        if s < t and not any(s < u < t for u in closed_list):
            sx, sy = positions[s]
            tx, ty = positions[t]
            ax.plot([sx, tx], [sy, ty], "k-", alpha=0.3, linewidth=1)

for s in closed_list:
    x, y = positions[s]
    label = "{" + ",".join(sorted(s)) + "}" if s else "{}"
    ax.scatter(x, y, s=800, c="steelblue", zorder=5, edgecolors="navy", linewidth=1.5)
    ax.annotate(label, (x, y), ha="center", va="center", fontsize=7, fontweight="bold", color="white")

ax.set_title("Hasse Diagram of Closed Sets\n(Rules: {A,B}->C, {C}->D)", fontsize=14)
ax.axis("off")
plt.tight_layout()
plt.savefig("closure_lattice.png", dpi=150)
print("Saved closure_lattice.png")