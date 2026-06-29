import matplotlib.pyplot as plt

def draw_diamond() -> None:
    pos = {'F': (0, 0), 'N': (-1, 1), 'B': (1, 1), 'T': (0, 2)}
    edges = [('F', 'N'), ('F', 'B'), ('N', 'T'), ('B', 'T')]
    colors = {'F': '#4477aa', 'T': '#4477aa', 'N': '#ccbb44', 'B': '#ee6677'}
    fig, ax = plt.subplots(figsize=(5, 5))
    for a, b in edges:
        (x1, y1), (x2, y2) = pos[a], pos[b]
        ax.plot([x1, x2], [y1, y2], color='gray', zorder=1)
    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=2200, color=colors[v], zorder=2)
        ax.text(x, y, v, ha='center', va='center',
                fontsize=18, color='white', zorder=3)
    ax.set_title('Belnap FOUR: truth order (F bottom, T top)\nN = gap, B = glut (negation-fixed)')
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('belnap_diamond.png', dpi=150)
    print('wrote belnap_diamond.png')

if __name__ == '__main__':
    draw_diamond()
