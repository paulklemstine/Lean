import matplotlib.pyplot as plt
import numpy as np

N = 16
ms = [16, 8, 4, 2, 1]
weak = [N for _ in ms]
exact = list(ms)  # |Im f| = m for x mod m

x = np.arange(len(ms)); w = 0.38
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(x - w/2, weak, w, label='weak successes (= |domain|)', color='#2b8cbe')
ax.bar(x + w/2, exact, w, label='exact recoveries (= |Im f|)', color='#e34a33')
ax.set_xticks(x); ax.set_xticklabels([f'm={m}' for m in ms])
ax.set_xlabel('image size m  (f = x mod m on a domain of size 16)')
ax.set_ylabel('number of inputs recovered')
ax.set_title('Weak inversion is total; exact inversion is capped by |Im f|')
ax.legend()
fig.tight_layout()
fig.savefig('weak_vs_exact.png', dpi=150)
print('wrote weak_vs_exact.png')
