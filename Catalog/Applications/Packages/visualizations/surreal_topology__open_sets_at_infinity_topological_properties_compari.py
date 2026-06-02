import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(10, 6))
spaces = ['Z', 'Q', 'R', 'Long Line', 'Surreals']
props = ['Hausdorff', 'Connected', 'First-Countable', 'Compact', 'Metrizable', 'Paracompact']
data = np.array([[1,0,1,0,1,1],[1,0,1,0,1,1],[1,1,1,0,1,1],[1,1,0,0,0,0],[1,1,0,0,0,0]])
im = ax.imshow(data.T, cmap=plt.cm.RdYlGn, aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(5)); ax.set_xticklabels(spaces)
ax.set_yticks(range(6)); ax.set_yticklabels(props)
for i in range(6):
    for j in range(5):
        ax.text(j, i, 'Y' if data[j,i]==1 else 'N', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
ax.set_title('Topological Properties of Ordered Spaces', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('topological_properties.png', dpi=150)
plt.close()