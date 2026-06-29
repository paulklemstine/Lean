import matplotlib.pyplot as plt

def visualize_fibrewise_equiv() -> None:
    carrier = ['a0', 'a1', 'a2']
    a0 = 'a0'
    path = {a: ([0] if a == a0 else []) for a in carrier}
    R = {a: (['*'] if a == a0 else []) for a in carrier}
    fig, axes = plt.subplots(1, len(carrier), figsize=(12, 4))
    for ax, a in zip(axes, carrier):
        for i, _ in enumerate(path[a]):
            ax.scatter([0], [i], s=200, c='steelblue')
        for i, _ in enumerate(R[a]):
            ax.scatter([1], [i], s=200, c='seagreen')
            ax.annotate('', xy=(1, i), xytext=(0, i),
                        arrowprops=dict(arrowstyle='<->'))
        ax.set_title(f'a = {a}')
        ax.set_xlim(-0.5, 1.5); ax.set_ylim(-0.5, 1.5)
        ax.set_xticks([0, 1]); ax.set_xticklabels(['(a0=a)', 'R a'])
        ax.set_yticks([])
    fig.suptitle('Fundamental equivalence (a0 = a) ~ R a, fibre by fibre')
    plt.tight_layout(); plt.savefig('fibrewise_equiv.png', dpi=140)
    print('wrote fibrewise_equiv.png')

if __name__ == '__main__':
    visualize_fibrewise_equiv()
