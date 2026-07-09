import matplotlib.pyplot as plt


def anti_fib_closed(k: int) -> int:
    return 1 + k * (k - 1) // 2


def fib(n: int) -> list[int]:
    f = [1, 1]
    for _ in range(2, n):
        f.append(f[-1] + f[-2])
    return f[:n]


N = 30
ks = list(range(N))
a = [anti_fib_closed(k) for k in ks]
f = fib(N)
plt.figure(figsize=(8, 5))
plt.semilogy(ks, a, 'o-', label='Anti-Fibonacci  A(k)=1+k(k-1)/2')
plt.semilogy(ks, f, 's-', label='Fibonacci  F(k)')
plt.xlabel('index k')
plt.ylabel('value (log scale)')
plt.title('Quadratic vs. exponential growth')
plt.legend()
plt.grid(True, which='both', alpha=0.3)
plt.tight_layout()
plt.savefig('growth_comparison.png', dpi=150)
print('saved growth_comparison.png')
