import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# Octahedron vertex positions (three axis pairs)
pos = {0:(0,1),1:(0,-1),2:(-1.4,0.3),3:(1.4,-0.3),4:(-1.4,-0.6),5:(1.4,0.6)}

def octa_edges():
    return [(u,v) for u,v in combinations(range(6),2) if u//2 != v//2]

fig, ax = plt.subplots(figsize=(7,6))
for u,v in octa_edges():
    x=[pos[u][0],pos[v][0]]; y=[pos[u][1],pos[v][1]]
    ax.plot(x,y,color="0.75",lw=1,zorder=1)

triangles = [([0,2,4],"tab:red"),([0,3,5],"tab:green"),([1,2,5],"tab:blue")]
for tri,col in triangles:
    for u,v in combinations(tri,2):
        ax.plot([pos[u][0],pos[v][0]],[pos[u][1],pos[v][1]],color=col,lw=2.5,alpha=0.6,zorder=2)

for v,(x,y) in pos.items():
    ax.scatter([x],[y],s=600,color="white",edgecolor="black",zorder=3)
    ax.text(x,y,str(v),ha="center",va="center",fontsize=14,zorder=4)

ax.set_title("Octahedron: three triangles meet pairwise at 0,2,5 with empty core")
ax.set_axis_off(); ax.set_aspect("equal")
plt.tight_layout(); plt.savefig("octahedron_eye.png",dpi=150)
print("saved octahedron_eye.png")
