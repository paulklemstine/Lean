import matplotlib.pyplot as plt


def plot_one_plus_i_spiral(max_r: int = 16) -> None:
    xs, ys, labels = [], [], []
    for r in range(max_r + 1):
        z = (1 + 1j) ** r
        xs.append(z.real)
        ys.append(z.imag)
        labels.append(r)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.plot(xs, ys, '-o', color='steelblue', lw=1)
    for x, y, r in zip(xs, ys, labels):
        pos_real = abs(y) < 1e-9 and x > 0
        ax.annotate(f'r={r}', (x, y),
                    color='crimson' if pos_real else 'black',
                    fontsize=9)
    ax.axhline(0, color='gray', lw=0.5)
    ax.axvline(0, color='gray', lw=0.5)
    ax.set_title('Powers of (1 + i): positive-real only when 8 | r')
    ax.set_xlabel('Re'); ax.set_ylabel('Im')
    ax.set_aspect('equal', 'box')
    plt.tight_layout()
    plt.savefig('one_plus_i_spiral.png', dpi=150)
    print('wrote one_plus_i_spiral.png')


if __name__ == '__main__':
    plot_one_plus_i_spiral()
