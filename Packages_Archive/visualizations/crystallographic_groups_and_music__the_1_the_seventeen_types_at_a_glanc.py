"""Visualize the seventeen wallpaper types of rhythm: a bar chart of how
many types share each rotation order, plus a heat strip of mirror/glide
presence. Requires matplotlib."""
from __future__ import annotations
import matplotlib.pyplot as plt

TYPES = [
    ('p1',1,0,0), ('p2',2,0,0), ('pm',1,1,0), ('pg',1,0,1), ('cm',1,1,1),
    ('pmm',2,1,0), ('pmg',2,1,1), ('pgg',2,0,1), ('cmm',2,1,1),
    ('p4',4,0,0), ('p4m',4,1,0), ('p4g',4,1,1), ('p3',3,0,0),
    ('p3m1',3,1,0), ('p31m',3,1,1), ('p6',6,0,0), ('p6m',6,1,1),
]

def main() -> None:
    orders = [1, 2, 3, 4, 6]
    counts = [sum(1 for _, r, _, _ in TYPES if r == o) for o in orders]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    ax1.bar([str(o) for o in orders], counts, color='#4C72B0')
    ax1.set_title('Wallpaper types by rotation order (note: no 5 or 7)')
    ax1.set_xlabel('rotation order'); ax1.set_ylabel('number of types')
    for i, c in enumerate(counts):
        ax1.text(i, c + 0.05, str(c), ha='center')
    names = [t[0] for t in TYPES]
    mat = [[t[2] for t in TYPES], [t[3] for t in TYPES]]
    ax2.imshow(mat, aspect='auto', cmap='Greens')
    ax2.set_yticks([0, 1]); ax2.set_yticklabels(['mirror', 'glide'])
    ax2.set_xticks(range(len(names)))
    ax2.set_xticklabels(names, rotation=90)
    ax2.set_title('Mirror (10) and glide (8) content of the 17 types')
    plt.tight_layout(); plt.savefig('wallpaper_rhythm.png', dpi=140)
    print('wrote wallpaper_rhythm.png')

if __name__ == '__main__':
    main()
