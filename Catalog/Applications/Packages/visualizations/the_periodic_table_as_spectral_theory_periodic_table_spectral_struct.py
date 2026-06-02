import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Shell degeneracy
ax1 = axes[0, 0]
ns = np.arange(1, 8)
degs = [2*n*n for n in ns]
ax1.bar(ns, degs, color='#2196F3', edgecolor='navy', alpha=0.8)
ax1.plot(ns, 2*ns**2, 'r--', linewidth=2, label='$2n^2$')
ax1.set_xlabel('Shell n')
ax1.set_ylabel('Degeneracy')
ax1.set_title('Shell Degeneracy = $2n^2$')
ax1.legend()

# Period lengths
ax2 = axes[0, 1]
periods = [2, 8, 8, 18, 18, 32, 32]
colors = ['#E53935', '#1E88E5', '#1E88E5', '#43A047', '#43A047', '#FB8C00', '#FB8C00']
ax2.bar(range(1, 8), periods, color=colors, edgecolor='black', alpha=0.8)
ax2.set_xlabel('Period number')
ax2.set_ylabel('Period length')
ax2.set_title('Period Lengths = $2n^2$ (paired)')

# HO vs real magic
ax3 = axes[1, 0]
real_magic = [2, 8, 20, 28, 50, 82, 126]
ho_magic = [2, 8, 20, 40, 70, 112, 168]
x = np.arange(7)
w = 0.35
ax3.bar(x-w/2, ho_magic, w, label='HO', color='#1E88E5', alpha=0.8)
ax3.bar(x+w/2, real_magic, w, label='Real', color='#E53935', alpha=0.8)
ax3.set_title('Nuclear Magic Numbers')
ax3.legend()

# Cumulative filling
ax4 = axes[1, 1]
noble = [2, 10, 18, 36, 54, 86, 118]
ax4.step(range(1, 8), noble, where='mid', linewidth=2, color='#43A047')
ax4.scatter(range(1, 8), noble, s=80, color='gold', zorder=5, edgecolor='black')
ax4.set_xlabel('Noble gas index')
ax4.set_ylabel('Atomic number Z')
ax4.set_title('Noble Gas Atomic Numbers')

plt.tight_layout()
plt.savefig('spectral_periodic_table.png', dpi=150)
print('Saved spectral_periodic_table.png')