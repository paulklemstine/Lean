import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compute_cp(n):
    even = set(x for x in range(n) if x % 2 == 0)
    top = set(x for x in range(n) if x >= 2*n//3)
    return len(even & top) / len(top) if top else 0

sizes = list(range(6, 5001, 2))
cps = [compute_cp(n) for n in sizes]

fig, ax = plt.subplots(figsize=(10, 5))
ax.plot(sizes, cps, 'b-', lw=0.5, alpha=0.7)
ax.axhline(y=0.5, color='r', ls='--', label='Limit')
ax.set_xlabel('Universe size |Ω|')
ax.set_ylabel('P(even | top third)')
ax.set_title('Ratio Stability: Infinitesimals Cancel in Conditional Probability')
ax.legend()
ax.set_ylim(0.45, 0.55)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('ratio_stability.png', dpi=150)
print('Saved ratio_stability.png')