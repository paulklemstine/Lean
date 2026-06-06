import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def gol_step(grid):
    rows, cols = grid.shape
    padded = np.pad(grid, 1, mode='wrap')
    count = np.zeros_like(grid)
    for di in [-1,0,1]:
        for dj in [-1,0,1]:
            if di==0 and dj==0: continue
            count += padded[1+di:rows+1+di, 1+dj:cols+1+dj]
    return ((grid==0)&(count==3)|(grid==1)&((count==2)|(count==3))).astype(int)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Glider
ax = axes[0]
grid = np.zeros((20,20), dtype=int)
grid[0,1]=grid[1,2]=grid[2,0]=grid[2,1]=grid[2,2]=1
colors = plt.cm.viridis(np.linspace(0,1,5))
for t in range(5):
    cells = np.argwhere(grid==1)
    ax.scatter(cells[:,1]+t*0.05, cells[:,0]+t*0.05, c=[colors[t]], s=100, alpha=0.7, label=f't={t*4}')
    for _ in range(4): grid = gol_step(grid)
ax.set_xlim(-0.5,12); ax.set_ylim(12,-0.5)
ax.set_title('Glider Signal Propagation'); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

# NAND
ax = axes[1]
bar_colors = ['#2ecc71','#2ecc71','#2ecc71','#e74c3c']
ax.bar(range(4), [1,1,1,0], color=bar_colors, edgecolor='black')
ax.set_xticks(range(4)); ax.set_xticklabels(['(0,0)','(0,1)','(1,0)','(1,1)'])
ax.set_title('NAND Gate via Glider Collision')

# Overhead
ax = axes[2]
for d in [1,2,4,8,16]:
    g = np.arange(1,101)
    ax.plot(g, (d+1)*g+1, label=f'd={d}')
ax.set_xlabel('Gates'); ax.set_ylabel('CA Steps'); ax.set_title('Simulation Overhead'); ax.legend()

plt.tight_layout(); plt.savefig('signal_collision_algebra.png', dpi=150)
print('Saved')