import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from typing import Dict, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, int]


def draw(ax, db: PartialDB, title: str, n_rows: int, n_cols: int, color: str):
    ax.set_title(title)
    ax.set_xlim(0, n_cols); ax.set_ylim(0, n_rows)
    ax.set_xticks(range(n_cols + 1)); ax.set_yticks(range(n_rows + 1))
    ax.grid(True); ax.set_aspect('equal'); ax.invert_yaxis()
    for (r, c), v in db.items():
        ax.add_patch(Rectangle((c, r), 1, 1, color=color, alpha=0.5))
        ax.text(c + 0.5, r + 0.5, str(v), ha='center', va='center')


db1: PartialDB = {(0, 0): 1, (0, 1): 2, (1, 0): 5}
db2: PartialDB = {(0, 1): 2, (1, 1): 8}
glued: PartialDB = dict(db2); glued.update(db1)

fig, axes = plt.subplots(1, 3, figsize=(12, 4))
draw(axes[0], db1, 'Source A', 2, 2, 'tab:blue')
draw(axes[1], db2, 'Source B', 2, 2, 'tab:orange')
draw(axes[2], glued, 'Glue(A, B)', 2, 2, 'tab:green')
plt.tight_layout()
plt.savefig('gluing_diagram.png', dpi=150)
print('wrote gluing_diagram.png')
