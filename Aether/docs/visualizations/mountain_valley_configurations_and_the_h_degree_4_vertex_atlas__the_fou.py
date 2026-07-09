import itertools, math
import matplotlib.pyplot as plt

def generic_valid(a):
    return a[0] != a[1] and a[2] == a[3]

def vertex_atlas():
    valid = [a for a in itertools.product([False, True], repeat=4)
             if generic_valid(a)]
    fig, axes = plt.subplots(1, 4, figsize=(16, 4.2))
    angles = [45, 135, 225, 315]  # four creases
    for ax, a in zip(axes, valid):
        for i, ang in enumerate(angles):
            r = math.radians(ang)
            ax.plot([0, math.cos(r)], [0, math.sin(r)],
                    color='#d1495b' if a[i] else '#2e86ab',
                    lw=3, linestyle='-' if a[i] else '--')
        m = sum(1 for x in a if x)
        label = ''.join('M' if x else 'V' for x in a)
        ax.set_title(f'{label}   ({m} mountains)')
        ax.set_xlim(-1.2, 1.2); ax.set_ylim(-1.2, 1.2)
        ax.set_aspect('equal'); ax.axis('off')
    fig.suptitle('The four generic flat-foldable degree-4 vertices '
                 '(solid=mountain, dashed=valley)')
    plt.tight_layout(); plt.savefig('vertex_atlas.png', dpi=150)
    print('wrote vertex_atlas.png')

if __name__ == '__main__':
    vertex_atlas()
