import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(10, 6))
np.random.seed(42)
bx = np.random.uniform(0, 4, 25)
by = np.random.uniform(0, 0.9, 25)
fx = np.random.uniform(6, 10, 25)
fy = np.ones(25) + np.random.uniform(-0.02, 0.02, 25)
ax.scatter(bx, by, s=80, c='steelblue', alpha=0.7, label='Bounded (sub-\u03c9)')
ax.scatter(fx, fy, s=80, c='crimson', alpha=0.7, label='Full (= \u03c9)')
ax.axvline(x=5, color='black', linestyle='--', linewidth=2, alpha=0.5)
ax.set_title('Sharp Dichotomy: survival \u2265 \u03c9 iff full')
ax.legend()
plt.tight_layout()
plt.savefig('dichotomy.png', dpi=150)
plt.close()