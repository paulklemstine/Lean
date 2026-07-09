import random
import matplotlib.pyplot as plt

random.seed(0)
lam = sorted(random.uniform(0.5, 5.0) for _ in range(6))
d = len(lam)
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(range(1, d + 1), lam, color='C0')
ax.axhline(lam[0], ls='--', color='C2', label='lambda_1 (min)')
ax.axhline(lam[-1], ls='--', color='C3', label='lambda_d (max)')
ax.set_xlabel('index i'); ax.set_ylabel('lambda_i')
ax.set_title(f'trace sandwich: {d*lam[0]:.2f} <= {sum(lam):.2f} <= {d*lam[-1]:.2f}')
ax.legend(); fig.tight_layout()
fig.savefig('trace_sandwich.png', dpi=150)
print('saved trace_sandwich.png')
