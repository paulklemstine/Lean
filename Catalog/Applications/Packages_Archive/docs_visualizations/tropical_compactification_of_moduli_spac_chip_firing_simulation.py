import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def graph_laplacian(n, edges):
    L = [[0]*n for _ in range(n)]
    for u,v in edges:
        L[u][v] = -1; L[v][u] = -1; L[u][u] += 1; L[v][v] += 1
    return L

def fire(L, config, v):
    n = len(config)
    new = config[:]
    for w in range(n): new[w] += L[w][v]
    return new

# Triangle K_3
L = graph_laplacian(3, [(0,1),(1,2),(0,2)])
config = [5, 1, 0]
history = [config[:]]

# Fire sequence: 0, 0, 1
for v in [0, 0, 1, 2, 0]:
    config = fire(L, config, v)
    history.append(config[:])

fig, ax = plt.subplots(figsize=(10,5))
colors = ['#e74c3c','#3498db','#2ecc71']
for vertex in range(3):
    vals = [h[vertex] for h in history]
    ax.plot(range(len(vals)), vals, 'o-', color=colors[vertex],
            label=f'Vertex {vertex}', linewidth=2, markersize=8)

ax.set_xlabel('Firing Step', fontsize=12)
ax.set_ylabel('Chips', fontsize=12)
ax.set_title('Chip-Firing Evolution on K₃', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xticks(range(len(history)))
plt.tight_layout()
plt.savefig('chip_firing_evolution.png', dpi=150)
print('Saved chip_firing_evolution.png')