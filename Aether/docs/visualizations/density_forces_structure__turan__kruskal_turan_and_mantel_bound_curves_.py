import matplotlib.pyplot as plt
from math import comb


def turan_graph_edges(n: int, r: int) -> int:
    q, s = divmod(n, r)
    return comb(n, 2) - s * comb(q + 1, 2) - (r - s) * comb(q, 2)


ns = list(range(2, 41))
fig, ax = plt.subplots(figsize=(8, 5))
for r in [2, 3, 4, 5]:
    bound = [(1 - 1 / r) * n * n / 2 for n in ns]
    exact = [turan_graph_edges(n, r) for n in ns]
    line, = ax.plot(ns, bound, label=f'bound r={r}')
    ax.plot(ns, exact, '.', color=line.get_color(), markersize=4)
ax.set_xlabel('number of vertices n')
ax.set_ylabel('max edges in K_(r+1)-free graph')
ax.set_title('Turan bound (lines) vs exact Turan-graph edges (dots)')
ax.legend()
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig('turan_bounds.png', dpi=150)
print('saved turan_bounds.png')
