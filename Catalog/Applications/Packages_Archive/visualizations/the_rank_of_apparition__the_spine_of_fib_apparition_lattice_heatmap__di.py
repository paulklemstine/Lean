import matplotlib.pyplot as plt
import numpy as np

def fib_mod(n: int, m: int) -> int:
    if m == 1:
        return 0
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % m
    return a % m

def fib_rank(m: int) -> int:
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable")

def main() -> None:
    M, N = 16, 48
    grid = np.array([[1 if fib_mod(n, m) == 0 else 0
                      for n in range(1, N + 1)]
                     for m in range(2, M + 1)])
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.imshow(grid, aspect='auto', cmap='YlGnBu', origin='lower',
              extent=[1, N, 2, M])
    ax.set_xlabel('index n')
    ax.set_ylabel('modulus m')
    ax.set_title('m | F_n  (each row is a progression of period rank(m))')
    for m in range(2, M + 1):
        ax.text(N + 0.5, m, f'rank={fib_rank(m)}', va='center', fontsize=8)
    plt.tight_layout()
    plt.savefig('apparition_heatmap.png', dpi=150)
    print('wrote apparition_heatmap.png')

if __name__ == '__main__':
    main()
