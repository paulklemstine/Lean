import matplotlib.pyplot as plt

def visualize_clopen(n: int = 5, r: int = 0b10110) -> None:
    full = (1 << n) - 1
    d_r = [i for i in range(n) if (r >> i) & 1]
    d_compl = [i for i in range(n) if ((full ^ r) >> i) & 1]
    fig, ax = plt.subplots(figsize=(8, 2))
    ax.scatter(d_r, [0] * len(d_r), s=400, c='crimson',
               label='D(r)  (clopen)')
    ax.scatter(d_compl, [0] * len(d_compl), s=400, c='steelblue',
               label='D(1+r) = complement')
    for i in range(n):
        ax.annotate(f'p{i}', (i, 0), textcoords='offset points',
                    xytext=(0, 12), ha='center')
    ax.set_title(f'Stone space of a Boolean algebra (n={n}): '
                 f'D(r) and its clopen complement')
    ax.set_yticks([]); ax.legend(loc='upper center',
                                 bbox_to_anchor=(0.5, -0.15), ncol=2)
    plt.tight_layout(); plt.show()

if __name__ == '__main__':
    visualize_clopen()
