import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
import numpy as np

def count_perfect_powers(N):
    powers = set()
    for e in range(2, max(3, int(math.log2(N)) + 1)):
        b = 2
        while b ** e <= N:
            powers.add(b ** e); b += 1
    return len(powers)

def find_pillai_solutions(k, max_base=200, max_exp=15):
    powers = {}
    for base in range(2, max_base + 1):
        for exp in range(2, max_exp + 1):
            val = base ** exp
            if val > max_base ** max_exp: break
            if val not in powers: powers[val] = []
            powers[val].append((base, exp))
    solutions = []
    for val, reps in powers.items():
        target = val - k
        if target in powers and target > 0:
            for x, a in reps:
                for y, b in powers[target]: solutions.append((x, a, y, b))
    return solutions

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
ax = axes[0, 0]
for e in [2, 3, 4, 5]:
    bs = list(range(2, 51))
    gaps = [(b + 1) ** e - b ** e for b in bs]
    ax.plot(bs, gaps, label=f'e = {e}', linewidth=2)
ax.set_xlabel('Base b'); ax.set_ylabel('Gap'); ax.set_title('Power Gap Growth')
ax.legend(); ax.set_yscale('log'); ax.grid(True, alpha=0.3)

ax = axes[0, 1]
Ns = list(range(10, 10001, 10))
counts = [count_perfect_powers(N) for N in Ns]
sqrts = [int(math.sqrt(N)) - 1 for N in Ns]
ax.plot(Ns, counts, 'b-', label='pi_PP(N)'); ax.plot(Ns, sqrts, 'r--', label='sqrt(N)-1')
ax.set_xlabel('N'); ax.set_ylabel('Count'); ax.set_title('Perfect Power Counting'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[1, 0]
ks = list(range(1, 51))
solution_counts = [len(find_pillai_solutions(k)) for k in ks]
colors = ['red' if c == 0 else 'steelblue' for c in solution_counts]
ax.bar(ks, solution_counts, color=colors, alpha=0.8)
ax.set_xlabel('Gap k'); ax.set_ylabel('Solutions'); ax.set_title('Pillai Solutions by k'); ax.grid(True, alpha=0.3, axis='y')

ax = axes[1, 1]
N = 200
powers_set = set()
for e in range(2, 8):
    b = 2
    while b ** e <= N: powers_set.add(b ** e); b += 1
powers_list = sorted(powers_set)
gaps = [powers_list[i+1] - powers_list[i] for i in range(len(powers_list)-1)]
ax.scatter(range(1, len(gaps)+1), gaps, c='navy', s=30, alpha=0.7)
ax.set_xlabel('Index'); ax.set_ylabel('Gap'); ax.set_title('Gaps Between Perfect Powers'); ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('pillai_visualization.png', dpi=150)
print('Saved pillai_visualization.png')