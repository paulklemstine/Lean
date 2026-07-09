import matplotlib.pyplot as plt
from math import sqrt


def anti_fib_closed(k: int) -> int:
    return 1 + k * (k - 1) // 2


def fib(n: int) -> list[int]:
    f = [1, 1]
    for _ in range(2, n):
        f.append(f[-1] + f[-2])
    return f[:n]


phi = (1 + sqrt(5)) / 2
N = 25
ks = list(range(1, N))
ar = [anti_fib_closed(k + 1) / anti_fib_closed(k) for k in ks]
fvals = fib(N + 1)
fr = [fvals[k + 1] / fvals[k] for k in ks]
plt.figure(figsize=(8, 5))
plt.plot(ks, ar, 'o-', label='Anti-Fibonacci ratio -> 1')
plt.plot(ks, fr, 's-', label='Fibonacci ratio -> phi')
plt.axhline(phi, color='gray', ls='--', label=f'phi = {phi:.4f}')
plt.axhline(1.0, color='black', ls=':', label='1')
plt.xlabel('index k')
plt.ylabel('A(k+1)/A(k)')
plt.title('Consecutive-ratio limits: 1 vs. golden ratio')
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('ratio_convergence.png', dpi=150)
print('saved ratio_convergence.png')
