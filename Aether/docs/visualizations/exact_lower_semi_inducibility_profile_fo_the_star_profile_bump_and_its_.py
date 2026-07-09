import numpy as np
import matplotlib.pyplot as plt

def edge_density(t):
    return t * (1 - t / 2)

def min_profile(t):
    return t * t * (1 - t)

t = np.linspace(0.0, 1.0, 400)
beta = edge_density(t)
p = min_profile(t)
d = np.linspace(0.0, 1.0, 400)
f = d * d * (1 - d)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
ax1.plot(beta, p, lw=2, color='crimson')
ax1.scatter([4/9], [4/27], color='black', zorder=5)
ax1.annotate('peak 4/27 at beta=4/9', (4/9, 4/27),
             textcoords='offset points', xytext=(-20, -25))
ax1.scatter([0.5], [0.0], color='blue', zorder=5)
ax1.scatter([0.5], [1/12], facecolors='none', edgecolors='green', zorder=5)
ax1.annotate('predicted 0 (breaks)', (0.5, 0.0),
             textcoords='offset points', xytext=(-90, 10))
ax1.annotate('conjectured 1/12', (0.5, 1/12),
             textcoords='offset points', xytext=(-95, 0), color='green')
ax1.set_xlabel('edge density beta')
ax1.set_ylabel('p_min(beta)')
ax1.set_title('Construction profile on [0, 1/2]')
ax1.grid(alpha=0.3)

ax2.plot(d, f, lw=2, color='darkorange')
ax2.axhline(4/27, ls='--', color='gray')
ax2.scatter([2/3], [4/27], color='black', zorder=5)
ax2.annotate('max 4/27 at d=2/3', (2/3, 4/27),
             textcoords='offset points', xytext=(-30, -25))
ax2.set_xlabel('local neighbour-density d')
ax2.set_ylabel('f(d) = d^2 (1 - d)')
ax2.set_title('Star functional bump, bound 4/27')
ax2.grid(alpha=0.3)

fig.tight_layout()
fig.savefig('s21_profile.png', dpi=150)
print('wrote s21_profile.png')
