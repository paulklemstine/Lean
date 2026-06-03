import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def generate_markov_tree_with_edges(depth=5):
    nodes = {}
    edges = []
    queue = [(1, 1, 1, None)]
    for _ in range(depth):
        new_queue = []
        for x, y, z, parent in queue:
            t = tuple(sorted([x, y, z]))
            if t in nodes: continue
            nodes[t] = len(nodes)
            if parent is not None:
                edges.append((parent, t))
            for child in [(3*y*z-x,y,z),(x,3*x*z-y,z),(x,y,3*x*y-z)]:
                c = tuple(sorted(child))
                if c[0] >= 1 and c not in nodes:
                    new_queue.append((*child, t))
        queue = new_queue
    return nodes, edges

nodes, edges = generate_markov_tree_with_edges(6)
import math
positions = {}
level_count = {}
for t in sorted(nodes.keys(), key=lambda x: max(x)):
    lvl = int(math.log2(max(t) + 1)) if max(t) > 1 else 0
    if lvl not in level_count: level_count[lvl] = 0
    level_count[lvl] += 1
    positions[t] = (level_count[lvl], -lvl)

fig, ax = plt.subplots(figsize=(14, 8))
for parent, child in edges:
    if parent in positions and child in positions:
        ax.plot([positions[parent][0], positions[child][0]],
                [positions[parent][1], positions[child][1]], 'b-', alpha=0.3)
for t, (x, y) in positions.items():
    ax.plot(x, y, 'ro', markersize=8)
    ax.annotate(str(t), (x, y), textcoords='offset points',
                xytext=(0, 10), ha='center', fontsize=7)
ax.set_title('Markov Tree (first levels)', fontsize=16)
ax.axis('off')
plt.tight_layout()
plt.savefig('markov_tree.png', dpi=150)
plt.show()