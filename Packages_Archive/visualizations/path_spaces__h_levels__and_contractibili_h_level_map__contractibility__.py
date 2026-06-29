import matplotlib.pyplot as plt

def is_contr(c): return len(c) == 1
def is_nonempty(c): return len(c) > 0
def is_mere_prop(c): return len(c) <= 1

types = {'empty': [], 'point': ['*'], 'pair': ['x','y'],
         'triple': ['x','y','z']}
xs, ys, cols, labels = [], [], [], []
for name, c in types.items():
    xs.append(1 if is_nonempty(c) else 0)
    ys.append(1 if is_mere_prop(c) else 0)
    cols.append('crimson' if is_contr(c) else 'steelblue')
    labels.append(name)

fig, ax = plt.subplots(figsize=(6, 6))
ax.scatter(xs, ys, c=cols, s=400, edgecolors='black', zorder=3)
for x, y, lab in zip(xs, ys, labels):
    ax.annotate(lab, (x, y), textcoords='offset points',
                xytext=(10, 8), fontsize=11)
ax.set_xticks([0, 1]); ax.set_xticklabels(['empty', 'inhabited'])
ax.set_yticks([0, 1]); ax.set_yticklabels(['proper', 'mere-prop'])
ax.set_title('Contractible (red) = Inhabited AND Mere Proposition')
ax.set_xlim(-0.5, 1.5); ax.set_ylim(-0.5, 1.5); ax.grid(True, zorder=0)
plt.tight_layout(); plt.savefig('hlevel_map.png', dpi=150)
print('wrote hlevel_map.png')
