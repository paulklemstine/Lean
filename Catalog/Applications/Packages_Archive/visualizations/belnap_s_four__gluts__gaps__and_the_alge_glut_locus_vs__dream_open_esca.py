import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

def draw_bridge(n: int = 16) -> None:
    v = lambda k: 'B' if k % 2 == 0 else 'T'
    fig, ax = plt.subplots(figsize=(10, 2.4))
    for k in range(n):
        c = '#ee6677' if v(k) == 'B' else '#4477aa'
        ax.add_patch(Rectangle((k, 0), 1, 1, facecolor=c, edgecolor='white'))
        ax.text(k + 0.5, 0.5, v(k), ha='center', va='center', color='white')
        ax.text(k + 0.5, -0.4, str(k), ha='center', va='center', fontsize=8)
    ax.set_xlim(0, n)
    ax.set_ylim(-0.8, 1.4)
    ax.set_title('Glut locus (red B-cells = evens) is an escaped union: '
                 'each {2k} dream-open, union not dream-open')
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('glut_locus_bridge.png', dpi=150)
    print('wrote glut_locus_bridge.png')

if __name__ == '__main__':
    draw_bridge()
