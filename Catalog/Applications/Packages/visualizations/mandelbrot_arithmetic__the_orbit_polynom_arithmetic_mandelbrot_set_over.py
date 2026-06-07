import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def find_period_mod(c, p):
    z = 0
    for n in range(1, p*p+2):
        z = (z*z + c) % p
        if z == 0: return n
    return 0

primes = [2, 3, 5, 7, 11, 13, 17, 19]
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
fig.suptitle('Arithmetic Mandelbrot Set over Z/pZ', fontsize=14, fontweight='bold')
cmap = plt.cm.Set1
for idx, p in enumerate(primes):
    ax = axes[idx//4][idx%4]
    periods = [find_period_mod(c, p) for c in range(p)]
    colors = ['lightgray' if per==0 else cmap(per/10) for per in periods]
    ax.bar(range(p), [1]*p, color=colors, edgecolor='black', linewidth=0.5)
    for i, per in enumerate(periods):
        if per > 0: ax.text(i, 0.5, str(per), ha='center', va='center', fontsize=8)
    ax.set_title(f'Z/{p}Z |M|={sum(1 for x in periods if x>0)}/{p}')
    ax.set_yticks([])
plt.tight_layout()
plt.savefig('arithmetic_mandelbrot.png', dpi=150)
print('Saved arithmetic_mandelbrot.png')