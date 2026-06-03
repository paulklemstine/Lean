import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

PC_NAMES = ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B']

def transpose(S, t): return frozenset((x+t)%12 for x in S)
def hamming_dist(A, B): return len(A.symmetric_difference(B))

major = frozenset({0,4,7})
minor = frozenset({0,3,7})
chords = [transpose(major, r) for r in range(12)] + [transpose(minor, r) for r in range(12)]
labels = [PC_NAMES[r] for r in range(12)] + [f'{PC_NAMES[r]}m' for r in range(12)]

n = len(chords)
D = np.array([[hamming_dist(chords[i], chords[j]) for j in range(n)] for i in range(n)])

fig, ax = plt.subplots(figsize=(14,12))
im = ax.imshow(D, cmap='YlOrRd_r')
ax.set_xticks(range(n)); ax.set_yticks(range(n))
ax.set_xticklabels(labels, rotation=90, fontsize=8)
ax.set_yticklabels(labels, fontsize=8)
for i in range(n):
  for j in range(n):
    ax.text(j, i, str(D[i,j]), ha='center', va='center', fontsize=6)
ax.set_title('Hamming Distance: Major & Minor Triads')
plt.colorbar(im)
plt.tight_layout()
plt.savefig('chord_heatmap.png', dpi=150)
print('Saved chord_heatmap.png')