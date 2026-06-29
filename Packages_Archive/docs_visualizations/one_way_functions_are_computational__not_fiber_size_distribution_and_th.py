import matplotlib.pyplot as plt

domain = list(range(10)); f = lambda x: x % 4
ys = sorted(set(f(x) for x in domain))
fibers = {y: [x for x in domain if f(x) == y] for y in ys}
sizes = [len(fibers[y]) for y in ys]

fig, ax = plt.subplots(figsize=(8, 5))
colors = ['#e34a33' if s >= 2 else '#2b8cbe' for s in sizes]
ax.bar([str(y) for y in ys], sizes, color=colors)
ax.axhline(1.5, ls='--', color='gray', label='collision threshold (size >= 2)')
ax.set_xlabel('output value y'); ax.set_ylabel('fiber size |f^-1(y)|')
ax.set_title(f'Fiber partition: sum of sizes = {sum(sizes)} = |domain|')
ax.legend()
fig.tight_layout(); fig.savefig('fiber_sizes.png', dpi=150)
print('wrote fiber_sizes.png')
