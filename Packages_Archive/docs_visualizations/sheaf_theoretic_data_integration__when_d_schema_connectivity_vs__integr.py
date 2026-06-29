import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import deque

def components(graph):
    seen, comps = set(), 0
    for s in graph:
        if s in seen: continue
        comps += 1; q = deque([s]); seen.add(s)
        while q:
            v = q.popleft()
            for w in graph[v]:
                if w not in seen: seen.add(w); q.append(w)
    return comps

graphs = [
    {'A':['B'],'B':['A','C'],'C':['B','D'],'D':['C']},
    {'A':['B'],'B':['A'],'C':['D'],'D':['C']},
    {'A':[],'B':[],'C':[],'D':[]},
]
pos = {'A':(0,1),'B':(1,1),'C':(1,0),'D':(0,0)}
fig, axes = plt.subplots(1, 3, figsize=(12, 4))
for ax, g in zip(axes, graphs):
    for v in g:
        for w in g[v]:
            ax.plot([pos[v][0],pos[w][0]],[pos[v][1],pos[w][1]],'k-',zorder=1)
    for v,(x,y) in pos.items():
        ax.scatter([x],[y],s=600,zorder=2)
        ax.text(x,y,v,ha='center',va='center',color='white',weight='bold')
    ax.set_title(f'dim H0 = {components(g)} components')
    ax.set_xlim(-0.4,1.4); ax.set_ylim(-0.4,1.4); ax.axis('off')
fig.suptitle('Schema connectivity controls integration freedom')
fig.tight_layout()
fig.savefig('schema_h0.png', dpi=150)
print('wrote schema_h0.png')