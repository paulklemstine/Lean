import matplotlib.pyplot as plt
from math import isqrt

def sigma(n: int) -> int:
    s = 0
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s

N = 120
xs = list(range(1, N + 1))
ys = [sigma(n) / n for n in xs]
colors = ['#2ca02c' if abs(y - 2) < 1e-9 else ('#d62728' if y > 2 else '#1f77b4') for y in ys]
plt.figure(figsize=(12, 6))
plt.axhline(2.0, color='black', lw=1, ls='--', label='perfection (A=2)')
plt.scatter(xs, ys, c=colors, s=28)
for n, y in zip(xs, ys):
    if abs(y - 2) < 1e-9:
        plt.annotate(str(n), (n, y), textcoords='offset points', xytext=(0, 8), ha='center')
plt.xlabel('n'); plt.ylabel('abundancy index A(n) = sigma(n)/n')
plt.title('Abundancy landscape: deficient (blue), abundant (red), perfect (green)')
plt.legend(); plt.tight_layout(); plt.savefig('abundancy_landscape.png', dpi=150)
print('saved abundancy_landscape.png')