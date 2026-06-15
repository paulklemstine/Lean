import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

e_val = math.e
values = []
degrees = []

for d in range(1, 4):
    def gen(k):
        if k == 0: return [[c] for c in range(-3, 4)]
        return [[c] + s for c in range(-3, 4) for s in gen(k-1)]
    for coeffs in gen(d):
        if all(c == 0 for c in coeffs) or coeffs[-1] == 0:
            continue
        val = abs(sum(c * e_val**i for i, c in enumerate(coeffs)))
        if val < 50:
            values.append(val)
            degrees.append(d)

fig, ax = plt.subplots(figsize=(10, 6))
colors = {1: '#4e79a7', 2: '#f28e2b', 3: '#e15759'}
for d in [1, 2, 3]:
    vals = [v for v, deg in zip(values, degrees) if deg == d]
    ax.hist(vals, bins=50, alpha=0.6, label=f'degree {d}', color=colors[d])

ax.axvline(x=0, color='black', linewidth=2, linestyle='--', label='Zero (never reached)')
ax.set_xlabel('|p(e)|', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('No Integer Polynomial Vanishes at e', fontsize=14)
ax.legend()
plt.tight_layout()
plt.savefig('polynomial_nearness_e.png', dpi=150)
print('Saved polynomial_nearness_e.png')
