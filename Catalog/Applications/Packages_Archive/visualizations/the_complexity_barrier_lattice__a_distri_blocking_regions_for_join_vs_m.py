import numpy as np
import matplotlib.pyplot as plt

c1, c2 = 5, 7
targets = np.arange(0, 12)
join_blocks = targets > max(c1, c2)
meet_blocks = targets > min(c1, c2)

fig, ax = plt.subplots(figsize=(10, 3.5))
ax.fill_between(targets, 0, meet_blocks.astype(int), step='mid', alpha=0.4, label='MEET blocks (c1 OR c2)')
ax.fill_between(targets, 0, join_blocks.astype(int), step='mid', alpha=0.7, label='JOIN blocks (c1 AND c2)')
ax.axvline(min(c1, c2) + 0.5, ls='--', color='gray')
ax.axvline(max(c1, c2) + 0.5, ls='--', color='black')
ax.set_xlabel('target lower bound t')
ax.set_yticks([0, 1]); ax.set_yticklabels(['not blocked', 'blocked'])
ax.set_title(f'Blocking regions (c1={c1}, c2={c2}): meet blocks a wider target interval than join')
ax.legend(loc='center left')
plt.tight_layout()
plt.savefig('blocking_regions.png', dpi=150)
print('wrote blocking_regions.png')