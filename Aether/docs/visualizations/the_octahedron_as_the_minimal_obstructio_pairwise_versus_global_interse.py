import matplotlib.pyplot as plt
from matplotlib.patches import Circle

A={0,2,4}; B={0,3,5}; C={1,2,5}
fig,ax=plt.subplots(figsize=(7,7))
c1=Circle((-0.5,0.4),1.2,alpha=0.3,color="tab:red",label="A={0,2,4}")
c2=Circle((0.5,0.4),1.2,alpha=0.3,color="tab:green",label="B={0,3,5}")
c3=Circle((0,-0.5),1.2,alpha=0.3,color="tab:blue",label="C={1,2,5}")
for c in (c1,c2,c3): ax.add_patch(c)

# annotate memberships
placements={4:(-1.3,0.6),3:(1.3,0.6),1:(0,-1.4),
            0:(0,1.1),2:(-0.9,-0.4),5:(0.9,-0.4)}
for v,(x,y) in placements.items():
    ax.text(x,y,str(v),ha="center",va="center",fontsize=16,fontweight="bold")
ax.text(0,0.05,"empty\ncore",ha="center",va="center",fontsize=11,color="darkred")
ax.legend(loc="upper center",bbox_to_anchor=(0.5,-0.02),ncol=3)
ax.set_xlim(-2.5,2.5); ax.set_ylim(-2.5,2.5); ax.set_aspect("equal"); ax.set_axis_off()
ax.set_title("Pairwise overlaps at 0,2,5 but empty triple intersection")
plt.tight_layout(); plt.savefig("venn_cliques.png",dpi=150)
print("saved venn_cliques.png")
