import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Penrose polygon monodromy
ax = axes[0]
ks = range(3, 15)
monos = [k * 1.0 for k in ks]
ax.bar(list(ks), monos, color='steelblue', alpha=0.8)
ax.set_xlabel('Polygon Order k')
ax.set_ylabel('Monodromy')
ax.set_title('Penrose k-gon Monodromy = k*delta')
ax.axhline(y=0, color='red', linestyle='--', label='Realizability')
ax.legend()

# Panel 2: Height spiral
ax = axes[1]
w = [1.0, 1.0, 1.0]
h = 0.0
angles, heights = [], []
for lap in range(5):
    for i, wi in enumerate(w):
        angles.append(2*np.pi*(lap*3+i)/3)
        heights.append(h)
        h += wi
angles.append(2*np.pi*5)
heights.append(h)
ax.plot(angles, heights, 'b-', linewidth=2)
ax.set_xlabel('Angle (rad)')
ax.set_ylabel('Height')
ax.set_title('Penrose Triangle Height Spiral')

# Panel 3: Obstruction degree
ax = axes[2]
np.random.seed(42)
ms = np.random.randn(300)*2
colors = ['green' if abs(m)<0.1 else ('blue' if m>0 else 'red') for m in ms]
ax.scatter(range(len(ms)), ms, c=colors, s=8, alpha=0.6)
ax.axhline(y=0, color='k')
ax.set_title('Obstruction Degree Classification')

plt.tight_layout()
plt.savefig('monodromy_analysis.png', dpi=150)
plt.close()
print('Saved monodromy_analysis.png')