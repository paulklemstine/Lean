import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def iterate(step, n, x):
    for _ in range(n): x = step[x]
    return x

step = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
states = list(range(6))
N = 25
counts = [sum(1 for x in states if iterate(step, n, x) == x) for n in range(N)]

fig, ax = plt.subplots(figsize=(10, 5))
ax.bar(range(N), counts, color='steelblue', alpha=0.8)
ax.set_xlabel('Iteration n', fontsize=13)
ax.set_ylabel('Periodic point count p_n', fontsize=13)
ax.set_title('Periodic Point Counts — 6-State System (3-cycle + 2-cycle + fixpt)', fontsize=14)
ax.set_xticks(range(0, N, 2))
ax.axhline(y=len(states), color='red', linestyle='--', alpha=0.5, label=f'|α| = {len(states)}')
ax.legend(fontsize=12)
plt.tight_layout()
plt.savefig('periodic_counts.png', dpi=150)
print('Saved periodic_counts.png')