import matplotlib.pyplot as plt
import numpy as np

def euler_char(dim, k):
    return ((-1) ** (-dim)) * k

fig, ax = plt.subplots(figsize=(10, 6))
dims = list(range(0, -16, -1))
for k in [1, 2, 3, 5]:
    chis = [euler_char(d, k) for d in dims]
    ax.plot(dims, chis, 'o-', label=f'|π₀| = {k}', markersize=6)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Dimension')
ax.set_ylabel('Euler Characteristic χ')
ax.set_title('Euler Characteristic in Negative Dimensions')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('euler_sign_pattern.png', dpi=150)
plt.close()