"""Novelty filtration: number of delta-novel candidates as the threshold
delta increases (a monotone-decreasing staircase) and a few persistence bars."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(0)
corpus = rng.uniform(0,1,size=(8,2))
cands = rng.uniform(0,1,size=(40,2))
scores = np.array([np.min(np.linalg.norm(corpus - c, axis=1)) for c in cands])
deltas = np.linspace(0, scores.max()*1.05, 200)
counts = [(scores >= d).sum() for d in deltas]

fig, (a1, a2) = plt.subplots(1, 2, figsize=(12,5))
a1.step(deltas, counts, where='post', color='navy')
a1.set_title('Novelty filtration (antitone in threshold)')
a1.set_xlabel('threshold delta'); a1.set_ylabel('# delta-novel candidates')
a1.grid(alpha=0.3)

order = np.argsort(scores)[::-1][:15]
for i, idx in enumerate(order):
    a2.plot([0, scores[idx]], [i, i], lw=4, color='teal')
a2.set_title('Persistence intervals [0, score) of top candidates')
a2.set_xlabel('novelty threshold'); a2.set_ylabel('candidate rank')
a2.grid(alpha=0.3)
plt.tight_layout(); plt.savefig('novelty_filtration.png', dpi=150)
print('wrote novelty_filtration.png')
