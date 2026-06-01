import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def hardness(n, d): return d*(1-d)*n**4
def critical(n): return (n**2-1)/n**2

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
for idx, n in enumerate([3, 5, 9]):
    ds = np.linspace(0, 1, 200)
    axes[idx].plot(ds, [hardness(n,d) for d in ds], 'b-')
    axes[idx].axvline(x=critical(n), color='r', linestyle='--', label=f'd_c={critical(n):.3f}')
    axes[idx].set_title(f'n={n}'); axes[idx].legend()
plt.suptitle('Hardness H(d) = d(1-d)n⁴')
plt.tight_layout(); plt.savefig('viz_hardness_landscape.png', dpi=150)