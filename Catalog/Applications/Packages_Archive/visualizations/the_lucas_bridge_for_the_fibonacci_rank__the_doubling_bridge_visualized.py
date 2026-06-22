import matplotlib.pyplot as plt

def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def lucas(n):
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a

ns = list(range(1, 21))
f2n = [fib(2 * n) for n in ns]
prod = [fib(n) * lucas(n) for n in ns]

fig, ax = plt.subplots(figsize=(11, 6))
ax.plot(ns, f2n, 'o-', label='F(2n)')
ax.plot(ns, prod, 'x--', label='F(n) * L(n)')
ax.set_yscale('log')
ax.set_xlabel('n')
ax.set_ylabel('value (log scale)')
ax.set_title('Doubling bridge: F(2n) = F(n) * L(n)')
for n in [4, 6, 8]:
    ax.annotate(f'F({2*n})={fib(2*n)}=F({n})*L({n})={fib(n)}*{lucas(n)}',
                xy=(n, fib(2 * n)), fontsize=8,
                xytext=(n + 0.3, fib(2 * n)))
ax.legend()
plt.tight_layout()
plt.savefig('doubling_bridge.png', dpi=150)
print('saved doubling_bridge.png')
