import itertools
import matplotlib.pyplot as plt

def hypercube_q4():
    verts = [tuple(b) for b in itertools.product([0, 1], repeat=4)]
    # 4D -> 2D projection via two basis directions per axis pair.
    basis = [(1.0, 0.0), (0.0, 1.0), (0.35, 0.35), (-0.35, 0.35)]
    def pos(v):
        x = sum(v[k] * basis[k][0] for k in range(4))
        y = sum(v[k] * basis[k][1] for k in range(4))
        return x, y
    fig, ax = plt.subplots(figsize=(9, 9))
    for a in verts:
        for i in range(4):
            b = a[:i] + (1 - a[i],) + a[i + 1:]
            if a < b:
                xa, ya = pos(a); xb, yb = pos(b)
                ax.plot([xa, xb], [ya, yb], color='0.7', lw=0.8, zorder=1)
    for a in verts:
        x, y = pos(a)
        parity = sum(a) % 2
        ax.scatter([x], [y], s=420,
                   color='#d1495b' if parity else '#2e86ab', zorder=2)
        label = ''.join('M' if c else 'V' for c in a)
        ax.text(x, y, label, ha='center', va='center',
                color='white', fontsize=8, fontweight='bold', zorder=3)
    ax.set_title('Flip graph Q_4: 16 vertices, 32 edges, 4-regular, bipartite')
    ax.set_aspect('equal'); ax.axis('off')
    plt.tight_layout(); plt.savefig('q4_hypercube.png', dpi=150)
    print('wrote q4_hypercube.png')

if __name__ == '__main__':
    hypercube_q4()
