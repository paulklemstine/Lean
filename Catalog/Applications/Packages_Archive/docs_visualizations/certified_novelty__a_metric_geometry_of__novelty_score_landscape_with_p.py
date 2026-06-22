"""Novelty-score heatmap: distance-to-corpus over the plane, with the
corpus points and their eps/2 packing balls overlaid."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

corpus = np.array([[0.2,0.3],[0.7,0.8],[0.8,0.2],[0.4,0.6],[0.1,0.9]])

def score(x, y):
    pts = np.stack([x.ravel(), y.ravel()], axis=1)
    d = np.sqrt(((pts[:,None,:]-corpus[None,:,:])**2).sum(-1))
    return d.min(1).reshape(x.shape)

xx, yy = np.meshgrid(np.linspace(0,1,400), np.linspace(0,1,400))
Z = score(xx, yy)
fig, ax = plt.subplots(figsize=(7,6))
im = ax.contourf(xx, yy, Z, levels=30, cmap='viridis')
ax.contour(xx, yy, Z, levels=10, colors='white', linewidths=0.4, alpha=0.5)
ax.scatter(corpus[:,0], corpus[:,1], c='red', s=60, edgecolor='white',
           zorder=5, label='corpus (known)')
# separation and packing balls of radius sigma/2
sig = min(math.dist(corpus[i], corpus[j])
          for i in range(len(corpus)) for j in range(i+1,len(corpus)))
for c in corpus:
    ax.add_patch(plt.Circle(c, sig/2, fill=False, color='red', ls='--', lw=1))
ax.set_title('Novelty score = distance to corpus (brighter = more novel)')
ax.set_xlabel('feature 1'); ax.set_ylabel('feature 2')
fig.colorbar(im, ax=ax, label='novelty score')
ax.legend(loc='upper left'); ax.set_aspect('equal')
plt.tight_layout(); plt.savefig('novelty_heatmap.png', dpi=150)
print('wrote novelty_heatmap.png')
