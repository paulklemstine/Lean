#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(1, 1, figsize=(10, 5))
labels = ['Algebraic', 'Trans-1', 'Analytic', 'Trans-2', 'Combinat.']
fitnesses = [8, 3, 7, 2, 9]
x = np.arange(5)
colors = ['#e74c3c' if i in [0,2,4] else '#3498db' for i in range(5)]
ax.bar(x, fitnesses, color=colors, edgecolor='black', width=0.6)
ax.plot(x, fitnesses, 'k--', alpha=0.3)
ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=9)
ax.set_ylabel('Fitness')
ax.set_title('Fitness Landscape: Mathematical Styles as Local Optima')
plt.tight_layout()
plt.savefig('fitness_landscape.png', dpi=150)
print('Saved fitness_landscape.png')