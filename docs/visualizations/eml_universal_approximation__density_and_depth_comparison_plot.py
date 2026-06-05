import numpy as np
import matplotlib.pyplot as plt

def iterExp(k, x):
    result = x.copy()
    for _ in range(k):
        result = np.exp(np.clip(result, -500, 500))
    return result

def fit_depth(f, depth, degree, x):
    base = iterExp(depth, x)
    V = np.vander(base, degree + 1, increasing=True)
    y = f(x)
    c, _, _, _ = np.linalg.lstsq(V, y, rcond=None)
    return V @ c

x = np.linspace(0, 1, 500)
f = lambda x: np.sin(np.pi * x)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for i, depth in enumerate([0, 1, 2]):
    ax = axes[i]
    ax.plot(x, f(x), 'k-', lw=2, label='sin(πx)')
    for deg in [3, 5, 10]:
        try:
            approx = fit_depth(f, depth, deg, x)
            err = np.max(np.abs(approx - f(x)))
            ax.plot(x, approx, '--', label=f'deg {deg} (err={err:.2e})')
        except:
            pass
    ax.set_title(f'Depth {depth}')
    ax.legend(fontsize=8)
    ax.set_xlabel('x')
plt.suptitle('EML Approximation Tower: Depth Comparison', fontsize=14)
plt.tight_layout()
plt.savefig('depth_comparison.png', dpi=150)
plt.show()
