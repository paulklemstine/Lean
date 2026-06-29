import matplotlib.pyplot as plt
import numpy as np

def visualize_total_space_collapse() -> None:
    # one valid identity system: only a0 carries a certificate
    carrier = ['a0', 'a1', 'a2', 'a3']
    a0 = 'a0'
    # exotic but valid R: certificate at a0 only (identity-system condition)
    fibres = {'a0': ['rflR'], 'a1': [], 'a2': [], 'a3': []}
    nodes = [(a, r) for a in carrier for r in fibres[a]]
    fig, ax = plt.subplots(figsize=(7, 6))
    cx, cy = 0.0, 0.0
    ax.scatter([cx], [cy], s=400, c='crimson', zorder=3,
               label='centre (a0, rflR)')
    ax.annotate('(a0, rflR)', (cx, cy), textcoords='offset points',
                xytext=(10, 10))
    n = max(len(nodes), 1)
    for i, node in enumerate(nodes):
        ang = 2 * np.pi * i / n
        x, y = 2.5 * np.cos(ang), 2.5 * np.sin(ang)
        ax.plot([x, cx], [y, cy], 'k--', alpha=0.4, zorder=1)
        ax.scatter([x], [y], s=200, c='steelblue', zorder=2)
        ax.annotate(str(node), (x, y))
    ax.set_title('Total space Sigma a, R a contracts onto its centre')
    ax.set_aspect('equal'); ax.axis('off'); ax.legend()
    plt.tight_layout(); plt.savefig('total_space_collapse.png', dpi=140)
    print('wrote total_space_collapse.png')

if __name__ == '__main__':
    visualize_total_space_collapse()
