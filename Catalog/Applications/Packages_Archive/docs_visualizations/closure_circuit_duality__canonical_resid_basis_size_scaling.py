import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import random
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

def find_minimal_supports(cl_func, target, universe):
    supports = []
    for size in range(len(universe) + 1):
        for combo in combinations(universe, size):
            candidate = frozenset(combo)
            if target in cl_func(candidate):
                is_minimal = all(not (prev < candidate) for prev in supports)
                if is_minimal:
                    for sub_size in range(size):
                        for sub in combinations(combo, sub_size):
                            if target in cl_func(frozenset(sub)):
                                is_minimal = False; break
                        if not is_minimal: break
                if is_minimal:
                    supports.append(candidate)
    return supports

sizes = range(3, 8)
avg_basis_sizes = []
random.seed(42)

for n in sizes:
    universe = [str(i) for i in range(n)]
    total = 0
    trials = 5
    for _ in range(trials):
        rules = []
        for _ in range(n):
            k = random.randint(1, min(3, n-1))
            premises = frozenset(random.sample(universe, k))
            conclusion = random.choice(universe)
            rules.append((premises, conclusion))
        cl = lambda s, r=rules: generated_closure(r, s)
        basis_size = sum(len(find_minimal_supports(cl, x, universe)) for x in universe)
        total += basis_size
    avg_basis_sizes.append(total / trials)

fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(list(sizes), avg_basis_sizes, color="steelblue", edgecolor="navy")
ax.set_xlabel("Universe Size", fontsize=12)
ax.set_ylabel("Average Canonical Basis Size", fontsize=12)
ax.set_title("Canonical Basis Size vs Universe Size\n(Random rank-3 closure systems, 5 trials each)", fontsize=13)
plt.tight_layout()
plt.savefig("basis_scaling.png", dpi=150)
print("Saved basis_scaling.png")