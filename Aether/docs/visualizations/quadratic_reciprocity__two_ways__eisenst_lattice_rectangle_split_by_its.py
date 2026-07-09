import matplotlib.pyplot as plt

def plot_eisenstein_rectangle(p: int = 11, q: int = 7) -> None:
    below_x, below_y, above_x, above_y = [], [], [], []
    for x in range(1, (p - 1) // 2 + 1):
        for y in range(1, (q - 1) // 2 + 1):
            if p * y < q * x:
                below_x.append(x); below_y.append(y)
            else:
                above_x.append(x); above_y.append(y)
    plt.figure(figsize=(6, 5))
    plt.scatter(below_x, below_y, c='crimson', label=f'below: S_qp={len(below_x)}')
    plt.scatter(above_x, above_y, c='royalblue', label=f'above: S_pq={len(above_x)}')
    xs = [0, (p - 1) / 2]
    plt.plot(xs, [q / p * x for x in xs], 'k--', label='y=(q/p)x')
    plt.title(f'p={p}, q={q}: total={(p-1)//2*((q-1)//2)}')
    plt.xlabel('x'); plt.ylabel('y'); plt.legend(); plt.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig('eisenstein_rectangle.png', dpi=150)

if __name__ == '__main__':
    plot_eisenstein_rectangle()