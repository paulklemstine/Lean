import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

data = {
    'p1': (0,0,'#ecf0f1',1), 'p2': (-2,1,'#e74c3c',2), 'pm': (0,1,'#3498db',1),
    'pg': (2,1,'#2ecc71',1), 'cm': (3,2,'#1abc9c',1), 'pmm': (-2,2,'#e74c3c',2),
    'pmg': (0,2,'#e67e22',2), 'pgg': (2,2,'#9b59b6',2), 'cmm': (1,3,'#e67e22',2),
    'p4': (-2,3,'#f39c12',4), 'p3': (4,3,'#16a085',3), 'p4m': (-3,4,'#f39c12',4),
    'p4g': (-1,4,'#d35400',4), 'p3m1': (3,4,'#16a085',3), 'p31m': (5,4,'#27ae60',3),
    'p6': (1,5,'#8e44ad',6), 'p6m': (1,6,'#c0392b',6)
}
edges = [('p1','p2'),('p1','pm'),('p1','pg'),('pm','pmm'),('pm','cm'),('pg','pmg'),
    ('pg','pgg'),('pg','cm'),('p2','pmm'),('p2','pmg'),('p2','pgg'),('pmm','cmm'),
    ('pmg','cmm'),('p2','p4'),('pmm','p4m'),('pgg','p4g'),('p4','p4m'),('p4','p4g'),
    ('p2','p6'),('p3','p6'),('p4m','p6m'),('p3m1','p6m'),('p31m','p6m'),('p6','p6m'),
    ('p3','p3m1'),('p3','p31m'),('cm','cmm'),('cmm','p4g')]
fig, ax = plt.subplots(figsize=(12,8))
for s,d in edges:
    ax.plot([data[s][0],data[d][0]], [data[s][1],data[d][1]], 'k-', alpha=0.2)
for n,(x,y,c,r) in data.items():
    ax.add_patch(plt.Circle((x,y),0.3,facecolor=c,edgecolor='k',lw=1.5,zorder=10))
    ax.text(x,y,n,ha='center',va='center',fontsize=8,fontweight='bold',zorder=11)
ax.set_title('The 17 Wallpaper Groups: Symmetry Lattice',fontsize=14,fontweight='bold')
ax.set_xlim(-5,7); ax.set_ylim(-0.8,7); ax.set_aspect('equal')
plt.tight_layout()
plt.savefig('wallpaper_lattice.png',dpi=150)
print('Saved wallpaper_lattice.png')