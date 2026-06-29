import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def rank(m: int, N: int = 60) -> int:
    return next(k for k in range(1, N) if fib(k) % m == 0)

def plot_comb(m: int = 7, N: int = 60) -> None:
    r = rank(m)
    div = [n for n in range(1, N + 1) if fib(n) % m == 0]
    mult = [n for n in range(1, N + 1) if n % r == 0]
    fig, ax = plt.subplots(figsize=(11, 2.6))
    ax.vlines(div, 0.6, 1.0, color='crimson', lw=2, label=f'n with {m} | F(n)')
    ax.vlines(mult, 0.0, 0.4, color='navy', lw=2, label=f'multiples of r({m})={r}')
    ax.set_yticks([])
    ax.set_xlabel('index n')
    ax.set_title(f'The spine for m={m}:  {m} | F(n)  <=>  {r} | n')
    ax.legend(loc='upper right')
    fig.tight_layout()
    fig.savefig('apparition_comb.png', dpi=150)
    print('wrote apparition_comb.png')

if __name__ == '__main__':
    plot_comb()
